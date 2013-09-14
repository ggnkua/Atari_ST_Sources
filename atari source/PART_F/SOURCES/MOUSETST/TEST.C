#include <aes.h>
#include <vdi.h>
#include <stdio.h>

#include "stuffptr.h"

MFORM	mfAlert, mfOther;



void
main( void )
{
     appl_init();
     
     linea_init();
     graf_mouse( BUSYBEE, 0L );
     printf( "\n\nHit a Key - Saving Bee, making arrow.\n" );
     evnt_keybd();

     MFsave( TRUE, &mfOther );
     graf_mouse( ARROW, 0L );

     printf( "Hit a Key - Restore Bee\n" );
     evnt_keybd();
     
     MFsave( FALSE, &mfOther );
     evnt_keybd();
     appl_exit();
}



void
MFsave( BOOLEAN saveit, MFORM *mf )
{
	if( saveit )
	{
		*mf = *(MFORM *)(&Vdiesc->m_pos_hx);
	}
	else
	{
		*(MFORM *)(&Vdiesc->m_pos_hx) = *mf;
		Vdiesc->cur_flag = 1;
	}
}
