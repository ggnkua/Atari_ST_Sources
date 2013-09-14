#include "stuffptr.h"

EXTERN  WORD AES_Version;
MFORM	mfAlert, mfOther;


/* MODIFIED 04/28/92 CJG -
 * SAVE is now DISABLED......
 * RESTORE will force the mouse image to an arrow.
 *
 * MODIFIED 07/06/92 CJG -
 * RESTORE is disabled now also...
 *
 * MODIFIED 07/07/92 cjg
 * If we are on AES version >= 3.2, then save it using graf_mouse
 * otherwise, skip and do nothing.
 *
 * MODIFIED 01/14/93 cjg
 * Restore the mouse to an ARROW if we're less than 3.2
 */
void cdecl
MFsave( BOOLEAN saveit, MFORM *mf )
{
   
   if( AES_Version >= 0x0320 )
   {
     if( saveit )
     {
        graf_mouse( 258, 0L );
     }
     else
     {
   	graf_mouse( 259, 0L );
     }
   }
   else
   {
       /* If we're LESS than the latest AES, then let's slam it back
        * to an arrow for them. Regardless. This way, we don't have
        * BUSYBEEs etc, lying around.
        */
       if( !saveit )
          graf_mouse( ARROW, 0L );
   }  
}
