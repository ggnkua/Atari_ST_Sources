#ifndef _FB_H
#define _FB_H

#include "relocate.h" /* fVDI */

/* Definitions of frame buffers						*/

#define FB_MAJOR		29
#define FB_MAX			32	/* sufficient for now */

/* ioctls
   0x46 is 'F'								*/
#define FBIOGET_VSCREENINFO	0x4600
#define FBIOPUT_VSCREENINFO	0x4601
#define FBIOGET_FSCREENINFO	0x4602
#define FBIOPAN_DISPLAY     0x4606
#define FBIOBLANK		        0x4611		/* arg: 0 or vesa level + 1 */
#define FBIO_ALLOC          0x4613
#define FBIO_FREE           0x4614

/* picture format */
#define PICT_FORMAT(bpp,type,a,r,g,b)	(((bpp) << 24) | ((type) << 16) | ((a) << 12) | ((r) << 8) | ((g) << 4) | ((b)))
/* gray/color formats use a visual index instead of argb */
#define PICT_VISFORMAT(bpp,type,vi)	(((bpp) << 24) | ((type) << 16) | ((vi)))
#define PICT_FORMAT_BPP(f)	(((f) >> 24)       )
#define PICT_FORMAT_TYPE(f)	(((f) >> 16) & 0xff)
#define PICT_FORMAT_A(f)	(((f) >> 12) & 0x0f)
#define PICT_FORMAT_R(f)	(((f) >>  8) & 0x0f)
#define PICT_FORMAT_G(f)	(((f) >>  4) & 0x0f)
#define PICT_FORMAT_B(f)	(((f)      ) & 0x0f)
#define PICT_FORMAT_RGB(f)	(((f)      ) & 0xfff)
#define PICT_FORMAT_VIS(f)	(((f)      ) & 0xffff)
#define PICT_TYPE_OTHER	0
#define PICT_TYPE_A	1
#define PICT_TYPE_ARGB	2
#define PICT_TYPE_ABGR	3
#define PICT_TYPE_COLOR	4
#define PICT_TYPE_GRAY	5
#define PICT_FORMAT_COLOR(f)	(PICT_FORMAT_TYPE(f) & 2)
/* 32bpp formats */
#define PICT_a8r8g8b8	PICT_FORMAT(32,PICT_TYPE_ARGB,8,8,8,8)
#define PICT_x8r8g8b8	PICT_FORMAT(32,PICT_TYPE_ARGB,0,8,8,8)
#define PICT_a8b8g8r8	PICT_FORMAT(32,PICT_TYPE_ABGR,8,8,8,8)
#define PICT_x8b8g8r8	PICT_FORMAT(32,PICT_TYPE_ABGR,0,8,8,8)
/* 24bpp formats */
#define PICT_r8g8b8	PICT_FORMAT(24,PICT_TYPE_ARGB,0,8,8,8)
#define PICT_b8g8r8	PICT_FORMAT(24,PICT_TYPE_ABGR,0,8,8,8)
/* 16bpp formats */
#define PICT_r5g6b5	PICT_FORMAT(16,PICT_TYPE_ARGB,0,5,6,5)
#define PICT_b5g6r5	PICT_FORMAT(16,PICT_TYPE_ABGR,0,5,6,5)
#define PICT_a1r5g5b5	PICT_FORMAT(16,PICT_TYPE_ARGB,1,5,5,5)
#define PICT_x1r5g5b5	PICT_FORMAT(16,PICT_TYPE_ARGB,0,5,5,5)
#define PICT_a1b5g5r5	PICT_FORMAT(16,PICT_TYPE_ABGR,1,5,5,5)
#define PICT_x1b5g5r5	PICT_FORMAT(16,PICT_TYPE_ABGR,0,5,5,5)
#define PICT_a4r4g4b4	PICT_FORMAT(16,PICT_TYPE_ARGB,4,4,4,4)
#define PICT_x4r4g4b4	PICT_FORMAT(16,PICT_TYPE_ARGB,4,4,4,4)
#define PICT_a4b4g4r4	PICT_FORMAT(16,PICT_TYPE_ARGB,4,4,4,4)
#define PICT_x4b4g4r4	PICT_FORMAT(16,PICT_TYPE_ARGB,4,4,4,4)
/* 8bpp formats */
#define PICT_a8 PICT_FORMAT(8,PICT_TYPE_A,8,0,0,0)
#define PICT_r3g3b2	PICT_FORMAT(8,PICT_TYPE_ARGB,0,3,3,2)
#define PICT_b2g3r3	PICT_FORMAT(8,PICT_TYPE_ABGR,0,3,3,2)
#define PICT_a2r2g2b2 PICT_FORMAT(8,PICT_TYPE_ARGB,2,2,2,2)
#define PICT_a2b2g2r2 PICT_FORMAT(8,PICT_TYPE_ABGR,2,2,2,2)
#define PICT_c8 PICT_FORMAT(8,PICT_TYPE_COLOR,0,0,0,0)
#define PICT_g8 PICT_FORMAT(8,PICT_TYPE_GRAY,0,0,0,0)

/* fVDI */
#define MODE_EMUL_MONO_FLAG 1
#define MODE_VESA_FLAG 2 /* for modedb.c */
struct mode_option {
	short used; /* Whether the mode option was used or not. */
	short width;
	short height;
	short bpp;
	short freq;
	short flags;
};

extern struct mode_option resolution; /* fVDI */

#define FB_TYPE_PACKED_PIXELS		0	/* Packed Pixels	*/
#define FB_TYPE_PLANES			1	/* Non interleaved planes */
#define FB_TYPE_INTERLEAVED_PLANES	2	/* Interleaved planes	*/
#define FB_TYPE_TEXT			3	/* Text/attributes	*/
#define FB_TYPE_VGA_PLANES		4	/* EGA/VGA planes	*/

#define FB_AUX_TEXT_MDA		0	/* Monochrome text */
#define FB_AUX_TEXT_CGA		1	/* CGA/EGA/VGA Color text */
#define FB_AUX_TEXT_S3_MMIO	2	/* S3 MMIO fasttext */
#define FB_AUX_TEXT_MGA_STEP16	3	/* MGA Millenium I: text, attr, 14 reserved bytes */
#define FB_AUX_TEXT_MGA_STEP8	4	/* other MGAs:      text, attr,  6 reserved bytes */

#define FB_AUX_VGA_PLANES_VGA4		0	/* 16 color planes (EGA/VGA) */
#define FB_AUX_VGA_PLANES_CFB4		1	/* CFB4 in planes (VGA) */
#define FB_AUX_VGA_PLANES_CFB8		2	/* CFB8 in planes (VGA) */

#define FB_VISUAL_MONO01		0	/* Monochr. 1=Black 0=White */
#define FB_VISUAL_MONO10		1	/* Monochr. 1=White 0=Black */
#define FB_VISUAL_TRUECOLOR		2	/* True color	*/
#define FB_VISUAL_PSEUDOCOLOR		3	/* Pseudo color (like atari) */
#define FB_VISUAL_DIRECTCOLOR		4	/* Direct color */
#define FB_VISUAL_STATIC_PSEUDOCOLOR	5	/* Pseudo color readonly */

#define FB_ACCEL_NONE		0	/* no hardware accelerator	*/
#define FB_ACCEL_ATARIBLITT	1	/* Atari Blitter		*/
#define FB_ACCEL_AMIGABLITT	2	/* Amiga Blitter                */
#define FB_ACCEL_S3_TRIO64	3	/* Cybervision64 (S3 Trio64)    */
#define FB_ACCEL_NCR_77C32BLT	4	/* RetinaZ3 (NCR 77C32BLT)      */
#define FB_ACCEL_S3_VIRGE	5	/* Cybervision64/3D (S3 ViRGE)	*/
#define FB_ACCEL_ATI_MACH64GX	6	/* ATI Mach 64GX family		*/
#define FB_ACCEL_DEC_TGA	7	/* DEC 21030 TGA		*/
#define FB_ACCEL_ATI_MACH64CT	8	/* ATI Mach 64CT family		*/
#define FB_ACCEL_ATI_MACH64VT	9	/* ATI Mach 64CT family VT class */
#define FB_ACCEL_ATI_MACH64GT	10	/* ATI Mach 64CT family GT class */
#define FB_ACCEL_SUN_CREATOR	11	/* Sun Creator/Creator3D	*/
#define FB_ACCEL_SUN_CGSIX	12	/* Sun cg6			*/
#define FB_ACCEL_SUN_LEO	13	/* Sun leo/zx			*/
#define FB_ACCEL_IMS_TWINTURBO	14	/* IMS Twin Turbo		*/
#define FB_ACCEL_3DLABS_PERMEDIA2 15	/* 3Dlabs Permedia 2		*/
#define FB_ACCEL_MATROX_MGA2064W 16	/* Matrox MGA2064W (Millenium)	*/
#define FB_ACCEL_MATROX_MGA1064SG 17	/* Matrox MGA1064SG (Mystique)	*/
#define FB_ACCEL_MATROX_MGA2164W 18	/* Matrox MGA2164W (Millenium II) */
#define FB_ACCEL_MATROX_MGA2164W_AGP 19	/* Matrox MGA2164W (Millenium II) */
#define FB_ACCEL_MATROX_MGAG100	20	/* Matrox G100 (Productiva G100) */
#define FB_ACCEL_MATROX_MGAG200	21	/* Matrox G200 (Myst, Mill, ...) */
#define FB_ACCEL_SUN_CG14	22	/* Sun cgfourteen		 */
#define FB_ACCEL_SUN_BWTWO	23	/* Sun bwtwo			*/
#define FB_ACCEL_SUN_CGTHREE	24	/* Sun cgthree			*/
#define FB_ACCEL_SUN_TCX	25	/* Sun tcx			*/
#define FB_ACCEL_MATROX_MGAG400	26	/* Matrox G400			*/
#define FB_ACCEL_NV3		27	/* nVidia RIVA 128              */
#define FB_ACCEL_NV4		28	/* nVidia RIVA TNT		*/
#define FB_ACCEL_NV5		29	/* nVidia RIVA TNT2		*/
#define FB_ACCEL_CT_6555x	30	/* C&T 6555x			*/
#define FB_ACCEL_3DFX_BANSHEE	31	/* 3Dfx Banshee			*/
#define FB_ACCEL_ATI_RAGE128	32	/* ATI Rage128 family		*/
#define FB_ACCEL_IGS_CYBER2000	33	/* CyberPro 2000		*/
#define FB_ACCEL_IGS_CYBER2010	34	/* CyberPro 2010		*/
#define FB_ACCEL_IGS_CYBER5000	35	/* CyberPro 5000		*/
#define FB_ACCEL_SIS_GLAMOUR    36	/* SiS 300/630/540              */
#define FB_ACCEL_3DLABS_PERMEDIA3 37	/* 3Dlabs Permedia 3		*/
#define FB_ACCEL_ATI_RADEON	38	/* ATI Radeon family		*/
#define FB_ACCEL_I810           39      /* Intel 810/815                */
#define FB_ACCEL_SIS_GLAMOUR_2  40	/* SiS 315, 650, 740		*/
#define FB_ACCEL_SIS_XABRE      41	/* SiS 330 ("Xabre")		*/
#define FB_ACCEL_I830           42      /* Intel 830M/845G/85x/865G     */
#define FB_ACCEL_NV_10          43      /* nVidia Arch 10               */
#define FB_ACCEL_NV_20          44      /* nVidia Arch 20               */
#define FB_ACCEL_NV_30          45      /* nVidia Arch 30               */
#define FB_ACCEL_NV_40          46      /* nVidia Arch 40               */
#define FB_ACCEL_NEOMAGIC_NM2070 90	/* NeoMagic NM2070              */
#define FB_ACCEL_NEOMAGIC_NM2090 91	/* NeoMagic NM2090              */
#define FB_ACCEL_NEOMAGIC_NM2093 92	/* NeoMagic NM2093              */
#define FB_ACCEL_NEOMAGIC_NM2097 93	/* NeoMagic NM2097              */
#define FB_ACCEL_NEOMAGIC_NM2160 94	/* NeoMagic NM2160              */
#define FB_ACCEL_NEOMAGIC_NM2200 95	/* NeoMagic NM2200              */
#define FB_ACCEL_NEOMAGIC_NM2230 96	/* NeoMagic NM2230              */
#define FB_ACCEL_NEOMAGIC_NM2360 97	/* NeoMagic NM2360              */
#define FB_ACCEL_NEOMAGIC_NM2380 98	/* NeoMagic NM2380              */

#define FB_ACCEL_SAVAGE4        0x80	/* S3 Savage4                   */
#define FB_ACCEL_SAVAGE3D       0x81	/* S3 Savage3D                  */
#define FB_ACCEL_SAVAGE3D_MV    0x82	/* S3 Savage3D-MV               */
#define FB_ACCEL_SAVAGE2000     0x83	/* S3 Savage2000                */
#define FB_ACCEL_SAVAGE_MX_MV   0x84	/* S3 Savage/MX-MV              */
#define FB_ACCEL_SAVAGE_MX      0x85	/* S3 Savage/MX                 */
#define FB_ACCEL_SAVAGE_IX_MV   0x86	/* S3 Savage/IX-MV              */
#define FB_ACCEL_SAVAGE_IX      0x87	/* S3 Savage/IX                 */
#define FB_ACCEL_PROSAVAGE_PM   0x88	/* S3 ProSavage PM133           */
#define FB_ACCEL_PROSAVAGE_KM   0x89	/* S3 ProSavage KM133           */
#define FB_ACCEL_S3TWISTER_P    0x8a	/* S3 Twister                   */
#define FB_ACCEL_S3TWISTER_K    0x8b	/* S3 TwisterK                  */
#define FB_ACCEL_SUPERSAVAGE    0x8c    /* S3 Supersavage               */
#define FB_ACCEL_PROSAVAGE_DDR  0x8d	/* S3 ProSavage DDR             */
#define FB_ACCEL_PROSAVAGE_DDRK 0x8e	/* S3 ProSavage DDR-K           */

struct fb_fix_screeninfo {
	char id[16];			/* identification string eg "TT Builtin" */
	unsigned long smem_start;	/* Start of frame buffer mem */
					/* (physical address) */
	unsigned long smem_len;			/* Length of frame buffer mem */
	unsigned long type;			/* see FB_TYPE_*		*/
	unsigned long type_aux;			/* Interleave for interleaved Planes */
	unsigned long visual;			/* see FB_VISUAL_*		*/ 
	unsigned short xpanstep;			/* zero if no hardware panning  */
	unsigned short ypanstep;			/* zero if no hardware panning  */
	unsigned short ywrapstep;		/* zero if no hardware ywrap    */
	unsigned long line_length;		/* length of a line in bytes    */
	unsigned long mmio_start;	/* Start of Memory Mapped I/O   */
					/* (physical address) */
	unsigned long mmio_len;			/* Length of Memory Mapped I/O  */
	unsigned long accel;			/* Indicate to driver which	*/
					/*  specific chip/card we have	*/
	unsigned short reserved[3];		/* Reserved for future compatibility */
};

/* Interpretation of offset for color fields: All offsets are from the right,
 * inside a "pixel" value, which is exactly 'bits_per_pixel' wide (means: you
 * can use the offset as right argument to <<). A pixel afterwards is a bit
 * stream and is written to video memory as that unmodified. This implies
 * big-endian byte order if bits_per_pixel is greater than 8.
 */
struct fb_bitfield {
	unsigned long offset;			/* beginning of bitfield	*/
	unsigned long length;			/* length of bitfield		*/
	unsigned long msb_right;		/* != 0 : Most significant bit is */ 
					/* right */ 
};

#define FB_NONSTD_HAM		1	/* Hold-And-Modify (HAM)        */

#define FB_ACTIVATE_NOW		0	/* set values immediately (or vbl)*/
#define FB_ACTIVATE_NXTOPEN	1	/* activate on next open	*/
#define FB_ACTIVATE_TEST	2	/* don't set, round up impossible */
#define FB_ACTIVATE_MASK       15
					/* values			*/
#define FB_ACTIVATE_VBL	       16	/* activate values on next vbl  */
#define FB_CHANGE_CMAP_VBL     32	/* change colormap on vbl	*/
#define FB_ACTIVATE_ALL	       64	/* change all VCs on this fb	*/
#define FB_ACTIVATE_FORCE     128	/* force apply even when no change*/
#define FB_ACTIVATE_INV_MODE  256 /* invalidate videomode */

#define FB_ACCELF_TEXT		1	/* (OBSOLETE) see fb_info.flags and vc_mode */

#define FB_SYNC_HOR_HIGH_ACT	1	/* horizontal sync high active	*/
#define FB_SYNC_VERT_HIGH_ACT	2	/* vertical sync high active	*/
#define FB_SYNC_EXT		4	/* external sync		*/
#define FB_SYNC_COMP_HIGH_ACT	8	/* composite sync high active   */
#define FB_SYNC_BROADCAST	16	/* broadcast video timings      */
					/* vtotal = 144d/288n/576i => PAL  */
					/* vtotal = 121d/242n/484i => NTSC */
#define FB_SYNC_ON_GREEN	32	/* sync on green */

#define FB_VMODE_NONINTERLACED  0	/* non interlaced */
#define FB_VMODE_INTERLACED	1	/* interlaced	*/
#define FB_VMODE_DOUBLE		2	/* double scan */
#define FB_VMODE_MASK		255

#define FB_VMODE_YWRAP		256	/* ywrap instead of panning     */
#define FB_VMODE_SMOOTH_XPAN	512	/* smooth xpan possible (internally used) */
#define FB_VMODE_CONUPDATE	512	/* don't update x/yoffset	*/

#define PICOS2KHZ(a) (1000000000UL/(a))
#define KHZ2PICOS(a) (1000000000UL/(a))

struct fb_var_screeninfo {
	unsigned long xres;			/* visible resolution		*/
	unsigned long yres;
	unsigned long xres_virtual;		/* virtual resolution		*/
	unsigned long yres_virtual;
	unsigned long xoffset;			/* offset from virtual to visible */
	unsigned long yoffset;			/* resolution			*/

	unsigned long bits_per_pixel;		/* guess what			*/
	unsigned long grayscale;		/* != 0 Graylevels instead of colors */

	struct fb_bitfield red;		/* bitfield in fb mem if true color, */
	struct fb_bitfield green;	/* else only length is significant */
	struct fb_bitfield blue;
	struct fb_bitfield transp;	/* transparency			*/	

	unsigned long nonstd;			/* != 0 Non standard pixel format */

	unsigned long activate;			/* see FB_ACTIVATE_*		*/

	unsigned long height;			/* height of picture in mm    */
	unsigned long width;			/* width of picture in mm     */

	unsigned long accel_flags;		/* (OBSOLETE) see fb_info.flags */

	/* Timing: All values in pixclocks, except pixclock (of course) */
	unsigned long pixclock;			/* pixel clock in ps (pico seconds) */
	unsigned long left_margin;		/* time from sync to picture	*/
	unsigned long right_margin;		/* time from picture to sync	*/
	unsigned long upper_margin;		/* time from sync to picture	*/
	unsigned long lower_margin;
	unsigned long hsync_len;		/* length of horizontal sync	*/
	unsigned long vsync_len;		/* length of vertical sync	*/
	unsigned long sync;			/* see FB_SYNC_*		*/
	unsigned long vmode;			/* see FB_VMODE_*		*/
	unsigned long rotate;			/* angle we rotate counter clockwise */
	unsigned long refresh;
	unsigned long reserved[4];		/* Reserved for future compatibility */
};

/* VESA Blanking Levels */
#define VESA_NO_BLANKING        0
#define VESA_VSYNC_SUSPEND      1
#define VESA_HSYNC_SUSPEND      2
#define VESA_POWERDOWN          3

enum {
	/* screen: unblanked, hsync: on,  vsync: on */
	FB_BLANK_UNBLANK       = VESA_NO_BLANKING,
	/* screen: blanked,   hsync: on,  vsync: on */
	FB_BLANK_NORMAL        = VESA_NO_BLANKING + 1,
	/* screen: blanked,   hsync: on,  vsync: off */
	FB_BLANK_VSYNC_SUSPEND = VESA_VSYNC_SUSPEND + 1,
	/* screen: blanked,   hsync: off, vsync: on */
	FB_BLANK_HSYNC_SUSPEND = VESA_HSYNC_SUSPEND + 1,
	/* screen: blanked,   hsync: off, vsync: off */
	FB_BLANK_POWERDOWN     = VESA_POWERDOWN + 1
};

#define FB_VBLANK_VBLANKING	0x001	/* currently in a vertical blank */
#define FB_VBLANK_HBLANKING	0x002	/* currently in a horizontal blank */
#define FB_VBLANK_HAVE_VBLANK	0x004	/* vertical blanks can be detected */
#define FB_VBLANK_HAVE_HBLANK	0x008	/* horizontal blanks can be detected */
#define FB_VBLANK_HAVE_COUNT	0x010	/* global retrace counter is available */
#define FB_VBLANK_HAVE_VCOUNT	0x020	/* the vcount field is valid */
#define FB_VBLANK_HAVE_HCOUNT	0x040	/* the hcount field is valid */
#define FB_VBLANK_VSYNCING	0x080	/* currently in a vsync */
#define FB_VBLANK_HAVE_VSYNC	0x100	/* verical syncs can be detected */

struct fb_vblank {
	unsigned long flags;			/* FB_VBLANK flags */
	unsigned long count;			/* counter of retraces since boot */
	unsigned long vcount;			/* current scanline position */
	unsigned long hcount;			/* current scandot position */
	unsigned long reserved[4];		/* reserved for future compatibility */
};

struct vm_area_struct;
struct fb_info;
struct device;
struct file;

/* Definitions below are used in the parsed monitor specs */
#define FB_DPMS_ACTIVE_OFF	1
#define FB_DPMS_SUSPEND		2
#define FB_DPMS_STANDBY		4

#define FB_DISP_DDI		1
#define FB_DISP_ANA_700_300	2
#define FB_DISP_ANA_714_286	4
#define FB_DISP_ANA_1000_400	8
#define FB_DISP_ANA_700_000	16

#define FB_DISP_MONO		32
#define FB_DISP_RGB		64
#define FB_DISP_MULTI		128
#define FB_DISP_UNKNOWN		256

#define FB_SIGNAL_NONE		0
#define FB_SIGNAL_BLANK_BLANK	1
#define FB_SIGNAL_SEPARATE	2
#define FB_SIGNAL_COMPOSITE	4
#define FB_SIGNAL_SYNC_ON_GREEN	8
#define FB_SIGNAL_SERRATION_ON	16

#define FB_MISC_PRIM_COLOR	1
#define FB_MISC_1ST_DETAIL	2	/* First Detailed Timing is preferred */
struct fb_chroma {
	unsigned long redx;	/* in fraction of 1024 */
	unsigned long greenx;
	unsigned long bluex;
	unsigned long whitex;
	unsigned long redy;
	unsigned long greeny;
	unsigned long bluey;
	unsigned long whitey;
};

struct fb_monspecs {
	struct fb_chroma chroma;
	struct fb_videomode *modedb;	/* mode database */
	unsigned char  manufacturer[4];		/* Manufacturer */
	unsigned char  monitor[14];		/* Monitor String */
	unsigned char  serial_no[14];		/* Serial Number */
	unsigned char  ascii[14];		/* ? */
	unsigned long modedb_len;		/* mode database length */
	unsigned long model;			/* Monitor Model */
	unsigned long serial;			/* Serial Number - Integer */
	unsigned long year;			/* Year manufactured */
	unsigned long week;			/* Week Manufactured */
	unsigned long hfmin;			/* hfreq lower limit (Hz) */
	unsigned long hfmax;			/* hfreq upper limit (Hz) */
	unsigned long dclkmin;			/* pixelclock lower limit (Hz) */
	unsigned long dclkmax;			/* pixelclock upper limit (Hz) */
	unsigned short input;			/* display type - see FB_DISP_* */
	unsigned short dpms;			/* DPMS support - see FB_DPMS_ */
	unsigned short signal;			/* Signal Type - see FB_SIGNAL_* */
	unsigned short vfmin;			/* vfreq lower limit (Hz) */
	unsigned short vfmax;			/* vfreq upper limit (Hz) */
	unsigned short gamma;			/* Gamma - in fractions of 100 */
	unsigned short gtf	: 1;		/* supports GTF */
	unsigned short misc;			/* Misc flags - see FB_MISC_* */
	unsigned char  version;			/* EDID version... */
	unsigned char  revision;			/* ...and revision */
	unsigned char  max_x;			/* Maximum horizontal size (cm) */
	unsigned char  max_y;			/* Maximum vertical size (cm) */
};

struct fb_ops {
	/* checks var and eventually tweaks if to soomething supported,
	 * DO NOT MODIFY PAR  */
	int (*fb_check_var)(struct fb_var_screeninfo *var, struct fb_info *info);
	/* set the video mode according to info->var */
	int (*fb_set_par)(struct fb_info *info);
	/* set color register */
	int (*fb_setcolreg)(unsigned regno, unsigned red, unsigned green,
	                    unsigned blue, unsigned transp, struct fb_info *info);
	/* pan display */
	int (*fb_pan_display)(struct fb_var_screeninfo *var, struct fb_info *info);
	/* blank display */
	int (*fb_blank)(int blank, struct fb_info *info);
	/* wait for blit idle */
	int (*fb_sync)(struct fb_info *info);
	/* perform fb specific ioctl */
	int (*fb_ioctl)(unsigned int cmd, unsigned long arg, struct fb_info *info);
	/* Buildthe modedb for head 1 (head 2 will come later), check panel infos
	 * from either BIOS or EDID, and pick up the default mode */
	void (*fb_check_modes)(struct fb_info *info, struct mode_option *resolution);
  /* Accel functions */
#define DEGREES_0	0
#define DEGREES_90	1
#define DEGREES_180	2
#define DEGREES_270	3
#define OMIT_LAST	1
	void (*SetupForSolidFill)(struct fb_info *info, int color, int rop, unsigned int planemask);
	void (*SubsequentSolidFillRect)(struct fb_info *info, int x, int y, int w, int h);
	void (*SetupForSolidLine)(struct fb_info *info, int color, int rop, unsigned int planemask);
	void (*SubsequentSolidHorVertLine)(struct fb_info *info, int x, int y, int len, int dir);   
	void (*SubsequentSolidTwoPointLine)(struct fb_info *info, int xa, int ya, int xb, int yb, int flags);  
	void (*SetupForDashedLine)(struct fb_info *info, int fg, int bg, int rop, unsigned int planemask, int length, unsigned char *pattern);
	void (*SubsequentDashedTwoPointLine)(struct fb_info *info, int xa, int ya, int xb, int yb, int flags, int phase);  
	void (*SetupForScreenToScreenCopy)(struct fb_info *info, int xdir, int ydir, int rop, unsigned int planemask, int trans_color);
	void (*SubsequentScreenToScreenCopy)(struct fb_info *info, int xa, int ya, int xb, int yb, int w, int h);   
	void (*ScreenToScreenCopy)(struct fb_info *info, int xa, int ya, int xb, int yb, int w, int h, int rop);
	void (*SetupForMono8x8PatternFill)(struct fb_info *info, int patternx, int patterny, int fg, int bg, int rop, unsigned int planemask);
	void (*SubsequentMono8x8PatternFillRect)(struct fb_info *info, int patternx, int patterny, int x, int y, int w, int h);
	void (*SetupForScanlineCPUToScreenColorExpandFill)(struct fb_info *info, int fg, int bg, int rop, unsigned int planemask);
	void (*SubsequentScanlineCPUToScreenColorExpandFill)(struct fb_info *info, int x, int y, int w, int h, int skipleft);
	void (*SubsequentScanline)(struct fb_info *info, unsigned long *buf);
	void (*SetupForScanlineImageWrite)(struct fb_info *info, int rop, unsigned int planemask, int trans_color, int bpp);
	void (*SubsequentScanlineImageWriteRect)(struct fb_info *info, int x, int y, int w, int h, int skipleft);  
	void (*SetClippingRectangle)(struct fb_info *info, int xa, int ya, int xb, int yb);
	void (*DisableClipping)(struct fb_info *info);
	int (*SetupForCPUToScreenAlphaTexture)(struct fb_info *info, 
      int op, unsigned short red, unsigned short green, unsigned short blue, unsigned short alpha, unsigned long maskFormat, unsigned long dstFormat, unsigned char *alphaPtr, int alphaPitch, int width, int height, int flags);
	int (*SetupForCPUToScreenTexture)(struct fb_info *info, int op, unsigned long srcFormat, unsigned long dstFormat, unsigned char *texPtr, int texPitch, int width, int height, int flags);
	void (*SubsequentCPUToScreenTexture)(struct fb_info *info, int dstx, int dsty, int srcx, int srcy, int width, int height);
	/* Cursor functions */
	void (*SetCursorColors)(struct fb_info *info, int bg, int fg);
	void (*SetCursorPosition)(struct fb_info *info, int x, int y);
	void (*LoadCursorImage)(struct fb_info *info, unsigned short *mask, unsigned short *data, int zoom);
	void (*HideCursor)(struct fb_info *info);
	void (*ShowCursor)(struct fb_info *info);
	long (*CursorInit)(struct fb_info *info);
	void (*WaitVbl)(struct fb_info *info);
};

struct fb_info {
	struct fb_var_screeninfo var;	/* Current var */
	struct fb_fix_screeninfo fix;	/* Current fix */
	struct fb_monspecs monspecs;	/* Current Monitor specs */
	struct fb_videomode *mode;	/* current mode */
	char *screen_base;	/* Virtual address */
	unsigned long screen_size;
	char *ram_base;	        /* base vram */
	unsigned long ram_size; /* vram size */
	char *screen_mono;
	long update_mono;
	struct fb_ops *fbops;
	void *par; /* device dependent */
};

/* fbmem.c */
extern int fb_pan_display(struct fb_info *info, struct fb_var_screeninfo *var); 
extern int fb_set_var(struct fb_info *info, struct fb_var_screeninfo *var); 
extern int fb_blank(struct fb_info *info, int blank);
extern int fb_ioctl(unsigned int cmd, unsigned long arg);
extern struct fb_info *framebuffer_alloc(unsigned long size);
extern void framebuffer_release(struct fb_info *info);

/* offscreen.c */
extern long offscreen_free(struct fb_info *info, long addr);
extern long offscreen_alloc(struct fb_info *info, long amount);
extern long offscren_reserved(void);
extern void offscreen_init(struct fb_info *info);

/* fbmon.c */
#define FB_MAXTIMINGS		0
#define FB_VSYNCTIMINGS		1
#define FB_HSYNCTIMINGS		2
#define FB_DCLKTIMINGS		3
#define FB_IGNOREMON		0x100

#define FB_MODE_IS_UNKNOWN	0
#define FB_MODE_IS_DETAILED	1
#define FB_MODE_IS_STANDARD	2
#define FB_MODE_IS_VESA		4
#define FB_MODE_IS_CALCULATED	8
#define FB_MODE_IS_FIRST	16
#define FB_MODE_IS_FROM_VAR     32

extern void fb_destroy_modedb(struct fb_videomode *modedb);
extern int fb_parse_edid(unsigned char *edid, struct fb_var_screeninfo *var);
extern void fb_edid_to_monspecs(unsigned char *edid, struct fb_monspecs *specs);
extern int fb_get_mode(int flags, unsigned long val, struct fb_var_screeninfo *var, struct fb_info *info);
extern int fb_validate_mode(const struct fb_var_screeninfo *var, struct fb_info *info);

/* modedb.c */
#define VESA_MODEDB_SIZE 34
extern int fb_find_mode(struct fb_var_screeninfo *var,
           struct fb_info *info, struct mode_option *resolution ,
           const struct fb_videomode *db, unsigned int dbsize,
           const struct fb_videomode *default_mode, unsigned int default_bpp);
extern void fb_var_to_videomode(struct fb_videomode *mode, struct fb_var_screeninfo *var);
extern void fb_videomode_to_var(struct fb_var_screeninfo *var, struct fb_videomode *mode);
extern int fb_mode_is_equal(struct fb_videomode *mode1, struct fb_videomode *mode2);

struct fb_videomode {
	unsigned short refresh;		/* optional */
	unsigned short xres;
	unsigned short yres;
	unsigned long pixclock;
	unsigned short left_margin;
	unsigned short right_margin;
	unsigned short upper_margin;
	unsigned short lower_margin;
	unsigned short hsync_len;
	unsigned short vsync_len;
	unsigned short sync;
	unsigned short vmode;
	unsigned short flag;
};

extern const struct fb_videomode vesa_modes[];

/* timer */
extern void udelay(long usec);
#ifdef COLDFIRE
#ifdef MCF5445X
#define US_TO_TIMER(a) (a)
#define TIMER_TO_US(a) (a)
#else /* MCF548X */
#define US_TO_TIMER(a) ((a)*100)
#define TIMER_TO_US(a) ((a)/100)
#endif
#else
#define US_TO_TIMER(a) (((a)*256)/5000)
#define TIMER_TO_US(a) (((a)*5000)/256)
#endif
extern long get_timer(void);
extern void start_timeout(void);
extern int end_timeout(long msec);
extern void mdelay(long msec);
extern void install_vbl_timer(void *func, int remove);
extern void uninstall_vbl_timer(void *func);

/*
 * fVDI access
 */
extern void Funcs_copymem(const void *s, void *d, long n);
extern const char *Funcs_next_line(const char *ptr);
extern const char *Funcs_skip_space(const char *ptr);
extern const char *Funcs_get_token(const char *ptr, char *buf, long n);
extern long Funcs_equal(const char *str1, const char *str2);
extern long Funcs_length(const char *text);
extern void Funcs_copy(const char *src, char *dest);
extern void Funcs_cat(const char *src, char *dest);
extern long Funcs_numeric(long ch);
extern long Funcs_atol(const char *text);
extern void Funcs_error(const char *text1, const char *text2);
extern void *Funcs_malloc(long size, long type);
extern long Funcs_free(void *addr);
extern int Funcs_puts(const char *text);
extern void Funcs_ltoa(char *buf, long n, unsigned long base);
extern long Funcs_get_cookie(const unsigned char *cname, long super);
extern long Funcs_set_cookie(const unsigned char *cname, long value);
extern long Funcs_fixup_font(Fontheader *font, char *buffer, long flip);
extern long Funcs_unpack_font(Fontheader *header, long format);
extern long Funcs_insert_font(Fontheader **first_font, Fontheader *new_font);
extern long Funcs_get_size(const char *name);
extern char *Funcs_allocate_block(long size);
extern void Funcs_free_block(void *address);
extern void Funcs_cache_flush(void);
extern long Funcs_misc(long func, long par, const char *token);
extern long Funcs_event(long id_type, long data); 

extern struct fb_info *info_fvdi;

/*
 * Debugging stuffs
 */
extern short debug;
extern void debug_print(const char *string);
extern void debug_print_value(const char *string, long val);
extern void debug_print_value_hex(const char *string, long val);
extern void debug_print_value_hex_byte(const char *string, unsigned char val);
extern void debug_print_value_hex_word(const char *string, unsigned short val);
extern void debug_print_value_hex_long(const char *string, unsigned long val);
#define DPRINT debug_print
#define DPRINTVAL debug_print_value
#define DPRINTVALHEX debug_print_value_hex
#define DPRINTVALHEXBYTE debug_print_value_hex_byte
#define DPRINTVALHEXWORD debug_print_value_hex_word
#define DPRINTVALHEXLONG debug_print_value_hex_long

#endif /* _FB_H */
