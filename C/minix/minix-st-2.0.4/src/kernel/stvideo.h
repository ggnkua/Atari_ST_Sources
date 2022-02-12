/*
 * Atari ST hardware:
 * Access to circuitry for video
 */

#define	VIDEO	((struct video *)AD_VIDEO)

struct video {
    _VOLATILE unsigned char  vdb[64];	/* sparsely filled, both odd and even */
    unsigned short vd_st_rgb[16];	/* RGB for simultaneous ST colors */
    unsigned char  vd_st_res;		/* ST resolution */
    unsigned char  unused;
    unsigned short vd_tt_res;		/* TT resolution */
    unsigned char  vd_ste_hscroll;	/* MEGA STe: hor bitwise scroll */
    unsigned char  unused2[411];
    unsigned short vd_tt_rgb[256];	/* RGB for simultaneous TT colors */
    
};

#define	vd_ramh		vdb[ 1]	/* base address Video RAM, high byte */
#define	vd_ramm		vdb[ 3]	/* base address Video RAM, mid byte */
#define	vd_ptrh		vdb[ 5]	/* scan address Video RAM, high byte */
#define	vd_ptrm		vdb[ 7]	/* scan address Video RAM, mid byte */
#define	vd_ptrl		vdb[ 9]	/* scan address Video RAM, low byte */
#define	vd_sync		vdb[10]	/* synchronization mode */
#define	vd_raml		vdb[13]	/* base address Video RAM, low byte; STe only */
#define	vd_loff		vdb[15] /* base address line offset, MEGA-STe */

/* bits in vd_sync: */
#define	SYNC_EXT	0x01	/* extern sync */
#define	SYNC_50		0x02	/* 50 Hertz (used for color) */

/* bits in vd_st_rgb[]: */
#define	RGB_B		0x0007
#define	RGB_G		0x0070
#define	RGB_R		0x0700

/* some values for vd_st_rgb[]: */
#define	RGB_BLACK	0x0000
#define	RGB_RED		0x0700
#define	RGB_GREEN	0x0070
#define	RGB_BLUE	0x0007
#define	RGB_WHITE	0x0777
#define	RGB_MAGENTA	0x0707
#define	RGB_CYAN	0x0077
#define	RGB_YELLOW	0x0770
#define	RGB_LGREY	0x0555
#define	RGB_DGREY	0x0222

/* values for vd_st_res: */
#define	RES_LOW		0x00	/* 320x200, 16 colors */
#define	RES_MID		0x01	/* 640x200,  4 colors */
#define	RES_HIGH	0x02	/* 640x400, monochrome */
