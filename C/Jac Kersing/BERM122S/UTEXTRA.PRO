#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif

/* utextra.c */

#if UNIX | BWIN32
struct date
{
    int    da_year;                     /* Current year */
    char   da_day;                      /* Day of the month */
    char   da_mon;                      /* Month ( 1 = Jan ) */
};

struct time
{
    unsigned char   ti_min;             /* Minutes */
    unsigned char   ti_hour;            /* Hours */
    unsigned char   ti_hund;            /* Hundredths of seconds */
    unsigned char   ti_sec;             /* Seconds */
};

void getdate P((struct date *date));
void gettime P((struct time *time));
#endif

void setstamp P((char *name , char *buf ));
#ifdef LINN
static void conv P((unsigned long getal , char *p , int base , int unsign, int low));
#else
static void conv P((unsigned long getal , char *p , int base , int unsign));
#endif
#if UNIX==0
static void cdecl iprint P((void (*outp)(char) , char *fmt, ... ));
void cdecl doprint P((void (*outp )(char ), char *fmt , ... ));
void cdecl fmprint P((char *buf , char *fmt , ... ));
void cdecl sprint P((char *buf , char *fmt , ... ));
void cdecl message P((int level , char *fmt , ... ));
void cdecl clprint P((char *fmt , ... ));
void cdecl print P((char *fmt , ... ));
#else
/* varargs... being very bad on C, I've been unable to handle them correctly on Unix - VP */
static void cdecl iprint();
void cdecl doprint();
void cdecl fmprint();
void cdecl sprint();
void cdecl message();
void cdecl clprint();
void cdecl print();
#endif
char *ffirst P((char *name ));
char *fnext P((void ));
#ifdef MSTRUPR
char *strupr P((char *str ));
#endif
#ifdef MSTRDUP
char *strdup P((char *s));
#endif
int is_arcmail P((char *p , int n ));
int execute P((char *prg , char *cmd ));
int weekday P((struct date *d ));
unsigned int ztoi P((char *str , int len ));
int getadress P((char *str , int *zone , int *net , int *node ));
unsigned inteli P((int x));
long intell P((long x));

#undef P
