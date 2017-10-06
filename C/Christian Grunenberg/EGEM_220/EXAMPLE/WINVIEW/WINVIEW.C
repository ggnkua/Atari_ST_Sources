/* WindowViewer/ClipboardViewer (PRG/ACC), (c) 1994/95 C. Grunenberg
	Optionen:
	 WIN_MAX	-> maximale Fensteranzahl (nur beim WindowViewer von Bedeutung)
				-> bei nur einem Fenster wird dieses immer mit der neuen Datei Åberladen
	 CLIPVIEW	-> als ClipboardViewer Åbersetzen
	 CURSOR		-> Cursor im Text-/Dump-Modus,Suchen/Markierungsfunktionen
	 SMALLTOOL	-> keine Informations-/Hilfe-/Fehlermeldungen/Ikonifizierung
  => ohne Kommentare/Mehrfachvarianten betrÑgt die LÑnge dieses Moduls max. 16 KB */

#include "data.h"
#include "..\keys.c"
#include "images.c"
#include <ctype.h>

/* Fensterelemente */
#ifndef SMALLTOOL
#define GADGETS	NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER
#else
#define GADGETS	NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE
#endif

/*	INFO_LEN	 -> LÑnger der Daten im Setup
	entry		 -> Eintrag im DESK-MenÅ
	av_name		 -> AV-Programmname
	win_id		 -> ID vor Fenstertitel
	info_file/id -> Dateiname/ID fÅr Setup
	info_text	 -> Hilfs-Text
	button		 -> Buttons im Hilfedialog
	path/fname	 -> Pfad- u. Dateinamen */

#define INFO_LEN	((int) sizeof(SETUP))

char *info_id="Viewer";

#ifdef CLIPVIEW

#define WIN_MAX		1

#ifndef SMALLTOOL

char entry[]="  ClipboardViewer\0XDSC\0""1Viewer\0XFontAck\0",*av_name="CLIPVIEW",*win_id="ClipView",
*button="[Save setup|[Update|[Ok",*info_text=
"_ ClipboardViewer: |^|"\
"^\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"|^|"\
"^ Update window:  CTRL-V|"\
"^ Save settings:  CTRL-S|"\
"^ Select font:    CTRL-T|"\
"^ Set tabulator:  TAB|"\
"^ Scroll picture: Use (SHIFT/CTRL+) Cursor-Keys";

#else

char entry[]="  MiniClipboard\0XDSC\0""1Viewer\0XFontAck\0",*av_name="MINICLIP",*win_id="MiniClip";

#endif

char *info_file="clipbrd.inf";

#else

#ifndef SMALLTOOL

#define WIN_MAX		16

char *av_name="WINVIEW",entry[]="  WindowViewer\0XDSC\0""1Viewer\0""2View\0NView\0XViewData\0X.ASC\0X.HEX\0X.IMG\0XDump\0XFontAck\0",
*button="[Save setup|[Load file|[Ok",*info_text=
"_ WindowViewer: |^|"\
"^\xBD""1995 C. Grunenberg, Version "E_GEM_VERSION", "__DATE__"|^|"\
"^ Load file:       CTRL-O|"\
"^ Save settings:   CTRL-S|"\
"^ Find/Find next:  (SHIFT-/ALT-) CTRL-F/G|"\
"^ Set/Goto marker: CTRL/ALT-[0-9]|"\
"^ Select font:     CTRL-T|"\
"^ Set tabulator:   TAB|"\
"^ Scroll picture:  Use (SHIFT/CTRL+) Cursor-Keys";

#else

#define WIN_MAX		1

char *av_name="MINIVIEW",entry[]="  MiniViewer\0XDSC\0""1Viewer\0""2View\0NView\0XViewData\0X.ASC\0X.HEX\0X.IMG\0XDump\0XFontAck\0";

#endif

char path[MAX_PATH],fname[MAX_PATH],*info_file="viewer.inf",*win_id="View";

#endif

/* voreingestellte Fonts fÅr jeweilige Fenster */
char *x_name = &entry[2]; 	/* (XAcc2-) Programmname */
DATA win_data[WIN_MAX];		/* Struktur fÅr geladene Daten pro Fenster */
WIN *top_win;				/* Zeiger auf oberstes Fenster */
GRECT max_win;				/* maximale Fensterausmaûe */

#ifdef CURSOR
DATA *set_data; 			/* Fenster, dessen Infozeile gesetzt werden soll */
long timer;
#endif

/***********************************************************************
 Fehlermeldung ausgeben
***********************************************************************/
#ifndef SMALLTOOL
void error(int icon,char *msg)
{
	xalert(1,1,icon,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,x_name,msg,NULL);
}
#endif

/***********************************************************************
 Fenster-Infozeile setzen u. evtl. aktualisieren
 ***********************************************************************/
void SetInfo(boolean set,DATA *data)
{
#ifdef CURSOR
	if (data->find)
		strcat(strcat(strcpy(data->info,"Find: "),data->search),"_");
	else
#endif

	switch (data->flag)
	{
	case IMAGE:	/* GEM-Image */
		sprintf(data->info," %d x %d Pixel",data->width,data->height);break;
	case ASCII: /* Text-Datei*/
	#ifdef CURSOR
		sprintf(data->info," Line: %5ld/%ld, Column: %4d/%d, Tab: %d",data->crs_line,data->lines,data->crs_row,data->max_rows,data->tab_size);
	#else
		sprintf(data->info," %ld Line(s), %d Column(s), Tab: %d",data->lines,data->max_rows,data->tab_size);
	#endif
		break;
	case DUMP: /* BinÑr-Datei */
	#ifdef CURSOR
		{
			long off=data->crs_line*data->rows+data->crs_row;
			byte ch=data->data[off];
			sprintf(data->info," Byte: %6ld/%ld, ASCII: $%02X (%03d) \'%c\'",off,data->size,ch,ch,ch ? ch : ' ');
		}
	#else
		sprintf(data->info," %ld Byte(s)",data->size);
	#endif
		break;
#ifdef CLIPVIEW
	default:
		strcpy(data->info," No file in clipboard.");
#endif
	}
	if (set)	/* Infozeile aktualisieren? */
		window_info(data->win,data->info);
}

/***********************************************************************
 Fenster-Scroll-Struktur initialisieren
 ***********************************************************************/
void SetScroll(DATA *data)
{
	SCROLL *sc=&data->sc;
	long wi,he;

	/* schnelles automatisches Scrolling */
	sc->scroll = FAST_SCROLL;
	/* keine Toolbar-Bereiche,kein Scroll-Objekt */
	sc->obj = sc->tbar_l = sc->tbar_r = sc->tbar_u = sc->tbar_d = 0;

	/* hsize/vsize:		  Zeilen/Spalten
	   px_hline/px_vline: Breite/Hîhe einer Spalte/Zeile
	   hscroll/vscroll:	  Scroll-Schrittweite in Spalten/Zeilen */

	switch (data->flag)
	{
	case IMAGE:	/* Image */
		sc->hsize = data->width;
		sc->vsize = data->height;
		sc->px_hline = sc->px_vline = 1;
		sc->hscroll = sc->vscroll = 8;
		break;
	case ASCII:	/* Text- oder BinÑr-Datei (Dump) */
	case DUMP:
		sc->vsize = data->lines;
		sc->hsize = data->max_rows+1;
		sc->px_hline = data->font_cw;
		sc->px_vline = data->font_ch;
		sc->hscroll = sc->vscroll = 1;
		break;
#ifdef CLIPVIEW
	default: /* Keine Datei geladen */
		sc->hsize = sc->vsize = 0;
#endif
	}
	SetInfo(FALSE,data);	/* Infozeile setzen */

	/* maximale Image-/Textausmaûe berechnen */
	wi = data->sc.hsize*data->sc.px_hline;
	he = data->sc.vsize*data->sc.px_vline;
	window_border(GADGETS,0,0,wi>max_w ? max_w : (int) wi,he>max_h ? max_h : (int) he,&max_win);
}

/***********************************************************************
 Fenster schlieûen, Speicher/Timer freigeben u. Programm beenden
***********************************************************************/
void CloseWindow(DATA *data,int ac)
{
#if WIN_MAX>1
	int wins;
#endif

	if (data->win)						/* Fenster geîffnet? */
	{
		/* Kein AC_CLOSE/AP_TERM? */
		if (!ac)
			close_window(data->win,FALSE);	/* Fenster schlieûen (keine Shrink-Boxen) */
	#if WIN_MAX>1
		if (data->win==top_win)			/* oberstes Fenster? */
	#endif
			top_win = NULL;
		data->win = NULL;
		ClearData(data);				/* Speicher freigeben */
	}

#ifdef CURSOR
#if WIN_MAX>1
	if (data==set_data)
#else
	if (set_data)
#endif
	{
		MouseOn();
		set_data = NULL;				/* Infozeile nicht mehr aktualisieren */
	}
#endif

	/* Keine Fenster mehr geîffnet und als Programm gestartet? */
#if WIN_MAX>1
	get_dialog_info(NULL,NULL,&wins,NULL);
	if (wins==0 && _app)
#else
	if (_app)
#endif
		exit_gem(TRUE,0);				/* Programm beenden */
}

/***********************************************************************
 Alle Fenster schlieûen
 ***********************************************************************/
#if WIN_MAX>1
void CloseAllWindows(int ac)
{
	int i;
	for (i=WIN_MAX;--i>=0;)
		CloseWindow(&win_data[i],ac);
}
#else
#define CloseAllWindows(ac)	CloseWindow(&win_data[0],ac)
#endif

/***********************************************************************
 Fenster-abhÑngige Mausform setzen
 ***********************************************************************/
void SetMouse(DATA *data)
{
	int mouse,dx,dy;
	MFORM *mf;

	/* benutzerdefinierte Mausform */
	mouse = USER_DEF;

	/* Fensterinhalt breiter als eine Fensterseite? */
	dx = (data->sc.hsize>data->sc.hpage);

	/* Fensterinhalt hîher als eine Fensterseite? */
	dy = (data->sc.vsize>data->sc.vpage);

	if (dx && dy)	/* vertikales & horizontales Scrolling mîglich? */
		mf = &mouse_vh;
	else if (dx)	/* horizontales Scrolling mîglich? */
		mf = &mouse_h;
	else if (dy)	/* vertikales Scrolling mîglich? */
		mf = &mouse_v;
	else
	{
		/* ansonsten Maus auf Fadenkreuz (Image) bzw. Text-Cursor (Text,
		   Dump) innerhalb des Arbeitsbereichs setzen */
		mouse = (data->flag==IMAGE) ? THIN_CROSS : TEXT_CRSR;
		mf = NULL;
	}

	/* Mausform setzen (auûerhalb des Arbeitsbereichs als Pfeil) */
	window_set_mouse(data->win,mouse,mouse,ARROW,ARROW,mf,mf,NULL,NULL);
}

/***********************************************************************
 Fenster reinitialisieren ((max.) Fensterausmaûe/-titel/-infozeile) u. neuzeichnen
***********************************************************************/
void SetWindow(DATA *data,int home)
{
	WIN *win=data->win;
#ifdef CURSOR
	data->crs_valid = 0;
	data->crs_on = (data->win==top_win);
#endif
	SetScroll(data);
#ifndef SMALLTOOL
	win->max = data->valid ? max_win : desk;
#endif
	window_reinit(win,GetFilename(data->fname),NULL,data->info,home,FALSE);
}

/***********************************************************************
 Fenster îffnen, evtl. Fileselector aufrufen und Datei laden
***********************************************************************/
DATA *OpenWindow(char *file,char *mem,long length)
{
	DATA *data;
	char filename[MAX_PATH];
	GRECT start;

#ifdef CLIPVIEW
	data = &win_data[0];
	ClearData(data);	/* vorherigen Clipboard-Inhalt lîschen */

	/* Clipboard-Dateien (Image, Text) suchen */
	if (scrp_find("img.txt.asc.rtf.tex.csv.eps.*",filename))
		LoadData(data,filename,NULL,0l);	/* Datei laden, falls vorhanden */

	SetScroll(data);	/* Scroll-Struktur initialisieren */
	if (set.start.g_w>0) /* Fenster an letzter Position îffnen? */
		start = set.start;
	else if	(!data->valid) /* Fensterausmaûe in AbhÑngigkeit vom Ladezustand berechnen */
		window_border(GADGETS,0,0,desk.g_w>>1,desk.g_h>>1,&start);
	else
#else
#if WIN_MAX>1
	int i;

	/* freies Fenster ermitteln */
	for (i=0,data=NULL;i<WIN_MAX && win_data[i].win;i++);

	if (i==WIN_MAX)	/* kein Fenster verfÅgbar? */
	{
	#ifndef SMALLTOOL
		error(X_ICN_ERROR,"No more windows available!");
	#endif
		return(NULL);
	}

	data = &win_data[i];
#else
	/* Fenster wird Åberladen */
	data = &win_data[0];
#endif
	/* Pfad- und Dateiname Åbergeben? */
	if (file && mem==NULL && *GetFilename(file)=='\0')
	{
		strcpy(path,file);	/* nur Pfad Åbergeben */
		file = NULL;
	}

	/* Datei Åbergeben? */
	if (file || mem)
	{
		if (file)
			strcpy(filename,file);
		else
			filename[0] = '\0';

		/* Datei laden */
		if (LoadData(data,filename,mem,length)==LOADED)	/* Wurde Datei geladen? */
		{
			/* Scroll-Struktur initialisieren */
			SetScroll(data);
#endif
			start = max_win;

		#if WIN_MAX==1
			if (data->win==NULL)	/* Fenster noch nicht geîffnet? */
		#endif
			{
				/* Fenster îffnen */
			#ifndef SMALLTOOL
				data->win = open_window(GetFilename(data->fname),NULL,data->info,data->valid ? &icon[(data->flag-1)<<1] : NULL,GADGETS,FALSE,0,0,data->valid ? &max_win : NULL,&start,&data->sc,DrawData,data,XM_TOP|XM_BOTTOM|XM_SIZE);
				if (data->win==NULL)	/* Fenster konnte nicht geîffnet werden */
					error(X_ICN_ALERT,"No more windows available!");
			#else
				data->win = open_window(GetFilename(data->fname),NULL,data->info,NULL,GADGETS,FALSE,0,0,NULL,&start,&data->sc,DrawData,data,XM_TOP|XM_BOTTOM|XM_SIZE);
			#endif
			}
		#if WIN_MAX==1
			else /* Fenster initialisieren */
			{
			#ifndef SMALLTOOL
				data->win->icon = data->valid ? &icon[(data->flag-1)<<1] : NULL;
			#endif
				SetWindow(data,TRUE);
			}
		#endif
#ifdef CLIPVIEW
			/* letzte Ausmaûe des Clipboard-Fensters */
			if (data->win)
				set.start = data->win->curr;
#else
		}
	}
	else /* Fileselector aufrufen, falls keine Datei Åbergeben wurde */
	{
	#if WIN_MAX>1
		char buffer[WIN_MAX][34],*outptr[WIN_MAX];
		int i,j;

		for (j=WIN_MAX;--j>=0;outptr[j]=&buffer[j][0]);
		
		for (j=0,i=FileSelect("Load file...",path,fname,NULL,TRUE,WIN_MAX,outptr);j<i;)
		{
			/* kompletten Pfad erstellen */
			MakeFullpath(filename,path,outptr[j++]);
			/* Datei laden */
			if (*GetFilename(filename)=='\0' || OpenWindow(filename,NULL,0l)==NULL)
				break;
			Event_Timer(0,0,FALSE);
		}
	#else
		if (FileSelect("Load file...",path,fname,NULL,TRUE,1,NULL)>0)
			if (*GetFilename(MakeFullpath(filename,path,fname)))
				OpenWindow(filename,NULL,0l);
	#endif
	}
#endif

	if (data->win)			/* Fenster geîffnet? */
	{
		/* Tasten fÅr Fensterscrolling anmelden */
	#ifdef CURSOR
		WindowItems(data->win,(data->flag==ASCII || data->flag==DUMP) ? 2 : SCROLL_KEYS,scroll_keys);
	#else
		WindowItems(data->win,SCROLL_KEYS,scroll_keys);
	#endif
		SetMouse(data);	/* Mauszeigerform setzen */
	}
	else
		CloseWindow(data,FALSE); /* ansonsten evtl. Programm beenden */
	return(data);
}

/***********************************************************************
 Information/Hilfe anzeigen
***********************************************************************/
void Info(void)
{
#ifndef SMALLTOOL
	switch (xalert(3,3,X_ICN_INFO,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,NULL,info_text,button))
	{
	case 0:
		SaveInfoFile(info_file,TRUE,&set,INFO_LEN,info_id,0x0100);break;
	case 1:
#else
	{
#endif
		OpenWindow(NULL,NULL,0l);
	}
}

#ifdef CURSOR
/***********************************************************************
 Cursor an-/ausschalten und neuzeichnen
***********************************************************************/
void Cursor(DATA *data,int on)
{
	if (data->valid && data->flag!=IMAGE && on!=data->crs_on && window_output())
	{
		data->crs_on = on;
		if (!data->win->iconified)
		{
			if (!data->crs_valid)
			{
				int d;
				MakeString(data,&data->text[data->crs_line],&d,NULL);
			}
			DrawCursor(data);
		}
	}
}

/***********************************************************************
 blinkender Cursor im obersten Fenster
***********************************************************************/
long CursorTimer(long p,long t,MKSTATE *m)
{
	if (top_win)
	{
		DATA *data=(DATA *)top_win->para;
		Cursor(data,1-data->crs_on);
		return(CONT_TIMER);	/* Periodisch fortsetzen */
	}
	else
	{
		timer = 0;
		return(STOP_TIMER);	/* Abbrechen */
	}
}

/***********************************************************************
 Cursor-Position setzen u. gegebenenfalls Fenster scrollen
***********************************************************************/
void SetCursor(DATA *data,long line,int row,int marker)
{
	byte *p;
	TEXT *txt;
	SCROLL *sc=&data->sc;
	long ypos;
	int x,xpos;

	/* Cursor auf gÅltige Werte setzen */
	if (line<0)
		line = 0;
	else if (line>=sc->vsize)
		line = sc->vsize - 1;

	txt = &data->text[line];
	p = MakeString(data,txt,&xpos,NULL);

	if (!marker && line!=data->crs_line && row==data->crs_row)
		row = min(data->crs_lastrow,xpos);
	else
	{
		row = min(row,xpos);
		if (row!=data->crs_row || marker)
			data->crs_lastrow = row;
	}

	if (data->flag==DUMP)
		row = min(row,xpos-1);
	row = max(row,0);
	
	/* Fenster scrollen, falls Cursor auûerhalb Fenster */
	if (line<(ypos=sc->vpos))
		ypos = line;
	else if (line>=(ypos+sc->vpage))
		ypos = line-sc->vpage+1;
	
	xpos = (int) sc->hpos;
	x = StringWidth(data,p,row) - (int) sc->px_hpos;
	if (x<0)
		xpos -= max(sc->hpage>>1,(-x)/sc->px_hline+1);
	else if (x>=data->win->work.g_w)
		xpos += max(sc->hpage>>1,(x-data->win->work.g_w)/sc->px_hline+1);

	/* Fenster- oder Cursorposition geÑndert? */
	if (line!=data->crs_line || row!=data->crs_row || xpos!=sc->hpos || ypos!=sc->vpos)
	{
		if (!marker && (xpos!=sc->hpos|| ypos!=sc->vpos))
			ClrKeybd();	/* Tastaturpuffer lîschen */

		beg_update(FALSE,TRUE);
		if (data->crs_on)
			DrawCursor(data); /* Cursor lîschen */
		data->crs_valid = data->crs_on = 0;
		data->crs_line = line;
		data->crs_row = row;

		sc->hpos = xpos;
		sc->vpos = ypos;
		scroll_window(data->win,WIN_SCROLL,NULL);

		MakeString(data,txt,&xpos,NULL);
		data->crs_on = 1;
		DrawCursor(data);	/* Cursor setzen */
		end_update(TRUE);

		if (marker)
			SetInfo(TRUE,data);
		else
		{
		#if WIN_MAX>1
			if (set_data!=data)
			{
				if (set_data)
					SetInfo(TRUE,set_data);	/* evtl. Infozeile eines anderen Fensters setzen */
				else
					MouseOff();
			}
		#else
			if (set_data==NULL)
				MouseOff();
		#endif
			set_data = data; /* in Pause aktualisieren */
		}
	}
}

/***********************************************************************
 Zeichenkette suchen u. im Erfolgsfall Cursor setzen/Fenster scrollen
***********************************************************************/

char word_char[256],upper_char[256];

char *search_std(char *search,char *string,int len,int s_len)
{
	char *last=&string[len],c1=*search++,c2=*search,s=*last;
	for (*last=c1;;)
	{
		while (*string++!=c1);
		if (string>last)
		{
			*last = s;
			return(NULL);
		}
		else if (*string==c2 && !strncmp(string,search,s_len-1))
		{
			*last = s;
			return(string-1);
		}
	}
}

char *search_words(char *search,char *string,int len,int s_len)
{
	char *start=string,*last=&string[len],c1=*search++,c2=*search,s=*last;

	for (*last=c1;;)
	{
		while (*string++!=c1);
		if (string>last)
		{
			*last = s;
			return(NULL);
		}
		else if (*string==c2)
		{
			string--;
			if (!word_char[(byte) string[s_len]] && (string==start || !word_char[(byte) string[-1]]) && !strncmp(string,search-1,s_len))
			{
				*last = s;
				return(string);
			}
			else
				string++;
		}
	}
}

char *search_insens(char *search,char *string,int len,int s_len)
{
	char *last=&string[len],*upper=upper_char,c1=upper[(byte) *search++],c2=upper[(byte) *search],s=*last;
	for (*last=c1;;)
	{
		while (upper[(byte) *string++]!=c1);
		if (string>last)
		{
			*last = s;
			return(NULL);
		}
		else if (upper[(byte) *string]==c2 && !strnicmp(string,search,s_len-1))
		{
			*last = s;
			return(string-1);
		}
	}
}

char *search_insens_words(char *search,char *string,int len,int s_len)
{
	char *start=string,*last=&string[len],*upper=upper_char,c1=upper[(byte) *search++],c2=upper[(byte) *search],s=*last;

	for (*last=c1;;)
	{
		while (upper[(byte) *string++]!=c1);
		if (string>last)
		{
			*last = s;
			return(NULL);
		}
		else if (upper[(byte) *string]==c2)
		{
			string--;
			if ((!word_char[(byte) string[s_len]] && (string==start || !word_char[(byte) string[-1]])) && !strnicmp(string,search-1,s_len))
			{
				*last = s;
				return(string);
			}
			else
				string++;
		}
	}
}

void SearchString(DATA *data)
{
	int search_len,len;
	char *(*search_string)(char*,char*,int,int);
	char *pos,*src,*search=data->search;
	long start=data->crs_line;
	TEXT *txt=&data->text[start];

	if ((search_len=(int) strlen(search))==0)
		return;

	if (data->insens)
		search_string = data->words ? search_insens_words : search_insens;
	else
		search_string = data->words ? search_words : search_std;

	if (data->back)
		for (;--start>=0;)
		{
			txt--;
			if (search_string(search,(char *) txt->text,txt->len,search_len) && (pos=search_string(search,src=(char *) MakeString(data,txt,&len,NULL),len,search_len))!=NULL)
			{
				SetCursor(data,start,(int) (pos-src),TRUE);
				return;
			}
		}
	else
		for (;++start<data->lines;)
		{
			txt++;
			if (search_string(search,(char *) txt->text,txt->len,search_len) && (pos=search_string(search,src=(char *) MakeString(data,txt,&len,NULL),len,search_len))!=NULL)
			{
				SetCursor(data,start,(int) (pos-src),TRUE);
				return;
			}
		}
	data->back ^= 1;
}
#endif

/***********************************************************************
 Initialisierungs-Routine, welche die Event-Struktur setzt sowie die
 Ereignisse, die von der Applikation benîtigt werden, zurÅckgibt
***********************************************************************/
int InitEvent(XEVENT *ev,int avail)
{
	int flags=MU_MESAG|MU_KEYBD;	/* auf Nachrichten und TastendrÅcke warten */

#ifdef CURSOR
	/* Infozeile aktualisieren (4. Timer ist immer verfÅgbar) */
	if (set_data)
	{
		ev->ev_mt4count = set_data->flag==DUMP ? 100 : 250;	/* Verzîgerung */
		ev->ev_mt4last = 0;		/* ab jetzt */
		flags |= MU_TIMER4;
	}
#endif

	/* erstes Button-Ereignis verfÅgbar? */
	if (avail & MU_BUTTON1)
	{
		/* Einfach-/Doppelklick links */
		ev->ev_mb1clicks = 2;
		ev->ev_mb1state = ev->ev_mb1mask = 1;
		flags |= MU_BUTTON1;
	}

	/* gewÅnschte Ereignisse zurÅckgeben */
	return(flags&avail);
}

/***********************************************************************
 Ereignisauswertung (AES-Nachrichten, Mausklicks/-bewegung, TastendrÅcke)
***********************************************************************/
int Event(XEVENT *ev)
{
	WIN *win;
	DATA *data;
	int wich=ev->ev_mwich,*msg,i,k,scan,state,old_x,old_y;

#ifdef CLIPVIEW
	char scrap[MAX_PATH],*path;
#else
	DRAG_DROP *dd;
	char *ptr;
	int mbuf[8];
#endif

#ifdef CURSOR
	byte *p;
	TEXT *txt;
	SCROLL *sc;
	long va;

	if (wich & MU_TIMER4)		/* Timer-Event? */
	{
		SetInfo(TRUE,set_data);	/* Infozeile aktualisieren */
		MouseOn();
		set_data = NULL;
	}
#endif

	if (wich & MU_BUTTON1)		/* Mausklick? */
	{
		if (ev->ev_mbreturn==2)	/* Doppelklick? */
			Info();	/* Info anzeigen */
		/* Einfackklick in Arbeitsbereichs eines nicht ikonifizierten Fensters? */
		else if ((win=window_find(old_x=ev->ev_mmox,old_y=ev->ev_mmoy))!=NULL && rc_inside(old_x,old_y,&win->work) && !win->iconified)
		{
			int dx,dy,x,y,xoff,yoff;

			data = (DATA *) win->para;	/* Datenstruktur zum Fenster ermitteln */

			beg_ctrl(FALSE,FALSE,FALSE);
			MouseOff();

		#ifdef CURSOR
			if (mouse(&x,&y) & 1)	/* Maustaste gedrÅckt? */
		#endif
			{
				do
				{
					/* Maustaste und -position ermitteln */
					k = mouse(&x,&y);
					/* Wurde Maus bewegt? */
					if ((dx=x-old_x)!=0 || (dy=y-old_y)!=0)
					{
						/* Fensterposition verschieben */
						if (data->flag==IMAGE)
						{
							xoff = dx*data->sc.hscroll;
							yoff = dy*data->sc.vscroll;
						}
						else
						{
							xoff = 1<<min(abs(dx)-1,6);
							if (dx<0)
								xoff = -xoff;
							else if (dx==0)
								xoff = 0;
							yoff = 1<<min(abs(dy)-1,6);
							if (dy<0)
								yoff = -yoff;
							else if (dy==0)
								yoff = 0;
						}

						/* Fenster scrollen */
						data->sc.hpos += xoff;
						data->sc.vpos += yoff;
						scroll_window(win,WIN_SCROLL,NULL);

						/* Mausposition merken */
						old_x = x;
						old_y = y;
					}
				} while (k & 1); /* solange Maustaste gedrÅckt */
			}
		#ifdef CURSOR
			else if (data->flag==ASCII || data->flag==DUMP)
			{
				long line;

				sc = &data->sc;
				line = sc->vpos + (y-win->work.g_y)/data->font_ch;
				if (line>=sc->vsize)
					line = sc->vsize-1;

				x += (int) sc->px_hpos - win->work.g_x;
				txt = &data->text[line];
				p = MakeString(data,txt,&yoff,NULL);
				for (dx=xoff=0;dx<x && --yoff>=0;xoff++)
					dx += CharWidth(data,*p++);
				if (xoff>0 && yoff>=0)
					xoff--;

				SetCursor(data,line,xoff,TRUE);
			}
		#endif
			MouseOn();
			end_ctrl(FALSE,FALSE);
		}
	}

	if (wich & MU_MESAG) /* Nachricht vom AES oder der Library? */
	{
		msg = ev->ev_mmgpbuf; /* Adresse des Nachrichten-Puffers */
		if ((win=get_window(msg[3]))!=NULL) /* Fenster/Datenstruktur ermitteln */
			data = (DATA *) win->para;

		switch (msg[0])
		{
		/* (Fileselector aufrufen u.) Datei/Klemmbrett laden */
		case AC_OPEN:
			OpenWindow(NULL,NULL,0l);break;
		/* Programm beenden */
		case AC_CLOSE:
		case AP_TERM:
			CloseAllWindows(TRUE);break;
		/* Fenster schlieûen */
		case WM_CLOSED:
			CloseWindow(data,FALSE);break;
		case WIN_NEWTOP:
		#ifdef CURSOR
			if (top_win!=win)
			{
				if (top_win)
					Cursor((DATA *) top_win->para,0); /* letzten Cursor lîschen */
				if (win) /* neues oberstes Fenster gehîrt Applikation? */
				{
					Cursor((DATA *) data,1);/* neuen Cursor setzen */
					if (timer==0) /* noch kein Timer fÅr Cursor? */
						timer = NewTimer(500,0,CursorTimer);
				}
			}
		#endif
			top_win = win;
			break;
		/* Mausform an neue Fenstergrîûe anpassen */
		case WIN_SIZED:
			SetMouse(data);
		#ifdef CLIPVIEW
			set.start = win->curr;
		#endif
			break;
		/* Zeichensatz, Grîûe u. Farbe setzen */
		case FONT_CHANGED:
			state = 0;i = 1;
			do
			{
				if (msg[3]<0)	/* alle Fenster? */
					win = get_window_list(i);
				if (win==NULL)
					break;
				else
					data = (DATA *) win->para;
				k = msg[4]<0 ? data->font.id : msg[4]; /* neuer Font? */
				if (data->flag==ASCII || (data->flag==DUMP && (FontInfo(k)->type & (FNT_PROP|FNT_ASCII))==0)) /* Text- oder Dump-Fenster? */
				{
					data->font.id = k;
					if (msg[5]>0) /* neue Font-Grîûe setzen? */
						data->font.size = -msg[5];
					if (msg[6]>WHITE) /* neue Text-Farbe? */
						data->font.color = msg[6];
					SetFont(data,TRUE);
					SetWindow(data,FALSE);
					state++;
				}
				i = 0;
			} while (msg[3]<0);
			FontAck(msg[1],state);
			break;
		#ifdef CLIPVIEW
		/* Inhalt eines Pfades/Laufwerks wurde verÑndert */
		case SH_WDRAW:
		case AV_PATH_UPDATE:
			/* Klemmbrett vorhanden? */
			if (scrp_path(scrap,NULL))
			{
				if (msg[0]==SH_WDRAW)
				{
					/* Pfad, dessen Inhalt sich geÑndert hat */
					path = *(char **) &msg[3];
					/* Åbergeordneter Pfad des Klemmbretts? */
					if (strnicmp(scrap,path,strlen(path)))
						break;
				}
				/* Alle Laufwerke oder das Klemmbrett-Laufwerk betroffen? */
				else if (msg[3]>=0 && GetDrive(scrap)!=msg[3])
					break;
			}
			else
				break;
		/* Inhalt des Klemmbretts hat sich geÑndert */
		case SC_CHANGED:
			/* Klemmbrett aktualisieren */
			OpenWindow(NULL,NULL,0l);break;
		#else
		/* Datei soll angezeigt werden (View-Protokoll) */
		case VIEW_FILE:
		case VIEW_DATA:
			ptr = *(char **) &msg[3];
			if (msg[0]==VIEW_FILE)	/* Datei laden und anzeigen */
				data = OpenWindow(ptr,NULL,0l);
			else					/* Datei anzeigen */
			{
				i = *(int *) &ptr[4];
				data = OpenWindow(&ptr[6],&ptr[i],(*(long *) &msg[5]) - i);
			}
			/* Nachricht entsprechend beantworten */
			*(char **) &mbuf[3] = ptr;	/* zur Identifikation */
			mbuf[5] = (data && data->valid) ? VIEWERR_ERROR : 0;
			mbuf[6] = 0;	/* reserviert */
			mbuf[7] = 0;	/* keine weitere Kommunikation */
			AvSendMsg(msg[1],mbuf[5] ? VIEW_OPEN : VIEW_FAILED,msg);
			break;
		/* Datei/Pfad wurde per Drag&Drop Åbergeben */
		case OBJC_DRAGGED:
			/* Datei laden u. anzeigen oder Fileselector aufrufen */
			dd = *(DRAG_DROP **) &msg[4];
			if (dd->dd_mem)
				OpenWindow(dd->dd_name,dd->dd_mem,dd->dd_size);
			else if (dd->dd_args)
			#if WIN_MAX>1
				for (ptr=ParseArgs(dd->dd_args);ptr && OpenWindow(ptr,NULL,0l);ptr=ParseArgs(NULL))
					Event_Timer(0,0,FALSE);
			#else
				OpenWindow(ParseArgs(dd->dd_args),NULL,0l);
			#endif
			else
				OpenWindow(NULL,NULL,0l);
			break;
		#endif
		/* unbekannte Nachricht */
		default:
			wich ^= MU_MESAG;
		}
	}

	/* Tastatur-Ereignis? */
	if ((wich & MU_KEYBD) && (win=top_win)!=NULL)
	{
		data = (DATA *) win->para;	/* Datenstruktur zum Fenster ermitteln */
		state = ev->ev_mmokstate;	/* Status der Umschalttasten */
		scan = ev->ev_mkreturn>>8;	/* Scancode der gedrÅckten Taste */
		i = data->valid && !win->iconified && data->flag!=IMAGE; /* Datei geladen u. Fenster nicht ikonifiziert */
		k = scan_2_ascii(ev->ev_mkreturn,state); /* ASCII-Zeichen der gedrÅckten Taste */

	#ifdef CURSOR
		if ((state & (K_ALT|K_CTRL)) && k>='0' && k<='9')
		{
			if (i)
			{
				k -= '0';
				if (state & K_CTRL)	/* Marker setzen */
				{
					data->mrk_line[k] = data->crs_line;
					data->mrk_row[k] = data->crs_row;
				}
				else if ((va=data->mrk_line[k])>=0) /* Marker anspringen */
					SetCursor(data,va,data->mrk_row[k],TRUE);
			}
		}
		else
	#endif
		if (state & K_CTRL)	/* Control-Taste gedrÅckt? */
		{
			switch (k)
			{
			case 'Q':	/* Programm beenden */
				CloseAllWindows(FALSE);break;
		#ifdef CLIPVIEW
			case 'V':	/* Klemmbrett aktualisieren */
		#else
			case 'O':	/* Fileselector aufrufen u. Datei laden */
		#endif
				OpenWindow(NULL,NULL,0l);break;
			case 'S':	/* Einstellungen speichern */
				SaveInfoFile(info_file,TRUE,&set,INFO_LEN,info_id,0x0100);break;
			case 'T':	/* externen D&D-Fontselector aufrufen */
				if (i)
				#ifndef SMALLTOOL
					if (!CallFontSelector(win->handle,data->font.id,-data->font.size,data->font.color,-1))
						error(X_ICN_ALERT,"Fontselector not available!");
				#else
					CallFontSelector(win->handle,data->font.id,-data->font.size,data->font.color,-1);
				#endif
				break;
		#ifdef CURSOR
			case 'F':	/* Text suchen */
				if (i)
				{
					data->insens = state & K_SHIFT;
					data->words = state & K_ALT;
					data->find = TRUE;
					SetInfo(TRUE,data);
				}
				break;
			case 'G':	/* Text weitersuchen */
				if (i)
				{
					SearchString(data);
					ClrKeybd();
				}
				break;
		#endif
			default:
				wich ^= MU_KEYBD; 
			}
		}
		else if (scan==SCANHELP) /* Help-Taste? -> Information anzeigen */
			Info();
		else if (i)
		{
			if (scan==SCANTAB)
			{
				if (data->flag==ASCII && data->tabs) /* Textdatei mit Tabulatoren? */
				{
					/* neue Tabulator-Grîûe setzen */
					if (data->tab_size==0)
						data->tab_size++;
					else
						data->tab_size = (data->tab_size*2)&15;
					set.tab = data->tab_size;
					CalcText(data);
					data->sc.hpos = 0;
					SetWindow(data,FALSE);
				}
			}
			else
		#ifdef CURSOR
			{
				long line=data->crs_line;
				int row=data->crs_row;

				sc = &data->sc;
				if (state&K_SHIFT) /* Shift gedrÅckt? */
					switch (scan)
					{
					case SCANUP:
						line -= sc->vpage;break;
					case SCANDOWN:
						line += sc->vpage;break;
					case SCANRIGHT:
						row = (int) sc->hsize;break;
					case SCANHOME:
						line = sc->vsize;
					case SCANLEFT:
						data->crs_lastrow = row = 0;break;
					default:
						wich ^= MU_KEYBD;
					}
				else
					switch (scan)
					{
					case SCANUP:
						line--;break;
					case SCANDOWN:
						line++;break;
					case SCANLEFT:
						if (row)
							row--;
						else if (line)
						{
							line--;
							row = (int) sc->hsize;
						}
						break;
					case SCANRIGHT:
						if (row<data->crs_len)
							row++;
						else if (line<(sc->vsize-1))
						{
							line++;
							row = 0;
						}
						break;
					case SCANHOME:
						line = data->crs_lastrow = row = 0;break;
					default:
						wich ^= MU_KEYBD;
					}

				if (wich & MU_KEYBD)	/* Cursor neu setzen? */
					SetCursor(data,line,row,FALSE);
				else if (data->find && (state&K_ALT)==0)
				{
					i = (int) strlen(data->search);
					k = (char) ev->ev_mkreturn;
					switch (scan)
					{
					case SCANRET:
					case SCANENTER:
						data->back = 0;SearchString(data);
					case SCANUNDO:
						data->find = FALSE;break;
					case SCANBS:
					case SCANDEL:
						if (i>0)
							data->search[i-1] = '\0';
						break;
					case SCANESC:
						i = k = 0;
					default:
						data->search[i] = k;
						data->search[i+1] = '\0';
					}
					SetInfo(TRUE,data);
					wich |= MU_KEYBD;
				}
			}
		#else
				wich ^= MU_KEYBD;
		#endif
		}
		else
			wich ^= MU_KEYBD;
	}
	else
		wich &= ~MU_KEYBD;
	return(wich); /* ausgewertete Ereignisse zurÅckgeben */
}

#ifndef CLIPVIEW

/* Bevorzugte Drag&Drop-Formate */
char our_exts[DD_EXTSIZE] = ".IMG.TXT.ASC.RTF.TEX.CSV.EPSARGS";

void main(int argc,char **argv)

#else

void main()

#endif

{
	/* Bibliothek sowie AES, VDI und Protokolle initialisieren
	   (keine anwendungspezifische AV/XAcc-Nachrichtenauswertung) */
	if (init_gem(win_id,entry,x_name,av_name,0,0,0)==TRUE)
	{
	#if defined(CURSOR) || !defined(SMALLTOOL)
		int i;
	#endif

	#ifndef CLIPVIEW
		/* Falls Viewer bereits geladen, dann Kommandozeile an diesen Åbermitteln */
		if ((i=AppLoaded(av_name))>=0)
		{
			char file[MAX_PATH];
			if (argc>1)
			{
			#if WIN_MAX>1
				while (--argc>=1)
					/* Quoting fÅr Dateinamen mit Leerzeichen */
					if (VaStart(i,strcat(strcat(strcpy(file,"\'"),argv[argc]),"\'"))==FALSE)
						break;
				
			#else
					VaStart(i,strcat(strcat(strcpy(file,"\'"),argv[1]),"\'"));
			#endif
			}
			else
				VaStart(i,NULL);
			exit_gem(TRUE,0);
		}
	#endif

	#ifndef SMALLTOOL
		for (i=0;i<=4;i+=2)
			rsrc_calc(&icon[i],NO_SCALING,8,16);
	#endif

	#ifdef CURSOR
		/* Tabellen initialisieren */
		for (i=256;--i>=0;)
		{
			word_char[i] = (i>0 && (isalnum(i) || strchr("_ÑîÅéôöû",i)));
			upper_char[i] = UpperChar(i);
		}
	#endif

		/* Einstellungen laden/setzen */
		set.text.id = ibm_font_id;
		set.text.size = ibm_font;
		set.dump = set.text;

		LoadInfoFile(info_file,TRUE,&set,INFO_LEN,14,info_id,0x0100);

	#ifndef CLIPVIEW
		getcwd(path,(int) sizeof(path));/* aktuellen Pfad fÅr Fileselectoraufruf */
		SetDragDrop(TRUE,our_exts);		/* beliebige Daten per Drag&Drop */
	#endif

		Event_Handler(InitEvent,Event);	/* Ereignis-Routinen anmelden */

		if (_app)	/* als Programm gestartet? */
		#ifndef CLIPVIEW
			/* Åbergebene Dateien laden? */
			if (argc>1)
			#if WIN_MAX>1
				while (--argc>=1 && OpenWindow(argv[argc],NULL,0l))
					Event_Timer(0,0,FALSE);
			#else
				OpenWindow(argv[1],NULL,0l);
			#endif
			else
		#endif
				OpenWindow(NULL,NULL,0l);	/* Fileselector bzw. Clipboard laden */
		Event_Multi(NULL);
	}
}
