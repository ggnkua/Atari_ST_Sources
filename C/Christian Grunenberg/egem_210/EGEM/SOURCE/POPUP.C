
#include "proto.h"
#include <string.h>

static int		ob_next(OBJECT *,int);
static int	 	ob_find(OBJECT *,int,int);
static int		do_popup(OBJECT *,boolean,int,int *);

#ifdef DEBUG
extern void _check_hotkeys(OBJECT *);
#endif

static int ob_check(OBJECT *obj)
{
	return ((obj->ob_state & DISABLED)==0 && (obj->ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE);
}

static int ob_search(OBJECT *tree,int last)
{
	reg int j;

	for (j=tree->ob_head;j<=last;j++)
		if (ob_check(&tree[j]))
			return (j);

	return (FAIL);
}

static int ob_next(OBJECT *tree,int start)
{
	reg OBJECT *obj;
	reg int i = start;

	if (start<tree->ob_head)
		start = tree->ob_head;

	do
	{
		obj = tree + i;
		if (ob_check(&tree[i]))
			return(i);
		i = obj->ob_next;
	}
	while (i>=0);

	return(FAIL);
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
	XEVENT events;

	_mouse_pos(&events.ev_mmox,&events.ev_mmoy);
	if ((current = ob_find(menu,events.ev_mmox,events.ev_mmoy))<=0)
		current = last;

	memset(&events,0,sizeof(XEVENT));
	events.ev_mflags = MU_BUTTON|MU_M1|MU_KEYBD;
	events.ev_mbstate = events.ev_mbclicks = events.ev_bmask = 1;

	for (;;)
	{
		if (current!=old)
		{
			if (old>0)
				ob_select(NULL,menu,old,CLEAR_STATE,TRUE);

			if (current>0)
				ob_select(NULL,menu,current,SET_STATE,TRUE);

			old = current;
		}

		if (objc_find(menu,ROOT,1,events.ev_mmox,events.ev_mmoy)<0)
		{
			events.ev_mm1flags = 0;
			*(GRECT *) &events.ev_mm1x = *(GRECT *) &menu->ob_x;
		}
		else
		{
			events.ev_mm1flags = events.ev_mm1width = events.ev_mm1height = 1;
			events.ev_mm1x = events.ev_mmox;
			events.ev_mm1y = events.ev_mmoy;
		}

		Event_Multi(&events);
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

		if (events.ev_mwich & MU_M1)
		{
			current = ob_find(menu,events.ev_mmox,events.ev_mmoy);
			events.ev_mm2x = events.ev_mmox;
			events.ev_mm2y = events.ev_mmoy;
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
						current = ob_search(menu,menu->ob_tail);
					else
						current = ob_next(menu,menu->ob_head);
					break;
				case 75:
				case 72:
					{
						reg int temp = FAIL;

						if (current>menu->ob_head)
							temp = ob_search(menu,current-1);

						if (temp<0 && (wrap || current<0))
							temp = ob_search(menu,menu->ob_tail);

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
	
						if ((obj=_is_hotkey(menu,scan_2_ascii(events.ev_mkreturn,events.ev_mmokstate)))>0)
						{
							if (ob_check(&menu[obj]))
							{
								if (old>0)
									ob_select(NULL,menu,old,CLEAR_STATE,TRUE);
								ob_select(NULL,menu,obj,SET_STATE,TRUE);

								Event_Timer(100,0);
	
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
	reg OBJECT *menu = popup->p_menu,*tree=(info!=NULL) ? info->di_tree : NULL;
	reg int current = FAIL,exit = FAIL,object;
	int dc = FALSE;

	MouseArrow();

	if (tree!=NULL)
	{
		object = (mode & POPUP_CYCLE) ? popup->p_cycle : popup->p_parent;
		if (object>0)
			ob_select(info,tree,object,SET_STATE,TRUE);
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
		RC_RECT area;

		_mouse_pos(&sx,&sy);
		if (tree!=NULL && popup->p_button>0)
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

		_popup++;
		_beg_ctrl();

		_rc_sc_savetree(menu,&area);
		if (!area.valid)
			form_dial(FMD_START,0,0,0,0,sx,sy,sw,sh);
		objc_draw(menu,ROOT,MAX_DEPTH,sx,sy,sw,sh);

	#ifdef DEBUG
		check_hotkeys(menu);
	#endif

		exit = do_popup(menu,popup->p_wrap,current,&dc);

		if (area.valid)
		{
			MouseOff();
			rc_sc_restore(sx,sy,&area,TRUE);
			MouseOn();
		}
		else
			form_dial(FMD_FINISH,0,0,0,0,sx,sy,sw,sh);

		_end_ctrl();
		_popup--;
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
	}

	if (tree!=NULL && object>0)
		ob_select(info,tree,object,CLEAR_STATE,TRUE);

	if (exit>0)
	{
		if (mode & POPUP_CHECK)
		{
			if (current>=0)
				menu[current].ob_state &= ~CHECKED;
			menu[exit].ob_state |= CHECKED;
		}

		if (tree!=NULL && popup->p_set && popup->p_button>0)
		{
			ob_set_text(tree,popup->p_button,ob_get_text(menu,exit,0));
			ob_draw(info,popup->p_button);
			if (popup->p_cycle>0)
				ob_draw(info,popup->p_cycle);
		}

		if (index!=NULL)
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

	_reset_mouse();

	if (exit<=0)
		return(0);
	else
		return ((dc) ? (exit|0x8000) : exit);
}
