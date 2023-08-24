/*****************************************************************************

    Konvertiert Cybersculpt 3D2-Files in das POV-Sourceformat.

    (c) Coderight Juni 1994:

                  Jochen Knaus
                  Nickeleshalde 19
                  88400 Biberach
           EMail: knaus@ruf.uni-freiburg.de

    Datum:        27.7.1994
    Update:       30.9.1994 (1.20): kleiner, schneller.
                  19.12.94  (1.29): Objektsplitting, einh. Kommandozeile.
                  01.01.95  (1.291): Ausgabebug gefixed.
                  26.06.95  (1.292): Objektnamen mit '//' auskommentiert.
                  27.06.95  (1.3) : Gnu C Anpassung (gcc), Fehler auf stdout.
                  07.07.95  (1.39): "smooth_triangles" integriert, noch ungetestet.
                  11.07.95  (1.41): "smooth_triangles" fertig (mit bel. Genauigkeit).
    Version:      1.41
    Compiler:     `Pure C' oder `Gnu C'.

    Dieses Konvertierprogramm ist Freeware, im Geiste des POV.
		Hallo an Dirk Klemmt: vielleicht liegt dieses Tool ja bald der Shell bei!

    Das ganze sehr unsauber, unstrukturiert (jaja, wenn keine Punkte da sind...),
    aber schnell gebastelt und trotzdem portabel (GCC kompatibel --> weltweit gut).

    Aufruf: CYB_POV -flags 3d2_file <Destfile> <objektname>
            Flags:  -v  : File fÅr POV 1.x erzeugen.
                    -b  : Automatisches berechnen der Objektgrenzen.
                    -o  : Objektsplitting.
                    -l  : Extra LF am Zeilenende ausschalten.
                    -s  : Smooth Triangles an.
                    -eX : Setzt Genauigkeit bei smooth_triangle Normalen auf X.
                          (Default 4).

******************************************************************************/

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<math.h>
#include<limits.h>                      /* Eve. fÅr Anpassungen gebraucht.  */

#include "cyb_pov.h"                    /* Systembedingte Variablen.        */

#define VERSION_A 1                     /* Versionsnummern. */
#define VERSION_B 41                    /*        "         */

#ifndef FALSE                           /* TRUE und FALSE ggf. def.         */
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

typedef struct{ float a,b,c; }VEC3;     /* Simple Struct fÅr 3D-Vektor.     */

int   abbruch( void );                  /* Schlieût Files.                  */
void  write_bounds( void );             /* Bestimmt und schreibt Objektgrz. */
void  vecadd( VEC3 *, VEC3 *);          /* Vektoraddition fÅr 3D-Veks.      */

FILE  *source, *destin;                 /* Filehandles global...            */
WORD  wandel[6], minmax[6];
WORD  pov_mode = 2, bounds = FALSE, obj_split = FALSE, smooth = FALSE,
      *punkte = NULL, *facetten = NULL;
VEC3  *normale = NULL, *punkt_norm;
char  *vorzeichen[6], buffer[4000], minus[2] = { '-', 0 },
      nullos[2] = { 0 },
      buffer3[3] = { '}', 10, 0 };      /* Default: CR/LF am Zeilenende.		*/
int   genau = 4;                        /* Default: Genauigkeit.						*/

int main( int argc, char *argv[] )
{
  WORD          header[128], anz_obj, anz_punkte, anz_facetten, divi;
  VEC3          intp_norm;
  char          obj_name[10],  buffer2[512], output[48],
                def_file[PATHLEN] = "STD.POV", def_name[64] = "DEFOBJ",
                source_file[PATHLEN];
  register WORD i, j, m = 1;
  VEC3          v, w;
  float         len, fdivi;

  /* Startmeldung. */
  printf( "\n3D2->POV Converter vers. %d.%d, (c) 1994 by Jochen Knaus (AURA), Freeware.\n\n",
          VERSION_A, VERSION_B );

  /**************************
    Kommandozeile auswerten.
   **************************/
  if( argc <= 1 ) {                           /* Keine Parameter ? */
    puts( "Kommandozeile: [-vobls] sourcefile [destination] [objectname]" );
    return FALSE;
  }

  /* Alle CommandozeileneintrÑge nach Optionen untersuchen. */
  if( (argv[1])[0] == '-' ) {                 /* "-" beginnt Optionen.    */
    if( strlen( argv[1] ) > 1 ) {             /* Einzelnes "-"            */
      for( j=1 ; j < strlen( argv[1] ); j++ ) { /* Alle Optionenzeichen.  */
        switch( (argv[1])[j] ) {
          case  'v':  pov_mode = 1; break;    /* Umschalten auf Ver. 1    */
          case  'b':  bounds = TRUE; break;   /* Autobounding.            */
          case  'l':  buffer3[1] = 13; break; /* Nur CR als Zeilenendkennung. */
          case  's':  smooth = TRUE; break;   /* Smooth-Triangles.        */
          case  'e':  genau = (int) ((argv[1])[++j] - SCAN_ZERO); /* Genauigkeit */
                      if( genau < 1 || genau > 9 ) {              /* der Ausgabe */
                        puts( "Use -eX with X between 1 and 9." ); /* der smooth_polys */
                        return FALSE;                             /* verÑndern? */
                      }
                      break;
          case  'o':  obj_split = TRUE;       /* Objektsplitting.         */
        }
      }
    }
  }
  else m = 0;                                /* Filenamen im ersten Argument. */

  /* Dateinamen und Objektnamen (wenn vorhanden) Åbernehmen. */
  if( argc > ( 1 + m ) ) {
    strncpy( source_file, argv[1+m], 127 );
    if( argc > ( 2 + m ) ) {
      strncpy( def_file, argv[2+m], 127 );
      if( argc > ( 3 + m ) ) strncpy( def_name, argv[3+m], 63 );
    }
  }
  else {                                      /* Kein zu konvertierendes File ? */
    puts( "Kein Cybersculptfile angegeben !" );
    return FALSE;
  }

  if( strlen( source_file ) == 0 ) {            /* Kein 3D2-File angegeben ? */
    puts( "No source (3D2) file." );
    return FALSE;
  }

  /* Quelldatei (binÑr) îffnen. */
  if( ( source = fopen( source_file, "rb" ) ) == NULL ) {
    printf( "Cannot access sourcefile <%s>.\n", source_file );
    return FALSE;
  }

  /* Zieldatei (ASCII) erzeugen. */
  if( ( destin = fopen( def_file, "w+" ) ) == NULL ) {
    printf( "Cannot create or access destinationfile <%s>.\n", def_file );
    return FALSE;
  }

  /* Header lesen, bei Fehler abbrechen. */
  if( fread( header, 256, 1, source ) < 0 ) return( abbruch() );

  /* 3D2-Kennung ÅberprÅfen. */
  if( header[0] != 15618 ) {
    puts( "No 3D2 file, identification wrong." );
    return( abbruch() );
  }

  /* Ausgabestring fÅr "sprintf" initialisieren (je nach gewÅnschter POV-Version).
     (Damit nur eine Ausgaberoutine benîtigt wird). */
  if( pov_mode == 1 )
    if( !smooth )
      strcpy( output, "<%s%d.%d %s%d.%d %s%d.%d>" );
    else
      strcpy( output, "<%s%d.%d %s%d.%d %s%d.%d><%.*f %.*f %.*f>" );
  else
    if( !smooth )
      strcpy( output, "<%s%d.%d,%s%d.%d,%s%d.%d>" );
    else
      strcpy( output, "<%s%d.%d,%s%d.%d,%s%d.%d><%.*f,%.*f,%.*f>" );

  /* Ausgabefile initialisieren. */
  anz_obj = header[1];                          /* Anzahl Objekte. */
  printf( "%s: convert %d object(s).\n\n", source_file, anz_obj );

  /* #declare <objektnamen> erzeugen. */
  sprintf( buffer, "#declare %s = union {%s", def_name, &buffer3[1] );
  fwrite( buffer, strlen(buffer), 1, destin );

  if( !obj_split && bounds ) {                  /* Grenzwerte initialisieren? */
    minmax[0] = WORD_MAX; minmax[1] = WORD_MIN; /* Ohne Objektsplitting muû */  
    minmax[2] = WORD_MAX; minmax[3] = WORD_MIN; /* Box um ganzes Objekt be- */
    minmax[4] = WORD_MAX; minmax[5] = WORD_MIN; /* rechnet werden.          */
  }

  /* Alle Objekte umsetzen, Bufferstring initialisieren.  */
  for( i=0, buffer[0] = '\0'; i<anz_obj ; i++ ) { /* Alle Objekte !           */
    fread( obj_name, 9, 1, source );              /* Objektnamen.             */
    fread( &anz_punkte, 2, 1, source );           /* Anzahl Punkte (2 Bytes). */

    if( obj_split ) {                             /* Objektsplitting ?  */
      strcat( buffer, "union{ " ); /* strcat( buffer, &buffer3[1] ); */

      if( obj_split && bounds )                 /* Grenzwerte initialisieren. */
      {                                         /* Bei Objektsplitting fÅr    */
        minmax[0] = WORD_MAX; minmax[1] = WORD_MIN; /* jedes einzelne Objekt  */
        minmax[2] = WORD_MAX; minmax[3] = WORD_MIN; /* Boundbox berechnen.    */
        minmax[4] = WORD_MAX; minmax[5] = WORD_MIN;
      }
    }

    /* Sollte das Objekt Punkte besitzen, dann Speicher fÅr Punkte reservieren,
       (Std. malloc) und Punkte einlesen, andernfalls abbrechen.              */
    if( anz_punkte > 0 ) {
      if( ( punkte = malloc( (long) (anz_punkte * 6) ) ) == NULL )
        return( abbruch() );

      fread( punkte, anz_punkte*2, 3, source );     /* Punkte einlesen. */

      if( bounds ) {                          /* Objektgrenzen feststellen ? */
        for( j = 0 ; j < anz_punkte ; j++ ) { /* Objektextremas festellen. */
          if( punkte[j*3+0] < minmax[0] ) minmax[0] = punkte[j*3+0];
          if( punkte[j*3+0] > minmax[1] ) minmax[1] = punkte[j*3+0];
          if( punkte[j*3+1] < minmax[2] ) minmax[2] = punkte[j*3+1];
          if( punkte[j*3+1] > minmax[3] ) minmax[3] = punkte[j*3+1];
          if( punkte[j*3+2] < minmax[4] ) minmax[4] = punkte[j*3+2];
          if( punkte[j*3+2] > minmax[5] ) minmax[5] = punkte[j*3+2];
        }
      }

      /* Anzahl Facetten lesen. */
      fread( &anz_facetten, 2, 1, source );

      /* Objekt und Anzahl Facetten ausgeben. */
      printf( "%8s: %4d faces: ", obj_name, anz_facetten );

      /* Keine Facetten: Warnung ausgeben. */
      if( anz_facetten == 0 )
        puts( "Warning: Zero facettes in object." );

      /* Facettenspeicher reservieren. */
      if( ( facetten = malloc( (long) (anz_facetten * 8) ) ) == NULL )
        return( abbruch() );

      /* Facetten einlesen. */
      fread( facetten, anz_facetten*4, 2, source );

      /* Smooth Triangles Berechnung (wenn benîtigt) vorberechnen:
         FlÑchennormalen. */
      if( smooth ) {
        printf( " Calc. facett normals. " );

        if( ( normale = malloc((long)(anz_facetten*sizeof(VEC3)))) == NULL )
          return( abbruch() );
        if( ( punkt_norm = malloc((long)(anz_punkte*sizeof(VEC3)))) == NULL )
          return( abbruch() );

        /* FÅr alle Facetten Åber das Kreuzprodukt eine Normale bilden. */
        for( j=0; j<anz_facetten; j++ ) {
          v.a = (float) (punkte[facetten[j*4+0]*3+0]);    /* Punkt 1 */
          v.b = (float) (punkte[facetten[j*4+0]*3+1]);
          v.c = (float) (punkte[facetten[j*4+0]*3+2]);
          w.a = (float) (punkte[facetten[j*4+1]*3+0]);    /* Punkt 2 */
          w.b = (float) (punkte[facetten[j*4+1]*3+1]);
          w.c = (float) (punkte[facetten[j*4+1]*3+2]);

          normale[j].a = v.b * w.c - v.c * w.b;           /* Kreuzprodukt. */
          normale[j].b = v.c * w.a - v.a * w.c;
          normale[j].c = v.a * w.b - v.b * w.a;

          /* NormalenlÑnge berechnen. */
          len = sqrt( normale[j].a*normale[j].a + normale[j].b*normale[j].b +
                     normale[j].c*normale[j].c );

          /* Normale normieren. */
          normale[j].a /= len;
          normale[j].b /= len;
          normale[j].c /= len;
        }

        /* Jetzt an jedem Punkt die interpolierte Normale bilden. */
        for( j=0; j<anz_punkte; j++ ) {
          divi = 0;                           /* Anzahl Facetten mit Punkt. */
          intp_norm.a = intp_norm.b = intp_norm.c = 0;

          /* Facetten, in denen der Punkt eine Ecke darstellt bestimmen, und
             dann deren Normalen aufaddieren. */
          for( m=0; m<anz_facetten; m++ ) {
            if( facetten[m*4+0] == j ) {
              vecadd( &intp_norm, &normale[m] );  divi++;
            }
            else if( facetten[m*4+1] == j ) {
              vecadd( &intp_norm, &normale[m] );  divi++;
            }
            else if( facetten[m*4+2] == j ) {
              vecadd( &intp_norm, &normale[m] );  divi++;
            }
          }

          /* Normale := Addition der anliegenden Normalen. */
          if( divi > 0 ) {    /* divi = 0 sollte eigentlich nie vorkommen. */
            fdivi = (float) divi;     /* Nur einmal casten. */
            punkt_norm[j].a = intp_norm.a / fdivi;
            punkt_norm[j].b = intp_norm.b / fdivi;
            punkt_norm[j].c = intp_norm.c / fdivi;
          }
          else
            punkt_norm[j].a = punkt_norm[j].b = punkt_norm[j].c = 0;
        }
      }

      /* Objektnamen als Kommentar in Source einfÅgen. */
      sprintf( buffer2, "// %s", obj_name );
      strcat( buffer, buffer2 );  strcat( buffer, &buffer3[1] );

      for( j=0; j<anz_facetten ; j++ ) {            /* Facetten konvertieren. */
        if( smooth )
          strcat( buffer, " smooth_triangle{" );
        else
          strcat( buffer, " triangle{" );

        /* Punkte wandeln... 2 Stellen Nachkomma (/100) (3D2-Fixkommaformat!),
           Verkleinerung mÅssen in POV durchgefÅhrt werden. */
        for( m=0 ; m<3 ; m++ ) {
          wandel[0] = (punkte[facetten[j*4+m]*3+0]);      /* x */
          wandel[1] = (punkte[facetten[j*4+m]*3+1]);      /* y */
          wandel[2] = (punkte[facetten[j*4+m]*3+2]);      /* z */
          wandel[3] = abs( wandel[0] );                   /* FÅr Nachkomma... */
          wandel[4] = abs( wandel[1] );
          wandel[5] = abs( wandel[2] );
          if( wandel[0] < 0 ) vorzeichen[0] = minus; else vorzeichen[0] = nullos;
          if( wandel[1] < 0 ) vorzeichen[1] = minus; else vorzeichen[1] = nullos;
          if( wandel[2] < 0 ) vorzeichen[2] = minus; else vorzeichen[2] = nullos;

          /* Ausgabe: "triangle" oder "smooth_triangle", die verschiedenen
             POV-Notationen wurden bereits in 'output' initialisiert. */
          if( !smooth )
            sprintf( buffer2, output,
                     vorzeichen[0], wandel[3] / 100, wandel[3] % 100,
                     vorzeichen[1], wandel[4] / 100, wandel[4] % 100,
                     vorzeichen[2], wandel[5] / 100, wandel[5] % 100 );
          else
            sprintf( buffer2, output,
                     vorzeichen[0], wandel[3] / 100, wandel[3] % 100,
                     vorzeichen[1], wandel[4] / 100, wandel[4] % 100,
                     vorzeichen[2], wandel[5] / 100, wandel[5] % 100,
                     genau, punkt_norm[facetten[j*4+m]].a,
                     genau, punkt_norm[facetten[j*4+m]].b,
                     genau, punkt_norm[facetten[j*4+m]].c );
            
          strcat( buffer, buffer2 );
        }
        strcat( buffer, buffer3 );                  /* "}" und CR/LF anhÑngen.        */

        if( ( j % 10 ) == 0 ) {                     /* Alle 10 Dreiecke schreiben.    */
          printf( "." );      /* Der User sieht das Proggy arbeiten und freut sich... */
          fwrite( buffer, strlen(buffer), 1, destin );
          buffer[0] = '\0';                         /* Buffer zurÅcksetzen.           */
        }
      }   /* NÑchstes Facette */

      if( strlen( buffer ) > 0 )                    /* Restlichen Facetten schreiben. */
      { fwrite( buffer, strlen(buffer), 1, destin ); buffer[0] = '\0'; }

      if( obj_split ) {                               /* Objektsplitting ?            */
        if( bounds ) write_bounds();                  /* even. Grenzen schreiben.     */
        fwrite( buffer3, strlen(buffer3), 1, destin );/* "union" abschliessen.        */
      }

      if( smooth ) {                                  /* Smooth --> Normen und Punktnorm. */
        free( normale ); free( punkt_norm );          /* freigeben.                   */
        normale = punkt_norm = NULL;
      }

      free(punkte); free(facetten);                   /* Objektspeicher freigeben.    */
      punkte = facetten = NULL;                       /* Wg. "abbruch" auf NULL.      */
    }
    else {                                            /* Keine Punkte im Objekt.      */
      puts( "Zero or negative number of points in object. Exit." );
      return( abbruch() );
    }

    puts( " done." );
  }   /* NÑchstes 3D2-Objekt. */

  /* Falls fÅr gesamtes Objekt "bounded" gewÅnscht wurde. */
  if( bounds && !obj_split ) write_bounds();

  fwrite( buffer3, strlen(buffer3), 1, destin );      /* declare-union abschlieûen.   */
  fclose( source ); fclose( destin );                 /* Files schlieûen.             */
  return TRUE;
}

/* Vektoraddition (3D-Vek.) */
void vecadd( VEC3 *v, VEC3 *w ) {
  v->a += w->a;
  v->b += w->b;
  v->c += w->c;
}

/* Bestimmt Grenzen und hÑngt diese an den Buffer an. */
void write_bounds() {
  wandel[0] = abs( minmax[0] ); wandel[1] = abs( minmax[1] );
  wandel[2] = abs( minmax[2] ); wandel[3] = abs( minmax[3] );
  wandel[4] = abs( minmax[4] ); wandel[5] = abs( minmax[5] );

  if( minmax[0] < 0 ) vorzeichen[0] = minus; else vorzeichen[0] = nullos;
  if( minmax[1] < 0 ) vorzeichen[1] = minus; else vorzeichen[1] = nullos;
  if( minmax[2] < 0 ) vorzeichen[2] = minus; else vorzeichen[2] = nullos;
  if( minmax[3] < 0 ) vorzeichen[3] = minus; else vorzeichen[3] = nullos;
  if( minmax[4] < 0 ) vorzeichen[4] = minus; else vorzeichen[4] = nullos;
  if( minmax[5] < 0 ) vorzeichen[5] = minus; else vorzeichen[5] = nullos;

  if( pov_mode == 1 )
    sprintf( buffer, " bounded_by{box{<%s%d.%d %s%d.%d %s%d.%d><%s%d.%d %s%d.%d %s%d.%d>}}",
              vorzeichen[0], wandel[0] / 100, wandel[0] % 100,
              vorzeichen[2], wandel[2] / 100, wandel[2] % 100,
              vorzeichen[4], wandel[4] / 100, wandel[4] % 100,
              vorzeichen[1], wandel[1] / 100, wandel[1] % 100,
              vorzeichen[3], wandel[3] / 100, wandel[3] % 100,
              vorzeichen[5], wandel[5] / 100, wandel[5] % 100 );
  else
    sprintf( buffer, " bounded_by{box{<%s%d.%d,%s%d.%d,%s%d.%d><%s%d.%d,%s%d.%d,%s%d.%d>}}",
              vorzeichen[0], wandel[0] / 100, wandel[0] % 100,
              vorzeichen[2], wandel[2] / 100, wandel[2] % 100,
              vorzeichen[4], wandel[4] / 100, wandel[4] % 100,
              vorzeichen[1], wandel[1] / 100, wandel[1] % 100,
              vorzeichen[3], wandel[3] / 100, wandel[3] % 100,
              vorzeichen[5], wandel[5] / 100, wandel[5] % 100 );

  fwrite( buffer, strlen(buffer), 1, destin );  buffer[0] = '\0';
}

/* Abbruch: Schlieût die geîffneten Dateien und gibt Fehler zurÅck. */
int abbruch() {
  if( punkte != NULL ) free( punkte );    /* Dyn. Buffer ggf. freigeben. */
  if( facetten != NULL ) free( facetten );
  if( normale != NULL ) free( normale );
  if( punkt_norm != NULL ) free( punkt_norm );

  fclose( source ); fclose( destin );
  return FALSE;
}