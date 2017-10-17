/*
 * fVDI generic device driver initialization, by Johan Klockars
 *
 * $Id: init.c,v 1.8 2005/06/01 21:00:10 johan Exp $
 *
 * Since it would be difficult to do without this file when
 * writing new device drivers, and to make it possible for
 * some such drivers to be commercial, this file is put in
 * the public domain. It's not copyrighted or under any sort
 * of license.
 *
 * I don't expect this file to need many changes for different modes
 * and hardware.
 *
 * This file will of course be extended when new acceleration options
 * and such are added to the fVDI kernel.
 */

#include <mint/osbind.h>
#include <string.h>
#include "fvdi.h"
#include "driver.h"
#include "relocate.h"
#include "fb.h"


#define MAX_PALETTE	256
#define Min(x,y)	(((x) <= (y)) ? (x) : (y))


extern void CDECL check_linea(Workstation *);

/*
 * Necessary device driver functions
 */
extern void *set_palette;
extern void *c_set_palette;
extern void *colour;
extern void *c_colour;
extern void *set_pixel;
extern void *c_set_pixel;
extern void *get_pixel;
extern void *c_get_pixel;

/*
 * Acceleration functions
 */
extern void *line;
extern void *c_line;
extern void *expand;
extern void *c_expand;
extern void *fill;
extern void *c_fill;
extern void *fillpoly;
extern void *c_fillpoly;
extern void *blit;
extern void *c_blit;
extern void *text;
extern void *c_text;
extern void *mouse;
extern void *c_mouse;

extern short accel_s;	/* Bit vector of available assembly acceleration routines */
extern short accel_c;	/* The same for C versions */


extern Mode *graphics_mode;

extern long wk_extend;

extern char driver_name[];


extern void check_token(char *, const char **);
extern void CDECL initialize(Virtual *);
extern long CDECL setup(long, long);
extern Virtual* CDECL opnwk(Virtual *);
extern void CDECL clswk(Virtual *);


/*
 * Default 'accelerator' functions
 * Will be called automatically from
 * common.s/c_common.s if an accelerator
 * function returns with d0=0.
 */

void *fallback_line;
void *fallback_text;
void *fallback_fill;
void *fallback_fillpoly;
void *fallback_expand;
void *fallback_blit;

/*
 * Global variables
 */

long CDECL init(Access *_access, Driver *driver, Virtual *vwk, char *);

Locator locator = {MAGIC, MODULE_IF_VER, init};

Access *access;

short mask[16][4];		/* Allocate instead? */

Driver *me;			/* Access to this seems to be needed */

Device device;

short *loaded_palette;

static unsigned char tos_colours[] = {0, 255, 1, 2, 4, 6, 3, 5, 7, 8, 9, 10, 12, 14, 11, 13};

char err_msg[80];

short accelerate, oldmouse;


void copymem(void *s, void *d, long n)
{
	char *src, *dest;

	src = (char *)s;
	dest = (char *)d;
	for(n = n - 1; n >= 0; n--)
		*dest++ = *src++;
}

long tokenize(const char *ptr)
{
	char token[80], *tmp, ch;
	ptr = Funcs_skip_space(ptr);
	while (ptr) {
		ptr = Funcs_get_token(ptr, token, 80);
		check_token(token, &ptr);	/* Check driver specific parameters */
		if (Funcs_equal(token, "accelerate")) {
			if (!(ptr = Funcs_skip_space(ptr)))
				;		/* *********** Error, somehow */
			ptr = Funcs_get_token(ptr, token, 80);
			accelerate = 0;
			tmp = token;
			while ((ch = *tmp++)) {	/* Figure out what things should be accelerated */
				accelerate <<= 1;
				if ((ch != '0') && (ch != '-'))
					accelerate++;
			}
			accelerate &= ACCEL_ALL;
		}
		if (Funcs_equal(token, "oldmouse")) {
			oldmouse = 1;
		}
		ptr = Funcs_skip_space(ptr);
	}
	return 1;
}


void setup_scrninfo(Device *device, Mode *graphics_mode)
{
	int i;
	MBits *gmbits;

	device->format = graphics_mode->format;
	device->clut = graphics_mode->clut;
	device->bit_depth = graphics_mode->bpp;
	gmbits = &graphics_mode->bits;
	device->bits.red = gmbits->red[0];
	device->bits.green = gmbits->green[0];
	device->bits.blue = gmbits->blue[0];
	device->bits.alpha = gmbits->alpha[0];
	device->bits.genlock = gmbits->genlock[0];
	device->bits.unused = gmbits->unused[0];
	device->bits.organization = graphics_mode->org;	
	device->dummy2 = 0;
	if (device->clut == 2) {
		int bits = gmbits->red[0] + gmbits->green[0] + gmbits->blue[0];
		device->dummy1 = (1L << bits) >> 16;
		device->colours = (1L << bits) & 0xffff;

		for(i = 0; i < gmbits->red[0]; i++)
			device->scrmap.bitnumber.red[i] = gmbits->red[i + 1];
		for(i = gmbits->red[0]; i < 16; i++)
			device->scrmap.bitnumber.red[i] = -1;		/* Not used */
		for(i = 0; i < gmbits->green[0]; i++)
			device->scrmap.bitnumber.green[i] = gmbits->green[i + 1];
		for(i = gmbits->green[0]; i < 16; i++)
			device->scrmap.bitnumber.green[i] = -1;		/* Not used */
		for(i = 0; i < gmbits->blue[0]; i++)
			device->scrmap.bitnumber.blue[i] = gmbits->blue[i + 1];
		for(i = gmbits->blue[0]; i < 16; i++)
			device->scrmap.bitnumber.blue[i] = -1;		/* Not used */
		for(i = 0; i < gmbits->alpha[0]; i++)
			device->scrmap.bitnumber.alpha[i] = gmbits->alpha[i + 1];
		for(i = gmbits->alpha[0]; i < 16; i++)
			device->scrmap.bitnumber.alpha[i] = -1;		/* Not used */
		for(i = 0; i < gmbits->genlock[0]; i++)
			device->scrmap.bitnumber.genlock[i] = gmbits->genlock[i + 1];
		for(i = gmbits->genlock[0]; i < 16; i++)
			device->scrmap.bitnumber.genlock[i] = -1;	/* Not used */
		for(i = 0; i < gmbits->unused[0]; i++)
			device->scrmap.bitnumber.unused[i] = gmbits->unused[i + 1];
		for(i = gmbits->unused[0]; i < 32; i++)
			device->scrmap.bitnumber.unused[i] = -1;	/* Not used */
		for(i = 0; i < 144; i++)
			device->scrmap.bitnumber.reserved[i] = 0;
	} else {
		device->dummy1 = (1L << graphics_mode->bpp) >> 16;
		device->colours = (1L << graphics_mode->bpp) & 0xffff;

		for(i = 0; i < sizeof(tos_colours); i++)
			device->scrmap.vdi2pix[i] = (unsigned short)tos_colours[i];
		if (graphics_mode->bpp == 8) {
			for(; i < 255; i++)
				device->scrmap.vdi2pix[i] = i;
			device->scrmap.vdi2pix[255] = 15;
		} else {
			for(; i < 256; i++)
				device->scrmap.vdi2pix[i] = 0;
		}
	}
}


/*
 * Do all initialization that can be done while loading.
 * Supplied is an access structure for fVDI internals,
 *   the default fVDI virtual workstation and
 *   a pointer to the command line arguments.
 * Return 1 if no error occured.
 */
long CDECL init(Access *_access, Driver *driver, Virtual *vwk, char *opts)
{
	Workstation *wk;
	Virtual *default_vwk = 0;
	Workstation *default_wk = 0;
	Colour *default_palette = 0;
	if(((unsigned long)init < 0xE00000UL) || ((unsigned long)init >= 0x1000000UL)) /* not from ROM */
	{
		extern char _bss_start[], _end[];
		memset(_bss_start, 0, (int)(_end - _bss_start)); /* bss zone not cleared by fVDI */
	}
	
	access = _access;

	/*
	 * Initialize the device structure
	 */
	 
	me = driver;			/* Seems to be needed */
	driver->module.name = driver_name;
	driver->module.initialize = initialize;
	driver->module.setup = setup;
	driver->opnwk = opnwk;
	driver->clswk = clswk;
	driver->default_vwk = 0;	/* Set below */
	driver->device = &device;
	driver->module.private = 0;

	/*
	 * Check device driver options
	 */

	accelerate = ACCEL_ALL;		/* Default to everything on */
	oldmouse = 0;			/* Default to fVDI mouse drawing */
	tokenize(opts);

	/*
	 * Allocate and do initial setup (by copying)
	 * of the default device specific workstation/virtual
	 */
	 
	if (!(default_wk = (Workstation *)Funcs_malloc(sizeof(Workstation) + wk_extend, 3)))
		return 0;
		
	if (!(default_vwk = (Virtual *)Funcs_malloc(sizeof(Virtual), 3))) {
		Funcs_free(default_wk);
		return 0;
	}

	copymem(vwk->real_address, default_wk, sizeof(Workstation));
	copymem(vwk, default_vwk, sizeof(Virtual));

	wk = default_wk;
	default_vwk->real_address = wk;
	driver->default_vwk = default_vwk;

	/*
	 * Do some initialization using LineA etc
	 * if it can be of use to the driver.
	 */

	if (graphics_mode && (graphics_mode->flags & CHECK_PREVIOUS)) {
		check_linea(wk);		/* Sets linea/wrap/width/height/bitplanes */

		if(wk->screen.mfdb.bitplanes == 32)
			wk->screen.palette.size = MAX_PALETTE;
		else
			wk->screen.palette.size = Min(1L << wk->screen.mfdb.bitplanes, MAX_PALETTE);
		wk->screen.mfdb.address = (void *)Physbase();
		wk->screen.mfdb.wdwidth = wk->screen.mfdb.width / 16;
#if 0
		wk->screen.logical = Logical();
#endif

		if (!(default_palette = (Colour *)Funcs_malloc(wk->screen.palette.size * sizeof(Colour), 3))) {
			Funcs_free(default_vwk);
			Funcs_free(default_wk);
			return 0;
		}
		if (wk->screen.palette.colours)
			loaded_palette = (short *)wk->screen.palette.colours;
		wk->screen.palette.colours = default_palette;
	}


	/*
	 * Initialize more of the default workstation
	 */
	 
	wk->driver = driver;
	wk->screen.mfdb.standard = 0;
	wk->screen.type = 4;
	wk->screen.colour = 1;
	wk->screen.bkg_colours = 0;			/* ? */
#if 0
	if (graphics_mode->flags & TRUE_COLOUR)
		wk->screen.look_up_table = 0;		/* True colour */
	else
		wk->screen.look_up_table = 1;		/* Not true colour */
	wk->screen.palette.possibilities = 1 << graphics_mode->bpp;
#else
 #if 0
	if (graphics_mode->clut)
		wk->screen.look_up_table = 0;		/* Hardware or software lookup table */
	else
		wk->screen.look_up_table = 1;		/* No lookup table (ST monochrome) */
 #else
	wk->screen.look_up_table = 1;			/* Why?!? */
 #endif
	wk->screen.palette.possibilities = 0;		/* More than 32767 colours available */
 #if 0
        if (...)
		wk->screen.palette.possibilities = 0;		/* Old modes had less colours */
 #endif
#endif
/* Values and transformation table */
/* Pixel width/height */
/* Coordinates (what's 'course'?  max/min should be more sophisticated) */
	wk->screen.coordinates.max_x = wk->screen.mfdb.width - 1;
	wk->screen.coordinates.max_y = wk->screen.mfdb.height - 1;
/* 16x16 op/s */
	wk->various.buttons = 2;
	wk->various.cursor_movement = 2;
	wk->various.number_entry = 1;
	wk->various.selection = 1;
	wk->various.typing = 1;
	wk->various.workstation_type = 2;
	
	
	/*
	 * Set up the required and accelerator functions
	 */

//	if (accel_s & A_SET_PAL)
//		wk->r.set_palette = &set_palette;
//	else
		wk->r.set_palette = &c_set_palette;
//	if (accel_s & A_GET_COL)
//		wk->r.get_colour = &colour;
//	else
		wk->r.get_colour = &c_colour;
//	if (accel_s & A_SET_PIX)
//		wk->r.set_pixel = &set_pixel;
//	else
		wk->r.set_pixel = &c_set_pixel;
//	if (accel_s & A_GET_PIX)
//		wk->r.get_pixel = &get_pixel;
//	else
		wk->r.get_pixel = &c_get_pixel;
	if (accelerate & A_LINE)
	{
		fallback_line = wk->r.line;		/* Remember the original (internal) function */
//		if (accel_s & A_LINE)			/* Look for assembly... */
//			wk->r.line = &line;
//		else
		if (accel_c & A_LINE)		/* ...and C accelerator functions */
			wk->r.line = &c_line;
	}
	if (accelerate & A_EXPAND)
	{
		fallback_expand = wk->r.expand;
//		if (accel_s & A_EXPAND)
//			wk->r.expand = &expand;
//		else
		if (accel_c & A_EXPAND)
			wk->r.expand = &c_expand;
	}
	if (accelerate & A_FILL)
	{
		fallback_fill = wk->r.fill;
//		if (accel_s & A_FILL)
//			wk->r.fill = &fill;
//		else
		if (accel_c & A_FILL)
			wk->r.fill = &c_fill;
	}
	if (accelerate & A_FILLPOLY)
	{
		fallback_fillpoly = wk->r.fillpoly;
//		if (accel_s & A_FILLPOLY)
//			wk->r.fillpoly = &fillpoly;
//		else
		if (accel_c & A_FILLPOLY)
			wk->r.fillpoly = &c_fillpoly;
	}
	if (accelerate & A_BLIT)
	{
		fallback_blit = wk->r.blit;
//		if (accel_s & A_BLIT)
//			wk->r.blit = &blit;
//		else
		if (accel_c & A_BLIT)
			wk->r.blit = &c_blit;
	}
	if (accelerate & A_TEXT)
	{
		fallback_text = wk->r.text;
//		if (accel_s & A_TEXT)
//			wk->r.text = &text;
//		else
		if (accel_c & A_TEXT)
			wk->r.text = &c_text;
	}
	if (!oldmouse)
	{
		if (accelerate & A_MOUSE)
		{
			wk->mouse.type = 1;	/* Should this be here? */
			if (accel_s & A_MOUSE)
				wk->r.mouse = &mouse;
			else if (accel_c & A_MOUSE)
				wk->r.mouse = &c_mouse;
		}
		else
		{
			if ((wk->mouse.extra_info = Funcs_malloc((16 * 16 + 2 ) * sizeof(short), 3)))
				wk->mouse.type = 1;
		}
	}

	/*
	 * Initialize colour number to mask conversion table
	 * if it's needed (that is, for bitplane modes).
	 */

	if (!(graphics_mode->flags & CHUNKY)) {
		int i, j, v;
		for(i = 0; i < 16; i++) {
			switch (wk->screen.mfdb.bitplanes) {
			case 1:
				v = (i & 0x01) ? 0x000f : 0;
				break;
			case 2:
				v = i & 0x03;
				v |= v << 2;
				break;
			default:
				v = i;
				break;
			}
			for(j = 0; j < 4; j++) {
				if (v & 0x01)
					mask[i][j] = 0xffff;
				else
					mask[i][j] = 0;
				v >>= 1;
			}
		}
	}
	
	setup_scrninfo(&device, graphics_mode);
	
/* Perhaps set up default clipping? */

	return 1;
}
