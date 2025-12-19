/* Versionsangaben */
#define ID "$Header: LINKINFO DL6SDC/DG2SBV 1.05 930811$"
#define VERSION "LINKINFO Version 1.05 (930811) by DL6SDC, DG2SBV"
#define FILEVERS 0x100
/*static char *rcsid=ID;*/

/* Konfiguration */
/* Defines:
   a) Maschinentyp
      Entweder UNIX, MSDOS oder ATARI
   b) SEG: Schaltet auf Segmentierung. Muss auch auf Dose explizit gesetzt
      werden!
   c) NDEBUG/DEBUG: Debugging aus/an. Default ist Debug an.
      im Debug-Modus sind unter UNIX Optionen fuer die Dateinamen gestattet.
      Der Debug-Modus ist unter UNIX eine Sicherheitsluecke, so dass man
      einem Debug-Linkinfo keinesfalls set user id geben sollte!
   d) COLUMNS: Anzahl Spalten bei der Ausgabe. Default: 79
 */

#ifndef COLUMNS
#define COLUMNS 79
#endif

#ifdef NDEBUG
#ifdef DEBUG
ErRoR /* Debug und Nodebug geht nicht gleichzeitig */
#endif
#undef DEBUG
#else
#undef DEBUG /* Falls mit -DDEBUG compiliert wird */
#define DEBUG
#endif

#ifdef SEG
#define SEGMENT64K 1
#else
#define SEGMENT64K 0 /* max. 64 KB am Stueck */
#endif

#ifdef UNIX
#ifdef SEG
ErRoR /* Was ist denn ein UNIX mit 64KB-Segmenten?! */
#endif
#define MEMLIMIT   0 /* eng begrenzter Speicher -> Verwende coreleft() */
#if defined (MSDOS) || defined (ATARI)
ErRoR
#endif
#else
#define MEMLIMIT   1 /* eng begrenzter Speicher -> Verwende coreleft() */
#endif

#ifdef MSDOS
#if defined (ATARI)
ErRoR
#endif
#endif

#if !defined (UNIX) && !defined (MSDOS) && !defined (ATARI)
ErRoR
#endif

#if SEGMENT64K
#define INDIRECT 1
#else
#define INDIRECT 0
#endif

#if MEMLIMIT || SEGMENT64K
#define MEMRESV 16384
#endif

/* Includes */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <ctype.h>
#include <string.h>
#include "mygetopt.h"

#ifdef UNIX
#include <sys/types.h>
#include <sys/stat.h>
#else
#include <time.h>
#ifdef ATARI
#include <ext.h>
/* E.g. TURBO-C/Pure C */
#else
#include <sys/stat.h>
#endif
#endif

/* Defines */

#define NOT_IMPLEMENTED assert(0)

#ifdef UNIX
#define ASCII_FILENAME "/usr/local/lib/digimap.dat"
#define BIN_FILENAME "/usr/local/lib/digimap.bin"
#define INFO_TMP "/tmp/digiinfo.%d"
#else
#define ASCII_FILENAME "digimap.dat"
#define BIN_FILENAME "digimap.bin"
#define INFO_TMP "digiinfo.tmp"
#endif

#if defined(__TURBOC__) || (defined(__STDC__) && __STDC__) || defined(LATTICE)
#define _ARGS(a) a
#else
#define _ARGS(a) ()
#define const
#endif

#if INDIRECT
#define digi(a) (digitab[(a)])
#define link(a) (linktab[(a)])
#else
#define digi(a) (digitab+(a))
#define link(a) (linktab+(a))
#endif

#define infty     32767  /* Passt noch in jedes int... */

#define LINK_WIRE 9950
#define LINK_38K4 9900
#define LINK_19K2 9800
#define LINK_9K6  9700
#define LINK_4K8  9600
#define LINK_2K4  9400
#define LINK_1K2  9000
#define LINK_300  8000
#define LINK_NONE 0000

#define P_WIRE    3
#define P_38K4    6
#define P_19K2    12
#define P_9K6     18
#define P_4K8     24
#define P_2K4     37
#define P_1K2     63
#define P_300     133
#define P_NONE    infty

#define SYM_WIRE  '%'
#define SYM_38K4  '|'
#define SYM_19K2  '!'
#define SYM_9K6   '#'
#define SYM_4K8   '@'
#define SYM_2K4   '$'
#define SYM_1K2   ' '
#define SYM_300   '"'
#define SYM_NONE  '&'

#define STR_WIRE  "<Draht>"
#define STR_38K4  "<38K4>"
#define STR_19K2  "<19K2>"
#define STR_9K6   "<9K6>"
#define STR_4K8   "<4K8>"
#define STR_2K4   "<2K4>"
#define STR_1K2   "<1K2>"
#define STR_300   "<300>"
#define STR_NONE  "<>-X-<>"

#define NAME_WIRE "Draht"
#define NAME_38K4 "38400 Baud"
#define NAME_19K2 "19200 Baud"
#define NAME_9K6  "9600 Baud"
#define NAME_4K8  "4800 Baud"
#define NAME_2K4  "2400 Baud"
#define NAME_1K2  "1200 Baud"
#define NAME_300  "300 Baud"
#define NAME_NONE "Nicht in Betrieb/im Bau/geplant"

#define TYPE_USER 0 /* User, der inoffizielle Links betreibt */
#define TYPE_SATG 1 /* Sat-Gate */
#define TYPE_BBS  2 /* Mailbox */
#define TYPE_DIGI 3 /* Digipeater */
#define TYPE_CLU  4 /* DX-Cluster */
#define TYPE_WX   5 /* Wetterstation */
#define TYPE_TCP  6 /* TCP/IP-Knoten */
#define TYPE_TNC  7 /* Link-TNC */

#define MAXINFO 64

/* typedefs */

typedef struct{
  char call[7];
  short laenge;  /* 5' - Einheiten ab 180 Grad westl. nach Osten */
  short breite;  /* 2.5' - Einheiten ab 90 Grad suedl. nach Norden */
  short type;    /* Werte s.o. */
  long qrg;      /* In kHz, Bereich also 0-~2000000 MHz... */
  unsigned char num_links;
  unsigned short links;
  /*char info[MAXINFO];    /* Infofeld */
}DIGI_T;
#define FILE_DIGI_T_LENGTH 20

typedef struct{
  unsigned short neighbour;
  unsigned short pquality;
}LINK_T;
#define FILE_LINK_T_LENGTH 4

typedef struct {
  unsigned short neighbour;
  unsigned short pquality;
  short digi;
} SEARCH_T;
/* Variablen */

#ifdef ATARI
int Nowait = 0;
#endif

int Sp; /* Wird Linkinfo unter SP aufgerufen? */

int Columns = COLUMNS; /* Kann durch die Option -c geaendert werden */

#if INDIRECT
DIGI_T **digitab;
LINK_T **linktab;
#else
DIGI_T *digitab;
LINK_T *linktab;
#endif
int digis,links;

char *ascii_filename;
char *bin_filename;

FILE *ascfile;
FILE *tmp_file;
char tmpname [80];
int tmp_exists = 0;

FILE *binfile;
long info_offset;
int sorted;

/* Prototypes */

#ifdef ATARI
void my_exit _ARGS((int));
#endif
char * parse_call _ARGS((char *, char [7]));
int search_digi _ARGS((char [7]));
void dump _ARGS((void));
void alloc _ARGS((int, int));
void free_data _ARGS((void));
void load_digis _ARGS((void));
void load_links _ARGS((void));
void check_links _ARGS((void));
void countasc _ARGS((int *, int *));
int callcmp _ARGS((char *, char *));
void printcoord _ARGS((int, int));
void read_info _ARGS((char *, int));
char *asctype _ARGS((int));
char *vasctype _ARGS((int));
char *asccall _ARGS((char [7]));
char *stripstr _ARGS((char *));
char *stripcall _ARGS((char [7]));
void printloc _ARGS((short,short));
void vausgabe _ARGS((int));
void ausgabe _ARGS((int));
void compile_data _ARGS((void));
void data_info _ARGS((void));
void load_data _ARGS((void));
void find_qrg _ARGS((char *));
int info_call _ARGS((char *));
void info_prefix _ARGS((char *));
void exclude_call _ARGS((char [7], char [7], char [7]));
void exclude_link _ARGS((char [7], char [7]));
void do_exclusions _ARGS((int,char **, char *, char *));
void print_quality _ARGS((int));
void print_path _ARGS((int, SEARCH_T *));
void print_distances _ARGS((int, SEARCH_T *));
void found_route _ARGS((int, SEARCH_T *));
void find_route _ARGS((char *,char *));
void stop _ARGS((char *));
void internal _ARGS((int,char *));
void pstop _ARGS((char *));
void parse_options _ARGS((int,char **));
int asciinewer _ARGS((void));
int put_num _ARGS((FILE*,long,int));
int get_numl _ARGS((FILE*,long*,int));
int iswhitespace _ARGS((char));
void strtoupper _ARGS((char*));
int qthvalid _ARGS((char*));
int qrgvalid _ARGS((char*));
void copyright _ARGS((void));
void usage _ARGS((void));
int main _ARGS((int,char**));
int checksp _ARGS((int, char **));

#ifdef ATARI
/* Dies muss vor allen anderen Funktionen stehen. */
void my_exit (val)
{
  if (! Nowait && !system ((char *) 0)) {
    printf ("\nBeliebige Taste druecken...");
    getch ();
  }
  exit (val);
}
#define exit my_exit
#endif

char *parse_call (text, call)
char *text;
char call [7];
{
  int i;
  char *str = text;
  while (*str && iswhitespace (*str)) str ++;
  for (i = 0; i < 6 && isalnum (*str); i ++) {
    call [i] = toupper (*str);
    str ++;
  }
  if (i == 0) return text;
  while (i < 6) call [i ++] = ' ';
  if (*str == '-') {
    str ++;
    switch (toupper (*str)) {
    case '0':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      call [6] = *str - '0';
      break;
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
      call [6] = toupper (*str) - 'A' + 10;
      break;
    case '1':
      str ++;
      if (*str < '0' || *str > '5') {
	call [6] = 1;
	return str;
      }
      call [6] = *str - '0' + 10;
      break;
    default:
      return text;
    }
    str ++;
  } else {
    call [6] = 0;
  }
  return str;
}
int search_digi (call)
char call [7];
{
  if (sorted) {
    int min, max, half, cmp;
    min = 0; max = digis; /* max ausschliesslich */
    while (min < max) {
      half = (min + max) / 2;
      cmp = callcmp (digi (half) -> call, call);
      if (cmp == 0) return half;
      if (cmp < 0) {
	min = half + 1;
      } else {
	max = half;
      }
    }
  } else {
    int i;
    for (i = 0; i < digis; i ++) {
      if (!callcmp (digi (i) -> call, call)) return i;
    }
  }
  return -1;
}
void dump ()
{
  int i;
  DIGI_T *dt;
  LINK_T *lt;
  char it [MAXINFO];
  if (put_num (binfile, FILEVERS | (sorted ? 0x8000 : 0), 2) != 2)
    pstop (bin_filename);
  if (put_num (binfile, digis, 2) != 2) pstop (bin_filename);
  if (put_num (binfile, links, 2) != 2) pstop (bin_filename);
  for (i = 0; i < digis; i ++) {
    dt = digi (i);
    if (fwrite (dt -> call, sizeof (char), 7, binfile) != 7)
      pstop (bin_filename);
    if (put_num (binfile, dt -> laenge, 2) != 2) pstop (bin_filename);
    if (put_num (binfile, dt -> breite, 2) != 2) pstop (bin_filename);
    if (put_num (binfile, dt -> type, 2) != 2) pstop (bin_filename);
    if (put_num (binfile, dt -> qrg, 4) != 4) pstop (bin_filename);
    if (put_num (binfile, dt -> num_links, 1) != 1) pstop (bin_filename);
    if (put_num (binfile, dt -> links, 2) != 2) pstop (bin_filename);
  }
  for (i = 0; i < links; i ++) {
    lt = link (i);
    if (put_num (binfile, lt -> neighbour, 2) != 2) pstop (bin_filename);
    if (put_num (binfile, lt -> pquality, 2) != 2) pstop (bin_filename);
  }
  for (i = 0; i < digis; i ++) {
    if (fread (it, sizeof (char), MAXINFO, tmp_file) != MAXINFO)
      pstop (tmpname);
    if (fwrite (it, sizeof (char), MAXINFO, binfile) != MAXINFO)
      pstop (bin_filename);
  }
}
void alloc (digis, links)
int digis, links;
{
#if MEMLIMIT
#if INDIRECT
  /* if( digis*sizeof(DIGI_T) + links*sizeof(LINK_T) +
     (digis+links) * sizeof(DIGI_T*) + MEMRESV > coreleft() )
    stop("Nicht genug Speicher"); */
  /* coreleft() gibt nur die Groesse von einem Segment zurueck, also
     ist diese Bedingung zu streng. */
#else
  if( digis*sizeof(DIGI_T) + links*sizeof(LINK_T) +
     MEMRESV > coreleft() )
    stop("Nicht genug Speicher");
#endif
#endif
#if INDIRECT
  if( !(digitab = (DIGI_T **) calloc(digis, sizeof(DIGI_T *))))
    pstop(bin_filename);
  if( !(linktab = (LINK_T **) calloc(links, sizeof(LINK_T *))))
    pstop(bin_filename);
  {
    DIGI_T *hd; LINK_T *hl;
    int d, di, l, li, i;
    DIGI_T **ld; LINK_T **ll;
#if SEGMENT64K
    d=(int)((65536l - MEMRESV) / sizeof(DIGI_T));
    l=(int)((65536l - MEMRESV) / sizeof(LINK_T));
#else
    d=digis;l=links;
#endif
    for(ld = digitab, di=digis; di; di-=d){
      if(d > di) d = di;
      hd = (DIGI_T*) calloc(d, sizeof(DIGI_T));
      if(!hd) pstop(bin_filename);
      for(i=0; i<d; i++){
	*ld++=hd;
	hd++;
      }
    }
    for(ll = linktab, li=links; li; li-=l){
      if(l > li) l = li;
      hl = (LINK_T*) calloc(l, sizeof(LINK_T));
      if(!hl) pstop(bin_filename);
      for(i=0; i<l; i++){
	*ll++=hl;
	hl++;
      }
    }
  }
#else
  digitab = (DIGI_T*) calloc(digis, sizeof(DIGI_T));
  if(!digitab) pstop(bin_filename);
  linktab = (LINK_T*) calloc(links, sizeof(LINK_T));
  if(!linktab) pstop(bin_filename);
#endif
}
void free_data ()
{
#if INDIRECT
#if SEGMENT64K
  int d, l;
  int i;
  d=(int)((65536l - MEMRESV) / sizeof(DIGI_T));
  l=(int)((65536l - MEMRESV) / sizeof(LINK_T));
  for (i = 0; i < digis; i += d) {
    free (digitab [i]);
  }
  for (i = 0; i < links; i += l) {
    free (linktab [i]);
  }
#else
  free (digitab [0]);
  free (linktab [0]);
#endif
  free (digitab);
  free (linktab);
#else
  free (digitab);
  free (linktab);
#endif
  if (fclose (binfile) == EOF) pstop (bin_filename);
}
void load_digis ()
{
  int d, l;
  long line_nr;
  char prevcall [7];
  char currcall [7];
  char buf [2048];
  char *bp, *bp2;
  DIGI_T *dt;
  int i;
  sorted = 1;
  line_nr = d = l = 0;
  for (i = 0; i < 7; i ++)
    prevcall [i] = 0;
  while (fgets (buf, 2048, ascfile)) {
    line_nr ++;
    for (bp = buf; *bp && iswhitespace (*bp); bp ++)
      ;
    if (!*bp || *bp == '#') continue;
    dt = digi (d);
    d ++;
    /* Call */
    bp2 = parse_call (bp, currcall);
    if (bp2 == bp) {
      printf ("%s: Fehlerhafte Zeile Nr. %ld: Fehler im Call",
	      ascii_filename, line_nr);
      stop ("");
    } else {
      bp = bp2;
    }
    i = callcmp (prevcall, currcall) ;
    if (i > 0) {
      printf ("%s: Warnung in Zeile Nr. %ld: Zeile nicht in Sortierreihenfolge\n",
	      ascii_filename, line_nr);
      sorted = 0;
    }
    if (i == 0) {
      printf ("%s: Fehlerhafte Zeile Nr. %ld: Doppelter Digi %s",
	      ascii_filename, line_nr, stripcall (currcall));
      stop ("");
    }
    if (!sorted) {
      int i;
      for (i = 0; i < d; i ++) {
	if (!callcmp (digi (i) -> call, currcall)) {
	  printf ("%s: Fehlerhafte Zeile Nr. %ld: Doppelter Digi %s",
		  ascii_filename, line_nr, stripcall (currcall));
	  stop ("");
	}
      }
    }
    /* Call eingelesen -- umkopieren */
    for (i = 0; i < 7; i ++) dt -> call [i] = prevcall [i] = currcall [i];
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Locator */
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp == ',') {
      dt -> laenge = -1;
      dt -> breite = -1;
    } else {
      if (strlen (bp) < 6) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld",
		ascii_filename, line_nr);
	stop ("");
      }
      for (i = 0; i < 6; i ++) {
	if (bp [i] >= 'a' && bp [i] <= 'z')
	  bp [i] -= 32;
      }
      if (bp [0] < 'A' || bp [0] > 'R' ||
	  bp [1] < 'A' || bp [1] > 'R' ||
	  bp [2] < '0' || bp [2] > '9' ||
	  bp [3] < '0' || bp [3] > '9' ||
	  bp [4] < 'A' || bp [4] > 'X' ||
	  bp [5] < 'A' || bp [5] > 'X') {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Fehler im Locator",
		ascii_filename, line_nr);
	stop ("");
      }
      dt -> laenge = (bp [0] - 'A') * 240 +
	             (bp [2] - '0') * 24 +
	             (bp [4] - 'A');
      dt -> breite = (bp [1] - 'A') * 240 +
                     (bp [3] - '0') * 24 +
		     (bp [5] - 'A');
      bp += 6;
      while (*bp && iswhitespace (*bp)) bp ++;
    }
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Typ */
    while (*bp && iswhitespace (*bp)) bp ++;
    dt -> type = 0;
    while (*bp >= '0' && *bp <= '9') {
      dt -> type *= 10;
      dt -> type += *bp - '0';
      bp ++;
    }
    if (dt -> type != TYPE_USER && dt -> type != TYPE_SATG &&
	dt -> type != TYPE_BBS  && dt -> type != TYPE_DIGI &&
	dt -> type != TYPE_CLU  && dt -> type != TYPE_WX   &&
	dt -> type != TYPE_TCP  && dt -> type != TYPE_TNC     ) {
      printf ("%s: Fehlerhafte Zeile Nr. %ld: Unbekannter Typ",
	      ascii_filename, line_nr);
      stop ("");
    }
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* QRG */
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp == ',') {
      dt -> qrg = -1;
    } else {
      dt -> qrg = 0;
      while (*bp >= '0' && *bp <= '9') {
	dt -> qrg *= 10;
	dt -> qrg += *bp - '0';
	bp ++;
      }
      dt -> qrg *= 1000;
      if (*bp == '.') {
	bp ++;
	i = 1000;
	while (*bp >= '0' && *bp <= '9') {
	  if (i == 1) {
	    if (*bp >= '5') dt -> qrg ++;
	    i = 0;
	  } else {
	    i /= 10;
	    dt -> qrg += i * (*bp - '0');
	  }
	  bp ++;
	}
      }
      while (*bp && iswhitespace (*bp)) bp ++;
    }
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Dummy */
    while (*bp && *bp != ',') bp ++;
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Links -- nur zaehlen */
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp != '(') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    dt -> num_links = 0;
    while (1) {
      while (*bp && iswhitespace (*bp)) bp ++;
      if (!*bp) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	stop ("");
      }
      if (*bp == ')') break;
      if (dt -> num_links == 255) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Zu viele Links",
		ascii_filename, line_nr);
	stop ("");
      }
      dt -> num_links ++;
      while (*bp && *bp != ',' && *bp != ')') bp ++;
      if (*bp == ',') bp ++;
    }
    bp ++; /* ) ueberspringen */
    dt -> links = l;
    l += dt -> num_links;
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp != ',') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld",
	      ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Info kopieren, max. 64 Zeichen... */
    while (*bp && iswhitespace (*bp)) bp ++;
    {
      int whitespace = 0;
      char info [MAXINFO];
      i = 0;
      while (*bp && i < MAXINFO) {
	if (iswhitespace (*bp)) {
	  if (!whitespace) {
	    whitespace = 1;
	    info [i ++] = *bp;
	  }
	} else {
	  whitespace = 0;
	  info [i ++] = *bp;
	}
	bp ++;
      }
      while (i && iswhitespace (info [i - 1])) i --;
      while (i < MAXINFO) info [i ++] = 0;
      if (fwrite (info, sizeof (char), MAXINFO, tmp_file) != MAXINFO)
	pstop (tmpname);
    }
  }
  if (fseek (ascfile, 0, 0)) pstop (ascii_filename);
}
void load_links ()
{
  DIGI_T *dt;
  LINK_T *lt;
  int d, l, i, j;
  char *bp, *bp2;
  char buf [2048];
  long line_nr;
  char call [7];
  int neighbour, last_neighbour;

  line_nr = d = 0;
  while (fgets (buf, 2048, ascfile)) {
    last_neighbour = -1;
    line_nr ++;
    buf [2047] = 0;
    for (bp = buf; *bp && iswhitespace (*bp); bp ++)
      ;
    if (!*bp || *bp == '#') continue;
    dt = digi (d);
    d ++;
    for (i = 0; i < 5; i ++) {
      while (*bp && *bp != ',') bp ++;
      if (!*bp) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	stop ("");
      }
      bp ++;
    }
    while (*bp && iswhitespace (*bp)) bp ++;
    if (*bp != '(') {
      printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
      stop ("");
    }
    bp ++;
    /* Links eintragen */
    i = dt -> num_links;
    l = dt -> links;
    while (1) {
      while (*bp && iswhitespace (*bp)) bp ++;
      if (!*bp) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	stop ("");
      }
      if (*bp == ')') break;
      if (!i) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Falsche Linkangabe(n)",
		ascii_filename, line_nr);
	stop ("");
      }
      i --;
      lt = link (l);
      l ++;
      bp2 = parse_call (bp, call);
      if (bp2 == bp) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Fehler im Linkpartner",
		ascii_filename, line_nr);
	stop ("");
      } else {
	bp = bp2;
      }
      if (!callcmp (call, dt -> call)) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Link vom Digi zu sich selbst",
		ascii_filename, line_nr);
	stop ("");
      }
      neighbour = search_digi (call);
      if (neighbour < 0) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Unbekannter Linkpartner %s",
		ascii_filename, line_nr, stripcall (call));
	stop ("");
      }
      if (neighbour < last_neighbour) {
	printf ("%s: Warnung in Zeile Nr. %ld: Links nicht sortiert\n",
		ascii_filename, line_nr);
      }
      if (neighbour == last_neighbour) {
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Doppelter Linkeintrag",
		ascii_filename, line_nr);
	stop ("");
      }
      for (j = dt -> links; j < l - 1; j ++) {
	if (link (j) -> neighbour == neighbour) {
	  printf ("%s: Fehlerhafte Zeile Nr. %ld: Doppelter Linkeintrag",
		  ascii_filename, line_nr);
	  stop ("");
	}
      }
      last_neighbour = neighbour;
      lt -> neighbour = neighbour;
      while (*bp && iswhitespace (*bp)) bp ++;
      switch (*bp) {
      case SYM_WIRE:
	bp ++;
	lt -> pquality = P_WIRE;
	break;
      case SYM_38K4:
	bp ++;
	lt -> pquality = P_38K4;
	break;
      case SYM_19K2:
	bp ++;
	lt -> pquality = P_19K2;
	break;
      case SYM_9K6:
	bp ++;
	lt -> pquality = P_9K6;
	break;
      case SYM_4K8:
	bp ++;
	lt -> pquality = P_4K8;
	break;
      case SYM_2K4:
	bp ++;
	lt -> pquality = P_2K4;
	break;
      case ',':
      case ')':
	/* Sonderbehandlung: Das Zeichen fuer 1K2 ist das nichtvorhandensein
	   eines Zeichens... :-)
	 */
	lt -> pquality = P_1K2;
	break;
      case SYM_300:
	bp ++;
	lt -> pquality = P_300;
	break;
      case SYM_NONE:
	bp ++;
	lt -> pquality = P_NONE;
	break;
      default:
	printf ("%s: Fehlerhafte Zeile Nr. %ld: Falsches Linksymbol",
		ascii_filename, line_nr);
	stop ("");
      }
      while (*bp && iswhitespace (*bp)) bp ++;
      if (*bp != ',' && *bp != ')') {
	printf ("%s: Fehlerhafte Zeile Nr. %ld",
		ascii_filename, line_nr);
	stop ("");
      }
      /*while (*bp && *bp != ',' && *bp != ')') bp ++;*/
      if (*bp == ',') bp ++;
    }
  }
}
void check_links ()
{
  int d;
  int l;
  int i, j, k;
  int n;
  DIGI_T *dt1, *dt2;
  LINK_T *lt;
  for (d = 0; d < digis; d ++) {
    dt1 = digi (d);
    i = dt1 -> num_links;
    for (l = dt1 -> links; i; i --, l ++) {
      lt = link (l);
      n = lt -> neighbour;
      dt2 = digi (n);
      k = dt2 -> num_links;
      for (j = dt2 -> links; k; j ++, k --) {
	if (link (j) -> neighbour == d) break;
      }
      if (!k) {
	printf ("%s", stripcall (dt1 -> call));
	printf (" --> %s besitzt keinen Rueckweg", stripcall (dt2 -> call));
	stop ("");
      }
      if (link (j) -> pquality != lt -> pquality) {
	printf ("%s", stripcall (dt1 -> call));
	printf (" <--> %s hat verschieden schnelle Wege",
		stripcall (dt2 -> call));
	stop ("");
      }
    }
  }
}
void countasc (digis, links)
int *digis, *links;
{
  int d, l;
  char buf [2048];
  char *bp;
  long line_nr;
  line_nr=0;
  l = d = 0;
  while (fgets (buf, 2048, ascfile)) {
    line_nr ++;
    buf [2047] = 0;
    for (bp = buf; *bp && iswhitespace (*bp); bp ++)
      ;
    if (*bp && *bp != '#') {
      int c;
      d ++;
      for (c = 0; c < 5; c ++) {
	while (*bp && *bp != ',') bp ++;
	if (!*bp) {
	  printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	  stop ("");
	}
	bp ++;
      }
      while (*bp && iswhitespace (*bp)) bp ++;
      if (*bp != '(') {
	printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	stop ("");
      }
      bp ++;
      /* Links zaehlen */
      while (1) {
	while (*bp && iswhitespace (*bp)) bp ++;
	if (!*bp) {
	  printf ("%s: Fehlerhafte Zeile Nr. %ld", ascii_filename, line_nr);
	  stop ("");
	}
	if (*bp == ')') break;
	l ++;
	while (*bp && *bp != ',' && *bp != ')') bp ++;
	if (*bp == ',') bp ++;
      }
    }
  }
  *digis = d;
  *links = l;
  if (fseek (ascfile, 0, 0)) pstop (ascii_filename);
}
int callcmp (call1, call2)
char *call1, *call2;
{
  int i;
  for (i = 0; i < 7; i ++) {
    if (call1 [i] > call2 [i]) return 1;
    if (call1 [i] < call2 [i]) return -1;
  }
  return 0;
}
void printcoord (laenge, breite)
int laenge, breite;
{
  int gr_nord, min_nord, sued_p;
  int gr_ost, min_ost, west_p;
  gr_nord = -90 + breite / 24;
  min_nord = gr_nord * 60 + ((breite % 24) * 5) / 2;
  sued_p=min_nord<0;
  if(sued_p){
    min_nord=-min_nord;
    if(min_nord%5){
      if(min_nord%5==3)min_nord--;
    }
  }
  gr_ost = -180 + laenge / 12;
  min_ost= gr_ost * 60 + (laenge % 12) * 5;
  west_p=min_ost<0;
  if(west_p){
    min_ost=-min_ost;
  }
  printf ("%d Grad, %d", min_nord / 60 , min_nord % 60);
  if (min_nord % 5) printf (".5");
  printf(" Minuten %s, %d Grad, %d Minuten %s",
	 (sued_p?"Sued":"Nord"), min_ost/60, min_ost%60,
	 (west_p?"West":"Ost"));
}
void read_info (buf, index)
char *buf;
int index;
{
  if (fseek (binfile, (long) info_offset + MAXINFO * (long) index, 0))
    pstop (bin_filename);
  if (fread (buf, sizeof (char), MAXINFO, binfile) != 64)
    pstop (bin_filename);
  buf [MAXINFO] = 0;
}
char *asctype (nr)
int nr;
{
  switch (nr) {
  case TYPE_USER:
    return "User";
  case TYPE_SATG:
    return "SAT ";
  case TYPE_BBS:
    return "BBS ";
  case TYPE_DIGI:
    return "Digi";
  case TYPE_CLU:
    return "DXCl";
  case TYPE_WX:
    return "WX  ";
  case TYPE_TCP:
    return "TCP ";
  case TYPE_TNC:
    return "TNC ";
  default:
    stop ("Unbekannter Knotentyp");
    return 0;
  }
}
char *vasctype (nr)
int nr;
{
  switch (nr) {
  case TYPE_USER:
    return "User";
  case TYPE_SATG:
    return "SAT-Gate";
  case TYPE_BBS:
    return "BBS";
  case TYPE_DIGI:
    return "Digipeater";
  case TYPE_CLU:
    return "DX-Cluster";
  case TYPE_WX:
    return "Wetterstation";
  case TYPE_TCP:
    return "TCP/IP-Knoten";
  case TYPE_TNC:
    return "Link-TNC";
  default:
    stop ("Unbekannter Knotentyp");
    return 0;
  }
}
char *asccall (call)
char call [7];
{
  static char asc [10];
  int i;
  for (i = 0; i < 6 && call [i] != ' '; i++) {
    asc [i] = call [i];
  }
  if (call [6]) {
    asc [i ++] = '-';
    if (call [6] > 9) asc [i ++] = '1';
    asc [i ++] = '0' + call [6] % 10;
  }
  while (i<9) asc [i ++] = ' ';
  asc [i] = 0;
  return asc;
}
char *stripstr (text)
char *text;
{
  char *str = text;
  while (*str && !iswhitespace (*str)) str ++;
  *str = 0;
  return text;
}
char *stripcall (call)
char call [7];
{
  return stripstr (asccall (call));
}
void printloc (laenge, breite)
short laenge, breite;
{
  printf ("%c%c%c%c%c%c", 'A' + laenge / 240, 'A' + breite / 240,
	  '0' + (laenge / 24) % 10, '0' + (breite / 24) % 10,
	  'A' + laenge % 24, 'A' + breite % 24);
}
void vausgabe(index)
int index;
{
  DIGI_T *x;
  char *call;
  char info [MAXINFO + 1];
  int i;
  int infocolumns;

  x = digi (index);
  call = stripcall (x -> call);
  printf ("Call: %s\n", call);
  printf ("Locator: ");
  if (x -> laenge < 0 || x -> breite < 0) {
    printf ("unbekannt");
  } else {
    printloc (x -> laenge, x -> breite);
    printf (" = ");
    printcoord (x -> laenge, x -> breite);
  }
  if (x -> qrg < 0) {
    printf ("\nQRG: unbekannt\nTyp: %s\n", vasctype (x -> type));
  } else {
    printf ("\nQRG: %4ld.%03ld\nTyp: %s\n", x -> qrg / 1000, x -> qrg % 1000,
	    vasctype (x -> type));
  }
  read_info (info, index);
  infocolumns = Columns - 6;
  if (infocolumns > MAXINFO) infocolumns = MAXINFO;
  info [infocolumns] = 0;
  printf ("Info: %s\n", info);
  if (x -> num_links) {
    LINK_T *l;
    printf ("Links:\n");
    for (i = 0; i < x -> num_links; i ++){
      l = link (x -> links + i);
      printf ("    %s  ", asccall (digi (l -> neighbour) -> call));
      switch (l -> pquality) {
      case P_WIRE:
	printf (NAME_WIRE);
	break;
      case P_38K4:
	printf (NAME_38K4);
	break;
      case P_19K2:
	printf (NAME_19K2);
	break;
      case P_9K6:
	printf (NAME_9K6);
	break;
      case P_4K8:
	printf (NAME_4K8);
	break;
      case P_2K4:
	printf (NAME_2K4);
	break;
      case P_1K2:
	printf (NAME_1K2);
	break;
      case P_300:
	printf (NAME_300);
	break;
      case P_NONE:
	printf (NAME_NONE);
	break;
      default:
	stop ("Unbekannter Linktyp");
      }
      printf("\n");
    }
  }
}
void ausgabe(index)
int index;
{
  DIGI_T *x;
  char info [MAXINFO + 1];
  int infocolumns;
  x = digi(index);
  printf ("%s", asccall (x -> call));
  printf (" ");
  if (x -> laenge < 0 || x -> breite < 0) {
    printf ("      ");
  } else {
    printloc (x -> laenge, x -> breite);
  }
  if (x -> qrg < 0) {
    printf ("          ");
  } else {
    printf (" %4ld.%03ld ", x -> qrg / 1000, x -> qrg % 1000);
  }
  printf ("%s", asctype (x -> type));
  printf (" %2d  ", x -> num_links);
  /* Info einlesen */
  read_info (info, index);
  infocolumns = Columns - 35;
  if (infocolumns > MAXINFO) infocolumns = MAXINFO;
  info [infocolumns] = 0;
  printf ("%s\n", info);
}
void compile_data()
{
#ifdef UNIX
  sprintf (tmpname, INFO_TMP, getpid ());
#else
  strcpy (tmpname, INFO_TMP);
#endif
  printf ("Compilieren der Daten...\n");
  if ((ascfile = fopen (ascii_filename, "r")) == 0) pstop (ascii_filename);
#ifdef DEBUG
  printf ("Schritt 1\n");
#endif
  countasc (&digis, &links);
#ifdef DEBUG
  printf ("%d Digis, %d Links\nSchritt 2\n", digis, links);
#endif
  alloc (digis, links);
  if ((tmp_file = fopen (tmpname, "wb")) == 0) pstop (tmpname);
  tmp_exists = 1;
  load_digis ();
  if (fclose (tmp_file) == EOF) pstop (tmpname);
#ifdef DEBUG
  printf ("Schritt 3\n");
#endif
  load_links ();
#ifdef DEBUG
  printf ("Schritt 4\n");
#endif
  check_links ();
  if ((binfile = fopen (bin_filename, "wb")) == 0) pstop (bin_filename);
  if ((tmp_file = fopen (tmpname, "rb")) == 0) pstop (tmpname);
  dump ();
  if (fclose (tmp_file) == EOF) pstop (tmpname);
  tmp_exists = 0;
  if (unlink (tmpname)) pstop (tmpname);
  free_data ();
  printf ("\n");
  if (fclose (ascfile) == EOF) pstop (ascii_filename);
}
void data_info()
{
  long version, digis, links;
  int sorted;
  if((binfile = fopen(bin_filename, "rb")) == NULL) pstop(bin_filename);
  if(get_numl(binfile, &version, 2) != 2) pstop(bin_filename);
  sorted = (version & 0x8000) != 0;
  version &= 0x7fff;
  if(get_numl(binfile, &digis, 2) != 2) pstop(bin_filename);
  if(get_numl(binfile, &links, 2) != 2) pstop(bin_filename);
  printf("Datenfile %s\n", bin_filename);
  printf("Version %2ld.%01ld%01ld (%s), ", (version>>8)&255, (version>>4)&15,
	 version&15, sorted ? "sortiert" : "unsortiert");
  printf("%ld Digis, %ld Links\n\n", digis, links);
  if (fclose (binfile) == EOF) pstop (bin_filename);
}
void load_data()
{
  long version;
  int i;
  long tmp;
  if(asciinewer()){
    compile_data();
  }
  if((binfile = fopen(bin_filename,"rb")) == NULL) {
    pstop(bin_filename);
  }
  if(get_numl(binfile, &version, 2) != 2) pstop(bin_filename);
  sorted = (version & 0x8000) != 0;
  version &= 0x7fff;
  if(version>FILEVERS){
    printf("%s", bin_filename);
    stop(": Unbekannte Version");
  }
  if(get_numl(binfile,&tmp,2) != 2) pstop(bin_filename);
  digis = (int) tmp;
  if(get_numl(binfile,&tmp,2) != 2) pstop(bin_filename); 
  links = (int) tmp;
  if((long) digis > 32767 || (long) links > 32767){
    printf("%s", bin_filename);
#ifdef DEBUG
    stop(": digis>32767 || links>32767");
#else
    stop(": Fehlerhafte Datei");
#endif
  }
  if(fseek(binfile, 0l, 2)) pstop(bin_filename);
  if(ftell(binfile) != 6l + (long) digis*(FILE_DIGI_T_LENGTH+MAXINFO) +
                       (long) links*FILE_LINK_T_LENGTH){
    printf("%s", bin_filename);
#ifdef DEBUG
    stop(": Falsche Dateilaenge");
#else
    stop(": Fehlerhafte Datei");
#endif
  }
  if(fseek(binfile, 6l, 0)) pstop(bin_filename);
  alloc (digis, links);
  /* Digis laden */
  for(i=0;i<digis;i++){
    if(fread(digi(i)->call, sizeof(char), 7, binfile) != 7)
      pstop(bin_filename);
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    digi(i)->laenge = tmp;
    if(tmp>(360*12) && tmp != 0x0000ffffl){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": laenge");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    digi(i)->breite = tmp;
    if(tmp>(180*24) && tmp != 0x0000ffffl){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": breite");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    digi(i)->type = tmp;
    if (tmp != TYPE_USER && tmp != TYPE_SATG &&
	tmp != TYPE_BBS  && tmp != TYPE_DIGI &&
	tmp != TYPE_CLU  && tmp != TYPE_WX   &&
	tmp != TYPE_TCP  && tmp != TYPE_TNC     ){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": type");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
    if(get_numl(binfile, &tmp, 4) != 4) pstop(bin_filename);
    digi(i)->qrg = tmp;
    if(get_numl(binfile, &tmp, 1) != 1) pstop(bin_filename);
    digi(i)->num_links = tmp;
    if(tmp>links){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": num_links");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    digi(i)->links = tmp;
    if(tmp+digi(i)->num_links > links){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": links+num_links > links gesamt");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
  }
  for(i=0; i<links; i++){
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    link(i)->neighbour = tmp;
    if(tmp >= digis){
      printf("%s", bin_filename);
#ifdef DEBUG
      stop(": neighbour");
#else
      stop(": Fehlerhafte Datei");
#endif
    }
    if(get_numl(binfile, &tmp, 2) != 2) pstop(bin_filename);
    link(i)->pquality = tmp;
  }
  info_offset=ftell(binfile);
}
void find_qrg(qrgstr)
char *qrgstr;
{
  /* Lineares Durchsuchen der Digi-Liste... */
  int i;
  long qrg;
  int found;
  printf("Call       Loc      QRG   Typ  Lks Info\n");
  /* Zuerst parsen der qrg... */
  qrg=0;
  while (*qrgstr && iswhitespace(*qrgstr)) qrgstr++;
  qrg=0;
  while (*qrgstr && *qrgstr>='0' && *qrgstr<='9') {
    qrg *= 10;
    qrg += *qrgstr - '0';
    qrgstr ++;
  }
  qrg *= 1000; /* Das waren die MHz */
  /* Nun ist ein Dezimalpunkt erlaubt. */
  if (*qrgstr == '.') {
    int faktor=1000;
    /* Kilohertz einlesen */
    qrgstr ++;
    while (*qrgstr >= '0' && *qrgstr <= '9') {
      if (faktor==1) {
	/* Runden */
	if (*qrgstr >= '5') qrg++;
	break;
      } else {
	faktor /= 10;
	qrg += faktor * (*qrgstr - '0');
      }
      qrgstr ++;
    }
  }
  found = 0;
  for (i = 0; i < digis; i ++) {
    if (digi(i) -> qrg == qrg) {
      ausgabe(i);
      found ++;
    }
  }
  if (!found) {
    printf("\nKein Digi mit der angegebenen QRG gefunden.\n\n");
  } else {
    if (found == 1) {
      printf ("\n1 Digi gefunden.\n\n");
    } else {
      printf("\n%d Digis gefunden.\n\n", found);
    }
  }
}
int info_call(callstr)
char *callstr;
/* Return: 0=OK, Call gefunden, sonst nicht gefunden */
{
  char call[7];
  int i;
  char *bp;
  /* Call parsen */
  bp = parse_call (callstr, call);
  if (bp == callstr) {
    stop ("Fehler in Rufzeichenangabe");
  } else {
    callstr = bp;
  }
  while (*callstr) {
    if (!iswhitespace (*callstr)) stop ("Fehler in Rufzeichenangabe");
    callstr ++;
  }
  i = search_digi (call);
  if (i < 0) {
    return 1;
  } else {
    vausgabe (i);
    printf ("\n");
    return 0;
  }
}
void info_prefix(prefix)
char *prefix;
{
  char pr[7];
  int i, found;
  int len;
  int header_printed = 0;
  char *bp;
  /* Prefix parsen */
  if (!*prefix) {
    /* Sonderfall: ALLE Digis listen */
    for (i = 0; i < 6; i ++) pr [i] = ' ';
    pr [6] = 0;
  } else {
    bp = parse_call (prefix, pr);
    if (bp == prefix) {
      stop ("Fehler in Rufzeichenangabe");
    } else {
      prefix = bp;
    }
    while (*prefix) {
      if (!iswhitespace (*prefix)) stop ("Fehler in Rufzeichenangabe");
      prefix ++;
    }
  }
  for (len = 0; len < 6 && pr [len] != ' '; len ++)
    ;
  found = 0;
  for (i = 0; i < digis; i ++) {
    int j; DIGI_T *d;
    d = digi (i);
    for (j = 0; j < len; j ++) {
      if (pr [j] != d -> call [j]) break;
    }
    if (j == len) {
      if (!header_printed) {
	printf("Call       Loc      QRG   Typ  Lks Info\n");
	header_printed = 1;
      }
      ausgabe (i);
      found ++;
    }
  }
  if (!found) {
    printf("Call/Praefix nicht gefunden.\n\n");
  } else {
    if (found == 1) {
      printf ("\n1 Digi gefunden.\n\n");
    } else {
      printf("\n%d Digis gefunden.\n\n", found);
    }
  }
}
void exclude_call (call, src, dest)
char call [7], src [7], dest [7];
{
  int d, d2, i, j, k, l;
  if (!callcmp (call, src)) stop ("Ausschluss des 1. Calls unmoeglich");
  if (!callcmp (call, dest)) stop ("Ausschluss des 2. Calls unmoeglich");
  d = search_digi (call);
  if (d < 0) {
    printf ("Digi %s nicht gefunden", stripcall (call));
    stop ("");
  }
  for (i = digi (d) -> links, j = i + digi(d) -> num_links;
       i < j; i ++) {
    link (i) -> pquality = infty;
    d2 = link (i) -> neighbour;
    for (k = digi (d2) -> links, l = k + digi (d2) -> num_links;
	 k < l; k ++) {
      if (link (k) -> neighbour == d) {
	link (k) -> pquality = infty;
	break;
      }
    }
    if (k == l) stop ("Inkonsistenz in Datendatei");
  }
}
void exclude_link (call1, call2)
char call1 [7], call2 [7];
{
  int d1, d2, i, j;
  d1 = search_digi (call1);
  if (d1 < 0) {
    printf ("Digi %s nicht gefunden", stripcall (call1));
    stop ("");
  }
  d2 = search_digi (call2);
  if (d2 < 0) {
    printf ("Digi %s nicht gefunden", stripcall (call2));
    stop ("");
  }
  for (i = digi (d1) -> links, j = i + digi (d1) -> num_links;
       i < j; i ++) {
    if (link (i) -> neighbour == d2) {
      link (i) -> pquality = infty;
      break;
    }
  }
  if (i == j) {
    printf ("Link %s", stripcall (call1));
    printf ("/%s nicht gefunden", stripcall (call2));
    stop ("");
  }
  for (i = digi (d2) -> links, j = i + digi (d2) -> num_links;
       i < j; i ++) {
    if (link (i) -> neighbour == d1) {
      link (i) -> pquality = infty;
      break;
    }
  }
  if (i == j)
    stop ("Inkonsistenz in Datendatei");
}
void do_exclusions (num, list, src, dest)
int num;
char **list;
char *src, *dest;
{
  int i;
  char *bp1, *bp2;
  char call1 [7], call2 [7], srccall [7], destcall [7];
  bp1 = src;
  bp2 = parse_call (bp1, srccall);
  if (bp1 == bp2) stop ("Fehler im 1. Call");
  while (*bp2 && iswhitespace (*bp2)) bp2 ++;
  if (*bp2) stop ("Fehler im 1. Call");
  bp1 = dest;
  bp2 = parse_call (bp1, destcall);
  if (bp1 == bp2) stop ("Fehler im 2. Call");
  while (*bp2 && iswhitespace (*bp2)) bp2 ++;
  if (*bp2) stop ("Fehler im 2. Call");
  for (i = 0; i < num; i ++) {
    bp1 = list [i];
    bp2 = parse_call (bp1, call1);
    if (bp1 == bp2) stop ("Fehler im Ausschluss: Call falsch");
    bp1 = bp2;
    while (*bp1 && iswhitespace (*bp1)) bp1 ++;
    if (*bp1 && *bp1 != '/') stop ("Fehler im Ausschluss");
    if (*bp1 == '/') {
      bp1 ++;
      bp2 = parse_call (bp1, call2);
      if (bp2 == bp1) stop ("Fehler im Ausschluss: Call falsch");
      while (*bp2 && iswhitespace (*bp2)) bp2 ++;
      if (*bp2) stop ("Fehler im Ausschluss");
      exclude_link (call1, call2);
    } else {
      exclude_call (call1, srccall, destcall);
    }
  }
}
void print_quality (qual)
int qual;
{
  int percent;
  percent = 10000;
  if (qual < 0) internal (5, "qual < 0");
  while (qual >= 6) {
    percent = (int) ((99l * percent + 50l) / 100);
    qual -= 6;
  }
  if (qual >= 3) {
    percent = (int) ((199l * percent + 100l) / 200);
    qual -= 3;
  }
  while (qual > 0) {
    percent = (int) ((19966l * percent + 10000l) / 20000l);
    qual --;
  }
  printf ("Qualitaet: %d %%\n", (percent + 50) / 100);
}
void print_path (n, tab)
int n;
SEARCH_T *tab;
{
  int qual;
  int col;
  char buf [10];
  printf ("Pfad: ");
  col = 6;
  while (n) {
    if (n < 0) internal (4, "n < 0");
    sprintf (buf, "%s", stripcall (digi (tab [n] . digi & 0x7fff) -> call));
    if (col + strlen (buf) > Columns) {
      printf ("\n      "); col = 6;
    }
    printf ("%s", buf);
    col += strlen (buf);
    qual = tab [n] . pquality;
    n = tab [n] . neighbour;
    qual -= tab [n] . pquality;
    switch (qual) {
    case P_WIRE:
      sprintf (buf, "%s", STR_WIRE);
      break;
    case P_38K4:
      sprintf (buf, "%s", STR_38K4);
      break;
    case P_19K2:
      sprintf (buf, "%s", STR_19K2);
      break;
    case P_9K6:
      sprintf (buf, "%s", STR_9K6);
      break;
    case P_4K8:
      sprintf (buf, "%s", STR_4K8);
      break;
    case P_2K4:
      sprintf (buf, "%s", STR_2K4);
      break;
    case P_1K2:
      sprintf (buf, "%s", STR_1K2);
      break;
    case P_300:
      sprintf (buf, "%s", STR_300);
      break;
    case P_NONE:
      sprintf (buf, "%s", STR_NONE);
      break;
    default:
      internal (3, "Pathtrace: Linktype");
    }
    if (col + strlen (buf) > Columns) {
      printf ("\n      "); col = 6;
    }
    printf ("%s", buf);
    col += strlen (buf);
  }
  printf ("%s\n", stripcall (digi (tab [0].digi & 0x7fff) -> call));
}
void print_distances (n, tab)
int n;
SEARCH_T *tab;
{
  n = n; tab = tab;
}
void found_route (n, tab)
int n;
SEARCH_T *tab;
{
  printf ("Link gefunden:\n\n");
  print_quality (tab [n] . pquality);
  print_path (n, tab);
  print_distances (n, tab);
  printf ("\n");
}
void find_route(src,dest)
char *src, *dest;
{
  SEARCH_T *searchtab;
  int searched_digis;
  int w; /* Working digi */
  char srccall [7], destcall [7];
  char *bp;
  int dsrc, ddest;
  if ((searchtab = calloc (digis, sizeof (SEARCH_T))) == 0)
    stop ("Nicht genug Speicher");
  searched_digis = 0;
  bp = parse_call (src, srccall);
  if (bp == src) stop ("Fehler im 1. Call");
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp) pstop ("Fehler im 1. Call");
  bp = parse_call (dest, destcall);
  if (bp == dest) stop ("Fehler im 2. Call");
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp) pstop ("Fehler im 2. Call");
  dsrc = search_digi (srccall);
  if (dsrc < 0) {
    printf ("Digi %s nicht gefunden", stripcall (srccall));
    stop ("");
  }
  ddest = search_digi (destcall);
  if (ddest < 0) {
    printf ("Digi %s nicht gefunden", stripcall (destcall));
    stop ("");
  }
  searchtab [0].digi = ddest;
  searchtab [0].pquality = 0;
  searched_digis = 1;
  w = 0;
  while (1) {
    /* Algorithmus durchfuehren */
    {
      /* Vom Working Digi aus alle Links eintragen */
      int li, lj, si;
      unsigned int qual;
      qual = searchtab [w] . pquality;
      for (li = digi(searchtab [w] . digi & 0x7fff) -> links,
	   lj = li + digi(searchtab [w] . digi & 0x7fff) -> num_links;
	   li < lj; li ++) {
	if (qual + link (li) -> pquality >= infty) continue;
	for (si = 0; si < searched_digis; si ++) {
	  if (searchtab [si] . digi == link (li) -> neighbour) {
	    if (searchtab [si] . pquality > qual + link (li) -> pquality) {
	      searchtab [si] . pquality = qual + link (li) -> pquality;
	      searchtab [si] . neighbour = w;
	    }
	    break;
	  }
	  if ((searchtab [si] . digi & 0x7fff) == link (li) -> neighbour)
	    break;
	}
	if (si == searched_digis) {
	  /* Neu eintragen */
	  searchtab [si] . digi = link (li) -> neighbour;
	  searchtab [si] . pquality = qual + link (li) -> pquality;
	  searchtab [si] . neighbour = w;
	  searched_digis ++;
	}
      }
    }
    {
      /* Naechsten Working Digi bestimmen */
      int min_qual = infty;
      int wi;
      w = -1;
      for (wi = 0; wi < searched_digis; wi ++) {
	if ((searchtab [wi] . digi & 0x8000) == 0 &&
	    searchtab [wi] . pquality < min_qual) {
	  w = wi;
	  min_qual = searchtab [wi] . pquality;
	}
      }
      if (min_qual == infty) {
	printf ("Kein Link zwischen %s", stripcall (srccall));
	printf (" und %s gefunden.\n\n", stripcall (destcall));
	return;
      }
      if (searchtab [w] . digi == dsrc) {
	found_route (w, searchtab);
	return;
      }
      searchtab [w] . digi |= 0x8000;
    }
  }
}

void stop(str)
char *str;
{
  printf("%s\n\n",str);
  if (tmp_exists) unlink (tmpname);
  exit(0);
}
void internal(num,str)
int num;
char *str;
{
  printf("Interner Fehler #%d: %s\n",num,str);
  printf("Bitte an dl6sdc mit Angabe des Rechnertyps, Betriebssystems,\n");
  printf("Programmversion, und woher Sie das Programm haben, usw. melden\n");
  printf("Dann wird der Fehler einigermassen schnell korrigiert :-)\n\n");
  if (tmp_exists) unlink (tmpname);
  exit(0);
}
void pstop(str)
char *str;
{
  perror(str);
  printf("\n");
  if (tmp_exists) unlink (tmpname);
  exit(0);
}
void parse_options(argc,argv)
int argc;
char **argv;
{
#ifdef DEBUG
#ifdef ATARI
#define OPTSTR "a:b:c:hn"
#else
#define OPTSTR "a:b:c:h"
#endif
#else /* DEBUG */
#ifdef ATARI
#define OPTSTR "c:hn"
#else
#define OPTSTR "c:h"
#endif
#endif /* DEBUG */
  char c;
#ifdef DEBUG
  int asc_set = 0;
  int bin_set = 0;
#endif
#ifdef ATARI
  int nowait_set = 0;
#endif
  int col_set = 0;
#if defined (DEBUG) || !defined(UNIX)
  ascii_filename=getenv("ASC_FILE");
  bin_filename=getenv("BIN_FILE");
#else
  ascii_filename=0;
  bin_filename=0;
#endif
  if( !ascii_filename || !*ascii_filename ) ascii_filename=ASCII_FILENAME;
  if( !bin_filename || !*bin_filename ) bin_filename=BIN_FILENAME;
#ifdef DEBUG
  while((c=my_getopt(argc,argv, OPTSTR))!=EOF){
    switch(c){
    case 'a':
      if (asc_set) stop ("-a: Doppelte Angabe");
      asc_set = 1;
      ascii_filename=Optarg;
      break;
    case 'b':
      if (bin_set) stop ("-b: Doppelte Angabe");
      bin_set = 1;
      bin_filename=Optarg;
      break;
    case 'c':
      if (col_set) stop ("-c: Doppelte Angabe");
      col_set = 1;
      Columns = 0;
      while (*Optarg && iswhitespace (*Optarg)) Optarg ++;
      while (*Optarg >= '0' && *Optarg <= '9') {
	Columns *= 10;
	Columns += *Optarg ++ - '0';
	if (Columns >= 1000) stop ("-c: Zu grosse Spaltenzahl");
      }
      while (*Optarg && iswhitespace (*Optarg)) Optarg ++;
      if (*Optarg) stop ("-c: Fehler bei der Angabe der Spaltenzahl");
      break;
#ifdef ATARI
    case 'n':
      if (nowait_set) stop ("-n: Doppelte Angabe");
      nowait_set = 1;
      Nowait = 1;
      break;
#endif
    default:
      usage();
      exit(0);
    }
  }
#else
  while ((c = my_getopt (argc, argv, OPTSTR)) != EOF) {
    switch (c) {
    case 'c':
      if (col_set) stop ("-c: Doppelte Angabe");
      col_set = 1;
      Columns = 0;
      while (*Optarg && iswhitespace (*Optarg)) Optarg ++;
      while (*Optarg >= '0' && *Optarg <= '9') {
	Columns *= 10;
	Columns += *Optarg ++ - '0';
	if (Columns >= 1000) stop ("-c: Zu grosse Spaltenzahl");
      }
      while (*Optarg && iswhitespace (*Optarg)) Optarg ++;
      if (*Optarg) stop ("-c: Fehler bei der Angabe der Spaltenzahl");
      break;
#ifdef ATARI
    case 'n':
      if (nowait_set) stop ("-n: Doppelte Angabe");
      nowait_set = 1;
      Nowait = 1;
      break;
#endif
    default:
      usage();
      exit(0);
    }
  }
#endif
  if (Columns < 39) stop ("-c: Spaltenzahl zu gering (min. 39)");
}
int asciinewer()
{
  struct stat statbuf;
  time_t asctime,bintime;
  int ascvalid,binvalid;

  if(stat(ascii_filename,&statbuf)){
    ascvalid=0;
  }else{
    ascvalid=1;
    asctime=statbuf.st_mtime;
  }
  if(stat(bin_filename,&statbuf)){
    binvalid=0;
  }else{
    binvalid=1;
    bintime=statbuf.st_mtime;
  }
  if(!ascvalid && !binvalid){
    stop("Datenfiles fehlen!");
  }
  if(!binvalid)return 1;
  if(!ascvalid)return 0;
  return asctime>=bintime;
}
int put_num(stream, num, bytes)
FILE *stream;
long num;
int bytes;
{
  int i;
  for(i=0;i<bytes;i++){
    if(putc((int) (num&255),stream)==EOF)return i;
    num>>=8;
  }
  return i;
}
int get_numl(stream, num, bytes)
FILE *stream;
long *num;
int bytes;
{
  int i,c;
  for(i=0,*num=0;i<bytes;i++){
    if((c=getc(stream))==EOF)return i;
    *num|=((long) c&255l)<<(8*i);
  }
  return i;
}
int iswhitespace(ch)
char ch;
{
  if(ch=='\t'||ch=='\n'||ch=='\r'||ch==' ')return 1;
  return 0;
}
void strtoupper(str)
char *str;
{
  while(*str){
    if(*str>='a'&&*str<='z')*str-=32;
    str++;
  }
}
int qthvalid(str)
char *str;
{
  strtoupper(str);
  while(iswhitespace(*str))str++;
  if(*str<'A'||*str>'R')return 0;
  str++;
  if(*str<'A'||*str>'R')return 0;
  str++;
  if(*str<'0'||*str>'9')return 0;
  str++;
  if(*str<'0'||*str>'9')return 0;
  str++;
  if(*str<'A'||*str>'X')return 0;
  str++;
  if(*str<'A'||*str>'X')return 0;
  str++;
  while(*str){
    if(!iswhitespace(*str))return 0;
    str++;
  }
  return 1;
}
int qrgvalid(str)
char *str;
{
  while(iswhitespace(*str))str++;
  while(*str&&!iswhitespace(*str)&&*str!='.'){
    if(*str<'0' || *str>'9') return 0;
    str++;
  }
  if(*str=='.'){
    str++;
    while(*str&&!iswhitespace(*str)){
      if(*str<'0' || *str>'9') return 0;
      str++;
    }
  }
  while(*str){
    if(!iswhitespace(*str)) return 0;
    str++;
  }
  return 1;
}
void copyright()
{
#ifdef DEBUG
  printf ("\n%s -- Debug-Version\n\n", VERSION);
#else
  printf("\n%s\n\n",VERSION);
#endif
}
void usage()
{
#ifdef DEBUG
  printf("Anleitung: LINKINFO {Optionen} Befehl\n\n");
  printf("Optionen: -a <Ascii-Dateiname>   Waehlt den Namen der ASCII-Datei aus\n");
  printf("          -b <Bin-Dateiname>     Waehlt den Namen der internen Binaerdatei aus\n");
  printf("          -c <Spaltenzahl>       Umbruch nach angegebener Spaltenzahl\n");
  printf("                                 (Default: %d)\n", COLUMNS);
#ifdef ATARI
  if (!Sp) {
    printf("          -n                     Am Ende nicht auf Taste warten\n");
  }
#endif
  printf("          -h                     Zeigt diese Hilfe an\n\n");
  printf("Standard:\n");
  printf("   ASCII=%s, Binaer=%s\n", ASCII_FILENAME, BIN_FILENAME);
  printf("Aktuelle Einstellung:\n");
  printf("   ASCII=%s, Binaer=%s\n\n", ascii_filename, bin_filename);
#else
  printf ("Anleitung: LINKINFO {Optionen} Befehl\n\n");
  printf ("Optionen: -c <Spaltenzahl>       Umbruch nach angegebener Spaltenzahl\n");
  printf ("                                 (Default: %d)\n", COLUMNS);
#ifdef ATARI
  if (!Sp) {
    printf("          -n                     Am Ende nicht auf Taste warten\n");
  }
#endif
  printf ("          -h                     Zeigt diese Hilfe an\n\n");
#endif
  printf("Befehl: <call>               Info ueber Call ausgeben\n");
  printf("        <praefix>            Calls zu Praefix ausgeben\n");
  printf("        <QRG>                Calls zu QRG ausgeben\n");
  printf("        <Locator>            Locator in Grad umrechnen\n");
  printf("        <1> <2> {Ausschluss} Pfad zwischen <1> und <2> mit Ausschluessen\n\n");
  printf("Ausschluss: Nahezu beliebig viele Angaben der folgenden Art:\n");
  printf("        <call>          Route nicht ueber call\n");
  printf("        <call1>/<call2> (Schraegstrich, aber KEIN Leerzeichen dazwischen)\n");
  printf("                        Nicht ueber den Link call1<-->call2\n\n");
  printf ("Linkinfo ist freie Software, unter den Bedingungen, die in\n");
  printf ("LICENCE beschrieben sind.\n");
  printf ("Die Autoren uebernehmen keine Garantie!\n\n");
}
int main(argc,argv)
int argc;
char **argv;
{
  char *rcs=ID;
  rcs [strlen(rcs)] = 1;
  rcs [strlen(rcs)] = 0;
  /* C-Optimizer ueberlisten, dass der Header im Executable drinsteht. */

  /* Consistency check */
  if( sizeof(short int) != 2 )internal(1,"sizeof(short int)!=2");
  if( sizeof(long int) != 4 )internal(2,"sizeof(long int)!=4");
  if (checksp (argc, argv)) {
    argc -= 3;
    Sp = 1;
#ifdef ATARI
    Nowait = 1;
    /* SP/ATARI benoetigt es, dass LINKINFO seine Ausgabe umlenkt. */
    if (!freopen ("OUT.TXT", "w", stdout)) exit (1);
    memcpy (stderr, stdout, sizeof (FILE));
#endif
  } else {
    Sp = 0;
  }
  copyright();
  parse_options(argc,argv);
  if (Optind == 0) Optind++;
  argc -= Optind; 
  argv += Optind; /* argc enthaelt die Zahl der eigentl.
		   * Argumente, argv zeigt auf die Liste
		   * der eigentlichen Argumente
		   */
  switch(argc){
  case 0:
    if(asciinewer()){
      compile_data();
      data_info();
    } else {
      data_info();
    }
    usage();
    if (tmp_exists) unlink (tmpname);
    exit(0);
  case 1:
    /* Verschiedene Faelle: */
    {
      char *bp = argv[0];
      while (*bp && iswhitespace (*bp)) bp ++;
      if (! *bp) {
	load_data();
	info_prefix ("");
	free_data ();
	if (tmp_exists) unlink (tmpname);
	exit (0);
      }
    }
    if(qrgvalid(argv[0])){
      load_data();
      find_qrg(argv[0]);
      free_data();
      if (tmp_exists) unlink (tmpname);
      exit(0);
    }
    if(qthvalid(argv[0])){
      int laenge, breite;
      /* Einfache Aufgabe */
      strtoupper(argv[0]);
      while(iswhitespace(argv[0][0]))argv[0]++;
      laenge = (argv[0][0] - 'A') * 240 + (argv[0][2] - '0') * 24 +
	(argv[0][4] - 'A');
      breite = (argv[0][1] - 'A') * 240 + (argv[0][3] - '0') * 24 +
	(argv[0][5] - 'A');
      printf ("%.6s ist ", argv[0]);
      printcoord (laenge, breite);
      printf("\n\n");
      if (tmp_exists) unlink (tmpname);
      exit(0);
    }
    load_data();
    if(!info_call(argv[0])){
      free_data();
      if (tmp_exists) unlink (tmpname);
      exit(0);
      /* Kein Fehler -> Call gefunden */
    }
    info_prefix(argv[0]);
    free_data();
    if (tmp_exists) unlink (tmpname);
    exit(0);
  default:
    load_data();
    do_exclusions(argc-2,argv+2, argv [0], argv [1]);
    find_route (argv [0], argv [1]);
    free_data();
    if (tmp_exists) unlink (tmpname);
    exit(0);
  }
  return 0;
}
int checksp (argc, argv)
int argc;
char **argv;
{
  char *bp, call [7];
  if (argc < 3) return 0;
  bp = argv [argc - 3];
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp < '0' || *bp > '9') return 0;
  bp ++;
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp) return 0;
  bp = argv [argc - 2];
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp < '0' || *bp > '9') return 0;
  bp ++;
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp) return 0;
  bp = parse_call (argv [argc - 1], call);
  if (bp == argv [argc - 1]) return 0;
  while (*bp && iswhitespace (*bp)) bp ++;
  if (*bp) return 0;
  return 1;
}
