/* Windowed dialog boxes */

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

# include <errno.h>
# include <string.h>

# include "dosproto.h"
# include "gemma.h"
# include "gemproto.h"
# include "user.h"
# include "alert.h"

extern long __rc_intersect(short *r1, short *r2);

/* Internal functions */

static long
ret(void)
{
	DEBUGMSG("Default event handler\n");

	return 0;
}

static void
objcedit(PROC_ARRAY *proc, WINDIAL *wd, short mode)
{
	if (!wd->wb_startob)
		return;
	if (wd->wb_iconified)
		return;

	if (mode == ED_INIT)
	{
		TEDINFO *ted;
		short ob = wd->wb_startob;
		OBJECT *tree = wd->wb_treeptr;

		if (wd->wb_fieldinit)
			return;
		ted = tree[ob].ob_spec.tedinfo;
		wd->wb_edindex = strlen(ted->te_ptext);
		wd->wb_fieldinit = 1;
	}

	if (mode == ED_END)
	{
		if (wd->wb_fieldinit)
			wd->wb_fieldinit = 0;
		else
			return;
	}

	_objc_edit(proc, wd->wb_treeptr, wd->wb_startob, \
				R_TREE, wd->wb_edindex, mode);
}

static inline long
mclick(PROC_ARRAY *proc, WINDIAL *wd)
{
	long r;

	if (wd->wb_iconified)
		return 0;

	if (wd->wb_handle != \
			_wind_find(proc, wd->wb_mouse_x, wd->wb_mouse_y))
		return 0;

	r = _objc_find(proc, wd->wb_treeptr, R_TREE, 7, \
				wd->wb_mouse_x, wd->wb_mouse_y);
	if (r < 0)
		return 0;
	wd->wb_object = (short)r;

	if (wd->wb_treeptr[r].ob_flags & OF_EDITABLE)
	{
		objcedit(proc, wd, ED_END);
		wd->wb_startob = wd->wb_object;
		objcedit(proc, wd, ED_INIT);
	}

	if (wd->wb_treeptr[r].ob_flags & (OF_EXIT|OF_TOUCHEXIT))
	{
		r = _form_button(proc, wd->wb_treeptr, \
					wd->wb_object, wd->wb_bclicks);
		if (!r)
		{
			if (sflags.button_delay)
				_evnt_timer(proc, sflags.button_delay);
			return (long)wd->wb_object;
		}
	}

	return 0;
}

static inline long
kstroke(PROC_ARRAY *proc, WINDIAL *wd, short key)
{
	long r;

	DEBUGMSG("kstroke(): calling form_keybd()\n");

	if (wd->wb_iconified)
		return 0;

	r = _form_keybd(proc, wd->wb_treeptr, wd->wb_startob, 1, key);

	wd->wb_object = proc->gem.int_out[1];
	wd->wb_key = proc->gem.int_out[2];

# ifdef DEBUG
	{
		extern void bin2asc(long number, char *out);
		char tmp[32];

		bin2asc((long)key, tmp);
		DEBUGMSG("- passed key is ");
		DEBUGMSG(tmp);
		DEBUGMSG("\n");

		bin2asc(r, tmp);
		DEBUGMSG("- return value is ");
		DEBUGMSG(tmp);
		DEBUGMSG("\n");

		bin2asc((long)wd->wb_object, tmp);
		DEBUGMSG("- new object index is ");
		DEBUGMSG(tmp);
		DEBUGMSG("\n");

		bin2asc((long)wd->wb_key, tmp);
		DEBUGMSG("- new key is ");
		DEBUGMSG(tmp);
		DEBUGMSG("\n");
	}
# endif

	if (!r)
		return 0;

	/* Don't bother doing anything further if the box
	 * has no edit fields
	 */
	if (!wd->wb_startob)
		return 1;

	if (!wd->wb_key && (wd->wb_object != wd->wb_startob))
	{
		DEBUGMSG("kstroke(): field switch\n");

		objcedit(proc, wd, ED_END);
		wd->wb_startob = wd->wb_object;
		objcedit(proc, wd, ED_INIT);

		DEBUGMSG("kstroke(): complete\n");

		return 1;
	}

	DEBUGMSG("kstroke(): doing ED_CHAR\n");

	_objc_edit(proc, wd->wb_treeptr, wd->wb_startob, \
				wd->wb_key, wd->wb_edindex, ED_CHAR);
	wd->wb_edindex = proc->gem.int_out[1];

	DEBUGMSG("kstroke(): complete\n");

	return r;
}

static void
wd_struct_unlink(WINDIAL *wd)
{
	WINDIAL *prev, *next;

	prev = wd->wb_prev;
	next = wd->wb_next;

	if (!prev && !next)
		return;					/* nothing to do */
	if (!prev)
	{
		next->wb_prev = 0;
		return;
	}
	if (!next)
	{
		prev->wb_next = 0;
		return;
	}

	prev->wb_next = next;
	next->wb_prev = prev;
}

static void
obj_update(WINDIAL *wd)
{
	OBJECT *tree;

	if (wd->wb_iconified)
		tree = wd->wb_icontree;
	else
		tree = wd->wb_treeptr;

	tree->ob_x = wd->wb_work_x;
	tree->ob_y = wd->wb_work_y;
}

static inline void
calc_center(WINDIAL *wd)
{
	wd->wb_center_x = (wd->wb_border_x + wd->wb_border_w) >> 1;
	wd->wb_center_y = (wd->wb_border_y + wd->wb_border_h) >> 1;
}

static void
reset_form(PROC_ARRAY *proc, WINDIAL *wd)
{
	OBJECT *tree;
	short comp = 0;

	if (wd->wb_iconified)
		tree = wd->wb_icontree;
	else
		tree = wd->wb_treeptr;

	wd->wb_work_x = tree->ob_x;
	wd->wb_work_y = tree->ob_y;
	wd->wb_work_w = tree->ob_width;
	wd->wb_work_h = tree->ob_height;

	_wind_calc(proc, WC_BORDER, wd->wb_gadgets, &wd->wb_work_x);
	wd->wb_border_x = proc->gem.int_out[1];
	wd->wb_border_y = proc->gem.int_out[2];
	wd->wb_border_w = proc->gem.int_out[3];
	wd->wb_border_h = proc->gem.int_out[4];

	if (sflags.screen_comp)
		comp = wd->wb_border_h - wd->wb_work_h;
	wd->wb_border_x = (wd->wb_desk_w - wd->wb_border_w) >> 1;
	wd->wb_border_y = (wd->wb_desk_h - wd->wb_border_h + comp) >> 1;

	_wind_calc(proc, WC_WORK, wd->wb_gadgets, &wd->wb_border_x);
	wd->wb_work_x = proc->gem.int_out[1];
	wd->wb_work_y = proc->gem.int_out[2];
	wd->wb_work_w = proc->gem.int_out[3];
	wd->wb_work_h = proc->gem.int_out[4];

	obj_update(wd);
	calc_center(wd);
}

/* User functions */

long
windial_size(void)
{
	return sizeof(WINDIAL);
}

long
windial_center(BASEPAGE *bp, long fn, short nargs, \
		WINDIAL *wd, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;

	if (!nargs)
		return -EINVAL;
	if (nargs > 1) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;
	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	reset_form(proc, wd);

	proc->gem.int_in[2] = wd->wb_border_x;
	proc->gem.int_in[3] = wd->wb_border_y;
	proc->gem.int_in[4] = wd->wb_border_w;
	proc->gem.int_in[5] = wd->wb_border_h;
	_wind_set(proc, wd->wb_handle, WF_CURRXYWH);

	return 0;
}

/* Initialize the WINDIAL structure for the window
 */
long
windial_create(BASEPAGE *bp, long fn, short nargs, \
		WINDIAL *wd, short obj, short icon, short field, \
		char *title, short gadgets, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	short m = 0, g;
	long r;

	if (nargs < 5) return -EINVAL;
	if (nargs == 5)
		g = NAME|MOVER|CLOSER|FULLER;
	else
		g = gadgets;
	if (nargs > 6) proc = p;
	if ((nargs < 7) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;

	DEBUGMSG("windial_create(): enter\n");

	if (!wd)
	{
		if (proc->window.wb_magic == WINDIAL_MAGIC)
		{
			wd = (WINDIAL *)_alloc(sizeof(WINDIAL));
			m = 1;
		} else
			wd = (WINDIAL *)&proc->window.wb_treeptr;
	}
	if (!wd)
		return -EINTERNAL;	/* impossible */
	if ((long)wd < 0)
		return (long)wd;

	if (!proc->wchain)
		proc->wchain = wd;

	bzero(wd, sizeof(WINDIAL));

	DEBUGMSG("windial_create(): init handlers\n");

	r = (long)ret;
	wd->wb_exthandler = r;
	wd->wb_keyhandler = r;
	wd->wb_buthandler = r;
	wd->wb_rc1handler = r;
	wd->wb_rc2handler = r;
	wd->wb_timhandler = r;

	DEBUGMSG("windial_create(): init title\n");

	wd->wb_title = (char *)obj2addr(proc, R_STRING, (unsigned long)title);
	wd->wb_startob = field;
	wd->wb_gadgets = g;

	DEBUGMSG("windial_create(): init icon\n");

	if (icon)
	{
		wd->wb_icon = icon;
		r = rsrc_xgaddr(bp, 16L, 3, R_TREE, icon, proc);
		if (r > 0)
		{
			short ap[4];

			TOUCH(r);
			wd->wb_icontree = (OBJECT *)r;
			_appl_getinfo(proc, 11, ap);
			if (ap[2] & 1)		
				wd->wb_gadgets |= SMALLER;
		}
	}
	if (!wd->wb_icontree)
		wd->wb_gadgets &= ~SMALLER;

	DEBUGMSG("windial_create(): init tree\n");

	wd->wb_box = obj;
	r = rsrc_xgaddr(bp, 16L, 3, R_TREE, obj, proc);
	if (r <= 0)
	{
		_alert(proc, 1, "[1][windial_create():|cannot find root object|requested by apid %a!][ Cancel ]\n");
		goto fatal;
	}
	TOUCH(r);
	wd->wb_treeptr = (OBJECT *)r;

	DEBUGMSG("windial_create(): init textfields\n");
	{
		OBJECT *o = wd->wb_treeptr;
		unsigned short so;

		for (so = 0; so <= 0xffff; so++)
		{
			if (o[so].ob_flags & OF_EDITABLE)
			{
				r = ftext_fix(bp, 29L, 3, wd->wb_box, so, proc);
				if (r) break;
			}
			if (o[so].ob_flags & OF_LASTOB)
				break;
		}
	}

	DEBUGMSG("windial_create(): init fillpatterns\n");
	if (proc->gem.vwk_colors < 16)
	{
		OBJECT *o = wd->wb_treeptr;
		unsigned short so, ot;

		for (so = 0; so <= 0xffff; so++)
		{
			ot = o[so].ob_type;
			if ((ot == G_BOX) || (ot == G_IBOX))
				o[so].ob_spec.obspec.fillpattern = 0;
			if (o[so].ob_flags & OF_LASTOB)
				break;
		}
	}

	DEBUGMSG("windial_create(): get desk size\n");
	_wind_get(proc, 0, WF_WORKXYWH);
	wd->wb_desk_x = proc->gem.int_out[1];
	wd->wb_desk_y = proc->gem.int_out[2];
	wd->wb_desk_w = proc->gem.int_out[3];
	wd->wb_desk_h = proc->gem.int_out[4];

	DEBUGMSG("windial_create(): reset form\n");
	reset_form(proc, wd);

	DEBUGMSG("windial_create(): create window\n");
	r = _wind_create(proc, wd->wb_gadgets, &wd->wb_border_x);
	if (r <= 0)
	{
		_alert(proc, 1, "[1][windial_create():|cannot create new window|requested by apid %a!][ Cancel ]\n");
		goto fatal;
	}
	wd->wb_handle = r;

	DEBUGMSG("windial_create(): set title\n");
	r = (long)wd->wb_title;
	if (r <= 0)
		r = (long)"";
	proc->gem.int_in[2] = (short)(r >> 16);
	proc->gem.int_in[3] = (short)r;
	_wind_set(proc, wd->wb_handle, WF_NAME);

	DEBUGMSG("windial_create(): init events\n");
	wd->wb_eventmask = MU_MESAG|MU_KEYBD|MU_BUTTON;
	wd->wb_bclicks = 1;
	wd->wb_bmask = 0x0001;
	wd->wb_bstate = 1;

	wd->wb_autofree = m;
	wd->wb_magic = WINDIAL_MAGIC;

	DEBUGMSG("windial_create(): complete\n");

	return (long)wd;

fatal:	if (m)
		_free((long)wd);

	DEBUGMSG("windial_create(): exit on error\n");

	return -EINVAL;
}

long
windial_open(BASEPAGE *bp, long fn, short nargs, WINDIAL *wd, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;

	DEBUGMSG("windial_open(): begin\n");

	if (!nargs) return -EINVAL;
	if (nargs > 1) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;
	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	DEBUGMSG("windial_open(): enter\n");

	_graf_mkstate(proc);
	wd->wb_start_x = proc->gem.int_out[1];
	wd->wb_start_y = proc->gem.int_out[2];

	_graf_movebox(proc, 16, 16, wd->wb_start_x, wd->wb_start_y, \
					wd->wb_center_x, wd->wb_center_y);
	_graf_growbox(proc, wd->wb_center_x, wd->wb_center_y, \
					1, 1, &wd->wb_border_x);

	_wind_open(proc, wd->wb_handle, &wd->wb_border_x);

	wd->wb_ontop = 1;

	DEBUGMSG("windial_open(): complete\n");

	return 0;
}

long
windial_close(BASEPAGE *bp, long fn, short nargs, WINDIAL *wd, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;

	DEBUGMSG("windial_close(): begin\n");

	if (!nargs) return -EINVAL;
	if (nargs > 1) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;
	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	if (wd->wb_startob && !wd->wb_iconified)
		_objc_edit(proc, wd->wb_treeptr, wd->wb_startob, 0, wd->wb_edindex, ED_END);

	_wind_close(proc, wd->wb_handle);

	_graf_shrinkbox(proc, wd->wb_center_x, wd->wb_center_y, 1, 1, &wd->wb_border_x);
	_graf_movebox(proc, 16, 16, wd->wb_center_x, wd->wb_center_y, \
					wd->wb_start_x, wd->wb_start_y);

	DEBUGMSG("windial_close(): complete\n");

	return 0;
}

long
windial_delete(BASEPAGE *bp, long fn, short nargs, WINDIAL *wd, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;

	DEBUGMSG("windial_delete(): begin\n");

	if (!nargs) return -EINVAL;
	if (nargs > 1) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;
	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	_wind_delete(proc, wd->wb_handle);

	/* If this is the last window, its wb_next pointer is NULL
	 */ 
	if (wd == proc->wchain)
		proc->wchain = wd->wb_next;

	wd_struct_unlink(wd);
	wd->wb_magic = 0;		/* invalidate the struct */

	if (wd->wb_autofree)
		_free((long)wd);

	DEBUGMSG("windial_delete(): complete\n");

	return 0;
}

long
windial_formdo(BASEPAGE *bp, long fn, short nargs, WINDIAL *wd, PROC_ARRAY *p)
{
	PROC_ARRAY *proc = 0;
	long retval;

	DEBUGMSG("windial_formdo(): begin\n");

	if (!nargs) return -EINVAL;
	if (nargs > 1) proc = p;
	if ((nargs < 2) || !proc) proc = get_contrl(bp);

	if (!proc->gem.global[0])
		return -EACCES;
	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	for(;;)
	{
		long m;

		m = _evnt_multi(proc, wd->wb_eventmask, wd->wb_bclicks, wd->wb_bmask, \
			wd->wb_bstate, wd->wb_m1flag, wd->wb_m1x, wd->wb_m1y, \
			wd->wb_m1w, wd->wb_m1h, wd->wb_m2flag, wd->wb_m2x, \
			wd->wb_m2y, wd->wb_m2w, wd->wb_m2h, \
			wd->wb_aesmessage, wd->wb_timer);

		if (m & MU_TIMER)
		{
			typedef void (*EXEC)(WINDIAL *wd, short vec, unsigned long count);
			EXEC hnd = (EXEC)wd->wb_timhandler;

			if (hnd)
			{
				DEBUGMSG("Calling timer handler\n");
				(hnd)(wd, WD_TIMVEC, wd->wb_timer);
				DEBUGMSG("Returning from timer handler\n");
			}
		}
		if (m & MU_BUTTON)
		{
			typedef void (*EXEC)(WINDIAL *wd, short vec);
			EXEC hnd = (EXEC)wd->wb_buthandler;

			wd->wb_mouse_x = proc->gem.int_out[1];
			wd->wb_mouse_y = proc->gem.int_out[2];

			if (hnd)
			{
				DEBUGMSG("Calling button handler\n");
				(hnd)(wd, WD_BUTVEC);
				DEBUGMSG("Returning from button handler\n");
			}
			if (mclick(proc, wd))
				break;
		}
		if (m & MU_KEYBD)
		{
			typedef long (*EXEC)(WINDIAL *wd, short vec, short ks, short kc);
			EXEC hnd = (EXEC)wd->wb_keyhandler;
			long r = 0;
			short key, kst;

			kst = proc->gem.int_out[4];
			key = proc->gem.int_out[5];
			if (hnd)
			{
				DEBUGMSG("Calling keyboard handler\n");
				r = (hnd)(wd, WD_KEYVEC, kst, key);
				DEBUGMSG("Returned from keyboard handler\n");
				if (r > 0)
					key = (short)r;
			}
			if (r >= 0)
			{
				r = kstroke(proc, wd, key);
				if (!r)
					break;
			}
		}
		if (m & MU_MESAG)
		{
			typedef long (*EXEC)(WINDIAL *wd, short vec, short *aesmsg);
			EXEC hnd = (EXEC)wd->wb_exthandler;
			long r = 0;
			short msg;

			if (hnd)
			{
				DEBUGMSG("Calling message handler\n");
				r = (hnd)(wd, WD_MSGVEC, wd->wb_aesmessage);
				DEBUGMSG("Returning from message handler\n");
			}

			if (wd->wb_aesmessage[3] != wd->wb_handle)
				continue;

			if (r >= 0)
			{
				msg = wd->wb_aesmessage[0];
				switch (msg)
				{
					case WM_CLOSED:
						{
							retval = wd->wb_box;
							retval <<= 16;
							retval |= 0x0000ffffL;
							return retval;
						}
					case WM_TOPPED:
					case WM_ONTOP:
						if (!wd->wb_ontop)
						{
							_wind_set(proc, wd->wb_handle, WF_TOP);
							wd->wb_ontop = 1;
							objcedit(proc, wd, ED_INIT);
						}
						break;
					case WM_BOTTOMED:
						if (wd->wb_ontop)
						{
							objcedit(proc, wd, ED_END);
							_wind_set(proc, wd->wb_handle, WF_BOTTOM);
							wd->wb_ontop = 0;
						}
						break;
					case WM_UNTOPPED:
						wd->wb_ontop = 0;
						break;
					case WM_FULLED:
					case WM_MOVED:
						if (msg == WM_MOVED)
						{
							if (sflags.moveboxes)
								_graf_movebox(proc, wd->wb_border_w, wd->wb_border_h, \
										wd->wb_border_x, wd->wb_border_y, \
										wd->wb_aesmessage[4], wd->wb_aesmessage[5]);
							wd->wb_border_x = wd->wb_aesmessage[4];
							wd->wb_border_y = wd->wb_aesmessage[5];
							wd->wb_border_w = wd->wb_aesmessage[6];
							wd->wb_border_h = wd->wb_aesmessage[7];
						} else
							reset_form(proc, wd);
						proc->gem.int_in[2] = wd->wb_border_x;
						proc->gem.int_in[3] = wd->wb_border_y;
						proc->gem.int_in[4] = wd->wb_border_w;
						proc->gem.int_in[5] = wd->wb_border_h;
						_wind_set(proc, wd->wb_aesmessage[3], WF_CURRXYWH);
						if (msg == WM_MOVED)
						{
							calc_center(wd);
							_wind_calc(proc, WC_WORK, wd->wb_gadgets, &wd->wb_border_x);
							wd->wb_work_x = proc->gem.int_out[1];
							wd->wb_work_y = proc->gem.int_out[2];
							wd->wb_work_w = proc->gem.int_out[3];
							wd->wb_work_h = proc->gem.int_out[4];
							obj_update(wd);
						}
						break;
					case WM_ICONIFY:
					case WM_UNICONIFY:
						{
							short wset;

							if (msg == WM_ICONIFY)
							{
								_form_dial(proc, FMD_SHRINK, &wd->wb_aesmessage[4], &wd->wb_work_x);
								wset = WF_ICONIFY;
								wd->wb_iconified = 1;
							}
							else
							{
								_form_dial(proc, FMD_GROW, &wd->wb_work_x, &wd->wb_aesmessage[4]);
								wset = WF_UNICONIFY;
								wd->wb_iconified = 0;
							}
							proc->gem.int_in[2] = wd->wb_aesmessage[4];
							proc->gem.int_in[3] = wd->wb_aesmessage[5];
							proc->gem.int_in[4] = wd->wb_aesmessage[6];
							proc->gem.int_in[5] = wd->wb_aesmessage[7];
							_wind_set(proc, wd->wb_handle, wset);
							_wind_get(proc, wd->wb_handle, WF_WORKXYWH);
							wd->wb_work_x = proc->gem.int_out[1];
							wd->wb_work_y = proc->gem.int_out[2];
							wd->wb_work_w = proc->gem.int_out[3];
							wd->wb_work_h = proc->gem.int_out[4];
							obj_update(wd);
						}
						break;
					case WM_REDRAW:
						{
							short md;

							if (wd->wb_ontop)
								objcedit(proc, wd, ED_END);
							md = WF_FIRSTXYWH;
							_wind_update(proc, BEG_UPDATE);
							for(;;)
							{
								_wind_get(proc, wd->wb_aesmessage[3], md);
								if ((proc->gem.int_out[3] == 0) && (proc->gem.int_out[4] == 0))
									break;
								wd->wb_rcdraw_x = wd->wb_aesmessage[4];
								wd->wb_rcdraw_y = wd->wb_aesmessage[5];
								wd->wb_rcdraw_w = wd->wb_aesmessage[6];
								wd->wb_rcdraw_h = wd->wb_aesmessage[7];
								if (__rc_intersect(&proc->gem.int_out[1], &wd->wb_rcdraw_x))
								{
									if (wd->wb_iconified)
										_objc_draw(proc, wd->wb_icontree, R_TREE, 1, &wd->wb_rcdraw_x);
									else
										_objc_draw(proc, wd->wb_treeptr, R_TREE, 7, &wd->wb_rcdraw_x);
								}
								md = WF_NEXTXYWH;
							}
							_wind_update(proc, END_UPDATE);
							if (wd->wb_ontop)
								objcedit(proc, wd, ED_INIT);
						}
						break;
				}
			}
		}
	}

	retval = wd->wb_box;
	retval <<= 16;
	retval |= (unsigned short)wd->wb_object;

	DEBUGMSG("windial_formdo(): exit\n");

	return retval;
}

long
windial_duplnk(BASEPAGE *bp, long fn, short nargs, \
		WINDIAL *old, WINDIAL *new, PROC_ARRAY *p)
{
	WINDIAL *newhandle = new, *w = old;
	short m = 0;

	UNUSED(p);
	if (nargs < 2) return -EINVAL;

	if (old->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	if (fn != 20)
	{
		if (!newhandle)
		{
			newhandle = (WINDIAL *)_alloc(sizeof(WINDIAL));
			if ((long)newhandle < 0)
				return (long)newhandle;
			m++;
		}
		memcpy(newhandle, old, sizeof(WINDIAL));
		newhandle->wb_autofree = m;
		newhandle->wb_prev = newhandle->wb_next = 0;
	}

	if (newhandle->wb_magic != WINDIAL_MAGIC)
	{
		if (m)
			_free((long)newhandle);	/* impossible */
		return -EFAULT;
	}

	for(;;)
	{
		if (!w->wb_next)
			break;
		if (w->wb_next == old)
		{
			if (m)
				_free((long)newhandle);
			return -EINTERNAL;
		}
		w = w->wb_next;
	}

	w->wb_next = newhandle;
	newhandle->wb_prev = w;

	return 0;
}

long
windial_unlink(BASEPAGE *bp, long fn, short nargs, \
		WINDIAL *wd, PROC_ARRAY *p)
{
	UNUSED(p);

	if (wd->wb_magic != WINDIAL_MAGIC)
		return -EFAULT;

	wd_struct_unlink(wd);

	return 0;
}

/* EOF */
