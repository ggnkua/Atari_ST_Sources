# define __LCALOAD__

# ifndef BYTESinMAP
# define BYTESinMAP	256
# endif

# ifndef LOADok
# define LOADok				0
# define LCAbusyTimeOut		1
# define LCAsignalsDone		2
# define LCAnoDoneSignal	3
# define LCAearlyDoneSignal	4
# define LCAbufferEmpty		5

# define LCAfileNotFound	6
# define LCAfileLoadError	7
# endif

typedef struct
{
	unsigned number ;
	unsigned bytes ;
	unsigned char Buffer[BYTESinMAP] ;
} LCAdata ;

typedef LCAdata *PLCAdata ;

extern LCAdata lca_data ;

extern int  LoadLcaDataBlock ( unsigned port ) ;
extern int  LoadLCA ( unsigned number, unsigned port, unsigned char *buffer, unsigned bytes ) ;
extern void ResetLCA ( unsigned port ) ;
