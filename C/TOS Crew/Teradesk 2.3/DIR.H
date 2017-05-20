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

void dir_init(void);
void dir_default(void);

int dir_load(XFILE *file);
int dir_save(XFILE *file);
int dir_load_window(XFILE *file);
int dir_save_window(XFILE *file, WINDOW *w);

/* boolean dir_add_window(const char *path); DjV 017 280103 */
boolean dir_add_window(const char *path, const char *name); /* DjV 017 280103 */
void dir_close(WINDOW *w, int mode);

void dir_setfont(void);
const char *dir_path(WINDOW *w);		/* DjV 031 070203 */
void get_dir_line(WINDOW *dw, char *s, int item); /* DjV 029 120203 */
void dir_always_update (WINDOW *w); /* DjV 029 160203 */
