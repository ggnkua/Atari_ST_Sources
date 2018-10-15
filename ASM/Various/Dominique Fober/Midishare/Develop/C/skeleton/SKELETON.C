/********************************************************************************/
/*                        MIDI SHARE Application Skeleton                       */
/*		  			       Version Turbo C 1.1						*/
/*		  			       Version Mark Williams C 3.0.5				*/
/*------------------------------------------------------------------------------*/
/* MIDISHARE est un module logiciel con‡u sp‚cialement pour permettre le fonc-	*/
/* tionnement et le d‚veloppement d'applications Midi dans un contexte multi-	*/
/* tƒches et temps r‚el.	 											*/
/* 																*/
/* MIDISHARE prend en charge la plupart des problŠmes sp‚cifiques li‚s au d‚ve- */
/* loppement d'applications Midi: gestion des flux Midi, gestion du temps,		*/
/* gestion des tƒches. En outre, MIDISHARE permet le fonctionnement simultan‚	*/
/* sous Multi-Finder de ces applications, ainsi que l'‚tablissement de connec-	*/
/* tions Midi virtuelles entre celles-ci.								*/
/* 																*/
/* SKELETON est un exemple d'application MidiShare minimale qui peut ˆtre		*/
/* utilis‚e comme base de d‚veloppement pour de nouvelles applications.		*/
/* Par d‚faut, l'application renvoie tous les ‚v‚nements qu'elle re‡oit, sans	*/
/* aucune modification.												*/
/*																*/
/* Les points qui peuvent ˆtre facilement modifi‚s sont les suivants :		*/
/*																*/
/* - La constante ApplName : le nom de l'application pour MidiShare			*/
/*																*/
/* - ReceiveEvents : qui traite tous les ‚v‚nements re‡us et qui r‚alise ici 	*/
/*   un simple MidiThru.												*/
/*																*/
/* - La constante wantRealTime : quand elle vaut 1, ReceiveEvents est appel‚e	*/
/*   sous interruption et fonctionne donc en temps r‚el; quand elle vaut 0, 	*/
/*   ReceiveEvents est appel‚e dans la boucle principale. 					*/
/*																*/
/* - La constante wantFilter : quand elle vaut 1, un filtre sur les entr‚es  	*/
/*   Midi est install‚, quand elle vaut 0, aucun filtre n'est install‚ et 		*/
/*   l'application re‡oit tous les ‚v‚nements.							*/
/*																*/
/* - InstallFilter : qui configure le filtre d'entr‚e						*/
/*																*/
/* - La fichier de ressource qui d‚finit le contenu de la fenˆtre de 			*/
/*   l'application													*/
/*																*/
/*------------------------------------------------------------------------------*/
/*		@ GRAME 1989/90, Yann Orlarey et Herv‚ Lequay 					*/
/*					  Dominique Fober (Atari ST)						*/
/********************************************************************************/

/*
la compilation de skeleton.c se fait:
	sous Turbo_c 		: avec le projet skeleton.prj
	sous Mark Williams C: en executant sous shell la commande suivante :
					  pour une application :
					  cc skeleton.c -VGEMAPP -lmidi -o skeleton.prg
					  pour un accessoire de bureau :
					  cc skeleton.c -VGEMACC -lmidi -o skeleton.prg
*/

#include <stdio.h>
#include <msh_unit.h>

#ifdef TURBO_C
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>
#endif

#include "skeleton.h"


#ifdef TURBO_C
# define TedInfo(a,b) a[b].ob_spec.tedinfo->te_ptext
# define Getshift	Kbshift
# define cdecl		cdecl
#else
# define TedInfo(a,b) ((TEDINFO *)a[b].ob_spec)->te_ptext
# define cdecl
#endif

/*
 * pour ex‚cuter en test sous l'environnement de d‚veloppement 
 * du Turbo C, il faut positionner la macro TEST dans l'option de
 * compilation 'Define macro'. Cette macro est … supprimer dans la 
 * version d‚finitive car l'application d‚pend alors de l'execution 
 * pr‚alable de MidiSave.prg .
 */
/* #define TEST */
/*
 * pour compiler en accessoire de bureau 
 * il faut positionner la macro ACC. 
 */


/* Quelques constantes */

#define nil		0
#define TRUE		1
#define FALSE		0


/* La fenˆtre de l'application */
#define WI_KIND		MOVER|CLOSER|NAME
#define NO_WINDOW		-1

/* Pour les erreurs */

#define NO_RSC			-1			/* pas de fichier de ressources 			*/
#define RSC_DAMAGED		-2			/* fichier de ressources endommag‚ 		*/
#define NO_MORE_WINDOW	-3			/* plus de fenetre disponible				*/
#define NO_MIDISHARE	-4			/* MidiShare n'est pas install‚ 			*/
#define MIDISHARE_FULL	-5			/* pas d'application MidiShare disponibles 	*/



/* Constantes pour param‚trer l'application	*/

#define ApplName 		"MidiSkeleton"
#define wantRealTime 	TRUE
#define wantFilter		FALSE
#define NO_REFNUM		-1



/* Variables globales pour MidiShare	*/

short	myRefNum= NO_REFNUM;		/* num‚ro d'appl. Midi			*/
TFilter	myFilter;					/* filtre pour les ‚v‚nements Midi	*/


/* Variables globales d'une application Atari */

Boolean doneFlag;				/* flag d'arret 				*/

/*---------------------------------------------------------------*/
/* les adresses des ressources  */
OBJECT *Adr_rsc, *Adr_menu, *Adr_about;

/*---------------------------------------------------------------*/
/* les handlers menu, application, fenetres */
short Menu_id;					/* identificateur du menu 		*/
short gl_apid;					/* identificateur de l'application */
short phys_handle;				/* physical workstation handle 	*/
short handle;					/* virtual workstation handle 	*/
short wi_handle;				/* window handle 				*/

/*---------------------------------------------------------------*/
/* la gestion des fenetres */
short xdesk, ydesk, wdesk, hdesk;	/* les coordonn‚es de la fenetre sur le bureau */
short xwork, ywork, hwork, wwork;	/* l'espace de travail courant 			  */

/*---------------------------------------------------------------*/
/* la gestion des evenements */
short evType;					/* type des evenements gem	*/
short msgbuff[8];				/* event message buffer 		*/
short mx,my;					/* mouse x and y pos. 		*/
short hidden;					/* current state of cursor 	*/

/*---------------------------------------------------------------*/
/* storage wasted for idiotic bindings */
short contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];	
short work_in[11];				/* Input to GSX parameter array 	*/
short work_out[57];				/* Output from GSX parameter array */
short pxyarray[10];				/* input point array 			*/



/*======================== d‚clarations de fonctions ===========================*/

Boolean AlertUser();
void CloseAppl();
Boolean SetUpWindow();


/*=============================== MidiShare Part ===============================*/


/********************************************************************************/
/* 								ReceiveEvents						*/
/*------------------------------------------------------------------------------*/
/* Cette proc‚dure traite tous les ‚v‚nements re‡us. Elle peut ˆtre appel‚e	*/
/* "manuellement" (wantRealTime 0) dans la boucle principale de l'application	*/
/* s'il n'y a pas de contraintes temps r‚el sur la r‚ception.				*/
/* 																*/
/* Dans le cas contraire (wantRealTime 1), grƒce … MidiSetRcvAlarm, la routine 	*/
/* peut ˆtre appel‚e automatiquement par MidiShare, sous interruptions, chaque 	*/ 
/* fois que l'application re‡oit de nouveaux ‚v‚nements (voir SetupMidi). 		*/
/* 																*/
/* Dans le code ci dessous, ReceiveEvents r‚alise un simple MidiThru sans		*/
/* aucun traitement. 												*/
/* 																*/
/* ReceiveEvents doit obligatoirement comporter un paramŠtre, qui est le 		*/
/* num‚ro de r‚f‚rence MidiShare de l'application.						*/
/* 																*/
/* Les paramŠtres de l'appel :										*/
/* ---------------------------										*/
/* 																*/
/*		refNum:	num‚ro de r‚f‚rence MidiShare de l'application.			*/
/* 																*/
/********************************************************************************/

void cdecl ReceiveEvents ( refNum)
short refNum;
{
	register MidiEvPtr	e;
	register long n;
	register short r;

	r = refNum;
	for ( n=MidiCountEvs(r); n>0; --n ) 	/* Pour chaque ‚v‚nement re‡u :	*/
	{
		e = MidiGetEv(r);				/*  r‚cup‚rer l'‚v‚nement		*/
		/* .... */					/*  traiter l'‚v‚nement			*/
		MidiSend(r,e);					/*  renvoyer l'‚v‚nement			*/
	}
}


/****************************************************************************
* 							InstallFilter						 *
*---------------------------------------------------------------------------*
* Cette proc‚dure d‚finit les valeurs du filtre de l'application. Un filtre *
* est compos‚ de trois parties, qui sont trois tableaux de bool‚ens :		 * 
* 															 *
*		un tableau de 256 bits pour les ports Midi accept‚s			 *
*		un tableau de 256 bits pour les types d'‚v‚nements accept‚s		 *
*		un tableau de  16 bits pour les canaux Midi accept‚s			 *
* 															 *
* Dans le code ci dessous, le filtre est param‚tr‚ pour accepter n'importe	 *
* quel type d'‚v‚nement. 										 *
* 															 *
* Les paramŠtres de l'appel :										 *
* ---------------------------										 *
* 															 *
*		aucun												 *
* 															 *
*****************************************************************************/

void InstallFilter ()
{
	register short i;

	for (i = 0; i<256; i++)
	{ 										
		AcceptBit(myFilter.evType,i);		/* accepte tous les types d'‚v‚nements	*/
		AcceptBit(myFilter.port,i);		/* en provenance de tous les ports		*/
	}
											
	for (i = 0; i<16; i++)
		AcceptBit(myFilter.channel,i);	/* et sur tous les canaux Midi		*/
		
	MidiSetFilter( myRefNum, &myFilter );   /* installe le filtre				*/
}


/********************************************************************************/
/* 								SETUP MIDI						*/
/*------------------------------------------------------------------------------*/
/* V‚rifie la pr‚sence de MidiShare, la possibilit‚ d'ouverture Midi, et		*/
/* installe la proc‚dure d'alarme qui sera appel‚e par MidiShare lors des chan-	*/
/* gements de statut des applications ou des ports.						*/
/* 																*/
/* Les paramŠtres de l'appel :										*/
/* ---------------------------										*/
/* 																*/
/*		aucun													*/
/* 																*/
/********************************************************************************/

Boolean SetUpMidi()
{
	if (!MidiShare())							/* V‚rifie la pr‚sence de MidiShare		*/
		return AlertUser( NO_MIDISHARE);
	if( myRefNum!= NO_REFNUM)
		return TRUE;							/* l'application est dej… ouverte			*/
	myRefNum= MidiOpen( ApplName );				/* Ouvre l'application pour MidiShare		*/		
	if (myRefNum == MIDIerrSpace)					/* V‚rifie que tout s'est bien pass‚		*/
		return AlertUser( MIDISHARE_FULL);
	if (wantRealTime)							/* Installe la routine de r‚ception pour	*/
		MidiSetRcvAlarm(myRefNum, ReceiveEvents);	/* qu'elle soit appel‚e sous interruptions 	*/		
	if (wantFilter)
		InstallFilter();						/* Installe le filtre de r‚ception			*/	
	MidiConnect(0,myRefNum,TRUE);					/* Connecte l'entr‚e de l'appl. aux entr‚es physiques	*/
	MidiConnect(myRefNum,0,TRUE);					/* Connecte la sortie de l'appl. aux sorties physiques	*/
	return TRUE;
}
			

/********************************************************************************/
/* 								Do Idle							*/
/*------------------------------------------------------------------------------*/
/* Execution des diff‚rentes tƒches Midi : reception des ‚v‚nements Midi si	*/
/* cela n'est pas fait sous interruptions; Ex‚cution des tƒches diff‚r‚es en	*/
/* attente (tƒches cr‚es par MidiDTask).								*/
/* 																*/
/* Les paramŠtres de l'appel :										*/
/* ---------------------------										*/
/* 																*/
/*		aucun													*/
/* 																*/
/********************************************************************************/
void DoIdle()
{
	register long	n;
	register short r;
	
	r = myRefNum;
	if (!wantRealTime) ReceiveEvents(r);
	for (n=MidiCountDTasks(r); n>0; --n) MidiExec1DTask(r);
	/* .... */
}



/********************************************************************************/
/* 								Atari utilities					*/
/*------------------------------------------------------------------------------*/
/* 																*/
/********************************************************************************/

#define Alert( a, b)	form_alert( a, b)

Boolean AlertUser( errIndex )			/* Signale une erreur … l'utilisateur	*/
short errIndex;
{
	switch( errIndex)
	{
		case NO_RSC:
			Alert( 1, "[3][ | I don't find the | ressource's file | for Midi Space !][OK]");
			break;
		case RSC_DAMAGED:
			Alert( 1, "[3][ | Error reading the | ressource's file | of Midi Space !][OK]");
			rsrc_free();
			break;
		case NO_MORE_WINDOW:
			Alert( 1, "[3][ | No more window available. | Close an unused window !][OK]");
			break;
		case NO_MIDISHARE:
			Alert( 1, "[3][ | MidiShare |is not resident !][OK]");
			break;
		case MIDISHARE_FULL:
			Alert( 1, "[3][ | MidiShare can't | open Midi Space !][OK]");
			break;
	}
	return FALSE;
}


hide_mouse()
{
	if(! hidden)
	{
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}


show_mouse()
{
	if(hidden)
	{
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

open_vwork()
{
	register short i;
	
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}


set_clip(x,y,w,h)
short x,y,w,h;
{
	short clip[4];
	
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w;
	clip[3]=y+h;
	vs_clip(handle,1,clip);
}


void update_window()
{
	wind_get( wi_handle, WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	set_clip(xwork, ywork, wwork, hwork-1);
	Adr_rsc[ROOT].ob_x= xwork;
	Adr_rsc[ROOT].ob_y= ywork;
}


do_redraw( xc,yc,wc,hc)
short xc,yc,wc,hc;
{
	register OBJECT *ob;
	GRECT t1,t2;

	ob= Adr_rsc;
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get( wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) 
	{
	    	set_clip( t1.g_x, t1.g_y, t1.g_w, t1.g_h);
		objc_draw( ob, 0, 5, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
		wind_get( wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
    	set_clip( xwork, ywork, wwork, hwork-1);
}


Boolean OpenAppl()
{
	open_vwork();					/* ouverture d'une station de travail 	*/
	if( SetUpMidi())				/* ouverture MidiShare				*/
	{
		if( SetUpWindows())			/* initialisations fenˆtre 			*/
		{
			evType |= MU_TIMER;		/* event + timer 					*/
			return TRUE;
		}
	}
	CloseAppl();
	return FALSE;
}


void CloseAppl()
{
	v_clsvwk( handle);						/* ferme la station de travail 	   */
#ifdef ACC
	if( MidiShare() && myRefNum!= NO_REFNUM)	/* si MidiShare est toujours install‚ */
	{
		if( !( (int)Kbshift(-1) & K_ALT))		/* si alternate non appuy‚e 		   */
		{
			MidiClose( myRefNum);
			myRefNum= NO_REFNUM;
		}
	}
#else
	if( myRefNum!= NO_REFNUM)				/* si l'appl MidiShare est install‚e */
		MidiClose( myRefNum);				/* ferme l'application MidiShare 	*/
	menu_bar( Adr_menu, 0);					/* supprime la barre des menus 	*/
	rsrc_free();							/* libŠre les ressources 		*/
	appl_exit();							/* libŠre l'application courante	*/
#endif
}

/********************************************************************************/
/* 								Setup windows									*/
/*------------------------------------------------------------------------------*/
/* Ouvre la fenˆtre																*/
/* 																				*/
/* Les paramŠtres de l'appel :													*/
/* ---------------------------													*/
/* 																				*/
/*		aucun																	*/
/* 																				*/
/********************************************************************************/

SetUpWindows()
{
	short ret;
	register OBJECT *ob;

	ob= Adr_rsc;
	form_center( ob, &xdesk, &ydesk, &ret, &ret);
	wind_calc( WC_BORDER, WI_KIND, xdesk, ydesk, ob[ROOT].ob_width,\
		ob[ROOT].ob_height, &ret, &ret, &wdesk, &hdesk);

	wi_handle= wind_create( WI_KIND, xdesk, ydesk, wdesk, hdesk);
	if( wi_handle> 0) {
		wind_set( wi_handle, WF_NAME," SKELETON ",0,0);
		wind_set( wi_handle, WF_NEXTXYWH,xdesk,ydesk,wdesk,hdesk);
		hide_mouse();
		graf_growbox( xdesk+wdesk/2, ydesk+hdesk/2, 40, 40, xdesk, ydesk, wdesk, hdesk);
		wind_open( wi_handle, xdesk, ydesk, wdesk, hdesk);
		show_mouse();
		update_window();
		return TRUE;
	}
	else return AlertUser( NO_MORE_WINDOW);
}


/********************************************************************************
* 								Show About						*
*------------------------------------------------------------------------------	*
* Affiche la fenˆtre de About. La routine r‚cupŠre un dialogue en ressource	*
* dans MidiShareI (AboutID) qu'elle personnalise avec le num‚ro de version de	*
* MidiShare et une picture de pr‚sentation de l'application (AboutPictID).		*
* 																*
* Les paramŠtres de l'appel :											*
* ---------------------------											*
* 																*
*		aucun													*
* 																*
********************************************************************************/
void ShowAbout()
{											
	static char version[5];
	register OBJECT *rsc;
	register short n;
	short x, y, w, h;

	rsc= Adr_about;
	n= MidiGetVersion();
	sprintf( version,"%1d.%2d", n/100, n%100 );
	TedInfo( rsc, VERSION)= version;

	wind_update( BEG_UPDATE);
	form_center(rsc, &x, &y, &w, &h);
	form_dial(FMD_START, 0,0,0,0, x, y, w, h); 
	objc_draw( rsc, 0, 7, x, y, w, h);
	form_do( rsc, 0);
	objc_change( rsc, OK, 0, 0,0,640,400, NORMAL, 1);
	form_dial(FMD_FINISH, 0,0,0,0, x, y, w, h); 
	wind_update( END_UPDATE);
}


/********************************************************************************
* 								TrackDialog						*
*------------------------------------------------------------------------------	*
* Proc‚dure charg‚e du suivi de la souris.								*
* 																*
* Les paramŠtres de l'appel :											*
* ---------------------------											*
* 																*
*		x	y :	coordonn‚es point‚es par la souris.					*
* 																*
********************************************************************************/

void TrackDialog( x, y)
short x, y;
{
	register int object;			/* l'objet s‚lectionn‚ 		*/
	register int state;				/* son ‚tat 				*/
	register OBJECT *rsc;			/* l'adresse de la ressource 	*/

	rsc= Adr_rsc;
	if( (object= objc_find( rsc, RSC, 5, x, y)) != -1  && ( rsc[object].ob_flags & SELECTABLE)) 
	{
		state= rsc[object].ob_state;
		switch( object)
		{
			case SKELETON:
#ifdef ACC
				objc_change( rsc, SKELETON, 0, xwork, ywork, wwork, hwork, state|SELECTED, 1) ;
				ShowAbout();
				objc_change( rsc, SKELETON, 0, xwork, ywork, wwork, hwork, state&~SELECTED, 1) ;
#else
				if( state & SELECTED )
					objc_change( rsc, SKELETON, 0, xwork, ywork, wwork, hwork, state&~SELECTED, 1) ;
				else
					objc_change( rsc, SKELETON, 0, xwork, ywork, wwork, hwork, state|SELECTED, 1) ;
#endif
				break;
			
			/*-----------*/
		}
	}
}

		
/********************************************************************************/
/* 								SET UP RESSOURCES					*/
/*------------------------------------------------------------------------------*/
/* Chargement des ressources											*/
/* Installation de la barre de menus									*/
/* 																*/
/* Les paramŠtres de l'appel :										*/
/* ---------------------------										*/
/* 																*/
/*		rscName :	nom du fichier de ressources							*/
/* 																*/
/********************************************************************************/

Boolean SetUpRsc( rscName)
char *rscName;
{
	if( rsrc_load( rscName))
	{
		if( !rsrc_gaddr(R_TREE, RSC, &Adr_rsc))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, MENU, &Adr_menu))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, ABOUT, &Adr_about))
			return AlertUser( RSC_DAMAGED);
#ifdef ACC
		Menu_id = menu_register(gl_apid,"  Skeleton");
#else
		menu_bar( Adr_menu, 1);
#endif

	}
	else return AlertUser( NO_RSC);
}			

			
/********************************************************************************
* 								DO COMMAND						*
*------------------------------------------------------------------------------	*
* Execution des commandes du menu. Ici on se contente de g‚rer l'item			*
* Informations .													*
* 																*
* Les paramŠtres de l'appel :											*
* ---------------------------											*
* 																*
*		menu :	le titre du menu s‚lectionn‚.							*
*		item :	l'item de ce menu s‚lectionn‚.						*
* 																*
********************************************************************************/

void DoCommand( menu, item)
short item, menu;
{
	switch ( item )
	{
		case ABOUTID :
			ShowAbout();
			break;
		/*-----------*/
	} 
	menu_tnormal( Adr_menu, menu, 1);
}


/********************************************************************************/
/* 								INITIALIZE						*/
/*------------------------------------------------------------------------------*/
/* Initialisations g‚n‚rales ( ressources , fenˆtre, Midi)					*/
/* 																*/
/* Les paramŠtres de l'appel :										*/
/* ---------------------------										*/
/* 																*/
/*		aucun													*/
/* 																*/
/********************************************************************************/

void Initialize()
{
	short ret;

	gl_apid= appl_init();
	phys_handle=graf_handle(&ret,&ret,&ret,&ret);
	graf_mouse(ARROW, 0x0L);
	wi_handle= NO_WINDOW;						/* fenetre ferm‚e 	*/
	hidden=FALSE;								/* souris apparente */
	evType= MU_MESAG|MU_BUTTON;					/* evts attendus	*/	
	if( !SetUpRsc("skeleton.rsc"))				/* chargement des ressources, mise en place menus  */
	{
#ifndef ACC
		appl_exit();
		exit( 1);
#endif
	}
#ifndef ACC	
	if( !OpenAppl())							/* ouverture de l'application	*/
		exit( 1);
#endif
}

/********************************************************************************/
/* 							Corps Principal						*/
/*------------------------------------------------------------------------------*/
/* Initialisation de l'application, ouverture fenˆtre, initialisations diverses */
/* et tutti quanti, boucle principale.									*/
/* 																*/
/********************************************************************************/

void main()
{
	short ret;
	register short event;

#ifdef TEST
	if( !TCMidiRestore())
		exit(1);
#endif
	
	Initialize();

	doneFlag = FALSE;											
	while (!doneFlag) 							/* Loop			*/
	{

    		event = evnt_multi( evType,
			   1,1,1,
			   0,0,0,0,0,
			   0,0,0,0,0,
			   msgbuff,0,0,&mx,&my,&ret,&ret,&ret,&ret);

		wind_update(BEG_UPDATE);

		if (event & MU_MESAG) 
	  	{
	  		switch (msgbuff[0]) 
	  		{
	  			case WM_REDRAW:
					do_redraw( msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
					break;

		 		case WM_NEWTOP:
     	     	case WM_TOPPED:
					wind_set(wi_handle,WF_TOP,0,0,0,0);
		   			break;

            		case WM_CLOSED:
					wind_close( wi_handle);
					wind_delete( wi_handle);
					wi_handle = NO_WINDOW;
					CloseAppl();
#ifndef ACC
					doneFlag= TRUE;
#endif
					break;
					
            		case WM_MOVED:
			   	    	wind_set( wi_handle, WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
			    		wind_get( wi_handle, WF_CURRXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
				    	update_window();
		  		    	break;
#ifdef ACC
				case AC_CLOSE:
					if( (msgbuff[3]== Menu_id) && (wi_handle!= NO_WINDOW) )
					{
						wind_delete( wi_handle);
						wi_handle = NO_WINDOW;
						CloseAppl();
					}
					break;
				
				case AC_OPEN:
					if((msgbuff[4] == Menu_id) && (msgbuff[3])) 
					{
						if( wi_handle== NO_WINDOW)
							OpenAppl();
						else
							wind_set(wi_handle,WF_TOP,0,0,0,0);
					}
					break;
#else
		  		case MN_SELECTED:
		  			DoCommand( msgbuff[3], msgbuff[4]);
	  				break;
#endif
			} /* switch (msgbuff[0]) */

		} /* end if( event & MU_MESAG)*/

		wind_update(END_UPDATE);
	
		if( event & MU_BUTTON) 
		{
			if( wind_find( mx,my)== wi_handle)
				TrackDialog( mx, my);
		}
	
		if( event & MU_TIMER) 
		{
			DoIdle();
		}

	} /* end while */
	exit(0);
}
