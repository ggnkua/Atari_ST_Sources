/* --------------------------------	*/
/* global.h : global definitions	*/
/* --------------------------------	*/
/* 23.05.91 / MATRIX / WA			*/
/* 28.10.91 / MATRIX / HG			*/
/* --------------------------------	*/

# ifndef __GLOBAL__

# define __GLOBAL__

/* constants ...	*/

# define EQUAL 0
# define LASTline 22

# define OK 0

# define MAXint		((int)0x7fff)
# define MINint		((int)0x8000)

# define MAXuint	((unsigned)0xffff)

# define MEGA (1024L*1024L)

# define MHz 1000000L
# define kHz    1000L

/* types ...	*/

typedef enum boolean { FALSE, TRUE } bool ;

# define OFF 0
# define ON  1

typedef unsigned char	byte ;
typedef short	 		word ;
typedef unsigned short	uword ;
typedef unsigned long	ulong ;
typedef unsigned long	longcard ;

typedef int (*PRINTfct)( const char *format, ... );
typedef void (PROC)(void);

typedef struct { int x, y ;	}		POINT ;
typedef struct { int x, y, w, h ; }	RECTANGLE ;
typedef POINT 	  TPoint ;
typedef RECTANGLE TRectangle ;

typedef struct { int x0, y0, x1, y1 ; }	XY2 ;

typedef struct { unsigned x, y;	}	XY ;
typedef struct { unsigned y, x;	}	YX ;


/* macros ...	*/

# define max(a,b) ((a)>(b)?(a):(b))
# define min(a,b) ((a)<(b)?(a):(b))

# define BIT(n) (1<<(n))
# define FIELD(f,n) ((f)<<(n))

# define GetFIELD(v,n,m)	(((v)>>(n))&(m))
# define GetBIT(v,n)		GetFIELD(v,n,1)

# define Assign(dest,source) memcpy(dest,source,sizeof(*dest))
# define NOwarning(x) x = x

# define STRUCTmalloc(p) ((p=malloc(sizeof(*p))) != NULL)

# define forward static
# define local   static

extern	int			null ;
extern	int 		verbose ;
extern	PRINTfct	uprintf ;

extern int ld ( int i ) ;	/* i != 2^^N -> result < 0	*/
extern long get_lcont ( long *a ) ;
extern void put_lcont ( long *a, long c ) ;
extern word get_wcont ( word *a ) ;
extern void put_wcont ( word *a, word c ) ;

extern word get_long_frame ( void ) ;

extern long disa_irq (void) ;
extern long ena_irq (void) ;
# define irq_enable()	Supexec(ena_irq)
# define irq_disable()	Supexec(disa_irq)

# define FOREIGN	0
# define GERMAN		1
extern int nation ( void ) ;
extern int TOSversion ( void ) ;
extern void key_click ( int on ) ;
extern char get_boot_drive ( void ) ;
extern void break_point(void) ;	/* from traps.h	*/

# endif __GLOBAL__
