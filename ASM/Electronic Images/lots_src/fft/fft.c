/*	name...
		fft

	bugs...
		Should do transforms on several functions (-b option).
		use large model.
		eliminate use of extra few entries, permitting use of exactly
			64K arrays (4 bytes * 8K entries * 2 arrays)

	performance...
		4096 point transform in 1:13.71 with 6 MHz 80286 and 4 MHz 80287.

	bugs...
		check for unequally spaced data is too strict.


	history...
		6 Jun 91	Ver 1.42: can read data from stdin.  Uses args.c
					to read switches and echo command line.
		19 Apr 89	Ver 1.41: forcing space between columns in output.
		1 Jun 87	Checking for unequally spaced data.
		-- 1.40 --
		11 May 87	-o option installed, -p	option accepts total number
					as well as padding factor.
		8 May 87	Reading into doubles and performing range check
					before converting to floats.
		1 May 87	calculating with floats rather than doubles.
					performing 4096 point transforms.
					-a option suppresses frequencies on output
		-- 1.3 --
		29 Apr 87	Fixed padding factor calculation
					added -m option to print only freq and mag
					added -z option to shift origin
					enhanced help display
		6 Apr 87	Default edge weight .1 instead of .9,
					Default abscissa step 1 (instead of 0!).
		20 Mar 87	Conversion to/from dBs or to magnitude/phase removed.
					Default output to STDOUT.
					Removed prompts.
		8 Feb 87	Inverse FFT code split off into separate file.
		7 Nov 86	-o omits phase printout, -p specifies padding factor.
			padding factor defaults to 1/4 of maximum, # points defaults
			to all.
		6 Nov 86	Switch s sets up windowing.
		2 Nov 86	Ported to DeSmet C, input & output files in ASCII,
			options read from command line.
		12 Jul 84  Printing time between samples.
		11 Jul 84  One sided windows, degree 6, 10, or 16.
			Calculating energy before & after windowing.
		10 Jul 84  No longer printing out y values. Announcing
			program version.  One sided windowing, degree 16.
			Allows peak to be any value from 200 to 22000 without
			rescaling.  No longer discarding zero frequency point.
		26 Jun 84  Weight at window edge (epsilon) specified by
			user.  Number of input data points to be retained
			is specified by user.
		25 Jun 84  Supergaussian windowing (degree 6) is optional,
			beeping after finishing transform.
		22 Jun 84  Scaling real & imaginary parts to the range
			10900...22000.  Padding by a factor of 4, then 
			discarding 50% of the data (high frequency values) so
			512 magitude values are retained.  No "magnitude"
			values printed out (not even zeros).
		18 Jun 84  writing out first magnitude, then phase.
			Correctly calculating time step.
		15 Jun 84  setting phase to zero.
		12 Jun 84  scaling so largest element is 2048.
			Calculating magnitude & phase.
		May 84     written
*/
#include <stdio.h>
#include <math.h>

#define VERSION "1.42"



#define BIGFLOAT 6.e38	/* no floats larger than this  */
#define ENTRIES 4098
#define MAXLABELS 50
#define BUFSIZE 200
#define DEFAULT_EDGE_WEIGHT .1
#define FLOAT float		/* change to "double" to restore higher precision */

FILE *ifile=stdin, *ofile=stdout;

char buffer[128], iname[35], oname[35];
char buf[BUFSIZE];
char *label_array[MAXLABELS];
char **p_text=label_array;


int m,			/* number of input values to be retained */
n,				/* number of data points to be Fourier transformed */
*nnn,			/* points to n */
breaking=0,		/* nonzero if finding separate transforms for several functions */
labels,			/* number of labels stored */
super=0,		/* if nonzero, the degree of supergaussian window desired */
automatic_abscissas, /* nonzero if abscissas to be calculated */
abscissa_arguments=0,
shifting=0,	/* nonzero if data to be shifted */
pad_factor=0,	/* nonzero if specific padding factor was requested */
keeping=0,		/* if nonzero, the number of input values to be kept */
magnitudes=0,	/* nonzero if only magnitudes are to be written */
f_arguments=0,
x_arguments=0;

int standard_input=0;		/* nonzero if data is coming from standard input */
int index_array[MAXLABELS];	/* indexes into x and y */
int *p_data=index_array;

FLOAT *x,		/* time or frequency values */
*y;				/* voltages (on input) or magnitudes (on output) */
double abscissa,
abscissa_step=1.,
before, after,	/* energy in data before & after windowing */
origin,			/* abscissa value to be treated as time zero */
wt=0.,			/* weight on last data point kept */
output=0.,		/* if nonzero, the number of calculated values to be printed */
fmin, fmax,
xmin, xmax;		/* first & last data points to be used */

double energy(), atan2();

main(argc, argv) int argc; char **argv;
{	int i, nn, windowing;

	double amp, phase, factor, q, pi, time, dt;
	double this, big, sweep, scale, yr, yi;

	{double junk;
	sscanf("3.4","%lf",&junk);		/* workaround for DESMET sscanf bug */
	}

	argc = args(argc, argv);		/* fetch switches */

	read_data(argc, argv);			/* read input data */

/*	puts(" time function\n"); listt(y, 1, 10); */
	nn=n;
		{double dt;
		dt=x[2]-x[1];
		if(nn*fabs(x[nn]-x[nn-1]-dt) + fabs(x[nn]-x[1]-(nn-1)*dt) > .001*nn*dt)
			{printf("fft: times not equally spaced\n");
			printf("x[1]=%f, x[2]=%f, x[%d]=%f, x[%d]=%f, dt=%f",
				x[1], x[2], nn-1, x[nn-1], nn, x[nn], dt);
			exit();
			}
		}
	nn=pad();
/*	puts(" time function after padding\n"); listt(y, 1, 10); */
	before=energy();
	windowing = wind16() || wind10() || wind6();
	if(windowing)
		{after=energy();
		fprintf(stderr, "Energy loss due to windowing = %5.2f%% \n",
			100.*(before-after)/before);
		}
	else after=before;
	fprintf(stderr, "Energy (sum of squares of data%s) %s= %10.3g \n", 
	(!automatic_abscissas || abscissa_arguments) ? ", times time step" : "",
	windowing?"after windowing ":"", after);
/*	puts(" time function\n"); listt(y, 1, 10); listt(y, nn-10, nn); */
	if(shifting) shift(nn);
	
	fprintf(stderr, "computing FFT...\n");
	fft(&nn, x, y);

	if(output)
		{if(output<32) output = nn/output;
		if(output<nn) nn=output;
		}
	if(abscissa_arguments)
		fprintf(ofile, "; output frequency step is %15.8g", x[2]-x[1]);
	i=1;
	while(1)
		{if(!automatic_abscissas)  fprintf(ofile, "%15.6g ", x[i]);
		yr=y[2*i-1]; yi=y[2*i];
		if(magnitudes)  fprintf(ofile, "%15.6g", sqrt(yr*yr + yi*yi));
		else            fprintf(ofile, "%15.6g %15.6g", yr, yi);
		if(++i>nn) break;
		fprintf(ofile, "\n");
		}
	fprintf(ofile, " \"\"\n");
	if(ofile!=stdout)
		{fclose(ofile);
		}
}

double energy()
{	double v, e;
	int i;
	i=1;
	e=0.;
	while(i<=m)
		{v=y[i++]; e=e+v*v;
		}
	return e*(x[2]-x[1]);
}

pad()		/* pad the data with zeros */
{	int i, k, num, max;
	char c;
	if(keeping)
		m=keeping;
	else 
		m=n;
/*
		while(1)
			{fprintf(stderr,
			"Last point to include (2...%d, default %d) ? ", n, n);
			gets(buf);
			if(buf[0]) sscanf(buf, "%d", &m);
			else m=n;
			if((m>=2) && (m<=n)) break;
			}
*/
	if(pad_factor)
		{if(pad_factor>=32) num=(pad_factor/10)*7;
		else if(pad_factor>0) num=((m*pad_factor)/10)*7;
		else num=m*4;	/*  default is a padding factor between 4 and 8 */
		}
	else num=m*4;	/*  default is a padding factor between 4 and 8 */
	for (k=1; k<num; k <<= 1) {}	/* find next power of 2 */
	while (k>ENTRIES) {k >>= 1;}	/* back off if too many for buffer */
	fprintf(stderr, "transforming %d points, for actual padding factor of %3.1f\n", 
		k, k/(double)m);
	i=m;
	while(i<k)	/* will have k values after this */
		{y[++i]=0.;}
	return k;
}

shift(n) int n;		/* shift data so time "origin" is at the beginning of the array */
{	int k;
	k=(int)((origin-x[1])/(x[2]-x[1]) + 1.5);
	if(k<1 || k>n) 
		{fprintf(stderr, "specified origin isn't within abscissa range");
		exit(1);
		}
			/* need to swap y[1]...y[k-1] with y[k]...y[n] */
	reverse(1, k-1);
	reverse(k, n);
	reverse(1, n);
}

reverse(i, j) int i,j;  /* reverse y[i]...y[j]  */
{	double t;
	while(i<j) {t=y[i]; y[i]=y[j]; y[j]=t; i++; j--;}
}

wind16()
{	char c;
	int j;
	double p, p2, dp, scale, epsilon;

/*	if(!super)
		{while(1)
			{puts("Perform one-sided supergaussian windowing, degree 16? ");
			c=toupper(getchar()); putchar('\n');
			if(c=='N')return 0;
			if(c=='Y')break;
			}
		}
	else
*/
	     if(super!=16) return 0;		
/*
	if(wt==0.)
		{fprintf(stderr, "Weight at window edge (0 < epsilon < 1, default=%f) ? ",
			DEFAULT_EDGE_WEIGHT);
		gets(buffer);
		if(buffer[0]) epsilon=atof(buffer); else epsilon=DEFAULT_EDGE_WEIGHT;
		}
	else 
*/		epsilon=wt;
	p=exp(log(-log(epsilon))/16.);	/* (-ln(epsilon))**(1/16) */
/*	fprintf(stderr, "ratio C/A = %7.4f \n", p);  */
	dp=p/(m-1);
	j=m;
	while(j)
		{p2=p*p; p2=p2*p2; p2=p2*p2;	/* p**8 */
		y[j] *= exp(-p2*p2);	/* p**16 */
		p -= dp; --j;
		}
	return 1;
}

wind10()
{	char c;
	int j;
	double p, p2, p4, dp, scale, epsilon;

/*	if(!super)
		{while(1)
			{puts("Perform one-sided supergaussian windowing, degree 10? ");
			c=toupper(getchar()); putchar('\n');
			if(c=='N')return 0;
			if(c=='Y')break;
			}
		}
	else
*/
	     if(super!=10) return 0;		
/*
	if(wt==0.)
		{fprintf(stderr,"Weight at window edge (0 < epsilon < 1, default=%f) ? ",
			DEFAULT_EDGE_WEIGHT);
		gets(buffer);
		if(buffer[0]) epsilon=atof(buffer); else epsilon=DEFAULT_EDGE_WEIGHT;
		}
	else 
*/
		epsilon=wt;
	p=exp(log(-log(epsilon))/10.);	/* (-ln(epsilon))**(1/10) */
/*	fprintf(stderr, "ratio C/A = %7.4f \n", p);  */
	dp=p/(m-1);
	j=m;
	while(j)
		{p2=p*p; p4=p2*p2;	/* p**2, p**4 */
		y[j] *= exp(-p2*p4*p4);	/* p**10 */
		p -= dp; --j;
		}
	return 1;
}

wind6()
{	char c;
	int j;
	double p, p2, dp, scale, epsilon;

/*	if(!super)
		{while(1)
			{puts("Perform one-sided supergaussian windowing, degree 6? ");
			c=toupper(getchar()); putchar('\n');
			if(c=='N')return 0;
			if(c=='Y')break;
			}
		}
	else
*/
	     if(super!=6) return 0;		
/*
	if(wt==0.)
		{fprintf(stderr,"Weight at window edge (0 < epsilon < 1, default=%f) ? ",
			DEFAULT_EDGE_WEIGHT);
		gets(buffer);
		if(buffer[0]) epsilon=atof(buffer); else epsilon=DEFAULT_EDGE_WEIGHT;
		}
	else 
*/
		epsilon=wt;
	p=exp(log(-log(epsilon))/6.);	/* (-ln(epsilon))**(1/6) */
/*	fprintf(stderr, "ratio C/A = %7.4f \n", p);  */
	dp=p/(m-1);
	j=m;
	while(j)
		{p2=p*p*p;  /* p**3 */
		y[j] *= exp(-p2*p2);	/* p**6 */
		p -= dp; --j;
		}
	return 1;
}

listt(y, i, j) FLOAT y[]; int i, j;	/* display y[i] through y[j]  */
{	while (i<=j) {printf("%4d %15.9f \n", i, y[i]); ++i;}
}


read_data(argc, argv) int argc; char **argv;
{	int i, j, length;
	double xx, yy, d, *pd, sum;
	char *s, *t, *stop;
	char *malloc();
	char *strchr();

	x=(FLOAT *)malloc(ENTRIES*sizeof(FLOAT));
	y=(FLOAT *)malloc(ENTRIES*sizeof(FLOAT));
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
	p_data[0]=-1;

	fprint_cmd(ofile, "; fft %s\n");

	i=1;		/* note x[0] and y[0] aren't defined */
	while(i<ENTRIES)
		{if(fgets(buf, BUFSIZE, ifile)==0)
			{if(standard_input) {fclose(ifile); ifile=fopen("/dev/con", "r");}
			break;
			}
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
			sscanf(buf, "%lf", &yy); 
			}
		else
			{
			sscanf(buf, "%lf %lf", &xx, &yy);
			}
		range_check(xx); range_check(yy);
		x[i]=xx; y[i]=yy;		/* convert doubles to floats here */
		s=buf;                      /* start looking for label */
		while(*s==' ')s++;			/* skip first number */
		while(*s && (*s!=' '))s++;
		if(!automatic_abscissas)	/* skip second number */
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
/*	if(ifile==stdin) {close(ifile); ifile=fopen();} */
	if(breaking && (!labels || p_data[labels-1]!=n-1))
		{p_data[labels]=i-1;
		if(p_text[labels]=(char *)malloc(1)) *p_text[labels++]=0;
		}
}

/* check whether number is too big for a float */
range_check(x) double x;
{	if(fabs(x)>BIGFLOAT)
		{fprintf(stderr, "input number too large: %f\n", x);
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
	else if(streq(*argv, "-b")) {breaking=1; return 1;}
	else if(streq(*argv, "-s"))
		{super=10; wt=DEFAULT_EDGE_WEIGHT;
		if((argc>1) && numeric(argv[1])) 
			{super=atoi(argv[1]);
			if((super!=16) && (super!=10) && (super!=6))
				{fprintf(stderr, "windowing only of degrees 6, 10, & 16 available");
				exit(1);
				}
			if((argc>2) && numeric(argv[2]))
				{wt=atof(argv[2]);
				if((wt<=0.)||(wt>=1.))
					{fprintf(stderr, "wt=%f, need  0 < wt < 1", wt); exit(1);
					}
				return 3;
				}
			return 2;
			}
		return 1;
		}
	else if(streq(*argv, "-n"))
		{if((argc>1) && numeric(argv[1])) keeping=atoi(argv[1]);
		if(keeping<2 || keeping>ENTRIES)
			{fprintf(stderr, "switch -n option out of range 2...%d\n",ENTRIES);
			exit(1);
			}
		return 2;
		}
	else if(streq(*argv, "-o"))
		{if((argc>1) && numeric(argv[1])) output=atof(argv[1]);
		if(output<1 || output>ENTRIES)
			{fprintf(stderr, "switch -o option out of range 1...%d\n",ENTRIES);
			exit(1);
			}
		return 2;
		}
	else if(streq(*argv, "-p"))
		{if((argc>1) && numeric(argv[1])) pad_factor=atoi(argv[1]);
		return 2;
		}
	else if(streq(*argv, "-f"))
		{i=get_double(argc, argv, 2, &fmin, &fmax, &fmax);
		f_arguments=i-1;
		return i;
		}
	else if(streq(*argv, "-t"))
		{i=get_double(argc, argv, 2, &xmin, &xmax, &xmax);
		x_arguments=i-1;
		return i;
		}
	else if(streq(*argv, "-m"))
		{magnitudes=1;
		return 1;
		}
	else if(streq(*argv, "-z"))
		{origin=0.;
		i=get_double(argc, argv, 1, &origin, &fmax, &fmax);
		shifting=1;
		return i;
		}
	else gripe(argv);
}

char *message[]={
"fft   version ", VERSION,
" - calculate fast Fourier transform of time domain curve\n",
"usage: fft  [infile  [outfile]]  [options]\n",
"options are:\n",
"  -a  [step]       automatic abscissas \n",
/*
"  -b               break input after each label,  \n",
"                   find separate transforms\n",
"  -f  min [max]    minimum and maximum frequencies\n",
"  -t  min [max]    minimum and maximum times\n",
*/
"  -m               print only frequencies & magnitudes\n",
"  -p  num          pad data by factor of num\n",
"  -n  num          keep only first  num  input data points\n",
"  -o  num          print out num values\n",
"  -s  [deg [wt]]   perform supergaussian windowing of\n",
"             degree deg (6, 10, or 16, default 10) with\n",
"             weight wt on last point (default .9)\n",
"  -z  origin       subtract  origin  from each abscissa value\n",
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

	/* format time domain function for calculation
		of its fast Fourier transform */
/*
on input:
n = a power of 2
x[1...n] has  t(0)  t(1)  t(2)  ...  t(n-1)
y[1...n] has  q(0)  q(1)  q(2)  ...  q(n-1)

on output:
n = (n/2+1), one more than a power of 2
x[1...n]  has  f(0)  f(1)  f(2)  ...  f(n-1)
y[1...2n] has  Qr(0) Qi(0)   Qr(1) Qi(1)   Qr(2) Qi(2)  ...  Qr(n-1)  Qi(n-1)
*/
fft(nnn, x, y) int *nnn; FLOAT x[], y[];
{	n= *nnn;
	if(n<=0){puts("fft: illegal # points"); return;}
	dt=x[2]-x[1];
	df=1./(n*dt);
	n2=4; nu=0;
	while(++nu<=20)
		{if(n2==n)break;
		n2=n2+n2;
		}
	if(nu>20){puts("fft: n not a power of 2"); return;}
/*	puts("fft: n is ok, nu= %d\n", nu);	*/
	n=n/2; i=0;
	while(++i<=n) {x[i]=y[2*i]; y[i]=y[2*i-1];}
/*
	printf("fft: data reformatted\n");
	i=0; 
	while(++i<=10) {printf("%6d %15.6f %15.6f\n", i, y[i], x[i]);}
*/
	fft2(y, x, n, nu);
/*
	puts("fft: transform calculated\n"); 
	i=0; 
	while(++i<=10) {printf("%6d %15.6f %15.6f\n", i, y[i], x[i]);}
*/
	ip=n+1; y[ip]=y[1]; x[ip]=x[1];
	ninv=3.14159265358979/n;
	n=n/2; n2=n+1; i=0;
	while(++i<=n2)
		{arg=ninv*(i-1); s=sin(arg); c=cos(arg);
		uplus=y[i]+y[ip]; uminus=y[i]-y[ip];
		vplus=x[i]+x[ip]; vminus=x[i]-x[ip];
		p= c*vplus-s*uminus; q= -s*vplus-c*uminus;
		y[i]=.5*(uplus+p); y[ip]=.5*(uplus-p);
		x[i]=.5*(q+vminus); x[ip]=.5*(q-vminus);
		--ip;
		}
	n=n+n+1; ip=n;
	while(ip) {y[ip+ip-1]=dt*y[ip]; --ip;}
	freq=0.; i=0;
	while(++i<=n) {y[i+i]=x[i]*dt; x[i]=freq; freq=freq+df;}
	*nnn=n;
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

