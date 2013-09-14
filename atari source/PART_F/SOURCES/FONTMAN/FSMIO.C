/*
	FSMIO.C

	Handles the disk IO for the FSM Desk Accessory, which includes
	reading the ASSIGN.SYS, the EXTEND.SYS, and grabbing all the bitmaps
	for the available fonts.
	Builds the font list as a byproduct.

	Kenneth Soohoo
	January 4, 1990		Copyright 1990 Atari Corporation
*/

#include "fsmhead.h"

#define FSM_CACHE 1
extern long atol();

extern char font_search_path[], bitmap_path[];
extern FON_PTR fon_list, fsm_list, bit_list;
extern FON_PTR fon_last, fsm_last, bit_last;
extern int fon_count, fsm_count, bit_count;
extern int bittop, fsmtop;
extern int font_type;
extern long set_sel();
extern FDB screen;
extern long fsm_defaults[];
extern long bitcache, fsmcache;

extern int gr_handle, handle, line_h, char_w;
extern OBJECT *infrf, *infrbit, *preview, *fsmsel;

char old_path[128];
char abuf[512];			/* ASSIGN.SYS, EXTEND.SYS buffer, and others */
int alen;			/* # bytes we read */
char nofonts[80] ="[3][Cannot Find Fonts!][ OK ]";
char nodevices[80] ="[3][Cannot Find Devices!][ OK ]";
char nodrivers[80] ="[3][Cannot Find Drivers!][ OK ]";
char nomem[80] = "[3][Out of Memory!][ OK ]";
char baddata[80] = "[3][Bad File Read!][ OK ]";

int widthtables;		/* Build width tables or no? */

int fsm_found, bitmap_found;	/* TRUE for found paths to both */
DMABUFFER *olddma, newdma;	/* DMA buffers for _our_ searches */

DEV devices[MAX_DEV + 1];	/* Devices */
int device_count;		/* # devices we know about */
int current_device;		/* Device position (offset) */
char drivers[MAX_DRIVERS][14];	/* Driver names */
int driver_count;		/* Number of drivers */

FON font_arena[MAX_FONTS];	/* We use a static arena */
int font_counter = 0;
int free_font[MAX_FONTS];	/* Keeps track of what's open */

FON_PTR another_font(type)
{
	FON_PTR newfont;
	int i;

	if (font_counter >= MAX_FONTS) return (FON_PTR )NULL;

	/* Go looking for an open space in the arena */
	i= 0;
	while ((i < MAX_FONTS) && (!free_font[i])) { ++i; }
	free_font[i] = FALSE;

	newfont = &font_arena[i];
	FTYPE(newfont) = (long )type;

	return newfont;
}

void free_all_bitmap()
/* free_all_bitmap()
   Responsible for resetting all the bitmap font parameters to something
   normal, as well as freeing up all the arena space it's been using.
   Caller is responsible for re-calling the font reading routines.
 */
{
	int i;

	/* Free arena space */
	for (i = 0; i < MAX_FONTS; ++i) {
		if ((!free_font[i]) && (font_arena[i].type == BITMAP_FONT)) {
			free_font[i] = TRUE;
			}
		}
	bit_list = (FON_PTR )NULL;
	bit_last = (FON_PTR )NULL;
	bit_count = 0;
	bittop = 0;

	device_count = 0;		/* Clear device info */
	current_device = 0;
	driver_count = 0;		/* Clear driver info */

	return;
}

void free_all_fsm()
/* free_all_fsm()
   Responsible for resetting all the outline font parameters to something
   normal, as well as freeing up all the arena space it's been using.
   Caller is responsible for re-calling the font reading routines.
 */
{
	int i;

	/* Free arena space */
	for (i = 0; i < MAX_FONTS; ++i) {
		if ((!free_font[i]) && (font_arena[i].type != BITMAP_FONT)) {
			free_font[i] = TRUE;
			}
		}
	fsm_list = (FON_PTR )NULL;
	fsm_last = (FON_PTR )NULL;
	fsm_count = 0;
	fsmtop = 0;

	return;
}

long read_buffer(assign, bytes, buffer, allupper)
int assign;
long bytes;
char *buffer;
int allupper;
/* read_buffer(assign, bytes, buffer, allupper)
   Reads in a buffer load of assign.sys, returns the error code if an
   error occured.  Otherwise, returns the # of bytes actually read.
   If allupper is TRUE, sets all the alphabetic lower case to upper case.
 */
{
	long i, length;		/* Loop counter, # bytes read */

	length = Fread(assign, bytes, buffer);
	if (length < 0) {
		form_alert(1, "[3][Error reading!][ OK ]");
		}
	else if (allupper) {
		for (i = 0; i < length; ++i) {
			if ((buffer[i] >= 'a') && (buffer[i] <= 'z')) {
				buffer[i] -= 'a' - 'A';
				}
			}
		}

	return length;
}

void save_path()
/* save_path()
 */
{
	int old_drive;

	old_drive = Dgetdrv();
	Dgetpath(&old_path[2], old_drive + 1);
	old_path[0] = old_drive + 'A';
	old_path[1] = ':';

	return;
}

void restore_path()
{
	Dsetpath(old_path);
}

FON_PTR sel_fsm_font(fontname)
char *fontname;
/* sel_fsm_font(fontname)
   Go looking for a font with the same name as the name supplied.
   If found, set it to be selected.
 */
{
	FON_PTR temp;

	temp = fsm_list;
	while(temp != (FON_PTR )NULL) {
		if (!strncmp(FFNAME(temp), fontname, strlen(FFNAME(temp)))) {
			SEL(temp) = TRUE;
			return temp;
			}
		temp = FNEXT(temp);
		}
	return (FON_PTR )NULL;
}

void set_font_pts(font, points)
FON_PTR font;
char points[];
/* set_font_pts(font, points)
   Take a line of point sizes and place them into the font.
 */
{
	int i = 0, j = 0;

	if (font == (FON_PTR )NULL) return;

	i = 0;
	while (points[i] != '\0') {
		DLINK(font)[j] = (FON_PTR )atol(&points[i]);
		fsm_defaults[j] = (long )DLINK(font)[j];
		++j;
		while ((points[i] != '\0') && (points[i] != ',')) { ++i; }
		if (points[i] == ',') {
			++i;
			while (isspace(points[i])) {++i;}
			}
		}
	return;
}

char *extract_path(offset, max)
int *offset;
int max;
/* extract_path(offset)
   Given an index into abuf, immediately following the keyword that
   indicates a path follows, will extract a pointer to the path and
   return it.
 */
{
	int j;

	/* Goes looking for the start of the path */
	while ((abuf[*offset] != '=') && (*offset < max)) {
		*offset += 1;
		}
	*offset += 1;
	while ((kisspace(abuf[*offset])) && (*offset < max)) {
		*offset += 1;
		}

	/* Properly null terminates the path */
	j = *offset;
	while ((abuf[j] != '\n') && (j < (max - 1)) && (abuf[j] != '\r')) {++j;}
	abuf[j] = '\0';

	return (&abuf[*offset]);
}

void parse_extend()
/* parse_extend()
   Find out all about the fonts and point sizes for FSM.
 */
{
	int i, j, sys_file;
	FON_PTR cfont;

	if ((sys_file = Fopen("C:\\EXTEND.SYS", 0)) < 0) {
		form_alert(1, "[3][Cannot open EXTEND.SYS][ OK ]");
		sprintf(font_search_path, "C:\\");
		return;
		}

	/* Parse the C:\EXTEND.SYS file */
	do {
		i = 0;
		if ((alen = read_buffer(sys_file, 512L, abuf, TRUE)) < 0L) return;
		do {
			/* Ensure that we have a complete line to parse */
			/* If we don't, we want to read in the line */
			j = i;
			find_newline(j);

			if (j == alen) {
				strncpy(&abuf[0], &abuf[i], j - i);
				if ((alen = read_buffer(sys_file, 512L - (j - i), 
						    &abuf[j - i], TRUE)) < 0)
				    return;
				alen += (j - i);
				i = 0;
				j = i;
				find_newline(j);
				}

			if (!strncmp(&abuf[i], "files", 5) || 
			    !strncmp(&abuf[i], "FILES", 5) ) {
				cfont = sel_fsm_font(extract_path(&i, alen));
				}	
			else if (!strncmp(&abuf[i], "points", 6) || 
			         !strncmp(&abuf[i], "POINTS", 6) ) {
				set_font_pts(cfont, extract_path(&i, alen));
				}
			else if (!strncmp(&abuf[i], "WIDTHTABLES", 11) || 
			         !strncmp(&abuf[i], "widthtables", 11) ) {
				widthtables = atoi(extract_path(&i, alen));
				if (widthtables)
					fsmsel[WIDTH].ob_state |= CHECKED;
				else 
					fsmsel[WIDTH].ob_state &= ~CHECKED;
				}
#ifndef FSM_CACHE
			else if (!strncmp(&abuf[i], "cache", 5) || 
			         !strncmp(&abuf[i], "CACHE", 5) ) {
				bitcache = atol(extract_path(&i, alen));
				}
#else
			else if (!strncmp(&abuf[i], "bitcache", 8) || 
			         !strncmp(&abuf[i], "BITCACHE", 8) ) {
				bitcache = atol(extract_path(&i, alen));
				}
			else if (!strncmp(&abuf[i], "fsmcache", 8) || 
			         !strncmp(&abuf[i], "FSMCACHE", 8) ) {
				fsmcache = atol(extract_path(&i, alen));
				}
#endif
			while ((abuf[i] != '\n') && (i < alen)) {++i;}	/* Skip to newline */
			++i;
			} while (i < alen);
		} while (alen == 512L);
	Fclose(sys_file);
			
}

void get_bitpath()
{
	int i, sys_file;

	if ((sys_file = Fopen("C:\\ASSIGN.SYS", 0)) < 0) {
		form_alert(1, "[3][Cannot open ASSIGN.SYS][ OK ]");
		sprintf(bitmap_path, "C:\\");
		return;
		}

	fsm_found = FALSE;
	bitmap_found = FALSE;

	do {
		i = 0;
		alen = Fread(sys_file, 512L, abuf);
		do {
			if (!strncmp(&abuf[i], "path", 4) || !strncmp(&abuf[i], "PATH", 4) ) {
				strcpy(bitmap_path, extract_path(&i, alen));
				bitmap_found = TRUE;

				break;
				}
			else {
				while ((abuf[i] != '\n') && (i < alen)) {++i;}	/* Skip to newline */
				++i;
				}
			} while (i < alen);
		} while (alen == 512L);
	Fclose(sys_file);

}

void get_fsmpath()
{
	int i, sys_file;

	if ((sys_file = Fopen("C:\\EXTEND.SYS", 0)) < 0) {
		form_alert(1, "[3][Cannot open EXTEND.SYS][ OK ]");
		sprintf(font_search_path, "C:\\");
		return;
		}

	/* Parse the C:\EXTEND.SYS file */
	do {
		i = 0;
		alen = Fread(sys_file, 512L, abuf);
		do {
			if (!strncmp(&abuf[i], "path", 4) || 
			    !strncmp(&abuf[i], "PATH", 4) ) {
				strcpy(font_search_path, extract_path(&i, alen));
				fsm_found = TRUE;
				}
			while ((abuf[i] != '\n') && (i < alen)) {++i;}	/* Skip to newline */
			++i;
			} while (i < alen);
		} while (alen == 512L);
	Fclose(sys_file);
}

void get_paths()
{

	get_bitpath();
	get_fsmpath();

	return;
}

void show_fonts()
/* show_fonts()
   Simple walk of the font list, using printf to display all the info.
 */
{
	FON_PTR temp_fon = fon_list;
	char temp[80];

	Cconws("Start showing fonts\r\n");
	while (temp_fon != (FON_PTR )NULL) {
		sprintf(temp, "%s\n\r", FNAME(temp_fon)); 
		Cconws(temp);
		temp_fon = FNEXT(temp_fon);
		}
	Cconws("Done showing fonts\r\n");

	return;
}

void alpha_fsm_add(font)
FON_PTR font;
/* alpha_fsm_add(font)
   Add a font name into the FSM font list alphabetically, using strcmp to
   determine where the font should be added.
 */
{
	FON_PTR current = fsm_list;

	if (current == (FON_PTR )NULL) {	/* Add to bare list */
		fsm_list = font;
		fsm_last = font;
		FNEXT(font) = (FON_PTR )NULL;
		FPREV(font) = (FON_PTR )NULL;
		return;
		}

	while( (current != (FON_PTR )NULL) &&
		(strcmp(FNAME(font), FNAME(current)) >= 0) ) {
		current = FNEXT(current);	/* Advance */
		}

	if (current == (FON_PTR )NULL) {	/* Add as last */
		FNEXT(fsm_last) = font;
		FPREV(font) = fsm_last;
		FNEXT(font) = (FON_PTR )NULL;
		fsm_last = font;
		return;
		}

	FPREV(font) = FPREV(current);	/* Take over prev */
	FPREV(current) = font;		/* prev becomes this one */
	FNEXT(font) = current;		/* next is current */
	
	if (FPREV(font) != (FON_PTR )NULL) {
		FNEXT(FPREV(font)) = font;
		}
	if (fsm_list == current) {	/* Insert as first */
		fsm_list = font;
		}

	return;
}

int mangle_cmp(one, two)
char one[], two[];
{
	int first, second;

	first = strncmp(&one[6], &two[6], 2);
	second = strncmp(&one[0], &two[0], 6);

	if (first != 0) return first;
	else return second;
}

void alpha_bit_add(font)
FON_PTR font;
/* alpha_bit_add(font)
   Add a font name into the Bitmap font list alphabetically, using strcmp to
   determine where the font should be added.
 */
{
	FON_PTR current = bit_list;

	if (current == (FON_PTR )NULL) {	/* Add to bare list */
		bit_list = font;
		bit_last = font;
		FNEXT(font) = (FON_PTR )NULL;
		FPREV(font) = (FON_PTR )NULL;
		return;
		}

	while( (current != (FON_PTR )NULL) &&
		(mangle_cmp(FNAME(font), FNAME(current)) >= 0) ) {
		current = FNEXT(current);	/* Advance */
		}

	if (current == (FON_PTR )NULL) {	/* Add as last */
		FNEXT(bit_last) = font;
		FPREV(font) = bit_last;
		FNEXT(font) = (FON_PTR )NULL;
		bit_last = font;
		return;
		}

	FPREV(font) = FPREV(current);	/* Take over prev */
	FPREV(current) = font;		/* prev becomes this one */
	FNEXT(font) = current;		/* next is current */
	
	if (FPREV(font) != (FON_PTR )NULL) {
		FNEXT(FPREV(font)) = font;
		}
	if (bit_list == current) {	/* Insert as first */
		bit_list = font;
		}

	return;
}

int get_all_fsm_fonts()
{
	int fd, i, error;
	char nlen;
	FON_PTR temp_fon;
	char temp[64];
	char fsm_search[80];

	sprintf(fsm_search, "%s\\%s", font_search_path, "*.QFM");

	error = Fsfirst(fsm_search, 0);/* Normal file search for 1st file */
	if (error != E_OK) {		/* No such files! */
		form_alert(1, nofonts);
		return 0;		
		}

	graf_mouse(BUSY_BEE, 0l);
	open_dialog(infrf);		/* Tell user about it */

	do {
		/* Check for symbol, or hebrew, if so, save name */
		/* Otherwise, open file, extract name, close file */
		/* (Save name, also) */

		temp_fon = another_font(FSM_FONT);
		if (temp_fon == (FON_PTR) NULL) {
			form_alert(1, nomem);
			close_dialog();
			return 0;
			}

		sprintf(FFNAME(temp_fon),"%s", (char *)newdma.d_fname);
		sprintf(abuf,"%s\\%s", font_search_path, FFNAME(temp_fon));

		fd = Fopen(abuf, 0);/* Open the file */

		if (fd < 0) {	/* Bad open */
			sprintf(baddata, "[3][Unable to open|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}

		if (Fread(fd, 61l, temp) < 0) {	/* to read the name */
			Fclose(fd);
			sprintf(baddata, "[3][Bad read in|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}

		nlen = temp[60];
		if ((int )nlen > 29) nlen = (char )29;

		if ((int )nlen < 1) {
			Fclose(fd);
			sprintf(baddata, "[3][Bad font name in|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}

		if (Fread(fd, (long )nlen,(char *) FNAME(temp_fon)) < 0) {
			Fclose(fd);
			sprintf(baddata, "[3][Bad font name read in|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}
		Fclose(fd);
		
		for (i = (int )nlen; i < 29; ++i) {
			FNAME(temp_fon)[i] = ' ';
			}
		FNAME(temp_fon)[29] = '\0';

		SEL(temp_fon) = 0L;
		for (i = 0; i < MAX_DEV; ++i)
			DLINK(temp_fon)[i] = (FON_PTR )NULL;

		++fsm_count;			/* Add to fonts */
		alpha_fsm_add(temp_fon);

recover:;
		} while (Fsnext() == E_OK);

	close_dialog();

	for (i = 0; i < 16; ++i) {	/* Blank the defaults */
		fsm_defaults[i] = 0L;
		}
	mouse_arrow();

	return 1;
}

FON_PTR find_font(userstring)
char *userstring;
/* find_font(userstring)
   Given the user's string, attempt to match it to an existing font.
   If matched successfully, return a pointer to the font's structure.
 */
{
	FON_PTR search;
	int i, comp;
	char no_ext[9];

	/* Copies the first 8 characters from the user's string
	   into local buffer, and pads out if less than 8 appear
	   before a '.'.
	 */
	for (i = 0; i < 8; ++i) {
		no_ext[i] = userstring[i];
		/* Pad out with spaces */
		if (no_ext[i] == '.') {
			while (i < 8) {
				no_ext[i++] = ' ';
				}
			}
		}
	no_ext[8] = '\0';

	/* Run through the bitmap fonts list and find the font
	   we've just been passed.  If the font name is ever bigger
	   than the current search name, we have gone too far!
	 */
	search = bit_list;
	for (i = 0; i < bit_count; ++i) {
		comp = mangle_cmp(no_ext, FNAME(search));
		if (comp == 0) {
			return (FON_PTR )search;
			}
		else if (comp < 0) {
			form_alert(1, "[3][Font in ASSIGN.SYS|not found.][ OK ]");
			return (FON_PTR )NULL;
			}
		search = FNEXT(search);
		}
	form_alert(1, "[3][Font in ASSIGN.SYS|not found.][ OK ]");
	return (FON_PTR )NULL;
}

int find_driver(userstring)
char *userstring;
/* find_driver(userstring)
   Given the user's string, attempt to match it to an existing driver.
   If matched successfully, return a pointer to the driver's string.
 */
{
	int i;

	for (i = 0; i < driver_count; ++i) {
		if (strncmp(userstring, drivers[i], strlen(drivers[i])) == 0) {
			return i;
			}
		}
	return 0;
}

int assign_devices()
/* assign_devices()
   Reads the ASSIGN.SYS, and for each device number, it tries to
   associate a driver (in the driver names list) with it.
 */
{
	DEV_PTR temp_device;
	FON_PTR l_fon, t_fon;
	int drv;			/* Driver # */
	int assign, dnum, i, j;		/* Assign.sys file handle */
	char assign_search[80];
	char drvtype;			/* The "rom" "resident" flags */

	font_type = BITMAP_FONT;

	device_count = 0;		/* No devices yet */
	current_device = 0;		/* Current device don't exist */
	temp_device = (DEV_PTR )NULL;	/* No "most recent device" */
	t_fon = (FON_PTR )NULL;		/* No "most recent font" */

	sprintf(assign_search, "C:\\ASSIGN.SYS", bitmap_path);

	/* Open the assign.sys file */
	assign = Fopen(assign_search, 0);

	do {
		if ((alen = read_buffer(assign, 512L, abuf, TRUE)) < 0L) return;

		/* Skip to the next line */
		i = 0;
/*		find_newline(i);
		++i;
*/
		do {
			/* Ensure that we have a complete line to parse */
			/* If we don't, we want to read in the line */
			j = i;
			find_newline(j);

			if (j == alen) {
				strncpy(&abuf[0], &abuf[i], j - i);
				if ((alen = read_buffer(assign, 512L - (j - i), 
						    &abuf[j - i], TRUE)) < 0)
				    return;
				alen += (j - i);
				i = 0;
				j = i;
				find_newline(j);
				}

			if ((abuf[i] >= '0') && (abuf[i] <= '9')) {
				/* We've got a device */
				/* Go find it's name in the list */

				dnum = atoi(&abuf[i]);

				while (!kisspace(abuf[i])) {++i;}
				if ((abuf[i - 1] < '0') || (abuf[i - 1] > '9')) {
					drvtype = abuf[i - 1];
					}
				else {
					drvtype = ' ';
					}
				while (kisspace(abuf[i])) {++i;}

				j = i;
				find_newline(j);
				abuf[j] = '\0';

				if ( ((drv = find_driver(&abuf[i])) != 0) ||
				     ((dnum < 11) && (dnum > 0)) ){

					/* Screen devices are automagic */
					if ((dnum > 0) && (dnum < 11)) {
						drv = 0;
						}

					temp_device = &devices[device_count];
					current_device = device_count++;
					DNAME(temp_device) = drv;

					/* Set the fonts list to NULL */
					DFONT(temp_device) = (FON_PTR )NULL;
					DTFONT(temp_device) = (FON_PTR )NULL;
					DFCOUNT(temp_device) = 0;
					DDEV(temp_device) = dnum;
					DTYPE(temp_device) = drvtype;

					/* Now we need to load all the
					   associated fonts, i.e. create
					   the linked list of fonts 
					 */
					t_fon = (FON_PTR )NULL;
					l_fon = (FON_PTR )NULL;
					}

				i = j + 1;
				}
			else if ((temp_device != (DEV_PTR )NULL) &&
				 (abuf[i] != ';')) {
				/* If we've seen a device, and this is not
				   a comment, then it must be a font.  We
				   should also be able to find this in our
				   current font list
				*/
				t_fon = find_font(&abuf[i]);

				/* Put it into the font links as first */
				if ((t_fon != (FON_PTR )NULL) && 
				    (l_fon == (FON_PTR )NULL)) {
					SEL(t_fon) = set_sel(SEL(t_fon));
					DFONT(temp_device) = t_fon;
					DTFONT(temp_device) = t_fon;
					DFCOUNT(temp_device) = 1;
					DTOP(temp_device) = 0;
					l_fon = t_fon;
					}
				/* Put into the font links as last */
				else if (t_fon != (FON_PTR )NULL) {
					DFCOUNT(temp_device) += 1;
					SEL(t_fon) = set_sel(SEL(t_fon));
					DLINK(l_fon)[current_device] = t_fon;
					l_fon = t_fon;
					}

				find_newline(i);
				++i;
				}
			else {
				find_newline(i);
				++i;
				}
			} while (i < alen);
		} while (alen == 512L);
	Fclose(assign);

	/* Set the current device to the first one we saw */
	current_device = 0;
}

int get_drivers()
/* get_drivers()
   Goes into the GDOS directory (pointed to by the ASSIGN.SYS) and
   finds all the drivers (*.SYS).  Inserts those driver names into
   an array of names (MAX_DRIVERS drivers).   The ASSIGN.SYS can then
   be parsed to link devices with drivers.
 */
{
	int i, error;
	char driver_search[80];

	sprintf(driver_search, "%s\\%s", bitmap_path, "*.SYS");

	error = Fsfirst(driver_search, 0);/* Normal file search for 1st file */
	if (error != E_OK) {		/* No such files! */
		form_alert(1, nodrivers);
		return FALSE;
		}

	strcpy(drivers[0], "SCREEN.SYS", 14);	/* Screen driver is ROM */
	driver_count = 1;
	do {
		/* Grab the name out of the DTA structure */
		strncpy(drivers[driver_count], (char *)newdma.d_fname, 14);
		for (i = 0; i < 12; ++i) {
			if (drivers[driver_count][i] == '.') {
				drivers[driver_count][i + 4] = '\0';
				}
			}
		driver_count++;
		} while ((Fsnext() == E_OK) && (driver_count < MAX_DRIVERS));

	return TRUE;
}

int get_all_bitmap_fonts()
{
	int i, fd, error;
	FON_PTR temp_fon;
	char temp[37];
	char gdos_search[80];

	sprintf(gdos_search, "%s\\%s", bitmap_path, "*.FNT");

	error = Fsfirst(gdos_search, 0);/* Normal file search for 1st file */
	if (error != E_OK) {		/* No such files! */
		form_alert(1, nofonts);
		return 0;
		}

	graf_mouse(BUSY_BEE, 0L);
	open_dialog(infrbit);		/* Tell user about it */

	do {
		/* Check for symbol, or hebrew, if so, save name */
		/* Otherwise, open file, extract name, close file */
		/* (Save name, also) */

		temp_fon = another_font(BITMAP_FONT);
		if (temp_fon == (FON_PTR) NULL) {
			form_alert(1, nomem);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}
		strncpy(FFNAME(temp_fon), (char *)newdma.d_fname, 14);
		for (i = 0; i < 12; ++i) {
			if (FFNAME(temp_fon)[i] == '.') {
				FFNAME(temp_fon)[i + 4] = '\0';
				}
			}
		strncpy(FNAME(temp_fon), FFNAME(temp_fon), 14);
		/* Ensure that all 'names' are the same length */
		FNAME(temp_fon)[strlen(FNAME(temp_fon)) - 4] = '\0';
		for (i = strlen(FNAME(temp_fon)); i < 9; ++i) {
			FNAME(temp_fon)[i] = ' ';
			}
		FNAME(temp_fon)[i] = '\0';
		FSIZE(temp_fon) = newdma.d_fsize;

		sprintf(abuf,"%s\\%s", bitmap_path, FFNAME(temp_fon));

		if ((fd = Fopen(abuf, 0)) < 0) {	/* Bad open */
			sprintf(baddata, "[3][Unable to open|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}

		/* Read in first four bytes as well... */
		if (Fread(fd, 36L, temp) < 0) {
			Fclose(fd);
			sprintf(baddata, "[3][Bad font name read in|%s.|Font not used.][ OK ]", FFNAME(temp_fon));
			form_alert(1, baddata);
/*			close_dialog();
			return 0;
*/
			goto recover;
			}
		Fclose(fd);

		/* Get rid of 1st 4 bytes */
		strncpy(&temp[0], &temp[4], 32);
	
		if ((strlen(FNAME(temp_fon)) + 2 + strlen(temp)) > 29) {
			temp[29 - (strlen(FNAME(temp_fon)) + 2)] = '\0';
			}
		strcat(FNAME(temp_fon), "(");
		strcat(FNAME(temp_fon), temp);
		strcat(FNAME(temp_fon), ")");

		if (strlen(FNAME(temp_fon)) < 29) {
			for (i = strlen(FNAME(temp_fon)); i < 29; ++i) {
				FNAME(temp_fon)[i] = ' ';
				}
			FNAME(temp_fon)[29] = '\0';
			}

		SEL(temp_fon) = 0L;
		++bit_count;			/* Add to fonts */
		alpha_bit_add(temp_fon);

recover:;

	} while (Fsnext() == E_OK);

	mouse_arrow();

	get_drivers();
	assign_devices();

	close_dialog();

	return 1;
}

int read_fonts()
/* read_fonts()
   Calls the FSM and Bitmap routines to find all available fonts and
   insert them into the appropriate list.

   Returns a 0 on file error.
 */
{
	int prev;

	fon_list = (FON_PTR )NULL;	/* Empty lists to begin with */
	fsm_list = (FON_PTR )NULL;
	bit_list = (FON_PTR )NULL;

	fon_count = 0;			/* No fonts to begin with */
	fsm_count = 0;
	bit_count = 0;

	olddma = (DMABUFFER *)Fgetdta();	
	Fsetdta(&newdma);		/* Point to OUR buffer */

	if (fsm_found) {
		if (!get_all_fsm_fonts()) {
			}
		else {
			prev = 0;
			}
		parse_extend();
		}
	if (bitmap_found) {
		if (!get_all_bitmap_fonts()) {
			}
		}

	Fsetdta(olddma);		/* Point to OLD buffer */

	return 1;
}

void output_header(new_assign)
int new_assign;
{
	char line_buf[80];
	long time;

	sprintf(line_buf, ";> ASSIGN.SYS Created with FONTMAN Copyright 1990 Atari Corp.\r\n");
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";> For use with GDOS 1.1 and higher.\r\n");
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";> Comments other than these first lines were preserved\r\n");
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";> from the original ASSIGN.SYS and may be invalid.\r\n");
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);

	time = Gettime();
	sprintf(line_buf, ";> Last modified on %d/%d/%d %02d:%02d\r\n", 
		(int )((time >> 21) & 0x0F),
		(int )((time >> 16) & 0x1F),
		(int )(((time >> 25) & 0x7F) + 1980),
		(int )((time >> 11) & 0x1F),
		(int )((time >> 5) & 0x3F) );
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";>\r\n");
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);

	return;
}

int old_idx;		/* Index into old ASSIGN.SYS */

int get_complete_line(file, index)
int file;
int *index;
{
	int j;

	j = *index;
	if (j >= alen) return -1;	/* Gone too far! */

	find_newline(j);

	/* Ensure that we have a complete line in the buffer */
	if (j == 512L) {
		strncpy(&abuf[0], &abuf[*index], j - *index);
		if ((alen = read_buffer(file, 
		     512L - (j - *index), 
		     &abuf[j - *index]), FALSE) < 0) {
			Fclose(file);
			*index = -1;
			return -1;
			}
		alen += (j - *index);
		*index = 0;
		}

	return alen;
}

void skip_fontman_header(old_assign)
int old_assign;
/*  skip_fontman_header(old_assign)
    Reads buffer loads until through the FONTMAN generate header.
 */
{
	if (old_idx < 0) return;	/* Nothing more to be read */

	if ((alen = read_buffer(old_assign, 512L, &abuf[0], FALSE)) < 0) {
		Fclose(old_assign);
		old_idx = -1;		/* Stopped */
		return;
		}
	else old_idx = 0;		/* Start it at top */

	do {
		/* Ensure that we have a complete line to parse */
		/* If we don't, we want to read in the line */
		if (get_complete_line(old_assign, &old_idx) < 0) {
			return;
			}
		/* If we've got a FONTMAN comment, skip it */
		if ((abuf[old_idx] == ';') && (abuf[old_idx + 1] == '>')) {
			find_newline(old_idx);
			old_idx++;
			}
		else {
			/* Anything but a special comment returns us */
			return;
			}
		} while (TRUE);
}

int output_old_header(old_assign, new_assign)
int old_assign, new_assign;
/* output_old_header(old_assign, new_assign)
   Takes all the comments that begin the old ASSIGN.SYS (not FONTMAN comments)
   and transfers them to the new ASSIGN.SYS.
 */
{
	int j;

	if (old_idx < 0) return;

	do {
		/* Ensure that we have a complete line to parse */
		/* If we don't, we want to read in the line */
		if (get_complete_line(old_assign, &old_idx) < 0) {
			return -1;
			}

		/* If we've got a comment, write it out! */
		if (abuf[old_idx] == ';') {
			j = old_idx;
			find_newline(j);
			Fwrite(new_assign, (long )(j - old_idx + 1), 
			       &abuf[old_idx]);

			old_idx = j + 1;
			}
		else {
			/* Anything but a comment returns us */
			return 0;
			}
		} while (TRUE);
}

int comments_until_device(old_assign, new_assign)
int old_assign, new_assign;
/* comments_until_device(old_assign, new_assign)
   Takes all the comments from the old ASSIGN.SYS until a device number 
   is encountered and transfers them to the new ASSIGN.SYS.
 */
{
	int j;
	int the_dev;

	if (old_idx < 0) return -1;

	do {
		/* Ensure that we have a complete line to parse */
		/* If we don't, we want to read in the line */
		if (get_complete_line(old_assign, &old_idx) < 0) {
			return -1;
			}

		/* If we've got a comment, write it out! */
		if (abuf[old_idx] == ';') {
			j = old_idx;
			find_newline(j);
			Fwrite(new_assign, (long )(j - old_idx + 1), 
			       &abuf[old_idx]);

			old_idx = j + 1;
			}
		else if ((abuf[old_idx] >= '0') && (abuf[old_idx] <= '9')) {
			/* Device # returns us */
			the_dev = atoi(&abuf[old_idx]);
			find_newline(old_idx);
			old_idx++;

			return the_dev;
			}
		else {
			/* Advance to the next line */
			find_newline(old_idx);
			old_idx++;
			}
		} while (TRUE);
}

void write_device(device, idx, new_assign)
DEV_PTR device;
int idx;
int new_assign;
{
	FON_PTR t_fon;
	char line_buf[80];

	/* Write out the device number, type, and driver name */
	sprintf(line_buf, "%d%c %s\r\n\0", DDEV(device), DTYPE(device),
		drivers[DNAME(device)]);
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);
		
	/* Write out all the associated fonts */
	t_fon = DFONT(device);
	while (t_fon != (FON_PTR )NULL) {
		sprintf(line_buf, "%s\r\n\0", FFNAME(t_fon));
		Fwrite(new_assign, (long )strlen(line_buf), line_buf);

		t_fon = DLINK(t_fon)[idx];	/* Next font! */
		}
}

void write_pointsizes(font, new_extend)
FON_PTR font;
int new_extend;
{
	int i, idx;
	long already_set;
	char line_buf[80];

	for (i = 0, already_set = 0L; i < 16; ++i) {
		already_set |= (long )DLINK(font)[i];
		}

	if (already_set == 0L) {
		/* Write out default point sizes */
		for (i = 0; (i < 16) && (fsm_defaults[i] != 0L); ++i) {
			if (i != 0) sprintf(line_buf, ",%ld", fsm_defaults[i]);
			else sprintf(line_buf, "%ld", fsm_defaults[i]);
			Fwrite(new_extend, (long )strlen(line_buf), line_buf);
			}
		}
	else {
		/* Write out point sizes */
		for (i = 0, idx = 0; i < 16; ++i) {
			if ((long )DLINK(font)[i] != 0L) {
				if (idx != 0) sprintf(line_buf, ",%ld", (long )DLINK(font)[i]);
				else sprintf(line_buf, "%ld", (long )DLINK(font)[i]);
				Fwrite(new_extend, (long )strlen(line_buf), line_buf);
				++idx;
				}
			}
		}
}

void write_extend()
/* write_extend()
   Responsible for outputting a new EXTEND.SYS over the old (or
   nonexistent one.
   As of March 9, 1990:
	c:\extend.sys format consists of:
	for all devices:

	CACHE = {bitmap cache only}
	FONT = blah.hdr
	FILES = blah.qfm
	POINTS = 12, 14, 16
 */
{
	FON_PTR fsmfonts;
	int new_extend;
	int j;
	char line_buf[80];
	long time;

	if ((new_extend = Fcreate("C:\\EXTEND.SYS", 0)) < 0) {
		form_alert(1, "[3][Error opening|EXTEND.SYS file.|Nothing written.][ OK ]");
		return;
		}

	sprintf(line_buf, ";\r\n");
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, "; FSM Configuration File\r\n");
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	time = Gettime();
	sprintf(line_buf, "; Last modified on %d/%d/%d %02d:%02d\r\n", 
		(int )((time >> 21) & 0x0F),
		(int )((time >> 16) & 0x1F),
		(int )(((time >> 25) & 0x7F) + 1980),
		(int )((time >> 11) & 0x1F),
		(int )((time >> 5) & 0x3F) );
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
	sprintf(line_buf, ";\r\n");
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write the path to the fonts */
	sprintf(line_buf, "PATH = %s\r\n", font_search_path);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

#ifdef FSM_CACHE
	/* Write out how big the bitmap cache is gonna be */
	sprintf(line_buf, "BITCACHE = %ld\r\n", bitcache);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	/* Write out how big the outline fonts cache is gonna be */
	sprintf(line_buf, "FSMCACHE = %ld\r\n", fsmcache);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
#else
	/* Write out how big the bitmap cache is gonna be */
	sprintf(line_buf, "CACHE = %ld\r\n", bitcache);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);
#endif
	if (fsmsel[WIDTH].ob_state & CHECKED) widthtables = 1;
	else widthtables = 0;

	/* Write out if we pre-generate a width table */
	sprintf(line_buf, "WIDTHTABLES = %d\r\n", widthtables);
	Fwrite(new_extend, (long )strlen(line_buf), line_buf);

	fsmfonts = fsm_list;
	while (fsmfonts != (FON_PTR )NULL) {
		if (SEL(fsmfonts)) {
#ifdef NEVER
			sprintf(line_buf, "FONT = %s", FFNAME(fsmfonts));
			j = 0;
			while(line_buf[j] != '.') {++j;}
			strncpy(&line_buf[++j], "HDR\r\n\0", 6);
			Fwrite(new_extend, (long )strlen(line_buf), line_buf);
#endif
			sprintf(line_buf, "FILES = %s\r\n", FFNAME(fsmfonts));
			Fwrite(new_extend, (long )strlen(line_buf), line_buf);

			sprintf(line_buf, "POINTS =");
			Fwrite(new_extend, (long )strlen(line_buf), line_buf);
			write_pointsizes(fsmfonts, new_extend);
			sprintf(line_buf, "\r\n");
			Fwrite(new_extend, (long )strlen(line_buf), line_buf);
			}
		fsmfonts = FNEXT(fsmfonts);
		}

	Fclose(new_extend);
}

void write_assign()
/* write_assign()
   Writes the ASSIGN.SYS file out with the current device and font
   information.  Preserves all the old comments in the position.
 */
{
	DEV_PTR device;
	char line_buf[80];
	int i, new_assign, old_assign;
	int the_dev;		/* user's ASSIGN.SYS dev# we've seen! */
	int dev_done[32];	/* Device was done! */

	if ((new_assign = Fcreate("C:\\ASSIGN.KEN", 0)) < 0) {
		form_alert(1, "[3][Error opening temporary|ASSIGN.SYS file.|Nothing written.][ OK ]");
		return;
		}
	if ((old_assign = Fopen("C:\\ASSIGN.SYS", 0)) < 0) {
		old_idx = -1;	/* Show no assign.sys */
		}
	else skip_fontman_header(old_assign);

	mouse_busy();

	/* Output commentary at the beginning */
	output_header(new_assign);

	/* Copy any previously leading comments to the new assign */
	output_old_header(old_assign, new_assign);
	/* Now output the path */
	sprintf(line_buf, "PATH = %s\r\n", bitmap_path);
	Fwrite(new_assign, (long )strlen(line_buf), line_buf);

	/* For all devices, output the device #, driver, and fonts */
	for (i = 0; i < device_count; ++i) { dev_done[i] = FALSE; }

	/* For each device originally in the ASSIGN.SYS, output the
	   new (if any) driver and fonts 
	 */
	while(((the_dev = comments_until_device(old_assign, new_assign)) >= 0)){
		for (i = 0; i < device_count; ++i) {
			device = &devices[i];	/* Grab pointer to device */

			if (DDEV(device) == the_dev) {
				dev_done[i] = TRUE;
				write_device(device, i, new_assign);
				}
			}
		}

	/* Then, for any remaining devices, the drivers, and fonts, output
	   those after the original's
	 */
	for (i = 0; i < device_count; ++i) {
		if (dev_done[i] == FALSE) {
			device = &devices[i];	/* Grab pointer to device */
			write_device(device, i, new_assign);
			}
		}

	Fclose(new_assign);
	if (old_idx >= 0) Fclose(old_assign);

	/* Now delete the original ASSIGN.SYS, and move the ASSIGN.KEN
	   to ASSIGN.SYS
	 */
	Fdelete("C:\\ASSIGN.SYS");
	Frename(0, "C:\\ASSIGN.KEN", "C:\\ASSIGN.SYS");

	mouse_arrow();

	return;
}
