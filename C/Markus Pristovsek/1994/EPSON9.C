#include <portab.h>
#include <stdlib.h>
#include <string.h>

#include "mintbind.h"
#include "treiber.h"

/***************************/
/* Version 1.0 von 10.2.93 */
/* Markus Pristovsek       */
/* Nur 240*216 dpi         */
/***************************/
/* Version 1.1 von 1.3.93  */
/* Alle Auflîsungen, d.h.  */
/* hor.: 240,120,90,80,72  */
/* ver.: 216,144,72 dpi    */
/***************************/
/* Version 1.2 von 23.8.93 */
/* Drehen per Assembler    */
/***************************/

#define BITS_PER_CHAR	20	/* Elite-Dichte! */
#define COMPRESSION 2	/* Von 2 bis 0 (so lassen) */
#define MAX_DPI	240L
#define WEITE 1920	 /* FÅr DINA3 vergrîûern! */

UBYTE	*drucker_ext="n9";

static UBYTE	dpi_modus[]={ 240, '3', 120, '1', 72, '5' };
static UBYTE	tmp[4096];
static UBYTE	*INIT="\33@\33M\33\63\1";
static UBYTE	*V_STEP="\033f\001x";


/* Funktioniert scheinbar nicht mit print_block-Routine */
#define WRITE(i,j,k) Fwrite(k,i,j)


void write_compressed( WORD th, UBYTE *tmp, LONG len, long bpc )
{
	LONG	i, j;

	if(  len<=0  )
	{
		WRITE( 2L, "\015\012", th );
		return;
	}
#if COMPRESSION==2
/* Schneidet nur links und rechts ab */
/* Diese Routine sollte mit nahezu jedem Drucker gehen! */
/* wenn man BITS_PER_CHAR (bpc) kennt! */

	for(  i=0;  i<len  &&  tmp[5+i]==0;  i++  )
		;
	while(  tmp[len+4]==0  &&  len>i  )
		len--;
	if(  i>=len  )
		WRITE( 2L, "\015\012", th );
	else
	{
		for(  j=0;  j<i/bpc;  j++  )
			WRITE( 1L, " ", th );
		j *= bpc;
		len -= j;
		tmp[3] = (UBYTE)(len % 256);
		tmp[4] = (UBYTE)(len / 256);
		WRITE( 5L, tmp, th );
		WRITE( len, tmp+5+j, th );
		WRITE( 2L, "\015\012", th );
	}
#elif COMPRESSION==1
/* Schneidet nur rechts ab */
	for(  i=len;  i>0  && tmp[i+5]==0;  i--  )
		;
	len--;
	if(  i==0  )
		WRITE( 2L, "\015\012", th );
	else
	{
		len = i;
		tmp[3] = (UBYTE)(len % 256);
		tmp[4] = (UBYTE)(len / 256);
		WRITE( 5L+len, tmp, th );
		WRITE( 2L, "\015\012", th );
	}
#else
/* Und unkomprimiert! */
	WRITE( 5L+len, tmp, th );
	WRITE( 2L, "\015\012", th );
#endif
}


WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	extern char	tmp_file[256]; /* In Datei drucken? */

	LONG	modus, v_modus;
	LONG	max_spalte, zeile, lz, links, linker_rand, rechts;
	LONG	h_len, len, i;

	if(  start_x>0  )
		return -1;

		/* Auflîsung feststellen */
	for(  i=4;  i>0  &&  h_dpi>dpi_modus[i];  i-=2  )
		;
	modus = dpi_modus[i+1];
	h_dpi = dpi_modus[i];
	if(  v_dpi>175  )
		v_modus = 3;	/* Hochauflîsend */
	else if(  v_dpi>110  )
		v_modus = 2;	/* naja... */
	else
		v_modus = 1;	/* und Klîtzchengraphic */

		/* Ab hier wird es ernst */
	if(  weite<WEITE*h_dpi/MAX_DPI  )
		max_spalte = (weite+7)/8;
	else
		max_spalte = (WEITE*h_dpi)/(8*MAX_DPI);

	weite = (weite+15L)/16L;
	weite *= 2;
	if(  flag&1  )
		WRITE( 7L, INIT, th ); /* Reset + Elite-Dichte + Zeilenabstand 1/216 */

	/* Linken Rand festlegen */
	for(  lz=0;  ist_next_leer( p+lz, weite, max_zeile )  &&   lz<max_spalte;  lz++  )
		;
	linker_rand = lz;

	lz = links = 0;
	zeile = start_y;
	max_zeile += start_y;

	/* Endlich drucken */
	while(  flag&2  )
 	{
 		/* Leerzeilen Åberspringen */
 		for(  lz=0;  ist_leerzeile( p, max_spalte )  &&  zeile<max_zeile;  lz++, zeile++  )
 			p += weite;

		lz = links+(lz+lz+lz)/v_modus;
		while(  lz>0  )
		{
			if(  lz>255  )
				V_STEP[3] = 255;
			else
				V_STEP[3] = lz;
			WRITE( 4L, V_STEP, th );
			lz -= 255;
		}
		if(  zeile>=max_zeile  )
			break;

			/* RÑnder feststellen */
 		for(  rechts=max_spalte-1;  ist_next_leer( p+rechts, weite, v_modus*8 )  &&  rechts>linker_rand;  rechts--  )
 			;
 		rechts++;
		/* Leerzeichen am linken Rand */
		for(  links=linker_rand;  ist_next_leer( p+links, weite, v_modus*8 )  &&   links<rechts;  links++  )
			;
		/*  gleichen Anfang festlegen */
		tmp[0] = 27;
		tmp[1] = '*';
		tmp[2] = modus;
		h_len = links*8;
		len = 8*rechts;
		if(  h_len>0  )
			memset( tmp+5, 0, h_len );
		tmp[3] = (UBYTE)(len % 256);
		tmp[4] = (UBYTE)(len / 256);

		/* 24 Zeilen (3x Druckkopfhîhe an den Drucker! */
		/* Oder auch weniger bei geringerer Auflîsung */
		for(  lz=0;  lz<v_modus;  lz++  )
		{
			block_it( tmp+5+h_len, p+links, (WORD)(rechts-links), weite*v_modus, 1 );
			p += weite;
			/* Letzte Zeile gesondert behandeln */
			if(  zeile+v_modus*8+lz>=max_zeile  )
			{
				int	bit, byte, and_it;

				bit = (int)((zeile+v_modus*8+lz - max_zeile)/v_modus);
				and_it = (0x00FF<<(bit&7));
				for(  byte=0;  byte<len-h_len;  byte++  )
					tmp[5L+h_len+byte] &= and_it;
			}
			write_compressed( th, tmp, len, (h_dpi*BITS_PER_CHAR)/MAX_DPI );
  	}
		p += weite*v_modus*7L;
		links = 24-v_modus;
		if(  zeile+(8*v_modus)>=max_zeile  )
			links = max_zeile-zeile-v_modus;
		zeile += (8*v_modus);
 }

		/* Ende Seite */
  if(  (flag&4)  )
  {
  	if(  2!=WRITE( 1L, " \014", th )  )
	  	/* Platz reichte nicht aus */
			return -1;
  }
	return 0;
}
/* 17.1.93 */

