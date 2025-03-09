/*
 * checkfat.c vom 15.01.1996
 * 
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * FAT-Testprogramm fÅr den Aufruf in einer Shell
 * oder (mit kleinem Hilfsprogramm) aus dem Auto-
 * Ordner. Findet falsche DateilÑngen, illegale
 * Start- und Folgecluster, Clusterschleifen,
 * Ordnerschleifen, Files mit als defekt
 * markierten Clustern, Cluster mit mehreren
 * VorgÑngern, falsche ClustereintrÑge, verwaiste
 * Cluster und mehrfach belegte Cluster. Ebenso
 * werden alle als defekt markierten Cluster
 * gefunden. Mittels Kommandozeilenoptionen kann
 * die Ausgabe aller Filenamen, zusÑtzlich die
 * Ausgabe sÑmtlicher Cluster jedes Files sowie
 * eine detailierte Ergebnis-Ausgabe eingeschaltet
 * werden.
 * Wichtig: Nur fÅr 16-Bit-FATs geeignet!
 *
 * Vielen Dank auch an meine Betatester (in alpha-
 * betischer Reihenfolge):
 * Alexander Clauss, Dirk Klemmt, Rainer Riedl,
 * Michael Schwingen, Uwe Seimet, Manfred Ssykor
 * und Arno Welzel.
 *
 * History:
 * Irgendwann 1993: Erstellung
 * 23.03.1995: Deutliche Verbesserung. CheckFat
 *             findet jetzt auch Clusterschleifen,
 *             illegale Folgecluster und ist auf
 *             die Steuerung der Ausgabe Åber
 *             Kommandozeilenoptionen vorbereitet.
 * 24.03.1995: CheckFat findet jetzt auch
 *             Ordnerschleifen und Cluster mit
 *             mehreren VorgÑngern.
 * 26.03.1995: Da neuere GEMDOS-Versionen wirklich
 *             alle Datencluster belegen kînnen,
 *             werden jetzt Clusternummern von 2
 *             bis numcl + 1 akzeptiert (bisher
 *             nur bis numcl - 1). Auûerdem wurden
 *             jetzt die Steuerung per
 *             Kommandozeile integriert und einige
 *             interne Optimierungen vorgenommen.
 * 27.03.1995: Beginn der Kommentierung, dabei
 *             noch kleinere Optimierungen und
 *             Fehlerbeseitigungen.
 * 29.03.1995: "Fehler" in der Meldung bei Start
 *             ohne Parameter ausgebaut (fehlendes
 *             Newline). Auûerdem darf die
 *             Laufwerksangabe jetzt auch mehr als
 *             einen Buchstaben lang sein, der
 *             Rest wird einfach ignoriert (damit
 *             kann beispielsweise auch c: oder
 *             c:\ Åbergeben werden)
 * 31.03.1995: Anpassungen an MiNTLib
 * 24.07.1995: Neue Kommandozeilenoption -h fÅr
 *             Tastendruck vor Programmende.
 * 10.10.1995: CheckFat merkt sich jetzt auch alle
 *             Dateinamen (auf Wunsch auch mit
 *             Pfad, dabei aber weitaus hîherer
 *             Speicherbedarf!) und gibt bei
 *             mehrfach belegten Clustern die
 *             Dateien an (besser: Ist beim
 *             Scannen der Files ein Cluster schon
 *             von einer anderen Datei belegt,
 *             gibt CheckFat deren Namen aus. Wenn
 *             ein Cluster also viermal belegt
 *             ist, wird bei drei Dateien der
 *             Hinweis erscheinen, daû der Cluster
 *             bereits von der letzten belegt
 *             ist.) Diese Ausgabe erfolgt nur,
 *             wenn sie per -x (siehe unten)
 *             angefordert wurde!
 *             In diesem Zusammenhang gibt es auch
 *             drei neue Kommandozeilenoptionen:
 *             -x meldet, wie gerade beschrieben,
 *                mehrfach belegte Cluster mit
 *                dem Dateinamen.
 *             -l merkt sich die kompletten Pfade
 *                (normal werden nur die Filenamen
 *                gespeichert).
 *             -a gibt bei mehrfach belegten
 *                Clustern diesen Umstand bei
 *                jedem beteiligten Cluster aus,
 *                wÑhrend dies sonst nur beim
 *                ersten Mal passiert (die
 *                restlichen Cluster der Datei
 *                sind ja damit zwangsweise
 *                ebenfalls bereits belegt).
 * 11.10.1995: Fehler in work_dir behoben, der zum
 *             öberlauf des scl-Arrays und damit
 *             zur öberschreibung der Variablen
 *             drive fÅhrte. Auûerdem wird jetzt
 *             zusÑtzlich geprÅft, ob bei der
 *             Rekursion noch genÅgend Platz im
 *             my_path-Array ist.
 *             DarÅberhinaus stimmt jetzt auch der
 *             Returncode bei Fehlerabbruch, und
 *             fÅr die zu speichernden Filenamen
 *             (-x/-l) wird nicht mehr immer ein
 *             Byte zu wenig angefordert.
 *             SicherheitsÅberprÅfungen fÅr den
 *             BPB.
 * 12.10.1995: Bei Unterverzeichnissen wird jetzt
 *             geprÅft, ob sie als erstes die
 *             Ordner "." und ".." enthalten. Wenn
 *             nicht, wird das Verzeichnis nicht
 *             bearbeitet. Ebenso werden falsche
 *             EintrÑge fÅr den Startcluster
 *             dieser beiden Pseudoverzeichnisse
 *             gemeldet.
 *             Kleinen Fehler in der BPB-PrÅfung
 *             entfernt (der ersten Datencluster
 *             muû hinter dem Wurzelverzeicnis
 *             beginnen, nicht hinter der 2. FAT).
 * 13.10.1995: Freitag, der 13., und trotzdem habe
 *             ich heute erfahren, daû ich meine
 *             letzte Vordiplomsklausur bestanden
 *             habe :)
 *             UnabhÑngig davon meldet CheckFat
 *             jetzt bei der Schluûanalyse der FAT
 *             auch Cluster, die auf sich selbst
 *             zeigen.
 * 19.10.1995: Compilierung mit Memdebug, um zu
 *             testen, ob alle mallocs/frees in
 *             Ordnung sind. Sind sie zum GlÅck :)
 * 20.10.1995: Probleme mit Thing und TOSWIN
 *             (Parameter werden nicht erkannt),
 *             daher ein wenig Debug-Output.
 * 26.10.1995: Die Probleme lagen an Thing, der
 *             Debug-Output ist also wieder weg.
 *             Es gibt eine neue Kommandozeilen-
 *             Option -d, mit der die Ausgabe von
 *             als defekt markierten Clustern
 *             eingeschaltet wird. Bisher wurden
 *             sie immer ausgegeben und als Fehler
 *             gemeldet; das hat sich aber als
 *             unbrauchbar erwiesen, weil Cluster
 *             16383 bei grîûeren Partionen wegen
 *             eines GEMDOS-Fehlers von den
 *             meisten Partitionierungsprogrammen
 *             als defekt markiert wird.
 *             Die Versionsnummer entfernt, weil
 *             sie ohnehin recht wenig aussagt.
 * 29.10.1995: Neue Option -u, bei der CheckFat
 *             nicht mehr Dlock benutzt.
 * 12.12.1995: Bei einem defekten Cluster 16383
 *             erfolgt jetzt die Meldung, daû dies
 *             normalerweise eine Schutzmaûnahme
 *             gegen einen GEMDOS-Fehler ist.
 * 20.12.1995: CheckFat gibt jetzt bei Option -?
 *             die Kurzanleitung aus (also so, wie
 *             wie es auch bei Aufruf komplett
 *             ohne Parameter geschieht).
 * 21.12.1995: In der Kurzanleitung fehlte noch
 *             die gestern eingefÅhrte Option -?.
 * 15.01.1996: Letzte Vorbereitungen fÅr die
 *             Verîffentlichung.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mintbind.h>
#include <portab.h>
#include <memdebug.h>

/* Benîtigte Strukturen und Konstanten */

#define VERSION   "vom 15.01.1996"

#define NOT16BIT  1
#define NOMEM     2
#define READERROR 3
#define NOBPB     4
#define TOODEEP   5
#define LOCKED    6
#define NOBIOS    7
#define WRONGBPB  8
#define TMFILES   9

#define WRONG       0
#define ILLEGAL     1
#define LOOPS       2
#define DIRLOOPS    3
#define DESTROYED   4
#define AMBIGUOUS   5
#define ILLCL       6
#define DAMAGED     7
#define ORPHAN      8
#define MULTIPLE    9
#define ILLSUBDIR   10
#define ILLPSEUDO   11
#define SELFPOINTER 12
#define NO_OF_TYPES 13

/*
 * Die maximale Rekursionstiefe bestimmt sich in
 * etwa durch [*_StkSize / (61 + PATHMAX)] - 4,
 * wobei man natÅrlich eine recht groûe
 * Sicherheitsreserve fÅr den Stack lassen sollte
 */
#define MAXDEPTH  17

/*
 * Bestimmt, wie lang ein Pfad inklusive Nullbyte
 * maximal sein darf. Sollte diese Grenze wÑhrend
 * der Rekursion innerhalb von work_dir
 * Åberschritten werden, wird CheckFat mit der
 * Meldung "Zu tiefe Ordnerverschachtelung"
 * abgebrochen.
 */
#define PATHMAX   129

#define MAXCLUST  ((UWORD)bpb->numcl + 1)

typedef struct
{
  char  dir_name[11];
  BYTE  dir_attr;
  BYTE  dir_dummy[10];
  UWORD dir_time;
  UWORD dir_date;
  UWORD dir_stcl;
  ULONG dir_flen;
} DIR;

/* Prototypen */

void leave(WORD retcode);
WORD eval_args(WORD argc, char *argv[]);
void usage(void);
void err(WORD code);
void correct_dir(DIR *dir, WORD entries);
void work_dir(DIR *dir, WORD entries, char *path,
  UWORD *scl, WORD depth);
void swap(UWORD *value);
void lswap(ULONG *value);

/* Globale Variablen */

char  *errtext[] = {
        "Kein Fehler!",
        "Medium hat keine 16-Bit-Fat!",
        "Kein Speicher mehr frei!",
        "Lesefehler!",
        "Bios-Parameterblock unlesbar!",
        "Zu tiefe Ordnerverschachtelung!",
        "Laufwerk gesperrt!",
        "Kein BIOS-Laufwerk!",
        "Bios-Parameterblock fehlerhaft!",
        "Zu viele Files!?"},
      *reporttext[NO_OF_TYPES] = {
        "%d unterschiedliche DateilÑnge(n)!\n",
        "%d File(s)/Ordner mit illegalem Start/"
          "Folgecluster!\n",
        "%d File(s)/Ordner mit "
          "Clusterschleife!\n",
        "%d Ordnerschleife(n)!\n",
        "%d File(s)/Ordner mit defektem "
          "Cluster!\n",
        "%d Cluster ohne eindeutigen "
          "VorgÑnger!\n",
        "%d illegale(r) Folgecluster!\n",
        "%d als defekt markierte(r) Cluster!\n",
        "%d verwaiste(r) Cluster!\n",
        "%d mehrfach belegte(r) Cluster!\n",
        "%d Verzeichnis(se) ohne '.' und/oder "
          "'..'!\n",
        "%d falsche(r) Startcluster bei '.' "
          "und/oder '..'!\n",
        "%d auf sich selbst zeigende(r) "
          "Cluster!\n"},
      *filenames[32768L];
UWORD filenr,
      *fat,
      startclusters[MAXDEPTH];
WORD  drive,
      to_report[NO_OF_TYPES],
      shownames,    /* Namen anzeigen */
      showclusters, /* Cluster anzeigen */
      verbose,      /* AusfÅhrliche Meldungen */
      crosslinks,   /* Namen bei Crosslinks */
      showall,      /* Alle Crosslinks */
      longnames,    /* Pfadnamen bei Crosslinks */
      showdamaged,  /* Defekte Cluster melden */
      nolock,       /* Device nicht locken */
      hold,         /* Auf Tastendruck warten */
      quit,
      entries,
      *checkfat,
      *tempcheck;
LONG  lock;
#ifdef __MINT__
_BPB  *bpb;
#else
BPB   *bpb;
#endif
DIR   *rootdir;

void main(WORD argc, char *argv[])
{
  UWORD i, j,
        badfat;
  LONG  minfat;

  shownames = showclusters = verbose = quit =
    hold = showall = longnames = showdamaged =
    nolock = 0;
/*
 * Kommandozeile auswerten, beenden, wenn
 * fehlerhaft
 */
  if (!eval_args(argc, argv))
    leave(2);
/*
 * Versuchen, das gewÅnschte Bios-Device gegen
 * GEMDOS-Zugriffe zu schÅtzen. Ist der Aufruf
 * vorhanden und es trat dabei ein Fehler auf,
 * wird CheckFat mit einer entsprechenden Meldung
 * verlassen.
 */
  if (!nolock &&
    ((lock = Dlock(1, drive)) != -32L))
  {
    if (lock == -46L)
      err(NOBIOS);
    if (lock != 0L)
      err(LOCKED);
  }
  for (i = 0; i < NO_OF_TYPES; i++)
    to_report[i] = 0;
/* Versuchen, den Bios-Parameterblock zu lesen */
  if ((bpb = Getbpb(drive)) == 0L)
    err(NOBPB);
/*
 * Sicherstellen, daû es sich um eine 16-Bit-FAT
 * handelt
 */
  if ((bpb->bflags & 1) != 1)
    err(NOT16BIT);
/*
 * Einige Tests, ob es wirklich ein gÅltiger BPB
 * ist:
 * - Bytes pro Sektor durch 512 teilbar
 * - Bytes pro Cluster = Sektoren pro Cluster *
 *   Bytes pro Sektor
 * - Wurzelverzeichnis mindestens 1 Sektor lang
 * - mindestens ein, maximal 32766 Datencluster
 * - FAT groû genug fÅr alle Datencluster
 * - Erster Datensektor hinter Ende von Directory
 */
  if (bpb->recsiz % 512)
    err(WRONGBPB);
  if (bpb->clsizb != (bpb->clsiz * bpb->recsiz))
    err(WRONGBPB);
  if (bpb->rdlen < 1)
    err(WRONGBPB);
  if ((bpb->numcl < 1) || (bpb->numcl > 32766))
    err(WRONGBPB);
  minfat = ((LONG)bpb->numcl * 2L +
    ((LONG)bpb->recsiz - 1L)) / (LONG)bpb->recsiz;
  if ((WORD)minfat > bpb->fsiz)
    err(WRONGBPB);
  if ((bpb->fatrec + bpb->fsiz + bpb->rdlen) >
    bpb->datrec)
  {
    err(WRONGBPB);
  }
/*
 * Speicherplatz fÅr Wurzelverzeichnis, FAT und
 * zwei Testtabellen anfordern. Gelingt dies
 * nicht, Programm mit Meldung verlassen.
 */
  if ((rootdir = (DIR *)malloc((LONG)bpb->rdlen
    * (LONG)bpb->recsiz)) == 0L)
  {
    err(NOMEM);
  }
  if ((fat = (UWORD *)malloc((LONG)bpb->fsiz *
    (LONG)bpb->recsiz)) == 0L)
  {
    err(NOMEM);
  }
  if ((checkfat = (WORD *)malloc((LONG)bpb->fsiz
    * (LONG)bpb->recsiz)) == 0L)
  {
    err(NOMEM);
  }
  if ((tempcheck = (WORD *)malloc((LONG)
    bpb->fsiz * (LONG)bpb->recsiz)) == 0L)
  {
    err(NOMEM);
  }
/*
 * Anzahl der EintrÑge im Wurzelverzeichnis
 * berechnen
 */
  entries = (WORD)((LONG)bpb->rdlen *
    bpb->recsiz / 32);
/*
 * Wurzelverzeichnis und FAT 2 einlesen. Tritt
 * dabei ein Fehler auf, Programm beenden
 */
  if (Rwabs(0, (void *)rootdir, bpb->rdlen,
    bpb->fatrec + bpb->fsiz, drive))
  {
    err(READERROR);
  }
  if (Rwabs(0, (void *)fat, bpb->fsiz, bpb->fatrec, drive))
  {
    err(READERROR);
  }
/*
 * FAT-EintrÑge in Motorola-Format wandeln und
 * Tabellen vorbereiten
 */
  for (i = 0; i <= MAXCLUST; i++)
  {
    checkfat[i] = tempcheck[i] = 0;
    swap(&fat[i]);
  }
  memset(filenames, 0, sizeof(char *) * 32768L);
  filenr = 0;
  printf("CheckFat: PrÅfe FAT von Laufwerk "
    "%c...\n", (char)(drive + 65));
/*
 * Wurzelverzeichnis bearbeiten. Da die Funktion
 * work_dir rekursiv arbeitet, wird dadurch der
 * gesamte Dateibaum durchgetestet. Die globale
 * Variable quit wird auf einen Wert != 0 gesetzt,
 * wenn dabei ein Lesefehler oder Speichermangel
 * aufgetreten ist. In diesem Fall wird CheckFat
 * mit einer Meldung beendet.
 */
  work_dir(rootdir, entries, "\\",
    startclusters, 0);
  if (quit)
    err(quit);
  puts("\nCheckFat-Ergebnis:");
/*
 * Alle (gÅltigen) ClustereintrÑge durchgehen und
 * Fehler melden bzw. merken (ersteres nur, wenn
 * ausfÅhrliche Ausgabe per -v gewÅnscht ist)
 */
  memset(tempcheck, 0, (LONG)bpb->fsiz *
    (LONG)bpb->recsiz);
  for (i = 2; i <= MAXCLUST; i++)
  {
/*
 * PrÅfen, ob weitere Cluster auf den Folgecluster
 * des aktuellen zeigen
 */
    if ((fat[i] >= 2) && (fat[i] <= MAXCLUST))
    {
      if (tempcheck[fat[i]] > 0)
      {
        if (verbose)
        {
          printf("Folgende Cluster zeigen alle "
            "auf Cluster %u:\n", fat[i]);
          printf("%u %u ", tempcheck[fat[i]], i);
          for (j = i + 1; j <= MAXCLUST; j++)
          {
            if (fat[j] == fat[i])
              printf("%u ", j);
          }
          puts("");
        }
        to_report[AMBIGUOUS]++;
        tempcheck[fat[i]] = -1;
      }
      else
      {
        if (!tempcheck[fat[i]])
          tempcheck[fat[i]] = i;
      }
/* PrÅfen, ob Cluster mehrfach belegt ist */
    }
    if (checkfat[i] > 1)
    {
      if (verbose)
      {
        printf("Cluster %u ist %d-fach belegt!\n",
          i, checkfat[i]);
      }
      to_report[MULTIPLE]++;
    }
/* PrÅfen, ob Cluster verwaist ist */
    if ((fat[i] > 1) && ((fat[i] <= MAXCLUST) ||
      (fat[i] == 0xffffU)) && (checkfat[i] == 0))
    {
      if (verbose)
        printf("Cluster %u ist verwaist!\n", i);
      to_report[ORPHAN]++;
    }
/* PrÅfen, ob Cluster gÅltigen Folgecluster hat */
    if (fat[i] && ((fat[i] < 2) ||
      ((fat[i] < 0xfff0U) &&
      (fat[i] > MAXCLUST))))
    {
      if (verbose)
      {
        printf("Cluster %u hat illegalen "
          "Folgecluster!\n", i);
      }
      to_report[ILLCL]++;
    }
/*
 * PrÅfen, ob Cluster als defekt markiert ist. Die
 * Ausgabe erfolgt nur, wenn Option -d aktiv ist.
 */
    if (showdamaged && (fat[i] >= 0xfff0U) &&
      (fat[i] <= 0xfff7U))
    {
      if (verbose)
      {
        printf("Cluster %u ist als defekt "
          "markiert!\n", i);
        if (i == 16383)
        {
          puts("Dies ist in der Regel nur ein "
            "Schutz gegen einen GEMDOS-Fehler!");
        }
      }
      to_report[DAMAGED]++;
    }
/* PrÅfen, ob Cluster auf sich selbst verweist */
    if (fat[i] == i)
    {
      if (verbose)
      {
        printf("Cluster %u zeigt auf sich "
          "selbst!\n", i);
      }
      to_report[SELFPOINTER]++;
    }
  }
/* Eventuell gefundene Fehler berichten */
  for (i = badfat = 0; i < NO_OF_TYPES; i++)
  {
    badfat += to_report[i];
    if (to_report[i])
      printf(reporttext[i], to_report[i]);
  }
  if (!badfat)
    puts("Alles OK!");
/*
 * Am Schluû den Speicher und das Laufwerk wieder
 * freigeben und 0 zurÅckliefern, wenn kein Fehler
 * gefunden wurde, sonst 3
 */
  for (i = 32767U; i > 0; i--)
  {
    if (filenames[i])
      free(filenames[i]);
  }
  if (filenames[i])
    free(filenames[i]);
  free((void *)tempcheck);
  free((void *)checkfat);
  free((void *)fat);
  free((void *)rootdir);
  if (!nolock && (lock == 0L))
    Dlock(0, drive);
  if (badfat)
    leave(3);
  else
    leave(0);
}

/*
 * leave
 *
 * VerlÑût CheckFat mit einem gegebenen Returncode
 * und wartet dabei gegebenenfalls vorher auf eine
 * Taste.
 *
 * Eingabe:
 * retcode: ZurÅckzuliefernder Returncode
 */
void leave(WORD retcode)
{
  if (hold)
  {
    puts("\nBitte eine Taste drÅcken!");
    Cnecin();
  }
  exit(retcode);
}

/*
 * eval_args
 *
 * Wertet die Kommandozeile aus, die CheckFat
 * Åbergeben wurde.
 *
 * Eingabe:
 * argc: Anzahl der Elemente in argv
 * argv: Stringarray mit einzelnen Optionen
 *       (argc und argv haben exakt die gleiche
 *       Bedeutung wie bei main!)
 *
 * RÅckgabe:
 * 0: Parameter waren fehlerhaft
 * 1: Parameter OK
 */
WORD eval_args(WORD argc, char *argv[])
{
  WORD  i, j;

  drive = -1;
  if (argc < 2)
  {
    usage();
    return(0);
  }
  for (i = 1; i < argc; i++)
  {
    if (*argv[i] == '-')
    {
      if (strlen(argv[i]) == 1)
      {
        puts("CheckFat: Falsches Optionsformat "
          "- ignoriert");
        continue;
      }
      for (j = 1; j < strlen(argv[i]); j++)
      {
        switch (argv[i][j])
        {
          case 'v':
            verbose = 1;
            break;
          case 'n':
            shownames = 1;
            break;
          case 'c':
            shownames = showclusters = 1;
            break;
          case 'a':
            showall = 1;
            break;
          case 'x':
            crosslinks = 1;
            break;
          case 'l':
            crosslinks = longnames = 1;
            break;
          case 'd':
            showdamaged = 1;
            break;
          case 'u':
            nolock = 1;
            break;
          case 'h':
            hold = 1;
            break;
          case '?':
            usage();
            return(0);
          default:
            printf("CheckFat: Unbekannte Option "
              "'%c' - ignoriert\n", argv[i][j]);
        }
      }
    }
    else
    {
      drive = (*argv[i] & ~32) - 65;
      if ((drive < 0) || (drive > 31))
      {
        puts("CheckFat: Falsche "
          "Laufwerksangabe!");
        return(0);
      }
      if (i != (argc - 1))
      {
        puts("CheckFat: öberflÅssige Parameter "
          "- ignoriert");
      }
      break;
    }
  }
  if (drive == -1)
  {
    puts("CheckFat: Laufwerksangabe fehlt!");
    return(0);
  }
  return(1);
}

/*
 * usage
 *
 * Gibt die Kurzanleitung aus.
 */
void usage(void)
{
  puts("CheckFat "VERSION);
  puts("(c) 1996 by MAXON Computer GmbH");
  puts("Geschrieben in Pure C von Thomas Binder");
  puts("\nAufruf: checkfat [Optionen] Laufwerk");
  puts("\nOptionen:");
  puts("\t-v: AusfÅhrliche FAT-Fehlermeldungen");
  puts("\t-n: Alle Filenamen anzeigen");
  puts("\t-c: Alle Cluster zu allen Files "
    "anzeigen (schlieût -n ein)");
  puts("\t-a: Alle mehrfach belegten Cluster "
    "einer Datei anzeigen");
  puts("\t-x: Bei mehrfach belegten Clustern "
    "auch die anderen Dateinamen melden");
  puts("\t-l: Komplette Pfadnamen bei -x melden "
    "(schlieût -x ein, hoher Speicher-\n"
    "\t    bedarf!)");
  puts("\t-d: Bei der Ergebnisausgabe als "
    "defekt markierte Cluster melden");
  puts("\t-u: Laufwerk nicht mit Dlock sperren");
  puts("\t-h: Nach Programmende auf Tastendruck "
    "warten");
  puts("\t-?: Dieser Hilfetext");
}

/*
 * work_dir
 *
 * Bearbeitet alle Files eines Verzeichnisses und
 * alle Unterverzeichnisse. Gefunden werden dabei
 * Clusterschleifen, Ordnerschleifen, illegale
 * Start- und Folgecluster sowie Files mit
 * defekten Clustern. Auûerdem werden alle
 * belegten Cluster vermerkt, um spÑter mehrfach
 * vergebene und verwaiste Cluster erkennen zu
 * kînnen.
 *
 * Eingabe:
 * dir: Zeiger auf das zu bearbeitende Verzeichnis
 * entries: Maximale Anzahl an EintrÑgen in dir
 * path: Pfadname von dir (mit abschlieûendem \\)
 * scl: Array mit Anfangsclustern der
 *      "Elternverzeichnisse" von dir
 * depth: Bisherige Schachtelungstiefe, 0 =
 *        Wurzelverzeichnis. scl enthÑlt somit
 *        depth EintrÑge.
 */
void work_dir(DIR *dir, WORD entries, char *path,
  UWORD *scl, WORD depth)
{
  WORD  i, j, k,
        first;
  UWORD cl;
  ULONG clusts,
        must;
  DIR   *subdir;
  char  my_path[PATHMAX],
        fname[13];

/*
 * Sollte maximale Schachtelungstiefe erreicht
 * sein, Funktion abbrechen und Fehler melden
 */
  if (depth == MAXDEPTH)
  {
    if (!shownames)
    {
      printf("%s: Pfad zu tief verschachtelt!\n",
        path);
    }
    quit = TOODEEP;
    return;
  }
/* EintrÑge des Verzeichnisses umwandeln */
  correct_dir(dir, entries);
/*
 * PrÅfen, ob die beiden ersten EintrÑge . und ..
 * heissen und Verzeichnisse sind. Wenn nicht,
 * Verzeichnis nicht bearbeiten. Dieser Test muû
 * natÅrlich im Wurzelverzeichnis entfallen.
 */
  if (depth)
  {
    if (strncmp(dir[0].dir_name, ".          ",
      11) || strncmp(dir[1].dir_name,
      "..         ", 11) ||
      !(dir[0].dir_attr & 16) ||
      !(dir[1].dir_attr & 16))
    {
      if (!shownames)
        printf("%s: ", path);
      puts("Kein '.' und/oder '..'!");
      to_report[ILLSUBDIR]++;
      return;
    }
/*
 * Jetzt noch testen, ob . und .. die richtigen
 * Startcluster haben. Falls nicht, wird dies
 * gemeldet, das Verzeichnis aber trotzdem
 * bearbeitet.
 */
    if (dir[0].dir_stcl != scl[depth - 1])
    {
      if (!shownames)
        printf("%s: ", path);
      puts("Falscher Startcluster fÅr '.'!");
      to_report[ILLPSEUDO]++;
    }
    if (dir[1].dir_stcl != ((depth == 1) ? 0 :
      scl[depth - 2]))
    {
      if (!shownames)
        printf("%s: ", path);
      puts("Falscher Startcluster fÅr '..'!");
      to_report[ILLPSEUDO]++;
    }
  }
/* Alle EintrÑge durchgehen */
  for (i = (depth) ? 2 : 0; i < entries; i++)
  {
/*
 * Ist das erste Zeichen des aktuellen Filenamens
 * eine Null, ist der letzte Eintrag erreicht
 */
    if (!dir[i].dir_name[0])
      break;
/*
 * Eintrag nur ÅberprÅfen, wenn es kein gelîschtes
 * File und kein Laufwerkslabel ist
 */
    if ((dir[i].dir_name[0] == (char)0xe5) ||
      (dir[i].dir_attr & 8))
    {
      continue;
    }
/*
 * Startcluster ermitteln und aktuelle Filenummer
 * erhîhen. Durch diese Nummer erhÑlt jedes File
 * eine individuelle Kennzeichnung, mit der es
 * mîglich ist, Clusterschleifen zuverlÑssig zu
 * erkennen. Da filenr ein 16-Bit-Wert ist, darf
 * ein Laufwerk maximal 65535 Dateien/Ordner
 * beherbergen; allerdings ist diese Grenze schon
 * technisch nicht erreichbar, da eine 16-Bit-Fat
 * maximal 32766 Dateicluster haben kann. Auûerdem
 * ermîglicht es diese individuelle Nummer, bei
 * bereits belegten Clustern zu ermitteln, zu
 * welcher Datei sie gehîren.
 */
    cl = dir[i].dir_stcl;
    if ((filenr++) == 32768U)
    {
      quit = TMFILES;
      return;
    }
/* Den aktuellen Filenamen basteln */
    for (j = 0; j < 8; j++)
    {
      if (dir[i].dir_name[j] != ' ')
        fname[j] = dir[i].dir_name[j];
      else
        break;
    }
    fname[j] = 0;
    if (dir[i].dir_name[8] != ' ')
    {
      fname[j++] = '.';
      for (k = 0; k < 3; k++)
      {
        if (dir[i].dir_name[8 + k] != ' ')
          fname[j + k] = dir[i].dir_name[8 + k];
        else
          break;
      }
      fname[j + k] = 0;
    }
    if (dir[i].dir_attr & 16)
    {
/*
 * Eintrag ist Ordner, also neuen Pfadnamen
 * zusammensetzen; dabei vorher prÅfen, ob my_path
 * noch genÅgend Platz bietet; wenn nicht, wird
 * TOODEEP gemeldet
 */
      if ((strlen(path) + 2 + strlen(fname)) >
        PATHMAX)
      {
        printf("%s%s\\ ist zu lang!\n", path,
          fname);
        quit = TOODEEP;
        return;
      }
      strcpy(my_path, path);
      strcat(my_path, fname);
      strcat(my_path, "\\");
      if (shownames)
        printf("%s ", my_path);
/*
 * Startcluster ÅberprÅfen und notfalls
 * beanstanden. Bei Ordnern wird auch Null als
 * Startcluster beanstandet, da Ordner nie
 * komplett leer sein dÅrfen (sie mÅssen
 * mindestens . und .. enthalten).
 */
      if ((cl < 2) || (cl > MAXCLUST))
      {
        if (!shownames)
          printf("%s: ", my_path);
        puts("Illegaler Startcluster!");
        to_report[ILLEGAL]++;
        continue;
      }
/*
 * PrÅfen, ob dieser Startcluster im aktuellen
 * Pfad schon einmal vorhanden war. Wenn ja, zeigt
 * das neue Verzeichnis auf einen seiner
 * VorgÑnger, es gibt also eine Ordnerschleife.
 */
      for (j = 0; j < depth; j++)
      {
        if (scl[j] == cl)
        {
          if (!shownames)
            printf("%s: ", my_path);
          puts("Ordnerschleife!");
          to_report[DIRLOOPS]++;
          break;
        }
      }
      if (j != depth)
        continue;
/*
 * Bei aktiver Kommandozeilenoption -x den Ordner-
 * bzw. Pfadnamen speichern. Ist dazu nicht mehr
 * genug Speicher vorhanden, wird work_dir
 * abgebrochen. Die Speicherung erfolgt erst
 * jetzt, weil vorher noch nicht sichergestellt
 * war, ob der Ordner Åberhaupt gÅltig ist, was
 * unter UmstÑnden Speicher spart.
 */
      if (crosslinks)
      {
        if (longnames)
        {
          filenames[filenr] =
            malloc(strlen(my_path) + 1);
        }
        else
        {
          filenames[filenr] =
            malloc(strlen(fname) + 1);
        }
        if (filenames[filenr] == 0L)
        {
          if (shownames)
            puts("");
          quit = NOMEM;
          return;
        }
        if (longnames)
          strcpy(filenames[filenr], my_path);
        else
        {
          strcpy(filenames[filenr], fname);
          strcat(filenames[filenr], "\\");
        }
      }
/*
 * Den Startcluster in der Liste vermerken und
 * Speicher fÅr ein neues Verzeichnis anfordern
 */
      scl[depth] = cl;
      if ((subdir = (DIR *)malloc((LONG)
        bpb->clsizb)) != 0L)
      {
/*
 * War Speicher vorhanden, alle Cluster des neuen
 * Directories ermitteln und prÅfen
 */
        clusts = first = 0;
        while (cl < 0xfff0U)
        {
          if (showclusters)
            printf("%u ", cl);
/* Testen, ob aktueller Cluster gÅltig ist */
          if ((cl < 2) || ((cl > MAXCLUST) &&
            (cl < 0xfff0)))
          {
            if (!shownames)
              printf("%s: ", my_path);
            puts("Illegaler Folgecluster!");
            to_report[ILLEGAL]++;
            break;
          }
/*
 * Gehîrt der aktuelle Cluster bereits zu diesem
 * Ordner, liegt eine Clusterschleife vor
 */
          if (tempcheck[cl] == filenr)
          {
            if (!shownames)
              printf("%s: ", my_path);
            puts("Clusterschleife!");
            to_report[LOOPS]++;
            break;
          }
/*
 * War der Cluster bereits belegt, dies (ggf. mit
 * File- bzw. Pfadnamen der Datei, die ihn belegt)
 * ausgeben (je nach Einstellung von showall
 * nur, wenn es der erste Cluster war). Dabei wird
 * die Einleseschleife nicht abgebrochen, da das
 * Unterverzeichnis ja noch weitergeht (wenn auch
 * nicht mehr ganz korrekt).
 */
          if (tempcheck[cl])
          {
            if (showall || !first)
            {
              first = 1;
              if (!shownames)
                printf("%s: ", my_path);
              if (crosslinks)
              {
                printf("Cluster %d bereits durch "
                  "%s belegt!\n", cl,
                  filenames[tempcheck[cl]]);
              }
              else
              {
                printf("Cluster %d bereits "
                  "belegt!\n", cl);
              }
            }
          }
/*
 * War alles OK, den aktuellen Cluster einlesen.
 * Tritt dabei ein Fehler auf, die Routine
 * abbrechen.
 */
          if (Rwabs(0, (void *)((LONG)subdir +
            clusts * (LONG)bpb->clsizb),
            bpb->clsiz, bpb->datrec + (cl - 2) *
            bpb->clsiz, drive))
          {
            free((void *)subdir);
            if (shownames)
              puts("");
            quit = READERROR;
            break;
          }
/*
 * In der FAT-Testtabelle den Belegungsgrad des
 * aktuellen Clusters erhîhen und vermerken, daû
 * er bereits zu diesem Ordner gehîrt
 */
          checkfat[cl]++;
          tempcheck[cl] = filenr;
/*
 * Folgecluster ermitteln und ggf. neuen Speicher
 * anfordern
 */
          cl = fat[cl];
          clusts++;
          if (cl < 0xfff0U)
          {
            subdir = (DIR *)realloc((void *)
              subdir, (clusts + 1L) *
              (LONG)bpb->clsizb);
            if (subdir == 0L)
            {
              quit = NOMEM;
              if (shownames)
                puts("");
            }
          }
        }
        if (!quit)
        {
/*
 * Alle Cluster sind ermittelt. War der letzte
 * Cluster ein als defekt markierter, dieses
 * vermerken.
 */
          if ((cl >= 0xfff0) && (cl < 0xfff8U))
          {
            if (!shownames)
              printf("%s: ", my_path);
            puts("EnthÑlt defekten Cluster!");
            to_report[DESTROYED]++;
          }
          if (shownames)
            puts("");
/*
 * work_dir rekursiv mit dem neu eingelesenen
 * Verzeichnis aufrufen
 */
          work_dir(subdir, (WORD)(clusts *
            (LONG)bpb->clsizb / 32L), my_path,
            scl, depth + 1);
          free(subdir);
        }
      }
      else
      {
        quit = NOMEM;
        if (shownames)
          puts("");
      }
    }
    else
    {
/*
 * Aktueller Verzeichniseintrag ist eine Datei.
 * Auch hier zunÑchst den Startcluster prÅfen.
 */
      if (shownames)
        printf("%s%s ", path, fname);
      clusts = first = 0;
/*
 * Bei Dateien Startcluster Null nicht
 * beanstanden, es handelt sich hierbei um
 * regulÑre Files mit LÑnge Null
 */
      if (!cl)
      {
        if (shownames)
          puts("");
        continue;
      }
/* Startcluster prÅfen */
      if ((cl < 2) || (cl > MAXCLUST))
      {
        if (!shownames)
          printf("%s%s: ", path, fname);
        puts("Illegaler Startcluster!");
        to_report[ILLEGAL]++;
      }
      else
      {
/*
 * War Startcluster OK, aus der DateilÑnge
 * berechnen, wieviele Cluster diese Datei
 * belegen muû. Danach alle Cluster des Files
 * durchgehen. Zuvor wird noch, falls nîtig (-x),
 * der Datei- bzw. Pfadname gespeichert.
 */
        if (crosslinks)
        {
          if (longnames)
          {
            filenames[filenr] = malloc(
              strlen(path) + strlen(fname) + 1);
          }
          else
          {
            filenames[filenr] =
              malloc(strlen(fname) + 1);
          }
          if (filenames[filenr] == 0L)
          {
            quit = NOMEM;
            if (shownames)
              puts("");
            return;
          }
          if (longnames)
          {
            strcpy(filenames[filenr], path);
            strcat(filenames[filenr], fname);
          }
          else
            strcpy(filenames[filenr], fname);
        }
        must = (dir[i].dir_flen / bpb->clsizb);
        if (dir[i].dir_flen % bpb->clsizb)
          must++;
        while (cl < 0xfff0U)
        {
          if (showclusters)
            printf("%u ", cl);
/* Cluster auf GÅltigkeit prÅfen */
          if ((cl < 2) || ((cl > MAXCLUST) &&
            (cl < 0xfff0)))
          {
            if (!shownames)
              printf("%s%s: ", path,fname);
            puts("Illegaler Folgecluster!");
            to_report[ILLEGAL]++;
            break;
          }
/*
 * War der aktuelle Cluster schon durch diese
 * Datei belegt, Clusterschleife melden
 */
          if (tempcheck[cl] == filenr)
          {
            if (!shownames)
              printf("%s%s: ", path, fname);
            puts("Clusterschleife!");
            to_report[LOOPS]++;
            break;
          }
/*
 * Ist der Cluster bereits durch eine andere
 * Datei belegt, dieses melden. Die Schleife wird
 * dabei nicht abgebrochen, da die Datei dadurch
 * ja noch nicht beendet ist.
 */
          if (tempcheck[cl])
          {
            if (showall || !first)
            {
              first = 1;
              if (!shownames)
                printf("%s%s: ", path, fname);
              if (crosslinks)
              {
                printf("Cluster %d bereits durch "
                  "%s belegt!\n", cl,
                  filenames[tempcheck[cl]]);
              }
              else
              {
                printf("Cluster %d bereits "
                  "belegt!\n", cl);
              }
            }
          }
/*
 * Jetzt Belegungsgrad des aktuellen Clusters
 * erhîhen und vermerken, daû er bereits in diesem
 * File benutzt wurde
 */
          checkfat[cl]++;
          tempcheck[cl] = filenr;
/*
 * Folgecluster ermitteln und Anzahl der durch das
 * File tatsÑchlich belegten Cluster um eins
 * erhîhen
 */
          cl = fat[cl];
          clusts++;
        }
/*
 * Sind alle Cluster geprÅft, testen, ob das Ende
 * der Verkettung durch einen defekten Cluster
 * markiert wurde. Wenn ja, dies vermerken.
 */
        if ((cl >= 0xfff0) && (cl < 0xfff8U))
        {
          if (!shownames)
            printf("%s%s: ", path, fname);
          puts("EnthÑlt defekten Cluster!");
          to_report[DESTROYED]++;
        }
        else
        {
/*
 * Ansonsten prÅfen, ob die Datei die richtige
 * Anzahl von Clustern belegt
 */
          if (clusts != must)
          {
            if (!shownames)
              printf("%s%s: ", path, fname);
            puts("Abweichende LÑngen!");
            to_report[WRONG]++;
            continue;
          }
        }
        if (shownames)
          puts("");
      }
    }
    if (quit)
      return;
  }
}

/*
 * correct_dir
 *
 * Wandelt die EintrÑge eines eingelesenen
 * Verzeichnisses vom Intel- in's Motorola-Format
 * um.
 *
 * Eingabe:
 * dir: Zeiger auf Verzeichnis
 * entries: Anzahl zu wandelnder EintrÑge in dir
 */
void correct_dir(DIR *dir, WORD entries)
{
  WORD  i;
  
  for (i = 0; i < entries; i++)
  {
    swap(&dir[i].dir_time);
    swap(&dir[i].dir_date);
    swap(&dir[i].dir_stcl);
    lswap(&dir[i].dir_flen);
  }
}

/*
 * swap
 *
 * 16-Bit-Wert vom Intel- in's Motorola-Format
 * umwandeln (und umgekehrt).
 *
 * Eingabe:
 * value: Zeiger auf zu wandelndes Wort
 */
void swap(UWORD *value)
{
  *value = ((*value & 255) << 8) + (*value >> 8);
}

/*
 * lswap
 *
 * Wie swap, jedoch fÅr 32-Bit-Werte.
 *
 * Eingabe:
 * value: Zeiger auf zu wandelnden Long
 */
void lswap(ULONG *value)
{
  UWORD high, low;
  
  low = (UWORD)(*value & 65535L);
  high = (UWORD)(*value >> 16);
  
  swap(&low);
  swap(&high);
  
  *value = ((LONG)low << 16) + (LONG)high;
}

/*
 * err
 *
 * Fehlerbehandlungsroutine. Wird angesprungen,
 * wenn wÑhrend des Programmablaufs ein Fehler
 * aufgetreten ist. Hier wird, wenn nîtig, aller
 * angeforderter Speicher freigegeben und eine
 * Meldung ausgegeben, welcher Fehler aufgetreten
 * ist. Die Funktion kehrt nicht zurÅck, sondern
 * beendet das Programm.
 *
 * Eingabe:
 * code: Fehlercode
 */
void err(WORD code){
  WORD i;

/* Wenn nîtig, Speicher freigeben */
  for (i = 32767; i >= 0; i--)
  {
    if (filenames[i])
      free(filenames[i]);
  }
  if (tempcheck != 0L)
    free((void *)tempcheck);
  if (checkfat != 0L)
    free((void *)checkfat);
  if (fat != 0L)
    free((void *)fat);
  if (rootdir != 0L)
    free((void *)rootdir);
/* Meldung ausgeben */
  printf("CheckFat: %s\n", errtext[code]);
/* Laufwerk freigeben, wenn nîtig */
  if (!nolock && (lock == 0L))
    Dlock(0, drive);
/* Und tschÅû... */
  leave(1);
}

/* EOF */
