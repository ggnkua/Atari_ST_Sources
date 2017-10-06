/* Internal bindings for AES functions */

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

# include "gemma.h"
# include "gemproto.h"
# include "user.h"

long
_appl_control(PROC_ARRAY *proc, short opcode, void *out)
{
	proc->gem.int_in[0] = proc->gem.global[2];	/* apid */
	proc->gem.int_in[1] = opcode;
	proc->gem.addr_in[0] = (long)out;

	return call_aes(proc->base, 1L, 2, proc, 129);
}

long
_appl_find(PROC_ARRAY *proc, char *name)
{
	proc->gem.addr_in[0] = (long)name;

	return call_aes(proc->base, 1L, 2, proc, 13);
}

long
_appl_getinfo(PROC_ARRAY *proc, short fn, short *out)
{
	long r;

	proc->gem.int_in[0] = fn;

	r = call_aes(proc->base, 1L, 2, proc, 130);

	out[0] = proc->gem.int_out[1];
	out[1] = proc->gem.int_out[2];
	out[2] = proc->gem.int_out[3];
	out[3] = proc->gem.int_out[4];

	return r;
}

long
_appl_write(PROC_ARRAY *proc, short id, short len, short *buf)
{
	proc->gem.int_in[0] = id;
	proc->gem.int_in[1] = len;
	proc->gem.addr_in[0] = (long)buf;

	return call_aes(proc->base, 1L, 2, proc, 12);
}

long
_evnt_multi(PROC_ARRAY *proc, short fl, short cl, short mask, short state, \
			short m1f, short m1x, short m1y, short m1w, short m1h, \
			short m2f, short m2x, short m2y, short m2w, short m2h, \
			short *msg, unsigned long timer)
{
	proc->gem.int_in[0] = fl;
	proc->gem.int_in[1] = cl;
	proc->gem.int_in[2] = mask;
	proc->gem.int_in[3] = state;
	proc->gem.int_in[4] = m1f;
	proc->gem.int_in[5] = m1x;
	proc->gem.int_in[6] = m1y;
	proc->gem.int_in[7] = m1w;
	proc->gem.int_in[8] = m1h;
	proc->gem.int_in[9] = m2f;
	proc->gem.int_in[10] = m2x;
	proc->gem.int_in[11] = m2y;
	proc->gem.int_in[12] = m2w;
	proc->gem.int_in[13] = m2h;
	proc->gem.int_in[14] = (short)timer;
	proc->gem.int_in[15] = (short)(timer>>16);

	proc->gem.addr_in[0] = (long)msg;

	return call_aes(proc->base, 1L, 2, proc, 25);
}

long
_evnt_timer(PROC_ARRAY *proc, unsigned long timer)
{
	proc->gem.int_in[0] = (short)timer;
	proc->gem.int_in[1] = timer>>16;

	return call_aes(proc->base, 1L, 2, proc, 24);
}

long
_fsel_exinput(PROC_ARRAY *proc, char *path, char *name, char *title)
{
	proc->gem.addr_in[0] = (long)path;
	proc->gem.addr_in[1] = (long)name;
	proc->gem.addr_in[2] = (long)title;

	if (call_aes(proc->base, 1L, 2, proc, 91) > 0)
		return (long)proc->gem.int_out[1];

	return 0;
}

long
_form_alert(PROC_ARRAY *proc, short button, char *msg)
{
	proc->gem.int_in[0] = button;
	proc->gem.addr_in[0] = (long)msg;

	return call_aes(proc->base, 1L, 2, proc, 52);
}

long
_form_button(PROC_ARRAY *proc, OBJECT *tree, short obj, short clk)
{
	proc->gem.int_in[0] = obj;
	proc->gem.int_in[1] = clk;
	proc->gem.addr_in[0] = (long)tree;

	return call_aes(proc->base, 1L, 2, proc, 56);
}

long
_form_dial(PROC_ARRAY *proc, short flag, short *dxywh, short *cxywh)
{
	proc->gem.int_in[0] = flag;
	proc->gem.int_in[1] = dxywh[0];
	proc->gem.int_in[2] = dxywh[1];
	proc->gem.int_in[3] = dxywh[2];
	proc->gem.int_in[4] = dxywh[3];
	proc->gem.int_in[5] = cxywh[0];
	proc->gem.int_in[6] = cxywh[1];
	proc->gem.int_in[7] = cxywh[2];
	proc->gem.int_in[8] = cxywh[3];

	return call_aes(proc->base, 1L, 2, proc, 51);
}

long
_form_keybd(PROC_ARRAY *proc, OBJECT *tree, short obj, short nobj, short tch)
{
	proc->gem.int_in[0] = obj;
	proc->gem.int_in[1] = tch;
	proc->gem.int_in[2] = nobj;
	proc->gem.addr_in[0] = (long)tree;

	return call_aes(proc->base, 1L, 2, proc, 55);
}

long
_graf_movebox(PROC_ARRAY *proc, short w, short h, short x, short y, short dx, short dy)
{
	proc->gem.int_in[0] = w;
	proc->gem.int_in[1] = h;
	proc->gem.int_in[2] = x;
	proc->gem.int_in[3] = y;
	proc->gem.int_in[4] = dx;
	proc->gem.int_in[5] = dy;

	return call_aes(proc->base, 1L, 2, proc, 72);
}

long
_graf_growbox(PROC_ARRAY *proc, short x, short y, short w, short h, short *xywh)
{
	proc->gem.int_in[0] = x;
	proc->gem.int_in[1] = y;
	proc->gem.int_in[2] = w;
	proc->gem.int_in[3] = h;
	proc->gem.int_in[4] = xywh[0];
	proc->gem.int_in[5] = xywh[1];
	proc->gem.int_in[6] = xywh[2];
	proc->gem.int_in[7] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 73);
}

long
_graf_shrinkbox(PROC_ARRAY *proc, short x, short y, short w, short h, short *xywh)
{
	proc->gem.int_in[0] = x;
	proc->gem.int_in[1] = y;
	proc->gem.int_in[2] = w;
	proc->gem.int_in[3] = h;
	proc->gem.int_in[4] = xywh[0];
	proc->gem.int_in[5] = xywh[1];
	proc->gem.int_in[6] = xywh[2];
	proc->gem.int_in[7] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 74);
}

long
_graf_mouse(PROC_ARRAY *proc, short num, void *addr)
{
	proc->gem.int_in[0] = num;
	proc->gem.addr_in[0] = (long)addr;

	return call_aes(proc->base, 1L, 2, proc, 78);
}

long
_menu_popup(PROC_ARRAY *proc, MENU *m1, short x, short y, MENU *m2)
{
	proc->gem.addr_in[0] = (long)m1;
	proc->gem.addr_in[1] = (long)m2;
	proc->gem.int_in[0] = x;
	proc->gem.int_in[1] = y;

	return call_aes(proc->base, 1L, 2, proc, 36);
}

long
_menu_register(PROC_ARRAY *proc, short id, char *name)
{
	proc->gem.int_in[0] = id;
	proc->gem.addr_in[0] = (long)name;

	return call_aes(proc->base, 1L, 2, proc, 35);
}

long
_objc_edit(PROC_ARRAY *proc, OBJECT *tree, short edob, short edchar, short idx, short mode)
{
	proc->gem.int_in[0] = edob;
	proc->gem.int_in[1] = edchar;
	proc->gem.int_in[2] = idx;
	proc->gem.int_in[3] = mode;
	proc->gem.addr_in[0] = (long)tree;

	return call_aes(proc->base, 1L, 2, proc, 46);
}

long
_objc_change(PROC_ARRAY *proc, OBJECT *tree, short ob, short *xywh, short nw, short rd)
{
	proc->gem.addr_in[0] = (long)tree;
	proc->gem.int_in[0] = ob;
	proc->gem.int_in[1] = 0;
	proc->gem.int_in[2] = xywh[0];
	proc->gem.int_in[3] = xywh[1];
	proc->gem.int_in[4] = xywh[2];
	proc->gem.int_in[5] = xywh[3];
	proc->gem.int_in[6] = nw;
	proc->gem.int_in[7] = rd;

	return call_aes(proc->base, 1L, 2, proc, 47);
}

long
_objc_find(PROC_ARRAY *proc, OBJECT *tree, short ob, short depth, short mx, short my)
{
	proc->gem.addr_in[0] = (long)tree;
	proc->gem.int_in[0] = ob;
	proc->gem.int_in[1] = depth;
	proc->gem.int_in[2] = mx;
	proc->gem.int_in[3] = my;

	return call_aes(proc->base, 1L, 2, proc, 43);
}

long
_objc_draw(PROC_ARRAY *proc, OBJECT *tree, short ob, short dp, short *xywh)
{
	proc->gem.addr_in[0] = (long)tree;
	proc->gem.int_in[0] = ob;
	proc->gem.int_in[1] = dp;
	proc->gem.int_in[2] = xywh[0];
	proc->gem.int_in[3] = xywh[1];
	proc->gem.int_in[4] = xywh[2];
	proc->gem.int_in[5] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 42);
}

long
_objc_offset(PROC_ARRAY *proc, OBJECT *tree, short obj)
{
	proc->gem.int_in[0] = obj;
	proc->gem.addr_in[0] = (long)tree;

	return call_aes(proc->base, 1L, 2, proc, 44);
}

long
_rsrc_load(PROC_ARRAY *proc, char *name)
{
	proc->gem.addr_in[0] = (long)name;

	return call_aes(proc->base, 1L, 2, proc, 110);
}

long
_rsrc_rcfix(PROC_ARRAY *proc, char *buf)
{
	proc->gem.addr_in[0] = (long)buf;

	return call_aes(proc->base, 1L, 2, proc, 115);
}

long
_shel_help(PROC_ARRAY *proc, short mode, char *file, char *key)
{
	proc->gem.int_in[0] = mode;
	proc->gem.addr_in[0] = (long)file;
	proc->gem.addr_in[1] = (long)key;

	return call_aes(proc->base, 1L, 2, proc, 128);
}

long
_shel_write(PROC_ARRAY *proc, short wd, short wg, short wc, char *cmd, char *tail)
{
	proc->gem.int_in[0] = wd;
	proc->gem.int_in[1] = wg;
	proc->gem.int_in[2] = wc;

	proc->gem.addr_in[0] = (long)cmd;
	proc->gem.addr_in[1] = (long)tail;

	return call_aes(proc->base, 1L, 2, proc, 121);
}

long
_wind_get(PROC_ARRAY *proc, short w, short fn)
{
	proc->gem.int_in[0] = w;
	proc->gem.int_in[1] = fn;

	return call_aes(proc->base, 1L, 2, proc, 104);
}

long
_wind_set(PROC_ARRAY *proc, short w, short fn)
{
	proc->gem.int_in[0] = w;
	proc->gem.int_in[1] = fn;

	return call_aes(proc->base, 1L, 2, proc, 105);
}

long
_wind_calc(PROC_ARRAY *proc, short type, short gadgets, short *xywh)
{
	proc->gem.int_in[0] = type;
	proc->gem.int_in[1] = gadgets;
	proc->gem.int_in[2] = xywh[0];
	proc->gem.int_in[3] = xywh[1];
	proc->gem.int_in[4] = xywh[2];
	proc->gem.int_in[5] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 108);
}

long
_wind_create(PROC_ARRAY *proc, short gadgets, short *xywh)
{
	proc->gem.int_in[0] = gadgets;
	proc->gem.int_in[1] = xywh[0];
	proc->gem.int_in[2] = xywh[1];
	proc->gem.int_in[3] = xywh[2];
	proc->gem.int_in[4] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 100);
}

long
_wind_open(PROC_ARRAY *proc, short handle, short *xywh)
{
	proc->gem.int_in[0] = handle;
	proc->gem.int_in[1] = xywh[0];
	proc->gem.int_in[2] = xywh[1];
	proc->gem.int_in[3] = xywh[2];
	proc->gem.int_in[4] = xywh[3];

	return call_aes(proc->base, 1L, 2, proc, 101);
}

long
_wind_close(PROC_ARRAY *proc, short handle)
{
	proc->gem.int_in[0] = handle;

	return call_aes(proc->base, 1L, 2, proc, 102);
}

long
_wind_delete(PROC_ARRAY *proc, short handle)
{
	proc->gem.int_in[0] = handle;

	return call_aes(proc->base, 1L, 2, proc, 103);
}

long
_wind_find(PROC_ARRAY *proc, short mx, short my)
{
	proc->gem.int_in[0] = mx;
	proc->gem.int_in[1] = my;

	return call_aes(proc->base, 1L, 2, proc, 106);
}

long
_wind_update(PROC_ARRAY *proc, short mode)
{
	proc->gem.int_in[0] = mode;

	return call_aes(proc->base, 1L, 2, proc, 107);
}

/* EOF */
