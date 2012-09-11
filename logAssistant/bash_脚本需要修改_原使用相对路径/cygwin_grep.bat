@echo off

d:
chdir d:\cygwin\bin

bash --login -i

grep -f home/newKeyword home/host1110.txt >> home/result1110.txt
