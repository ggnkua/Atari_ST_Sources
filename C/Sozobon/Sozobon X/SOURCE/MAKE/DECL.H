	/***********************************************\
	*						*
	*  Decl.h - extern declarations for C library	*
	*						*
	\***********************************************/

#ifdef FILE
extern    FILE *fopen(), *freopen(), *fdopen();
extern    FILE *fopena(), *freopa();
extern    FILE *fopenb(), *freopb();
#endif

extern    char    *etoa();
extern    char    *ftoa();
extern    char    *getpass();
extern    char    *strchr();
extern    char    *mktemp();
extern    char    *strrchr();
extern    char    *sprintf();
extern    char    *strcat();
extern    char    *strcpy();
extern    char    *strncat();
extern    char    *strncpy();
extern    char    *calloc(), *malloc(), *realloc(), *sbrk();
extern    char    *gets(), *fgets();
extern    char    *ttyname();

extern    double    atan();
extern    double    atof();
extern    double    ceil();
extern    double    cos();
extern    double    exp();
extern    double    fabs();
extern    double    floor();
extern    double    fmod();
extern    double    log();
extern    double    pow();
extern    double    sin();
extern    double    sinh();
extern    double    sqrt();
extern    double    tan();
extern    double    tanh();

extern    int    strlen();
extern    int    (*signal())();

extern    long     atol();
#if 0
extern    long     ftell();
#endif
extern    long     lseek(), tell();
extern    long     getl();

