#!/bin/bash
#ver0.12, 起始编号为0.10
#2006-9-6完成
#2006-9-6__9-8修改, ver0.11
#1 (9-6)由于每次查的关键字不一定相同, 只是判断$file和${file}_keyword新旧没有意义. 改为判断$file和${file}.$keyword的新旧, 不用_$keyword, 是为了避免关键字是seg时, 与${file}_seg重名.
#2 把默认的输出文件改为output.$keyword
#3 (9-7)把$currentFilename改为$currentFile. ${currentFile}_seg改为$currentFileSeg}. ${currentFile},$keyword改为$currentFileKeyword}.这样更简洁一些。另外，文件名中暂时不用$keyword这种形式，如果是中文关键字，linux无法识别。
#4 _seg和.keyword文件显得要搜索关键字的目录很乱，脚本处理完成后，直接删除_seg和.keyword文件。等脚本中加入了工作目录后，把_seg和.keyword文件放到一个单独的目录。
#5 (9-8)加入第三个参数，可以要搜索的文件名, 不能使用通配符.
#2006-10-11修改
#改进对日期的搜索
#grep  "[0-9]\{1,2\}:[0-9]\{1,2\} 200[0-9]-[0-9]\{1,2\}-[0-9]\{1,2\}" filename
#搜索"y:y 200x-y-y"形式的数据, 其中x表示一位数字, y表示一位或两位数字
#grep "#200[0-9]-[0-9]\{1,2\}-[0-9]\{1,2\} [0-9]\{1,2\}:[0-9]\{1,2\}" filename
#搜索"#200x-y-y y:y"形式的数据.
# grep -v -E "(\(|\))" filename表示把包含"("或")"的内容去掉
#但是(1)"^"和"$"表示行开始和行结束的符号没有起作用, 可能是和bash shell符号或用法有冲突, 查***(2)检索的年份是2000-2009年, 要根据需要修改 (2)没有限制日期, 时间的格式, "99:34 2005-13-34"的日期也会检索出来.
#2006-10-15修改
#改进对日期的搜索
#搜索200yyyyy yyyy形式的日期
#grep -n "#200[0-9]\{5,5\} [0-9]\{4,4\}" $currentFile >> ${currentFileSeg}.temp
#2006-10-16修改
#1, 为了避免冲突规定如果不是seg标志的日期, 要加入""".
#  grep -v -E "(\"|\")" filename表示把包含"""的内容去掉
#2, 在搜索seg时在文件结尾插入一个临时的seg(99:99 2009-99-99), 这样文件末尾的信息也有显示在结果中. 而且不影响日志文件的生成. 原有方法是手工在要搜索的文件结尾加入日期, 这样建立日志时不方便, 不利于以后实现日志的自动插入.

#基本功能
#用于输出包含关键字的在分段标记中间的内容.
#一, 使用说明: 
#1,把logAssistant.sh和fileOutput加入到PATH路径. 
#例如: 这两个文件都位于/home/bamv2006/UnixProgramming
#PATH=$PATH:/home/bamv2006/UnixProgramming
#env $PATH
#可以看到/home/bamv2006/UnixProgramming已经加入到了路径中.
#不建议把这个路径加入到启动脚本中, 那样如果与到重名的logAssistant.sh或
#fileOutput, 可能会出现难以预料的结果.
#2, 参数说明见usage函数. 不输入参数直接运行脚本同样显示使用方法.
#二, 功能说明: 搜索当前目录中*.txt文件包含keyword的内容. 把包括行号的结果保存到
#"filename.keyword"文件中, 搜索当前目录中*.txt文件包含分段标记(日期,形如
#'#20061016 1647', '#2006-10-16 16:47', '16:47 2006-10-16')的内容. 把包括行号的
#结果保存到_seg文件中. 用fileOutput函数把"filename.keyword"文件中行号位于
#"filename_seg"文件行号的"filename_seg"文件行号信息保存. 用head和tail命令输出
#原文件中这些行号之间的内容. 

#例如: test.txt(不包括"#")
#2006-9-1 00:01
#test
#2006-9-2 00:01
#zhangjian
#2006-9-4 00:01
#bamvor
#2006-9-4 00:01
#执行logAssistant zhangjian myOutput
#....
#output result?
#y
#2006-9-2 00:01
#zhangjian
#2006-9-4 00:01


#definition function.
usage() {
    #show how to use this script
    echo "The first parameter is the keyword"
    echo "The second parameter is output file."
    #使用单引号"'", 这样单引号内部的内容是按原样显示的, 不替换变量, 转义字符等
    echo '    if not, using "output.keyword" as default'
    echo "The third parameter is input file."
    echo '    if not, using "*.txt" as default'
}
#function definition ends

#get keyword
if [ "$1" = "" ]; then
    echo "no parameter."
    usage
    exit 0
else
    keyword=$1
fi

#get outputFile, if it already exists, backup it and create a new one.
if [ "$2" = "" ]; then
    outputFile=output.keyword
else
    outputFile=$2
fi
echo "using \"${outputFile}\" as output filename"
if [ -f $outputFile ]; then
    echo "$outputFile already exist, exit"
    exit
fi

#get the file list
if [ "$3" = "" ]; then
#2006-9-6, change `ls` to `ls *.txt`
    filename=`ls *.txt`
else
    filename=`ls $3`
fi
echo "using \"$filename\" as input filename"

#search each file in $filename and output the all result in outputFile
for currentFile in $filename
do
    currentFileSeg=${currentFile}_seg
    currentFileKeyword=${currentFile}.keyword

    if [ -f $currentFile ];then
        #add a segment to the tail of the $currentFile temporarily, or we 
        #can not get the lastest message.
        cp $currentFile ${currentFile}.bak
        echo "99:99 2009-99-99" >> $currentFile

        #creating $currentFileKeyword
        echo "search $keyword in $currentFile"
        grep -n -o $keyword $currentFile > $currentFileKeyword
 
        #creating or updating $currentFileSeg. after it, sort the line number
        #in  $currentFileSeg. 
        if [ $currentFile -nt  $currentFileSeg ]; then

            echo "search seg_seperater in $currentFile"
            grep -n "[0-9]\{1,2\}:[0-9]\{1,2\} 200[0-9]-[0-9]\{1,2\}-[0-9]\{1,2\}" $currentFile > ${currentFileSeg}.temp
            grep -n "#200[0-9]-[0-9]\{1,2\}-[0-9]\{1,2\} [0-9]\{1,2\}:[0-9]\{1,2\}" $currentFile >> ${currentFileSeg}.temp
            grep -n "#200[0-9]\{5,5\} [0-9]\{4,4\}" $currentFile >> ${currentFileSeg}.temp
            grep -v -E "(\(|\))" ${currentFileSeg}.temp \
            | grep -v -E "(\"|\")"  > $currentFileSeg
            sort -g $currentFileSeg > ${currentFileSeg}_result
            mv ${currentFileSeg}_result $currentFileSeg
        else
            echo "$currentFileSeg is up to date"
        fi

        #using fileOutput ( write by myself ). output the script for display 
        # the result in each file. and then run each script output to 
        # $outputFile
        if [ -f ${currentFile}_output ]; then
            mv ${currentFile}_output ${currentFile}_output.bak
        fi
        fileOutput $currentFileKeyword $currentFileSeg ${currentFile}_output
        chmod 755 ${currentFile}_output
        ./${currentFile}_output $currentFile >> $outputFile
        if [ -f ${currentFile}_output.bak ]; then
            mv ${currentFile}_output.bak ${currentFile}_output
        fi

        #恢复原文件
        mv ${currentFile}.bak $currentFile
        #删除中间文件
        rm $currentFileKeyword
        rm $currentFileSeg
        rm ${currentFileSeg}.temp
        rm -f ${currentFile}_output

        echo
    fi
done

echo "successful. result in $outputFile"
echo "output result?(y/n)"
read isOutput
if [ "$isOutput" = "Y" ] || [ "$isOutput" = "y" ]; then
    cat $outputFile | more
fi
echo "end script"

