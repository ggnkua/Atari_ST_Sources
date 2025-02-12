/*	name...
		ri2mag - convert frequencies with real & imaginary parts to frequencies
				with magnitudes
	bugs...
		should read in all data, then write, so disk head doesn't have
		to move between input and output file.
*/
#include <stdio.h>
#include <math.h>

#define VERSION "1.1"
#define MAXLABELS 50
#define BUFSIZE 200

FILE *ifile=stdin, *ofile=stdout;

char buffer[128], oname[35];
char buf[BUFSIZE];

int automatic_abscissas, /* nonzero if abscissas to be calculated */
abscissa_arguments;

double
abscissa,
abscissa_step;


main(argc, argv) int argc; char **argv;
{	int i;

	double amp, phase, factor, q, pi, time, dt;
	double this, big, sweep, scale;

	{double junk;
	sscanf("3.4","%lf",&junk);		/* workaround for DESMET sscanf bug */
	}

	argc = args(argc, argv);
	read_data(argc, argv);

	if(ofile!=stdout)
		{fclose(ofile);
		}
}



read_data(argc, argv) int argc; char **argv;
{	int i, j, nums, ac;
	double ff, xx, yy;
	char *s, *t, *stop, **av;
	char *strchr();

	argc--; argv++;
	if(strchr(argv[0], '?')) help();

/*            open input file         */
	if(argc)
		{ifile=fopen(argv[0], "r");
		if(ifile==0) {printf("file %s not found\n", argv[0]); exit(1);}
		argc--; argv++;
		}
/*            open output file         */
	if(argc)
		{strcpy(oname, argv[0]);
		unlink(oname);
		if((ofile=fopen(oname, "w"))==0)
			{fprintf(stderr, "can\'t open output file");
			exit(1);
			}		
		}

	fprint_cmd(stdout, "; ri2m%s\n");

	while(fgets(buf, BUFSIZE, ifile))
		{t=buf;
		while(*t && isspace(*t)) t++;
		if(*t == 0) continue;		/* skip blank lines */
		buf[strlen(buf)-1]=0;		/* zero out the line feed */
		if(buf[0]==';')				/* copy comment */
			{fprintf(ofile, "%s\n", buf); continue;
			}
		if(t = strchr(buf, ';')) *t=0;	/* zap same-line comment */
		if(automatic_abscissas)
			{ff=abscissa;
			abscissa+=abscissa_step;
			sscanf(buf, "%lf %lf", &xx, &yy);
			}
		else
			{sscanf(buf, "%lf %lf %lf", &ff, &xx, &yy);
			}
		s=buf;                      /* start looking for label */
		nums=3;
		if(automatic_abscissas) nums--;
		while(nums--)					/* skip the numbers */
			{while(*s==' ')s++;
			while(*s && (*s!=' '))s++;
			}
		while(*s==' ')s++;
		fprintf(ofile, "%15.8g %15.8g %s\n", ff, sqrt(xx*xx + yy*yy), s);
		}
}

int streq(a,b) char *a,*b;
{	while(*a)
		{if(*a!=*b)return 0;
		a++; b++;
		}
	return (*b==0);
}

/* get_parameter - process one command line option
		(return # parameters used) */
get_parameter(argc, argv) int argc; char **argv;
{	int i;
	if(streq(*argv, "-a"))
		{i=get_double(argc, argv, 2, &abscissa_step, &abscissa, &abscissa);
		abscissa_arguments=i-1;
		automatic_abscissas=1;
		return i;
		}
	else gripe(argv);
}

char *message[]={
"ri2m   version ", VERSION,
" - convert real & imag parts to magnitude\n",
"usage: ri2m  infile  [outfile]  [options]\n",
"options are:\n",
"  -a  [step [start]] automatic abscissas \n",
0
};

