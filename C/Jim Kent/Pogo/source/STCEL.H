
#ifndef WORD
#define WORD int
#endif WORD

#ifndef UWORD
#define UWORD unsigned
#endif UWORD


#define	XMAX	320
#define	YMAX	200
#define COLORS	16
#define BITPLANES 4
#define CH_WIDTH 8
#define CH_HEIGHT 9

/* handy macro to find out how much memory a raster line takes up */
#define Mask_line(width) ((((width)+15)>>3)&0xfffe)
#define Mask_block(width, height) (Mask_line(width)*(height))
#define Raster_line(width) (((((width)+15)>>3)&0xfffe)<<2)
#define Raster_block(width, height) (Raster_line(width)*(height))
#define Pixels16(width)	(((width)+15)>>4)


#define SCREEN_LBYTES Raster_line(XMAX)
#define SCREEN_LWORDS (SCREEN_LBYTES/2)

struct cursor 
    {
    WORD type;
    UWORD *image;
    WORD width,height;
    WORD xhot, yhot;
    };


struct cel
	{
	WORD xoff, yoff;
	WORD width, height;
	WORD cmap[16];
	WORD *image;
	long image_size;
	WORD *mask;
	};
typedef struct cel Cel;

extern WORD *cscreen;
extern WORD *sys_cmap;
