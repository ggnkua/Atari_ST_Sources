/* gifcode.h - Include file for GIF encoder/decoder routines. */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

#define GIF_MAXCODES 4096
typedef struct {
	FFILE *ff;
	unsigned char curblock[256];
	int curblocksize,curblockpos;
	int nbits;
	long bits;
	int datasize;
	int clear,eoi;
	int prefix[GIF_MAXCODES];
	unsigned char suffix[GIF_MAXCODES];
	int codesize,codemask;
	int avail;
	union {
		struct {
			int sl_ptr[GIF_MAXCODES];
			int sl_index;
			unsigned char sl_suffix[GIF_MAXCODES];
			int sl_newprefix[GIF_MAXCODES];
			int sl_next[GIF_MAXCODES];
			int curprefix;
		} e;
		struct {
			int prevc;
			unsigned char first[GIF_MAXCODES];
			unsigned char cstack[GIF_MAXCODES];
			int csttop;
		} d;
	} u;
} GIF_CODER;

/* functions/macros used internally only: */
extern int gif___f_decode_c P((GIF_CODER *gc),());

/* functions/macros for external use: */
extern void gif_start_encoding P((GIF_CODER *gc, FFILE *ff, int datasize),());
/* Prepares to encode an image to ff. Normally datasize will be the bits per
	pixel for the image, except for binary images where datasize = 2. */
extern int gif_encode_c P((int c, GIF_CODER *gc),());
/* Encodes a single pixel. Returns 0 on success, or -1 on failure. */
extern int gif_end_encoding P((GIF_CODER *gc),());
/* Ends encoding. Returns 0 on success, or -1 on failure. */
extern void gif_start_decoding P((GIF_CODER *gc, FFILE *ff, int datasize),());
/* Prepares to decode an image from ff. Normally datasize will be the bits per
	pixel for the image, except for binary images where datasize = 2. */
#define gif_decode_c(gc) ((gc)->u.d.csttop>0 \
	? (gc)->u.d.cstack[--((gc)->u.d.csttop)] : gif___f_decode_c(gc))
/* Decodes a single pixel. Returns a pixel value on success, or -1
	on failure. */
int gif_end_decoding P((GIF_CODER *gc),());
/* Ends decoding. Returns 0 on success, or -1 on failure. */
