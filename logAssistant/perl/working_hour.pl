#输出filename的每天上班时间(日期: 上班时间). 
#将来要用find_keyword.pl实现. 
#usage:
#working_hour.pl filename

use Encode;

$filename = shift @ARGV;

$keyword="时间管理";
Encode::from_to($keyword,"gb2312", "utf8");

open STDIN, $filename;
$last_date_time;
$last_date;
while(<>){
	if (/$keyword/) {
#		Encode::from_to($_, "utf8", "gb2312");
#		print;
		$_=<>;
		if (/0,/) {
			s/0,\ (\d\d?:\d\d?).*/$1/;
			Encode::from_to($_, "utf8", "gb2312");
			print "$last_date: $_";
		}
	}
	$last_date_time = $_;
	chomp $last_date_time;
	$last_date_time =~ s/\d\d?:\d\d?\ (\d\d\d\d-\d\d?-\d\d?)/$1/;
	$last_date = $last_date_time;
}
close STDIN;
