/***********************************************/
/* Modul  : EXITFONT                           */
/* Aufgabe: Speicher der Fonts abmelden        */
/***********************************************/

#include <tos.h>
#include <vdi.h>
#include "initfont.h"

#include "exitfont.h"

void ExitFonts( int v_handle, FONTSTRCT *f )
{
   if( vq_gdos() )
      vst_unload_fonts( v_handle, 0 );

   Mfree( f );
}
