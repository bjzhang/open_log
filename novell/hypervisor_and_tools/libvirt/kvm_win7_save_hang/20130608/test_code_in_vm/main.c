
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
    int i  = 0;
    int total = 0;
    const int per = 100*1024*1024;
    int *ptr = NULL;
    int j = 0;

    for ( i = 0; ; i++) {
        ptr = (int*)malloc(per*sizeof(int));
        if ( NULL != ptr ) {
            total += per;
        } else {
            goto sleep_a_while;
        }

        for ( j = 0; j < per; j++ ) {
            *ptr++ = j + (int)ptr;
            if ( j % 10000 == 0 )
                printf("j = %d\n", j);
        }
        printf("total malloc %d\n", total);
        ptr = NULL;
    }
    return 0;
sleep_a_while:
    for ( i = 0; i < 1000000; i++ ){
        for ( j = 0; j < 10000; j++ ) {;}
    }
    printf("sleep return");
    return 0;
}
