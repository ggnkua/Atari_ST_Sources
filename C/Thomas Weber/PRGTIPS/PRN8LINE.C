/* ===============================================================
   < prn8line.c >                              Version: 13.06.1990
   Umwandlung einer monochromen Bitmap-Grafikzeile ( 1 bis 8 Pixel
   hoch ) in Druckerdaten fr 8-Nadel-Drucker mit L„ngen-Optimierung
   ---------------------------------------------------------------
   Copyright (C) 1990 by Thomas Weber - Software Entwicklung
   Dortmunder Straže 5 - 6830 Schwetzingen - Tel. 06202 - 12242
   ---------------------------------------------------------------
   -> Parameter:
   char *bitmap     - Basis-Adresse der monochromen Bitmap-Grafik
   int  y_off       - Startzeile in der Grafik ( bei 0 anfangen zu z„hlen ! )
   int  lines       - Anzahl der zu wandelnden Zeilen (min. 1 / max. 8)
   int  width       - Breite der Grafik in Pixels
   int  z_off       - Zeilenoffset der Grafik in Bytes
   char *buffer     - Adresse des Drucker-Puffers ( auf ausreichende L„nge achten )
   int  optimize    - 0 = Druckzeilenl„nge nicht optimieren
   <- Parameter:
   int  b_len       - aktuelle Anzahl der Druckerdatenbytes (bei 0 nicht drucken
   =============================================================== */

int prn8line( unsigned char *bitmap, int y_off, int lines, int width, int z_off, unsigned char *buffer, int optimize )
{
    int             n = 0,  /* Z„hler fr Drucker-buffer */
                    x = 0,  /* Z„hler fr optimierte L„nge */
                    full,   /* Anzahl der 8 Bit breiten Blocks */
                    last,   /* Breite des letzten Blocks ( 0 = kein Block ) */
                    i, k;   /* Diverse Schleifenz„hler */

    unsigned char   *basis[8];  /* Adress-Array fr Zeile 0..7 */

    const unsigned char mask[8] = {128,64,32,16,8,4,2,1}; /* Bit-Maskierung */

    full = width >> 3;      /* Anzahl der 8 Bit breiten Blocks */
    last = width % 8;       /* ggf. Breite Bit-Rest im letzten Block */

    basis[0] = bitmap + y_off * z_off; /* Zeilen-Basis-Adressen */
    for( i = 0, k = 1; k < lines; i++, k++ ) basis[k] = basis[i] + z_off;

    while ( full > 0 ) /* 'full' 8 Bit breite Blocks je Grafikzeile */
    {
        for( i = 0; i < 8; i++) /* 8 Druckspalten je Block */
        {
            buffer[n] = 0; /* Puffer l”schen */

            for( k = 0; k < lines; k++ ) /* 'lines' Zeilenbits je Druckspalte */
                if( *(basis[k]) & mask[i] ) buffer[n] += mask[k]; /* Bits testen bzw. setzen */

            if( buffer[n++] != 0 ) x = n; /* zum Optimieren mitz„hlen */
        }

        for( i = 0; i < 8; i++ ) basis[i]++; /* Zeiger auf n„chsten Block */

        full--; /* n„chsten 8 Bit breiten Block */
    }

    if( last > 0 ) /* ggf. einen letzten Block wandeln ( schmaler als 8 Bit ) */
    {
        for( i = 0; i < last; i++ ) /* 'last' Druckspalten je Block (1...8) */
        {
            for( k = 0; k < lines; k++ ) /* 'lines' Zeilenbits je Druckspalte */
                if( *(basis[k]) & mask[i] ) buffer[n] += mask[k]; /* Bits testen bzw. setzen */

            if( buffer[n++] != 0 ) x = n; /* zum Optimieren mitz„hlen */
        }
    }

    if( optimize ) /* Datenl„nge optimieren */
        return(x);
    else
        return(width);
} /* END of <prn8line.c> */
/* =============================================================== */
