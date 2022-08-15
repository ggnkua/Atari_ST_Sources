#ifndef SKY_H
#define SKY_H

#define TP_MAGIC1 "GfABASIC"   /* Magic for version 1 and 2 files */
#define TP_MAGIC3 "GFA-BASIC3" /* Magic for version 3 and 4 files */
#define TP_MAGICA "GFA-AMIGAB" /* Magic for Amiga files */
#define TP_MAGIMS "A-BASIC MS-DOS" /* Magic for DOS BASIC files */
#define TP_MAGIW3 "A-BASIC WIN300" /* Magic for WIN BASIC files */

/* gf4tp_tp flags */
#define TP_BACKW  0x01 /* Scan backwards */
#define TP_CONV   0x02 /* Convert charset */
#define TP_VERB   0x04 /* Be verbose */
#define TP_TIME   0x08 /* Measure time */
#define TP_BUGEM  0x10 /* Emulate bugs */

struct gfahdr {
	unsigned char resvd:7;
	enum {TP_SAVE, TP_PSAVE} type:1;            /* List type/protection */
	unsigned char vers;                         /* File format version */
	                                            /*  1: Atari, V1.0 */
	                                            /*  2: Atari, V2.0 */
	                                            /*  3: Atari, V3.0 */
	                                            /*     Amiga, V3.5 */
	                                            /*  4: Atari, V3.5 */
	                                            /* 70: MS-DOS */
	                                            /*     Windows */
	unsigned char mag[18];                      /* Magic */
	unsigned int sep[38];                       /* 38 x 32 Bit Memory
	                                             * Separators
	                                             */
};

struct gfainf {
	struct gfahdr *hdr;                         /* Header */
	unsigned char **ident[16];                  /* Identifier list */
	unsigned char **fld;                        /* Pointer field */
	unsigned char *pool;                        /* Memory pool */
	/* XXX In-Depth documentation of field and pool lacking here. */
};

struct gfalin {
	unsigned short size;                        /* Length of the line */
	short depth;                                /* Indent depth */
	unsigned char *line;                        /* Pointer to line buffer */
};

unsigned char *gf4tp_tp(unsigned char *dst, struct gfainf *gi, 
                        struct gfalin *gl, unsigned int flags);
void gf4tp_getgi(struct gfainf *gi, unsigned char *src);
void gf4tp_getdi(struct gfainf *gi, unsigned char *src);
void gf4tp_getii(struct gfainf *gi, unsigned char *src,
                 unsigned char **ptr);
void gf4tp_init(int (*output)(const char *format, ...), 
                unsigned char *(*resvar)(struct gfainf *gi,
                                         unsigned short type,
                                         unsigned short var));

/* GFA-BASIC files come from M68K platform and use 8 bits per byte */

#define M68K_BIT 8

#define shift64b(dst, src) \
	*dst    = *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst++ |= *src++

#define pop64b(dst, src) \
	 dst    = *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++

#define copy64b(dst, src) \
	 dst    = src[0],  dst <<= M68K_BIT, \
	 dst   |= src[1],  dst <<= M68K_BIT, \
	 dst   |= src[2],  dst <<= M68K_BIT, \
	 dst   |= src[3],  dst <<= M68K_BIT, \
	 dst   |= src[4],  dst <<= M68K_BIT, \
	 dst   |= src[5],  dst <<= M68K_BIT, \
	 dst   |= src[6],  dst <<= M68K_BIT, \
	 dst   |= src[7]

/* Pushes big endian 32 bit from unsigned char *src to unsigned int *dst. 
 * Beware the expression *dst++ = *src++ << 24 | *src++ << 16 | ... whose
 * result is undefined in C.  This is avoided here by the usage of the
 * comma operator which introduces a sequence point.
 */

#define shift32b(dst, src) \
	*dst    = *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst   |= *src++, *dst <<= M68K_BIT, \
	*dst++ |= *src++

#define pop32b(dst, src) \
	 dst    = *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++

#define copy32b(dst, src) \
	 dst    = src[0],  dst <<= M68K_BIT, \
	 dst   |= src[1],  dst <<= M68K_BIT, \
	 dst   |= src[2],  dst <<= M68K_BIT, \
	 dst   |= src[3]

/* Same as above, but only handles 16 bit. */

#define shift16b(dst, src) \
	*dst    = *src++, *dst <<= M68K_BIT, \
	*dst++ |= *src++

#define pop16b(dst, src); \
	 dst    = *src++,  dst <<= M68K_BIT, \
	 dst   |= *src++

#define copy16b(dst, src) \
	 dst    = src[0],  dst <<= M68K_BIT, \
	 dst   |= src[1]

/* Convert non-negative GFA3 float to IEEE.
 * This version cannot handle negative values.
 *
 * This is a bytewise, portable version of the following
 * which requires 64 bit big endian unsigned ints:
 * dst   = src;
 * tmp   = src;
 * dst  &= 0x7FFFFFFFFFFFFFFFULL;
 * tmp  &= 0x00000000000007FFULL;
 * dst >>= 11;
 * tmp <<= 52;
 * dst  |= tmp;
 */
#define dgfabintoieee(dst, src) \
	/* copy src to dst, masking out the leftmost bit and \
	 * shifting the whole thing eleven bits right. \
	 */ \
	dst[7]   = src[5]  & 0x07, /* Copy three bits from the third byte */ \
	dst[7] <<= 5,              /* Shift them in position */ \
	dst[7]  |= src[6] >> 3,    /* Copy five bits from the second byte */ \
	dst[6]   = src[4]  & 0x07, /* ... */ \
	dst[6] <<= 5, \
	dst[6]  |= src[5] >> 3, \
	dst[5]   = src[3]  & 0x07, \
	dst[5] <<= 5, \
	dst[5]  |= src[4] >> 3, \
	dst[4]   = src[2]  & 0x07, \
	dst[4] <<= 5, \
	dst[4]  |= src[3] >> 3, \
	dst[3]   = src[1]  & 0x07, \
	dst[3] <<= 5, \
	dst[3]  |= src[2] >> 3, \
	dst[2]   = src[0]  & 0x07, \
	dst[2] <<= 5, \
	dst[2]  |= src[1] >> 3, \
	dst[1]   = src[0]  & 0x78, /* Mask out the left and three rightmost bits */\
	dst[1] >>= 3,              /* Shift that in position */ \
	/* shift the lower 11 bits by 52 bits left and inject that to \
	 * the destination.\
	 */ \
	dst[0]   = src[6]  & 0x07, /* shift bits 11..9 left by 48 bits */ \
	dst[0] <<= 4,              /* shift bits 11..9 the remaining four bits. */ \
	dst[0]  |= src[7] >> 4,    /* shift bits  8..5 left by 52 bits */ \
	dst[1]  |= src[7] << 4 & 0xFF /* shift bits  4..1 left by 52 bits */

#define pushvar(dst, mrk, t, v, inf, res) \
	mrk = inf->hdr->type == TP_SAVE ? inf->ident[t][v] : res(inf, t, v); \
	while (*mrk != 0x00) \
		*dst++ = *mrk++; \
	mrk = gfavst[t]; \
	while (*mrk != 0x00) \
		*dst++ = *mrk++

#define pushsig(dst, num) \
	if (num < 0) \
		*dst++  = 0x2D, \
		num    *= -1
	
#define pushnum(dst, num, dim, bin, i, j, c) \
	bin = dst; \
	while (num != 0) { \
		*dst++ = gfanct[num % dim]; \
		num /= dim; \
	} \
	if (dst > bin) { \
		j  = dst - bin; \
		j /= 2; \
		dst--; \
		for (i = 0; i < j; i++) { \
			c       = dst[-i]; \
			dst[-i] = bin[ i]; \
			bin[ i] = c; \
		} \
		dst++; \
	} else \
		*dst++ = gfanct[0]



#endif

