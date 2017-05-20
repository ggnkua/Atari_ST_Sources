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

typedef struct ftype
{
	SNAME filetype;				/* HR 240203 */
	struct ftype *prev;
	struct ftype *next;
} FTYPE;

typedef struct appl
{
	const char *name;
	const char *cmdline;
	ApplType appltype;
	boolean path;
	int fkey;
	boolean argv;
	FTYPE *filetypes;
	struct appl *prev;
	struct appl *next;
} APPLINFO;

void app_init(void);
void app_default(void);
int app_load(XFILE *file);
int app_save(XFILE *file);

void app_install(void);
APPLINFO *app_find(const char *file);
APPLINFO *find_fkey(int fkey);
boolean app_exec(const char *program, APPLINFO *appl, WINDOW *w, int *sellist, int n, int kstate, boolean dragged);

void app_update(wd_upd_type type, const char *fname1, const char *fname2);
