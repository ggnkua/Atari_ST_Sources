#include <stdio.h>
#include <portab.h>

/*
 * Hack to circumvent GO's nasty habit of converting register pointers
 * into base register or stack frame offsets.
 */
void *regptr(const void *p);
#pragma inline a0=regptr(a0) { ""; }
#define lptr(l) (regptr((void *)l))


GLOBAL int	modecode;   /* @DEFAULT 0 */

/* Sparrow video mode word (modecode)
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * The sparrow knowledge tables are taken from the VTG Cookbook with
 * several simplifications.  Always assume a 2us video burst.
 *
 * The mode word is encoded thusly:
 * 0000000i sopvcbbb
 *               ^^^ log2 bits per pixel
 *              c--- columns: 1=80 0=40
 *             v---- VGA mode
 *            p----- 1=PAL 0=NTSC
 *           o------ overscan
 *          s------- ST compatibility mode
 *        i -------- interlace (TV) / vertical doubling (VGA)
 */

/* log2 bits per pixel values */
#define BPPMASK	0x007	/* modecode mask for log2(bits per pixel) */
#define BPP1	0x000
#define BPP2	0x001
#define BPP4	0x002
#define BPP8	0x003
#define BPP16	0x004
#define BPP32	0x005
#define BPP(m)	((m) & BPPMASK)

/* # of columns */
#define COLMASK	0x008	/* modecode mask for # of columns */
#define COL40	0x000
#define COL80	0x008
#define is40(m)	(((m) & COLMASK) == COL40)
#define is80(m)	(((m) & COLMASK) == COL80)


/* video modes */
#define VIDMASK	0x1f0	/* modecode mask for monitor type & display mode */

/* monitor types */
#define VGA	0x010
#define PAL	0x020
#define isTV(m)  (((m) & VGA) != VGA)
#define isVGA(m) (((m) & VGA) == VGA)
#define isPAL(m) (((m) & PAL) == PAL)

/* display modes */
#define OVERSCAN 0x040	/* h & v res are 1.2 * normal */
#define STMODE	 0x080	/* ST compatible mode */
#define VERTFLAG 0x100	/* Interlace (TV) / Vertical doubling (VGA) */
#define isOVER(m)   (((m) & OVERSCAN) == OVERSCAN)
#define isSTMODE(m) (((m) & STMODE) == STMODE)
#define isVMODE(m)  (((m) & VERTFLAG) == VERTFLAG)
/*
 * NOTE: In VGA modes, setting VERTFLAG *halves* the vertical resolution;
 *	in TV modes, setting VERTFLAG *doubles* the vertical resolution.
 */

long colorptr[1];
long sprgb[] = {
	0x00ffffffL,		// 0 - boot color (white in production)
	0x00ff0000L,		// 1 red
	0x0000ff00L,		// 2 green
	0x00ffff00L,		// 3 yellow
	0x000000ffL,		// 4 blue
	0x00ff00ffL,		// 5 magenta
	0x0000ffffL,		// 6 cyan
	0x00aaaaaaL,		// 7 "low white"
	0x00555555L,		// 8 grey
	0x00ff5555L,		// 9 light red
	0x0055ff55L,		// 10 light green
	0x00ffff55L,		// 11 light yellow
	0x005555ffL,		// 12 light blue
	0x00ff55ffL,		// 13 light magenta
	0x0055ffffL,		// 14 light cyan
	0x00000000L		// 15 black
};



/* n_rgb variable, used by vblank routine to determine # of colors to move */
GLOBAL WORD n_rgb;
long sp_lut[256];

/* void VsetRGB(index, count, array)				XBIOS @93
 *=======================================================================
 * Set colors by RGB value.
 */
GLOBAL void
VsetRGB(WORD index, WORD count, long *array)
{
    long cptr;

long sp_munge(long);
#pragma inline d0=sp_munge(d0) {"E198E058";}
				/* rol.l #8,d0 / ror.w #8,d0 */
WORD st_munge(long);
#pragma inline d0=st_munge(d0) {"EA08E618E210E098EA08E618E210E098EA08E618EA10E198E848E998";}

    n_rgb = (isSTMODE(modecode) || BPP(modecode) < BPP8) ? 16 : 256;
    if (index+count <= n_rgb)
    {
	cptr = (long)sp_lut;
	if (isSTMODE(modecode))
	{
	    REG WORD *lut = lptr(cptr);
	    lut += index;
	    while (--count >= 0)
		*lut++ = st_munge(*array++);
	}
	else
	{
	    REG long *lut = lptr(cptr);
	    lut += index;
	    while (--count >= 0)
		*lut++ = sp_munge(*array++);
	    cptr |= 1L;
	}
	--n_rgb;
	*colorptr = cptr;
    }
}

int
main(void)
{
    int i;
    WORD *wp;
    long *lp, *cp;

    modecode = BPP16;
    cp = sprgb;
    VsetRGB(0, 16, cp);
    lp = sp_lut;
    printf("colorptr=$%p, &sp_lut=$%p\n", *colorptr, &sp_lut);
    for (i = 0; i < 16; i++)
	printf("0x%08lx -> 0x%08lx\n", *cp++, *lp++);

    modecode = STMODE|BPP4;
    cp = sprgb;
    VsetRGB(0, 16, cp);
    wp = (WORD *)sp_lut;
    printf("colorptr=$%p, &sp_lut=$%p\n", *colorptr, &sp_lut);
    for (i = 0; i < 16; i++)
	printf("0x%08lx -> 0x%04x\n", *cp++, *wp++);

    return 0;
}
