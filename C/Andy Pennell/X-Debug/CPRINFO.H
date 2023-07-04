
/* cprinfo.h based on Amiga SAS docs */

/* made up DBGARG, added func2 type */

/* AMP additions here:	*/
typedef unsigned short BLK_TYP;
#define STORECLASS 1
#define	NEWFUNC(x)	(strcmp(" V5.44",x)<=0)
/*						*/


#define DEBUG_VERSION "DBGV07"

typedef unsigned char BYTE;
typedef unsigned short UNS16;
typedef unsigned long UNS32;
typedef long RANGE;
typedef unsigned long ATTR_TYPE;

typedef struct
{
	char signature[6];			/* "DBGVnn" */
	UNS16 options;
	UNS32 code_end;
	UNS16 dgroup;
	UNS16 num_modules;
	long int mod_start;
} DBG_HEADER;

#define DBG_HDRSIZE sizeof(DBG_HEADER)

#define DBG_IGNORECASE	0x1
#define DBG_OVERLAID	0x2

#ifndef DEBUGGER
#define MAXMOD 32
#endif

typedef struct
{
	char name[MAXMOD];
	UNS32 start;
	UNS32 code_size;
	UNS32 linnum_size;
	UNS32 sym_size;
	UNS32 source_len;
} DBG_MODULE;

#define DBG_MODSIZ	(MAXMOD+14)

#define DBG_CHIP	0x01
#define	DBG_FAR		0x02
#define	DBG_HUGE	0x04
#define	DBG_DATA	0x08
#define	DBG_NDATA	0x10
#define	DBG_BSS		0x20
#define	DBG_FAR_BSS	0x40
#define	DBG_HUGE_BSS	0x80

typedef struct
{
	UNS16 module_index;
	UNS16 overlay;
	UNS32 entry_point;
	UNS16 link;
	BYTE namelen;
} DBG_FUNCTION;

#define DBG_FUNCSIZE	11

#define DBG_EXTSIZ	5

#define NDBGHEAD	0
#define NDBGFUNC	1
#define NDBGBLK		2
#define NDBGID		3
#define NDBGTAG		4
#define NDBGMEM		5
#define NDBGCTX		7
#define NDBGARG		8
#define NDBGPPS		9
#define NDBGMAX		9

#ifndef DEBUGGER
typedef unsigned char UNS8;
#endif

#define do_node(fncs,node,name,text) \
 if ((fncs)[*(node)]) (fncs[*(node)](((btype_t *)(node))+1,name,text); \
 else;

#define DBG_NAME unsigned char dbgname[] = { 0,1,0,1,1,1,0,0,0,1 }

/* note: this uses DBGFUNC, may need fixing to DBGFUNC2 */
#define DBG_SIZE unsigned char dbgsize[] = { \
	sizeof(struct DBGHEAD), sizeof(struct DBGFUNC), sizeof(struct DBGBLK), \
	sizeof(struct DBGID),   sizeof(struct DBGTAG),  sizeof(struct DBGMEM), \
	0,						sizeof(struct DBGCTX),  sizeof(struct DBGARG), \
	sizeof(struct DBGPPS) }

typedef void (*DBG_FUNCS[10]) ();

typedef unsigned char btype_t;

struct DBGHEAD {
	BLK_TYP blockno;
	BLK_TYP totalblks;
	UNS16 options;
	BLK_TYP func;
	BLK_TYP stats;
	BLK_TYP exts;
	BLK_TYP typedefs;
	BLK_TYP tags;
#if 0
	BLK_TYP pps;
#endif
	char version[8];
	} ;
#define SIZDBGHEAD (sizeof(struct DBGHEAD))

struct DBGFUNC {
	BLK_TYP blockno;
	BLK_TYP link;
	BLK_TYP fblk;
	BLK_TYP stats;
	BLK_TYP exts;
	BLK_TYP autos;
	BLK_TYP typedefs;
	BLK_TYP tags;
	UNS16 flno;
	UNS16 llno;
	UNS32 attr;
	BLK_TYP cont;
	BLK_TYP aggr;
	BLK_TYP parms;
	RANGE localoff;
	};
#define SIZDBGFUNC (sizeof(struct DBGFUNC))

struct DBGFUNC2 {
	BLK_TYP blockno;
	BLK_TYP link;
	BLK_TYP fblk;
	BLK_TYP stats;
	BLK_TYP exts;
	BLK_TYP autos;
	BLK_TYP typedefs;
	BLK_TYP tags;
	UNS16 flno;
	UNS16 llno;
	UNS32 attr;
	BLK_TYP cont;
	BLK_TYP aggr;
	BLK_TYP parms;
	BLK_TYP arg;		/* new in 5.44 */
	RANGE localoff;
	};
#define SIZDBGFUNC2 (sizeof(struct DBGFUNC2))

struct DBGBLK {
	BLK_TYP blockno;
	BLK_TYP slink;
	BLK_TYP clink;
	BLK_TYP stats;
	BLK_TYP exts;
	BLK_TYP autos;
	BLK_TYP typedefs;
	BLK_TYP tags;
	UNS16 flno;
	UNS16 llno;
	};
#define SIZDBGBLK (sizeof(struct DBGBLK))

struct DBGID {
	BLK_TYP blockno;
	BLK_TYP link;
	UNS32 attr;
	RANGE offset;
	BLK_TYP aggr;
	BLK_TYP cont;
	};
#define SIZDBGID (sizeof(struct DBGID))

struct DBGTAG {
	BLK_TYP blockno;
	BLK_TYP link;
	UNS32 attr;
	RANGE size;
	BLK_TYP list;
	};
#define SIZDBGTAG (sizeof(struct DBGTAG))

struct DBGMEM {
	BLK_TYP blockno;
	BLK_TYP link;
	UNS32 attr;
	UNS16 field;
	BLK_TYP aggr;
	BLK_TYP cont;
	RANGE offset;
	};
#define SIZDBGMEM (sizeof(struct DBGMEM))

#define NOARGS	(MAXARG+1)

struct DBGPPS {
	BLK_TYP blockno;
	BLK_TYP link;
	UNS16 start;
	UNS16 end;
	UNS8 args;
	};
#define SIZDBGPPS (sizeof(struct DBGPPS))

struct DBGCTX {
	BLK_TYP blockno;
	BLK_TYP link;
	UNS16 type;
	union { BLK_TYP parms;
			RANGE length;
		  } x;
	};
#define SIZDBGCTX (sizeof(struct DBGCTX))

/* this is made up by AMP */
struct DBGARG {
	BLK_TYP blockno;
	BLK_TYP crap[6];
};
#define SIZDBGARG	(sizeof(struct DBGARG))

union DBGUNION {
	struct DBGHEAD dhead;
	struct DBGFUNC dfunc;
	struct DBGFUNC2 dfunc2;
	struct DBGBLK dblk;
	struct DBGID did;
	struct DBGTAG dtag;
	struct DBGMEM dmem;
	struct DBGCTX dctx;
	};
struct DBGSLST {
	UNS32 offset;
	UNS16 type;
	char *name;
	};

#define UNS		8
#define	VOID	7
#define	DEC		6
#define	DOUBLE	5
#define	LDOUBLE	DOUBLE
#define	FLOAT	4
#define	DLONG	3
#define	LONG	2
#define	SHORT	1
#define	CHAR	0

#define	ARITYPE	0x07
#define	SARITYP	0x0F

#ifdef FPFLAG
#define	HASPTR	0x00000100L
#endif

#define	LANG	0x00c80000
#define	SPECARG	0x00080000
#define	REGARGS	0x00400000
#define	HLLANG	0x00c80000
#define	PASCAL	0x00c00000
#define	INTSERV	0x00800000
#define	TOPREG	0x00001000L

#define SUPRESS	0x80000000L

#define	UINIT	0x80000000L
#define	STRING	0x40000000L
#define	REG		0x20000000L
#define	DEF		0x10000000L
#define	FORMAL	0x08000000L
#define	AUTO	0x04000000L
#define	REF		0x02000000L
#define	STATIC	0x01000000L

#ifdef STORECLASS
#define	CHIP	0x00800000L
#define	HUGE	0x00400000L
#define	NEAR	0x00200000L
#define	FAR		0x00100000L
#define	INVERT	0x00080000L
#define	EXSECTS (NEAR|FAR|CHIP|HUGE)
#else
#define NEAR 0
#define FAR 0
#define INVERT 0
#define EXSECTS 0
#endif

#define TYPED	0x00040000L
#define	ENUMID	0x00020000L
#define	LOCAL	0x00010000L
#define	POINTER	0x00008000L
#define	NEW		0x00004000L
#define	USED	0x00002000L
#define	UNDEF	0x00001000L
#define	CONST	0x00000400L
#define	VOLATILE	0x00000200L
#define	NOALIAS	0x00000010L

#ifdef REGDES
#define	ASMREG	0x00000010L
#else
#define ASMREG	0
#endif

#define SAVEDS	0x00000800L
#define	INTR	0x00000100L
#define	NOTINT	0x00000080L
#define	SIGNED	0x00000040L
#define	NEWFORM	0x00000020L

#define	STRUCT	0L
#define	UNION	1L
#define	ENUM	2L

#define BITOFFS	0x0000FF00L
#define	BITATTR	0x000000F0L

#ifdef USEPAD
#define PADJJR	SUPRESS
#define NOPAD	STRING
#define	PAD64K	FORMAL
#else
#define	PADJJR	0
#define	NOPAD	0
#define	PAD64K	0
#endif

#ifdef USEALMEM
#define	ALMEM	REG
#define	NOALMEM	DEF
#define	ALT_ALIGN	0x1
#define	ALT_NOALIGN	0x2
#else
#define	ALMEM	0
#define	NOALMEM	0
#endif

