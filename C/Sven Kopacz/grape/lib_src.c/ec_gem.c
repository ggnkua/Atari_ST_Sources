/* EC_GEM */
/* Funktionen zur vereinfachten GEM-Steuerung */

#include <ec_gem.h>
#include <atarierr.h>
#include <xvdi.h>

/* Globale Variablen */

char	*ap_name;

AP_INFO	ap_info;

int		magix, multitos, geneva, letfly, avs_id;
long	magixval, multitosval, genevaval, letflyval;
int		letflykeys; /* RÅckgabewert von Let'm'fly */

int		pwchar, phchar, pwbox, phbox;
int		ap_id, me_id, ap_type, handle, phys_handle;
int		work_in[11], work_out[57], pbuf[64];
/* AES Font-width */
char	aes_fw[256];
int		aes_fid, aes_fsize;	/* Font-ID und Font-size */

COOKIE	*jar_addres;

/* Interne Funktionen */

void		nostart(char *ap_nam, char *e_text, char aes); 

COOKIE	*inst_jar(long n);


/* VDI-Elemente fÅr Fenster-Workstation */

int		wpwchar, wphchar, wpwbox, wphbox;
int		whandle, wwork_in[11], wwork_out[57];

int		globalmodal, globalhandle; /* Semaphore fÅr Dialoge */

int		show_ww, show_wh;		/* Breite & Hîhe Show-Fenster */
int		show_bw, show_bh;		/* Breite & Hîhe des Balkens */

WINDOW	*winpoint[MAX_WIN];	/* Zeiger auf die Fenster, NULL sind freie EintrÑge */

/*---------------------------------------------------------------*/
/* Programm-Startup */

void	e_start_as(int how, char *ap_nam)
{	/* PrÅft, ob das Programm den Vorgaben enstprechend gestartet
	 wurde. Falls ja erfolgt komplette Anmeldung, falls nein
	 erfolgt Fehlermeldung.
	 Die globalen Variablen :
		pwchar, phchar, pwbox, phbox
		ap_id, me_id, ap_type, handle
		work_in[10], work_out[56]
	 werden entsprechend initialisiert
	 ap_id: von appl_init() geliefert, me_id: FÅr Accessory,
	 bei menu_register() geliefert, ap_type: siehe Eingabe,
	 handle: vdi-handle der virtuellen Workstation
	 Eingabe :
	 ap_name: Name des Programms (fÅr die Fehlemeldungen) und fÅr
	 die Anmeldung fÅr den Fall des Accessorystarts. String wird
	 OHNE fÅhrende 2 Leerzeichen Åbergeben. Diese werden beim Anmelden
	 automatisch hinzugefÅgt! String wird auûerdem fÅr Dialog-Titel
	 verwendet.
	 how: Art des erlaubten Programmstarts, mîglich sind
	 ACC,PRG,TOS,AUTO,ANY und jede beliebige Kombination
	 (VerknÅpfung mittels binÑrem oder '|')
	 PrioritÑten: Bei TOS & PRG wird vom Desktop als PRG
	 Gestartet. Bei Start aus AUTO muû TOS nicht gesetzt
	 sein. Es wird nicht die tatsÑchliche Endung geprÅft,
	 es sind also auch APP,GTP,TTP mîglich.
	 Bei Start aus AUTO wird ap_type auf AUTO | TOS gesetzt
	 Die Funktion setzt die globale Variable ap_type auf
	 den Wert, als welchem das Programm tatsÑchlich gestartet
	 wurde. Bei Fehlstart ist ap_type=NONE.
	 Beim unerlaubten Start als Accessory hÑngt sich das Programm
	 automatisch in eine Endlos-Schleife, in der es sich als
	 ap_name in der MenÅzeile anmeldet und beim Aufruf eine
	 Fehlermeldung zum besten gibt.
	*/
	char		*autext, *aut, *acc, *prg, *autacc, *autprg, *me_name;
	int			a;
	
	for(a=0; a < MAX_WIN;++a)
		winpoint[a]=NULL;
		
	whandle=-1;
	handle=-1;
	
	autext=" nicht aus dem Auto-Ordner starten!]";
	prg="|vom Desktop starten.][Abbruch]";
	aut="|aus dem Auto-|Ordner starten.][Abbruch]";
	acc="|als Accessory starten.][Abbruch]";
	autacc="|als Accessory|oder aus dem Auto-|Ordner starten.][Abbruch]";
	autprg="|aus dem Auto-|Ordner oder vom|Desktop starten.][Abbruch]";
		
	magix=find_cookie('MagX',&magixval);
	multitos=find_cookie('MiNT',&multitosval);
	geneva=find_cookie('Gnva',&genevaval);
	letfly=find_cookie('LTMF',&letflyval);
	letflykeys=0;
	avs_id=-1;
		
	ap_name=ap_nam;
	me_name=(char *) calloc(24, sizeof(char));
	strcpy(me_name,"  ");
	strncat(me_name,ap_name, 21);
	me_name[23]=0;
	if (how)
	{
		ap_type=NONE;
		
		if (_app)
		{ /* Als Programm gestartet */
			(_GemParBlk.global[0])=0;
			ap_id=appl_init();
			if (_GemParBlk.global[0])
			{/* Nicht aus Auto-Ordner gestartet */

				if (how & PRG ) /* Darf als PRG gestartet werden */
				{
					if(ap_id >= 0)
						ap_type=PRG;
				}
				else if (how & TOS) /* Darf als TOS gestartet werden */
				{
					appl_exit();
					ap_type=TOS;
				}
				else
				{ /* Wurde vom Desktop gestartet */
					/* darf aber nur AUTO oder ACC sein */
					if ((how & AUTO) && (how & ACC))
					{	nostart(ap_name, autacc, 1);}
					else if (how & AUTO)
					{	nostart(ap_name, aut, 1);}
					else
					{	nostart(ap_name, acc, 1);}
					
					appl_exit();
				}
			}
			else
			{/* Aus Auto-Ordner gestartet... */
				if (how & AUTO) /* ...was OK ist */
					ap_type=(AUTO | TOS);
				else /* ...was nicht OK ist */
					nostart(ap_name, autext, 0);
			}
		}
		else /* Als Accessory gestartet */
		{
			ap_id=appl_init();
			if(ap_id >= 0)
			{
				me_id=menu_register(ap_id,me_name);
				if(me_id != -1)
				{
					ap_type=ACC;
					if (!(how & ACC))
					{ /* Darf eigentlich keine Accessory sein */
						do
						{
							evnt_mesag(pbuf);
							if(pbuf[0] == AC_OPEN)
							{
								if ((how & AUTO) && ((how & PRG) || (how & TOS)))			
								{	nostart(ap_name, autprg, 1);}
								else if (how & AUTO)
								{	nostart(ap_name, aut, 1);}
								else
								{	nostart(ap_name, prg, 1);}
							}
						}while (1);
					}
				}
				else /* Fehler beim Registrieren im MenÅ */
				{	appl_exit();}
			}
		}
	}
	
	ap_info.gunknown=NULL;
	ap_info.menu=NULL;
		
	free (me_name);
}


void	e_quit(void)
{ /* Beendet ein Programm, wobei nicht viel zu tun ist:
	 Ist ap_type=PRG, so findet eine AES-Abmeldung statt
	 FÅr TOS (also auch fÅr AUTO) ist nichts notwendig
	 ACC kînnen nicht beendet werden, hier sollte die Funktion
	 auch nicht aufgerufen werden, insbesondere dann nicht,
	 wenn _app verÑndert wurde!
	*/
	if (_app)
	{
		if (ap_type & PRG)
		{
			if (whandle > -1)
				v_clsvwk(whandle);
			if (handle > -1)
				v_clsvwk(handle);
			appl_exit();
		}
	}
}

void	uses_vdi(void)
{
	int i, dum, extend[8];
	unsigned char	cw[2];
	
  for ( i = 0; i < 10; i++ )
  {
    work_in[i]  = 1;
  }
  work_in[10] = 2;
	phys_handle=handle=graf_handle(&pwchar, &phchar, &pwbox, &phbox);
	v_opnvwk( work_in, &handle, work_out);

	/* AES-Font Einzelbreiten */
	if(vq_gdos())	vst_load_fonts(handle, 0);
	appl_getinfo(0, &aes_fsize, &aes_fid, &i, &dum);
	vst_font(handle, aes_fid);
	vst_height(handle, aes_fsize, &dum, &dum, &dum, &dum);
	cw[1]=0;
	for(i=0; i < 256; ++i)
	{
		cw[0]=i;
		vqt_extent(handle, (char*)cw, extend);
		aes_fw[i]=extend[2];
	}
	if(vq_gdos()) vst_unload_fonts(handle, 0);
}

void	uses_txwin(void)
{
	int		i, att[10];
	
  for ( i = 0; i < 10; i++ )
  {
    wwork_in[i] = 1;
  }
  wwork_in[10]= 2;
	whandle=graf_handle(&wpwchar, &wphchar, &wpwbox, &wphbox);
	v_opnvwk( wwork_in, &whandle, wwork_out);
	/* Zeichensatzgrîûe fÅr Fenster feststellen */
	vqt_attributes(whandle, att);
	wpwchar=att[8];
	wphchar=att[9];
	wpwbox=att[6];
	wphbox=att[7];
}

void	nostart(char *ap_nam, char *e_text, char aes)
{ /* Gibt Fehlertext aus, falls Anmeldung nicht geklappt hat
	 Weil das Programm nicht den WÅnschen des Programmierers
	 entsprechend gestartet wurde.
	 Eingabe: Zeiger auf Programm-Name, Zeiger auf Fehlertext
	 1 fÅr Alertbox-Ausgabe, 0 fÅr String-Ausgabe (VT52)
	*/
	char		*alert, *output;
	alert="[3][Bitte ";
	output=(char *) calloc(110, sizeof(char));

	strcpy(output, alert);
	strcat(output, ap_nam);
	strcat(output, e_text); 
	
	if (aes)
		form_alert(1, output);
	else
		puts(output);
		
	free(output);
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
/* Cookie Funktionen */
/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/

long	jaradres(void)
{
	jar_addres=(COOKIE*)(*(long*)0x5a0l);
	return((long)jar_addres);
}

long inst_cjar(long n)
{ /* Installiert Cookie-Jar fÅr n Cookies*/
	/* Falls bereits ein Jar existiert, in dem weniger */
	/* als n Cookies frei sind, so wird dieser vergrîûert */
	
	/* Liefert die Anzahl der freien Cookies */

	COOKIE	*cookie, *cookieo;
	int			ncookie=0;

	Supexec(jaradres);
	cookie=cookieo=jar_addres;
	
	if (!cookie)
	{
		if ((cookie=inst_jar(n+1))==NULL)
			return(0); /* Konnte nicht angelegt werden */
		ncookie=0;
	}

	for(;(cookie->id);cookie++,ncookie++);

	/* cookie zeigt auf Nullcookie */

	if ((cookie->val-ncookie) <= n)
	{ /* Nicht mehr genug Platz */
		cookie=inst_jar(cookie->val+n);
		if(cookie)
		{/* Neuer Jar angelegt: Cookies kopieren */
			for (;cookieo->id!=0L;
					(*cookie++)=(*cookieo++));
			cookie->id=0L; /* Letzten auf Null setzen */
			cookie->val=cookieo->val+n;
			return(n);
		}
		else
			return(cookie->val-ncookie); /* Konnte nicht vergrîûert werden*/
	}
	else
		return(cookie->val-ncookie);
}

int			make_cookie(long cid, long cval, int jarmode, long n)
{ /* Legt den Cookie (cid, cval) in den Cookie-Jar */
	/* Mode bedeutet: */
	/* C_NEVER : Keinen neuen Jar anlegen (fÅr PRGs) */
	/* C_ALWAYS : Jar immer um n Cookies vergrîûern */
	/* C_FULL : Jar nur um n Cookies vergrîûern, wenn er voll ist */
	/* C_LAST : Jar um n Cookies vergîûern, wenn er voll ist oder */
	/*           wenn der Eintrag des Cookies den letzten Platz belegt */
	
	/* Liefert 1 bei erfolgreicher Installation */
	/*         0 falls der Cookie schon existiert */
	/*        -1 falls kein Platz vorhanden ist oder der Jar nicht */
	/*           auf die gewÅnschte Grîûe gebracht werden konnte */
	/*           (dann wird der Cookie auch nicht installiert) */
	
	COOKIE	*cookie, *cookieo;
	int			ncookie=0;
	long		jarsize;

	Supexec(jaradres);
	cookie=cookieo=jar_addres;
		
	if (!cookie)
	{
		if (jarmode==C_NEVER)
			return(-1);
		else
		{
			cookie=inst_jar(n+1l);
			if(cookie)
				ncookie=0;
			else
				return(-1);
		}
	}

	else
		for(;((cookie->id)&&(cookie->id!=cid));cookie++,ncookie++);

	/* cookie zeigt auf anzulegenden Cookie oder Nullcookie */

	if (!cookie->id)
	{ /* Noch nicht installiert */
		if 
		( ((jarmode == C_ALWAYS) && (cookie->val-ncookie <= (n+1)))||
			((jarmode == C_NEVER) && (cookie->val<=ncookie)) ||
			((jarmode == C_FULL) && (cookie->val<=ncookie)) ||
			((jarmode == C_LAST) && (cookie->val-ncookie <= 1))
		)
		{ /* Kein Platz mehr */
			if (jarmode == C_NEVER)
				return(-1);

			cookie=inst_jar(cookie->val+n+1l);
			if(cookie)				
			{
				for (;cookieo->id!=0L;
						(*cookie++)=(*cookieo++));	
				cookie->id=0L;
				cookie->val=cookieo->val+n+1l;
			}
			else
				return(-1);
		}

		/* Cookie eintragen */
		jarsize=cookie->val;
		cookie->id=cid;
		cookie++->val=cval;
		cookie->id=0L;
		cookie->val=jarsize;
		return(1);
	}
	else
		return(0);
}

int			find_cookie(long cid, long *cval)
{ /* Sucht den Cookie (cid) und liefert dessen Wert in cval */

  /* Liefert 1, falls der Cookie gefunden wurde, sonst 0 */
  
	COOKIE	*cookie;

	Supexec(jaradres);
	cookie=jar_addres;
		
	if (!cookie)
		return(0);
		
	for(;((cookie->id)&&(cookie->id!=cid));cookie++);

	/* cookie zeigt auf gesuchten Cookie oder Nullcookie */

	if (!cookie->id)
		return(0);
	else
	{
		*cval=cookie->val;
		return(1);
	}
}

int			search_cookie(long n, long *cid, long *cval)
{ /* Sucht den Cookie-Eintrag Nummer n */

	/* Liefert die Anzahl der installierten Cookies (0=kein Jar oder */
	/* kein Cookie installiert) */
	/* Falls Cookies installiert sind und n<=Anzahl ist, wird in cid */
	/* und cval der Cookie-Eintrag zurÅckgeliefert */

	COOKIE	*cookie;
	int			ncookie=0, found=0;
	
	Supexec(jaradres);
	cookie=jar_addres;
	
		
	if (!cookie)
		return(0);
		
	for(;(cookie->id);cookie++,ncookie++)
	{
		if (ncookie==n)
		{ /* GewÅnschter Eintrag */
			*cid=cookie->id;
			*cval=cookie->val;
			found=1;
		}
	}

	/* cookie zeigt auf Nullcookie */
	
	if (!found)
	{
		*cid=0l;
		*cval=0l;
	}
	return(ncookie);

}
int			kill_cookie(long cid)
{ /* Lîscht den Cookie (cid) */

  /* Liefert 1, wenn der Cookie gelîscht wurde, sonst 0 (nicht */
  /* gefunden */

	COOKIE	*cookie, *cookieo;
	

	Supexec(jaradres);
	cookie=jar_addres;
	
	if (!cookie) /* Kein Cookie-Jar vorhanden */
		return(0);

	for(;((cookie->id)&&(cookie->id!=cid));cookie++);
	/* cookie zeigt auf zu lîschenden Cookie oder Nullcookie */

	if(cookie->id)
	{ /* Cookie lîschen, also alle weiteren zurÅckkopieren */
		cookieo=cookie;
		cookie++;
		do
		{
			(*cookieo++)=(*cookie++);
		}while(cookieo->id);
		/* Gelîscht */
		return(1);
	}
	else /* Nicht gefunden */
		return(0);
	
}

COOKIE *inst_jar(long n)
{
	COOKIE *cookie;
	
	cookie=Malloc(sizeof(COOKIE)*n);
	if (cookie)
	{
		Supexec(jaradres);
		cookie=jar_addres;

		cookie->id=0l;
		cookie->val=n;
		return(cookie);
	}
	else
		return(NULL);
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
/* Vektor Funktionen */
/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/

int vector(int offset, long xbid, int del)
{
	/* Sucht den XBRA-Eintrag xbid */
	/* im KBDVBASE-Vektor Nummer 'offset' */
	/* falls offset <=32 ist */
	/* sonst wird der GEMDOS-Vektor 'offset' untersucht*/
	/* Falls del=0 passiert nix, sonst wird der Vektor ausgehÑngt */
	
	/* Falls gefunden wird 1, sonst 0 geliefert */
	
	KBDVBASE			*mybase;
	XBRA					*check;
	long					*origin;
	char					nofound, nolost, count;
	const long		xbconst=0x58425241l; /*XBRA*/
	
	nofound=1;
	nolost=1;
	count=0;
	
	if (offset < 33)
	{	/* Kbdvbase Zeiger zurÅck */
		mybase=Kbdvbase();
		origin=(long*)((long)(mybase)+offset); /* indirekte Adresse */
		check=(XBRA*)(*origin-12);
	}
	else
	{	/* Gemdos Vektor zurÅck */
		origin=(long*)(Setexc(offset,(void(*)()) -1L)); /* Achtung-direkte Adresse */
		check=(XBRA*)((long)(origin)-12);
	}
	do
	{
		if( xbconst==*((long*) &(check->xb_magic[0])) )
		{
			if( xbid== *((long*)&(check->xb_id[0])) )
			{ /* Vektor gefunden, lîschen? */
				if (del)
				{
					if ((offset < 33) || (count))
						*origin=check->xb_oldvec;
					else
						Setexc(offset, (void(*)())(check->xb_oldvec));
				}
				nofound=0;
			}
			else
			{
				origin=(long*)((long)(check)+8);
				check=(XBRA*)(*origin-12);
				count++;
			}
		}
		else
		{ /* Eintrag kein XBRA */
			nolost=0;
		}
	}while(nofound && nolost);
	if(nofound)
		return(0);
	else
		return(1);
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
/* Ausgabe Funktionen */
/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/

void show(int zahl)
{ /* Gibt oben links die Zahl (zahl) aus */

	char *txt;
	txt=(char*)calloc(40,sizeof(char));

	itoa(zahl, txt, 10);
	strcat(txt, " ");
	Cur_home();
	puts(txt);
	
	free(txt);
}

void showl(long zahl)
{ /* Gibt oben links die Zahl (zahl) aus */

	char *txt;
	txt=(char*)calloc(60,sizeof(char));

	ltoa(zahl, txt, 10);
	strcat(txt, " ");
	Cur_home();
	puts(txt);
	
	free(txt);
}

void showlxy(int x, int y, long zahl)
{ /* Gibt an x, y die Zahl (zahl) aus */

	char *txt;
	txt=(char*)calloc(60,sizeof(char));

	ltoa(zahl, txt, 10);
	strcat(txt, " ");
	Goto_pos(y, x);
	puts(txt);
	
	free(txt);
}

void showf(double zahl)
{ /* Gibt oben links die float-Zahl aus */
	
	char	*txt, *numb;
	int		dec, sign;
	
	txt=(char*)calloc(40, sizeof(char));
	numb=(char*)calloc(14, sizeof(char));
	
	ftoa(&zahl, numb, 10, 1, &dec, &sign);
	if (dec > 0)
	{
		strncpy(txt, numb, dec);
		strcat(txt, ".");
		strcat(txt, strocpy(numb, numb, dec));
	}
	else
	{
		strcpy(txt,"0.");
		while (dec < 0)
		{
			strcat(txt, "0");
			dec++;
		}
		strcat(txt, numb);
	}
	Cur_home();
	puts(txt);

	free(numb);
	free(txt);		
}

void showxy(int x, int y, int zahl)
{ /* Gibt an der Stelle x,y die Zahl (zahl) aus */
	/* ZÑhlung beginnt bei 0 */
	
	char *txt;
	txt=(char*)calloc(40,sizeof(char));

	itoa(zahl, txt, 10);
	strcat(txt, " ");
	Goto_pos(y, x);
	puts(txt);
	
	free(txt);
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
/* Screen Saver Funktionen */
/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/

int scrsvr(void)
{
/* Liefert 1, wenn Bildschirmschoner aktiv */
/* sonst 0 (auch wenn kein Cookie da) */

	INFOXSSI	*cvalue;

	/* XSSI-Cookie suchen */
	/* 0x58535349l = XSSI */
	
	if (find_cookie(0x58535349l,(long *) &cvalue))
	{/* Schoner ist da */
		if (cvalue->save_stat)
			return (1);
		else
			return (0);
	}
	else
		return (0);
}

/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
/* String Funktionen */
/*---------------------------------------------------------------*/
/*---------------------------------------------------------------*/
char *strocpy(char *dest, char *src, long offset)
{/* Kopiert nach Zeichen offset (beginnt bei 0!) src in dest */
 /* HÑngt \0 an dest an */
	long a;
	
	if (offset < 0)
		offset=0;
		
	a=0;
	/* PrÅfen, ob src vorher aufhîrt */
	while ((src[a]) && (a < offset))
		a++;
	/* Kopieren */	
	if (a == offset)
	{
		a=0;
		while (src[offset])
		{
			dest[a]=src[offset];
			a++;
			offset++;
		}
	}
	else
		a=0;
		
	dest[a]=0;
	return (dest);
}

char *strmid(char *dest, char *src, long offset, long len)
{/* Kopiert ab Zeichen offset (beginnt bei 1!) src in dest */
 /* Dabei werden maximal len Zeichen kopiert. Falls src weniger */
 /* als offset+len Zeichen enthÑlt werden 0-Zeichen eingefÅgt */
 /* HÑngt \0 an dest an */

	long a;
	
	if (offset < 1)
		offset=1;
	if (len < 0)
		len=0;
		
	a=0;
	/* PrÅfen, ob src vorher aufhîrt */
	while ((src[a] != 0) && (a < offset))
		a++;
	if (a == offset)
	{
		a=0;
		while (src[offset-1] && (a < len))
		{
			dest[a]=src[offset-1];
			a++;
			offset++;
		}
		
		while (a < len)
		{
			dest[a]=0;
			a++;
		}
	}
	else
		a=0;
		
	dest[a]=0;
	
	return (dest);
}

/*---------------------------------------------------------------*/
/* Fenster Funktionen */
/*---------------------------------------------------------------*/
int	rc_intersect(GRECT *p1, GRECT *p2)
{ /* SchnittflÑche zweier Rechtecke, p2 wird mit SchnittflÑche */
  /* Åberschrieben, 1=Schnitt, 0=kein Schnitt */
  
	int tx, ty, tw, th;
	
	tw=min(p2->g_x+p2->g_w, p1->g_x+p1->g_w);
	th=min(p2->g_y+p2->g_h, p1->g_y+p1->g_h);
	tx=max(p2->g_x, p1->g_x);
	ty=max(p2->g_y, p1->g_y);
	p2->g_x=tx;
	p2->g_y=ty;
	p2->g_w=tw-tx;
	p2->g_h=th-ty;
	return((tw > tx) && (th > ty));
}

int min(int a, int b)
{
	if (a < b)
		return(a);
	else
		return(b);
}
long lmin(long a, long b)
{
	if (a < b)
		return(a);
	else
		return(b);
}

int max(int a, int b)
{
	if (a > b)
		return(a);
	else
		return(b);
}
long lmax(long a, long b)
{
	if (a > b)
		return(a);
	else
		return(b);
}

void	w_init(WINDOW *win)
{	/* Setzt Default-Werte und Routinen fÅr das Fenster */

	int x, y, w, h;
	
	win->whandle=-1;
	
	win->open=0;
	win->full=0;
	
	win->dialog=0;
	win->text=0;
	win->show=0;
		
	win->amode=ARSYS;
	win->hpos=0;
	win->vpos=0;
	win->hsiz=1000;
	win->vsiz=1000;
	win->hstep=0;
	win->vstep=0;
	win->hpage=0;
	win->vpage=0;
	
	win->do_align=0;
	win->xa=0;
	win->xo=0;
	win->ya=0;
	win->yo=0;
	
	win->rmode=RDARROW;
	/* Fenster-Routinen setzen */
	win->userdraw=noredraw;
	win->suserdraw=nosredraw;
	win->usercalc=nofunction;
	
	win->redraw=redraw;
	win->topped=topped;
	win->closed=closed;
	win->fulled=fulled;
	win->arrowed=arrowed;
	win->hslid=hslid;
	win->vslid=vslid;
	win->sized=sized;
	win->moved=moved;
	win->untopped=untopped;
	win->ontop=ontop;
	win->backdrop=backdrop;
	
	wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
	win->wx=win->mx=x-w; /* Damit man auch nach links schieben kann*/
	win->wy=win->my=y;
	win->ww=win->mw=w;
	win->wh=win->mh=h;
	
	win->nw=40;
	win->nh=40;
}

int		w_make(WINDOW *win)
{	/* Erzeugt Fenster und setzt defs */
	/* Return 1=OK, 0=Fehler */

	int	ret, a;
	
	ret=wind_create(win->kind, win->mx, win->my, win->mw, win->mh);
	if (ret>=0)
	{	/* Fenster-Werte setzen */
		win->whandle=ret;
/*		if(!wind_set(ret, WF_CURRXYWH, win->wx, win->wy, win->ww, win->wh))*/
/*			return(0);*/
		if (win->kind & NAME)
		{
			if(!wind_set(ret, WF_NAME, (int)( ((long)(win->name))>>16),(int)((long)(win->name) & 0xffffl)  ,0,0))
				return(0);
		}
		if (win->kind & INFO)
		{
			if(!wind_set(ret, WF_INFO, (int)( ((long)(win->info))>>16),(int)((long)(win->info) & 0xffffl)  ,0,0))
				return(0);
		}
		if (win->kind & HSLIDE)
		{
			if(!wind_set(ret, WF_HSLIDE, win->hpos,0,0,0))
				return(0);
			if(!wind_set(ret, WF_HSLSIZE, win->hsiz,0,0,0))
				return(0);
		}
		if (win->kind & VSLIDE)
		{
			if(!wind_set(ret, WF_VSLIDE, win->vpos,0,0,0))
				return(0);
			if(!wind_set(ret, WF_VSLSIZE, win->vsiz,0,0,0))
				return(0);
		}

		for(a=0; a < MAX_WIN; ++a)
		{
			if(winpoint[a]==NULL)
			{
				winpoint[a]=win;
				return(1);
			}
		}
	}

	return(0);
}

int		w_open(WINDOW *win)
{ /* ôffnet Fenster mit wx,wy,ww,wh */
	w_align(win);
	if((win->whandle != -1) && wind_open(win->whandle, win->wx, win->wy, win->ww, win->wh))
	{
		win->open=1;
		va_open(win->whandle);
		return(1);
	}
	else
	{
		win->open=0;
		return(0);
	}
}

void	w_top(WINDOW *win)
{ /* Topped das Fenster */

	int	sbuf[16];

	if (win->open)
	{	
		sbuf[0]=WM_TOPPED;
		sbuf[1]=ap_id;
		sbuf[2]=0;
		sbuf[3]=win->whandle;
	
		appl_write(ap_id, 16, sbuf);
	}
}

int	w_istop(WINDOW *win)
{ /* PrÅft, ob das Fenster oberstes ist */

	int wt, dum;
	
	wind_get(0,WF_TOP, &wt, &dum, &dum, &dum);

	return(wt == win->whandle);
}

int		w_close(WINDOW *win)
{	/* Schlieût das Fenster */
	if ((win->whandle != -1) && wind_close(win->whandle))
	{
		win->open=0;
		va_close(win->whandle);
		return(1);
	}
	else
		return(0);
}

int		w_kill(WINDOW *win)
{ /* Lîscht Fenster und schlieût vorher, falls offen */
	int a;
	
	for(a=0; a < MAX_WIN; ++a)
	{
		if(winpoint[a]==win)
			winpoint[a]=NULL;
	}
	
	if (win->open)
	{
		if (wind_close(win->whandle))
		{
			win->open=0;
			while(w_timer(100,0) != MU_TIMER);
			va_close(win->whandle);
		}
		else
			return(0);
	}
	
	if ((win->whandle != -1) && wind_delete(win->whandle))
	{
		win->whandle=-1;
		return(1);
	}
	else
		return(0);
}

int		w_timer(int lo, int hi)
{	/* Wartet lo,hi time und liefert den Event zurÅck */
	/* Falls evnt_mesag auftritt, wird w_dispatch */
	/* gerufen. Damit wird die Message-queue geleert */
	
	int	evnt, dum;
	
	evnt=evnt_multi(MU_MESAG|MU_TIMER,
									0,0,0,0,0,0,0,0,0,0,0,0,0,
									pbuf,lo,hi,&dum,&dum,&dum,&dum,&dum,&dum);
	
	if (evnt & MU_MESAG)
		w_dispatch(pbuf);
		
	return(evnt);
}

void	w_redraw(WINDOW *win, int x, int y, int w, int h, int mode)
{	/* Liest Rechteck-Liste aus, clipped mit xywh und Screen */
	/* setzt CLIP und ruft userdraw. Falls als Redraw-Force */
	/* sollte x,y,w,h auf Screen oder Window Grîûe gesetzt werden */
	/* Wenn mode=1 ist darf special-Redraw verwendet werden */
	/* Wenn mode=2 ist soll special-Redraw verwendet werden */
	/* (wird z.B. von w_objc_draw verwendet) */

	GRECT scr, rect, todo, mouse;
	int		xywh[4], ms, d;
	todo.g_x=x;
	todo.g_y=y;
	todo.g_w=w;
	todo.g_h=h;

	w_calc(win);
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse))
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;

	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* Arbeits-Bereich */
	w_calc(win);
	/* erstes Redraw-Rechteck */
	wind_get(win->whandle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enthÑlt jetzt */
				/* SchnittflÑche */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;
				if (handle > -1)
					vs_clip(handle, 1, xywh);
				if (whandle > -1)
					vs_clip(whandle, 1, xywh);
				if ( ((mode) && 
						  (rect.g_x == win->ax) && (rect.g_y == win->ay) && (rect.g_w == win->aw) && (rect.g_h == win->ah))
						  || (mode == 2))
					win->suserdraw(win, rect.g_x, rect.g_y, rect.g_w, rect.g_h, mode);
				else
					win->userdraw(win, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
				if (whandle > -1)
					vs_clip(whandle, 0, xywh);
				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(win->whandle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
}

void	w_clear(int x, int y, int w, int h)
{
	int c[4];
	c[0]=x;
	c[1]=y;
	c[2]=w+c[0]-1;
	c[3]=h+c[1]-1;
	vsf_interior( whandle, 0);
	vsf_color( whandle, 1	);
	vsf_perimeter( whandle, 0);
	v_bar( whandle, c);
}

void	w_set(WINDOW *win, int atrib)
{ /* éndert die in 'atrib' (=kind)*/
	/* gesetzten werte per wind_set */
	/* zusÑtzlich zu den kinds			*/
	/* gibts CURR (Ñndert POS & SIZ)*/
	
	if (win->whandle != -1)
	{
		if (atrib & CURR)
			wind_set(win->whandle, WF_CURRXYWH, win->wx, win->wy, win->ww, win->wh);
		if (atrib & NAME)
			wind_set(win->whandle, WF_NAME, (int)( ((long)(win->name))>>16),(int)((long)(win->name) & 0xffffl)  ,0,0);
		if (atrib & INFO)
			wind_set(win->whandle, WF_INFO, (int)( ((long)(win->info))>>16),(int)((long)(win->info) & 0xffffl)  ,0,0);
		if (atrib & HSLIDE)
		{
			wind_set(win->whandle, WF_HSLIDE, win->hpos,0,0,0);
			wind_set(win->whandle, WF_HSLSIZE, win->hsiz,0,0,0);
		}
		if (atrib & VSLIDE)
		{
			wind_set(win->whandle, WF_VSLIDE, win->vpos,0,0,0);
			wind_set(win->whandle, WF_VSLSIZE, win->vsiz,0,0,0);
		}
	}
}

void	w_get(WINDOW *win)
{ /* Setz wx,wy,ww,wh hpos,vpos,hsiz,vsiz*/
	int w1, w2, w3, w4;

	wind_get(win->whandle, WF_CURRXYWH, &w1, &w2, &w3, &w4);
	win->wx=w1;
	win->wy=w2;
	win->ww=w3;
	win->wh=w4;
	if(win->kind & HSLIDE)
	{
		wind_get(win->whandle, WF_HSLIDE, &w1,0,0,0);
		win->hpos=w1;
		wind_get(win->whandle, WF_HSLSIZE, &w1,0,0,0);
		win->hsiz=w1;
	}
	if(win->kind & VSLIDE)
	{
		wind_get(win->whandle, WF_VSLIDE, &w1,0,0,0);
		win->vpos=w1;
		wind_get(win->whandle, WF_VSLSIZE, &w1,0,0,0);
		win->vsiz=w1;
	}
}

void	w_calc(WINDOW *win)
{
	wind_calc(WC_WORK, win->kind, win->wx, win->wy, win->ww, win->wh, &win->ax, &win->ay, &win->aw, &win->ah);
}

void	w_wcalc(WINDOW *win)
{
	wind_calc(WC_BORDER, win->kind, win->ax, win->ay, win->aw, win->ah, &win->wx, &win->wy, &win->ww, &win->wh);
}

void	w_align(WINDOW *win)
{
	int	x, y, w, h;
	
	w_calc(win);
	x=win->ax;
	y=win->ay;
	w=win->aw;
	h=win->ah;
	if (win->xa)
	{
		if (win->do_align & MOVE)
			x=((x + win->xo)/win->xa)*win->xa-win->xo;
		if (win->do_align & SIZE)
			w=((w - win->xp-win->xo)/win->xa)*win->xa+win->xp+win->xo;
		wind_calc(WC_BORDER, win->kind, x, y, w, h, &win->wx, &win->wy, &win->ww, &win->wh);
		
	}
	if (win->ya)
	{
		if (win->do_align & MOVE)
			y=((y + win->yo)/win->ya)*win->ya-win->yo;
		if (win->do_align & SIZE)
			h=((h - win->yp-win->yo)/win->ya)*win->ya+win->yp+win->yo;
		wind_calc(WC_BORDER, win->kind, x, y, w, h, &win->wx, &win->wy, &win->ww, &win->wh);
		
	}
	if (win->wx < win->mx)
		win->wx=win->mx;
	if (win->wy < win->my)
		win->wy=win->my;
	if (win->ww > win->mw)
		win->ww=win->mw;
	if (win->ww < win->nw)
		win->ww=win->nw;
	if (win->wh > win->mh)
		win->wh=win->mh;
	if (win->wh < win->nh)
		win->wh=win->nh;
	
}

int	w_dispatch(int *mbuf)
{ /* Ruft evtl. eine der folgenden Fn */
	int	a, r=0;
	WINDOW	*win;

	if(pbuf[0] == MN_SELECTED)
	{
		if(ap_info.menu)
			ap_info.menu(pbuf[3], pbuf[4]);
		return(-1);
	}
			
	win=NULL;
	for (a=0; a<MAX_WIN; a++)
	{
		if(winpoint[a])
			if (mbuf[3] == winpoint[a]->whandle)
			{
				win=winpoint[a];
				break;
			}
	}

	if (win != NULL)
	{
		r=-1;
		switch(mbuf[0])
		{
			case WM_REDRAW:
				if(win->redraw)	win->redraw(win, mbuf);
			break;

			case WM_TOPPED:
				if(win->topped) win->topped(win);
			break;

			case WM_ONTOP:
			case WM_NEWTOP:
				if(win->ontop) win->ontop(win);
			break;

			case WM_M_BDROPPED:
			case WM_BOTTOMED:
				if (win->kind & BACKDROP)
					if(win->backdrop) win->backdrop(win);
			break;
						
			case WM_CLOSED:
				if (win->kind & CLOSE)
					if(win->closed) win->closed(win);
			break;
			
			case WM_FULLED:
				if (win->kind & FULL)
					if(win->fulled) win->fulled(win);
			break;
			
			case WM_ARROWED:
				if (win->kind & (UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE))
					if(win->arrowed) win->arrowed(win, mbuf);
			break;
			
			case WM_HSLID:
				if (win->kind & HSLIDE)
					if(win->hslid) win->hslid(win, mbuf);
			break;

			case WM_VSLID:
				if(win->kind & VSLIDE)
					if(win->vslid) win->vslid(win, mbuf);
			break;

			case WM_SIZED:
				if(win->kind & SIZE)
					if(win->sized) win->sized(win, mbuf);
			break;
			
			case WM_MOVED:
				if(win->moved) win->moved(win, mbuf);
			break;

			case WM_UNTOPPED:
				if(win->untopped) win->untopped(win);
			break;

			default:
				if (ap_info.gunknown)
					ap_info.gunknown(mbuf);
		}
	}/* endif win != NULL */
	else if (ap_info.gunknown)
	{
		ap_info.gunknown(mbuf);
		r=-1;
	}

	return(r);
}

void	s_redraw(WINDOW *win)
{
	int	sbuf[16];

	if((win->whandle > -1)	&& (win->open))
	{
		sbuf[0]=WM_REDRAW;
		sbuf[1]=ap_id;
		sbuf[2]=0;
		sbuf[3]=win->whandle;
		sbuf[4]=win->wx;
		sbuf[5]=win->wy;
		sbuf[6]=win->ww;
		sbuf[7]=win->wh;
	
		appl_write(ap_id, 16, sbuf);
	}
}

void	redraw(WINDOW *win, int *mbuf)
{ /*WM_REDRAW Fn */
	if (win->open)
		w_redraw(win, mbuf[4], mbuf[5], mbuf[6], mbuf[7], 0);
}

void	topped(WINDOW *win)
{ /*WM_TOPPED Fn */
	if (globalmodal && (globalhandle != win->whandle))
	{	/*Bell();*/ }
	else
		wind_set(win->whandle, WF_TOP,0,0,0,0);
}

void	closed(WINDOW *win)
{ /*WM_CLOSED Fn */
	if (globalmodal)
		Bell();
	else
	{
		wind_close(win->whandle);
		win->open=0;
	}
}

void	fulled(WINDOW *win)
{ /*WM_FULLED Fn */
	if (win->full)
	{
		win->full=0;
		win->wx=win->fx;
		win->wy=win->fy;
		win->ww=win->fw;
		win->wh=win->fh;
	}
	else
	{
		wind_get(win->whandle, WF_CURRXYWH, &(win->fx), &(win->fy), &(win->fw), &(win->fh));
		if (win->mx > -1)
		{ /* Falls Anwender was verÑndert hat, ansonsten steht in mx */
			/* nÑmlich -sx, damit links rausschieben mîglich ist */
			win->wx=win->mx;
			win->wy=win->my;
			win->ww=win->mw;
			win->wh=win->mh;
		}
		else /* Sonst Screensize nehmen */
			wind_get(0, WF_WORKXYWH, &(win->wx), &(win->wy), &(win->ww), &(win->wh));
		win->full=1;
	}
	w_align(win);
	if (win->amode & ARCALC)
		win->usercalc(win);

	wind_set(win->whandle, WF_CURRXYWH, win->wx, win->wy, win->ww, win->wh);
}

void	arrowed(WINDOW *win, int *mbuf)
{ /*WM_ARROWED Fn */
	int t,d, specl, oh, ov, ouh, ouv;
	float	factor;
	
	oh=win->hpos;
	ov=win->vpos;
	ouh=win->uhpos;
	ouv=win->uvpos;
	
	specl=0;
	switch(mbuf[4])
	{
		case WA_UPPAGE:
		{
			if (win->amode & ARUSER)
				win->uvpos-=win->uvpage;
			if (win->amode & ARSYS)
				win->vpos-=win->vpage;
		}
		break;
		case WA_DNPAGE:
		{
			if (win->amode & ARUSER)
				win->uvpos+=win->uvpage;
			if (win->amode & ARSYS)
				win->vpos+=win->vpage;
		}
		break;
		case WA_UPLINE:
		{
			specl=1;
			if (win->amode & ARUSER)
				win->uvpos-=win->uvstep;
			if (win->amode & ARSYS)
				win->vpos-=win->vstep;
		}
		break;
		case WA_DNLINE:
		{
			specl=1;
			if (win->amode & ARUSER)
				win->uvpos+=win->uvstep;
			if (win->amode & ARSYS)
				win->vpos+=win->vstep;
		}
		break;
		case WA_LFPAGE:
		{
			if (win->amode & ARUSER)
				win->uhpos-=win->uhpage;
			if (win->amode & ARSYS)
				win->hpos-=win->hpage;
		}
		break;
		case WA_RTPAGE:
		{
			if (win->amode & ARUSER)
				win->uhpos+=win->uhpage;
			if (win->amode & ARSYS)
				win->hpos+=win->hpage;
		}
		break;
		case WA_LFLINE:
		{
			specl=1;
			if (win->amode & ARUSER)
				win->uhpos-=win->uhstep;
			if (win->amode & ARSYS)
				win->hpos-=win->hstep;
		}
		break;
		case WA_RTLINE:
		{
			specl=1;
			if (win->amode & ARUSER)
				win->uhpos+=win->uhstep;
			if (win->amode & ARSYS)
				win->hpos+=win->hstep;
		}
		break;
	}/* endswitch */

	if (win->amode & ARUSER)
	{	 /* Werte prÅfen */
		if (win->uhpos < win->uhmin)
			win->uhpos=win->uhmin;
		if (win->uhpos > win->uhmax)
			win->uhpos=win->uhmax;
		if (win->uvpos < win->uvmin)
			win->uvpos=win->uvmin;
		if (win->uvpos > win->uvmax)
			win->uvpos=win->uvmax;
		/* Werte umrechnen */
		factor=(float)(1000/(float)(win->uvmax-win->uvmin));
		win->vpos=(int)((float)(win->uvpos*factor));
		factor=(float)(1000/(float)(win->uhmax-win->uhmin));
		win->hpos=(int)((float)(win->uhpos*factor));
	}

	if (win->hpos < 0)
		win->hpos=0;
	if (win->hpos > 1000)
		win->hpos=1000;
	if (win->vpos < 0)
		win->vpos=0;
	if (win->vpos > 1000)
		win->vpos=1000;
	
	if ((oh != win->hpos) || (ov != win->vpos))
	{
		wind_set(win->whandle, WF_HSLIDE, win->hpos,0,0,0);
		wind_set(win->whandle, WF_VSLIDE, win->vpos,0,0,0);
		
		if (
				(!(win->amode & ARUSER)) || 
				((win->amode & ARUSER) && ((win->uhpos!=ouh)||(win->uvpos!=ouv)))
			 )
		{
			if (specl && (win->rmode & RDSPECL))
			{
				wind_get(0, WF_TOP, &t, &d, &d, &d);
				if(t == win->whandle)
					w_redraw(win, win->wx, win->wy, win->ww, win->wh, mbuf[4]);
				else
					s_redraw(win);
			}
			else if ((win->rmode) & RDARROW)
				s_redraw(win);
		}
	}
}

void	hslid(WINDOW *win, int *mbuf)
{ /*WM_HSLID Fn */
	float	factor;
	int		ou, t, d, dir, specl;
	
	ou=win->uhpos;
	
	if (win->hpos != mbuf[4])
	{
		win->hpos=mbuf[4];
		if (win->amode & ARUSER)
		{
			factor=(float)((float)(win->uhmax-win->uhmin)/(float)1000);
			win->uhpos=(int)((float)((float)(win->hpos)*factor+0.001));
			factor=(float)(1000/(float)(win->uhmax-win->uhmin));
			win->hpos=(int)((float)(win->uhpos*factor));
			specl=0;
			if (win->uhpos == ou-win->uhstep)
			{
				specl=1;
				dir=WA_LFLINE;
			}
			else if (win->uhpos == ou+win->uhstep)
			{
				specl=1;
				dir=WA_RTLINE;
			}
		}
		wind_set(win->whandle, WF_HSLIDE, win->hpos,0,0,0);
		
		if ((win->rmode & RDARROW) && (ou != win->uhpos))
		{
			if (specl && (win->rmode & RDSPECL))
			{
				wind_get(0, WF_TOP, &t, &d, &d, &d);
				if(t == win->whandle)
					w_redraw(win, win->wx, win->wy, win->ww, win->wh, dir);
				else
					s_redraw(win);
			}
			else
				s_redraw(win);
		}
	}
}

void	vslid(WINDOW *win, int *mbuf)
{ /*WM_VSLID Fn */
	float	factor;
	int		ou, t, d, dir, specl;
	
	ou=win->uvpos;
	
	if (win->vpos != mbuf[4])
	{
		win->vpos=mbuf[4];
		if (win->amode & ARUSER)
		{
			factor=(float)((float)(win->uvmax-win->uvmin)/(float)1000);
			win->uvpos=(int)((float)((float)(win->vpos)*factor+0.001));
			factor=(float)(1000/(float)(win->uvmax-win->uvmin));
			win->vpos=(int)((float)(win->uvpos*factor));
			specl=0;
			if (win->uvpos == ou-win->uvstep)
			{
				specl=1;
				dir=WA_UPLINE;
			}
			else if (win->uvpos == ou+win->uvstep)
			{
				specl=1;
				dir=WA_DNLINE;
			}
		}
		wind_set(win->whandle, WF_VSLIDE, win->vpos,0,0,0);

		if ((win->rmode & RDARROW) && (ou != win->uvpos))
		{
			if (specl && (win->rmode & RDSPECL))
			{
				wind_get(0, WF_TOP, &t, &d, &d, &d);
				if(t == win->whandle)
					w_redraw(win, win->wx, win->wy, win->ww, win->wh, dir);
				else
					s_redraw(win);
			}
			else
				s_redraw(win);
		}
	}
}

void	sized(WINDOW *win, int *mbuf)
{ /*WM_SIZED Fn */
	
	int	dnsiz, x, y, w, h;
	/* Alte Werte merken */
	x=win->wx;
	y=win->wy;
	w=win->ww;
	h=win->wh;

	win->full=0;

	/* Werte mit max. und min. Werten clippen */
	win->wx=mbuf[4];
	win->wy=mbuf[5];	
	win->ww=mbuf[6];
	win->wh=mbuf[7];

	/* Werte rastern */
	if (win->do_align & SIZE)
		w_align(win);

	if (win->amode & ARCALC)
		win->usercalc(win);

	/* Werte setzen */
	if ((x!=win->wx)||(y!=win->wy)||(w!=win->ww)||(h!=win->wh))
	{
		wind_set(win->whandle, WF_CURRXYWH, win->wx, win->wy, win->ww, win->wh);

		/* Downsized prÅfen */
		if ((win->wh <= h) && (win->ww <= w))
			dnsiz=1;
		else
			dnsiz=0;

		if ((win->rmode & RDDNSIZED) && dnsiz)
			s_redraw(win);
		if ((win->rmode & RDUPSIZED) && !dnsiz)
			s_redraw(win);
	}
	
}

void	moved(WINDOW *win, int *mbuf)
{ /*WM_MOVED Fn */
	int x, y, w, h;
	
	x=win->wx;
	y=win->wy;
	w=win->ww;
	h=win->wh;
	
	win->wx=mbuf[4];
	win->wy=mbuf[5];
	win->ww=mbuf[6];
	win->wh=mbuf[7];
	if (win->do_align & MOVE)
		w_align(win);
	if ((x!=win->wx)||(y!=win->wy)||(w!=win->ww)||(h!=win->wh))
		wind_set(win->whandle, WF_CURRXYWH, win->wx, win->wy, win->ww, win->wh);
}

void	untopped(WINDOW *win)
{ /*WM_UNTOPPED Fn */
	nofunction(win);
}

void	ontop(WINDOW *win)
{	/*WM_ONTOP Fn */
	if (globalmodal && (globalhandle != win->whandle))
	{
/*		Bell();*/
		wind_set(globalhandle, WF_TOP,0,0,0,0);
	}
}

void	backdrop(WINDOW *win)
{ /* WM_BOTTOMED, WM_M_BDROPPED Fn */
	wind_set(win->whandle, WF_BOTTOM, 0, 0, 0, 0);
}

void	nofunction(WINDOW *win)
{ /* FÅr vom user nicht belegte Funktionen */
}
void	noredraw(WINDOW *win, int x, int y, int w, int h)
{
}
void	nosredraw(WINDOW *win, int x, int y, int w, int h, int m)
{
}

/*---------------------------------------------------------------*/
/* Text-Fenster Funktionen */
/*---------------------------------------------------------------*/


int		lcount(char **text, int *longest)
{
	int			a;
	size_t	lng;
	
	*longest=0;
	a=0;
	
	while ((lng=strlen(text[a]))!=0)
	{
		if (lng > *longest)
			*longest=(int)lng;
		a++;
	}
	return(a);
}

int		w_text(WINDOW *win)
{	/* Erzeugt ein Textfenster */
	int dum;
	win->tinfo->lines=
		lcount(win->tinfo->text, &(win->tinfo->longest));
	vst_alignment(whandle, 0, 3, &dum, &dum);
	win->kind=MOVE|NAME|INFO|SIZE|CLOSE|FULL
						|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|BACKDROP;
	win->info="Line: 1234  of: 1234";
	win->text=1;
	win->dialog=0;
	
	win->wx=50;
	win->wy=50;
	win->ww=200;
	win->wh=150;
	
	win->xa=wpwchar;
	win->xo=2;
	win->xp=4;
	win->ya=wphchar;
	win->yo=2;
	win->yp=2;
	w_align(win);
	win->rmode=RDARROW|RDUPSIZED|RDDNSIZED|RDSPECL;
	win->suserdraw=t_sredraw;
	win->userdraw=t_redraw;
	win->usercalc=t_calc;

	win->vpos=0;
	win->hpos=0;
	win->uvstep=1;
	win->uhstep=1;
	win->uvmin=0;
	win->uhmin=0;
	win->amode=ARUSER|ARCALC;
	t_calc(win);
		
	return(w_make(win));
}

void	t_redraw(WINDOW *win, int x, int y, int w, int h)
{ /* Redraw-Routine fÅr TEXT */

	GRECT	r1, r2;
	int 	sline, srow, a, b, c, d;
	char	*numb="1234", *inf="Line: 1234  of: 1234", line[256];

	vsf_interior( whandle, 0);
	vsf_color( whandle, 1	);
	vsf_perimeter( whandle, 0);
	vswr_mode(whandle,MD_REPLACE);

	w_clear(x, y, w, h);
  
  r1.g_x=x; r1.g_y=y; r1.g_w=w; r1.g_h=h;
  r2.g_x=win->ax+win->xo; r2.g_y=win->ay+win->yo;
  r2.g_w=win->aw-win->xo-win->xp;
  r2.g_h=win->ah-win->yo-win->yp;
  if (rc_intersect(&r1, &r2))
  {
		sline=win->uvpos;
		srow=win->uhpos;
		a=(r2.g_y-win->ay-win->yo)/wphchar;
		b=(r2.g_y+r2.g_h-win->ay-win->yo-1)/wphchar;
		if (b+sline >= win->tinfo->lines)
			b=win->tinfo->lines-1;
		c=(r2.g_x-win->ax-win->xo)/wpwchar;
		d=(r2.g_x+r2.g_w-win->ax-win->xo-1)/wpwchar;
		if (d+srow > win->tinfo->longest)
			d=win->tinfo->longest;
			
		strcpy(inf, "Line:");
		itoa(sline+1, numb, 10);
		strcat(inf, numb);
		strcat(inf, "  of:");
		itoa(win->tinfo->lines, numb, 10);
		strcat(inf, numb);
		win->info=inf;
		
		for (; a<=b ; a++)
		{
			strmid(line, win->tinfo->text[a+sline], srow+1+c, d-c+1);
			v_gtext(whandle, win->ax+win->xo+wpwchar*c, win->ay+win->yo+wphchar*(a+1)-1,line);
		}
	}
	w_set(win, INFO);
	
}

void	t_sredraw(WINDOW *win, int x, int y, int w, int h, int dir)
{ /* Smart-Redraw */
	MFDB	src, dest;
	int		xy[8], rx, ry, rw, rh;

	vsf_interior( whandle, 0);
	vsf_color( whandle, 1	);
	vsf_perimeter( whandle, 0);
	vswr_mode(whandle,MD_REPLACE);
	
	src.fd_addr=NULL;
	dest.fd_addr=NULL;

	switch (dir)
	{
		case WA_UPLINE:
		{
			xy[0]=xy[4]=win->ax;
			xy[2]=xy[6]=win->ax+win->aw-1;
		
			xy[1]=win->ay;
			xy[3]=win->ay+win->ah-1-wphchar;
			xy[5]=xy[1]+wphchar;
			xy[7]=xy[3]+wphchar;
			ry=win->ay;
			rx=win->ax;
			rw=win->aw;
			rh=wphchar+win->yo;
		}
		break;
		case WA_DNLINE:
		{
			xy[0]=xy[4]=win->ax;
			xy[2]=xy[6]=win->ax+win->aw-1;
	
			xy[1]=win->ay+wphchar;
			xy[3]=win->ay+win->ah-1;
			xy[5]=xy[1]-wphchar;
			xy[7]=xy[3]-wphchar;
			ry=(win->yo+win->ay+win->ah-1)-(wphchar+win->yp+1);
			rx=win->ax;
			rw=win->aw;
			rh=wphchar+win->yp+1;
		}
		break;
		case WA_LFLINE:
		{
			xy[1]=xy[5]=win->ay;
			xy[3]=xy[7]=win->ay+win->ah-1;
			
			xy[0]=win->ax;
			xy[2]=win->ax+win->aw-1-wpwchar;
			xy[4]=xy[0]+wpwchar;
			xy[6]=xy[2]+wpwchar;
			rx=win->ax;
			ry=win->ay;
			rw=wpwchar+win->xo;
			rh=win->ah;
		}
		break;
		case WA_RTLINE:
		{
			xy[1]=xy[5]=win->ay;
			xy[3]=xy[7]=win->ay+win->ah-1;
			
			xy[0]=win->ax+wpwchar;
			xy[2]=win->ax+win->aw-1;
			xy[4]=xy[0]-wpwchar;
			xy[6]=xy[2]-wpwchar;
			rx=(win->xo+win->ax+win->aw-1)-(wpwchar+win->xp+1);
			ry=win->ay;
			rw=wpwchar+win->xp+1;
			rh=win->ah;
		}
		break;
	}/* endswitch */
	vro_cpyfm(whandle, S_ONLY, xy, &src, &dest);

	win->userdraw(win, rx, ry, rw, rh);
}

void	t_calc(WINDOW *win)
{ /* Berechnungs-Routine, liest uvpos und uhpos */
	/* Berechnet user-Grenzwerte aus aktueller Fenstergrîûe */
	/* und korrigiert die Systemslider-Werte */
	
	int 	lines, colums, maxdoc;
	long	mlines, mcolums;

	w_calc(win);

	lines=(win->ah-win->yo-win->yp)/wphchar;
	if ((win->ah-win->yo-win->yp) > wphchar*lines)
		lines=lines+1;
	maxdoc=win->tinfo->lines-lines;
	if (maxdoc < 1)
		maxdoc=0;

	win->uvpage=lines;
	win->uvmax=maxdoc;

	if (win->uvpos >= maxdoc)
		win->uvpos=maxdoc;

	win->vpos=(int)((float)((float)win->uvpos*(1000/(float)maxdoc)));
	
	mlines=lines;
	win->vsiz=(int)lmin(mlines*1000l/(long)win->tinfo->lines, 1000l);	
	w_set(win, VSLIDE);

	colums=(win->aw-win->xo-win->xp)/wpwchar;
	if ((win->aw-win->xo-win->xp) > wpwchar*colums)
		colums=colums+1;
	maxdoc=win->tinfo->longest-colums;
	if (maxdoc < 1)
		maxdoc=0;

	win->uhpage=colums;
	win->uhmax=maxdoc;

	if (win->uhpos >= maxdoc)
		win->uhpos=maxdoc;

	win->hpos=(int)((float)((float)win->uhpos*(1000/(float)maxdoc)));
	
	mcolums=colums;
	win->hsiz=(int)lmin(mcolums*1000/(long)win->tinfo->longest, 1000);	
	w_set(win, HSLIDE);
}

void	w_txchange(WINDOW *win)
{ /* Updatet bei TextÑnderung */
	win->tinfo->lines=lcount(win->tinfo->text, &(win->tinfo->longest));
	t_calc(win);
	if (win->open)
		s_redraw(win);
}

void w_txlinechange(WINDOW *win, int line)
{/* Updatet eine Zeile (ZÑhlung bei 0) bei TextÑnderung */
	int		 rx, ry, rw, rh;
	
	if(!win->open) return;
	if(line < win->uvpos) return;
	if(wphchar*(line-win->uvpos) > win->ah-win->yo-win->yp) return;
	
	ry=win->ay+win->yo+wphchar*(line-win->uvpos);
	rx=win->ax;
	rw=win->aw;
	rh=wphchar;
	w_redraw(win, rx,ry,rw,rh,0);
}

void	w_txhome(WINDOW *win)
{ /* Stellt Textfenster auf Pos 0/0 */
	w_txgoto(win, 0, 0);
}

void	w_txgoto(WINDOW *win, int x, int y)
{ /* Setzt die Textposition auf x, y */
	if((win->uhpos==x)&&(win->uvpos==y))
		return;	
	win->uhpos=x;
	win->uvpos=y;
	t_calc(win);
	if (win->open)
		s_redraw(win);
}

void	w_txmove(WINDOW *win)
{ /* Verschiebt das Textfenster an win->wx und win->wy */
	w_calc(win);
	w_align(win);
	win->usercalc(win);
	w_set(win, CURR);
	s_redraw(win);
}

void	w_txfit(WINDOW *win, int mode)
{ /* Passt die Fenstergrîûe an den Text an */
	int sx, sy, sw, sh, ox, oy, ow, oh;
	
	ox=win->wx;
	oy=win->wy;
	ow=win->ww;
	oh=win->wh;
	
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
	if (mode & T_HFIT)
	{
		win->aw=wpwchar*win->tinfo->longest+win->xo+win->xp+1;
		w_wcalc(win);
		if (win->ww > sw)
		{ /* Auf maximale Breite trimmen */
			win->ww=sw;
			w_calc(win);
		}
		if (win->wx+win->ww > sx+sw)
		{	/* DafÅr sorgen, daû alles sichtbar ist */
			win->wx=sx+sw-win->ww;
			w_calc(win);
		}
	}
	if (mode & T_VFIT)
	{
		win->ah=wphchar*win->tinfo->lines+win->yo+win->yp+1;
		w_wcalc(win);
		if (win->wh > sh)
		{ /* Auf maximale Hîhe trimmen */
			win->wh=sh;
			w_calc(win);
		}
		if (win->wy+win->wh > sy+sh)
		{	/* DafÅr sorgen, daû alles sichtbar ist */
			win->wy=sy+sh-win->wh;
			w_calc(win);
		}
	}
	w_align(win);
	win->usercalc(win);
	w_set(win, CURR);
	
	if (win->open)
	{
		if ((win->wx!=ox)||(win->wy!=oy)||(win->ww!=ow)||(win->wh!=oh))
			s_redraw(win);
	}
}

/*---------------------------------------------------------------*/
/* Dialog-Fenster Funktionen */
/*---------------------------------------------------------------*/
int check_layer(OBJECT *tree, int ob, int parent)
{/* -1=Found, not hidden, 1=Found, hidden, 0=not found */
	int	sob, ret;	

	sob=tree[parent].ob_head;
	do
	{
		if(tree[sob].ob_head > -1)
		{
			if((ret=check_layer(tree, ob, sob))!=0)
			{
				if(ret==1) return(1);
				/* Hidden here? */
				if(tree[parent].ob_flags & HIDETREE) return(1);
				return(-1);
			}
		}
		if(sob==ob)
		{
			if(tree[parent].ob_flags & HIDETREE) return(1);
			return(-1);
		}
		sob=tree[sob].ob_next;
	}while(sob > parent);
	return(0);
}

int check_hide_parent(OBJECT *tree, int ob)
{/* PrÅft, ob das Object oder einer der Parents HIDETREE gesetzt hat */
/* Return: Ja=1, Nein=0 */
	
	/* Object selbst prÅfen */
	if(tree[ob].ob_flags & HIDETREE) return(1);

	/* PrÅfen, ob ein Parent Hidetree gesetzt hat */
	if(tree[0].ob_head==-1) return(0);
	if(check_layer(tree, ob, 0)==1) return(1);
	return(0);
}

int ocheck_hide_parent(OBJECT *tree, int ob)
{/* PrÅft, ob das Object oder einer der Parents HIDETREE gesetzt hat */
/* Return: Ja=1, Nein=0 */
	int a;
	
	/* Object selbst prÅfen */
	if(tree[ob].ob_flags & HIDETREE) return(1);

	/* PrÅfen, ob ein Parent Hidetree gesetzt hat */
	while(tree[ob].ob_next > -1)
	{
		a=ob;
		do
		{
			ob=tree[ob].ob_next;
		}while(ob > a);
		/* Parent gefunden */
		if(tree[ob].ob_flags & HIDETREE) return(1);
	}
	return(0);
}
int o2check_hide_parent(OBJECT *tree, int ob)
{/* PrÅft, ob das Object oder einer der Parents HIDETREE gesetzt hat */
/* Return: Ja=1, Nein=0 */
/* Funktioniert nicht, weil das mit dem Grîûenvergleich fÅr
	Parent-Feststellung ein kalter ist. Objekt kann an gleicher
	Stelle liegen ohne Parent zu sein (s. Iconf-Rahmen) */
	
	int x, y, w, h, x2, y2, mob=ob;
	
	/* Object selbst prÅfen */
	if(tree[ob].ob_flags & HIDETREE) return(1);

	/* PrÅfen, ob ein Parent Hidetree gesetzt hat */
	while(tree[ob].ob_next > -1)
	{
		objc_offset(tree, ob, &x, &y);
		w=tree[ob].ob_width; h=tree[ob].ob_height;
		do
		{
			ob=tree[ob].ob_next;
			if(ob==-1) break;
			objc_offset(tree, ob, &x2, &y2);
		}while((ob > mob) || (x2 > x) || (y2 > y) || (x2+tree[ob].ob_width < x+w) || (y2+tree[ob].ob_height < y+h));
		if(ob==-1)
			break;
		/* Parent gefunden */
		if(tree[ob].ob_flags & HIDETREE) return(1);
	}
	return(0);
}

int	w_devent(int *evnt, int *mx, int *my, int *swt, int *key)
{ /* Macht Multi-Event mesag/button/key und gibt o zurÅck */
	/* o=0 Keybd/Button/Msg Event->nicht verarbeitet */
	/* o=1 Keybd/Button Event->in Dialog verarbeitet */
	/* o=-1 Msg Event (verarbeitet in Window) */
	/*      Msgpuffer ist pbuf */
	
	int			dum, o, wt;
	int			mevnt, mmx, mmy, mswt, mkey;
	WINDOW	*win;
	
	o=-2;
	
	mevnt=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,
									1,1,1,0,0,0,0,0,0,0,0,0,0,
									pbuf,0,0,&mmx,&mmy,&dum,&mswt,&mkey,&dum);
									
	*evnt=mevnt; *mx=mmx; *my=mmy; *swt=mswt; *key=mkey;

	if (mevnt & MU_MESAG)
		o=w_dispatch(pbuf);

	if (mevnt & MU_BUTTON)
	{
		o=w_button(mmx, mmy);
		if(o < 0) o=-2;
	}
		
	if (mevnt & MU_KEYBD)
	{
		o=w_keybd(mkey, mswt);
		if(o < 0)
			o=-2;
		else if (o==0)
			return(1);
	}
		
	if ((o >= 0) && (mevnt & (MU_BUTTON | MU_KEYBD)))
	{
		if(mevnt & MU_BUTTON)
		{/* Fenster unter Maus suchen */
			wt=wind_find(mmx, mmy);
			win=w_find(wt);
			if (win) /* Fenster von mir verwaltet */
			{/* Fenser muû oberstes oder BEVENT sein */
				wind_get(win->whandle, WF_BEVENT, &wt, &dum, &dum, &dum);
				if(wt) wt=win->whandle;
				else	wind_get(win->whandle, WF_TOP, &wt, &dum, &dum, &dum);
				if (wt != win->whandle) win=NULL;
			}
		}
		else
		{ /* Oberstes Fenster suchen */
			wind_get(0, WF_TOP, &wt, &dum, &dum, &dum);
			win=w_find(wt);
		}
		if(win && win->dinfo)
			if (!(win->dinfo->tree[o].ob_state & DISABLED))
			{ /* Userroutine */
				if(win->dinfo->dwservice)
					win->dinfo->dwservice(win, o);
				else
					win->dinfo->dservice(o);
			}
		o=1;
	}
	else if(o==-2) o=0;
		
	return(o);
}

int	w_ddevent(int *evnt, int *mx, int *my, int *but, int *swt, int *key, int *klicks)
{ /* Macht Multi-Event mesag/button/key und gibt o zurÅck */
	/* Doppelklicks werden auch berÅcksichtigt */
	/* o=0 Keybd/Button/Msg Event->nicht verarbeitet */
	/* o=1 Keybd/Button Event->in Dialog verarbeitet */
	/* o=-1 Msg Event (verarbeitet in Window) */
	/*      Msgpuffer ist pbuf */
	
	int			dum, o, wt;
	int			mevnt, mmx, mmy, mbut, mswt, mkey, mklicks;
	WINDOW	*win;
	
	o=-2;
	
	mevnt=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,
									258,3,0,0,0,0,0,0,0,0,0,0,0,
									pbuf,0,0,&mmx,&mmy,&mbut,&mswt,&mkey,&mklicks);
	/* 2, 1, 1  <> 258, 3, 0 */									
	
	*evnt=mevnt; *mx=mmx; *my=mmy; *but=mbut; *swt=mswt; *key=mkey;
	*klicks=mklicks;
	
	if (mevnt & MU_MESAG)
		o=w_dispatch(pbuf);

	if ((mevnt & MU_BUTTON) && (mbut & 1) && (mklicks==1))
	{
		o=w_button(mmx, mmy);
		if(o < 0)
			o=-2;
	}
		
	if (mevnt & MU_KEYBD)
	{
		o=w_keybd(mkey, mswt);
		if(o < 0)
			o=-2;
		else if (o==0)
			return(1);
	}
		
	if ((o >= 0) && (mevnt & (MU_BUTTON | MU_KEYBD)))
	{ /* Noch nicht verarbeitet */
	
		if(mevnt & MU_BUTTON)
		{/* Fenster unter Maus suchen */
			wt=wind_find(mmx, mmy);
			win=w_find(wt);
			if (win) /* Fenster von mir verwaltet */
			{/* Fenser muû oberstes oder BEVENT sein */
				wind_get(win->whandle, WF_BEVENT, &wt, &dum, &dum, &dum);
				if(wt) wt=win->whandle;
				else	wind_get(win->whandle, WF_TOP, &wt, &dum, &dum, &dum);
				if (wt != win->whandle) win=NULL;
			}
		}
		else
		{ /* Oberstes Fenster suchen */
			wind_get(0, WF_TOP, &wt, &dum, &dum, &dum);
			win=w_find(wt);
		}
		if(win && win->dinfo)
			if (!(win->dinfo->tree[o].ob_state & DISABLED))
			{ /* Userroutine */
				if(win->dinfo->dwservice)
					win->dinfo->dwservice(win, o);
				else
					win->dinfo->dservice(o);
			}
		o=1;
	}
	else if(o==-2) o=0;
		
	return(o);
}

int	w_ddtevent(int *evnt, int *mx, int *my, int *but, int *swt, int *key, int *klicks, int lo, int hi)
{ /* Macht Multi-Event mesag/button/key/timer und gibt o zurÅck */
	/* Doppelklicks werden auch berÅcksichtigt */
	/* o=0 Keybd/Button/Msg Event->nicht verarbeitet */
	/* o=1 Keybd/Button Event->in Dialog verarbeitet */
	/* o=-1 Msg Event (verarbeitet in Window) */
	/* Timer-Event ist in evnt sichtbar*/
	/*      Msgpuffer ist pbuf */
	
	int			dum, o, wt;
	int			mevnt, mmx, mmy, mbut, mswt, mkey, mklicks;
	WINDOW	*win;
	
	o=-2;
	
	mevnt=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
									258,3,0,0,0,0,0,0,0,0,0,0,0,
									pbuf,lo,hi,&mmx,&mmy,&mbut,&mswt,&mkey,&mklicks);
	/* 2, 1, 1  <> 258, 3, 0 */									
	
	*evnt=mevnt; *mx=mmx; *my=mmy; *but=mbut; *swt=mswt; *key=mkey;
	*klicks=mklicks;

	if (mevnt & MU_MESAG)
		o=w_dispatch(pbuf);

	if ((mevnt & MU_BUTTON) && (mbut & 1) && (mklicks==1))
	{
		o=w_button(mmx, mmy);
		if(o < 0)
			o=-2;
	}
		
	if (mevnt & MU_KEYBD)
	{
		o=w_keybd(mkey, mswt);
		if(o < 0)
			o=-2;
		else if (o==0)
			return(1);
	}
		
	/* o=0 kann jetzt bedeuten:
	   Message wurde nicht verarbeitet
	   ODER
	   Object null wurde ausgewÑlt.
	   Falls letzteres, dann war Maus oder Keyboard im Spiel
	   Dann wird hier der Dialog-Service aufgerufen
	*/
	if ((o >= 0) && (mevnt & (MU_BUTTON | MU_KEYBD)))
	{
		if(mevnt & MU_BUTTON)
		{/* Fenster unter Maus suchen */
			wt=wind_find(mmx, mmy);
			win=w_find(wt);
			if (win) /* Fenster von mir verwaltet */
			{/* Fenser muû oberstes oder BEVENT sein */
				wind_get(win->whandle, WF_BEVENT, &wt, &dum, &dum, &dum);
				if(wt) wt=win->whandle;
				else	wind_get(win->whandle, WF_TOP, &wt, &dum, &dum, &dum);
				if (wt != win->whandle) win=NULL;
			}
		}
		else
		{ /* Oberstes Fenster suchen */
			wind_get(0, WF_TOP, &wt, &dum, &dum, &dum);
			win=w_find(wt);
		}
		if(win && win->dinfo)
			if (!(win->dinfo->tree[o].ob_state & DISABLED))
			{ /* Userroutine */
				if(win->dinfo->dwservice)
					win->dinfo->dwservice(win, o);
				else
					win->dinfo->dservice(o);
			}
		o=1;
	}
	else if(o==-2) o=0;
		
	return(o);
}

int	w_dtimevent(int *evnt, int *mx, int *my, int *swt, int *key, int lo, int hi)
{ /* Macht Multi-Event mesag/button/key/timer und gibt o zurÅck */
	/* o=0 Keybd/Button/Msg Event->nicht verarbeitet */
	/* o=1 Keybd/Button Event->in Dialog verarbeitet */
	/* o=-1 Msg Event (verarbeitet in Window) */
	/*      Msgpuffer ist pbuf */
	/* Timer Event ist in evnt sichtbar */
	
	int			dum, o, wt;
	int			mevnt, mmx, mmy, mswt, mkey;
	WINDOW	*win;
	
	o=-2;
	
	mevnt=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
									1,1,1,0,0,0,0,0,0,0,0,0,0,
									pbuf,lo,hi,&mmx,&mmy,&dum,&mswt,&mkey,&dum);
										
	*evnt=mevnt; *mx=mmx; *my=mmy; *swt=mswt; *key=mkey;

	if (mevnt & MU_MESAG)
		o=w_dispatch(pbuf);

	if (mevnt & MU_BUTTON)
	{
		o=w_button(mmx, mmy);
		if(o < 0)
			o=-2;
	}
		
	if (mevnt & MU_KEYBD)
	{
		o=w_keybd(mkey, mswt);
		if(o < 0)
			o=-2;
		else if (o==0)
			return(1);
	}
		
	if ((o >= 0) && (mevnt & (MU_BUTTON | MU_KEYBD)))
	{
		if(mevnt & MU_BUTTON)
		{/* Fenster unter Maus suchen */
			wt=wind_find(mmx, mmy);
			win=w_find(wt);
			if (win) /* Fenster von mir verwaltet */
			{/* Fenser muû oberstes oder BEVENT sein */
				wind_get(win->whandle, WF_BEVENT, &wt, &dum, &dum, &dum);
				if(wt) wt=win->whandle;
				else	wind_get(win->whandle, WF_TOP, &wt, &dum, &dum, &dum);
				if (wt != win->whandle) win=NULL;
			}
		}
		else
		{ /* Oberstes Fenster suchen */
			wind_get(0, WF_TOP, &wt, &dum, &dum, &dum);
			win=w_find(wt);
		}
		if(win && win->dinfo)
			if (!(win->dinfo->tree[o].ob_state & DISABLED))
			{ /* Userroutine */
				if(win->dinfo->dwservice)
					win->dinfo->dwservice(win, o);
				else
					win->dinfo->dservice(o);
			}
		o=1;
	}
	else if(o==-2) o=0;
		
	return(o);
}

void	w_dinit(WINDOW *win)
{	/* Setzt Default-Werte und Routinen fÅr das Dialog-Fenster */

	int x, y, w, h;
	
	win->whandle=-1;
	
	win->open=0;
	win->full=0;
	
	win->dialog=0;
	win->text=0;
	win->show=0;
		
	win->amode=ARSYS;
	win->hpos=0;
	win->vpos=0;
	win->hsiz=1000;
	win->vsiz=1000;
	win->hstep=0;
	win->vstep=0;
	win->hpage=0;
	win->vpage=0;
	
	win->do_align=0;
	win->xa=0;
	win->xo=0;
	win->ya=0;
	win->yo=0;
	
	win->rmode=RDARROW;
	/* Fenster-Routinen setzen */
	win->userdraw=NULL;
	win->suserdraw=NULL;
	win->usercalc=NULL;
	
	win->redraw=redraw;
	win->topped=NULL;
	win->closed=NULL;
	win->fulled=NULL;
	win->arrowed=NULL;
	win->hslid=NULL;
	win->vslid=NULL;
	win->sized=NULL;
	win->moved=NULL;
	win->untopped=NULL;
	win->ontop=NULL;
	win->backdrop=backdrop;
	
	wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
	win->wx=win->mx=x-w; /* Damit man auch nach links schieben kann*/
	win->wy=win->my=y;
	win->ww=win->mw=w;
	win->wh=win->mh=h;
	
	win->nw=40;
	win->nh=40;
}

int	w_dial(WINDOW *win, int center)
{	/*	Belegt Fenster fÅr unmodalen Dialog */
	/* 0=Fehler, dann als modal versuchen? */
	return(w_kdial(win, center, MOVE|NAME|BACKDROP));
}

int	w_kdial(WINDOW *win, int center, int kind)
{	/*	Belegt Fenster fÅr unmodalen Dialog */
	/* Wie w_dial, aber in kind kînnen die Elemente angegeben werden */
	/* 0=Fehler, dann als modal versuchen? */
	
	win->dialog=1;
	win->kind=kind;
	win->name=ap_name;
	win->userdraw=w_dialdraw;
	win->suserdraw=w_sdialdraw;
	win->moved=w_dialmoved;
	win->untopped=w_dialuntopped;
	win->topped=w_dialtopped;
	win->ontop=w_dialontop;
	win->dinfo->dedit=0;	/* Objectnummer erstes Edit */
	win->dinfo->curon=1;	/* Cursor auf ON setzen */
	win->dinfo->cpos=0;
	win->dinfo->ostart=0; /* Objectnummer des ersten zu zeichnenden */
	win->dinfo->odepth=0; /* Zeichentiefe (fÅr Teil-Redraw)*/
	win->dinfo->dwservice=NOFN;
	win->dinfo->dbutton=NOFN;
	win->dinfo->dkeybd=NOFN;
	win->dinfo->dabutton=NOFN;
	win->dinfo->dakeybd=NOFN;
	win->dinfo->dwfocus=NOFN;
	win->dinfo->dwkeydispatch=(int(*)())0l;	/* NOFN ist (void) */
	if (center == D_MOUSE)
		form_mouse(win->dinfo->tree, &win->ax, &win->ay, &win->aw, &win->ah);
	else /* FÅr D_CENTER und unbekannt */
		form_center(win->dinfo->tree, &win->ax, &win->ay, &win->aw, &win->ah);

	win->dinfo->xdif=win->dinfo->tree[0].ob_x-win->ax;
	win->dinfo->ydif=win->dinfo->tree[0].ob_y-win->ay;
	w_wcalc(win);

	if (w_make(win))
	{
		win->dinfo->winok=1;
		w_calc(win);
		win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
		win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;
	}
	else
		win->dinfo->winok=0;

	return(win->dinfo->winok);
}

void	form_mouse(OBJECT *tree, int *x, int *y, int *w, int *h)
{ /* Centered den Dialog um die Maus herum ohne auf Fenster-*/
	/* Grîûe zu achten */

	int mx, my, dum, sx, sy, sw, sh, ex, ey, xdif, ydif;
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
	graf_mkstate(&mx, &my, &dum, &dum);
	form_center(tree, x, y, w, h);
	xdif=tree[0].ob_x-*x;
	ydif=tree[0].ob_y-*y;
	
	ex=mx-(*w/2);
	if (ex < sx)
		ex=sx;
	if ((ex+*w) > (sx+sw))
		ex=(sx+sw)-*w;
		
	ey=my-(*h/2);
	if (ey < sy)
		ey=sy;
	if ((ey+*h) > (sy+sh))
		ey=(sy+sh)-*h;
		
	tree[0].ob_x=ex+xdif;
	tree[0].ob_y=ey+ydif;
	*x=ex;
	*y=ey;

}

void	w_form_dial(int mode, int x1, int y1, int w1, int h1, WINDOW *win)
{	/* START belegt Fenster oder normale Fn, falls kein Fenster frei */
	/* FINISH schlieût Fenster oder Dialog, falls dinfo->winok=0 */
	
	if (mode == FMD_START)
	{
		w_init(win);
		win->dialog=1;
		win->kind=MOVE|NAME|BACKDROP;
		win->name=ap_name;
		win->userdraw=w_dialdraw;
		win->suserdraw=w_sdialdraw;
		win->moved=w_dialmoved;
		win->untopped=w_dialuntopped;
		win->topped=w_dialtopped;
		win->ontop=w_dialontop;
		win->dinfo->curon=1;
		win->dinfo->cpos=0;
		win->dinfo->dwservice=NOFN;
		win->dinfo->dbutton=NOFN;
		win->dinfo->dkeybd=NOFN;
		win->dinfo->dabutton=NOFN;
		win->dinfo->dakeybd=NOFN;
		win->dinfo->dwfocus=NOFN;
		win->dinfo->dwkeydispatch=(int(*)())0l;	/* NOFN ist (void) */
		
		win->dinfo->xdif=win->dinfo->tree[0].ob_x-x1;
		win->dinfo->ydif=win->dinfo->tree[0].ob_y-y1;
		wind_calc(WC_BORDER, win->kind, x1, y1, w1, h1, &win->wx, &win->wy, &win->ww, &win->wh);
		if (w_make(win))
		{
			win->dinfo->winok=1;
			w_open(win);		
			w_calc(win);
			win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
			win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;
		}
		else
		{
			win->dinfo->winok=0;
			form_dial(FMD_START,x1,y1,w1,h1,x1,y1,w1,h1);
		}
	}
	else if (mode == FMD_FINISH)
	{
		w_kill(win);
		if (!win->dinfo->winok)
			form_dial(FMD_FINISH,x1,y1,w1,h1,x1,y1,w1,h1);
	}
}

void	w_dialdraw(WINDOW *win, int x, int y, int w, int h)
{	/* Redraw-Routine fÅr ganzen Dialog */
	w_sdialdraw(win, x, y, w, h, 0);
}

void	w_sdialdraw(WINDOW *win, int x, int y, int w, int h, int mode)
{	/* Redraw fÅr Dialog-Teile */
	int	cur;

	if (win->dinfo->dedit)
		cur=w_dialcursor(win, D_CUROFF);

	win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
	win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;
	if (mode)
		objc_draw(win->dinfo->tree, win->dinfo->ostart, win->dinfo->odepth, x, y, w, h);
	else
		objc_draw(win->dinfo->tree, win->dinfo->osmax, win->dinfo->odmax, x, y, w, h);
	
	if ((win->dinfo->support & LetEmFly) && letfly)
	{
		if (w_istop(win))
			letflykeys = init_keys(win->dinfo->tree);
	}

	if (cur)
	{
		if (win->dinfo->dedit)
			w_dialcursor(win, D_CURON);
	}
}

void	w_objc_draw(WINDOW *win, int ostart, int odepth, int x, int y, int w, int h)
{ /* wie objc_draw. Da auch beim ersten ôffnen verwendet, werden */
	/* Maximalwerte abgefragt und ggfls. in die Struktur gesetzt */

	GRECT in, out;
	int		ob_t;
	
	if((win->whandle > -1) && (win->open))
	{
		in.g_x=x; in.g_y=y; in.g_w=w; in.g_h=h;
		objc_offset(win->dinfo->tree, ostart, &out.g_x, &out.g_y);
		out.g_w=win->dinfo->tree[ostart].ob_width;	
		out.g_h=win->dinfo->tree[ostart].ob_height;
		/* Rahmen prÅfen */
		ob_t=(win->dinfo->tree[ostart].ob_type) & 255;
		if((ob_t==G_BOXTEXT)||(ob_t==G_TEXT)||(ob_t==G_FTEXT)||(ob_t==G_FBOXTEXT))
		{/* TEDINFO-Rahmen (pos.=innen, neg.=auûen) */
			if(win->dinfo->tree[ostart].ob_spec.tedinfo->te_thickness < 0)
			{
				out.g_x+=win->dinfo->tree[ostart].ob_spec.tedinfo->te_thickness;
				out.g_y+=win->dinfo->tree[ostart].ob_spec.tedinfo->te_thickness;
				out.g_w-=win->dinfo->tree[ostart].ob_spec.tedinfo->te_thickness*2;
				out.g_h-=win->dinfo->tree[ostart].ob_spec.tedinfo->te_thickness*2;
				out.g_x--; out.g_y--; out.g_w+=2; out.g_h+=2;
			}
		}
		else if((ob_t==G_BOX)||(ob_t==G_IBOX)||(ob_t==G_BOXCHAR))
		{/* ob_spec enthÑlt Rahmen-Daten */
			if(win->dinfo->tree[ostart].ob_spec.obspec.framesize < 0)
			{
				out.g_x+=win->dinfo->tree[ostart].ob_spec.obspec.framesize;
				out.g_y+=win->dinfo->tree[ostart].ob_spec.obspec.framesize;
				out.g_w-=win->dinfo->tree[ostart].ob_spec.obspec.framesize*2;
				out.g_h-=win->dinfo->tree[ostart].ob_spec.obspec.framesize*2;
			}
		}
		else if(ob_t==G_BUTTON)
		{/* FÅr Button immer 2 Randpixel rundrum */
			out.g_x-=2;
			out.g_y-=2;
			out.g_w+=4;
			out.g_h+=4;
		}
		
		if(rc_intersect(&in, &out))
		{
			if (win->dinfo->winok)
			{
				win->dinfo->ostart=ostart;
				if (ostart < win->dinfo->osmax)
					win->dinfo->osmax=ostart;
				
				win->dinfo->odepth=odepth;
				if (odepth > win->dinfo->odmax)
					win->dinfo->odmax=odepth;
	
				w_redraw(win, out.g_x, out.g_y, out.g_w, out.g_h, 2);
			}
			else
				objc_draw(win->dinfo->tree, ostart, odepth, x, y, w, h);
		}
	}
}

void	w_objc_change(WINDOW *win, int onum, int rsv, int x, int y, int w, int h, int nstate, int redraw)
{	/* wie objc_change */

	if (win->dinfo->winok)
	{
		objc_change(win->dinfo->tree, onum, rsv, x, y, w, h, nstate, 0);
		if (redraw)
			w_objc_draw(win, onum, 1, x, y, w, h);
	}
	else objc_change(win->dinfo->tree, onum, rsv, x, y, w, h, nstate, redraw);
	
}

int old_w_do_dial(OBJECT *tree)
{/* Der einfachste Fensterdialog von allen */
	/* FÅhrt tree als modalen Dialog im Fenster aus und gibt Exitob zurÅck */
	WINDOW win;
	DINFO	 dob;
	int x,y,w,h,o;
	
	dob.tree=tree;
	dob.support=0;
	dob.dservice=NULL;
	dob.osmax=0;
	dob.odmax=8;
	dob.dedit=0;
	x=0;
	while(!(tree[x].ob_flags & LASTOB))
	{
		if(tree[x].ob_flags & EDITABLE)
		{dob.dedit=x; break;}
		++x;
	}

	win.dinfo=&dob;
	
	form_center(tree, &x, &y, &w, &h);

	w_form_dial(FMD_START, x,y,w,h, &win);
	o=w_form_do(&win, dob.dedit);
	w_form_dial(FMD_FINISH, x,y,w,h, &win);
	if(o)
		tree[o].ob_state &= (~SELECTED);
	return(o);
}

void w_do_dial_service(WINDOW *win, int ob)
{
	if(win->dinfo->tree[ob].ob_flags & EXIT)
	{
		*(int*)(win->user)=ob;
		w_close(win);
	}
}

int w_do_dial(OBJECT *tree)
{
	return(w_do_opt_dial(tree, w_do_dial_service));
}

int		w_do_opt_dial(OBJECT *tree, void (*w_do_obj)(WINDOW *win, int ob))
{/* Die Åbergeben Serviceroutine muû bei einem Exit-Objekt
		das Fenster schlieûen und im WINDOW-Userob die Objekt-
		Nummer des Exitobjekts setzen!
		(Eine der Service-Routinen muû natÅrlich NULL sein)
		So: *(int*)(win->user)=ob;
	 */
	int			dum, first_edit, ret_ob, swt, key, evnt, sx,sy,sw,sh;
	WINDOW	wdial;
	DINFO		ddial;

	wind_get(0, WF_WORKXYWH, &sx,&sy,&sw,&sh);
	dum=0; first_edit=0;
	while(!(tree[dum].ob_flags & LASTOB))
	{
		if(tree[dum].ob_flags & EDITABLE)
		{first_edit=dum; break;}
		++dum;
	}

	w_dinit(&wdial);
	ddial.tree=tree;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_dial(&wdial, D_CENTER);
	ddial.dservice=NULL;
	ddial.dwservice=w_do_obj;
	ddial.dedit=first_edit;
	w_open(&wdial);

	(int*)(wdial.user)=&ret_ob;
	
	w_modal(&wdial, MODAL_ON);

	while(wdial.open)
	{
		if(w_devent(&evnt,&dum,&dum,&swt,&key)) continue;
		if(!(evnt & MU_KEYBD)) continue;
		/* Scancode 59-62 = F1-F4, lîst Buttons 1-4 aus */
		key>>=8;
		if(((swt&255)==0) && (key >= 59) && (key <= 62))
		{
			dum=-1; key-=58; /* 1-4 */
			do
			{
				++dum;
				if((tree[dum].ob_type & 255) == G_BUTTON)
				{
					if(--key == 0)
					{
						tree[dum].ob_state |= SELECTED;
						w_objc_draw(&wdial, dum, 8, sx,sy,sw,sh);
						ret_ob=dum;
						goto _wddone;
					}
				}
			}while(!(tree[dum].ob_flags & LASTOB));
		}
	}

_wddone:
	w_modal(&wdial, MODAL_OFF);
	
	w_kill(&wdial);
	return(ret_ob);
}

int		w_form_do(WINDOW *win, int oedit)
{	/* Modale Dialogverwaltung (user-Routine) */

	if (win->dinfo->winok)
		return(w_form_modal(win, oedit));
	else
		return(form_do(win->dinfo->tree,oedit));
}

int		w_form_modal(WINDOW *win, int oedit)
{	/* Modale Dialogverwaltung (systemroutine) */
	int o;

	w_modal(win, MODAL_ON);
	
	if (!(win->dinfo->curon) && (oedit))
	{/* Cursor ist nicht an */
		win->dinfo->curon=1;
		win->dinfo->dedit=oedit;
		objc_edit(win->dinfo->tree,oedit,0,&win->dinfo->cpos,1);

		if ((win->dinfo->support & LetEmFly) && letfly)
			letflykeys = init_keys(win->dinfo->tree);
	}
	
	while ((o=w_event())==-1);
			
	w_modal(win, MODAL_OFF);
	
	return(o);
}

int		w_event(void)
{ /* event-Verwaltung fÅr Modale Dialoge */

	int			evnt, mx, my, swt, key, dum, o;

	o=-1;

	evnt=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,
									1,1,1,0,0,0,0,0,0,0,0,0,0,
									pbuf,0,0,&mx,&my,&dum,&swt,&key,&dum);
									
	if (evnt & MU_MESAG)
	{
		o=w_dispatch(pbuf);
	}

	if (evnt & MU_BUTTON)
	{
		o=w_button(mx, my);
	}
		
	if (evnt & MU_KEYBD)
	{
		o=w_keybd(key, swt);
	}
			
	return(o);
}

int get_cpos(WINDOW *win, int ob, int mx)
{
	int ox, dum;
	
	objc_offset(win->dinfo->tree, ob, &ox, &dum);
	mx-=ox;

	dum=0;
	while((mx > 0)&&(win->dinfo->tree[ob].ob_spec.tedinfo->te_ptext[dum]))
	{
		mx-=(int)(aes_fw[(unsigned char)(win->dinfo->tree[ob].ob_spec.tedinfo->te_ptext[dum++])]);
	}	
	if(dum && (mx<=0))--dum;	 /* Cursor VOR angeklickten Buhstaben setzen */
	return(dum);
}

int	w_button(int mx, int my)
{	/* Dialog-Button Dispatcher */
	/* Return: -1=kein Exit-Object angeklickt
						>=0 Nummer des angeklickten Exit-Objects */
	int			wh, wt, dum, o, br, no, mem;
	WINDOW	*win;

	o=-1;
	
	wh=wind_find(mx, my);
	win=w_find(wh);
	if (win) /* Fenster von mir verwaltet ?*/
	{
		wind_get(win->whandle, WF_BEVENT, &wt, &dum, &dum, &dum);
		if(wt) wt=win->whandle;
		else	wind_get(win->whandle, WF_TOP, &wt, &dum, &dum, &dum);
		if ((wt == win->whandle) && win->dialog)
		{ /* Angeklicktes Fenster ist oberstes (oder BEVENT) und Dialog*/
			if (win->dinfo->dbutton)
				win->dinfo->dbutton(mx, my);
			o=objc_find(win->dinfo->tree, win->dinfo->osmax, win->dinfo->odmax, mx, my);
			/* Object simulieren */
			if (o>=0)
			{/* Hat was getroffen */
				br=form_button(win->dinfo->tree, o, 1, &no);
				if (br)
				{/* Kein Exit-Object angeklickt */
					if (no)
					{/* Edit Object wurde geÑndert */
						w_dialcursor(win, D_CUROFF); /* Muû an sein, da Fenster */
						if((!check_hide_parent(win->dinfo->tree, no)) && (win->dinfo->tree[no].ob_flags & EDITABLE))
						{
							mem=win->dinfo->dedit;
							win->dinfo->dedit=no; /* oberstes ist */
							win->dinfo->cpos=get_cpos(win, no, mx);
							if(win->dinfo->dwfocus) win->dinfo->dwfocus(win, mem, no);
						}
						w_dialcursor(win, D_CURON);
					}
					o=-1;
				}
			}
			else
				o=-1;
	
			if(win->dinfo->dabutton)
				win->dinfo->dabutton(mx, my);
		}
	}
	
	return(o);
}

void xted_strcpy(OBJECT *tree, int ob)
{
	char	*src, *dst;
	int		len;
	
	dst=tree[ob].ob_spec.tedinfo->te_ptext;
	src=&(xted(tree, ob)->te_ptext[xted(tree, ob)->offset]);
	len=(int)strlen(xted(tree, ob)->te_ptext)-xted(tree, ob)->offset;
	if(len > tree[ob].ob_spec.tedinfo->te_txtlen-1) len=tree[ob].ob_spec.tedinfo->te_txtlen-1;
	if(xted(tree, ob)->secret) while(len--)
		*dst++=xted(tree, ob)->secret;
	else while(len--)
		*dst++=*src++;
	*dst=0;
}

void objc_xted(OBJECT *tree, int ob, int len, char secret)
{/* TEDINFO-Object in XTED fÅr scrollbares Edit-Feld umwandeln */
	XTEDINFO	*xt;
	
	xt=(XTEDINFO*)malloc(sizeof(XTEDINFO));
	if(xt==NULL) return;
	xt->te_ptext=(char*)calloc(len+1, 1);
	if(xt->te_ptext==NULL) {free(xt); return;}
	tree[ob].ob_spec.tedinfo->te_ptext[0]=0;	/* String lîschen */
	tree[ob].ob_spec.tedinfo->te_ptext[tree[ob].ob_spec.tedinfo->te_txtlen-1]=0;	/* String terminieren, damit das bei objc_edit nicht dauernd gemacht werden muû */
	xt->ti=*(tree[ob].ob_spec.tedinfo);
	xt->ascii_low=0;
	xt->secret=secret;
	xt->magic='XTED';
	xt->maxlen=len;
	xt->offset=0;
	*((XTEDINFO**)&(tree[ob].ob_spec.tedinfo))=xt;
}

void objc_xtedset(OBJECT *tree, int ob, char *text)
{
	xted(tree, ob)->te_ptext=text;
	xted(tree, ob)->offset=0;
	xted_strcpy(tree, ob);
}

void objc_xtedcpy(OBJECT *tree, int ob, char *text)
{
	strncpy(xted(tree, ob)->te_ptext,text,xted(tree, ob)->maxlen);
	xted(tree, ob)->offset=0;
	xted_strcpy(tree, ob);
}

long	objc_xtedstrlen(OBJECT *tree, int ob)
{
	if(xted(tree, ob)->magic != 'XTED')
		return(strlen(tree[ob].ob_spec.tedinfo->te_ptext));
	return(strlen(xted(tree, ob)->te_ptext));
}

int xed_cursor(OBJECT *tree, int ob, int cpos, int edkind)
{
	int w, pxy[4];
	#define Y_CUR_ADD 3

	w=0;
	while(cpos--)
	{
		w+=(int)(aes_fw[(unsigned char)(tree[ob].ob_spec.tedinfo->te_ptext[cpos])]);
	}	
/*	w=tree[ob].ob_width/(tree[ob].ob_spec.tedinfo->te_txtlen-1);
	w*=cpos;*/

	vswr_mode(whandle,MD_XOR);
	vsl_type(whandle, 1);
	vsl_width(whandle, 1);
	vsl_color(whandle, 0);
	vsl_ends(whandle, 0, 0);
	
	objc_offset(tree, ob, &(pxy[0]), &(pxy[1]));
	pxy[0]+=w;
	pxy[1]-=Y_CUR_ADD;
	pxy[2]=pxy[0];
	pxy[3]=pxy[1]+tree[ob].ob_height+2*Y_CUR_ADD-1;
	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF, NULL);
	v_pline(whandle, 2,pxy);
	graf_mouse(M_ON, NULL);
	wind_update(END_MCTRL);
	return(1);
}

int xobjc_edit(OBJECT *tree, int ob, int key, int *cpos, int edkind)
{
	int	fh, sx,sy,sw,sh,a,swt=(int)Kbshift(-1) & 15;
	long	len;
	
	wind_get(0, WF_WORKXYWH, &sx,&sy,&sw,&sh);

	/* Scrollbar? */
	if(xted(tree, ob)->magic != 'XTED')
	{
		return(objc_edit(tree,ob,key,cpos,edkind));
	}

	/* (Cursor kann fÅr nicht-scrollbar noch nicht Åbernommen werden,
	    weil da die Maske evtl. fÅr Offset-Strings etc. sorgt! ) */
	    	
	/* Cursor ON/OFF? */
	if((edkind==1)||(edkind==3))
	{
		/* Cursor ggf. auf Ende d. Edit-Felds setzen */
		if(*cpos > (int)strlen(tree[ob].ob_spec.tedinfo->te_ptext))
			*cpos=(int)strlen(tree[ob].ob_spec.tedinfo->te_ptext);
		return(xed_cursor(tree, ob, *cpos, edkind));
	}

	/* Mode=ED_EDIT? */
	if(edkind != 2)
		return(objc_edit(tree,ob,key,cpos,edkind));

	/* Cursor ausschalten */
	xed_cursor(tree, ob, *cpos, 3);
	
	/* Links? */
	if(((key>>8)==75) && (swt==0))
	{/* Editfeld schon am Anfang und Cursor ganz links ? */
		if((*cpos==0) && (xted(tree, ob)->offset==0))
			return(xed_cursor(tree, ob, *cpos, 1));
		/* Cursor nur eins nach links setzen? */
		if(*cpos)
		{
			--*cpos;
			return(xed_cursor(tree, ob, *cpos, 1));
		}
		/* Scrollfeld eins nach links setzen */
		--xted(tree, ob)->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}

	/* Rechts? */
	if(((key>>8)==77) && (swt==0))
	{/* Schon auf letztem Buchstaben? */
		if(xted(tree, ob)->te_ptext[xted(tree, ob)->offset+*cpos] == 0)
			return(xed_cursor(tree, ob, *cpos, 1));
		/* Cursor nicht ganz rechts (HINTER letztem Zeichen) ? */
		if(*cpos < tree[ob].ob_spec.tedinfo->te_txtlen-1)
		{
			++*cpos;
			return(xed_cursor(tree, ob, *cpos, 1));
		}
		/* Scrollfeld eins nach rechts setzen */
		++xted(tree, ob)->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}

	/* Shift links? */
	if( ((key>>8)==71) || (((key>>8)==75) && (swt & 3)) )
	{
		xted(tree, ob)->offset=0;
		*cpos=0;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* Shift rechts? */
	if(((key>>8)==54) ||  (((key>>8)==77) && (swt & 3)))
	{
		*cpos=(int)strlen(xted(tree, ob)->te_ptext);
		if(*cpos > tree[ob].ob_spec.tedinfo->te_txtlen-1)
			*cpos=tree[ob].ob_spec.tedinfo->te_txtlen-1;
		xted(tree, ob)->offset=0;
		while(xted(tree, ob)->offset + *cpos < strlen(xted(tree,ob)->te_ptext))
			++xted(tree,ob)->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* Control links ? */
	if(((key>>8)==115) || (((key>>8)==75) && (swt & 4)) )
	{
		while(*cpos + xted(tree, ob)->offset > 0)
		{
			if(*cpos) --*cpos;
			else	--xted(tree, ob)->offset;
			if(xted(tree,ob)->te_ptext[*cpos+xted(tree,ob)->offset-1]==' ')
				break;
		}
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}

	/* Control rechts ? */
	if(((key>>8)==116) || (((key>>8)==77) && (swt & 4)) )
	{
		while(*cpos + xted(tree, ob)->offset < strlen(xted(tree,ob)->te_ptext))
		{
			if(*cpos < tree[ob].ob_spec.tedinfo->te_txtlen-1) ++*cpos;
			else	++xted(tree, ob)->offset;
			if(xted(tree,ob)->te_ptext[*cpos+xted(tree,ob)->offset-1]==' ')
				break;
		}
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* ESC? */
	if((key>>8)==1)
	{
		xted(tree, ob)->te_ptext[0]=0;
		xted(tree, ob)->offset=0;
		*cpos=0;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* Backspace? */
	if((key>>8)==14)
	{/* Alles schon ganz links? */
		if((*cpos==0) && (xted(tree, ob)->offset==0))
			return(xed_cursor(tree, ob, *cpos, 1));
		/* String eins nach links kopieren */
		strcpy(&(xted(tree, ob)->te_ptext[xted(tree, ob)->offset-1+*cpos]), &(xted(tree, ob)->te_ptext[xted(tree, ob)->offset+*cpos]));
		/* Cursor oder offset versetzen */
		if(*cpos) --*cpos;
		else --xted(tree, ob)->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}

	/* Delete? */
	if((key>>8)==83)
	{/* Cursor schon hinter letztem Buchstaben? */
		if(*cpos == strlen(tree[ob].ob_spec.tedinfo->te_ptext))
			return(xed_cursor(tree, ob, *cpos, 1));
		/* String eins nach links kopieren */
		strcpy(&(xted(tree, ob)->te_ptext[xted(tree, ob)->offset+*cpos]), &(xted(tree, ob)->te_ptext[xted(tree, ob)->offset+*cpos+1]));
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* Cut, Copy, Paste */
	if(((key>>8)==45) && (swt & 4))	/* Cut */
	{
		graf_mouse(BUSYBEE, NULL);
		clear_clipboard();
		fh=write_clipboard("SCRAP.TXT");
		if(fh < 0) {graf_mouse(ARROW, NULL);gemdos_alert("Kann SCRAP.TXT nicht anlegen", fh); return(xed_cursor(tree, ob, *cpos, 1));} 
		if(xted(tree, ob)->secret)
			Fwrite(fh, strlen("You can't copy from a secret input box."), "You can't copy from a secret input box."); 
		else
			Fwrite(fh, strlen(xted(tree, ob)->te_ptext), xted(tree, ob)->te_ptext);
		Fclose(fh);
		graf_mouse(ARROW, NULL);
		xted(tree, ob)->te_ptext[0]=0;
		xted(tree, ob)->offset=0;
		*cpos=0;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	if(((key>>8)==46) && (swt & 4))	/* Copy */
	{
		graf_mouse(BUSYBEE, NULL);
		clear_clipboard();
		fh=write_clipboard("SCRAP.TXT");
		if(fh < 0) {graf_mouse(ARROW, NULL);gemdos_alert("Kann SCRAP.TXT nicht anlegen", fh); return(xed_cursor(tree, ob, *cpos, 1));} 
		if(xted(tree, ob)->secret)
			Fwrite(fh, strlen("You can't copy from a secret input box."), "You can't copy from a secret input box."); 
		else
			Fwrite(fh, strlen(xted(tree, ob)->te_ptext), xted(tree, ob)->te_ptext);
		Fclose(fh);
		graf_mouse(ARROW, NULL);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	if(((key>>8)==47) && (swt & 4))	/* Paste */
	{
		graf_mouse(BUSYBEE, NULL);
		fh=sread_clipboard("SCRAP.TXT");
		if(fh < 0) {graf_mouse(ARROW, NULL); return(xed_cursor(tree, ob, *cpos, 1));} 
		len=Fread(fh, xted(tree, ob)->maxlen, xted(tree, ob)->te_ptext);
		Fclose(fh);
		graf_mouse(ARROW, NULL);
		if(len < 0) return(xed_cursor(tree, ob, *cpos, 1)); /* Fehler beim Lesen */
		xted(tree, ob)->te_ptext[len]=0;
		/* Shift rechts simulieren */
		*cpos=(int)strlen(xted(tree, ob)->te_ptext);
		if(*cpos > tree[ob].ob_spec.tedinfo->te_txtlen-1)
			*cpos=tree[ob].ob_spec.tedinfo->te_txtlen-1;
		xted(tree, ob)->offset=0;
		while(xted(tree, ob)->offset + *cpos < strlen(xted(tree,ob)->te_ptext))
			++xted(tree,ob)->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}

	/* EinzufÅgendes Zeichen? */
	if((key & 0xff) > xted(tree, ob)->ascii_low)
	{/* Kein Platz mehr? */
		if(strlen(xted(tree, ob)->te_ptext) == xted(tree, ob)->maxlen)
			return(xed_cursor(tree, ob, *cpos, 1));
		/* Zeichen einfÅgen */
		a=xted(tree,ob)->maxlen;
		while(--a > xted(tree, ob)->offset+*cpos)
			xted(tree, ob)->te_ptext[a]=xted(tree, ob)->te_ptext[a-1];
		xted(tree, ob)->te_ptext[xted(tree, ob)->offset+*cpos]=(key&0xff);
		/* Cursor eins nach rechts falls nicht ganz hinten */
		if(*cpos < tree[ob].ob_spec.tedinfo->te_txtlen-1)
			++*cpos;
		else
			++(xted(tree, ob))->offset;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(xed_cursor(tree, ob, *cpos, 1));
	}
	
	/* Alles andere kommt spÑter */
	return(objc_edit(tree,ob,key,cpos,1));
}

int xform_keybd(OBJECT *tree, int ob, int obnxt, int key, int *nxtob, int *nxtchar)
{
	return(form_keybd(tree, ob, obnxt, key, nxtob, nxtchar));
}

int o_xform_keybd(OBJECT *tree, int ob, int obnxt, int key, int *nxtob, int *nxtchar)
{
	int ret=form_keybd(tree, ob, obnxt, key, nxtob, nxtchar);
	int	sx,sy,sw,sh;

	if(*nxtchar==key) return(ret);	 /* Nicht verarbeitet */
	
	if(*nxtob != ob)	/* Aktuelles Editobjekt bearbeiten */
		ob=*nxtob;
		
	/* Scrollbar? */
	if(xted(tree, ob)->magic != 'XTED')
		return(ret);	/* Nein->Keine besonderen Maûnahmen nîtig */
		
	/* Wurde (Shift) Home gedrÅckt? Dann neues Editfeld auf Offset 0 setzen */
	if((key>>8)==71)
	{
		wind_get(0, WF_WORKXYWH, &sx,&sy,&sw,&sh);
		xted(tree, ob)->offset=0;
		/* Echten String einkopieren, Text und Cursor zeichnen */
		xted_strcpy(tree, ob);
		objc_draw(tree, ob, 8, sx,sy,sw,sh);
		return(ret);
	}

	return(ret);
}

int w_keybd(int key, int swt)
{	/* Dialog-Keyboard Dispatcher */
	/* return:
			-1=nix gemacht
			 0=Verarbeitet (z.B. Editfeld Ñndern oder Eingabe 
			>0=Exitobjekt, das durch Tasteneingabe aufgerufen wurde
	*/
	
	int 		wt, dum, bkey, bobj, o2, o, no, mem;
	WINDOW	*win;
	
	o=-1;
	
	/* Oberstes Fenster */
	wind_get(0, WF_TOP, &wt, &dum, &dum, &dum);
	win=w_find(wt);
	if (win)	/* Mein Fenster */
	{
		if (win->dialog)
		{ /* Fenster ist Dialog */
			if(win->dinfo->dwkeydispatch)
				if(win->dinfo->dwkeydispatch(win, key, swt)) return(0);
			if (win->dinfo->dkeybd)
				win->dinfo->dkeybd(key, swt);
			bkey=0;
			bobj=0;
			o2=1;
			
			if ((win->dinfo->support & LetEmFly) && letfly && letflykeys)
			{
				o2 = lookup_key(key, swt);
				if(o2)
				{
					o=o2;
					o2 = form_button(win->dinfo->tree, o, 1, &no);
					if (o2)
						o=-1;
				}
				else
					o2=1;
			} /* endif let'em fly */
			else if ((win->dinfo->support & MagiX) && magix)
			{
				o2=xform_keybd(win->dinfo->tree, 0x8765,0,key,&bobj,&bkey);
				if ((o2==1)&&(!bkey))
				{
					o=bobj;
					o2=0;
					/*o2=form_button(win->dinfo->tree,o,1,&no);*/
					/*if (o2)*/
					/*	o=-1;*/
				}
				else
					o2=1;
			}
			/* Normale form-do */
			if (o2)
			{ /* o Noch nicht verarbeitet */
				o=xform_keybd(win->dinfo->tree,win->dinfo->dedit,0,key,&bobj,&bkey);
				if(!o) /* Exit-Objekt betÑtig */
					o=bobj;
				else if((win->dinfo->dedit)&& !(check_hide_parent(win->dinfo->tree, win->dinfo->dedit)))
				{
					if (bkey) /* Normale Eingabe */
					{
						if(!(win->dinfo->tree[win->dinfo->dedit].ob_state & DISABLED))
						{
							o2=win->dinfo->cpos; mem=(int)objc_xtedstrlen(win->dinfo->tree,win->dinfo->dedit);
							xobjc_edit(win->dinfo->tree,win->dinfo->dedit,key,&win->dinfo->cpos,2);
							if((win->dinfo->cpos != o2)||(mem!=(int)objc_xtedstrlen(win->dinfo->tree,win->dinfo->dedit)))
								/* Eingabe akzeptiert */
								o=0;
							else
								o=-1;	/* Eingabe nicht ausgefÅhrt */
						}
						else
							o=-1;
					}
					else if (bobj) /* Keine normale Eingabe & kein Exit */
					{/* d.h. Edit Object wurde geÑndert */
						w_dialcursor(win, D_CUROFF); /* Muû an sein, da Fenster */
						if((!(win->dinfo->tree[bobj].ob_state & DISABLED))&&(!check_hide_parent(win->dinfo->tree, bobj)) && (win->dinfo->tree[bobj].ob_flags & EDITABLE))
						{
							mem=win->dinfo->dedit;
							win->dinfo->dedit=bobj; /* oberstes ist */
							if(win->dinfo->dwfocus) win->dinfo->dwfocus(win, mem, bobj);
						}
						w_dialcursor(win, D_CURON);
						o=0;
					}
					else
						o=-1;
				}
				else
					o=-1;
			}
			if(win->dinfo->dakeybd)
				win->dinfo->dakeybd(key, swt);
		}/* endif Dialogfenster */
	}/* endif mein Fenster */
	
	return(o);
}

WINDOW *w_find(int whandle)
{ /* Liefert Zeiger auf Fenster mit handle whandle, sonst NULL */

	int	a;

	for (a=0; a < MAX_WIN; a++)
	{
		if(winpoint[a])
			if (whandle == winpoint[a]->whandle)
				return(winpoint[a]);
	}
	
	return(NULL);
}

WINDOW	*w_list(int cont)
{/* Liefert den ersten (cont=0) oder den jeweils nÑchsten Zeiger
		(cont=1) auf alle von der Lib verwalteten Fenster oder NULL,
		wenn keine mehr existieren */
static	int	ix;

	if(cont==0) ix=0;
	while(ix < MAX_WIN)
	{
		++ix;
		if(winpoint[ix-1])
			return(winpoint[ix-1]);
	}
	return(NULL);
}

void	w_dialmoved(WINDOW *win, int *mbuf)
{ /*WM_MOVED Fn fÅr Dialoge */
	moved(win, mbuf);
	
	w_calc(win);
	win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
	win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;
}

void w_dialuntopped(WINDOW *win)
{ /* Cursor ausschalten */
	w_dialcursor(win, D_CUROFF);
	untopped(win);
}
void	w_dialtopped(WINDOW *win)
{ /* Cursor (und evtl. Fly) anschalten */
	w_dialontop(win);
	topped(win);
}
void	w_dialontop(WINDOW *win)
{	/* Cursor und evtl. Fly einschalten */
	if ((win->dinfo->support & LetEmFly) && letfly)
		letflykeys = init_keys(win->dinfo->tree);
	w_dialcursor(win, D_CURON);
	ontop(win);
}

int	w_dialcursor(WINDOW *win, int mode)
{ /* Schaltet Cursor an/aus und gibt alte Cursoreinstellung zurÅck */
	/* Nur falls Cursor sichtbar */
	int ret;
	
	ret=win->dinfo->curon;
	if(win->dinfo->dedit==0) return(ret);
	if(!(win->dinfo->tree[win->dinfo->dedit].ob_flags & EDITABLE)) return(ret);
	if(check_hide_parent(win->dinfo->tree, win->dinfo->dedit))
		return(ret);
	if (mode == D_CUROFF)
	{
		if (win->dinfo->curon)
		{
			win->dinfo->curon=0;
			xobjc_edit(win->dinfo->tree,win->dinfo->dedit,0,&win->dinfo->cpos,ED_END);
		}
	}
	else if (mode == D_CURON)
	{
		if (!win->dinfo->curon)
		{
			win->dinfo->curon=1;
			xobjc_edit(win->dinfo->tree,win->dinfo->dedit,0,&win->dinfo->cpos,ED_INIT);
		}
	}
	
	return(ret);
}

void w_modal(WINDOW *win, int mode)
{ /* Schaltet global Modal auf dieses Fenster */

	if (mode == MODAL_ON)
	{
		globalmodal=1;
		globalhandle=win->whandle;
	}
	else if (mode == MODAL_OFF)
	{
		globalmodal=0;
	}
}

void w_unsel(WINDOW *win, int ob)
{
	int sx, sy, sw, sh;
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
	win->dinfo->tree[ob].ob_state &= (~SELECTED);
	w_objc_draw(win, ob, 8, sx, sy, sw, sh);
}

/*---------------------------------------------------------------*/
/* Balken-Fenster */
/*---------------------------------------------------------------*/


void	w_showmake(WINDOW *win, char *action)
{
	int sx, sy, sw, sh, dum;

	vst_alignment(whandle, 0, 3, &dum, &dum);
	show_ww=20*wpwchar;
	show_bw=18*wpwchar;
	show_wh=4*wphchar;
	show_bh=1*wphchar;
	
	w_init(win);
	
	win->sinfo->wist=0;
	win->sinfo->wsoll=1000;
	win->sinfo->saction=action;
	
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
	win->kind=NAME|MOVE|CLOSE;
	win->name=ap_name;
	win->ax=(sw-show_ww)/2;
	win->ay=(sh-show_wh)/2;
	win->aw=show_ww;
	win->ah=show_wh;
	win->userdraw=w_showdraw;
	w_wcalc(win);
	if (w_make(win))
		w_open(win);
}

void	w_show(WINDOW *win, size_t ist, size_t soll)
{
	win->sinfo->wist=ist;
	win->sinfo->wsoll=soll;
	s_redraw(win);
}

void	w_showkill(WINDOW *win)
{
	w_kill(win);
}

void	w_showdraw(WINDOW *win, int x, int y, int w, int h)
{
	int 	mshow, xoffset, yoffset, bxy[10], txy[8];
	int		leftw, rightw, toph, txh, resty;
	float	sfactor;
	GRECT	clear, draw1;
	
	clear.g_x=x;
	clear.g_y=y;
	clear.g_w=w;
	clear.g_h=h;
	
	if (!win->sinfo->wist)
		win->sinfo->wist=1;
	if (!win->sinfo->wsoll)
		win->sinfo->wsoll=1;
	if (win->sinfo->wist > win->sinfo->wsoll)
		win->sinfo->wist=win->sinfo->wsoll;
	
	xoffset=wpwchar;
	yoffset=wphchar/4;

	vqt_extent(whandle, win->sinfo->saction, txy);
	leftw=xoffset;
	rightw=win->aw-(xoffset+txy[2])+1;
	txh=txy[7]-txy[1];
	toph=yoffset+wphchar-txh+1;
	/* Rechtecke um Text lîschen */
	/* oben */
	draw1.g_x=win->ax;
	draw1.g_y=win->ay;
	draw1.g_w=win->aw;
	draw1.g_h=toph;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	/* links */
	draw1.g_x=win->ax;
	draw1.g_y=win->ay+toph;
	draw1.g_w=leftw;
	draw1.g_h=txh;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	/* rechts */
	draw1.g_x=win->ax+xoffset+txy[2];
	draw1.g_y=win->ay+toph;
	draw1.g_w=rightw;
	draw1.g_h=txh;
	resty=draw1.g_y+draw1.g_h-1;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
		
	v_gtext(whandle, win->ax+xoffset, win->ay+wphchar+yoffset, win->sinfo->saction);
	
	yoffset=wphchar+wphchar/2;
	bxy[0]=bxy[2]=bxy[8]=win->ax+(win->aw-show_bw)/2;
	bxy[1]=bxy[7]=bxy[9]=win->ay+yoffset+(win->ah-yoffset-show_bh)/2;
	bxy[4]=bxy[6]=bxy[0]+show_bw;
	bxy[5]=bxy[3]=bxy[1]+show_bh;
	/* Rechtecke um Rahmen lîschen */
	/* oben */
	draw1.g_x=win->ax;
	draw1.g_y=resty;
	draw1.g_w=win->aw;
	draw1.g_h=bxy[1]-resty;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	/* unten */
	draw1.g_x=win->ax;
	draw1.g_y=bxy[3]+1;
	draw1.g_w=win->aw;
	draw1.g_h=win->ay+win->ah-bxy[3];
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	/* links */
	draw1.g_x=win->ax;
	draw1.g_y=bxy[1];
	draw1.g_w=bxy[0]-win->ax;
	draw1.g_h=bxy[3]-bxy[1]+1;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	/* rechts */
	draw1.g_x=bxy[4]+1;
	draw1.g_y=bxy[1];
	draw1.g_w=win->ax+win->aw-bxy[4];
	draw1.g_h=bxy[3]-bxy[1]+1;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	
	/* Rahmen zeichnen */
	vsf_interior(whandle,0);
	v_pline(whandle, 5,bxy);
	/* Balken zeichnen */
	sfactor=(float)win->sinfo->wsoll/(float)win->sinfo->wist;
	mshow=(int)((float)(show_bw)/sfactor);
	if (mshow > show_bw)
		mshow=show_bw;
	bxy[2]=bxy[0]+mshow;
	vsf_interior(whandle, 2);
	vsf_style(whandle, 4);
	vsf_color(whandle, 1);
	vsf_perimeter(whandle, 1);
	v_bar(whandle, bxy);
	/* Rest im Rahmen lîschen */
	draw1.g_x=bxy[2]+1;
	draw1.g_y=bxy[1]+1;
	draw1.g_w=bxy[4]-draw1.g_x;
	draw1.g_h=bxy[3]-draw1.g_y;
	if(rc_intersect(&clear, &draw1))
		w_clear(draw1.g_x, draw1.g_y, draw1.g_w, draw1.g_h);
	
}


/*---------------------------------------------------------------*/
/* Extra AES-Funktionen */
/*---------------------------------------------------------------*/




void img_fix(OBJECT *root, int ob)
{
	int	ohigh, nhigh, a, b, rl, wl, linlen, icount;
	unsigned char *rline, *wline;
	float each_nd, count;
	long	imgadr, imgzadr;
	
	if (phchar != TXT_HEIGHT)
	{
		imgadr=imgzadr=(long)(root[ob].ob_spec.bitblk->bi_pdata);
		linlen=root[ob].ob_spec.bitblk->bi_wb;
		ohigh=root[ob].ob_spec.bitblk->bi_hl;
		nhigh=(((ohigh*10)/16)*phchar)/10;
		root[ob].ob_spec.bitblk->bi_hl=nhigh;
	}
	
	if (phchar < TXT_HEIGHT)
	{
		each_nd=(float)((float)ohigh/(float)(ohigh-nhigh));
		for (a=rl=wl=0, count=each_nd; a < ohigh; a++)
		{
			icount=(int)count;
			if (a >= icount)
			{ /* Auslasszeile auf vorige odern*/
				wline=(unsigned char*)((long)(imgadr + (long)((wl-1)*linlen)));
				rline=(unsigned char*)((long)(imgadr + (long)(rl*linlen)));
				for (b=0; b < linlen; b++)
					wline[b]|=rline[b];
				count+=each_nd;
				rl++;
			}
			else
			{ /* Zeile kopieren */
				wline=(unsigned char*)((long)(imgadr + (long)(wl*linlen)));
				rline=(unsigned char*)((long)(imgadr + (long)(rl*linlen)));
				for (b=0; b < linlen; b++)
					wline[b]=rline[b];
				rl++;
				wl++;
			}
		}/* endfor */
	}/* < 16? */
	else if (phchar > TXT_HEIGHT)/* > 16 */
	{
		imgzadr=(long)(Malloc(nhigh*linlen));
		root[ob].ob_spec.bitblk->bi_pdata=(int*)(imgzadr);
		each_nd=(float)((float)nhigh/(float)(nhigh-ohigh));
		for (a=rl=wl=0, count=each_nd; a < ohigh; a++)
		{
			icount=(int)count;
			if (a >= icount)
			{ /* Zeile verdoppeln*/
				wline=(unsigned char*)((long)(imgzadr + (long)(wl*linlen)));
				rline=(unsigned char*)((long)(imgadr + (long)((rl-1)*linlen)));
				for (b=0; b < linlen; b++)
					wline[b]=rline[b];
				count+=each_nd;
				wl++;
			}
			else
			{ /* Zeile kopieren */
				wline=(unsigned char*)((long)(imgzadr + (long)(wl*linlen)));
				rline=(unsigned char*)((long)(imgadr + (long)(rl*linlen)));
				for (b=0; b < linlen; b++)
					wline[b]=rline[b];
				rl++;
				wl++;
			}
		}/* endfor */
		for (a=ohigh; a < nhigh; a++)
		{/* Rest lîschen */
			wline=(unsigned char*)((long)(imgzadr + (long)(wl*linlen)));
			for (b=0; b < linlen; b++)
				wline[b]=0;
			wl++;
		}
	}/* endelse */
	
}

void	img_free(OBJECT *root, int ob)
{	
	if (phchar > TXT_HEIGHT)
		Mfree((void*)(root[ob].ob_spec.bitblk->bi_pdata));
}

int	popup(OBJECT *tree, int ob, OBJECT *poproot, int pop, int entries, int def)
{ /* Verarbeitet das Popup Nr. pop aus dem Objc.-Tree poproot */
  /* Das Popup wird an der Stelle des Objects ob aus tree geîffnet */
  /* entries ist die Anzahl der Popup-EintrÑge, def ist der */
  /* Momentane Wert (0-n) oder -1, wenn kein Default (HÑkchen) */
  /* Die Resource muû so aufgebaut sein, daû die Objektnummern der */
  /* PopupeintrÑge bei parent+1 beginnen und nach unten steigen */
  /* ZurÅckgeliefert wird die Nr. des Eintrags (0-n) */
  /* oder -1 (=Cancel) */
  
  int	a, x, y, mx, my, mox, moy, mb, dum;
  int	moobj, obj, oobj, sel, key, evt;
  int	ox,oy,ow,oh, sx, sy, sw, sh;
  int klick=0;

	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
  
  /* Popup-Init */
  for (a=0; a < entries; a++)
  {
  	if (a == def)
	  	poproot[pop+1+a].ob_state=CHECKED;
	  else
	  	poproot[pop+1+a].ob_state=0;
  }
  sel=oobj=moobj=-1;
  mox=moy=0;
  
  /* Popup zeichnen */
  form_center(&poproot[pop], &dum, &dum, &ow, &oh);
  objc_offset(tree, ob, &x, &y);
  if(def > 0)
	  y-=def*(poproot[pop+1].ob_height);
  if ((x+ow) > (sx+sw))
  	x=sx+sw-ow;
  if (x < sx)
  	x=sx;
  if ((y+oh) > (sy+sh))
  	y=sy+sh-oh;
  if (y < sy)
  	y=sy;
  	
  poproot[0].ob_x=ox=x;
  poproot[0].ob_y=oy=y;
  poproot[pop].ob_x=0;
  poproot[pop].ob_y=0;
  form_dial(FMD_START,ox-1,oy-1,ow+1,oh+1,ox-1,oy-1,ow+1,oh+1);
  objc_draw(poproot,pop,entries+1,ox-1,oy-1,ow+1,oh+1);
  
  /* Warten, daû Taste losgelassen wird */
  mb=1;
	evnt_button(1,1,0,&dum,&dum,&dum,&dum);
  	
  /* Popup verarbeiten */
  while (!klick)
  {
  	graf_mkstate(&mx, &my, &dum, &dum);

		evt=evnt_multi(MU_BUTTON|MU_M1|MU_KEYBD,
								1,1,1, 1,mx,my,1,1, 0,0,0,0,0, 
								NULL,0,0, &mx,&my,&mb, &dum, &key, &dum);
		
  	klick=mb & 1;

		if (evt & MU_KEYBD)
		{
			key/=256;
			if ((key == 28) && (sel != -1)) /* Return */
				klick=1;
				
			if ((key == 1) || (key == 97)) /* ESC, Undo */
			{
				klick=1;
				sel=-1;
			}
			
			if ((key == 72) || (key == 80)) /* Up, down */
			{
				if (key == 72)
				{/* Up */
					if (oobj != -1)
						obj=oobj-1;
					else
						obj=pop+entries;
					if (obj < pop+1)
						obj=pop+entries;
				}
				else if (key == 80)
				{/* Down */
					if (oobj != -1)
						obj=oobj+1;
					else
						obj=pop+1;
					if (obj > pop+entries)
						obj=pop+1;
				}
	  		if (obj != oobj)
	  		{
	  			if (oobj > -1)
	  				objc_change(poproot,oobj,0,ox,oy,ow,oh,poproot[oobj].ob_state&CHECKED,1);
	  			if (obj > -1)
	  				objc_change(poproot,obj,0,ox,oy,ow,oh,poproot[obj].ob_state|SELECTED,1);
		  		oobj=obj;
		  		moobj=-1;
		  		if (obj > -1)
		  			sel=obj-pop-1;
		  		else
		  			sel=-1;
	  		}
			}/* Endif up, down */
 		}/* endif keybd */

  	if ((evt & MU_BUTTON) || (evt & MU_M1))
  	{ /* Vielleicht Maus-Bewegung */
  		if ((mx != mox) || (my != moy))
  		{
  			mox=mx;
  			moy=my;
	  		obj=objc_find(poproot,pop,entries+1,mx,my);
	  		if(poproot[pop].ob_state & DISABLED)
	  			obj=-1;
	  		if (obj != moobj)
	  		{
	  			if (oobj > -1)
	  				objc_change(poproot,oobj,0,ox,oy,ow,oh,poproot[oobj].ob_state&CHECKED,1);
	  			if (obj > -1)
	  				objc_change(poproot,obj,0,ox,oy,ow,oh,poproot[obj].ob_state|SELECTED,1);
		  		moobj=oobj=obj;
		  		if (obj > -1)
		  			sel=obj-pop-1;
		  		else
		  			sel=-1;
	  		}
  		}/* endif mauspos*/
  	}/* endif evnt Mouse */
  }/* end while noklick */
  form_dial(FMD_FINISH,ox-1,oy-1,ow+1,oh+1,ox-1,oy-1,ow+1,oh+1);
	evnt_button(1,1,0,&dum,&dum,&dum,&dum);

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);

  return(sel);
}

int	form_popup(OBJECT *poproot, int x, int y)
{ /* Verarbeitet das Popup aus dem Objc.-Tree poproot */ 
  /* Das Popup wird an der Position x,y geîffnet */ 
   
  /* ZurÅckgeliefert wird die Nr. des Eintrags (0-n) */ 
  /* oder -1 (=Cancel) */ 
   
  int a, mx, my, mox, moy, mb, dum;
  int	sx,sy,sw,sh;
  int obj, oobj, sel, evt; 
  int ox,oy,ow,oh; 
  int klick=0; 

	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
 
  /* Popup-Init */ 
 
 	a=-1;
 	do
  { 
  	++a;
    poproot[a].ob_state&=(~SELECTED); 
  }while(!(poproot[a].ob_flags & LASTOB));
  
  a=1; 
  sel=-1; 
 
  oobj=-1; 
  mox=moy=0; 
   
  /* Popup zeichnen */ 
 
  form_center(&poproot[0], &dum, &dum, &ow, &oh);
  if ((x+ow) > (sx+sw))
  	x=sx+sw-ow;
  if (x < sx)
  	x=sx;
  if ((y+oh) > (sy+sh))
  	y=sy+sh-oh;
  if (y < sy)
  	y=sy;

  poproot[0].ob_x=ox=x;
  poproot[0].ob_y=oy=y;
  form_dial(FMD_START,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);
  objc_draw(poproot,0,6,ox-3,oy-3,ow+3,oh+3);

  /* Warten, daû Taste losgelassen wird */
  mb=1;
	evnt_button(1,1,0,&dum,&dum,&dum,&dum);
  
  /* Popup verarbeiten */ 
  while (!klick) 
  { 
    graf_mkstate(&mx, &my, &dum, &dum); 
 
    evt=evnt_multi(MU_BUTTON|MU_M1, 
                1,1,1, 1,mx,my,1,1, 0,0,0,0,0,  
                NULL,0,0, &mx,&my,&mb, &dum, &dum, &dum); 
     
    klick=mb & 1; 
 
  
    if ((evt & MU_BUTTON) || (evt & MU_M1)) 
    { /* Vielleicht Maus-Bewegung */ 
      if ((mx != mox) || (my != moy)) 
      { 
        mox=mx; 
        moy=my; 
        obj=objc_find(poproot,0,6,mx,my); 
        if((poproot[obj].ob_state & DISABLED) | !(poproot[obj].ob_flags & SELECTABLE))
          obj=-1; 
        if (obj != oobj) 
        { 
          if (oobj > -1) 
            objc_change(poproot,oobj,0,ox,oy,ow,oh,poproot[oobj].ob_state&(~SELECTED),1); 
          if (obj > -1) 
            objc_change(poproot,obj,0,ox,oy,ow,oh,poproot[obj].ob_state|SELECTED,1); 
          oobj=sel=obj; 
        } 
      }/* endif mauspos*/ 
    }/* endif evnt Mouse */ 
  }/* end while noklick */ 
  form_dial(FMD_FINISH,ox-3,oy-3,ow+3,oh+3,ox-3,oy-3,ow+3,oh+3);

  evnt_button(1,1,0,&dum,&dum,&dum,&dum); 

 	a=-1;
 	do
  { 
  	++a;
    poproot[a].ob_state&=(~SELECTED); 
  }while(!(poproot[a].ob_flags & LASTOB));

	wind_update(END_UPDATE);
	wind_update(END_MCTRL);
	 
  return(sel); 
} 


int	wnd_get(int w_hnd, int func, int *p1, int *p2, int *p3, int *p4)
{

	AESPB	c;
	c.contrl=_GemParBlk.contrl;
	c.global=_GemParBlk.global;
	c.intin=_GemParBlk.intin;
	c.intout=_GemParBlk.intout;
	
	_GemParBlk.contrl[0]=104;
	_GemParBlk.contrl[1]=2;
	_GemParBlk.contrl[2]=5;
	_GemParBlk.contrl[3]=0;
	_GemParBlk.contrl[4]=0;
	
	_GemParBlk.intin[0]=w_hnd;
	_GemParBlk.intin[1]=func;

	_crystal(&c);
	
	*p1=_GemParBlk.intout[1];
	*p2=_GemParBlk.intout[2];
	*p3=_GemParBlk.intout[3];
	*p4=_GemParBlk.intout[4];
	
	return(_GemParBlk.intout[0]);
}

void	unsel(OBJECT *tree, int obnr)
{
	int sx, sy, sw, sh;
	
	wind_get(0, WF_WORKXYWH, &sx, &sy, &sw, &sh);
	tree[obnr].ob_state &= (~SELECTED);
	objc_draw(tree,obnr,1,sx,sy,sw,sh);
}


/*---------------------------------------------------------------*/
/* AV-Protokoll */
/*---------------------------------------------------------------*/


void	va_init(char *my_name)
{
/* AV_PROTOKOLL: Mit dieser Nachrichtennummer sollte man bei 
 * anderen Applikationen und auch VENUS/GEMINI nachfragen, ob
 * und welche Nachrichten sie versteht.
 */

	char *avser, anam[15];
	
	avser=NULL;
	shel_envrn(&avser, "AVSERVER");
	if (avser)
	{
		strcpy(anam, &avser[1]);
		if (strlen(anam) < 8)
			strncat(anam,"        ",8-strlen(anam));
		avs_id=appl_find(anam);
	}
	else
		avs_id=-1;
	if (avs_id > -1)
	{
		pbuf[0]=AV_PROTOKOLL;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=16;	/* Kann Quoting */
		pbuf[4]=0;
		pbuf[5]=0;
		pbuf[6]=(int)((unsigned long)(my_name)/65536l);
		pbuf[7]=(int)((unsigned long)(my_name)-(pbuf[6]*65536l));
		appl_write(avs_id, 16, pbuf);
	}
}

void	va_open(int wid)
{
/* AV_ACCWINDOPEN: Mit dieser Nachricht kann ein Acc Venus mitteilen, daû
 * es ein Fenster geîffnet hat.
 * Word 3 AES-Handle des geîffneten Fensters
 */
	if (avs_id > -1)
	{
		pbuf[0]=AV_ACCWINDOPEN;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=wid;
		appl_write(avs_id, 16, pbuf);
	}
}

void	va_close(int wid)
{
/* AV_ACCWINDCLOSED: Acc teilt Venus mit, daû sein Fenster geschlossen
 * wurde. Dies braucht das Acc nur in dem Fall zu tun, wenn es selbst das
 * Fenster schlieût. Bekommt es eine AC_CLOSE Mitteilung vom AES, so weiû
 * Venus schon, daû alle Fenster weg sind.
 * Word 3   AES-Handle des Fensters
 */
	if (avs_id > -1)
	{
		pbuf[0]=AV_ACCWINDCLOSED;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=wid;
		appl_write(avs_id, 16, pbuf);
	}
}

void	va_sendkey(int kbs, int key)
{
/* AV_SENDKEY: Gibt den Sondertasten- und Scancode an den Server
 * weiter. (Entspricht den evnt_multi RÅckgabewerten)
 * Word 3   Sondertastenstatus
 * Word 4   Scancode
 */
	if (avs_id > -1)
	{
		pbuf[0]=AV_SENDKEY;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=kbs;
		pbuf[4]=key;
		appl_write(avs_id, 16, pbuf);
	}
}

void	va_exit(void)
{
/* AV_EXIT: Ein Programm/Accessory teilt Gemini mit, daû es nicht
 * mehr am Protokoll teilnimmt (normalerweisem, weil es beendet
 * wurde).
 * Word 3   AES-ID des Programms/Accessories
 */
	if (avs_id > -1)
	{
		pbuf[0]=AV_EXIT;
		pbuf[1]=ap_id;
		pbuf[2]=0;
		pbuf[3]=ap_id;
		appl_write(avs_id, 16, pbuf);
	}
}


/*---------------------------------------------------------------*/
/* MenÅsteuerung per Tastatur */
/*---------------------------------------------------------------*/


void scan_text(int key, int *swt, char *dst)
{ /* Baut in AbhÑngigkeit vom LÑndercode einen String fÅr
			die Tastenkombination key+swt auf. Dabei wird nur ein String
			fÅr die Taste selbst erzeugt. Ein Shifttastenstatus, der sich
			aus dem Scancode ergibt, wird in swt vermerkt, ansonsten
			bleibt swt unverÑndert.
			Unbelegte Scancodes erzeugen einen Leerstring */
			
	
	char	*table[133][4]=
	{
		"", "", "", "", 					/* 0 = n.d. */
		"ESC", "ESC", "ESC", "ESC",
		"1", "1", "1", "1",
		"2", "2", "2", "2",
		"3", "3", "3", "3",
		"4", "4", "4", "4", 
		"5", "5", "5", "5",
		"6", "6", "6", "6",
		"7", "7", "7", "7",
		"8", "8", "8", "8", 
		"9", "9", "9", "9",
		"0", "0", "0", "0",
		"û", "-", "-", ")",
		"\'", "=", "=", "-",
		"BSPC", "BSPC", "BSPC", "BSPC",
		"TAB", "TAB", "TAB", "TAB",
		"Q", "Q", "Q", "A",
		"W", "W", "W", "Z",
		"E", "E", "E", "E",
		"R", "R", "R", "R",
		"T", "T", "T", "T",
		"Z", "Y", "Y", "Y",
		"U", "U", "U", "U",
		"I", "I", "I", "I",
		"O", "O", "O", "O",
		"P", "P", "P", "P",
		"ö", "[", "[", "[",
		"+", "]", "]", "]",
		"CR", "CR", "CR", "CR",
		"", "", "", "",			/* Control */
		"A", "A", "A", "Q",
		"S", "S", "S", "S",
		"D", "D", "D", "D",
		"F", "F", "F", "F",
		"G", "G", "G", "G",
		"H", "H", "H", "H",
		"J", "J", "J", "J", 
		"K", "K", "K", "K",
		"L", "L", "L", "L",
		"ô", ";", ";", "M",
		"é", "\'", "\'", "\\",
		"#", "\`", "\`", "\`",
		"", "", "", "",				/* Shift links */
		"~", "\\", "#", "@",
		"Y", "Z", "Z", "W",
		"X", "X", "X", "X",
		"C", "C", "C", "C",
		"V", "V", "V", "V",
		"B", "B", "B", "B",
		"N", "N", "N", "N",
		"M", "M", "M", ",",
		",", ",", ",", ";",
		".", ".", ".", ":",
		"-", "/", "/", "=",
		"", "", "", "",					/* Shift rechts */
		"", "", "", "", 				/* n.d. */
		"", "", "", "", 				/* Alternate */
		"SPC", "SPC", "SPC", "SPC",
		"", "", "", "", 				/* Caps Lock */
		"F1", "F1", "F1", "F1",
		"F2", "F2", "F2", "F2",
		"F3", "F3", "F3", "F3",
		"F4", "F4", "F4", "F4",
		"F5", "F5", "F5", "F5",
		"F6", "F6", "F6", "F6",
		"F7", "F7", "F7", "F7",
		"F8", "F8", "F8", "F8",
		"F9", "F9", "F9", "F9",
		"F10", "F10", "F10", "F10",
		"", "", "", "", 				/* n.d. */
		"", "", "", "", 				/* n.d. */
		"CLR", "CLR", "CLR", "CLR",
		"UP", "UP", "UP", "UP",
		"", "", "", "", 				/* n.d. */
		"[-]", "[-]", "[-]", "[-]",
		"LFT", "LFT", "LFT", "LFT",
		"", "", "", "", 				/* n.d. */
		"RGT", "RGT", "RGT", "RGT",
		"[+]", "[+]", "[+]", "[+]",
		"", "", "", "", 				/* n.d. */
		"DWN", "DWN", "DWN", "DWN",
		"", "", "", "", 				/* n.d. */
		"INS", "INS", "INS", "INS",
		"DEL", "DEL", "DEL", "DEL",
		"F1", "F1", "F1", "F1",
		"F2", "F2", "F2", "F2",
		"F3", "F3", "F3", "F3",
		"F4", "F4", "F4", "F4",
		"F5", "F5", "F5", "F5",
		"F6", "F6", "F6", "F6",
		"F7", "F7", "F7", "F7",
		"F8", "F8", "F8", "F8",
		"F9", "F9", "F9", "F9",
		"F10", "F10", "F10", "F10",
		"", "", "", "", 				/* n.d. */
		"", "", "", "", 				/* n.d. */
		"<", "", "\\", "<",
		"UNDO", "UNDO", "UNDO", "UNDO",
		"HELP", "HELP", "HELP", "HELP",
		"[(]", "[(]", "[(]", "[(]",
		"[)]", "[)]", "[)]", "[)]",
		"[/]", "[/]", "[/]", "[/]",
		"[*]", "[*]", "[*]", "[*]",
		"[7]", "[7]", "[7]", "[7]",
		"[8]", "[8]", "[8]", "[8]",
		"[9]", "[9]", "[9]", "[9]",
		"[4]", "[4]", "[4]", "[4]",
		"[5]", "[5]", "[5]", "[5]",
		"[6]", "[6]", "[6]", "[6]",
		"[1]", "[1]", "[1]", "[1]",
		"[2]", "[2]", "[2]", "[2]",
		"[3]", "[3]", "[3]", "[3]",
		"[0]", "[0]", "[0]", "[0]",
		"[.]", "[.]", "[.]", "[.]",
		"[CR]", "[CR]", "[CR]", "[CR]",
		"LFT", "LFT", "LFT", "LFT",
		"RGT", "RGT", "RGT", "RGT",
		"", "", "", "", 				/* n.d. */
		"", "", "", "", 				/* n.d. */
		"CLR", "CLR", "CLR", "CLR",
		"1", "1", "1", "1",
		"2", "2", "2", "2",
		"3", "3", "3", "3",
		"4", "4", "4", "4", 
		"5", "5", "5", "5",
		"6", "6", "6", "6",
		"7", "7", "7", "7",
		"8", "8", "8", "8", 
		"9", "9", "9", "9",
		"0", "0", "0", "0",
		"û", "-", "-", ")",
		"\'", "=", "=", "-",
		"", "", "", "" 				/* n.d. */
	};
	
	KEYTAB	*systab;
	int			country=0; /* Tabellenindex, 0=D, 1=USA, 2=GB, 3=F */
	
	/* Land ausfindig machen */
	systab=Keytbl((void*)-1l, (void*)-1l, (void*)-1l);
	
	if(systab->unshift[43]=='\\') country=1;
	else if(systab->unshift[43]=='#') country=2;
	else if(systab->unshift[43]=='@') country=3;

	if(key < 133)	
		strcpy(dst, table[(unsigned int) key][country]);
	else
		strcpy(dst, table[(unsigned int) 132][country]);
	
	/* swt-Korrektur */
	
	if(key == 29) *swt |= K_CTRL;
	else if(key == 42) *swt |= K_LSHIFT;
	else if(key == 54) *swt |= K_RSHIFT;
	else if(key == 56) *swt |= K_ALT;
	else if(key == 58) *swt |= K_LOCK;
	else if((key>=84) && (key <=93)) *swt |= K_SHIFT;
	else if((key>=120) && (key <=131)) *swt |= K_ALT;
	else if((key==115) || (key==116) || (key==119)) *swt |= K_CTRL;

}

void make_menu_string(int key, int swt, char *dst)
{/* Baut aus key und swt einen MenÅ-AbkÅrzungsstring auf und
		schreibt ihn in dst.
		Der Text hat maximal 3 swt-Symbole und max. 4 Zeichen, also 
		insgs. max 7 Zeichen */
		
	dst[0]=0;
	
	if(swt & K_SHIFT)
		strcpy(dst, "\x01"); /* Pfeil aufwÑrts Symbol fÅr Shift */
		
	if(swt & K_ALT)
		strcat(dst, "\x07"); /* Fuller Symbol fÅr Alt */
		
	if(swt & K_CTRL)
		strcat(dst, "^"); /* Symbol fÅr Ctrl */
	scan_text(key, &swt, &(dst[strlen(dst)])); /* Tastenname holen */
}

char *get_menu_key(OBJECT *tree, int ob, char *dst)
{ /* Versucht aus dem MenÅeintrag ob im MenÅbaum tree einen
     Shortcuttext zu extrahieren und schreibt ihn in dst.
     Es werden maximal 7 Zeichen kopiert
     Wird nix gefunden, bleibt der String unverÑndert, kann also
     vorher auf ein unmîgliches Zeichen (z.B. geshiftete Nummern, also
     !, ", › ...) initialisiert werden.
   */
     
	char	*c;
	int		x, start, end;
	
	c=tree[ob].ob_spec.free_string;
	x=(int)strlen(c)-1; /* Auf letztes Zeichen setzen */
	
	/* Von rechts erstes Nicht-Space suchen */
	
	while(x && (c[x]==' ')) --x;
	end=x;

	if(!x)	/* Ganzer String ist nur Space */
		return(dst);
	
	/* NÑchstes Space suchen */
	while(x)
	{
		if(c[x] == ' ')
		{
			start=x+1;
			break;
		}
		--x;
	}
	
	if((!x) || (end-start > 6)) /* Nix gefunden oder mehr als 7 Zeichen*/
		return(dst);
	
	/* Sonst kopieren */
	x=0;
	while(start <= end)
		dst[x++]=c[start++];
	dst[x]=0;
	return(dst);
}

int	menu_key(OBJECT *tree, int key, int swt, int *title, int *ob)
{
	/* Testet, ob im MenÅbaum tree der Shortcut key/swt vorgesehen
	   ist. Falls ja wird 1 geliefert und in title/ob der MenÅpunkt
	   eingetragen, sonst wird 0 geliefert.
	   WICHTIG: <key> ist nicht der Returnwert von evnt_multi
	   bzw den w_devent-Derivaten sondern der dortige Return>>8!
	   Also der Scan und nicht der Ascii-Code!
	   
	   Im MenÅ mÅssen die Sondertasten in der Reihenfolge Shift-Alt-Ctrl
	   eingetragen sein. Neben den Ascii-Zeichen wird HELP, INS, DEL,
	   F1-F10, CLR, UNDO, TAB, CR, ESC, BSPC, SPC und Ziffernblocktasten
	   als [x] unterstÅtzt
	*/
	   
	char	c[10], extract[10];
	int		i=3, ret=0;
	
	/* Suchtring aufbauen */
	make_menu_string(key, swt, c);
	/* Tree absuchen */
	/* Titel Åbergehen */
	while(tree[i].ob_type == G_TITLE) ++i;
	
	*title=2; /* Auf ersten Titel-1 setzen */
	do
	{
		++i; /* Beim Einsprung wird dadurch die MenÅ-umfassende Box Åbergangen */
		/* Ggf. Titel setzten */
		if(tree[i].ob_type == G_BOX) ++*title; /* Falls Boxob->neues MenÅ */
		
		/* Passendes Objekt? */
		if( (tree[i].ob_type == G_STRING) &&
				!(tree[i].ob_state & DISABLED))
		{
			extract[0]='?';
			extract[1]=0;
			get_menu_key(tree, i, extract);

			if(!strcmp(extract, c))
			{
				*ob=i;
				ret=1;
				break;
			}
		}
	}while(!(tree[i].ob_flags & LASTOB));	
	return(ret);
}

/* MenÅ sperren und freigeben */
/* Sperrt alle Titel auûer erstem und erstes G_STRING
   in erstem MenÅ und gibt diese wieder frei */
void lock_menu(OBJECT *tree)
{
#define obj_type(a, b) ((int)(a[b].ob_type & 0xff))
	int go=0, ob=0;
	
	do
	{
		if(obj_type(tree, ob)==G_TITLE)
		{	
			if(go)
				menu_ienable(tree, ob, 0);
			else
				go=1;
		}
		else if(obj_type(tree, ob)==G_STRING)	/* Erster Eintrag Desk-MenÅ */
		{
			menu_ienable(tree, ob, 0);
			break;
		}
	}while(!(tree[ob++].ob_flags & LASTOB));
	menu_bar(tree, 1);
#undef obj_type
}
void unlock_menu(OBJECT *tree)
{
#define obj_type(a, b) ((int)(a[b].ob_type & 0xff))
	int go=0, ob=0;
	
	do
	{
		if(obj_type(tree, ob)==G_TITLE)
		{	
			if(go)
				menu_ienable(tree, ob, 1);
			else
				go=1;
		}
		else if(obj_type(tree, ob)==G_STRING)	/* Erster Eintrag Desk-MenÅ */
		{
			menu_ienable(tree, ob, 1);
			break;
		}
	}while(!(tree[ob++].ob_flags & LASTOB));
	menu_bar(tree, 1);
#undef obj_type
}


/*---------------------------------------------------------------*/
/* GEMDOS-Fehlermeldungen    */
/*---------------------------------------------------------------*/

void gemdos_alert(char *text, long en)
{/* text=Operation bei der Fehler aufgetreten ist, z.B. 
		"Kann Datei blabla nicht îffnen"
		Darf hîchstens eine Alert-Zeile lang sein
		en=error nubmer wie sie von Gemdos geliefert wird
*/
	char alert[512], num[33];
	
	strcpy(alert, "[1][");
	strcat(alert, text);
	strcat(alert, "|Gemdos error #");
	ltoa(en, num, 10);
	strcat(alert, num);
	strcat(alert, "|");
	switch((int)en)
	{
		case EINVFN	:		/* invalid function */
			strcat(alert,"UngÅltiger Funktionsaufruf");		break;		case EFILNF	:		/* file not found */			strcat(alert,"Datei nicht gefunden");		break;		case EPTHNF	:		/* path not found */			strcat(alert,"Pfad nicht gefunden");		break;		case ENHNDL	:		/* no more handles */			strcat(alert,"Keine Dateihandles mehr frei");		break;		case EACCDN	:		/* access denied */			strcat(alert,"Zugriff verweigert");		break;		case EIHNDL	:		/* invalid handle */			strcat(alert,"UngÅltiges Handle");		break;		case ENSMEM	:		/* insufficient memory */			strcat(alert,"Nicht genÅgend Speicher");		break;		case EIMBA	:		/* invalid memory block address */			strcat(alert,"UngÅltige Speicherblock-Adresse");		break;		case EDRIVE	:		/* invalid drive specification */			strcat(alert,"UngÅltiges Laufwerk");		break;		case EXDEV	:		/* cross device rename */			strcat(alert,"LaufwerksÅbergreifendes Rename");		break;		case ENMFIL	:		/* no more files (from fsnext) */			strcat(alert,"Keine weiteren Dateien");		break;		case ELOCKED:		/* record is locked already */			strcat(alert,"Bereits gesperrt");		break;		case ENSLOCK:		/* invalid lock removal request */			strcat(alert,"Aufheben der Sperre|nicht zulÑssig");		break;		case ERANGE	:		/* range error */			strcat(alert,"Bereichsfehler|(z.B. Dateiname zu lang)");		break;		case EINTRN	:		/* internal error */			strcat(alert,"Interner Fehler");		break;		case EPLFMT	:		/* invalid program load format */			strcat(alert,"UngÅltiges Programm-Datei Format");		break;		case EGSBF	:		/* memory block growth failure */			strcat(alert,"Speicherblock kann nicht|vergrîûert werden");		break;		case ELOOP	:		/* too many symbolic links */			strcat(alert,"Zu viele symbolische Links");		break;		case EPIPE	:		/* broken pipe */			strcat(alert,"Broken pipe");		break;
		default:
			strcat(alert,"(Kein Fehlertext verfÅgbar)");		break;	}
	strcat(alert,"][Cancel]");
	form_alert(1,alert);
}



int unselect_3d(OBJECT *tree, int ob)
{	/* Ggf. selektierte 3D-Rahmen deselektieren */
	/* Gibt 1 zurÅck, falls deselektiert wurde, sonst 0 */
	int f3d, dum;
	
	if((wwork_out[13]<16)||(appl_getinfo(13,&f3d,&dum,&dum,&dum)==0) || (f3d==0))
	{
		tree[ob].ob_state &=(~SELECTED);
		return(1);
	}
	return(0);
}


/*---------------------------------------------------------------*/
/* Clipboard-Utilities    */
/*---------------------------------------------------------------*/



int write_clipboard(char *name)
{
	/* ôffnet die Clipboard-Datei 'name' zum Schreiben */
	/* und liefert das Dateihandle */
	/* Ist ein Fehler aufgetreten, wird der Gemdos-Code (negativ) geliefert */
	
	long	fh;
	char	path[256];

	clear_clipboard();	
	clip_path(path);
	
	strcat(path, name);
	fh=Fcreate(path, 0);
	return((int)fh);
}

int read_clipboard(char *name, char *dpath)
{
	/* ôffnet die erste Clipboard-Datei, die auf 'name' paût
		 zum Lesen und liefert das Dateihandle
		 ACHTUNG! name muû groû genug sein, um den kompletten Namen
		 der geîffneten Datei aufzunehmen (wird nÑmlich darÅber Åbergeben)
		 und dpath muû genug Platz fÅr den Pfad bieten oder NULL sein.
		 Der Clippfad wird immer, der Name nur im Erfolgsfall geschrieben
		 Ist ein Fehler aufgetreten (leeres Clipboard) wird -1 geliefert
	*/
	
	long	fh;
	char	path[256], opath[256];
	DTA		*old=Fgetdta(), dta;
	
	clip_path(path);
	strcpy(opath, path);
	if(dpath != NULL)	strcpy(dpath, path);
	strcat(path, name);
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))
		strcat(opath, dta.d_fname);
	Fsetdta(old);
	
	fh=Fopen(opath, FO_READ);
	if(fh < 0)
		return(-1);

	strcpy(name, dta.d_fname);
	
	return((int)fh);
}

int sread_clipboard(char *name)
{	/* Simple Read Clipboard. Gibt weder Name noch Pfad der geîffneten
		 Datei zurÅck sondern nur das Filehandle oder -1 */
	char	nbuf[64];
	
	strcpy(nbuf, name);
	return(read_clipboard(nbuf, NULL));
}

void clear_clipboard(void)
{
	/* Lîscht alle SCRAP.* aus dem Clipboard */
	char	path[256], dpath[256], dfile[256];
	DTA		*old=Fgetdta(), dta;	

	clip_path(dpath);
	strcpy(path, dpath);
	strcat(path, "SCRAP.*");
	Fsetdta(&dta);
	
	if(!Fsfirst(path, 0))
	{
		do
		{
			strcpy(dfile, dpath);
			strcat(dfile, dta.d_fname);
			Fdelete(dfile);
		}while(!Fsnext());
	}
	Fsetdta(old);
}

void clip_path(char *dst)
{
	/* Schreibt den Clipboard-Pfad in dst. Clipboard wird ggf.
		 angelegt.
		 Pfad endet immer auf '\'
	*/
	long	ssp;
	char	path[256], *tosscrap;
	
	path[0]=0;

	if(!(scrp_read(path) && path[0]))
	{ /* Clipboard suchen und anlegen */
		shel_envrn(&tosscrap, "CLIPBRD");
	  if (!tosscrap) 
	  {
		  shel_envrn(&tosscrap, "SCRAPDIR");
		  if (!tosscrap)
			{
				tosscrap ="X:\\CLIPBRD";
				ssp = Super(0L);
				*tosscrap = (char) (*((int *) 0x446)+65);    /* Bootlaufwerk */
				Super((void*)ssp);
			}
			else
				++tosscrap;
		}
		else
			++tosscrap;

		strcpy(path, tosscrap);
		if(path[strlen(path)-1] != '\\')
			strcat(path,"\\");

		scrp_write(path);
	}/* end not exist */

	if(path[strlen(path)-1] != '\\')
		strcat(path,"\\");

	strcpy(dst, path);
}


int wind_get(int w_hnd, int func, int *p1, int *p2, int *p3, int *p4) 
{ 
 
 AESPB  c; 
 c.contrl=_GemParBlk.contrl; 
 c.global=_GemParBlk.global; 
 c.intin=_GemParBlk.intin; 
 c.intout=_GemParBlk.intout; 
 
 _GemParBlk.contrl[0]=104; 
 _GemParBlk.contrl[1]=2; 
 _GemParBlk.contrl[2]=5; 
 _GemParBlk.contrl[3]=0; 
 _GemParBlk.contrl[4]=0; 
 
 _GemParBlk.intin[0]=w_hnd; 
 _GemParBlk.intin[1]=func; 
 
 _crystal(&c); 
 
 if(p1) *p1=_GemParBlk.intout[1]; 
 if(p2) *p2=_GemParBlk.intout[2]; 
 if(p3) *p3=_GemParBlk.intout[3]; 
 if(p4) *p4=_GemParBlk.intout[4]; 
 
 return(_GemParBlk.intout[0]); 
} 
int wind_set(int w_hnd, int func, int p1, int p2, int p3, int p4) 
{ 
 
 AESPB  c; 
 c.contrl=_GemParBlk.contrl; 
 c.global=_GemParBlk.global; 
 c.intin=_GemParBlk.intin; 
 c.intout=_GemParBlk.intout; 
 
 _GemParBlk.contrl[0]=105; 
 _GemParBlk.contrl[1]=6; 
 _GemParBlk.contrl[2]=1; 
 _GemParBlk.contrl[3]=0; 
 _GemParBlk.contrl[4]=0; 
 
 _GemParBlk.intin[0]=w_hnd; 
 _GemParBlk.intin[1]=func; 
 _GemParBlk.intin[2]=p1; 
 _GemParBlk.intin[3]=p2; 
 _GemParBlk.intin[4]=p3; 
 _GemParBlk.intin[5]=p4; 
 
 _crystal(&c); 
 
 return(_GemParBlk.intout[0]); 
} 

