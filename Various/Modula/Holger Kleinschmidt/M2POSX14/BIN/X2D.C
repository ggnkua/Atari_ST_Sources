/*
 * Benutzung:        'X2D' ['-'lines] ['<'infile] ['>'outfile]
 *             oder  [input '|'] 'X2D' ['-'lines] ['|' output]
 *
 * Dieses kurze Programm wird als Filter zwischen Standardeingabe und
 * Standardausgabe benutzt. X2D steht dabei fuer UNIX TO DOS.
 * Es wandelt alle UNIX-Zeilenenden, d.h. separat stehende LF's in 
 * DOS/TOS-Zeilenenden um ( CR + LF ).
 * Bereits in der Eingabe stehende CR/LF-Sequenzen werden unveraendert
 * uebertragen. Leerzeichen am Ende einer Zeile werden entfernt.
 *
 * Falls die Optionsangabe aus genau einem Minuszeichen besteht, dem
 * direkt, d.h. ohne Leerzeichen, eine Ziffer zwischen Null und Neun
 * folgt, wird diese Angabe als maximale Anzahl erlaubter aufeinander-
 * folgender Leerzeilen interpretiert; wenn in der Eingabe mehr Leerzeilen
 * direkt hintereinander stehen, werden diese nicht mehr in die Ausgabe
 * uebertragen. Mit X2D -0 enthaelt also die Ausgabe keine Leerzeilen mehr.
 *
 * Folgen in der Eingabe mehr als 256 Blanks, Tabs usw. hintereinander,
 * werden die restlichen Leerzeichen nicht uebertragen.
 *
 * Das Programm wurde mit GCC 1.37.1 und der MiNTLIB uebersetzt und ist in
 * erster Linie fuer M2-Quelltexte gedacht, die mit dem GNU-CPP bearbeitet 
 * wurden. Fuer diese Aufgabe ist der Aufruf mit 'X2D -1'  sinnvoll.
 *
 *
 * Die Dateien:
 *
 *   X2D.C
 *   X2D.TTP
 *   X2D1.C
 *   X2D1.TOS
 *
 * gehoeren zusammen, und muessen auch immer zusammen weitergegeben werden,
 * alles weitere wie in COPYLEFT von FSF.
 *
 *    hk, 15-Nov-91
 */


/*
**  I M P O R T
*/

#include <osbind.h>   /* Fwrite( ), Fread( )               */
#include <limits.h>   /* SHRT_MAX                          */
#include <minimal.h>  /* _main( ), exit( )                 */
#include <ctype.h>    /* isascii(), isspace( ), isdigit( ) */
#include <string.h>   /* strlen( )                         */


/*
**  K O N S T A N T E N
*/

#define BUFSIZE  0x2000L  /* 8 kB Puffer fuer Ein/Ausgabe */
#define MAXSPACE 256      /* maximal 256 aufeinanderfolgende Leerzeichen */

#define CON    (-1)
#define STDIN  0
#define STDOUT 1

#define CR 0x0D
#define LF 0x0A

#define FALSE 0
#define TRUE  1
#define EOF   (-1)



/*
**  G L O B A L E   V A R I A B L E N
*/

char  input[BUFSIZE];                 /* Eingabepuffer */
char  output[BUFSIZE];                /* Ausgabepuffer */
char  spacebuf[MAXSPACE];             /* Puffer fuer Leerz. innerhalb Zeile */
char  *input_ptr  = input  + BUFSIZE; /* -> naechstes Eingabezechen */
char  *output_ptr = output;           /* -> naechstes Ausgabezeichen */
char  *space_ptr;                     /* -> naechstes Ein/Ausgabe-Leerzeichen */
char  *input_end  = input  + BUFSIZE; /* -> Ausgabepufferende + 1 */
char  *output_end = output + BUFSIZE; /* -> Eingabepufferende + 1 */
char  *space_end  = spacebuf + MAXSPACE;
short akt_char, unch;                 /* letztes Eingabezeichen */
char  errmsg[] = "\n+++ FEHLER BEIM SCHREIBEN !\n";
short unread = FALSE;


/*
**  F U N K T I O N E N
*/



short
read_char( )

/* Das naechste Zeichen aus dem Puffer wird gelesen und als auf 'short'
 * erweiterter Wert zurueckgeliefert. Ist der Puffer leer, wird ein
 * neuer Puffer von 'stdin' eingelesen. Ist die Eingabedatei abgearbeitet,
 * wird 'EOF' zurueckgeliefert. 
 */
{
  long  size;

  if( unread )
  { unread = FALSE;
    return( unch );
  }
  if( input_ptr >= input_end )
  { if(( size = Fread( STDIN, BUFSIZE, input )) <= 0L )
      return( EOF );
    input_end = input + size;
    input_ptr = input;
  }
  return((short)(*input_ptr++));
}

/*--------------------------------------------------------------------------*/

void
flush( )

/* Die bisher im Ausgabepuffer stehenden Zeichen werden komplett
 * nach 'stdout' geschrieben.
 */
{
  if( Fwrite( STDOUT, output_ptr - output, output ) != output_ptr - output )
  { (void)Fwrite( CON, strlen( errmsg ), errmsg );
    exit(-1 );
  }
  output_ptr = output;
}

/*--------------------------------------------------------------------------*/

void
write_char( char ch )

/* Das Zeichen <ch> wird in den Ausgabepuffer geschrieben; ist
 * der Puffer voll, wird er komplett nach 'stdout' geschrieben.
 */
{
  if( output_ptr >= output_end ) flush( );
  *output_ptr++ = ch;
}

/*--------------------------------------------------------------------------*/

void 
read_space( )

/* von der Eingabe werden solange Zeichen nach 'spacebuf' geschrieben,
 * bis das Dateiende, das (UNIX-)Zeilenende oder ein Zeichen
 * auftritt, dass kein `space'-Zeichen ist. Dieses Zeichen steht
 * global in 'akt_char' zur Verfuegung.
 *
 * Bei Ueberlauf des Puffers wird nur noch ueberlesen, aber nicht
 * mehr abgespeichert !
 */
{
  space_ptr = spacebuf;
  while( isascii(akt_char=read_char( )) && isspace(akt_char) && akt_char != LF)
    if( space_ptr < space_end )
      *space_ptr++ = akt_char;
}

/*--------------------------------------------------------------------------*/

void
write_space( )

/* Alle Zeichen aus 'spacebuf' werden in die Ausgabe geschrieben */
{
  char *space_max = space_ptr;
  
  for( space_ptr=spacebuf; space_ptr<space_max; write_char( *space_ptr++ ))
    ;
}

/*--------------------------------------------------------------------------*/

short 
copyline( )

/* Eine Zeile aus dem Eingabepuffer, die mit einem einzelnen 'LF' 
 * abgeschlossen ist, wird ohne Zeilenende nach 'stdout' geschrieben,
 * falls die Zeile nicht nur aus `space'-Zeichen bestand oder leer war.
 * Der letzte Teil der Ausgabe kann noch im Ausgabepuffer stehen. Das
 * die Zeile beendende Zeichen ( 'LF' oder 'EOF' ) steht global in 
 * 'akt_char' zur Verfuegung. 
 * Als Funktionswert wird zurueckgeliefert, ob die Zeile eine Leerzeile
 * war.
 */
{
  short empty = TRUE;
  
  do
  { read_space( );
    if( akt_char == EOF || akt_char == LF ) return( empty );
    write_space( );
    empty = FALSE;

    do
    {
      write_char( akt_char );
    } while(    !( isascii( akt_char=read_char()) && isspace( akt_char )) 
             && akt_char != EOF  &&  akt_char != LF );

    unread = TRUE;
    unch   = akt_char;

  } while( akt_char != EOF && akt_char != LF );

  unread = FALSE;
  return( FALSE );
}


/*
**  H A U P T P R O G R A M M
*/

int  
main( int argc, char *argv[] )
{
  short  max_empty;
  short  empty_lines = 0;


  if( argc > 1 && *argv[1] == '-'
               && isascii(*++argv[1]) && isdigit(*argv[1]))
    max_empty = *argv[1] - '0';
  else
    max_empty = SHRT_MAX;
      
  do
  { if( copyline( ))
      empty_lines++;
    else
      empty_lines = 0;
    
    if( empty_lines <= max_empty && akt_char != EOF )
    { write_char( CR );
      write_char( LF );
    }
  } while( akt_char != EOF );
  flush( );
  return( 0 );
}
