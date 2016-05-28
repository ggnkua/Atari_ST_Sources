const uchar title[] =
"\r\n LHarc "LZHVERSION", Copyright (c) Yoshizaki, 1988-89\r\n"
" Atari-Version (c) Grunenberg, Mandel, 1994, Haun, 1996/97\r\n";

#ifndef __SHELL__

const uchar title_x[] =
"   LHarc Version "LZHVERSION" (Atari)\r\n"
"   (c) Yoshizaki, 1988-1989, Grunenberg, Mandel, 1994, Haun, 1996/97";

uchar *usage[] =
{
" ================================================================ "__DATE__" =",
" Aufruf: LHarc [<Kommando>] [{{-|/}{<Schalter>[-|+|0-3|<Option>]}}...] <Archiv>",
"         [{<Laufwerk>:[\\]}|{<Hauptverzeichnis>\\}] {[&|&-|~] <Pfade> ...}",
" ------------------------------------------------------------------------------",
"  <Kommando>",
"     a: Dateien an Archiv anfÅgen       u: Dateien, falls neuer, anfÅgen",
"   f,r: Dateien im Archiv erneuern      m: Datei in das Archiv schieben",
"     d: Dateien aus Archiv lîschen    e,x: Dateien aus Archiv extrahieren",
"     p: Dateien aus Archiv anzeigen   l,v: Dateiliste des Archivs",
"     t: Archiv testen                   c: Dateien fÅr AFX komprimieren",
" ------------------------------------------------------------------------------",
"  <Schalter>  (ACHTUNG: Die Bedeutung des d-Schalters wurde komplett geÑndert)",
"     a: Erlaube alle Dateiattribute     b: Archiv-Bit der Dateien lîschen",
"     c: Kein Vergleich des Dateidatums  d: Bearbeitete Dateien lîschen",
"     e: Dateikommentare eingeben        f: Ordner ebenfalls einpacken",
"     g: Archiv in Ordner auspacken      h: Warte auf Tastendruck vor Ende",
"     i: Dateiattribute ignorieren       j: Dateien der LÑnge 0 ausschlieûen",
"     k: Header-Level (0-2)              l: Erzeuge Larc-kompatibles Archiv",
"     m: Nachfragen ausschalten          n: Prozeûindikator einstellen",
"     o: Erzeuge 1.13-kompatibles Archiv p: Unterscheide Ordnernamen",
"     q: UnterdrÅcke alle Ausgaben       r: rekursive Datei-/Ordnersuche",
"     s: Wandle \\ in / um                t: Archivdatum setzen",
"     u: Ungepackt archivieren           v: Dateien mit anderem Prg ansehen",
"     w: Arbeitsverzeichnis bestimmen    x: Erweitere Dateinamen",
"     y: Nur Dateien mit Archiv-Bit      z: Archivkommentar eingeben",
"     A: Dateien an das Archiv anhÑngen  B: Backup vom Archiv erzeugen",
"     C: Keine PrÅfsummenÅberprÅfung     D: Dateien aus dem Archiv entfernen",
"     F: 5+3-Regel fÅr lange Dateinamen  I: Dateien in Verzeichnis packen",
"     K: Akustisches Signal am Ende      L: Speicherbedarf einstellen",
"     M: Maximale Dateigrîûe             N: Nur Dateien neuer als Datum ddmmyy",
"     O: nicht in Verzeichnis entpacken  P: Prozeûindikator-Zeichen",
"     R: Unix-Dateien manuell umbenennen S: Groû-/Kleinschreibung von Dateinamen",
"     U: Dateien ungepackt archivieren   W: Kein Wildcard-Matching",
"     X: Dateipfade relativ sichern      Y: VerschlÅsselung",
"     4: Ungepacktes Larc-Archiv         5: Erzwinge lh5-Archiv",
"     ?: Hilfsbildschirm ausgeben",
" Pfad;\ Dateipfad relativ sichern      ~,! Dateien ausschlieûen",
"    &,@ Pfade aus Datei einlesen     &-,@- Pfade von stdin eingeben",
" ==============================================================================",
"   ( Eine genauere Beschreibung finden Sie in der Anleitung 'MANUAL.GER' )",
"",
"  e-mail Yoshizaki: Nifty-Serve  PFF00253  /  oASCII-pcs   pcs02846",
0L
};
#endif

uchar M_UNKNOWNERR[] = "Unbekannter Fehler";
uchar M_INVCMDERR[]  = "Unbekanntes Kommando";
uchar M_MANYPATERR[] = "";
uchar M_NOARCNMERR[] = "Kein Archivname";
uchar M_NOFNERR[]    = "Kein Dateiname";
uchar M_NOARCERR[]   = "Archiv existiert nicht";
uchar M_RENAMEERR[]  = "Ich kann das Archiv nicht umbenennen";
uchar M_MKTMPERR[]   = "Ich kann die temporÑre Datei nicht erstellen";
uchar M_DUPFNERR[]   = "";
uchar M_TOOMANYERR[] = "";
uchar M_TOOLONGERR[] = "Pfadname ist zu lang";
uchar M_NOFILEERR[]  = "Keine Datei gefunden";
uchar M_MKFILEERR[]  = "Ich kann das Archiv nicht anlegen";
uchar M_RDERR[]      = "Ich kann die Datei nicht lesen";
uchar M_WTERR[]      = "Ich kann die Datei nicht schreiben";
uchar M_MEMOVRERR[]  = "Kein Speicher mehr frei";
uchar M_INVSWERR[]   = "";
uchar M_CTRLBRK[]    = "";
uchar M_NOMATCHERR[] = "Ich kann die Datei nicht finden";
uchar M_COPYERR[]    = "\r\nIch konnte die temporÑre Datei nicht in das Archiv kopieren";
uchar M_NOTLZH[]     = "Erweiterung des Archivs (%s) ist nicht 'LZH'.\r\nWollen Sie fortfahren? [J/N] ";
uchar M_OVERWT[]     = "Datei existiert. öberschreiben [J/N/Alle] oder Rename? ";
uchar M_ENTERNEW[]   = "Neuer Name:";
uchar M_MKDIR[]      = "Ordner anlegen? [J/N/Alle] ";
uchar M_MKDIRERR[]   = "Ich konnte den Ordner nicht anlegen";
uchar M_CRCERR[]     = "";
uchar M_RDONLY[]     = "Datei mit 'Nur lesen'-Status!";
uchar M_PRESSKEY[]   = "-- Mit Tastendruck gehts weiter --";
uchar M_COMMENT[]    = "Kommentar:";
uchar M_PATH[]       = "Pfade/Dateien (Wildcards erlaubt (*?@[^-|],)):";
uchar M_FILETAB[]    = "Datei-Tabelle voll. Ignoriere";
uchar M_BADTAB[]     = "\r Zerstîrte Tabelle/verschlÅsselte Datei ";
