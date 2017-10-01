/*  mem.h - header file for memory and process management routines	*/


/*
**  conditional compile switches
*/

#define	OSMPANIC	FALSE
#define	OSMLIST		FALSE


/*
**  externals
*/

extern	FTAB	sft[] ;
extern	long	errbuf[3] ;			/*  sup.c  */
extern	MPB	pmd ;
extern	int	osmem[] ;
extern	int	osmlen ;
extern	int	*root[20];
extern	int	osmptr;

extern	long	trap13() ;
extern	long	xmalloc() ;
extern	long	xsetblk() ;
extern	MD	*ffit() ;

/*
**  process management
*/

extern	long	bakbuf[] ;
extern	int	supstk[] ;
extern	PD	*run;

extern	long	xexec() ;
extern	VOID	xterm() ;
extern	VOID	x0term() ;


