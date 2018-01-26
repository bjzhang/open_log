
# `test_script` test cases
```
$ . /Users/bamvor/works/open_log/productivity/Linux_environment/utils/functions.sh
$ test_script
It is in the main shell
$ bash ./test__test_script.sh
It is in a shell script
$ ssh -t localhost '. /Users/bamvor/works/open_log/productivity/Linux_environment/utils/functions.sh; test_script'
It is in the main shell
Connection to localhost closed.
$ ssh  localhost '. /Users/bamvor/works/open_log/productivity/Linux_environment/utils/functions.sh; test_script'
It is in the main shell
$ ssh -t localhost 'bash /Users/bamvor/works/open_log/productivity/Linux_environment/utils/test__test_script.sh'
It is in a shell script
Connection to localhost closed.
$ ssh  localhost 'bash /Users/bamvor/works/open_log/productivity/Linux_environment/utils/test__test_script.sh'
It is in a shell script
```

# `smart_exit` test cases
```
$ . functions.sh
$ smart_exit
return from function
1
$ smart_exit 2
return from function
2
$ bash ./test__smart_exit.sh
exit from script shell
$?
1
$ bash ./test__smart_exit.sh 128
exit from script shell
$?
128
```
