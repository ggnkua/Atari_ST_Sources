/* 
   Font Scaling Module Device Editor

   Kenneth Soohoo
   March 9, 1990	Copyright 1990 Atari Corporation
 */

#include "fsmhead.h"

extern int SCw, SCh;
extern OBJECT *devedit;

extern DEV devices[MAX_DEV];
extern FON font_arena[MAX_FONTS];
extern char drivers[MAX_DRIVERS][14];	/* Driver names */
extern int device_count, current_device;
extern int driver_count;

char too_many[80] = "[3][|Cannot add more devices.][ OK ]";

int edit_vcurrent = 0;		/* Current view device */ 
int edit_dcurrent = 0;		/* Current delete device */

void add_to_device(font)
FON_PTR font;
/* add_to_device(font)
   Appends the given font to the current_device's font list.
 */
{
	DEV_PTR device;
	FON_PTR t_fon;

	device = &devices[current_device];

	if ((t_fon = DFONT(device)) == (FON_PTR )NULL) {
		DFONT(device) = font;
		DTFONT(device) = font;
		DLINK(font)[current_device] = (FON_PTR )NULL;
		}
	else {
		while (DLINK(t_fon)[current_device] != (FON_PTR )NULL) {
			t_fon = DLINK(t_fon)[current_device];
			}
		DLINK(t_fon)[current_device] = font;
		DLINK(font)[current_device] = (FON_PTR )NULL;
		}

	DFCOUNT(device) += 1;

	return;
}

void remove_from_device(font)
FON_PTR font;
/* remove_from_device(font)
   Removes the given font from the current_device's font list.
 */
{
	DEV_PTR device, oldtop;
	FON_PTR t_fon, l_fon;

	device = &devices[current_device];

	oldtop = DTFONT(device);

	if (font == DFONT(device)) {
		/* First font in the list is deleted */
		DFONT(device) = DLINK(font)[current_device];
		DLINK(font)[current_device] = (FON_PTR )NULL;

		/* Top font was this font, then update the top font */
		if (oldtop == font) DTFONT(device) = DFONT(device);
		}
	else {
		t_fon = DFONT(device);

		/* Go search for the font being deleted */
		while ((t_fon != (FON_PTR )NULL) && (t_fon != font)) {
			l_fon = t_fon;
			t_fon = DLINK(t_fon)[current_device];
			}
		if (t_fon != (FON_PTR )NULL) {
			/* Link over the deleted font */
			DLINK(l_fon)[current_device] = DLINK(t_fon)[current_device];
			DLINK(t_fon)[current_device] = (FON_PTR )NULL;

			/* If we were displaying the deleted font as top... */
			if (oldtop == font) 
				DTFONT(device) = DLINK(l_fon)[current_device];
			}
		}

	DFCOUNT(device) -= 1;

	return;
}

void draw_vdevice()
/* draw_vdevice()
   Draws the view device in the device editing dialog.
 */
{
	DEV_PTR vdevice;
	char *device_text;

	vdevice = &devices[edit_vcurrent];
	device_text = *(char **)devedit[VTXT].ob_spec;

	if (device_count != 0) {
		sprintf(device_text, " %2d %s", DDEV(vdevice), drivers[DNAME(vdevice)]);

		/* Indicate if the device is ROM, and resident */
		if (DTYPE(vdevice) == 'R')
			devedit[VRES].ob_state |= CHECKED;
		else devedit[VRES].ob_state &= ~CHECKED;
		if (DTYPE(vdevice) == 'P')
			devedit[VROM].ob_state |= CHECKED;
		else devedit[VROM].ob_state &= ~CHECKED;
		}
	else {
		device_text[0] = ' ';
		devedit[VRES].ob_state &= CHECKED;
		devedit[VROM].ob_state &= CHECKED;
		}

	objc_draw(devedit, VTXT, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, VROM, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, VRES, 0, 0, 0, SCw, SCh);

	return;
}

void draw_ddevice()
/* draw_ddevice()
   Draws the delete device selector in the device editing dialog.
 */
{
	DEV_PTR ddevice;
	char *device_text;

	ddevice = &devices[edit_dcurrent];
	device_text = *(char **)devedit[DTXT].ob_spec;

	if (device_count != 0) {
		sprintf(device_text, " %2d %s", DDEV(ddevice), drivers[DNAME(ddevice)]);

		/* Indicate if the device is ROM, and resident */
		if (DTYPE(ddevice) == 'R')
			devedit[DRES].ob_state |= CHECKED;
		else devedit[DRES].ob_state &= ~CHECKED;
		if (DTYPE(ddevice) == 'P')
			devedit[DROM].ob_state |= CHECKED;
		else devedit[DROM].ob_state &= ~CHECKED;
		}
	else {
		device_text[0] = ' ';

		devedit[DRES].ob_state &= ~CHECKED;
		devedit[DROM].ob_state &= ~CHECKED;
		}

	objc_draw(devedit, DTXT, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, DROM, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, DRES, 0, 0, 0, SCw, SCh);

	return;
}

void draw_adevice()
/* draw_adevice()
   Draws the add device selector in the device editing dialog.
 */
{
	DEV_PTR adevice;
	char *device_text;

	adevice = &devices[device_count];
	device_text = *(char **)devedit[ATXT].ob_spec;

	sprintf(device_text, " %2d %s", DDEV(adevice), drivers[DNAME(adevice)]);

	/* Indicate if the device is ROM, and resident */
	if (DTYPE(adevice) == 'R')
		devedit[ARES].ob_state |= CHECKED;
	else devedit[ARES].ob_state &= ~CHECKED;
	if (DTYPE(adevice) == 'P')
		devedit[AROM].ob_state |= CHECKED;
	else devedit[AROM].ob_state &= ~CHECKED;

	objc_draw(devedit, ATXT, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, AROM, 0, 0, 0, SCw, SCh);
	objc_draw(devedit, ARES, 0, 0, 0, SCw, SCh);

	return;
}

DEV_PTR find_device(device)
int device;
/* find_device(device)
   Goes looking through our current devices to see if there's a device
   with the given number.  If so, return it's pointer, otherwise, NULL;
 */
{
	DEV_PTR tdevice;
	int i;

	for (i = 0; i < device_count; ++i) {
		tdevice = &devices[i];
		if (DDEV(tdevice) == device) return tdevice;
		}
	return (DEV_PTR )NULL;
}

void init_adevice()
/* init_adevice()
   Initializes the parameters for adding a device.
 */
{
	DEV_PTR adevice;
	char *device_text;

	/* Initialize the "add device" scroller */
	adevice = &devices[device_count];
	
	/* Initialize the "add device" scroller */
	DDEV(adevice) = 0;
	do {
		DDEV(adevice) += 1;
		} while (find_device(DDEV(adevice)));
	DNAME(adevice) = 0;
	DTYPE(adevice) = ' ';

	device_text = *(char **)devedit[ATXT].ob_spec;
	sprintf(device_text, " %2d %s", DDEV(adevice), drivers[DNAME(adevice)]);

	/* Indicate if the device is ROM, and resident */
	if (DTYPE(adevice) == 'R')
		devedit[ARES].ob_state |= CHECKED;
	else devedit[ARES].ob_state &= ~CHECKED;
	if (DTYPE(adevice) == 'P')
		devedit[AROM].ob_state |= CHECKED;
	else devedit[AROM].ob_state &= ~CHECKED;
}

void init_editdev()
/* init_editdev()
   Sets up the appropriate values for the Edit Device dialog.
   Initializes the "view" and "delete" scrollers, and calls the
   "add" device initialization.
 */
{
	DEV_PTR vdevice, ddevice;
	char *device_text;

	edit_vcurrent = 0;
	edit_dcurrent = 0;

	/* Initialize the "view device" scroller */
	vdevice = &devices[edit_vcurrent];
	/* Initialize the "delete device" scroller */
	ddevice = &devices[edit_dcurrent];

	device_text = *(char **)devedit[VTXT].ob_spec;
	if (device_count != 0) {
		sprintf(device_text, " %2d %s", DDEV(vdevice), drivers[DNAME(vdevice)]);

		/* Indicate if the device is ROM, and resident */
		if (DTYPE(vdevice) == 'R')
			devedit[VRES].ob_state |= CHECKED;
		else devedit[VRES].ob_state &= ~CHECKED;
		if (DTYPE(vdevice) == 'P')
			devedit[VROM].ob_state |= CHECKED;
		else devedit[VROM].ob_state &= ~CHECKED;
		}
	else {
		device_text[0] = ' ';
		devedit[VRES].ob_state &= ~CHECKED;
		devedit[VROM].ob_state &= ~CHECKED;
		}

	/* Initialize the "delete device" scroller */
	device_text = *(char **)devedit[DTXT].ob_spec;
	if (device_count != 0) {
		sprintf(device_text, " %2d %s", DDEV(ddevice), drivers[DNAME(ddevice)]);

		/* Indicate if the device is ROM, and resident */
		if (DTYPE(ddevice) == 'R')
			devedit[DRES].ob_state |= CHECKED;
		else devedit[DRES].ob_state &= ~CHECKED;
		if (DTYPE(ddevice) == 'P')
			devedit[DROM].ob_state |= CHECKED;
		else devedit[DROM].ob_state &= ~CHECKED;
		}
	else {
		device_text[0] = ' ';
		devedit[DRES].ob_state &= ~CHECKED;
		devedit[DROM].ob_state &= ~CHECKED;
		}

	init_adevice();

	return;
}

void del_font_dlinks(start)
int start;
/* del_font_dlinks(start)
   For all fonts, scoot the font dlinks (links of fonts for a specific
   device) to compensate for the deleted device at "start"
 */
{
	long oldsel, newsel;
	register int i, j;

	for (i = 0; i < MAX_FONTS; ++i) {
		if (font_arena[i].type == BITMAP_FONT) {
			for (j = start; j < device_count; ++j) {
				font_arena[i].dlink[j] = font_arena[i].dlink[j+1];
				}
			oldsel = font_arena[i].select;
			newsel = oldsel & ((1L << start) - 1L);
			oldsel &= ~((1L << start) - 1L);
			oldsel >>= 1;	/* Make room */
			oldsel &= ~((1 << start) - 1);
			font_arena[i].select = oldsel | newsel;
			}
		}
}

void bump_font_dlinks(start)
int start;
/* bump_font_dlinks(start)
   For all fonts, make room for a device font link at "start".
 */
{
	long oldsel, newsel;
	register int i, j;

	for (i = 0; i < MAX_FONTS; ++i) {
		for (j = device_count; j > start; --j) {
			font_arena[i].dlink[j] = font_arena[i].dlink[j-1];
			}
		font_arena[i].dlink[j] = (FON_PTR )NULL;

		oldsel = font_arena[i].select;
		newsel = oldsel & ((1L << start) - 1L);
		oldsel &= ~((1L << start) - 1L);
		oldsel <<= 1;	/* Make room */
		font_arena[i].select = oldsel | newsel;
		}
}

void do_editdev(outbut)
int outbut;
/* do_editdev(outbut)
   Handles all possible buttons and their operations in the edit devices
   dialog box.  Returns nothing.  Expects the button that was touched
   to be re-drawn, but doesn't assume any other redraws.
 */
{
	DEV_PTR vdevice, ddevice, adevice;
	DEV temp_dev;
	int i, j;

	/* Just in case */
	if (device_count == 0) {
		edit_vcurrent = 0;
		edit_dcurrent = 0;
		}

	vdevice = &devices[edit_vcurrent];	/* View pointer */
	ddevice = &devices[edit_dcurrent];	/* Pointer to possible del */
	adevice = &devices[device_count];	/* Add into next position */

	switch (outbut) {
		case VLEFT:
			/* View the next lowest index device */
			if (--edit_vcurrent < 0)
				edit_vcurrent = device_count - 1;
			draw_vdevice();
			break;
		case VRIGHT:
			/* View the next highest index device */
			if (++edit_vcurrent >= device_count)
				edit_vcurrent = 0;
			draw_vdevice();
			break;
		case VUP:
			/* Change this device's driver */
			if ((DNAME(vdevice) += 1) >= driver_count)
				DNAME(vdevice) = 0;
			draw_vdevice();
			if (vdevice == ddevice)
				draw_ddevice();
			break;
		case VDOWN:
			if ((DNAME(vdevice) -= 1) < 0)
				DNAME(vdevice) = driver_count - 1;
			draw_vdevice();
			if (vdevice == ddevice)
				draw_ddevice();
			break;

		case DLEFT:
			if (--edit_dcurrent < 0)
				edit_dcurrent = device_count - 1;
			draw_ddevice();
			break;
		case DRIGHT:
			if (++edit_dcurrent >= device_count)
				edit_dcurrent = 0;
			draw_ddevice();
			break;

		case ALEFT:
			do {
				DDEV(adevice) -= 1;
				if (DDEV(adevice) < 1) DDEV(adevice) = 99;
				} while (find_device(DDEV(adevice)));
			draw_adevice();
			break;
		case ARIGHT:
			do {
				DDEV(adevice) += 1;
				if (DDEV(adevice) > 99) DDEV(adevice) = 1;
				} while (find_device(DDEV(adevice)));
			draw_adevice();
			break;
		case AUP:
			if ((DNAME(adevice) += 1) >= driver_count)
				DNAME(adevice) = 0;
			draw_adevice();
			break;
		case ADOWN:
			if ((DNAME(adevice) -= 1) < 0)
				DNAME(adevice) = driver_count - 1;
			draw_adevice();
			break;

		case VRES:
			if (device_count == 0) return;

			if (DTYPE(vdevice) == 'P') {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(vdevice) = 'R';
				else DTYPE(vdevice) = ' ';

				devedit[VROM].ob_state &= ~CHECKED;
				objc_draw(devedit, VROM, 0, 0, 0, SCw, SCh);
				}
			else {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(vdevice) = 'R';
				else DTYPE(vdevice) = ' ';
				}
			if (vdevice == ddevice)
				draw_ddevice();
			break;
		case VROM:
			if (device_count == 0) return;

			if (DTYPE(vdevice) == 'R') {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(vdevice) = 'P';
				else DTYPE(vdevice) = ' ';

				devedit[VRES].ob_state &= ~CHECKED;
				objc_draw(devedit, VRES, 0, 0, 0, SCw, SCh);
				}
			else {
				devedit[outbut].ob_state ^= CHECKED;

				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(vdevice) = 'P';
				else DTYPE(vdevice) = ' ';
				}
			if (vdevice == ddevice)
				draw_ddevice();
			break;

		case ARES:
			if (DTYPE(adevice) == 'P') {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(adevice) = 'R';
				else DTYPE(adevice) = ' ';

				devedit[AROM].ob_state &= ~CHECKED;
				objc_draw(devedit, AROM, 0, 0, 0, SCw, SCh);
				}
			else {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(adevice) = 'R';
				else DTYPE(adevice) = ' ';
				}
			break;

		case AROM:
			if (DTYPE(adevice) == 'R') {
				devedit[outbut].ob_state ^= CHECKED;
				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(adevice) = 'P';
				else DTYPE(adevice) = ' ';

				devedit[ARES].ob_state &= ~CHECKED;
				objc_draw(devedit, ARES, 0, 0, 0, SCw, SCh);
				}
			else {
				devedit[outbut].ob_state ^= CHECKED;

				if (devedit[outbut].ob_state & CHECKED)
					DTYPE(adevice) = 'P';
				else DTYPE(adevice) = ' ';
				}
			break;

		case ADDDEV:
			/* Only allow 16 devices at a time */
			if (current_device == MAX_DEV) {
				form_alert(1, too_many);
				return;
				}

			/* Look for a numerical spot for this device */
			for (i = 0; (i <= device_count) &&
				    (devices[i].device <
				     devices[device_count].device); ++i) {}

			/* Make sure it's a valid location */
			if ((device_count == 0) ||	/* No devs OK */
			    (i == device_count) || 	/* Last position OK */
			    ((i < device_count) && 
			    (devices[i].device != devices[device_count].device))){

				/* Initialize a few values to empty */
				devices[device_count].font_count = 0;
				devices[device_count].first_font = (FON_PTR )NULL;
				devices[device_count].top_font = (FON_PTR )NULL;
				devices[device_count].top_num = 0;

				/* Insert into devices list */
				temp_dev = devices[device_count];
				for (j = device_count; j > i; --j) {
					devices[j] = devices[j - 1];
					}
				devices[i] = temp_dev;
				if (device_count > 0) {
					if (current_device >= i) current_device++;
					if (edit_vcurrent >= i) edit_vcurrent++;
					}
				else {
					current_device = 0;
					edit_vcurrent = 0;
					edit_dcurrent = 0;
					}
				device_count++;

				bump_font_dlinks(i);

				/* Reset the "add device" scroller */
				adevice = &devices[device_count];
				DDEV(adevice) = devices[current_device].device;
				do {
					DDEV(adevice) += 1;
					if (DDEV(adevice) > 99) 
						DDEV(adevice) = 1;
					} while (find_device(DDEV(adevice)));
				draw_adevice();

				if (device_count == 1) {
					draw_vdevice();
					draw_ddevice();
					}
				}

			break;
		case DELDEV:
			if (device_count == 0) return;

			/* Move devices in to fill the hole */
			for (i = edit_dcurrent; i < device_count; ++i) {
				devices[i] = devices[i + 1];
				}
			del_font_dlinks(edit_dcurrent);

			/* Fix up device count */
			device_count--;
			/* Change display if we're looking at deleted dev */
			if (current_device >= edit_dcurrent) 
				if (--current_device < 0) current_device = 0;
			if (edit_vcurrent >= edit_dcurrent) 
				if (--edit_vcurrent < 0) edit_vcurrent = 0;
			draw_vdevice();

			/* and initialize "delete device" */
			edit_dcurrent = 0;
			draw_ddevice();

			break;

		default:
			break;
	}
}

