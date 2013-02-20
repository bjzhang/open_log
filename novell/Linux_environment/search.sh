#!/bin/bash

echo search $KEYWORD compare with $BASE

current_year=`date +%Y`
current_month=`date +%m`
current_day=`date +%d`
new=$BASE
while true; do
    current_year=$((current_year - 1))
    old=`git log --before=${current_year}-${current_month} -n 1 | grep ^commit | cut -d \  -f 2`
    echo compare with $BASE and $old
    git diff --no-ext-diff $old $BASE | grep $KEYWORD 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "got nothing, search previous year"
    else
        echo "got in this range"
        break
    fi
done

number=`git log $old..$new |grep ^commit | cut -d \  -f 2 | wc -l`
#echo $number
number=$((number / 2 + 1))
echo $number
mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`

while true; do
    echo new: $new, mid: $mid, old: $old, number: $number
    new_date=`git log --date=iso -n 1 $new |grep ^Date | sed "s/^Date:\ *//"`
    mid_date=`git log --date=iso -n 1 $mid |grep ^Date | sed "s/^Date:\ *//"`
    old_date=`git log --date=iso -n 1 $old |grep ^Date | sed "s/^Date:\ *//"`
    echo compare in $old..$mid, from $old_date to $mid_date
    git diff --no-ext-diff $old $mid | grep $KEYWORD #2>&1 > /dev/null
    if [ $? = 0 ]; then
        if [ $number -eq 1 ]; then
            result=$mid
            echo got in $result
            break
        fi
        echo got it in $old..$mid
        number=`git log $old..$mid |grep ^commit | cut -d \  -f 2 | wc -l`
        number=$((number + 1))
        number=$((number / 2))
        new=$mid
        mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`
        continue
    fi
    echo compare in $mid..$new, from $mid_date to $new_date
    git diff --no-ext-diff $mid $new | grep $KEYWORD #2>&1 > /dev/null
    if [ $? = 0 ]; then
        if [ $number -eq 1 ]; then
            result=$new
            echo got in $result
            break
        fi
        echo got it in $mid..$new
        number=`git log $mid..$new |grep ^commit | cut -d \  -f 2 | wc -l`
        number=$((number + 1))
        number=$((number / 2))
        old=$mid
        mid=`git log $new -n $number | grep ^commit | tail -n 1 | cut -d \  -f 2`
        continue
    fi
done

echo generating patch file
git format-patch $result^!

#search=virDomainObjLock; base=676688b69bb5761b74bd1e5bb491562bd6d3dd26;  for cs in `git log | grep commit | cut -d \  -f 2`; do echo "${cs}: ${search}"; git diff --no-ext-diff ${base} ${cs} | grep ${search}; done

#echo search $KEYWORD compare with $BASE
#
#current_year=`date +%Y`
#current_month=`date +%m`
#current_day=`date +%d`
#while true; do
#    echo search between ${current_year}-${current_month} and $((${current_year}-1))-${current_month}
#    current_year=$((current_year - 1))
#    commit=`git log --before=${current_year}-${current_month} | head -n 1 | cut -d \  -f 2`
#    echo compare with $BASE and $commit
#    git diff --no-ext-diff $BASE $commit | grep $KEYWORD 2>&1 > /dev/null
#    if [ $? -ne 0 ]; then
#        echo "got nothing, search previous year"
#    else
#        echo "got in this range"
#        break
#    fi
#done
#
#commit=`git log --after=${current_year}-${current_month} |grep ^commit | cut -d \  -f 2`
#number=`echo $commit | wc -w`
#echo $number
#number=$((number / 2 + 1))
#echo $number
#range="--after=${current_year}-${current_month} -n $number"
#echo $range
#
#while true; do
#    if [ $number -eq 1 ]; then
#        break
#    fi
#    if [ $number -eq 2 ]; then
#        break
#    fi
#    commit=`git log $range | grep ^commit | cut -d \  -f 2 | tail -n 1`
#    echo compare with $BASE and $commit in \"$range\"
#    git diff --no-ext-diff $BASE $commit | grep $KEYWORD 2>&1 > /dev/null
#    if [ $? -ne 0 ]; then
#        number=$((number / 2 + 1))
#        range="--after=${current_year}-${current_month} -n $number"
#    else
#        range="--after=${current_year}-${current_month} -n 1"
#    fi
#done
#
