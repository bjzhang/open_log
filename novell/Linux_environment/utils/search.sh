#!/bin/bash
#help
#1, search function add:
#search.sh -k "^+libxlDomainCreateXML", will got 0001-Add-libxenlight-driver.patch, commit: 2b84e445d598894c711278afacfbb9247333bdd8
#search.sh -k "static.void.umlNotifyLoadDomain", will got 0001-Add-domain-events-support-to-UML-driver.patch

while getopts 'b:k:' opt; do
    case $opt in
        b)
            base=$OPTARG
            ;;
        k)
            keyword=$OPTARG
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

if [ -z $base ]; then
    echo "Warning: base commit empty, using HEAD instead"
    base=`git log -n 1 | grep ^commit | cut -d \  -f 2`
fi

if [ -z $keyword ]; then
    echo "Error: keyword should not empty, exit"
    exit 1
fi

echo search \"$keyword\" compare with \"$base\"

current_year="2012"
current_month="01"
current_day="20"
#current_year=`date +%Y`
#current_month=`date +%m`
#current_day=`date +%d`
new=$base
end_of_commit=0
while true; do
    current_year=$((current_year - 1))
    old=`git log --before=${current_year}-${current_month} -n 1 | grep ^commit | cut -d \  -f 2`
    if [ -z $old ]; then
#        current_year=$((current_year + 1))
#        old=`git log --before=${current_year}-${current_month} | grep ^commit | tail -n 1 | cut -d \  -f 2`
#        end_of_commit=1
        echo could not handle the earlyest year. exit
        exit 1
    fi
    echo compare with $old and $new
    git diff --no-ext-diff $old $new | grep $keyword #2>&1 > /dev/null
    if [ $? = 0 ]; then
        echo "got in this range"
        break
    else
#        if [ $end_of_commit -eq 1 ]; then
#            echo "end of commit, exit"
#            exit 1;
#        else
            echo "got nothing, search previous year"
            new=$old
#        fi
    fi
done

number=`git log $old^..$new |grep ^commit | cut -d \  -f 2 | wc -l`
echo total commit number: $number
number=$(((number + 1) / 2))
mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`

while true; do
    echo new: $new, mid: $mid, old: $old, number: $number
    new_date=`git log --date=iso -n 1 $new |grep ^Date | sed "s/^Date:\ *//"`
    mid_date=`git log --date=iso -n 1 $mid |grep ^Date | sed "s/^Date:\ *//"`
    old_date=`git log --date=iso -n 1 $old |grep ^Date | sed "s/^Date:\ *//"`
    echo compare in $old..$mid, from $old_date to $mid_date
    git diff --no-ext-diff $old $mid | grep $keyword #2>&1 > /dev/null
    if [ $? = 0 ]; then
        if [ $number -eq 1 ]; then
            result=$mid
            echo got in $result
            break
        fi
        echo got it in $old..$mid
        number=`git log $old^..$mid |grep ^commit | cut -d \  -f 2 | wc -l`
        number=$((number + 1))
        number=$((number / 2))
        new=$mid
        mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`
        continue
    fi
    echo compare in $mid..$new, from $mid_date to $new_date
    git diff --no-ext-diff $mid $new | grep $keyword #2>&1 > /dev/null
    if [ $? = 0 ]; then
        if [ $number -eq 1 ]; then
            result=$new
            echo got in $result
            break
        fi
        echo got it in $mid..$new
        number=`git log $mid^..$new |grep ^commit | cut -d \  -f 2 | wc -l`
        number=$((number + 1))
        number=$((number / 2))
        old=$mid
        mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`
        continue
    fi
done

echo generating patch file
git format-patch $result^!

