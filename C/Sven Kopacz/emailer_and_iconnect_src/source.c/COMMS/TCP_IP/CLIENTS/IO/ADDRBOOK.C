#include <ec_gem.h>
#include <atarierr.h>
#include "io.h"
#include "ioglobal.h"
#include "addrbook.h"

void adr_autoloc(int key, int swt);

void draw_adrframe(void)
{
	w_objc_draw(&waddress, ADRFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(&waddress, ADRBAR, 8, sx,sy,sw,sh);
	w_objc_draw(&waddress, ADRTITEL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void put_abs_to_adrbook(void)
{
	char *c, *d, buf[256];
	
	buf[255]=0;
	if(loaded==NULL) return;
	address_dial(&wdial);
	if(!(waddress.open))return;
	if((c=get_head_field("From:"))==NULL) return;
	while(*c==' ')++c;
	strncpy(buf, c, 255);
	if(((c=strchr(buf, '<'))!=NULL) && ((d=strchr(c, '>'))!=NULL))
	{*c=0; ++c; *d=0;}
	else
		c=buf;
	if(c > buf+1)	/* buf ist Name und c Adresse */
		d=buf;
	else
	{
		if((d=strchr(c, '('))!=NULL)
		{
			*d=0; ++d;
			if(strchr(d, ')')!=NULL) *strchr(d, ')')=0;
		}
		else
			d="";
	}

	while(c[strlen(c)-1]==' ') c[strlen(c)-1]=0;
	while(d[strlen(d)-1]==' ') d[strlen(d)-1]=0;

	objc_xtedcpy(oaddress, ADRNAME, d);
	objc_xtedcpy(oaddress, ADRADR, c);

	w_objc_draw(&waddress, ADRNAME, 8, sx,sy,sw,sh);
	w_objc_draw(&waddress, ADRADR, 8, sx,sy,sw,sh);
	
	adr_autoloc(0,0);
}

/* -------------------------------------- */

int load_addrbook(void)
{/* -1=Kein Speicher, 0=Kein Adressbuch, 1=Ok */
	char path[256], *c;
	long	fhl;
	int		fh;
	
	if(adr_inf.addr) free(adr_inf.addr);
	adr_inf.addr=NULL; adr_inf.addr_c=0; adr_inf.changes=0;
	strcpy(path, db_path);
	strcat(path, "\\ADDRBOOK.TXT");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0)
	{
		if(fhl != EFILNF) gemdos_alert(gettext(ADDROPEN_ERR), fhl);
		return(0);
	}
	fh=(int)fhl;
	fhl=Fseek(0, fh, 2);
	Fseek(0,fh,0);
	c=malloc(fhl+1+2);	/* Evtl muž CR/LF angefgt werden */
	if(c==NULL)
	{
		form_alert(1, gettext(NO_ADDRMEM));
		Fclose(fh);
		return(-1);
	}
	adr_inf.addr=c;
	Fread(fh, fhl, c);
	Fclose(fh);
	c[fhl]=0;
	if((c[fhl-1]!=10)&&(c[fhl-1]!=13)) {c[fhl]=13;c[fhl+1]=10;c[fhl+2]=0;}
	adr_inf.addr_c=0;
	while(*c)
	{
		++adr_inf.addr_c;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		while(*c&&((*c==13)||(*c==10)))++c;
	}
	return(1);
}

/* -------------------------------------- */

void save_addrbook(void)
{
	char path[256];
	long	fhl;
	int		fh, pbuf[8];
	
	strcpy(path, db_path);
	strcat(path, "\\ADDRBOOK.TXT");
	if((adr_inf.addr==NULL) || (adr_inf.addr_c==0))
	{
		Fdelete(path);
		goto _exit_save;
	}
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert(gettext(ADDRMAKE_ERR), fhl);
		return;
	}
	fh=(int)fhl;
	Fwrite(fh, strlen(adr_inf.addr), adr_inf.addr);
	Fclose(fh);
	adr_inf.changes=0;

_exit_save:
	/* Inform ADDRBOOK */
	if((fh=appl_find("ADDRBOOK")) > 0)
	{
		pbuf[0]=ADDRBOOK_CHANGED;
		pbuf[1]=ap_id;
		pbuf[3]=1;
		appl_write(fh, 16, pbuf);
	}
}

/* -------------------------------------- */

int delete_addr(void)
{
	char *c, *d;
	long 	cnt=0;
	
	adr_inf.changes=1;
	c=adr_inf.addr;
	while(cnt < adr_inf.sel)
	{
		while(*c && (*c!=13)&&(*c!=10)) ++c;
		if(!(*c))return(0);
		while(*c && ((*c==13)||(*c==10)))++c;
		if(!(*c)) return(0);
		++cnt;
	}
	d=c;
	while(*c && (*c!=13)&&(*c!=10)) ++c;
	while(*c && ((*c==13)||(*c==10)))++c;
	/* Jetzt d=Anfang zu l”schende, c=Anfang n„chste */
	/* Alles nach hinten kopieren: */
	while(*c) *d++=*c++;
	*d=0;
	--adr_inf.addr_c;
	if(adr_inf.addr_c==0)
	{
		free(adr_inf.addr);
		adr_inf.addr=NULL;
	}
	return(1);
}

/* -------------------------------------- */

int rename_addr(char *newname, char *newaddr)
{
	char *c, *d, *n;
	long 	cnt=0, siz;
	
	adr_inf.changes=1;
	c=adr_inf.addr;
	while(cnt < adr_inf.sel)
	{
		while(*c && (*c!=13)&&(*c!=10)) ++c;
		if(!(*c))return(0);
		while(*c && ((*c==13)||(*c==10)))++c;
		if(!(*c)) return(0);
		++cnt;
	}
	d=c;
	while(*c && (*c!=13)&&(*c!=10)) ++c;
	while(*c && ((*c==13)||(*c==10)))++c;
	/* Jetzt d=Anfang zu „ndernde, c=Anfang n„chste */
	*d=0;
	siz=strlen(c)+strlen(adr_inf.addr);
	siz+=strlen(newname);
	siz+=1;	/* TAB */
	siz+=strlen(newaddr);
	siz+=3; /* CR/LF + 0 */
	n=malloc(siz);
	if(n==NULL){form_alert(1, gettext(NOMEM)); return(0);}
	strcpy(n, adr_inf.addr); /* šber d teminiert */
	strcat(n, newname);
	strcat(n, "\t");
	strcat(n, newaddr);
	strcat(n, "\r\n");
	strcat(n, c);
	free(adr_inf.addr);
	adr_inf.addr=n;
	return(1);
}

/* -------------------------------------- */

int add_addr(void)
{
	char *c;
	long	siz=0;
	
	adr_inf.changes=1;
	if(adr_inf.addr)	siz=strlen(adr_inf.addr);
	siz+=strlen(xted(oaddress, ADRNAME)->te_ptext);
	siz+=1;	/* TAB */
	siz+=strlen(xted(oaddress, ADRADR)->te_ptext);
	siz+=3; /* CR/LF + 0 */
	c=malloc(siz);
	if(c==NULL)
	{
		form_alert(1, gettext(NOMEM));
		return(0);
	}
	if(adr_inf.addr) strcpy(c, adr_inf.addr);
	else c[0]=0;
	strcat(c, xted(oaddress, ADRNAME)->te_ptext);
	strcat(c, "\t");
	strcat(c, xted(oaddress, ADRADR)->te_ptext);
	strcat(c, "\r\n");
	if(adr_inf.addr) free(adr_inf.addr);
	adr_inf.addr=c;
	++adr_inf.addr_c;
	return(1);
}

/* -------------------------------------- */

void adr_init_inf(void)
{
	adr_inf.offset=adr_inf.sel=0;
	if(adr_inf.addr==NULL) load_addrbook();
}

/* -------------------------------------- */

void adr_set_dial(void)
{
	long	a;
	long	t, l;
	char *c, *d, *e, mem;
	
	/* Slider setzen */

	/* Ggf. Listenoffset korrigieren */
	l=(ADRLAST-ADR1)/2+1;	/* Sichtbare Zeilen */
	if(adr_inf.offset+l > adr_inf.addr_c)	adr_inf.offset=adr_inf.addr_c-l;
	if(adr_inf.offset < 0) 	adr_inf.offset=0;
	
	a=adr_inf.offset;
	
	if(adr_inf.addr_c <= l)
	{
		oaddress[ADRSLIDE].ob_y=0;
		oaddress[ADRSLIDE].ob_height=oaddress[ADRBAR].ob_height;
		goto _adr_text;
	}
	
	/* Slidergr”že */
	t=(long)adr_inf.addr_c*(long)(oaddress[ADR1].ob_height);	/* Gesamte Liste in Pixeln */
	oaddress[ADRSLIDE].ob_height=(int)( ((long)oaddress[ADRBAR].ob_height*(long)(l*(long)oaddress[ADR1].ob_height))/t);
	if(oaddress[ADRSLIDE].ob_height < oaddress[ADRSLIDE].ob_width)
		oaddress[ADRSLIDE].ob_height=oaddress[ADRSLIDE].ob_width;
	
	/* Sliderpos. */
	oaddress[ADRSLIDE].ob_y=(int)(
				((long)(oaddress[ADRBAR].ob_height-oaddress[ADRSLIDE].ob_height)*
				 (long)(adr_inf.offset)) 
				 / 
				 (adr_inf.addr_c-l));

_adr_text:
	/* Strings setzen */
	t=a;
	c=adr_inf.addr;
	if(c) while(t)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) break;
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) break;
		--t;
	}
	while((a < adr_inf.addr_c) && (a-adr_inf.offset <= (ADRLAST-ADR1)/2))
	{
		strncpy(e=oaddress[ADR1+(a-adr_inf.offset)*2].ob_spec.tedinfo->te_ptext, c, 30);
		e[30]=0;
		if((d=strchr(e, 9))!=NULL) *d=0;
		if((d=strchr(e, 13))!=NULL) *d=0;
		if((d=strchr(e, 10))!=NULL) *d=0;
		while(*c && (*c!=9)&&(*c!=13)&&(*c!=10))++c;
		if(*c==9)
		{
			e=d=c;
			while(*d&&(*d!=13)&&(*d!=10))++d;
			mem=*d; *d=0;
			if(strchr(e, ','))
				oaddress[IADR1+(a-adr_inf.offset)*2].ob_spec.iconblk=ovorl[IADR_MULTI].ob_spec.iconblk;
			else
				oaddress[IADR1+(a-adr_inf.offset)*2].ob_spec.iconblk=ovorl[IADR_SINGLE].ob_spec.iconblk;
			*d=mem;
			while(*c&&(*c!=13)&&(*c!=10))++c;
		}
		else
			oaddress[IADR1+(a-adr_inf.offset)*2].ob_spec.iconblk=ovorl[IADR_SINGLE].ob_spec.iconblk;
		while(*c&&((*c==13)||(*c==10)))++c;
		oaddress[IADR1+(a-adr_inf.offset)*2].ob_flags &= (~HIDETREE);

		if(a==adr_inf.sel)
			oaddress[ADR1+(a-adr_inf.offset)*2].ob_state |= SELECTED;
		else
			oaddress[ADR1+(a-adr_inf.offset)*2].ob_state &= (~SELECTED);
		++a;
	}
	while(a-adr_inf.offset <= (ADRLAST-ADR1)/2)
	{
		oaddress[ADR1+(a-adr_inf.offset)*2].ob_spec.tedinfo->te_ptext[0]=0;
		oaddress[ADR1+(a-adr_inf.offset)*2].ob_state &= (~SELECTED);
		oaddress[IADR1+(a-adr_inf.offset)*2].ob_flags |= HIDETREE;
		++a;
	}
	
	/* Buttons aktiv/inaktiv */
	if((!(oaddress[ADRRENAME].ob_state & DISABLED)) && ((adr_inf.addr==NULL)||(adr_inf.addr_c==0)))
	{
		oaddress[ADRRENAME].ob_state |= DISABLED;
		oaddress[IADRRENAME].ob_state |= DISABLED;
		oaddress[ADRDEL].ob_state |= DISABLED;
		oaddress[IADRDEL].ob_state |= DISABLED;
		w_objc_draw(&waddress, ADRRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&waddress, ADRDEL, 8, sx,sy,sw,sh);
	}
	else if((oaddress[ADRRENAME].ob_state & DISABLED) && (adr_inf.addr!=NULL) && (adr_inf.addr_c > 0))
	{
		oaddress[ADRRENAME].ob_state &= (~DISABLED);
		oaddress[IADRRENAME].ob_state &= (~DISABLED);
		oaddress[ADRDEL].ob_state &= (~DISABLED);
		oaddress[IADRDEL].ob_state &= (~DISABLED);
		w_objc_draw(&waddress, ADRRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&waddress, ADRDEL, 8, sx,sy,sw,sh);
	}
}

/* -------------------------------------- */

char	*get_adrname(long a)
{
	char	*c=adr_inf.addr;
	static char buf[66];
	
	buf[0]=buf[65]=0;
	if(c==NULL) return(buf);
	while(a)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) return(buf);
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) return(buf);
		--a;
	}
	strncpy(buf, c, 64);
	if((c=strchr(buf, 9))!=NULL) *c=0;
	if((c=strchr(buf, 13))!=NULL) *c=0;
	if((c=strchr(buf, 10))!=NULL) *c=0;
	return(buf);
}

/* -------------------------------------- */

char *get_adradr(long a)
{
	char	*c=adr_inf.addr, *d;
	long  len;
	static char *buf="";
	
	if(c==NULL) return(buf);
	while(a)
	{
		while((*c)&&(*c!=13)&&(*c!=10))++c;
		if(*c==0) return(buf);
		while(*c&&((*c==13)||(*c==10)))++c;
		if(*c==0) return(buf);
		--a;
	}
	while(*c&&(*c!=9)&&(*c!=13)&&(*c!=10))++c;
	if(*c!=9) return(buf);
	++c;
	len=0;
	d=c;
	while(*c && (*c!=13) && (*c!=10)) {++c; ++len;}
	buf=malloc(len+1); if(buf==NULL) return("");
	strncpy(buf, d, len);
	buf[len]=0;
	return(buf);
}

char *get_256adradr(long a)
{
	char *c=get_adradr(a);
	if(strlen(c) > 256) c[256]=0;
	return(c);
}

/* -------------------------------------- */

long get_index(char *name)
{/* Falls <name> im Addresbuch, wird der Index des Eintrags geliefert,
	sonst -1 */

	char	*c=adr_inf.addr, *d, mem;
	long cnt=0;
	
	if(c==NULL) return(-1);
	while(cnt < adr_inf.addr_c)
	{
		d=c;
		while(*c&&(*c!=9)&&(*c!=13)&&(*c!=10))++c;
		mem=*c; *c=0;
		if(!stricmp(name, d)) {*c=mem; return(cnt);}
		*c=mem;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		while(*c&&((*c==13)||(*c==10)))++c;
		++cnt;
	}
	return(-1);
}

/* -------------------------------------- */

void adr_closed(WINDOW *win)
{
	if(adr_inf.changes)
		save_addrbook();
	w_close(win);
	w_kill(win);
}

/* -------------------------------------- */

void adr_autoloc(int key, int swt)
{
	long	n, ix;
	char	*c;
	static char buf[66];
	
	/* Avoid Compiler-Warning: */
	if((key==swt)&&(key!=swt)) return;

	if((adr_inf.addr==NULL)||(adr_inf.addr_c==0)) return;

	/* Žnderungen am Namen? */
	if(!stricmp(buf, xted(oaddress, ADRNAME)->te_ptext)) return;
	strcpy(buf, xted(oaddress, ADRNAME)->te_ptext);
	n=strlen(buf);
	c=adr_inf.addr;
	ix=0;
	while(*c)
	{
		if(strnicmp(buf, c, n)==0) goto _aloc_found;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		while(*c&&((*c==13)||(*c==10)))++c;
		++ix;
	}
	/* Nicht dabei, "Neu" als Default */
	if(oaddress[ADRNEU].ob_flags & DEFAULT) return;
	oaddress[ADRNEU].ob_flags |= DEFAULT;
	oaddress[ADRWRITETO].ob_flags &= (~DEFAULT);
	w_objc_draw(&waddress, ADRBUTFRAME, 8, sx,sy,sw,sh);
	return;

_aloc_found:
	if(ix==adr_inf.sel) goto _aloc_but;
	adr_inf.sel=ix;
	if(adr_inf.offset > ix) adr_inf.offset=ix;
	if(adr_inf.offset+(ADRLAST-ADR1)/2 < ix) adr_inf.offset=ix-((ADRLAST-ADR1)/2);
	adr_set_dial();
	draw_adrframe();
_aloc_but:
	if(oaddress[ADRWRITETO].ob_flags & DEFAULT) return;
	oaddress[ADRWRITETO].ob_flags |= DEFAULT;
	oaddress[ADRNEU].ob_flags &= (~DEFAULT);
	w_objc_draw(&waddress, ADRBUTFRAME, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void address_reload(int req_id)
{/* Addressbuch wurde von externer App ge„ndert -> Neu einlesen */
	int pbuf[8];
	
	if(waddress.open)	/* Nicht m”glich, w„hrend Addressbuch offen */
	{
		pbuf[0]=ADDRBOOK_CHANGED;
		pbuf[1]=ap_id;
		pbuf[3]=3;
		appl_write(req_id, 16, pbuf);
		return;
	}
	
	/* Addressbuch ist zu -> Adressbuch neu einlesen */
	if(load_addrbook()==1)
		pbuf[3]=2;
	else
		pbuf[3]=4;
	pbuf[0]=ADDRBOOK_CHANGED;
	pbuf[1]=ap_id;
	appl_write(req_id, 16, pbuf);
}

/* -------------------------------------- */

void	address_dial(WINDOW *caller)
{
	char *c;
	
	waddress.user=caller;
	/* Wird auf NULL gesetzt, falls caller->tree[0] ext_type<0 ist
		und der Dialog per Anschreibe-Button verlassen wurde.
		Mit get_adrname(adr_inf.sel) kann dann der gew„hlte Eintrag
		ausgelesen werden. 
	 */
	
	if(waddress.open)
	{
		w_top(&waddress);
		return;
	}

	adr_init_inf();
	adr_set_dial();
	if(adr_inf.addr_c)
	{
		objc_xtedcpy(oaddress, ADRNAME, get_adrname(adr_inf.sel));
		objc_xtedcpy(oaddress, ADRADR, c=get_256adradr(adr_inf.sel)); if(c[0]) free(c);
	}
	waddress.dinfo=&daddress;
	w_kdial(&waddress, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	waddress.closed=adr_closed;
	daddress.dakeybd=adr_autoloc;
	/*waddress.name="";
	w_set(&waddress, NAME);*/
	daddress.dedit=ADRNAME;
	w_open(&waddress);
}

/* -------------------------------------- */

void slide_address(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off;

	maxy=oaddress[ADRBAR].ob_height-oaddress[ADRSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(oaddress, ADRSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(oaddress, ADRBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=(IADRLAST-IADR1)/2+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(adr_inf.addr_c-l))/(long)maxy);
		if(off!=adr_inf.offset)
		{
			adr_inf.offset=off;
			adr_set_dial();
			draw_adrframe();
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void pack_edits(void)
{
	char name[66], adr[258], *n, *m;
	
	n=xted(oaddress, ADRNAME)->te_ptext;
	/* Fhrende Leerzeichen weg */
	while(*n==' ')++n;
	strcpy(name, n);
	/* Kommas in Space */
	n=name;
	while(*n) {if(*n==',') *n=' '; ++n;}
	/* Doppelte Leerzeichen weg */
	n=m=name;
	while(*n)
	{
		if((*n==' ')&&(*(n+1)==' ')) {++n; continue;}
		*m++=*n++;
	}
	*m=0;
	/* Abschliežende Leerzeichen weg */
	if(name[0])
	{
		n=&(name[strlen(name)-1]);
		while(*n==' '){*n=0; --n;}
	}
	
	n=xted(oaddress, ADRADR)->te_ptext;
	while(*n==' ')++n;
	strcpy(adr, n);
	if(adr[0])
	{/* Abschliežende Space entfernen */
		n=&(adr[strlen(adr)-1]);
		while(*n==' '){*n=0; --n;}
		/* Komma+Space entfernen */
		while((n=strstr(adr, ", "))!=NULL)
		{
			++n;
			while(*n){*n=*(n+1);++n;}
		}
	}

	w_dialcursor(&waddress, D_CUROFF);
	objc_xtedcpy(oaddress, ADRNAME, name);
	objc_xtedcpy(oaddress, ADRADR, adr);
	w_objc_draw(&waddress, ADRNAME, 8, sx,sy,sw,sh);
	w_objc_draw(&waddress, ADRADR, 8, sx,sy,sw,sh);
	w_dialcursor(&waddress, D_CURON);
}

/* -------------------------------------- */

long count_comma(char *c)
{
	long cnt=0;
	
	while((c=strchr(c, ','))!=NULL)
	{
		++cnt; ++c;
	}
	return(cnt);
}

/* -------------------------------------- */

int adr_resolve(char *adr, char **res)
{/* L”st die (komma-getrennten) Eintr„ge in adr auf und
		schreibt das (komma-getrennte) Ergebnis in eigenen Speicher,
		dessen Zeiger in res geliefert wird. Der Aufrufer muž res
		freigeben!
		return: -1=Rekursion entdeckt!	(dann *res=NULL)
						 0=Nicht genug Speicher (dann *res=NULL)
						 1=Ok oder leeres Adressbuch (dann *res=NULL)
	*/
	char	*mark=NULL, *c, *d, mem, *buf1=NULL, *buf2=NULL, *tmp, *tmp2, found;
	long	ix;
	
	*res=NULL;
	
	if((adr_inf.addr==NULL)||(adr_inf.addr_c==0)) return(1);
	mark=calloc(adr_inf.addr_c, 1); if(mark==NULL) goto _nm_return;
	
	buf1=malloc(strlen(adr)+1); if(buf1==NULL) goto _nm_return;
	strcpy(buf1, adr);
	do
	{
		found=0;
		c=buf1;
		do
		{
			while((*c==' ') || (*c==',')) ++c;
			d=c;
			c=strchr(c, ',');
			if(c){mem=*c; *c=0;}
			ix=get_index(d);
			if(ix > -1)
			{
				found=1;
				if(mark[ix]) goto _rekurs_return;
				mark[ix]=1;
				tmp=get_adradr(ix);
				if(buf2)
				{
					tmp2=malloc(strlen(buf2)+strlen(tmp)+2);
					if(tmp2==NULL) {free(buf2); goto _nm_return;}
					strcpy(tmp2, buf2); free(buf2); buf2=tmp2;
					strcat(buf2, ",");
					strcat(buf2, tmp); 
				}
				else
				{
					buf2=malloc(strlen(tmp)+2);
					if(buf2==NULL) goto _nm_return;
					strcpy(buf2, tmp); 
				}
				if(tmp[0]) free(tmp);
			}
			else
			{
				if(buf2)
				{
					tmp2=malloc(strlen(buf2)+strlen(d)+2);
					if(tmp2==NULL) {free(buf2); goto _nm_return;}
					strcpy(tmp2, buf2); free(buf2); buf2=tmp2;
					strcat(buf2, ",");
					strcat(buf2, d);
				}
				else
				{
					buf2=malloc(strlen(d)+2);
					if(buf2==NULL) goto _nm_return;
					strcpy(buf2, d);
				}
			}
			if(c){*c=mem; ++c;}
		}while(c);
		free(buf1);
		buf1=buf2;
		buf2=NULL;
	}
	while(found);
	*res=buf1;
	while(buf1[strlen(buf1)-1]==',') buf1[strlen(buf1)-1]=0;
	free(mark);
	return(1);

_rekurs_return:
	free(mark);
	free(buf1);
	free(buf2);
	return(-1);

_nm_return:	/* Return no memory */
	if(mark) free(mark);
	if(buf1) free(buf1);
	if(buf2) free(buf2);
	return(0);
}

/* -------------------------------------- */

char	*adr_single_match(char *adr)
{/* Liefert NULL oder einen Zeiger auf einen Adressbuch-Namen, der
		auf adr pažt. Zeiger ist statisch! */
	char	*c, *d, *e, mem;
	static char buf[66];


	if((adr_inf.addr==NULL)||(adr_inf.addr_c==0)) return(NULL);
	c=adr_inf.addr;
	while(*c)
	{
		d=c;
		while(*c&&(*c!=9)&&(*c!=13)&&(*c!=10))++c;
		if(*c==9)
		{
			*c=0; e=c+1;
			while(*e&&(*e!=13)&&(*e!=10))++e;
			mem=*e; *e=0;
			if(!stricmp(adr, c+1)) /* Gefunden */
			{
				strncpy(buf, d, 64); buf[64]=0;
				*c=9; *e=mem;
				return(buf);
			}
			*c=9;
			*e=mem;
			c=e;
		}
		while(*c&&((*c==13)||(*c==10)))++c;
	}
	return(NULL);
}

char	*adr_match(char *adr)
{/* Liefert NULL oder einen Zeiger auf Adressbuch-Namen, der/die
		auf adr pažt. Zeiger ist statisch! Maximal 256 Zeichen. 
		Eingabe muž Komma-getrennt sein */
	static char	buf[256];
	char		*c, *d, *f, mem;
	
	buf[0]=0;
	c=adr;
	while(*c)
	{
		while(*c==' ')++c;
		d=c;
		while(*c && (*c!=',')) ++c;
		mem=*c, *c=0;
		if((f=adr_single_match(d))!=NULL)
			strncat(buf, f, 255-strlen(buf));
		else
			strncat(buf, d, 255-strlen(buf));
		*c=mem;
		if(*c) {++c; if(strlen(buf)<255) strcat(buf, ",");}
	}
	buf[255]=0;
	return(buf);
}

/* -------------------------------------- */

void dial_address(int ob)
{
	long	a;
	int		my,oy,dum;
	char	*tmp, *nbuf, *abuf;
#define err_ret(a) {form_alert(1, gettext(a)); w_wo_ibut_unsel(&waddress, ob); break;}	
	switch(ob)
	{
		case ADRNEU: case IADRNEU:
			if(!w_wo_ibut_sel(&waddress, ob)) break;
			pack_edits();
			if(strlen(xted(oaddress, ADRNAME)->te_ptext)==0)
				err_ret(ADR_NONAME);
			if(strlen(xted(oaddress, ADRADR)->te_ptext)==0)
				err_ret(ADR_NOADR);
			if(get_index(xted(oaddress, ADRNAME)->te_ptext) > -1)
				err_ret(ADR_EALREADY);
			if((!strchr(xted(oaddress, ADRADR)->te_ptext, ','))&&(!strchr(xted(oaddress, ADRADR)->te_ptext, '@')))
			{
				if(get_index(xted(oaddress, ADRADR)->te_ptext) > -1)
					form_alert(1,gettext(ADR_NOALIAS));
				else
					form_alert(1,gettext(ADR_NOEMAIL));
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			if(add_addr()==0)
			{
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			adr_inf.sel=adr_inf.addr_c-1;
			if(strchr(xted(oaddress, ADRADR)->te_ptext, ','))
			{
				a=adr_resolve(xted(oaddress, ADRADR)->te_ptext, &tmp);
				if(a < 1)
				{
					delete_addr();
					if(a==-1)	err_ret(ADR_REKURS)
					else err_ret(NOMEM)
				}
				free(tmp);
			}
			adr_set_dial();
			draw_adrframe();
			w_wo_ibut_unsel(&waddress, ob);
		break;
		case ADRRENAME: case IADRRENAME:
			if(!w_wo_ibut_sel(&waddress, ob)) break;
			pack_edits();
			if(strlen(xted(oaddress, ADRNAME)->te_ptext)==0)
				err_ret(ADR_NONAME);
			if(strlen(xted(oaddress, ADRADR)->te_ptext)==0)
				err_ret(ADR_NOADR);
			if((((a=get_index(xted(oaddress, ADRNAME)->te_ptext)) != adr_inf.sel)) && (a!=-1))
				err_ret(ADR_EALREADY);
			if((!strchr(xted(oaddress, ADRADR)->te_ptext, ','))&&(!strchr(xted(oaddress, ADRADR)->te_ptext, '@')))
			{
				if(get_index(xted(oaddress, ADRADR)->te_ptext) > -1)
					form_alert(1,gettext(ADR_NOALIAS));
				else
					form_alert(1,gettext(ADR_NOEMAIL));
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			nbuf=get_adrname(adr_inf.sel);
			abuf=get_adradr(adr_inf.sel);
			if(rename_addr(xted(oaddress, ADRNAME)->te_ptext, xted(oaddress, ADRADR)->te_ptext)==0)
			{
				w_wo_ibut_unsel(&waddress, ob);
				if(abuf[0]) free(abuf);
				break;
			}
			if(strchr(xted(oaddress, ADRADR)->te_ptext, ','))
			{
				a=adr_resolve(xted(oaddress, ADRADR)->te_ptext, &tmp);
				if(a < 1)
				{
					rename_addr(nbuf, abuf);
					if(abuf[0]) free(abuf);
					if(a == -1)	err_ret(ADR_REKURS)
					else err_ret(NOMEM)
				}
				free(tmp);
			}
			if(abuf[0]) free(abuf);
			adr_set_dial();
			draw_adrframe();
			w_wo_ibut_unsel(&waddress, ob);
		break;
		case ADRDEL: case IADRDEL:
			if(!w_wo_ibut_sel(&waddress, ob)) break;
			if(strlen(xted(oaddress, ADRNAME)->te_ptext)==0)
			{
				form_alert(1,gettext(ADR_NONAME));
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			if(strlen(xted(oaddress, ADRADR)->te_ptext)==0)
			{
				form_alert(1,gettext(ADR_NOADR));
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			if(delete_addr()==0)
			{
				w_wo_ibut_unsel(&waddress, ob);
				break;
			}
			if(adr_inf.sel >= adr_inf.addr_c)
			{
				adr_inf.sel=adr_inf.addr_c-1;
				if(adr_inf.sel < 0) adr_inf.sel=0;
			}
			adr_set_dial();
			w_dialcursor(&waddress, D_CUROFF);
			objc_xtedcpy(oaddress, ADRNAME, get_adrname(adr_inf.sel));
			objc_xtedcpy(oaddress, ADRADR, tmp=get_256adradr(adr_inf.sel)); if(tmp[0]) free(tmp);
			w_objc_draw(&waddress, ADRNAME, 8, sx,sy,sw,sh);
			w_objc_draw(&waddress, ADRADR, 8, sx,sy,sw,sh);
			w_dialcursor(&waddress, D_CURON);
			draw_adrframe();
			w_wo_ibut_unsel(&waddress, ob);
		break;
	
		case ADRWRITETO: case IADRWRITETO:
			if(!w_wo_ibut_sel(&waddress, ob)) break;
			w_wo_ibut_unsel(&waddress, ob);
			adr_closed(&waddress);
			if(ext_type(((WINDOW*)(waddress.user))->dinfo->tree, 0)>0)
				waddress.user=NULL;
			else
			{
				nbuf=get_adrname(adr_inf.sel);
				if(nbuf[0]==0) nbuf=NULL;
				/* Verteiler nicht in CC eintragen */
				/*
				if(strchr(abuf, ','))
					nachricht_an(NULL, nbuf, NULL,NULL);
				else
					nachricht_an(nbuf,NULL,NULL,NULL);
				*/
				nachricht_an(nbuf,NULL,NULL,NULL);
			}
		break;
			
		case ADRUP:
			a=adr_inf.offset-1;
		goto _new_adr_offset;
		case ADRDOWN:
			a=adr_inf.offset+1;
		goto _new_adr_offset;
		case ADRSLIDE:
			slide_address();
		break;
		case ADRBAR:
			graf_mkstate(&dum, &my, &dum, &dum);
			objc_offset(oaddress, ADRSLIDE, &dum, &oy);
			if(my < oy)
				a=adr_inf.offset-((ADRLAST-ADR1)/2+1);
			else
				a=adr_inf.offset+((ADRLAST-ADR1)/2+1);
		goto _new_adr_offset;
	}
	
	if((ob >= IADR1)&&(ob <= ADRLAST))
	{
		a=ob-IADR1; a/=2; a+=adr_inf.offset;
		if(a >= adr_inf.addr_c) a=adr_inf.addr_c-1;
		if(a==adr_inf.sel) return;
		adr_inf.sel=a;
		adr_set_dial();
		if(!(Kbshift(-1) & 8))
		{
			w_dialcursor(&waddress, D_CUROFF);
			objc_xtedcpy(oaddress, ADRNAME, get_adrname(adr_inf.sel));
			objc_xtedcpy(oaddress, ADRADR, tmp=get_256adradr(adr_inf.sel)); if(tmp[0]) free(tmp);
			w_objc_draw(&waddress, ADRNAME, 8, sx,sy,sw,sh);
			w_objc_draw(&waddress, ADRADR, 8, sx,sy,sw,sh);
			w_dialcursor(&waddress, D_CURON);
		}
		draw_adrframe();
		if(oaddress[ADRWRITETO].ob_flags & DEFAULT) return;
		oaddress[ADRWRITETO].ob_flags |= DEFAULT;
		oaddress[ADRNEU].ob_flags &= (~DEFAULT);
		w_objc_draw(&waddress, ADRBUTFRAME, 8, sx,sy,sw,sh);
	}
	return;

_new_adr_offset:
	if(a+(ADRLAST-ADR1)/2+1 > adr_inf.addr_c)	a=adr_inf.addr_c-((ADRLAST-ADR1)/2+1);
	if(a < 0) a=0;
	if(a==adr_inf.offset) return;
	adr_inf.offset=a;
	adr_set_dial();
	draw_adrframe();

#undef err_ret
}

void do_adr_double(int ob)
{
	if((ob >= IADR1)&&(ob <= ADRLAST))
	{
		dial_address(ob);
		dial_address(ADRWRITETO);
	}
}