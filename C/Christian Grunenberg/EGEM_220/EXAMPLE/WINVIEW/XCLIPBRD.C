
/* XClipboard (PRG/ACC), (c) 1994/95 C. Grunenberg
   -> demonstriert die Verwendung von Fensterdialogen mit allen Fenster-
      elementen, wodurch hier eine Toolbar realisiert wird */

#include "data.h"
#include "..\keys.c"

#include <rsc.h>
#include "xcliprsc.c"
#include "xcliprsc.h"

#define ICNS	5
#define ICNW	48
#define ICNH	32

#define DIALGADGETS	WIN_DIAL|WD_HSLIDER|WD_VSLIDER|WD_FULLER|WD_SIZER|WD_INFO|WD_SET_SIZE

DIAINFO *dialog;
OBJECT *dialog_tree;
WIN *window;
DATA data;

long img_handle=FAIL;
int img_sender,meta,acc_img;

char temp[MAX_PATH],*ext,fext[5],*small_title="XClipbrd",entry[]="  XClipboard\0XDSC\0""1Clipboard\0XFontAck\0",*title=&entry[2],*info_file="xclipbrd.inf",*info_id="Viewer",
*help_text=
"_ XClipboard: |^|"\
"^\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"|^|"\
"^ Cut/Copy/Paste: CTRL-X/C/V|"\
"^ Save settings:  CTRL-S|"\
"^ Select font:    CTRL-T|"\
"^ Set tabulator:  TAB|"\
"^ Scroll picture: Use (SHIFT/CTRL+) Cursor-Keys";

void HandleDialog(void);

void error(int icon,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,NULL);
}

void SetScroll(void)
{
	char *name=data.fname[0] ? data.fname : "No name";
	int disable=(data.valid==0),draw=(dialog!=NULL);

	ob_disable(dialog,dialog_tree,CUT,disable,draw);
	ob_disable(dialog,dialog_tree,COPY,disable,draw);

	data.sc.scroll = AUTO_SCROLL;
	data.sc.hscroll = data.sc.vscroll = data.sc.px_hline = data.sc.px_vline = 1;

	switch (data.flag)
	{
	case IMAGE:
		data.sc.hsize = data.width;
		data.sc.vsize = data.height;
		data.sc.hscroll = data.sc.vscroll = 8;
		sprintf(data.info," %s (Image), %d x %d Pixel",name,data.width,data.height);
		break;
	case ASCII:
	case DUMP:
		data.sc.hsize = data.max_rows+1;
		data.sc.vsize = data.lines;
		data.sc.px_hline = data.font_cw;
		data.sc.px_vline = data.font_ch;
		if (data.flag==ASCII)
			sprintf(data.info," %s (Text), %ld Line(s), %d Column(s), Tab: %d",name,data.lines,data.max_rows,data.tab_size);
		else
			sprintf(data.info," %s (Data), %ld Bytes",name,data.size);
		break;
	default:
		data.sc.hsize = data.sc.vsize = 0;
		strcpy(data.info," No file.");
	}
}

void CloseImg(int succ)
{
	if (img_handle>0)
	{
		XAccSendAck(img_sender,succ);
		Fclose((int) img_handle);
		Fdelete(temp);
		img_handle = -1;
	}
}

void Paste(char *file,char *mem,long length,int new)
{
	if (new)
	{
		char scrap[MAX_PATH];

		meta = FALSE;
		ext = NULL;
		ClearData(&data);

		if (new!=FAIL)
		{
			if (file || mem)
			{
				if (LoadData(&data,file,mem,length) && file)
				{
					if (strcmp(file,temp))
						strcpy(data.fname,GetFilename(file));
					else
						data.fname[0] = '\0';
				}
				if (*(ext=GetExtension(data.fname))=='\0')
					ext = NULL;
			}
			else if (scrp_find("img.txt.asc.rtf.tex.csv.eps.*",scrap))
			{
				if ((ext=GetExtension(scrap))=='\0')
					ext = NULL;
				if (LoadData(&data,scrap,NULL,0l))
					strcpy(data.fname,"Clipboard");
			}
		}
	}

	SetScroll();
	if (dialog==NULL)
	{
		if ((dialog=open_dialog(dialog_tree,title,small_title,NULL,DIA_LASTPOS,FALSE,DIALGADGETS,0,0l,0l))!=NULL)
		{
			WindowItems(data.win=window=dialog->di_win,SCROLL_KEYS,scroll_keys);

			/* Breite der Toolbar berechnen */
			data.sc.tbar_l = ICNW+8+dialog->di_xy_off;
			data.sc.tbar_r = data.sc.tbar_u = data.sc.tbar_d = 0;

			data.sc.obj = DIALVIEW;	/* nur dieses Objekt beim Scrolling neuzeichnen */
			window->para = &data;	/* Fenster-Parameter setzen */

			/* neue, minimale Ausmaže setzen */
			window->min_w = ICNW*2+window->curr.g_w-window->work.g_w;
			window->min_h = ICNH*3+window->curr.g_h-window->work.g_h;

			/* Hierdurch werden die Slider u. die SCROLL-Struktur initialisiert */
			window->scroll = &data.sc;
			window_size(window,&window->curr);
			set.start = *(GRECT *) &dialog_tree->ob_x;
			window_info(window,data.info); /* Info-Zeile setzen */

			HandleDialog();	/* Dialog wieder ganz normal abarbeiten */
		}
		else
			error(X_ICN_ALERT,"No windows available!");
	}
	else
		window_reinit(window,title,small_title,data.info,TRUE,TRUE);
}

char *GetExt(void)
{
	if (ext)
		return(ext);
	else
		switch (data.flag)
		{
		case IMAGE:
			return(".img");
		case ASCII:
			return(".txt");
		}
	return(meta ? ".gem" : ".dat");
}

void Copy(void)
{
	char scrap[MAX_PATH];
	int err=0,scf_id=SCF_INDEF;
	long handle,scf_ext=0l;

	if (scrp_path(scrap,"scrap"))
	{
		scrp_clear(0);
		if (data.valid)
		{
			strcat(scrap,GetExt());
			memcpy(&scf_ext,GetExt(),4);
			if ((handle=Fcreate(scrap,0))>0)
			{
				err = (Fwrite((int) handle,data.size,data.data)!=data.size);
				Fclose((int) handle);
				if (err)
					Fdelete(scrap);
			}
			else
				err++;

			if (err)
			{
				error(X_ICN_DISC_ERR,"Couldn't copy|data on clipboard!");
				scf_ext = 0l;
			}
			else
				switch (data.flag)
				{
				case IMAGE:
					scf_id = SCF_RASTER;break;
				case ASCII:
					scf_id = SCF_TEXT;break;
				default:
					if (meta)
						scf_id = SCF_VECTOR;
				}
		}
		scrp_changed(scf_id,scf_ext);
	}
}

void Clear(void)
{
	switch (xalert(3,3,X_ICN_QUESTION,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,"Clear clipboard or memory?","Cli[pboard|[Memory|[Cancel"))
	{
	case 0:
		scrp_clear(0);scrp_changed(SCF_INDEF,0l);break;
	case 1:
		Paste(NULL,NULL,0l,FAIL);
	}
}

void CloseDialog(int all)
{
	if (all || _app)
	{
		CloseImg(FALSE);
		ClearData(&data);
		meta = FALSE;
	}

	close_all_dialogs();
	dialog = NULL;
	window = NULL;

	if (_app)
		exit_gem(TRUE,0);
}

void HandleDialog(void)
{
	GRECT start;
	XAcc *app;
	int exit,x,y,d,id,k;

	while ((exit=XFormObject(NULL,NULL))>0)
	{
		ob_select(dialog,dialog_tree,exit&=NO_CLICK,FALSE,TRUE);
		switch (exit)
		{
		case CUT:
			Copy();Paste(NULL,NULL,0l,FAIL);break;
		case COPY:
			Copy();break;
		case PASTE:
			Paste(NULL,NULL,0l,TRUE);break;
		case CLEAR:
			Clear();break;
		case HELP:
			if (xalert(2,2,X_ICN_INFO,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,NULL,help_text,"[Save setup|[Ok")==0)
				SaveInfoFile(info_file,TRUE,&set,(int) sizeof(SETUP),info_id,0x0100);
			break;
		case DIALVIEW:
			if (data.valid && mouse(NULL,NULL))
			{
				window_work(window,&start);
				graf_rt_dragbox(FALSE,&start,&desk,&d,&d,0l);
				graf_mkstate(&x,&y,&d,&k);
				switch (SendDragDrop(x,y,k,data.fname,GetExt(),data.size,(char *) data.data))
				{
				case NO_DD:
				case DD_NAK:
					wind_xget(wind_find(x,y),WF_OWNER,&id,&d,&d,&d);
					if ((app=find_id(id))!=NULL)
					{
						if (data.flag==IMAGE && (app->version&2))
							XAccSendImg(id,TRUE,(char *) data.data,data.size);
						else if (meta && (app->version&2))
							XAccSendMeta(id,TRUE,(char *) data.data,data.size);
						else if (data.flag==ASCII && (app->version&1))
							XAccSendText(id,(char *) data.data);
					}
				}
			}
		}
	}
	CloseDialog(FALSE);
}

void ReceiveData(int *msg)
{
	long len;

	if (img_handle>0 && img_sender!=msg[1])
		CloseImg(FALSE);

	if ((img_handle<=0 && msg[3]) || (acc_img && (img_handle>0 || (img_handle=Fcreate(temp,0))>0)))
	{
		img_sender = msg[1];

		len = *(long *) &msg[6];
		if (img_handle>0 && Fwrite((int) img_handle,len,*(char **) &msg[4])!=len)
			CloseImg(FALSE);
		else
		{
			if (img_handle<=0)
			{
				Paste(NULL,*(char **) &msg[4],len,TRUE);
				meta = (data.flag==DUMP);
			}
			XAccSendAck(msg[1],TRUE);
			if (img_handle>0 && msg[3])
			{
				Fclose((int) img_handle);
				Paste(temp,NULL,0l,TRUE);
				meta = (data.flag==DUMP);
				Fdelete(temp);
				img_handle = -1;
			}
		}
	}
	else
		XAccSendAck(msg[1],FALSE);
}

int Init(XEVENT *ev,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	DRAG_DROP *dd;
	char *text;
	int wi=ev->ev_mwich,*msg=ev->ev_mmgpbuf,sc=ev->ev_mkreturn,k;

	if (wi&MU_MESAG)
	{
		switch (msg[0])
		{
		case AC_OPEN:
			Paste(NULL,NULL,0l,data.valid ? FALSE : TRUE);break;
		case AC_CLOSE:
		case AP_TERM:
			CloseDialog(TRUE);break;
		case ACC_IMG:
		case ACC_META:
			ReceiveData(msg);break;
		case ACC_TEXT:
			text = *(char **) &msg[4];
			Paste(NULL,text,strlen(text),TRUE);
			XAccSendAck(msg[1],TRUE);
			break;
		case OBJC_SIZED:
			if (*(DIAINFO **) &msg[4]==dialog)
				set.start = *(GRECT *) &dialog_tree->ob_x;
			break;
		case OBJC_DRAGGED:
			dd = *(DRAG_DROP **) &msg[4];
			if (dd->dd_mem)
				Paste(dd->dd_name,dd->dd_mem,dd->dd_size,TRUE);
			else if (dd->dd_args)
				Paste(ParseArgs(dd->dd_args),NULL,0l,TRUE);
			else
			{
				Paste(NULL,NULL,0l,data.valid ? FALSE : TRUE);
				break;
			}
			if (data.valid)
			{
				if (data.fname[0]=='\0' && dd->dd_name)
				{
					strcpy(data.fname,GetFilename(dd->dd_name));
					SetScroll();
				}
				if (ext==NULL)
				{
					if (dd->dd_name && *(ext=GetExtension(dd->dd_name))!='\0')
						ext = strncpy(fext,ext,4);
					else if (dd->dd_ext[0])
						ext = strncpy(fext,dd->dd_ext,4);
				}
			}
			break;
		case FONT_CHANGED:
			msg[3] = FALSE;
			k = msg[4]<0 ? data.font.id : msg[4];
			if (data.flag==ASCII || (data.flag==DUMP && (FontInfo(k)->type & (FNT_PROP|FNT_ASCII))==0))
			{
				data.font.id = k;
				if (msg[5]>0)
					data.font.size = -msg[5];
				if (msg[6]>WHITE)
					data.font.color = msg[6];
				SetFont(&data,TRUE);
				SetScroll();
				window_reinit(window,title,small_title,data.info,FALSE,TRUE);
				msg[3] = TRUE;
			}
			FontAck(msg[1],msg[3]);
			break;
		default:
			wi ^= MU_MESAG;
		}
	}

	if ((wi&MU_KEYBD) && dialog)
	{
		if (ev->ev_mmokstate&K_CTRL)
		{
			switch (k=scan_2_ascii(sc,K_CTRL))
			{
			case 'Q':
				CloseDialog(FALSE);break;
			case 'V':
				Paste(NULL,NULL,0l,TRUE);break;
			case 'Y':
				Clear();break;
			case 'S':
				SaveInfoFile(info_file,TRUE,&set,(int) sizeof(SETUP),info_id,0x0100);break;
			default:
				if (data.valid)
				{
					switch (k)
					{
					case 'X':
						Copy();Paste(NULL,NULL,0l,FAIL);break;
					case 'C':
						Copy();break;
					case 'T':
						if (data.flag!=IMAGE && !CallFontSelector(window->handle,data.font.id,-data.font.size,data.font.color,-1))
							error(X_ICN_ALERT,"Fontselector not available!");
						break;
					default:
						wi ^= MU_KEYBD;
					}
				}
				else
					wi ^= MU_KEYBD;
			}
		}
		else if ((sc>>8)==SCANTAB && data.flag==ASCII)
		{
			if (data.tabs)
			{
				if (data.tab_size==0)
					data.tab_size++;
				else
					data.tab_size = (data.tab_size*2)&15;
				data.sc.hpos = 0;
				CalcText(&data);
				SetScroll();
				window_reinit(window,title,small_title,data.info,FALSE,TRUE);
			}
		}
		else
			wi ^= MU_KEYBD;
	}
	else
		wi &= ~MU_KEYBD;
	return(wi);
}

int cdecl DrawUser(PARMBLK *pb)
{
	GRECT work=*(GRECT *) &pb->pb_x;
	int old[4],new[4];

	if (rc_intersect((GRECT *) &pb->pb_xc,&work))
	{
		save_clipping(old);
		rc_grect_to_array(&work,new);
		restore_clipping(new);
		DrawData(0,window,&work);
		restore_clipping(old);
	}
	return(0);
}

int icons[]={CUT,COPY,PASTE,CLEAR,HELP};
USERBLK draw={DrawUser,0l};

void InitResource(void)
{
	OBJECT *tree,*obj;
	int i,y;

	rsrc_init(NUM_TREE,NUM_OBS,NUM_FRSTR,NUM_FRIMG,NO_SCALING,rs_strings,rs_frstr,rs_bitblk,
			  rs_frimg,rs_iconblk,rs_tedinfo,rs_object,(OBJECT **) rs_trindex,(RS_IMDOPE *) rs_imdope,8,16);
	tree = dialog_tree = (OBJECT *) rs_trindex[DIALOG];
	iconified = (OBJECT *) rs_trindex[ICON];

	*(GRECT *) &tree->ob_x = desk;
	tree->ob_width >>= 1;
	tree->ob_height >>= 1;

	for (y=i=0;i<ICNS;)
	{
		obj = tree+icons[i++];
		obj->ob_y = y;
		obj->ob_width = ICNW;
		y += (obj->ob_height=ICNH);
	}

	obj = &tree[ICONBOX];
	obj->ob_width = ICNW;
	obj->ob_height = desk.g_h;

	obj = &tree[DIALVIEW];
	obj->ob_x = ICNW+8;
	obj->ob_width = desk.g_w;
	obj->ob_height = desk.g_h;
	obj->ob_type = G_USERDEF;
	obj->ob_spec.userblk = &draw;
}

char ourexts[DD_EXTSIZE] = ".IMG.TXT.ASC.RTF.TEX.CSV.EPSARGS";

void main(int argc,char **argv)
{
	if (init_gem(NULL,entry,title,"XCLIPBRD",0,0,X_MSG_IMG|X_MSG_TEXT|X_MSG_META)==TRUE)
	{
		int info,d;

		if (!owner)
		{
			error(X_ICN_ERROR,"XClipboard needs Winx, MultiTasking|or GEM>=3.30 to run!");
			exit_gem(TRUE,-1);
		}

		InitResource();
		acc_img = scrp_path(temp,"__temp__.dat");

		set.text.id = ibm_font_id;
		set.text.size = ibm_font;
		set.dump = set.text;
		set.start = *(GRECT *) &dialog_tree->ob_x;

		if (LoadInfoFile(info_file,TRUE,&set,(int) sizeof(SETUP),14,info_id,0x0100)>=22 && set.start.g_w>0)
			*(GRECT *) &dialog_tree->ob_x = set.start;

		SetDragDrop(TRUE,ourexts);
		dial_options(TRUE,TRUE,FALSE,RETURN_DEFAULT,AES_BACK,FALSE,KEY_STD,TRUE,FALSE,0);
		Event_Handler(Init,Event);

		if (_app)
			Paste((argc>1) ? argv[1] : NULL,NULL,0l,TRUE);
		Event_Multi(NULL);
	}
}
