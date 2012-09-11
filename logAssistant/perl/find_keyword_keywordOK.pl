#!/usr/bin/perl
#find keyword(ignoring case). keyword is the word at the next line of the date.

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
my $regexp=$opt_k;      #$regexp=123

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
	print "search $content_key in $regexp section.\n";
}

print "regular expression is \"$regexp\", filename is \"$filename\"\n";

#convert keyword format from gb2312 to utf8. do nothing while it is already utf8.
eval {my $str = $regexp; Encode::decode("gb2312", $str, 1)};
my $cur_env_locale = "utf8";
if ( !$@ ){
	Encode::from_to($regexp, "gb2312", "utf8");
	$cur_env_locale = "gb2312";
}
print "current environment locale is $cur_env_locale.\n";

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
			$i++;
#			print "$_\n";
			my $is_match=0;
			if ( $opt_i ) {
				if (/$regexp/i) {
					$is_match = 1;
				}
			} else {
				if (/$regexp/) {
					$is_match = 1;
				}			
			}
			if ( $is_match == 1) {
				my $keyword_line = $_;
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
