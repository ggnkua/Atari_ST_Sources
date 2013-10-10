#include "extern.h"

static int seq_hndl = -1;
static OBJECT *list_fm;
static long akt_seqpos;
static int name_idc[] = {SEQ_1, SEQ_2, SEQ_3, SEQ_4, SEQ_5, SEQ_6};
static long akt_lstpos;
static int name_idc2[] = {LST_1, LST_2, LST_3, LST_4, LST_5, LST_6};

int plan_select(char *path2)
{
int stat, but;
char file2[14];

strcpy(path2, path);
if (strchr(path2, '.'))
	strcpy(strrchr(path2, '.'), ".SPN");
else
	strcat(path2, ".SPN");
file2[0] = 0;

stat = fsel_input(path2, file2, &but);
if (stat && but)
	{
	strcpy(strrchr(path2, '\\') + 1, file2);
	return 1;
	}
return 0;
}

void save_plan(void)
{
char path2[141];
long fd;

if (plan_select(path2))
	{
	fd = Fcreate(path2, 0);
	
	if (fd > 0)
		{
		Fwrite((int)fd, sizeof(seq_num), &seq_num);
		Fwrite((int)fd, sizeof(lst_num), &lst_num);
		Fwrite((int)fd, sizeof(SEQUENZ) * seq_num, seq_data);
		Fwrite((int)fd, sizeof(int) * lst_num, play_list);
		Fclose((int)fd);
		}
	}
}

void load_plan(void)
{
char path2[141];
long fd;

if (plan_select(path2))
	{
	fd = Fopen(path2, 0);
	
	if (fd > 0)
		{
		Fread((int)fd, sizeof(seq_num), &seq_num);
		Fread((int)fd, sizeof(lst_num), &lst_num);
		
		if (seq_data)
			{
			free(seq_data);
			free(play_list);
			}
			
		seq_data = (SEQUENZ *)malloc(seq_num * sizeof(SEQUENZ));
		play_list = (int *)malloc(lst_num * sizeof(int));
		
		Fread((int)fd, sizeof(SEQUENZ) * seq_num, seq_data);
		Fread((int)fd, sizeof(int) * lst_num, play_list);
		Fclose((int)fd);
		}
	}
}

/* ------------------------
   | PrÅfen ob selektiert |
   ------------------------ */
int check_list(int obj, int *name_idc, long akt_pos, long max_pos)
{
int i;

for (i = 0; i < 6; i++)
	if (obj == name_idc[i] && akt_pos + i < max_pos)
		break;
			
if (i < 6)
	{
	for (i = 0; i < 6; i++)
		if (list_fm[name_idc[i]].ob_state & SELECTED)
			{
			list_fm[name_idc[i]].ob_state &= ~SELECTED;
			redraw_obj(list_fm, name_idc[i]);
			}

	list_fm[obj].ob_state |= SELECTED;
	redraw_obj(list_fm, obj);

	return 1;
	}
return 0;
}

/* ------------------------
   | Work in Sequenz list |
   ------------------------ */
void seqs_work(int mx, int my, int clicks)
{
int w_handle, obj;
int i;

wind_get(0, WF_TOP, &w_handle);
if (w_handle == seq_hndl)
	{
	obj = objc_find(list_fm, ROOT, MAX_DEPTH, mx, my);

	if (!check_list(obj, name_idc, akt_seqpos, seq_num))
		if (!check_list(obj, name_idc2, akt_lstpos, lst_num))
			switch(obj)
				{
				case SEQ_HEAR:
					press_button(list_fm, SEQ_HEAR);
					for (i = 0; i < 6; i++)
						if (list_fm[name_idc[i]].ob_state & SELECTED)
							break;
					
					if (i < 6)
						play(o_bytes + seq_data[akt_seqpos + i].pos, seq_data[akt_seqpos + i].len);
					break;

				case KEEP_PLN:
					save_plan();
					break;
					
				case LOAD_PLN:
					load_plan();
					break;
										
				case PLAY_LST:
					press_button(list_fm, PLAY_LST);
					break;
					
				case SEQ_UP:
					press_button(list_fm, SEQ_UP);
					set_seqs(-1, 1);
					break;

				case SEQ_DWN:
					press_button(list_fm, SEQ_DWN);
					set_seqs(1, 1);
					break;

				case LST_UP:
					press_button(list_fm, LST_UP);
					set_seqs(-1, 2);
					break;

				case LST_DWN:
					press_button(list_fm, LST_DWN);
					set_seqs(1, 2);
					break;
					
				case KEEP_SEQ:
					press_button(list_fm, KEEP_SEQ);
					for (i = 0; i < 6; i++)
						if (list_fm[name_idc[i]].ob_state & SELECTED)
							break;
					
					if (i < 6)
						{
						strcpy(file, seq_data[akt_seqpos + i].file);
						strcat(file, ".SEQ");
						save_part(1, o_bytes + seq_data[akt_seqpos + i].pos, seq_data[akt_seqpos + i].len);
						}
					break;
				}
				
	if (clicks == 2);
	}
}

/* ----------------------
   | Set sequence-names |
   ---------------------- */
void set_seqs(int direction, int flg)
{
long new_pos;
int i;
long max_pos, akt_pos;
int  *idc;

if (flg == 1)
	{
	max_pos = seq_num;
	idc = name_idc;
	akt_pos = akt_seqpos;
	}
else
	{
	max_pos = lst_num;
	idc = name_idc2;
	akt_pos = akt_lstpos;
	}

switch(direction)
	{
	case 0:
		akt_pos = -1;
		new_pos = 0;
		break;
	
	case 1:
		new_pos = akt_pos + 6;
		if (new_pos >= max_pos)
			new_pos = akt_pos;
		break;
		
	case -1:
		new_pos = akt_pos - 6;
		if (new_pos < 0)
			new_pos = 0;
		break;
	}

if (new_pos != akt_pos)
	{
	for (i = 0; i < 6; i++)
		{
		if (new_pos + i >= max_pos)
			list_fm[idc[i]].ob_spec.free_string = "\0";
		else
		  if (flg == 1)
				list_fm[idc[i]].ob_spec.free_string = seq_data[new_pos + i].name;
			else
				list_fm[idc[i]].ob_spec.free_string = seq_data[play_list[new_pos + i]].name;
			
		list_fm[idc[i]].ob_state &= ~SELECTED;
		}

	if (flg == 1)
		{
		redraw_obj(list_fm, SEQ_RDW);
		akt_seqpos = new_pos;
		}
	else
		{
		redraw_obj(list_fm, LST_RDW);
		akt_lstpos = new_pos;
		}
	}
}

/* ------------------------
   | Get list koordinates |
   ------------------------ */
void seqs_koor(void)
{
int w, h;

if (seq_hndl > -1)
	wind_get(seq_hndl, WF_WORKXYWH, &list_fm[ROOT].ob_x, &list_fm[ROOT].ob_y, &w, &h);
}

/* -----------------------
   | Redraw Sequenz list |
   ----------------------- */
void seqs_redraw(int wind_id)
{
int s;

if (wind_id == seq_hndl)
	{
	s = first_rect(seq_hndl, 0);
	while(s)
		{
		objc_draw(list_fm, ROOT, MAX_DEPTH, r_xy[0], r_xy[1], r_xy[2], r_xy[3]);
		s = next_rect(seq_hndl, 0);
		}
	}
}

/* ----------------------
   | Close Sequenz list |
   ---------------------- */
void seqs_close(int wind_id)
{
if (wind_id == seq_hndl || wind_id == -1)
	{
	wind_close(seq_hndl);
	wind_delete(seq_hndl);
	seq_hndl = -1;
	}
}

/* ----------------
	 | Sequenzliste |
	 ---------------- */
void seq_list(void)
{
int x, y, w, h;
int w_x, w_y, w_w, w_h;

rsrc_gaddr(R_TREE, SEQ_LST, &list_fm);

form_center(list_fm, &x, &y, &w, &h);
wind_calc(WC_BORDER, CLOSER|MOVER|NAME, x, y, w, h, &w_x, &w_y, &w_w, &w_h);
seq_hndl = open_window(CLOSER|MOVER|NAME, 0, w_y, w_w, w_h, "SEQUENZEN");

seqs_koor();
set_seqs(0, 1);
set_seqs(0, 2);
}

