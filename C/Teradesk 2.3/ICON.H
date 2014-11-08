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

#define ICON_W		80
#define ICON_H		46

extern OBJECT *icons;	/* HR 151202: use rsrc_load for icons. */
extern int n_icons;
extern OBJECT *desktop;
extern WD_FUNC icn_functions;
extern WINDOW *desk_window;
extern SNAME iname; /* DjV 024 140103 HR 240203 */

boolean dsk_init(void);
int dsk_load(XFILE *file);
int dsk_save(XFILE *file);
void dsk_default(void);
void dsk_close(void);

void dsk_insticon(void);
void dsk_remicon(void);
void dsk_chngicon(void);

void dsk_draw(void);

void dsk_options(void);

boolean load_icons(void);
void free_icons(void);

void remove_icon(int object, boolean draw);

int rsrc_icon(const char *name);		/* HR 151102 */

int rsrc_icon_rscid(int id, char *name );	/* DjV 024 140103 */
