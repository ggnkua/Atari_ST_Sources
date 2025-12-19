/*      *** sin.c ***    05.01.1990 P.Hassi       */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int Help(void);

#define IS_DIGIT(a)     (48 <= a  && a <= 57)
#define SAMESTRING(a,b) (!(stricmp(a,b)))
#define ERROR(a) {printf("%s\n",a); exit(10);}

    /* Don't change these defines! */

#define FALSE 0
#define TRUE  1
#define POS   2
#define NEG   3

#define SIN 1
#define COS 2

#define PLUS  1
#define MINUS 2

int main(argc,argv)
int argc;
char *argv[];
{
	double alku,loppu,astekulma,radkulma,tulos,step,keha;
    double alkuker,loppuker,kerstep,kerroin,offset=0;
	int arg,kpl,i,j,rivikpl,sign,loop,angle_mode,mode=SIN;
    char outfmt[10];        /* default output format string */
    
    strcpy(outfmt," % 7.2lf"); 
    sign = loop = FALSE;
    keha = 3.141592654 * 2;     /* circle */
    angle_mode = FALSE;
    alkuker=loppuker=1;
    rivikpl=5;

    arg=3;
    argc--;

    if (argc < 3)
    {
        Help();
        exit(0);   
    }
    if (!(sscanf(argv[1],"%d",&kpl)))
	{
		printf("Can't read  COUNT\n");
		exit(0);
	}
	if (!(sscanf(argv[2],"%lf",&alku)))
	{
		printf("Can't read  START_ANGLE\n");
		exit(0);
	}
    
    if (SAMESTRING(argv[3],"+"))
    {
        angle_mode = PLUS;        
        arg++;
    }
    else
    if (SAMESTRING(argv[3],"-"))
    {
        angle_mode = MINUS;
        arg++;
    }
    if (angle_mode != FALSE)
    {
        if (argc < 4)  
        {
            Help();
            exit(0);   
        }
    }
	if (!(sscanf(argv[arg],"%lf",&loppu)))
	{
		printf("Can't read  END_ANGLE\n");
		exit(0);
	}
    switch (angle_mode)
    {
        case PLUS:
                loppu = alku + loppu;
                break;
        case MINUS:
                loppu = alku - loppu;
                break;
        default:    
                break;
    }
        
    arg++;
    
    while (arg <= argc)
    {
        if (SAMESTRING(argv[arg],"m"))
        {
            if ((argc - arg) < 1)
                ERROR("m multiplier1 [multiplier2]")
            if (!(sscanf(argv[arg+1],"%lf",&alkuker)))
    		    ERROR("Can't read  MULTIPLIER1\n")
            if ((argc - arg) >= 2)
            {
                if (!(sscanf(argv[arg+2],"%lf",&loppuker)))
    		    {
                    loppuker = alkuker;
                    arg+=2;
                }
                else
                    arg+=3;
            }
            else
            {
                loppuker = alkuker;
                arg+=2;
            }
        }
        else
        if (SAMESTRING(argv[arg],"f"))
        {
            if ((argc - arg) < 2)
            {
                printf("F values_per_line output_format_string\n");
                ERROR("for example:   f 6 8.1")
            }
            if (!(sscanf(argv[arg+1],"%d",&rivikpl)))
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
        if (SAMESTRING(argv[arg],"o"))
        {
            if ((argc - arg) < 1)
                ERROR("o offset")
            if (!(sscanf(argv[arg+1],"%lf",&offset)))
    		    ERROR("o offset\n")
            arg+=2;
        }
        else 
        if (SAMESTRING(argv[arg],"POS"))
        {
            sign = POS;
            arg++;
        }
        else
        if (SAMESTRING(argv[arg],"NEG"))
        {
            sign = NEG;
            arg++;
        }
        else
        if (SAMESTRING(argv[arg],"LOOP"))
        {
            loop = TRUE;
            arg++;
        }
        else
        if (SAMESTRING(argv[arg],"COS"))
        {
            mode = COS;
            arg++;
        }
        else
        {
            printf("Unknown option! %s\n",argv[arg]);
            Help();
            exit(0);
        }
    }

    astekulma = alku;
    kerroin = alkuker;
	step = (loppu - alku) / (kpl-(!loop));
    kerstep = (double)(loppuker - alkuker) / (kpl-(!loop));

	i=j=0;
    printf("\n#% 8.2lf#  ",astekulma);
    while( (i+j) < kpl )
	{
		radkulma = (astekulma * keha) / 360;
        
        if (mode == SIN)
            tulos = sin(radkulma) * kerroin;
        else
            if (mode == COS)
                tulos = cos(radkulma) * kerroin;
        if (sign == POS  &&  tulos<0)
            tulos*=-1;
        if (sign == NEG  &&  tulos>0)
            tulos*=-1;
        tulos = offset + tulos;
		printf(outfmt,tulos);
        astekulma+= step;
        kerroin += kerstep;

        i++;
        if (i >= rivikpl && (i+j)<kpl)
        {
            j+=i;
            i=0;
            printf("\n#% 8.2lf#  ",astekulma);
        }
	}
    printf("\n");
    return(1);
}


int Help(void)
{
        printf("version 1.5\n");
		printf("SIN\t count start_angle [+] [-] end_angle\n");
        printf("\t [M multiplier1 [multiplier2]] [O offset]\n");
        printf("\t [F values_per_line output_format_string] [COS] [POS] [NEG] [LOOP]\n");
		return(0);
}
