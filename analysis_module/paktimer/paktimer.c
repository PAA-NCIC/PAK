#include <stdio.h>
#include <sys/time.h>
struct timeval t1;
struct timeval t2;

int main(int argc,char** argv)
{
    FILE *fp;
    double time;
    //printf("the target file is %s \n", argv[1]);
    gettimeofday(&t1,0);
    system(argv[1]);
    gettimeofday(&t2,0);
    time = ((((1000000.0 * (t2.tv_sec - t1.tv_sec)) + t2.tv_usec) - t1.tv_usec) / 1000000.0);
    
    if(fp=fopen("temp.time","wb"))
        fprintf(fp,"%.4f",time);

    return 0;
}
