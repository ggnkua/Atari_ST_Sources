/***** (C) 1996-1997, Trevor Blight *****
* 
*  $Id: chpr.c 1.12 1999/12/11 23:12:58 tbb Exp tbb $
* 
*  ttf-gdos utility to swap devices 21 & 22
*  
****************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vdibind.h>
#include <aesbind.h>
#include <osbind.h>
#include <sysvars.h>
#include "ttf-gdos.h"

#define TRAP    __asm__ volatile( "illegal" )

#define EFILNF (-33)

static int  ap_id;
static int  menu_id;
static char acc_name[] = "  use 12345678.123\0";
static int  msg_buff[8];
static int  event;
static char cpy_msg[] = "copying 12345678.123";
static OBJECT rs_object[] = {
    -1, 1, 1,G_BOX,   0x0, 0x0, 0x21190L, 0,0,25,3,  /* 0 root of dialog box */
     0,-1,-1,G_STRING,0x20,0x0, cpy_msg,  1,1,22,1   /* 1 progress string */
     };

/*   ^  ^  ^    ^      ^    ^    ^        ^ ^  ^ ^
     |  |  |    |      |    |    |        | |  | +-- ob_height height of obj (now chars, but
     |  |  |    |      |    |    |        | |  +---- ob_width  width  of obj (must cnvt to pixels
     |  |  |    |      |    |    |        | +------- ob_y      y coord relative to parent
     |  |  |    |      |    |    |        +--------- ob_x      x coord relative to parent
     |  |  |    |      |    |    +-----------------  ob_spec   obj determines meaning (p11-55,60)
     |  |  |    |      |    +----------------------  ob_state  current state of obj (p.11-61 MM)
     |  |  |    |      +---------------------------  ob_flags  attributes for obj (p.11-60 MM)
     |  |  |    +----------------------------------  ob_type   object type (p. 11-59 MM)
     |  |  +---------------------------------------  ob_tail   ptr to last child of obj or -1
     |  +------------------------------------------  ob_head   ptr to first child of obj or -1
     +---------------------------------------------  ob_next   ptr to next sibling or -1

*/

static void die()
{
   /** an acc can't return, so go here instead **/
   while( 1 ) {
      event = evnt_mesag( msg_buff );
   } /* while */
} /* die() */

static char err_buf[80];
static void err_msg( char *msg, char *arg )
{
   sprintf( err_buf, msg, arg );
   form_alert( 1, err_buf );

} /* err_msg() */


void main( void )
{
TTF_GDOS_INF_RECORD *p = (TTF_GDOS_INF_RECORD *)vq_vgdos();
WORKSTN_RECORD  *p1 = NULL, *p2 = NULL;
int xdial,ydial,wdial,hdial;         /* co-ords for dialog box */
int  x,y,w,h;

   /** set up acc ... */
   ap_id = appl_init();
   if( ap_id < 0 ) {
      Cconws( "chpr: can't initialise\r\n" );
      die();
   } /* if */
   
   /** look for ttf-gdos ... **/
   
   if( p == (TTF_GDOS_INF_RECORD *)GDOS_NONE ) {
      form_alert( 1, "[1][chpr: gdos not present][Too Bad]" );
   }
   else if( (((uint32)p&1) != 0)
        ||  (long)p <= 0x800 /* bot of mem */ 
	||  (long)p >= get_sysvar(phystop)
	||  p->magic_nr != MAGIC_NR ) {
      form_alert( 1, "[1][chpr: ttf-gdos not present][Too Bad]" );
   }
   else if( p->version < MY_VERSION ) {
      form_alert( 1, "[3][please upgrade to|latest version of ttf-gdos][OK]" );
   }
   else if( p->version > MY_VERSION ) {
      form_alert( 1, "[3][please use latest version of chpr][good idea]");
   }
   else {
      /** found ttf-gdos, ==> find device 21 & 22 **/
      uint16 n = p->nr_wkstns;
      WORKSTN_RECORD *pw = p->workstn_table;
      while( n > 0 ) {
         if( pw->id == 21 ) {
	    p1 = pw;
	 }
	 else if( pw->id == 22) {
	    p2 = pw;
	 } /* if */
	 pw++; n--;
      } /* while */
      if( p1 == NULL) {
         form_alert( 1, "[1][chpr: printer 21 not found][Too Bad]" );
      } /* if */
      if( p2 == NULL ) {
         form_alert( 1, "[1][chpr: printer 22 not found][Too Bad]" );
      } /* if */
   } /* if */
   
   if( (p1 == NULL) || ( p2 == NULL ) ) {
      die();
   } /* if */
   
   menu_id = menu_register( ap_id, acc_name );
   if( menu_id < 0 ) {
      form_alert( 1, "[1][chpr: can't register accessory][Too Bad]" );
      die();
   } /* if */

   /* Cconws( "chpr $Revision: 1.12 $ ready to roll !!!\r\n" ); */
   rsrc_obfix(rs_object,0);        /* chg coord from char to pixel */
   rsrc_obfix(rs_object,1);        /* chg coord from char to pixel */
   form_center (&rs_object,&xdial,&ydial,&wdial,&hdial);
   
   while( 1 ) {
   
      /** copy all files from (device 21)->driver_name dir to current dir ... **/
      if( Dsetpath( (p1->id==21? p1: p2)->driver_name )==0 ) {
      struct _dta new_dta;
      struct _dta *const old_dta = (struct _dta *)Fgetdta();
	 Fsetdta( &new_dta );
	 if( Fsfirst("*.*", 0)==0 ) {
	    x=y=w=h=0;
	    form_dial (FMD_START,x,y,w,h,xdial,ydial,wdial,hdial);	/* reserve room */
	    do {
	    int sfh;
	       sprintf( cpy_msg, "copying %s", new_dta.dta_name );
	       objc_draw( &rs_object, 0, 2, xdial, ydial, wdial, hdial ); /* draw the dialog box */
	       sfh = Fopen( new_dta.dta_name, 0);    /* read only */
	       if( sfh >= 0 ) {
		  void *buf = (void *)Malloc(new_dta.dta_size);
		  if( buf != NULL ) {
		  char dfn[20] = "..\\";
		  int dfh;
		     if( Fread( sfh, new_dta.dta_size, buf ) == new_dta.dta_size ) {
			strcpy( dfn+3, new_dta.dta_name );
			dfh = Fopen( dfn, 1 );	     /* write only */
			if( dfh == EFILNF ) {
			   dfh = Fcreate( dfn, 0 );
			} /* if */
			if( dfh>=0 ) {
			   if( Fwrite( dfh, new_dta.dta_size, buf ) == new_dta.dta_size ) {
			      /* success!  */
			   } else {
			      err_msg( "[1][chpr: can't write file| %s][ok]", dfn );
			   } /* if */
			   (void)Fclose( dfh );
			} else {
			   err_msg( "[1][chpr: can't open dest file| %s][ok]", dfn );
			} /* if */
		     } else {
			err_msg( "[1][chpr: can't read file: %s][ok]", new_dta.dta_name );
		     } /* if */
		     (void)Mfree( buf );
		  } else {
		     err_msg( "[1][chpr: can't get memory for file copy][ok]", "" );
		  } /* if */
		  (void)Fclose( sfh );
	       } else {
		  err_msg( "[1][chpr: can't open file: %s][ok]", new_dta.dta_name );
	       } /* if */
	    } while (Fsnext() == 0);
	    form_dial( FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial );  /* release its room */
	 } /* if */
	 Fsetdta( old_dta ); /* restore dta */
	 (void)Dsetpath( "..\\" );   /* assume successful */
      } /* if */

      sprintf( acc_name, "  use %s", (p1->id==21? p2: p1)->driver_name );
      event = evnt_mesag( msg_buff );
      if( (msg_buff[0] == AC_OPEN) && (msg_buff[4] == menu_id) ) {
         /** swap the printer drivers **/
	 Cconws( "\a\a\a" );
	 /** now it's ok to swap **/
	 if( p1->id == 21 ) {
	    p1->id = 22;
	    p2->id = 21;
	 }
	 else
	 {
	    p1->id = 21;
	    p2->id = 22;
	 } /* if */

      } /* if */
   } /* while */

} /* main() */

/********************** end of chpr.c ********************/

