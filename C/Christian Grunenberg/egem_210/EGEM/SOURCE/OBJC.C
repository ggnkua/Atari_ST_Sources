
#include <string.h>
#include "proto.h"

#ifndef SMALL_EGEM
void ob_clear_edit(reg OBJECT *obj)
{
	reg int flags;

	for (;;)
	{
		flags = obj->ob_flags;
		if (flags & EDITABLE)
			ob_get_text(obj,0,TRUE);
		if (flags & LASTOB)
			break;
		else
			obj++;
	}
}
#endif

static int ob_state(DIAINFO *info,OBJECT *tree,int obj,int masc,int set,int draw)
{
	reg OBJECT *ob_ptr;
	reg int state,old_state;

	ob_ptr = &tree[obj];
	old_state = state = ob_ptr->ob_state;

	switch (set)
	{
	case SET_STATE:
		state |= masc;
		break;
	case CLEAR_STATE:
		state &= ~masc;
		break;
	default:
		state ^= masc;
	}

	if (state!=old_state)
	{
		if (info)
		{
			if (draw)
				ob_draw_chg(info,obj,NULL,state,FALSE);
		}
		else if (draw)
		{
			wind_update(BEG_UPDATE);
			objc_change(tree,obj,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,state,1);
			wind_update(END_UPDATE);
		}
		ob_ptr->ob_state = state;
		return (TRUE);
	}
	else
		return (FALSE);
}

int ob_select(DIAINFO *info,OBJECT *tree,int obj,int select,int draw)
{
	return(ob_state(info,tree,obj,SELECTED,select,draw));
}

int ob_disable(DIAINFO *info,OBJECT *tree,int obj,int disable,int draw)
{
	reg int changed;

	if (draw && info)
	{
		if ((changed=ob_state(NULL,tree,obj,DISABLED,disable,FALSE))!=0)
			ob_draw(info,obj);
	}
	else
		changed = ob_state(info,tree,obj,DISABLED,disable,draw);
	return (changed);
}

int ob_draw(DIAINFO *info,int obj)
{
	return(ob_draw_chg(info,obj,NULL,FAIL,FALSE));
}

int ob_draw_list(reg DIAINFO *info,reg int *ob_lst,reg GRECT *area)
{
	if (info->di_flag>CLOSED && !info->di_win->iconified && _popup==0 && (_dia_len==0 || info==_dia_list[_dia_len-1]))
	{
		reg OBJECT *tree = info->di_tree;
		GRECT win,work;

		if (area)
			win = *area;
		else
			win = *(GRECT *) &tree->ob_x;

		if (rc_intersect(&desk,&win))
		{
			reg int *objs,ob;

		#ifndef SMALL_EGEM
			if (info->di_cursor)
			{
				objs = ob_lst;
				ob = info->di_ed_obj;
				while (*objs)
					if (*objs++==ob)
					{
						_cursor_off(info);
						break;
					}
			}
		#endif

			if (info->di_flag<WINDOW)
			{
				_clip_rect(&win);
				while ((ob=*ob_lst++)>0)
					objc_draw(tree,ob,MAX_DEPTH,win.g_x,win.g_y,win.g_w,win.g_h);
				_clip_rect(&desk);
			}
			else
			{
				wind_update(BEG_UPDATE);
				window_first(info->di_win,&work);
				while (work.g_w>0 && work.g_h>0)
				{
					if (rc_intersect(&win,&work))
					{
						_clip_rect(&work);

						objs = ob_lst;
						while ((ob=*objs++)>0)
							objc_draw(tree,ob,MAX_DEPTH,work.g_x,work.g_y,work.g_w,work.g_h);
					}
					window_next(info->di_win,&work);
				}
				_clip_rect(&desk);
				wind_update(END_UPDATE);
			}

			return (TRUE);
		}
	}

	return (FALSE);
}

int ob_draw_chg(DIAINFO *info,int obj,GRECT *area,int new_state,boolean top)
{
	reg OBJECT *tree = info->di_tree;
	int exit = FALSE;

	if (info->di_flag==CLOSED || info->di_win->iconified || _popup || (_dia_len>0 && info!=_dia_list[_dia_len-1]))
	{
		if (new_state>=0)
		{
			if (tree!=NULL)
				tree[obj].ob_state = new_state;
			else
				exit = FAIL;
		}
	}
	else
	{
		reg OBJECT *ob = tree + obj;
		GRECT win,work;

		if (area)
			win = *area;
		else
			win = *(GRECT *) &tree->ob_x;

		if (rc_intersect(&desk,&win))
		{
		#ifndef SMALL_EGEM
			if (info->di_cursor && (obj==info->di_ed_obj || obj==0))
				_cursor_off(info);
		#endif

			if (top || info->di_flag<WINDOW)
			{
				_clip_rect(&win);
				if (new_state>=0)
					objc_change(tree,obj,0,win.g_x,win.g_y,win.g_w,win.g_h,new_state,1);
				else
					objc_draw(tree,obj,MAX_DEPTH,win.g_x,win.g_y,win.g_w,win.g_h);
				_clip_rect(&desk);
			}
			else
			{
				int old_state = ob->ob_state;

				wind_update(BEG_UPDATE);
				window_first(info->di_win,&work);
				while (work.g_w>0 && work.g_h>0)
				{
					if (rc_intersect(&win,&work))
					{
						_clip_rect(&work);
						if (new_state>=0)
						{
							objc_change(tree,obj,0,work.g_x,work.g_y,work.g_w,work.g_h,new_state,1);
							ob->ob_state = old_state;
						}
						else
							objc_draw(tree,obj,MAX_DEPTH,work.g_x,work.g_y,work.g_w,work.g_h);
					}
					window_next(info->di_win,&work);
				}
				_clip_rect(&desk);
				wind_update(END_UPDATE);
			}
			exit = TRUE;
		}

		if (new_state>=0)
			ob->ob_state = new_state;
	}

	return (exit);
}

int ob_radio(OBJECT *tree,int parent,int object)
{
	reg int i,radio = 0,first = tree[parent].ob_head,last = tree[parent].ob_tail;
	reg OBJECT *obj;

	i = first;
	while (i>=first && i<=last)
	{
		obj = tree + i;
		if (obj->ob_flags & RBUTTON)
		{
			if (!(obj->ob_state & DISABLED))
		 	{
				if (radio==object)
					obj->ob_state |= SELECTED;
				else if (obj->ob_state & SELECTED)
				{
					if (object>=0)
						obj->ob_state &= ~SELECTED;
					else
						object = radio;
				}
			}
			radio++;
		}
		i = obj->ob_next;
	}
	return (object);
}

int ob_get_parent(OBJECT *tree,int obj)
{
	reg int index = 0,parent = 0;

	do
	{
		if (tree->ob_head<=obj && tree->ob_tail>=obj)
			parent = index;
		tree++;index++;
	}
	while (!(tree->ob_flags & LASTOB));

	return(parent);
}

int _get_hotkey(OBJECT *tree,int button)
{
	reg OBJECT *obj = &tree[button];
	reg int i,last,type;

	type = obj->ob_type & G_TYPE;
	if ((unsigned char) type!=G_USERDEF)
		type = (unsigned char) type;

	switch (type)
	{
	case G_IND:
	case G_HOTKEY:
		return (button);
	case G_CHK:
	case G_RB:
		if ((button = obj->ob_next)<0)
			return (FAIL);
		obj = &tree[button];
	case G_TEXT:
	case G_FTEXT:
	case G_BOXTEXT:
	case G_FBOXTEXT:
	case G_STRING:
	case G_BUTTON:
	case G_BOXCHAR:
		if ((i=obj->ob_head)>0)
			for (last=obj->ob_tail,obj=&tree[i];i<=last;i++,obj++)
			{
				switch (obj->ob_type & G_TYPE)
				{
				case G_IND:
				case G_HOTKEY:
					return (i);
				}
			}
	}

	return (FALSE);
}

char ob_get_hotkey(OBJECT *tree,int button)
{
	reg int obj = _get_hotkey(tree,button);

	if (obj>0)
		return(tree[obj].ob_state>>8);
	else
		return(0);
}

int ob_set_hotkey(OBJECT *tree,int button,char hot)
{
	reg int obj = _get_hotkey(tree,button);

	if (obj>0)
	{
		reg int width,parent = ob_get_parent(tree,obj);
		reg OBJECT *ob_ptr = &tree[obj],*par_ptr = &tree[parent];
		reg char *text = ob_get_text(tree,parent,FALSE),*pos;

		if (text && ((pos = strchr(text,UpperChar(hot)))!=NULL || (pos = strchr(text,LowerChar(hot)))!=NULL))
		{
			width = (int) strlen(text);

			switch((unsigned char) par_ptr->ob_type)
			{
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				if (par_ptr->ob_spec.tedinfo->te_font==SMALL)
					width *= gr_sw;
				else
					width *= gr_cw;

				switch (par_ptr->ob_spec.tedinfo->te_just)
				{
				case TE_LEFT:
					ob_ptr->ob_x = 0;
					break;
				case TE_RIGHT:
					ob_ptr->ob_x = par_ptr->ob_width - width;
					break;
				case TE_CNTR:
					ob_ptr->ob_x = (par_ptr->ob_width - width)>>1;
				}

				if (par_ptr->ob_spec.tedinfo->te_font==SMALL)
					ob_ptr->ob_x += (int) ((long) (pos - text) * gr_sw);
				else
					ob_ptr->ob_x += (int) ((long) (pos - text) * gr_cw);
				break;
			case G_BUTTON:
				width *= gr_cw;
				ob_ptr->ob_x = (par_ptr->ob_width - width)>>1;
				ob_ptr->ob_x += (int) ((long) (pos - text) * gr_cw);
				break;
			case G_STRING:
				ob_ptr->ob_x = (int) ((long) (pos - text) * gr_cw);
				break;
			default:
				return(FALSE);
			}
		}
		else if ((unsigned char) par_ptr->ob_type==G_BOXCHAR)
		{
			if (par_ptr->ob_spec.obspec.character==hot)
				ob_ptr->ob_x = (par_ptr->ob_width - gr_cw)>>1;
			else
				return(FALSE);
		}
		else if (hot) 
			return(FALSE);

		if (hot=='\0')
			ob_ptr->ob_flags |= HIDETREE;
		else
			ob_ptr->ob_flags &= ~HIDETREE;

		ob_ptr->ob_state &= 0x00ff;
		ob_ptr->ob_state |= UpperChar(hot)<<8;

		return (TRUE);
	}

	return(FALSE);
}
