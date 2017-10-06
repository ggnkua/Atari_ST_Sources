
#include "proto.h"
#include <string.h>
#include <time.h>

#define	DIF	(1+6)

static int mouse_index;
static long last_mouse;

static int mform[] = {
0x0000, 0x03C0, 0x0CF0, 0x10F8, 0x20FC, 0x20FC, 0x40FE, 0x40FE, 
0x7F02, 0x7F02, 0x3F04, 0x3F04, 0x1F08, 0x0F30, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0C30, 0x1008, 0x381C, 0x3C3C, 0x7E7E, 0x7FFE, 
0x7FFE, 0x7E7E, 0x3C3C, 0x381C, 0x1008, 0x0C30, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0F30, 0x1F08, 0x3F04, 0x3F04, 0x7F02, 0x7F02, 
0x40FE, 0x40FE, 0x20FC, 0x20FC, 0x10F8, 0x0CF0, 0x03C0, 0x0000,
0x0000, 0x03C0, 0x0FF0, 0x1FF8, 0x2FF4, 0x27E4, 0x43C2, 0x4182, 
0x4182, 0x43C2, 0x27E4, 0x2FF4, 0x1FF8, 0x0FF0, 0x03C0, 0x0000 };

static MFORM mbuf = { 7,7,1,0,1,
  {0x03C0, 0x0FF0, 0x1FF8, 0x3FFC, 0x7FFE, 0x7FFE, 0xFFFF, 0xFFFF, 
   0xFFFF, 0xFFFF, 0x7FFE, 0x7FFE, 0x3FFC, 0x1FF8, 0x0FF0, 0x03C0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};

void graf_busy_mouse(void)
{
	long time;

	if (((time=clock())-last_mouse)<20)
		return;

	last_mouse = time;
	memcpy(((int *) &mbuf)+5+16,&mform[mouse_index<<4],32);
	MouseForm(USER_DEF,&mbuf);
	mouse_index = (mouse_index+1) & 3;
}

#ifndef SMALL_NO_GRAF

typedef struct
{
	SLINFO *sl;
	GRECT view,par;
	int dist_vh,max_pos;
} SL_PARA;

static void draw_slidebox(int first,WIN *dummy,GRECT *rect,GRECT *area,void *para)
{
	reg SL_PARA *p = (SL_PARA *) para;
	reg SLINFO *sl = p->sl;
	reg OBJECT *tree = sl->sl_info->di_tree;
	GRECT work;

	if (p->max_pos>0)
	{
		work = p->par;
		if (rc_intersect(rect,&work))
			_ob_xdraw(tree,sl->sl_parent,&work);
	}
	_ob_xdraw(tree,sl->sl_slider,rect);

	if (sl->sl_view>0)
	{
		work = p->view;
		if (rc_intersect(rect,&work))
		{
			reg int dv = 0,dh = 0;
			if (sl->sl_vh)
				dv = p->dist_vh;
			else
				dh = p->dist_vh;
			if (!rc_sc_scroll(&work,dh,dv,&work))
				return;
			_ob_xdraw(tree,sl->sl_view,&work);
		}
	}
}

void graf_rt_slidebox(SLINFO *sl,int obj,int double_click,int new_pos,int new_cursor)
{
	SL_PARA para;
	XEVENT event;
	GRECT work,par;
	WIN *win;
	reg DIAINFO *info = sl->sl_info;
	reg OBJECT *ptree = info->di_tree;
	reg OBJECT *ob_ptr = ptree+sl->sl_slider,*par_ptr = ptree+sl->sl_parent;
	reg int pos,prev,max_pos,max_val,*rect,*ob;
	reg long y;
	int	start_x,start_y,delta,flag,count,index,offset = 0;
	boolean sl_mode,first = TRUE;

#ifndef SMALL_EDIT
	int on = FALSE;
#endif

	max_val = sl->sl_max - sl->sl_page;
	if (info==NULL || info->di_flag==CLOSED)
		return;

	win = info->di_win;
	if (win->iconified || (max_val<=0 && obj>0))
		return;

	if (sl->sl_view>0)
		ob_pos(ptree,sl->sl_view,&para.view);
	ob_pos(ptree,sl->sl_parent,&par);

	start_x = ob_ptr->ob_x;
	start_y = ob_ptr->ob_y;
	delta = max(sl->sl_page-1,1);

	max_pos = max((sl->sl_vh) ? (par_ptr->ob_height - ob_ptr->ob_height) : (par_ptr->ob_width - ob_ptr->ob_width),0);

	if (obj<0)
	{
		reg int cur = sl->sl_cursor,prevcur;

		if (cur<0)
			sl->sl_cursor = cur = -1;
		prevcur = cur;

		prev = pos = sl->sl_pos;

		max_val = max(max_val,0);

		switch (obj)
		{
		case SL_CRS_UP:
			if (cur<0)
				cur = sl->sl_max;
			else
				cur--;
			break;
		case SL_CRS_DN:
			cur++;
			break;
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
			pos = cur = 0;
			break;
		case SL_END:
			cur = sl->sl_max;
			pos = max_val;
			break;
		case SL_SET:
			cur = new_cursor;
			if (new_pos>=0)
				pos = new_pos;
			break;
		default:
			return;
		}

		pos = min(max(pos,0),max_val);

		if (cur<0 && obj==SL_SET)
			cur = -1;
		else
			cur = min(max(cur,0),sl->sl_max-1);

		if (cur!=prevcur)
		{
			rect = sl->sl_vh ? &work.g_y : &work.g_x;

			if (cur>=0 && obj!=SL_SET)
			{
				if (cur<pos)
					pos = cur;
				else if (cur>=pos+sl->sl_page)
					pos = cur-sl->sl_page+1;
			}

			work = para.view;
			rect[2] = sl->sl_line;

			sl->sl_cursor = cur;
			if (sl->sl_do)
				sl->sl_do(sl,ptree,prev,prev,max_val,cur,prevcur);

			if (pos==prev)
			{
				if (prevcur>=0 && cur>=0)
				{
					rect[0] += (min(cur,prevcur)-prev)*sl->sl_line;
					rect[2] = (abs(cur-prevcur)+1)*sl->sl_line;
				}
				else
					rect[0] += ((cur>=0 ? cur : prevcur)-prev)*sl->sl_line;
				if (rc_intersect(&para.view,&work))
					ob_draw_chg(info,sl->sl_view,&work,FAIL);
				return;
			}
			else
			{
				count = prev+sl->sl_page;
				rect[0] += (prevcur-prev)*sl->sl_line;
				if (prevcur>=prev && prevcur<count)
					ob_draw_chg(info,sl->sl_view,&work,FAIL);
				rect[0] += (cur-prevcur)*sl->sl_line;
				if (cur>=prev && cur<count)
					ob_draw_chg(info,sl->sl_view,&work,FAIL);
				goto _set_slider;
			}
		}
		else if (pos!=prev)
			goto _set_slider;
		else
			return;
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
	else if (max_pos==0)
		return;
	else if (obj==sl->sl_slider || double_click)
	{
		pos = (max_pos/max_val)>>1;
		prev = mouse(&event.ev_mm1x, &event.ev_mm1y);
		if (obj==sl->sl_slider)
		{
			start_x += pos - event.ev_mm1x;
			start_y += pos - event.ev_mm1y;
			double_click = 0;
		}
		else
		{
			start_x = -(par.g_x+(ob_ptr->ob_width>>1)-pos);
			start_y = -(par.g_y+(ob_ptr->ob_height>>1)-pos);
		}
		sl_mode = FAIL;
	}
	else
	{
		mouse(&start_x,&start_y);
		sl_mode = FALSE;
	}

	beg_ctrl(FALSE,FALSE,TRUE);

	memset(&event,0,sizeof(XEVENT));
	event.ev_mflags	= MU_BUTTON|MU_TIMER;
	event.ev_mbmask = 3;
	event.ev_mbclicks = 1;
	event.ev_mtlocount = sl->sl_speed;

	if (sl_mode==TRUE)
		ob_select(info,ptree,obj,TRUE,TRUE);
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
	else if (double_click)
		event.ev_mflags = MU_BUTTON;
	else
	{
		event.ev_mflags = MU_BUTTON|MU_M1;
		event.ev_mm1flags = event.ev_mm1width = event.ev_mm1height = 1;
		if (prev==0)
			event.ev_mbclicks = 258;
		MouseFlatHand();
	}

	if (sl_mode>=FALSE && !double_click)
		Event_Timer(sl->sl_delay,0,TRUE);

	do
	{
		if (double_click)
			event.ev_mtlocount = 0;
		else if (sl_mode>=FALSE && sl->sl_mode==SL_LOG)
		{
			count++;
			event.ev_mtlocount = sl->sl_speed/count;
		}

		if ((flag=Event_Multi(&event) & MU_BUTTON)!=0 && !first)
			break;
		first = FALSE;

		*(long *) &event.ev_mm1x = *(long *) &event.ev_mmox;

		if (max_val>0)
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
						offset = ++index;break;
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
				if (double_click)
					flag = TRUE;
			}
			else
				pos = prev + delta;

			pos = min(max(pos,0),max_val);

			_set_slider:
			if (pos!=prev)
			{
				reg int dif,n_pos,n_prev;

			#ifndef SMALL_EDIT
				if (!on && info->di_ed_obj==sl->sl_slider)
				{
				#ifndef SMALL_NO_HZ
					_no_edit++;
					_last_cursor = NULL;
				#endif
					_cursor_off(info);
					on = TRUE;
				}
			#endif

				sl->sl_pos = pos;

				y = pos;y *= max_pos;y /= max_val;
				n_pos = (int) y;

				y = prev;y *= max_pos;y /= max_val;
				n_prev = (int) y;

				dif = (n_pos<n_prev) ? (n_prev - n_pos + DIF) : (n_pos - n_prev + DIF);

				para.par = desk;
				rect = &para.par.g_x;
				ob = &ob_ptr->ob_x;

				if (sl->sl_vh)
				{
					rect++;
					ob++;
					*rect = par.g_y;
				}
				else
					*rect = par.g_x;

				rect[2] = dif;
				if (n_pos<n_prev)
					rect[0] += n_pos+ob[2];
				else
					rect[0] += n_prev-DIF;
				ob[0] = n_pos;

				if (sl->sl_do)
					sl->sl_do(sl,ptree,pos,prev,max_val,sl->sl_cursor,sl->sl_cursor);

				para.sl = sl;
				para.max_pos = max_pos;
				para.dist_vh = (pos-prev)*sl->sl_line;

				prev = win->vdi_handle;
				win->vdi_handle = -1;
				draw_window(win,NULL,&para,sl->sl_view>0 ? MOUSE_OFF : MOUSE_ON,draw_slidebox);
				win->vdi_handle = prev;
				graf_set_slider(sl,ptree,GRAF_SET_ARROWS|GRAF_DRAW_SLIDER);
			}
		}
	} while (!flag && obj>=0);

#ifndef SMALL_EDIT
	if (on)
	{
		ob_set_cursor(info,FAIL,0x1000,FAIL);
	#ifndef SMALL_NO_HZ
		_no_edit--;
	#endif
	}
#endif

	if (obj<0)
		return;

	if (sl_mode==TRUE)
	{
		if (sl->sl_dec<0)
			sl->sl_dec = obj;
		else
			sl->sl_inc = obj;
		ob_select(info,ptree,obj,FALSE,TRUE);
		graf_set_slider(sl,ptree,GRAF_SET_ARROWS|GRAF_DRAW_SLIDER);
	}

	NoClick();
	end_ctrl(FALSE,TRUE);
}

void graf_rt_slidecursor(SLINFO *sl,int dc)
{
	DIAINFO *info = sl->sl_info;
	OBJECT *obj;
	XEVENT event;
	int xo,yo,pos,crs,size,count = 0,o_pos,o_crs;

	if (info==NULL || sl->sl_view<=0)
		return;

	beg_ctrl(FALSE,FALSE,TRUE);
	objc_offset(obj=info->di_tree,sl->sl_view,&xo,&yo);
	obj += sl->sl_view;
	size = sl->sl_vh ? obj->ob_height : obj->ob_width;

	memset(&event,0,sizeof(XEVENT));

	event.ev_mflags = MU_BUTTON|MU_M1;
	event.ev_mbclicks = event.ev_mm1flags = event.ev_mm1width = event.ev_mm1height = 1;
	event.ev_bmask = 3;

	mouse(&event.ev_mmox,&event.ev_mmoy);

	do
	{
		event.ev_mflags |= MU_TIMER;

		crs = sl->sl_vh ? event.ev_mmoy-yo : event.ev_mmox-xo;
		pos = sl->sl_pos;

		if (crs<0)
			crs = --pos;
		else if (crs>=size)
		{
			pos++;
			crs = sl->sl_pos+sl->sl_page;
		}
		else
		{
			crs = crs/sl->sl_line+sl->sl_pos;
			event.ev_mflags ^= MU_TIMER;
			count = 0;
		}

		count++;
		if ((crs=max(min(crs,sl->sl_max-1),0))!=(o_crs=sl->sl_cursor) || pos!=(o_pos=sl->sl_pos))
		{
			graf_rt_slidebox(sl,SL_SET,FALSE,pos,crs);
			if (crs!=o_crs || pos!=o_pos)
				_send_msg(sl,0,SLIDER_CHANGED,0,0);
		}

		if (dc)
			break;

		if (sl->sl_mode<=SL_LINEAR)
			count = 1;
		event.ev_mt1locount = sl->sl_speed/count;
		*(long *) &event.ev_mm1x = *(long *) &event.ev_mmox;
	} while (!(Event_Multi(&event) & MU_BUTTON));

	NoClick();
	end_ctrl(FALSE,TRUE);
}

void graf_arrows(SLINFO *sl,OBJECT *tree,int show)
{
	graf_set_slider(sl,tree,(show) ? (GRAF_SET_ARROWS|GRAF_DRAW_SLIDER) : GRAF_SET_ARROWS);
}

void graf_set_slider(SLINFO *sl,OBJECT *tree,int show)
{
	reg DIAINFO *info = sl->sl_info;

	if (show & GRAF_SET_SIZE_POS)
	{
		GRECT old_size;
		reg OBJECT *ob_ptr,*par_ptr;
		reg long y,size;
		reg int vh = sl->sl_vh,max_val,min_size;

		Max(&sl->sl_max,0);
		Max(&sl->sl_page,1);

		max_val = max(sl->sl_max-sl->sl_page,0);
		sl->sl_pos = max(min(min_size=sl->sl_pos,max_val),0);

		if (sl->sl_do)
			sl->sl_do(sl,tree,sl->sl_pos,min_size,max_val,sl->sl_cursor,sl->sl_cursor);

		par_ptr = &tree[sl->sl_parent];
		ob_ptr = &tree[sl->sl_slider];
		old_size = *(GRECT *) &ob_ptr->ob_x;

		size = (vh) ? par_ptr->ob_height : par_ptr->ob_width;
		min_size = min(max(sl->sl_min_size,(vh) ? ob_ptr->ob_width : ob_ptr->ob_height),(int) size);

		if (max_val>0)
		{
			if (sl->sl_page>1)
			{
				size *= sl->sl_page;
				size /= sl->sl_max;
			}
			else
				size /= (max_val+1);
		}
		else if (vh)
			ob_ptr->ob_y = 0;
		else
			ob_ptr->ob_x = 0;

		if (size<min_size)
			size = min_size;

		y = sl->sl_pos;
		if (vh)
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

		if (info && (show & GRAF_DRAW_SLIDER) && (sl->sl_do!=NULL || !rc_equal(&old_size,(GRECT *) &ob_ptr->ob_x)))
		{
			ob_draw(info,sl->sl_parent);
			if (ob_ptr->ob_flags & EDITABLE)
				_inform(MOUSE_INIT);
		}
	}

	if (show & GRAF_SET_ARROWS)
	{
		show &= GRAF_DRAW_SLIDER;
		if (info==NULL)
			show = 0;

		if (sl->sl_dec>0)
			ob_disable(info,tree,sl->sl_dec,sl->sl_pos==0,show);

		if (sl->sl_inc>0)
			ob_disable(info,tree,sl->sl_inc,sl->sl_pos>=(sl->sl_max-sl->sl_page),show);
	}
}

#endif

static int last_pattern;

static void GrafRtLine(int sx,int sy,int dx,int dy)
{
	reg int pattern;

	if (sy==dy)
		pattern = (sy&1) ? 0xAAAA : 0x5555;
	else
		pattern = (sx&1)==(sy&1) ? 0x5555 : 0xAAAA;
	if (pattern!=last_pattern)
		vsl_udsty(x_handle,last_pattern=pattern);
	v_line(sx,sy,dx,dy);
}

void graf_rt_lines(int *array,boolean close)
{
	reg int sx,sy,cnt,*pxy;

	last_pattern = 0;
	_vdi_attr(MD_XOR,1,1,7);

	while ((cnt=*array++)>0)
	{
		for (pxy=array;--cnt>0;)
		{
			sx = *pxy++;sy = *pxy++;
			GrafRtLine(sx,sy,pxy[0],pxy[1]);
		}
		if (close && (pxy[0]!=array[0] || pxy[1]!=array[1]))
			GrafRtLine(pxy[0],pxy[1],array[0],array[1]);
		array = pxy+2;
	}
}

static void GrafRtObjects(int box,int *array,GRECT *clip)
{
	reg int rect[10],area[4],*pxy;

	if (box)
	{
		rc_grect_to_array((GRECT *) array,pxy=area);
		rect[0] = 4;
		rect[1] = rect[7] = *pxy++;
		rect[2] = rect[4] = *pxy++;
		rect[3] = rect[5] = *pxy++;
		rect[6] = rect[8] = *pxy;
		rect[9] = 0;
		array = rect;
	}

	_clip_rect(clip);
	graf_rt_lines(array,TRUE);
}

static void GrafRtInit(XEVENT *event,boolean move)
{
	int d;

	beg_ctrl(FALSE,FALSE,TRUE);

	memset(event,0,sizeof(XEVENT));
	event->ev_mflags = MU_BUTTON|MU_M1;
	event->ev_mbclicks = event->ev_mm1flags = event->ev_mm1width = event->ev_mm1height = 1;
	event->ev_bmask = 3;

	if ((event->ev_mmobutton=mouse(&event->ev_mmox,&event->ev_mmoy))==0)
		event->ev_mbclicks = 258;

	*(long *) &event->ev_mm1x = *(long *) &event->ev_mmox;

	if (move)
		MouseFlatHand();
	else
	{
		graf_mkstate(&d,&d,&d,&event->ev_mmokstate);
		MousePointHand();
	}

	last_pattern = 0;
}

static void GrafRtDraw(int desk_clip,int box,int *pxy)
{
	GRECT area;

	MouseOff();
	if (desk_clip && output)
	{
		wind_xget(0,WF_FIRSTXYWH,&area.g_x,&area.g_y,&area.g_w,&area.g_h);
		while (area.g_w>0 && area.g_h>0)
		{
			GrafRtObjects(box,pxy,&area);
			wind_xget(0,WF_NEXTXYWH,&area.g_x,&area.g_y,&area.g_w,&area.g_h);
		}
	}
	else
		GrafRtObjects(box,pxy,&desk);
	MouseOn();
}

static int GrafRtEvent(int desk_clip,int box,int *pxy,XEVENT *event,void (*call_func)(boolean,int *,MKSTATE *))
{
	int events;

	*(long *) &event->ev_mm1x = *(long *) &event->ev_mmox;

	if (call_func)
		call_func(TRUE,pxy,(MKSTATE *) &event->ev_mmox);

	GrafRtDraw(desk_clip,box,pxy);

	_no_output++;
	events = Event_Multi(event);
	_no_output--;

	GrafRtDraw(desk_clip,box,pxy);

	if (call_func)
		call_func(FALSE,pxy,(MKSTATE *) &event->ev_mmox);

	if (events & MU_BUTTON)
	{
		if (event->ev_mbclicks==258)
			NoClick();
		end_ctrl(FALSE,TRUE);
		return (event->ev_mmobutton==2 ? FAIL : TRUE);
	}
	return (FALSE);
}

int graf_rt_rubberbox(int desk_clip,int s_x,int s_y,int min_w,int min_h,GRECT *bound,int *r_w,int *r_h,void (*call_func)(boolean,int *,MKSTATE *))
{
	GRECT rect;
	XEVENT event;
	int max_1,max_2,exit;

	if (!rc_inside(s_x,s_y,bound))
	{
		NoClick();
		return(FALSE);
	}

	GrafRtInit(&event,FALSE);
	max_1 = min((rect.g_x=s_x)-bound->g_x-1,(rect.g_y=s_y)-bound->g_y-1);
	max_2 = min(bound->g_x+bound->g_w-s_x,bound->g_y+bound->g_h-s_y);

	do
	{
		rect.g_w = max(min(max(event.ev_mmox,bound->g_x)-rect.g_x+1,bound->g_w),min_w);
		rect.g_h = max(min(max(event.ev_mmoy,bound->g_y)-rect.g_y+1,bound->g_h),min_h);
		if (event.ev_mmokstate&(K_SHIFT|K_CTRL|K_ALT))
			rect.g_w = rect.g_h = rect.g_w>0 ? min(rect.g_w,max_2) : max(rect.g_w,-max_1);
	} while ((exit=GrafRtEvent(desk_clip,TRUE,&rect.g_x,&event,call_func))==FALSE);

	*r_w = rect.g_w;
	*r_h = rect.g_h;

	return (exit);
}

int graf_rt_dragbox(int desk_clip,GRECT *start,GRECT *bound,int *r_x,int *r_y,void (*call_func)(boolean,int *,MKSTATE *))
{
	GRECT rect;
	XEVENT event;
	int max_x,max_y,exit;

	if (!rc_inside(start->g_x,start->g_y,bound) || start->g_w>bound->g_w || start->g_h>bound->g_h)
	{
		NoClick();
		return(FALSE);
	}

	GrafRtInit(&event,TRUE);
	max_x = bound->g_x + bound->g_w - start->g_w;
	max_y = bound->g_y + bound->g_h - start->g_h;
	rect = *start;

	do
	{
		*r_x = rect.g_x = min(max(rect.g_x+event.ev_mmox-event.ev_mm1x,bound->g_x),max_x);
		*r_y = rect.g_y = min(max(rect.g_y+event.ev_mmoy-event.ev_mm1y,bound->g_y),max_y);
	} while ((exit=GrafRtEvent(desk_clip,TRUE,&rect.g_x,&event,call_func))==FALSE);

	return (exit);
}

int graf_rt_dragobjects(int desk_clip,int *objects,GRECT *bound,void (*call_func)(boolean,int *,MKSTATE *))
{
	XEVENT event;
	reg int x,y,cnt,dx,dy,*pxy;
	int max_x,max_y;

	for (x=y=0x7fff,max_x=max_y=0,pxy=objects;(cnt=*pxy++)>0;)
		while (--cnt>=0)
		{
			x = min(x,*pxy);max_x = max(max_x,*pxy++);
			y = min(y,*pxy);max_y = max(max_y,*pxy++);
		}

	max_x = bound->g_x + bound->g_w - 1 - max_x + x;
	max_y = bound->g_y + bound->g_h - 1 - max_y + y;

	if (!rc_inside(x,y,bound) || max_x<bound->g_x || max_y<bound->g_y)
	{
		NoClick();
		return(FALSE);
	}

	GrafRtInit(&event,TRUE);
	while ((cnt=GrafRtEvent(desk_clip,FALSE,objects,&event,call_func))==FALSE)
	{
		dx = min(max(x+event.ev_mmox-event.ev_mm1x,bound->g_x),max_x) - x;
		dy = min(max(y+event.ev_mmoy-event.ev_mm1y,bound->g_y),max_y) - y;
		for (pxy=objects;(cnt=*pxy++)>0;)
			while (--cnt>=0)
			{
				*pxy++ += dx;
				*pxy++ += dy;
			}
		x += dx;
		y += dy;
	}
	return (cnt);
}
