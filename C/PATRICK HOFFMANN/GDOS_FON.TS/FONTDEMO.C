/*======================================================================*/
/* Die FONT-GDOS-PROTHESE                           (GDOS = "Geh' DOS") */
/*======================================================================*/
/* Programmiert:    Ja!                                                 */
/* Von:             PATRICK HOFFMANN                                    */
/* FÅr:             ...mich selbst.                                     */
/* In:              Berlin... Ñhh, TURBO-C 2.xx                         */
/* Am:              20.3. - 21.3.91                                     */
/* Um:              ..sonst!?                                           */
/* Kopireit:        ...beim Programmierer.                              */
/* Codezeilen:      ca. 130 ohne, und 334 mit Kommentaren               */
/*======================================================================*/
/* Autor ist erreichbar unter:                                          */
/*      Tel.: (030) 452 59 89 oder NetzmÑûig unter: PATHO@JPBERLIN.ZER  */
/*======================================================================*/

/*==== Sub-Sub-Routines ================================================*/

#include <linea.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <ext.h>

/*==== Prototypen (Sub-Routines) =======================================*/

FONT_HDR    *FNT_load( char *file );
void        FNT_unload( FONT_HDR *font );
void        FNT_text( int x, int y, char *text, FONT_HDR *font, 
                      int winkel, int stil, int wrmode );
int         FNT_len( char *text, FONT_HDR *font );

/*==== Prototypen (Sub-Sub-Routines) ===================================*/

char        *ext( char *file, char *ext );
char        *strbchr( char *text, char find );
FONT_HDR    *intel_to_68000( FONT_HDR *hdr );
void        wswitch( int *w );
void        lswitch( long *l );

/*==== Demoprogramm ====================================================*/

void main()                     /* GDOS-PROTHESE-Demo                   */
{
    FONT_HDR *font1,                        /* Zeiger auf Fontheader    */
             *font2,                        /* Zeiger auf Fontheader    */
             *font3,                        /* Zeiger auf Fontheader    */
             *font4;                        /* Zeiger auf Fontheader    */

    int      exitb;             /* Exit-Flag fÅr die Hauptschleife      */

    char     file[13],          /* Dateiname                            */
             path[255],         /* Pfadname                             */
             fontfile[255],     /* Pfad+Dateiname                       */
                                /* Demotext:                            */
             *text = "The quick brown fox jumps over the lazy dog!";

    strcpy( file, "ROMAN.FNT" );            /* Defaultauswahl           */
    strcpy( path, "\\*.F??" );              /* Defaultpfadname          */

    do
    {
        fsel_input( path, file, &exitb );       /* Fileselector         */
    
        if( exitb == 1 )                /* Abbruch-Button gewÑhlt?      */
        {
            Cconws( "\x1B\x45" );

            strcpy( fontfile, path );   /* Pfad u. Dateiname verkoppeln */
            memcpy( strbchr( fontfile, '\\' ) +1, file, strlen(file) +1 );
    
            font1 = FNT_load( ext(fontfile, "FNT") );   /* Font laden   */
            font2 = FNT_load( ext(fontfile, "F09") );   /* Font laden   */
            font3 = FNT_load( ext(fontfile, "F30") );   /* Font laden   */
            font4 = FNT_load( ext(fontfile, "F24") );   /* Font laden   */

            linea_init();                           /* LineA starten    */

            /* Texte in verschiedenen Fonts ausgeben                    */

            FNT_text( 30, 30, text, font1, 0, 0, REPLACE );
            FNT_text( 30, 100, text, font2, 0, 0, REPLACE );
            FNT_text( 30, 200, text, font3, 0, 0, REPLACE );
            FNT_text( 30, 300, text, font4, 0, 0, REPLACE );

            FNT_text( 5, 390, "(C) 1991 Patrick Hoffmann, Netz:"
                    " PATHO@JPBERLIN.ZER", font1, 900, 0, REPLACE );
            
            FNT_unload( font1 );    /* Fontspeicher wieder freigeben    */
            FNT_unload( font2 );    /* Fontspeicher wieder freigeben    */
            FNT_unload( font3 );    /* Fontspeicher wieder freigeben    */
            FNT_unload( font4 );    /* Fontspeicher wieder freigeben    */

            getch();                /* Auf Taste warten             */
        }
    }while( exitb == 1 );           /* Bis Abbruch-Button gewÑhlt wurde */
}

/*==== Sub-Routines ====================================================*/

/*++ Textausgabe +++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* ->   x,y     : Textposition                                          */
/*      text    : auszugebender Text                                    */
/*      font    : Zeiger auf Fontheader                                 */
/*      winkel  : Ausgabewinkel ( 0, 900, 1800 o. 2700 )                */
/*      stil    : Textstil laut set_text_blt(..., style, ...)           */
/*      wrmode  : VerknÅpfungsmodi (REPLACE usw.)                       */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void FNT_text( int x, int y, char *text, FONT_HDR *font, 
               int winkel, int stil, int wrmode )
{
    int i,
        step;
    
    if( font != (void*)0L )                 /* Fontadresse ok?          */
    {
        hide_mouse();                               /* Maus weg!        */
        set_wrt_mode( wrmode );                     /* VerknÅpfungsmodi */
        set_text_blt( font, 0, stil, winkel, 1, 0 );    /* Text-Stil    */
        for( i=0; i<strlen(text); i++)
        {
            text_blt( x, y, *(text+i) );

            /* proportionale Schrittweite holen                         */
            step = *(font->ch_ofst+(*(text+i)-font->ade_lo) +1 ) - 
                   *(font->ch_ofst+(*(text+i)-font->ade_lo));

            switch( winkel )
            {
            case 0:     x += step;  break;  /* Von rechts nach links    */
            case 900:   y -= step;  break;  /* Von unten nach oben      */
            case 1800:  x -= step;  break;  /* Von links nach rechts    */
            case 2700:  y += step;          /* Von oben nach unten      */
            }
        }
        show_mouse( 1 );                            /* Maus hin!        */
    }
}

/*++ TextlÑngenbestimmung ++++++++++++++++++++++++++++++++++++++++++++++*/
/* ->   text    : Text                                                  */
/*      font    : Zeiger auf Fontheader                                 */
/* <-   errechnete LÑnge in Pixeln                                      */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int FNT_len( char *text, FONT_HDR *font )
{
    int i, len;
    
    len = 0;

    for( i=0; i<strlen(text); i++)
        len += *(font->ch_ofst+(*(text+i)-font->ade_lo) +1 ) - 
               *(font->ch_ofst+(*(text+i)-font->ade_lo));
    return( len );
}

/*++ GDOS-Font laden +++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* -> file: Dateiname nach TOS-Norm                                     */
/* <-       Zeiger auf geladene Fontstruktur laut FONT_HDR (siehe       */
/*          LineA-Doku). Bei Ladefehler wird NULL zurÅckgegeben!        */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

FONT_HDR *FNT_load( char *file )

{
    FONT_HDR    *buffer;            /* Hier wird der Font hingeladen    */
    int         handle;             /* File-Handle                      */

    if( (handle = Fopen( file, 0 )) >= 0 )  /* Datei îffnen, Handle     */
                                            /* holen u. Fehler abfragen */
    {
                            /* Speicher reservieren (nach DateilÑnge)   */
        buffer = malloc( filelength( handle ) );
                            /* Datei in den reservierten Buffer lesen   */
        Fread( handle, filelength( handle ), buffer );

        /* Die orginalen GDOS-Fonts haben die dubiose Eigenschaft Byte- */
        /* weise vollkommen "verdreht" zu sein! Das liegt daran, daû    */
        /* Digital Research geschickter Weise darauf gekommen ist, fÅr  */
        /* ihre ZeichensÑtze das Intelformat zu verwenden. Das wiederum */
        /* heiût: Jedes WORD oder LONG komplett spiegeln! (siehe        */
        /* intel_to_68000(), wswitch() und lswitch() ).                 */
        /* Da aber zum Bleistift die von ARABESQUE konvertierten Fonts  */
        /* im 68000er Format vorliegen, mÅssen beide Formate beachtet   */
        /* werden.                                                      */

        /* Wenn kein Bit im Lowbyte der Flagstruktur gesetzt ist, dann  */
        /* ist entweder kein Bit in flags gesetzt oder flags liegt auch */
        /* im Intelformat vor. In beiden FÑllen kann das Umrechnen ins  */
        /* Motorola Format nichts kaputtmachen.                         */

        /* Die Ausrufezeichen am Anfang beachten!!: */

        if( !(*(int*)&(buffer->flags) & 0x00FF) )
            wswitch( (int*)&(buffer->flags) );      /* Also umrechnen!  */

        if( !buffer->flags.f68000 )         /* Intelformat-Flag ?       */
            intel_to_68000( buffer );       /* Umrechnen...!            */

        /* Zeig' mir, daû Du als Zeiger auf einen anderen Zeiger auf    */
        /* auf den Zeiger eines Zeigers der auf einen Integer zeigt     */
        /* zeigst! (Na los, 10x hintereinander!)                        */
        /* Nein, nein hier addiere ich lediglich den Dateioffset fÅr    */
        /* die HOT, COT und Fontdaten zur Adresse der geladenen         */
        /* Struktur im Speicher. (Ein Relativ-Verschiebung sozusagen!)  */

        buffer->hz_ofst = buffer->hz_ofst + (long)buffer;
        buffer->ch_ofst = (int*)((char*)buffer->ch_ofst + (long)buffer);
        buffer->fnt_dta = (int*)((char*)buffer->fnt_dta + (long)buffer);

        Fclose( handle );               /* Schlieûe was Du offen hast!  */
        
        return( buffer );               /* Zeiger zurÅckgeben           */

    }else                                   /* Bei Ladefehler...        */
        return( (void*)0L );                /* ..Nullzeiger zurÅckgeben */
}

/*++ Fontspeicher wieder freigeben +++++++++++++++++++++++++++++++++++++*/
/* ->   font    : Zeiger auf Fontheader                                 */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void FNT_unload( FONT_HDR *font )       /* Font "ent"-laden             */
{
    free( font );               /* Einfach Speicherbereich freigeben    */
}

/*==== Sub-Sub-Routines ================================================*/

/*++ Extender eines Pfadnamens austauschen +++++++++++++++++++++++++++++*/
/* ->   file    : Pfad+Dateiname                                        */
/*      ext     : Neuer Extender                                        */
/* <-   Zeiger auf geÑnderten Namen                                     */
/* Bemerkung: Arbeitet nur, wenn schon ein Extender vorhanden ist!      */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

char *ext( char *file, char *ext )
{
    memcpy( strbchr(file, '.') +1, ext, 4 ); 
    return( file );
}
/*++ Zeichen in einem String rÅckwÑrts suchen ++++++++++++++++++++++++++*/
/* ->   text    : Zu durchsuchender Text                                */
/*      find    : Zu suchendes Zeichen                                  */
/* <-   Zeiger auf gefundenes Zeichen                                   */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

char *strbchr( char *text, char find )
{
    int i;
    for( i=(int)strlen(text)-1; i>=0; i-- )
    {
        if( *(text+i) == find )
        {
            return( text+i );
        }
    }
    return( (void*)0L );
}

/*++ Umrechnen eines Fontheaders vom Intel- ins 68000er-Format +++++++++*/
/* ->   hdr     : Umzurechnender Header                                 */
/* <-   hdr wird auch wieder zurÅckgegeben                              */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

FONT_HDR *intel_to_68000( FONT_HDR *hdr )
{
    int i;

    if( hdr->id > 255 )         /* Wenn ID > $FF -> INTEL-Format    */
    {
        /* Wandeln vom Intel ins Motorola-"Normalformat"...     */
        
        wswitch( &(hdr -> id) );
        wswitch( &(hdr -> size) );
        
        /* Von .ade_lo bis .skewng_m (15 Words)...              */
        
        for( i=0; i<15; i++)
            wswitch( &(hdr->ade_lo)+i );

        lswitch( (long*)&(hdr -> hz_ofst) );
        lswitch( (long*)&(hdr -> ch_ofst) );
        lswitch( (long*)&(hdr -> fnt_dta) );
        wswitch( &(hdr -> frm_wdt) );   wswitch( &(hdr -> frm_hgt) );

        /* Die COT (character-offset-table) auch noch switchen!         */

        for( i=0; i< (hdr->ade_hi - hdr->ade_lo)+2; i++ )
            wswitch( ((int*)((long)hdr->ch_ofst + (long)hdr) + i) );

        /* Von der HOT (horizontal-offset-table) hab' ich erst einmal   */
        /* die Greiferchen gelassen, denn ich hab' noch keinen Font     */
        /* analysieren kînnen, der die HOT benutzt. Eigentlich mÅûte    */
        /* man die auch noch spiegeln.                                  */
        /* Aber VORSICHT! Wird die HOT nicht benutzt, so kann der Off-  */
        /* set fÅr HOT und COT gleich sein! Ergebnis: Die COT wird dann */
        /* wieder zurÅckgespiegelt                                      */
    }
    
    return( hdr );  
}

/*++ Word ins 68000er Format +++++++++++++++++++++++++++++++++++++++++++*/
/* ->   w       : umzurechnendes Word                                   */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void wswitch( int *w )
{
    char i;
    
    i = *(char*)w;                                  /* Dreieckstausch   */
    *(char*)w = *((char*)w+1);                      /*      ...         */
    *((char*)w+1) = i;                              /*      ...!        */
}

/*++ Long in 68000er-Format ++++++++++++++++++++++++++++++++++++++++++++*/
/* ->   l       : umzurechnendes Long                                   */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void lswitch( long *l )
{
    int i;

    wswitch( (int*)l );         /* HI-/LO-Bytes der beiden Wîrter...    */
    wswitch( ((int*)l+1) );     /*              ...                     */
    
    i = *(int*)l;               /* ...und die beiden Wîrter selbst...   */
    *(int*)l = *((int*)l+1);    /*          ...tauschen...              */
    *((int*)l+1) = i;           /*              ...!                    */
}

