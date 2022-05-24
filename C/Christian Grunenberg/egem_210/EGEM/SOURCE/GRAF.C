
#include "proto.h"
#include <string.h>
#include <time.h>

int _no_button = 0;

static void draw_rubber(int *);

static int mouse_index;
static long last_mouse;

static MFORM mouse_form[4] = {
{ 7,7,1,0,1,
  {0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 
   0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x03C0},
  {0x0000, 0x03C0, 0x0CF0, 0x10F8, 0x20FC, 0x20FC, 0x40FE, 0x40FE, 
   0x7F02, 0x7F02, 0x3F04, 0x3F04, 0x1F08, 0x0F30, 0x03C0, 0x0000}},
{ 7,7,1,0,1,
  {0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 
   0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x03C0},
  {0x0000, 0x03C0, 0x0C30, 0x1008, 0x381C, 0x3C3C, 0x7E7E, 0x7FFE, 
   0x7FFE, 0x7E7E, 0x3C3C, 0x381C, 0x1008, 0x0C30, 0x03C0, 0x0000}},
{ 7,7,1,0,1,
  {0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 
   0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x03C0},
  {0x0000, 0x03C0, 0x0F30, 0x1F08, 0x3F04, 0x3F04, 0x7F02, 0x7F02, 
   0x40FE, 0x40FE, 0x20FC, 0x20FC, 0x10F8, 0x0CF0, 0x03C0, 0x0000}},
{ 7,7,1,0,1,
  {0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 
   0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x03C0},
  {0x0000, 0x03C0, 0x0FF0, 0x1FF8, 0x2FF4, 0x27E4, 0x43C2, 0x4182, 
   0x4182, 0x43C2, 0x27E4, 0x2FF4, 0x1FF8, 0x0FF0, 0x03C0, 0x0000}}};

void graf_busy_mouse(void)
{
	long time;

	if (((time=clock())-last_mouse)<20)
		return;

	last_mouse = time;
	graf_mouse(USER_DEF,&mouse_form[mouse_index++]);
	mouse_index &= 3;
}

void graf_rt_slidebox(SLINFO *sl,int obj,int double_click)
{
	XEVENT event;
	reg DIAINFO *info = sl->sl_info;
	reg OBJECT *ptree = info->di_tree;
	reg OBJECT *ob_ptr = ptree+sl->sl_slider,*par_ptr = ptree+sl->sl_parent;
	reg int pos,prev,max_pos,max_val;
	reg long y;
	int	top,start_x,start_y,delta,flag = FALSE,count,index,offset = 0;
	boolean sl_mode;
	GRECT par;

	if (info->di_flag==CLOSED || info->di_win->iconified)
		return;

	if (info->di_flag>=WINDOW)
	{
		GRECT work;

		window_first(info->di_win,&work);
		if (work.g_w>0 && work.g_h>0)
			top = rc_equal(&info->di_win->work,&work);
		else
			return;
	}
	else
		top = TRUE;

	start_x = ob_ptr->ob_x;
	start_y = ob_ptr->ob_y;

	max_val = max(sl->sl_max - sl->sl_page,0);
	delta = max(sl->sl_page - 1,1);

	objc_offset(ptree,sl->sl_parent,&par.g_x,&par.g_y);
	par.g_w = par_ptr->ob_width;
	par.g_h = par_ptr->ob_height;

	if (sl->sl_vh)
		max_pos = par_ptr->ob_height - ob_ptr->ob_height;
	else
		max_pos = par_ptr->ob_width - ob_ptr->ob_width;

	if (obj<0)
	{
		prev = pos = sl->sl_pos;

		switch (obj)
		{
		case SL_UP:
			pos--;
			break;			
		case SL_DOWN:
			pos++;
			break;
		case SL_PG_UP:
			pos -= delta;
			break;
		case SL_PG_DN:
			pos += delta;
			break;
		case SL_START:
			pos = 0;
			break;
		case SL_END:
			pos = max_val;
			break;
		default:
			return;
		}

		goto _set_slider;
	}
	else if (obj==sl->sl_dec || obj==sl->sl_inc)
	{
		sl_mode = TRUE;
		count = index = 0;
		if (obj==sl->sl_dec)
			sl->sl_dec = FAIL;
		else
			sl->sl_inc = FAIL;
	}
	else if (obj==sl->sl_slider)
	{
		_mouse_pos(&event.ev_mm1x, &event.ev_mm1y);
		start_x -= event.ev_mm1x;
		start_y -= event.ev_mm1y;
		sl_mode = FAIL;
		double_click = 0;
	}
	else
	{
		_mouse_pos(&start_x, &start_y);
		sl_mode = FALSE;
		double_click = 0;
	}

	_beg_ctrl();

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags	= MU_BUTTON|MU_TIMER;
	event.ev_mbmask = 3;
	event.ev_mbclicks = 1;
	event.ev_mtlocount = sl->sl_speed;

	if (sl_mode==TRUE)
		ob_select(info,ptree,obj,SET_STATE,TRUE);
	else if (sl_mode==FALSE)
	{
		if (sl->sl_vh)
		{
			if (start_y<par.g_y + ob_ptr->ob_y)
				delta = -delta;
		}
		else if (start_x<(par.g_x+ob_ptr->ob_x))
			delta = -delta;
	}
	else
	{
		event.ev_mflags = MU_BUTTON|MU_M1;
		event.ev_mm1flags = event.ev_mm1width = event.ev_mm1height = 1;

		MouseFlatHand();
	}

	if (sl_mode>=FALSE)
		Event_Timer(sl->sl_delay,0);

	do
	{
		if (sl_mode>=FALSE && sl->sl_mode==SL_LOG)
		{
			count++;
			event.ev_mtlocount = sl->sl_speed/count;
		}

		_no_button++;
		flag = Event_Multi(&event) & MU_BUTTON;
		_no_button--;

		event.ev_mm1x = event.ev_mmox;
		event.ev_mm1y = event.ev_mmoy;

		if (max_pos>0)
		{
			prev = sl->sl_pos;

			if (sl_mode==TRUE)
			{
				if (double_click)
				{
					if (sl->sl_dec<0)
						pos = 0;
					else
						pos = max_val;
					flag = TRUE;
				}
				else
				{
					switch (sl->sl_mode)
					{
					case SL_EXP:
						offset += ++index;
						break;
					case SL_LOG:
						offset = ++index;
						break;
					case SL_STEP:
						flag = TRUE;
					default:
						offset = 1;
					}

					if (sl->sl_dec<0)
						pos = prev - offset;
					else
						pos = prev + offset;

					if (pos<0 || pos>max_val)
						flag = TRUE;
				}
			}
			else if (sl_mode==FAIL)
			{
				if (sl->sl_vh)
					pos = start_y + event.ev_mm1y;
				else
					pos = start_x + event.ev_mm1x;
				y = pos; y *= max_val; y /= max_pos;
				pos = (int) y;
			}
			else
				pos = prev + delta;

			_set_slider:
			pos = min(max(pos,0),max_val);

			if (pos!=prev)
			{
				reg GRECT area = par;
				reg int dif,n_pos,n_prev;

				sl->sl_pos = pos;

				y = pos;y *= max_pos;y /= max_val;
				n_pos = (int) y;

				y = prev;y *= max_pos;y /= max_val;
				n_prev = (int) y;

				dif = (n_pos < n_prev) ? (n_prev - n_pos + 1) : (n_pos - n_prev + 1);

				if (sl->sl_vh)
				{
					area.g_h = dif;
					if (n_pos<n_prev)
						area.g_y += n_pos + ob_ptr->ob_height;
					else
						area.g_y += n_prev - 1;
					ob_ptr->ob_y = n_pos;
				}
				else
				{
					area.g_w = dif;
					if (n_pos<n_prev)
						area.g_x += n_pos + ob_ptr->ob_width;
					else
						area.g_x += n_prev - 1;
					ob_ptr->ob_x = n_pos;
				}

				if (sl->sl_do)
					sl->sl_do(ob_ptr,pos,prev,max_val,top);

				ob_draw_chg(info,sl->sl_slider,NULL,FAIL,top);
				ob_draw_chg(info,sl->sl_parent,&area,FAIL,top);

				graf_set_slider(sl,ptree,GRAF_SET_ARROWS|GRAF_DRAW_SLIDER);
			}

			if (obj<0)
				return;
		}
	} while (flag==FALSE);

	if (sl_mode==TRUE)
	{
		if (sl->sl_dec<0)
			sl->sl_dec = obj;
		else
			sl->sl_inc = obj;
		ob_select(info,ptree,obj,CLEAR_STATE,TRUE);
		graf_set_slider(sl,ptree,GRAF_SET_ARROWS|GRAF_DRAW_SLIDER);
	}
	else
		MouseArrow();

	_no_click();
	_end_ctrl();
}

void graf_arrows(SLINFO *sl,OBJECT *tree,int show)
{
	graf_set_slider(sl,tree,(show) ? (GRAF_SET_ARROWS|GRAF_DRAW_SLIDER) : GRAF_SET_ARROWS);
}

void graf_set_slider(SLINFO *sl,OBJECT *tree,int show)
{
	if (show & GRAF_SET_SIZE_POS)
	{
		reg OBJECT *ob_ptr,*par_ptr;
		reg long y = sl->sl_pos,size;
		reg int vh = sl->sl_vh,max_val = sl->sl_max - sl->sl_page;

		par_ptr = tree+sl->sl_parent;
		ob_ptr = tree+sl->sl_slider;

		if (sl->sl_page>1)
		{
			size = (vh==VERT_SLIDER) ? par_ptr->ob_height : par_ptr->ob_width;

			if (max_val>0)
			{
				size *= sl->sl_page;
				size /= sl->sl_max;
			}
			else if (vh==VERT_SLIDER)
				ob_ptr->ob_y = 0;
			else
				ob_ptr->ob_x = 0;
		}
		else
			size = (vh==VERT_SLIDER) ? ob_ptr->ob_height : ob_ptr->ob_width;

		if (size<gr_ch)
			size = gr_ch;

		if (vh==VERT_SLIDER)
		{
			ob_ptr->ob_height = (int) size;

			if (max_val>0)
			{
				y *= (par_ptr->ob_height - (int) size);
				y /= max_val;
				ob_ptr->ob_y = (int) y;
			}
		}
		else
		{
			ob_ptr->ob_width = (int) size;

			if (max_val>0)
			{
				y *= (par_ptr->ob_width - (int) size);
				y /= max_val;
				ob_ptr->ob_x = (int) y;
			}
		}

		if (show & GRAF_DRAW_SLIDER)
			ob_draw(sl->sl_info,sl->sl_parent);
	}

	if (show & GRAF_SET_ARROWS)
	{
		show &= GRAF_DRAW_SLIDER;

		if (sl->sl_dec>0)
			ob_disable(sl->sl_info,tree,sl->sl_dec,(sl->sl_pos>0) ? CLEAR_STATE : SET_STATE,show);

		if (sl->sl_inc>0)
			ob_disable(sl->sl_info,tree,sl->sl_inc,(sl->sl_pos<(sl->sl_max-sl->sl_page)) ? CLEAR_STATE : SET_STATE,show);
	}
}

int graf_rt_rubberbox(int s_x,int s_y,GRECT *rect,int *r_w,int *r_h,void (*call_func)(int *new_rect))
{
	XEVENT event;
	reg int pxy[4],rect_xy[4];
	reg int events,max_1,max_2,dif;

	if (!rc_inside(s_x,s_y,rect))
		return(FALSE);

	rc_grect_to_array(rect,rect_xy);

	pxy[0] = s_x;
	pxy[1] = s_y;

	max_1 = min(s_x - rect_xy[0],s_y - rect_xy[1]);
	max_2 = min(rect_xy[2] - s_x,rect_xy[3] - s_y);

	_vdi_attr(MD_XOR,1,1);
	vsl_type(x_handle,7);

	_beg_ctrl();	
	MousePointHand();

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags = MU_BUTTON|MU_M1;
	event.ev_mbclicks = event.ev_mm1flags = event.ev_mm1width = event.ev_mm1height = event.ev_mmokstate = 1;
	event.ev_bmask = 3;

	_mouse_pos(&event.ev_mm1x,&event.ev_mm1y);

	do
	{
		pxy[2] = max(event.ev_mm1x,rect_xy[0]);
		Min(pxy+2,rect_xy[2]);

		pxy[3] = max(event.ev_mm1y,rect_xy[1]);
		Min(pxy+3,rect_xy[3]);

		if (event.ev_mmokstate)
		{
			dif = pxy[2] - pxy[0];
			dif = (dif>0) ? min(dif,max_2) : max(dif,-max_1);
			pxy[2] = pxy[0] + dif;
			pxy[3] = pxy[1] + dif;
		}

		draw_rubber(pxy);

		if (call_func)
			call_func(pxy);

		_no_button++;
		events = Event_Multi(&event);
		_no_button--;

		if (events & MU_M1)
		{
			event.ev_mm1x = event.ev_mmox;
			event.ev_mm1y = event.ev_mmoy;
		}

		draw_rubber(pxy);
	}
	while(!(events & MU_BUTTON));

	vsl_udsty(x_handle,0x5555);
	vsl_type(x_handle,1);

	MouseArrow();
	_end_ctrl();	

	*r_w = pxy[2] - pxy[0];
	*r_h = pxy[3] - pxy[1];

	return(TRUE);
}

static void draw_rubber(reg int *pxy)
{
	MouseOff();
	vsl_udsty(x_handle,(pxy[0] & 1) == (pxy[1] & 1) ? 21845 : (int) 43690L);
	_line(pxy[0],pxy[1],pxy[0],pxy[3]);
	
	vsl_udsty(x_handle,(pxy[2] & 1) == (pxy[1] & 1) ? 21845 : (int) 43690L);
	_line(pxy[2],pxy[1],pxy[2],pxy[3]);

	vsl_udsty(x_handle,(pxy[1] & 1) ? (int) 43690L : 21845);
	_line(pxy[0],pxy[1],pxy[2],pxy[1]);
	
	vsl_udsty(x_handle,(pxy[3] & 1) ? (int) 43690L : 21845);
	_line(pxy[0],pxy[3],pxy[2],pxy[3]);
	MouseOn();
}
