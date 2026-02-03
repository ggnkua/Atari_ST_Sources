/*********************************************************************
**** VDI-Treiber, gibt Seite Åber GDOS aus, sicher die langsamste ****
**** Art, dafÅr gehts es mit jedem GDOS-Drucker, der Bitimages    ****
**** ausgeben kann.																								****
*********************************************************************/


#include <portab.h>
#include <atarierr.h>

#include <vdi.h>
#include <stdlib.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"


/* Schreibe in DVI-Datei */
WORD	drucke( UBYTE *p, LONG weite, LONG hoehe, LONG h_dpi, LONG v_dpi )
{
	WORD			i, work_in[12], work[56];
	LONG			addr;
	MFDB			bitmap, drucker;

	bitmap.fd_addr = p;
	bitmap.fd_w = (int)weite;
	bitmap.fd_h = (int)hoehe;
	bitmap.fd_wdwidth = (int)(weite+15)>>4;
	bitmap.fd_stand = 1;
	bitmap.fd_nplanes = 1;

	if(  vq_gdos()==0  )
	{
		Cconws( "\007\033HKein GDOS!" );
		return -1;
	}
	/* Und nun die Ausgabe auf GerÑt 21 */
  for(  i=1;  i<10;  i++  )
    work_in[i] = 1;
  work_in[10] = 2; /* Raster-Koordinaten! */
  work_in[0] = i = 21;
	v_opnwk( work_in, &i, work );
	addr = _VDIParBlk.contrl[0];
	addr = (addr<<16)|_VDIParBlk.contrl[1];
	drucker.fd_addr = (char *)addr;
	drucker.fd_w = work[0];
	drucker.fd_h = work[1];
	drucker.fd_wdwidth = (work[0]+15)>>4;
	drucker.fd_stand = 1;
	drucker.fd_nplanes = 1;

	if(  i>0  )
	{
		if(  addr!=0x00010000L  &&  addr>2048  )
		{
			Cconws( "\033H*" );
			work_in[0] = work_in[1] = 0;
			work_in[4] = work_in[5] = 0;
			work_in[2] = work_in[6] = (short)weite;
			if(  weite>drucker.fd_w  )
				work_in[2] = work_in[6] = drucker.fd_w;
			work_in[3] = work_in[7] = (short)hoehe;
			if(  hoehe>drucker.fd_h  )
				work_in[3] = work_in[7] = drucker.fd_h;
			work[0] = 0;	/* Farben */
			work[1] = 1;
			Cconws( "\033H+" );
			vrt_cpyfm( i, MD_REPLACE, work_in, &bitmap, &drucker, work );
			Cconws( "\033H*" );
			v_updwk( i );
		}
		else
			Cconws( "\007\033HZu altes GDOS!" );
		v_clswk( i );
	}
	else
		Cconws( "\007\033HGDOS-Fehler!" );

	/* Sollte immer gut gehen! (d.h. kein File zum Drucken!) */
	return 0;
}
/* 22.1.93 */


