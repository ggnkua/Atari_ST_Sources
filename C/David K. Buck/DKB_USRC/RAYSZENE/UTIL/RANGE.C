/*  *** range.c *** 6.12.1990    */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ERROR(a) {printf("%s\n",a); exit(10);}
#define IS_DIGIT(a)     (48 <= a  && a <= 57)
#define SAMESTRING(a,b) (!(stricmp(a,b)))
#define UCHAR unsigned char
#define TRUE 1

int Help(void);

char outfmt[10];     /* default output string */

main(argc,argv)
int argc;
char *argv[];
{
    long arg,i,kpl,j,loop,rivikpl = 5;
    double alku,loppu,step;
    
    alku=loppu=kpl=j=loop=0;
    arg=4;

    strcpy(outfmt," % 7.2lf"); 
    
    argc--;
    if (argc < 3 ) 
    {
        Help();
        exit(10);
    }
    if (SAMESTRING(argv[1],"?"))
    {
        Help();
        exit(10);
    }
    if ( (!sscanf(argv[1],"%ld",&kpl))   || 
         (!sscanf(argv[2],"%lf",&alku))  || 
         (!sscanf(argv[3],"%lf",&loppu)) )
        ERROR("parameters must be numbers\n")
    
    while (arg <= argc)
    {
        if (SAMESTRING(argv[arg],"f"))
        {
            if ((argc - arg) < 2)
            {
                printf("F values_per_line output_format_string\n");
                ERROR("for example:  F 6 8.1")
            }
            if (!(sscanf(argv[arg+1],"%ld",&rivikpl)))
    		    ERROR("Can't read  VALUES_PER_LINE\n")
            if (strlen(argv[arg+2]) < 3)
    		    ERROR("Output format must be X.X, where X is a digit\n")
    	    if (!(IS_DIGIT(argv[arg+2][0])))
    		    ERROR("Output format must be X.X, where X is a digit\n")
            if (!(IS_DIGIT(argv[arg+2][2])))
    		    ERROR("Output format must be X.X, where X is a digit\n")
            outfmt[3] = argv[arg+2][0];
            outfmt[5] = argv[arg+2][2];
            arg+=3;
        }
        else
        if (SAMESTRING(argv[arg],"LOOP"))
        {
            loop = TRUE;
            arg++;
        }
        else
        {
            printf("Unknown option! %s\n",argv[arg]);
            Help();
            exit(0);
        }
        
    }
    
    step = ( loppu - alku ) / (kpl-(!loop));

    for(i=0; i<kpl; i++)
    {
        printf(outfmt, alku + i*step);
        j++;
        if (j == rivikpl)
        {
            printf("\n");
            j=0;
        }
    }
    printf("\n");
    return(0);
}


int Help(void)
{
    printf("version 1.2\n");
    printf("RANGE \t count beginning_value end_value\n");
    printf("\t [F values_per_line output_format_string] [LOOP]\n");
    return(0);
}
