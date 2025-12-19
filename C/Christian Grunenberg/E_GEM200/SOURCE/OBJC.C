
#include <string.h>
#include "proto.h"

int ob_draw_list(reg DIAINFO *info,reg int *ob_lst,reg GRECT *area)
{
	reg OBJECT *tree = info->di_tree;
	reg int *ob,ed;

	if (info==NULL || info->di_flag<=CLOSED || info->di_win->iconified)
		return(FALSE);
	else
	{
		DIAINFO *fly;
		reg int output;

		output = get_dialog_info(NULL,NULL,&fly);
		if (output==FAIL || (output==FALSE && fly!=info))
			return(FALSE);
	}

	if (info->di_cursor)
	{
		ob = ob_lst;
		ed = info->di_ed_obj;
		while (*ob)
			if (*ob++==ed)
			{
				_cursor_off(info);
				break;
			}
	}

	if (info->di_flag<WINDOW)
	{
		reg int ob;

		if (area==NULL)
			area = (GRECT *) &tree->ob_x;
		while ((ob=*ob_lst++)>0)
			objc_draw(tree,ob,MAX_DEPTH,area->g_x,area->g_y,area->g_w,area->g_h);
	}
	else
	{
		GRECT win;

		if (area)
			win = *area;
		else
			win = *((GRECT *) &tree->ob_x);

		if (rc_intersect(&desk,&win))
		{
			GRECT work;
			reg int *objs,ob,handle = info->di_win->handle,pxy[4];
			reg GRECT *w=&work;

			wind_update(BEG_UPDATE);
			wind_xget(handle,WF_FIRSTXYWH,&w->g_x,&w->g_y,&w->g_w,&w->g_h);

			while (w->g_w>0 && w->g_h>0)
			{
				if (rc_intersect(&win,w))
				{
					rc_grect_to_array(w,pxy);
					_set_clip(pxy);

					objs = ob_lst;
					while ((ob = *objs++)>0)
						objc_draw(tree,ob,MAX_DEPTH,w->g_x,w->g_y,w->g_w,w->g_h);
				}

				wind_xget(handle,WF_NEXTXYWH,&w->g_x,&w->g_y,&w->g_w,&w->g_h);
			}

			_set_clip((int *) &clip);
			wind_update(END_UPDATE);
		}
	}

	return (TRUE);
}

int ob_draw_chg(DIAINFO *info,int obj,GRECT *area,int new_state,boolean top)
{
	reg OBJECT *tree = info->di_tree;

	if (info==NULL || info->di_flag<=CLOSED || info->di_win->iconified)
		return(FALSE);
	else
	{
		DIAINFO *fly;
		reg int output;

		output = get_dialog_info(NULL,NULL,&fly);
		if (output==FAIL || (output==FALSE && fly!=info))
			return(FALSE);
	}

	if (info->di_cursor && (obj==info->di_ed_obj || obj==0))
		_cursor_off(info);

	if (top || info->di_flag<WINDOW)
	{
		if (area==NULL)
			area = (GRECT *) &tree->ob_x;
		if (new_state>=0)
			objc_change(tree,obj,0,area->g_x,area->g_y,area->g_w,area->g_h,new_state,1);
		else
			objc_draw(tree,obj,MAX_DEPTH,area->g_x,area->g_y,area->g_w,area->g_h);
	}
	else
	{
		reg OBJECT *ob = tree + obj;
		GRECT win;

		if (area)
			win = *area;
		else
			win = *((GRECT *) &tree->ob_x);

		if (rc_intersect(&desk,&win))
		{
			reg int handle = info->di_win->handle,state = ob->ob_state,pxy[4];
			GRECT work;

			wind_update(BEG_UPDATE);
			wind_xget(handle,WF_FIRSTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);

			while (work.g_w>0 && work.g_h>0)
			{
				if (rc_intersect(&win,&work))
				{
					rc_grect_to_array(&work,pxy);
					_set_clip(pxy);
					if (new_state>=0)
					{
						objc_change(tree,obj,0,work.g_x,work.g_y,work.g_w,work.g_h,new_state,1);
						ob->ob_state = state;
					}
					else
						objc_draw(tree,obj,MAX_DEPTH,work.g_x,work.g_y,work.g_w,work.g_h);
				}
				wind_xget(handle,WF_NEXTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
			}

			if (new_state>=0)
				ob->ob_state = new_state;
			_set_clip((int *) &clip);
			wind_update(END_UPDATE);
		}
	}

	return (TRUE);
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

		if (text && ((pos = strchr(text,_upper(hot)))!=NULL || (pos = strchr(text,_lower(hot)))!=NULL))
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
		ob_ptr->ob_state |= _upper(hot)<<8;

		return (TRUE);
	}

	return(FALSE);
}
