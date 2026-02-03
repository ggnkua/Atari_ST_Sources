/*************************************************************************
****  Hier der speziell an den StarJet-Drucker von Star angepažte     ****
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


/** Vorlaeufige Parameter */
#define MAX_DPI 360L
#define WEITE   2880L
#define HOEHE   -1L
#define OBEN    0L
#define LINKS   0L

/* Reset + NLQ + Einheit 1/MAX_DPI" */
UBYTE   *INIT   =   "\033@\033x\001\033+\001";
UBYTE   *H_STEP =   "\033\\xx";
UBYTE   *V_STEP =   "\033Jx\012";


struct
{
    UBYTE   modus;
    WORD    h_dpi;
    WORD    v_dpi;
    WORD    t;
} modus[4]=
{
    { 39, 180, 180, 3 },
    { 40, 360, 180, 3 },
    { 71, 180, 360, 6 },
    { 72, 360, 360, 6 }
};

/* Zwischenspeicher fuer eine Zeile */
static UBYTE    tmp[WEITE*6L+5L];
UBYTE						*drucker_ext="sls";


WORD	drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag )
{
	extern char	tmp_file[256]; /* In Datei drucken? */
	extern long	max_puffer_laenge;

	LONG	max_spalte, zeile, lz, links, linker_rand, rechts;
	LONG	len, i, d_modus, bits_per_row, bytes_per_row;

	if(  start_x>0  )
		return -1;

	if(  v_dpi<200	)
	{
		if(  v_dpi<80  )
			v_dpi = 60;
		else
			v_dpi = 180;
	}
	else
		v_dpi = MAX_DPI;

	for(  d_modus=0;  d_modus<3;  d_modus++  )
		if(  (h_dpi*90)/100<modus[d_modus].h_dpi  &&  v_dpi==modus[d_modus].v_dpi  )
			break;
	h_dpi = modus[d_modus].h_dpi;
	bytes_per_row = modus[d_modus].t;
	bits_per_row = 8*modus[d_modus].t;
	d_modus = modus[d_modus].modus;

		/* Ab hier wird es ernst */
	if(  weite<(WEITE*h_dpi)/MAX_DPI  )
		max_spalte = (weite+7)/8-LINKS;
	else
		max_spalte = (WEITE*h_dpi)/(MAX_DPI*8L)-LINKS;
	
		/* Diverse Variablen initialisieren */
	zeile = start_y;
	weite = (weite+15L)/16L;
	weite *= 2;
	if(  flag&1  )
	{
		p += weite*OBEN;	/* Nicht druckbarer oberer Rand */
		max_zeile -= OBEN;
	}
	max_zeile += start_y;
	if(  HOEHE>0	&&	(max_zeile*v_dpi)/MAX_DPI>HOEHE  )
		max_zeile = HOEHE;
	max_zeile -= start_y;
	p += LINKS;	/* Nicht druckbarer linker Rand */
	lz = 0;
	max_zeile--;

	for(  linker_rand=0;	ist_next_leer( p+linker_rand, weite, max_zeile )  &&  linker_rand<max_spalte;  linker_rand++  )
		;
	if(  linker_rand==max_spalte  )
	{	/* Leerseite */
		lz = max_zeile-zeile;
		zeile = max_zeile;
	}

		/* Reset + LQ-Mode */
	if(  flag&1  )
		print_block( 23L, INIT, th );

	/* Endlich drucken */
	while(	zeile<max_zeile  &&  flag&2  )
	{
		/* Leerzeilen berspringen */
		while(  zeile<max_zeile  &&  ist_leerzeile( p, max_spalte )  )
		{
			lz++;
			zeile++;
			p += weite;
		}

    /* Leerzeilen ueberspringen */
    if(  v_dpi==360  )
    {
			if(  lz&1  )
				print_block( 1L, "\012", th );
			lz >>= 1;
    }
		i = (lz*MAX_DPI)/v_dpi;
		while(	 i>255  )
		{	/* Leerzeilen berspringen */
      if(  lz>255  )
          V_STEP[2] = 255;
      else
          V_STEP[2] = (UBYTE)lz;
			print_block( 4L, V_STEP, th );
      i -= 255;
		}

		if(  zeile>=max_zeile  )
			break;

			/* R„nder feststellen */
		for(	rechts=max_spalte-1;	rechts>linker_rand;  rechts--  )
			if(  !ist_next_leer( p+rechts, weite, bits_per_row )  )
				break;
		for(  links=linker_rand;	ist_next_leer( p+links, weite, bits_per_row )	&&	links<rechts;  links++  )
			;
		if(	links>0	)
		{	/* Linker Rand */
			i = (links*8L*MAX_DPI)/h_dpi;
			H_STEP[2] = (UBYTE)i;
			H_STEP[3] = (UBYTE)(i>>8);
			print_block( 4L, H_STEP, th );
		}

		len = rechts-links;
		tmp[0] = '\033';
		tmp[1] = '*';
		tmp[2] = (UBYTE)d_modus;
		tmp[3] = (UBYTE)((len%32)*8);
		tmp[4] = (UBYTE)(len>>5);

		block_it( tmp+5, p+links, len, weite, bytes_per_row );
		/* Letze Zeile ist nicht eine Druckkopfh”he, ein Teil muss abgeschnitten werden! */
		if(  zeile+bits_per_row>max_zeile  )
		{
			WORD	bit, byte, and_it;

			bit = (WORD)(zeile+bits_per_row - max_zeile);
			byte = bit/8;
			and_it = (0x00FF<<(bit&7));
			for(  lz=0;  lz<len*bits_per_row;  lz++  )
			{
				if(  lz%bytes_per_row==byte  )
					tmp[5L+lz] &= and_it;
				else
					if(  lz%bytes_per_row>byte  )
						tmp[5L+lz] = 0;
			}
			print_block( 5L+len*bits_per_row, tmp, th );
			lz = bit;
			break;
		}
		lz = bits_per_row;
		print_block( 5L+len*bits_per_row, tmp, th );
		p += weite*bits_per_row;
		zeile += lz;
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

