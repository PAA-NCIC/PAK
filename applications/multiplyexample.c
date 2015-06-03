#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define DATATYPE float
#define NX 3000
#define NY 3000
#define ITER 30
DATATYPE a[NX][NY];
DATATYPE b[NX][NY];
DATATYPE c[NX][NY];
int main()
{
    int i,j,t;

    for(i=0;i<NX;i++)
        for(j=0;j<NY;j++)
        {
            a[i][j]=rand();
            b[i][j]=rand();
            c[i][j]=rand();
        }
    for(t=0;t<ITER;t++)
        for(i=0;i<NX;i++)
            for(j=0;j<NY;j++)
                c[i][j]=a[i][j]*b[i][j]/c[j][i];

    //printf("result is %.2f\n",c[100][100]);
    return 0;
}
