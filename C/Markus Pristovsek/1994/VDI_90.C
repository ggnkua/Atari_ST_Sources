/***************************************************************************/
/*  Querdruck fÅr GDOS-Drucker                                             */
/***************************************************************************/


#include <portab.h>
#include <vdi.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"



/* Versucht Zeile zu Komprimieren */
LONG	compress_img_run( UBYTE *ziel, UBYTE *p, LONG *limit )
{
	UBYTE	i;

		/* Sonst getrennt */
	if(  p[0]==0xFF  ||  p[0]==0  )
	{
		for(  i=1;  p[i]==p[0]  &&  i<*limit  &&  i<0x7F;  i++  )
			;
		ziel[0] = (0x80 & p[0]) | i;
		(*limit) -= i;
		return 1;
	}
	else
	{
		/* Abstand zum nÑchsten Ungleichen... */
		for(  i=0;  p[i]!=0  &&  p[i]!=0xFF  &&  i<127  &&  i<*limit;  i++  )
			ziel[i+2] = p[i];
		ziel[0] = 0x80;
		ziel[1] = i;
		(*limit) -= i;
		return i+2;
	}
}
/* 17.1.93 */



typedef struct {
	unsigned version;
	unsigned headlen;
	unsigned nplanes;
	unsigned patlen;
	unsigned pixelw;
	unsigned pixelh;
	unsigned linew;
	unsigned lines;
/*	unsigned palette[16]; Sind eh monochrom */
} IMGHEADER;


char	tmp_zeile[8192];	/* Gedrehte Zeilen + Sicherheit */
char	line[8192];	/* Gedrehte Zeilen + Sicherheit */
char	display_status[4]="\033H*";
UBYTE	*drucker_ext="img";


/* Datei ausdrucken */
WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	extern char tmp_file[256];
	IMGHEADER	hdr;
	LONG			max_spalte, wweite, lz;
	WORD			work_in[12], work[56];
	LONG			rep, x, i;

	if(  th!=3  ||  start_y>0  ||  vq_gdos()==0  ||  flag!=7  )
	{
		Cconout( 7 );
		return -1;
	}
	th = (WORD)get_tempfile();
	if(  th<0  )
		return -1;

		/* Header */
	hdr.version = 1;
	hdr.headlen = (WORD)sizeof(IMGHEADER)/2;
	hdr.nplanes = 1;
	hdr.patlen = 2;
		/* Grafikauflîsung festlegen */
	hdr.pixelw = (WORD)((25400L+v_dpi/2)/v_dpi);
	hdr.pixelh = (WORD)((25400L+h_dpi/2)/h_dpi);
		/* Grafikweite festlegen */
	hdr.linew = (WORD)max_zeile;
	hdr.lines = (WORD)weite;
	Fwrite( th, sizeof(IMGHEADER), &hdr );

	max_spalte = (max_zeile+7)/8;
	x = 0;
	wweite = (weite+15)/16;
	wweite *= 2;
	Cconws( display_status );

	for(  i=0;  x<weite;  x++  )
	{
		if(  (x%128)==0  )
		{
			Cconws( display_status );
			display_status[2] ^= 1;
		}
		drehe_90( p, tmp_zeile, wweite, max_spalte, x );
 		Fwrite( th, 4L, "\000\000\377\001" );

			/* Eine Zeile in die Datei! */
		rep = lz = max_spalte;
		i = 0;
		while(  lz>0  )
			i += compress_img_run( line+i, tmp_zeile+rep-lz, &lz );
		Fwrite( th, (LONG)i, line );
 	}
 	Fclose( th );

	/* Und nun die Ausgabe auf GerÑt 21 */
  for(  i=1;  i<10;  i++  )
    work_in[i] = 1;
  work_in[10] = 2; /* Raster-Koordinaten! */
  work_in[0] = th = 21;
	v_opnwk( work_in, &th, work );
	if(  th>0  )
	{
		Cconws( "\033Hp" );
		work_in[0] = work_in[1] = 0;
		work_in[2] = work[0];
		work_in[3] = work[1];
		v_bit_image(	th, tmp_file, 0,
									1, 1, /* Ganzahlig xy */
									0, 0, /* Links oben */
									work_in );
		v_updwk( th );
		v_clswk( th );
		Fdelete( tmp_file );
	}
	else
		Cconout( 7 );

	return 0;
}


