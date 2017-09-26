#include <ec_gem.h>

#include "ioglobal.h"
#include "io.h"

/* Format der geladenen Ascii-Datei: */
/* 0 bedeutet Original-Zeilenende */
/* 1 bedeutet dieses Zeichen ignorieren. Kommt nur direkt vor 0, war dann CR/LF in Ursprungsmail */
/*   Sollte aber nirgends mehr benutzt werden, deshalb wird dadurch auch
     das Ende des Header-Bereichs angezeigt */
/* 2 bedeutet eigener Formatierungs-Umbruch, war Space */
/* 3 bedeutet eigener Formatierungs-Umbruch, war "-" */
/* 4 bedeutet eigener Formatierungs-Umbruch, war Tab */
/* 5 am Anfang einer Zeile bedeutet erstes Wort fett schreiben */

#define BREAK_LINE_LEN 40


#define SMILE1 0
#define SMILE2 1
#define SMILE3 2
#define SMILE4 3
#define SMILELAST SMILE4

char *SMILE_STR[]={":-)",";-)",":-(",":-/"};

void format_loaded(int n)
{
	/* Formatierung des geladenen Texts auf n Pixel Breite */
	char	*c, *last_sp, *line_start, *sel_start, *sel_end, *mem;
	long	len, cnt, line_length;
	int		apix, head_ends=0, tear_line=0, quote_mode;

	if(loaded==NULL) return;
	
	n-=MESSAGE_OFFSET;
	
	/* Aktuelle Selektion in Pointer umrechnen */
	if(sel_sl > -1)
	{/* Startzeile bestimmen */
		sel_start=loaded; cnt=0;
		while(cnt < sel_sl)
		{	sel_start+=lstrlen(sel_start)+1;	++cnt;}
		sel_end=sel_start;
		sel_start+=sel_sc; if(sel_sc) --sel_start;
		while(cnt < sel_el)
		{	sel_end+=lstrlen(sel_end)+1;	++cnt;}
		sel_end+=sel_ec;
	}

	len=llen;
	c=loaded;
	quote_mode=0;
	while(len--) /* Alte Formatierung entfernen */
	{
		if(*c==RP_SPC) {*c=' '; quote_mode=1;}
		else if(*c==RP_MIN) {*c='-'; quote_mode=1;}
		else if(*c==RP_TAB) {*c=9; quote_mode=1;}
		++c;
	}

	len=0; llines=1; last_sp=c=line_start=loaded;
	apix=0;
	quote_mode=0;
	line_length=0;
		
	while(len < llen)	
	{
		/* Erlaubte UmbrÅche: Space, TAB und "-" */
		if((*c==' ')||(*c==9)) last_sp=c;
		/* Bei "-" aber Smileys schÅtzen */
		if(*c=='-')
		{
			if( (strchr(":;",*(c-1))==NULL) && (strchr("/()",*(c+1))==NULL) )
				last_sp=c;
		}
		
		if(*c==0)
		{/* Neue Zeile aus Original-Umbruch */
			if( (!head_ends) || (tear_line) ||
					(!(ios.ignore_crlf)) || 
					(apix > n) ||
					(line_length < BREAK_LINE_LEN) ||
					(*(c-1)==0) || (*(c-1)==1) || (*(c+1)==0) || (*(c+1)==' ') ||
					(*(c+1)=='-') || (*(c+1)==9) ||
					((*(c+1)>FIRST_FAT)&&((*(c+1)=='>')||(*(c+2)=='>')||(*(c+3)=='>'))) ||
					((quote_mode==1)&&(*(c+1)!='>')&&(*(c+2)!='>')&&(*(c+3)!='>')))
			{
				if(ios.ignore_crlf)
				{
					if( (*(c+1)=='-')&&(*(c+2)=='-')&&(*(c+3)=='-'))
					{
						if(tear_line) tear_line=0;
						else tear_line=1;
						goto _line_break_;
					}
					if(tear_line) goto _line_break_;
					if((*(c+1)>FIRST_FAT)&&((*(c+1)=='>') || (*(c+2)=='>') || (*(c+3)=='>'))) 
					{
						if(quote_mode==0)	quote_mode=1;
						else /* Quote Åbergehen ? */
						{	
							mem=c; while(*mem != '>')++mem;
							++mem;
							if((*mem=='-')||(*mem==' ')||(*mem==9)) /* Quote umbrechen */
								goto _line_break_;
							if(line_length < BREAK_LINE_LEN) goto _line_break_;
							while(*c != '>') {*c++=' ';++len; apix+=ios.mcwidth[' '];}
							last_sp=c;
							*c++=' '; ++len; apix+=ios.mcwidth[' '];
							goto _umbruch_;
						}
					}
					else quote_mode=0;
				}
				_line_break_:
				++c; ++len;
				apix=0; line_length=0; last_sp=line_start=c;
				++llines;
				continue;
			}
			*c=' '; line_length=0;
		}
		if(*c==1)
		{
			head_ends=1; ++c; ++len; continue;
		}
		apix+=ios.mcwidth[(uchar)(*c++)]; ++len; ++line_length;
_umbruch_:
		if(apix > n)	/* Umbrechen */
		{
			if(last_sp==line_start)	/* Keine Umbruchmîglichkeit->Weiter */
				continue;
			if(*last_sp==' ') *last_sp=RP_SPC;
			else if(*last_sp=='-') *last_sp=RP_MIN;
			else *last_sp=RP_TAB;
			len-=(c-last_sp)-1;	/* Counter rÅcksetzen */
			last_sp=line_start=c=last_sp+1;
			apix=0;
			++llines;
		}
	}
	
	/* Selektion neu berechnen */
	if(sel_sl > -1)
	{
		c=loaded; sel_sl=0;
		while(c+lstrlen(c) < sel_start)
		{	c+=lstrlen(c)+1; ++sel_sl;}
		sel_sc=sel_start-c; if(sel_sc) ++sel_sc;
		sel_el=sel_sl;
		while(c+lstrlen(c) < sel_end)
		{	c+=lstrlen(c)+1;	++sel_el;}
		sel_ec=sel_end-c;
	}
	
}

/* -------------------------------------- */

long	lstrlen(char *t)
{/* LÑnge ab aktuellem Pointer, beachtet auch den kÅnstlichen Umbruch */
	/* Achtung, ein Umbruch-Zeichen, das von lstrcpy mitkopiert wird,
	   wird hier nicht beachtet! */
	long	l=0;
	uchar	*c=(uchar*)t;
	
	while((*c > RP_TAB) || (*c==RP_CRLF))
	{
		++l;++c;
	}
	return(l);
}

/* -------------------------------------- */

int	lstrcpy(char *d, char *s)
{/* Kopiert intern formatierten String von src als normalen C-String
		nach dst. Gibt 1 zurÅck, wenn String mit echtem Zeilenumbruch
		endet, sonst 0 */
	uchar	*dst=(uchar*)d, *src=(uchar*)s;
	
	while(*src > RP_TAB) 
	{
		if(*src!=FIRST_FAT)	/* Fett-Anweisung nicht mitkopieren */
			*dst++=*src++;
		else
			++src;
	}
	*dst=0;
	if(*src < RP_SPC) return(1);
	else if(*src==RP_SPC) *dst++=' ';
	else if(*src==RP_MIN) *dst++='-';
	else *dst++=9;
	*dst=0;
	return(0);
}

char	*lstrchr(char *s, char c)
{/* Sucht in s nach Zeichen c und bricht bei allen kÅnstlichen
    UmbrÅchen ab. Return: Pointer auf Zeichen oder NULL */
	
	while(*s > RP_TAB)
	{
		if(*s==c) return(s);
		++s;
	}
	return(NULL);
}

/* -------------------------------------- */

void url_schr_v_gtext(int vhandle, int px, int py, char *c, char *url, void (*extend)(char *c, int *xy))
{
	char *x=c, *y, *z, mem;
	int	 extnd[8];
	
	do
	{
		x=strstr(x, url);	
		if(x==NULL) break;
		*x=0;
		extend(c, extnd);
		*x=url[0];
		/* URL endet mit Leerzeichen, Komma oder Klammer, whatever comes first */
		y=strchr(x, ' ');
		z=strchr(x, ','); 
		if(y!=NULL)
		{
			if((z!=NULL) && (z < y)) {y=z; mem=',';}
			else mem=' ';
		}
		else
		{	y=z; mem=',';}
		z=strchr(x, ')'); 
		if(y!=NULL)
		{
			if((z!=NULL) && (z < y)) {y=z; mem=')';}
		}
		else
		{y=z; mem=')';}
		if(y) *y=0;
		v_gtext(vhandle, px+extnd[2], py-1, x);
		if(y) *y=mem;
		x=y;
	}while(x);
}

void draw_smiley(int x, int y, int *clipxy, char smile, int d_width)
{
	int	base_ob;
	
	base_ob=ISMILE16;
	if(ios.mfhi < 14) base_ob=ISMILE12;
	if(ios.mfhi < 10) base_ob=ISMILE8;
	base_ob+=smile;
	ovorl[base_ob].ob_x=x+d_width/2-ovorl[base_ob].ob_width/2;
	ovorl[base_ob].ob_y=y-ovorl[base_ob].ob_height;
	objc_draw(ovorl, base_ob, 8, clipxy[0], clipxy[1], clipxy[2]-clipxy[0]+1, clipxy[3]-clipxy[1]+1);
}

void url_v_gtext(int vhandle, int *clipxy, int px, int py, char *c, int fcolor, void (*extend)(char *c, int *xy))
{
	char *d, *s, *s1,*s2,*s3,*s4, mem, smile;
	int extnd[8], mpx, mx;
	
	if((c[0]==FIRST_FAT) && ((d=strchr(c, ' '))!=NULL)) 
	{ /* Header-Feldname Fett drucken */
		*d=0;
		vst_effects(handle, 1);
		v_gtext(vhandle, px, py-1, c+1);
		vqt_extent(handle, c, extnd);
		vst_effects(handle, 0);
		*d=' ';
		/* Parameter so hinbiegen, daû der Rest von der Folgefunktion dargestellt wird */
		c=d; px+=extnd[2];
	}
	/* Normalen Text und Smileys ausgeben */
	d=c; mpx=px;
	do
	{
		mem=0; s=NULL;
		if(ios.real_smile)
		{
			s1=strstr(d,SMILE_STR[0]);s2=strstr(d,SMILE_STR[1]);s3=strstr(d,SMILE_STR[2]);s4=strstr(d,SMILE_STR[3]);
			s=(char*)((long)s1+(long)s2+(long)s3+(long)s4);	/* Ist damit entweder NULL oder grîûer als jeder einzelne Pointer */
			if(s1 && (s1 <= s)) {s=s1; smile=SMILE1;}
			if(s2 && (s2 <= s)) {s=s2; smile=SMILE2;}
			if(s3 && (s3 <= s)) {s=s3; smile=SMILE3;}
			if(s4 && (s4 <= s)) {s=s4; smile=SMILE4;}
			if(s) {mem=*s; *s=0; extend(SMILE_STR[smile],extnd); mx=extnd[2];}
		}
		if(*d)
		{
			v_gtext(vhandle, mpx, py-1, d);
			extend(d, extnd); mpx+=extnd[2];
		}
		if(s)
		{
			draw_smiley(mpx, py, clipxy, smile, mx);
			mpx+=mx;
			*s=mem; d=s+3; if(*d==0) mem=0;
		}
	}while(mem);

	/* URLs drÅberschreiben */
	vst_color(vhandle, ios.urlcol);
	vst_effects(handle, 8);
	url_schr_v_gtext(vhandle, px, py, c, "http://", extend);
	url_schr_v_gtext(vhandle, px, py, c, "ftp://", extend);
	url_schr_v_gtext(vhandle, px, py, c, "mailto:", extend);
	vst_effects(handle, 0);
	vst_color(vhandle, fcolor);
}

void lv_gtext(int vhandle, int *clipxy, int x, int y, char *c, int fcolor)
{/* Ausgabe mit Beachtung der kÅnstlichen UmbrÅche */
	char mem;
	long	len=lstrlen(c);
	
	mem=c[len];
	
	switch(mem)
	{
		case RP_CR:	/* Umbruch OK */
			if(c[len-1]==1)	/* Ignorieren! */
			{	mem=1; c[len-1]=0;}
			url_v_gtext(vhandle, clipxy, x, y, c, fcolor, mail_extent);
			if(mem) c[len-1]=1;
		break;
		case RP_SPC:	/* Umbruch OK, war Space */
		case RP_TAB:	/* Umbruch OK, war Tab */
			c[len]=0;
			url_v_gtext(vhandle, clipxy, x, y, c, fcolor, mail_extent);
			c[len]=mem;
		break;
		case RP_MIN:	/* Umbruch, war '-' */
			mem=c[len+1];
			c[len]='-';
			c[len+1]=0;
			url_v_gtext(vhandle, clipxy, x, y, c, fcolor, mail_extent);
			c[len]=3;
			c[len+1]=mem;
		break;
	}
}

/* -------------------------------------- */

void mail_copy(void)
{/* Kopiert den Selektierten Text ins Clipboard */
	long		a, cnt;
	int			fh;
	char		*w, mem;

	if(sel_sl == -1) return;

	fh=write_clipboard("SCRAP.TXT");
	if(fh < 0) {gemdos_alert(gettext(CREATEERR), fh); return;}

	w=loaded; cnt=0;
	if(w) while(cnt < sel_sl)
	{	w+=lstrlen(w)+1;	++cnt;}
	w+=sel_sc; if(sel_sc) --w;
	while(cnt < sel_el)
	{
		if(w[0]==FIRST_FAT) ++w;	/* Fett-Markierung nicht mit-kopieren */
		a=lstrlen(w);
		switch(w[a])
		{
			case RP_CR:
				if(w[a-1]==RP_CRLF) --a;
				Fwrite(fh, a, w); Fwrite(fh, 2, "\r\n");
			break;
			case RP_SPC:
				Fwrite(fh, a, w); Fwrite(fh, 1, " ");
			break;
			case RP_MIN:
				Fwrite(fh, a, w); Fwrite(fh, 1, "-");
			break;
			case RP_TAB:
				Fwrite(fh, a, w); Fwrite(fh, 1, "\t");
			break;
			default:
				Fwrite(fh, a, w);
			break;
		}
		w+=lstrlen(w)+1; ++cnt;
	}
	if(sel_ec)
	{
		if(w[0]==FIRST_FAT) ++w;	/* Fett-Markierung nicht mit-kopieren */
		if(sel_el==sel_sl)
		{mem=w[sel_ec-sel_sc+1];	w[sel_ec-sel_sc+1]=0;}
		else
		{mem=w[sel_ec]; w[sel_ec]=0;}
		a=lstrlen(w);
		Fwrite(fh, a, w); 
		if(mem < RP_SPC) Fwrite(fh, 2, "\r\n");
		if(sel_el==sel_sl) w[sel_ec-sel_sc+1]=mem;
		else w[sel_ec]=mem;
	}
	Fclose(fh);
}

/* -------------------------------------- */

void mail_selall(void)
{
	long		cnt=0;
	char		*w=loaded;

	if(w==NULL) return;
	sel_sc=sel_sl=0;
	sel_el=llines-1; 
	while(cnt < llines-1)
	{	w+=lstrlen(w)+1;	++cnt;}
	sel_ec=lstrlen(w); if(w[0]==RP_CRLF) --sel_ec;
	
	w_objc_draw(&wdial, FTEXT, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void mail_extent(char *c, int *ex)
{
	ex[2]=0;
	while(*c)
		ex[2]+=ios.mcwidth[(uchar)(*c++)];
}

/* -------------------------------------- */

char	*stristr(char *src, char *search)
{
	long a=strlen(search), f=strlen(src)-strlen(search);
	
	if(f < 0) return(NULL);
	do
	{
		if(!strnicmp(src, search, a)) return(src);
		++src;
		--f;
	}
	while(f >= 0);
	return(NULL);
}

/* -------------------------------------- */

int strmnicmp(char *src, char *dst)
{	
	long a=strlen(dst);
	return(strnicmp(src, dst, a));
}

/* -------------------------------------- */

char *lstristr(char *src, char *search)
{/* Suche in Formatiertem String (d.h. Endezeichen <=3 ) */
	long a=lstrlen(search), f=lstrlen(src)-lstrlen(search);
	
	if(f < 0) return(NULL);
	do
	{
		if(!strnicmp(src, search, a)) return(src);
		++src;
		--f;
	}
	while(f >= 0);
	return(NULL);
}

char *lstrstr(char *src, char *search)
{/* Suche in Formatiertem String (d.h. Endezeichen <=3 ) */
	long a=lstrlen(search), f=lstrlen(src)-lstrlen(search);
	
	if(f < 0) return(NULL);
	do
	{
		if(!strncmp(src, search, a)) return(src);
		++src;
		--f;
	}
	while(f >= 0);
	return(NULL);
}

/* -------------------------------------- */

void main_sel_search_string(void)
{
	OBJECT *tree;
	long	cnt, xoff=0;
	char	*w, *c;

	if(loaded==NULL) {sel_sl=-1; return;}
	rsrc_gaddr(0, SEARCH, &tree);

	w=loaded; cnt=0;
	while(cnt < sel_sl)	/* Bei nicht-Selektion ist sel_sl=-1 */
	{	w+=lstrlen(w)+1;	++cnt;}
	if(sel_sl > -1)
	{/* Sel-Start+1 dazuzÑhlen, damit nicht nochmal gleiche Fundstelle */
		w+=xoff=sel_sc;
		if(sel_sc==0) ++w;
		/*else --xoff;*/
	}
	while(cnt < llines)
	{
		if(tree[SEGRKL].ob_state & SELECTED)		/* GROSS=klein (stristr) */
			c=lstristr(w, tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext);
		else
			c=lstrstr(w, tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext);
		if(c)
		{
			sel_el=sel_sl=cnt;
			sel_sc=(c-w)+1+xoff;
			sel_ec=sel_sc+strlen(tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext)-1;
			return;
		}
		xoff=0;
		++cnt;
		w+=lstrlen(w)+1;
	}
	sel_sl=-1;
}

/* -------------------------------------- */

void main_search(void)
{
	main_sel_search_string();
	if(sel_sl==-1) 
		Bell(); 
	else /* Nachrichten-Anzeige auf Sel-Offset bringen */
	lloff=sel_sl;
	mail_slide_set();
	if(!(odial[FTEXT].ob_flags & HIDETREE))
		w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void asuchen(void)
{
	WINDOW	*win;
	int			wh;

	/* Oberstes Fenster ist Editor? */
	wh=wind_gtop();
	win=w_find(wh);
	if(win==NULL) return;
	if(win==&wdial) {main_search(); return;}
	if(ext_type(win->dinfo->tree, 0)!=1) return;
	edit_search(win);
}

/* -------------------------------------- */

void suchen(void)
{
	OBJECT *tree;

	rsrc_gaddr(0, SEARCH, &tree);
	tree[SEOK].ob_state &= (~SELECTED);
	tree[SEABBRUCH].ob_state &= (~SELECTED);
	if(w_do_dial(tree)==SEABBRUCH) return;
	asuchen();	
}

/* -------------------------------------- */

void date_popup(WINDOW *win, int dst_ob)
{/* Zeigt das Datum-Popup und trÑgt Ergebnis in win/ob ein.
		win/ob muû editable vom Format tt[.]mm[.]yyyy sein */
	OBJECT	*dst=win->dinfo->tree, *tree;
	char		num[10];
	int			res, mx, my;
	uint		gdate;
	int			dd, mm, yy;
	
	rsrc_gaddr(0, AFDATPOP, &tree);
	graf_mkstate(&mx, &my, &res, &res);
	res=form_popup(tree, mx, my);
	if(res < 1) return;
	gdate=Tgetdate();
	dd=(int)(gdate&31);
	mm=(int)((gdate>>5)&15);
	yy=(int)(gdate>>9);
	yy+=1980;
	switch(res)
	{
		case 1:	/* 1 Woche */
			dd-=7;
		break;
		case 2:	/* 2 Wochen */
			dd-=14;
		break;
		case 3:	/* 1 Monat */
			mm-=1;
		break;
		case 4:	/* 2 Monate */
			mm-=2;
		break;
		case 5:	/* 1/2 Jahr */
			mm-=6;
		break;
		case 6:	/* 1 Jahr*/
			yy-=1;
		break;
		case 7:	/* 2 Jahre */
			yy-=2;
		break;
	}
	if(dd < 1)
	{	
		--mm;
		if(mm < 1) {--yy; mm=12;}
		switch(mm)
		{
			case 1: case 3: case 5: case 7: case 8: case 10: case 12:
				dd+=31;
			break;
			case 2:
				if((yy/4)*4==yy)
					dd+=29;
				else
					dd+=28;
			break;
			default:
				dd+=30;
			break;
		}
	}
	else if(mm < 1)
	{
		--yy; mm+=12;
		switch(mm)
		{
			case 4: case 6: case 9: case 11:
				if(dd > 30) dd=30;
			break;
			case 2:
				if((yy/4)*4==yy)
				{	if(dd > 29) dd=29;}
				else
				{ if(dd > 28) dd=28;}
			break;
		}
	}

	dst[dst_ob].ob_spec.tedinfo->te_ptext[0]=0;

	if(dd < 10)
		strcpy(dst[dst_ob].ob_spec.tedinfo->te_ptext, " ");
	strcat(dst[dst_ob].ob_spec.tedinfo->te_ptext, itoa(dd, num, 10));

	if(mm < 10)
		strcat(dst[dst_ob].ob_spec.tedinfo->te_ptext, " ");
	strcat(dst[dst_ob].ob_spec.tedinfo->te_ptext, itoa(mm, num, 10));

	strcat(dst[dst_ob].ob_spec.tedinfo->te_ptext, itoa(yy, num, 10));
	
	w_objc_draw(win, dst_ob, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

char *itoa2(int a, char *t)
{
	/* Wandelt a auf Zehnerbasis in String t und hÑngt fÅhrende
		Zeichen '0' an bis LÑnge 2 erreicht ist
	*/

	if(a < 10)
	{
		t[0]='0';	
		t[1]=a+'0';
		t[2]=0;
		return(t);
	}
	
	return(itoa(a, t, 10));
}

/* -------------------------------------- */

void clip_url(void)
{/* Im Clipboard gespeicherte URL an Desktop schicken */
	int 	fh, red;
	static char	c[1025], *w;
	
	fh=sread_clipboard("SCRAP.TXT");
	if(fh < 0) return;
	red=(int)Fread(fh, 1024, c);
	Fclose(fh);
	if(red < 0) return;
	c[red]=0;
	while((c[strlen(c)-1]==13)||(c[strlen(c)-1]==10)||(c[strlen(c)-1]=='\"')||(c[strlen(c)-1]=='>')) 
		c[strlen(c)-1]=0;
	w=c;
	if((c[0]=='\"') || (c[0]=='<')) ++w;

	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=c;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=3210; /* Magic */
	appl_write(0, 16, pbuf);
}