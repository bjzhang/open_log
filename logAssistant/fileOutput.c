/*
功能见logAssistant.sh的说明. 
*/

/*修改记录*/
/*
01:04 2006-9-4
修改, 原: readLineNum只处理读取的第一行, 如果第一行中没有需要格式的行号, 就返回.
      现: 只有读到需要格式的行号, 或者文件结束才返回.
*/
/*
2006-10-10
0.20板:
1, 修正错误: 
现象: 如果seg文件为空, 搜索时会出错.
修改方法: 如果seg文件为空, 退出搜索.
原来为什么没有发现: (1)没有考虑这个问题,(2)原来的情况是seg文件不为空, 
以后怎么办:
(1)其实这个错误的原因就是文件使用前, 没有测试是否为空. 
总是不重视这类问题: 变量使用前判断是否可以使用(例如判断指针是否为空, 文件是否为空), 使用后销毁(释放指针申请的空间). 注意不要溢出. 
(2)每次的测试都不完整, 测试应该怎么做?
2, 加入xFilename和xFilenamePt, x表示seg, keyword, output, 这样便于文件名和文件指针的使用; 
*/

/*最初的算法见0.10版*/

#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>	/*for memset*/

//#define DEBUG

#ifdef DEBUG
      /* use specific keyword and seg file input file */
//    #define GDB_DEBUG
      /* use the first parameter as input file, test readLineNum() function  */ 
    #define READ_LINE_NUM_TEST
#endif


/*output how to use to program*/
void usage(void);

/*read a line from *fp, return the number in the beginning of the line which 
  ends with a seperater, return -1 if  file end.
  notes: We pass the address of the file. So,  this function changes its own 
  filepointer when it read the file. but the original file pointer is unchanged.
  after this function, we can use the original file pointer normally. 
*/
int readLineNum(FILE *fp);

int main(int ac, char *av[])
{
    char *keywordFilenamePt=NULL;
    FILE *keyword_fp=NULL;	/*关键字文件*/
    char *segFilenamePt=NULL;
    FILE *seg_fp=NULL;		/*标记文件*/
    char *outputFilenamePt=NULL;
    FILE *output_fp=NULL;	/*输出文件*/
    int currentSegLineNum, lastSegLineNum, currentKeywordLineNum;

#ifdef GDB_DEBUG
    char keywordFilename[]="log200610.txt.keyword";
    char segFilename[]="log200610.txt_seg";
#endif//GDB_DEBUG ends
    char outputFilename[]="standard output";

#ifdef READ_LINE_NUM_TEST
    FILE *fp;
    if ( ac == 2 ) {
        if ( (fp = fopen( *++av, "r" ) ) == NULL ) {
            printf("open file %s error\n", *av);
            exit(1);
        }
        int currentLineNum = -1;
        while ( ( currentLineNum = readLineNum(fp) ) != -1 ) {
            fprintf(stdout,"currentLineNum = %d\n", currentLineNum);
        }
        return 0;
    }
#endif/*READ_LINE_NUM_TEST ends*/

    if ( ac < 3 ) {
#ifdef GDB_DEBUG
        //only for test, specific the file which you already creade for the test
        keywordFilenamePt=keywordFilename;
        segFilenamePt=segFilename;
        outputFilenamePt=outputFilename;
        output_fp = stdout;
#else
        fputs("need two input file\n",stdout);
        usage();
        return 1;
#endif/*GDB_DEBUG ends*/
    } else {
        if ( ac == 3 ) {
            outputFilenamePt=outputFilename;
            output_fp = stdout;
        } else if ( ac == 4 ) {
            /*"a" means output at the end of this file*/
            outputFilenamePt= *(av+3);
            if ( ( output_fp = fopen( outputFilenamePt, "a" ) ) == NULL  ) {
                printf("open file %s error\n", outputFilenamePt);
                exit(1);
            }
        }
        keywordFilenamePt=*(av+1);
        segFilenamePt=*(av+2);
    }
    if ( ( keyword_fp = fopen(keywordFilenamePt, "r" ) ) == NULL ) {
        printf("open keyword file \"%s\" error\n", keywordFilenamePt);
        exit(1);
    }
    if ( ( seg_fp = fopen(segFilenamePt, "r" ) ) ==NULL ) {
        printf("open seg file \"%s\" error\n", segFilenamePt);
        exit(1);
    }

    if ( ( lastSegLineNum = readLineNum(seg_fp) ) == -1 ) {
//           || readLineNum(keyword_fp)  == -1) {
        fclose(seg_fp);
        fclose(keyword_fp);
        if ( ac == 4 ) {
            fclose(output_fp);
        }
        printf("no data in file, exit.\n");
        exit(1);
    }

    fprintf(output_fp, "echo \"result in %s\"\n", keywordFilenamePt);
    while( ( currentKeywordLineNum = readLineNum(keyword_fp) ) != -1 ) {
/*        fprintf(output_fp, "currentKeywordLineNum = %d\n", 
                currentKeywordLineNum);
*/
        int exitSearchSegfile=0;
        while (!exitSearchSegfile) {
            if ( currentKeywordLineNum < lastSegLineNum  ) {
/*                fprintf(output_fp, "lastSegLineNum  = %d\n", lastSegLineNum );
*/
                exitSearchSegfile=1;
            } else {
                if ( ( currentSegLineNum = readLineNum(seg_fp) ) == -1 ) {
                    break;
                }
/*                fprintf(output_fp, "currentSegLineNum = %d\n", 
                       currentSegLineNum);
*/
                if ( currentKeywordLineNum < currentSegLineNum 
                     && currentKeywordLineNum > lastSegLineNum ) {
                    fprintf(output_fp,"echo start at\n");
                    fprintf(output_fp,"head -n %d $1 | tail -n %d\n",
                            currentSegLineNum, 
                            currentSegLineNum-lastSegLineNum+1);
                    fprintf(output_fp,"echo This segment end\n");
                    fprintf(output_fp,"echo\n");
                    exitSearchSegfile=1;
                }
                lastSegLineNum = currentSegLineNum;
            }
        }
    }
    fclose(seg_fp);
    fclose(keyword_fp);
    if ( ac == 4 ) fclose(output_fp);
    return 0;
}

void usage()
{
    fputs("\nusage\n",stdout);
    fputs("fileOutput keywordFilename segFilename\n",stdout);
    fputs("or\n",stdout);
    fputs("fileOutput keywordFilename segFilename outputFilename\n",stdout);
}

/*using the third arithmetic*/
int readLineNum(FILE *fp)
{
    const char SEPERATER = ':';
    const int CHAR_ARRAY_LEN = 6;
    const int LINE_LEN=100;
    int lineNum = -1;
    char newLine[LINE_LEN];
    char *newLinePt=newLine;
    char digitArray[CHAR_ARRAY_LEN];
    char *digitArrayPt=digitArray;

startReadLine:    
    if ( fgets(newLine, LINE_LEN, fp) == NULL ) {
        lineNum = -1;
    } else if ( isdigit(*newLinePt) != 0 ) {
         while ( ( *digitArrayPt = *newLinePt++ ) != '\0'  ) {
            if ( isdigit( *digitArrayPt ) ) {
                digitArrayPt++;
            } else if ( *digitArrayPt == SEPERATER ) {
                digitArrayPt++;
                lineNum=atoi(digitArray);
                break;
            } else {
                goto startReadLine;
            }
        }
    } else {
        goto startReadLine;
    }
    return lineNum;
}
