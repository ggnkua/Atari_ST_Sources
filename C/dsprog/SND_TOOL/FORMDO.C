#include "extern.h"

#define NIL -1
#define TRUE 1
#define FMD_FORWARD 1
#define FMD_BACKWARD 2
#define FMD_DEFLT 0

/* ------------------------------- */
/* | Springe zum n„chsten Object | */
/* ------------------------------- */
int next_index(OBJECT *tree, int obj, int *d, int deepth)
{
int a_obj;

if (tree[obj].ob_head != -1 && *d < deepth)
	{
	*d = *d + 1;
	return(tree[obj].ob_head);
	}

do
	{
	a_obj = obj;
	obj = tree[obj].ob_next;

	if (tree[obj].ob_tail == a_obj)
		*d = *d - 1;

	}while(tree[obj].ob_tail == a_obj && obj > -1);

return(obj);
}

/* ----------------------------------------
	 | Search first editable object in tree |
	 ---------------------------------------- */
int find_obj(OBJECT *tree, int start_obj)
{
int obj, flag;
int d;

obj = 0;
flag = EDITABLE;
obj = start_obj + 1;

d = 0;
while(obj >= 0 && d > -1)
	{
	if (tree[obj].ob_flags & flag)
		return(obj);

	obj = next_index(tree, obj, &d, MAX_DEPTH);
	}

return(start_obj);
}

/* ---------------------------
	 | Search default edit-obj |
	 --------------------------- */
int fm_inifld(OBJECT *tree, int start_fld)
{
if (!start_fld)
	start_fld = find_obj(tree, 0);

return start_fld;
}

/* ---------------------
	 | Form-do in window |
	 --------------------- */
int win_formdo(OBJECT *tree, int start_fld, int wind_id)
{
int edit_obj;
int next_obj;
int which, cont;
int idx;
int mx, my, mb, ks, kr, br, msg[8];
int x, y, w, h;

if (start_fld != -1)
	next_obj = fm_inifld(tree, start_fld);
else
	next_obj = 0;

edit_obj = 0;
cont = TRUE;
while(cont)
	{
	if (next_obj && edit_obj != next_obj)
		{
		edit_obj = next_obj;
		next_obj = 0;

		objc_edit(tree, edit_obj, 0, &idx, ED_INIT);
		}

	if (start_fld == -1)
		which = evnt_multi(MU_MESAG|MU_TIMER|MU_KEYBD,
											 0, 0, 0,
											 0, 0, 0, 0, 0,
											 0, 0, 0, 0, 0,
											 msg,
											 100, 0,
											 &mx, &my, &mb, &ks, &kr, &br);
	else
		which = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,
											 0x02, 0x01, 0x01,
											 0, 0, 0, 0, 0,
											 0, 0, 0, 0, 0,
											 msg,
											 0, 0,
											 &mx, &my, &mb, &ks, &kr, &br);

	if (which & MU_KEYBD)
		{
		wind_update(BEG_UPDATE);
		
		cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
		if (kr)
			objc_edit(tree, edit_obj, kr, &idx, ED_CHAR);
			
		wind_update(END_UPDATE);
		}

	if (which & MU_BUTTON)
		{
		wind_update(BEG_UPDATE);

		next_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my);
		if (next_obj == NIL)
			{
			Cconout(0x7);
			next_obj = 0;
			}
		else
			cont = form_button(tree, next_obj, br, &next_obj);

		wind_update(END_UPDATE);
		}

	if (which & MU_MESAG)
		{
		switch(msg[0])
			{
			case WM_REDRAW:
				red_x = msg[4];
				red_y = msg[5];
				red_w = msg[6];
				red_h = msg[7];

				if (msg[3] == wind_id)
					{
					if (edit_obj)
						objc_edit(tree, edit_obj, 0, &idx, ED_END);

					dialog_window(wind_id, tree, RDW_DIA, ROOT);

					if (edit_obj)
						objc_edit(tree, edit_obj, 0, &idx, ED_INIT);
					}
				else
					{
					sample_redraw(msg[3]);
					seqs_redraw(msg[3]);
					}
				break;

			case WM_MOVED:
				if (msg[3] == wind_id)
					{
					wind_set(wind_id, WF_CURRXYWH, msg[4], msg[5], msg[6], msg[7]);
					wind_get(wind_id, WF_WORKXYWH, &x, &y, &w, &h);
					tree[ROOT].ob_x = x;
					tree[ROOT].ob_y = y;
					}
				break;
			}
		}

	if (!cont || (next_obj && next_obj != edit_obj))
		objc_edit(tree, edit_obj, 0, &idx, ED_END);

	if (start_fld == -1 && which == MU_TIMER)
		break;
		
	if (start_fld == -1 && which == MU_KEYBD)
		break;
	}

if (start_fld == -1)
	return ((kr & 0xFF) == 0x1B);
else
	return(next_obj);
}

/* -------------------------
	 | Dialog window handler |
	 ------------------------- */
int dialog_window(int wind_id, OBJECT *dialog, int action, int ext)
{
int x, y, w, h, s;
int w_x, w_y, w_w, w_h;
int hndl, sel;

switch(action)
	{
	case CLS_DIA:
		wind_close(wind_id);
		wind_delete(wind_id);
		break;

	case OPN_DIA:
		form_center(dialog, &x, &y, &w, &h);
	 	wind_calc(WC_BORDER, MOVER|NAME, x, y, w, h, &w_x, &w_y, &w_w, &w_h);
	  hndl = open_window(MOVER|NAME, w_x, w_y, w_w, w_h, "");
		return hndl;

	case RDW_DIA:
		s = first_rect(wind_id, 0);
		while(s)
			{
			objc_draw(dialog, ext, MAX_DEPTH, r_xy[0], r_xy[1], r_xy[2], r_xy[3]);
			s = next_rect(wind_id, 0);
			}
		break;

	case ACT_DIA:
		sel = win_formdo(dialog, ext, wind_id);
		if (dialog[sel].ob_flags & EXIT)
			dialog[sel].ob_state &= ~SELECTED;

		return sel;
	}
return 0;
}
