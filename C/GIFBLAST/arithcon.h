/* arithcon.h - Include file for arithmetic coding context routines. */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

#define ARCON_NCODES 256 /* must be power of two */
typedef unsigned char ARCON_CODETYPE;
/* must be able to contain 0 .. ARCON_NCODES-1 */

#define ARCON_BIG_RBSIZE 1792
typedef struct {
	ARCON_CODETYPE rb[ARCON_BIG_RBSIZE];
	int count,tail;
	int freqs[2*ARCON_NCODES-1];
} ARCON_BIG_CONTEXT;

#ifndef ARCON_SMALL_RBSIZE
#define ARCON_SMALL_RBSIZE 20
#endif
typedef struct {
	ARCON_CODETYPE rb[ARCON_SMALL_RBSIZE];
	char count,tail;
	ARCON_CODETYPE hits[ARCON_SMALL_RBSIZE];
	char hitfreqs[ARCON_SMALL_RBSIZE];
	char nhits;
} ARCON_SMALL_CONTEXT;

#ifndef ARCON_NTYPES
#define ARCON_NTYPES 5
#endif
#define ARCON_MAXTYPEFREQ 512
typedef struct {
	int freqs[ARCON_NTYPES];
	int totfreq;
} ARCON_TYPE_CONTEXT;

/* Routines to keep track of large contexts: */
extern void arcon_big_init P((ARCON_BIG_CONTEXT *ac),());
/* Initializes a large context. */
extern int arcon_big_add P((ARCON_BIG_CONTEXT *ac, int c),());
/* Adds c to ac. Returns 0 on success, or -1 on failure. */
#define arcon_big_rtot(ac) ((ac)->freqs[2*ARCON_NCODES-2])
/* Returns the current total frequency of ac. */
extern int arcon_big_find_range P((ARCON_BIG_CONTEXT *ac,
	int c, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range for c in ac. Returns the
	size of this range, 0 if not found. */
extern int arcon_big_find_c P((ARCON_BIG_CONTEXT *ac,
	int rpos, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range that contains rpos in ac.
	Returns the character that corresponds to this range, -1 if not found. */

/* Routines to keep track of small contexts: */
extern void arcon_small_init P((ARCON_SMALL_CONTEXT *ac),());
/* Initializes a small context. */
extern int arcon_small_add P((ARCON_SMALL_CONTEXT *ac, int c),());
/* Adds c to ac. Returns 0 on success, or -1 on failure. */
#define arcon_small_rtot(ac) ((ac)->count)
/* Returns the current total frequency of ac. */
extern int arcon_small_find_range P((ARCON_SMALL_CONTEXT *ac,
	int c, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range for c in ac. Returns the
	size of this range, 0 if not found. */
extern int arcon_small_find_c P((ARCON_SMALL_CONTEXT *ac,
	int rpos, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range that contains rpos in ac.
	Returns the character that corresponds to this range, -1 if not found. */

/* Routines to keep track of type contexts: */
extern void arcon_type_init P((ARCON_TYPE_CONTEXT *ac),());
/* Initializes a type context. */
extern int arcon_type_add P((ARCON_TYPE_CONTEXT *ac, int c),());
/* Adds c to ac. Returns 0 on success, or -1 on failure. */
extern int arcon_type_rtot P((ARCON_TYPE_CONTEXT *ac, int t),());
/* Returns the current total frequency of ac up to and including type t. */
extern int arcon_type_find_range P((ARCON_TYPE_CONTEXT *ac,
	int c, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range for c in ac. Returns the
	size of this range, 0 if not found. */
extern int arcon_type_find_c P((ARCON_TYPE_CONTEXT *ac,
	int rpos, int *prstart, int *prend),());
/* Sets *prstart..*prend to the current range that contains rpos in ac.
	Returns the character that corresponds to this range, -1 if not found. */
