
use strict;
use warnings;

use Android;

my $droid = Android->new();

my $year = `date +%Y`;
my $month = `date +%m`;
chomp $year;
chomp $month;

my $file_extension = &selection;

my $title = 'Alert';
$droid->dialogCreateAlert($title);
$droid->dialogCreateDatePicker($year, $month, 1);
$droid->dialogShow();
my $response = $droid->dialogGetResponse()->{'result'};
$year = $response->{'year'};
$month = $response->{'month'};
my $day = $response->{'day'};
print "date is $year, $month, $day\n";

my $path = "/sdcard/log";
if ( -e $path ) {
} else {
    $path = "/sdcard/external_sd/log";
} 

if ( $month < 10 ) {
    $month = "0".$month; 
}

my $filename = $path."/log".$year."*".$file_extension.".txt"; 
 
my @filelist = glob $filename;
@filelist = sort @filelist;
print "find $#filelist $filename: \n";
foreach  (@filelist) {
print;
print " ";
}
print "filelist end\n";

if ( $#filelist >= 0 ) {
    $filename = "";
    foreach (@filelist) {
        if ( /$year$month[_0-9]*$file_extension\.txt/ ) {
            $filename = $_;
            last;
        }
    }
    if ( $filename eq "" ) {
        $filename = $path."/log".$year.$file_extension.".txt"; 
    }
} elsif ( $#filelist == -1 ) {
    $droid->makeToast("no such file.");
    exit;
}else {

}

print "open $filename\n";

$droid->view("file://".$filename,"text/plain");

sub selection{
    my $title = 'Alert';
    $droid->dialogCreateAlert($title);
    $droid->dialogSetItems( [ qw /vimicro think dog  other/ ] );
    $droid->dialogShow();
    my $response = $droid->dialogGetResponse()->{'result'};
    my $item = $response->{'item'};
    print "item is $item\n";
    my $result;
    if ( $item eq "0" ) {
        $result = "vimicro";
    } elsif ( $item eq "1" ) {
        $result = "thinking";
    } elsif ( $item eq "2" ) {
        $result = "HappyDog";
    } else {
        $result = "";
    }
}

