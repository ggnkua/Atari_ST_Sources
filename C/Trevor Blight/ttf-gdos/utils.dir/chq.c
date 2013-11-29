/***** (C) 1999 Trevor Blight ****************
* 
*  $Id: chq.c 1.1 1999/06/22 21:09:16 tbb Exp $
* 
*  ttf-gdos utility to modify print quality in FSMC cookie
*  
****************************************/

#include <stdlib.h>
#include <string.h>
#include <vdibind.h>
#include <aesbind.h>
#include <osbind.h>
#include <sysvars.h>
#include <unixlib.h>

typedef int int16;

#define TRAP    __asm__ volatile( "illegal" )

static int  ap_id;
static int  menu_id;
static char acc_name[] = "  print quality ...  \0";
static int  msg_buff[8];
static int  event;

static void die()
{
   /** an acc can't return, so go here instead **/
   while( 1 ) {
      event = evnt_mesag( msg_buff );
   } /* while */
} /* die() */


typedef struct {
   long id;
   void *arg;
} tCOOKIE;

struct {
   char  id[4];
   int16 values[10];
} *pgdos_info = NULL;

void main( void )
{
void *sav_ssp = Super(0);
register tCOOKIE *p = *(tCOOKIE **)_p_cookies;

   /** look for FSMC cookie ... **/

   if( p != NULL ) {
      while( p->id != 0L ) {
         if( p->id == 0x46534D43  /* 'FSMC' */ ) {
            pgdos_info = p->arg;
            break;
         } /* if */
         p++;
      } /* while */
   } /* if */

   Super(sav_ssp);

   /** set up acc ... */
   ap_id = appl_init();
   if( ap_id < 0 ) {
      Cconws( "chq: can't initialise\r\n" );
      die();
   } /* if */
   
   if( !vq_gdos() ) {
      form_alert( 1, "[1][chq: GDOS not present][Too Bad]" );
      die();
   } /* if */

   if( pgdos_info == NULL ) {
      form_alert( 1, "[1][chq: can't control|"
			 "printer quality|"
			 "with this GDOS][Too Bad]" );
      die();
   } /* if */

   menu_id = menu_register( ap_id, acc_name );
   if( menu_id < 0 ) {
      form_alert( 1, "[1][chq: can't start accessory][Too Bad]" );
      die();
   } /* if */
   
   /* Cconws( "chq $Revision: 1.1 $ ready to roll !!!\r\n" ); */
   
   /** main accessory loop ...
   ** wait to be activated, then set quality flag 
   **/
   while( 1 ) {
      event = evnt_mesag( msg_buff ); /* wait .. */

      /** if the message is for us, set the printer quality **/

      if( (msg_buff[0] == AC_OPEN) && (msg_buff[4] == menu_id) ) {
      register int qual_flag;
	 switch( form_alert( 1, "[0][select print quality][default|draft|final]" ) ) {
	 case 3: qual_flag = 1;  /* final button */
	         break;
	 case 2: qual_flag = 0;  /* draft button */
	         break;
	 default: qual_flag = -1; /* default button */
	 } /* switch */
	 pgdos_info->values[1] = qual_flag;
      } /* if */
   } /* while */

} /* main() */

/********************** end of chq.c ********************/

