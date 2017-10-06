typedef struct
{
  short version;
  unsigned short headlen;
  short planes,
	pat_run,
	pix_width,
	pix_height,
	sl_width,
	sl_height;
}
IMG_HEADER;

/* Public struct for buffered file i/o.
 * data_func must be 'read' for file input, 'write' for file output.
 * It has the task to update the bytes_left entry with size of next
 * data if read, size of output buffer if write, and to set the pbuf
 * entry to point to the next data if read, output buffer if write.
 * NOTE: Because of the structure of the below input fetch macros,
 *       it is important to UPDATE (add, not set) the bytes_left
 *       entry with the new data buffer size if read!
 * The public struct should be used as substruct being the first
 * entry in a specific struct, which holds additional data (i.e.
 * data buffer pointer and data buffer size) to be used by data_func.
 * Look in the main module to see what is required.
 */

typedef struct fbufpub
{
  char *pbuf;
  long bytes_left;
  void (*data_func)(struct fbufpub *fp);
}
FBUFPUB;

/* Public struct for image data processing. */

typedef struct ibufpub
{
  char *pbuf;
  long bytes_left;
  void (*put_line)(struct ibufpub *ip);
  char *pat_buf;
  short pat_run;
  char vrc, pad;
}
IBUFPUB;


/* The following macros handle buffered file i/o and
 * image output based on the introduced structs.
 */

#define MAKESTMT(stuff)	  do { stuff } while (0)

#define FGETC(fp, dest)   \
  MAKESTMT( if (--(fp)->bytes_left < 0) (*(fp)->data_func)(fp); \
	    dest = *(fp)->pbuf++; )

#define FPUTC(fp, ch)   \
  MAKESTMT( *(fp)->pbuf++ = ch; \
	    if (--(fp)->bytes_left == 0) (*(fp)->data_func)(fp); )

#define FCOPYC(src, des)   \
  MAKESTMT( if (--(src)->bytes_left < 0) (*(src)->data_func)(src); \
	    *(des)->pbuf++ = *(src)->pbuf++; \
	    if (--(des)->bytes_left == 0) (*(des)->data_func)(des); )

#define ISKIPC(ip)   \
  MAKESTMT( (ip)->pbuf++; \
	    if (--(ip)->bytes_left == 0) (*(ip)->put_line)(ip); )

#define IPUTC(ip, ch)   \
  MAKESTMT( *(ip)->pbuf++ = ch; \
	    if (--(ip)->bytes_left == 0) (*(ip)->put_line)(ip); )

#define FICOPYC(src, des)   \
  MAKESTMT( if (--(src)->bytes_left < 0) (*(src)->data_func)(src); \
	    *(des)->pbuf++ = *(src)->pbuf++; \
	    if (--(des)->bytes_left == 0) (*(des)->put_line)(des); )

/* Automatic HiByte/LoByte data conversion is provided by the
 * following macros to avoid use of the standard ntohs/htons
 * scheme here.
 * This ensures unique interpretation/representation of external
 * data in natural "Network" Order (HiByte first, then LoByte)
 * by different hosts (especially for Intel-Systems).
 */

#define FGETW(fp, dest)   \
  MAKESTMT( if (--(fp)->bytes_left < 0) (*(fp)->data_func)(fp); \
	    dest = *((unsigned char *)(fp)->pbuf)++; \
	    dest <<= 8; \
	    if (--(fp)->bytes_left < 0) (*(fp)->data_func)(fp); \
	    dest |= *((unsigned char *)(fp)->pbuf)++; )

#define FPUTW(fp, wd)   \
  MAKESTMT( *(fp)->pbuf++ = (char)(wd >> 8); \
	    if (--(fp)->bytes_left == 0) (*(fp)->data_func)(fp); \
	    *(fp)->pbuf++ = (char)wd; \
	    if (--(fp)->bytes_left == 0) (*(fp)->data_func)(fp); )


/* Prototypes for public library functions. */

void level_3_decode(FBUFPUB *input, IBUFPUB *image);

IBUFPUB *encode_init(IMG_HEADER *input_header, FBUFPUB *output,
		     void *(*user_malloc)(long size),
		     void (*user_exit)(void),
		     short out_lev, short out_pat);

IBUFPUB *l3p2_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

IBUFPUB *l3p1_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

IBUFPUB *l2p2_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

IBUFPUB *l2p1_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

IBUFPUB *l1p2_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));

IBUFPUB *l1p1_encode_init(IMG_HEADER *input_header, FBUFPUB *output,
			  void *(*user_malloc)(long size),
			  void (*user_exit)(void));
