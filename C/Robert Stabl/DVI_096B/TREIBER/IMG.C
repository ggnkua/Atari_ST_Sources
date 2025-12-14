#include <portab.h>
#include <mintbind.h>
#include <atarierr.h>

#include <stdlib.h>
#include <string.h>

#include <treiber.h>



/* Versucht Zeile zu Komprimieren */
WORD	compress_img_run( UBYTE *ziel, UBYTE *p, WORD *limit )
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
		/* Abstand zum n„chsten Ungleichen... */
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


UBYTE			line[8192];

/* Schreibe in DVI-Datei */
WORD	drucke( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi )
{
	IMGHEADER	hdr;
	WORD			max_spalte, zeile, lz;
	WORD			rep, th, i;
	UBYTE			l;

	th = (WORD)get_tempfile( "img" );
	if(  th<0  )
		return -1;

		/* Header */
	hdr.version = 1;
	hdr.headlen = (WORD)sizeof(IMGHEADER)/2;
	hdr.nplanes = 1;
	hdr.patlen = 2;
		/* Grafikaufl”sung festlegen */
	hdr.pixelw = (WORD)((25400L+h_dpi/2)/h_dpi);
	hdr.pixelh = (WORD)((25400L+v_dpi/2)/v_dpi);
		/* Grafikweite festlegen */
	hdr.linew = (WORD)weite;
	hdr.lines = (WORD)max_zeile;
	Fwrite( th, sizeof(IMGHEADER), &hdr );

	max_spalte = (WORD)((weite+7)/8);
	zeile = 0;
	weite = (weite+15)/16;
	weite *= 2;

	while(  zeile<max_zeile  )
 	{
 			/* Zeilenkopf */
 			/* gleiche Zeilen komprimieren */
 		for(  l=1;  0==memcmp( p, p+weite, max_spalte )  &&  zeile<max_zeile  &&  l<255;  l++, zeile++  )
 			p += weite;
 		Fwrite( th, 3L, "\0\0\xFF" );
		Fputchar( th, l, 0 );

			/* Eine Zeile in die Datei! */
		rep = lz = max_spalte;
		i = 0;
			/* Wir komprimieren (es bleibt auch nichts brig) */
		while(  lz>0  )
			i += compress_img_run( line+i, p+rep-lz, &lz );
		Fwrite( th, (LONG)i, line );

		p += weite;
		zeile++;
	}
	Fclose( th );
	/* Sollte immer gut gehen! (d.h. kein File zum Drucken!) */
	return 0;
}
/* 22.1.93 */


