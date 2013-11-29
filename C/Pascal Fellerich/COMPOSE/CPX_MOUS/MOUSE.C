/************************************************************************/
/*																		*/
/*	SETUP-CPX fÅr den Mausbeschleuniger aus CKBD.PRG					*/
/*																		*/
/*																		*/
/* 1.0  21-mar-1994  Auf Basis von COMPOSE.CPX aufgebaut				*/
/*																		*/
/*																		*/
/*																		*/
/************************************************************************/

int errno;		/* to avoid linker error in STDLIB ?!?!?! */

/*-- standard includes -------------------------------------------------*/
#include <tos.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#define EXTERN extern

/*-- CPX includes ------------------------------------------------------*/
#include "MOUS_RSC.RSH"
#include "MOUS_RSC.RH"
#include "XCONTROL.H"
#include "CKBD.H"

#include "language.h"				/* contains texts */

/*----------------------------------------------------------------------*/
/* SAVE-Variablen am Anfang des CPX-DATA Segmentes! 					*/
/*----------------------------------------------------------------------*/
extern struct safe {
	short	language,				/* cpx sprache */
			autodetect;				/* automatic resolution adaptation */
	MSPEEDER_SETUP mouse;			/* Mausdaten */
} save_vars;


/*----------------------------------------------------------------------*/
/* CPX globale Variablen												*/
/*----------------------------------------------------------------------*/
interface	*ckbd;					/* cookie aufruf */
CPX_PARAMS	*xpcb;
USERBLK		ublk;					/* fÅr's Editfeld */
int 		msg_buffer[8];			/* fÅr den Xformdo() call */
char		**rscstrings,			/* fÅr Language.h */
			**otherstrings;
int			*polyarrptr;			/* zeiger auf polyfactor array */


int			polypreset[5][4]=		/* polyfactor preset data */
	{
		0,		4,		-15,	128,	/* superslow */
		0,		0,		40,		200,	/* slow */
		0,		29,		133,	93,		/* normal */
		0,		100,	100,	56,		/* fast */
		0,		228,	0,		28		/* superfast */
	};


/* intern benutzt, fÅr UNDO-Buffer etc */
typedef struct {
	MSPEEDER_SETUP mouse;			/* current setup for Mouse_cfg() */
	int 	language;				/* current language */
	int		autodetect;				/* automatic resolution detection */
	char	mrotation[8],			/* mouse rotation ascii strings */
			mresolution[8],			/* -> don't use RSC strings! */
			sresolution[8],
			sratio[8];
} Undobuffer;


/* aus polyfit: */
extern char	pftext1[6], pftext2[6], pftext3[6];

extern int work_out[];				/* vdi arrays */


/************************************************************************/

WORD	cdecl cpx_call(GRECT *curr_wind);
void	RedrawObject(OBJECT *tree,int object);
int 	get_cookie(void);

/************************************************************************/
/* interne FN's prototypen												*/
void set_compstate(OBJECT *tree, int state);
void RedrawObj( OBJECT *tree, int ob);
char *say(int what);
char **pop(int what);
int set_language(int new);
void setup_mainpage(Undobuffer *u);


int polyeditor_page(GRECT *curr_wind, MSPEEDER_SETUP *m);

/*----------------------------------------------------------------------*/
/* CPX Startup code 													*/
CPX_INFO * cdecl cpx_init(CPX_PARAMS *par)
{
	int 	object;
	OBJECT	*cobj;

	static CPX_INFO info = {cpx_call,0L,0L,0L,0L,0L,0L,0L,0L,0L};

	xpcb=par;						/* save CPX_PARAMS */

	if (!xpcb->rsc_init)			/* resource fixup? */
	{
		for(object=0; object<NUM_OBS; object++)
		{	xpcb->rsh_obfix(rs_trindex[0],object);
			cobj = &rs_object[object];
			if ((cobj->ob_type >> 8) == 13)		/* Spezial: polywindow */
			{
				ublk.ub_code = draw_polynomial;
				ublk.ub_parm = (long)&polyarrptr;
				cobj->ob_spec.userblk = &ublk;
				cobj->ob_type = G_USERDEF;
			};
		};
	};

	if (xpcb->booting)
	{								/* booting? -> read settings...*/
		if (get_cookie())
		{
			/*
			Mouse_cfg(INQUIRE, &save_vars.mouse);
			*/
			if (save_vars.autodetect)		/* bei AutoDetect */
			{	init_uvdi();				/* Pixel-VerhÑltnis abfragen! */
				save_vars.mouse.ratio = (((long)work_out[3]*256L)/(long)work_out[4]);
				save_vars.mouse.screen_rez = UM_PER_INCH/work_out[3];
				exit_uvdi();
			};

			Mouse_cfg(SET, &save_vars.mouse);
			
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
	int 	new, action, startob=0;
	int		dialogpage=0;
	GRECT	popbut;
	OBJECT	*tree;

	Undobuffer	oldstate, currstate;

	oldstate.language = set_language(save_vars.language);

	/* Cookie suchen... */
	if (!get_cookie()) {
		form_alert(1, say(NOTINSTALLED));
		return(FALSE);
	};

	/* Maindialog ist jetzt default: */
	tree = rs_trindex[MAIN];
	ObX(ROOT)=curr_wind->g_x; ObY(ROOT)=curr_wind->g_y;

	/* Alte Einstellungen auslesen */
	Mouse_cfg(INQUIRE, &oldstate.mouse);
	oldstate.autodetect		= save_vars.autodetect;
	
	/* alles kopieren */
	memcpy(&currstate, &oldstate, sizeof(Undobuffer));

	/* Start immer mit Page 0 */
	if (dialogpage==0)
	{	HideObj(M_SUB2); NoEdit(M_ASPECTRATIO); NoEdit(M_SRESOLUTION);
		ShowObj(M_SUB1); MakeEditable(M_ROTATION); MakeEditable(M_MRESOLUTION);
	}
	else
	{	HideObj(M_SUB1); NoEdit(M_ROTATION); NoEdit(M_MRESOLUTION);
		ShowObj(M_SUB2); MakeEditable(M_ASPECTRATIO); MakeEditable(M_SRESOLUTION);
	}

	/* Setup & Zeiche das Formular... */
	setup_mainpage(&currstate);
	RedrawObject(tree,ROOT);

	/* Formular-verwaltung */
	init_uvdi();
	do {
		button=(xpcb->Xform_do)(tree,startob,msg_buffer);
		if (button == MESSAGE) {
			switch (msg_buffer[0])
			{
				case AC_CLOSE:	goto do_abort;
				case WM_CLOSED: goto do_ok;
			};
		} else {
			button&=0x7FFF; 			/* evtl. Doppelklick weg! */

			/* at every event read out edit fields */
			currstate.mouse.rotation = atoi(currstate.mrotation);
			currstate.mouse.mouse_rez = atoi(currstate.mresolution);
			currstate.mouse.screen_rez = atoi(currstate.sresolution);
			currstate.mouse.ratio = atoi(currstate.sratio);
			Mouse_cfg(SET, &currstate.mouse);

			switch (button)
			{
			/*-- Abbruch -----------------------------------------------*/
			do_abort:
			case M_ABORT:
				Mouse_cfg(SET, &oldstate.mouse);
				abort_flag=TRUE; break;
			/*-- OK ----------------------------------------------------*/
			do_ok:
			case M_OK:
				abort_flag=TRUE;
				break;

			/*-- SAVE PARAMS -------------------------------------------*/
			case M_SAVE:
				action=xpcb->XGen_Alert( SAVE_DEFAULTS );
				objc_change( tree, M_SAVE, 0,
								ObX(ROOT), ObY(ROOT), ObW(ROOT), ObH(ROOT),
								NORMAL, TRUE );
				if (action!=0) {
					save_vars.mouse = currstate.mouse;
					save_vars.language = currstate.language;
					save_vars.autodetect = currstate.autodetect;
					
					xpcb->CPX_Save( &save_vars, sizeof(struct safe) );
				};
				break;

			/*-- Infoline clicked --------------------------------------*/
			case M_TITLE:
				Deselect(M_TITLE);
				form_alert(1, say(INFOBOX));
				RedrawObj(tree, M_TITLE);
				break;

			/*-- Speeder ON OFF popup ----------------------------------*/
			case M_MS_ONOFF:
				objc_offset(tree, M_MS_ONOFF, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_MS_ONOFF); popbut.g_h=ObH(M_MS_ONOFF);
				new=xpcb->Popup(pop(POP_ONOFF), 2, -1, IBM,	&popbut, ObRectP(ROOT));
				switch (new) {
					case 0:
						currstate.mouse.switches.activity = ON;
						TedText(M_MS_ONOFF) = say(POP_ON);
						break;
					case 1:
						currstate.mouse.switches.activity = OFF;
						TedText(M_MS_ONOFF) = say(POP_OFF);
						break;
				};
				RedrawObj(tree, M_MS_ONOFF);
				Mouse_cfg(SET, &currstate.mouse);
				break;

			/**** PAGE CHANGE ******************************************/
			case M_PAGE1:				/* go to page 0 */
				Deselect(M_PAGE1); dialogpage=0; startob=0;
				HideObj(M_SUB2); NoEdit(M_ASPECTRATIO); NoEdit(M_SRESOLUTION);
				ShowObj(M_SUB1); MakeEditable(M_ROTATION); MakeEditable(M_MRESOLUTION);
				RedrawObject(tree, M_SUB1);
				break;
			case M_PAGE2:				/* go to page 1 */
				Deselect(M_PAGE2); dialogpage=1; startob=0;
				HideObj(M_SUB1); NoEdit(M_ROTATION); NoEdit(M_MRESOLUTION);
				ShowObj(M_SUB2); MakeEditable(M_ASPECTRATIO); MakeEditable(M_SRESOLUTION);
				RedrawObject(tree, M_SUB2);
				break;

			/*-- edit field exit ---------------------------------------*/
			case M_ROTATION:
			case M_MRESOLUTION:
			case M_ASPECTRATIO:
			case M_SRESOLUTION:
				startob=button;
				break;
			
			/**** PAGE 0 ************************************************/
			/*-- Maustasten vertauschen --------------------------------*/
			case M_MS_BUTTONSWAP:
				objc_offset(tree, M_MS_BUTTONSWAP, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_MS_BUTTONSWAP); popbut.g_h=ObH(M_MS_BUTTONSWAP);
				new=xpcb->Popup(pop(POP_MBUT), 2, -1, IBM, &popbut, ObRectP(ROOT));
				switch (new) {
					case 0:
						currstate.mouse.switches.lefthand = OFF; /* L,R */
						TedText(M_MS_BUTTONSWAP) = say(POP_LR);
						break;
					case 1:
						currstate.mouse.switches.lefthand = ON; /* R,L */
						TedText(M_MS_BUTTONSWAP) = say(POP_RL);
						break;
				};
				Mouse_cfg(SET, &currstate.mouse);
				RedrawObj(tree, M_MS_BUTTONSWAP);
				break;

			/*-- Voreinstellungen --------------------------------------*/
			case M_POLYNOMEDIT:
				Deselect(M_POLYNOMEDIT);
				if (polyeditor_page(curr_wind, &currstate.mouse))
					abort_flag=TRUE;
				else
					ObX(ROOT)=rs_trindex[POLY_ED][ROOT].ob_x;
					ObY(ROOT)=rs_trindex[POLY_ED][ROOT].ob_y;
					RedrawObject(tree,ROOT);	/* redraw this dialog */
				break;

			/**** PAGE 1 ************************************************/
			/*-- Voreinstellungen --------------------------------------*/
			case M_AUTOMATIC:
				if ((currstate.autodetect=ObState(M_AUTOMATIC))!=0)
				{	currstate.mouse.ratio = (((long)work_out[3]*256L)/(long)work_out[4]);
					currstate.mouse.screen_rez = UM_PER_INCH/work_out[3];
					setup_mainpage(&currstate);
					RedrawObject(tree,M_SUB2);
				} else
					RedrawObj(tree,M_AUTOMATIC);
				break;

			/*-- Sprache -----------------------------------------------*/
			case M_LANGUAGE:
				objc_offset(tree, M_LANGUAGE, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(M_LANGUAGE); popbut.g_h=ObH(M_LANGUAGE);
				new=xpcb->Popup(languagestr, NUMLANGUAGES, currstate.language, IBM, &popbut, ObRectP(ROOT));
				if (new!=-1) currstate.language=new;
				setup_mainpage(&currstate);
				RedrawObject(tree, ROOT);
				break;
			};
		};
	} while (abort_flag==FALSE);
	exit_uvdi();
	return(FALSE);
}


/* Main Page Setup */
void setup_mainpage(Undobuffer *u)
{
	OBJECT *tree;
	tree = rs_trindex[MAIN];

	TedText(M_TITLE) = Identify();

	set_language(u->language);

	TedText(M_MS_ONOFF) = (u->mouse.switches.activity==ON) ? say(POP_ON) : say(POP_OFF);
	/* Dialogpage 0: */
	TedText(M_MS_BUTTONSWAP) = (u->mouse.switches.lefthand==ON) ? say(POP_RL) : say(POP_LR);
	TedText(M_ROTATION) = itoa(u->mouse.rotation, u->mrotation, 10);
	TedText(M_MRESOLUTION) = itoa(u->mouse.mouse_rez, u->mresolution, 10);
	/* Dialogpage 1: */
	ObState(M_AUTOMATIC) = u->autodetect & SELECTED;
	TedText(M_ASPECTRATIO) = itoa(u->mouse.ratio, u->sratio, 10);
	TedText(M_SRESOLUTION) = itoa(u->mouse.screen_rez, u->sresolution, 10);
	TedText(M_LANGUAGE) = say(MYLANGUAGE);

}



/*----------------------------------------------------------------------*/
/* Polynomeditor-Page verwalten!												*/
int polyeditor_page(GRECT *curr_wind, MSPEEDER_SETUP *mouse)
{
	OBJECT	*tree;
	GRECT	popbut,*o;
	int 	button, abort_flag=FALSE,
			new,pos, x, y, xn, yn;
	MSPEEDER_SETUP oldmouse;

	/* configdialog ist jetzt default: */
	tree = rs_trindex[POLY_ED];
	ObX(ROOT)=curr_wind->g_x;
	ObY(ROOT)=curr_wind->g_y;

	/* Parameter auslesen */
	Mouse_cfg(INQUIRE, mouse);
	Mouse_cfg(INQUIRE, &oldmouse);
	polyarrptr = (int *)mouse->polynomial;
	
	/* Dialog korrekt setzen: */
	set_editfield(polyarrptr, TRUE);
	
	/* Dialog zeichnen */
	RedrawObject(tree,ROOT);			/* Dialog zeichnen */

	/* Dialog abarbeiten */
	do {
		button=(xpcb->Xform_do)(tree,0,msg_buffer);
		if (button == MESSAGE) {
			switch (msg_buffer[0])
			{
			case AC_CLOSE:
				Mouse_cfg(SET, &oldmouse); Mouse_cfg(INQUIRE, mouse);
				return TRUE;					/* abort other dialog! */
			case WM_CLOSED:
				Mouse_cfg(SET, mouse);
				return TRUE;
			};
		} else {
			button&=0x7FFF;
			switch (button)
			{
			/*-- Abbruch -----------------------------------------------*/
			case P_ABORT:
				Deselect(P_ABORT);
				Mouse_cfg(SET, &oldmouse); Mouse_cfg(INQUIRE, mouse);
				abort_flag=TRUE;
				break;

			/*-- OK ----------------------------------------------------*/
			case P_OK:
				Deselect(P_OK);		Mouse_cfg(SET, mouse);
				abort_flag=TRUE;
				break;

			/*-- Voreinstellungs-PopUp ---------------------------------*/
			case P_PRESETPOPUP:
				objc_offset(tree, P_PRESETPOPUP, &popbut.g_x, &popbut.g_y);
				popbut.g_w=ObW(P_PRESETPOPUP); popbut.g_h=ObH(P_PRESETPOPUP);
				new=xpcb->Popup(pop(POP_SPEED), 5, -1, IBM, &popbut, ObRectP(ROOT));
				if (new==-1) break;

				mouse->polynomial[0]=polypreset[new][0];
				mouse->polynomial[1]=polypreset[new][1];
				mouse->polynomial[2]=polypreset[new][2];
				mouse->polynomial[3]=polypreset[new][3];
				Mouse_cfg(SET, mouse);
				set_editfield(polyarrptr, TRUE);
				RedrawObject(tree, P_POLYFACBOX); RedrawObject(tree, P_EDITFIELD);
				TedText(P_PRESETPOPUP) = say(POP_S1+new);
				RedrawObj(tree, M_MS_BUTTONSWAP);
				break;
			

			/*-- Editfeld ----------------------------------------------*/
			case P_EDITFIELD:
				Deselect(P_EDITFIELD);
				read_polyfactors(polyarrptr);
				set_editfield(polyarrptr, TRUE);
				RedrawObject(tree, P_POLYFACBOX); RedrawObject(tree, P_EDITFIELD);
				Mouse_cfg(SET, mouse);
				break;
				
			/*-- Polynomfaktor -----------------------------------------*/
			case P_ZEROLINE:
				pos=graf_slidebox(tree, P_EDITFIELD, P_ZEROLINE, 1);
				ObY(P_ZEROLINE)=((long)pos*(long)(ObH(P_EDITFIELD)-ObH(P_ZEROLINE)))/1000L;
				set_editfield(polyarrptr, TRUE);	RedrawObject(tree, P_EDITFIELD);
				break;
				
			case P_P1:
				o=ObRectP(P_P1); goto drag_the_box;
			case P_P2:
				o=ObRectP(P_P2); goto drag_the_box;
			case P_P3:
				o=ObRectP(P_P3);
			drag_the_box:
				objc_offset(tree, P_EDITFIELD, &x, &y);
				graf_dragbox(o->g_w, o->g_h, o->g_x+x, o->g_y+y,
							x+1, y+1, ObW(P_EDITFIELD), ObH(P_EDITFIELD),
							&xn, &yn);
				o->g_x=xn-x; o->g_y=yn-y;
				read_editfield(polyarrptr);
				set_editfield(polyarrptr, FALSE);
				RedrawObject(tree, P_POLYFACBOX);	RedrawObject(tree, P_EDITFIELD);
				break;
			};
		};
	} while (abort_flag==FALSE);
	return FALSE;				/* continue calling dialog */
}



/************************************************************************/
/* RedrawObj: zeichnet genau ein Objekt neu 							*/
void RedrawObj( OBJECT *tree, int ob)
{
	objc_draw( tree, ob, 0, ObX(ROOT), ObY(ROOT), ObW(ROOT), ObH(ROOT));
}

/*----------------------------------------------------------------------*/
/* Zeichne an objekt OBnr neu; mit Rechtecklisten						*/
void RedrawObject(OBJECT *tree,int object)
{
	GRECT *clip_ptr,clip,xywh;

	/* absolute koordinaten berechnen */
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



/* Teste, ob  Cookie vorhanden & setze Pointer! */
int get_cookie(void)
{
	if ((xpcb->getcookie)( CKBD, (long *)&ckbd ) != 0) return(TRUE);
	else return(FALSE);
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
	int 	ti,oi,i,language;
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
