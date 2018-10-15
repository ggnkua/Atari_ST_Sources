/********************************************************************************/
/*                     MIDI SHARE Application Midi Connecte                     */
/*------------------------------------------------------------------------------*/
/*		@ GRAME 1990												*/
/*		Dominique Fober (Atari ST)									*/
/********************************************************************************/

#include <stdio.h>
#include <msh_unit.h>

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


#include "msnet.h"
#include "con_defs.h"


#ifdef TURBO_C
# define TedInfo(a,b) a[b].ob_spec.tedinfo->te_ptext
# define Getshift	Kbshift
# define cdecl		cdecl
#else
# define TedInfo(a,b) ((TEDINFO *)a[b].ob_spec)->te_ptext
# define cdecl
#endif

/* La fenˆtre de l'application */
#define WI_KIND		MOVER|CLOSER|NAME|SIZER
#define NO_WINDOW		-1
#define MIN_WSIZE		140


/* Constantes pour param‚trer l'application	*/
#define kNeedVersion	131

#define ApplName 		"Midi Connecte"
#define NO_REFNUM		-1


/*---------------------------------------------------------------*/
/* Variables globales pour MidiShare						*/
short myRefNum= NO_REFNUM;		/* num‚ro d'appl. Midi		*/
Boolean newState= FALSE;			/* signale que l'‚tat a chang‚*/

/*---------------------------------------------------------------*/
/* Variables globales de l'application */
Boolean doneFlag;				/* flag d'arret 				 */

extern struct GEST gest;			/* gestion globale de l'application */
extern GRECT clip[3];			/* clippings de chaque sous-fenetre */

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
short xdesk, ydesk, wdesk, hdesk;	/* coord. fenetre sur le bureau  */
short xwork, ywork, hwork, wwork;	/* l'espace de travail courant   */
short xold, yold, wold, hold;		/* sauvegarde espace de travail  */

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
extern APPL *getApplPtr(), *addAppl();

Boolean AlertUser();
void CloseAppl();
void init_appl();
Boolean SetUpWindows();



/********************************************************************************/
/* 								ReceiveEvents						*/
/********************************************************************************/
void cdecl ReceiveEvents ( refNum)
short refNum;
{
	MidiFlushEvs( refNum);
}

/********************************************************************************/
/* 								ApplAlarme						*/
/********************************************************************************/
void cdecl ApplAlarme( refnum, refmod, status)
register short refnum, refmod, status;
{
	register APPL * appl;
	
	if( status== MIDIOpenAppl)
	{
		addAppl( refmod);
		newState= TRUE;
		chge_vslide( 0);
	}
	else if( appl= getApplPtr( refmod))
	{
		switch( status)
		{
			case MIDICloseAppl:
				delAppl( appl);
				newState= TRUE;
				gest.state= FALSE;
				chge_vslide( 0);
				break;
			case MIDIChgName:
				chgeNameAppl( appl);
				newState= TRUE;
				break;
			case MIDIChgConnect:
				break;
		}
	}
	getAllConnect();
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
	MidiSetRcvAlarm(myRefNum, ReceiveEvents);
	MidiSetApplAlarm( myRefNum, ApplAlarme); 
	return TRUE;
}
			

/********************************************************************************/
/* 								Do Idle							*/
/********************************************************************************/
void DoIdle()
{
	if( newState)
	{
		newState= FALSE;
		do_redraw( xwork, ywork, wwork, hwork);
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
			Alert( 1, "[3][ | I don't find the | ressource's file | for Midi Connecte !][OK]");
			break;
		case RSC_DAMAGED:
			Alert( 1, "[3][ | Error reading ressource's | file of Mid Connecte !][OK]");
			rsrc_free();
			break;
		case NO_MORE_WINDOW:
			Alert( 1, "[3][ | | No more window available| Close an unused window ![OK]");
			break;
		case NO_MIDISHARE:
			Alert( 1, "[3][ | MidiShare |is not resident !][OK]");
			break;
		case MIDISHARE_FULL:
			Alert( 1, "[3][ | MidiShare can't open | Midi Connecte !][OK]");
			break;
		case ERR_MEM:
			Alert( 1, "[3][ | | Not enough memory | for Midi Connecte !][OK]");
			break;
		case ERR_FULL:
			Alert( 1, "[3][ | | Too much applications | for Midi Connecte !][OK]");
			break;
		case BAD_VERSION:
			sprintf( s, "[3][ | MsSpace need at least | MidiShare version %d.%d !][OK]", 
					kNeedVersion/100, kNeedVersion%100);
			Alert( 1, s);
			break;
	}
	return FALSE;
}


void release()
{
	int ret, state;
	
	do{
		vq_mouse( handle, &state, &ret, &ret);
	} while( state);
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
	clip[2]=x+w-1;
	clip[3]=y+h-1;
	vs_clip(handle,1,clip);
}

void chge_h_rsc( diff)
register short diff;
{
	register OBJECT *rsc;
	
	rsc= Adr_rsc;
	rsc[FOND].ob_height += diff;
	rsc[FIN].ob_height += diff;
	rsc[FAPP].ob_height += diff;
	rsc[FOUT].ob_height += diff;
	rsc[IN].ob_height += diff;
	rsc[APP].ob_height += diff;
	rsc[OUT].ob_height += diff;
	rsc[DOWNIN].ob_y += diff;
	rsc[DOWNAPP].ob_y += diff;
	rsc[DOWNOUT].ob_y += diff;
	rsc[FSIN].ob_height += diff;
	rsc[FSAPP].ob_height += diff;
	rsc[FSOUT].ob_height += diff;
}

void update_window()
{
	wind_get( wi_handle, WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	set_clip(xwork, ywork, wwork, hwork);
	Adr_rsc[ROOT].ob_x= xwork;
	Adr_rsc[ROOT].ob_y= ywork;
	get_sf_clips();
}


do_redraw( xc,yc,wc,hc)
short xc,yc,wc,hc;
{
	register OBJECT *ob;
	register Boolean state;
	GRECT t1,t2,t3;

	ob= Adr_rsc;
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	state= gest.state;
	wind_get( wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) 
	{
#ifdef MWC
	  	if (rc_intersect(&t2,&t1)) 
#endif
	  	{
		    	set_clip( t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			objc_draw( ob, ROOT, 5, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	  		t3= t1;
#ifdef MWC
	  		if (rc_intersect(&clip[SFAPP],&t3))
#endif
	  		{
		    		set_clip( t3.g_x, t3.g_y, t3.g_w, t3.g_h);
				aff_appls( gest.aff[SFAPP], state, gest.sel, SFAPP);
			}
			if( state)
			{
	  			t3= t1;
#ifdef MWC
		  		if( rc_intersect(&clip[SFIN],&t3))
#endif
		  		{
			    		set_clip( t3.g_x, t3.g_y, t3.g_w, t3.g_h);
					aff_appls( gest.aff[SFIN], state, gest.sel, SFIN);
	  			}
	  			t3= t1;
#ifdef MWC
	  			if (rc_intersect(&clip[SFOUT],&t3))
#endif
		  		{
			    		set_clip( t3.g_x, t3.g_y, t3.g_w, t3.g_h);
					aff_appls( gest.aff[SFOUT], state, gest.sel, SFOUT);
				}
			}
	  	}
		wind_get( wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
    	set_clip( xwork, ywork, wwork, hwork);
}


void init_appl()
{
	gest.aff[SFIN]= gest.appl;
	gest.aff[SFAPP]= gest.appl;
	gest.aff[SFOUT]= gest.appl;
	gest.sel= (APPL *)nil;
	gest.state= FALSE;
}


Boolean OpenAppl()
{
	open_vwork();					/* ouverture d'une station de travail 	*/
	init_aff();
	if( SetUpMidi())				/* ouverture MidiShare				*/
	{
		if( !init_mem())
			AlertUser(ERR_MEM);
		else
		{
			getStateAppls();		/* collecte appl MidiShare et leurs ‚tats */
			init_appl();	
			if( SetUpWindows())		/* initialisations fenˆtre 			*/
			{
				chge_vslide(0);
				evType |= MU_TIMER;	/* event + timer 					*/
				return TRUE;
			}
		}
	}
	CloseAppl();
	return FALSE;
}


void CloseAppl()
{
	v_clsvwk( handle);			/* ferme la station de travail 	 */
	if( gl_apid)				/* si c'est un accessoire de bureau */
	{
		if( MidiShare() && (myRefNum!= NO_REFNUM))	/* si MidiShare est toujours install‚ */
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
		if( myRefNum!= NO_REFNUM)	/* si l'appl MidiShare est install‚e */
			MidiClose( myRefNum);	/* ferme l'application MidiShare 	*/
		menu_bar( Adr_menu, 0);		/* supprime la barre des menus 	*/
		rsrc_free();				/* libŠre les ressources 		*/
		appl_exit();				/* libŠre l'application courante	*/
	}
	free_mem();					/* libŠre la m‚moire allou‚e		*/
}

/********************************************************************************/
/* 								Setup windows									*/
/********************************************************************************/

Boolean SetUpWindows()
{
	short ret;
	register OBJECT *ob;

	ob= Adr_rsc;
	if( xold)
	{
		xdesk= xold;
		ydesk= yold;
	}
	else
	{
		chge_h_rsc( (ob[APP].ob_height%H_LINE)- 6);
		form_center( ob, &xdesk, &ydesk, &ret, &ret);
	}
	wind_calc( WC_BORDER, WI_KIND, xdesk, ydesk, ob[ROOT].ob_width,\
		ob[ROOT].ob_height, &ret, &ret, &wdesk, &hdesk);

	wi_handle= wind_create( WI_KIND, xdesk, ydesk, wdesk, hdesk);
	if( wi_handle> 0) {
		wind_set( wi_handle, WF_NAME," MIDI CONNECTE ",0,0);
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
	TedInfo(rsc, VERSION)= version;
	TedInfo(rsc, VAPPL)= app_version;

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
* 								TrackDialog						*
********************************************************************************/

void TrackDialog( x, y)
short x, y;
{
	register int object;			/* l'objet s‚lectionn‚ 		*/
	register OBJECT *rsc;			/* l'adresse de la ressource 	*/
	register int ret;

	rsc= Adr_rsc;
	if( (object= objc_find( rsc, ROOT, 5, x, y)) != -1 )  
	{
		if( (rsc[object].ob_flags & SELECTABLE) && gl_apid)
			ShowAbout();
		else
		{
			switch( object)
			{
				case UPIN:
					if( gest.state) step_page( LINEUP, SFIN);
					break;
				case UPAPP:
					step_page( LINEUP, SFAPP);
					break;
				case UPOUT:
					if( gest.state) step_page( LINEUP, SFOUT);
					break;
				case DOWNIN:
					if( gest.state) step_page( LINEDOWN, SFIN);
					break;
				case DOWNAPP:
					step_page( LINEDOWN, SFAPP);
					break;
				case DOWNOUT:
					if( gest.state) step_page( LINEDOWN, SFOUT);
					break;

				case FSIN:
					if( gest.state) 
					{
						if( (y-(rsc[FSIN].ob_y+rsc[ROOT].ob_y+rsc[FAPP].ob_y)) < rsc[SLIDEIN].ob_y)
							step_page( PAGEUP, SFIN);
						else
							step_page( PAGEDOWN, SFIN);
					}
					break;					
				case FSAPP:
					if( (y-(rsc[FSAPP].ob_y+rsc[ROOT].ob_y+rsc[FAPP].ob_y)) < rsc[SLIDEAPP].ob_y)
						step_page( PAGEUP, SFAPP);
					else
						step_page( PAGEDOWN, SFAPP);
					break;					
				case FSOUT:
					if( gest.state) 
					{
						if( (y-(rsc[FSOUT].ob_y+rsc[ROOT].ob_y+rsc[FAPP].ob_y)) < rsc[SLIDEOUT].ob_y)
							step_page( PAGEUP, SFOUT);
						else
							step_page( PAGEDOWN, SFOUT);
					}
					break;					

				case SLIDEIN:
					if( gest.state) 
					{
						ret= graf_slidebox( rsc, FSIN, SLIDEIN, 1);
						chge_page( ret, SFIN);
					}
					break;
				case SLIDEAPP:
					ret= graf_slidebox( rsc, FSAPP, SLIDEAPP, 1);
					chge_page( ret, SFAPP);
					break;
				case SLIDEOUT:
					if( gest.state) 
					{
						ret= graf_slidebox( rsc, FSOUT, SLIDEOUT, 1);
						chge_page( ret, SFOUT);
					}
					break;

				case IN:
					if( gest.state)	chge_connect( y, SFIN);
					release();
					break;
				case APP:
					applSelect( y);
					release();
					break;
				case OUT:
					if( gest.state) 	chge_connect( y, SFOUT);
					release();
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
		if( !rsrc_gaddr(R_TREE, MENU, &Adr_menu))
			return AlertUser( RSC_DAMAGED);
		if( !rsrc_gaddr(R_TREE, ABOUT, &Adr_about))
			return AlertUser( RSC_DAMAGED);
		if( gl_apid)
			Menu_id = menu_register(gl_apid,"  Midi Connecte");
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
	if( item== ABOUTID )
		ShowAbout();
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
	wi_handle= NO_WINDOW;				/* fenetre ferm‚e 	*/
	hidden=FALSE;						/* souris apparente */
	evType= MU_MESAG|MU_BUTTON;			/* evts attendus	*/	
	if( !SetUpRsc("msnet.rsc") && !gl_apid)
	{
		appl_exit();
		free_mem();
		exit( 1);
	}
	if( !gl_apid)		
	{
		if( !OpenAppl())				/* ouverture de l'application	*/
			exit( 1);
	}
}

/********************************************************************************/
/* 							Corps Principal						*/
/********************************************************************************/

void main()
{
short ret;
register short event, i;

	Initialize();
	
	doneFlag = FALSE;											
	while (!doneFlag) 							/* Main Loop			*/
	{

    		event = evnt_multi( evType,
			   1,1,1,
			   0,0,0,0,0,
			   0,0,0,0,0,
			   msgbuff,1,0,&mx,&my,&ret,&ret,&ret,&ret);

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
					if( !gl_apid)
						doneFlag= TRUE;
					break;
					
            		case WM_SIZED:
            			msgbuff[6]= wdesk;
            			if( msgbuff[7]< MIN_WSIZE) msgbuff[7]= MIN_WSIZE;
					msgbuff[7]-= (msgbuff[7] % H_LINE)-3;
					chge_h_rsc( i= msgbuff[7]- hdesk);
					chge_vslide( i);
            		case WM_MOVED:
			   	    	wind_set( wi_handle, WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
			    		wind_get( wi_handle, WF_CURRXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
			    		wind_get( wi_handle, WF_CURRXYWH,&xold,&yold,&wold,&hold);
				    	update_window();
	  		    		if( i< 0)
			    			do_redraw( xwork, ywork, wwork, hwork);
	  		    		i=0;
		  		    	break;

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
	
		if( event & MU_TIMER)
		{
			static short c= 10;
			if( !c--)
			{
				DoIdle();
				c= 10;
			}
		}

	} /* end while */
	exit(0);
}

/*======================== END CONNECT.C =========================*/