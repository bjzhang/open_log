#!/usr/bin/perl
#find keyword(use -i to ingore case). keyword is the word at the next line of the date.
#-f search file. support globbing
#-k keyword, "A B" for match A and B. 
#-i ignore case

use strict;
use Encode;
use Getopt::Std;	#for getopts
use vars qw($opt_f $opt_k $opt_i $opt_c);

#get and process arguments.
print "argument is \"@ARGV\".\n";
getopts('f:k:ic:');

#filename
#print "$opt_f\n";
my $filename = $opt_f;  #$filename=test.txt
#get filename list
my @filelist = glob $filename;

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

foreach  (@filelist) {
	my $i = 0;
	my $cur_file = $_;
	open STDIN,"$cur_file";
	while(<>){
		#\todo check the file encoding and convert to utf8 if necessary.
		chomp;
#		print " Line is $_\n";
		$i++;
		if (/(
				# "15:16 2009-12-7"
				^\d{1,2}:\d{1,2}\ 20\d\d-\d{1,2}-\d{1,2}
			)|(
				# "#2006-8-7 21:07"
				^\#20\d\d\-\d{1,2}\-\d{1,2}\ \d{1,2}:\d{1,2}
			)|(
				# "#15:20 2006-3-10"
				^\#\d{1,2}:\d{1,2}\ 20\d\d\-\d{1,2}\-\d{1,2}
			)|(
				# "#20060519 2345"
				^\#20\d{6}\ \d{4}
			)
		/x) {
			my $date_line = $_;
#			print "find in $i\n";
			$_=<>;
			chomp;
			my $keyword_line = $_;
			$i++;
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
				print "\"$cur_file\"($keyword_line_num,0,$date_line): ";
				if ( $cur_env_locale eq "gb2312" ) {
					Encode::from_to($keyword_line, "utf8", "gb2312");
				}
				print "$keyword_line\n";
			}
		}
	}
}
