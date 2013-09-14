/*
	FSMACC.C

	FSM Font Manager Desk Accessory
	Enables the user to alter his or her FSM.SYS on the fly.
	Also contains complete ASSIGN.SYS and bitmap font handling.
	Enables the user to preview the available FSM fonts.

	Kenneth Soohoo
	December 29, 1989	Atari Corporation

	Last Modified: January 18, 1990
 */

#include "fsmhead.h"

#ifdef DESKACC
extern int gl_apid;
#endif

extern void init_select_font(), select_font(), draw_names(), do_manager();
extern void get_paths();
extern int bx, by;
extern int free_font[];

OBJECT *infrf, *aboutit, *preview, *infrbit;
OBJECT *fonsel, *fsmsel, *bitsel;
OBJECT *setpath, *setcache, *devedit, *fsmpoints;
GRECT about, nothing;
Prect dial_bx;

extern void free_all_bitmap(), free_all_fsm();
extern int get_all_bitmap_fonts(), get_all_fsm_fonts();
extern void get_bitpath(), get_fsmpath();

extern FON_PTR fon_list, fon_last, start_fon;	/* Doubly linked list of fonts */
extern FON_PTR fsm_list, fsm_last, fsm_start;
extern FON_PTR bit_list, bit_last, bit_start;
extern int fon_count, fsm_count, bit_count;	/* Totals for # of fonts */
extern int font_type, topitem, bittop, fsmtop;

int contrl[12], intin[256], intout[256], ptsin[256], ptsout[256];
int work_in[256], work_out[256];
int extent[8];				/* Extent of 30 spaces text */
int handle, SCw, SCh, rez, line_h, char_w;
int gr_handle;
int wind_hand = -1;

int fullx, fully, fullw, fullh;	/* Screen's biggest size */
int currx, curry, currw, currh;	/* Current coordinates */
int workx, worky, workw, workh;	/* Current Workspace */
int x, y, w, h;			/* X, Y, WIDTH, HEIGHT of window */
int parts = NAME | CLOSER | MOVER;

int fake;

int kisspace(thing)
char thing;
{
	if ((thing == ' ') || (thing == '\t')) return TRUE;
	else return FALSE;
}

void create_fake_window()
{
	fake = wind_create(0, 0, 0, SCw, SCh);
}
void delete_fake_window()
{
	wind_delete(fake);
}
void close_fake_window()
{
	int type, dum;
	int buffer[16];

	/* Get rid of all events from the window */
	do {
		type = evnt_multi(MU_MESAG | MU_TIMER,
				  1, 1, 1,
				  0, 0, 0, 0, 0,
				  0, 0, 0, 0, 0,
				  buffer,
				  0, 0,
				  &dum, &dum, &dum, &dum, &dum, &dum
				  );
		} while (type != MU_TIMER);

	wind_close(fake);
}
void open_fake_window()
{
	wind_open(fake, about.g_x, about.g_y, about.g_w, about.g_h);
}

void open_dialog(tree)
OBJECT *tree;
/* open_dialog(tree)
   Makes the approriate calls to draw the dialog on the screen, plus 
   extras.
 */
{
	int clipit[4];

	dial_bx.x = &about.g_x; dial_bx.y = &about.g_y; 	/* Point Prect to */
	dial_bx.w = &about.g_w; dial_bx.h = &about.g_h;	/* GRECT */
	nothing.g_x = SCw / 2; nothing.g_y = SCh / 2;
	nothing.g_w = 1; nothing.g_h = 1;

	mouse_off();
	form_center(tree, dial_bx);			/* Center everything */

	open_fake_window();

	form_dial(FMD_START, nothing, about);/* Redraw message */
	form_dial(FMD_GROW, nothing, about);		/* Expand box */

	objc_draw(tree, ROOT, MAX_DEPTH, about);	/* Draw on screen */
	mouse_on();

	clipit[0] = about.g_x;
	clipit[1] = about.g_y;
	clipit[2] = about.g_x + about.g_w - 1;
	clipit[3] = about.g_y + about.g_h - 1;
	vs_clip(handle, 1, clipit);
}

void close_dialog()
/*
  Performs the appropriate calls to remove the dialog box from the
  screen.
 */
{
	mouse_off();

	form_dial(FMD_SHRINK, nothing, about);		/* Collapse box */
	form_dial(FMD_FINISH, nothing, about);		/* Redraw message */

	mouse_on();

	close_fake_window();
}

int do_dialog(tree)
OBJECT *tree;
/* do_dialog(tree)
   Puts up and gives control of a dialog box to AES.
   Returns the exit button's ID.
 */
{
	int button;

	open_dialog(tree);

	button = form_do(tree, 0);			/* Wait for EXIT */

	close_dialog();
	tree[button].ob_state = NORMAL;		/* De-select exit button */

	return(button);
}

#ifdef DESKACC
char norsc[] = "[3][No FONTMAN.RSC file.|Install and re-boot.][ OK ]";
#else
char norsc[] = "[3][No FONTMAN.RSC file.|Install it!!][ OK ]";
#endif
char allchars[53] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123";

main()
{
#ifdef DESKACC
	int ap_id;		/* Desk accessory ID */
	int init_done = FALSE;	/* Desk Acc init */
	int msg[16];		/* evnt_multi messages */
	int event;		/* What the event handler received */
#endif
	int work_open = FALSE;	/* Workstation open? */
	int i;			/* Loop variable */
	long dum;		/* Dummy location */
	int no_resource = 0;
	
	appl_init();
	rez = Getrez();

	if (!rsrc_load("FONTMAN.RSC")) {
		no_resource = 1;
#ifndef DESKACC
		form_alert(1, norsc);
		appl_exit();
#else
		evnt_mesag(msg);	/* Go away forever */
#endif
		}

	else {
		rsrc_gaddr(0, BITSEL, &bitsel);
		rsrc_gaddr(0, FSMSEL, &fsmsel);
		rsrc_gaddr(0, INFRF, &infrf);
		rsrc_gaddr(0, INFRBIT, &infrbit);
		rsrc_gaddr(0, ABOUTIT, &aboutit);
		rsrc_gaddr(0, SETPATH, &setpath);
		rsrc_gaddr(0, SETCACHE, &setcache);
		rsrc_gaddr(0, DEVEDIT, &devedit);
		rsrc_gaddr(0, FSMPTS, &fsmpoints);

		/* Now do a little fixup to separate some buttons */
		bitsel[FUNDO].ob_y -= 1;
		bitsel[BITCACHE].ob_y -= 1;
		bitsel[EDITDEV].ob_y -= 1;

		bitsel[FOK].ob_y += 2;
		bitsel[BITPATH].ob_y += 2;
		bitsel[FSWITCH].ob_y += 2;

		/* A little more fixup for the fsm dialog */
		fsmsel[FSMUNDO].ob_y -= 1;
		fsmsel[FSMCACHE].ob_y -= 1;
		fsmsel[FSMDEFS].ob_y -= 1;

		fsmsel[FSMOK].ob_y += 2;
		fsmsel[FSMPATH].ob_y += 2;
		fsmsel[FSMSWIT].ob_y += 2;
		fsmsel[WIDTH].ob_y -= 4;

		devedit[ADDDEV].ob_y += 3;
		devedit[DELDEV].ob_y += 3;
		}

	for (i = 0; i < MAX_FONTS; ++i) {
		free_font[i] = TRUE;
		}
	
#ifndef DESKACC
	/* Gotta open the workstation */
	mouse_off();
	handle = graf_handle(&dum, &dum, &dum, &dum);
	work_in[0] = Getrez() + 2;
	for (i = 1; i < 10; work_in[i++] = 1) ; /* Open workstation */
		work_in[10] = 2;
	v_opnvwk (work_in, &handle, work_out);
	mouse_on();

	create_fake_window();

	SCw = work_out[0]; SCh = work_out[1];
	vqt_extent(handle, allchars, extent);
	line_h = extent[7] + 1;
	char_w = extent[4] / 29;

	get_paths();
	read_fonts();

	/* Now do the dialog box handling! */

	fonsel = bitsel;	/* Start with FSM manager */
	do_manager();

	delete_fake_window();
	
	return;
#endif

#ifdef DESKACC
	ap_id = menu_register(gl_apid, "  \016\017 Font Manager");

	while(TRUE) {
		event = evnt_multi(MU_MESAG,
			1, 1, 1,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			msg,
			0, 0,
			&dum, &dum, &dum, &dum, &dum, &dum
			);

		wind_update(BEG_UPDATE);

		if (event & MU_MESAG) {
			switch(msg[0]) {
				case AC_OPEN:
					/* Keep virtual workstation once */
					/* We're open, just re-open window */

					if (msg[4] != ap_id) break;

					if (no_resource) {
						form_alert(1, norsc);
						break;
						}			

					create_fake_window();

					get_paths();
					read_fonts();

					if (!work_open) {
						handle = graf_handle(&dum, &dum, &dum, &dum);
						work_in[0] = Getrez() + 2;
						for (i = 1; i < 10; work_in[i++] = 1) ; /* Open workstation */
						work_in[10] = 2;

						v_opnvwk (work_in, &handle, work_out);
						SCw = work_out[0]; 
						SCh = work_out[1];
						vqt_extent(handle, allchars, extent);
						line_h = extent[7] + 1;

						work_open = TRUE;
						}
					/* Do all the neato dialog stuff here */
					fonsel = bitsel;

					do_manager();

					free_all_bitmap();
					free_all_fsm();

					if (font_type == BITMAP_FONT) {
						fon_list = bit_list;
						fon_last = bit_last;
						fon_count = bit_count;
						topitem = bittop;
						start_fon = bit_list;
						}
					else {
						fon_list = fsm_list;
						fon_last = fsm_last;
						fon_count = fsm_count;
						topitem = fsmtop;
						start_fon = fsm_list;
						}

					delete_fake_window();

					break;

				case AC_CLOSE:
					if (msg[3] != ap_id) break;

					if (work_open) v_clsvwk(handle);
					work_open = FALSE;

					free_all_bitmap();
					free_all_fsm();

					fon_list = bit_list;
					fon_last = bit_last;
					fon_count = bit_count;
					topitem = bittop;
					start_fon = bit_list;

					break;
				default:
					break;
				}

			}
		wind_update(END_UPDATE);
		}
#endif
}
