/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	JOURNAL.H
 *
 */

extern M_S jmen;
void init_jrnl(COPRMSG *init_text, DIALFI find, short full);
BUTTON	jrnl_button;
void con_input(IT *w,short task,short stage,char *msg, char *prompt, char *deflt,
       CON_RET *ret_action,CON_RET *undo_action);
void con_end(bool top);
void send_msg (char *, ...);
void send_msg_n(char *, ...);	/* does not top the journal */
void store_msg(char *, ...);	/* just store msg in journal text chain */
void console(Cstr text, ...);
void wcons  (Cstr text, ...);		/* console + wait */
void load_scrap(IT *w);
void dump_scrap(short);		/* for testing */

COPRM do_init_text;
void open_clicked_file(Cstr fn, short linenr);
