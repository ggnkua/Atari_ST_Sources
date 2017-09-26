#define BPB struct _bpb
#define BCB struct _bcb
#define MD struct _md
#define MPB struct _mpb
#define PD struct _pd

PD				/* base page format */
{
	long	p_lowtpa;	/* 00 */
	long	p_hitpa;	/* 04 */
	long	p_tbase;	/* 08 */
	long	p_tlen;		/* 0C */
	long	p_dbase;	/* 10 */
	long	p_dlen;		/* 14 */
	long	p_bbase;	/* 18 */
	long	p_blen;		/* 1C */
	long	p_0fill[3];	/* 20 */
	char	*p_env;		/* 2C */
	long	p_1fill[20];	/* 30 */
	char	p_cmdlin[0x80];	/* 80 */
} ;

MD				/* memory descriptor */
{
	MD	*m_link;
	long	m_start;
	long	m_length;
	PD	*m_own;
} ;

MPB				/* memory partition block */
{
	MD	*mp_mfl;
	MD	*mp_mal;
	MD	*mp_rover;
} ;

BPB				/* bios parameter block */
{
	int	recsiz;			/* sector size in bytes */
	int	clsiz;			/* cluster size in sectors */
	int 	clsizb;			/* cluster size in bytes */
	int	rdlen;			/* root directory length in records */
	int	fsiz;			/* fat size in records */
	int	fatrec;			/* first fat record (of last fat) */
	int	datrec;			/* first data record */
	int	numcl;			/* number of data clusters available */
	int	b_flags;
} ;

BCB				/* buffer control block */
{
	BCB	*b_link;
	int	b_bufdrv;
	int	b_buftyp;
	int	b_bufrec;
	int	b_dirty;
	long	b_fill;
	char	*b_bufr;
} ;

/*************************************
**
** BIOS level character device handles
**
**************************************
*/

#define	BFHPRN	0
#define	BFHAUX	1
#define	BFHCON	2
#define	BFHCLK	3
#define	BFHMOU	4
