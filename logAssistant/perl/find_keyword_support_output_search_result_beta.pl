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

#get and process arguments.

#output argument at new line for user copy
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
    print "output file is $output_file\n";
} else {
    print "no output file\n";
}

open OUTPUT_FILE, "> $output_file";
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
    my $status = 0;
    my @section_header = undef;
    my @section = undef;
    while(<>){
		#\todo check the file encoding and convert to utf8 if necessary.
		chomp;
		$i++;
		my $cur_line = $_;
		my $keyword_column = 0;

#        print "status: $status \@line<$i>\n";
        if (  1 == match_section_start($cur_line, "", "") ) {
            if ( $status == 4 ) {
                if ( @section != undef ) {
                    print OUTPUT_FILE @section_header;
                    print OUTPUT_FILE @section;
                }
            }
            #开始新的section.
            $date_line = $cur_line;
            $status = 1;
            @section = undef;
            @section_header = undef;
            push @section_header, "$_\n";
            next;
        }

        if ( $status == 1 ) {
            $status = 2;
            #每个section可能有多个section_keywords(多个时期时间段), 跳过这些. 
            if ( 1 == match_section_start($cur_line, "\\(", "\\)") ) {
#                print "skipping\@line<$i>: $_\n";
                push @section_header, "$cur_line\n";
                $status = 1;
            }
        }
        if ( $status == 2 ) {
            $keyword_line = $cur_line;
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
                push @section_header, "$_\n";
                $keyword_line_num = $i;
                if ( $content_key ) {
                    $status = 3;
                } else {
                    $status = 0;
                    $match_count++;
                    &print_content($keyword_line, $cur_file, $keyword_line_num, $keyword_column, $date_line);
                }
            } else {
                $status = 0;
            }
        } elsif ( $status == 3 || $status == 4 ) {
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
                if ( $status == 3 ) {
#                    &print_content($keyword_line, $cur_file, $keyword_line_num, $keyword_column, $date_line);
                    &print_content($keyword_line, "##################", "##################", "##################", "##################");
                } elsif ( $status == 4 ) {
                }
                &print_content($_, $cur_file, $i, 0, "");
                $status = 4;
            }
            push @section, "$_\n";
        }
	}
    if ( $status == 4 ) {
        if ( @section != undef ) {
            print OUTPUT_FILE @section_header;
            print OUTPUT_FILE @section;
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

sub match_section_start {
    #input parameter
    my $line = $_[0];
    my $start = $_[1];
    my $end = $_[2];
    #return parameter
    my $match = 0;
    #internal content
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

#    print "$line: start<$start>, end<$end>\n";
    foreach (@section_start_keywords) {
        if ( $line =~ /^$start$_$end/ ) {
#            print "match and return\n";
            $match = 1;
            last;
        }
    }
    $match;
}
