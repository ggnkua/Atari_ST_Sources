/* babel - News transport agent for STiK
 *
 * gem.c - GEM user interface code
 *
 * (c)1996 Mark Baker. Distributable under the terms of the GNU
 *                     general public licence
 *
 * $Id: gem.c,v 1.3 1996/07/28 14:26:38 mnb20 Exp $
 */
/* These include files are for gcc. For lattice, use aes.h/vdi.h. There
   may be other changes you need to make as well */

#include <aes.h>
#include <vdi.h>

#include <stdio.h>
#include <string.h>

#include "babel.h"

/* GCC's gem library doesn't include this for some reason */
#if !defined FIS_SOLID
#define FIS_SOLID 1
#endif

/* Window gadgets to use */
#define WINDOW_KIND ( MOVER | CLOSER | NAME )

/* size of window in characters */
#define WINDOW_WIDTH  40
#define WINDOW_HEIGHT 5

/* Evnt_multi() time out, in ms */
#define EVENT_TIMEOUT 0

/* Private function prototype */
void redraw( GRECT *area ) ;

/* A handful of globals */
short apid ;
short vdihandle ;
short windowhandle ;
short charheight, charwidth ;
short workout[57] ;
short workin[] = { 1, 1,1,1,1,1,1, FIS_SOLID, 1, WHITE, 2 } ;
int program_exit=FALSE;

/* Current status line */
char window_server[WINDOW_WIDTH];
char window_group[WINDOW_WIDTH];
char window_status[WINDOW_WIDTH] ;
char avserver[8];
extern Options opt ;

/*
 * initialise_gem() does the usual stuff
 */

void initialise_gem( void )
{
  short dummy ;
  short window_height, window_width ;
  char *addr;
  if( opt.mode == 'g' || opt.mode == 's')
  {
    /* Initialise AES and register app name */
    if( ( apid = appl_init() ) != -1 )
    {
//      menu_register( apid, strings.menu_name ) ;
    }
    else
    {
      alert("Appl_init did not work");
      byebye(1);
    }  
    /* Register to receive AP_TERM messages */
    shel_write( SWM_NEWMSG, 1, 0, NULL, NULL ) ;

    /* Search for the AVSERVER if any exist */
    if(!shel_envrn(&addr,"AVSERVER"))
      strcpy(avserver,"");
    else
      strcpy(avserver,addr+1);
    while (strlen(avserver) < 8)
      strcat(avserver, " ");
    
    
    
    /* Open virtual workstation */
    vdihandle = graf_handle( &charwidth, &charheight, &dummy, &dummy ) ;
    v_opnvwk( workin, &vdihandle, workout ) ;

    /* Centre text */
    vst_alignment( vdihandle, 1, 0, &dummy, &dummy ) ;

    /* Calculate window size */
    wind_calc( WC_BORDER, WINDOW_KIND, 100, 100, WINDOW_WIDTH * charwidth, WINDOW_HEIGHT * charheight, &dummy, &dummy, &window_width, &window_height) ;
      
    /* Create and open window */
    windowhandle = wind_create( WINDOW_KIND, 100, 100, window_width, window_height ) ;

    wind_title(windowhandle,strings.wind_name);
//    wind_set( windowhandle, WF_NAME, strings.wind_name ) ;
    wind_open( windowhandle, 100, 100, window_width, window_height ) ;

    window_status[WINDOW_WIDTH-1]=0;
    window_server[WINDOW_WIDTH-1]=0;
    window_group[WINDOW_WIDTH-1]=0;

    /* Normal mouse arrow */
    graf_mouse( ARROW, NULL ) ;
  }
}

/*
 * shutdown_gem() is pretty predictable as well
 */

void shutdown_gem( void )
{
  if( opt.mode == 'g' || opt.mode == 's')
  {
    /* Close and destroy window */
    if( windowhandle )
    {
      wind_close( windowhandle ) ;
      wind_delete( windowhandle ) ;
    }

    /* Close our virtual workstation */
    if( vdihandle )
    {
      v_clsvwk( vdihandle ) ;
    }  
    /* Shutdown AES */
    appl_exit() ;
  }
}

/*
 * status_line() checks for AES messages, allows other programs
 *    to execute, and redraws window with new status line
 */

void status_line( char *message , int important , char *server , char *group )
{
  if( opt.mode == 't' && important)
  {
    printf( "%s\n", message ) ;
  }
  else if( opt.mode == 'g' || opt.mode == 's')
  {
    /* Store current message */
    if (message)
    {
      strncpy( window_status, message ,WINDOW_WIDTH-1) ;
      window_status[WINDOW_WIDTH-1]=0;
    }
    if(server)
    {
      strcpy( window_server,"Server: ");
      strncat( window_server,server,WINDOW_WIDTH-1);
      window_server[WINDOW_WIDTH-1]=0;
    }
    if(group)
    {
      strcpy( window_group,"Group : ");
      strncat( window_group,group,WINDOW_WIDTH-1);
      window_group[WINDOW_WIDTH-1]=0;
    }
    /* Force redraw of window */
    redraw( NULL ) ;

    /* Do an evnt_multi once */
    event_loop() ;
  }
}

/*
 * redraw() redraws the contents of the window; area if non-null is the
 *    area that needs redrawing, otherwise all of it is redrawn.
 */

void redraw( GRECT *area )
{
  GRECT box ;
  short vdirect[4] ;
  short x, y, w, h ;
  short dummy;
  
  /* Prepare for redraw */
  wind_update( BEG_UPDATE ) ;
  graf_mouse( M_OFF, NULL ) ;

  /* Get first visible rectangle */
  wind_get( windowhandle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h ) ;

  /* While we get a valid box (it has non-zero area) */
  while( box.g_w && box.g_h )
  {
    /* Only redraw intersection of this box with redraw area, this does
       a continue if no intersection, or updates box if there is */
    if( area != NULL )
    {
      if( !rc_intersect( area, &box ) )
      {
        continue ;
      }
    }

    /* Set up a VDI rectangle to correspond to box */
    vdirect[0] = box.g_x ;
    vdirect[1] = box.g_y ;
    vdirect[2] = box.g_x + box.g_w - 1 ;
    vdirect[3] = box.g_y + box.g_h - 1 ;

    /* Set clipping rectangle */
    vs_clip( vdihandle, 1, vdirect ) ;

    /* Draw a white rectangle. It's white because I set it up that way
       when initialising */
    v_bar( vdihandle, vdirect ) ;
    wind_get( windowhandle, WF_WORKXYWH, &x, &y, &w, &h ) ;
    vst_alignment(vdihandle,0,0,&dummy,&dummy);
    y += charheight;
    x += charwidth;
    v_gtext( vdihandle , x , y , window_server ) ;
    y += charheight;
    v_gtext( vdihandle , x , y , window_group ) ;
    x += w / 2 ;
    y += 2*charheight ;
    vst_alignment(vdihandle,1,0,&dummy,&dummy);
    v_gtext( vdihandle, x, y, window_status ) ;

    /* Turn off clipping */
    vs_clip( vdihandle, 0, vdirect ) ;

    /* Get next rectangle */
    wind_get( windowhandle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h ) ; 
  }

  graf_mouse( M_ON, NULL ) ;
  wind_update( END_UPDATE ) ;
}

/*
 * event_loop() checks for AES messages, allows other programs
 *    to execute - notably STiK, since current versions are
 *    desk accessories.
 */

void event_loop( void )
{
  int ev ;
  short dummy ;
  short kstate, key ;
  short mesag[8] ;

  if( opt.mode == 'g' || opt.mode == 's')
  {
    /* Wait for an event */
    ev = evnt_multi( MU_KEYBD | MU_MESAG | MU_TIMER, /* Event mask */
                     0,0,0, 0,0,0,0,0, 0,0,0,0,0,    /* Not used */
                     mesag,                          /* Message buffer */
                     EVENT_TIMEOUT,0,                /* Timeout for timer event */
                     &dummy, &dummy, &dummy,         /* Not interested in mouse */
                     &kstate, &key,                  /* Keyboard return */
                     &dummy ) ;                      /* Not interested in mouse */

    /* Keyboard event */
    if( ev & MU_KEYBD )
    {
      if ( avserver[ 0 ] )
      {
        long server_id;
        server_id = appl_find( avserver ) ;
        if(server_id!=FAIL)
        {
          mesag[0]=(short)0x4710;
          mesag[1]=(short)apid;
          mesag[2]=(short)0;
          mesag[3]=(short)kstate;
          mesag[4]=(short)key;
          mesag[5]=(short)0;
          mesag[6]=(short)0;
          mesag[7]=(short)0;
          appl_write(server_id,16,mesag);
        }
      }
    }
    /* Mouse event */
    if( ev & MU_MESAG )
    {
      switch( mesag[0] )
      {
        case WM_REDRAW :
          /* Call redraw code. Cast is to interpret mesag[4]..[7] as
             a GRECT */
          redraw( (GRECT *)(mesag + 4) ) ;
          break ;
        case WM_TOPPED :
          /* Top window */
          wind_set( windowhandle, WF_TOP, windowhandle, 0,0,0 ) ;
          break ;
        case WM_CLOSED :
          /* Abort if the close box clicked */
          program_exit=TRUE;
          break ;
        case WM_MOVED :
          /* Move the window */
          wind_set( windowhandle, WF_CURRXYWH, mesag[4], mesag[5], mesag[6], mesag[7] ) ;
          break ;
        case WM_BOTTOM :
          /* Bottom the window */
          wind_set( windowhandle, WF_BOTTOM, windowhandle, 0,0,0 ) ;
          break ;
        case WM_ALLICONIFY :
        case WM_ICONIFY :
          /* Well, some day these'll be implemented */
          break ;
        case WM_UNICONIFY :
          /* This too... */
          break ;
        case AP_TERM :
          /* The system has been shut down, clean up nicely */
          program_exit=TRUE;
          break ;
      }
    }
  }
}

/*
 * alert() brings up - surprise surprise - an alert box
 */

void alert( char *text )
{
  char alert_string[100+1] ;
  if( opt.mode == 'g' )
  {
    Log("ERROR: %s\n",text);
    sprintf( alert_string, "[1][%s][Cancel]", text ) ;
    form_alert( 1, alert_string ) ;
  }
  else if( opt.mode == 't' )
  {
    printf( "%s\n", text ) ;
  }
}