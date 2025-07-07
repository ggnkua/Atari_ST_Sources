
#include "proto.h"

static int		ob_next(OBJECT *,int);
static void 	ob_change(OBJECT *,int,int);
static int	 	ob_find(OBJECT *,int,int);
static int		do_popup(OBJECT *,boolean,int,int *);

static int ob_next(OBJECT *tree,int start)
{
	reg OBJECT *obj;
	reg int i = start;

	if (start<tree->ob_head)
		start=tree->ob_head;
	do
	{
		obj = tree + i;
		if ((obj->ob_state & DISABLED)==0 && (obj->ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
			return(i);
		i = obj->ob_next;
	}
	while (i>=0);
	return(FAIL);
}

static void ob_change(OBJECT *tree,int obj,int newstate)
{
	reg OBJECT *ob = tree + obj;
	int x,y;

	objc_offset(tree,obj,&x,&y);
	objc_change(tree,obj,0,x,y,ob->ob_width,ob->ob_height,newstate,1);
}

static int ob_find(OBJECT *tree,int x,int y)
{
	reg int pos = objc_find(tree,ROOT,1,x,y);

	if (pos>0 && ob_next(tree,pos)==pos)
		return(pos);
	else
		return(FAIL);
}

static int do_popup(OBJECT *menu,boolean wrap,int last,int *dc)
{
	reg int current,old = FAIL,ret = FAIL;

	EVENT events =
	{
		MU_BUTTON | MU_M1 | MU_M2 | MU_KEYBD,
		1,1,1,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0,0,0,0,
		{0,0,0,0,0,0,0,0}
	};

	_mouse_pos(&events.ev_mmox,&events.ev_mmoy);
	if ((current = ob_find(menu,events.ev_mmox,events.ev_mmoy))<=0)
		current = last;

	for (;;)
	{
		reg int mpos;

		if (current!=old)
		{
			if (old>0)
				ob_change(menu,old,menu[old].ob_state & (~SELECTED));
			
			if (current>0)
				ob_change(menu,current,menu[current].ob_state | SELECTED);

			old = current;
		}

		if ((mpos = objc_find(menu,ROOT,1,events.ev_mmox,events.ev_mmoy)) < 0)
		{
			events.ev_mm1flags	= 0;
			events.ev_mm1x		= menu->ob_x;
			events.ev_mm1y		= menu->ob_y;
			events.ev_mm1width	= menu->ob_width;
			events.ev_mm1height	= menu->ob_height;
			events.ev_mflags	&= ~MU_M2;
		}
		else
		{
			events.ev_mm1flags	= 1;
			objc_offset(menu,mpos,&events.ev_mm1x,&events.ev_mm1y);
			events.ev_mm1width	= menu[mpos].ob_width;
			events.ev_mm1height	= menu[mpos].ob_height;
			events.ev_mm2x		= events.ev_mmox;
			events.ev_mm2y		= events.ev_mmoy;
			events.ev_mflags	|= MU_M2;
		}
		
		events.ev_mwich = Event_Multi(&events,0);
		if (events.ev_mwich & MU_BUTTON)
		{
			if (!(events.ev_mmobutton & 1))
			{
				ret = ob_find(menu,events.ev_mmox,events.ev_mmoy);
				break;
			}
			else
				events.ev_mbstate = 0;
		}

		if (events.ev_mwich & (MU_M1|MU_M2))
		{
			current = ob_find(menu,events.ev_mmox,events.ev_mmoy);
			
			if (events.ev_mwich & MU_M2)
			{
				events.ev_mm2x = events.ev_mmox;
				events.ev_mm2y = events.ev_mmoy;
			}
		}
		
		if (events.ev_mwich & MU_KEYBD)
		{
			int exitmode = FALSE;

			switch (events.ev_mkreturn & 0x00ff)
			{
			case 13:
			case 32:
				ret = current;
				exitmode = TRUE;
				break;
			case 27:
				ret = FAIL;
				exitmode = TRUE;
			}

			if (exitmode==FALSE)
			{
				switch (events.ev_mkreturn>>8)
				{
				case 97:
					ret = FAIL;
					exitmode = TRUE;
					break;
				case 71:
					if (events.ev_mmokstate & 3)
					{
						reg int j;
	
						for (j=menu->ob_head;j<=menu->ob_tail;j++)
							if ((menu[j].ob_state & DISABLED)==0 && (menu[j].ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
								 current = j;
					}
					else
						current = ob_next(menu,menu->ob_head);
					break;
				case 75:
				case 72:
					{
						reg int j,temp = FAIL;

						if (current>menu->ob_head)
						{
							for (j=menu->ob_head;j<current;j++)
								if ((menu[j].ob_state & DISABLED)==0 && (menu[j].ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
									 temp = j;
						}

						if (temp<0 && (wrap || current<0))
						{
							for (j=menu->ob_head;j<=menu->ob_tail;j++)
								if ((menu[j].ob_state & DISABLED)==0 && (menu[j].ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
									 temp = j;
						}

						if (temp>0)
							current = temp;
					}
					break;
				case 77:
				case 80:
					if (current<menu->ob_tail)
					{
						if (current<0)
							current = ob_next(menu,menu->ob_head);
						else
						{
							int temp = ob_next(menu,menu[current].ob_next);
							if (temp>0 && temp!=current)
								current = temp;
							else
								current = ob_next(menu,menu->ob_head);
						}
					}
					else if (wrap)
						current = ob_next(menu,menu->ob_head);
					break;
				default:
					{
						int obj;
	
						if ((obj=_is_hotkey(menu,events.ev_mkreturn,events.ev_mmokstate))>0)
						{
							if ((menu[obj].ob_state & DISABLED)==0 && (menu[obj].ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
							{
								if (old>0)
									ob_change(menu,old,menu[old].ob_state & (~SELECTED));
								ob_change(menu,obj,menu[obj].ob_state | SELECTED);
								evnt_timer(150,0);
	
								exitmode = TRUE;
								ret = obj;
							}
						}
					}
				}
			}

			if (exitmode)
				break;
		}
	}

	if (ret>0)
		*dc = (events.ev_mbreturn>=2 || (events.ev_mmokstate & 3));
	return (ret);
}

int Popup(POPUP *popup,int mode,int center,int x,int y,int *index,int select)
{
	reg DIAINFO *info = popup->p_info;
	reg OBJECT	*menu = popup->p_menu,*tree = info->di_tree;
	reg int current = FAIL,exit = FAIL,object;
	int dc = FALSE;

	graf_mouse(ARROW,NULL);

	if (info)
	{
		object = (mode & POPUP_CYCLE) ? popup->p_cycle : popup->p_parent;
		if (object>0)
			ob_draw_chg(info,object,NULL,tree[object].ob_state|SELECTED,FALSE);
	}

	{
		reg int i;

		for (i=menu->ob_head;i<=menu->ob_tail;i++)
		{
			if (menu[i].ob_flags & SELECTABLE)
				menu[i].ob_state &= ~SELECTED;

			if (!(menu[i].ob_flags & HIDETREE))
			{
				if (i==select)
				{
					if (mode & POPUP_CHECK)
						menu[i].ob_state |= CHECKED;
					if (current>=0)
						menu[current].ob_state &= ~CHECKED;
					current=i;
				}
				else if (menu[i].ob_state & CHECKED)
				{
					if (!(mode & POPUP_CHECK) || current>=0)
						menu[i].ob_state &= ~CHECKED;
					else
						current = i;
				}
			}
		}
	}

	if (!(mode & POPUP_CYCLE))
	{
		int sx,sy,sw = menu->ob_width>>1,sh = menu->ob_height>>1,dummy;
		long mem = 0l;
		MFDB dial;

		_mouse_pos(&sx,&sy);
		if (info && popup->p_button>0)
		{
			int bx,by;
			objc_offset(tree,popup->p_button,&bx,&by);
			if (x<=0)
				x = bx;
			if (y<=0)
				y = by;
		}

		switch (center)
		{
		case CENTER:
			{
				INFOVSCR *vscr;

				form_center(menu,&dummy,&dummy,&dummy,&dummy);
				if (get_cookie(COOKIE_VSCR,(long *) &vscr) && (vscr->cookie==COOKIE_XBRA))
				{
					menu->ob_x = vscr->x + (vscr->w>>1) - sw;
					menu->ob_y = vscr->y + (vscr->h>>1) - sh;
				}
			}
			break;
		case XYPOS:
			menu->ob_x = x;
			menu->ob_y = y;
			break;
		case MOUSEPOS:
			menu->ob_x = sx - sw;
			menu->ob_y = sy - sh;
			break;
		case XPOS:
			menu->ob_x = x;
			menu->ob_y = sy - sh;
			break;
		case YPOS:
			menu->ob_x = sx - sw;
			menu->ob_y = y;
			break;
		case OBJPOS:
			menu->ob_x = x;
			menu->ob_y = y;
			if (current>=0)
			{
				menu->ob_x -= menu[current].ob_x;
				menu->ob_y -= menu[current].ob_y;
			}
		}

		Min(&menu->ob_x,clip.v_x2 - menu->ob_width - 3);
		Max(&menu->ob_x,clip.v_x1 + 3);
		Min(&menu->ob_y,clip.v_y2 - menu->ob_height - 3);
		Max(&menu->ob_y,clip.v_y1 + 3);

		sx = menu->ob_x - 3;
		sy = menu->ob_y - 3;
		sw = menu->ob_width + 6;
		sh = menu->ob_height + 6;

		_beg_ctrl();
		mfdb(&dial,NULL,sw,sh,0,planes);
		
		{
			reg long len = mfdb_size(&dial);

			if ((long) Malloc(-1l)>(len+4096l))
			{
				if ((mem = (long) Malloc(len+256l))>0l)
				{
					dial.fd_addr	= (int *) ((mem & 0xfffffffel) + 2);
					_bitblt(menu,&dial,TRUE);
					goto draw_popup;
				}
			}
		}

		form_dial(FMD_START,sx,sy,sw,sh,sx,sy,sw,sh);
		
		draw_popup:
		objc_draw(menu,ROOT,MAX_DEPTH,sx,sy,sw,sh);
		exit = do_popup(menu,popup->p_wrap,current,&dc);

		if (mem)
		{
			_bitblt(menu,&dial,FALSE);
			Mfree((void *) mem);
		}
		else
			form_dial(FMD_FINISH,sx,sy,sw,sh,sx,sy,sw,sh);
		_end_ctrl();
	}
	else
	{
		if (current<0 || current>=menu->ob_tail)
			exit = ob_next(menu,menu->ob_head);
		else
		{
			int temp = ob_next(menu,menu[current].ob_next);
			exit = (temp>0) ? temp : ob_next(menu,menu->ob_head);
		}
		evnt_timer(50,0);
	}

	if (info && object>0)
		ob_draw_chg(info,object,NULL,tree[object].ob_state & (~SELECTED),FALSE);

	if (exit>0)
	{
		if (mode & POPUP_CHECK)
		{
			if (current>=0)
				menu[current].ob_state &= ~CHECKED;
			menu[exit].ob_state |= CHECKED;
		}

		if (info && popup->p_set && popup->p_button>0)
		{
			ob_set_text(tree,popup->p_button,ob_get_text(menu,exit,0));
			ob_draw_chg(info,popup->p_button,NULL,FAIL,FALSE);
			if (popup->p_cycle>0)
				ob_draw_chg(info,popup->p_cycle,NULL,FAIL,FALSE);
		}

		if (index)
		{
			reg int i = 1,radio = 0;

			do
			{
				if ((menu[i].ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE)
				{
					if (i==exit)
					{
						*index = radio;
						break;
					}
					radio++;
				}
				i = menu[i].ob_next;
			} while (i>=0);
		}
	}

	if (exit<=0)
		return(0);
	else
		return ((dc) ? (exit|0x8000) : exit);
}
