/*
 * Decl.h
 *	Declarations for commonly used C functions.
 *	The way we use it is in stdio.h we put in
 *	the following lines:
 *
 *	#ifdef DECL
 *	#include <decl.h>
 *	#endif
 *
 *	and when we compile, we declare DECL, so that it
 *	decl.h gets included and we have all the functions
 *	that return types other than int, appropriately declared.
 */


/*
char *getcwd(char *, int);
*/

/*
char *calloc(unsigned int, unsigned int);
*/
extern	char *calloc();

/*
char *malloc(unsigned int);
*/
extern	char *malloc();

/*
char *realloc(char *, unsigned int);
*/
extern	char *realloc();

/*
char *sbrk(int);
*/
extern	char *sbrk();


#ifndef HUGE
	/* HUGE is defined if math.h has been included */
/*
double acos(double);
*/
extern	double acos();

/*
double asin(double);
*/
extern	double asin();

/*
double atan(double);
*/
extern	double atan();

/*
double atan2(double, double);
*/
/*
extern	double atan2();
*/

/*
double atof(char *);
*/
extern	double atof();

/*
double ceil(double);
*/
extern	double ceil();

/*
double cos(double);
*/
extern	double cos();

/*
double cosh(double);
*/
extern	double cosh();

/*
double exp(double);
*/
extern	double exp();

/*
double fabs(double);
*/
extern	double fabs();

/*
double floor(double);
*/
extern	double floor();

/*
double fmod(double, double);
*/
extern	double fmod();

/*
double frexp(double, int *);
*/
/*
extern	double frexp();
*/

/*
double hypot(double, double);
*/
/*
extern	double hypot();
*/

/*
double j0(double);
*/
/*
extern	double j0();
*/

/*
double j1(double);
*/
/*
extern	double j1();
*/

/*
double jn(int, double);
*/
/*
extern	double jn();
*/

/*
double ldexp(double, double);
*/
/*
extern	double ldexp();
*/

/*
double log(double);
*/
extern	double log();

/*
double log10(double);
*/
extern	double log10();

/*
double modf(double, double *);
*/
extern	double modf();

/*
double pow(double, double);
*/
extern	double pow();

/*
double sin(double);
*/
extern	double sin();

/*
double sinh(double);
*/
/*
extern	double sinh();
*/

/*
double sqrt(double);
*/
extern	double sqrt();

/*
double tan(double);
*/
/*
extern	double tan();
*/

/*
double tanh(double);
*/
/*
extern	double tanh();
*/

/*
double y0(double);
*/
/*
extern	double y0();
*/

/*
double y1(double);
*/
/*
extern	double y1();
*/

/*
double yn(int, double);
*/
/*
extern	double yn();
*/

#endif	/* HUGE */


/*
int (*signal(int, int (*)()))();
*/
extern	int (*signal())();

/*
FILE *fdopen(int, char *);
*/
extern	FILE *fdopen();

/*
char *fgets(char *, int, FILE *);
*/
extern	char *fgets();

/*
FILE *fopen(char *, char *);
*/
extern	FILE *fopen();

/*
FILE *freopen(char *, char *, FILE *);
*/
extern	FILE *freopen();

/*
long ftell(FILE *);
*/
extern	long ftell();

/*
char *gets(char *);
*/
extern	char *gets();

/*
long lseek(int, long, int);
*/
extern	long lseek();

/*
char *mktemp(char *);
*/
extern	char *mktemp();

/*
long tell(int);
*/
extern	long tell();


/*
long atol(char *);
*/
extern	long atol();

/*
char *ecvt(double, int, int *, int *);
*/
extern	char *ecvt();

/*
char *fcvt(double, int, int *, int *);
*/
extern	char *fcvt();

/*
char *gcvt(double, int, char *);
*/
extern	char *gcvt();

/*
char *getenv(char *);
*/
extern	char *getenv();

/*
char *itoa(int, char *, int);
*/
extern	char *itoa();

/*
long labs(long);
*/
extern	long labs();

/*
char *ltoa();
*/
extern	char *ltoa();

/*
char *ultoa(unsigned long, char *, int);
*/
extern	char *ultoa();


/*
char *strcat(char *, char *);
*/
extern	char *strcat();

/*
char *strcpy(char *, char *);
*/
extern	char *strcpy();

/*
unsigned int strlen(char *);
*/
extern	unsigned int strlen();

/*
char *strncat(char *, char *, unsigned int);
*/
extern	char *strncat();

/*
char *strncpy(char *, char *, unsigned int);
*/
extern	char *strncpy();

/*
char	*index(char *, char);
*/
extern	char	*index();

/*
char	*rindex(char *, char);
*/
extern	char	*rindex();
