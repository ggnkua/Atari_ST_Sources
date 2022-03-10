uchar title[] =
"\r\n LHarc "LZHVERSION" - gewidmet "PERSON"\r\n"
" Copyright (c) Yoshizaki, 1988-89, Grunenberg, Mandel, 1994\n";

#ifndef __SHELL__

uchar title_x[] =
"   LHarc Version "LZHVERSION" (Atari) - gewidmet "PERSON"\r\n"
"   (c) Haruyasu Yoshizaki, 1988-1989, Grunenberg, Mandel, 1994";

uchar use_1[] =
" ================================================================ "__DATE__" =\r\n"
" Aufruf: LHarc [<Kommando>] [{{-|/}{<Schalter>[-|+|0-3|<Option>]}}...] <Archiv>\r\n"
"         [{<Laufwerk>:[\\]}|{<Hauptverzeichnis>\\}] {[&|&-|~] <Pfade> ...}\r\n"
" ------------------------------------------------------------------------------\r\n"
"  <Kommando>\r\n"
"      a: Dateien an Archiv anfÅgen      u: Dateien, falls neuer, anfÅgen\r\n"
"    f,r: Dateien im Archiv erneuern     m: Datei in das Archiv schieben\r\n"
"      d: Dateien aus Archiv lîschen   e,x: Dateien aus Archiv extrahieren\r\n"
"      p: Dateien aus Archiv anzeigen  l,v: Dateiliste des Archivs\r\n"
"      t: Archiv testen                  c: Dateien fÅr AFX komprimieren\r\n"
" ------------------------------------------------------------------------------\r\n"
"  <Schalter>  (ACHTUNG: Die Bedeutung des d-Schalters wurde komplett geÑndert)\r\n"
"      r: rekursive Datei-/Ordnersuche   w: Arbeitsverzeichnis bestimmen\r\n"
"      x: Erweitere Dateinamen           m: Nachfragen ausschalten\r\n"
"      p: Unterscheide Ordnernamen       f: Ordner ebenfalls einpacken\r\n"
"      c: Kein Vergleich des Dateidatums i: Dateiattribute ignorieren\r\n"
"      a: Erlaube alle Dateiattribute    v: Dateien mit anderem Prg ansehen\r\n"
"      n: Prozessindikator einstellen    h: Warte auf Tastendruck vor Ende\r\n"
"      t: Archivdatum setzen             y: Nur Dateien mit Archiv-Bit packen\r\n"
"      b: Archiv-Bit der Dateien lîschen l: Erzeuge Larc-kompatibles Archiv\r\n"
"      q: UnterdrÅcke alle Ausgaben      o: Erzeuge 1.13-kompatibles Archiv\r\n"
"      u: Ungepackt archivieren          k: Header-Level (0-2)";

uchar use_2[] =
"\r      e: Dateikommentare eingeben       z: Archivkommentar eingeben\r\n"
"      d: Bearbeitete Dateien lîschen    C: Keine PrÅfsummenÅberprÅfung\r\n"
"      g: Archiv in Ordner auspacken     j: Dateien der LÑnge 0 ausschlieûen\r\n"
"      5: Erzwinge lh5-Archiv            4: Ungepacktes Larc-Archiv\r\n"
"      s: Wandle \\ in / um               P: Prozeû-Indikator-Zeichen\r\n"
"      L: Speicherbedarf einstellen      S: Groû-/Kleinschreibung von Dateinamen\r\n"
"      M: Maximale Dateigrîûe            N: Nur Dateien neuer als Datum ddmmyy\r\n"
"      U: Dateien ungepackt archivieren  R: Unix-Dateien manuell umbenennen\r\n"
"      I: Dateien in Verzeichnis packen  B: Backup vom Archiv erzeugen\r\n"
"      A: Dateien an das Archiv anhÑngen D: Dateien aus dem Archiv entfernen\r\n"
"      W: Kein Wildcard-Matching         X: Dateipfade relativ sichern\r\n"
"      Y: VerschlÅsselung                K: Akustisches Signal am Ende\r\n"
"      ?: Hilfsbildschirm ausgeben\r\n"
"  Pfad;\ Dateipfad relativ sichern     ~,! Dateien ausschlieûen\r\n"
"     &,@ Pfade aus Datei einlesen    &-,@- Pfade von stdin eingeben\r\n"
" ==============================================================================\r\n"
"   ( Eine genauere Beschreibung finden Sie in der Anleitung 'MANUAL.GER' )\r\n\n"
"  Yoshizaki  : Nifty-Serve  PFF00253\r\n"
"               oASCII-pcs   pcs02846\r\n"
"  Grunenberg : Christian Grunenberg @ S2 (Mausnet)\r\n"
"               Christian_Grunenberg@S2.maus.de (Inter-/Usenet)\r\n"
"               07062 - 5287 (Telefon)\n";

uchar use_3[] =
"\r LHarc ist inklusive aller Quelltexte Freeware. Dies bedeutet, daû das Pro-\r\n"
" gramm frei kopiert, getestet und benutzt werden darf. Wenn Ihnen LHarc aller-\r\n"
" dings gefÑllt und Sie regelmÑûig damit arbeiten, so sollten Sie den Autor\r\n"
" durch eine angemessene freiwillige Spende (ungefÑhr DM 20,- (SchÅler/Stu-\r\n"
" denten) bzw. DM 30,- (BerufstÑtige/Institute/Firmen)) unterstÅtzen, wodurch\r\n"
" auch die Weiterentwicklung gesichert wird. Den Betrag kînnen Sie entweder\r\n"
" auf mein Konto Åberweisen oder mir als Schein oder Scheck zusenden. Danke.\r\n\r\n"
" Bankverbindung:\r\n"
" ---------------\r\n"
"  Christian Grunenberg\r\n"
"  Kreissparkasse Heilbronn (Bankleitzahl: 62050000)\r\n"
"  Konto-Nummer: 3695041\r\n\r\n"
" Adresse:\r\n"
" --------\r\n"
"  Christian Grunenberg  -  Traminerweg 5  -  D-71717 Beilstein\r\n\n"
" WICHTIG:\r\n"
" ========\r\n"
"  FÅr die einwandfreie FunktionalitÑt von LHarc kann und will ich nicht\r\n"
"  garantieren und Åbernehme daher keinerlei Verantwortung fÅr SchÑden\r\n"
"  jeglicher Art, die von LHarc verursacht werden. Die Benutzung dieses\r\n"
"  Utilities erfolgt auf eigene Gefahr!";

#endif

uchar M_UNKNOWNERR[] =   "Unbekannter Fehler";
uchar M_INVCMDERR[]  =   "Unbekanntes Kommando";
uchar M_MANYPATERR[] =   "";
uchar M_NOARCNMERR[] =   "Kein Archivname";
uchar M_NOFNERR[]    =   "Kein Dateiname";
uchar M_NOARCERR[]   =   "Archiv existiert nicht";
uchar M_RENAMEERR[]  =   "Ich kann das Archiv nicht umbenennen";
uchar M_MKTMPERR[]   =   "Ich kann die temporÑre Datei nicht erstellen";
uchar M_DUPFNERR[]   =   "";
uchar M_TOOMANYERR[] =   "";
uchar M_TOOLONGERR[] =   "Pfadname ist zu lang";
uchar M_NOFILEERR[]  =   "Keine Datei gefunden";
uchar M_MKFILEERR[]  =   "Ich kann das Archiv nicht anlegen";
uchar M_RDERR[]      =   "Ich kann die Datei nicht lesen";
uchar M_WTERR[]      =   "Ich kann die Datei nicht schreiben";
uchar M_MEMOVRERR[]  =   "Kein Speicher mehr frei";
uchar M_INVSWERR[]   =   "";
uchar M_CTRLBRK[]    =   "";
uchar M_NOMATCHERR[] =   "Ich kann die Datei nicht finden";
uchar M_COPYERR[]    =   "\r\nIch konnte die temporÑre Datei nicht in das Archiv kopieren";
uchar M_NOTLZH[]     =   "Erweiterung des Archivs (%s) ist nicht 'LZH'.\r\nWollen Sie fortfahren ? [J/N]";
uchar M_OVERWT[]     =   "Datei existiert,öberschreiben [J/N/Alle] oder Rename?";
uchar M_ENTERNEW[]   =   "Neuer Name :";
uchar M_MKDIR[]      =   "Ordner anlegen ? [J/N/Alle]";
uchar M_MKDIRERR[]   =   "Ich konnte den Ordner nicht anlegen";
uchar M_CRCERR[]     =   "";
uchar M_RDONLY[]     =   "Datei mit 'Nur lesen'-Status !";
uchar M_PRESSKEY[]   =   "-- Mit Tastendruck gehts weiter --";
uchar M_COMMENT[]    =   "Kommentar :";
uchar M_PATH[]		 =	 "Pfade/Dateien (Wildcards erlaubt (*?@[^-|],)) :";
uchar M_FILETAB[]	 =	 "Datei-Tabelle voll. Ignoriere";
uchar M_BADTAB[]	 =	 "\r Zerstîrte Tabelle/verschlÅsselte Datei ";
