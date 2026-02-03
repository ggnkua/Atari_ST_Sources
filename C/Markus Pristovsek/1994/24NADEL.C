/************************************************************************* ****	Kern des universellen 24-Nadeltreibers			      **** ****	Sollte von Headerdatei aufgerufen werden		      **** *************************************************************************/#include <portab.h>#include <stdlib.h>#include <string.h>#include "mintbind.h"#include "treiber.h"#ifndef STEP_360#error "Bitte diese Datei nur per #include lesen!"#endifUBYTE 	*INIT 	    = "\033@\033x\001";UBYTE 	*GRAFIK_180 = "\033*\047";UBYTE 	*GRAFIK_360 = "\033*\050";UBYTE 	*STEP_180   = "\033\063\001\012";

UBYTE		*drucker_ext= EXTENTION;

/* Kînnte ruhig geÑndert werden! */
#undef FAST_PRN

#ifdef __TURBOC__
#pragma warn -sig	/* Konversion may loose signifikant Digit aus! */
#endif
VOID block_out( UBYTE *dest, UBYTE *src, WORD ende, LONG offset, WORD hoehe  ){  WORD j, k, i, l, m;	if(  hoehe!=24  )
	{	/* Nur wenn es wirklich nîtig ist die langsame Bitpfriemelei */    while(  ende-->0  )
    { /* Byte-Pfriemeln */      for(  j=8;  j-->0;  )
      {				for(  m=3, l=i=0;  m-- || l<hoehe;  )
				{				  for(  *dest=0, k=8; l<hoehe  &&  k-->0;  l++, i+=offset  )				    *dest |= ((src[i] >> j) & 1) << k;				  dest++;				}      }      src++;    }  }
  else
#ifndef FAST_PRN  {	/* 24 Zeilen Åbertragen */
    while(  ende-->0  )
    {	/* Byte-Pfriemeln */      for(  j=8;  j-->0;  )
      {				*dest   =  ((src[0]           >> j) & 1) << 7;				*dest   |= ((src[k = offset]  >> j) & 1) << 6;				*dest   |= ((src[k += offset] >> j) & 1) << 5;				*dest   |= ((src[k += offset] >> j) & 1) << 4;				*dest   |= ((src[k += offset] >> j) & 1) << 3;				*dest   |= ((src[k += offset] >> j) & 1) << 2;				*dest   |= ((src[k += offset] >> j) & 1) << 1;				*dest++ |= (src[k += offset]  >> j) & 1;				*dest   =  ((src[k += offset] >> j) & 1) << 7;				*dest   |= ((src[k += offset] >> j) & 1) << 6;				*dest   |= ((src[k += offset] >> j) & 1) << 5;				*dest   |= ((src[k += offset] >> j) & 1) << 4;				*dest   |= ((src[k += offset] >> j) & 1) << 3;				*dest   |= ((src[k += offset] >> j) & 1) << 2;				*dest   |= ((src[k += offset] >> j) & 1) << 1;				*dest++ |= (src[k += offset]  >> j) & 1;				*dest   =  ((src[k += offset] >> j) & 1) << 7;				*dest   |= ((src[k += offset] >> j) & 1) << 6;				*dest   |= ((src[k += offset] >> j) & 1) << 5;				*dest   |= ((src[k += offset] >> j) & 1) << 4;				*dest   |= ((src[k += offset] >> j) & 1) << 3;				*dest   |= ((src[k += offset] >> j) & 1) << 2;				*dest   |= ((src[k += offset] >> j) & 1) << 1;				*dest++ |= (src[k += offset]  >> j) & 1;      }      src++;    }  }
#else
	block_it( dest, src, ende, offset, 3 );
#endif}/* 20.1.93 */
#ifdef __TURBOC__
#pragma warn .sig	/* Konversion may loose signifikant Digit reset! */
#endif

/* Zur Zeit wird fast nicht optimiert; Zum einen sollte jetzt fast jeder * Drucker arbeiten; Zum anderen habe ich keinen 24-Nadeldrucker zum Testen * Bastler sind hier zur Arbeit aufgefordert! */static UBYTE	tmp[16384];
WORD drucke( UBYTE *p, LONG start_x, LONG start_y, LONG weite, LONG max_zeile, LONG h_dpi, LONG v_dpi, WORD th, WORD flag ){  LONG	max_spalte, zeile, lz, links, linker_rand, rechts;  LONG	h_len, len, i;  UBYTE *grafik, *pcv = ((UBYTE *)&i)+2; /* Geht so NUR auf Atari! */  WORD	v_modus;  grafik = GRAFIK_360;  if(  h_dpi<200  )
  {    grafik = GRAFIK_180;    h_dpi = 180;  }
  else    h_dpi = 360;    if(  v_dpi<200  )
    v_dpi = 180;
  else	  v_dpi = 360;  	if(  weite<WEITE*h_dpi/360L  ) /* FÅr DINA3 vergrîûern! */  	max_spalte = (weite+7) / 8;  else	  max_spalte = WEITE*h_dpi / (360L*8L);
  /* Diverse Variablen initialisieren */  zeile = 0;  weite = (weite+15L) / 16L*2L;
	if(  flag&1  )	/* Obere RÑnder setzen */
	{
	  Fwrite(th, strlen(INIT), INIT); /* Reset + LQ-Mode */
		p += weite*OBEN + LINKS;	/* Nicht druckbare RÑnder*/	  if(  (max_zeile-=OBEN)<0  )	    max_zeile = 0;
	}  if(  HOEHE>0  &&  max_zeile+start_y>HOEHE  )    max_zeile = HOEHE-start_x;  lz = 0;  v_modus = v_dpi / 180;  linker_rand = 0;  links = 0;	/* Wird mit Miûachtung gestraft! */    /* Endlich drucken */  while(  flag&2  )
  { 
  	/* Leerzeilen Åberspringen */    while( ist_leerzeile(p, max_spalte) && zeile<max_zeile  )
    {
      p += weite;
    	lz++;
    	zeile++;
    }		/* 360"-Step extra behandeln */
    if (v_dpi == 360)
    {      if(  lz&1  )				Fwrite( th, strlen(STEP_360), STEP_360 );      lz >>= 1;    }    while (lz > 0)
    {      Fwrite( th, 2L, "\033J");
      if(lz > 255)				Fwrite(th, 1L, "\377");      else				Fwrite(th, 1L, ((char *)(&lz) + 3));	/* Long = 4 Bytes! */      lz -= 255;    }
			/* Rechtzeitig Schluû! */
    if(  zeile>=max_zeile  )      break;    /* RÑnder feststellen */    for(  rechts=max_spalte-1;  ist_next_leer( p+rechts, weite, v_modus*24 )  &&  rechts>linker_rand;  rechts--  )
    	;    rechts++;
    len = rechts-links;    h_len = 5;    strcpy (tmp, grafik);    i = 8*(rechts-links);    tmp[3] = pcv[1];	/* i nach Intel konvertieren */    tmp[4] = pcv[0];    /* Oder auch weniger bei geringerer Auflîsung */    for(  lz=0;  zeile<max_zeile  &&  lz<v_modus;  zeile++  )
    {      if(  (i=(max_zeile-zeile))>24*v_modus  )				i = 24*v_modus;      i = (i+v_modus-1) / v_modus;
#ifdef FAST_PRN      if(  len>0  &&  i==24  )				memset( tmp+h_len, 0, 24*len  );
#endif      block_out(  tmp+h_len, p+links, (WORD)len, weite*v_modus, (WORD)i  );      Fwrite(th, h_len + 24*len, tmp );      Fwrite(th, 1L, "\015");	/* CR */      p += weite;            if(  v_dpi==360  )
				Fwrite( th, strlen(STEP_360), STEP_360  );    }    lz = 24*v_modus-1;	/* eine Zeile weniger Åberspringen, da */    p += weite*lz;      /* bereits im Loop eine uebersprungen wird. */    if(  zeile-lz>=max_zeile  )	/* Evt. auf Abschnittende auchten! */
    	lz = max_zeile-zeile;    zeile += lz;  }

  /* Ende Seite */  if(  flag&4  &&  Fwrite( th, 1L, "\014" )!=1  )
		/* Platz reichte nicht aus */    return -1;	    return th;}/* 17.1.93 *//* Viele kleine Fehler gefunden und gefixt. 6.5.93 Marcus Haebler *//* Nachbearbeitet von Markus Kilbinger */
/* Angepaût an scheibenweisen Druck, 5.9.94, Markus Pristovsek */
