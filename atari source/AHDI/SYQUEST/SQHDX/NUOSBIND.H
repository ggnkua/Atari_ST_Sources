/* NUOSBIND.H	12/2/88	ml.	Started this.	*/

extern	long	bios();

/*	BIOS	(trap 13)	*/
#define	Lrwabs(a,b,c,d,e)	bios(4,a,b,c,-1,e,d)

