/*********************************************************************

	Midi Echo		Accessoire de bureau
	Module GEM

	GRAME		D. Fober
	24/10/89	
*********************************************************************/

#ifdef MWC
# include <gemdefs.h>
# include <osbind.h>
# include <aesbind.h>
# include <vdibind.h>
# include <obdefs.h>
#endif

#ifdef TURBO_C
# include <aes.h>
# include <vdi.h>
# include <tos.h>
#endif

#include "msecho.h"
#include "echo.h"

/*****************************************************************/
/* DEFINE  						   	     			*/
/*****************************************************************/

/*--------------------- gestion de la fenetre  ------------------*/

#define WI_KIND	(MOVER|CLOSER|NAME)	/* type de la fenetre */
#define NO_WINDOW 	(-1)				/* si la fenetre est ferm‚e */

/*****************************************************************/
/* GLOBAL VARIABLES					   	     			*/
/*****************************************************************/

/*---------------------------------------------------------------*/
/* les ressources  */
OBJECT *Adr_rsc, *Adr_menu, *Adr_infos;

/*---------------------------------------------------------------*/
/* les messages d'alerte */
char *Fenetre_mess= "[3][ | No more window available !| Close an unused window.][OK]";
char *Rsc_mess    = "[1][ | I don't find |  the ressource's file  | for Midi Echo !][OK]";
char *Rsc_pb  	   = "[1][ | Midi Echo : | Error reading ressource's  | file !][OK]";
char *MshNo_mess  = "[3][ | |  MidiShare   | is not resident !][OK]";
char *MshFull_mess= "[3][ | |  MidiShare can't |  open Midi Echo ! ][OK]";
char *screen_mess = "[1][ | Midi Echo : | works just in high resolution ! ][OK]";

/*---------------------------------------------------------------*/
/* les handlers menu, application, fenetres */
int Menu_id;				/* identificateur du menu */
int gl_apid;				/* identificateur de l'application */
int phys_handle;			/* physical workstation handle */
int handle;				/* virtual workstation handle */
int wi_handle;				/* window handle */

/*---------------------------------------------------------------*/
/* la gestion des fenetres */
int top_window;			/* handle de la fenetre courante */

/*---------------------------------------------------------------*/
/* les coordonn‚es de la fenetre sur le bureau */
int xdesk= 30, ydesk= 30, wdesk, hdesk;
int xwork, ywork, hwork, wwork;	/* l'espace de travail courant */

/*---------------------------------------------------------------*/
/* la gestion des evenements */
int	msgbuff[8];	/* event message buffer */
int	keycode;		/* keycode returned by event-keyboard */
int	mx,my;		/* mouse x and y pos. */
int  nbre_clics;	/* nbre de clics souris au retour de evnt_multi */
int  bt_state;		/* l'etat des boutons */
int	hidden;		/* current state of cursor */

/*---------------------------------------------------------------*/
/* storage wasted for idiotic bindings */
int	contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];	
int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */


/****************************************************************/
/* routines d'affichage 						*/
/****************************************************************/

#define alert(a,b)	form_alert( a, b)


/****************************************************************/
/*  GSX UTILITY ROUTINES.					*/
/****************************************************************/

hide_mouse()
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}

/****************************************************************/
/* open virtual workstation					*/
/****************************************************************/
open_vwork()
{
register int i;
	for(i=0;i<10;work_in[i++]=1);
	work_in[10]=2;
	handle=phys_handle;
	v_opnvwk(work_in,&handle,work_out);
}

/****************************************************************/
/* set clipping rectangle					*/
/****************************************************************/
set_clip(x,y,w,h)
int x,y,w,h;
{
int clip[4];
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w;
	clip[3]=y+h;
	vs_clip(handle,1,clip);
}

/************************************************************/
/* mise … jour de la gestion de la fenetre 			*/
/************************************************************/
void update_window()
{
	wind_get( wi_handle, WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	set_clip(xwork, ywork, wwork, hwork-1);
	Adr_rsc[ROOT].ob_x= xwork;
	Adr_rsc[ROOT].ob_y= ywork;
}

/****************************************************************/
/* ouverture d'une fenetre 							*/
/****************************************************************/
int open_window()
{
int ret;				/* dummy */
register OBJECT *ob;

	ob= Adr_rsc;
	if( !gl_apid)
		form_center( ob, &xdesk, &ydesk, &ret, &ret);
	wind_calc( WC_BORDER, WI_KIND, xdesk, ydesk, ob[ECHO].ob_width,\
		ob[ECHO].ob_height, &ret, &ret, &wdesk, &hdesk);

	wi_handle= wind_create( WI_KIND, xdesk, ydesk, wdesk, hdesk);
	if( wi_handle> 0) {
		wind_set( wi_handle, WF_NAME," MIDI ECHO ",0,0);
		wind_set( wi_handle, WF_NEXTXYWH,xdesk,ydesk,wdesk,hdesk);
		hide_mouse();
		graf_growbox( xdesk+wdesk/2, ydesk+hdesk/2, 40, 40, xdesk, ydesk, wdesk, hdesk);
		wind_open( wi_handle, xdesk, ydesk, wdesk, hdesk);
		show_mouse();
		update_window();
		return(TRUE);
	}
	else {
		alert(1, Fenetre_mess);
		return(FALSE);
	}
}

/****************************************************************/
/* find and redraw all clipping rectangles			*/
/****************************************************************/
do_redraw( xc,yc,wc,hc)
int xc,yc,wc,hc;			/* coord de la zone de retra‡age */
{
register OBJECT *ob;
GRECT t1,t2;

	ob= Adr_rsc;
	t2.g_x=xc;
	t2.g_y=yc;
	t2.g_w=wc;
	t2.g_h=hc;
	wind_get( wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	while (t1.g_w && t1.g_h) {
#ifdef MWC
	  if (rc_intersect(&t2,&t1)) 
#endif
	  {
	    	set_clip( t1.g_x, t1.g_y, t1.g_w-1, t1.g_h-1);
		objc_draw( ob, 0, 5, t1.g_x,t1.g_y,t1.g_w,t1.g_h);
	  }
	  wind_get( wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
    	set_clip( xwork, ywork, wwork, hwork-1);
}


/****************************************************************/
int get_adr_rsc()
{
	if( !(rsrc_gaddr(R_TREE, ECHO, &Adr_rsc)) )
		return FALSE;
	if( !(rsrc_gaddr(R_TREE, MENU, &Adr_menu)) )
		return FALSE;
	if( !(rsrc_gaddr(R_TREE, INFORME, &Adr_infos)) )
		return FALSE;
	return TRUE;
}

/****************************************************************/
int charge_rsc( rsc)
char *rsc;
{
	if( rsrc_load( rsc)){	/* charge les ressources */	
		if( get_adr_rsc()){
			if( gl_apid)
				Menu_id = menu_register(gl_apid,"  Midi Echo");
			else
				menu_bar( Adr_menu, 1);
			return TRUE;
		}
		else {
			alert( 1, Rsc_pb);
			rsrc_free();
		}
	}
	else alert( 1, Rsc_mess);
	return FALSE;
}

/****************************************************************/
void close_acc()		/* fermeture standard de l'accessoire */
{
	v_clsvwk( handle);				/* ferme la station de travail */
	if( !gl_apid){
		fin_connecte();			/* ferme l'application MidiShare */
		menu_bar( Adr_menu, 0);		/* supprime la barre des menus */
		rsrc_free();				/* libŠre les ressources */
		appl_exit();				/* libŠre l'application courante */
		exit();
	}
	if( !( (int)Getshift(-1) & K_ALT))	/* si alternate non appuy‚e */
		fin_connecte();
}

/****************************************************************/
void open_acc()			/* ouverture de l'accessoire */
{
register int ret;

	open_vwork();			/* ouverture d'une station de travail */
	ret= midi_connecte();	/* initialisation MidiShare */
	if( ret== MSH_OK) {		/* si init OK */
		if( open_window())		/* ouverture de la fenetre */
		{
			graf_mouse(ARROW, 0x0L);
			return;
		}
		else 
			close_acc();
	}
	else if( ret== MSH_NO)
		alert( 1, MshNo_mess);
	else if( ret== MSH_FULL)
		alert( 1, MshFull_mess);
	close_acc();
}

/****************************************************************/
/*		Accessory Init. Until First Event_Multi		*/
/****************************************************************/
void main()
{
int ret;
register char *rsc;

	gl_apid= appl_init();
	phys_handle=graf_handle(&ret,&ret,&ret,&ret);
	wi_handle= NO_WINDOW;		/* fenetre ferm‚e */
	hidden=FALSE;				/* souris apparente */
	if( Getrez()== 2)
		rsc= "msecho.rsc";
	else if( !gl_apid)
	{
		alert( 1, screen_mess);
		appl_exit();
		exit();
	}
	else multi();
	if( !charge_rsc( rsc) && !gl_apid){
		appl_exit();
		exit();
	}
	if( !gl_apid)
		open_acc();
	multi();			/* attente de l'ouverture de l'accessoire */
}

/****************************************************************/
/* dispatches all accessory tasks				*/
/****************************************************************/
multi()
{
int ret;
register int event, i;

  while(TRUE) {
    	
    	event = evnt_multi( MU_MESAG|MU_BUTTON,
			3,1,1,
			0,xwork, ywork, wwork, hwork,
			0,0,0,0,0,
			msgbuff,0,0,&mx,&my,&bt_state,&ret,&keycode,&nbre_clics);

	wind_update(BEG_UPDATE);
	wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);

	if (event & MU_MESAG) 
	  	switch (msgbuff[0]) {

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
				if( !gl_apid)
					wind_update(END_UPDATE);
				close_acc();
				break;
					
            	case WM_MOVED:
				i= wi_handle;
		   	    	wind_set( i, WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
		    		wind_get( i, WF_CURRXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
			    	update_window();
		  	    	break;

			case AC_CLOSE:
				if( (msgbuff[3]== Menu_id) && (wi_handle!= NO_WINDOW) )
				{
					wind_delete( wi_handle);
					wi_handle = NO_WINDOW;
					close_acc();
				}
				break;
				
			case AC_OPEN:
				if((msgbuff[4] == Menu_id) && (msgbuff[3])) {
					if( wi_handle== NO_WINDOW)
						open_acc();
					else
						wind_set(wi_handle,WF_TOP,0,0,0,0);
				}
				break;

	  		case MN_SELECTED:
	  			traite_menu( msgbuff[3], msgbuff[4]);
	  			break;

		  } /* switch (msgbuff[0]) */

	wind_update(END_UPDATE);
	
	if( event & MU_BUTTON) {
		if( bt_state== 1){
			if( wind_find( mx,my)== wi_handle)
				traite_entrees( mx, my);
		}
	}

  }
}

/**************************** fin ********************************/
