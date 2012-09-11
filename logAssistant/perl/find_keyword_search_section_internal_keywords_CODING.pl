#!/usr/bin/perl
#find keyword(use -i to ingore case). keyword is the word at the next line of the date.
#-f search file. support globbing
#-k keyword, "A B" for match A and B. 
#-i ignore case

use strict;
use Encode;
use Getopt::Std;	#for getopts
use vars qw($opt_f $opt_k $opt_i $opt_c);

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
getopts('f:k:ic:');

#filename
#print "$opt_f\n";
my $filename = $opt_f;  #$filename=test.txt
#get filename list
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

#content_keyword
#print "$opt_c\n";
my $content_key;
if ($opt_c) {
	$content_key=$opt_c;
	print "search $content_key in $keywords section.\n";
}

print "filename is \"$filename\"\n";

#convert keyword format from gb2312 to utf8. do nothing while it is already utf8.
eval {my $str = $keywords; Encode::decode("gb2312", $str, 1)};
my $cur_env_locale = "utf8";
if ( !$@ ){
#	Encode::from_to($keywords, "gb2312", "utf8");
	$keywords = Encode::decode("gb2312", $keywords);
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

my $match_count = 0;
foreach  (@filelist) {
	my $i = 0;
	my $cur_file = $_;
#	print "searching $cur_file.\n";
	open STDIN,"$cur_file";
	while(<>){
		#\todo check the file encoding and convert to utf8 if necessary.
		chomp;
#		print " Line is $_\n";
		$i++;
		my $cur_line = $_;
		my $is_sec_match = 0;
		foreach (@section_start_keywords) {
#			print "use $_ to match $cur_line.\n";
			if ( $cur_line =~ /^$_/ ) {
#			print "$cur_line match with $_.\n";
				$is_sec_match = 1;
				last;
			}
		}
		my $date_line;
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
		}
		if ( $is_sec_match ) {
#			my $date_line = $cur_line;
#			print "find in $i\n";
#			$cur_line=<>;
#			chomp $cur_line;
#			$i++;
			my $keyword_line = $cur_line;
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
						$is_match = 1;
#						print "match $keyword_utf8 in $keyword_line\n";
					} else {
						$is_match = 0; last;
					}
				} else {
					if ( $keyword_line =~ /$keyword_utf8/) {
						$is_match = 1;
#						print "match $keyword_utf8 in $keyword_line\n";
					} else {
						$is_match = 0; last;
					}
				}
			}
			if ( $is_match == 1) {
				my $keyword_line_num = $i;
				$match_count++;
				print "\"$cur_file\"($keyword_line_num,0,$date_line): ";
				if ( $cur_env_locale eq "gb2312" ) {
					Encode::from_to($keyword_line, "utf8", "gb2312");
				}
				print "$keyword_line\n";
			}
		}
	}
	close STDIN;
}
print "total $match_count times matches.\n";
