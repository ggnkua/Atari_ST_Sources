#include <portab.h>
#include <mintbind.h>
#include <stdlib.h>
#include <string.h>

#include "treiber.h"

/***************************/
/* Version 1.0 von 10.2.93 */
/* Nur 240*216 dpi         */
/***************************/
/* Version 1.1 von 1.3.93  */
/* Alle Aufl”sungen, d.h.  */
/* hor.: 240,120,90,80,72  */
/* ver.: 216,144,72 dpi    */
/***************************/


VOID	block_out( UBYTE *dest, UBYTE *src, WORD ende, LONG offset, WORD hoehe )
{
	WORD		i, j, k;

#if 0
	if(  hoehe<8  )
	{
		/* Nur wenn es wirklich n”tig ist die langsame Bitpfriemelei */
		for(  i=0;  i<=ende;  i++  )
		{
			/* Byte-Pfriemeln */
			for(  j=7;  j>=0;  j--  )
			{
				*dest = 0;
				for(  k=0;  k<hoehe;  k++  )
					*dest |= ((src[0+k*offset]>>j)&1)<<(7-k);
			}
			dest++;
			src++;
		}
		return;
	}
#endif

	/* So ist wesentlich schneller */
	for(  i=0;  i<=ende;  i++  )
	{
		/* Byte-Pfriemeln */
		for(  j=7;  j>=0;  j--  )
		{
			*dest = 0;
			*dest |= ((src[0]>>j)&1)<<7;
			*dest |= ((src[offset]>>j)&1)<<6;
			*dest |= ((src[offset*2]>>j)&1)<<5;
			*dest |= ((src[offset*3]>>j)&1)<<4;
			*dest |= ((src[offset*4]>>j)&1)<<3;
			*dest |= ((src[offset*5]>>j)&1)<<2;
			*dest |= ((src[offset*6]>>j)&1)<<1;
			*dest |= (src[offset*7]>>j)&1;
			dest++;
		}
		src++;
	}
}
/* 20.1.93 */


static UBYTE	dpi_modus[]={ 240, '3', 120, '1', 90, '6', 80, '4', 72, '5' };
static UBYTE	tmp[8192];

WORD	drucke( UBYTE *p, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi )
{
	UBYTE	modus, v_modus;
	LONG	max_spalte, zeile, lz, links, linker_rand, rechts;
	LONG	h_len, len, i;
	WORD	th;

	th = (WORD)get_tempfile( "n9" );
	if(  th<0  )
		return -1;

		/* Aufl”sung feststellen */
	for(  i=8;  i>0  &&  h_dpi>dpi_modus[i];  i-=2  )
		;
	modus = dpi_modus[i+1];
	h_dpi = dpi_modus[i];
	if(  v_dpi>175  )
		v_modus = 3;	/* Hochaufl”send */
	else if(  v_dpi>110  )
		v_modus = 2;	/* naja... */
	else
		v_modus = 1;	/* und Kl”tzchengraphic */

		/* Ab hier wird es ernst */
	if(  weite<1920*h_dpi/240L  ) /* Fr DINA3 vergr”žern! */
		max_spalte = (weite+7)/8;
	else
		max_spalte = 240*h_dpi/240L;

	zeile = 0;
	weite = (weite+15L)/16L;
	weite *= 2;
	Fwrite( th, 7L, "\33@\33P\33\63\1" ); /* Reset + Pic-Dichte + Zeilenabstand 1/216 */

	/* Linken Rand festlegen */
	for(  lz=0;  ist_next_leer( p+lz, weite, max_zeile )  &&   lz<max_spalte;  lz++  )
		;
	if(  modus=='3'  &&  lz>2  )
	{
		/* Dazu den immer gleichen Rand schon einmal schicken */
		Fwrite( th, 2L, "\33l" );
		Fputchar( th, lz/3, 0 );
		max_spalte -= lz/3;
		linker_rand = lz%3;
		p += lz-linker_rand;
	}
	else
		linker_rand = lz;

	/* Endlich drucken */
	while(  zeile<max_zeile  )
 	{
 		/* Leerzeilen berspringen */
 		for(  lz=0;  ist_leerzeile( p, max_spalte )  &&  zeile<max_zeile;  lz++, zeile++  )
 			p += weite;

		lz = (lz*3)/v_modus;
 		while(  lz>0  )
		{
			Fwrite( th, 3L, "\33f\1" );
			if(  lz>255  )
				Fputchar( th, 255, 0 );
			else
				Fputchar( th, lz, 0 );
			lz -= 255;
		}

			/* R„nder feststellen */
 		for(  rechts=max_spalte-1;  ist_next_leer( p+rechts, weite, v_modus*8 )  &&  rechts>linker_rand;  rechts--  )
 			;
		/* Leerzeichen am linken Rand */
		for(  lz=linker_rand;  ist_next_leer( p+lz, weite, v_modus*8 )  &&   lz<rechts;  lz++  )
			;
 		if(  modus=='3'  )
 		{
			links = lz-linker_rand;
			rechts ++;
	
			/*  gleichen Anfang festlegen und Leerzeichen berspringen */
			tmp[0] = 13; /* CR */
			if(  links>2  )
				memset( tmp+1, ' ', links/3 );
			tmp[links/3+1] = 0;
			strcat( tmp, "\33*" );
			h_len = (WORD)strlen(tmp);
			tmp[h_len] = modus;
			h_len += 3;
			len = (lz%3)*8;
		}
		else
		{
			/*  gleichen Anfang festlegen */
			tmp[0] = 13; /* CR */
			tmp[1] = 27;
			tmp[2] = '*';
			tmp[3] = modus;
			h_len = 6;
			links = lz;
			len = lz;
		}
		if(  len>0  )
			memset( tmp+h_len, 0, len );
		tmp[h_len-2] = (UBYTE)((8*(rechts-links)+len) % 256);
		tmp[h_len-1] = (UBYTE)((8*(rechts-links)+len) / 256);

		/* 24 Zeilen (3x Druckkopfh”he an den Drucker! */
		/* Oder auch weniger bei geringerer Aufl”sung */
		for(  lz=0;  lz<v_modus;  lz++, zeile++  )
		{
			i = (max_zeile-(zeile+(8*v_modus)))/v_modus;
			if(  i<=0  )
				break;
			i = 8-i;
			if(  i<0  )
				i = 0;
			block_out( tmp+h_len+len, p+links, (WORD)(rechts-links), weite*v_modus, (WORD)i );
			Fwrite( th, len+h_len+8*(rechts-links), tmp );
 			p += weite;
			zeile ++;
			Fputchar( th, 10, 0 );	/* Neue Zeile */
  	}
		p += weite*(7*v_modus);
		zeile += (7*v_modus);
		Fwrite( th, 3L, "\33f\1" );
		Fputchar( th, 24-v_modus, 0 );
 }

		/* Ende Seite */
  if(  1!=Fputchar( th, 12, 0 )  )
  {
  	/* Platz reichte nicht aus */
  	Fclose( th );
  	return -1;
  }
	return th;
}
/* 17.1.93 */

