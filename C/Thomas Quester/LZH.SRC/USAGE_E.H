/*************************************************
        LHarc version 1.13b (c) Yoshi 1988-89.
        usage & message module : 1989/ 5/14
        (for version including no Kanji or Kana)

        adaption to ATARI ST with TURBO-C 1.1
        by J. Moeller 1990/01/31

HTAB = 4
*************************************************/

#ifndef __TOS__
char title[] = "\nLHarc 2.01m (c)Yoshi, 1988-89\n";

#else
char title[] = "\nLHarc 2.01m (c)Yoshi, Quester, 1988-91.\n"
"(Version vom 27.03.92 (Assembler vom 10.11.1991)\n";

char morefiles[] =
"LHarc kînnte noch einige Dateien enthalten. Auspacken mit Paramter LHARC.TTP\n";
#endif

char use[] =
#ifndef __TOS__
"LHarc  version 2.01m                Copyright (c) Haruyasu Yoshizaki, 1988-89.\n"
#else
"LHarc Version 2.01m (Atari ST)      Copyright (c) Haruyasu Yoshizaki, 1988-89.\n"
"                                    Optimiert von Thomas Quester      1989-91\n"
#endif
"================================================================  03.07.91  ===\n"
"               <<< High-performance file-compression program >>>\n"
"===============================================================================\n"
"  Aufruf: LHarc  [<Kommando>] [{{/|-}{<Schalter>[-|+|2|<Option>]}}...] <archive>\n"
"                 [{<Laufwerk>:}|{<Hauptvezeichnis>\\}] [<Pfad> ...]\n"
"-------------------------------------------------------------------------------\n"
"  <Kommando>\n"

"     a: Dateien an Archiv anfÅgen       u: Dateien im Archiv erneuern\n"
"     f: Dateien anfÅgen, wenn neuer     m: Datei in das Archiv 'moven'\n"
"     d: Dateien aus Archiv lîschen    e,x: Dateien aus Archiv extrahieren\n"
"     p: Dateien aus Archiv anzeigen   l,v: Dateiliste des Archivs\n"
#ifndef __TOS__
"     s: make a Self-extract archive     t: Test integrity of archive\n"
#else
"     t: Archiv testen                   c: Dateien fÅr AFX komprimieren\n"
#endif
"  <Schalter>\n"
"     r: Mit Ordnern packen/entpacken    w: Arbeitsdirectory bestimmen\n"
"     x: Erweitere Dateinamen            m: Beantworte alle Fragen mit Ja\n"
"     p: Unterscheide Ordnernamen        c: Kein Vergleich des Dateidatums\n"
"     a: Erlaube bel. Dateiattribute     v: Dateien mit anderem Prg ansehen\n"
"     n: Keinen Prozessindikator zeigen  h: Warte auf Tastendruck vor exit\n"
"     t: Archivdatum setzen              y: Nur dateien mit Archive bit packen\n"
"     b: Wie y, Archivbit wird gelîscht  l: Erzeuge Larc-kompatibles Archiv\n"
"     d: UnterdrÅcke ALLE Ausgaben       o: Erzeuge 1.13-kompatibles Archiv\n"
"     u: Ungepackt speichern             k: Erzeuge Kompatible Header\n"
"     e: Mit Kommentaren archivieren     5: Zwinge lh5-Archiv"
"     s: Wandle \\ in / um\n"
"===============================================================================\n"
"  (Eine genaue Anleitung finden Sie im User-Manual.)\n"
"  Wenn Sie Yoschi erreichen wollen: Nifty-Serve  PFF00253\n"
"                                    oASCII-pcs   pcs02846\n"
"  Wenn Sie Thomas Quester  Zerberus T.Quester @ DATA-HH\n"
"  erreichen wollen:        Maus     Thomas Quester @ HH\n"
"                           Tel./BTX (040) 720 54 31\n"
"\n"
"LHarc beinhaltet noch einige Dateien. Auspacken mit"
"  x -rm LHARC.TTP";
/*
"  Don't distribute to other network systems!             Nifty-Serve  PFF00253\n"
"  !!!! This version is made only for myself. !!!!        ASCII-pcs    pcs02846";
*/

char M_UNKNOWNERR[]     =       "Unbekannter Fehler";
char M_INVCMDERR[]      =       "Unbekanntes Kommando";
char M_MANYPATERR[]     =       "Zu viele Dateien in der Kommandozeile";
char M_NOARCNMERR[]     =       "Kein Archivname";
char M_NOFNERR[]        =       "Kein Dateiname";
char M_NOARCERR[]       =       "Archiv existiert nicht";
char M_RENAMEERR[]      =       "Ich kann das Archiv nicht umbenennen";
char M_MKTMPERR[]       =       "Ich kann die temporÑre Datei nicht erstellen";
char M_DUPFNERR[]       =       "Einige Dateien in einem anderen Ordner";
char M_TOOMANYERR[]     =       "Zu viele Dateien gefunden";
char M_TOOLONGERR[]     =       "Pfadname ist zu lang";
char M_NOFILEERR[]      =       "Keine Datei gefunden";
char M_MKFILEERR[]      =       "Ich kann das Archiv nicht anlegen";
char M_RDERR[]          =       "Ich kann die Datei nicht lesen";
char M_WTERR[]          =       "Ich kann die Datei nicht schreiben";
char M_MEMOVRERR[]      =       "Kein Speicher mehr frei";
char M_INVSWERR[]       =       "Unbekannte Option";
char M_CTRLBRK[]        =       "Programmabbruch";
char M_NOMATCHERR[]     =       "Ich kann die Datei nicht finden";
char M_COPYERR[]        =       "\nIch konnte die temporÑre Datei nicht in das Archiv kopieren";
char M_NOTLZH[]         =       "Erweiterung des Archivs (%s) ist nicht .LZH."
                                                "Wollen Sie fortfahren? [J/N] ";
char M_OVERWT[]         =       "Datei existiert, öberschreiben [J/N] oder Rename? ";
char M_ENTERNEW[]		=       "Neuer Name:";
char M_MKDIR[]          =       "Ordner anlegen?? [J/N] ";
char M_MKDIRERR[]       =       "Ich konnte den Ordner nicht anlegen";
char M_CRCERR[]         =       "CRC Fehler\n";
char M_RDONLY[]         =       "Read only!";
char M_PRESSKEY[]       =       "-- Mit Tastendruck gehts weiter --";
char M_COMMENT[]		=       "Kommentar:";

char *errmes[] = {
        M_UNKNOWNERR, M_INVCMDERR, M_MANYPATERR, M_NOARCNMERR,
        M_NOFNERR, M_NOARCERR, M_RENAMEERR, M_MKTMPERR,
        M_DUPFNERR, M_TOOMANYERR, M_TOOLONGERR, M_NOFILEERR,
        M_MKFILEERR, M_RDERR, M_WTERR, M_MEMOVRERR, M_INVSWERR,
        M_CTRLBRK, M_NOMATCHERR, M_COPYERR,
        M_NOTLZH, M_OVERWT, M_MKDIR, M_MKDIRERR, M_CRCERR,
        M_RDONLY
};
