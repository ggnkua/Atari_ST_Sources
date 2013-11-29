#define UBYTE unsigned char

/* EA handy make a long from 4 chars macros redone to work with Aztec*/
#define MAKE_ID(a, b, c, d)\
	( ((long)(a)<<24) + ((long)(b)<<16) + ((long)(c)<<8) + (long)(d) )

/* these are the IFF types I deal with */
#define FORM MAKE_ID('F', 'O', 'R', 'M')
#define ILBM MAKE_ID('I', 'L', 'B', 'M')
#define BMHD MAKE_ID('B', 'M', 'H', 'D')
#define CMAP MAKE_ID('C', 'M', 'A', 'P')
#define BODY MAKE_ID('B', 'O', 'D', 'Y')

union bytes4
	{
	char b4_name[4];
	long b4_type;
	};

struct iff_chunk
	{
	union bytes4 iff_type;
	long iff_length;
	};

struct form_chunk
	{
	union bytes4 fc_type; /* == FORM */
	long fc_length;
	union bytes4 fc_subtype;
	};

struct BitMapHeader
	{
	UWORD w, h;
	UWORD x, y;
	UBYTE nPlanes;
	UBYTE masking;
	UBYTE compression;
	UBYTE pad1;
	UWORD transparentColor;
	UBYTE xAspect, yAspect;
	WORD pageWidth, pageHeight;
	};
