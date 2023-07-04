
struct remefad {
	ulong addr;
	byte esize;
	bool immed;
	};
/* this is non-zero if remembering is required - an array of two elems */
extern struct remefad *remefad;


#define	SIZE_BYTE	0
#define	SIZE_WORD	1
#define	SIZE_LONG	2
#define	SIZE_BAD	3
#define	SIZE_QUAD	4
#define	SIZE_EXTENDED	5
#define	SIZE_DECIMAL	6
#define	SIZE_DOUBLE		7
#define	SIZE_SINGLE		8

#define	DISS_SPECIAL	16
