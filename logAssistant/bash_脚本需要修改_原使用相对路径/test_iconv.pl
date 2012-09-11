#!/usr/bin/perl

my $file = shift @ARGV;

open STDIN, $file;

system 'iconv -f utf8 -t gb2312';
