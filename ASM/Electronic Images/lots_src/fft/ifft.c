/*	name...
		ifft

	bugs...
		Should do transforms on several functions (-b option).

	history...
		-- 1.21 --
		1 Jun 87	-a option suppresses abscissas on output.
		-- 1.20 --
		11 May 87	Using "float" rather than "double" variables
		8 May 87	Reading into doubles and performing range check
					before converting to floats.
		-- 1.1 --
		6 Apr 87	Default abscissa step is 1 (rather than 0!)
					Some printing removed.
		-- 1.0 --
		20 Mar 87	default output to STDOUT
		8 Feb 87	split off from fft program.

	performance...
		128 point transform in 14.43 sec with 7.5 MHz V-20 and no 8087.
		4096 point transform in 1:53.15 with 6 MHz 80286 and 4 MHz 80287.
*/
#include <stdio.h>
#include <math.h>

#define VERSION "1.21"


#define BIGFLOAT 6.e38	/* no floats larger than this  */
#define ENTRIES 4098
#define MAXLABELS 50
#define BUFSIZE 200
#define FLOAT float	/* change to "double" to restore higher precision */

FILE *ifile=stdin, *ofile=stdout;

char buffer[128], iname[35], oname[35];
char buf[BUFSIZE];
char *label_array[MAXLABELS];
char **p_text=label_array;


int m,			/* number of input values to be retained */
n,				/* number of data points to be Fourier transformed */
*nnn,			/* points to n */
breaking,		/* nonzero if finding separate transforms for several functions */
labels,			/* number of labels stored */
automatic_abscissas, /* nonzero if abscissas to be calculated */
abscissa_arguments,
keeping=0,		/* if nonzero, the number of input values to be kept */
f_arguments=0,
x_arguments=0,
index_array[MAXLABELS],	/* indexes into x and y */
*p_data=index_array;

FLOAT *x,		/* frequency values */
*y;				/* magnitudes (on input) or voltages (on output) */
double abscissa,
origin,			/* abscissa value to be treated as time zero */
abscissa_step=1.,
fmin, fmax,
xmin, xmax;		/* first & last data points to be used */

main(argc, argv) int argc; char **argv;
{	int i;

	{double junk;
	sscanf("3.4","%lf",&junk);		/* workaround for DESMET sscanf bug */
	}

	argc = args(argc, argv);		/* fetch switches */

	read_data(argc, argv);
	pad();

/*	fprintf(stderr, "\n\n   computing inverse fft\n\n");  */
	ifft(&n, x, y);

	i=1;
	while(1)
		{if(!automatic_abscissas)  fprintf(ofile, "%15.6g", x[i] + origin);
		fprintf(ofile, "%15.6g", y[i]);
		if(++i>n) break;
		fprintf(ofile, "\n");
		}
	fprintf(ofile, " \"\"\n");
	if(ofile!=stdout)
		{fclose(ofile);
		}
}

pad()
{	int m;
	double freq, df;
	for (m=2; m<ENTRIES; m *= 2)
		if (n<=m+1) break;
	if(n==m+1) return;
/*	printf("transforming %d points after padding\n", m+1);  */
	freq=x[n];
	df=freq-x[n-1];
	while(n<=m)
		{n++;
		freq += df;
		x[n]=freq;
		y[2*n-1]=y[2*n]=0.;
		}
}

listt(y, i, j) FLOAT y[]; int i, j;	/* display y[i] through y[j]  */
{	while (i<=j) {printf("%4d %15.9f \n", i, y[i]); ++i;}
}


read_data(argc, argv) int argc; char **argv;
{	int i, j, length, nums;
	double xx, yyr, yyi, d, *pd, sum;
	char *s, *t, *stop;
	char *malloc();
	char *strchr();

	x=(FLOAT *)malloc(ENTRIES*sizeof(FLOAT));
	y=(FLOAT *)malloc(2*ENTRIES*sizeof(FLOAT));
	if(x==0 || y==0) {fprintf(stderr, "can\'t allocate buffer"); exit(1);}
	argc--; argv++;
	if(strchr(argv[0], '?')) help();
/*            open input file         */
	if(argc && *argv[0]!='-')
		{ifile=fopen(argv[0], "r");
		if(ifile==0) {fprintf(stderr, "file %s not found\n", argv[0]); exit(1);}
		strcpy(iname, argv[0]);
		argc--; argv++;
		}
/*            open output file         */
	if(argc && *argv[0]!='-')
		{strcpy(oname, argv[0]);
		argc--; argv++;
		unlink(oname);
		if((ofile=fopen(oname, "w"))==0)
			{fprintf(stderr, "can\'t open output file %s", oname);
			exit(1);
			}		
		}

	fprint_cmd(ofile, "; ifft %s\n");

	p_data[0]=-1;
	i=1;		/* note x[0] and y[0] aren't defined */
	while(i<ENTRIES)
		{if(fgets(buf, BUFSIZE, ifile)==0) break;
		t=buf;
		while(*t && isspace(*t)) t++;
		if(*t == 0) continue;		/* skip blank lines */
		buf[strlen(buf)-1]=0;		/* zero out the line feed */
		if(buf[0]==';')				/* skip comment */
			{fprintf(ofile, "%s\n", buf); continue;
			}
		if(t = strchr(buf, ';')) *t=0;	/* zap same-line comment */
		if(automatic_abscissas)
			{xx=abscissa;
			abscissa+=abscissa_step;
			sscanf(buf, "%lf %lf", &yyr, &yyi);
			}
		else
			{sscanf(buf, "%lf %lf %lf", &xx, &yyr, &yyi);
			}
		range_check(xx); range_check(yyr); range_check(yyi);
		x[i]=xx; y[i+i-1]=yyr; y[i+i]=yyi; /* convert doubles to floats here */
		s=buf;                      /* start looking for label */
		nums=3;
		if(automatic_abscissas) nums--;
		while(nums--)					/* skip the numbers */
			{while(*s==' ')s++;
			while(*s && (*s!=' '))s++;
			}
		while(*s==' ')s++;
		if((length=strlen(s))&&(labels<MAXLABELS))
			{if(*s=='\"')           /* label in quotes */
				{t=s+1;
				while(*t && (*t!='\"')) t++;
				t++;
				}
			else                    /* label without quotes */
				{t=s;
				while(*t && (*t!=' '))t++;
				}
			*t=0;
			length=t-s;
			p_data[labels]=i;
			p_text[labels]=(char *)malloc(length+1);
			if(p_text[labels]) strcpy(p_text[labels++], s);
			}
		i++;
		}
	n=i-1;
	if(breaking && (!labels || p_data[labels-1]!=n-1))
		{p_data[labels]=i-1;
		if(p_text[labels]=(char *)malloc(1)) *p_text[labels++]=0;
		}
}

/* check whether number is too big for a float */
range_check(x) double x;
{	if(fabs(x)>BIGFLOAT)
		{printf("input number too large: %f\n", x);
		exit(1);
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
		{i=get_double(argc, argv, 1, &abscissa_step, &abscissa, &abscissa);
		abscissa_arguments=i-1;
		automatic_abscissas=1;
		return i;
		}
	else if(streq(*argv, "-z"))
		{origin=0.;
		i=get_double(argc, argv, 1, &origin, &fmax, &fmax);
		return i;
		}

	else gripe(argv);
}

char *message[]={
"ifft   version ", VERSION,
" - calculate inverse fast Fourier transform \n",
"                     of frequency domain function\n",
"usage: ifft  [infile  [outfile]]  [options]\n",
"options are:\n",
"  -a  [step]     automatic abscissas \n",
"  -z  val        add <val> to each abscissa value\n",
/*
"  -b             break input after each label, \n",
"                 find separate transforms\n",
"  -f  min [max]  minimum and maximum frequencies\n",
"  -t  min [max]  minimum and maximum times\n",
*/
0
};


/*	name...
		fft

	purpose...
		perform forward or inverse FFT

	history...
		May 84  translated from FORTRAN
		12 Jun 84  diagnostic printouts shortened
*/

	int ip, n2, i, j, k, nu, nn;
	int k1n2, l, nu1;
	double arg, p, q, s, c;
	double ninv, time, dt, freq, df;
	double xplus, xminus, yplus, yminus;
	double uplus, uminus, vplus, vminus;

/*	format frequency domain data so its
	inverse fast Fourier transform can be calculated

	on input:
	n is one more than a power of 2:  n == 3, 9, 17, 33, 65, ...
	x[1...n]  has  f(0)  f(1)  f(2)  ...  f(n-1)
	y[1...2n] has  Qr(0) Qi(0)   Qr(1) Qi(1)  ...  Qr(n-1) Qi(n-1)

	on output:
	n has been increased:  n = 2*n-1
	x[1...n] has  t(0)  t(1)  t(2)  ...  t(n-1)
	y[1...n] has  q(0)  q(1)  q(2)  ...  q(n-1)
*/
ifft(nnn, x, y) int *nnn; FLOAT x[], y[];
{
	n= *nnn;
	if(n<= 0) {fprintf(stderr, "ifft: bad value of n: %d", n); return 1;}
	df= x[2]-x[1]; dt= .5/x[n];
	if((fabs(df*dt*(n-1)-.5)>.01) || (fabs(x[n]-x[n-1]-df)>.01*df))
		{fprintf(stderr, "ifft: frequencies not equally spaced");
		exit(1);
		}
	nn= 2; nu= 0;
	while(++nu<= 20)
		{if(nn==n-1)break;
		nn= nn+nn;
		}
	if(nu>20)
		{fprintf(stderr, "ifft: n isn\'t 1 more than a power of 2");
		return n;
		}
	ip= 2; i= 0;
	while(++i<= n) {x[i]= y[ip]; y[i]= y[ip-1]; ip=ip+2;}
	n2= n/2+1; ip= n; arg= 0.;
	n= n-1;   /* original n, minus one */
	ninv= 3.14159265358979/n;
	i= 0;
	while(++i<= n2)
		{/* printf("i= %d ", i); */
		s= sin(arg); c= cos(arg);
		yplus= y[i]+y[ip]; yminus= y[i]-y[ip];
		xplus= x[i]+x[ip]; xminus= x[i]-x[ip];
		p= s*yminus+c*xplus; q= s*xplus-c*yminus;
		x[i]= q-xminus; x[ip]= q+xminus;
		y[i]= yplus-p;  y[ip]= yplus+p;
		--ip;
		arg= arg+ninv;   /* faster than: arg=ninv*i; */
		}

	fft2(y, x, n, nu);

/*	fprintf(stderr, "ifft: transform calculated\n");
	i=0; while(++i<=10) {printf("%6d %15.6f %15.6f\n", i, y[i], x[i]);}
*/
	ip=n;
	while(ip)
		{y[ip+ip]= -df*x[ip]; y[ip+ip-1]=df*y[ip];
		--ip;
		}
	time=0.; i=0;
	*nnn=n=n+n;  /* twice (original n, minus 1) */
	while(++i<=n) {x[i]=time; time=time+dt;}
}
fft2(xreal, ximag, n, nu)
FLOAT xreal[], ximag[];
int n, nu;
{	double treal, timag;
	FLOAT *xr1, *xr2, *xi1, *xi2;

	n2=n/2; nu1=nu-1; k=0; l=0;
	while(++l<=nu)
		{while(k<n)
			{p=ibitr(k>>nu1, nu);
			arg=3.14159265358979*2*p/n;
			c=cos(arg); s=sin(arg); i=0;
			while(++i<=n2)
			    {++k; k1n2=k+n2;
			    /* initialize four pointers */
			    xr1=xreal+k; xr2=xreal+k1n2;
			    xi1=ximag+k; xi2=ximag+k1n2;
			    treal= *xr2*c+ *xi2*s;
			    timag= *xi2*c- *xr2*s;
			    *xr2= *xr1-treal;
			    *xi2= *xi1-timag;
			    *xr1= *xr1+treal;
			    *xi1= *xi1+timag;
			    }
			k=k+n2;
			}
		k=0; --nu1; n2=n2/2;
		}
	k=0;
	while(++k<=n)
		{i=ibitr(k-1, nu)+1;
		if(i>k)
			{treal=xreal[k];   timag=ximag[k];
			xreal[k]=xreal[i]; ximag[k]=ximag[i];
			xreal[i]=treal;    ximag[i]=timag;
			}
		}
}

/* reverse the last nu bits of j */
ibitr(j, nu) int j, nu;
{	int ib;
	ib=0;
	while(nu--){ib=(ib<<1)+(j&1); j=j>>1;}
	return ib;
}


