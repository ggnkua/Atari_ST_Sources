/***********************************************/
/* Modul  : EXITVWK                            */
/* Aufgabe: VDI-Bildschirm-Workstation         */
/*          abmelden                           */
/***********************************************/

#include <vdi.h>

#include "exitvwk.h"

void ExitVWork( int v_handle )
{
   v_clsvwk( v_handle );
}
