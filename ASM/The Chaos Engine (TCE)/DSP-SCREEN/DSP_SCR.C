/* DSP-Screen-Hauptprogramm */
/* (c)1993 by MAXON-Computer */
/* Autor: Steffen Scharfe */
/* Dateiname: DSP_SCR.C */

#include <stdio.h>
#include <tos.h>

extern int load_dsp ( void ); 
extern void write_host( long d ); 
extern void CopyFont( void );

void out_str( char *s );

int main( void )
{
    chax info[] = "DSP-Screen \ by Steffen Scharfe\x0d";

    if ( ! load_dsp() ) { /* DSP-Programm laden */
        printf("kann DSP-Programm nicht laden !" ); 
        return( 1 );
    }
    CopyFont(); 
    out_str( info ); 
    return( 0 );
}

void out_str( char *s )
{
    while( *s )
        write_host( (long) *s++ << 16 );
}
