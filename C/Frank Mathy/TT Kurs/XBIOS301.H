#include <tos.h>

long	Bconmap(int devno);
long	DMAread(long sector,int count,void *buffer,int devno);
long	DMAwrite(long sector,int count,void *buffer,int devno);
int		NVMaccess(int op,int start,int count,char *buffer);

struct devline {
	int     (*Bconstat)( int dev );
	long    (*Bconin)( int dev );
	long    (*Bcostat)( int dev );
	void    (*Bconout)( int dev, int c );
	long    (*Rsconf)( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
	IOREC   *(*Iorec)( int dev );
};

struct bconmap {
	long *maptab;				/* ptr to map table (consists of devline structures) */
	int maptabsize;				/* number of lines in the table */
};
