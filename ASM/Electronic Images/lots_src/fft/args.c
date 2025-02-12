/*
	args - handle command line arguments

	The calling program must supply the following two items...
*/
extern int get_parameter();
extern char *message[];

#include <stdio.h>

#define streq(a, b) (strcmp(a, b) == 0)

extern double atof();

/*---------------------------------------------------------------*/
/*	write out the command line */
fprint_cmd(fp, format) 
FILE *fp;		/* pointer to output file */
char *format; 	/* desired print format, possibly including program name */
{	char buf[129];
	int i=0;
#ifdef __DESMET__
	_lmove(129, 130, _showcs()-0x10, &buf, _showds());
	buf[128]=13;
	while(buf[i] != 13) i++;
	buf[i]=0;
#else /* not __DESMET__ */
#ifdef __TURBOC__
	extern int _argc;
	extern char **_argv;
	buf[0] = 0;
	for (i = 1; i < _argc; i++) {strcat(buf, _argv[i]); strcat(buf, " ");}
#else /* not __TURBOC__ */
	buf[0] = 0;
#endif /* not __TURBOC__ */
#endif /* not __DESMET__ */

	fprintf(fp, format, buf);
}

/*  parse command line switches */
args( argc, argv ) int argc; char **argv;
{	char **av;
	int ac, i;
	argc--; argv++;
	ac=argc; av=argv; argc=0;
	while(ac>0)
		{if(**av=='?') help();
		else if(**av=='-' && (i=get_parameter( ac, av )) && i > 0)
			{ac-=i; av+=i;
			}
		else {argv[argc++] = *av++; ac--;}
		}
	return argc+1;
}

/*
	get one or more double values from command line.

	note variable number of arguments...  
								get_double(argc, argv, 3, &a, &b, &c)
*/
int get_double(argc, argv, permitted, a)	/* returns # arguments used */
int argc; 									/* # argument strings left */
char **argv; 								/* ptr to string array */
int permitted; 								/* # pointers following */
double *a;									/* the first of the pointers */
{	int i=1;
	double **dp = &a;

	while((permitted--)>0 && (argc>i) && numeric(argv[i])) 
		{**dp = atof(argv[i++]); 
		dp++;
		}
	return i;
}

gripe_arg(s) char *s;
{	fprintf(stderr, "argument missing for switch %s", s);
	help();
}

gripe(argv) char **argv;
{	fprintf(stderr, *argv); fprintf(stderr, " isn\'t a legal argument \n\n");
	help();
}

numeric(s) char *s;
{	char c;
	while(c=*s++)
		{if((c <= '9' && c >= '0') || 
						c == '+' || 
						c == '-' || 
						c == '.' || 
						c == 'e' || 
						c == 'E') continue;
		return 0;
		}
	return 1;
}

help()
{	char **sp;

	for (sp = message; *sp; sp++) printf(*sp);
	exit();
}

#ifdef MAIN

double f1, f2, f3;
int debugging = 0;

/* get_parameter - process one command line option
		(return # parameters used) */
int get_parameter(argc, argv) 
int argc; 			/* # valid entries in argv[] */
char **argv;		/* pointer to array of pointers to argument strings */
{
	int i;

	if(streq(*argv, "-d")) {debugging = 1; return 1;}
	else if(streq(*argv, "-f1")) 
		{i = get_double(argc, argv, 1, &f1, &f2, &f3); 
		return i;
		}
	else if(streq(*argv, "-f2")) 
		{i = get_double(argc, argv, 2, &f1, &f2, &f3); 
		return i;
		}
	else if(streq(*argv, "-f3")) 
		{i = get_double(argc, argv, 3, &f1, &f2, &f3); 
		return i;
		}

	else gripe(argv);
}


char *message[]=
{
" - calculate ASAT engagements\n",
"usage:  asat  [options]\n",
"options:\n",
"     -a <num>   target satellite altitude (km, default 400)\n",
"     -i <num>   target satellite inclination (degrees, default 65)\n",
"     -la <num>  ASAT site latitude (degrees, default 9)\n",
"     -r         print radar horizon only\n",
"     -v <num>   ASAT axial delta velocity (km/sec, default 4)\n",
"     -n         northbound satellite\n",
"     -vl        visibility limit\n",
"     -el        energy limit (default)\n",
"     -tl        timing limit\n",
"     -td        delay time (sec, default 30)\n",

0
};

main(argc, argv) int argc; char **argv;
{	int i;

	fprint_cmd(stdout, "; args %s\n");

	argc = args(argc, argv);

	printf("f1 = %f  f2 = %f  f3 = %f\n", f1, f2, f3);

	printf("argv = ");
	for (i = 0; i < argc; i++) printf(" \"%s\"", argv[i]);

}


#endif /* MAIN */

