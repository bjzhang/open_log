
use strict;
use warnings;

use Android;

my $droid = Android->new();

my $year = `date +%Y`;
my $month = `date +%m`;
chomp $year;
chomp $month;

my $file_extension = &selection;

my $path = "/sdcard/log";
if ( -e $path ) {
} else {
    $path = "/sdcard/external_sd/log";
} 

my $filename = $path."/log".$year.$month.$file_extension.".txt";

if ( -e $filename ) {
} else {
    $filename = $path."/log".$year.$file_extension.".txt";
}
$droid->view("file://".$filename,"text/plain");

sub selection{
    my $title = 'Alert';
    $droid->dialogCreateAlert($title);
    $droid->dialogSetItems( [ qw /vimicro think other/ ] );
    $droid->dialogShow();
    my $response = $droid->dialogGetResponse()->{'result'};
    my $item = $response->{'item'};
    print "item is $item\n";
    my $result;
    if ( $item eq "0" ) {
        $result = "vimicro";
    } elsif ( $item eq "1" ) {
        $result = "thinking";
    } else {
        $result = "";
    }
}

