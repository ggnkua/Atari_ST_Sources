/*************************************************************************
**** Querdruck fÅr EPSON ESC/P 9-Nadeldrucker                         ****
*************************************************************************/

#include <string.h>
#include <stdio.h>

#include <portab.h>
#include <mintbind.h>

#include "treiber.h"

/** VorlÑufige Parameter */
#define MAX_DPI	240L
#define	HOEHE	1920L
#define WEITE -1L
#define BITS_PER_CHAR	20	/* Elite-Dichte! */
#define COMPRESSION 2	/* Von 2 bis 0 (so lassen) */

#ifdef FAST_PRN
#define WRITE(i,j) ((th>0)?(Fwrite(th,i,j)):(print_block(i,j)))
#endif


/* Reset + NLQ + Einheit 1/MAX_DPI" + Zeilenabstand 1/216" */
UBYTE	*INIT = "\033@\033M\033\063\001\015";
UBYTE	*V_STEP	=	"\033f\001x";
UBYTE	*H_STEP = "\033lx";




void write_compressed( WORD th, UBYTE *tmp, LONG len, long bpc )
{
#if COMPRESSION==2
/* Schneidet nur links und rechts ab */
/* Diese Routine sollte mit nahezu jedem Drucker gehen! */
/* wenn man BITS_PER_CHAR (bpc) kennt! */
	LONG	i, j;

	for(  i=0;  i<len  &&  tmp[5+i]==0;  i++  )
		;
	while(  tmp[len+4]==0  &&  len>i  )
		len--;
	if(  i==len  )
		WRITE( 2L, "\015\012" );
	else
	{
		for(  j=0;  j<i/bpc;  j++  )
			WRITE( 1L, " " );
		j *= bpc;
		len -= j;
		tmp[3] = (UBYTE)(len % 256);
		tmp[4] = (UBYTE)(len / 256);
		WRITE( 5L, tmp );
		WRITE( len, tmp+5+j );
		WRITE( 2L, "\015\012" );
	}
#elif COMPRESSION==1
	LONG	i;

/* Schneidet nur rechts ab */
	for(  i=len;  i>0  && tmp[i+5]==0;  i--  )
		;
	len--;
	if(  i==0  )
		WRITE( 2L, "\015\012" );
	else
	{
		len = i;
		tmp[3] = (UBYTE)(len % 256);
		tmp[4] = (UBYTE)(len / 256);
		WRITE( 5L+len, tmp );
		WRITE( 2L, "\015\012" );
	}
#else
	WRITE( 7L+len, tmp );
#endif
}
/* 23.8.93 */


/* Zwischenspeicher fÅr eine Zeile */
static UBYTE	tmp1[HOEHE+6L];
static UBYTE	tmp2[HOEHE+6L];
static UBYTE	tmp3[HOEHE+6L];

static LONG	bit_table[]=
{
	0x00800000L,0x00400000L,0x00200000L,0x00100000L,
	0x00080000L,0x00040000L,0x00020000L,0x00010000L,
	0x00008000L,0x00004000L,0x00002000L,0x00001000L,
	0x00000800L,0x00000400L,0x00000200L,0x00000100L,
	0x00000080L,0x00000040L,0x00000020L,0x00000010L,
	0x00000008L,0x00000004L,0x00000002L,0x00000001L
};



WORD	drucke( UBYTE *p, LONG weite, LONG hoehe, LONG h_dpi, LONG v_dpi )
{
	extern char	tmp_file[256]; /* In Datei drucken? */

	LONG	max_spalte, max_zeile, zeile, lz;
	LONG	len, bytes_per_row, offset, i, j, k;
	WORD	th=0;
	UBYTE	t;

#ifdef FAST_PRN
	/* FÅr viel Geschwindigkeit */
	if(  tmp_file[0]>0  ||  open_printer()<0  )
#endif
		th = (WORD)get_tempfile( "n9q" );
	if(  th<0  )
		return -1;

	t = '3';
	j = 240;
	if(  v_dpi<150  )
	{
		t = '1';
		j = 120;
	}

	v_dpi = 216;
	bytes_per_row = 3;
	if(  h_dpi<80  )
	{
		v_dpi = 72;
		bytes_per_row = 1;
	}
	else
		if(  h_dpi<160  )
		{
			v_dpi = 144;
			bytes_per_row = 2;
		}
	h_dpi = j;

		/* Ab hier wird es ernst */
	if(  hoehe>(HOEHE*h_dpi)/MAX_DPI  )
		max_spalte = (HOEHE*h_dpi)/MAX_DPI;

		/* Diverse Variablen initialisieren */
	zeile = 0;
	if(  WEITE>0	&&	(weite*v_dpi)/MAX_DPI>WEITE  )
		max_zeile = (WEITE+7)*v_dpi/(8*MAX_DPI);
	else
		max_zeile = (weite+7L)/8L;
	weite = (weite+15L)/16L;
	weite *= 2;

		/* Reset + LQ-Mode */
	WRITE( 8L, INIT );

	/* Endlich drucken */
	max_zeile--;
	while(	zeile<max_zeile )
	{
		for(  lz=0;  ist_next_leer( p+lz, weite, hoehe )  &&  lz<max_zeile;  lz++  )
			;
		if(	 lz>0	)
		{	/* Leerzeilen Åberspringen */
			zeile += lz;
			p += lz;
			lz = lz*8*3/bytes_per_row;
	 		while(  lz>0  )
			{
				if(  lz>255  )
					V_STEP[3] = 255;
				else
					V_STEP[3] = lz;
				WRITE( 4L, V_STEP );
				lz -= 255;
			}
		}
		if(  zeile>=max_zeile  )
			break;

		len = max_spalte;
		if(  max_spalte<(HOEHE*h_dpi)/MAX_DPI  )
			offset = (HOEHE*h_dpi)/MAX_DPI-max_spalte;
		else
			offset = 0;
		tmp1[0] = '\033';
		tmp1[1] = '*';
		tmp1[2] = t;

		switch(  (int)bytes_per_row  )
		{
			case 1:	for(  lz=0;  lz<len;  lz++  )
								tmp1[4L+offset+len-lz] = p[lz*weite];
							memset( tmp1+5, 0, offset );
							tmp1[3] = (UBYTE)((len+offset) % 256);
							tmp1[4] = (UBYTE)((len+offset) / 256);
							write_compressed( th, tmp1, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							p += 1;
						break;
			case 2:	memset(  tmp1+5, 0, offset+len );
							memcpy(  tmp2, tmp1, 5+offset+len );
							for(  lz=0;  lz<len;  lz++  )
							{
								i = 256L*p[lz*weite]+p[lz*weite+1];
								if(  i==0L  )
									continue;
								for(  j=8,k=0;  k<8;  k++  )
								{
									if(  (i&bit_table[j++])!=0L  )
										tmp1[4L+offset+len-lz] |= bit_table[16+k];
									if(  (i&bit_table[j++])!=0L  )
										tmp2[4L+offset+len-lz] |= bit_table[16+k];
								}
							}
							/* Komprimiert schreiben */
							write_compressed( th, tmp1, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							write_compressed( th, tmp2, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							p += 2;
						break;
			case 3:	memset(  tmp1+5, 0, offset+len );
							memcpy(  tmp2, tmp1, 5+offset+len );
							memcpy(  tmp3, tmp1, 5+offset+len );
							for(  lz=0;  lz<len;  lz++  )
							{
								i = p[lz*weite]*65536L+p[lz*weite+1]*256L+p[lz*weite+2];
								if(  i==0  )
									continue;
								for(  j=k=0;  k<8;  k++  )
								{
									if(  (i&bit_table[j++])!=0  )
										tmp1[4L+offset+len-lz] |= bit_table[16+k];
									if(  (i&bit_table[j++])!=0  )
										tmp2[4L+offset+len-lz] |= bit_table[16+k];
									if(  (i&bit_table[j++])!=0  )
										tmp3[4L+offset+len-lz] |= bit_table[16+k];
								}
							}
							write_compressed( th, tmp1, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							write_compressed( th, tmp2, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							write_compressed( th, tmp3, len+offset, (BITS_PER_CHAR*h_dpi)/MAX_DPI );
							p += 3;
						break;
		}
		V_STEP[3] = 24-bytes_per_row;
		WRITE( 4L, V_STEP );
		zeile += bytes_per_row;
	}

		/* Ende Seite */
	if(  2!=WRITE( 1L, " \014" )  )
	{
		/* Platz reichte nicht aus */
		if(  th>0  )
			Fclose( th );
		th = -1;
	}

	if(  tmp_file[0]==0  )
		flush_block();
	return th;
}
/* 17.1.93 */
