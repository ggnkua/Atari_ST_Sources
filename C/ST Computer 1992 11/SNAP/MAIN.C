/* MAIN.C
   (c) 1992 MAXON Computer
*/


#include <aes.h>
#include <vdi.h>
#include "rect.h"


void ResizeWindow( int handle, int x, int y );
void MoveWindow( int handle, int x, int y );
int RedrawWindow( int handle );

int  crkind = NAME|CLOSER|MOVER|SIZER,
     vhandle;


int main( void )
{
   int  handle,
        finish = 0,
        dummy, i,
        defx, defy, defw, defh,
        msg[8],
        work_in[11],
        work_out[57];


   /* Bei den AES anmelden */
   if( appl_init() < 0 )
      return( -1 );

   /* VDI-Workstation anmelden */
   vhandle = graf_handle( &dummy, &dummy,
                          &dummy, &dummy );
   for( i = 0; i < 10; work_in[i++] = 1 );
   work_in[10] = 2;
   v_opnvwk( work_in, &vhandle, work_out );
   if( !vhandle )
   {
      appl_exit();
      return( -1 );
   }
   vswr_mode( vhandle, MD_REPLACE );
   vsf_interior( vhandle, FIS_HOLLOW );
   vsl_width( vhandle, 1 );
   

   /* Default Fenstergr”že ermitteln */
   wind_get( 0, WF_WORKXYWH,
             &defx, &defy, &defw, &defh );

   /* Fenster erzeugen */
   handle = wind_create( crkind,
                         defx, defy, defw, defh );
   if( handle < 0 )
      return( -1 );

   /* Name setzen */
   wind_set( handle, WF_NAME,
             " RectToElement-Demo " );

   /* Fenster ”ffnen */
   if( !wind_open( handle,
                   defx, defy, defw, defh ) )
      return( -1 );

   graf_mouse( ARROW, 0L );

   /* Eventschleife */
   while( !finish )
   {
      evnt_mesag( msg );

      switch( msg[0] )
      {
         case WM_CLOSED :
               finish = 1;
               break;

         case WM_SIZED  :
               ResizeWindow( msg[3], msg[6], msg[7] );
               break;

         case WM_MOVED  :
               MoveWindow( msg[3], msg[4], msg[5] );
               break;

         case WM_REDRAW :
               RedrawWindow( msg[3] );
               break;
      }
   }


   v_clsvwk( vhandle );

   appl_exit();


   return( 0 );
}




void ResizeWindow( int handle, int w, int h )
{
   GRECT  wind;


   wind_get( handle, WF_CURRXYWH,
             &wind.g_x, &wind.g_y,
             &wind.g_w, &wind.g_h );

   wind.g_w = w;
   wind.g_h = h;

   wind_calc( WC_WORK, crkind, 
              wind.g_x,  wind.g_y,
              wind.g_w,  wind.g_h,
              &wind.g_x, &wind.g_y,
              &wind.g_w, &wind.g_h );

   RectToElement( &wind, 40, 40, DOSETW|DOSETH );

   wind_calc( WC_BORDER, crkind, 
              wind.g_x,  wind.g_y,
              wind.g_w,  wind.g_h,
              &wind.g_x, &wind.g_y,
              &wind.g_w, &wind.g_h );

   wind_set( handle, WF_CURRXYWH,
             wind.g_x, wind.g_y,
             wind.g_w, wind.g_h );

   RedrawWindow( handle );
}




void MoveWindow( int handle, int x, int y )
{
   GRECT  wind;


   wind_get( handle, WF_CURRXYWH,
             &wind.g_x, &wind.g_y,
             &wind.g_w, &wind.g_h );
   wind.g_x = x;
   wind.g_y = y;

   wind_calc( WC_WORK, crkind, 
              wind.g_x,  wind.g_y,
              wind.g_w,  wind.g_h,
              &wind.g_x, &wind.g_y,
              &wind.g_w, &wind.g_h );

   RectToElement( &wind, 40, 40, DOSETX|DOSETY );

   wind_calc( WC_BORDER, crkind, 
              wind.g_x,  wind.g_y,
              wind.g_w,  wind.g_h,
              &wind.g_x, &wind.g_y,
              &wind.g_w, &wind.g_h );

   wind_set( handle, WF_CURRXYWH,
             wind.g_x, wind.g_y,
             wind.g_w, wind.g_h );
}



int RedrawWindow( int handle )
{
   int    pxy[4];
   GRECT  wind;


   graf_mouse( M_OFF, 0L );
   wind_update( BEG_UPDATE );


   if( wind_get( handle, WF_FIRSTXYWH,
                 &wind.g_x, &wind.g_y,
                 &wind.g_w, &wind.g_h ) )
      while( wind.g_w && wind.g_h )
      {
         pxy[0] = wind.g_x;
         pxy[1] = wind.g_y;
         pxy[2] = wind.g_x + wind.g_w - 1;
         pxy[3] = wind.g_y + wind.g_h - 1;

         vr_recfl( vhandle, pxy );

         v_pline( vhandle, 2, pxy );

         pxy[0] = wind.g_x + wind.g_w - 1;
         pxy[2] = wind.g_x;
         v_pline( vhandle, 2, pxy );

         /* n„chstes Rechteck */
         if( !wind_get( handle, WF_NEXTXYWH,
                        &wind.g_x, &wind.g_y,
                        &wind.g_w, &wind.g_h ) )
            wind.g_w = wind.g_h = 0;
   }


   graf_mouse( M_ON, 0L );
   wind_update( END_UPDATE );


   return( 1 );
}
