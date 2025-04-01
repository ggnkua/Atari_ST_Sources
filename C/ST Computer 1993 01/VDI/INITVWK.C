/***********************************************/
/* Modul  : INITVDI                            */
/* Aufgabe: VDI-Bildschirm-Workstation anlegen */
/***********************************************/

#include <aes.h>
#include <vdi.h>

#include "initvwk.h"

int InitVWork( int *v_handle,
               int *pixel_width,
               int *pixel_height,
               int *scr_width,
               int *scr_height,
               int *ch_width,
               int *ch_height,
               int *planes )
{
   int  i,
        ch_w,
        ch_h,
        work_in[11],
        work_out[57],
        _void;

   *v_handle = graf_handle( &ch_w, &ch_h,
                            &_void, &_void );
   for ( i = 0; i < 10; work_in[i++] = 1 );
   work_in[10] = 2;

   v_opnvwk( work_in, v_handle, work_out );

   if( !*v_handle )
      return( 0 );

   if( pixel_width )
      *pixel_width  = work_out[3];
   if( pixel_height )
      *pixel_height = work_out[4];
   if( scr_width )
      *scr_width    = work_out[0] + 1;
   if( scr_height )
      *scr_height   = work_out[1] + 1;

   if( ch_width )
      *ch_width  = ch_w;
   if( ch_height )
      *ch_height = ch_h;

   if( planes )
   {
      vq_extnd( *v_handle, 1, work_out );
      *planes = work_out[4];
   }

   return( 1 );
}
