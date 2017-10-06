
#include <string.h>
#include "proto.h"

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

OBJECT *ob_copy_tree(OBJECT *tree)
{
	OBJECT *new;
	TEDINFO *nted;
	reg OBJECT *obj=tree;
	reg TEDINFO *ted;
#ifndef SMALL_NO_XTEXT
	reg X_TEXT *xtxt;
#endif
	reg char *d,*s;
	reg long size=0,strsize=0;
	reg	int i;

	for (;;)
	{
		size += sizeof(OBJECT);
		switch ((unsigned char) obj->ob_type)
		{
		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			ted = obj->ob_spec.tedinfo;
			strsize += sizeof(TEDINFO);
			strsize += ted->te_txtlen*2+ted->te_tmplen+3+1;
			strsize &= ~1;
			break;
		case G_STRING:
		case G_TITLE:
		case G_BUTTON:
			strsize += strlen(obj->ob_spec.free_string)+1+1;
			strsize &= ~1;
			break;
	#ifndef SMALL_NO_XTEXT
		case G_USERDEF:
			if ((obj->ob_type&G_TYPE)==G_XTEXT)
			{
				strsize += sizeof(X_TEXT);
				strsize += strlen(((X_TEXT *) obj->ob_spec.userblk->ub_parm)->string)+1+1;
				strsize &= ~1;
			}
	#endif
		}
		if (obj->ob_flags & LASTOB)
			break;
		obj++;
	}

	if ((new=(OBJECT *) calloc(1,size+strsize))!=NULL)
		for (memcpy(obj=new,tree,size),nted=(TEDINFO *) (((char *) new)+size);;)
		{
			switch ((unsigned char) obj->ob_type)
			{
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				ted = obj->ob_spec.tedinfo;
				obj->ob_spec.tedinfo = nted;
				*nted = *ted;
				nted->te_ptext = d = (char *) &nted[1];
				for (s=ted->te_ptext,i=ted->te_txtlen;--i>=0;*d++=*s++);
				nted->te_ptmplt = d;
				for (s=ted->te_ptmplt,i=ted->te_tmplen;--i>=0;*d++=*s++);
				nted->te_pvalid = d;
				for (s=ted->te_pvalid,i=ted->te_txtlen;--i>=0;*d++=*s++);
				nted = (TEDINFO *) ((long) (d+1) & ~1);
				break;
			case G_STRING:
			case G_TITLE:
			case G_BUTTON:
				obj->ob_spec.free_string = d = strcpy((char *) nted,obj->ob_spec.free_string);
				nted = (TEDINFO *) ((long) (d+strlen(d)+1+1) & ~1);
		#ifndef SMALL_NO_XTEXT
				break;
			case G_USERDEF:
				if ((obj->ob_type&G_TYPE)==G_XTEXT)
				{
					*(xtxt=(X_TEXT *) nted) = *(X_TEXT *) obj->ob_spec.userblk->ub_parm;
					(obj->ob_spec.userblk=&xtxt->text_blk)->ub_parm = (long) xtxt;
					d = (char *) &xtxt[1];
					xtxt->string = strcpy(d,xtxt->string);
					nted = (TEDINFO *) ((long) (d+strlen(d)+1+1) & ~1);
				}
		#endif
			}
			if (obj->ob_flags & LASTOB)
				break;
			obj++;
		}
	return (new);
}

void ob_hide(OBJECT *tree,int obj,int hide)
{
	tree += obj;
	if (hide)
		tree->ob_flags |= HIDETREE;
	else
		tree->ob_flags &= ~HIDETREE;
}

void ob_dostate(OBJECT *tree, int obj, int state)
{
	tree[obj].ob_state |= state;
}

void ob_undostate(OBJECT *tree, int obj, int state)
{
	tree[obj].ob_state &= ~state;
}

int ob_isstate(OBJECT *tree,int obj,int state)
{
	return ((tree[obj].ob_state & state)==state ? TRUE : FALSE);
}

void ob_doflag(OBJECT *tree,int obj,int flag)
{
	tree[obj].ob_flags |= flag;
}

void ob_undoflag(OBJECT *tree,int obj,int flag)
{
	tree[obj].ob_flags &= ~flag;
}

int ob_isflag(OBJECT *tree,int obj,int flag)
{
	return ((tree[obj].ob_flags & flag)==flag ? TRUE : FALSE);
}

void ob_xywh(OBJECT *tree,int obj,GRECT *rec)
{
	*rec = *(GRECT *) &tree[obj].ob_x;
}

void ob_pos(OBJECT *tree,int obj,GRECT *rec)
{
	objc_offset(tree,obj,&rec->g_x,&rec->g_y);
	*(long *) &rec->g_w = *(long *) &tree[obj].ob_width;
}

static char **typetest(OBJECT *tree,int obj)
{
	reg OBJECT *t = &tree[obj];
#ifndef SMALL_NO_XTEXT
	reg int ot;

	switch ((unsigned char) (ot=t->ob_type))
#else
	switch ((unsigned char) t->ob_type)
#endif
	{
	case G_TEXT:
	case G_FTEXT:
	case G_BOXTEXT:
	case G_FBOXTEXT:
		return &(t->ob_spec.tedinfo->te_ptext);
	case G_ICON:
		return &(t->ob_spec.iconblk->ib_ptext);
	case G_STRING:
	case G_BUTTON:
	case G_TITLE:
		return &(t->ob_spec.free_string);
	default:
	#ifndef SMALL_NO_XTEXT
		if ((ot & G_TYPE)==G_XTEXT)
			return &(get_xtext(t,0)->string);
		else
	#endif
			return (NULL);
	}
}

char *ob_get_text(OBJECT *tree,int obj,int clear)
{
	reg char **text;

	if ((text=typetest(tree,obj))!=NULL)
	{
		if (clear)
			**text = '\0';
		return (*text);
	}
	else
		return (NULL);
}

void ob_set_text(OBJECT *tree,int obj,char *text)
{
	reg char **te;

	if ((te=typetest(tree,obj))!=NULL)
		*te = text;
}

void _ob_xdraw(OBJECT *tree,int obj,GRECT *work)
{
	reg OBJECT *ob = &tree[obj];
	if (work==NULL)
		work = &desk;
	if ((unsigned char) ob->ob_type==G_USERDEF || ob->ob_head>0)
		_clip_rect(work);
	objc_draw(tree,obj,MAX_DEPTH,work->g_x,work->g_y,work->g_w,work->g_h);
}

void ob_draw_dialog(OBJECT *tree,int x,int y,int w,int h)
{
	GRECT t;

	form_center(tree,&t.g_x,&t.g_y,&t.g_w,&t.g_h);
	form_dial(FMD_START,t.g_x,t.g_y,t.g_w,t.g_h,t.g_x,t.g_y,t.g_w,t.g_h);
	if (w>0 && h>0)
		form_dial(FMD_GROW,x,y,w,h,t.g_x,t.g_y,t.g_w,t.g_h);
	_ob_xdraw(tree,0,&t);
}

void ob_undraw_dialog(OBJECT *tree,int x,int y,int w,int h)
{
	int tx,ty,tw,th;

	form_center(tree,&tx,&ty,&tw,&th);
	if (w>0 && h>0)
		form_dial(FMD_SHRINK,tx,ty,tw,th,x,y,w,h);
	form_dial(FMD_FINISH,tx,ty,tw,th,tx,ty,tw,th);
}

static int ob_state(DIAINFO *info,OBJECT *tree,int obj,int masc,int set,int draw)
{
	reg OBJECT *ob_ptr;
	reg int state,old_state;

	ob_ptr = &tree[obj];
	old_state = state = ob_ptr->ob_state;

	if (set)
		state |= masc;
	else
		state &= ~masc;

	if (state!=old_state)
	{
		if (info)
		{
			if (draw)
				ob_draw_chg(info,obj,NULL,state);
		}
		else if (draw)
		{
			beg_update(FALSE,FALSE);
			_clip_rect(NULL);
			objc_change(tree,obj,0,desk.g_x,desk.g_y,desk.g_w,desk.g_h,state,1);
			end_update(FALSE);
		}
		ob_ptr->ob_state = state;
		return (TRUE);
	}
	else
		return (FALSE);
}

int ob_select(DIAINFO *info,OBJECT *tree,int obj,int select,int draw)
{
	reg OBJECT *obptr = &tree[obj];

#ifndef SMALL_NO_XTEXT
	if (draw && info && ((((unsigned char) obptr->ob_type)==G_USERDEF && (obptr->ob_type&G_TYPE)!=G_XTEXT) ||
#else
	if (draw && info && (((unsigned char) obptr->ob_type)==G_USERDEF ||
#endif
		((obptr->ob_flags&0x0600) && (obptr->ob_head>0))))
	{
		if (ob_state(NULL,tree,obj,SELECTED,select,FALSE))
		{
			ob_draw(info,obj);
			return (TRUE);
		}
		else
			return (FALSE);
	}
	else
		return (ob_state(info,tree,obj,SELECTED,select,draw));
}

int ob_disable(DIAINFO *info,OBJECT *tree,int obj,int disable,int draw)
{
	if (draw && info)
	{
		if (ob_state(NULL,tree,obj,DISABLED,disable,FALSE))
		{
			ob_draw(info,obj);
			return (TRUE);
		}
		else
			return (FALSE);
	}
	else
		return (ob_state(info,tree,obj,DISABLED,disable,draw));
}

int ob_draw(DIAINFO *info,int obj)
{
	return (ob_draw_chg(info,obj,NULL,FAIL));
}

#ifndef SMALL_NO_EDIT
static int is_edit(OBJECT *tree,int parent,int index,int edit)
{
	reg OBJECT *obj;
	reg int start;

	do
	{
		if (index==edit)
			return (TRUE);
		else
		{
			obj = &tree[index];
			if ((start=obj->ob_head)>0 && is_edit(tree,index,start,edit))
				return (TRUE);
		}
	} while ((index=obj->ob_next)>parent);
	return (FALSE);
}
#endif

typedef struct
{
	OBJECT	*tree;
	int		*list;
} LIST_PARA;

static void draw_list(int first,WIN *dummy,GRECT *area,GRECT *work,void *para)
{
	reg OBJECT *tree = ((LIST_PARA *) para)->tree;
	reg int *list = ((LIST_PARA *) para)->list,ob;

	while ((ob=*list++)>0)
		_ob_xdraw(tree,ob,area);
}

int ob_draw_list(reg DIAINFO *info,reg int *ob_lst,reg GRECT *area)
{
	if (info!=NULL && info->di_flag>CLOSED && !info->di_win->iconified && info->di_drawn && !_no_output && (_dia_len==0 || info==_dia_list[_dia_len-1]))
	{
		reg OBJECT *tree = info->di_tree;
		GRECT win = area!=NULL ? *area : *(GRECT *) &tree->ob_x;

		if ((info->di_flag<WINDOW || rc_intersect(&info->di_win->work,&win)) && rc_intersect(&desk,&win))
		{
			LIST_PARA para;

		#ifndef SMALL_NO_EDIT
			reg int *objs,act,ob,on = 0,head;

			if (info->di_cursor)
				for (objs=ob_lst,ob=info->di_ed_obj;(act=*objs++)>0;)
					if (act==ob || ((head=tree[act].ob_head)>0 && (head==ob || is_edit(tree,act,head,ob))))
					{
						beg_update(FALSE,TRUE);
						_cursor_off(info);
						on = act==ob ? 0x1000 : FAIL;
						break;
					}
		#endif

			para.tree = tree;
			para.list = ob_lst;
			draw_window(info->di_win,&win,&para,MOUSE_ON,draw_list);

		#ifndef SMALL_NO_EDIT
			if (on)
			{
				ob_set_cursor(info,FAIL,on,FAIL);
				end_update(TRUE);
			}
		#endif

			return (TRUE);
		}
	}
	return (FALSE);
}

typedef struct
{
	OBJECT *tree;
	int obj,state;
} DRAW_PARA;

static void draw_chg(int first,WIN *dummy,GRECT *area,GRECT *work,void *para)
{
	reg OBJECT *tree = ((DRAW_PARA *) para)->tree;
	reg int obj = ((DRAW_PARA *) para)->obj,state = ((DRAW_PARA *) para)->state;

	if (state>=0)
	{
		reg OBJECT *ob = &tree[obj];
		reg int old_state = ob->ob_state;
		objc_change(tree,obj,0,area->g_x,area->g_y,area->g_w,area->g_h,state,1);
		ob->ob_state = old_state;
	}
	else
		_ob_xdraw(tree,obj,area);
}

int ob_draw_chg(DIAINFO *info,int obj,GRECT *area,int new_state)
{
	int exit = FALSE;

	if (info==NULL || (info->di_flag==CLOSED || !info->di_drawn || info->di_win->iconified || _no_output || (_dia_len>0 && info!=_dia_list[_dia_len-1])))
	{
		if (new_state>=0)
		{
			if (info!=NULL && info->di_tree)
				info->di_tree[obj].ob_state = new_state;
			else
				exit = FAIL;
		}
	}
	else
	{
		reg OBJECT *tree = info->di_tree, *ob_ptr = &tree[obj];
		GRECT win = area!=NULL ? *area : *(GRECT *) &tree->ob_x;

		if ((info->di_flag<WINDOW || rc_intersect(&info->di_win->work,&win)) && rc_intersect(&desk,&win))
		{
			DRAW_PARA para;

		#ifndef SMALL_NO_EDIT
			reg int on = 0,ed = info->di_ed_obj,head;
			if (info->di_cursor && (obj==0 || obj==ed || ((head=ob_ptr->ob_head)>0 && (head==ed || is_edit(tree,obj,head,ed)))))
			{
				beg_update(FALSE,TRUE);
				_cursor_off(info);
				on = obj==ed ? 0x1000 : FAIL;
			}
		#endif

			para.tree = tree;
			para.state = new_state;
			para.obj = obj;
			draw_window(info->di_win,&win,&para,MOUSE_ON,draw_chg);

			#ifndef SMALL_NO_EDIT
				if (on)
				{
					ob_set_cursor(info,FAIL,on,FAIL);
					end_update(TRUE);
				}
			#endif
			exit = TRUE;
		}

		if (new_state>=0)
			ob_ptr->ob_state = new_state;
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

int ob_get_parent(OBJECT *tree,int index)
{
	reg OBJECT *obj = &tree[index];
	reg int act;

	for (act=index;--act>=0;)
	{
		obj--;
		if (obj->ob_head<=index && obj->ob_tail>=index)
			return (act);
	}
	return (0);
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
		if ((button=obj->ob_next)<0)
			return (FAIL);
		obj = &tree[button];
	case G_TEXT:
	case G_FTEXT:
	case G_BOXTEXT:
	case G_FBOXTEXT:
	case G_STRING:
	case G_BUTTON:
	case G_BOXCHAR:
#ifndef SMALL_NO_XTEXT
	case G_XTEXT:
#endif
		if ((i=obj->ob_head)>0)
			for (last=obj->ob_tail,obj=&tree[i];i<=last;i++,obj++)
				switch (obj->ob_type & G_TYPE)
				{
				case G_IND:
				case G_HOTKEY:
					return (i);
				}
	}
	return (0);
}

char ob_get_hotkey(OBJECT *tree,int button)
{
	reg int obj;
	if ((obj=_get_hotkey(tree,button))>0)
		return (tree[obj].ob_state>>8);
	else
		return (0);
}

int _set_hotkey(OBJECT *hotkey,OBJECT *parent,char hot)
{
#ifndef SMALL_NO_XTEXT
	reg X_TEXT *xtxt;
	int d,eff[3],out[5];
#endif
	reg char *text,*pos,orig;
	reg int x,width,type = (unsigned char) parent->ob_type,center;
	int w,h,xo,yo;

	switch (type)
	{
	case G_FTEXT:
	case G_FBOXTEXT:
		text = parent->ob_spec.tedinfo->te_ptmplt;break;
	default:
		text = ob_get_text(parent,0,FALSE);
	}

	x = xo = 0;
	w = gr_cw;
	h = gr_ch;
	center = TE_CNTR;
	yo = _ibm_hot;

	if (text)
	{
		if (((pos=strchr(text,UpperChar(hot)))!=NULL || (pos=strchr(text,LowerChar(hot)))!=NULL))
		{
			orig = *pos;
			width = (int) strlen(text);

			switch (type)
			{
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				_get_font_size(parent,&w,&h,&yo);
				center = parent->ob_spec.tedinfo->te_just;
			case G_BUTTON:
			#ifndef SMALL_NO_XTEXT
				_hotkey_pos:
			#endif
				width *= w;
				switch (center)
				{
				case TE_RIGHT:
					x = parent->ob_width - width;break;
				case TE_CNTR:
					x = (parent->ob_width - width)>>1;
					if (w<gr_cw)
						x++;
				}
			case G_TITLE:
			case G_STRING:
				x += ((int) (pos - text))*w;
				break;
			default:
			#ifndef SMALL_NO_XTEXT
				if ((parent->ob_type & G_TYPE)==G_XTEXT)
				{
					xtxt = get_xtext(parent,0);
					v_set_text(xtxt->font_id,xtxt->font_size,FAIL,xtxt->effect&31,0,out);
					w = out[2];
					h = out[3];
					center = xtxt->center;
					vqt_fontinfo(x_handle,&d,&d,out,&d,eff);
					xo = eff[1];
					yo = out[4]+1;
					goto _hotkey_pos;
				}
			#endif
				hot = '\0';
			}
		}
		else
			hot = '\0';
	}
	else if (type==G_BOXCHAR && ((orig=parent->ob_spec.obspec.character)==UpperChar(hot) || orig==LowerChar(hot)))
		x = (parent->ob_width-w)>>1;
	else
		hot = '\0';

	ob_hide(hotkey,0,hot=='\0');
	hotkey->ob_state &= 0x00ff;
	hotkey->ob_state |= UpperChar(hot)<<8;

	hotkey->ob_width = w;

	w = parent->ob_height;
	if (hot)
	{
		switch (type)
		{
		case G_BUTTON:
		case G_BOXTEXT:
		case G_FBOXTEXT:
		case G_BOXCHAR:
			if (yo<(w-2))
				yo++;
			break;
		default:
			if (yo<(w-1))
				yo++;
		}
		if (strchr("gpqy",orig))
			yo = min(yo+2,min(h+1,w));
	}

	hotkey->ob_x = x-xo;
	hotkey->ob_y = yo+((w-h)>>1);
	if (w>h)
		Min(&hotkey->ob_y,w-1);

	return ((hot) ? TRUE : FALSE);
}

int ob_set_hotkey(OBJECT *tree,int button,char hot)
{
	reg int obj;
	return ((obj=_get_hotkey(tree,button))>0 && _set_hotkey(&tree[obj],&tree[ob_get_parent(tree,obj)],hot));
}
