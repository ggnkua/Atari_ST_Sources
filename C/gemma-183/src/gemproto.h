/* Prototypes for internal GEM calls */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

void gemsys(long sysopcode, long *params);
# define gemsys(a, b)	asm( "move.l %0,d0; move.l %1,d1; trap #2" ::"r"(a),"r"(b):"d0","d1" );

/* AES */

# define _appl_init(p) call_aes(p->base, 1L, 2, p, 10)
# define _appl_exit(p) call_aes(p->base, 1L, 2, p, 19)
long _appl_control(PROC_ARRAY *proc, short opcode, void *out);
long _appl_find(PROC_ARRAY *proc, char *name);
long _appl_getinfo(PROC_ARRAY *proc, short fn, short *out);
long _appl_write(PROC_ARRAY *proc, short id, short len, short *buf);
long _evnt_multi(PROC_ARRAY *proc, short fl, short cl, short mask, short state, \
			short m1f, short m1x, short m1y, short m1w, short m1h, \
			short m2f, short m2x, short m2y, short m2w, short m2h, \
			short *msg, unsigned long timer);
long _evnt_timer(PROC_ARRAY *proc, unsigned long msec);
long _fsel_exinput(PROC_ARRAY *proc, char *path, char *name, char *title);
long _form_alert(PROC_ARRAY *proc, short b, char *msg);
long _form_button(PROC_ARRAY *proc, OBJECT *tree, short obj, short clk);
long _form_dial(PROC_ARRAY *proc, short flag, short *dxywh, short *cxywh);
long _form_keybd(PROC_ARRAY *proc, OBJECT *tree, short obj, short nobj, short tch);
# define _graf_handle(p) call_aes(p->base, 1L, 2, p, 77)
# define _graf_mkstate(p) call_aes(p->base, 1L, 2, p, 79)
long _graf_mouse(PROC_ARRAY *proc, short num, void *addr);
long _graf_movebox(PROC_ARRAY *proc, short mx, short my, short sx, short sy, short dx, short dy);
long _graf_growbox(PROC_ARRAY *proc, short sx, short sy, short mw, short mh, short *xywh);
long _graf_shrinkbox(PROC_ARRAY *proc, short sx, short sy, short mw, short mh, short *xywh);
long _menu_popup(PROC_ARRAY *proc, MENU *m1, short x, short y, MENU *m2);
long _menu_register(PROC_ARRAY *proc, short id, char *name);
long _objc_draw(PROC_ARRAY *proc, OBJECT *tree, short ob, short dp, short *xywh);
long _objc_change(PROC_ARRAY *proc, OBJECT *tree, short ob, short *xywh, short nw, short rd);
long _objc_edit(PROC_ARRAY *proc, OBJECT *tree, short startob, short key, short idx, short mode);
long _objc_find(PROC_ARRAY *proc, OBJECT *tree, short ob, short depth, short mx, short my);
long _objc_offset(PROC_ARRAY *proc, OBJECT *tree, short obj);
long _rsrc_rcfix(PROC_ARRAY *proc, char *buf);
long _rsrc_load(PROC_ARRAY *proc, char *name);
# define _rsrc_free(p) call_aes(p->base, 1L, 2, p, 111)
long _shel_help(PROC_ARRAY *proc, short mode, char *file, char *key);
long _shel_write(PROC_ARRAY *proc, short msg, short wg, short ws, char *name, char *env);
long _wind_get(PROC_ARRAY *proc, short w, short fn);
long _wind_set(PROC_ARRAY *proc, short w, short fn);
long _wind_calc(PROC_ARRAY *proc, short fn, short gd, short *xywh);
long _wind_create(PROC_ARRAY *proc, short gagdets, short *xywh);
long _wind_open(PROC_ARRAY *proc, short handle, short *xywh);
long _wind_close(PROC_ARRAY *proc, short handle);
long _wind_delete(PROC_ARRAY *proc, short handle);
long _wind_find(PROC_ARRAY *proc, short mx, short my);
long _wind_update(PROC_ARRAY *proc, short mode);

/* EOF */
