
#include "proto.h"

#ifndef SMALL_NO_EDIT
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifndef __MINT_LIB__
#include <stdlib.h>
#endif

#ifndef SMALL_EDIT
static char string_1[] = " \x01" "\x02" "\x03" "\x04" "\x05" "\x06" "\x07" "\x08" "\x09" "\x0a" "\x0b" "\x0c" "\x0d" "\x0e" "\x0f" "\x10" "\x11" "\x12" "\x13" "\x14" "\x15" "\x16" "\x17" "\x18" "\x19" "\x1a" "\x1b" "\x1c" "\x1d" "\x1e" "\x1f" "";
static char string_2[] = " !\"#$%&\'()*+,-./0123456789:;<=>?";
static char string_3[] = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
static char string_4[] = "`abcdefghijklmnopqrstuvwxyz{|}~\x7f" "";
static char string_5[] = "\x80" "Å\x82" "\x83" "Ñ\x85" "\x86" "\x87" "\x88" "\x89" "\x8a" "\x8b" "\x8c" "\x8d" "é\x8f" "\x90" "\x91" "\x92" "\x93" "î\x95" "\x96" "\x97" "\x98" "ôö\x9b" "\x9c" "\x9d" "û\x9f" "";
static char string_6[] = "\xa0" "\xa1" "\xa2" "\xa3" "\xa4" "\xa5" "\xa6" "\xa7" "\xa8" "\xa9" "\xaa" "\xab" "\xac" "\xad" "\xae" "\xaf" "\xb0" "\xb1" "\xb2" "\xb3" "\xb4" "\xb5" "\xb6" "\xb7" "\xb8" "\xb9" "\xba" "\xbb" "\xbc" "\xbd" "\xbe" "\xbf" "";
static char string_7[] = "\xc0" "\xc1" "\xc2" "\xc3" "\xc4" "\xc5" "\xc6" "\xc7" "\xc8" "\xc9" "\xca" "\xcb" "\xcc" "\xcd" "\xce" "\xcf" "\xd0" "\xd1" "\xd2" "\xd3" "\xd4" "\xd5" "\xd6" "\xd7" "\xd8" "\xd9" "\xda" "\xdb" "\xdc" "\xdd" "\xde" "\xdf" "";
static char string_8[] = "\xe0" "\xe1" "\xe2" "\xe3" "\xe4" "\xe5" "\xe6" "\xe7" "\xe8" "\xe9" "\xea" "\xeb" "\xec" "\xed" "\xee" "\xef" "\xf0" "\xf1" "\xf2" "\xf3" "\xf4" "\xf5" "\xf6" "\xf7" "\xf8" "\xf9" "\xfa" "\xfb" "\xfc" "\xfd" "\xfe" "\xff" "";

static TEDINFO ascii_title =
	{ "ASCII-Table", "", "", SMALL, 0, TE_CNTR, 0x1100, 0, -1, 11, 1};

static OBJECT ascii_tree[] = {
	{ -1, 1, 12, G_BOX, EXIT, OUTLINED, CAST 0x21141L, 0,0, 36,10 },
	{ 2, -1, -1, G_TEXT, EXIT, NORMAL, CAST &ascii_title, 2,1024, 32,1 },
	{ 11, 3, 10, G_BOX, NONE, DRAW3D, CAST 0xFF1101L, 2,1025, 32,8 },
	{ 4, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_1, 0,0, 32,1 },
	{ 5, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_2, 0,1, 32,1 },
	{ 6, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_3, 0,2, 32,1 },
	{ 7, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_4, 0,3, 32,1 },
	{ 8, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_5, 0,4, 32,1 },
	{ 9, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_6, 0,5, 32,1 },
	{ 10,-1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_7, 0,6, 32,1 },
	{ 2, -1, -1, G_STRING, TOUCHEXIT, NORMAL, CAST string_8, 0,7, 32,1 },
	{ 12, -1, -1, (UNDO_BTN<<8)|G_IBOX, EXIT, NORMAL, CAST 0l, 0,0, 0,0 },
	{ 0, -1, -1, (FLYDIAL<<8)+G_IBOX, SELECTABLE|LASTOB, NORMAL, CAST 0x57011100L, 34,0, 2,1 },
};

#define ASC_FI	3
#define ASC_LA	(ASC_FI+7)

#define	HISTORY	16

static char history[HISTORY][MAX_EDIT];
static int hist_index;
#endif

static char umlaute[] = "_ÑîÅéôöû";

static int insert_char(DIAINFO *,int);
static void delete_char(DIAINFO *,int);
static void insert_string(DIAINFO *,char *,int);

char *_edit_get_info(OBJECT *tree,int obj,int index,EDINFO *ed)
{
	reg OBJECT *obptr;
	reg TEDINFO *ted;
	reg char *edit,*masc,c,u='_';
	reg int x,idx,width;

	if (obj<=0 || index<0)
		return (NULL);

	_get_font_size(obptr=&tree[obj],&ed->cw,&ed->ch,NULL);

	ted = obptr->ob_spec.tedinfo;
	ed->text = ted->te_ptext;
	ed->masc = masc = ted->te_ptmplt;
	ed->valid = ted->te_pvalid;

	width = (int) strlen(masc);
	width *= ed->cw;

	objc_offset(tree,obj,&ed->text_x,&ed->text_y);
	ed->text_y += (obptr->ob_height - ed->ch)>>1;
	ed->text_w = width;
	ed->text_h = ed->ch;

	switch(ted->te_just)
	{
	case TE_RIGHT:
		ed->text_x += obptr->ob_width-width;
		break;
	case TE_CNTR:
		ed->text_x += (obptr->ob_width-width)>>1;
		break;
	}

	ed->edit_x = ed->text_x;
	ed->edit_y = ed->text_y;
	ed->edit_w = 0;
	ed->edit_h = ed->text_h;

	while (*masc && *masc++!=u)
		ed->edit_x += ed->cw;
	masc--;
	edit = masc;

	width = 0;
	while (*masc!='\0')
	{
		width += ed->cw;
		if (*masc++==u)
			ed->edit_w = width;
	}

	x = ed->crs_x = ed->edit_x;
	ed->crs_y = ed->edit_y;

	idx = 0;
	masc = edit;
	while ((c=*masc++)!='\0')
	{
		if (c==u)
		{
			ed->crs_x = x;
			if (idx>=index)
				break;
			else
			{
				ed->crs_x = (x += ed->cw);
				idx++;
			}
		}
		else
			x += ed->cw;
	}

	return (edit);
}

static void cursor_rect(int first,WIN *dummy,GRECT *area,GRECT *work,void *para)
{
	rc_sc_invert(area);
}

static void draw_cursor(DIAINFO *info,EDINFO *ed)
{
	WIN *win = info->di_win;
	OBJECT *tree = info->di_tree;
	GRECT cursor,*rect = &info->di_crsrect;

	if (ed)
	{
		_calc_cursor(info,ed,&cursor);
		*rect = cursor;
		rect->g_x -= tree->ob_x;
		rect->g_y -= tree->ob_y;
	}
	else
	{
		cursor = *rect;
		cursor.g_x += tree->ob_x;
		cursor.g_y += tree->ob_y;
	}

	win->vdi_handle = -1;
	draw_window(win,&cursor,NULL,MOUSE_TEST,cursor_rect);
	win->vdi_handle = x_handle;
}

void _calc_cursor(DIAINFO *info,reg EDINFO *ed,reg GRECT *cursor)
{
	cursor->g_x = ed->crs_x;
	cursor->g_y = ed->crs_y;

	if (info->di_insert)
	{
		cursor->g_y -= 1;
		cursor->g_w = 1;
		cursor->g_h = ed->ch+2;
	}
	else
	{
		cursor->g_w = ed->cw;
		cursor->g_h = ed->ch;
	}
}

void _cursor_off(DIAINFO *info)
{
	if (!info->di_win->iconified && info->di_cursor)
		draw_cursor(info,NULL);
	info->di_cursor = FALSE;
}

static int get_editlen(DIAINFO *info)
{
	reg char *masc = info->di_tree[info->di_ed_obj].ob_spec.tedinfo->te_ptmplt, u = '_', c;
	reg int len = 0;

	while ((c=*masc++)!='\0')
		if (c==u) len++;
	return (len);
}

int ob_set_cursor(DIAINFO *info,int obj,int index,int insert)
{
	EDINFO ed;
	reg char *text;
	reg int new_ob;

	if (info==NULL)
		return (FALSE);

	if (info->di_ed_cnt<=0 || (obj<=0 && (obj=info->di_ed_obj)<=0))
	{
		info->di_cursor = FALSE;
		return (FALSE);
	}

	if (insert>=TRUE)
		insert = TRUE;
	else if (insert<=FAIL)
		insert = info->di_insert;

	text = info->di_tree[obj].ob_spec.tedinfo->te_ptext;
	if (index<0 && (index=info->di_ed_index)<0)
		index = (int) strlen(text);
	else
		index = max(min(index,(int) strlen(text)),0);

	new_ob = (obj!=info->di_ed_obj);

	if (new_ob || index!=info->di_ed_index || insert!=info->di_insert || !info->di_cursor)
	{
	#ifndef SMALL_EDIT
		if (new_ob)
			_insert_history(info);
	#endif

		beg_update(FALSE,TRUE);
		_cursor_off(info);

		info->di_ed_obj = obj;
		if ((info->di_insert=insert)==FALSE)
			index = min(index,get_editlen(info)-1);
		info->di_ed_index = index;

		if (info->di_drawn && !info->di_win->iconified)
		{
			_edit_get_info(info->di_tree,obj,index,&ed);
			draw_cursor(info,&ed);
			info->di_cursor = TRUE;
		}

		end_update(TRUE);

		if (new_ob)
			strncpy(info->di_undobuff,ob_get_text(info->di_tree,info->di_ed_obj,0),MAX_EDIT-1);
	}
	return (TRUE);
}

static void first_last_edit(DIAINFO *info,int pos,int first)
{
	reg OBJECT *obj = info->di_tree;
	reg int index = 0,last = 0;

	if (info->di_ed_cnt<=1)
		return;

	do
	{
		obj++;index++;
		if ((obj->ob_flags & (EDITABLE|HIDETREE))==EDITABLE && !_is_hidden(info->di_tree,index))
		{
			last = index;
			if (first)
				break;
		}
	}
	while (!(obj->ob_flags & LASTOB));
	if (last)
		ob_set_cursor(info,last,pos,FAIL);
}

int _next_edit(DIAINFO *info,int first)
{
	reg int index = info->di_ed_obj;
	reg OBJECT *obj = &info->di_tree[index];

	if (info->di_ed_cnt<=1)
		return(FALSE);

	while (!(obj->ob_flags & LASTOB))
	{
		obj++;index++;
		if ((obj->ob_flags & (EDITABLE|HIDETREE))==EDITABLE && !_is_hidden(info->di_tree,index))
		{
			ob_set_cursor(info,index,0x1000,FAIL);
			return(TRUE);
		}
	}

	if (first)
	{
		first_last_edit(info,0x1000,TRUE);
		return (TRUE);
	}
	else
		return (FALSE);
}

static void prev_edit(DIAINFO *info)
{
	reg int index = info->di_ed_obj;
	reg OBJECT *obj = &info->di_tree[index];

	if (info->di_ed_cnt<=1)
		return;

	while (index>0)
	{
		obj--;index--;
		if ((obj->ob_flags & (EDITABLE|HIDETREE))==EDITABLE && !_is_hidden(info->di_tree,index))
		{
			ob_set_cursor(info,index,0x1000,FAIL);
			return;
		}
	}
	first_last_edit(info,0x1000,FALSE);
}

static void draw_edit(DIAINFO *info,int index)
{
	_cursor_off(info);
	ob_draw(info,info->di_ed_obj);
	ob_set_cursor(info,FAIL,index,FAIL);
}

static int cursor_handler(DIAINFO *info,int state,int scan,XEVENT *event)
{
	if (state & K_CTRL)
		return (FALSE);
	else
	{
		reg OBJECT *tree = info->di_tree;
		reg char *text = ob_get_text(tree,info->di_ed_obj,0);

		if (state & K_SHIFT)
		{
		#ifndef SMALL_EDIT
			reg OBJECT *obj;
			reg int flags,i,ob_list[128],*ptr = ob_list;
		#endif

			switch (scan)
			{
			#ifndef SMALL_EDIT
			case SCANESC:
				for (obj=tree,i=0;;obj++,i++)
				{
					flags = obj->ob_flags;
					if (flags & EDITABLE)
					{
						ob_get_text(tree,i,TRUE);
						*ptr++ = i;
					}
					if (flags & LASTOB)
						break;
				}
				*ptr = 0;
				first_last_edit(info,0,TRUE);
				ob_draw_list(info,ob_list,NULL);
				_send_msg(info,FAIL,OBJC_EDITED,0,0);
				info->di_taken = FAIL;
				break;
			#endif
			case SCANBS:
				if (info->di_ed_index>0)
				{
					strcpy(text,&text[info->di_ed_index]);
					draw_edit(info,0);
				}
				break;
			case SCANDEL:
				text[info->di_ed_index] = '\0';
				draw_edit(info,FAIL);
				break;
			case SCANRET:
			case SCANENTER:
			case SCANTAB:
				prev_edit(info);break;
			case SCANUP:
			case SCANHOME:
			case SCANDOWN:
				first_last_edit(info,scan==SCANHOME ? 0x1000: 0,scan==SCANUP);break;
			case SCANLEFT:
				ob_set_cursor(info,FAIL,0,FAIL);break;
			case SCANRIGHT:
				ob_set_cursor(info,FAIL,0x1000,FAIL);break;
			#ifndef SMALL_EDIT
			case SCANINS:
				ascii_box(info,NULL);break;
			#endif
			default:
				return(FALSE);
			}
		}
		else
		{
			switch(scan)
			{
			case SCANESC:
				insert_string(info,"",TRUE);break;
			case SCANBS:
				if (info->di_ed_index>0)
					delete_char(info,info->di_ed_index-1);
				break;
			case SCANDEL:
				delete_char(info,info->di_ed_index);break;
			case SCANHOME:
				first_last_edit(info,0,TRUE);break;
			case SCANUP:
				prev_edit(info);break;
			case SCANDOWN:
			case SCANTAB:
			case SCANENTER:
				_next_edit(info,TRUE);break;
			case SCANINS:
				ob_set_cursor(info,FAIL,FAIL,info->di_insert ? FALSE : TRUE);break;
			case SCANLEFT:
				ob_set_cursor(info,FAIL,max(info->di_ed_index-1,0),FAIL);break;
			case SCANRIGHT:
				ob_set_cursor(info,FAIL,info->di_ed_index+1,FAIL);break;
			default:
				return(FALSE);
			}
		}
		return(TRUE);
	}
}

static boolean (*edit_handler)(char,char,char *);

void ob_edit_handler(boolean (*handler)(char,char,char *))
{
	edit_handler = handler;
}

static char ted_char(char valid, reg unsigned char c)
{
	if (edit_handler)
	{
		char new;
		if (edit_handler(valid,(char) c,&new))
			return (new);
	}

	switch (valid)
	{
#ifndef SMALL_EDIT
	case 'l':
	case 'L':
		if (c>=16 && c<=25)
			return (c);
		else if (c>='0' && c<='9')
			return (c - '0' + 16);
		break;
	case 'c':
	case 'C':
		if (strchr(".+-*/^()[]{}",c))
			return (c);
		else if (c==',')
			return ('.');
	case '0':
	case '1':
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
#endif
	case '9':
		if (c>='0' && c<=valid)
			return (c);
		break;
#ifndef SMALL_EDIT
	case 'h':
		c = LowerChar(c);
		if ((c>='0' && c<='9') || (c>='a' && c<='f'))
			return (c);
		break;
	case 'H':
		c = UpperChar(c);
		if ((c>='0' && c<='9') || (c>='A' && c<='F'))
			return (c);
		break;
#endif
	case 'N':
		if (c>='0' && c<='9')
			return (c);
	case 'A':
		c = UpperChar(c);
		if ((c>='A' && c<='Z') || c==' ')
			return (c);
		break;
	case 'n':
		if (c>='0' && c<='9')
			return (c);
	case 'a':
		c = LowerChar(c);
		if ((c>='a' && c<='z') || c==' ')
			return (c);
		break;
	case 'P':
		if (c=='\?' || c=='*')
			return (c);
	case 'p':
		if (c=='.' || c==':' || c=='\\')
			return (c);
	case 'F':
		if ((c>='A' && c<='Z') || (c>='a' && c<='z') || (c>='0' && c<='9') || strchr("_!@#$%^&()+-=~\'`;\",<>|[]{}",c))
			return (c);
		break;
#ifndef SMALL_EDIT
	case 'U':
		c = UpperChar(c);
		if (c>=32 && c<=127)
			return (c);
		break;
	case 'u':
		c = LowerChar(c);
		if (c>=32 && c<=127)
			return (c);
		break;
	case 'V':
		c = UpperChar(c);
		if (c>=32)
			return (c);
		break;
	case 'v':
		c = LowerChar(c);
		if (c>=32)
			return (c);
		break;
	case 'w':
	case 'W':
		if (c>=32 && c<=127)
			return (c);
		break;
	case 'y':
	case 'Y':
		if (c>=32)
			return (c);
		break;
#endif
	default:
		return (c);
	}

	return ('\0');
}

static void insert_string(DIAINFO *info,char *str,int all)
{
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char c,v,*text = ted->te_ptext,*valid = ted->te_pvalid;
	reg int len = get_editlen(info);

	if (all)
		strncpy(text,str,get_editlen(info));
	else
	{
		v = *valid++;
		while (len>0 && *str!='\0')
			if ((c=ted_char(v,*str++))!='\0')
			{
				*text++ = c;
				if (*valid)
					v = *valid++;
				len--;
			}
		*text = '\0';
	}

	draw_edit(info,0x1000);
}

static void new_edit(DIAINFO *info, char *new, char *text, char *edit,int index, int len)
{
	char new_text[MAX_EDIT<<1],old_text[MAX_EDIT<<1];
	EDINFO ed;
	reg char m,*s,*c,*n,*o;
	reg int offset,width;
	int len1,len2;

	if (strcmp(new,text))
	{
		n = new_text; o = old_text;
		s = new; c = text;
		while ((m=*edit++)!='\0')
			if (m=='_')
			{
				*n++ = *s++;
				*o++ = *c++;
			}
			else
				*n++ = *o++ = m;

		s = new_text; c = old_text;
		while (*s++==*c++);

		s--;c--;
		offset = (int) (s-new_text);

		len1 = (int) strlen(s);
		len2 = (int) strlen(c);
		if (len1!=len2)
			width = max(len1,len2);
		else
		{
			width = len1;
			s += len1; c += len1;
			while (*--s==*--c)
				width--;
		}

		strncpy(text,new,len);

		_cursor_off(info);
		_edit_get_info(info->di_tree,info->di_ed_obj,info->di_ed_index,&ed);
		ed.text_x += offset*ed.cw;
		ed.text_w = width*ed.cw;
		ob_draw_chg(info,info->di_ed_obj,(GRECT *) &ed.text_x,FAIL);
	}
	ob_set_cursor(info,FAIL,index,FAIL);
}

static void delete_char(DIAINFO *info,int index)
{
	char buf[MAX_EDIT<<1];
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char *text = ted->te_ptext;

	if (text[index]!='\0')
	{
		strcpy(buf,text);
		strcpy(&buf[index],&text[index+1]);
		new_edit(info,buf,text,ted->te_ptmplt,index,get_editlen(info));
	}
}

static int insert_char(DIAINFO *info,int scan)
{
	char buf[MAX_EDIT<<1];
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char v,*text = ted->te_ptext,*valid = ted->te_pvalid;
	reg int idx,offset,taken;

	offset = idx = min(get_editlen(info)-1,info->di_ed_index);
	while (idx>=0 && *valid)
	{
		v = *valid++;
		idx--;
	}

	if ((taken=ted_char(v,scan))!=0)
	{
		strcpy(buf,text);

		if (info->di_insert)
			strcpy(&buf[offset+1],text+offset);
		else
		{
			valid = buf;
			while (*valid++);
			*valid++ = '\0';
		}

		buf[offset] = taken;
		new_edit(info,buf,text,ted->te_ptmplt,info->di_ed_index+1,get_editlen(info));
		return (TRUE);
	}
	else
		return (FALSE);
}

#ifndef SMALL_EDIT
void _insert_history(DIAINFO *info)
{
	reg char *str;

	if (info->di_ed_obj<=0)
		return;
	
	str = ob_get_text(info->di_tree,info->di_ed_obj,0);

	if (str!=NULL && *str!='\0')
	{
		reg int i;

		for (i=0;i<HISTORY-1;i++)
			if (!strcmp(history[i],str))
				return;

		for (i=(HISTORY-1);i>=1;i--)
			strcpy(history[i],history[i-1]);

		strcpy(history[0],str);

		if (hist_index<(HISTORY-1) && history[hist_index+1][0])
			hist_index++;
	}
}
#endif

int _insert_buf(DIAINFO *info,char *text,int cat)
{
	char buf[MAX_EDIT];
	reg char *line;
	reg int len = 0;

	strncpy(buf,text,MAX_EDIT-1);
	buf[MAX_EDIT-1] = '\0';

	if ((line=strpbrk(buf,"\r\n"))!=NULL)
	{
		len = (line[0]=='\r' && line[1]=='\n') ? 2 : 1;
		*line = '\0';
	}

	len += (int) strlen(buf);

	if (cat)
	{
		char str[MAX_EDIT<<1];

		strcpy(str,ob_get_text(info->di_tree,info->di_ed_obj,0));
		strcat(str,buf);
		strncpy(buf,str,MAX_EDIT-1);
		buf[MAX_EDIT-1] = '\0';
	}

	insert_string(info,buf,FALSE);

	return (len);
}

#if !defined(SMALL_NO_CLIPBRD) && !defined(SMALL_EDIT)
static boolean clipbrd_save(DIAINFO *info,boolean append)
{
	char path[MAX_PATH],*text,*crlf="\r\n";
	long handle;

	if ((text=ob_get_text(info->di_tree,info->di_ed_obj,0))!=NULL && scrp_path(path,"scrap.txt") && (handle = append ? Fopen(path,1) : Fcreate(path,0))>0)
	{
		if (append)
			Fseek(0l,(int) handle,SEEK_END);
		Fwrite((int) handle,strlen(text),text);
		Fwrite((int) handle,2,crlf);
		Fclose((int) handle);

	#ifndef SMALL_NO_XACC_AV
		scrp_changed(SCF_TEXT,0x2e545854l);	/* .TXT */
	#endif

		return(TRUE);
	}
	else
		return(FALSE);
}

static void clipbrd_load(DIAINFO *info,boolean flag)
{
	char path[MAX_PATH],buf[MAX_EDIT];
	long handle;
	int read;

	if (scrp_path(path,"scrap.txt") && (handle=Fopen(path,0))>0)
	{
		if ((read=(int) Fread((int) handle,MAX_EDIT-1,buf))>0)
		{
			buf[read] = '\0';
			_insert_buf(info,buf,flag);
		}
		Fclose((int) handle);
	}
}
#endif

static boolean word_char(char c)
{
	if (c)
		if (isalnum(c) || strchr(umlaute,c)!=NULL)
			return(TRUE);
	return(FALSE);
}

static void insert_point(DIAINFO *info,int scan,int state)
{
	char edit_buf[MAX_EDIT];
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char *masc = ted->te_ptmplt,*edit,*masc_start,c;
	reg int idx = info->di_ed_index,ascii;

	if (state&(K_ALT|K_CTRL))
		ascii = (unsigned char) scan;
	else
		ascii = scan_2_ascii(scan,state);

	if (ascii==0)
	{
		info->di_taken = FALSE;
		return;
	}

	edit = strcpy(edit_buf,ted->te_ptext);
	while ((c=*masc++)!='\0' && c!='_');
	masc_start = --masc;

	while (idx>0)
		if (*masc++=='_')
		{
			idx--;
			edit++;
		}

	while (*masc++!='_');
	masc--;

	if (strchr(",.;:/\\",ascii)!=NULL && strchr(masc_start,ascii)!=NULL)
	{
		if (strchr(masc,ascii)!=NULL)
		{
			while ((c=*masc++)!='\0')
				if (c==ascii)
					break;
				else if (c=='_')
					*edit++ = ' ';

			*edit = '\0';
			insert_string(info,edit_buf,TRUE);
		}
	}
	else if ((info->di_taken=insert_char(info,scan))==0 && ascii==' ')
	{
		while ((c=*masc++)=='_')
			*edit++ = ' ';
		*edit = '\0';
		idx = info->di_ed_index;
		insert_string(info,edit_buf,TRUE);
		if (c=='\0')
		{
			if (info->di_ed_cnt>1)
				_next_edit(info,TRUE);
			else
				ob_set_cursor(info,FAIL,idx,FAIL);
		}
		info->di_taken = TRUE;
	}
}

#ifndef SMALL_EDIT
static int value[] = {7,8,9,4,5,6,1,2,3,0};
#endif

void _objc_edit_handler(DIAINFO *info,int state,int scan,XEVENT *event,int *edited)
{
#ifndef SMALL_EDIT
	reg int shft = (state&3);
#endif
	reg int old_obj = info->di_ed_obj;
	reg int sn = (int) (((unsigned) scan)>>8);
	reg char old_edit[MAX_EDIT],*text = ob_get_text(info->di_tree,old_obj,0);

	strcpy(old_edit,text);

	info->di_taken = TRUE;
	if (cursor_handler(info,state,sn,event)==FALSE)
	{
		if (sn==SCANUNDO)
			insert_string(info,info->di_undobuff,TRUE);
	#ifndef SMALL_EDIT
		else if ((state & K_ALT) && (sn>=0x67 && sn<=0x70))
		{
			_ascii *= 10;
			_ascii += value[sn-0x67];
			_ascii_digit++;
			if (_ascii_digit==3 || _ascii>=26)
			{
				insert_char(info,_ascii);
				_ascii = _ascii_digit = 0;
			}
		}
	#endif
		else if (state & K_CTRL)
		{
			reg char *c	= text+info->di_ed_index;

			switch (sn)
			{
			case CTRLLEFT:
				while (c>text && word_char(*(--c)));
				while (c>text && !word_char(*(--c)));
				ob_set_cursor(info,FAIL,(c>text) ? (int) (c - text + 1) : 0,FAIL);
				break;
			case CTRLRIGHT:
				while (word_char(*c++));
				if (*(--c) != '\0')
				{
					while (!word_char(*c++));
					if (*(--c) != '\0')
						ob_set_cursor(info,FAIL,(int) (c - text),FAIL);
				}
				else
					ob_set_cursor(info,FAIL,(int) (c - text),FAIL);
				break;
			#ifndef SMALL_EDIT
			case SCANUP:
				{
					int o_i = hist_index;
					_insert_history(info);
					if (shft)
					{
						reg size_t n = strlen(text);
						if (n)
						{
							reg int i;
							for (i=(hist_index!=o_i) ? 1 : 0;i<HISTORY;i++)
								if (!strncmp(history[i],text,n))
								{
									insert_string(info,history[i],FALSE);
									hist_index = i;
									break;
								}
						}
					}
					else
					{
						if ((hist_index<(HISTORY-1)) && (history[hist_index+1][0]))
							hist_index++;
						insert_string(info,history[hist_index],FALSE);
					}
				}
				break;
			case SCANDOWN:
				_insert_history(info);
				if (shft)
				{
					reg size_t n = strlen(text);
					if (n)
					{
						reg int i;
						for (i=(HISTORY-1);i>=0;i--)
							if (!strncmp(history[i],text,n))
							{
								insert_string(info,history[i],FALSE);
								hist_index = i;
								break;
							}
					}
				}
				else
				{
					if (hist_index>0 && history[hist_index-1][0])
						hist_index--;
					insert_string(info,history[hist_index],FALSE);
				}
				break;
			#endif
			default:
				{
				#if !defined(SMALL_NO_CLIPBRD) && !defined(SMALL_EDIT)
					int ascii = scan_2_ascii(scan,state),flag;

					switch (ascii)
					{
					case 'X':
					case 'C':
						if (_edit_clip)
						{
							if (shft)
								flag = clipbrd_save(info,TRUE);
							else
							{
								scrp_clear(0);
								flag = clipbrd_save(info,FALSE);
							#ifndef SMALL_NO_XACC_AV
								if (!flag)
									scrp_changed(SCF_INDEF,0l);
							#endif
							}

							if (flag && ascii=='X')
							{
								ob_get_text(info->di_tree,info->di_ed_obj,1);
								draw_edit(info,FAIL);
							}
							break;
						}
					case 'V':
						if (_edit_clip)
						{
							clipbrd_load(info,(shft) ? TRUE : FALSE);
							break;
						}
					default:
						info->di_taken = FALSE;
					}
				#else
					info->di_taken = FALSE;
				#endif
				}
			}
		}
		else if (!(state&K_ALT) || (char) scan)
			insert_point(info,scan,state);
		else
			info->di_taken = FALSE;
	}

	if (info->di_taken==FAIL)
		*edited = FAIL;
	else if (info->di_taken && old_obj==info->di_ed_obj && strcmp(old_edit,text))
		*edited = TRUE;
	else
		*edited = FALSE;
}

#ifndef SMALL_EDIT
OBJECT *MakeAscii(void)
{
	static int fixed = 0;
	if (!fixed)
	{
		rsrc_calc(ascii_tree,SCALING,8,16);
		fixed++;
	}
	return (ob_copy_tree(ascii_tree));
}

char ExitAscii(OBJECT *tree,int exit)
{
	if ((exit=FormObject(exit))>0 && exit>=ASC_FI && exit<=ASC_LA)
	{
		int x,ox;

		objc_offset(tree,exit,&ox,&x);
		mouse(&x,NULL);

		exit = (exit-ASC_FI)<<5;
		if ((x-=ox)>=0)
			exit += x/gr_cw;

		exit = min(max(exit,0),255);
	}
	else
		exit = 0;
	NoClick();
	return (exit);
}

static int ascii_insert(DIAINFO *edit,int ascii)
{
	if (edit)
	{
		if (insert_char(edit,ascii))
			_send_msg(edit,edit->di_ed_obj,OBJC_EDITED,0,0);
		return (0);
	}
	return (ascii);
}

char ascii_box(DIAINFO *edit,char *title)
{
	DIAINFO *info;
	OBJECT *tree;
	int exit,ascii = 0,ob;

	if (edit)
	{
		if (title==NULL)
			title = edit->di_title;
		if (edit->di_ed_obj<=0)
			edit = NULL;
	}

	if ((tree=MakeAscii())!=NULL && (info=open_dialog(tree,title,NULL,NULL,DIA_MOUSEPOS,FALSE,AUTO_DIAL|WD_CLOSER|MODAL,0,NULL,NULL))!=NULL)
	{
		info->di_mem = tree;
		while ((exit=XFormObject(NULL,&ob))>0)
		{
			ascii = ExitAscii(tree,exit);
			if (exit<ASC_FI || exit>ASC_LA || edit==NULL || info->di_flag<WINDOW)
				break;
			else
				ascii = ascii_insert(edit,ascii);
		}
		if (ob!=W_ABANDON)
		{
			close_dialog(info,FALSE);
			ascii = ascii_insert(edit,ascii);
		}
	}
	else if (tree)
		free(tree);
	return (ascii);
}
#endif
#endif
