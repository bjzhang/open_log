#!/usr/bin/perl
#find keyword(use -i to ingore case). keyword is the word at the next line of the date.
#-f search file. support globbing
#-k keyword, "A B" for match A and B. 
#-i ignore case
#
#buglist:
#1, there must be a empty line at the beginning and the end of the file.

use strict;
use Encode;
use Getopt::Std;	#for getopts
use vars qw($opt_f $opt_k $opt_i $opt_c $opt_o $opt_a);
use IO::Handle;     #for autoflush
use File::Basename; #for basename

autoflush STDOUT 1;

#define section start/end pattern
#remove ^. add it while match
#caution: using ' not " in the following regular expression
my @section_start_keywords =
	(
		# "15:16 2009-12-7"
		'\d{1,2}:\d{1,2}\ 20\d\d-\d{1,2}-\d{1,2}',
		# "#2006-8-7 21:07"
		'\#20\d\d\-\d{1,2}\-\d{1,2}\ \d{1,2}:\d{1,2}',
		# "#15:20 2006-3-10"
		'\#\d{1,2}:\d{1,2}\ 20\d\d\-\d{1,2}\-\d{1,2}',
		# "#20060519 2345"
		'\#20\d{6}\ \d{4}'
	);

#get and process arguments.

#output argument at new line for user copy
#print "argument is \"@ARGV\".\n";
print "argument is \n@ARGV.\n";
getopts('f:k:ic:o:a');

#filename
#print "$opt_f\n";
my $filename = $opt_f;  #$filename=test.txt
#get filename list
$filename =~ s/\\/\\\\/g;
my @filelist = glob $filename;
#sort and reverse the filelist in order the search the last data work log.
#notes: i do not case that search logAllOther..., logEmbedded..., and other 
#small log files before log201002*.txt
@filelist = sort @filelist;
#print "after sort: \n";
#foreach  (@filelist) {
#	print;
#	print " ";
#}
#print "\n";
@filelist = reverse @filelist;
#print "after reverse : \n";
#foreach  (@filelist) {
#	print;
#	print " ";
#}
#print "\n";

#keyword
#print "$opt_k\n";
my $keywords=$opt_k;      #$keywords=123
print "search \"$keywords\" in file.\n";

#ingore case or not
if ($opt_i) {           #如果有"i"选项, $opt_i为真
	print "ingore case.\n";
} else {
	print "not ingore case.\n";
}

#output search result or not
my $output_file;
if ( $opt_o ) {
    $output_file = $opt_o;
    print "output file is x:/output.txt\n";
} else {
    print "no output file\n";
}

open OUTPUT_FILE, "> h:/output.txt";
#第一行如果是日期时间, 脚本没法识别
print OUTPUT_FILE "\n";

#content_keyword
#print "$opt_c\n";
my $content_key;
if ($opt_c) {
	$content_key=$opt_c;
}

print "filename is \"$filename\"\n";

#convert keyword format from gb2312 to utf8. do nothing while it is already utf8.
eval {my $str = $keywords; Encode::decode("gb2312", $str, 1)};
my $cur_env_locale = "utf8";
if ( !$@ ){
#	Encode::from_to($keywords, "gb2312", "utf8");
	$keywords = Encode::decode("gb2312", $keywords);
	$content_key = Encode::decode("gb2312", $content_key);
	$cur_env_locale = "gb2312";
}
print "current environment locale is $cur_env_locale.\n";

#get keyword list from $keywords
my @keyword_list = split/\ +/, $keywords;
print "I will search the following keywords: ";
foreach  (@keyword_list) {
	my $keyword;
	if ( $cur_env_locale eq "gb2312" ) {
		$keyword = Encode::encode("utf8", $_);
		Encode::from_to($keyword, "utf8", "gb2312");
	}
	print "\"$keyword\",";
}
print "\n";

#get content_key list from $content_key
#暂时不支持多个关键字. 
my @content_key_list = split/\ +/, $content_key;
print "I will search the following keywords in section content: ";
foreach  (@content_key_list) {
	my $keyword;
	if ( $cur_env_locale eq "gb2312" ) {
		$keyword = Encode::encode("utf8", $_);
		Encode::from_to($keyword, "utf8", "gb2312");
	}
	print "\"$keyword\",";
}
print "\n";

my $match_count = 0;
my $keyword_line_num = 0;
my $keyword_line = "";
my $date_line = "";
foreach  (@filelist) {
	my $i = 0;
	my $cur_file = $_;
#	print "searching $cur_file.\n";
    if(!open STDIN, $cur_file){
        die "Cannot open $cur_file: $!";
    }

    # 这个变量不是每行都清零, 开始是每行都清零, 所以不正确. 
    my $in_sec = 0;
    my $status = 0;
    my @section_header = undef;
    my @section = undef;
    while(<>){
		#\todo check the file encoding and convert to utf8 if necessary.
		chomp;
#		print " Line is $_\n";
		$i++;
		my $cur_line = $_;
		my $is_sec_match = 0;
		my $keyword_column = 0;

#        print "$in_sec @ $i\n";
        foreach (@section_start_keywords) {
#			print "use $_ to match $cur_line.\n";
            if ( $cur_line =~ /^$_/ ) {
#                print "$cur_line match with $_ @ $i.\n";
                $is_sec_match = 1;
                if ( $status == 4 ) {
                    print "print matched section.\n";
                    if ( @section != undef ) {
                        print OUTPUT_FILE @section_header;
                        print OUTPUT_FILE @section;
                        print OUTPUT_FILE "\n";
                    }
                }
                $status = 1;
                #开始新的section.
                $in_sec = 0;
                @section = undef;
                @section_header = undef;
                last;
            }
        }

        if ( $status == 1 ) {
            #每个section可能有多个section_keywords(多个时期时间段), 跳过这些. 
            if ( $is_sec_match ) {
                $date_line = $cur_line;
                while ( $is_sec_match == 1 ) {
                    $is_sec_match = 0;
                    $cur_line=<>;
                    if ( !$cur_line ) {
                        #这个地方用"last"其实不好. 退出当前while后, 还有执行
                        #"while(<>)"才退出. 说到底是代码结构不好导致的难以维护. 
                        last;
                    }
                    chomp $cur_line;$i++;
                    foreach (@section_start_keywords) {
    #					print "use $_ to match $cur_line($i).\n";
                        if ( $cur_line =~ /^\($_\)/ ) {
    #					print "$cur_line match with $_.\n";
                            $is_sec_match = 1;
                            last;
                        }
                    }
                }
                $is_sec_match = 1;
                $status = 2;
            }
        }

        if ( $status == 2 ) {
            if ( $is_sec_match ) {
    #			my $date_line = $cur_line;
    #			print "find in $i\n";
    #			$cur_line=<>;
    #			chomp $cur_line;
    #			$i++;
                $keyword_line = $cur_line;
    #			print "$_\n";
                my $is_match=0;
                my $keyword;
                foreach  $keyword (@keyword_list) {
    #				print "current keyword is $keyword, want to match $keyword_line.\n";
                    #encode perl internel code with utf8. it only close the utf8 
                    #flag because the internel charset already utf8(utf8 flag on)
                    my $keyword_utf8 = Encode::encode("utf8", $keyword);
                    if ( $opt_i ) {
                        if ( $keyword_line =~ /$keyword_utf8/i) {
                            if (!$is_match) {
                                $keyword_column = strlen($`, $cur_env_locale) + 1;
                            }
                            $is_match = 1;
    #						print "match $keyword_utf8 in $keyword_line\n";
                        } else {
                            $is_match = 0; last;
                        }
                    } else {
                        if ( $keyword_line =~ /$keyword_utf8/) {
                            if (!$is_match) {
                                $keyword_column = strlen($`, $cur_env_locale) + 1;
                            }
                            $is_match = 1;
    #						print "match $keyword_utf8 in $keyword_line\n";						
                        } else {
                            $is_match = 0; last;
                        }
                    }
                }
                if ( $is_match == 1) {
                    $status = 3;
                    $keyword_line_num = $i;
                    if ( $content_key ) {
                        $in_sec = 1; 
                        push @section_header, "$date_line\n";
                        push @section_header, "$keyword_line\n";
                    } else {
                        $match_count++;
                        &print_content($keyword_line, $cur_file, $keyword_line_num, $keyword_column, $date_line);
                    }
                }
            }
        }

        if ( $status == 3 || $status == 4 ) {
            if ( $in_sec ) {
    #            print "search section content @ $i\n";
                my $content_key_utf8 = Encode::encode("utf8", $content_key);
                my $content_match = 0;
                if ( $opt_i ) {
                    if ( /$content_key_utf8/i ) {
                        $content_match = 1;
                    }
                } else {
                    if ( /$content_key_utf8/ ) {
                        $content_match = 1;
                    }
                }
                if ( $content_match ) {
                    $match_count++;
                    $status = 4;
                    if ( $in_sec < 2 ) {
    #                    &print_content($keyword_line, $cur_file, $keyword_line_num, $keyword_column, $date_line);
                        &print_content($keyword_line, "##################", "##################", "##################", "##################");
                    } else {
    #                    print "$in_sec\n";
                    }
                    &print_content($_, $cur_file, $i, 0, "");
                    $in_sec++;
                }
                push @section, "$_\n";
            }
        }
	}
    if ( $status == 4 ) {
        print "print matched section.\n";
        if ( @section != undef ) {
            print OUTPUT_FILE @section_header;
            print OUTPUT_FILE @section;
            print OUTPUT_FILE "\n";
        }
    }
	close STDIN;
}

close OUTPUT_FILE;
print "total $match_count times matches.\n";


sub strlen {	
	my $length;
	my $str_utf8 = $_[0];
	my $cur_env = $_[1];

	if ( $cur_env eq "gb2312" ) {
		Encode::from_to($str_utf8, "utf8", "gb2312");
	}
	$length = length($str_utf8);
}

#print $content(in current locale) and its info: filename, line number, column, data line
#e.g.
#"\\10.0.13.101\share\zhangjian\log\log201009vimicro.txt"(1422,1,17:04 2010-9-19): VC0882, Linux, 移植
sub print_content {
    my $content = $_[0];
    my $filename = $_[1];
    my $content_line_num = $_[2];
    my $content_column   = $_[3];
    my $time             = $_[4];

#    $filename = basename $filename;
    print "\"$filename\"($content_line_num,$content_column,$time): ";
    if ( $cur_env_locale eq "gb2312" ) {
        Encode::from_to($content, "utf8", "gb2312");
    }
    print "$content\n";
}
