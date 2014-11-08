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

boolean item_copy(WINDOW *dw, int dobject, WINDOW *sw, int n,
				  int *list, int kstate);

/* DjV 031 070203 ---vvv--- */
#define CMD_COPY	 0
#define CMD_MOVE	 1
#define CMD_DELETE	 2
#define CMD_PRINT    3
#define CMD_PRINTDIR 4 /* for future development */

extern boolean cfdial_open;

int open_cfdialog(int mask, long folders, long files, long bytes, int function);
void close_cfdialog(int button);
void upd_copyinfo(long folders, long files, long bytes);
void upd_name(const char *name, int item);
boolean count_items(WINDOW *w, int n, int *list, long *folders,
						   long *files, long *bytes);
int copy_error(int error, const char *name, int function);
/* DjV 031 070203 ---^^^--- */

boolean itm_delete(WINDOW *w, int n, int *list);
