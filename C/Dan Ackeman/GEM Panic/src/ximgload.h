#ifndef _XIMGLOAD_H_
#define _XIMGLOAD_H_

/* error codes */
#define ERR_HEADER      1
#define ERR_ALLOC       2
#define ERR_FILE        3
#define ERR_DEPACK      4
#define ERR_TRFM		5

/* how many bytes one scanline can be */
#define LINEBUF   1024

/* define graf_mouse values */
#define MOUSE_ON  257
#define MOUSE_OFF 256

#define XIMG      0x58494D47L


struct IMG_HEADER
{                 /* Header of GEM Image Files   */
  int version;  /* Img file format version (1) */
  int length;   /* Header length in words  (8) */
  int planes;   /* Number of bit-planes    (1) */
  int pat_len;  /* length of Patterns      (2) */
  int pix_w;    /* Pixel width in 1/1000 mmm  (372)    */
  int pix_h;    /* Pixel height in 1/1000 mmm (372)    */
  int img_w;    /* Pixels per line (=(x+7)/8 Bytes)    */
  int img_h;    /* Total number of lines               */
  long  magic;    /* Contains "XIMG" if standard color   */
  int paltype;  /* palette type (0 = RGB (short each)) */
  int *palette; /* palette etc.                        */
  char *addr;     /* Address for the depacked bit-planes */
};

extern short *img_load(MFDB *raster, char *file, int method, MFDB *mask, int mask_color);
extern void show_error(int error);
extern int depack_img( char *name, struct IMG_HEADER *pic );
extern int show_img( struct IMG_HEADER *info );
extern int copy_img( struct IMG_HEADER *pic, MFDB *image_buffer);
extern int transform_img( MFDB *image, int planes, int *palette, int img_handle);
extern int dither( short **addr, long size, int width, int planes, int *palette );
extern int interleave( int interleave, short **addr, long size, int planes );
extern int convert( MFDB *image, long size, int planes, int img_handle );
extern int img_colors( int planes, int *palette , int col_handle);
extern int truecolorimg_colors( int planes, int *palette , int col_handle);
extern int mono_transform( MFDB *image, long size, int planes, int img_handle, int color, int keep_original);
extern int fix_image(MFDB *image,int color);
extern int transform_truecolor( MFDB *image, long size, int planes, int img_handle);
extern int test_color( int color, int img_handle );
extern int transform_remap( MFDB *image, long size, int planes, int img_handle);
extern int make_mask(struct IMG_HEADER *src, MFDB *dest, int mask_color);
extern int mfdb_make_mask(MFDB *src, MFDB *dest, int mask_color);

#endif