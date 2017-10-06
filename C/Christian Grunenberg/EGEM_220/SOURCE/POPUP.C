
#include "proto.h"

#ifndef SMALL_NO_POPUP
#include <string.h>

#ifdef DEBUG
extern void _check_hotkeys(OBJECT *);
#endif

#define	CYCLE	(POPUP_CYCLE|POPUP_INVCYCLE)

static int ob_check(OBJECT *obj)
{
	return ((obj->ob_state & DISABLED)==0 && (obj->ob_flags & (SELECTABLE|HIDETREE))==SELECTABLE);
}

static int ob_search(OBJECT *tree,int first,int last_entry)
{
	reg int act = FAIL,j;

	if (last_entry<0)
		last_entry = tree->ob_tail;

	for (j=tree->ob_head;j<=last_entry;j++)
		if (ob_check(&tree[j]))
		{
			act = j;
			if (first)
				break;
		}

	return (act);
}

static int ob_next(OBJECT *tree,reg int i)
{
	reg OBJECT *obj;

	if (i<tree->ob_head || i>tree->ob_tail)
		i = tree->ob_head;

	do
	{
		obj = tree + i;
		if (ob_check(obj))
			return(i);
		i = obj->ob_next;
	}
	while (i>=0);

	return (FAIL);
}

static int ob_find(OBJECT *tree,int x,int y)
{
	reg int pos = objc_find(tree,ROOT,1,x,y);

	if (pos>0 && ob_next(tree,pos)==pos)
		return (pos);
	else
		return (FAIL);
}

static int do_popup(POPUP *pop,int mode,OBJECT *menu,int last,int *cl)
{
	int selected = POPUP_MOUSE,obj;
	reg int current,old = FAIL,ret,exitmode,but;
	XEVENT events;

	but = mouse(&events.ev_mmox,&events.ev_mmoy);
	if ((current=ob_find(menu,events.ev_mmox,events.ev_mmoy))<=0 && last>0)
	{
		current = ob_next(menu,last);
		selected = 0;
	}

	memset(&events,0,sizeof(XEVENT));
	events.ev_mflags = MU_BUTTON|MU_M1|MU_KEYBD;
	events.ev_mbmask = 3;
	events.ev_mbclicks = but ? 1 : 258;

	do
	{
		for (ret=FAIL,exitmode=FALSE;exitmode==FALSE;)
		{
			if (current!=old)
			{
				if (old>0)
					ob_select(NULL,menu,old,FALSE,TRUE);

				if (current>0)
					ob_select(NULL,menu,current,TRUE,TRUE);

				if (events.ev_mmokstate & K_SHIFT)
					selected |= POPUP_DCLICK;
				if (events.ev_mmokstate & K_CTRL)
					selected |= POPUP_RCLICK;

				if (pop->p_func && pop->p_func(pop,current,selected)==POPUP_EXIT)
				{
					ret = FAIL;
					break;
				}
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
				*(long *) &events.ev_mm1x = *(long *) &events.ev_mmox;
			}

			Event_Multi(&events);
			selected = POPUP_MOUSE;

			if (events.ev_mwich & MU_BUTTON)
			{
				ret = ob_find(menu,events.ev_mmox,events.ev_mmoy);
				break;
			}

			if (events.ev_mwich & MU_M1)
			{
				current = ob_find(menu,events.ev_mmox,events.ev_mmoy);
				*(long *) &events.ev_mm2x = *(long *) &events.ev_mmox;
			}

			if (events.ev_mwich & MU_KEYBD)
			{
				selected = 0;

				if ((char) events.ev_mkreturn==' ')
				{
					ret = current;
					break;
				}

				switch (events.ev_mkreturn>>8)
				{
				case SCANESC:
				case SCANUNDO:
					ret = FAIL;
					exitmode = TRUE;
					break;
				case SCANRET:
				case SCANENTER:
					ret = current;
					exitmode = TRUE;
					break;
				case SCANHOME:
					current = ob_search(menu,(events.ev_mmokstate & K_SHIFT)==0,FAIL);
					break;
				case SCANLEFT:
					if (mode & POPUP_SUB)
					{
						ret = FAIL;
						exitmode = TRUE;
						break;
					}
				case SCANUP:
					{
						reg int temp = FAIL;

						if (current>menu->ob_head)
							temp = ob_search(menu,FALSE,current-1);

						if (temp<0 && (pop->p_wrap || current<0))
							temp = ob_search(menu,FALSE,FAIL);

						if (temp>0)
							current = temp;
					}
					break;
				case SCANRIGHT:
					if ((mode & POPUP_PARENT) && current>0 && (menu[current].ob_flags & (EXIT|TOUCHEXIT)))
					{
						ret = current;
						exitmode = TRUE;
						break;
					}
				case SCANDOWN:
					if (current<menu->ob_tail)
					{
						if (current<0)
							current = ob_search(menu,TRUE,FAIL);
						else
						{
							int temp = ob_next(menu,menu[current].ob_next);
							if (temp>0 && temp!=current)
								current = temp;
							else if (pop->p_wrap)
								current = ob_search(menu,TRUE,FAIL);
						}
					}
					else if (pop->p_wrap)
						current = ob_search(menu,TRUE,FAIL);
					break;
				default:
					if ((obj=_is_hotkey(menu,scan_2_ascii(events.ev_mkreturn,events.ev_mmokstate)))>0 && ob_check(&menu[obj]))
					{
						if (old>0)
							ob_select(NULL,menu,old,FALSE,TRUE);
						ob_select(NULL,menu,obj,TRUE,TRUE);
						Event_Timer(100,0,TRUE);
						exitmode = TRUE;
						ret = obj;
					}
					else
						selected = POPUP_MOUSE;
				}
			}
		}

		selected |= POPUP_EXITENTRY;
		*cl = 0;
		if (ret>0)
		{
			if (events.ev_mbreturn>=2 || (events.ev_mmokstate & K_SHIFT))
			{
				selected |= POPUP_DCLICK;
				*cl = DOUBLE_CLICK;
			}
			if (events.ev_mmobutton==2 || (events.ev_mmokstate & K_CTRL))
			{
				selected |= POPUP_RCLICK;
				*cl |= RIGHT_CLICK;
			}
		}
	} while (pop->p_func && pop->p_func(pop,current=ret,selected)==POPUP_CONT);
	NoClick();
	return (ret);
}

int Popup(POPUP *popup,int mode,int center,int x,int y,int *index,int select)
{
	reg DIAINFO *info = popup->p_info;
	reg OBJECT *menu = popup->p_menu,*tree = (info!=NULL) ? info->di_tree : NULL,*obj;
	reg int current = FAIL,exit = FAIL,object;
	int cl = 0;

	menu->ob_spec.obspec.framesize = -1;
	menu->ob_state &= ~(SHADOWED|OUTLINED);
	menu->ob_flags &= ~FL3DMASK;

	if (mode & POPUP_3D)
	{
		if (has_3d)
			menu->ob_flags |= FL3DACT;
		else
			menu->ob_state |= (SHADOWED|OUTLINED);
	}
	else if ((mode & POPUP_NO_SHADOW)==0)
		menu->ob_state |= SHADOWED;

	if (tree!=NULL)
	{
		object = (mode & CYCLE) ? popup->p_cycle : popup->p_parent;
		if (object>0)
			ob_select(info,tree,object,TRUE,TRUE);
	}

	{
		reg int i;

		for (i=menu->ob_head;i<=menu->ob_tail;i++)
		{
			obj = &menu[i];
			if (obj->ob_flags & SELECTABLE)
				obj->ob_state &= ~SELECTED;

			if ((mode & POPUP_CHECK) && !(obj->ob_flags & HIDETREE))
			{
				if (i==select)
				{
					if (current>=0)
						menu[current].ob_state &= ~CHECKED;
					obj->ob_state |= CHECKED;
					current=i;
				}
				else if (obj->ob_state & CHECKED)
				{
					if (current>=0)
						obj->ob_state &= ~CHECKED;
					else
						current = i;
				}
			}
		}

		if (current<0)
			current = select;
	}

	if (!(mode & CYCLE))
	{
		int bx,by,sx,sy,sw = menu->ob_width>>1,sh = menu->ob_height>>1,dummy;
		INFOVSCR *vscr;
		RC_RECT area;

		mouse(&sx,&sy);
		if (tree && popup->p_button>0)
		{
			objc_offset(tree,popup->p_button,&bx,&by);
			if (x<=0)
				x = bx;
			if (y<=0)
				y = by;
		}

		switch (center)
		{
		case CENTER:
			form_center(menu,&dummy,&dummy,&dummy,&dummy);
			if (get_cookie(COOKIE_VSCR,(long *) &vscr) && vscr->cookie==COOKIE_VSCR)
			{
				menu->ob_x = vscr->x + (vscr->w>>1) - sw;
				menu->ob_y = vscr->y + (vscr->h>>1) - sh;
			}
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
			if (current>0)
			{
				x -= menu[current].ob_x;
				y -= menu[current].ob_y;
			}
			goto _xypos;
		case MENUPOS:
			if (tree!=NULL && popup->p_button>0)
			{
				y = by + (tree[popup->p_button].ob_height + 1);
				if ((y+menu->ob_height+3)>=max_h)
				{
					y = by - (menu->ob_height + 1);
					if (info->di_flag>=WINDOW)
						y = max(y,info->di_win->work.g_y - (menu->ob_height + 1));
				}
			}
		case XYPOS:
			_xypos:
			menu->ob_x = x;
			menu->ob_y = y;
		}

		Min(&menu->ob_x,clip.v_x2 - menu->ob_width - 3);
		Max(&menu->ob_x,clip.v_x1 + 3);
		Min(&menu->ob_y,clip.v_y2 - menu->ob_height - 3);
		Max(&menu->ob_y,clip.v_y1 + 3);

		sx = menu->ob_x - 3;
		sy = menu->ob_y - 3;
		sw = menu->ob_width + 6;
		sh = menu->ob_height + 6;

		beg_ctrl(FALSE,TRUE,TRUE);
		MouseArrow();

		_rc_sc_savetree(menu,&area);
		if (!area.valid)
		{
			if (!output)
				goto no_popup;
			form_dial(FMD_START,0,0,0,0,sx,sy,sw,sh);
		}
		_ob_xdraw(menu,0,NULL);

	#ifdef DEBUG
		check_hotkeys(menu);
	#endif

		exit = do_popup(popup,mode,menu,(mode & POPUP_MENU) ? FAIL : current,&cl);

		if (area.valid)
		{
			MouseOff();
			rc_sc_restore(sx,sy,&area,TRUE);
			MouseOn();
		}
		else
			form_dial(FMD_FINISH,0,0,0,0,sx,sy,sw,sh);

		no_popup:
		end_ctrl(TRUE,TRUE);
	}
	else
	{
		if (current>=menu->ob_head && current<=menu->ob_tail)
			exit = (mode & POPUP_INVCYCLE)==0 ? ob_next(menu,menu[current].ob_next) : ob_search(menu,FALSE,current-1);
		if (exit<0)
			exit = ob_search(menu,(mode & POPUP_INVCYCLE)==0,FAIL);
		Event_Timer(100,0,TRUE);
	}

	if (tree!=NULL && object>0)
		ob_select(info,tree,object,FALSE,TRUE);

	if (exit>0)
	{
		if (mode & POPUP_CHECK)
		{
			if (current>=0)
				menu[current].ob_state &= ~CHECKED;
			menu[exit].ob_state |= CHECKED;
		}

		if (tree && popup->p_set && popup->p_button>0)
		{
			ob_set_text(tree,popup->p_button,ob_get_text(menu,exit,0));
			ob_draw(info,popup->p_button);
			if (popup->p_cycle>0)
				ob_draw(info,popup->p_cycle);
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
	ClrKeybd();
	return (exit<=0 ? 0 : (exit|cl));
}

#endif
