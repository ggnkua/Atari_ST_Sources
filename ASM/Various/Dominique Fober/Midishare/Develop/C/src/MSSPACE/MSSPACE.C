/* 
 *       MIDI STAT Application Midishare
 *	    Mark Williams C 3.0
 *	    TURBO_C 1.1
 *--------------------------------------------
 * @ GRAME 1989/91  Dominique Fober (Atari ST)
 */
 
#ifdef MWC
# include <gemdefs.h>
# include <obdefs.h>
# include <aesbind.h>
# include <vdibind.h>
# include <osbind.h>
#endif

#ifdef TURBO_C
# include <aes.h>
# include <vdi.h>
# include <tos.h>
#endif

#include <msh_unit.h>
#include <stdio.h>

#include "msspace.h"

#define NUMVERSION	135


#ifdef TURBO_C
# define TedInfo(a,b) a[b].ob_spec.tedinfo->te_ptext
# define Getshift	Kbshift
# define cdecl		cdecl
#else
# define TedInfo(a,b) ((TEDINFO *)a[b].ob_spec)->te_ptext
# define cdecl
#endif

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

#define GROW_APP		-6			/* growSpace pour une appl				*/
#define BAD_VERSION		-7			/* mauvaise version de MidiShare			*/


/* Constantes pour param‚trer l'application	*/
#define kNeedVersion	140

#define ApplName 		"Midi Space"
#define NO_REFNUM		-1

#define STAT	0
#define MGROW	1

#define defaultGrow		500
#define BlocGrow		100


/* Variables globales pour MidiShare	*/
short	myRefNum= NO_REFNUM;		/* num‚ro d'appl. Midi			*/
short 	State= STAT;
long 	growSize= -1;

/* Variables globales d'une application Atari */
Boolean doneFlag;				/* flag d'arret 				*/

/*---------------------------------------------------------------*/
/* les adresses des ressources  */
OBJECT *Adr_rsc, *Adr_rsc2, *Adr_menu, *Adr_about, *Adr_more;

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
/********************************************************************************/

void cdecl ReceiveEvents ( refNum)
short refNum;
{
	MidiFlushEvs( refNum);
}


/********************************************************************************/
/* 								SETUP MIDI						*/
/********************************************************************************/

Boolean SetUpMidi()
{
	if (!MidiShare())							/* V‚rifie la pr‚sence de MidiShare		*/
		return AlertUser( NO_MIDISHARE);
	if( MidiGetVersion() < kNeedVersion)
		return AlertUser( BAD_VERSION);
	if( myRefNum!= NO_REFNUM)
		return;								/* l'application est dej… ouverte			*/
	myRefNum= MidiOpen( ApplName );				/* Ouvre l'application pour MidiShare		*/		
	if (myRefNum == MIDIerrSpace)					/* V‚rifie que tout s'est bien pass‚		*/
		return AlertUser( MIDISHARE_FULL);
	MidiSetRcvAlarm( myRefNum, ReceiveEvents);		/* qu'elle soit appel‚e sous interruptions 	*/
	return TRUE;
}
			

/********************************************************************************/
/* 								Do Idle							*/
/********************************************************************************/
void DoIdle()
{
	register long	n;
	register short r;
	
	r = myRefNum;
	for (n=MidiCountDTasks(r); n>0; --n) 
		MidiExec1DTask(r);
}


/********************************************************************************/
/* 								Show free space					*/
/********************************************************************************/

void cdecl ShowFreeSpace( date, refNum, mode)
long date, mode;
short refNum;
{
	register OBJECT *rsc;
	register long total, used;
	register int prcent;
	static long oldTotal, oldUsed;
	static char usedS[15], prcentS[10];
	static char totalSpace[15];

	if( wi_handle!= NO_WINDOW && State== STAT)
	{
		rsc= Adr_rsc;
		total= MidiTotalSpace();
		sprintf( usedS,"%5ld", used= total- MidiFreeSpace());
		if( total) prcent= (used*100)/total;
		else		 prcent= 100;
		sprintf( prcentS,"%3d%%", prcent);
		sprintf( totalSpace,"%ld", total);
		TedInfo( rsc, TOTALNBR)= totalSpace;
		TedInfo( rsc, USEDNBR)= usedS;
		TedInfo( rsc, PRCENT)= prcentS;
		rsc[USED].ob_width= (rsc[TOTAL].ob_width * prcent)/100;
		if( !rsc[USED].ob_width)
			rsc[USED].ob_width= 1;
		if( total!= oldTotal || used!= oldUsed)
			redraw_stat( xwork, ywork, wwork, hwork);
		oldTotal= total;
		oldUsed= used;
		if( mode)
			MidiDTask( ShowFreeSpace, MidiGetTime()+500, refNum, 1L, 0,0);
	}
}

/********************************************************************************/
/* 								Atari utilities					*/
/********************************************************************************/

#define Alert(a,b)	form_alert( a, b)

Boolean AlertUser( errIndex )			/* Signale une erreur … l'utilisateur	*/
short errIndex;
{
	char s[200];
	
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
		case GROW_APP:
			Alert( 1, "[3][ | Just for a desk | accessory !][OK]");
			break;
		case BAD_VERSION:
			sprintf( s, "[3][ | MsSpace need at least | MidiShare version %d.%d !][OK]", 
					kNeedVersion/100, kNeedVersion%100);
			Alert( 1, s);
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
	Adr_rsc2[ROOT].ob_x= xwork;
	Adr_rsc2[ROOT].ob_y= ywork;
}

void aff_mem()
{
	static char mem[12];
	register OBJECT *rsc;

	rsc= Adr_rsc2;
	sprintf( mem,"%-7ld", (long)Malloc(-1L));
	TedInfo( rsc, MEMFREE)= mem;
	objc_draw( rsc, MEMFREE, 1, xwork, ywork, wwork, hwork);
}

void aff_grow()
{
	static char size[8];
	register OBJECT *rsc;

	if( growSize < 0) growSize= defaultGrow;
	rsc= Adr_rsc2;
	if( growSize < 10)
		sprintf( size,"  %ld  ", growSize );
	else if( growSize < 100)
		sprintf( size,"  %ld ", growSize );
	else if( growSize < 1000)
		sprintf( size," %ld ", growSize );
	else if( growSize < 10000)
		sprintf( size," %ld", growSize );
	else sprintf( size,"%ld", growSize );
	TedInfo( rsc, NUMBER)= size;
	objc_draw( rsc, NUMBER, 1, xwork, ywork, wwork, hwork);
}

redraw_stat( xc,yc,wc,hc)
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
#ifdef MWC
	  	if (rc_intersect(&t2,&t1)) 
#endif
	  	{
		    	set_clip( t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			objc_draw( ob, USEDNBR, 0, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
			objc_draw( ob, PRCENT, 0, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
			objc_draw( ob, TOTAL, 1, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
			objc_draw( ob, TOTALNBR, 1, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	  	}
		wind_get( wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
    	set_clip( xwork, ywork, wwork, hwork-1);
}


do_redraw( xc,yc,wc,hc)
short xc,yc,wc,hc;
{
	register OBJECT *ob;
	GRECT t1,t2;

	if( State== STAT)
		ob= Adr_rsc;
	else
		ob= Adr_rsc2;
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get( wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) 
	{
#ifdef MWC
	  	if (rc_intersect(&t2,&t1)) 
#endif
	  	{
		    	set_clip( t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			objc_draw( ob, 0, 5, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
		  }
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
			evType |= MU_TIMER;
			if( State== STAT)
				ShowFreeSpace( 0L, myRefNum, (long)TRUE);
			else
			{
				aff_mem();
				aff_grow();
			}
			return TRUE;
		}
	}
	CloseAppl();
	return FALSE;
}


void CloseAppl()
{
	v_clsvwk( handle);						/* ferme la station de travail 	   */
	if( gl_apid)
	{
		if( MidiShare() && myRefNum!= NO_REFNUM)	/* si MidiShare est toujours install‚ */
		{
			if( !( (int)Getshift(-1) & K_ALT))		/* si alternate non appuy‚e 		   */
			{
				MidiClose( myRefNum);
				myRefNum= NO_REFNUM;
			}
		}
		evType &= ~MU_TIMER;
	}
	else
	{
		if( myRefNum!= NO_REFNUM)		/* si l'appl MidiShare est install‚e */
			MidiClose( myRefNum);		/* ferme l'application MidiShare 	*/
		menu_bar( Adr_menu, 0);			/* supprime la barre des menus 	*/
		rsrc_free();					/* libŠre les ressources 		*/
		appl_exit();					/* libŠre l'application courante	*/
	}
}

/********************************************************************************/
/* 								Setup windows									*/
/********************************************************************************/

SetUpWindows()
{
	short ret;
	register OBJECT *ob;

	ob= Adr_rsc;
	if( !xdesk && !ydesk)
		form_center( ob, &xdesk, &ydesk, &ret, &ret);
	wind_calc( WC_BORDER, WI_KIND, xdesk, ydesk, ob[ROOT].ob_width,\
		ob[ROOT].ob_height, &ret, &ret, &wdesk, &hdesk);

	wi_handle= wind_create( WI_KIND, xdesk, ydesk, wdesk, hdesk);
	if( wi_handle> 0) {
		wind_set( wi_handle, WF_NAME," MIDI SPACE ",0,0);
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
********************************************************************************/
void ShowAbout()
{											
	static char version[5];
	static char app_version[5];
	register OBJECT *rsc;
	register short n;
	short x, y, w, h;
	int state;

	rsc= Adr_about;
	state= rsc[OK].ob_state;
	n= MidiGetVersion();
	sprintf( version,"%01d.%02d", n/100, n%100 );
	sprintf( app_version,"%01d.%02d", NUMVERSION/100, NUMVERSION%100 );
	TedInfo( rsc, VERSION)= version;
	TedInfo( rsc, VAPPL)= version;

	wind_update( BEG_UPDATE);
	form_center(rsc, &x, &y, &w, &h);
	form_dial(FMD_START, 0,0,0,0, x, y, w, h); 
	objc_draw( rsc, 0, 5, x, y, w, h);
	form_do( rsc, 0);
	objc_change( rsc, OK, 0, 0,0,640,400, state, 0);
	form_dial(FMD_FINISH, 0,0,0,0, x, y, w, h); 
	wind_update( END_UPDATE);
}

/********************************************************************************
* 								Show More							*
********************************************************************************/
void ShowMore()
{											
	register OBJECT *rsc;
	register MidiStatPtr stat;
	register int ret;
	char rcvErr[10], allocErr[10], rcv[15], xmt[15];
	short x, y, w, h;
	int state;

	rsc= Adr_more;
	stat= MidiGetStatPtr();
	sprintf( rcvErr,"%ld", stat->rcvErrs);
	sprintf( allocErr,"%ld", stat->allocErrs);
	sprintf( rcv,"%ld", stat->rcvEvs);
	sprintf( xmt,"%ld", stat->xmtEvs);
	TedInfo( rsc, RCVERR)= rcvErr;
	TedInfo( rsc, ALLOCERR)= allocErr;
	TedInfo( rsc, RCVTOT)= rcv;
	TedInfo( rsc, XMTTOT)= xmt;

	wind_update( BEG_UPDATE);
	form_center(rsc, &x, &y, &w, &h);
	form_dial(FMD_START, 0,0,0,0, x, y, w, h); 
	objc_draw( rsc, 0, 5, x, y, w, h);
	if( (ret= form_do( rsc, 0))== CLEAR)
	{
		stat->rcvErrs= stat->allocErrs= 0L;
		stat->rcvEvs= stat->xmtEvs= 0L;
	}
	state= rsc[ret].ob_state;
	objc_change( rsc, ret, 0, 0,0,640,400, state&~SELECTED, 0);
	form_dial(FMD_FINISH, 0,0,0,0, x, y, w, h); 
	wind_update( END_UPDATE);
}

/********************************************************************************
* 								TrackDialog						*
********************************************************************************/

void TrackDialog( x, y)
short x, y;
{
	register int object;			/* l'objet s‚lectionn‚ 		*/
	register int state;				/* l'‚tat de l'objet		*/
	register OBJECT *rsc;			/* l'adresse de la ressource 	*/
	int mouse, ret, tmp;

	if( State== STAT)
		rsc= Adr_rsc;
	else
		rsc= Adr_rsc2;
	if( (object= objc_find( rsc, ROOT, 5, x, y)) != -1  && ( rsc[object].ob_flags & SELECTABLE)) 
	{
		state= rsc[object].ob_state;
		if( State== STAT)
		{
			switch( object)
			{
				case FREEINFO:
					if( gl_apid)
					{
						objc_change( rsc, object, 0, xwork,ywork,wwork,hwork,state|SELECTED, 1);
						ShowAbout();
						objc_change( rsc, object, 0, xwork,ywork,wwork,hwork, state, 1);
					}
					break;
				case IDMORE:
					objc_change( rsc, object, 0, xwork,ywork,wwork,hwork,state|SELECTED, 1);
					ShowMore();
					objc_change( rsc, object, 0, xwork,ywork,wwork,hwork, state, 1);
					break;
				case SUITEA:
					State= MGROW;
					objc_draw( Adr_rsc2, 0, 5, xwork,ywork,wwork,hwork);
					aff_mem();
					aff_grow();
					break;
			}
		}
		else
		{
			switch( object)
			{
				case SUITEB:
					State= STAT;
					objc_draw( Adr_rsc, 0, 5, xwork,ywork,wwork,hwork);
					ShowFreeSpace( MidiGetTime(), myRefNum, TRUE);
					break;
				case GROWINFO:
					if( gl_apid)
					{
						objc_change( rsc, object, 0, xwork,ywork,wwork,hwork,state|SELECTED, 1);
						ShowAbout();
						objc_change( rsc, object, 0, xwork,ywork,wwork,hwork, state, 1);
					}
					break;
				case GROW:
					objc_change( rsc, GROW, 0, xwork, ywork, wwork, hwork, state|SELECTED, 1) ;
					if( gl_apid)
					{
						long alloc;
						
						alloc= MidiGrowSpace( growSize);
						if( alloc < growSize)
						{
							char mess[120];
							sprintf( mess, "[3][ Warning ! | just %ld events | allocated !][OK]", alloc);
							Alert( 1, mess);
						}
						do{
							vq_mouse( handle, &mouse, &ret, &ret);
						} while( mouse);
						aff_mem();
					}
					else AlertUser( GROW_APP);
					objc_change( rsc, GROW, 0, xwork, ywork, wwork, hwork, state, 1) ;
					break;
				case PLUS:
					objc_change( rsc, PLUS, 0, xwork, ywork, wwork, hwork, state|SELECTED, 1) ;
					tmp= BlocGrow;
					do {
						if( growSize < 100000L- tmp) growSize+= tmp;
						aff_grow();
						vq_mouse( handle, &mouse, &ret, &ret);
						if( mouse & 2) tmp= BlocGrow*10;
						else 		tmp= BlocGrow;
					} while( mouse);
					objc_change( rsc, PLUS, 0, xwork, ywork, wwork, hwork, state&~SELECTED, 1) ;
					break;
				case MOINS:			
					objc_change( rsc, MOINS, 0, xwork, ywork, wwork, hwork, state|SELECTED, 1) ;
					tmp= BlocGrow;
					do {
						if( growSize >= tmp) growSize-= tmp;
						else 			 growSize= 0;
						aff_grow();
						vq_mouse( handle, &mouse, &ret, &ret);
						if( mouse & 2) tmp= BlocGrow*10;
						else 		tmp= BlocGrow;
					} while( mouse);
					objc_change( rsc, MOINS, 0, xwork, ywork, wwork, hwork, state&~SELECTED, 1) ;
					break;
			}
		}
	}
}

		
/********************************************************************************/
/* 								SET UP RESSOURCES					*/
/********************************************************************************/

Boolean SetUpRsc( rscName)
char *rscName;
{
	if( rsrc_load( rscName))
	{
		if( !rsrc_gaddr(R_TREE, RSC, &Adr_rsc))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, RSC2, &Adr_rsc2))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, MENU, &Adr_menu))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, ABOUT, &Adr_about))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, MORE, &Adr_more))
			return AlertUser( RSC_DAMAGED);
		if( gl_apid)
			Menu_id = menu_register(gl_apid,"  Midi Space");
		else
			menu_bar( Adr_menu, 1);
	}
	else return AlertUser( NO_RSC);
}			

			
/********************************************************************************
* 								DO COMMAND						*
********************************************************************************/

void DoCommand( menu, item)
short item, menu;
{
	switch ( item )
	{
		case ABOUTID :
			ShowAbout();
			break;
	} 
	menu_tnormal( Adr_menu, menu, 1);
}


/********************************************************************************/
/* 								INITIALIZE						*/
/********************************************************************************/

void Initialize()
{
	short ret;

	gl_apid= appl_init();
	phys_handle=graf_handle(&ret,&ret,&ret,&ret);
	graf_mouse(ARROW, 0x0L);
	wi_handle= NO_WINDOW;			/* fenetre ferm‚e 	*/
	hidden=FALSE;					/* souris apparente */
	evType= MU_MESAG|MU_BUTTON;		/* evts attendus	*/	
	if( !SetUpRsc("msspace.rsc"))	/* chargement des ressources, mise en place menus  */
	{
		if( !gl_apid)
		{
			appl_exit();
			exit( 1);
		}
	}
	if( !gl_apid)
		if( !OpenAppl())			/* ouverture de l'application	*/
			exit( 1);
}

/********************************************************************************/
/* 							Corps Principal						*/
/********************************************************************************/

void main()
{
short ret;
register short event;

	Initialize();
	
	doneFlag = FALSE;											
	while (!doneFlag) 							/* Main Loop			*/
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
					MidiFlushDTasks( myRefNum);
					if( !gl_apid)
						doneFlag= TRUE;
					break;
					
            		case WM_MOVED:
			   	    	wind_set( wi_handle, WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
			    		wind_get( wi_handle, WF_CURRXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
				    	update_window();
		  		    	break;

				case AC_CLOSE:
					if( (msgbuff[3]== Menu_id) && (wi_handle!= NO_WINDOW) )
					{
						wind_delete( wi_handle);
						wi_handle = NO_WINDOW;
						MidiFlushDTasks( myRefNum);
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

		  		case MN_SELECTED:
		  			DoCommand( msgbuff[3], msgbuff[4]);
	  				break;
			} /* switch (msgbuff[0]) */

		} /* end if( event & MU_MESAG)*/

		wind_update(END_UPDATE);
	
		if( event & MU_BUTTON) 
		{
			if( wind_find( mx,my)== wi_handle)
				TrackDialog( mx, my);
		}
		
		if( (event & MU_TIMER) && wi_handle!= NO_WINDOW)
		{
			long count;
			count= MidiCountDTasks( myRefNum);
			if( count)
			{
				if( State== STAT)
					MidiExec1DTask( myRefNum);
				MidiFlushDTasks( myRefNum);
			}
		}

	} /* end while */
	exit(0);
}

/*=============================== FIN ==============================*/
