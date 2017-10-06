
/* FontPalette (PRG/ACC), (c) 1994/95 by C. Grunenberg */

#include "..\keys.c"
#include <stdlib.h>

#include <rsc.h>
#include "font_rsc.c"
#include "font_rsc.h"

#define ICONS	5
#define ICONW	48
#define ICONH	32

#define DIALGADGETS	WIN_DIAL|WD_HSLIDER|WD_VSLIDER|WD_FULLER|WD_SIZER|WD_SET_SIZE

char *help_text =
"_ FontPalette: |^|"\
"^>\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"||"\
"  New font:      CTRL-N|"\
"  Edit font:     CTRL-E,Return|"\
"  Delete font:   Delete|"\
"  Scroll list:|"\
"  Use (SHIFT/CTRL+) Cursor-Keys";

DIAINFO *dialog;
WIN	*window;
OBJECT *di_tree,*menu,*cr_tree;

XPOPUP win_menu = {{NULL,0l,MENU,MENU,FAIL,FALSE,FALSE,0l},1,POPUP_BTN|POPUP_MENU|POPUP_NO_SHADOW,FAIL,MENUPOS,0,0,FAIL,FAIL,0},*menu_list[] = {&win_menu,NULL};
FONTSEL fsel = {NULL,NULL,NULL,NULL,0,NORMAL,FS_GADGETS_STANDARD,FS_FNT_ALL,FAIL,FAIL,{0,0},{TRUE,DIA_MOUSEPOS,FALSE,TRUE,TRUE,FS_ACT_NONE},NULL,NULL,0,0,0,BLACK};

#define fnt_h(fnt)	(preview ? (fnt)->ch : height)

typedef struct
{
	int id,size,len,cw,ch;
} FONT;

#define FSIZE		sizeof(FONT)
#define MAX_FONTS	256
#define MAX_SIZES	16
#define MAX_PAL		512

FONT flist[MAX_PAL],*font_list;
SCROLL scroll;

int list_cnt,act_entry=-1,preview=TRUE,height,max_fonts,sort_mode;

char entry[]="  FontPalette\0XDSC\0""1Fontselector\0XFontSelect\0",*title=&entry[2],*id="FPAL",
	 *disc_error="Couldn't read/write palette!",*entry_error="Not enough entries available!",
	 path[MAX_PATH],info[64],file_list[MAX_PATH];

char *getcwd(char *,int);
void SetScroll(int,int);
void HandleDialog(void);

void alert(int icon,char *title,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,NULL);
}

void error(int icon,char *msg)
{
	alert(icon,title,msg);
}

char *entry_name(char *text,int id,int size)
{
	int2str(strlcpy(strlcpy(text,FastFontInfo(id)->name),", "),size,0);
	return(strcat(text," pts"));
}

void kill_entry(int entry,int update)
{
	if (entry<0)
		return;

	if (entry<(max_fonts-1))
		memcpy(&font_list[entry],&font_list[entry+1],FSIZE*(max_fonts-1-entry));
	act_entry = --list_cnt>0 ? min(act_entry,list_cnt-1) : -1;

	if (update)
		SetScroll(TRUE,FALSE);
}

void LoadList(char *fname)
{
	char file[MAX_PATH],filepath[MAX_PATH];

	if (fname || FileSelect("Load font-palette...",path,file,"*.fpl",TRUE,0,NULL)>0)
	{
		int hd;
		long handle;

		if (fname)
			strcpy(filepath,fname);
		else
			MakeFullpath(filepath,path,file);

		if ((handle=Fopen(filepath,0))>0)
		{
			GRECT work;
			if (Fread(hd=(int) handle,4,file)==4 && !strncmp(id,file,4) && Fread(hd,8,&work)==8)
			{
				FONT *fnt=&font_list[0];
				int i,cnt;

				if (Fread(hd,2,&cnt)==2 && (cnt=min(cnt,max_fonts))>0)
				{
					Fread(hd,2,&preview);
					Fread(hd,2,&fsel.options);
					Fread(hd,FSIZE*(list_cnt=cnt),fnt);
					Fclose(hd);

					act_entry = -1;
					for (i=0;i<list_cnt;)
					{
						if (v_set_font(fnt->id)!=fnt->id)
							kill_entry(i,FALSE);
						else
						{
							fnt++;
							i++;
						}
					}

					*(GRECT *) &di_tree->ob_x = work;
					strcpy(file_list,filepath);

					if (dialog)
					{
						windial_calc(TRUE,dialog,&work);
						window_calc(WC_BORDER,window->gadgets,&work,&window->curr);
					}

					ob_select(dialog,di_tree,PREVIEW,preview,dialog!=NULL);
					SetScroll(TRUE,TRUE);
					return;
				}
			}
			Fclose((int) handle);
		}
		error(X_ICN_DISC_ERR,disc_error);
	}	
}

void SaveList(char *fname)
{
	char file[MAX_PATH],filepath[MAX_PATH];

	if (fname && *GetFilename(fname)=='\0')
	{
		strcpy(path,fname);
		fname = NULL;
	}

	if (list_cnt>0 && (fname || FileSelect("Save font-palette as...",path,file,"*.fpl",TRUE,0,NULL)>0))
	{
		int hd;
		long handle;

		if (fname)
			strcpy(filepath,fname);
		else
			MakeFullpath(filepath,path,file);

		if ((handle=Fcreate(filepath,0))>0)
		{
			Fwrite(hd=(int) handle,4,id);
			Fwrite(hd,8,&di_tree->ob_x);
			Fwrite(hd,2,&list_cnt);
			Fwrite(hd,2,&preview);
			Fwrite(hd,2,&fsel.options);
			Fwrite(hd,FSIZE*list_cnt,font_list);
			Fclose(hd);

			drive_changed(GetDrive(filepath));
			strcpy(file_list,filepath);
			SetScroll(FALSE,FALSE);
		}
		else
			error(X_ICN_DISC_ERR,disc_error);
	}
}

int compare(FONT *f1,FONT *f2)
{
	int cmp1=f1->size-f2->size,cmp2=strcmp(FastFontInfo(f1->id)->name,FastFontInfo(f2->id)->name);
	return(sort_mode ? (cmp1 ? cmp1 : cmp2) : (cmp2 ? cmp2 : cmp1));
}

void SortList(void)
{
	if ((sort_mode=xalert(3,3,X_ICN_QUESTION,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,"Sort font-palette?","[Name|[Size|[Cancel"))<2)
	{
		qsort(font_list,list_cnt,FSIZE,compare);
		SetScroll(TRUE,TRUE);
	}
}

void set_entry(FONT *fnt,int id,int size)
{
	char text[64];
	int out[4];

	v_set_text(fnt->id=id,-size,FAIL,FAIL,FAIL,out);
	fnt->len = (int) strlen(entry_name(text,id,fnt->size=size));
	fnt->cw = out[2];
	fnt->ch = out[3]+1;
}

void MakeList(int make,int type,int min_size,int max_size)
{
	act_entry = -1;
	list_cnt = 0;
	GetFilename(file_list);

	if (make)
	{
		FONTINFO *flist[MAX_FONTS],*font_info;
		FONT *fnt=&font_list[0];
		int sizes[MAX_SIZES],cnt,fonts,i,j;

		fonts = FontList(type,min_size,max_size,MAX_FONTS,flist,0l);
		for (i=0;i<fonts && list_cnt<max_fonts;i++)
		{
			cnt = FontSizes((font_info=flist[i])->id,FALSE,min_size,max_size,MAX_SIZES,sizes,0l);
			for (j=0;j<cnt && list_cnt<max_fonts;j++,list_cnt++)
				set_entry(fnt++,font_info->id,sizes[j]);
		}
		if (list_cnt==max_fonts)
			error(X_ICN_ALERT,entry_error);
	}
	SetScroll(TRUE,TRUE);
}

int entry_pos(int entry,int sc,long *ypos,long *vpos)
{
	FONT *fnt=&font_list[0];
	GRECT work;
	long y;
	int i,h,ys,ye;

	if (entry<0 || list_cnt==0 || !window_work(window,&work))
		return(0);

	for (i=entry,y=0;--i>=0;y+=fnt_h(fnt++));

	if (vpos)
		*vpos = y;

	ye = (ys=work.g_y)+work.g_h-1;
	y += ys-scroll.vpos;

	if (ypos)
		*ypos = y;

	h = fnt_h(fnt);
	return(sc ? (y>=ys && y<=(ye-h)) : ((y+h)>=ys && y<=ye));
}

int get_entry(int y_pos,long *y_start)
{
	FONT *fnt=&font_list[0];
	long yo=scroll.vpos-(window->work.g_y+scroll.tbar_u),ys=yo+y_pos,y;
	int i;

	for (y=i=0;y<=ys;i++,fnt++)
	{
		if (i>=list_cnt)
			return(FAIL);
		y += fnt_h(fnt);
	}

	if (i>0)
	{
		fnt--;
		i--;
		y -= fnt_h(fnt);
	}

	if (y_start)
		*y_start = y-yo;

	return(i);
}

void invert(int f,WIN *w,GRECT *r,GRECT *wo,void *p)
{
	rc_sc_invert(r);
}

void InvertEntry(int entry)
{
	GRECT area,work;
	long y;

	if (!window_work(window,&area) || !entry_pos(entry,FALSE,&y,NULL))
		return;

	work = area;
	work.g_y = (int) y;
	work.g_h = fnt_h(&font_list[entry])-1;
	if (rc_intersect(&area,&work))
		draw_window(window,&work,0l,MOUSE_TEST,invert);
}

void sort_entry(int entry1,int entry2)
{
	FONT fnt=font_list[entry1];

	if (entry1<(max_fonts-1))
		memcpy(&font_list[entry1],&font_list[entry1+1],FSIZE*(max_fonts-1-entry1));
	if (entry2<(max_fonts-1))
		memcpy(&font_list[entry2+1],&font_list[entry2],FSIZE*(max_fonts-1-entry2));
	memcpy(&font_list[act_entry=entry2],&fnt,FSIZE);
	SetScroll(TRUE,FALSE);
}

void Edit(int entry)
{
	if (entry>=0)
	{
		FONT *fnt=&font_list[entry];

		fsel.title = "FontPalette: Edit font...";
		fsel.id = fnt->id;
		fsel.size = fnt->size;
		if (FontSelect(FSEL_DIAL,&fsel)==FS_OK)
		{
			set_entry(fnt,fsel.id,fsel.size);
			if (preview)
				SetScroll(TRUE,FALSE);
			else
			{
				GRECT area;
				long y;

				if (!window_work(window,&area) || !entry_pos(entry,FALSE,&y,NULL))
					return;

				area.g_y = (int) y;
				area.g_h = fnt_h(&font_list[entry]);
				redraw_window(window,&area);
			}
		}
	}
}

void New(void)
{
	if (list_cnt<max_fonts)
	{
		fsel.title = "FontPalette: New font...";
		if (FontSelect(FSEL_DIAL,&fsel)==FS_OK)
		{
			set_entry(&font_list[act_entry=list_cnt++],fsel.id,fsel.size);
			SetScroll(TRUE,FALSE);
		}
	}
	else
		error(X_ICN_ALERT,entry_error);
}

void SetScroll(int init,int home)
{	
	FONT *fnt=font_list;
	int i=list_cnt,w=0,h,draw=(dialog!=NULL),disable=(list_cnt==0);

	scroll.scroll = AUTO_SCROLL;
	scroll.px_hline = scroll.px_vline = 1;

	if (preview)
	{
		for (h=0;--i>=0;fnt++)
		{
			w = max(w,fnt->cw*fnt->len);
			h += fnt->ch;
		}
		scroll.hscroll = scroll.vscroll = 32;
	}
	else
	{
		for (;--i>=0;fnt++)
			w = max(w,fnt->len);
		w *= (scroll.hscroll=gr_cw);
		h = list_cnt*(scroll.vscroll=height);
	}

	scroll.hsize = w;
	scroll.vsize = h;

	if (list_cnt>0)
	{
		int2str(strlcpy(strlcpy(info,*GetFilename(file_list) ? GetFilename(file_list) : "New palette"),", "),list_cnt,0);
		strcat(info," entries");
	}
	else
		strcpy(info,"No entries");
	ob_draw(dialog,INFOBOX);

	ob_disable(dialog,di_tree,EDIT,disable,draw);
	ob_disable(dialog,di_tree,CLEAR,disable,draw);
	ob_disable(dialog,di_tree,SORT,disable,draw);
	ob_disable(NULL,menu,SAVE,disable,FALSE);
	ob_disable(NULL,menu,SAVEAS,disable,FALSE);
	ob_disable(NULL,menu,CLEARPAL,disable,FALSE);

	if (init)
	{
		if (home)
		{
			act_entry = (list_cnt>0) ? 0 : -1;
			scroll.hpos = scroll.vpos = 0;
		}
		if (window)
			window_reinit(window,title,NULL,info,home,TRUE);
	}
}

void OpenDialog(void)
{
	SetScroll(FALSE,FALSE);
	if (dialog==NULL)
	{
		if ((dialog=open_dialog(di_tree,title,NULL,NULL,DIA_LASTPOS,FALSE,DIALGADGETS,0,0l,menu_list))!=NULL)
		{
			window = dialog->di_win;
			scroll.tbar_u =  di_tree[scroll.obj=DIALVIEW].ob_y+dialog->di_xy_off;
			scroll.tbar_l = di_tree[DIALVIEW].ob_x+dialog->di_xy_off;
			scroll.tbar_d = scroll.tbar_r = 0;

			window->min_w = (ICONW*2) + (window->curr.g_w - window->work.g_w);
			window->min_h = (ICONH*ICONS) + (window->curr.g_h - window->work.g_h);
			window->scroll = &scroll;
			window_size(window,&window->curr);

			WindowItems(window,SCROLL_KEYS,scroll_keys);
	
			HandleDialog();
		}
		else
			error(X_ICN_ALERT,"No more windows available!");
	}
}

void CloseDialog(void)
{
	close_all_dialogs();
	dialog = NULL;
	window = NULL;

	if (_app)
		exit_gem(TRUE,0);
}

void HandleDialog(void)
{
	long ypos;
	int exit,dclick,entry,y,b,d;

	while ((exit=XFormObject(NULL,&dclick))>0)
	{
		switch (exit)
		{
		case NEW:
			New();break;
		case EDIT:
			Edit(act_entry);break;
		case SORT:
			SortList();break;
		case CLEAR:
			ob_select(dialog,di_tree,exit,FALSE,TRUE);
			kill_entry(act_entry,TRUE);
			continue;
		case HELP:
			alert(X_ICN_INFO,NULL,help_text);break;
		case DIALVIEW:
			mouse(NULL,&y);
			if ((entry=get_entry(y,&ypos))>=0)
			{
				if (dclick&DOUBLE_CLICK)
					Edit(entry);
				else if ((b=mouse(NULL,NULL))!=0)
				{
					FONT *fnt=&font_list[entry];
					GRECT drag;
					int x,w,k,app;

					window_work(window,&drag);
					drag.g_y = (int) ypos;
					drag.g_h = fnt_h(fnt);
					graf_rt_dragbox(FALSE,&drag,&desk,&d,&d,0l);
					graf_mkstate(&x,&y,&d,&k);
					k &= K_SHIFT|K_ALT;

					if ((w=wind_find(x,y))==window->handle)
					{
						if (!rc_inside(x,y,&drag) && (b=get_entry(y,NULL))>=0 && entry!=b)
							sort_entry(entry,b);
						break;
					}
					else if (owner && (w>0 || !_app) && wind_xget(w,WF_OWNER,&b,&d,&d,&d))
						app = b;
					else if (!multi && !_app)
						app = 0;
					else
						break;
					FontChanged(app,k ? -1 : w,fnt->id,fnt->size,-1,-1);
				}
				else if (act_entry!=entry)
				{
					InvertEntry(act_entry);
					InvertEntry(act_entry=entry);
				}
			}
		}
		ob_select(dialog,di_tree,exit,FALSE,TRUE);
	}
	CloseDialog();
}

int get_type(int obj,int masc)
{
	return(ob_isstate(cr_tree,obj,SELECTED) ? masc : 0);
}

int InitEvent(XEVENT *ev,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	long ypos;
	int wi=ev->ev_mwich,*msg=ev->ev_mmgpbuf;

	if (wi&MU_MESAG)
		switch (msg[0])
		{
		case AC_OPEN:
		case FONT_SELECT:
			if (window)
			{
				WindowHandler(W_UNICONIFY,window,NULL);
				window_top(window);
			}
			else
				OpenDialog();
			break;
		case AP_TERM:
		case AC_CLOSE:
			CloseDialog();break;
		case OBJC_CHANGED:
			if (msg[3]==PREVIEW)
			{
				preview = ob_isstate(di_tree,PREVIEW,SELECTED);
				SetScroll(TRUE,FALSE);
			}
			break;
		case MN_SELECTED:
			switch (msg[4])
			{
			case OPEN:
				LoadList(NULL);break;
			case SAVE:
				SaveList(file_list);break;
			case SAVEAS:
				SaveList(NULL);break;
			case CREATPAL:
				if (FormObject(xdialog(cr_tree,NULL,NULL,NULL,DIA_MOUSEPOS,FALSE,FLY_DIAL))==CREATE)
				{
					char *misize=ob_get_text(cr_tree,FNTSIZE,0),*masize=misize+3,c;
					int type,mi,ma=999;

					type = get_type(FPROP,FS_FNT_PROP);
					type |= get_type(FMONO,FS_FNT_MONO);
					type |= get_type(FBITMAP,FS_FNT_BITMAP);
					type |= get_type(FVECTOR,FS_FNT_VECTOR);

					c = *masize;
					*masize = '\0';
					mi = atoi(misize);
					*masize = c;
					if (strlen(misize)>3)
						ma = atoi(masize);
					MakeList(TRUE,type,mi,ma);
					int2str(misize,mi,3);
					int2str(masize,ma,3);
				}
				break;
			case CLEARPAL:
				if (xalert(2,2,X_ICN_QUESTION,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,"Delete font-palette?","[Delete|[Cancel")==0)
					MakeList(FALSE,0,0,0);
				break;
			case QUIT:
				CloseDialog();
			}
			break;
		default:
			wi ^= MU_MESAG;
		}

	if ((wi&MU_KEYBD) && dialog)
	{
		int state=ev->ev_mmokstate,scan=ev->ev_mkreturn>>8,shift=(state&K_SHIFT),old;

		if (state&K_CTRL)
		{
			switch (scan_2_ascii(ev->ev_mkreturn,state))
			{
			case 'Q':
				CloseDialog();break;
			case 'O':
				LoadList(NULL);break;
			case 'S':
				SaveList(file_list);break;
			case 'M':
				SaveList(NULL);break;
			case 'N':
				New();break;
			case 'E':
				Edit(act_entry);break;
			default:
				wi ^= MU_KEYBD;
			}
		}
		else if (scan==SCANDEL)
			kill_entry(act_entry,TRUE);
		else if (scan==SCANRET)
			Edit(act_entry);
		else if (list_cnt>0)
		{
			switch (scan)
			{
			case SCANUP:
				if (shift)
					scroll_window(window,PAGE_UP,NULL);
				else if ((old=act_entry)>0)
				{
					act_entry = -1;
					InvertEntry(old--);
					if (!entry_pos(old,TRUE,NULL,&ypos))
					{
						scroll.vpos = ypos;
						scroll_window(window,WIN_SCROLL,NULL);
					}
					InvertEntry(act_entry=old);
				}
				else
				{
					scroll.vpos = 0;
					scroll_window(window,WIN_SCROLL,NULL);
				}
				break;
			case SCANDOWN:
				if (shift)
					scroll_window(window,PAGE_DOWN,NULL);
				else if ((old=act_entry)<(list_cnt-1))
				{
					act_entry = -1;
					InvertEntry(old++);
					if (!entry_pos(old,TRUE,NULL,&ypos))
					{
						scroll.vpos = ypos + fnt_h(&font_list[old]) - (window->work.g_h - scroll.tbar_u);
						scroll_window(window,WIN_SCROLL,NULL);
					}
					InvertEntry(act_entry=old);
				}
				else
				{
					scroll.vpos = scroll.vsize;
					scroll_window(window,WIN_SCROLL,NULL);
				}
				break;
			case SCANHOME:
				InvertEntry(act_entry);
				scroll.hpos = 0;
				scroll.vpos = (shift) ? scroll.vsize : 0;
				act_entry = -1;
				scroll_window(window,WIN_SCROLL,NULL);
				InvertEntry(act_entry=(shift) ? list_cnt-1 : 0);
				break;
			default:
				wi ^= MU_KEYBD;
			}
		}
		else
			wi ^= MU_KEYBD;
		if (wi&MU_KEYBD)
			ClrKeybd();
	}
	else
		wi &= ~MU_KEYBD;
	return(wi);
}

void Draw(WIN *win,GRECT *work)
{
	char text[64];
	FONT *fnt;
	long y;
	int i,x,h,xe,ye,old[4],new[4];
	GRECT invert;

	rc_sc_clear(work);
	if ((i=get_entry(work->g_y,&y))<0)
		return;

	save_clipping(old);
	rc_grect_to_array(work,new);
	restore_clipping(new);

	fnt = &font_list[i];

	v_set_mode(preview ? MD_TRANS : MD_REPLACE);
	v_set_line(BLACK,1,7,0,0);
	vsl_udsty(x_handle,0x5555);

	x = win->work.g_x+scroll.tbar_l-(int) scroll.hpos;
	xe = work->g_x+work->g_w-1;
	ye = work->g_y+work->g_h;
	while (i<list_cnt && (int) y<ye)
	{
		if (preview)
			v_set_text(fnt->id,-fnt->size,BLACK,0,0,NULL);
		else
			v_set_text(ibm_font_id,ibm_font,BLACK,0,0,NULL);
		v_gtext(x_handle,x,(int) y,entry_name(text,fnt->id,fnt->size));
		h = fnt_h(fnt);
		if (i==act_entry)
		{
			invert = *work;
			invert.g_y = (int) y;
			invert.g_h = h-1;
			if (rc_intersect(work,&invert))
				rc_sc_invert(&invert);
		}
		y += h;
		v_line(work->g_x,(int) y-1,xe,(int) y-1);
		fnt++;
		i++;
	}
	restore_clipping(old);
}

int cdecl DrawUser(PARMBLK *pb)
{
	GRECT work = *(GRECT *) &pb->pb_x;
	if (rc_intersect((GRECT *) &pb->pb_xc,&work))
		Draw(window,&work);
	return(0);
}

USERBLK draw_blk={DrawUser,0l};
int icons[ICONS] = {NEW,EDIT,SORT,CLEAR,HELP};

void InitResource(void)
{
	OBJECT *tree,*obj;
	int i,y,*icn;

	rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,NO_SCALING,rs_strings,rs_frstr,rs_bitblk,
			  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,0,0);
	tree = di_tree = (OBJECT *) rs_trindex[DIALOG];
	menu = win_menu.popup.p_menu = (OBJECT *) rs_trindex[MENUPOP];
	iconified = (OBJECT *) rs_trindex[ICON];
	cr_tree = (OBJECT *) rs_trindex[NEWPAL];

	for (y=0,i=ICONS,icn=icons;--i>=0;y+=ICONH)
	{
		obj = &tree[*icn++];
		obj->ob_y = y;
		obj->ob_width = ICONW;
		obj->ob_height = ICONH;
	}

	tree[PREVIEW].ob_y = (y+=gr_ch);
	tree[PREVIEWT].ob_y = (y+=gr_ch);
	tree[INFOBOX].ob_width = tree[MENUBOX].ob_width = desk.g_w;

	y = tree[MENUBOX].ob_y+tree[MENUBOX].ob_height;

	*(GRECT *) &tree->ob_x = desk;
	tree->ob_width >>= 1;
	tree->ob_height = y+gr_bh*2;

	obj = &tree[ICONBOX];
	obj->ob_y = y+2;
	obj->ob_width = ICONW;
	obj->ob_height = desk.g_h;

	obj = &tree[DIALVIEW];
	obj->ob_x = ICONW+8;
	obj->ob_y = y+1;
	obj->ob_width = desk.g_w;
	obj->ob_height = desk.g_h;
	obj->ob_type = G_USERDEF;
	obj->ob_spec.userblk = &draw_blk;

	ob_set_text(tree,INFOBOX,info);
}

void main(int argc,char **argv)
{
	if (init_gem(NULL,entry,title,"FONT_PAL",0,0,0)==TRUE)
	{
		FONT *fnt;
		char file[MAX_PATH];

		height = gr_ch+1;
		getcwd(path,(int) sizeof(path));

		fsel.options.preview = gr_ch<16 ? FALSE : TRUE;

		InitResource();
		dial_options(TRUE,TRUE,FALSE,RETURN_DEFAULT,AES_BACK,FALSE,KEY_STD,TRUE,FALSE,0);
		Event_Handler(InitEvent,Event);

		font_list = flist;
		max_fonts = MAX_PAL;
		if (_app || multi)
			if ((fnt=(FONT *) calloc(fonts_loaded*(MAX_SIZES>>1),FSIZE))!=NULL)
			{
				font_list = fnt;
				max_fonts = fonts_loaded*(MAX_SIZES>>1);
			}

		if (argc>1)
			LoadList(argv[1]);
		else
		{
			strcpy(file,"font_pal.fpl");
			if (shel_find(file))
				LoadList(file);
		}

		if (_app)
			OpenDialog();
		Event_Multi(NULL);
	}
}
