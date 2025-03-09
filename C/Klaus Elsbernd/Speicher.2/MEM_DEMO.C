/* 		Testprogramm zu den	Routinen zur Speicherverwaltung 
 *
 * Autor: Klaus Elsbernd, Hilgardring 32, 6750 Kaiserslautern
 * 							 (c) 1992 MAXON Computer GmbH
 */

#include	<aes.h>
#include	<vdi.h>
#include	"mem.h"

extern	int	handle, work_out[];

void gem_prg (void)
{
   int i, j;
   register MYrec startrecord, record;
	 
	 	
	 graf_mouse(ARROW,0);	 
	 graf_mouse(M_OFF,0);	 
	 v_clrwk(handle);
	 graf_mouse(M_ON,0);	 
	 form_alert(0,"[0][Speicherverwaltungstest  ][ Start ]"); 	
   /* Schleife, die in jedem Durchlauf 387
    * Datenstrukturen anfordert und diese
    * anschliežend wieder freigibt.
    */
   graf_mouse(M_OFF,0);
   v_gtext(handle, (work_out[0]/2)-96, (work_out[1]/2)-8,"Test dauert max. 3 Min!");
   graf_mouse(M_ON,0);
   for (i = 0; i < 3000; i++) {
     for (startrecord = mkrec(),
          record = startrecord, j = 0;
          j < 387; j++) {
        record->meinZeiger = mkrec();
        record = record->meinZeiger;
     }
     for (record = startrecord, j = 0;
          j < 387; j++) {
        startrecord = record->meinZeiger;
        freemem((long)(sizeof(struct myrecord)),
                (long *)record);
        record = startrecord;
     }
   }
   vswr_mode(handle, MD_XOR);
   graf_mouse(M_OFF,0);
   v_gtext(handle, (work_out[0]/2)-96, (work_out[1]/2)-8,"Test dauert max. 3 Min!");
   graf_mouse(M_ON,0);
   vswr_mode(handle, MD_REPLACE);
	 form_alert(1,"[0][Test beendet!  ][ Ok ]"); 	
}

