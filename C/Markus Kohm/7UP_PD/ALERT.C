/* Deutsche und englische Texte */
/*****************************************************************************
*
*                                   7UP
*                              Modul: ALERT.C
*                            (c) by TheoSoft '92
*
*****************************************************************************/
#ifndef ENGLISH

char *Agrepfile[]=
{
   "[2][Durchsuchung beenden?][Nein|Ja]",
   "[0][Suchen in Textdateien mit|regulÑren AusdrÅcken. Geben|Sie in der FSB das Start-|verzeichnis und das Such-|muster fÅr die Dateien an.][OK]",
   "[3][Das Suchmuster konnte nicht|richtig ausgewertet werden!][OK]",
   "[0][Das Ergebnis der Dateidurch-|suchung muû in einer Datei|*.REG abgelegt werden.][OK]",
   "[1][Nichts gefunden!][OK]",
   "[3][Die Datei %s konnte|nicht erzeugt werden!][OK]",
   "[0][\'.\' = beliebiges Zeichen|\'$\' = Zeilenende|\'*\' = 0-max Wiederholungen|\'+\' = 1-max Wiederholungen|\'\\\' = Sonderzeichenquotierung][Abbruch|Weiter]",
   "[0][\':a\' = Buchstabe|\':d\' = Ziffer|\':n\' = alphanumerisch|\':.\' = Interpunktion|\': \' = Leerzeichen][Abbruch|Weiter]",
   "[0][Zeichensatz in eckigen|Klammern: 0-9,a-z,^0-9,^a-z|z.B.: ^a-bd-z? sucht nur|\'c\', Ziffern, Satzzeichen,|auûer dem Fragezeichen.][OK]"
};

char *Aprinter[]=
{
   "[1][Drucker nicht bereit!][OK]",
   "[3][Spooler-DA nicht vorhanden!][OK]",
   "[1][Bitte neues Blatt einlegen.][Abbruch|OK]",
   "[3][Fehler in der Druckereinstellung.|Bitte in \"Seitenlayout...\" Ñndern.][OK]",
   "[2][Ausgabe beenden?][Nein|Ja]",
   "[3][Drucker nicht bereit!][Abbruch|OK]",
   "[0][Zum Spoolen muû CALCLOCK oder|1STGUIDE gebootet sein. Es |wird eine Spooldatei erzeugt,|die gelîscht werden kann.][OK]",
   "[3][Fehlerhafte Seitenangabe!][OK]",
   "[3][Fehlerhafte Spaltenangabe!][OK]",
   "[3][Fehlerhafte Kopienangabe!][OK]",
   "[3][Spooldatei konnte nicht|erzeugt werden!][OK]",
   "[3][Datei konnte nicht erzeugt werden!][OK]",
   "[0][%T=Tag, %M=Monat, %J=Jahr,|%h=Std., %m=Min., %s=Sek.,|%W=Wochentag, %D=Tag im Jahr,|%F=Pfadname, %f=Dateiname,|%p=Seitennummer][Abbruch|Weiter]",
   "[0][Papiergrîûe und Zeilenabstand|nur bei Druck Åber GDOS-Treiber.][OK]",
   "[3][Der Bildschirmfont liegt|nicht als Metafilefont vor.|Die Ausgabe wird abgebrochen.][OK]",
   "[3][Der Bildschirmfont liegt|nicht als Druckerfont vor.|Die Ausgabe wird abgebrochen.][OK]",
   "[3][GDOS-Kanal %d konnte|nicht geîffnet werden!][OK]",
   "[3][Kein GDOS vorhanden!][OK]"
};

char *Agrep[]=
{
   "[3][Das Suchmuster konnte nicht|richtig ausgewertet werden!][OK]"
};

char *Adesktop[]=
{
   "[3][UngÅltige Iconoperation!][OK]",
   "[1][Das Klemmbrett ist leer.][OK]",
   "[2][Klemmbrett drucken?][Abbruch|OK]",
   "[1][Das Klemmbrett ist schon auf Disk!][OK]",
};

char *Atabulat[]=
{
   "[1][Falsche Eingabe!][OK]"
};

char *Afontsel[]=
{
   "[0][Um GDOS-Fonts nachzuladen,|muû GDOS im Autoordner und|ASSIGN.SYS auf der Root der|Bootdisk installiert sein.|WÑhlen Sie Typ und Grîûe.][OK]",
   "[3][Zu wenig Speicher fÅr diese Aktion!][OK]",
   "[0][FontId: %d, FontSize: %d.][OK]"
};

char *Afbinfo[]=
{
   "[0][Bei markiertem Block, wird|eine entsprechende Information|Åber den Block ausgegeben.][OK]",
   "[0][Im Verlaufe der Arbeit mit 7UP|wurden %d Datei(en) gelîscht.][OK]",
   "[0][Der Drucker ist bereit.][OK]",
   "[0][Der Drucker ist nicht bereit.][OK]",
   "[0][Auf der Diskstation der Datei|\"%s\"|sind noch %ld Bytes frei.][OK]",
   "[0][Dies ist die Diskstation.][OK]",
   "[0][Auf dem Klemmbrett befinden|sich %d Datei(en) vom Typ|\"SCRAP.*\"][OK]",
   "[0][Das Klemmbrett ist leer.][OK]",
   "[1][Kein Unterschied (mehr).][OK]",
   "[1][Unterschied in:|%s|Zeile %ld Spalte %d.][OK]"
};

char *A7up[]=
{
   "[3][7UP.RSC?][Abort]",
   "[2][%s|wurde verÑndert.|Was soll geschehen?][_Verwerfen|Abbruch|Sichern]",
   "[2][%s|existiert nicht.|Neu anlegen?][Abbruch|OK]",
   "[3][%s|konnte nicht vollstÑndig|eingelesen werden.][OK]",
   "[3][%s|existiert nicht!][OK]",
   "[3][Zu wenig Speicher fÅr diese Aktion!][OK]",
   "[3][Die Fehlermeldung kann|nicht dargestellt werden,|weil die Infozeile fehlt.][OK]",
   "[1][Es liegt keine Fehlermeldung vor.][OK]",
   "[3][Keine Hilfe mîglich!|%s|nicht gefunden.][OK]",
   "[2][Arbeit sichern?|Alle Einstellungen werden in|der Datei 7UP.INF gesichert.][Abbruch|OK]",
   "[3][Die eingestellte Systemfontgrîûe ist|ungeeignet. Stellen Sie bitte eine|andere Fontgrîûe ein. 7UP wird beendet.|Siehe Handbuch \"Technische Details\".][Abort]"
};

char *Afkeys[]=
{
   "[0][%T=Tag, %M=Monat, %J=Jahr,|%h=Std., %m=Min., %s=Sek.,|%W=Wochentag, %D=Tag im Jahr,|%F=Pfadname, %f=Dateiname|\\f1-\\f0, \\F1-\\F0, \\t<Pfadname>][OK]",
   "[3][%s|konnte nicht vollstÑndig|eingelesen werden.][OK]",
   "[3][%s|existiert nicht!][OK]"
};

char *Asort[]=
{
   "[3][Nicht genÅgend Speicher|zum Sortieren frei!][OK]",
   "[0][Sortieren markierter Blîcke nach|Zeilen oder gruppenorientiert.|Mit Zeilen- oder Spaltenblock,|auf- oder absteigend sortiert.|Extrahilfe fÅr Gruppensortierung.][OK]",
   "[1][Markieren Sie nun die Gruppe|und îffnen den Dialog erneut.][OK]",
   "[1][Legen sie jetzt das Kriterium|innerhalb der Gruppe fest und|îffnen den Dialog erneut.][OK]",
   "[3][Block kein ganzzahliges|Vielfaches der Gruppe.][OK]"
};

char *Aconfig[]=
{
   "[0][Backupzeit 1-99 min.|Hilfe-Accessories:|TC_HELP, 1STGUIDE, ST-GUIDE.][OK]",
   "[3][UngÅltige Zeitangabe!][OK]",
   "[1][Vor Abmelden des Desktops|alle Icons îffnen oder|alle Dateien schlieûen.][OK]",
   "[2][Zeilenlineal fÅr %s|als %s...][_Laden...|_Sichern|Abbruch]",
   "[3][%s existiert nicht!][OK]",
   "[3][Kann Datei nicht schreiben!][OK]",
   "[3][Falsche Versionsnummer!][OK]",
   "[3][Kann Datei nicht lesen!][OK]",
   "[1][7UP.INF nicht gefunden.|Gesetzter Pfad:|%s|Falsches Environment?][OK]"
};

char *Aavprot[]=
{
   "[2][%s existiert nicht.|Neu anlegen?][Abbruch|OK]",
   "[3][AES Fehler:|öberlauf der Messagepipe!][OK]",
   "[3][7UP:|Bitte verÑnderte Texte sichern.][OK]",
   "[0][Meldung von CALCLOCK:|Druckauftrag erhalten.][OK]"
};

char *Ablock[]=
{
   "[3][Zu wenig Speicher|fÅr diese Aktion!][OK]"
};

char *Ashell[]=
{
   "[0][Der Shellaufruf funktioniert|nur mit einem Desktop, das|den Systemcall unterstÅtzt,|wie z.B. GEMINI/VENUS.][OK]",
   "[3][Kein Kommandointerpreter verfÅgbar!][OK]"
};

char *Aeditor[]=
{
   "[3][Zu wenig Speicher|fÅr diese Aktion!|Programm wird beendet!][OK]",
   "[0][GewÑhltes Zeichen:| ASCII: %c|  Dez.: %d|Sedez.: $%02X][Abbruch|_EinfÅgen]",
   "[3][Keine Hilfe mîglich!|%s nicht gefunden.][OK]",
   "[3][Die Fehlermeldung kann|nicht dargestellt werden,|weil die Infozeile fehlt.][OK]",
   "[1][Es liegt keine Fehlermeldung vor.][OK]",
   "[0][ZeicheneinfÅgen durch direktes Anklicken|mit der Maus. Mit Shiftaste zusÑtzliche|Informationen Åber das gewÑhlte Zeichen.][OK]",
   "[2][Wirklich den gesamten|Text Åbertippen?][Nein|Ja]"
};

char *Afindrep[]=
{
   "[0][Es gibt drei Sucharten:|NORMAL = normal|MATCH  = Suchen mit Wildcards|GREP   = RegulÑre AusdrÅcke][OK]",
   "[0][Allquantor: * =|   beliebig viele Zeichen|Existenzquantor: ? =|   ein beliebiges Zeichen|Die Wildcards sind editierbar.][OK]",
   "[0][\'.\' = beliebiges Zeichen|\'$\' = Zeilenende|\'*\' = 0-max Wiederholungen|\'+\' = 1-max Wiederholungen|\'\\\' = Sonderzeichenquotierung][Abbruch|Weiter]",
   "[0][\':a\' = Buchstabe|\':d\' = Ziffer|\':n\' = alphanumerisch|\':.\' = Interpunktion|\': \' = Leerzeichen][Abbruch|Weiter]",
   "[0][Zeichensatz in eckigen|Klammern: 0-9,a-z,^0-9,^a-z|z.B.: ^a-bd-z? sucht nur|\'c\', Ziffern, Satzzeichen,|auûer dem Fragezeichen.][OK]",
   "[3][Fehlerhafte Quantoren!][OK]",
   "[3][Das Suchmuster konnte nicht|richtig ausgewertet werden!][OK]",
   "[3][Die maximale ZeilenlÑnge|von %d Zeichen pro Zeile|wÑre hier Åberschritten!][OK]",
   "[1][Keine weiteren Textstellen gefunden.][OK]",
   "[1][Es wurden %ld Stellen ersetzt.][OK]",
   "[1][Falsche Eingabe!][OK]",
   "[0][Ein Doppelklick auf eine Klammer|im Text bewirkt einen Sprung zur|korrespondierenden Klammer incl.|automatischer Blockmarkierung.|Ausnahme: Kommentarklammern.][OK]",
   "[3][Fehler: geschweifte Klammer!|Differenz: %d][OK]",
   "[3][Fehler: eckige Klammer!|Differenz: %d][OK]",
   "[3][Fehler: runde Klammer!|Differenz: %d][OK]",
   "[3][Fehler: spitze Klammer!|Differenz: %d][OK]",
   "[3][Zu wenig Speicher fÅr diese Aktion!][OK]",
   "[3][Fehler: Pascal Kommentar!|Differenz: %d][OK]",
   "[3][Fehler: 'C'-Kommentar!|Differenz: %d][OK]",
   "[3][Fehler: X. freies Muster!|%d schlieûende Elemente fehlen.][OK]",
   "[3][Fehler: X. freies Muster!|%d îffnende Elemente fehlen.][OK]"
};

char *Anumerik[]=
{
/* 0*/   "[3][Das Klemmbrett konnte nicht|installiert werden!][OK]",
/* 1*/   "[0][Anzahl : %d][OK]",
/* 2*/   "[0][Summe : %0.2lf][OK]",
/* 3*/   "[0][Mittel: %0.2lf][OK]",
/* 4*/   "[3][Division durch Null!][OK]",
/* 5*/   "[0][Std.Abw.: %0.2lf][OK]",
/* 6*/   "[3][Standardabweichung nicht zu berechnen!][OK]",
/* 7*/   "[0][Mwst: %0.2lf][OK]",
/* 8*/   "[3][Mehrwertsteuer nicht zu berechnen!][OK]",
/* 9*/   "[0][Anzahl  : %d|Summe   : %0.2lf|Mittel  : %0.2lf|Std.Abw.: %0.2lf|Mwst    : %0.2lf][OK]",
/*10*/   "[3][Fehler beim Anlegen der Datei!][OK]",
/*11*/   "[0][7UP verarbeitet Dezimalpunkt und|Dezimalkomma. Die Nachkommastellen|und Tausenderseparatoren werden nur|im Dokument dargestellt.][Abbruch|Weiter]",
/*12*/   "[3][Fehlerhafte Angabe|der Mehrwertsteuer!][OK]",
/*13*/   "[0][Ergebnis: %0.2lf][OK]",
/*14*/   "[0][Gleichungen dÅrfen nur die vier|Grundrechenarten aufweisen.|0-9 . , + - * / ( ) =|Es sind 10 Klammerebenen mîglich.][OK]",
/*15*/   "[3][Gleichungsfehler an der %d. Stelle!][OK]",
/**/
/* Fehler beim Interpretieren */
/**/
/* 1:*/ "[3][Division durch Null!][OK]",
/* 2:*/ "[3][Ergebnis ist grî·er als|\"Obergrenze\".][OK]",
/* 3:*/ "[3][Ergebnis ist kleiner als|\"Untergrenze\".][OK]",
/* 4:*/ "[3][KlammerregisterÅberlauf.|(mehr als 30 offene Klammern)][OK]",
/* 5:*/ "[3][Zu viele schlieûende Klammern.][OK]",
/* 6:*/ "[3][Anzahl der îffnenden und|schlieûenden Klammern ist|ungleich.][OK]",
/* 7:*/ "[3][Unerlaubtes Zeichen bei Variablen.|zulÑssig: 0 bis 9,A-Z,+,-,*,/,)][OK]",
/* 8:*/ "[3][Unerlaubtes Zeichen nach Ziffer.|zulÑssig: 0 bis 9,+,-,*,/,),.][OK]",
/* 9:*/ "[3][Unerlaubtes Zeichen nach Operator.|zulÑssig: 0 bis 9,A-Z,+,-,(,.][OK]",
/*10:*/ "[3][Unerlaubtes Zeichen nach|einem Vorzeichen.|zulÑssig: 0 bis 9,A-Z,(,.][OK]",
/*11:*/ "[3][Unerlaubtes Zeichen nach|geîffneter Klammer.|zulÑssig: 0 bis 9,A-Z,+,-,(,),.][OK]",
/*12:*/ "[3][Unerlaubtes Zeichen nach|geschlossener Klammer.|zulÑssig: +,-,*,/,)][OK]",
/*13:*/ "[3][Unerlaubtes Zeichen am Stringanfang.|zulÑssig: 0 bis 9,A-Z,+,-,(,.][OK]",
/*14:*/ "[3][Unerlaubtes Zeichen nach|einer Konstanten.][OK]",
/*15:*/ "[3][Unerlaubtes Zeichen nach|einer Variablen.][OK]",
/*16:*/ "[3][Fehler bei der Wandlung|einer Konstanten.][OK]",
/*17:*/ "[3][Angegebene Variable ist nicht|in Variablenliste vorhanden.][OK]"

};

char *Aformat[]=
{
   "[3][Fehler beim Schreiben|der Datei! Disk voll?][OK]",
   "[3][Das Klemmbrett konnte nicht|installiert werden!][OK]",
   "[3][Fehler beim Anlegen der Datei!][OK]",
   "[1][Klemmbrett konnte nicht voll-|stÑndig eingelesen werden!][OK]",
   "[1][Das Klemmbrett ist leer!][OK]",
   "[1][Die Formatierung dieses Blocks|kînnte Probleme bereiten.|Leerzeilen bzw. gesamter Text.|Trotzdem formatieren?][Abbruch|OK]",
   "[3][Zu wenig Speicher fÅr diese Aktion!][OK]",
   "[2][Sind Sie sicher, daû die|eingestellte ZeilenlÑnge|korrekt ist?][Abbruch|OK]",
   "[0][ZeilenlÑngenverkÅrzung nur bei|Blocksatz. Text wird umformatiert.][OK]",
   "[3][Die neue ZeilenlÑnge ist zu kurz!][OK]"
};

char *Afileio[]=
{
/* 0*/  "[2][%s|énderungen sichern?][Nein|Ja]",
/* 1*/  "[3][%s|konnte nicht vollstÑndig|eingelesen werden.][OK]",
/* 2*/  "[3][%s|existiert nicht!][OK]",
/* 3*/  "[3][Kein Klemmbrett installiert!][OK]",
/* 4*/  "[3][Klemmbrett konnte nicht voll-|stÑndig eingelesen werden!][OK]",
/* 5*/  "[1][Das Klemmbrett ist leer!][OK]",
/* 6*/  "[3][Fataler Fehler!][CRASH]",
/* 7*/  "[3][Kein Fenster mehr verfÅgbar!][OK]",
/* 8*/  "[2][%s|existiert nicht.|Neu anlegen?][Abbruch|OK]",
/* 9*/  "[3][Kein Fenster mehr verfÅgbar!][OK]",
/*10*/  "[2][FÅr|%s|wurde eine|TemporÑrdatei gefunden. Soll|diese anstatt geladen werden?][Nein|Ja]",
/*11*/  "[3][Fehler beim Schreiben|der Datei! Disk voll?][OK]",
/*12*/  "[2][%s|existiert schon!|öberschreiben?][Abbruch|OK]",
/*13*/  "[2][Neuen Pfadnamen Åbernehmen?][Nein|Ja]",
/*14*/  "[1][Datei ist schreibgeschÅtzt!|Schreibschutz aufheben und|Åberschreiben?][Abbruch|OK]",
/*15*/  "[3][Unbekannter Fehler beim|Anlegen der Datei!][OK]",
/*16*/  "[3][Fehler beim Anlegen der Datei!][OK]",
/*17*/  "[3][Das Klemmbrett konnte nicht|installiert werden!][OK]",
/*18*/  "[3][Fehler beim Anlegen der Datei!][OK]",
/*19*/  "[2][%s|lîschen?][Nein|Ja]",
/*20*/  "[1][Datei(en) nicht gefunden!][OK]",
/*21*/  "[3][Die Fehlermeldung kann|nicht dargestellt werden,|weil die Infozeile fehlt.][OK]",
/*22*/  "[1][%s|nicht gefunden.][OK]",
/*23*/  "[1][Fehler beim Lîschen der Datei!][OK]",
/*24*/  "[3][Fehler beim Anlegen des Backups!][OK]"
/*25*/  "[3][Fehler beim Anlegen der Scrapdatei!][OK]",
};

char *Aundo[]=
{
   "[3][Zu wenig Speicher fÅr diese Aktion!|Daher leider kein UNDO mîglich!][OK]"
};

char *Apreview[]=
{
   "[0][Ein Mausklick in eine Seite|bewirkt einen \"Seitensprung\".][OK]",
   "[3][Zu wenig Speicher fÅr diese Aktion!][OK]"
};

char *Adeadkey[]=
{
   "[3][Zu wenig Speicher zum|Laden der Shortcuts!][OK]",
   "[2][Bitte den Shortcuttyp auswÑhlen.][_MenÅ...|_Tastatur...|Abbruch]",
   "[3][Vor dem Sichern der MenÅshortcuts|\"Let 'em Fly!\" kurz ausschalten.][OK]",
   "[2][Was soll mit den Shortcuts geschehen?][_éndern...|_Sichern...|_Laden...]",
   "[0][^=Control, Fn=Fkt.taste,|\007=Alt(Alt 7), \001=Shift(Alt 1).|Vermeiden Sie Doppelbelegung.|Beachten Sie im Handbuch das|Kapitel \"Die Shifttaste\".][OK]",
   "[0][Zweitstufige Tastaturshortcuts.|\"\\in = \index{~}\" mit dem Cursor|zwischen den Klammern.][OK]",
   "[0][Aufnahme und Wiedergabe|von TastendrÅcken.|RECORD = ALT-F7|STOP   = ALT-F8|PLAY   = ALT-F9][OK]"
};

char *Apicklist[]=
{
   "[0][Pickliste der bearbeiteten Dateien.|Nach Infoeingabe Datei markieren,|sonst wird die Info nicht gespeichert.][OK]",
   "[1][Die Pickliste ist leer!][OK]",
   "[3][Falsche Versionsnummer!][OK]"
};

char *Aregcode[]=
{
   "[3][Schwerer Fehler:|Registrierung fehlgeschlagen!|Falscher SchlÅssel.][OK]",
   "[1][Erfolgreich registriert fÅr:|%s|SchlÅssel: %s][OK]",
   "[3][Schwerer Fehler:|Registrierung fehlgeschlagen!|Dateischreibfehler.][OK]",
   "[3][Schwerer Fehler:|Registrierung fehlgeschlagen!|Patchstellen nicht gefunden.][OK]",
   "[3][Schwerer Fehler:|Registrierung fehlgeschlagen!|Zu wenig Arbeitsspeicher.][OK]",
   "[3][Schwerer Fehler:|Registrierung fehlgeschlagen!|Pfad zu 7UP extern verstellt.][OK]"
};

char *Amacrorec[]=
{
   "[3][Das erste Zeichen muû der|Wiederholungsfaktor 1-9 sein!][OK]",
   "[3][Kein Speicher mehr frei!][OK]"
};

char *Atoolbar[]=
{
	"[2][Tabulatorleiste zurÅcksetzen?][Nein|Ja]"
};

char *fselmsg[]=
{
   "Datei(en) hinzuladen",             /* 0*/
   "Hilfe Deskaccessory auswÑhlen",
   "Zeilenlineal laden",
   "Arbeit sichern",
   "Defaultwerte laden",
   "MenÅshortcuts sichern",
   "MenÅshortcuts laden",
   "Tastaturshortcuts laden",
   "Tastaturmakro sichern",
   "Tastaturmakro laden",
   "Datei îffnen",                     /*10*/
   "Datei sichern als",
   "Datei anhÑngen an",
   "Block sichern als",
   "Datei(en) lîschen",
   "Datei(en) îffnen",
   "Datei(en) îffnen",
   "Dateien markieren (max 7)",
   "Zieldatei angeben",
   "GEM-Metafile erzeugen",
   "In Datei drucken",                 /*20*/
   "Datei drucken",
   "Seitenlayout laden",
   "Seitenlayout sichern",
   "Programm starten",
   "Parameter Åbergeben",
   "Programm auswÑhlen",
   "Datei auswÑhlen",
   "Tastaturmakro laden",
   "Tastaturmakro sichern"             /*29*/
};

#else /****************************************************************/

char *Agrepfile[]=
{
   "[2][Quit searching?][No|Yes]",
   "[0][Searching in text file with regular|expressions. Select starting directory|and the pattern for the files.][OK]",
   "[3][Can't compile search pattern!][OK]",
   "[0][The result of searching will be|put into a file named *.REG.][OK]",
   "[1][Nothing found!][OK]",
   "[3][Can't create|%s!][OK]",
   "[0][\'.\' = beliebiges Zeichen|\'$\' = Zeilenende|\'*\' = 0-max Wiederholungen|\'+\' = 1-max Wiederholungen|\'\\\' = Sonderzeichenquotierung][Cancel|More]",
   "[0][\':a\' = Buchstabe|\':d\' = Ziffer|\':n\' = alphanumerisch|\':.\' = Interpunktion|\': \' = Leerzeichen][Cancel|More]",
   "[0][Character set in squared|brackets: 0-9,a-z,^0-9,^a-z|z.B.: ^a-bd-z? only searches for|\'c\', numbers, interpunctions,|without the question mark.][OK]"
};

char *Aprinter[]=
{
   "[1][Printer not ready!][OK]",
   "[3][Spooler accessory not found!][OK]",
   "[1][Please insert the next page.][Cancel|OK]",
   "[3][Error in printer installation.][OK]",
   "[2][Cancel output?][No|Yes]",
   "[3][Printer not ready!][Cancel|OK]",
   "[0][CALCLOCK or 1STGUIDE must be booted|for spooling. A spool file will be|created, which can be deleted afterwards.][OK]",
   "[3][Wrong value for page number!][OK]",
   "[3][Wrong value for column number!][OK]",
   "[3][Wrong value for copy number!][OK]",
   "[3][Can't create spool file!][OK]",
   "[3][Can't create file!][OK]",
   "[0][%T=day, %M=month, %J=year,|%h=hour, %m=min., %s=sec.,|%W=day of the week, %D=day of the year,|%F=pathname, %f=filename,|%p=page number][Cancel|More]",
   "[0][Paper size und line distance|only when printing with GDOS.][OK]",
   "[3][There is no metafile font|for the screen font.][OK]",
   "[3][There is no printer font|for the screen font.][OK]",
   "[3][Can't open GDOS channel %d!][OK]",
   "[3][No GDOS available!][OK]"
};

char *Agrep[]=
{
   "[3][Can't compile search pattern!][OK]"
};

char *Adesktop[]=
{
   "[3][Invalid icon operation!][OK]",
   "[1][Clipboard is empty.][OK]",
   "[2][Print clipboard?][Cancel|OK]",
   "[1][Clipboard is allready on disk.][OK]"
};

char *Atabulat[]=
{
   "[1][Wrong value for tab!][OK]"
};

char *Afontsel[]=
{
   "[0][To load GDOS-Fonts, GDOS must|be bootet in auto folder.|ASSIGN.SYS must be installed in|root. Select typ and size.][OK]",
   "[3][Out of memory!][OK]",
   "[0][FontId: %d, FontSize: %d.][OK]"
};

char *Afbinfo[]=
{
   "[0][If there is a block marked, you|get information about this block.][OK]",
   "[0][%d file(s) have been deleted|during the work with 7UP.][OK]",
   "[0][Printer is ready.][OK]",
   "[0][Printer is not ready.][OK]",
   "[0][%ld Bytes free.][OK]",
   "[0][This is the diskstation.][OK]",
   "[0][There are %d file(s) typed|\"SCRAP.*\" on clipboard.][OK]",
   "[0][Clipboard is empty.][OK]",
   "[1][No difference (any more).][OK]",
   "[1][Difference in:|%s|line %ld column %d.][OK]"
};

char *A7up[]=
{
   "[3][7UP.RSC?][_Abort]",
   "[2][%s|has been changed.|What should happen?][_Abort|Cancel|_Save]",
   "[2][%s|doesn't exist.|Create new?][Cancel|OK]",
   "[3][Can't read|%s|completely.][OK]",
   "[3][%s|doesn't exist.][OK]",
   "[3][Out of memory!][OK]",
   "[3][Can't display error message,|because window has no info line.][OK]",
   "[1][There is no error message.][OK]",
   "[3][No help possible!|%s not found.][OK]",
   "[2][Save preferences?|Setup will be saved in 7UP.INF.][Cancel|OK]",
   "[3][7UP can't work with the installed|system fontsize. Install a different|size. 7UP will be finished.|See documentation \"Technical details\".][_Abort]"
};

char *Afkeys[]=
{
   "[0][%T=day, %M=month, %J=year,|%h=hour, %m=min., %s=sec.,|%W=day of the week, %D=day of the year,|%F=pathname, %f=filename|\\f1-\\f0, \\F1-\\F0, \\t<pathname>][OK]",
   "[3][Can't read|%s|completely.][OK]",
   "[3][%s|doesn't exist.][OK]"
};

char *Asort[]=
{
   "[3][Out of memory!][OK]",
   "[0][Sortieren markierter Blîcke nach|Zeilen oder gruppenorientiert.|Mit Zeilen- oder Spaltenblock,|auf- oder absteigend sortiert.|Extrahilfe fÅr Gruppensortierung.][OK]",
   "[1][Now select the group|and open the dialog again.][OK]",
   "[1][Select the criterion within the|group and open the dialog again.][OK]",
   "[3][Block is not a multiple|of the selected group.][OK]"
};

char *Aconfig[]=
{
   "[0][BACKUPTIME 1-99 min.|HELP-Accessories:|TC-HELP, 1STGUIDE, ST-GUIDE.][OK]",
   "[3][Invalid value for backup time!][OK]",
   "[1][Close all files before|switching off the desktop.][OK]",
   "[2][Line ruler for %s|as %s...][_Load...|_Save|Cancel]",
   "[3][%s|doesn't exist!][OK]",
   "[3][Can't write file!][OK]",
   "[3][Wrong version number!][OK]",
   "[3][Can't read file!][OK]",
   "[1][7UP.INF not found.|Set path:|%s|Wrong environment?][OK]"
};

char *Aavprot[]=
{
   "[2][%s|doesn't exist.|Create new?][Cancel|OK]",
   "[3][AES error:|Message pipe overflow!][OK]",
   "[3][Save changed files.][OK]",
   "[0][Message from CALCLOCK:|Print job received.][OK]"
};

char *Ablock[]=
{
   "[3][Out of memory!][OK]"
};

char *Ashell[]=
{
   "[0][Shell call only works with a desktop|that supports the system call.|For example GEMINI.][OK]",
   "[3][No commandline interpreter available!][OK]"
};

char *Aeditor[]=
{
   "[3][Out of memory!|It is not possible to save files!|Program must be aborted|to avoid total crash!][OK]",
   "[0][Chosen character:| ASCII: %c|  Dec.: %d|  Hex.: $%02X][Cancel|_Insert]",
   "[3][No help possible!|%s not found.][OK]",
   "[3][Can't display error message,|because there is no info line.][OK]",
   "[1][There is no error message.][OK]",
   "[0][Insert character by double clicking|with the mouse. Additional information|with pressed shift key.][OK]",
   "[2][Really overwrite whole text?][No|Yes]"
};

char *Afindrep[]=
{
   "[0][There are three search modes:|NORMAL = normal|MATCH  = searching with wildcards|GREP   = Regular expressions][OK]",
   "[0][Allquantor: * =|   beliebig viele Zeichen|Existenzquantor: ? =|   ein beliebiges Zeichen|Wildcards are editable.][OK]",
   "[0][\'.\' = beliebiges Zeichen|\'$\' = Zeilenende|\'*\' = 0-max Wiederholungen|\'+\' = 1-max Wiederholungen|\'\\\' = Sonderzeichenquotierung][Cancel|More]",
   "[0][\':a\' = letter|\':d\' = number|\':n\' = alpha numeric|\':.\' = interpunction|\': \' = blank][Cancel|More]",
   "[0][Character set in squared|brackets: 0-9,a-z,^0-9,^a-z|z.B.: ^a-bd-z? only searches for|\'c\', numbers, interpunctions,|without the question mark.][OK]",
   "[3][Wrong wildcards!][OK]",
   "[3][Can't compile search pattern!][OK]",
   "[3][The maximum linelength|of %d characters per line|would be exceeded here!][OK]",
   "[1][No more positions found.][OK]",
   "[1][%ld positions have been replaced.][OK]",
   "[1][Wrong value!][OK]",
   "[0][Double clicking a bracket causes a|jump to the corresponding bracket|including a marking a block.|Exception: comment brackets.][OK]",
   "[3][Fehler: geschweifte Klammer!|Differenz: %d][OK]",
   "[3][Fehler: eckige Klammer!|Differenz: %d][OK]",
   "[3][Fehler: runde Klammer!|Differenz: %d][OK]",
   "[3][Fehler: spitze Klammer!|Differenz: %d][OK]",
   "[3][Out of memory!][OK]",
   "[3][Fehler: Pascal Kommentar!|Differenz: %d][OK]",
   "[3][Fehler: 'C'-Kommentar!|Differenz: %d][OK]",
   "[3][Fehler: X. freies Muster!|%d schlieûende Elemente fehlen.][OK]",
   "[3][Fehler: X. freies Muster!|%d îffnende Elemente fehlen.][OK]"
};

char *Anumerik[]=
{
/* 0*/   "[3][Can't create clipboard!][OK]",
/* 1*/   "[0][Amount: %d][OK]",
/* 2*/   "[0][Sum   : %0.2lf][OK]",
/* 3*/   "[0][Mean  : %0.2lf][OK]",
/* 4*/   "[3][Division by zero!][OK]",
/* 5*/   "[0][Std. Dev.: %0.2lf][OK]",
/* 6*/   "[3][Can't calculate standard deviation!][OK]",
/* 7*/   "[0][Tax   : %0.2lf][OK]",
/* 8*/   "[3][Can't calculate tax!][OK]",
/* 9*/   "[0][Anzahl  : %d|Summe   : %0.2lf|Mittel  : %0.2lf|Std.Abw.: %0.2lf|Mwst    : %0.2lf][OK]",
/*10*/   "[3][Can't create file!][OK]",
/*11*/   "[0][7UP verarbeitet Dezimalpunkt und|Dezimalkomma. Die Nachkommastellen|und Tausenderseperatoren werden nur|im Dokument dargestellt.][Cancel|More]",
/*12*/   "[3][Wrong value for tax!][OK]",
/*13*/   "[0][Result: %0.2lf][OK]",
/*14*/   "[0][Gleichungen dÅrfen nur die vier|Grundrechenarten aufweisen.|0-9 . , + - * / ( ) =|Es sind 10 Klammerebenen mîglich.][OK]",
/*15*/   "[3][Gleichungsfehler an der %d. Stelle!][OK]",
/**/
/* Fehler beim Interpretieren */
/**/
/* 1:*/ "[3][Division by zero.][OK]",
/* 2:*/ "[3][Result is higher than upper border.][OK]",
/* 3:*/ "[3][Result is lower then lower border.][OK]",
/* 4:*/ "[3][Too many brackets (max. 30).][OK]",
/* 5:*/ "[3][Too many closing brackets.][OK]",
/* 6:*/ "[3][Difference between opening|and closing brackets.][OK]",
/* 7:*/ "[3][Unerlaubtes Zeichen bei Variablen.|zulÑssig: 0 bis 9,A-Z,+,-,*,/,)][OK]",
/* 8:*/ "[3][Unerlaubtes Zeichen nach Ziffer.|zulÑssig: 0 bis 9,+,-,*,/,),.][OK]",
/* 9:*/ "[3][Unerlaubtes Zeichen nach Operator.|zulÑssig: 0 bis 9,A-Z,+,-,(,.][OK]",
/*10:*/ "[3][Unerlaubtes Zeichen nach|einem Vorzeichen.|zulÑssig: 0 bis 9,A-Z,(,.][OK]",
/*11:*/ "[3][Unerlaubtes Zeichen nach|geîffneter Klammer.|zulÑssig: 0 bis 9,A-Z,+,-,(,),.][OK]",
/*12:*/ "[3][Unerlaubtes Zeichen nach|geschlossener Klammer.|zulÑssig: +,-,*,/,)][OK]",
/*13:*/ "[3][Unerlaubtes Zeichen am Stringanfang.|zulÑssig: 0 bis 9,A-Z,+,-,(,.][OK]",
/*14:*/ "[3][Unerlaubtes Zeichen nach|einer Konstanten.][OK]",
/*15:*/ "[3][Unerlaubtes Zeichen nach|einer Variablen.][OK]",
/*16:*/ "[3][Error converting a constant.][OK]",
/*17:*/ "[3][This variable is not in list.][OK]"

};

char *Aformat[]=
{
   "[3][Can't create file!|Disk full?][OK]",
   "[3][Can't create clipboard!][OK]",
   "[3][Can't create file!][OK]",
   "[1][Can't read clipboard completely!][OK]",
   "[1][Clipboard is empty!][OK]",
   "[1][Formatting this block will cause problems.|Empty lines or whole text. Proceed?][Cancel|OK]",
   "[3][Out of memory!][OK]",
   "[2][Are you sure, that the|linelength is correct?][Cancel|OK]",
   "[0][Do not change line length|without using block format.][OK]",
   "[3][The new line length ist too short!][OK]"
};

char *Afileio[]=
{
/* 0*/  "[2][%s|Save changes?][No|Yes]",
/* 1*/  "[3][Can't read|%s|completely.][OK]",
/* 2*/  "[3][%s|doesn't exist!][OK]",
/* 3*/  "[3][No clipboard installed!][OK]",
/* 4*/  "[3][Can't read clipboard completely!][OK]",
/* 5*/  "[1][Clipboard is empty!][OK]",
/* 6*/  "[3][Fatal Error!][CRASH]",
/* 7*/  "[3][No more window available!][OK]",
/* 8*/  "[2][%s|doesn't exist.|Create new?][Cancel|OK]",
/* 9*/  "[3][No more window available!][OK]",
/*10*/  "[2][There ist a temporary file for|%s.|Load this file?][No|Yes]",
/*11*/  "[3][Can't create file!|Disk full?][OK]",
/*12*/  "[2][%s|allready exist!|Overwrite?][Cancel|OK]",
/*13*/  "[2][Take over new pathname?][No|Yes]",
/*14*/  "[1][File is write protected!|Disable protection and overwrite?][Cancel|OK]",
/*15*/  "[3][Can't create file!][OK]",
/*16*/  "[3][Can't create file!][OK]",
/*17*/  "[3][Can't create clipboard!][OK]",
/*18*/  "[3][Can't create file!][OK]",
/*19*/  "[2][Delete|%s?][No|Yes]",
/*20*/  "[1][File(s) not found!][OK]",
/*21*/  "[3][Can't display error message,|because there is no info line.][OK]",
/*22*/  "[1][%s|not found.][OK]",
/*23*/  "[1][Can't delete file!][OK]",
/*24*/  "[3][Can't create backup!][OK]",
/*25*/  "[3][Can't create clipboard file!][OK]"
};

char *Aundo[]=
{
   "[3][Out of memory!|No UNDO possible!][OK]"
};

char *Apreview[]=
{
   "[0][Double clicking into a page|causes a jump to the page.][OK]",
   "[3][Out of memory!][OK]"
};

char *Adeadkey[]=
{
   "[3][Not enough memory to load shortcuts!][OK]",
   "[2][Choose typ of shortcut.][_Menue...|_Keyboard...|Cancel]",
   "[3][Switch off \"Let 'em Fly!\".][OK]",
   "[2][What should happen with the shortcuts?][_Change...|_Save...|_Laden...]",
   "[0][^=Control, Fn=Softkey,|\007=Alt(Alt 7), \001=Shift(Alt 1).|See documentation \"Shiftkey\".][OK]",
   "[0][Two step keyboard shortcuts.|\"\\in = \index{~}\" with the cursor|between the brackets.][OK]",
   "[0][Keystroke recorder.|RECORD = ALT-F7|STOP   = ALT-F8|PLAY   = ALT-F9][OK]"
};

char *Apicklist[]=
{
   "[0][The picklist contains edited files.|Select an entry after editing the|infoline, otherwise information will|not be saved.][OK]",
   "[1][The picklist is empty!][OK]",
   "[3][Wrong version number!][OK]"
};

char *Aregcode[]=
{
   "[3][Registration failed!|Wrong key.][OK]",
   "[1][Successfully registrated for:|%s|Key: %s][OK]",
   "[3][Registration failed!|File error.][OK]",
   "[3][Registration failed!|Can't find patch positions.][OK]",
   "[3][Registration failed!|Out of memory!][OK]",
   "[3][Registration failed!|Path to 7UP externally changed.][OK]"
};

char *Amacrorec[]=
{
   "[3][The first character must be|the repetition factor 1-9!][OK]",
   "[3][Out of memory!][OK]"
};

char *Atoolbar[]=
{
	"[2][Reset tabulator bar?][No|Yes]"
};


char *fselmsg[]=
{
   "Insert file(s)",             /* 0*/
   "Select help accessory",
   "Load ruler",
   "Save preferences",
   "Load defaults",
   "Save menue shortcuts",
   "Load menue shortcuts",
   "Load keyboard shortcuts",
   "Save keyboard macro",
   "Load keyboard macro",
   "Open file",                     /*10*/
   "Save file as",
   "Append file to",
   "Save block as",
   "delete file(s)",
   "Open file(s)",
   "Open file(s)",
   "Select files (max. 7)",
   "Select destination file",
   "Create GEM-Metafile",
   "Print in file",                 /*20*/
   "Print file",
   "Load page layout",
   "Save page layout",
   "Start program",
   "Parameters",
   "Select program",
   "Select file",
   "Load keyboard macro",
   "Save keyboard macro"             /*29*/
};

#endif
