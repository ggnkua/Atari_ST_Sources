/*************************************************************************
****  Hier der speziell an den Stylus 800-Drucker von Epson angepažte ****
****  24-Nadeltreiber. (Wie sch”n w„re es, wenn alle neuen Drucker    ****
****  HPCL k”nnten...)                                                ****
*************************************************************************/

#include <portab.h>

#include "mintbind.h"
#include "treiber.h"

/** Vorl„ufige Parameter */
#define MAX_DPI	360L
#define	WEITE	2880L
#define HOEHE	-1L
#define OBEN	0L
#define LINKS	0L



/* Reset + NLQ + Einheit 1/MAX_DPI" + Zeilenabstand 48/MAX_DPI" */
UBYTE	*INIT1	= " \033@\033x\001\033(U\001\000\012\033$\000\000\033(V\002\000\000\000";
UBYTE	*H_STEP	= "\033$xx";
UBYTE	*V_STEP	= "\033(v\002\000xx";
UBYTE	*GRAFIK	= "\033*";

UBYTE	*drucker_ext="stq";


/* Zwischenspeicher fr eine Zeile */
static UBYTE	tmp[WEITE*6L+5L];


WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	UBYTE	*ziel, *quelle;
	LONG	max_spalte, zeile, lz, links, linker_rand, rechts;
	LONG	len, i;

	if(  start_y>0  )
		return -1;

	(void)h_dpi;	/* Geht nur mit 600*600dpi! */
	(void)v_dpi;

		/* Ab hier wird es ernst */
	if(  max_zeile<WEITE  )
		max_spalte = max_zeile;
	else
		max_spalte = WEITE;
	
		/* Diverse Variablen initialisieren */
	max_zeile = weite+start_x;
	if(  HOEHE>-1  &&  max_zeile>HOEHE  )
		max_zeile = HOEHE-start_x;
	max_zeile -= start_x-1;
	if(  max_zeile<=0  )
		return 0;	/* Zu breit! */
	zeile = 0;

	weite = (weite+15L)/16L;
	weite *= 2;

	if(  flag&1  )
	{
		p += weite*OBEN;	/* Nicht druckbarer oberer Rand */
		zeile = OBEN;
		p += LINKS;	/* Nicht druckbarer linker Rand */
	}

	lz = 0;
	for(  linker_rand=0;	ist_next_leer( p+linker_rand, weite, max_zeile )  &&  linker_rand<max_spalte;  linker_rand++  )
		;
	if(  linker_rand==max_spalte  )
	{	/* Leerseite */
		lz = max_zeile-zeile;
		zeile = max_zeile;
	}

		/* Reset + LQ-Mode */
	if(  flag&1  )
		print_block( 23L, INIT1, th );

	/* Endlich drucken */
	while(	flag&2  )
	{
		/* Leerzeilen berspringen */
		while(  zeile+lz*8<max_zeile  &&  ist_next_leer( p+lz, weite, max_spalte )  )
			lz++;
		zeile += lz*8;
		if(  zeile>=max_zeile  )
			lz = max_zeile-(zeile-lz*8);
		else
			lz *= 8;
		if(  lz>0  )
		{
			V_STEP[5] = (UBYTE)lz;
			V_STEP[6] = (UBYTE)(lz>>8);
			print_block( 7L, V_STEP, th );
		}

		if(  zeile>=max_zeile  )
			break;

			/* R„nder feststellen */
		for(	links=0;  links<max_spalte-1  &&  ist_leerzeile( p+links*weite, 6 );  links++  )
			;
		for(	rechts=max_spalte-1;	rechts>links  &&  ist_leerzeile( p+rechts*weite, 6 );  rechts--  )
			;
		if(	links>0	)
		{	/* Linker Rand */
			H_STEP[2] = (UBYTE)links;
			H_STEP[3] = (UBYTE)(links>>8);
			print_block( 4L, H_STEP, th );
		}

		len = (rechts-links)*6;
		tmp[0] = '\033';
		tmp[1] = '*';
		tmp[2] = (UBYTE)73;
		tmp[3] = (UBYTE)len;
		tmp[4] = (UBYTE)(len>>8);

		len /= 6;
		ziel = tmp+5;
		for(  i=0;  i<len;  i++  )
		{
			quelle = p+(links*i)*weite;
			*ziel++ = *quelle++;
			*ziel++ = *quelle++;
			*ziel++ = *quelle++;
			*ziel++ = *quelle++;
			*ziel++ = *quelle++;
			*ziel++ = *quelle++;
		}

		/* Letze Zeile ist nicht eine Druckkopfh”he, ein Teil muss abgeschnitten werden! */
		if(  zeile+48>max_zeile  )
		{
			WORD	bit, byte, and_it;

			bit = (WORD)(zeile+48 - max_zeile);
			byte = bit/8;
			and_it = (0x00FF<<(bit&7));
			for(  lz=0;  lz<len*6;  lz++  )
			{
				if(  lz%6==byte  )
					tmp[5L+lz] &= and_it;
				else
					if(  lz%6>byte  )
						tmp[5L+lz] = 0;
			}
		}
		lz = 6;	/* lz Bytes weiter */
		print_block( 5L+len*6, tmp, th );
		p += lz;
 }

	if(  flag&4  )
	{	/* Seite beenden */
		if(  2!=print_block( 1L, "\014\007", th )  )
			/* Platz reichte nicht aus */
			return -1;
	}
	/* Sollte immer gut gehen! (d.h. kein File zu drucken!) */
	return 0;
}
/* 17.8.93 */

