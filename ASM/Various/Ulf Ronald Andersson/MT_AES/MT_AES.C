/****************************************************************
*
*	Tabulatorweite: 5
*
* Dieses Modul enthÑlt MT-sichere AES-Funktionen.
*
* Man beachte, daû die MT-Variante der AES- Funktionen gegenÅber
* dem Standard-Binding grundsÑtzlich das global[]- Feld mit
* Åbergeben muû. Auch wenn TOS und MagiC dieses Feld nur bei den
* folgenden Funktionen benîtigen:
*
*  WORD MT_appl_init( WORD *global );
*  WORD MT_rsrc_load( char *filename, WORD *global );
*  WORD MT_rsrc_free( WORD *global );
*  WORD MT_rsrc_gaddr( WORD type, WORD index, OBJECT **addr,
*				WORD *global )
*  WORD MT_rsrc_saddr( WORD type, WORD index, OBJECT *o,
*				WORD *global );
*  WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global );
*
* , so brauchen doch MutliTOS und N.AES das global[]- Feld bei
* jedem AES-Aufruf, da sie selbst den Taskwitch nicht beherrschen
* und die Ressourcen nicht zuweisen kînnen. Dort ist die ap_id
* wie ein VDI-Workstation-Handle zu verstehen, wÑhrend in TOS
* und MagiC die ap_id direkt die Task beschreibt.
*
* Um die Programmierung des AES zu vereinfachen, enthÑlt
* MT_AES.H fÅr jede AES-Funktion auûer den oben aufgefÅhrten ein
* Makro, das automatisch das global-Feld mit Åbergibt. Dabei ist
* darauf zu achten, daû im jeweiligen Aufrufkontext das richtige
* global[] Åbergeben wird. Sicherer ist der Verzicht auf die
* Makros und die direkte Verwendung der MT_xxx()- Funktionen.
*
* Jeder Thread muû also sein eigenes Array:
*	WORD global[15]
* haben.
*
*
* Bei einigen Funktionen wurde ein einfacheres Binding
* verwendet. Betroffen sind:
*
*	evnt_button( WORD nclicks, WORD mask, WORD state,
*				EVNTDATA *ev );
*	evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev );
*	objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g );
*	form_center( OBJECT *tree, GRECT *g );
*
*
* Bei anderen Funktionen ist nur die erweiterte Variante
* vorhanden:
*
*	WORD form_xdo( OBJECT *tree, WORD startob,
*			WORD *cursor_obj, void *scantab, void *flyinf );
*	WORD form_xdial( WORD subfn,
*				GRECT *lg, GRECT *bg,
*				void **flyinf );
*
* Entwickelt mit und fÅr PureC 1.1.
* Damit sich der Quelltext leicht portieren lÑût, wird mit
* portab.h gearbeitet.
*
* Andreas Kromke
* 16.3.96
*
*	énderungen:
*
* -	7.7.96
*	wind_set_string() ergÑnzt
* -	26.7.96
*	global-Feld fÅr MultiTOS und N.AES ergÑnzt.
* -	10.9.96 (sb)
*	-	form_xdial() korrigiert
*	-	diverse #defines im Header hinzugefÅgt, Deklarationen
*		korrigiert
*	-	global und _GemParBlk in MT_AESS.S definiert (KompatibilitÑt)
*	-	fÅr wdlg_xx(), lbox_xx() und fnts_xx() die 
*		Typen DIALOG, LIST_BOX und FNT_DIALOG hinzugefÅgt
* -	11.9.96 (sb)
*	-	Definition von SLCT_ITEM, SET_ITEM und UTXT_FN korrigiert
*	-	__aes() bekommt keinen AESPB als Parameter, sondern legt
*		ihn auf dem Stack an
*	-	alle #define-AusdrÅcke im Header verwenden als letzten
*		Parameter statt global 0L. In diesem Fall wieder im AESPB
*		_GemParBlk.global eingetragen, und der AES-Aufruf wird kÅrzer.
*	-	global ist nicht mehr als extern deklariert, sondern nur
*		noch Åber GemParBlk zu erreichen (kompatibel zu Pure C)
*	-	MT_EVNT_multi() hinzugefÅgt
*	-	_appl_yield() in MT_AESS.S hinzugefÅgt
*	-	MT_fnts_update() hinzugefÅgt
* -	12.9.96 (sb)
*	-	MT_wind_get() korrigiert
* -	13.9.96 (sb)
*	-	MT_appl_getinfo() hinzugefÅgt
* -	15.9.96 (sb)
*	-	MT_objc_xedit() hinzugefÅgt
*	-	MT_form_dial() hinzugefÅgt
*	-	MT_form_do() hinzugefÅgt
* -	18.9.96 (sb)
*	-	MT_xfrm_popup() besetzt intout[1] vor dem Aufruf, um auch bei
*		fehlender Funktion sinnvolle Ergebnisse zurÅckzuliefern.
* -	3.10.96 (sb)
*		MT_fnts_do() korrigiert (falsche Funktionsnummer)
* -	7.11.96
*		in MT_AES.H fehlte das MT_ vor der define-Anweisung fÅr form_error()
* -	27.11.96 (sb)
*		MT_wdlg_close(), MT_fnts_close() und MT_pdlg_close() wegen RÅckgabe
*		der Dialogkoordinaten modifiziert.
* -	3.12.96 (sb)
*		MT_lbox_set_slider() -> MT_lbox_set_asldr()
*		MT_lbox_scroll_to() -> MT_lbox_ascroll_to()
*		wegen Konflikten mit MT_AES.H
* - 29.12.96
*		MT_wind_get() um den fÅr WF_DCOLOR benîtigten
*		intin[2]-Eingabewert ergÑnzt.
*
* - 12.01.97
*		MT_fnts_get_name() korrigiert
* - 30.01.97
*		MT_form_xdial() korrigiert
*
* -	20.2.97 (sb)
*	-	Schalter MT_OLDWAY fÅr wdlg_close()/fnts_close() eingebaut
*	-	Nachbildung fÅr (u)int8/(u)int16/(u)int32 eingebaut falls Types2B.h
*		nicht vorhanden ist
*	-	Definition von PDLG_SUB/DRV_INFO eingefÅgt, damit Åber 
*		pdlg_add_sub_dialogs() Unterdialoge hinzugefÅgt werden kînnen
*
* - 18.07.97
*		MT_wind_set_int() ergÑnzt
*		MT_wind_get_int() ergÑnzt
*		MT_wind_get_ptr_int() ergÑnzt
*		MT_objc_wdraw() ergÑnzt
*		MT_objc_wchange() ergÑnzt
*		MT_graf_wwatchbox() ergÑnzt
*		MT_form_wbutton() ergÑnzt
*		MT_form_wkeybd() ergÑnzt
*		MT_objc_wedit() ergÑnzt
*		_mt_aes() nach MT_AES.H fÅr LowLevel-Interface
* - 21.02.98
*		MT_pdlg_get_setsize() korrigiert
*
* - 27.02.98 (sb)
*		MT_EDIT eingefÅgt
*		Strukturen fÅr Druckdialog ausgegliedert: PRDIALOG.H
*		Strukturen fÅr Druckereinstellung ausgegliedert: PRSETTING.H
*
****************************************************************/

#include	"mt_aes.h"

#if 0

static void __aes( PARMDATA *d, WORD *ctrldata, WORD *global )
{
	AESPB	pb;
	WORD	*c;

	c = d->contrl;
	pb.contrl = c;

	if ( global )				/* wurde global Åbergeben? */
		pb.global	= global;
	else						/* _GemParBlk.global fÅr Hauptprogramm */
		pb.global = _GemParBlk.global;

	pb.intin	= d->intin;
	pb.intout = d->intout;
	pb.addrin = d->addrin;
	pb.addrout = d->addrout;

	*c++ = *ctrldata++;			/* contrl[0..3] besetzen */
	*c++ = *ctrldata++;
	*c++ = *ctrldata++;
	*c++ = *ctrldata;

	_crystal( &pb );
}

#else						/* Assembler-Funktion aufrufen */

#define	__aes( d, ctrldata, global ) \
			_mt_aes( d, ctrldata, global )

#endif

/****************************************************************
*
* (10)	appl_init
*
****************************************************************/

WORD	MT_appl_init( WORD *global )
{
	PARMDATA d;
	static WORD	c[] = { 10, 0, 1, 0 };

	d.intout[0] = -1;			/* wichtig, falls AES nicht da */
	__aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (11)	appl_read
*
****************************************************************/

WORD MT_appl_read( WORD apid, WORD len, void *buf, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {11,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (12)	appl_write
*
****************************************************************/

WORD MT_appl_write( WORD apid, WORD len, void *buf, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {12,2,1,1};

	d.intin[0]	= apid;
	d.intin[1]	= len;
	d.addrin[0]	= buf;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (13)	appl_find
*
****************************************************************/

WORD MT_appl_find( char *apname, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {13,0,1,1};

	d.addrin[0]	= apname;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (14)	appl_tplay
*
****************************************************************/

WORD MT_appl_tplay( void *mem, WORD len, WORD scale, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {14,2,1,1};

	d.intin[0]	= len;
	d.intin[1]	= scale;
	d.addrin[0]	= mem;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (15)	appl_trecord
*
****************************************************************/

WORD MT_appl_trecord( void *mem, WORD len, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {15,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= mem;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (16)	appl_bvset
*
****************************************************************/

/* ... gibt's nich */


/****************************************************************
*
* (17)	appl_yield
*
****************************************************************/

void MT_appl_yield( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {17,0,1,0};

	__aes( &d, c, global );
}


/****************************************************************
*
* (18)	appl_search
*
****************************************************************/

WORD MT_appl_search( WORD mode, char *name, WORD *type, WORD *id,
						WORD *global )
{
	PARMDATA d;
	static WORD c[] = {18,0,1,0};

	d.intin[0]	= mode;
	d.addrin[0]	= name;
	__aes( &d, c, global );
	*type	= d.intout[1];
	*id = d.intout[2];
	return( d.intout[0] );
}


/****************************************************************
*
* (19)	appl_exit
*
****************************************************************/

WORD MT_appl_exit( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {19,0,1,0};

	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (130)	appl_getinfo
*
****************************************************************/

WORD	MT_appl_getinfo( WORD ap_gtype,
				WORD *ap_gout1, WORD *ap_gout2,
				WORD *ap_gout3, WORD *ap_gout4, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 130, 1, 5,0 };

	d.intin[0]	= ap_gtype;
	__aes( &d, c, global );

	if ( ap_gout1 )
		*ap_gout1 = d.intout[1];
	if ( ap_gout2 )
		*ap_gout2 = d.intout[2];
	if ( ap_gout3 )
		*ap_gout3 = d.intout[3];
	if ( ap_gout4 )
		*ap_gout4 = d.intout[4];

	return( d.intout[0] );
}


/****************************************************************
*
* (20)	evnt_keybd
*
****************************************************************/

WORD MT_evnt_keybd( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {20,0,1,0};

	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (21)	evnt_button
*
****************************************************************/

WORD MT_evnt_button( WORD nclicks, WORD mask, WORD state,
				EVNTDATA *ev, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {21,3,5,0};

	d.intin[0]	= nclicks;
	d.intin[1]	= mask;
	d.intin[2]	= state;
	__aes( &d, c, global );
	ev->x = d.intout[1];
	ev->y = d.intout[2];
	ev->bstate = d.intout[3];
	ev->kstate = d.intout[4];
	return(d.intout[0]);			/* nclicks */
}


/****************************************************************
*
* (22)	evnt_mouse
*
****************************************************************/

WORD MT_evnt_mouse( WORD flg_leave, GRECT *g, EVNTDATA *ev,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {22,5,5,0};

	d.intin[0]	= flg_leave;
	*((GRECT *)(d.intin+1))	= *g;
	__aes( &d, c, global );
	ev->x = d.intout[1];
	ev->y = d.intout[2];
	ev->bstate = d.intout[3];
	ev->kstate = d.intout[4];
	return(d.intout[0]);
}


/****************************************************************
*
* (23)	evnt_mesag
*
****************************************************************/

WORD MT_evnt_mesag( WORD *buf, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {23,0,1,1};

	d.addrin[0]	= buf;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (24)	evnt_timer
*
****************************************************************/

WORD MT_evnt_timer( ULONG ms, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {24,2,1,0};

	d.intin[0] = (WORD) ms;			/* Intel: erst Low */
	d.intin[1] = (WORD) (ms>>16L);	/* Intel: dann High */
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (25)	evnt_multi
*
****************************************************************/

WORD MT_evnt_multi(
			WORD evtypes,
			WORD nclicks, WORD bmask, WORD bstate,
			WORD flg1_leave, GRECT *g1,
			WORD flg2_leave, GRECT *g2,
			WORD *msgbuf,
			ULONG ms,
			EVNTDATA *ev,
			WORD *keycode,
			WORD *nbclicks,
			WORD *global
			)
{
	PARMDATA d;
	static WORD c[] = {25,16,7,1};

	d.intin[0] = evtypes;
	d.intin[1] = nclicks;
	d.intin[2] = bmask;
	d.intin[3] = bstate;

	if	( evtypes & MU_M1 )
	{
		d.intin[4] = flg1_leave;
		*((GRECT *)(d.intin+5))	= *g1;
	}
	
	if	( evtypes & MU_M2 )
	{
		d.intin[9] = flg2_leave;
		*((GRECT *)(d.intin+10)) = *g2;
	}

	d.intin[14] = (WORD) ms;			/* Intel: erst Low */
	d.intin[15] = (WORD) (ms>>16L);	/* Intel: dann High */
	d.addrin[0] = msgbuf;
	__aes( &d, c, global );
	ev->x		= d.intout[1];
	ev->y		= d.intout[2];
	ev->bstate	= d.intout[3];
	ev->kstate	= d.intout[4];
	*keycode		= d.intout[5];
	*nbclicks		= d.intout[6];
	return(d.intout[0]);
}

void	MT_EVNT_multi( WORD evtypes, WORD nclicks, WORD bmask, WORD bstate,
							MOBLK *m1, MOBLK *m2, ULONG ms,
							EVNT *event, WORD *global )
{
	static WORD	c[] = { 25, 16, 7, 1 };
	PARMDATA	d;
	WORD	*intout;
	WORD	*ev;

	d.intin[0] = evtypes;
	d.intin[1] = nclicks;
	d.intin[2] = bmask;
	d.intin[3] = bstate;

	if	( evtypes & MU_M1 )					/* Mausrechteck 1? */
		*((MOBLK *)( d.intin + 4 )) = *m1;

	if	( evtypes & MU_M2 )					/* Mausrechteck 2? */
		*((MOBLK *)( d.intin + 9 )) = *m2;

	d.intin[14] = (WORD) ms;					/* Wîrter drehen */
	d.intin[15] = (WORD) ( ms >> 16L );
	d.addrin[0] = event->msg;				/* Nachrichtenbuffer */
	__aes( &d, c, global );
	
	ev = (WORD *) event;					/* EVNT-Struktur besetzen */
	intout = d.intout;
	*ev++ = *intout++;						/* mwhich */
	*ev++ = *intout++;						/* mx */
	*ev++ = *intout++;						/* my */
	*ev++ = *intout++;						/* mbutton */
	*ev++ = *intout++;						/* kstate */
	*ev++ = *intout++;						/* key */
	*ev++ = *intout++;						/* mclicks */
}

/****************************************************************
*
* (26)	evnt_dclicks
*
****************************************************************/

WORD MT_evnt_dclicks( WORD val, WORD setflg, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {26,2,1,0};

	d.intin[0] = val;
	d.intin[1] = setflg;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (30)	menu_bar
*
****************************************************************/

WORD MT_menu_bar( OBJECT *tree, WORD show, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {30,1,1,1};

	d.intin[0] 	= show;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (31)	menu_icheck
*
****************************************************************/

WORD MT_menu_icheck( OBJECT *tree, WORD objnr, WORD chkflg,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {31,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (32)	menu_ienable
*
****************************************************************/

WORD MT_menu_ienable( OBJECT *tree, WORD objnr, WORD chkflg,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {32,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (33)	menu_tnormal
*
****************************************************************/

WORD MT_menu_tnormal( OBJECT *tree, WORD objnr, WORD chkflg,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {33,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= chkflg;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (34)	menu_text
*
****************************************************************/

WORD MT_menu_text( OBJECT *tree, WORD objnr, const char *text,
			WORD *global )
{
	PARMDATA d;
	static WORD c[] = {34,1,1,2};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	d.addrin[1] 	= text;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (35)	menu_register
*
****************************************************************/

WORD MT_menu_register( WORD apid, const char *text, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {35,1,1,1};

	d.intin[0] 	= apid;
	d.addrin[0]	= text;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (36)	menu_unregister
*
****************************************************************/

WORD MT_menu_unregister( WORD menuid, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {36,1,1,0};

	d.intin[0] 	= menuid;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
*  		menu_popup
*
****************************************************************/

WORD MT_menu_popup( MENU *menu, WORD x, WORD y, MENU *data,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {36,2,1,2};

	d.intin[0] 	= x;
	d.intin[1] 	= y;
	d.addrin[0] 	= menu;
	d.addrin[1] 	= data;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (37)	menu_click
*
****************************************************************/

WORD MT_menu_click( WORD val, WORD setflag, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {37,2,1,0};


	d.intin[0] 	= val;
	d.intin[1] 	= setflag;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* 		menu_attach
*
****************************************************************/

WORD MT_menu_attach( WORD flag, OBJECT *tree, WORD obj,
				MENU *data, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {37,2,1,2};

	d.intin[0] 	= flag;
	d.intin[1] 	= obj;
	d.addrin[0] 	= tree;
	d.addrin[1] 	= data;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (38)	menu_istart
*
****************************************************************/

WORD MT_menu_istart( WORD flag, OBJECT *tree, WORD menu, WORD item,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {38,3,1,1};

	d.intin[0] 	= flag;
	d.intin[1] 	= menu;
	d.intin[2] 	= item;
	d.addrin[0] 	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (39)	menu_settings
*
****************************************************************/

WORD MT_menu_settings( WORD flag, MN_SET *values, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {39,1,1,1};

	d.intin[0] 	= flag;
	d.addrin[0] 	= values;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (40)	objc_add
*
****************************************************************/

WORD MT_objc_add( OBJECT *tree, WORD parent, WORD child, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {40,2,1,1};

	d.intin[0] 	= parent;
	d.intin[1] 	= child;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (41)	objc_delete
*
****************************************************************/

WORD MT_objc_delete( OBJECT *tree, WORD objnr, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {41,1,1,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (42)	objc_draw
*
****************************************************************/

WORD MT_objc_draw( OBJECT *tree, WORD start, WORD depth, GRECT *g,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {42,6,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	*((GRECT *)(d.intin+2))	= *g;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (43)	objc_find
*
****************************************************************/

WORD MT_objc_find( OBJECT *tree, WORD start, WORD depth,
				WORD x, WORD y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {43,4,1,1};

	d.intin[0] 	= start;
	d.intin[1] 	= depth;
	d.intin[2] 	= x;
	d.intin[3] 	= y;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (44)	objc_offset
*
****************************************************************/

WORD MT_objc_offset( OBJECT *tree, WORD objnr, WORD *x, WORD *y,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {44,1,3,1};

	d.intin[0] 	= objnr;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	*x	= d.intout[1];
	*y	= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (45)	objc_order
*
****************************************************************/

WORD MT_objc_order( OBJECT *tree, WORD objnr, WORD newpos, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {45,2,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= newpos;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (46)	objc_edit
*
****************************************************************/

WORD MT_objc_edit( OBJECT *tree, WORD objnr, WORD key,
				WORD *cursor_xpos, WORD subfn, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {46,4,2,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= key;
	d.intin[2] 	= *cursor_xpos;
	d.intin[3] 	= subfn;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	*cursor_xpos	= d.intout[1];
	return(d.intout[0]);
}

WORD MT_objc_xedit( OBJECT *tree, WORD objnr, WORD key,
				WORD *cursor_xpos, WORD subfn, GRECT *r, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {46,4,2,2};

	d.intin[0] 	= objnr;
	d.intin[1] 	= key;
	d.intin[2] 	= *cursor_xpos;
	d.intin[3] 	= subfn;
	d.addrin[0]	= tree;
	d.addrin[1]	= r;
	__aes( &d, c, global );
	*cursor_xpos	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (47)	objc_change
*
****************************************************************/

WORD MT_objc_change( OBJECT *tree, WORD objnr, WORD resvd,
				GRECT *g, WORD newstate, WORD redraw, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {47,8,1,1};

	d.intin[0] 	= objnr;
	d.intin[1] 	= resvd;		/* ggf. spÑter: WindowHandle */
	*((GRECT *)(d.intin+2))	= *g;
	d.intin[6] 	= newstate;
	d.intin[7] 	= redraw;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (48)	objc_sysvar
*
****************************************************************/

WORD	MT_objc_sysvar( WORD ob_smode, WORD ob_swhich, WORD ob_sival1,
				WORD ob_sival2, WORD *ob_soval1, WORD *ob_soval2,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {48,4,3,0};

	d.intin[0] = ob_smode;
	d.intin[1] = ob_swhich;
	d.intin[2] = ob_sival1;
	d.intin[3] = ob_sival2;
	__aes( &d, c, global );
	*ob_soval1 = d.intout[1];
	*ob_soval2 = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (50)	form_(x)do
*
****************************************************************/

WORD MT_form_do( OBJECT *tree, WORD startob, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {50,1,1,1};

	d.intin[0] 	= startob;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_form_xdo( OBJECT *tree, WORD startob,
			WORD *cursor_obj,
			XDO_INF *scantab, void *flyinf,
			WORD *global )
{
	PARMDATA d;
	static WORD c[] = {50,1,2,3};

	d.intin[0] 	= startob;
	d.addrin[0]	= tree;
	d.addrin[1]	= scantab;
	d.addrin[2]	= flyinf;
	__aes( &d, c, global );
	*cursor_obj	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (51)	form_(x)dial
*
****************************************************************/

WORD	MT_form_dial( WORD subfn, GRECT *lg, GRECT *bg, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {51,9,1,0};

	d.intin[0] 	= subfn;
	if	(lg)
		*((GRECT *)(d.intin+1))	= *lg;
	*((GRECT *)(d.intin+5))	= *bg;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_form_xdial( WORD subfn, GRECT *lg, GRECT *bg,
				void **flyinf,	WORD *global )
{
	PARMDATA d;
	static WORD c[] = {51,9,1,2};

	d.intin[0] 	= subfn;
	if	(lg)
		*((GRECT *)(d.intin+1))	= *lg;
	*((GRECT *)(d.intin+5))	= *bg;
	d.addrin[0]	= flyinf;
	d.addrin[1]	= 0;		/* reserviert */
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (52)	form_alert
*
****************************************************************/

WORD MT_form_alert( WORD defbutton, const char *string, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {52,1,1,1};

	d.intin[0] 	= defbutton;
	d.addrin[0]	= string;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (53)	form_error
*
****************************************************************/

WORD MT_form_error( WORD dosenkot, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {53,1,1,0};

	d.intin[0] 	= dosenkot;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (54)	form_center
*
****************************************************************/

WORD MT_form_center( OBJECT *tree, GRECT *g, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {54,0,5,1};

	d.addrin[0]	= tree;
	__aes( &d, c, global );
	*g = *((GRECT *)(d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (55)	form_keybd
*
****************************************************************/

WORD MT_form_keybd( OBJECT *tree, WORD obj, WORD nxt, WORD key,
				WORD *nextob, WORD *nextchar, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {55,3,3,1};

	d.intin[0]	= obj;
	d.intin[1]	= key;
	d.intin[2]	= nxt;
	d.addrin[0]	= tree;
	__aes( &d, c, global );

	*nextob		= d.intout[1];
	*nextchar		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (56)	form_button
*
****************************************************************/

WORD MT_form_button( OBJECT *tree, WORD obj, WORD nclicks,
				WORD *nextob, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {56,2,2,1};

	d.intin[0]	= obj;
	d.intin[1]	= nclicks;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	*nextob		= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (60)	objc_wdraw	(ab 11.12.96, V5.10)
*
****************************************************************/

void MT_objc_wdraw(	OBJECT *tree, WORD object, WORD depth,
				GRECT *clip, WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {60,3,0,2};

	d.intin[0] = object;
	d.intin[1] = depth;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;
	d.addrin[1] = clip;

	__aes( &d, c, global );
}


/****************************************************************
*
* (61)	objc_wchange	(ab 11.12.96, V5.10)
*
****************************************************************/

void MT_objc_wchange( OBJECT *tree, WORD object, WORD newstate,
				GRECT *clip, WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {61,3,0,2};

	d.intin[0] = object;
	d.intin[1] = newstate;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;
	d.addrin[1] = clip;

	__aes( &d, c, global );
}


/****************************************************************
*
* (62)	objc_wwatchbox	(ab 11.12.96, V5.10)
*
****************************************************************/

WORD MT_graf_wwatchbox( OBJECT *tree, WORD object, WORD instate,
				WORD outstate,	WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {62,4,1,1};

	d.intin[0] = object;
	d.intin[1] = instate;
	d.intin[2] = outstate;
	d.intin[3] = windowhandle;

	d.addrin[0] = tree;

	__aes( &d, c, global );

	return(d.intout[0]);
}


/****************************************************************
*
* (63)	form_wbutton	(ab 11.12.96, V5.10)
*
****************************************************************/

WORD MT_form_wbutton( OBJECT *tree, WORD object, WORD nclicks,
				WORD *nextob, WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {63,3,2,1};

	d.intin[0] = object;
	d.intin[1] = nclicks;
	d.intin[2] = windowhandle;

	d.addrin[0] = tree;

	__aes( &d, c, global );

	*nextob = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (64)	form_wkeybd	(ab 11.12.96, V5.10)
*
****************************************************************/

WORD MT_form_wkeybd( OBJECT *tree,	WORD object, WORD nextob,
				WORD ichar, WORD *onextob, WORD *ochar,
				WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {64,3,3,1};

	d.intin[0] = object;
	d.intin[1] = ichar;
	d.intin[2] = nextob;
	d.intin[3] = windowhandle;

	d.addrin[0] = tree;

	__aes( &d, c, global );

	*ochar = d.intout[2];
	*onextob = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (65)	objc_wedit	(ab 11.12.96, V5.10)
*
****************************************************************/

WORD MT_objc_wedit( OBJECT *tree, WORD object, WORD edchar,
				WORD *didx, WORD kind, WORD windowhandle,
				WORD *global)
{
	PARMDATA d;
	static WORD c[] = {65,5,2,1};

	d.intin[0] = object;
	d.intin[1] = edchar;
	d.intin[2] = *didx;
	d.intin[3] = kind;
	d.intin[4] = windowhandle;

	d.addrin[0] = tree;

	__aes( &d, c, global );

	*didx = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (70)	graf_rubberbox
*
****************************************************************/

WORD MT_graf_rubberbox( int x, int y, int begw, int begh,
				int *endw, int *endh, WORD *global)
{
	PARMDATA d;
	static WORD c[] = {70,4,3,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.intin[2]	= begw;
	d.intin[3]	= begh;
	__aes( &d, c, global );
	*endw		= d.intout[1];
	*endh		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (71)	graf_dragbox
*
****************************************************************/

WORD MT_graf_dragbox( WORD w, WORD h, WORD begx, WORD begy,
				GRECT *g, WORD *endx, WORD *endy, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {71,8,3,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	*((GRECT *)(d.intin+4))	= *g;
	__aes( &d, c, global );
	*endx		= d.intout[1];
	*endy		= d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (72)	graf_movebox
*
****************************************************************/

WORD MT_graf_movebox( WORD w, WORD h, WORD begx, WORD begy,
				WORD endx, WORD endy, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {72,6,1,0};

	d.intin[0]	= w;
	d.intin[1]	= h;
	d.intin[2]	= begx;
	d.intin[3]	= begy;
	d.intin[4]	= endx;
	d.intin[5]	= endy;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (73)	graf_growbox
*
****************************************************************/

WORD MT_graf_growbox( GRECT *startg, GRECT *endg, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {73,8,1,0};

	*((GRECT *)(d.intin))	= *startg;
	*((GRECT *)(d.intin+4))	= *endg;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (74)	graf_shrinkbox
*
****************************************************************/

WORD MT_graf_shrinkbox( GRECT *endg, GRECT *startg, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {74,8,1,0};

	*((GRECT *)(d.intin))	= *endg;
	*((GRECT *)(d.intin+4))	= *startg;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (75)	graf_watchbox
*
****************************************************************/

WORD MT_graf_watchbox( OBJECT *tree, WORD obj, WORD instate,
				WORD outstate, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {75,4,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.intin[2]	= instate;
	d.intin[3]	= outstate;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (76)	graf_slidebox
*
****************************************************************/

WORD MT_graf_slidebox( OBJECT *tree, WORD parent, WORD obj,
				WORD h, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {76,3,1,1};

	d.intin[0]	= parent;
	d.intin[1]	= obj;
	d.intin[2]	= h;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (77)	graf_(x)handle
*
****************************************************************/

WORD MT_graf_handle( WORD *wchar, WORD *hchar,
				WORD *wbox, WORD *hbox, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {77,0,5,0};

	__aes( &d, c, global );
	*wchar	= d.intout[1];
	*hchar	= d.intout[2];
	*wbox	= d.intout[3];
	*hbox	= d.intout[4];
	return(d.intout[0]);
}
WORD MT_graf_xhandle( WORD *wchar, WORD *hchar,
				WORD *wbox, WORD *hbox, WORD *device,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {77,0,6,0};

	__aes( &d, c, global );
	*wchar	= d.intout[1];
	*hchar	= d.intout[2];
	*wbox	= d.intout[3];
	*hbox	= d.intout[4];
	*device	= d.intout[5];
	return(d.intout[0]);
}


/****************************************************************
*
* (78)	graf_mouse
*
****************************************************************/

WORD MT_graf_mouse( WORD code, MFORM *adr, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {78,1,1,1};

	d.intin[0]	= code;
	d.addrin[0]	= adr;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (79)	graf_mkstate
*
****************************************************************/

WORD MT_graf_mkstate( EVNTDATA *ev, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {79,0,5,0};

	__aes( &d, c, global );
	*ev		= *((EVNTDATA *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (80)	scrp_read
*
****************************************************************/

WORD MT_scrp_read( char *path, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {80,0,1,1};

	d.addrin[0]	= path;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (81)	scrp_write
*
****************************************************************/

WORD MT_scrp_write( char *path, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {81,0,1,1};

	d.addrin[0]	= path;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (82)	scrp_clear
*
****************************************************************/

WORD MT_scrp_clear( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {82,0,1,0};

	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (90)	fsel_input
*
****************************************************************/

WORD MT_fsel_input( char *path, char *name, WORD *button,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {90,0,2,2};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	__aes( &d, c, global );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (91)	fsel_exinput
*
****************************************************************/

WORD MT_fsel_exinput( char *path, char *name, WORD *button,
				char *label, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {91,0,2,3};

	d.addrin[0]	= path;
	d.addrin[1]	= name;
	d.addrin[2]	= label;
	__aes( &d, c, global );
	*button	= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (100)	wind_create
*
****************************************************************/

WORD MT_wind_create( WORD kind, GRECT *maxsize, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {100,5,1,0};

	d.intin[0]	= kind;
	*((GRECT *)(d.intin+1))	= *maxsize;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (101)	wind_open
*
****************************************************************/

WORD MT_wind_open( WORD whdl, GRECT *g, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {101,5,1,0};

	d.intin[0]	= whdl;
	*((GRECT *)(d.intin+1))	= *g;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (102)	wind_close
*
****************************************************************/

WORD MT_wind_close( WORD whdl, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {102,1,1,0};

	d.intin[0]	= whdl;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (103)	wind_delete
*
****************************************************************/

WORD MT_wind_delete( WORD whdl, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {103,1,1,0};

	d.intin[0]	= whdl;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (104)	wind_get
*
****************************************************************/

WORD MT_wind_get( WORD whdl, WORD subfn,
			WORD *g1, WORD *g2, WORD *g3, WORD *g4, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 104, 3, 5, 0 };	/* 3 (!) intin */

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	if	(g1)
		d.intin[2] = *g1;		/* fÅr WF_DCOLOR */
	__aes( &d, c, global );

	if ( g1 )
		*g1 = d.intout[1];
	if ( g2 )
		*g2 = d.intout[2];
	if ( g3 )
		*g3 = d.intout[3];
	if ( g4 )
		*g4 = d.intout[4];

	return( d.intout[0] );
}

WORD MT_wind_get_grect( WORD whdl, WORD subfn, GRECT *g, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	__aes( &d, c, global );
	*g = *((GRECT *) (d.intout+1));

	return( d.intout[0] );
}

WORD MT_wind_get_ptr( WORD whdl, WORD subfn, void **v, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	__aes( &d, c, global );
	*v = *((void **) (d.intout+1));

	return( d.intout[0] );
}

WORD MT_wind_get_int( WORD whdl, WORD subfn, WORD *g1, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 104, 2, 5, 0 };

	d.intin[0] = whdl;
	d.intin[1] = subfn;
	__aes( &d, c, global );
	if ( g1 )
		*g1 = d.intout[1];

	return( d.intout[0] );
}


/****************************************************************
*
* (105)	wind_set
*
****************************************************************/

WORD MT_wind_set( WORD whdl, WORD subfn,
		WORD g1, WORD g2, WORD g3, WORD g4, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {105,6,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	d.intin[2]	= g1;
	d.intin[3]	= g2;
	d.intin[4]	= g3;
	d.intin[5]	= g4;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_wind_set_string( WORD whdl, WORD subfn, char *s, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((char **) (d.intin+2)) = s;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_wind_set_grect( WORD whdl, WORD subfn, GRECT *g, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {105,6,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((GRECT *) (d.intin+2)) = *g;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_wind_set_int( WORD whdl, WORD subfn,
				WORD g1, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	d.intin[2]	= g1;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD MT_wind_set_ptr_int( WORD whdl, WORD subfn, void *s,
				WORD g3, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {105,4,1,0};

	d.intin[0]	= whdl;
	d.intin[1]	= subfn;
	*((char **) (d.intin+2)) = s;
	d.intin[4]	= g3;
	__aes( &d, c, global );
	return(d.intout[0]);
}




/****************************************************************
*
* (106)	wind_find
*
****************************************************************/

WORD MT_wind_find( WORD x, WORD y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {106,2,1,0};

	d.intin[0]	= x;
	d.intin[1]	= y;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (107)	wind_update
*
****************************************************************/

WORD MT_wind_update( WORD subfn, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {107,1,1,0};

	d.intin[0]	= subfn;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (108)	wind_calc
*
****************************************************************/

WORD MT_wind_calc( WORD subfn, WORD kind,
			GRECT *ing, GRECT *outg, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {108,6,5,0};

	d.intin[0]	= subfn;
	d.intin[1]	= kind;
	*((GRECT *) (d.intin+2)) = *ing;
	__aes( &d, c, global );
	*outg		= *((GRECT *) (d.intout+1));
	return(d.intout[0]);
}


/****************************************************************
*
* (109)	wind_new
*
****************************************************************/

void MT_wind_new( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {109,0,0,0};

	__aes( &d, c, global );
}


/****************************************************************
*
* (110)	rsrc_load
*
****************************************************************/

WORD MT_rsrc_load( char *filename, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {110,0,1,1};

	d.addrin[0]	= filename;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (111)	rsrc_free
*
****************************************************************/

WORD MT_rsrc_free( WORD *global )
{
	PARMDATA d;
	static WORD c[] = {111,0,1,0};

	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (112)	rsrc_gaddr
*
****************************************************************/

WORD MT_rsrc_gaddr( WORD type, WORD index, void *addr, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {112,2,1,0};

	d.intin[0]	= type;
	d.intin[1]	= index;
	__aes( &d, c, global );
	*((void **) addr) = d.addrout[0];
	return(d.intout[0]);
}


/****************************************************************
*
* (113)	rsrc_saddr
*
****************************************************************/

WORD MT_rsrc_saddr( WORD type, WORD index, void *o, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {113,2,1,1};

	d.intin[0]	= type;
	d.intin[1]	= index;
	d.addrin[0]	= o;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (114)	rsrc_obfix
*
****************************************************************/

WORD MT_rsrc_obfix( OBJECT *tree, WORD obj, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {114,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (115)	rsrc_obfix
*
****************************************************************/

WORD MT_rsrc_rcfix( RSHDR *rsh, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {115,0,1,1};

	d.addrin[0]	= rsh;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (120)	shel_read
*
****************************************************************/

WORD MT_shel_read( char *cmd, char *tail, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {120,0,1,2};

	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (121)	shel_write
*
****************************************************************/

WORD MT_shel_write( WORD doex, WORD isgr, WORD isover,
				char *cmd, char *tail, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {121,3,1,2};

	d.intin[0]	= doex;
	d.intin[1]	= isgr;
	d.intin[2]	= isover;
	d.addrin[0]	= cmd;
	d.addrin[1]	= tail;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (122)	shel_get
*
****************************************************************/

WORD MT_shel_get( char *buf, UWORD len, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {122,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (123)	shel_put
*
****************************************************************/

WORD MT_shel_put( char *buf, UWORD len, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {123,1,1,1};

	d.intin[0]	= len;
	d.addrin[0]	= buf;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (124)	shel_find
*
****************************************************************/

WORD MT_shel_find( char *path, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {124,0,1,1};

	d.addrin[0]	= path;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (125)	shel_envrn
*
****************************************************************/

WORD MT_shel_envrn( char **val, char *name, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {125,0,1,2};

	d.addrin[0]	= val;
	d.addrin[1]	= name;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (126)	shel_rdef
*
****************************************************************/

void MT_shel_rdef( char *fname, char *dir, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {126,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	__aes( &d, c, global );
}


/****************************************************************
*
* (127)	shel_wdef
*
****************************************************************/

void MT_shel_wdef( char *fname, char *dir, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {127,0,1,2};

	d.addrin[0]	= fname;
	d.addrin[1]	= dir;
	__aes( &d, c, global );
}

/****************************************************************
*
* (130)	xgrf_stepcalc
*
****************************************************************/

/****************************************************************
*
* (131)	xgrf_2box
*
****************************************************************/

/* ... brauchen wir nicht ... */


/****************************************************************
*
* (135)	form_popup
*		xfrm_popup (ab MagiC 5.03)
*
****************************************************************/

WORD MT_form_popup( OBJECT *tree, WORD x, WORD y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {135,2,1,1};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.addrin[0]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}
WORD MT_xfrm_popup(	OBJECT *tree, WORD x, WORD y,	WORD firstscrlob,
				WORD lastscrlob, WORD nlines,
				void	cdecl (*init)(OBJECT *tree, WORD scrollpos,
						 WORD nlines, void *param),
				void *param, WORD *lastscrlpos,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {135,6,2,3};

	d.intin[0]	= x;
	d.intin[1]	= y;
	d.intin[2]	= firstscrlob;
	d.intin[3]	= lastscrlob;
	d.intin[4]	= nlines;
	d.intin[5]	= *lastscrlpos;
	d.addrin[0]	= tree;
	d.addrin[1]	= init;
	d.addrin[2]	= param;

	d.intout[1] = *lastscrlpos;		/* vorbesetzen */

	__aes( &d, c, global );
	*lastscrlpos = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (136)	form_xerr
*
****************************************************************/

WORD MT_form_xerr( LONG errcode, char *errfile, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {136,2,1,1};

	*(LONG *) (d.intin)	= errcode;
	d.addrin[0]	= errfile;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (160)	wdlg_create
*
****************************************************************/

DIALOG *MT_wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree,
				void *user_data, WORD code, void *data,
				WORD flags, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {160,2,0,4};

	d.intin[0]	= code;
	d.intin[1]	= flags;
	d.addrin[0]	= handle_exit;
	d.addrin[1]	= tree;
	d.addrin[2]	= user_data;
	d.addrin[3]	= data;
	__aes( &d, c, global );
	return(d.addrout[0]);
}


/****************************************************************
*
* (161)	wdlg_open
*
****************************************************************/

WORD	MT_wdlg_open( DIALOG *dialog, char *title, WORD kind,
				WORD x, WORD y, WORD code, void *data,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {161,4,1,3};

	d.intin[0]	= kind;
	d.intin[1]	= x;
	d.intin[2]	= y;
	d.intin[3]	= code;
	d.addrin[0]	= dialog;
	d.addrin[1]	= title;
	d.addrin[2]	= data;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (162)	wdlg_close
*
****************************************************************/

#if MT_OLDWAY

WORD	MT_wdlg_close( DIALOG *dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {162,0,1,1};

	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}

#else

WORD	MT_wdlg_close( DIALOG *dialog, WORD *x, WORD *y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 162, 0, 3, 1 };

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0]	= dialog;
	__aes( &d, c, global );

	if	( x )
		*x = d.intout[1];
	if	( y )
		*y = d.intout[2];

	return( d.intout[0] );
}
#endif


/****************************************************************
*
* (163)	wdlg_delete
*
****************************************************************/

WORD	MT_wdlg_delete( DIALOG *dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {163,0,1,1};

	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (164)	wdlg_get
*
****************************************************************/

WORD	MT_wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {164,1,1,3};

	d.intin[0]	= 0;
	d.addrin[0]	= dialog;
	d.addrin[1]	= tree;
	d.addrin[2]	= r;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_wdlg_get_edit( DIALOG *dialog, WORD *cursor, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {164,1,2,1};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	*cursor		= d.intout[1];
	return(d.intout[0]);
}

void	*MT_wdlg_get_udata( DIALOG *dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {164,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

WORD	MT_wdlg_get_handle( DIALOG *dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {164,1,1,1};

	d.intin[0]	= 3;
	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (165)	wdlg_set
*
****************************************************************/

WORD	MT_wdlg_set_edit( DIALOG *dialog, WORD obj, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {165,2,1,1};

	d.intin[0]	= 0;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_wdlg_set_tree( DIALOG *dialog, OBJECT *new_tree, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {165,1,1,2};

	d.intin[0]	= 1;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_wdlg_set_size( DIALOG *dialog, GRECT *new_size, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {165,1,1,2};

	d.intin[0]	= 2;
	d.addrin[0]	= dialog;
	d.addrin[1]	= new_size;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title,
					OBJECT *tree, WORD obj,	WORD *global )
{
	PARMDATA d;
	static WORD c[] = {165,2,1,4};

	d.intin[0]	= 3;
	d.intin[1]	= obj;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title,
					OBJECT *tree, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {165,1,1,4};

	d.intin[0]	= 4;
	d.addrin[0]	= dialog;
	d.addrin[1]	= g;
	d.addrin[2]	= title;
	d.addrin[3]	= tree;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (166)	wdlg_evnt
*
****************************************************************/

WORD	MT_wdlg_evnt( DIALOG *dialog, EVNT *events, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {166,0,1,2};

	d.addrin[0]	= dialog;
	d.addrin[1]	= events;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (167)	wdlg_redraw
*
****************************************************************/

void	MT_wdlg_redraw( DIALOG *dialog, GRECT *rect, WORD obj,
				WORD depth, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {167,2,0,2};

	d.intin[0]	= obj;
	d.intin[1]	= depth;
	d.addrin[0]	= dialog;
	d.addrin[1]	= rect;
	__aes( &d, c, global );
}



/****************************************************************
*
* (170)	lbox_create
*
****************************************************************/

LIST_BOX *MT_lbox_create( OBJECT *tree, SLCT_ITEM slct,
					SET_ITEM set, LBOX_ITEM *items,
					WORD visible_a, WORD first_a,
					WORD *ctrl_objs, WORD *objs, WORD flags,
					WORD pause_a, void *user_data,
					void *dialog, WORD visible_b,
					WORD first_b, WORD entries_b,
					WORD pause_b, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {170,8,0,8};

	d.intin[0]	= visible_a;
	d.intin[1]	= first_a;
	d.intin[2]	= flags;
	d.intin[3]	= pause_a;
	d.intin[4]	= visible_b;
	d.intin[5]	= first_b;
	d.intin[6]	= entries_b;
	d.intin[7]	= pause_b;
	d.addrin[0]	= tree;
	d.addrin[1]	= slct;
	d.addrin[2]	= set;
	d.addrin[3]	= items;
	d.addrin[4]	= ctrl_objs;
	d.addrin[5]	= objs;
	d.addrin[6]	= user_data;
	d.addrin[7]	= dialog;
	__aes( &d, c, global );
	return(d.addrout[0]);
}


/****************************************************************
*
* (171)	lbox_update
*
****************************************************************/

void	MT_lbox_update( LIST_BOX *box, GRECT *rect, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {171,0,0,2};

	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &d, c, global );
}


/****************************************************************
*
* (172)	lbox_do
*
****************************************************************/

WORD	MT_lbox_do( LIST_BOX *box, WORD obj, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {172,1,1,1};

	d.intin[0]	= obj;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (173)	lbox_delete
*
****************************************************************/

WORD	MT_lbox_delete( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {173,0,1,1};

	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (174)	lbox_get
*
****************************************************************/

WORD	MT_lbox_cnt_items( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 0;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

OBJECT  *MT_lbox_get_tree( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

WORD	MT_box_get_visible( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

void	*MT_lbox_get_udata( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

WORD	MT_lbox_get_afirst( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 4;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_lbox_get_slct_idx( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 5;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

LBOX_ITEM  *MT_lbox_get_items( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 6;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

LBOX_ITEM  *MT_lbox_get_item( LIST_BOX *box, WORD n, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,2,0,1};

	d.intin[0]	= 7;
	d.intin[1]	= n;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

LBOX_ITEM	*MT_lbox_get_slct_item( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,0,1};

	d.intin[0]	= 8;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.addrout[0]);
}

WORD	MT_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,2};

	d.intin[0]	= 9;
	d.addrin[0]	= items;
	d.addrin[1]	= search;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_lbox_get_bvis( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 10;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_lbox_get_bentries( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 11;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_lbox_get_bfirst( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {174,1,1,1};

	d.intin[0]	= 12;
	d.addrin[0]	= box;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (175)	lbox_set
*
****************************************************************/

void	MT_lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,2,0,2};

	d.intin[0]	= 0;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &d, c, global );
}

void	MT_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,1,0,2};

	d.intin[0]	= 1;
	d.addrin[0]	= box;
	d.addrin[1]	= items;
	__aes( &d, c, global );
}

void	MT_lbox_free_items( LIST_BOX *box, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,1,0,1};

	d.intin[0]	= 2;
	d.addrin[0]	= box;
	__aes( &d, c, global );
}

void	MT_lbox_free_list( LBOX_ITEM *items, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,1,0,1};

	d.intin[0]	= 3;
	d.addrin[0]	= items;
	__aes( &d, c, global );
}

void	MT_lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect,
					GRECT *slider_rect, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,2,0,3};

	d.intin[0]	= 4;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	__aes( &d, c, global );
}

void	MT_lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,2,0,2};

	d.intin[0]	= 5;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= rect;
	__aes( &d, c, global );
}

void	MT_lbox_set_bentries( LIST_BOX *box, WORD entries, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,2,0,1};

	d.intin[0]	= 6;
	d.intin[1]	= entries;
	d.addrin[0]	= box;
	__aes( &d, c, global );
}

void	MT_lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect,
					GRECT *slider_rect, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {175,2,0,3};

	d.intin[0]	= 7;
	d.intin[1]	= first;
	d.addrin[0]	= box;
	d.addrin[1]	= box_rect;
	d.addrin[2]	= slider_rect;
	__aes( &d, c, global );
}


/****************************************************************
*
* (180)	fnts_create
*
****************************************************************/

FNT_DIALOG *MT_fnts_create( WORD vdi_handle, WORD no_fonts,
					WORD font_flags, WORD dialog_flags,
					char *sample, char *opt_button,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {180,4,0,4};

	d.intin[0] = vdi_handle;
	d.intin[1] = no_fonts;
	d.intin[2] = font_flags;
	d.intin[3] = dialog_flags;
	d.addrin[0] = sample;
	d.addrin[1] = opt_button;
	__aes( &d, c, global );
	return(d.addrout[0]);
}


/****************************************************************
*
* (181)	fnts_delete
*
****************************************************************/

WORD	MT_fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {181,1,1,1};

	d.intin[0] = vdi_handle;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (182)	fnts_open
*
****************************************************************/

WORD	MT_fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags,
			WORD x, WORD y, LONG id, LONG pt, LONG ratio,
			WORD *global )
{
	PARMDATA d;
	static WORD c[] = {182,9,1,1};

	d.intin[0] = button_flags;
	d.intin[1] = x;
	d.intin[2] = y;
	*((LONG *)(d.intin+3))	= id;
	*((LONG *)(d.intin+5))	= pt;
	*((LONG *)(d.intin+7))	= ratio;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (183)	fnts_close
*
****************************************************************/

#if MT_OLDWAY

WORD	MT_fnts_close( FNT_DIALOG *fnt_dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {183,0,1,1};

	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}

#else

WORD	MT_fnts_close( FNT_DIALOG *fnt_dialog, WORD *x, WORD *y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 183, 0, 3, 1};

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );

	if ( x )
		*x = d.intout[1];
	if ( y )
		*y = d.intout[2];

	return( d.intout[0] );
}

#endif


/****************************************************************
*
* (184)	fnts_get_info
*
****************************************************************/

WORD	MT_fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {184,3,1,1};

	d.intin[0] = 0;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return(d.intout[0]);
}

LONG	MT_fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index,
					WORD *global )
{
	PARMDATA d;
	static WORD c[] = {184,4,1,1};

	d.intin[0] = 1;
	*((LONG *) (d.intin+1)) = id;
	d.intin[3] = index;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return(*((LONG *) (d.intout+0)));
}

WORD	MT_fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id,
				BYTE *full_name, BYTE *family_name,
				BYTE *style_name, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {184,3,1,4};

	d.intin[0] = 2;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	d.addrin[1] = full_name;
	d.addrin[2] = family_name;

	d.addrin[3] = style_name;
	__aes( &d, c, global );
	return(d.intout[0]);
}

WORD	MT_fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono,
				WORD *outline, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {184,3,0,1};

	d.intin[0] = 3;
	*((LONG *) (d.intin+1)) = id;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	*mono = d.intout[1];
	*outline = d.intout[2];
	return(d.intout[0]);
}


/****************************************************************
*
* (185)	fnts_set
*
****************************************************************/

WORD	MT_fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = {185,1,1,2};

	d.intin[0] = 0;
	d.addrin[0] = fnt_dialog;
	d.addrin[1] = user_fonts;
	__aes( &d, c, global );
	return(d.intout[0]);
}

void	MT_fnts_remove( FNT_DIALOG *fnt_dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {185,1,0,1};

	d.intin[0] = 1;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
}


WORD	MT_fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags,
				LONG id, LONG pt, LONG ratio, WORD *global )
{
	static WORD	c[] = { 185, 8, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 2;
	d.intin[1] = button_flags;
	*((LONG *) &d.intin[2] ) = id;
	*((LONG *) &d.intin[4] ) = pt;
	*((LONG *) &d.intin[6] ) = ratio;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	return( d.intout[0] );
}

/****************************************************************
*
* (186)	fnts_evnt
*
****************************************************************/

WORD	MT_fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events,
				WORD *button, WORD *check_boxes, LONG *id,
				LONG *pt, LONG *ratio, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {186,0,9,2};

	d.addrin[0] = fnt_dialog;
	d.addrin[1] = events;
	__aes( &d, c, global );
	*button		= d.intout[1];
	*check_boxes	= d.intout[2];
	*id			= *((LONG *)(d.intout+3));
	*pt			= *((LONG *)(d.intout+5));
	*ratio		= *((LONG *)(d.intout+7));
	return(d.intout[0]);
}


/****************************************************************
*
* (187)	fnts_do
*
****************************************************************/

WORD	MT_fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags,
			LONG id_in, LONG pt_in, LONG ratio_in,
			WORD *check_boxes, LONG *id, LONG *pt,
			LONG *ratio, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {187,7,0,1};

	d.intin[0] = button_flags;
	*((LONG *) (d.intin+1)) = id_in;
	*((LONG *) (d.intin+3)) = pt_in;
	*((LONG *) (d.intin+5)) = ratio_in;
	d.addrin[0] = fnt_dialog;
	__aes( &d, c, global );
	*check_boxes = d.intout[1];
	*id = *((LONG *) (d.intout+2));
	*pt = *((LONG *) (d.intout+4));
	*ratio = *((LONG *) (d.intout+6));
	return(d.intout[0]);
}


/****************************************************************
*
* (190)	fslx_open
*
****************************************************************/

void * MT_fslx_open(
			char *title,
			WORD x, WORD y,
			WORD	*handle,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD sort_mode,
			WORD flags,
			WORD *global)
{
	PARMDATA d;
	static WORD c[] = {190,6,1,6};

	WORD *intin = d.intin;
	void **addrin = d.addrin;

	*intin++ = x;
	*intin++ = y;
	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	__aes( &d, c, global );

	*handle = d.intout[0];
	return(d.addrout[0]);
}


/****************************************************************
*
* (191)	fslx_close
*
****************************************************************/

WORD MT_fslx_close( void *fsd, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {191,0,1,1};

	d.addrin[0] = fsd;
	__aes( &d, c, global );
	return(d.intout[0]);
}


/****************************************************************
*
* (192)	fslx_getnxtfile
*
****************************************************************/

WORD MT_fslx_getnxtfile(
			void *fsd,
			char *fname, WORD *global
			)
{
	PARMDATA d;
	static WORD c[] = {192,0,1,2};

	d.addrin[0] = fsd;
	d.addrin[1] = fname;
	__aes( &d, c, global );
	return(d.intout[0]);

}


/****************************************************************
*
* (193)	fslx_evnt
*
****************************************************************/

WORD MT_fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			WORD *button,
			WORD *nfiles,
			WORD *sort_mode,
			char **pattern, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {193,0,4,4};

	void **addrin = d.addrin;

	*addrin++ = fsd;
	*addrin++ = events;
	*addrin++ = path;
	*addrin = fname;
	__aes( &d, c, global );
	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];
	*pattern = d.addrout[0];

	return(d.intout[0]);
}


/****************************************************************
*
* (194)	fslx_do
*
****************************************************************/

void * MT_fslx_do(
			char *title,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD *sort_mode,
			WORD flags,
			WORD *button,
			WORD *nfiles,
			char **pattern, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {194,4,4,6};

	WORD *intin = d.intin;
	void **addrin = d.addrin;

	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = *sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	__aes( &d, c, global );

	*button = d.intout[1];
	*nfiles = d.intout[2];
	*sort_mode = d.intout[3];
	*pattern = d.addrout[1];
	return(d.addrout[0]);
}


/****************************************************************
*
* (195)	fslx_set_flags
*
****************************************************************/

WORD MT_fslx_set_flags( WORD flags,
				WORD *oldval, WORD *global )
{
	PARMDATA d;
	static WORD c[] = {195,2,2,0};

	d.intin[0] = 0;
	d.intin[1] = flags;
	__aes( &d, c, global );
	*oldval = d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (200)	pdlg_create
*
****************************************************************/

PRN_DIALOG *MT_pdlg_create( WORD dialog_flags, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 200, 1, 0, 0 };

	d.intin[0] = dialog_flags;
	__aes( &d, c, global );
	return( d.addrout[0] );
}


/****************************************************************
*
* (201)	pdlg_delete
*
****************************************************************/

WORD	MT_pdlg_delete( PRN_DIALOG *prn_dialog, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 201, 0, 1, 1 };

	d.addrin[0] = prn_dialog;
	__aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (202)	pdlg_open
*
****************************************************************/

WORD	MT_pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				BYTE *document_name, WORD option_flags,
				WORD x, WORD y, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 202, 3, 1, 3 };

	d.intin[0] = option_flags;
	d.intin[1] = x;
	d.intin[2] = y;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = document_name;
	__aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (203)	pdlg_close
*
****************************************************************/

WORD	MT_pdlg_close( PRN_DIALOG *prn_dialog, WORD *x, WORD *y,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 203, 0, 3, 1 };

	d.intout[1] = -1;
	d.intout[2] = -1;

	d.addrin[0] = prn_dialog;
	__aes( &d, c, global );

	if ( x )
		*x = d.intout[1];
	if ( y )
		*y = d.intout[2];
		
	return( d.intout[0] );
}


/****************************************************************
*
* (204)	pdlg_get
*
****************************************************************/

LONG	MT_pdlg_get_setsize( WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 204, 1, 2, 0 };

	d.intin[0] = 0;
	__aes( &d, c, global );
	return( *(LONG *) &d.intout[0] );
}

/****************************************************************
*
* (205)	pdlg_set
*
****************************************************************/

WORD	MT_pdlg_add_printers( PRN_DIALOG *prn_dialog,
					DRV_INFO *drv_info, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 0;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = drv_info;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_remove_printers( PRN_DIALOG *prn_dialog, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 1;
	d.addrin[0] = prn_dialog;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_update( PRN_DIALOG *prn_dialog, BYTE *document_name,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 205, 1, 1, 3 };

	d.intin[0] = 2;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = 0L;
	d.addrin[2] = document_name;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog,
					PDLG_SUB *sub_dialogs, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 3;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = sub_dialogs;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog,
						WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 4;
	d.addrin[0] = prn_dialog;
	__aes( &d, c, global );
	return( d.intout[0] );
}

PRN_SETTINGS *MT_pdlg_new_settings( PRN_DIALOG *prn_dialog,
							WORD *global )
{
	static WORD	c[] = { 205, 1, 0, 1 };
	PARMDATA	d;

	d.intin[0] = 5;
	d.addrin[0] = prn_dialog;
	__aes( &d, c, global );
	return( d.addrout[0] );
}

WORD	MT_pdlg_free_settings( PRN_SETTINGS *settings, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 1 };
	PARMDATA	d;

	d.intin[0] = 6;
	d.addrin[0] = settings;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_dflt_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 7;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_validate_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 8;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_use_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 9;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	__aes( &d, c, global );
	return( d.intout[0] );
}

WORD	MT_pdlg_save_default_settings( PRN_DIALOG *prn_dialog,
					PRN_SETTINGS *settings, WORD *global )
{
	static WORD	c[] = { 205, 1, 1, 2 };
	PARMDATA	d;

	d.intin[0] = 10;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	__aes( &d, c, global );
	return( d.intout[0] );
}


/****************************************************************
*
* (206)	pdlg_evnt
*
****************************************************************/

WORD	MT_pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				EVNT *events, WORD *button, WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 206, 0, 2, 3 };

	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = events;
	__aes( &d, c, global );
	*button		= d.intout[1];
	return(d.intout[0]);
}


/****************************************************************
*
* (207)	pdlg_do
*
****************************************************************/

WORD	MT_pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings,
				BYTE *document_name, WORD option_flags,
				WORD *global )
{
	PARMDATA d;
	static WORD c[] = { 207, 1, 1, 3 };

	d.intin[0] = option_flags;
	d.addrin[0] = prn_dialog;
	d.addrin[1] = settings;
	d.addrin[2] = document_name;
	__aes( &d, c, global );
	return(d.intout[0]);
}

/****************************************************************
*
* (210) bis (217): Editor-Funktionen
*
****************************************************************/
#include	"MT_EDIT.C"
