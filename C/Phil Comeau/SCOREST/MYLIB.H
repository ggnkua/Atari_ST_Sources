/* Mylib:	Definitions used by clients of Mylib library
 * phil comeau 15-jun-89
 * last edited 21-aug-89 0009
 *
 * Copyright 1990 Antic Publishing Inc.
 *
 */

/* Constants. */

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif /* TRUE */
#define BITSPERBYTE 8
#define EOS '\0'
#define TICKSPERSEC 200			/* # ticks/sec returned by GetTicks
					 */

/* Types. */

/* BITMASKs:	Sets of binary bits in various widths. */
typedef unsigned char BITMASK8;
typedef unsigned short BITMASK16;
typedef unsigned long BITMASK32;

/* Signed and unsigned integers in various widths. */
typedef char S8;
typedef unsigned char U8;
typedef short S16;
typedef unsigned short U16;
typedef long S32;
typedef unsigned long U32;

/* BOOLEAN:	Holds TRUE or FALSE. Expressions of this type may reliably
 *		by used in C conditional expressions.
 */
typedef short BOOLEAN;


/* Macros */

/* MIN: return smaller of two values */
#define MIN(a, b) ((a) < (b) ? (a) : (b))

/* MAX: return larger of two values */
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* LOW8: Return lower 8 bits of 16-bit value */
#define LOW8(v) ((v) & 0xff)

/* HI8: Return upper 8 bits of 16-bit value */
#define HI8(v) (((v) >> 8) & 0xff)

/* LOW16: Return lower 16 bits of a 32-bit value */
#define LOW16(v) (unsigned short)((v) & 0xffff)

/* HI16: Return upper 16 bits of a 32-bit value */
#define HI16(v) (unsigned short)(((v) >> 16) & 0xffff)

/* COPY: Copy a block of memory n bytes long from s to d, byte by byte. */
#define COPY(s, d, n) { \
	register char *ps = (char *)(s), *pd = (char *)(d); \
	register int nn = (n); \
	while ((nn)--) *pd++ = *ps++; \
}

/* COPYW: Copy a block of memory in 16-bit chunks. s and d must point to
 *	words. n is the number of 16-bit words to copy.
 */
#define COPYW(s, d, n) { \
	register short *ps = (short *)(s), *pd = (short *)(d); \
	register int nn = (n); \
	while ((nn)--) *pd++ = *ps++; \
}

/* FILL: Fill a block of memory (p) n bytes long with a specified value (v).
 */
#define FILL(p, v, n) { \
	register char *pp = (char *)(p); \
	register int nn = (n); \
	while ((nn)--) *pp++ = (v); \
}

/* ISLEAP:	Return TRUE if year is a leap year. */
#define ISLEAP(year) ((year) % 4 == 0 && (year) % 100 != 0 && \
   (year) % 400 != 0)

/* MASK:	Create a bitmask from a bit number */
#define MASK(b) (1 << (b))

/* SETBIT:	Set bit b in mask m */
#define SETBIT(m, b) ((m) |= MASK(b))

/* CLEARBIT:	Clear bit b in mask m */
#define CLEARBIT(m, b) ((m) &= ~MASK(b))

/* ISBITSET:	Return TRUE if bit b is set in mask m */
#define ISBITSET(m, b) (((m) & MASK(b)) != 0)

/* Function definitions */
extern char *catc();
extern int CmpStr();
extern void delay();
extern void dump();
extern FILE *efopen();
extern void EFree();
extern char *EMalloc();
extern char *ERealloc();
extern BOOLEAN FindInt();
extern char *getExt();
extern long GetTicks();
extern char *getwrd();
extern char *itox();
extern void LoadEnv();
extern BOOLEAN MapInt();
extern BOOLEAN match();
extern char *mkNewExt();
extern char *skipws();
extern int strip();
extern char *strlower();
extern char *strsave();
extern unsigned int xtoi();
