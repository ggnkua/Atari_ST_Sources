/****************************************************************************\
|*		CLIP.H																*|
|*--------------------------------------------------------------------------*|
|*	by Russ Wetmore															*|
|*		Last revision:	11/04/86 15:06:14									*|
\****************************************************************************/
/*------------------------------*\
|*	portability concerns		*|
\*------------------------------*/
#ifdef ALCYON
typedef char			BYTE, UBYTE;	/* Alcyon used to be pretty dumb...	*/
typedef short			WORD, VOID, BOOLEAN;
typedef unsigned int	UWORD;
typedef long			LONG, ULONG;	/* ...about unsigned anything		*/
#endif

#ifdef MEGAMAX
typedef char			BYTE;
typedef unsigned char	UBYTE;
typedef int				WORD, VOID, BOOLEAN;
typedef unsigned int	UWORD;
typedef long			LONG;
typedef unsigned long	ULONG;
#endif

#define REG		register
#define IMPORT	extern					/* Variables imported to a module	*/
#define FORWARD	extern					/* Forward reference declarations	*/
#define GLOBAL	/**/					/* Variables are default global		*/
#define LOCAL	static					/* Variables local to a module		*/
	
/*------------------------------*\
|*	definitions					*|
\*------------------------------*/
typedef struct {
	LONG	size;						/* Size of present clipboard		*/
	BYTE	*location;					/* Pointer to the data itself		*/
	WORD	dirty;						/* Boolean says "data has changed"	*/
	WORD	where;						/* Where clipboard data is now		*/
	BYTE	filename[16];				/* Name of clipboard disk file		*/
} clipInfo;

IMPORT	WORD			clipboard();
IMPORT	WORD			InfoClip();
#define UnloadClip()	clipboard(1)
#define LoadClip()		clipboard(2)
#define ZeroClip()		(VOID)clipboard(3)
#define PutClip(a,b)	clipboard(4,a,b)
#define GetClip(a,b,c)	clipboard(5,a,b,c)
#define InitClip()		clipboard(6)
