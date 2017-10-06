
/* XAcc-Monitor (PRG/ACC), (c) 1994/95 C. Grunenberg,
	Definition von SMALLTOOL: keine Informations/Hilfe/Fehlermeldungen */

#include "..\keys.c"

#define ROWS	512
#define OFFSET	2

SCROLL scroll={AUTO_SCROLL,0,0,0,0,0,0,0,0,0,ROWS,0,0,0,0,0,0,0,1,1};
GRECT start;
WIN *win;

XAcc *app[128];
int app_cnt,fntid,fntsize,fntcolor=BLACK,cw,ch;

#ifdef SMALLTOOL

#define GADGETS		NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE

char *av_name="MINIMONI",entry[]="  MiniMonitor\0XDSC\0XFontAck\0";

#else

#define GADGETS		NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER

char *av_name="XACCMONI",entry[]="  XAccMonitor\0XDSC\0XFontAck\0",*info_text=
"_ XAcc/AV-Monitor: |^|"\
"^>\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"||"\
"  Select font:     CTRL-T|"\
"  Save settings:   CTRL-S|"\
"  Scroll list:|"\
"  Use (SHIFT/CTRL+) Cursor-Keys";

#endif

char *x_name=&entry[2],buf[ROWS*2],xdsc[ROWS],info[64],
	 xacc_info[]=" Name                 Ap-ID  Menu-ID   Version    Groups  Extended Features",
	 xacc_out[]=" %-20s%4d%8d%5d.%d ($%02x,%2d) %s  %s",xacc_groups[8],*info_file="monitor.inf",*info_id="Monitor";

#ifndef SMALLTOOL

char icon_info[10];
TEDINFO tedinfo={icon_info,"","",5,0,2,0x1100,0x0,-1,8,1};
OBJECT icon={-1,-1,-1,G_TEXT,LASTOB,NORMAL,(long) &tedinfo,2,1,8,1};

int alert(int icn,int def,char *title,char *msg,char *btn)
{
	return(xalert(def,1,icn,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,btn));
}
#endif

void SaveInfo(void)
{
	int info[7],*p=info;
	*p++ = fntid;
	*p++ = fntsize;
	*p++ = fntcolor;
	*(GRECT *) p = start;
	SaveInfoFile(info_file,TRUE,info,14,info_id,0x0100);
}

int make_info(XAcc *xacc)
{
	char c,*name=xacc->xname ? xacc->xname : xacc->name,*p,*q;
	int vers=xacc->version>>8,low=0,high,i,bit;

	if (vers>='0' && vers<='9')
		high = vers-'0';
	else if (vers>=0x10)
	{
		high = vers>>4;
		low = vers & 0xf;
	}
	else
		high = vers;

	p = xacc_groups;
	*p++ = (xacc->flag&AV) ? 'A' : '_';
	*p++ = (xacc->flag&XACC) ? 'X' : '_';
	for (i=4,bit=8;--i>=0;bit>>=1)
		*p++ = (xacc->version & bit) ? i+'1' : '_';

	p = xdsc;
	if ((q=xacc->xdsc)!=NULL)
		for (p=xdsc;;)
		{
			while ((c=*q++)!='\0')
				*p++ = c;
			if (*q)
				*p++ = ' ';
			else
				break;
		}
	*p = '\0';

	return(sprintf(buf,xacc_out,name,xacc->id,xacc->menu_id,high,low,vers,vers,xacc_groups,xdsc));
}

void Draw(int first,WIN *win,GRECT *area)
{
	SCROLL *sc=win->scroll;
	XAcc **list;
	char c,*p;
	int cnt,x,y=win->work.g_y,line,extent[8];

	v_set_mode(MD_TRANS);
	v_set_text(fntid,fntsize,fntcolor,0,0,NULL);
	rc_sc_clear(area);

	y += (line=((area->g_y-y)/ch))*ch;
	list = &app[max((line+=(int) sc->vpos)-OFFSET,0)];

	for (;y<(area->g_y+area->g_h) && line<(int) scroll.vsize;line++,y+=ch)
	{
		x = win->work.g_x;
		switch (line)
		{
		case 0:
			p = xacc_info;
			cnt = (int) sizeof(xacc_info)-1;
			v_set_line(BLACK,1,1,0,0);
			v_line(x,y+ch-1,x+win->work.g_w,y+ch-1);
			break;
		case 1:
			continue;
		default:
			p = buf;
			cnt = make_info(*list++);
		}

		for (x-=(int) sc->hpos*cw;;)
		{
			p += 120;c = *p;*p = '\0';
			v_gtext(x_handle,x,y,p-120);
			if ((cnt-=120)>0)
			{
				vqt_extent(x_handle,p-120,extent);
				x += extent[4];
				*p = c;
			}
			else
				break;
		}
	}
}

void SetScroll(void)
{
	int out[4];

	v_set_text(fntid,fntsize,FAIL,0,0,out);
	scroll.vsize = app_cnt+OFFSET;
	scroll.px_hline = cw = out[2];
	scroll.px_vline = ch = out[3];

	strcpy(info," Keine");
	if (app_cnt)
		int2str(&info[1],app_cnt,0);
	strcat(info," XAcc-/AV-Applikation(en) gefunden.");

#ifndef SMALLTOOL
	int2str(icon_info,app_cnt,0);
	strcat(icon_info," Appl.");
#endif
}

void CloseWindow(void)
{
	close_all_windows();
	win = NULL;
	if (_app)
		exit_gem(TRUE,0);
}

void OpenWindow(void)
{
	SetScroll();
	if (win==NULL && (win=open_window(x_name,NULL,info,NULL,GADGETS,FALSE,0,0,NULL,&start,&scroll,Draw,NULL,XM_TOP|XM_BOTTOM|XM_SIZE))==NULL)
	{
		CloseWindow();
		return;
	}
	WindowItems(win,SCROLL_KEYS,scroll_keys);
	window_set_mouse(win,TEXT_CRSR,TEXT_CRSR,ARROW,ARROW,NULL,NULL,NULL,NULL);
	start = win->curr;
}

int Init(XEVENT *ev,int avail)
{
	return((MU_MESAG|MU_KEYBD)&avail);
}

int Event(XEVENT *ev)
{
	int wi=ev->ev_mwich,i,k,*msg=ev->ev_mmgpbuf;

	if (wi&MU_MESAG)
	{
		switch (msg[0])
		{
		case AC_OPEN:
			OpenWindow();break;
		case AC_CLOSE:
		case AP_TERM:
		case WM_CLOSED:
			CloseWindow();break;
		case XACC_AV_INIT:
		case XACC_AV_EXIT:
		case XACC_AV_CLOSE:
			for (i=1,app_cnt=0;(app[app_cnt++]=find_app(i))!=NULL;i=0);
			app_cnt--;
			goto set_window;
		case FONT_CHANGED:
			if (msg[4]>0)
				fntid = msg[4];
			if (msg[5]>0)
				fntsize = -msg[5];
			if (msg[6]>WHITE)
				fntcolor = msg[6];
			FontAck(msg[1],TRUE);
			set_window:
			SetScroll();
			if (win)
				window_reinit(win,x_name,NULL,info,FALSE,FALSE);
			break;
		case WIN_SIZED:
			if (win)
				start = win->curr;
			break;
		default:
			wi ^= MU_MESAG;
		}
	}

	if (wi&MU_KEYBD)
	{
		k = ev->ev_mkreturn;
		i = ev->ev_mmokstate;
		if (i&K_CTRL)
		{
			switch (scan_2_ascii(k,i))
			{
			case 'Q':
				CloseWindow();break;
			case 'S':
				SaveInfo();break;
			case 'T':
				if (win && !CallFontSelector(win->handle,fntid,-fntsize,fntcolor,-1))
				{
				#ifndef SMALLTOOL
					alert(X_ICN_ALERT,1,x_name,"Fontselector not available!",NULL);
				#endif
				}
				break;
			default:
				wi ^= MU_KEYBD;
			}
		}
	#ifndef SMALLTOOL
		else if ((k>>8)==SCANHELP)
		{
			if (alert(X_ICN_INFO,2,NULL,info_text,"[Save|[Ok")==0)
				SaveInfo();
		}
	#endif
		else
			wi ^= MU_KEYBD;
	}
	return(wi);
}

void main()
{
	if (init_gem(NULL,entry,x_name,av_name,0,0,0)==TRUE)
	{
		int info[7],*p=info;

	#ifndef SMALLTOOL
		rsrc_calc(iconified=&icon,NO_SCALING,8,16);
	#endif

		start = desk;
		fntid = ibm_font_id;
		fntsize = ibm_font;

		if (LoadInfoFile(info_file,TRUE,info,14,14,info_id,0x0100)>0)
		{
			fntid = *p++;
			fntsize = *p++;
			fntcolor = *p++;
			start = *(GRECT *) p;
		}

		Event_Handler(Init,Event);
		if (_app)
		{
			Event_Timer(500,0,TRUE);
			OpenWindow();
		}
		Event_Multi(NULL);
	}
}
