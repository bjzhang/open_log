
use strict;
use warnings;

use Android;

my $droid = Android->new();

#pick operation: add, delete, modify, search. only support add and search in first version
my $operation = &selection(qw /增 删 查/);

#pick event: breast, water, washing, pipi, dabian, niaobu, weight, high, temperature
#only support english in early version.
my $event = &selection(qw /哺乳 洗澡 体重 身高 体温 补钙 鱼肝油 妈咪爱/);

#改写日期时间的为函数，增加event后内容。
my $year = `date +%Y`;
my $month = `date +%m`;
my $day = `date +%d`;
chomp $year;
chomp $month;
chomp $day;

$droid->dialogCreateAlert("date select");
$droid->dialogCreateDatePicker($year, $month, $day);
$droid->dialogShow();
my $response = $droid->dialogGetResponse()->{'result'};
$year = $response->{'year'};
$month = $response->{'month'};
$day = $response->{'day'};
print "date is $year, $month, $day\n";

if ( $month < 10 ) {
    $month = "0".$month; 
} 

my $path = "/sdcard/log";
if ( -e $path ) {
} else {
    $path = "/sdcard/external_sd/log";
} 

if ( $operation eq "增" ) {

#pick data and time: current, user input
my $hour = `date +%H`;
my $minute = `date +%M`;
chomp $hour;
chomp $minute;

$droid->dialogCreateAlert("time select");
$droid->dialogCreateTimePicker($hour, $minute, 1);
$droid->dialogShow();
$response = $droid->dialogGetResponse()->{'result'};
$droid->dialogDismiss(); 
$hour = $response->{'hour'};
$minute = $response->{'minute'};
print "time is $hour, $minute\n";
 
open LOG, ">> log".$year.$month."dog.txt";
print LOG "$year-$month-$day $hour:$minute $event\n";
close LOG; 

} elsif ( $operation eq "删") {
    open LOG, "< log".$year.$month."dog.txt";
    my @item;
    while (<LOG>) {
        chomp;
        if ( /$event/ ) {
            push @item, $_;
        }
    }
    close LOG;
    $droid->dialogCreateAlert("请选择要删除的条目"); 
    $droid->dialogSetMultiChoiceItems( [@item], [] );
    $droid->dialogSetPositiveButtonText("删除");
    $droid->dialogSetNegativeButtonText("取消");
    $droid->dialogShow();
    $response = $droid->dialogGetResponse()->{'result'};
    print "$response->{'which'}\n";
    my $t = $droid->dialogGetResponse()->{'select'};
#    print $t;
    my @selected_item = $droid->dialogGetSelectedItems()->{'result'};
#    my $selected_item_0 = $selected_item[0];
    my $i;
    foreach $i($selected_item[0]) {
#    for ( $i = 0; $i < $#item + 1; $i++ ) {
#        print "selected item 0 $selected_item[0][$i]\n";
        print "select $i\n";
    }
#    print "qwe $#selected_item\n";
#        print "qwe $selected_item[0][0]\n";
#        print "qwe $selected_item[0][1]\n";
#        print "qwe $selected_item[0][2]\n";
#        print "qwe $selected_item[0][3]\n";
#        print "qwe $selected_item[3]\n";

} elsif ( $operation eq "查" ) {
    open LOG, "< log".$year.$month."dog.txt";
    while (<LOG>) {
        if ( /$event/ ) {
            print;
        }
    }
    close LOG;
} else {
    print "error\n";
}

sub selection{
    my @list = @_;
    my $title = 'Alert';
    $droid->dialogCreateAlert($title);
    $droid->dialogSetItems( [ @list ] );
    $droid->dialogShow();
    my $response = $droid->dialogGetResponse()->{'result'}; 
    $droid->dialogDismiss();
    my $item = $response->{'item'};
    print "item is $item\n";
    my $result = $list[$item];
    print "result is $result.\n";
    $result = $list[$item]; 
}

