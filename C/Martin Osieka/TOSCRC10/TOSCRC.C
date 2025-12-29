/*********************************************************************
*
* TOSCRC
*
* Kurzbeschreibung:
* Berechnet die CRC-Pruefsummen einer TOS-Datei
*
* Versionen:
* 1.0  mo  18.12.91  Basisversion
*
* Autoren:
* mo   (\/) Martin Osieka, Erbacherstr. 2, D-6100 Darmstadt
*
**********************************************************************
* Bemerkungen:
* - Dieser Quelltext und das zugehoerige Programm sind Freeware
* - Ab TOS 2.00/3.00 werden 16-Bit-CRCs ueber den Inhalt jedes Megabit-
*   Roms berechnet und in den letzten zwei Bytes jedes ROMs gespeichert.
* - Ab TOS 2.06/3.06 werden die ROMs anhand dieser Werte wÑhrend der
*   Systeminitialisierung geprÅft.
* - Die ROMs sind im ST 16-Bit und im TT 32-Bit breit organisiert.
*********************************************************************/

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include <portab.h>

#define FORWARD

#define FALSE 0
#define TRUE  1

#define PRGNAME "toscrc"

/********************************************************************/

int fileload( char *name, void *pmem, long *pmemsize)
/*
 | Laedt die Datei <name> in einen freien Speicherbereich
 | und liefert dessen Beschreibung in <mem> und <len>.
 */
{
  int fh;
  long flen;
  char *fmem;
  int err;

  *(void **)pmem = NULL;
  *pmemsize = 0;

  /*** Datei oeffnen ***/
  if ((fh = open( name, O_RDONLY)) < 0) {
    return( errno);
  };
  
  /*** Groesse der Datei bestimmen ***/
  if ( ((flen = lseek( fh, 0, SEEK_END)) < 0) ||
       (lseek( fh, 0, SEEK_SET) != 0)          ) {
    err = errno;
    close( fh);
    return( err);
  };

  /*** Speicher fuer Datei anfordern ***/
  if ((long)(fmem = malloc( flen + 1)) <= 0) {
    close( fh);
    return( ENOMEM);
  };

  /*** Datei laden ***/
  if (read( fh, fmem, flen) != flen) {
    err = errno;
    close( fh);
    free( fmem);
    return( err);
  };
  fmem[ flen] = 0;
    
  /*** Datei schliessen ***/
  if (close( fh) != 0) {
    err = errno;
    free( fmem);
    return( err);
  };

  *(void **)pmem = fmem;
  *pmemsize = flen;
  return( 0);
} /* fileload */


/*------------------------------------------------------------------*/

int filesave( char *name, void *mem, long memsize)
/*
 | Sichert den durch <mem> und <memsize> beschriebenen Speicherbereich
 | in der Datei <name>.
 */
{
  int fh;
  int err;
  
  /*** Datei oeffnen ***/
  if ((fh = creat( name, O_RDONLY)) < 0) {
    return( errno);
  };
  
  /*** Datei speichern ***/
  if (write( fh, mem, memsize) != memsize) {
    err = errno;
    close( fh);
    return( err);
  };

  if (close( fh) != 0) {
    return( errno);
  };
  
  return( 0);
} /* filesave */


/*------------------------------------------------------------------*/

int filefree( void *mem, long memsize)
/*
 | Gibt den von einer Datei belegten Speicherbereich wieder frei
 */
{
  memsize = memsize;
  if (mem != NULL) free( mem);
  return( 0);
} /* filefree */


/*------------------------------------------------------------------*/

UWORD crc_table[] = {
  0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
  0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
  0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
  0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
  0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
  0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
  0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
  0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
  0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
  0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
  0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
  0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
  0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
  0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
  0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
  0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
  0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
  0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
  0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
  0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
  0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
  0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
  0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
  0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
  0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
  0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
  0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
  0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
  0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
  0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
  0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
  0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};


/*------------------------------------------------------------------*/

UWORD crc_calc( UBYTE *mem, long memsize, int bytew)
/*
 | Berechnet eine 16-bit CRC-Pruefsumme. Aus <memsize> Bytes
 | ab der Adresse <startadr> mit einem Offset von <bytew>.
 */
{
#if 1  /* Loesung ohne Shifts bringt auf 68000 ca. 25% */
  UBYTE crchig, crclow, *t;
  
  crchig = crclow = 0;
  while ((--memsize) >= 0) {
    t = (UBYTE *)&crc_table[ *mem ^ crchig];
    crchig = *t++ ^ crclow;
    crclow = *t;
    mem += bytew;
  };
  return( ((UWORD)crchig << 8) | (UWORD)crclow);
#else  /* Standardloesung */
  UWORD crc;

  crc = 0;
  while ((--memsize) >= 0) {
    crc = (crc << 8) ^ crc_table[ (crc >> 8) ^ *mem];
    mem += bytew;
  };
  return( crc);
#endif
} /* crc_calc */


/*------------------------------------------------------------------*/

int crc_write( UBYTE *fmem, long flen, int bytew)
/*
 | Berechnet eine 16-Bit-CRC ueber alle Bytes-2 eines ROMs
 | und schreibt sie in die letzten zwei Bytes
 */
{
  UWORD oldcrc, newcrc;
  int i;
  int modified;

  modified = FALSE;
  flen -= 2 * bytew;
  for (i = 0; i < bytew; i++, fmem++) {
    newcrc = crc_calc( fmem, flen/bytew, bytew);
    oldcrc = (((UWORD)fmem[ flen] << 8) | 
              ((UWORD)fmem[ flen+bytew]));
    if (newcrc != oldcrc) {
      modified = TRUE;
      fmem[ flen] = (UBYTE)(newcrc >> 8);
      fmem[ flen+bytew] = (UBYTE)newcrc;
    };
  };
  return( modified);
} /* crc_write */


/*------------------------------------------------------------------*/

int crc_check( UBYTE *fmem, long flen, int bytew)
/*
 | Berechnet eine 16-Bit-CRC ueber alle Bytes-2 eines ROMs
 | und vergleicht sie mit den letzten zwei Bytes
 */
{
  UWORD oldcrc, newcrc;
  int i;

  
  printf( "ROM     CRC im ROM   CRC berechnet\n");
  flen -= 2 * bytew;
  for (i = 0; i < bytew; i++, fmem++) {
    oldcrc = (((UWORD)fmem[ flen] << 8) | 
              ((UWORD)fmem[ flen+bytew]));
    printf( " %d        $%04X", i+1, oldcrc);
    newcrc = crc_calc( fmem, flen/bytew, bytew);
    printf( "          $%04X", newcrc);
    printf( "       %s\n", (newcrc == oldcrc) ? "OK" : "FEHLER");
  };
  return( TRUE);
} /* crc_check */


/*------------------------------------------------------------------*/

int usage( void)
{
  fprintf( stderr, 
"Anwendung: " PRGNAME " {Optionen} Tosdatei\n"
"           Berechnet und vergleicht die 16-Bit-CRC-PrÅfsummen, die ab\n"
"           TOS 2.x/3.x am Ende jedes 128kb ROMs zu finden sind. Das\n"
"           Programm akzeptiert Tosdateien in folgenden Formaten:\n"
"           TT (512kb, 32Bit), ST (256kb, 16Bit), gesplittet (128kb).\n"
  );
  fprintf( stderr, 
"Optionen:  -o[=Ausgabedatei]\n"
"           Korrigiert die CRCs und erzeugt Ausgabedatei\n"
"           (Vorgabe: Tosdatei neu erzeugen).\n"
  );
  return( -2);
} /* usage */


/*------------------------------------------------------------------*/

int main( int argc, char *argv[])
{
  static char *what = 
    "@(#)TOSCRC v1.0, Copyright (c)  Martin Osieka (\/), 18.12.91";
  char *args, argch;
  int arg, err;
  UBYTE *fmem;
  long flen;
  int oflag;
  char *tosfname, *outfname;
  int bytew;

  /*** Optionen verarbeiten ***/
  what = what;
  oflag = FALSE;
  outfname = NULL;
  for (arg = 1; arg < argc; arg++) {
    args = argv[ arg];
    if (*args++ != '-') break;
    while ((argch = toupper( *args++)) != '\0') {
      switch (argch) {
      case 'O': 
        oflag = TRUE; 
        if ((*args++ == '=') && (*args != '\0')) outfname = args;
        args = "";
        break;
      default:
        fprintf( stderr, PRGNAME "Fehler : Unbekannte Option '%c'!\n", argch);
        return( -1);
      };
    };
  };

  /*** Dateinamen bestimmen ***/
  if (arg + 1 != argc) return( usage());
  tosfname = argv[ arg];
  if (outfname == NULL) outfname = tosfname;
  
  /*** Datei laden, pruefen und eventuell sichern ***/
  if ((err = fileload( tosfname, &fmem, &flen)) != 0) {
    fprintf( stderr, PRGNAME ": Fehler %d beim Laden von %s!\n", err, tosfname);
  }
  else if ((flen != 0x20000L) && (flen != 0x40000L) && (flen != 0x80000L)) {
    fprintf( stderr, PRGNAME "Fehler: DateilÑnge muû 512kb, 256kb oder 128kb sein!\n");
    err = -3;
  }
  else {
    bytew = (int)(flen / 0x20000L);
    if (oflag) {
      crc_write( fmem, flen, bytew);
      if ((err = filesave( outfname, fmem, flen)) != 0) {
        fprintf( stderr, PRGNAME ": Fehler %d beim Speichern von %s!\n", err, outfname);
      }
      else {
        printf( PRGNAME ": Datei %s erzeugt.\n", outfname);
      };
    }
    else {
      crc_check( fmem, flen, bytew);
    }
  };
  filefree( fmem, flen);
  return( err);
} /* main */


/********************************************************************/
