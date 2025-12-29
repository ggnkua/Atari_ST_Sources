{///////////////////////////////////////////////////////////////////////////}
{/                                                                         /}
{/  PASCAL-HELP : Vereinigt  die Leistungen zweier meiner  bereits frÅher  /}
{/                realisierten Pascal-Hilfs-Programmen, die einen Pascal-  /}
{/                Source-Text nach den darin enthaltenen SchlÅsselwîrtern  /}
{/  Version 1.20  ( RESERVED WORDS ) und  Identifiern ( Namen von  Typen,  /}
{/  vom 16.08.87  Konstanten,  Variablen,  Unterprogrammen etc. )  unter-  /}
{/                sucht.                                                   /}
{/                Die Ausgabe kann auf grundsÑtzlich 2 verschiedene Arten  /}
{/                erfolgen, die das  erstellen von Pascal- Programmen er-  /}
{/                erleichtern sollen :                                     /}
{/                                                                         /}
{/              - Es kann eine Cross-Referenz-Liste  erstellt werden, die  /}
{/                die im Text  enthaltenen Identifier zunÑchst nach ihrem  /}
{/                Pascal-Sinn (unabhÑngig von Groû- und  Kleinschreibung)  /}
{/                und erst in  zweiter Linie nach ihrer Schreibweise sor-  /}
{/                tiert und  sie mit den  Zeilennummern ihres  Vorkommens  /}
{/                in einer Datei mit der Extension .XRF oder .XRT ausgibt  /}
{/                                                                         /}
{/              - Die  Source kann so  bearbeitet  werden, daû die  darin  /}
{/                enthaltenen SchlÅsselwîrter in Groûbuchstaben geschrie-  /}
{/                ben werden und so zur besseren Lesbarkeit des Programms  /}
{/                beigetragen wird.                                        /}
{/                Die  ursprÅngliche  Fassung der  Source  wird in  einer  /}
{/                Datei mit der Extension .ALT abgelegt.                   /}
{/                                                                         /}
{/  Dieses PUBLIC DOMAIN Programm wurde 1986 mit ST Pascal plus von CCD    /}
{/  entwickelt und 1987 erweitert von                                      /}
{/                                                   ERHARD SCHWARTZ       /}
{/                                                   Isaraustraûe 8        /}
{/                                               D - 8192 Geretsried 1     /}
{/                                                                         /}
{/                                                                         /}
{/  NEU : Um auch  AnfÑngern und Umsteigern den  Einstieg in diese schîne  /}
{/        Programmiersprache  zu  erleichtern, sind  ab sofort  auch  die  /}
{/        Pascal-Sources meiner Programme PUBLIC DOMAIN.                   /}
{/        Sollte  jedoch jemand dieses Programm selbst oder zumindest die  /}
{/        Source als Anregung fÅr eigene Programme gut gebrauchen kînnen,  /}
{/        so bitte ich um  öberweisung eines kleinen Unkostenbeitrags auf  /}
{/        folgendes Konto:                                                 /}
{/        Kreissparkasse Wolfratshausen, BLZ 70054306, Konto-Nr. 670588    /}
{/                                                                         /}
{///////////////////////////////////////////////////////////////////////////}

{$S50}{ Heap und Stack belegen 50 kByte; siehe auch Anmerkung weiter unten }
{$D-} { Ohne Debug                           }
{$P-} { Keine öberprÅfung von Zeigern        }
{$R-} { Keine UnterbereichsprÅfung           }
{$T+} {       öberprÅfung von Heap und Stack }


PROGRAM PASCAL_HELP_by_ERHARD_SCHWARTZ;

CONST {$I GEMCONST.INC}
      VERSION           = '1.20';
      MAX_C_STRING_LEN  = 81;
      HINTERGRUND_MUSTER= 17;
      BOX_LEN           = 48;

TYPE  {$I GEMTYPE.INC}
      c_string  = PACKED ARRAY[1..MAX_C_STRING_LEN] OF CHAR;

      dtabuftyp = RECORD                { Struktur des DTA-Puffers }
                    dos  : PACKED ARRAY[0..21] OF CHAR;
                    time,
                    date : INTEGER;
                    size : LONG_INTEGER;
                    name : PACKED ARRAY[1..14] OF CHAR;
                  END;

VAR drive       : CHAR;         { Einige globale Variablen }
    t,
    kein_name   : str255;
    mist,
    wahl        : INTEGER;
    source_name : path_name;

    dl                  : dialog_ptr;   { Namen aus dem Dialogfeld }
    source_name_box,                    { "mist" fÅr alle Objekte, die }
    quelle_btn,                         { nicht mehr geÑndert werden }
    start_btn,
    cancel_btn,
    tempus_btn,
    res_gross_btn       : INTEGER;

    tempus_ausgabe,                     { Flags zur Kommunikation }
    res_gross_ausgabe   : BOOLEAN;

    fenster,                            { Daten des Hintergrundfensters }
    fenst_x,
    fenst_y,
    fenst_w,
    fenst_h      : INTEGER;
    fenstername  : window_title;


{///////////////////////////////////////////////////////////////////////////}
{///  Definition der benîtigten GEMDOS- und Bibliotheks-Routinen   /////////}
{///////////////////////////////////////////////////////////////////////////}

{$I GEMSUBS.INC}

FUNCTION  get_drive : INTEGER;                                   GEMDOS($19);
PROCEDURE set_dta( VAR dta_puffer : dtabuftyp);                  GEMDOS($1A);
FUNCTION  fcreate( VAR filnam: c_string; att: INTEGER): INTEGER; GEMDOS($3C);
FUNCTION  fopen  ( VAR filnam: c_string; att: INTEGER): INTEGER; GEMDOS($3D);
FUNCTION  fclose ( handle : INTEGER)                  : INTEGER; GEMDOS($3E);
FUNCTION  fread  ( handle : INTEGER; count : LONG_INTEGER;
                   buffer : LONG_INTEGER)        : LONG_INTEGER; GEMDOS($3F);
FUNCTION  fwrite ( handle : INTEGER; count : LONG_INTEGER;
                   buffer : LONG_INTEGER)        : LONG_INTEGER; GEMDOS($40);
FUNCTION  fdelete( VAR filnam: c_string)              : INTEGER; GEMDOS($41);
FUNCTION  malloc ( amount : LONG_INTEGER) : LONG_INTEGER;        GEMDOS($48);
FUNCTION  mfree  ( adress : LONG_INTEGER) : INTEGER;             GEMDOS($49);
FUNCTION  fsfirst( VAR p : c_string; att : INTEGER)   : INTEGER; GEMDOS($4E);
FUNCTION  frename( zero:INTEGER; VAR p1,p2: c_string) : INTEGER; GEMDOS($56);


{///////////////////////////////////////////////////////////////////////////}
{///  Hier werden einige Voreinstellungen gemacht   ////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE initialisiere;
VAR i   : INTEGER;
BEGIN
  drive := chr( get_drive + 65);                { Laufwerk erfragen }

  kein_name := ' ??? keine Angabe ??? ';
  FOR i := (length( kein_name) + 1) TO BOX_LEN  { FÅllen mit Space }
  DO kein_name[i] := ' ';                       { und LÑnge korrigieren }
  kein_name[0] := chr( BOX_LEN);                { Sonst Absturz, wenn }
                                                { der Pfad lÑnger ist }
  source_name  := '';
END; { procedure initialisiere }


{///////////////////////////////////////////////////////////////////////////}
{///   Umwandlung eines Pascal-Strings in einen C-String   /////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE pas_to_c_path( pas_path : path_name; VAR c_path : c_string);
VAR i : INTEGER;
BEGIN
  FOR i := 1 TO length( pas_path) DO c_path[i] := pas_path[i];
  c_path[ length( pas_path) + 1] := #0;         { Abschluû mit ASCII NUL }
END; { procedure pas_to_c_path }


{///////////////////////////////////////////////////////////////////////////}
{///   Lîscht die Extension eines Dateinamens   ////////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE delete_extension( VAR path : path_name );
VAR i, punkt  : INTEGER;
BEGIN
  i := length( path);                           { Von hinten anfangen }
  punkt := 0;
  LOOP
    IF path[i] = '.' THEN punkt := i;
  EXIT IF ( punkt > 0 ) OR ( path[i] = '\' ) OR ( i = 1 );
    i := i - 1;
  END; { loop }
  IF punkt > 0 THEN path[0] := chr( punkt - 1); { LÑnge auf den Buchstaben }
END; { procedure delete_extension }             { vor dem Punkt setzen }


{///////////////////////////////////////////////////////////////////////////}
{///   Es wird geprÅft, ob eine Datei schon existiert   ////////////////////}
{///////////////////////////////////////////////////////////////////////////}

FUNCTION exist( filnam : path_name) : BOOLEAN;
VAR path : c_string;
BEGIN { function exist }
  pas_to_c_path( filnam, path);
  exist := fsfirst( path, 0) = 0;
END; { function exist }


{///////////////////////////////////////////////////////////////////////////}
{///   EnthÑlt die Liste der RESERVED WORDS   //////////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

FUNCTION reserviert(VAR w : str255) : BOOLEAN;  { Erwartet String mit Maxi- }
BEGIN                                           { mallÑnge, damit auch der  }
  reserviert := FALSE;                          { lÑngste Name hineinpaût   }
  CASE length(w) OF
  1 : IF (w='C') THEN reserviert := TRUE;
  2 : IF (w='DO') OR (w='IF') OR (w='IN') OR (w='OF') OR (w='OR') OR (w='TO')
      THEN reserviert := TRUE;
  3 : IF (w='AND') OR (w='DIV') OR (w='END') OR (w='FOR') OR (w='MOD') OR
         (w='NOT') OR (w='SET') OR (w='VAR') OR
         (w='NIL')
      THEN reserviert := TRUE;
  4 : IF (w='BIOS') OR (w='CASE') OR (w='ELSE') OR (w='EXIT') OR (w='FILE')OR
         (w='GOTO') OR (w='LOOP') OR (w='THEN') OR (w='TYPE') OR (w='WITH')OR
         (w='ALFA') OR (w='BYTE') OR (w='CHAR') OR (w='REAL') OR (w='TEXT')OR
         (w='TRUE')
      THEN reserviert := TRUE;
  5 : IF (w='ARRAY') OR (w='BEGIN') OR (w='CONST') OR (w='LABEL') OR
         (w='UNTIL') OR (w='WHILE') OR (w='XBIOS') OR (w='FALSE')
      THEN reserviert := TRUE;
  6 : IF (w='DOWNTO') OR (w='GEMDOS') OR (w='PACKED') OR (w='RECORD') OR
         (w='REPEAT') OR
         (w='STRING')
      THEN reserviert := TRUE;
  7 : IF  (w='FORWARD') OR (w='PROGRAM') OR ( w='BOOLEAN') OR (w='INTEGER')
      THEN reserviert := TRUE;
  8 : IF (w='EXTERNAL') OR (w='FUNCTION')
      THEN reserviert := TRUE;
  9 : IF (w='OTHERWISE') OR (w='PROCEDURE')
      THEN reserviert := TRUE;
 11 : IF (w='LONG_MAXINT')
      THEN reserviert := TRUE;
 12 : IF (w='LONG_INTEGER')
      THEN reserviert := TRUE;
  END; { CASE - Anweisung }
END; { function reserviert }


{///////////////////////////////////////////////////////////////////////////}
{///   Hier wird das Dialogfeld zusammengebaut   ///////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE baue_dialog;
CONST RA_ST_0   =  0;           { Rahmen-StÑrken}
      RA_ST_2I  =  2;
      NORM_FA   = $1181;        { Rahmen, Text und Muster sw, Text drÅber }
      MAX_D_ITEMS = 15;         { Maximale Zahl der Objekte }

BEGIN { baue_dialog }

dl      := new_dialog( MAX_D_ITEMS, 0, 0, 70, 16);

{ Variable mist fÅr alle Objekte, auf die spÑter nicht Bezug genommen wird }

mist    := add_ditem( dl, G_IBOX, NONE, 2, 1, 66, 5, RA_ST_2I, NORM_FA);
           obj_setstate ( dl, mist, OUTLINED , FALSE);

mist    := add_ditem( dl, G_TEXT, NONE, 2, 1, 66, 2, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           t := concat( 'PASCAL-HELP V ', VERSION,
                         '  * PUBLIC DOMAIN *  1986/87 by E. SCHWARTZ');
           set_dtext ( dl, mist, t, SYSTEM_FONT, TE_CENTER);

mist    := add_ditem(dl, G_TEXT, NONE, 2, 3, 66, 1, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           t := concat( 'ENTWICKELT MIT ST PASCAL PLUS VON CCD. KLEINE ',
                        'UNKOSTENBEITRéGE FöR DIESES PROGRAMM');
           set_dtext ( dl, mist, t, SMALL_FONT, TE_CENTER);

mist    := add_ditem( dl, G_TEXT, NONE, 2, 4, 66, 1, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           t := concat( 'WERDEN JEDERZEIT GERNE ENTGEGENGENOMMEN VON :   ',
                        'ERHARD SCHWARTZ, ISARAUSTRASSE 8,');
           set_dtext ( dl, mist, t, SMALL_FONT, TE_CENTER);

mist    := add_ditem( dl, G_TEXT, NONE, 2, 5, 66, 1, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           t := concat( 'D - 8192 GERETSRIED 1.  KONTO-NR. 670588, ',
                        'KREISSPARK. WOLFRATSHAUSEN, BLZ 70054306');
           set_dtext ( dl, mist, t, SMALL_FONT, TE_CENTER);

quelle_btn := add_ditem( dl, G_BUTTON, SELECTABLE | EXIT_BTN, 2, 8, 16, 2,
                         RA_ST_0, NORM_FA);
              obj_setstate ( dl, quelle_btn , OUTLINED, FALSE);
              set_dtext ( dl, quelle_btn, 'Quell-Datei ...', SYSTEM_FONT,
                          TE_CENTER);

source_name_box := add_ditem( dl, G_TEXT, NONE,20, 8, BOX_LEN, 2,
                              RA_ST_0, NORM_FA);
                   obj_setstate ( dl, source_name_box, NORMAL, FALSE);
                   set_dtext( dl, source_name_box, kein_name, SYSTEM_FONT,
                              TE_LEFT);

mist    := add_ditem(dl, G_TEXT, NONE, 2, 12, 9, 1, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           set_dtext ( dl, mist, 'Art der', SYSTEM_FONT, TE_LEFT);

mist    := add_ditem(dl, G_TEXT, NONE, 2, 14, 9,  1, RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, NORMAL, FALSE);
           set_dtext ( dl, mist, 'Ausgabe :', SYSTEM_FONT, TE_LEFT);

tempus_btn:= add_ditem( dl, G_BUTTON, SELECTABLE | RADIO_BTN, 12, 12, 14, 1,
                        RA_ST_0, NORM_FA);
             obj_setstate ( dl, tempus_btn, OUTLINED, FALSE);
             set_dtext (dl,tempus_btn,'Tempus-X-REF',SYSTEM_FONT,TE_CENTER);

mist    := add_ditem( dl, G_BUTTON, SELECTABLE | RADIO_BTN, 28, 12, 14, 1,
                      RA_ST_0, NORM_FA);
           obj_setstate ( dl, mist, OUTLINED, FALSE);
           set_dtext ( dl, mist, 'Normal-X-REF', SYSTEM_FONT, TE_CENTER);

res_gross_btn := add_ditem( dl, G_BUTTON, SELECTABLE|RADIO_BTN,12,14,30,1,
                            RA_ST_0, NORM_FA);
                 obj_setstate ( dl,res_gross_btn, OUTLINED|SELECTED, FALSE);
                 set_dtext ( dl, res_gross_btn, 'SchlÅsselwîrter in GROSS',
                             SYSTEM_FONT, TE_CENTER);

start_btn  := add_ditem( dl, G_BUTTON, SELECTABLE | EXIT_BTN, 46, 12, 12, 3,
                         RA_ST_0, NORM_FA);
              obj_setstate(dl,start_btn, OUTLINED|SHADOWED|DISABLED, FALSE);
              set_dtext (dl,start_btn, 'Los geht''s',SYSTEM_FONT,TE_CENTER);

cancel_btn := add_ditem( dl, G_BUTTON, SELECTABLE | EXIT_BTN, 60, 12, 8, 3,
                         RA_ST_0, NORM_FA);
              obj_setstate ( dl, cancel_btn, OUTLINED, FALSE);
              set_dtext ( dl, cancel_btn, 'Abbruch', SYSTEM_FONT, TE_CENTER);

END; { procedure baue_dialog }


{///////////////////////////////////////////////////////////////////////////}
{///   Ermittelt den gewÅnschten Dateinamen   //////////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

FUNCTION dateiname_ermittelt( VAR fil_path : path_name) : BOOLEAN;
VAR vorschlag, such_path : path_name;
    file_erhalten : BOOLEAN;
BEGIN
  such_path := fil_path;
  vorschlag := concat( drive, ':\*.PAS');
  file_erhalten := get_in_file( vorschlag, such_path);  { Aufruf der File- }
  IF file_erhalten                                      { Selector-Box }
  THEN BEGIN
         IF length( such_path) > BOX_LEN        { Pfadname nicht lÑnger als }
         THEN BEGIN                             { die Box, sonst Bomben     }
                t := '[1][Tut mir leid,|Pfadname zu lang !][ Schade ]';
                mist := do_alert( t, 1);
                file_erhalten := FALSE;
              END { Name war zu lang }
         ELSE fil_path := such_path;    { alles okay }
       END; { Dateisuche wurde nicht abgebrochen }
  dateiname_ermittelt := file_erhalten;
END; { function dateiname_ermittelt }


{///////////////////////////////////////////////////////////////////////////}
{///   Malt das Hintergrundfenster wieder aus   ////////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE redraw_hintergrund( xc, yc, wc, hc : INTEGER);
VAR x, y, w, h : INTEGER;
BEGIN
  paint_color( BLACK);                  { Parameter fÅrs Malen setzen }
  paint_style( HINTERGRUND_MUSTER);
  hide_mouse;
  first_rect( fenster, x, y, w, h);
  WHILE (w <> 0) OR (h <> 0) DO
  BEGIN                                 { Teile des Fensters sind sichtbar }
    IF rect_intersect( xc, yc, wc, hc, x, y, w, h)
    THEN BEGIN
           set_clip( x, y, w, h);       { Wieder ausmalen }
           paint_rect( x, y, w, h);
         END; { ein Teil ist neu gezeichnet }
    next_rect( fenster, x, y, w, h);
  END; { while sichtbare Teile }
  show_mouse;
END; { procedure redraw_hintergrund }


{///////////////////////////////////////////////////////////////////////////}
{///   Hier wird die eigentliche Arbeit erledigt   /////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE an_die_arbeit;

{$P-,R-} { Keine öberprÅfung von Zeigern, Arrays und Strings }

CONST REFS_TAB    = 25;       { Referenzen werden ab Spalte 25 gedruckt }

TYPE   identifier_ptr   = ^identifier_record;

       schreibweise_ptr = ^schreibweise_record;

       referenz_ptr     = ^referenz_record;

       identifier_record = RECORD
                             wort_wurzel : schreibweise_ptr;
                             links,
                             rechts      : identifier_ptr;
                             wortsinn    : str255;    { LÑnge wird bei der }
                                                      { Erzeugung bestimmt }
                           END; { record identifier_record }

       schreibweise_record = RECORD
                               str_anfang : ^str255;
                               erst_vork,
                               letzt_vork : referenz_ptr;
                               anz_vork   : INTEGER;
                               links,
                               rechts     : schreibweise_ptr;
                             END; { record schreibweise_record }

       referenz_record = RECORD
                           zeilen_nr,
                           spalten_nr : INTEGER;
                           naechstes  : referenz_ptr;
                         END; { record referenz_record }

VAR speicher_anfang,    { Variablen fÅr die Verwaltung des Speichers }
    source_laenge,
    source_puffer_anfang,
    source_puffer_ende,
    bytes_gelesen,
    bytes_geschrieben   : LONG_INTEGER;

    ref_pro_zeile,                      { Parameter fÅr die Ausgabe }
    ref_breite          : INTEGER;      { der X-REF-Liste }

    ref_list_wurzel     : identifier_ptr;       { Start der X-REF-Liste }

    dta_puffer          : dtabuftyp;

    source_handle,                              { Handles, Namen und Pfade }
    zwischen_handle     : INTEGER;              { der benîtigten Dateien }

    ausgabe_name,
    zwischen_name       : path_name;

    source_path,
    ausgabe_path,
    zwischen_path       : c_string;
    o                   : TEXT;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   Gibt die Referenzliste zu jeder Schreibweise aus   ++++++++++++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

  PROCEDURE gib_referenzen_aus( wort : schreibweise_record );

  VAR ref_pos,
      bereits_belegt,
      zusatz_blanks : INTEGER;
      ref           : referenz_ptr;

  BEGIN
    writeln(o);                                       { Leerzeile }
    write(o, wort.anz_vork : 6, ' *  ', wort.str_anfang^);
    bereits_belegt  := 6 + 4 + length( wort.str_anfang^);
    IF bereits_belegt < REFS_TAB
    THEN BEGIN              { Name und Anzahl sind kleiner als der Rand }
           ref_pos  := 1;   { Erste Referenz hat Position 1 }
           zusatz_blanks := REFS_TAB - bereits_belegt;
           write(o,' ' : zusatz_blanks);      { Leerzeichen bis zum Rand }
         END
    ELSE BEGIN
           ref_pos := (bereits_belegt - REFS_TAB) DIV ref_breite + 2;
           IF ref_pos <= ref_pro_zeile
           THEN BEGIN       { Mit Blanks zur nÑchsten Position auffÅllen }
                  zusatz_blanks := (ref_pos - 1) * ref_breite
                                   + REFS_TAB - bereits_belegt;
                  write( o, ' ' : zusatz_blanks );
                END;
         END;
    ref := wort.erst_vork;

    REPEAT
      IF ref_pos > ref_pro_zeile              { Zeilenende schreiben }
      THEN BEGIN
             writeln(o);
             write(o, ' ' : REFS_TAB);        { Rand setzen }
             ref_pos := 1;
           END;
      IF tempus_ausgabe
      THEN BEGIN
             zusatz_blanks := 1;              { Zahl der benîtigten }
             IF ref^.spalten_nr <= 9          { FÅllblanks ermitteln ... }
             THEN zusatz_blanks := 2
             ELSE IF ref^.spalten_nr >= 100
                  THEN zusatz_blanks := 0;

             write(o, ref^.zeilen_nr : 6,     { ... und schreiben }
                      '^', ref^.spalten_nr, ' ' : zusatz_blanks);
           END        { Ausgabe fÅr Tempus gemacht }
      ELSE write(o, ref^.zeilen_nr:ref_breite);       { Nur Zeilennummern }
      ref := ref^.naechstes;
      ref_pos := ref_pos + 1;
    UNTIL ref = NIL;
    writeln(o);       { Leerzeile }
  END; { procedure gib_referenzen_aus }


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   DurchlÑuft die verschiedenen Schreibweisen fÅr die Ausgabe   ++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

  PROCEDURE durchforste_gefundene_schreibweisen( wort : schreibweise_ptr);

  BEGIN { durchforste_gefundene_schreibweisen }
    IF wort <> NIL
    THEN BEGIN                                  { Rekursion nach links }
           durchforste_gefundene_schreibweisen( wort^.links);

           gib_referenzen_aus( wort^);
                                                { Rekursion nach rechts }
           durchforste_gefundene_schreibweisen( wort^.rechts);
         END; { wort war nicht nil }
  END; { procedure durchforste_gefundene_schreibweisen }


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   DurchlÑuft die Identifier fÅr die Ausgabe   +++++++++++++++++++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

  PROCEDURE durchforste_gefundene_identifier( ident : identifier_ptr );

  BEGIN { durchforste_gefundene_identifier }
    IF ident <> NIL
    THEN BEGIN                                  { Rekursion nach links }
           durchforste_gefundene_identifier( ident^.links);

           durchforste_gefundene_schreibweisen( ident^.wort_wurzel);

           durchforste_gefundene_identifier( ident^.rechts);
         END; { war nicht nil }                 { Rekursion nach rechts }
  END; { procedure durchforste_gefundene_identifier }


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   Untersucht die eingelesene Datei   ++++++++++++++++++++++++++++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

  PROCEDURE untersuche_quelle;

  CONST KLEINER  = -1;
        GLEICH   =  0;
        GROESSER =  1;

  TYPE zeiger_magic_typ   = RECORD CASE BOOLEAN OF
                                     FALSE : (long : LONG_INTEGER);
                                     TRUE  : (ptr  : ^str255)
                                   END; { record magictyp }
                        { Mit dieser Konstruktion kann der Zeiger }
                        { auf jeden Buchstaben der Source gesetzt werden }

  VAR wort              : str255;
      ch                : CHAR;
      i,
      zeile,
      spalte            : INTEGER;

      vorher_seperator  : BOOLEAN;
      zeiger,
      hilfs_zeiger,
      wort_string       : zeiger_magic_typ;

      wortanfang,
      spalten_anfang    : LONG_INTEGER;


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{~~~   Lexikalischer Vergleich von 2 Strings in einem Aufwasch   ~~~~~~~~~~~}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    FUNCTION string_vergleich( VAR str1, str2 : str255) : INTEGER;
    CONST   KLEINER  = -1;
            GLEICH   =  0;
            GROESSER =  1;
    VAR i,
        ende,
        erster_string : INTEGER;
    BEGIN
      ende := ord( str1[0]);
      IF str1[0] = str2[0]                      { Zuerst die LÑnge prÅfen }
      THEN erster_string := GLEICH              { und Variable ende auf }
      ELSE IF str1[0] < str2[0]                 { Ende des kÅrzeren }
           THEN erster_string := KLEINER        { Strings setzen }
           ELSE BEGIN
                  erster_string := GROESSER;
                  ende := ord( str2[0]);
                END;
      i := 1;   { So weit vor, bis verschiedene Buchstaben oder Ende }
      WHILE (str1[i] = str2[i]) AND (i < ende) DO i := i + 1;

      IF str1[i] < str2[i]              { Wenn Buchstaben verschieden, }
      THEN string_vergleich := KLEINER  { entscheidet das Alphabet }
      ELSE IF str1[i] > str2[i]
           THEN string_vergleich := GROESSER         { ansonsten die LÑnge }
           ELSE string_vergleich := erster_string;   { der Strings }
    END; { function string_vergleich }


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{~~~   Ordnet die Identifier nach ihrer Schreibweise ein   ~~~~~~~~~~~~~~~~~}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    PROCEDURE suche_wort( VAR aktuelles_wort : schreibweise_ptr );

    VAR wort_vork : referenz_ptr;

    BEGIN { suche_wort }
      IF aktuelles_wort = NIL                   { Schreibweise ist neu }
      THEN BEGIN
             new(aktuelles_wort);               { Schreibweise- und }
             new(wort_vork);                    { Referenz-Record erzeugen }
             WITH aktuelles_wort^ DO BEGIN      { und einhÑngen }
                                 str_anfang := wort_string.ptr;
                                 erst_vork  := wort_vork;
                                 letzt_vork := wort_vork;
                                 anz_vork   := 1;
                                 links      := NIL;
                                 rechts     := NIL;
                               END; { with wort_wort^ }
             WITH wort_vork^
             DO BEGIN                           { Daten Åbernehmen }
                  zeilen_nr  := zeile;
                  spalten_nr := spalte;
                  naechstes  := NIL;
                END; { with wort_vork }
         END { Schreibweise war neu }
      ELSE BEGIN
             CASE string_vergleich( wort_string.ptr^,
                                    aktuelles_wort^.str_anfang^) OF
               GLEICH   : BEGIN                 { Schreibweise ist gleich }
                            new( wort_vork);    { Neue Referenz anlegen }

                            WITH aktuelles_wort^{ Neue Referenz einhÑngen }
                            DO BEGIN
                                 letzt_vork^.naechstes := wort_vork;
                                 letzt_vork := wort_vork;
                                 anz_vork   := anz_vork + 1;
                               END; { with aktuelles_wort^ }

                            WITH wort_vork^     { und Daten Åbernehmen }
                            DO BEGIN
                                 zeilen_nr := zeile;
                                 spalten_nr := spalte;
                                 naechstes := NIL;
                               END; { with wort_vork }
                          END; { Schreibweise war identisch }
             KLEINER  : suche_wort( aktuelles_wort^.links);
             GROESSER : suche_wort( aktuelles_wort^.rechts);
             END; { case }
           END; { war nicht NIL }
    END; { procedure suche_wort }


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{~~~   Ordnet das gefundene Wort in die Liste der Identifier ein   ~~~~~~~~~}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    PROCEDURE suche_identifier( VAR aktueller_identifier : identifier_ptr );

    BEGIN { suche_identifier }
      IF aktueller_identifier = NIL             { Identifier ist neu }
      THEN BEGIN                        { Identifier-Record erzeugen ... }
             new(aktueller_identifier : length(wort) );
             WITH aktueller_identifier^         { ... und einhÑngen }
             DO BEGIN
                  wortsinn    := wort;
                  links       := NIL;
                  rechts      := NIL;
                  wort_wurzel := NIL;
                END; { with aktueller_identifier^ }

             suche_wort( aktueller_identifier^.wort_wurzel);
                                        { Zugehîrige Schreibweise merken }
           END { Identifier war neu }
      ELSE CASE string_vergleich( wort, aktueller_identifier^.wortsinn) OF
             KLEINER  : suche_identifier( aktueller_identifier^.links);
             GROESSER : suche_identifier( aktueller_identifier^.rechts);
             GLEICH   : suche_wort( aktueller_identifier^.wort_wurzel);
           END; { case }              { Identifier war bereits bekannt }
    END; { procedure suche_identifier }


{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

  BEGIN { untersuche_quelle }
    zeiger.long    := source_puffer_anfang - 1; { 1 Byte vor Textbeginn }
    spalten_anfang := source_puffer_anfang - 2; { Spalte wird auf }
                                                { imaginÑres CR gesetzt }
    vorher_seperator := TRUE;                   { Es ist ja Dateianfang }
    wortanfang := 0;                            { Noch kein Wort gefunden }
    zeile := 1;

    REPEAT  { Bis die Datei abgearbeitet ist }
      zeiger.long := zeiger.long + 1;           { Zeiger um 1 Byte weiter }
      IF zeiger.ptr^[0] IN ['a'..'z']           { Wandeln in Groûbuchstaben }
      THEN ch := chr( ord( zeiger.ptr^[0]) -32)
      ELSE ch := zeiger.ptr^[0];
      IF ch IN ['A'..'Z']
      THEN BEGIN
             IF vorher_seperator
             THEN BEGIN                         { Ein neues Wort beginnt }
                    wortanfang := zeiger.long;
                    wort := '';
                  END;
             wort[0] := succ( wort[0]);         { Zeichen an angefangenes }
             wort[ord( wort[0])] := ch;         { Wort anhÑngen }
             vorher_seperator := FALSE;
           END { ch war Buchstabe }
      ELSE BEGIN
             IF ch IN ['0'..'9', '_']
             THEN BEGIN
                    IF wortanfang > 0
                    THEN BEGIN                          { steht innerhalb }
                           wort[0] := succ( wort[0]);   { eines Wortes, }
                           wort[ord( wort[0])] := ch;   { also anhÑngen }
                         END;
                    vorher_seperator := FALSE;
                  END { ch war Ziffer oder Unterstreichung }
             ELSE BEGIN
                    vorher_seperator := TRUE;   { Zeichen ist Seperator }
                    IF wortanfang > 0
                    THEN BEGIN                  { Wort ist gefunden }
                           wort_string.long := wortanfang - 1;
                                                { String-Pointer setzen }

                           IF res_gross_ausgabe
                           THEN BEGIN
                                  IF reserviert( wort)
                                  THEN FOR i := 1 TO length( wort)
                                       DO wort_string.ptr^[i] := wort[i];
                                END    { Groûbuchstaben Åbernehmen }

                           ELSE BEGIN           { X-REF-Liste gewÅnscht }
                                  IF NOT reserviert( wort)
                                  THEN BEGIN    { LÑnge des Wortes setzen }
                                         wort_string.ptr^[0] := wort[0];
                                         spalte := int( wortanfang -
                                                        spalten_anfang - 2);

                                         suche_identifier( ref_list_wurzel);

                                       END; { Wort war ein Identifier }
                                END; { Listenerstellung }

                           wortanfang := 0;     { Wort ist abgearbeitet }
                         END; { Wort war angefangen }

                    CASE ch OF
{ Anfang einer }      '$',                              { HEX-Zahl folgt, }
{ HEX-Zahl     }      '"'  : vorher_seperator := FALSE; { also kein Wort }

{ Anfang eines }      '''' : REPEAT zeiger.long := zeiger.long + 1;
{ Strings      }             UNTIL zeiger.ptr^[0] = '''';
                              { Zeile braucht man im String nicht zÑhlen }
                              { da String Åber die Zeile verboten ist }
{ Anfang eines }      '{'  : REPEAT
{ Kommentars   }               zeiger.long := zeiger.long + 1;
                               IF zeiger.ptr^[0] = #13
                               THEN BEGIN
                                      zeile := zeile + 1;
                                      spalten_anfang := zeiger.long;
                                    END;
                             UNTIL zeiger.ptr^[0]  = '}';
{ Anfang eines }      '*'  : BEGIN
{ Kommentars,  }               hilfs_zeiger.long := zeiger.long - 1;
{ falls vorher }               IF hilfs_zeiger.ptr^[0] = '('
{ '(' steht    }               THEN REPEAT
                                      zeiger.long := zeiger.long + 1;
                                      IF zeiger.ptr^[0]  = #13
                                      THEN BEGIN
                                             zeile := zeile + 1;
                                             spalten_anfang := zeiger.long;
                                           END;
                                      hilfs_zeiger.long := zeiger.long - 1;
                                    UNTIL ( zeiger.ptr^[0] =')' ) AND
                                          ( hilfs_zeiger.ptr^[0]='*' );
                             END; { Zeichen war '*' }
{ Ende der     }      #13  : BEGIN
{ Zeile        }               zeile := zeile + 1;
                               spalten_anfang := zeiger.long;
                             END;
                    END; { case ch of }
                  END; { Character war weder Buchstabe }
                       { noch Ziffer noch Unterstreichung }
           END; { Character war kein Buchstabe }
    UNTIL zeiger.long >= source_puffer_ende; { Bis Dateiende }
  END; { procedure untersuche_quelle }

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

BEGIN { an_die_arbeit }
  set_dta( dta_puffer);                 { DTA-Puffer setzen }
  IF exist( source_name)                { Gibt es die Datei Åberhaupt, }
  THEN                                  { Zugleich Daten in den DTA-Puffer }
  BEGIN
    source_laenge := dta_puffer.size;

{ Anmerkung : In der neu angekÅndigten Version 2.0, in der die LÑnge einer }
{             Variablen nicht mehr auf 32000 Bytes beschrÑnkt ist, sollte  }
{             man besser den Textpuffer innerhalb des Heaps lassen, also   }
{             z.B. mit NEW eine ausreichend lange Variable erzeugen, und   }
{             dafÅr nicht mit der Compileranweisung $S... Heap und Stack   }
{             beschrÑnken. Als Resultat kînnten so insgesamt lÑngere       }
{             Sources bearbeitet werden, da der Speicher nicht aufgeteilt  }
{             zu werden braucht.                                           }

    speicher_anfang := malloc(source_laenge + 4); { Etwas mehr Speicher }
    IF speicher_anfang > 0                        { als gebraucht anfordern }
    THEN BEGIN
           pas_to_c_path( source_name, source_path);    { Source auf Spei- }
           source_handle := fopen( source_path, 0);     { cher lesen }
           source_puffer_anfang := speicher_anfang + 2;
           bytes_gelesen := fread( source_handle, source_laenge,
                                   source_puffer_anfang );
                            { Vor dem Text muû noch ein wenig Platz sein }
           source_puffer_ende   := source_puffer_anfang + source_laenge - 1;
           IF bytes_gelesen <> source_laenge
           THEN BEGIN
                  t := '[3][Kann Quelldatei nicht lesen][ Abbruch ]';
                  mist := do_alert( t, 1);
                END
           ELSE BEGIN { Quelle korrekt eingelesen }
                  mist := fclose( source_handle);       { Datei schlieûen }
                  ref_list_wurzel := NIL; { noch kein Identifier vorhanden }

                  untersuche_quelle;      { alles klar, es kann losgehen }

                  ausgabe_name := source_name;          { Gleicher Name }
                  delete_extension( ausgabe_name);      { wie Quelle }

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   Ab jetzt folgt die Ausgabe zur Groûschreibung   +++++++++++++++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IF res_gross_ausgabe    { SchlÅsselwîrter sollen in }
THEN BEGIN              { Groûschrift ausgegeben werden }
       zwischen_name := concat( ausgabe_name, '.RWG');  { Namen herrichten }
       pas_to_c_path( zwischen_name, zwischen_path);

       ausgabe_name  := concat( ausgabe_name, '.ALT');
       pas_to_c_path( ausgabe_name, ausgabe_path);

       zwischen_handle := fcreate( zwischen_path, 0);   { Zwischendatei }
       IF zwischen_handle < 0                           { .RWG anlegen }
       THEN BEGIN     { Fehler }
              t:=concat('[3][Kann Ausgabedatei|nicht anlegen][ Abbruch ]');
              mist := do_alert( t, 1);
            END
       ELSE BEGIN     { Alles klar, es geht weiter }
              IF exist( ausgabe_name)           { Eventuell .ALT lîschen }
              THEN mist := fdelete( ausgabe_path);
              bytes_geschrieben := fwrite(zwischen_handle, source_laenge,
                                          source_puffer_anfang);
                                                { .RWG beschreiben }
              mist := fclose( zwischen_handle); { und schlieûen }
              IF ( bytes_geschrieben = source_laenge ) AND ( mist = 0 )
              THEN BEGIN              { alles ok }
                     mist := frename( 0, source_path, ausgabe_path);
                     IF mist = 0                { .PAS in .ALT umbenennen }
                     THEN mist := frename(0,zwischen_path, source_path)
                     ELSE BEGIN                 { .RWG in .PAS umbenennen }
                            t := concat('[1][Fehler beim Umbenennen|der ',
                                        'Dateien !|Ausgabe ist unter|',
                                        '.RWG zu finden][ OK ]');
                            mist := do_alert( t, 1);
                          END;
                   END
              ELSE BEGIN      { Fehler beim Schreiben }
                     t := concat('[3][Fehler beim Schreiben|in Ausgabe',
                                 'datei|vermutlich zu wenig|',
                                 'Speicherplatz][ Abbruch ]');
                     mist := do_alert( t, 1);
                     mist := fdelete( zwischen_path);   { .RWG lîschen }
                   END;
            END; { Zwischendatei konnte angelegt werden }
     END { res_gross_ausgabe }

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++   Ab jetzt folgt die Ausgabe fÅr X-REF-Liste   ++++++++++++++++++++++++}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

ELSE BEGIN                              { X-REF-Liste gewÅnscht }
       IF tempus_ausgabe                { Werte fÅr gewÅnschte }
       THEN BEGIN                       { Ausgabeart setzen }
              ref_pro_zeile    := 5;
              ref_breite       := 10;
              ausgabe_name := concat(ausgabe_name, '.XRT');
            END
       ELSE BEGIN
              ref_pro_zeile    := 8;
              ref_breite       := 6;
              ausgabe_name := concat(ausgabe_name, '.XRF');
            END;

       rewrite(o, ausgabe_name);        { Datei îffnen }
       writeln(o);                      { Kopf der Ausgabe schreiben }
       writeln(o,'  PASCAL-HELP   Version ', VERSION,
                 '   1986/87 by ERHARD SCHWARTZ');
       writeln(o);
       writeln(o,'  Cross-Referenz-Liste der Datei ', source_name);
       writeln(o); writeln(o);
                                { Alle Identifier erkursiv durchgehen }
       durchforste_gefundene_identifier( ref_list_wurzel);

       writeln(o);
       close(o);                { Ausgabedatei schlieûen }

     END; { Erstellen der X-REF-Liste }

{+++   Ende des Ausgabeteils   +++++++++++++++++++++++++++++++++++++++++++++}

                END; { Quelle wurde korrekt eingelesen }
           mist := mfree( speicher_anfang );    { Speicher wieder zurÅck }
         END { Speicher konnte reserviert werden }
    ELSE mist:=do_alert('[3][Speicherplatz|reicht nicht aus][ SCHADE ]',1);
  END { Quelldatei hat existiert }
  ELSE mist := do_alert('[3][Kann Quelldatei|nicht finden !!!][ WIESO ]',1);

END; { procedure an_die_arbeit }

{$P=,R=} { öberprÅfung von Zeigern, Arrays und Strings wie zuvor }


{///////////////////////////////////////////////////////////////////////////}
{///   Betreibt das Dialogfeld   ///////////////////////////////////////////}
{///////////////////////////////////////////////////////////////////////////}

PROCEDURE fuehre_dialog;
VAR heaptop     : ^CHAR;
BEGIN
  REPEAT                { bis cancel_btn gewÑhlt oder X-REF erstellt }

    wahl := do_dialog( dl, NONE);

    IF wahl = start_btn                 { Kann nur gewÑhlt werden, }
    THEN BEGIN                          { wenn Dateiname ermittelt }
           tempus_ausgabe := obj_state(dl,tempus_btn) & SELECTED = SELECTED;
           res_gross_ausgabe := obj_state(dl, res_gross_btn)
                                          & SELECTED = SELECTED;
           mark( heaptop);              { Heaptop merken }
           set_mouse( M_BEE);           { Maus als Biene, weil beschÑftigt }

           an_die_arbeit;               { Jetzt geht's los }

           release( heaptop);           { Speicher wieder freigeben }
           set_mouse( M_ARROW);         { Maus als Pfeil, Arbeit ist fertig }
         END; { start_btn gewÑhlt }

    IF wahl = quelle_btn
    THEN BEGIN
           redraw_hintergrund( fenst_x, fenst_y, fenst_w, fenst_h);
           IF dateiname_ermittelt( source_name)
           THEN BEGIN                           { Dateiname wurde angegeben }
                  set_dtext(dl, source_name_box, source_name, SYSTEM_FONT,
                            TE_LEFT);
                  obj_setstate(dl, start_btn,
                               obj_state( dl, start_btn) &~ DISABLED, FALSE);
                END
           ELSE BEGIN                   { Vermutlich Abbruch gewÑhlt }
                  set_dtext(dl, source_name_box, kein_name, SYSTEM_FONT,
                            TE_LEFT);
                  obj_setstate(dl,start_btn,
                               obj_state( dl, start_btn) | DISABLED, FALSE);
                END;
           redraw_hintergrund( fenst_x, fenst_y, fenst_w, fenst_h);
         END; { quelle_btn gewÑhlt }

    obj_setstate( dl, wahl, obj_state(dl,wahl)       { SELECTED - Status }
                            &~SELECTED, FALSE);      { wieder zurÅcknehmen }
  UNTIL wahl = cancel_btn;

  end_dialog( dl);
END; { procedure fuehre_dialog }


{///////////////////////////////////////////////////////////////////////////}
{///   Richtet alles fÅr den Dialog her und schlieût wieder alles   ////////}
{///////////////////////////////////////////////////////////////////////////}

BEGIN { Hauptprogramm }
  IF init_gem >= 0
  THEN
  BEGIN
    set_mouse( M_ARROW);
    initialisiere;
    baue_dialog;
    center_dialog( dl);
    fenstername := '';          { Eigenes groûes Fenster als Hintergrund }
                                { sonst Stîrung durch fremdes WM_REDRAW  }
    fenster := new_window( NONE, fenstername, 0, 0, 0, 0 );
    open_window ( fenster, 0, 0, 0, 0 );
    work_rect( fenster, fenst_x, fenst_y, fenst_w, fenst_h);
    redraw_hintergrund( fenst_x, fenst_y, fenst_w, fenst_h);
    fuehre_dialog;
    close_window  ( fenster );  { Hintergrundfenster wieder entfernen }
    delete_window ( fenster );
  END; { init_gem erfolgreich }

END.

