/* tic.h & 11.11.93 & WA	*/


typedef struct
{
	uword id;
	uword size ;
	ulong count ;
	uword value[2] ;
} TICnumTag ;

typedef struct
{
	char type[2] ;
	uword magic ;
	ulong ifdoffset ;

	uword tagcount ;

	TICnumTag numtags[7] ;

	ulong nootherifd ;
	uword bps[3];
	long  stripoffs[3];
} TTicHeader ;

# define NUMtag(t,s,n,a,b)	{t,s,n,{a,b}}
# define DEFAULTticHeader \
{\
	"MM", 42, 8,\
	7,\
	{\
		NUMtag(0x100,3,1,320,0),\
		NUMtag(0x101,3,1,240,0),\
		NUMtag(0x102,3,3,0,0x0062),\
		NUMtag(0x106,3,1,2,0),\
		NUMtag(0x111,4,3,0,0x0068),\
		NUMtag(0x115,3,1,3,0),\
		NUMtag(0x11C,3,1,2,0)\
    },\
	0,\
	{8,8,8},\
    {0x0074,0,0}\
} ;

# if sizeof ( TTicHeader ) != 0x0074
*** error in TTicHeader definition
# endif

