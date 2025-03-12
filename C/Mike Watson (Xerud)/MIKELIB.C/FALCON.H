/*
** Used to build modecodes
*/
#define	VERTFLAG	0x100
#define	STMODES		0x80
#define	OVERSCAN	0x40
#define	PAL			0x20
#define	VGA			0x10
#define	TV			0x0
#define	COL80		0x8
#define	COL40		0x0
#define	NUMCOLS		7
#define	BPS16		4
#define	BPS8		3
#define	BPS4		2
#define	BPS2		1
#define	BPS1		0

short	Montype(void);
short	Vsetmode(short);
long	VgetSize(short);
void	Vsetscreen(void *,void *,short,short);
