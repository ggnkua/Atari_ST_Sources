/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* Windowtypes voor xw_create(). */

#define DESK_WIND		16
#define DIR_WIND		17
#define TEXT_WIND		18

/* definities voor itm_info */

#define ITM_PATHSIZE	1		/* lengte pad */
#define ITM_NAMESIZE	2		/* lengte naam */
#define ITM_FNAMESIZE	3		/* lengte van volledige naam */

/* Interne variabelen item windows. */

#define ITM_INTVARS		XW_INTVARS;			/* Interne variabelen bibliotheek. */	\
						ITMFUNC *itm_func	/* Item functions. */

/* Icon en item types */

typedef enum
{
	ITM_NOTUSED = 0,			/* niet gebruikt */
	ITM_DRIVE,
	ITM_TRASH,
	ITM_PRINTER,
	ITM_FOLDER,
	ITM_PROGRAM,
	ITM_FILE,
	ITM_PREVDIR
} ITMTYPE;

/* Update type */

typedef enum
{
	WD_UPD_DELETED,
	WD_UPD_COPIED,
	WD_UPD_MOVED,
	WD_UPD_ALLWAYS
} wd_upd_type;

typedef struct
{
	int (*itm_find) (WINDOW *w, int x, int y);
	boolean (*itm_state) (WINDOW *w, int item);
	ITMTYPE (*itm_type) (WINDOW *w, int item);
	int (*itm_icon) (WINDOW *w, int item);
	const char *(*itm_name) (WINDOW *w, int item);
	char *(*itm_fullname) (WINDOW *w, int item);
	int (*itm_attrib) (WINDOW *w, int item, int mode, XATTR *attr);
	long (*itm_info) (WINDOW *w, int item, int which);

	boolean (*itm_open) (WINDOW *w, int item, int kstate);
	boolean (*itm_copy) (WINDOW *dw, int dobject, WINDOW *sw,
	        int n, int *list, ICND *icns, int x, int y, int kstate);
	void (*itm_showinfo) (WINDOW *w, int n, int *list, int search);	/* DjV 017 150103 */

	void (*itm_select) (WINDOW *w, int selected, int mode, boolean draw);
	void (*itm_rselect) (WINDOW *w, int x, int y);
	boolean (*itm_xlist) (WINDOW *w, int *ns, int *nv, int **list, ICND **icns, int mx, int my);
	boolean (*itm_list) (WINDOW *w, int *n, int **list);

	const char *(*wd_path) (WINDOW *w);

	/* Funkties voor het verversen van de inhoud van een window */

	void (*wd_set_update) (WINDOW *w, wd_upd_type type, const char *fname1, const char *fname2);
	void (*wd_do_update) (WINDOW *w);

	/* Funkties die aangeroepen worden als filetype of sorteer methode worden gezet. */

	void (*wd_filemask) (WINDOW *w);
	void (*wd_newfolder) (WINDOW *w);
	void (*wd_disp_mode) (WINDOW *w, int mode);	/* 0 = text, 1 = icons */
	void (*wd_sort) (WINDOW *w, int sort);		/* 0 = name, 1 = extension, 2 = date, 3 = size, 4 = unsorted */
/*	void (*wd_attrib) (WINDOW *w, int attribs);	   bit 1 - hidden, bit 2 - system */
	void (*wd_fields) (WINDOW *w, int fields);	/* DjV 010 261202 bits 0:3=show size,date,time,attr. */
	void (*wd_seticons) (WINDOW *w);
} ITMFUNC;

/* DjV 017 280103 ---vvv--- */
typedef struct
{
	WINDOW *w;
	int selected;
	int n;
} SEL_INFO;
/* DJV 017 280103 ---^^^--- */

int itm_find(WINDOW *w, int x, int y);
boolean itm_state(WINDOW *w, int item);
ITMTYPE itm_type(WINDOW *w, int item);
int itm_icon(WINDOW *w, int item);
const char *itm_name(WINDOW *w, int item);
char *itm_fullname(WINDOW *w, int item);
int itm_attrib(WINDOW *w, int item, int mode, XATTR *attrib);
long itm_info(WINDOW *w, int item, int which);
boolean itm_open(WINDOW *w, int item, int kstate);

void itm_select(WINDOW *w, int selected, int mode, boolean draw);
void itm_rselect(WINDOW *w, int x, int y);
boolean itm_xlist(WINDOW *w, int *ns, int *nv, int **list, ICND **icns, int mx, int my);
boolean itm_list(WINDOW *w, int *n, int **list);
void itm_set_menu ( WINDOW *w ); /* DjV 017 290103 */

void wd_set_update(wd_upd_type type, const char *name1, const char *name2);
void wd_do_update(void);
void wd_update_drv(int drive);

void wd_hndlbutton(WINDOW *w, int x, int y, int n, int button_state,
				   int keystate);
const char *wd_path(WINDOW *w);
const char *wd_toppath(void);
void wd_seticons(void);

/* Funkties voor het opvragen van informatie over geselekteerde objecten. */

WINDOW *wd_selected_wd(void);
int wd_nselected(void);
int wd_selected(void);
void wd_reset(WINDOW *w);
void wd_deselect_all(void);
/* void wd_attrib(void);			 HR 230103, HR 050303 */
void wd_fields(void);				/* HR 050303 */
void wd_del_all(void);
void wd_hndlmenu(int item, int keystate);

void wd_init(void);
void wd_default(void);
int wd_load(XFILE *file);
int wd_save(XFILE *file);

boolean wd_tmpcls(void);
void wd_reopen(void);
