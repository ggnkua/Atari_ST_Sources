/* Testroutine fÅr <prn8line.c>

   Copyright (C) 1990 by Thomas Weber - Software Entwicklung
   Dortmunder Straûe 5 - 6830 Schwetzingen - Tel. 06202 - 12242
   --------------------------------------------------------------- */

#include "prn8line.h"
#include "prn8line.c"

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <tos.h>

#define mem_len     32000L          /* LÑnge des Grafikpuffers (Bildschirm) */
#define file_name   "TEST.PIC"      /* Name der Testgrafik */
#define g_width     640             /* Breite der Grafik bei 72dpi */
#define g_offset    80              /* Zeilenoffset in Bytes */
#define g_height    400             /* Hîhe der Grafik */
#define p_optim     1               /* Druckerdaten optimieren */

int main(void)
{
    unsigned char   *bitmap,                    /* Adresse der zu druckenden Grafik */
                    buffer[g_width],            /* Druckerdatenpuffer */
                    prn_head[] = {27,42,5,0,0}, /* Drucker Grafikinitialisierung ([ESC] "*" 5) */
                    prn_init[] = {27,85,1},     /* Unidirektionaler Ausdruck EIN */
                    prn_exit[] = {27,85,0},     /* Unidirektionaler Ausdruck AUS */
                    nextline[] = {13,27,74,0};  /* WagenrÅcklauf und Zeilenvorschub ([CR][LF] n/216) */

             int    p,                          /* SchleifenzÑhler */
                    y_offset = 0,               /* Zeilenoffset */
                    l_rest = g_height,          /* zu druckende Zeilen */
                    l_aktuell,                  /* aktuelle Zeilenzahl */
                    len,                        /* Anzahl der Grafik-Druckdaten */
                    fehler = -1;                /* Fehlerflag */

             FILE   *id;            /* Zeiger auf File-Struktur */

    bitmap = Physbase();            /* Bildschirmspeicher = Grafikpuffer */

    putchar(27);putchar('f'); /* Cursor ausschalten */

    if(( id = fopen( file_name, "rb" )) != NULL ) /* Datei îffnen */
    {
        fread( bitmap, mem_len, 1L, id ); /* Grafikdaten einlesen */
        fclose( id ); /* Datei schlieûen */

        if(( id = fopen( "PRN:", "wb" )) != NULL ) /* Drucker îffnen */
        {
            /* Drucker auf Unidirektional schalten */
            for( p = 0; p < sizeof(prn_init); p++ ) putc( prn_init[p], id );

            /* Grafik drucken */
            do
            {
                if( l_rest > 8 ) l_aktuell = 8; /* Zeilenhîhe feststellen */
                else l_aktuell = l_rest;

                len = prn8line( bitmap, y_offset, l_aktuell,
                                g_width, g_offset, buffer, p_optim ); /* Druckerdaten erzeugen */

                prn_head[sizeof(prn_head) -  2] = len % 256; /* LOW-Byte */
                prn_head[sizeof(prn_head) -  1] = len >> 8; /* HIGH-Byte */

                for( p = 0; p < sizeof(prn_head); p++ ) putc( prn_head[p], id ); /* Header */
                for( p = 0; p < len; p++ ) putc( buffer[p], id ); /* Daten */

                nextline[sizeof(nextline) - 1] = l_aktuell * 3;
                for( p = 0; p < sizeof(nextline); p++ ) putc( nextline[p], id ); /* [CR][LF] */

                l_rest -= 8; y_offset += 8;
            } while( y_offset < g_height );

            /* Unidirektional abschalten */
            for( p = 0; p < sizeof(prn_exit); p++ ) putc( prn_exit[p], id );

            fclose( id );
            fehler = 0;
        }
        else fehler = -2; /* Druckerfehler */
    }
    putchar(27);putchar('e'); /* Cursor einschalten */
    return(fehler);
}
