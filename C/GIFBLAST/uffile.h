/* uffile.h - Include file for portable fast file routines, UNIX version. */

#ifndef P_DEFINED
#define P_DEFINED
#ifdef NOPROTOS
#define P(a,b) b
#else
#define P(a,b) a
#endif
#endif

#define FFILEBUFSIZE 16384
#define BITS_IN_CHAR 8

enum {FF_READ,FF_WRITE};
typedef struct {
	FILE *f;
	int mode;
	size_t pos,count;
	long bits,tmpbits;
	char nbits;
	char onebitpos;
	unsigned char buf[FFILEBUFSIZE];
} FFILE;

/* functions/macros used internally only: */
extern int ff___inbuf P((FFILE *ff),());
extern int ff___outbuf P((int c, FFILE *ff),());
extern int ff___in1bit P((FFILE *ff),());
extern int ff___out1bit P((FFILE *ff, int bit),());
#define ff___advance_put1bitpos(ff) ((ff)->onebitpos==BITS_IN_CHAR-1 \
	? ((ff)->onebitpos=0, (ff)->count++) : (ff)->onebitpos++)

/* functions/macros for external use: */

/* The following work similarly to the standard i/o library. */
extern FFILE *ff_open P((char *fpath, int mode),());
/* Opens a new file (mode is FF_READ or FF_WRITE). Returns NULL on failure. */
#define ff_getc(ff) ((ff)->pos==(ff)->count \
	? ff___inbuf(ff) : (ff)->buf[(ff)->pos++])
/* Reads a single character from ff. Returns EOF on end of file. */
extern int ff_ungetc P((int c, FFILE *ff),());
/* Undoes a single character read from ff. The next read on ff will return c.
	At least one character may always be undone. May not be called with EOF
	as argument. Returns c, or EOF on failure. */
extern size_t ff_read P((char *buf, size_t n, FFILE *ff),());
/* Reads n characters from ff and places them into buf. Returns the number
	of characters successfully read. This may be less than n if end of file
	was reached during the read. */
#define ff_putc(c,ff) ((ff)->count==FFILEBUFSIZE \
	? ff___outbuf(c,ff) : ((ff)->buf[(ff)->count++]=(c)))
/* Writes a single character to ff. Returns EOF on failure. */
extern int ff_unputc P((FFILE *ff),());
/* Undoes a single character written to ff. If any characters have been
	written to ff, and ff_seek or ff_flush has not been called in the
	interim, then at least one character may be undone. Returns the last
	character written to ff, or EOF on failure. */
extern size_t ff_write P((char *buf, size_t n, FFILE *ff),());
/* Writes n characters from buf to ff. Returns the number of characters
	successfully written. This may be less than n if a disk write was
	unsuccessful (usually caused by a full disk). */
extern int ff_seek P((FFILE *ff, long offset, int whence),());
/* Seeks to a position in ff. Returns 0 on success, nonzero on failure. */
extern long ff_tell P((FFILE *ff),());
/* Returns the current position in ff, -1L on  failure. */
extern int ff_flush P((FFILE *ff),());
/* If ff is open for reading, discards any buffered input. Otherwise,
	writes all buffered output. Returns 0 on success, EOF on failure. */
extern int ff_close P((FFILE *ff),());
/* Closes ff, flushing buffers and freeing the storage used by ff. Returns 0
	on success, EOF on failure. */

/* The following is an optimized set of 1bitstream functions for the case
	where we only read or write one bit at a time. To begin, ff_start1bit
	must be called. Then, a series of ff_get1bit or ff_put1bit calls may
	be made, accordingly as the fast file structure is open for reading
	or writing. Finally, ff_end1bit must be called to end 1bitstream mode.
	None of the other routines above should be called while in 1bitstream
	mode (between ff_start1bit and ff_end1bit calls). */
extern void ff_start1bit P((FFILE *ff),());
/* Initializes 1bitstream state for ff. */
#define ff_get1bit(ff) ((ff)->pos==(ff)->count ? ff___in1bit(ff) \
	: ((ff)->onebitpos==BITS_IN_CHAR-1 \
		? ((ff)->onebitpos=0, \
			(((ff)->buf[(ff)->pos++]&(1<<(BITS_IN_CHAR-1))) != 0)) \
		: (((ff)->buf[(ff)->pos]&(1<<(ff->onebitpos++))) != 0)))
/* Reads one bit from ff. Returns -1 on failure. */
#define ff_put1bit(ff,b) ((ff)->count==FFILEBUFSIZE ? ff___out1bit(ff,b) \
	: (((ff)->onebitpos==0 && ((ff)->buf[(ff)->count]=0)), \
		(((b)&1)==0 ? (ff___advance_put1bitpos(ff), 0) \
			: ((ff)->buf[(ff)->count]|=(1<<(ff)->onebitpos), \
				ff___advance_put1bitpos(ff), 1))))
/* Writes the low bit of b to ff. Returns the low bit of b, or -1
	on failure. */
extern int ff_end1bit P((FFILE *ff),());
/* Ends 1bitstream state for ff. Returns 0 on success, or -1 on failure. */
