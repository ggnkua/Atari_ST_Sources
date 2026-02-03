/***************************************************************************/
/*  Querdruck fÅr IMG-Dateien                                              */
/***************************************************************************/


#include <portab.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"

char	*drucker_ext="img";


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


/* Datei ausdrucken */
WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG hoehe, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	IMGHEADER	hdr;
	LONG			max_spalte, wweite, lz;
	LONG			rep, i, x;
	UBYTE			and_it;

	if(  flag!=7  ||  th==3  )
	{
		(void)start_y;
		Cconws( "Bitte Dateinamen angeben!\007" );
		return -1;
	}
	if(  flag==4  )
		return 0;

		/* Header */
	hdr.version = 1;
	hdr.headlen = (WORD)sizeof(IMGHEADER)/2;
	hdr.nplanes = 1;
	hdr.patlen = 2;
		/* Grafikauflîsung festlegen */
	hdr.pixelw = (WORD)((25400L+v_dpi/2)/v_dpi);
	hdr.pixelh = (WORD)((25400L+h_dpi/2)/h_dpi);
		/* Grafikweite festlegen */
	hdr.linew = (WORD)hoehe;
	hdr.lines = (WORD)(start_x+weite);
	Fseek( 0L, th, 0 );
	Fwrite( th, sizeof(IMGHEADER), &hdr );
	Fseek( 0L, th, 2 );

	max_spalte = (hoehe+7)/8;
	and_it = 0x00FF;
	if(  (hoehe&7)>0  )
		and_it = (WORD)(0x00FF00L >> (hoehe&7));
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
		tmp_zeile[max_spalte] &= and_it;
		rep = lz = max_spalte;
		i = 0;
		while(  lz>0  )
			i += compress_img_run( line+i, tmp_zeile+rep-lz, &lz );
		Fwrite( th, (LONG)i, line );
 	}
	return 0;
}


