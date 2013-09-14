/* 
   Font Scaling Module Desk Accessory FONTMAN Event Handler
   Font selector code stolen from UFFON.C

   Kenneth Soohoo
   December 29, 1989		Copyright 1989 Atari Corp
   March 8, 1990		Copyright 1990 Atari Corp
 */

#include "fsmhead.h"

extern long atol();

extern void open_dialog(), close_dialog();
extern void save_path(), restore_path();
extern void free_all_bitmap(), free_all_fsm();
extern int get_all_bitmap_fonts(), get_all_fsm_fonts();
extern void get_bitpath(), get_fsmpath();

extern int handle, SCw, SCh, line_h, rez;
extern int extent[];
extern OBJECT *fonsel, *infrf, *aboutit;
extern OBJECT *fsmsel, *bitsel;
extern OBJECT *setpath, *setcache, *devedit, *fsmpoints;
extern GRECT about, nothing;
extern DMABUFFER *olddma, newdma;	/* DMA buffers for _our_ searches */

extern DEV devices[MAX_DEV];
extern FON font_arena[MAX_FONTS];
extern char drivers[MAX_DRIVERS][14];	/* Driver names */
extern int device_count, current_device;
extern int driver_count;
extern void text_init(), linea_text();		/* Assembly */
extern void write_assign();		/* Writes the assign.sys */
extern void write_extend();		/* Writes the extend.sys */

extern void add_to_device(), remove_from_device();
extern void init_editdev();
extern void do_editdev();

FON_PTR stemp, exit_fon, settemp;
int slidetop, slidesize, howfar, bx, by;
FON_PTR last_start = (FON_PTR )NULL;
int topitem, fsmtop, bittop;
int dvslidesize, dvslidetop;
FDB screen;

char font_search_path[120];	/* Path to get to fonts */
char bitmap_path[120];
char blanks[30] = "                           ";
long bitcache, fsmcache;	/* Cache size for each type of font */

FON_PTR fon_list, fon_last, start_fon;	/* Doubly linked list of fonts */
FON_PTR fsm_list, fsm_last, fsm_start;
FON_PTR bit_list, bit_last, bit_start;
int fon_count, fsm_count, bit_count;	/* Totals for # of fonts */
int font_type;				/* Bitmap or FSM fonts */

long fsm_defaults[16];		/* Default point sizes */

char set_bit_path[20] = "Set Bitmap Path";
char set_fsm_path[20] = "Set Outline Path";
char set_bit_cache[20] = "Set Bitmap Cache";
char set_fsm_cache[20] = "Set Outline Cache";
char bitcache_txt[60] = "be used to cache bitmapped fonts.  The change";
char fsmcache_txt[60] = "be used to cache outline fonts.  The change";

char affect_all[80] = "[1][Replace all current point|size selections with|these defaults][ No | Yes ]";
char newpath[120];
char filex[16];
char allfile[16] = "\\*.*";

int pts_idx[NUM_FSM_NAMES] = {
	PTS1, PTS2, PTS3, PTS4, PTS5, PTS6, PTS7, PTS8, 
	PTS9, PTS10, PTS11, PTS12, PTS13, PTS14, PTS15, PTS16
	};

long set_sel(val)
long val;
/* set_sel(val)
   Takes the current select value and returns the appropriate select
   value that makes it valid for the current device.
 */
{
	if (font_type == BITMAP_FONT) {
		val = val | (1L << current_device);
		return (val);
		}
	else {
		return TRUE;
		}
}

int clear_sel(val)
long val;
/* clear_sel(val)
   Takes the current select value and returns the appropriate select
   value that makes it de-selected for the current device.
 */
{
	if (font_type == BITMAP_FONT) {
		val = val & ~(1L << current_device);
		return (val);
		}
	else {
		return FALSE;
		}
}

int check_sel(val)
long val;
/* check_sel(val)
   Checks to see if the current device's bit has been set in the font's
   selected flag, and if so, returns true.
 */
{
	if (font_type == BITMAP_FONT) {
		if (device_count == 0) return FALSE;

		val = val & (1L << current_device);
		if (val != 0) return TRUE;
		else return FALSE;
		}
	else {
		return val;
		}
}

void draw_device_fonts()
{
	DEV_PTR device;
	FON_PTR t_fon;
	int ul_x, ul_y;
	int i;
	long largest, total;
	long save_sp;

	device = &devices[current_device];

	ul_x = fonsel[FBACK].ob_x + fonsel[DEVBOX].ob_x + fonsel[BBIGBOX].ob_x +
		fonsel[DEVNAMES].ob_x;
	ul_y = fonsel[FBACK].ob_y + fonsel[DEVBOX].ob_y + fonsel[BBIGBOX].ob_y +
		fonsel[DEVNAMES].ob_y;

	total = 0L; largest = 0L;

	mouse_off();
	save_sp = Super(0L);
	text_init();
	t_fon = DTFONT(device);

	for (i = 0; (i < NUM_DEV_NAMES) && (t_fon != (FON_PTR )NULL); ++i) {
		linea_text(ul_x, ul_y + (i * (line_h-1)), FNAME(t_fon), 7);

		t_fon = DLINK(t_fon)[current_device];
		}
	for (; i < NUM_DEV_NAMES; ++i) {
		linea_text(ul_x, ul_y + (i * (line_h-1)), blanks, 7);
		}

	Super(save_sp);

	/* Make the "largest" and "total" numbers for display */
	t_fon = DFONT(device);
	while (t_fon != (FON_PTR )NULL) {
		if (FSIZE(t_fon) > largest) largest = FSIZE(t_fon);
		total += FSIZE(t_fon);

		t_fon = DLINK(t_fon)[current_device];
		}

	sprintf(*(char **)fonsel[SIZE].ob_spec, "Total: %7ld Largest: %7ld",
		total, largest);
	objc_draw(fonsel, SIZE, 0, 0, 0, SCw, SCh);

	mouse_on();

}

void update_device_arrows()
{
	DEV_PTR device;

	device = &devices[current_device];

	if (DTOP(device) == 0) 
		fonsel[DEVDOWN].ob_state |= DISABLED;
	else fonsel[DEVDOWN].ob_state &= ~DISABLED;

	if (DTOP(device) >= (DFCOUNT(device) - NUM_DEV_NAMES)) 
		fonsel[DEVUP].ob_state |= DISABLED;
	else fonsel[DEVUP].ob_state &= ~DISABLED;

	fonsel[DEVSLID].ob_y = (dvslidesize * DTOP(device)) / 
		(DFCOUNT(device) - NUM_DEV_NAMES);
	if (fonsel[DEVSLID].ob_y > dvslidesize) fonsel[DEVSLID].ob_y = dvslidesize;

	objc_draw(fonsel, DEVDOWN, 0, 0, 0, SCw, SCh);
	objc_draw(fonsel, DEVUP, 0, 0, 0, SCw, SCh);
	objc_draw(fonsel, DEVPAREN, 1, 0, 0, SCw, SCh);

	return;
}

void draw_device()
/* draw_device()
   Puts the current device, it's device number, and it's associated fonts
   onto the screen.  Assumes that the current dialog is the bitmap fonts
   dialog.
 */
{
	DEV_PTR device;
	char *device_text;

	/* Replace the device text with the device's name and # */

	device = &devices[current_device];
	device_text = *(char **)fonsel[DRVNAME].ob_spec;

	if (device_count != 0) {
		sprintf(device_text, " %2d %s", DDEV(device), drivers[DNAME(device)]);
		}
	else {
		/* No devices! */
		current_device == 0;
		device = &devices[current_device];
		device_text[0] = '\0';
		DFCOUNT(device) = 0;
		DTFONT(device) = (FON_PTR )NULL;
		DDEV(device) = 0;
		}
	objc_draw(fonsel, DRVNAME, 0, 0, 0, SCw, SCh);

	/* Device changing arrows are enabled for non-screen devices */
/*
	if (DDEV(device) < 11) {
		fonsel[SWDRUP].ob_state |= DISABLED;
		fonsel[SWDRDOWN].ob_state |= DISABLED;
		}
	else {
		fonsel[SWDRUP].ob_state &= ~DISABLED;
		fonsel[SWDRDOWN].ob_state &= ~DISABLED;
		}
	objc_draw(fonsel, SWDRUP, 0, 0, 0, SCw, SCh);
	objc_draw(fonsel, SWDRDOWN, 0, 0, 0, SCw, SCh);
*/
	/* Now show all the fonts associated with that device # */

	/* Display the associated fonts and devices */
	draw_device_fonts();

	fonsel[DEVSLID].ob_height = 
		(fonsel[DEVPAREN].ob_height * NUM_DEV_NAMES) / DFCOUNT(device);
	if (fonsel[DEVSLID].ob_height > fonsel[DEVPAREN].ob_height)
		fonsel[DEVSLID].ob_height = fonsel[DEVPAREN].ob_height;

	dvslidesize = fonsel[DEVPAREN].ob_height - fonsel[DEVSLID].ob_height;

	update_device_arrows();

	return;
}

void draw_names()
/* draw_names()
   Displays the current font names in the font selector box (beginning with
   the start_fon font).  Selected fonts are inverted.
 */
{
	FON_PTR t_fon;
	int ul_x, ul_y;
	int width, height;
	int blit[8];		/* Screen scroll */
	long save_sp;
	int names_idx;
	int num_names;
	register int i, j;

	if (font_type == BITMAP_FONT) {
		num_names = NUM_NAMES;
		}
	else {
		num_names = NUM_FSM_NAMES;
		}

	if (fon_count == 0) {
		if (font_type != BITMAP_FONT) {
			for (i = 0; i < NUM_FSM_NAMES; ++i) {
				fonsel[pts_idx[i]].ob_state |= DISABLED;
				objc_draw(fonsel, pts_idx[i], 0, 0, 0, SCw, SCh);
				}
			}
		return;	/* Nothing to do! */
		}

	if (font_type == BITMAP_FONT) names_idx = FNAMES;
	else names_idx = FSMNAMES;

	ul_x = bx + fonsel[names_idx].ob_x;
	ul_y = by + fonsel[names_idx].ob_y;
	width = fonsel[names_idx].ob_width; 
	height = fonsel[names_idx].ob_height;

	vst_color(handle, 0);		/* In black */
	vswr_mode(handle, 1);		/* Replace */

	if ( (last_start == start_fon) ||
	     (last_start == (FON_PTR )NULL) ||
	     ((last_start != FPREV(start_fon)) &&
	      (last_start != FNEXT(start_fon)) ) ) {

		/* if we're jumping or re-drawing, then do entire thing */

		mouse_off();
		save_sp = Super(0L);
		text_init();
		t_fon = start_fon;

		for (i = 0; (i < num_names) && (i < fon_count); ++i) {
			if (check_sel(SEL(t_fon)))	/* Invert it! */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 16);
			else 		/* Let it be normal */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 7);

			t_fon = FNEXT(t_fon);
			}

		Super(save_sp);

		if (font_type != BITMAP_FONT) {
			for (j = 0; j < i; ++j) {
				fonsel[pts_idx[j]].ob_state &= ~DISABLED;
				objc_draw(fonsel, pts_idx[j], 0, 0, 0, SCw, SCh);
				}
			for ( ; i < num_names; ++i) {
				fonsel[pts_idx[i]].ob_state |= DISABLED;
				objc_draw(fonsel, pts_idx[i], 0, 0, 0, SCw, SCh);
				}
			}

		mouse_on();

		last_start = start_fon;
		}
	else {
		/* Otherwise we can blit the screen's area up or down */
		if (last_start == FPREV(start_fon)) {
			blit[0] = ul_x;			/* Source */
			blit[1] = ul_y + (line_h - 1);
			blit[2] = ul_x + width - 1;
			blit[3] = ul_y + height - 1;

			blit[4] = ul_x;
			blit[5] = ul_y;
			blit[6] = blit[2];
			blit[7] = blit[3] - (line_h - 1);

			mouse_off();
			save_sp = Super(0L);
			text_init();

			vro_cpyfm(handle, 3, blit, &screen, &screen);

			t_fon = start_fon;
			for (i = 0; i < (num_names - 1); ++i) {
				t_fon = FNEXT(t_fon);
				}

			if (check_sel(SEL(t_fon)))	/* Invert it! */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 16);
			else 		/* Let it be normal */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 7);


			Super(save_sp);
			mouse_on();
			}
		else if (last_start == FNEXT(start_fon)) {
			/* Define blit box for scroll by one */

			blit[0] = ul_x;
			blit[1] = ul_y;
			blit[2] = ul_x + width - 1;
			blit[3] = ul_y + height - 1 - (line_h - 1);

			blit[4] = ul_x;
			blit[5] = ul_y + (line_h - 1);
			blit[6] = ul_x + width - 1;
			blit[7] = ul_y + height - 1;

			mouse_off();
			save_sp = Super(0L);
			text_init();

			vro_cpyfm(handle, 3, blit, &screen, &screen);

			t_fon = start_fon;

			if (check_sel(SEL(t_fon)))	/* Invert it! */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 16);
			else 		/* Let it be normal */
				linea_text(ul_x, ul_y + (i * (line_h-1)), 
					   FNAME(t_fon), 7);

			Super(save_sp);
			mouse_on();
			}
		last_start = start_fon;
		}

	return;
}

void update_arrows()
/* update_arrows()
   Draws enabled / disabled versions of the slider arrows according to
   the current positioning.
 */
{
	int down_idx, up_idx, slider_idx, parent_idx;
	int num_names;

	if (font_type == BITMAP_FONT) {
		down_idx = FDOWN;
		up_idx = FUP;
		slider_idx = FSLIDER;
		parent_idx = FSLPAREN;
		num_names = NUM_NAMES;
		}
	else {
		down_idx = FSMDOWN;
		up_idx = FSMUP;
		slider_idx = FSMSLID;
		parent_idx = FSMPAREN;
		num_names = NUM_FSM_NAMES;
		}

	if (topitem == 0) fonsel[down_idx].ob_state |= DISABLED;
	else fonsel[down_idx].ob_state &= ~DISABLED;

	if (topitem >= (fon_count - num_names)) fonsel[up_idx].ob_state |= DISABLED;
	else fonsel[up_idx].ob_state &= ~DISABLED;

	fonsel[slider_idx].ob_y = (slidesize * topitem) / (fon_count - num_names);
	if (fonsel[slider_idx].ob_y > slidesize) fonsel[slider_idx].ob_y = slidesize;

	objc_draw(fonsel, down_idx, 0, 0, 0, SCw, SCh);
	objc_draw(fonsel, up_idx, 0, 0, 0, SCw, SCh);
	objc_draw(fonsel, parent_idx, 1, 0, 0, SCw, SCh);
}

void change_type()
{
	int down_idx, up_idx, slider_idx, parent_idx;
	int big_box, box_idx, back_idx;
	int num_names;

	if (font_type == BITMAP_FONT) {
		down_idx = FDOWN;
		up_idx = FUP;
		slider_idx = FSLIDER;
		parent_idx = FSLPAREN;
		box_idx = FBOX;
		big_box = BBIGBOX;
		back_idx = FBACK;
		num_names = NUM_NAMES;
		}
	else {
		down_idx = FSMDOWN;
		up_idx = FSMUP;
		slider_idx = FSMSLID;
		parent_idx = FSMPAREN;
		box_idx = FSMBOX;
		big_box = FBIGBOX;
		back_idx = FSMBACK;
		num_names = NUM_FSM_NAMES;
		}

	fonsel[slider_idx].ob_height = (fonsel[parent_idx].ob_height * num_names)/fon_count;
	if (fonsel[slider_idx].ob_height > fonsel[parent_idx].ob_height)
		fonsel[slider_idx].ob_height = fonsel[parent_idx].ob_height;

	fonsel[slider_idx].ob_y = 0;
	slidesize = fonsel[parent_idx].ob_height - fonsel[slider_idx].ob_height;

	bx = fonsel[box_idx].ob_x + fonsel[big_box].ob_x +
		fonsel[back_idx].ob_x;	/* Locate names in */
	by = fonsel[box_idx].ob_y + fonsel[big_box].ob_y +
		fonsel[back_idx].ob_y; 	/* Selector box */
}

void init_select_font()
/*  init_select_font()
    Sets up the necessary variables for select font, some of which we
    don't need to set up before every call.
 */
{
	int hor_out, vert_out;

	fon_list = bit_list; fon_last = bit_last;
	fon_count = bit_count; font_type = BITMAP_FONT;
	bit_start = bit_list; fsm_start = fsm_list;

	fonsel[FSLIDER].ob_height = (fonsel[FSLPAREN].ob_height * NUM_NAMES)/fon_count;
	if (fonsel[FSLIDER].ob_height > fonsel[FSLPAREN].ob_height)
		fonsel[FSLIDER].ob_height = fonsel[FSLPAREN].ob_height;

	fonsel[FSLIDER].ob_y = 0;
	slidesize = fonsel[FSLPAREN].ob_height - fonsel[FSLIDER].ob_height;

	start_fon = fon_list;		/* Font list */

	vst_effects(handle, 0);		/* Normal text */
	vsf_interior(handle, 1);	/* Fill box w/ white */
	vsf_style(handle, 0);

	/* Make sure we can draw by specifying the upper left corner */
	vst_alignment(handle, 0, 5, &hor_out, &vert_out);

	vswr_mode(handle, 2);		/* Transparent put */
	screen.fd_addr = 0l;		/* FDB for screen */

	bx = fonsel[FBOX].ob_x + fonsel[FBIGBOX].ob_x + fonsel[FBACK].ob_x;
	by = fonsel[FBOX].ob_y + fonsel[FBIGBOX].ob_y + fonsel[FBACK].ob_y;

	topitem = 0;			/* Start at the top ! */
	fsmtop = 0; bittop = 0;
}

void flip_font(ypos)
int ypos;
/* flip_font(ypos)
   Inverts the appropriate bar in the font names selector as well as the
   appropriate font in the global font bar.
 */
{
	FON_PTR settemp, last = (FON_PTR )NULL;
	int font_off, i, j;
	int pxy[4];
	int color[2] = {0, 1};
	int mx, my, but, key;
	int names;
	int num_names;

	/* Check for selecting one of the font names */

	if (font_type == BITMAP_FONT) {
		names = FNAMES;
		num_names = NUM_NAMES;
		}
	else {
		names = FSMNAMES;
		num_names = NUM_FSM_NAMES;
		}

	do {
		settemp = start_fon;
		font_off = (ypos - (by + fonsel[names].ob_y)) / (line_h - 1);
		if (font_off < 0) return;

		i = font_off; j = 0;
		while ((settemp != (FON_PTR )NULL) && (i > 0) && (j < num_names)) {
			settemp = FNEXT(settemp);
			i--; j++;
			}
		if ((settemp == (FON_PTR )NULL) || (j >= num_names) ) return;

		if (last != settemp) {

			if (check_sel(SEL(settemp))) {
				SEL(settemp) = clear_sel(SEL(settemp));
				if (font_type == BITMAP_FONT) {
					remove_from_device(settemp);
					draw_device();
					}
				}
			else {
				SEL(settemp) = set_sel(SEL(settemp));
				if (font_type == BITMAP_FONT) {
					add_to_device(settemp);
					draw_device();
					}
				}

			vswr_mode(handle, 3);	/* XOR for a second */
			vsf_color(handle, 1);	/* Black */

			pxy[0] = bx + fonsel[names].ob_x;
			pxy[1] = by + fonsel[names].ob_y + ((line_h - 1) * (font_off + 1)) - 1;
			pxy[2] = extent[4] + pxy[0] - 1;
			pxy[3] = pxy[1] - line_h + 2;

			mouse_off();
			vr_recfl(handle, pxy);
			mouse_on();

			vswr_mode(handle, 1);	/* Back to replace */
			}

		graf_mkstate(&mx, &my, &but, &key);
		if (but) {
			ypos = my;
			last = settemp;
			}
	} while (but);
	
	return;
}

void replace_all()
/* replace_all()
   Take the chosen defaults and replace all the current point size
   selections with those defaults.
 */
{
	FON_PTR scan;
	int i;

	scan = fsm_list;
	while(scan != (FON_PTR )NULL) {
		for (i = 0; i < 16; ++i) {
			DLINK(scan)[i] = (FON_PTR )fsm_defaults[i];
			}
		scan = FNEXT(scan);
		}
	return;
}

int select_font(button)
/* select_font(button)
   Handles the dialog box for selecting a font.
 */
{
	unsigned int dclick;
	int newpos;			/* Slider box's new position */
	int i, mx, my, but, key, dummy, count;
	int outbut;			/* Sub-dialog exit button */
	int num_names;
	long already_set;
	char *device_text;		/* Device's name in dialog */
	char *thepath;			/* Path temp name */
	long *thecache;
	DEV_PTR device;
	FON_PTR t_fon;

	/* Single pass through code after click in window taken */

	if ((button & 0x8000) != 0) dclick = 1;	/* Double click? */
	else dclick = 0;
	button &= ~0x8000;			/* Remove flag */ 
		
	switch (button) {

	case BITABOUT:
		close_dialog();
		do_dialog(aboutit);
		open_dialog(fonsel);
		draw_names();
		if (font_type == BITMAP_FONT) draw_device();

		return FALSE;
		
	case FOK:
		/* Accept the selections, write out the ASSIGN.SYS,
		   and exit the application.  Closer doesn't write.
		 */
		if (font_type == BITMAP_FONT) {
			fonsel[FOK].ob_state |= SELECTED;
			objc_draw(fonsel, FOK, 1, 0, 0, SCw, SCh);
			write_assign();
			fonsel[FOK].ob_state &= ~SELECTED;
			objc_draw(fonsel, FOK, 1, 0, 0, SCw, SCh);
			}
		else {
			fonsel[FSMOK].ob_state |= SELECTED;
			objc_draw(fonsel, FSMOK, 1, 0, 0, SCw, SCh);
			write_extend();
			fonsel[FSMOK].ob_state &= ~SELECTED;
			objc_draw(fonsel, FSMOK, 1, 0, 0, SCw, SCh);
			}

		return FALSE;

	case FUNDO:	/* Change the selections back */
		close_dialog();

		if (font_type == BITMAP_FONT) {
			free_all_bitmap();
			olddma = (DMABUFFER *)Fgetdta();	
			Fsetdta(&newdma);
			get_bitpath();
			get_all_bitmap_fonts();
			Fsetdta(olddma);

			fon_list = bit_list;
			fon_last = bit_last;
			fon_count = bit_count;
			topitem = bittop;
			start_fon = bit_list;
			}
		else {
			free_all_fsm();
			olddma = (DMABUFFER *)Fgetdta();	
			Fsetdta(&newdma);
			get_fsmpath();
			get_all_fsm_fonts();
			Fsetdta(olddma);
			parse_extend();

			fon_list = fsm_list;
			fon_last = fsm_last;
			fon_count = fsm_count;
			topitem = fsmtop;
			start_fon = fsm_list;
			}
		last_start = (FON_PTR )NULL;

		open_dialog(fonsel);
		draw_names();
		update_arrows();
		if (font_type == BITMAP_FONT) draw_device();

		return FALSE;

	case BITCLOSE:	/* Just an exit */
		return TRUE;

	case EDITDEV:	/* Change devices */
		if (font_type == BITMAP_FONT) {
			init_editdev();

			close_dialog();
			open_dialog(devedit);

			do {
				outbut = form_do(devedit, 0);
				outbut &= ~0x8000;
				devedit[outbut].ob_state &= ~SELECTED;
				do_editdev(outbut);
				objc_draw(devedit, outbut, MAX_DEPTH, about);

				} while (outbut != DEDITDN);

			close_dialog();
			}
		else {
			for (i = PNT1; i <= PNT10; ++i) {
				if (fsm_defaults[i - PNT1] != 0L) {
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"%3ld", fsm_defaults[i - PNT1]);
					}
				else {
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"@");
					}
				}

			sprintf(*(char **)fsmpoints[PTSNAME].ob_spec, 
				"Default Point Sizes");
			close_dialog();
			
			if (do_dialog(fsmpoints) == PTSOK) {
				for (i = PNT1; i <= PNT10; ++i) {
					fsm_defaults[i - PNT1] =
					  (long )atoi(*(char **)fsmpoints[i].ob_spec);
					}
				/* Affect all currently selected fonts? */
				if (form_alert(1, affect_all) == 2) {
					replace_all();
					}
				}
			}

		open_dialog(fonsel);
		draw_names();
		
		if (font_type == BITMAP_FONT) draw_device();
		
		return FALSE;

	case BITPATH:	/* Change path dialog */
		if (font_type == BITMAP_FONT) {
			thepath = bitmap_path;
/*			strcpy(*(char **)setpath[SETTITLE].ob_spec, set_bit_path); */
			}
		else {
			thepath = font_search_path;
/*			strcpy(*(char **)setpath[SETTITLE].ob_spec, set_fsm_path); */
			}
/*
		if (strlen(thepath) > 29) {
			/ * Too much for a single line * /
			strncpy(*(char **)setpath[PATH1].ob_spec, thepath, 29);
			strncpy(*(char **)setpath[PATH2].ob_spec, &thepath[29], 29);
			}
		else {
			/ * Path contained in a single line * /
			strcpy(*(char **)setpath[PATH1].ob_spec, thepath);
			strncpy(*(char **)setpath[PATH2].ob_spec, "@", 29);
			}

		outbut = do_dialog(setpath);
*/
		strcpy(newpath, thepath);
		strcat(newpath, allfile);
		close_dialog();
		fsel_input(newpath, filex, &outbut);

		if (outbut == 1) {
/*
			strncpy(thepath, *(char **)setpath[PATH1].ob_spec, 29);
			strncpy(&thepath[29], *(char **)setpath[PATH2].ob_spec, 29);
*/
			strcpy(thepath, newpath);

/*	
			if (thepath[strlen(thepath) - 1] == '\\')
				thepath[strlen(thepath) - 1] = '\0';
*/
			for (i = strlen(thepath); 
			     (i > 0) && (thepath[i] != '\\'); --i) { }
			thepath[i] = '\0';

			/* Now re-read the fonts! */
			if (font_type == BITMAP_FONT) {
				free_all_bitmap();
				olddma = (DMABUFFER *)Fgetdta();	
				Fsetdta(&newdma);
				get_all_bitmap_fonts();
				Fsetdta(olddma);

				fon_list = bit_list;
				fon_last = bit_last;
				fon_count = bit_count;
				topitem = bittop;
				start_fon = bit_list;
				}
			else {
				free_all_fsm();
				olddma = (DMABUFFER *)Fgetdta();	
				Fsetdta(&newdma);
				get_all_fsm_fonts();
				Fsetdta(olddma);
				parse_extend();

				fon_list = fsm_list;
				fon_last = fsm_last;
				fon_count = fsm_count;
				topitem = fsmtop;
				start_fon = fsm_list;
				}
			last_start = (FON_PTR )NULL;
			change_type();		/* Reset the sliders */
			}

		open_dialog(fonsel);
		draw_names();
		update_arrows();
		
		if (font_type == BITMAP_FONT) draw_device();

		return FALSE;

	case BITCACHE:	/* Change cache size dialog */
		if (font_type == BITMAP_FONT) {
			thecache = &bitcache;
			strcpy(*(char **)setcache[CACHETIT].ob_spec, set_bit_cache);
			strcpy(*(char **)setcache[CACHETXT].ob_spec, bitcache_txt);
			}
		else {
			thecache = &fsmcache;
			strcpy(*(char **)setcache[CACHETIT].ob_spec, set_fsm_cache);
			strcpy(*(char **)setcache[CACHETXT].ob_spec, fsmcache_txt);
			}

		sprintf(*(char **)setcache[CACHESIZ].ob_spec, "%7ld", *thecache);

		close_dialog();
		outbut = do_dialog(setcache);

		if (outbut == CACHEOK) {
			*thecache = atol(*(char **)setcache[CACHESIZ].ob_spec);
			}

		open_dialog(fonsel);
		draw_names();
		
		if (font_type == BITMAP_FONT) draw_device();

		return FALSE;

	case FSWITCH:	/* Switch bitmap and fsm */
		if (font_type == FSM_FONT) {
			font_type = BITMAP_FONT;/* Become Bitmap selector */
			fsm_start = start_fon;	/* Save stats */
			fsmtop = topitem;

			start_fon = bit_start;
			topitem = bittop;
			fon_count = bit_count;
			fon_list = bit_list;
			fon_last = bit_last;

			fonsel = bitsel;

			close_dialog();
			open_dialog(fonsel);
			change_type();

			draw_names();
			draw_device();
			update_arrows();
			}
		else {
			font_type = FSM_FONT;	/* Become FSM selector */
			bit_start = start_fon;
			bittop = topitem;

			start_fon = fsm_start;
			topitem = fsmtop;
			fon_count = fsm_count;
			fon_list = fsm_list;
			fon_last = fsm_last;

			fonsel = fsmsel;

			close_dialog();
			open_dialog(fonsel);
			change_type();

			draw_names();
			update_arrows();
			}

		do {				/* Prevent bounce */
			graf_mkstate(&mx, &my, &but, &key);
			} while (but);

		return FALSE;

	case FUP:
		if (font_type == BITMAP_FONT) num_names = NUM_NAMES;
		else num_names = NUM_FSM_NAMES;

		if (start_fon != (FON_PTR )NULL) {

			if (++topitem > (fon_count - num_names)) 
				topitem = fon_count - num_names;
			else {
				start_fon = FNEXT(start_fon);
				draw_names();
				}
			update_arrows();
			}

		return FALSE;

	case FDOWN:
		if (start_fon != (FON_PTR )NULL) {

			if (--topitem < 0) topitem = 0;
			else {
				start_fon = FPREV(start_fon);
				draw_names();
				}
			update_arrows();
			}

		return FALSE;

	case FSLIDER:
		if (font_type == BITMAP_FONT) num_names = NUM_NAMES;
		else num_names = NUM_FSM_NAMES;

		newpos = graf_slidebox(fonsel, FSLPAREN, FSLIDER, 1);

		topitem = (int )(((long )newpos * (long )(fon_count - num_names)) /
				 1000l);
		if (topitem < 0) topitem = 0;
		if (topitem > (fon_count - num_names)) topitem = fon_count - num_names;	

		howfar = topitem;
		stemp = fon_list;

		while ((stemp != (FON_PTR )NULL) && (howfar > 0)) {
			stemp = FNEXT(stemp);
			--howfar;
			}

		start_fon = stemp;	/* Update pointer to top */
		draw_names();

		update_arrows();

		return FALSE;

	case FSLPAREN:
		if (font_type == BITMAP_FONT) {
			objc_offset(fonsel, FSLIDER, &dummy, &slidetop);
			num_names = NUM_NAMES;
			}
		else {
			objc_offset(fonsel, FSMSLID, &dummy, &slidetop);
			num_names = NUM_FSM_NAMES;
			}
		graf_mkstate(&mx, &my, &but, &key);

		if (my < slidetop) {
			/* Move up one page (down) */
			if ((topitem -= (num_names - 1)) < 0) topitem = 0;

			update_arrows();
			}
		else {
			/* Move down one page (up) */
			if ((topitem += (num_names - 1)) > (fon_count - num_names)) 
				topitem = fon_count - num_names;

			update_arrows();
			}

		howfar = topitem;

		stemp = fon_list;
		while ((stemp != (FON_PTR )NULL) && (howfar > 0)) {
			stemp = FNEXT(stemp);
			--howfar;
			}
		if (font_type == BITMAP_FONT)
			objc_draw(fonsel, FSLPAREN, 1, 0, 0, SCw, SCh);
		else objc_draw(fonsel, FSMPAREN, 1, 0, 0, SCw, SCh);

		start_fon = stemp;	/* Update pointer to top */
		draw_names();

		return FALSE;
	
	case BITLEFT:
		if (device_count == 0) return FALSE;

		/* Go left a device */
		if (--current_device < 0) current_device = device_count - 1;
		draw_device();
		draw_names();

		count = 0;
		do {				/* Prevent bounce */
			graf_mkstate(&mx, &my, &but, &key);
			count++;
			} while ((but) && (count < 80));

		return FALSE;

	case BITRIGHT:
		if (device_count == 0) return FALSE;

		/* Go right a device */
		if (++current_device >= device_count) current_device = 0;
		draw_device();
		draw_names();

		count = 0;
		do {				/* Prevent bounce */
			graf_mkstate(&mx, &my, &but, &key);
			count++;
			} while ((but) && (count < 100));

		return FALSE;
	
	case DEVUP:
		device = &devices[current_device];

		if (DTFONT(device) != (FON_PTR )NULL) {

		if (++DTOP(device) > (DFCOUNT(device) - NUM_DEV_NAMES)) 
				DTOP(device) = DFCOUNT(device) - NUM_DEV_NAMES;
			else {
				DTFONT(device) = 
					DLINK(DTFONT(device))[current_device];
				draw_device_fonts();
				update_device_arrows();
				}
			}

		return FALSE;

	case DEVDOWN:
		device = &devices[current_device];

		if (DTFONT(device) != (FON_PTR )NULL) {

			if (--DTOP(device) < 0) {
				DTOP(device) = 0;
				DTFONT(device) = DFONT(device);
				}
			else {
				i = 0;
				t_fon = DFONT(device);
				while ((t_fon != (FON_PTR )NULL) &&
					(i < DTOP(device)) ){
					t_fon = DLINK(t_fon)[current_device];
					++i;
					}
				DTFONT(device) = t_fon;
				draw_device_fonts();
				update_device_arrows();
				}
			}

		return FALSE;

	case DEVSLID:
		device = &devices[current_device];

		newpos = graf_slidebox(fonsel, DEVPAREN, DEVSLID, 1);

		DTOP(device) = (int )(((long )newpos * (long )(DFCOUNT(device) - NUM_DEV_NAMES)) /
				 1000l);
		if (DTOP(device) < 0) DTOP(device) = 0;
		if (DTOP(device) > (DFCOUNT(device) - NUM_DEV_NAMES)) 
			DTOP(device) = DFCOUNT(device) - NUM_DEV_NAMES;	

		howfar = DTOP(device);
		stemp = DFONT(device);

		while ((stemp != (FON_PTR )NULL) && (howfar > 0)) {
			stemp = DLINK(stemp)[current_device];
			--howfar;
			}

		DTFONT(device) = stemp;	/* Update pointer to top */

		draw_device_fonts();
		update_device_arrows();

		return FALSE;

	case DEVPAREN:
		device = &devices[current_device];

		objc_offset(fonsel, DEVSLID, &dummy, &dvslidetop);
		graf_mkstate(&mx, &my, &but, &key);

		if (my < dvslidetop) {
			/* Move up one page (down) */
			if ((DTOP(device) -= (NUM_DEV_NAMES - 1)) < 0) DTOP(device) = 0;

			draw_device_fonts();
			update_device_arrows();
			}
		else {
			/* Move down one page (up) */
			if ((DTOP(device) += (NUM_DEV_NAMES - 1)) > (DFCOUNT(device) - NUM_DEV_NAMES)) 
				DTOP(device) = DFCOUNT(device) - NUM_DEV_NAMES;

			draw_device_fonts();
			update_device_arrows();
			}

		howfar = DTOP(device);

		stemp = DFONT(device);
		while ((stemp != (FON_PTR )NULL) && (howfar > 0)) {
			stemp = DLINK(stemp)[current_device];
			--howfar;
			}
		objc_draw(fonsel, DEVPAREN, 1, 0, 0, SCw, SCh);

		DTFONT(device) = stemp;	/* Update pointer to top */

		draw_device_fonts();
		update_device_arrows();

		return FALSE;
	
	case FNAMES:
		graf_mkstate(&mx, &my, &but, &key);
		flip_font(my);

		if (dclick) button = FOK; /* Double click */

		return FALSE;

	case SWDRUP:
		if (device_count == 0) return FALSE;

		device = &devices[current_device];

		if ((DNAME(device) += 1) >= driver_count) DNAME(device) = 0;

		device_text = *(char **)fonsel[DRVNAME].ob_spec;
		sprintf(device_text, " %2d %s", DDEV(device), drivers[DNAME(device)]);
		objc_draw(fonsel, DRVNAME, 0, 0, 0, SCw, SCh);

		count = 0;
		do {				/* Prevent bounce */
			graf_mkstate(&mx, &my, &but, &key);
			count++;
			} while ((but) && (count < 70));

		return FALSE;

	case SWDRDOWN:
		if (device_count == 0) return FALSE;

		device = &devices[current_device];

		if ((DNAME(device) -= 1) < 0) DNAME(device) = driver_count - 1;

		device_text = *(char **)fonsel[DRVNAME].ob_spec;
		sprintf(device_text, " %2d %s", DDEV(device), drivers[DNAME(device)]);
		objc_draw(fonsel, DRVNAME, 0, 0, 0, SCw, SCh);

		count = 0;
		do {				/* Prevent bounce */
			graf_mkstate(&mx, &my, &but, &key);
			count++;
			} while ((but) && (count < 70));

		return FALSE;

	case (100 + PTS1):
	case (100 + PTS2):
	case (100 + PTS3):
	case (100 + PTS4):
	case (100 + PTS5):
	case (100 + PTS6):
	case (100 + PTS7):
	case (100 + PTS8):
	case (100 + PTS9):
	case (100 + PTS10):
	case (100 + PTS11):
	case (100 + PTS12):
	case (100 + PTS13):
	case (100 + PTS14):
	case (100 + PTS15):
	case (100 + PTS16):
		for (i = 0, t_fon = start_fon; button != 100 + pts_idx[i]; ++i) {
			t_fon = FNEXT(t_fon);
			}
		for (i = 0, already_set = 0L; i < 16; ++i) {
			already_set |= (long )DLINK(t_fon)[i];
			}

		for (i = PNT1; i <= PNT10; ++i) {
			/* If we've set any of these fields before, then
			   we don't need the defaults.
			 */
			if (already_set > 0L) {
				/* Stored point size settings */
				if ((long )(DLINK(t_fon)[i - PNT1]) != 0L)
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"%3ld", (long )(DLINK(t_fon)[i - PNT1]));
				else 
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"@");
				}
			else {
				/* Use the default settings instead */
				if (fsm_defaults[i - PNT1] > 0L)
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"%3ld", fsm_defaults[i - PNT1]);
				else 
					sprintf(*(char **)fsmpoints[i].ob_spec,
						"@");
				}
			}
		/* Show the name of the font we're working on */
		sprintf(*(char **)fsmpoints[PTSNAME].ob_spec, 
			FNAME(t_fon));

		close_dialog();
		/* If the user said "OK" we can copy these out to the font. */
		if (do_dialog(fsmpoints) == PTSOK) {
			for (i = PNT1; i <= PNT10; ++i) {
				DLINK(t_fon)[i - PNT1] =
				  (FON_PTR )atoi(*(char **)fsmpoints[i].ob_spec);
				}
			}

		open_dialog(fonsel);
		draw_names();

		return FALSE;
		break;

	case ONLY_WIDTH:
		fonsel[WIDTH].ob_state ^= CHECKED;
		objc_draw(fonsel, WIDTH, 0, 0, 0, SCw, SCh);
		return FALSE;
		break;

	default:
		return FALSE;
	}
}

int fsm_objc[40] = {
	FSMBACK, FSMOK, FSMUNDO, FSMDOWN, FSMPAREN, FSMSLID, FSMUP,
	FSMNAMES, FSMSWIT, FSMCLOSE, FSMABOUT, FSMPATH, FSMCACHE,
	FSMDEFS, WIDTH, -1
	};
int bit_objc[40] = {
	FBACK, FOK, FUNDO, FDOWN, FSLPAREN, FSLIDER, FUP,
	FNAMES, FSWITCH, BITCLOSE, BITABOUT, BITPATH, BITCACHE,
	EDITDEV, ONLY_WIDTH, -1
	};

int map_to_bit(object)
int object;
{
	int i = 0;

	while (fsm_objc[i] >= 0) {
		if (fsm_objc[i] == object) return bit_objc[i];
		++i;
		}
}

void do_manager()
/* do_manager()
   Handles all the button presses for both the bitmap and outline font
   managers.
 */
{
	int i, out_but, out_flag = 0;

	open_dialog(fonsel);	
	init_select_font();

	/* Hit the form with the proper information */
	update_arrows();
	draw_names();
	draw_device();

	mouse_arrow();

	do {
		out_but = form_do(fonsel, 0);
		out_but &= ~0x8000;
		if (!(fonsel[out_but].ob_state & DISABLED)) {
			if (font_type == FSM_FONT) {
				for (i = 0; i < NUM_FSM_NAMES; ++i) {
					if (out_but == pts_idx[i])
						out_but += 100;
					}
				if (out_but < 100) 
					out_but = map_to_bit(out_but);
				}
			/* Do all normal bitmap & fsm selections */
			out_flag = select_font(out_but);
			}	
		} while (!out_flag);

	mouse_busy();

	close_dialog();

	mouse_arrow();

	return;
}
