/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _TASKMAN_H_
#define _TASKMAN_H_

extern
XA_WINDOW *task_man_win;

void open_taskmanager	(LOCK lock, bool shutdown);
void do_system_menu		(LOCK lock, int clicked_title, int menu_item);
void refresh_tasklist	(LOCK lock);
void update_tasklist	(LOCK lock);
void shutdown			(LOCK lock);
void *pendig_alerts		(OBJECT *form, int item);

#endif
