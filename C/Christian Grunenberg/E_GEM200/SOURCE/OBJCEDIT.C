
#include "proto.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#ifndef __MINT_LIB__
#include <stdlib.h>
#endif

#define	te_editlen	te_junk1

#define	HISTORY	20

static char history[HISTORY][MAX_EDIT];
static int	hist_index;

static char umlaute[] = "_ÑîÅéôöû";

static char string_0[] = "ASCII-Table";
static char string_1[] = " \x01" "\x02" "\x03" "\x04" "\x05" "\x06" "\x07" "\x08" "\x09" "\x0a" "\x0b" "\x0c" "\x0d" "\x0e" "\x0f" "\x10" "\x11" "\x12" "\x13" "\x14" "\x15" "\x16" "\x17" "\x18" "\x19" "\x1a" "\x1b" "\x1c" "\x1d" "\x1e" "\x1f" "";
static char string_2[] = " !\"#$%&\'()*+,-./0123456789:;<=>?";
static char string_3[] = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
static char string_4[] = "`abcdefghijklmnopqrstuvwxyz{|}~\x7f" "";
static char string_5[] = "\x80" "Å\x82" "\x83" "Ñ\x85" "\x86" "\x87" "\x88" "\x89" "\x8a" "\x8b" "\x8c" "\x8d" "é\x8f" "\x90" "\x91" "\x92" "\x93" "î\x95" "\x96" "\x97" "\x98" "ôö\x9b" "\x9c" "\x9d" "û\x9f" "";
static char string_6[] = "\xa0" "\xa1" "\xa2" "\xa3" "\xa4" "\xa5" "\xa6" "\xa7" "\xa8" "\xa9" "\xaa" "\xab" "\xac" "\xad" "\xae" "\xaf" "\xb0" "\xb1" "\xb2" "\xb3" "\xb4" "\xb5" "\xb6" "\xb7" "\xb8" "\xb9" "\xba" "\xbb" "\xbc" "\xbd" "\xbe" "\xbf" "";
static char string_7[] = "\xc0" "\xc1" "\xc2" "\xc3" "\xc4" "\xc5" "\xc6" "\xc7" "\xc8" "\xc9" "\xca" "\xcb" "\xcc" "\xcd" "\xce" "\xcf" "\xd0" "\xd1" "\xd2" "\xd3" "\xd4" "\xd5" "\xd6" "\xd7" "\xd8" "\xd9" "\xda" "\xdb" "\xdc" "\xdd" "\xde" "\xdf" "";
static char string_8[] = "\xe0" "\xe1" "\xe2" "\xe3" "\xe4" "\xe5" "\xe6" "\xe7" "\xe8" "\xe9" "\xea" "\xeb" "\xec" "\xed" "\xee" "\xef" "\xf0" "\xf1" "\xf2" "\xf3" "\xf4" "\xf5" "\xf6" "\xf7" "\xf8" "\xf9" "\xfa" "\xfb" "\xfc" "\xfd" "\xfe" "\xff" "";
static char string_9[] = "Cancel";

static TEDINFO ascii_title =
	{ string_0, "", "", IBM, 0, TE_CNTR, 0x1180, 0, -1, 11, 1};

static OBJECT ascii_tree[] = {
	{ -1, 1, 13, G_BOX, NONE, OUTLINED,CAST (0x21141L), 0,512, 36,14 },
	{ 11, 2, 10, G_BOX, NONE, NORMAL,CAST (0xFF1101L), 2,3073, 32,777 },
	{ 3, -1, -1, (HEADER<<8)+G_BOXTEXT, NONE, NORMAL,CAST &ascii_title, 1,0, 13,1 },
	{ 4, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_1, 0,1, 32,1 },
	{ 5, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_2, 0,2, 32,1 },
	{ 6, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_3, 0,3, 32,1 },
	{ 7, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_4, 0,4, 32,1 },
	{ 8, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_5, 0,5, 32,1 },
	{ 9, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_6, 0,6, 32,1 },
	{ 10,-1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_7, 0,7, 32,1 },
	{ 1, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_8, 0,8, 32,1 },
	{ 13, 12, 12, G_BUTTON, SELECTABLE|DEFAULT|EXIT, NORMAL,CAST string_9, 22,3851, 12,1025 },
	{ 11, -1, -1, (HOTKEY<<8)+G_IBOX, NONE, NORMAL,CAST (0x43011100L), 3,512, 1,1 },
	{ 0, -1, -1, (FLYDIAL<<8)+G_IBOX, SELECTABLE|LASTOB, NORMAL,CAST (0x57011100L), 34,0, 2,1 },
};

#define ASC0	3
#define CANCEL	11

static int insert_char(DIAINFO *info,int scan);
static void delete_char(DIAINFO *info,int index);
static void insert_string(DIAINFO *info,char *str);

char *_edit_get_info(OBJECT *tree,int obj,int index,EDINFO *ed)
{
	reg OBJECT *obptr;
	reg TEDINFO *ted;
	reg char *edit,*masc,c,u='_';
	reg int x,idx,width;

	if (obj<=0 || index<0)
		return (NULL);

	obptr = &tree[obj];
	ted = obptr->ob_spec.tedinfo;

	if (ted->te_font==SMALL)
	{
		ed->cw = gr_sw;
		ed->ch = gr_sh;
	}
	else
	{
		ed->cw = gr_cw;
		ed->ch = gr_ch;
	}

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

static void draw_cursor(DIAINFO *info,EDINFO *ed)
{
	GRECT cursor,work;

	_calc_cursor(info,ed,&cursor);
	if (info->di_flag>=WINDOW)
	{
		wind_xget(info->di_win->handle,WF_FIRSTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
		while (work.g_w>0 && work.g_h>0)
		{
			if (rc_intersect(&cursor,&work))
				rc_sc_invert(&work);
			wind_xget(info->di_win->handle,WF_NEXTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
		}
	}
	else if (info->di_flag>CLOSED)
		rc_sc_invert(&cursor);
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

static EDINFO ed;

EDINFO *_cursor_off(DIAINFO *info)
{
	if (_edit_get_info(info->di_tree,info->di_ed_obj,info->di_ed_index,&ed)!=NULL)
	{
		if (!info->di_win->iconified && info->di_cursor)
		{
			graf_mouse(M_OFF,NULL);
			if (info->di_flag>=WINDOW)
				wind_update(BEG_UPDATE);

			draw_cursor(info,&ed);

			if (info->di_flag>=WINDOW)
				wind_update(END_UPDATE);
			graf_mouse(M_ON,NULL);
		}

		info->di_cursor = FALSE;
		return (&ed);
	}
	else
		return (NULL);
}

void _set_cursor(DIAINFO *info,int obj,int index)
{
	reg TEDINFO *ted;
	reg char *masc;
	reg int new_ob,len = 0;

	if (obj<0)
		obj = info->di_ed_obj;

	if (info->di_win->iconified || obj<0)
	{
		info->di_cursor = FALSE;
		return;
	}

	ted = info->di_tree[obj].ob_spec.tedinfo;
	if (index<0 && (index=info->di_ed_index)<0)
		index = (int) strlen(ted->te_ptext);
	else
		index = max(min(index,(int) strlen(ted->te_ptext)),0);

	new_ob = (obj!=info->di_ed_obj);

	if (new_ob || index!=info->di_ed_index || info->di_cursor==FALSE)
	{
		if (new_ob)
			_insert_history(info);

		graf_mouse(M_OFF,NULL);
		if (info->di_flag>=WINDOW)
			wind_update(BEG_UPDATE);

		if (info->di_cursor)
		{
			_edit_get_info(info->di_tree,info->di_ed_obj,info->di_ed_index,&ed);
			draw_cursor(info,&ed);
			info->di_cursor = FALSE;
		}

		info->di_ed_obj = obj;
		ted = info->di_tree[obj].ob_spec.tedinfo;

		if (new_ob)
		{
			masc = ted->te_ptmplt;
			while (*masc)
				if (*masc++=='_')
					len++;
			ted->te_editlen = len;
		}

		if (info->di_insert==FALSE)
			index = min(index,ted->te_editlen-1);

		info->di_ed_index = index;

		if (info->di_drawn)
		{
			_edit_get_info(info->di_tree,obj,index,&ed);
			draw_cursor(info,&ed);
			info->di_cursor = TRUE;
		}

		if (info->di_flag>=WINDOW)
			wind_update(END_UPDATE);
		graf_mouse(M_ON,NULL);

		if (new_ob)
			strncpy(info->di_undobuff,ob_get_text(info->di_tree,info->di_ed_obj,0),MAX_EDIT-1);
	}
}

static void first_edit(DIAINFO *info)
{
	reg OBJECT *obj = info->di_tree;
	reg int index= 0;

	if (info->di_ed_cnt<=1)
		return;

	do
	{
		obj++;index++;
		if ((obj->ob_flags & EDITABLE) && !_is_hidden(info->di_tree,index))
		{
			_set_cursor(info,index,0);
			break;
		}
	}
	while (!(obj->ob_flags & LASTOB));
}

static void last_edit(DIAINFO *info)
{
	reg OBJECT *obj = info->di_tree;
	reg int index,last;

	if (info->di_ed_cnt<=1)
		return;

	index = last = 0;
	do
	{
		obj++;index++;
		if ((obj->ob_flags & EDITABLE) && !_is_hidden(info->di_tree,index))
			last = index;
	}
	while (!(obj->ob_flags & LASTOB));

	if (last)
		_set_cursor(info,last,0x1000);
}

int _next_edit(DIAINFO *info,int first)
{
	reg int index = info->di_ed_obj;
	reg OBJECT *obj = &info->di_tree[index];

	if (info->di_ed_cnt<=1)
		return(FALSE);

	if (!(obj->ob_flags & LASTOB))
	{
		do
		{
			obj++;index++;
			if ((obj->ob_flags & EDITABLE) && !_is_hidden(info->di_tree,index))
			{
				_set_cursor(info,index,0x1000);
				return(TRUE);
			}
		}
		while (!(obj->ob_flags & LASTOB));
	}

	if (first)
	{
		first_edit(info);
		_set_cursor(info,FAIL,0x1000);
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

	do
	{
		obj--;index--;
		if ((obj->ob_flags & EDITABLE) && !_is_hidden(info->di_tree,index))
		{
			_set_cursor(info,index,0x1000);
			return;
		}
	} while (index>0);
	
	last_edit(info);
}

static int cursor_handler(DIAINFO *info,int state,int scan,XEVENT *event)
{
	reg char *text = ob_get_text(info->di_tree,info->di_ed_obj,0);
	reg int ascii;

	if (!(state & K_CTRL))
	{
		if (state & 3)
		{
			switch(scan)
			{
			case SCANBS:
				if (info->di_ed_index>0)
				{
					_cursor_off(info);
					strcpy(text,&text[info->di_ed_index]);
					ob_draw_chg(info,info->di_ed_obj,NULL,FAIL,TRUE);
					_set_cursor(info,FAIL,0);
				}
				break;
			case SCANDEL:
				_cursor_off(info);
				text[info->di_ed_index] = '\0';
				ob_draw_chg(info,info->di_ed_obj,NULL,FAIL,TRUE);
				_set_cursor(info,FAIL,FAIL);
				break;
			case SCANRET:
			case SCANENTER:
			case SCANTAB:
				prev_edit(info);
				break;
			case SCANUP:
				first_edit(info);
				break;
			case SCANHOME:
				last_edit(info);
				break;
			case SCANDOWN:
				last_edit(info);
			case SCANLEFT:
				_set_cursor(info,FAIL,0);
				break;
			case SCANRIGHT:
				_set_cursor(info,FAIL,0x1000);
				break;
			case SCANINS:
				ascii = ascii_box(info->di_title);
				_init_xformdo(event,NULL,FAIL);
				if (ascii)
					insert_char(info,ascii);
				break;
			default:
				return(FALSE);
			}
		}
		else
		{
			switch(scan)
			{
			case SCANESC:
				insert_string(info,"");
				break;
			case SCANBS:
				if (info->di_ed_index>0)
					delete_char(info,info->di_ed_index-1);
				break;
			case SCANDEL:
				delete_char(info,info->di_ed_index);
				break;
			case SCANHOME:
				first_edit(info);
				break;
			case SCANUP:
				prev_edit(info);
				break;
			case SCANDOWN:
			case SCANTAB:
			case SCANENTER:
				_next_edit(info,TRUE);
				break;
			case SCANINS:
				_cursor_off(info);
				info->di_insert = (info->di_insert) ? FALSE : TRUE;
				_set_cursor(info,FAIL,FAIL);
				break;
			case SCANLEFT:
				_set_cursor(info,FAIL,max(info->di_ed_index-1,0));
				break;
			case SCANRIGHT:
				_set_cursor(info,FAIL,info->di_ed_index+1);
				break;
			default:
				return(FALSE);
			}
		}

		return(TRUE);
	}
	else
		return(FALSE);
}

static char ted_char(char valid, reg unsigned char c)
{
	switch (valid)
	{
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
	case '9':
		if (c>='0' && c<=valid)
			return (c);
		break;
	case 'h':
		c = _lower(c);
		if ((c>='0' && c<='9') || (c>='a' && c<='f'))
			return (c);
		break;
	case 'H':
		c = _upper(c);
		if ((c>='0' && c<='9') || (c>='A' && c<='F'))
			return (c);
		break;
	case 'N':
		if (c>='0' && c<='9')
			return (c);
	case 'A':
		c = _upper(c);
		if ((c>='A' && c<='Z') || c==' ')
			return (c);
		break;
	case 'n':
		if (c>='0' && c<='9')
			return (c);
	case 'a':
		c = _lower(c);
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
		if ((c>='A' && c<='Z') || (c>='a' && c<='z') || (c>='0' && c<='9') || strchr(" _!@#$%^&()+-=~\'`;\",<>|[]{}",c))
			return (c);
		break;
	case 'U':
		c = _upper(c);
		if (c>=32 && c<=127)
			return (c);
		break;
	case 'u':
		c = _lower(c);
		if (c>=32 && c<=127)
			return (c);
		break;
	case 'V':
		c = _upper(c);
		if (c>=32)
			return (c);
		break;
	case 'v':
		c = _lower(c);
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
	case 'X':
	default:
		return (c);
	}

	return ('\0');
}

static void insert_string(DIAINFO *info,char *str)
{
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char c,v,*text = ted->te_ptext,*valid = ted->te_pvalid;
	reg int len = ted->te_editlen;

	_cursor_off(info);

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

	ob_draw_chg(info,info->di_ed_obj,NULL,FAIL,FALSE);
	_set_cursor(info,FAIL,0x1000);
}

static void new_edit(DIAINFO *info, char *new, char *text, char *edit,int index, int len)
{
	char new_text[MAX_EDIT<<1],old_text[MAX_EDIT<<1];
	reg EDINFO *ed;
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

		ed = _cursor_off(info);
		ed->text_x += offset*ed->cw;
		ed->text_w = width*ed->cw;
		ob_draw_chg(info,info->di_ed_obj,(GRECT *) &ed->text_x,FAIL,FALSE);
	}

	_set_cursor(info,FAIL,index);
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
		new_edit(info,buf,text,ted->te_ptmplt,index,ted->te_editlen);
	}
}

static int insert_char(DIAINFO *info,int scan)
{
	char buf[MAX_EDIT<<1];
	reg TEDINFO *ted = info->di_tree[info->di_ed_obj].ob_spec.tedinfo;
	reg char v,*text = ted->te_ptext,*valid = ted->te_pvalid;
	reg int idx,offset,taken;

	offset = idx = min(ted->te_editlen-1,info->di_ed_index);
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

		new_edit(info,buf,text,ted->te_ptmplt,info->di_ed_index+1,ted->te_editlen);
	}

	return (taken);
}

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

static boolean clipbrd_save(DIAINFO *info,int mode)
{
	char path[256],buf[MAX_EDIT+4],*text=ob_get_text(info->di_tree,info->di_ed_obj,0);
	long len;
	int handle;

	scrp_read(path);
	if (*path)
	{
		_strmfp(path,NULL,"scrap.txt");
		if ((handle = open(path,mode))>0)
		{
			len = strlen(text);
			strcpy(buf,text);
			buf[len++] = '\r';
			buf[len++] = '\n';
#ifdef __MINT_LIB__
			write(handle,buf,(unsigned) len);
#else
			write(handle,buf,len);
#endif
			close(handle);
			scrp_changed(SCF_TEXT,0x2e545854l);	/* .TXT */
			return(TRUE);
		}
	}
	return(FALSE);
}

static void clipbrd_load(DIAINFO *info,boolean flag)
{
	char path[256],buf[MAX_EDIT];
	int handle;

	scrp_read(path);
	if (path[0]!='\0')
	{
		_strmfp(path,NULL,"scrap.txt");
		if ((handle = open(path,O_RDONLY))>0)
		{
			if (read(handle,buf,MAX_EDIT-1)>0);
			{
				reg char *line;
				
				buf[MAX_EDIT-1] = '\0';
				if ((line = strchr(buf,'\r'))!=NULL || (line = strchr(buf,'\n'))!=NULL)
					*line = '\0';

				if (flag)
				{
					char str[MAX_EDIT<<1];

					strcpy(str,ob_get_text(info->di_tree,info->di_ed_obj,0));
					strcat(str,buf);
					strncpy(buf,str,MAX_EDIT-1);
				}

				insert_string(info,buf);
			}
			close(handle);
		}
	}
}

static boolean word_char(char c)
{
	if (c)
		if (isalnum(c) || strchr(umlaute,c)!=NULL)
			return(TRUE);
	return(FALSE);
}

static int value[] = {7,8,9,4,5,6,1,2,3,0};

int _objc_edit_handler(DIAINFO *info,int state,int scan,XEVENT *event,int *edited)
{
	reg int old_obj = info->di_ed_obj;
	reg int sn = (int) (((unsigned) scan)>>8),shft = (state&3);
	reg char old_edit[MAX_EDIT],*text = ob_get_text(info->di_tree,old_obj,0);

	strcpy(old_edit,text);

	info->di_taken = TRUE;
	if (cursor_handler(info,state,sn,event)==FALSE)
	{
		if (sn==SCANUNDO)
			insert_string(info,info->di_undobuff);
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
		else if (state & K_CTRL)
		{
			reg char *c	= text+info->di_ed_index;

			switch (sn)
			{
			case CTRLLEFT:
				while (c>text && word_char(*(--c)));
				while (c>text && !word_char(*(--c)));
				_set_cursor(info,FAIL,(c>text) ? (int) (c - text + 1) : 0);
				break;
			case CTRLRIGHT:
				while (word_char(*c++));
				if (*(--c) != '\0')
				{
					while (!word_char(*c++));
					if (*(--c) != '\0')
						_set_cursor(info,FAIL,(int) (c - text));
				}
				else
					_set_cursor(info,FAIL,(int) (c - text));
				break;
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
									insert_string(info,history[i]);
									hist_index = i;
									break;
								}
						}
					}
					else
					{
						if ((hist_index<(HISTORY-1)) && (history[hist_index+1][0]))
							hist_index++;
						insert_string(info,history[hist_index]);
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
								insert_string(info,history[i]);
								hist_index = i;
								break;
							}
					}
				}
				else
				{
					if (hist_index>0 && history[hist_index-1][0])
						hist_index--;
					insert_string(info,history[hist_index]);
				}
				break;
			default:
				{
					int ascii = scan_2_ascii(scan,state),flag;

					switch (ascii)
					{
					case 'X':
					case 'C':
						if (shft)
							flag = clipbrd_save(info,O_WRONLY|O_APPEND|O_CREAT);
						else
						{
							scrp_clear(0);
							flag = clipbrd_save(info,O_WRONLY|O_CREAT);
						}

						if (flag && ascii=='X')
						{
							_cursor_off(info);
							ob_get_text(info->di_tree,info->di_ed_obj,1);
							ob_draw_chg(info,info->di_ed_obj,NULL,FAIL,TRUE);
							_set_cursor(info,FAIL,FAIL);
						}
						break;
					case 'V':
						clipbrd_load(info,(shft) ? TRUE : FALSE);
						break;
					default:
						info->di_taken = FALSE;
						break;
					}
				}
				break;
			}
		}
		else
			info->di_taken = insert_char(info,scan);
	}

	if (info->di_taken && old_obj==info->di_ed_obj && strcmp(old_edit,text))
		*edited = TRUE;
	else
		*edited = FALSE;

	return(FAIL);
}

char ascii_box(char *title)
{
	static int fix = TRUE;
	int exit;

	if (fix)
	{
		rsrc_calc(ascii_tree,SCALING,8,16);
		fix = FALSE;
	}

	exit = xdialog(ascii_tree,title,TRUE,FALSE,AUTO_DIAL|MODAL);

	if (exit>0)
	{
		if (exit!=CANCEL)
		{
			int x,ox,d,ascii;

			_mouse_pos(&x,&d);
			objc_offset(ascii_tree,exit,&ox,&d);
			_no_click();

			ascii = (exit - ASC0)<<5;
			if ((d = x-ox)>=0)
				ascii += d/gr_cw;
			ascii = min(max(ascii,0),255);

			return(ascii);
		}
	}

	return(0);
}
