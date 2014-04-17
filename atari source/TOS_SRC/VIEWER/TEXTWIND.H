/* textwind.h	text window handler definitions
 *=======================================================================
 * 920610 kbad
 */
#include "windows.h"

/* Definitions & data types
 *-----------------------------------------------------------------------
 */
#define TW_MAXLEN		128			/* maximum line length */
#define WINTYPE_TEXT	0x54455854L	/*TEXT*/

typedef struct textwind *TEXTWIND;

struct textwind {
struct wind	w;
	char	**lines;	/* line starts array */
	WORD	tabsize;
	WORD	font, pts;
};


/* Functions
 *=======================================================================
 */
WORD	tw_new __PROTO((int kind, int wsid, int font, int pts,
						char *buf, long bufsize, int tabsize));
void	tw_free __PROTO((WIND w));
