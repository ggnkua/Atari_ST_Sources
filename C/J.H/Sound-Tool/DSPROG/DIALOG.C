#include "extern.h"
#include "err_dia.h"

int but = 0;

/* ---------------------------
   | Search dialog window id |
   --------------------------- */
int search_dw(int w_handle)
{
int i;

if (w_handle)
	for (i = 0; i < 20; i++)
		if (dia_adr[i])
			if (dia_adr[i]->w_handle == w_handle)
				return i;

return -1;
}

/* -------------------
   | Exclusiv dialog |
   ------------------- */
int exclusiv_dialog(DIALOG *new_dia)
{
exclusive_wind = 1;
new_dialog(new_dia);
exclusive_wind = new_dia->w_handle;

but = 0;
if (exclusive_wind)
	do
		{
		check_action();
		}while(!but);

exclusive_wind = 0;	
return but;
}

/* -------------------
   | Draw new dialog |
   ------------------- */
void new_diaset(DIALOG *new_dia, int x, int y)
{
int w, h;
int w_x, w_y, w_w, w_h;
int a_x, a_y, a_w, a_h;
int i;

if (new_dia->w_handle)
	{
	wind_set(new_dia->w_handle, WF_TOP);
	return;
	}
	
for (i = 0; i < 20; i++)
	if (!dia_adr[i])
		break;
		
if (i == 20)
	{
	form_alert(1, "[3][ Alles voll ? | No more dialogs ! ][ schade ]");
	return;
	}

rsrc_gaddr(R_TREE, new_dia->f_no, &new_dia->tree);
get_curstate(new_dia);

if (x == -1)
	{
	if (new_dia->center)
		form_center(new_dia->tree, &x, &y, &w, &h);
	else
		{
		x = mx - (new_dia->tree->ob_width >> 1);
		y = my - (new_dia->tree->ob_height >> 1);
		w = new_dia->tree->ob_width;
		h = new_dia->tree->ob_height;
		}
	
	wind_calc(WC_BORDER, CLOSER|MOVER|NAME, x, y, w, h, &w_x, &w_y, &w_w, &w_h);

	wind_get(0, WF_WORKXYWH, &a_x, &a_y, &a_w, &a_h);
	if (w_x < a_x)
		w_x = a_x;
	if (w_y < a_y)
		w_y = a_y;
	if (w_x + w_w > a_x + a_w)
		w_x -= w_x + w_w - a_x - a_w;
	if (w_y + w_h > a_y + a_h)
		w_y -= w_y + w_h - a_y - a_h;
	}
else
	{
	w = new_dia->tree->ob_width;
	h = new_dia->tree->ob_height;
	
	wind_calc(WC_BORDER, CLOSER|MOVER|NAME, x, y, w, h, &w_x, &w_y, &w_w, &w_h);
	w_x = x;
	w_y = y;
	}
		
if (exclusive_wind)
	new_dia->w_handle = wind_create(NAME|MOVER, w_x, w_y, w_h, w_w);
else
	new_dia->w_handle = wind_create(CLOSER|NAME|MOVER, w_x, w_y, w_h, w_w);
	
if (!new_dia->w_handle)
	{
	form_alert(1, "[3][Kein Fenster mehr |verfgbar.][ schade ]");
	return;
	}
	
wind_set(new_dia->w_handle, WF_NAME, new_dia->title);
wind_open(new_dia->w_handle, w_x, w_y, w_w, w_h); 

wind_get(new_dia->w_handle, WF_WORKXYWH, &new_dia->tree->ob_x, &new_dia->tree->ob_y, &w, &h);
dia_adr[i] = new_dia;

if (new_dia->edit_obj)
	objc_edit(new_dia->tree, new_dia->edit_obj, 0, &new_dia->crs_idx, ED_INIT);
}

/* ---------------------------------
   | Set new dialog at mouse arrow |
   --------------------------------- */
void new_dialog(DIALOG *new_dia)
{
new_diaset(new_dia, -1, -1);
}

/* -------------------------------------
   | Set new dialog at window position |
   ------------------------------------- */
void new_dialog2(DIALOG *new_dia, int w_handle)
{
int x, y, w, h;

if (w_handle < 0)
	graf_mkstate(&x, &y, &w, &h);
else
	wind_get(w_handle, WF_CURRXYWH, &x, &y, &w, &h);
new_diaset(new_dia, x, y);
}

/* -------------------
   | Draw new dialog |
   ------------------- */
void dialog_reopen(int i_handle)
{
int x, y, w, h;
int w_x, w_y, w_w, w_h;
int a_x, a_y, a_w, a_h;
int i;
DIALOG *new_dia;

i = search_dw(i_handle);

if (i > -1)
	{
	new_dia = dia_adr[i];
	
	x = mx - (new_dia->tree->ob_width >> 1);
	y = my - (new_dia->tree->ob_height >> 1);
	w = new_dia->tree->ob_width;
	h = new_dia->tree->ob_height;
	
	wind_calc(WC_BORDER, CLOSER|MOVER|NAME, x, y, w, h, &w_x, &w_y, &w_w, &w_h);

	wind_get(0, WF_WORKXYWH, &a_x, &a_y, &a_w, &a_h);
	if (w_x < a_x)
		w_x = a_x;
	if (w_y < a_y)
		w_y = a_y;
	if (w_x + w_w > a_x + a_w)
		w_x -= w_x + w_w - a_x - a_w;
	if (w_y + w_h > a_y + a_h)
		w_y -= w_y + w_h - a_y - a_h;

	new_dia->w_handle = wind_create(CLOSER|NAME|MOVER, w_x, w_y, w_h, w_w);
	
	if (!new_dia->w_handle)
		{
		form_alert(1, "[3][Kein Fenster mehr |verfgbar.][ schade ]");
		return;
		}

	delete_icon(icon_no[(-i_handle) - 1]);
	
	wind_set(new_dia->w_handle, WF_NAME, new_dia->title);
	wind_open(new_dia->w_handle, w_x, w_y, w_w, w_h); 

	if (new_dia->edit_obj)
		objc_edit(new_dia->tree, new_dia->edit_obj, 0, &new_dia->crs_idx, ED_INIT);
	}
}

/* -----------------
   | Redraw dialog |
   ----------------- */
void dialog_redraw(int w_handle, int start, int r_x, int r_y, int r_w, int r_h)
{
int i, s;
int dummy;

if (w_handle < 0)
	return;
	
i = search_dw(w_handle);
		
if (i == -1)
	return;

wind_get(w_handle, WF_WORKXYWH, &dia_adr[i]->tree->ob_x, &dia_adr[i]->tree->ob_y, &dummy, &dummy);

if (dia_adr[i]->edit_obj)
	objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
	
wind_update(BEG_UPDATE);
s = first_rect(w_handle, r_x, r_y, r_w, r_h, 0);
while(s)
	{
	xobjc_draw(dia_adr[i]->tree, start, MAX_DEPTH, r_xy[0], r_xy[1], r_xy[2], r_xy[3]);
	s = next_rect(w_handle, 0);
	}
wind_update(END_UPDATE);

if (dia_adr[i]->edit_obj)
	objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_INIT);
}

/* ------------------------
   | Redraw dialog object |
   ------------------------ */
void force_oredraw(int w_handle, int obj)
{
int i;
int dummy;
int x, y;

i = search_dw(w_handle);
		
if (i == -1)
	return;

wind_get(w_handle, WF_WORKXYWH, &dia_adr[i]->tree->ob_x, &dia_adr[i]->tree->ob_y, &dummy, &dummy);

objc_offset(dia_adr[i]->tree, abs(obj), &x, &y);
if (obj > 0)
	dialog_redraw(dia_adr[i]->w_handle, obj, x, y,
																	dia_adr[i]->tree[obj].ob_width + 4,
																	dia_adr[i]->tree[obj].ob_height + 4);
else
	{
	obj = -obj;
	dialog_redraw(dia_adr[i]->w_handle, ROOT, x, y,
																	dia_adr[i]->tree[obj].ob_width + 4,
																	dia_adr[i]->tree[obj].ob_height + 4);
	}
}

/* ----------------
   | Close dialog |
   ---------------- */
int dialog_close(int w_handle)
{
int i, ni;

i = search_dw(w_handle);
		
if (i == -1)
	return 0;
		
if (exclusive_wind == dia_adr[i]->w_handle)
	return 0;

if (dia_adr[i]->icon_no > -1)
	{
	ni = search_freeicon();
	
	if (ni > 0)
		{
		if (dia_adr[i]->edit_obj)
			objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
			
		dia_adr[i]->w_handle = -ni;
		new_icon(icon_no[ni - 1], dia_adr[i]->icon_txt, dia_adr[i]->icon_no, -1, -1);
		}
	else
		return 0;
	}
else
	{
	if (dia_adr[i]->edit_obj)
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);

	dia_adr[i]->w_handle = 0;
	dia_adr[i] = NULL;
	}
return 1;
}

/* -------------------------
   | Delete DIALOG by icon |
   ------------------------- */
void dialog_delete(int i_handle)
{
int i;

i = search_dw(i_handle);

if (i > -1)
	{
	dia_adr[i]->w_handle = 0;
	dia_adr[i] = NULL;
	
	if (i_handle < 0)	
		delete_icon(icon_no[(-i_handle) - 1]);
	}
}

/* ----------------
   | Close dialog |
   ---------------- */
void dialog_move(int w_handle, int flg)
{
int i, dummy;

i = search_dw(w_handle);
		
if (i == -1)
	return;

if (flg == BEG_UPDATE)		
	{
	if (dia_adr[i]->edit_obj)
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
	}
else
	if (dia_adr[i]->edit_obj)
		{
		wind_get(w_handle, WF_WORKXYWH, &dia_adr[i]->tree->ob_x, &dia_adr[i]->tree->ob_y, &dummy, &dummy);
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_INIT);
		}
}

/* -----------------------------
   | Dialog button press check |
   ----------------------------- */
void dialog_button(void)
{
int i, obj, j, c;
int w_handle, dummy, mousek, last;

wind_get(0, WF_TOP, &w_handle);

i = search_dw(w_handle);
		
if (i == -1)
	return;

wind_get(w_handle, WF_WORKXYWH, &dia_adr[i]->tree->ob_x, &dia_adr[i]->tree->ob_y, &dummy, &dummy);
obj = objc_find(dia_adr[i]->tree, 0, MAX_DEPTH, mx, my);
if (obj != -1 && !(dia_adr[i]->tree[obj].ob_state & DISABLED))
	{
	for (j = 0; j < dia_adr[i]->activ_num; j++)
		if (dia_adr[i]->activ_but[j].idx == obj)
			{
			if (dia_adr[i]->tree[obj].ob_flags & SELECTABLE)
				{
				if ((dia_adr[i]->tree[obj].ob_flags & RBUTTON) &&
					  !(dia_adr[i]->tree[obj].ob_state & SELECTED))
					{
					dummy = obj;
					do
						{
						if (dia_adr[i]->tree[dummy].ob_state & SELECTED)
							{
							dia_adr[i]->tree[dummy].ob_state &= ~SELECTED;
							xobjc_draw(dia_adr[i]->tree, dummy, 0, dia_adr[i]->tree[0].ob_x,
																							  	 dia_adr[i]->tree[0].ob_y,
																								 	 dia_adr[i]->tree[0].ob_width,
																								 	 dia_adr[i]->tree[0].ob_height);
							}
					
						last = dummy;
						dummy = dia_adr[i]->tree[dummy].ob_next;
						if (dia_adr[i]->tree[dummy].ob_tail == last)
							dummy = dia_adr[i]->tree[dummy].ob_head;
						}while(dummy != obj);
					}
					
				dia_adr[i]->tree[obj].ob_state |= SELECTED;
				xobjc_draw(dia_adr[i]->tree, obj, 0, dia_adr[i]->tree[0].ob_x,
																						 dia_adr[i]->tree[0].ob_y,
																						 dia_adr[i]->tree[0].ob_width,
																						 dia_adr[i]->tree[0].ob_height);
				}
				
			if ((dia_adr[i]->tree[obj].ob_flags & TOUCHEXIT))
				evnt_timer(100, 0);
				
			do
				{
				if (!(dia_adr[i]->tree[obj].ob_flags & TOUCHEXIT))
					do
						{
						graf_mkstate(&dummy, &dummy, &mousek, &dummy);
						}while(mousek & 1);
				else
					graf_mkstate(&dummy, &dummy, &mousek, &dummy);

				but = j + 1;				
 				if ((*dia_adr[i]->activ_but[j].rout)())
					{
					if (dia_adr[i]->edit_obj)
						objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
					
					dia_adr[i]->tree[obj].ob_state &= ~SELECTED;
					wind_close(w_handle);
					wind_delete(w_handle);
					dia_adr[i]->w_handle = 0;
					return;
					}
					
				}while(mousek == 1);				

			if (dia_adr[i]->tree[obj].ob_flags & SELECTABLE)
				{
				dia_adr[i]->tree[obj].ob_state &= ~SELECTED;
				if (!(dia_adr[i]->tree[obj].ob_flags & RBUTTON))
					{
					xobjc_draw(dia_adr[i]->tree, obj, 0, dia_adr[i]->tree[0].ob_x,
																							 dia_adr[i]->tree[0].ob_y,
																							 dia_adr[i]->tree[0].ob_width,
																							 dia_adr[i]->tree[0].ob_height);
					return;
					}
				}
			}

	for (j = 0; j < dia_adr[i]->indic_num; j++)
		if (dia_adr[i]->indic_but[j].idx == obj)
			{
			if (dia_adr[i]->tree[obj].ob_flags & RBUTTON)
				{
				if (dia_adr[i]->tree[obj].ob_state & SELECTED)
					return;
					
				dummy = obj;
				do
					{
					if (dia_adr[i]->tree[dummy].ob_state & SELECTED)
						{
						dia_adr[i]->tree[dummy].ob_state &= ~SELECTED;
						xobjc_draw(dia_adr[i]->tree, dummy, 0, dia_adr[i]->tree[0].ob_x,
																							  	 dia_adr[i]->tree[0].ob_y,
																								 	 dia_adr[i]->tree[0].ob_width,
																								 	 dia_adr[i]->tree[0].ob_height);
						}
					
					last = dummy;
					dummy = dia_adr[i]->tree[dummy].ob_next;
					if (dia_adr[i]->tree[dummy].ob_tail == last)
						dummy = dia_adr[i]->tree[dummy].ob_head;
					}while(dummy != obj);

			 	*dia_adr[i]->indic_but[j].flg = 0;
			 	c = 1;
			 	while (j - c >= 0 && 
			 		dia_adr[i]->indic_but[j].flg == 
			 		dia_adr[i]->indic_but[j - c].flg)
			 		{
			 		c++;
			 		*dia_adr[i]->indic_but[j].flg += 1;
			 		}
				}
			else
			 	*dia_adr[i]->indic_but[j].flg = (dia_adr[i]->tree[obj].ob_state & SELECTED) ^ SELECTED;
	
			dia_adr[i]->tree[obj].ob_state ^= SELECTED;
			xobjc_draw(dia_adr[i]->tree, obj, 0, dia_adr[i]->tree[0].ob_x,
																					 dia_adr[i]->tree[0].ob_y,
																					 dia_adr[i]->tree[0].ob_width,
																					 dia_adr[i]->tree[0].ob_height);
			do
				{
				graf_mkstate(&dummy, &dummy, &mousek, &dummy);
				}while(mousek & 1);
			}
	}
	
dialog_update();
}

/* ------------------------
   | Press default button |
   ------------------------ */
void dialog_default(void)
{
int i, obj, j;
int w_handle, dummy;

wind_get(0, WF_TOP, &w_handle);

i = search_dw(w_handle);
		
if (i == -1)
	return;
	
wind_get(w_handle, WF_WORKXYWH, &dia_adr[i]->tree->ob_x, &dia_adr[i]->tree->ob_y, &dummy, &dummy);
for (j = 0; j < dia_adr[i]->activ_num; j++)
	{
	obj =	dia_adr[i]->activ_but[j].idx;
	
	if (dia_adr[i]->tree[obj].ob_flags & DEFAULT)
		{
		dia_adr[i]->tree[obj].ob_state |= SELECTED;
		xobjc_draw(dia_adr[i]->tree, obj, 0, dia_adr[i]->tree[0].ob_x,
																				 dia_adr[i]->tree[0].ob_y,
																				 dia_adr[i]->tree[0].ob_width,
																				 dia_adr[i]->tree[0].ob_height);

		delay(200);

		dia_adr[i]->tree[obj].ob_state &= ~SELECTED;
		xobjc_draw(dia_adr[i]->tree, obj, 0, dia_adr[i]->tree[0].ob_x,
																				 dia_adr[i]->tree[0].ob_y,
																				 dia_adr[i]->tree[0].ob_width,
																				 dia_adr[i]->tree[0].ob_height);

		but = j + 1;				
		if ((*dia_adr[i]->activ_but[j].rout)())
			{
			if (dia_adr[i]->edit_obj)
				objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
				
			wind_close(w_handle);
			wind_delete(w_handle);
			dia_adr[i]->w_handle = 0;
			return;
			}
		else
			return;
		}
	}
}

/* --------------------
   | Edit text object |
   -------------------- */
void dialog_edit(int key)
{
int i;
int w_handle;

wind_get(0, WF_TOP, &w_handle);

i = search_dw(w_handle);
		
if (i == -1)
	return;
	
if (dia_adr[i]->edit_obj)
	{
	wind_update(BEG_UPDATE);
	
	form_keybd(dia_adr[i]->tree, dia_adr[i]->edit_obj, dia_adr[i]->next_obj, key, &dia_adr[i]->next_obj, &key);
	if (key)
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, key, &dia_adr[i]->crs_idx, ED_CHAR);

	if (dia_adr[i]->next_obj && dia_adr[i]->next_obj != dia_adr[i]->edit_obj)
		{
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_END);
		dia_adr[i]->edit_obj = dia_adr[i]->next_obj;
		dia_adr[i]->next_obj = 0;
		objc_edit(dia_adr[i]->tree, dia_adr[i]->edit_obj, 0, &dia_adr[i]->crs_idx, ED_INIT);
		}
	wind_update(END_UPDATE);
	}
}

/* ------------------------------
   | Update all changed dialogs |
   ------------------------------ */
void dialog_update(void)
{
int i;

for (i = 0; i < 20; i++)
	if (dia_adr[i])
		get_curstate(dia_adr[i]);
}

/* -------------------------------
   | Get current state of dialog |
   ------------------------------- */
void get_curstate(DIALOG *new_dia)
{
int i, c, red;

red = new_dia->w_handle;
for (i = 0; i < new_dia->indic_num; i++)
	{
	if (new_dia->indic_but[i].idx > -1)
		if (new_dia->tree[new_dia->indic_but[i].idx].ob_flags & RBUTTON)
			{
			if (!(new_dia->tree[new_dia->indic_but[i + *new_dia->indic_but[i].flg].idx].ob_state & SELECTED))
				{
				c = 0; 
				while (i + c < new_dia->indic_num && 
						 new_dia->indic_but[i].flg == new_dia->indic_but[i + c].flg)
					{
					new_dia->tree[new_dia->indic_but[i + c].idx].ob_state &= ~SELECTED;
					if (red && c != *new_dia->indic_but[i].flg)
						force_oredraw(new_dia->w_handle, new_dia->indic_but[i + c].idx);
					c++;
					}
				
				new_dia->tree[new_dia->indic_but[i + *new_dia->indic_but[i].flg].idx].ob_state |= SELECTED;
				if (red)
					force_oredraw(new_dia->w_handle, new_dia->indic_but[i + *new_dia->indic_but[i].flg].idx);
				}
			else
				{
				c = 0; 
				while (i + c < new_dia->indic_num && 
						 new_dia->indic_but[i].flg == new_dia->indic_but[i + c].flg)
					c++;
				}
				
			i += c - 1;
			}
		else	
			if (*new_dia->indic_but[i].flg != (new_dia->tree[new_dia->indic_but[i].idx].ob_state & SELECTED))
				{
				if (*new_dia->indic_but[i].flg)
					new_dia->tree[new_dia->indic_but[i].idx].ob_state |= SELECTED;
				else
					new_dia->tree[new_dia->indic_but[i].idx].ob_state &= ~SELECTED;
					
				if (red)
					force_oredraw(new_dia->w_handle, new_dia->indic_but[i].idx);
				}
	}
}

/* --------------------------
   | Okay button is pressed |
   -------------------------- */
int okay_but(void)
{
return 1;
}

/* ----------------------------
   | Cancel button is pressed |
   ---------------------------- */
int cancel_but(void)
{
return 1;
}

/* -----------------
	 | Fehlermeldung |
	 ----------------- */
int error(char *s1, char *s2, int but)
{
OBJECT *err_form;

rsrc_gaddr(R_TREE, ERRDETEC, &err_form);

err_form[ERR_TXT1].ob_spec.free_string = s1;
err_form[ERR_TXT2].ob_spec.free_string = s2;

if (but & 2)
	err_form[ERR_OK].ob_flags &= ~HIDETREE;
else
	err_form[ERR_OK].ob_flags |= HIDETREE;

if (but & 1)
	err_form[ERR_CNC].ob_flags &= ~HIDETREE;
else
	err_form[ERR_CNC].ob_flags |= HIDETREE;

if (but & 8)
	err_form[ERR_OK].ob_flags |= DEFAULT;
else
	err_form[ERR_OK].ob_flags &= ~DEFAULT;

if (but & 4)
	err_form[ERR_CNC].ob_flags |= DEFAULT;
else
	err_form[ERR_CNC].ob_flags &= ~DEFAULT;

return exclusiv_dialog(&err_dia);
}
