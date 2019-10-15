/*------------------------------------------------------*/
/* MAKE_HLP.C                                           */
/* Programm: MAKE_HLP.TTP                               */
/*           Online-Hilfe "Help!"                       */
/* Sprache:  Turbo-C 2.0                                */
/* Autor:    (C)1990 Mathias Tobollik                   */
/*------------------------------------------------------*/
#include <help.h>

/*--------------------------------------------------------
   Hauptprogramm (.TTP) 
   Parameter: <Dateiname> des ASCII-Quelltextes    
--------------------------------------------------------*/
int main( int argc, char* argv[] )
{
                         /* FÅr das Inhaltsverzeichnis: */
char *memory;            /* Speicher fÅr Strings */
char *c[MAX_SRT];        /* Zeiger auf Strings   */

    if( argc != 2 )
    {
        printf( "\n Parameter: <Dateiname>" );
        getch();
        exit( -1 );
    }
/* Index- und Help-Datei erstellen: --------------------*/
    if( make_help( strupr( argv[1] ) ) )
        exit( -1 );
/* Verweise prÅfen: ------------------------------------*/
    if( check_help( argv[1] ) )
        exit( -2 );
/* Inhaltsverzeichnis erstellen: -----------------------*/
    memory=get_mem((long)(MAX_SRT*(REF_LEN+4)));
    if( make_contents( argv[1], c, memory ) )
    {
        fre_mem( memory );
        exit( -3 );
    }
    fre_mem( memory );
        
    exit( 0 );
    return( 0 );
}

/*-------------------- Ende MAKE_HLP.C -----------------*/

