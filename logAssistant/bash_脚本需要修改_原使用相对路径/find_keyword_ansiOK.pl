#!/usr/bin/perl

use strict;

print "argument is \"@ARGV\".\n";
my $filename=shift @ARGV;
my $regexp=shift @ARGV;

print "filename is \"$filename\", regular expression is \"$regexp\"\n";

my $i = 0;
open STDIN,"$filename";
while(<>){
	chomp;
#	print " Line is $_\n";
	$i++;
	if (/^(\d?\d:\d?\d\ 20\d\d-\d?\d-\d?\d)/) {
#		print "$i: find \"$1\" in $_\n";
		$_=<>;
		chomp;
		$i++;
#		print "$_\n";
		if (/$regexp/) {
			print "\"$filename\"($i): ";
			print "$_\n";
		}

	}
}
