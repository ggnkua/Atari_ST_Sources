/************************************************************************/
/*																		*/
/*	SETUP-CPX fÅr CKBD.PRG												*/
/*																		*/
/*	0.7: erste îffentliche Version										*/
/*	0.8: kleinen BUG beseitigt (Fileselector), RSC aufgemotzt			*/
/*	0.8b:Suche Cookies 'CKBD' und 'DBJ2'								*/
/*																		*/
/* 1.0  8-mar-1994  Fast kompletter ReWrite, Anpassung an neues TSR		*/
/*		26-mar-1994	Bugfixes vor Release, Infoalert!					*/
/*																		*/
/*																		*/
/************************************************************************/


/*-- standard includes -------------------------------------------------*/
#include <tos.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <vdi.h>

#define EXTERN extern

/*-- CPX includes ------------------------------------------------------*/
#include "CKBD_RSC.RSH"
#include "CKBD_RSC.RH"
#include "XCONTROL.H"
#include "CKBD.H"

#include "language.h"			/* contains code & text */

/*----------------------------------------------------------------------*/
/* SAVE-Variablen am Anfang des CPX-DATA Segmentes! 					*/
/*----------------------------------------------------------------------*/
extern struct safe {
	char	loadfile[128];			/* welche Datei wird geladen!? */
	short	filetype;				/* 0 none, 1 KBD, 2 CKB */
	short	extkey, compose, alt_nnn, deadkey;
	short	mapping;				/* cfg data for those fn's */
	short	language;
	char	keys[16];				/* deadkeys */
} save_vars;


/*----------------------------------------------------------------------*/
/* CPX globale Variablen												*/
/*----------------------------------------------------------------------*/
interface	*ckbd;					/* cookie aufruf */

CPX_PARAMS	*xpcb;
OBJECT		*images;
int 		msg_buffer[8];

int 		language;
char		**rscstrings,
			**otherstrings;

extern char *fileselect_name;
extern USERBLK ublk[];				/* 4 userblocks needed */

/************************************************************************/

WORD	cdecl cpx_call(GRECT *curr_wind);
void	RedrawObject(OBJECT *tree,int object);
int 	get_cookie(void);


/************************************************************************/
/* interne FN's prototypen												*/
void set_compstate(OBJECT *tree, int state);
void RedrawObj( OBJECT *tree, int ob);
void load_kbd_file(void);
void load_ckb_file(void);
void read_kbd(void);
void read_ckb(void);
void tablereset(void);

int setup_page(GRECT *curr_wind);

/*------------------------------------------------------------------------*/
CPX_INFO * cdecl cpx_init(CPX_PARAMS *par)
{
	int 	object;
	USERBLK *ub = ublk; 		/* Array mit den Userblocks */
	OBJECT	*cobj;

	static CPX_INFO info = {cpx_call,0L,0L,0L,0L,0L,0L,0L,0L,0L};

	xpcb=par;						/* save CPX_PARAMS */

	if (!xpcb->rsc_init)			/* resource fixup? */
	{
		images = rs_trindex[IMAGES];

		for(object=0; object<NUM_OBS; object++)
		{
			xpcb->rsh_obfix(rs_trindex[0],object);
			cobj = &rs_object[object];
			switch (cobj->ob_type >> 8)
			{
				case 0x01:			/* Cross-Buttons */
					ub->ub_code = draw_crossbutton;
					ub->ub_parm = cobj->ob_spec.index;
					cobj->ob_spec.userblk = ub;
					cobj->ob_type = G_USERDEF;
					ub++;
					break;
				case 0x02:			/* Radio-Buttons */
					ub->ub_code = draw_radiobutton;
					ub->ub_parm = cobj->ob_spec.index;
					cobj->ob_spec.userblk = ub;
					cobj->ob_type = G_USERDEF;
					ub++;
					break;
			}
		}
	}

	if (xpcb->booting)
	{								/* booting? -> read settings...*/
		if (get_cookie())
		{							/* Lade eine Datei.... */
			if (save_vars.filetype==1)		read_kbd();
			else if (save_vars.filetype==2) read_ckb();
									/* Setze gespeicherten Status */
			Extkey(save_vars.extkey);
			Compose(save_vars.compose);
			Alt_nnn(save_vars.alt_nnn);
			Deadkey(save_vars.deadkey, NULL);
			Deadkey(SET, save_vars.keys);
			Cbioskeys(save_vars.mapping);
		};
		return((CPX_INFO *)1L); 	/* yeah, READY */
	};

	return(&info);
};


/*----------------------------------------------------------------------*/
/* CPX cpx_call routine!													*/
WORD cdecl cpx_call(GRECT *curr_wind)
{
	int 	button, abort_flag=FALSE;
	int 	old, new, action;

	GRECT	popbut;
	XKEYTAB *keytab;
	OBJECT	*tree;

	struct {
		int 	compose, extkey, alt_nnn, deadkey, mapping;
		int 	language;
	} oldstate, currstate;


	oldstate.language = set_language(save_vars.language);

	/* Cookie suchen... */
	if (!get_cookie()) {
		form_alert(1, say(NOTINSTALLED));
		return(FALSE);
	};

	init_uvdi();
	/* maindialog ist jetzt default: */
	tree = rs_trindex[MAIN];
	ObX(ROOT)=curr_wind->g_x;
	ObY(ROOT)=curr_wind->g_y;

	/* Version fragen: */
	TedText(M_TITLE) = Identify();

	/* Alte Einstellungen auslesen */
	oldstate.compose	= currstate.compose = (int)Compose(INQUIRE);
	oldstate.extkey 	= currstate.extkey	= (int)Extkey(INQUIRE);
	oldstate.alt_nnn	= currstate.alt_nnn = (int)Alt_nnn(INQUIRE);
	oldstate.deadkey	= currstate.deadkey = (int)Deadkey(INQUIRE,NULL);
	oldstate.mapping	= currstate.mapping = (int)Cbioskeys(INQUIRE);

	/* Formular richtig setzen */
	ObState(M_COMPOSE)	= currstate.compose & SELECTED;
	ObState(M_DEADKEY)	= currstate.deadkey & SELECTED;
	ObState(M_EXTKEY)	= currstate.extkey & SELECTED;
	ObState(M_ALTNNN)	= currstate.alt_nnn & SELECTED;

	/* Name der aktiven Tabelle holen */
	keytab=(XKEYTAB *)Ckeytbl(-1L, -1L, -1L, -1L, -1L);
	TedText(M_USEDTABLE) = keytab->name;
	TedText(M_TABLEACTIVE)=say(POPNOVALID+currstate.mapping);

	/* Zeiche das Formular... */
	RedrawObject(tree,ROOT);

	/* Formular-verwaltung */
	do {
		button=(xpcb->Xform_do)(tree,0,msg_buffer);
		if (button == MESSAGE) {
			switch (msg_buffer[0])
			{
				case AC_CLOSE:	goto do_abort;
				case WM_CLOSED: goto do_ok;
			};
		} else {
			button&=0x7FFF; 			/* evtl. Doppelklick weg! */
			switch (button)
			{
			/*-- Abbruch -----------------------------------------------*/
			do_abort:
			case M_ABORT:
				Extkey(oldstate.extkey);
				Compose(oldstate.compose);
				Alt_nnn(oldstate.alt_nnn);
				Deadkey(oldstate.deadkey,NULL);
				Cbioskeys(oldstate.mapping);
				abort_flag=TRUE; break;
			/*-- OK ----------------------------------------------------*/
			do_ok:
			case M_OK:
				abort_flag=TRUE; break;

			/*-- SAVE PARAMS -------------------------------------------*/
			case M_SAVE:
				action=xpcb->XGen_Alert( SAVE_DEFAULTS );
				objc_change( tree, M_SAVE, 0,
								ObX(ROOT), ObY(ROOT), ObW(ROOT), ObH(ROOT),
								NORMAL, TRUE );
				if (action!=0) {
					save_vars.extkey=currstate.extkey;
					save_vars.compose=currstate.compose;
					save_vars.alt_nnn=currstate.alt_nnn;
					save_vars.deadkey=currstate.deadkey;
					save_vars.mapping=currstate.mapping;
					Deadkey(INQUIRE, save_vars.keys);

					xpcb->CPX_Save( &save_vars, sizeof(struct safe) );
				};
				break;

			/*-- Infoline clicked --------------------------------------*/
			case M_TITLE:
				Deselect(M_TITLE);
				form_alert(1, say(INFOBOX));
				RedrawObj(tree, M_TITLE);
				break;

			/*-- COMPOSE-Char ON OFF -----------------------------------*/
			case M_COMPOSE:
				currstate.compose = ObState(M_COMPOSE) & 1;
				Compose(currstate.compose | (Compose(-1) & 0xFFFE));
				break;

			/*-- Deadkey ON OFF ----------------------------------------*/
			case M_DEADKEY:
				currstate.deadkey = ObState(M_DEADKEY) & 1;
				Deadkey(currstate.deadkey,NULL);
				break;

			/*-- ExtKey on / off ---------------------------------------*/
			case M_EXTKEY:
				currstate.extkey = ObState(M_EXTKEY) & 1;
				Extkey(currstate.extkey);
				break;

			/*-- Alt-NNN on / off --------------------------------------*/
			case M_ALTNNN:
				currstate.alt_nnn = ObState(M_ALTNNN) & 1;
				Alt_nnn(currstate.alt_nnn);
				break;

			/*-- Keytable: (POPUP) -------------------------------------*/
			case M_USEDTABLE:
				objc_offset(tree, M_USEDTABLE, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_USEDTABLE); popbut.g_h=ObH(M_USEDTABLE);
				new=xpcb->Popup(pop(POPLOADTAB), 3, -1, IBM,
												&popbut, ObRectP(ROOT));
				switch (new) {
					case 0: 	load_ckb_file();	break;
					case 1: 	load_kbd_file();	break;
					case 2: 	tablereset();		break;
				};
				Cbioskeys(currstate.mapping);
				TedText(M_USEDTABLE) = keytab->name;
				RedrawObj(tree, M_USEDTABLE);
				break;

			/*-- Keytable: (POPUP) -------------------------------------*/
			case M_TABLEACTIVE:
				old=currstate.mapping;
				objc_offset(tree, M_TABLEACTIVE, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_TABLEACTIVE); popbut.g_h=ObH(M_TABLEACTIVE);
				new=xpcb->Popup(pop(POPTABLEACTIVE), 4, old, IBM,
												&popbut, ObRectP(ROOT));
				if (new!=-1) currstate.mapping=new;
				Cbioskeys(currstate.mapping);
				TedText(M_TABLEACTIVE) = say(POPNOVALID+currstate.mapping);
				RedrawObj(tree, M_TABLEACTIVE);
				break;

			/*-- Einstellungen -----------------------------------------*/
			case M_SETUP:
				ObState(M_SETUP)=NORMAL;
				if (setup_page(curr_wind))
					abort_flag=TRUE;
				else
					ObX(ROOT)=rs_trindex[CC_CFG][ROOT].ob_x;
					ObY(ROOT)=rs_trindex[CC_CFG][ROOT].ob_y;
					RedrawObject(tree,0);			/* redraw this dialog */
				break;

			/*-- Sprache -----------------------------------------------*/
			case M_LANGUAGE:
				old=language;
				objc_offset(tree, M_LANGUAGE, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_LANGUAGE); popbut.g_h=ObH(M_LANGUAGE);
				new=xpcb->Popup(languagestr, NUMLANGUAGES, old, IBM,
												&popbut, ObRectP(ROOT));
				if (new!=-1) save_vars.language=set_language(new);
				TedText(M_LANGUAGE) = say(MYLANGUAGE);
				TedText(M_TABLEACTIVE) = say(POPNOVALID+currstate.mapping);
				RedrawObject(tree, ROOT);
				break;
			};
		};
	} while (abort_flag==FALSE);
	exit_uvdi();
	return(FALSE);
}


/*----------------------------------------------------------------------*/
/* Setup-Page verwalten!												*/
int setup_page(GRECT *curr_wind)
{
	OBJECT	*tree;
	GRECT	popbut;
	int 	button, abort_flag=FALSE,
			new,old;
	int 	oldcompose, newcompose;
	char	deadkeys[16];

	/* configdialog ist jetzt default: */
	tree = rs_trindex[CC_CFG];
	ObX(ROOT)=curr_wind->g_x;
	ObY(ROOT)=curr_wind->g_y;

	/* Parameter auslesen */
	oldcompose = newcompose = (int)Compose(INQUIRE);
	Deadkey(INQUIRE, deadkeys);

	/* Dialog korrekt setzen: */
	set_compstate(tree, newcompose);
	strncpy(TedText(C_DEADKEYS), deadkeys, TedLen(C_DEADKEYS));

	/* Dialog zeichnen */
	RedrawObject(tree,ROOT);

	/* Dialog abarbeiten */
	do {
		button=(xpcb->Xform_do)(tree,0,msg_buffer);
		if (button == MESSAGE) {
			switch (msg_buffer[0])
			{
			case AC_CLOSE:
				Compose(oldcompose);			/* restore old mode */
				return TRUE;					/* abort other dialog! */
			case WM_CLOSED:
				Deadkey(SET,TedText(C_DEADKEYS));
				return TRUE;
			};
		} else {
			button&=0x7FFF; 			/* evtl. Doppelklick weg! */
			switch (button)
			{
			/*-- Abbruch -----------------------------------------------*/
			case C_ABORT:
				ObState(C_ABORT)=NORMAL;
				Compose(oldcompose);			/* restore old mode */
				abort_flag=TRUE; break;

			/*-- OK ----------------------------------------------------*/
			case C_OK:							/* accept new deadkeys */
				ObState(C_OK)=NORMAL;
				Deadkey(SET,TedText(C_DEADKEYS));
				abort_flag=TRUE; break;

			/*-- Compose-Order sensitive? --------(POPUP)---------------*/
			case C_COMPORDER:
				old=0;
				if (newcompose & ORDER_SENSITIVE) old=1;
				objc_offset(tree, C_COMPORDER, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(C_COMPORDER); popbut.g_h=ObH(C_COMPORDER);
				new=xpcb->Popup(pop(POPCOMPORDER), 2, old, IBM,
												&popbut, ObRectP(ROOT));
				if ( new >=0  &&  new!=old )
				{	newcompose ^= ORDER_SENSITIVE;
					set_compstate(tree, newcompose);
					RedrawObj(tree, C_COMPORDER);
					Compose(newcompose);
				}; break;

			/*-- Compose-DEC mode or MULTICHAR mode (POPUP)-------------*/
			case C_COMPMODE:
				old=0;
				if (newcompose & MULTICHAR_MODE) old=1;
				objc_offset(tree, C_COMPMODE, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(C_COMPMODE); popbut.g_h=ObH(C_COMPMODE);

				new=xpcb->Popup(pop(POPCOMPMODE), 2, old, IBM,
												&popbut, ObRectP(ROOT));
				if ( new >=0  &&  new!=old )
				{	newcompose ^= MULTICHAR_MODE;
					set_compstate(tree, newcompose);
					RedrawObj(tree, C_COMPMODE);
					Compose(newcompose);
				};
				break;
			};
		};
	} while (abort_flag==FALSE);
	return FALSE;				/* continue calling dialog */
}


/*----------------------------------------------------------------------*/
/* compose-buttons setzen: (kein redraw)								*/
void set_compstate(OBJECT *tree, int state)
{
	if (state & MULTICHAR_MODE)
					TedText(C_COMPMODE) = say(MULTICHAR);
	else			TedText(C_COMPMODE) = say(DECVT200);
	if (state & ORDER_SENSITIVE)
					TedText(C_COMPORDER) = say(ORDERSENS);
	else			TedText(C_COMPORDER) = say(ORDERINDIFF);
};


/************************************************************************/
/* RedrawObj: zeichnet genau ein Objekt neu 							*/
void RedrawObj( OBJECT *tree, int ob)
{
	objc_draw( tree, ob, 0, ObX(ROOT), ObY(ROOT), ObW(ROOT), ObH(ROOT));
}


/************************************************************************/
/* Setzt die Systemtabellen wieder ein. 								*/
void tablereset(void)
{
	XKEYTAB *keytab;

	Cbioskeys(0);
	keytab=(XKEYTAB*)Ckeytbl(-1L, -1L, -1L, -1L, "---system---");
	Ckeytbl(keytab->unshift, keytab->shift, keytab->caps,
									keytab->compose, keytab->name);
	save_vars.filetype=0;
};



/************************************************************************/
/* load_kbd_file(): lÑdt eine Tastaturtabelle (ttable alleine!) 		*/
void load_kbd_file(void)
{
	if (fileselect( save_vars.loadfile, "*.KBD", say(LOADNEWKEYBOARDTABLE) ))
	{
		tablereset();
		read_kbd();
	};
};

/************************************************************************/
/* load_ckb_file(): lÑdt eine komplette Definitionstabelle				*/
void load_ckb_file(void)
{
	if (fileselect( save_vars.loadfile, "*.CKB", say(LOADNEWCOMPOSETABLE)))
	{
		tablereset();
		read_ckb();
	};
};

/************************************************************************/
/* lade Dateien  (lowlevel) 											*/
void read_ckb(void)
{
	long 	hn;
	long	fs;
	CKB_FILE_HEADER *cfh;
	char	*tab;
	void	*unshift, *shift, *caps, *compose;

	unshift=shift=caps=compose=(void *)-1L;
	hn=Fopen( save_vars.loadfile, FO_READ);
	if (hn>0) {
		if ((tab=Malloc(fs=Fseek( 0L, (int)hn, 2 ))) != NULL ) {
			cfh=(CKB_FILE_HEADER*)tab;
			Fseek( 0L, (int)hn, 0 ); Fread((int)hn, fs, cfh);
			if ( cfh->magic==CKBD ) {
				if (cfh->unshift_offset)	unshift=tab+cfh->unshift_offset;
				if (cfh->shift_offset)		shift=tab+cfh->shift_offset;
				if (cfh->caps_offset)		caps=tab+cfh->caps_offset;
				if (cfh->compose_offset)	compose=tab+cfh->compose_offset;
				Ckeytbl( unshift, shift, caps, compose, cfh->name );
				save_vars.filetype=2;
			} else
				form_alert(1, say(WRONGFILEFORMAT));
			Mfree(cfh);
		};
		Fclose((int)hn);
	};
};


void read_kbd(void)
{
	long 	hn;
	char	*tab, *p, tabname[16];

	hn=Fopen( save_vars.loadfile, FO_READ);
	if ((hn>0) && (Fseek( 0L, (int)hn, 2 ) == 384)) {
		if ((tab=Malloc( 384L ) ) != NULL ) {
			p=strrchr(save_vars.loadfile, '\\');
			if (p==NULL) strncpy(tabname,save_vars.loadfile,15);
			else strncpy(tabname,p+1,15);
			Fseek( 0L, (int)hn, 0 ); Fread((int)hn, 384, tab);
			Ckeytbl( tab, (tab+128), (tab+256), -1L, tabname );
			save_vars.filetype=1;
			Mfree(tab);
		};
	};
	Fclose((int)hn);
};


/* Teste, ob  Cookie vorhanden & setze Pointer! */
int get_cookie(void)
{
	if ((xpcb->getcookie)( CKBD, (long *)&ckbd ) != 0) return(TRUE);
	else return(FALSE);
};


/*------------------------------------------------------------------------*/
void RedrawObject(OBJECT *tree,int object)
{
	GRECT *clip_ptr,clip,xywh;

	/* absloute koordinaten berechnen */

	objc_offset(tree,object,&xywh.g_x,&xywh.g_y);
	xywh.g_w=tree[object].ob_width;
	xywh.g_h=tree[object].ob_height;

	/* erstes rechteck holen */
	clip_ptr=(*(xpcb->GetFirstRec))(&xywh);
	while(clip_ptr) {
		clip=*clip_ptr;
		objc_draw(tree,object,MAX_DEPTH,clip.g_x,clip.g_y,clip.g_w,clip.g_h);
		clip_ptr=(*(xpcb->GetNextRec))();
	};
};



/* get language dependent string */
char *say(int what)
{
	return otherstrings[what];
}

/* get language dependent popup */
char **pop(int what)
{
	return &otherstrings[what];
}

/* set a new language and fixup resource */
int set_language(int new)
{
	int 	ti,oi,i;
	OBJECT	*ob;

	switch (new)
	{
	case 0: 				/* deutsch */
		rscstrings = RSC_german;
		otherstrings = OTHER_german;
		language = new;
		break;
	case 1: 				/* english */
		rscstrings = RSC_english;
		otherstrings = OTHER_english;
		language = new;
		break;
	case 2: 				/* francais */
		rscstrings = RSC_french;
		otherstrings = OTHER_french;
		language = new;
		break;
	case 3: 				/* lux. */
		rscstrings = RSC_luxbg;
		otherstrings = OTHER_luxbg;
		language = new;
		break;
	}
	/* resource fixup */
	i=0;
	while (RSC_objectindex[i][0]>=0)
	{
		ti=RSC_objectindex[i][0];	oi=RSC_objectindex[i][1];
		ob=rs_trindex[ti];

		switch (ob[oi].ob_type)
		{
		case G_STRING:
		case G_BUTTON:
			ob[oi].ob_spec.free_string = rscstrings[i];
			break;
		case G_TEXT:
		case G_BOXTEXT:
			ob[oi].ob_spec.tedinfo->te_ptext = rscstrings[i];
			break;
		case G_FTEXT:
		case G_FBOXTEXT:
			ob[oi].ob_spec.tedinfo->te_ptmplt = rscstrings[i];
			break;
		}
		i++;
	}

	return language;
}


/************************************************************************/
