{$S70}
PROGRAM messwert ;

{-----------------------------------------------------------------------------}
{ Dieses Programm erlaubt die einfache Erfassung und Darstellung von Daten.   }
{ Die Wertepaare kînnen in ein Diagramm gezeichnet werden. Auûerdem ist es    }
{ mîglich sich eine Ausgleichsfunktion berechnen zu lassen.                   }
{                                                                             }
{ (c) Thomas Proffen, RHEINBACH                                  19.11.1986   }
{-----------------------------------------------------------------------------}

CONST
 boxzeile  = 7 ;
 boxspalte = 6 ;
 z1        = 7 ;
 s1        = 6 ;

 {$I C:\GEM\GEMCONST.PAS    }
 {$I C:\MESSWERT\MESSWERT.I }

TYPE
 {$I C:\GEM\GEMTYPE.PAS     }

 wert_type                  = RECORD                    { Meûwertstruktur }
                               x           : real ;
                               y           : real ;
                               fehler_x    : real ;
                               fehler_y    : real ;
                              END ;
 gesamt_wert_type           =        ARRAY [1..1000] OF wert_type ;
 string_type                = PACKED ARRAY [1..15] OF char ;

 { fÅr AES-Call }

 Pointer                    = ^char ;
 Int_In_Parms               = ARRAY[0..15] OF integer ;
 Int_Out_Parms              = ARRAY[0..45] OF integer ;
 Addr_In_Parms              = ARRAY[0..1]  OF Pointer ;
 Addr_Out_Parms             = ARRAY[0..0]  OF Pointer ;


VAR
 wert                                   : gesamt_wert_type ;
 menu_zei                               : Menu_Ptr ;
 info_zei, funktion_zei, para_zei,
 fkt_zei, eingabe_zei, aendern_zei,
 anzeigen_zei, struk_zei                : Dialog_Ptr ;
 msg                                    : Message_Buffer ;
 dummy_file                             : FILE OF integer ;
 daten_file                             : FILE OF wert_type ;
 dummy_name                             : string_type ;
 maske, datei_name, beschr_x, beschr_y,
 gleichung, ein_str                     : str255 ;
 count, adr_bild, adr_menu              : long_integer ;
 button, pushed, anzahl, event, kanal,
 dummy, zeiger, plot_x, plot_y, null_x,
 null_y, hilf_x, hilf_y, max_pot_x,
 max_pot_y, min_pot_x, min_pot_y,
 window, wx, wy, w, h                   : integer ;
 x_max, x_min, y_max, y_min, dx, dy,
 strich, ein_x, ein_y, n, x, y, xy, x2,
 y2, lx, ly, xx, yy, nx, ny, ll, mg,
 yg, me, ye, mln, yln, rg, re, rln,
 vx, vy, wert_x, wert_y, a, b, fehler,
 xf, yf, dag, dbg, dae, dbe, dal, dbl   : real ;
 netz_flag, verb_flag, log_x, log_y,
 auto_flag, fehler_fkt, fehler_balken,
 global_x, global_y, auto_x, auto_y     : boolean ;
 warten                                 : char ;
 art                                    : (e, l, g) ;

 {$I C:\GEM\GEMSUBS.PAS     }


{--------------------------  Betriebssystemaufrufe  --------------------------}


FUNCTION  Fwrite (kanal : integer; size, adresse : long_integer)
                 : long_integer ; GEMDOS ($40) ;

FUNCTION  Fcreate (VAR name : string_type; attr : integer)
                  : integer ; GEMDOS ($3C);

FUNCTION  Drucker_bereit : integer ; GEMDOS ($11) ;

FUNCTION  Bild_Ram : long_integer ; XBIOS (2) ;

PROCEDURE Hardcopy ; XBIOS (20) ;

PROCEDURE Setscreen (log_adr, phys_adr : long_integer ; rez : integer) ;
          XBIOS (5) ;


{------ AES-Calls : Objc_Draw ------------------------------------------------}

PROCEDURE Objc_Draw (VAR Ptr : Dialog_Ptr) ;

 VAR
  int_in                                 : Int_In_Parms ;
  int_out                                : Int_Out_Parms ;
  addr_out                               : Addr_Out_Parms ;
  addr_in                               : Addr_In_Parms ;

 PROCEDURE AES_Call (    op       : integer ;
                     VAR int_in   : Int_In_Parms ;
                     VAR int_out  : Int_Out_Parms ;
                     VAR addr_in  : Addr_In_Parms ;
                     VAR addr_out : Addr_Out_Parms ) ; EXTERNAL ;

 BEGIN
  int_in[0] := 0 ;
  int_in[1] := 4 ;
  int_in[2] := 0 ;
  int_in[3] := 0 ;
  int_in[4] := 639 ;
  int_in[5] := 399 ;
  addr_in[0] := Ptr ;
  AES_Call (42, int_in, int_out, addr_in, addr_out) ;
 END ;


{------- Zahl_Auswerten : Wandelt String in Realzahl um ----------------------}

FUNCTION Zahl_Auswerten (zahl_str : str255 ; VAR ergebnis : real) : integer ;

 VAR
  neg_flag, pot_neg_flag, exp_flag   : boolean ;
  lauf, zeiger, potenz, error        : integer ;

 BEGIN
  neg_flag := false ; pot_neg_flag := false ;
  exp_flag := false ;
  lauf := 1 ; ergebnis := 0 ; potenz := 0 ; error := 0 ;

  IF zahl_str[1] = '*' THEN error := 1 ;
  IF LENGTH (zahl_str) = 0 THEN error := -1 ;

  IF error = 0 THEN
   BEGIN
    FOR zeiger := 1 TO LENGTH (zahl_str) DO
     IF (zahl_str[zeiger] <> '0') AND
        (zahl_str[zeiger] <> '1') AND
        (zahl_str[zeiger] <> '2') AND
        (zahl_str[zeiger] <> '3') AND
        (zahl_str[zeiger] <> '4') AND
        (zahl_str[zeiger] <> '5') AND
        (zahl_str[zeiger] <> '6') AND
        (zahl_str[zeiger] <> '7') AND
        (zahl_str[zeiger] <> '8') AND
        (zahl_str[zeiger] <> '9') AND
        (zahl_str[zeiger] <> '+') AND
        (zahl_str[zeiger] <> '-') AND
        (zahl_str[zeiger] <> '.') AND
        (zahl_str[zeiger] <> 'E') AND
        (zahl_str[zeiger] <> 'e') THEN  error := -1 ;

    zeiger := 1 ;
    IF error = 0 THEN
     BEGIN
      IF zahl_str[zeiger] = '-' THEN
       BEGIN
        neg_flag := true ;
        zeiger := zeiger + 1 ;
       END ;

      WHILE  (zeiger <= LENGTH(zahl_str))  AND (zahl_str[zeiger] <> '.')
             AND (zahl_str[zeiger] <> '+') AND (zahl_str[zeiger] <> '-')
             AND (zahl_str[zeiger] <> 'E') AND (zahl_str[zeiger] <> 'e') DO
       BEGIN
        ergebnis := ergebnis * 10 + ORD (zahl_str[zeiger]) - 48 ;
        zeiger := zeiger + 1 ;
       END ;

      IF zahl_str[zeiger] = '.' THEN
       BEGIN
        zeiger := zeiger + 1 ;
        WHILE (zeiger <= LENGTH(zahl_str)) AND (zahl_str[zeiger] <> 'E')
               AND (zahl_str[zeiger] <> '+') AND (zahl_str[zeiger] <> '-')
               AND (zahl_str[zeiger] <> 'e') DO
         BEGIN
          ergebnis :=
          ergebnis + (ORD (zahl_str[zeiger]) - 48)*(1/PwrOfTen(lauf)) ;
          zeiger := zeiger + 1 ;
          lauf := lauf + 1 ;
         END ;
        END ;

      IF (zahl_str[zeiger] = 'E') OR (zahl_str[zeiger] = 'e') THEN
       zeiger := zeiger + 1 ;
      IF zahl_str[zeiger] = '+' THEN zeiger := zeiger + 1 ;
      IF zahl_str[zeiger] = '-' THEN
       BEGIN
        pot_neg_flag := true ;
        zeiger := zeiger + 1 ;
       END ;
      WHILE  zeiger <= LENGTH(zahl_str) DO
       BEGIN
        exp_flag := true ;
        potenz := potenz * 10 + ORD (zahl_str[zeiger]) - 48 ;
        zeiger := zeiger + 1 ;
       END ;
      IF potenz > 38 THEN error := -1 ;
      IF (exp_flag) AND (error = 0) THEN
       BEGIN
        IF  pot_neg_flag THEN ergebnis := ergebnis * (1 / PwrOfTen (potenz))
        ELSE                  ergebnis := ergebnis * PwrOfTen (potenz) ;
       END ;

      IF neg_flag THEN ergebnis := -1 * ergebnis ;
     END ;
   END ;
   Zahl_Auswerten := error ;
  END ;


{-------- LOG : Berechnet den dekadischen Logarithmus ------------------------}

FUNCTION log (zahl : real) : real ;

 BEGIN
  IF zahl > 0 THEN
   log := (LN(zahl) / LN(10)) ;
 END ;


{-------- NPwrOfTen : Erlaubt auch negative Exponenten -----------------------}

FUNCTION NPwrOfTen (zahl : integer) : real ;

 VAR zwischen            : real ;

 BEGIN
  zwischen := PwrOfTen (ABS(zahl)) ;
  IF zahl < 0 THEN
   zwischen := 1/zwischen ;
  NPwrOfTen := zwischen ;
 END ;


{-------- Do_Init : öbernimmt die erste Einstellung der Parameter ------------}

PROCEDURE Do_Init ;

 BEGIN
  Obj_SetState (funktion_zei, gerade,   selected|outlined, false) ;
  Obj_SetState (para_zei,  ylin,        selected|outlined, false) ;
  Obj_SetState (para_zei,  xlin,        selected|outlined, false) ;
  Obj_SetState (para_zei,  netzzei,     selected|outlined, false) ;
  Obj_SetState (para_zei,  grauto,      selected|outlined, false) ;
  Obj_SetState (struk_zei, xglobal,     selected|outlined, false) ;
  Obj_SetState (struk_zei, yglobal,     selected|outlined, false) ;

  log_x := false ; log_y := false ;
  auto_flag     := true ;
  netz_flag     := true ;
  global_x      := true ;
  global_y      := true ;
  auto_x        := false ;
  auto_y        := false ;
  verb_flag     := false ;
  fehler_fkt    := false ;
  fehler_balken := false ;
  beschr_x      := ' X ' ;
  beschr_y      := ' Y ' ;
  art           := g ;
  dx := 1E-6 ; dy := 1E-6 ;
  Set_DText (para_zei, beschrx, beschr_x, System_Font, TE_Center) ;
  Set_DText (para_zei, beschry, beschr_y, System_Font, TE_Center) ;
  { Da Fehlerrechnung noch nicht fertig !! }
  Obj_SetState (funktion_zei, fehlfkt, DISABLED, false) ;
 END ;


{------ Do_Auswerten : Ermitteln Minimal- bzw. Maximalwerte ------------------}

PROCEDURE Do_Auswerten ;

 VAR i                 : integer ;

 BEGIN
  IF auto_flag THEN
   BEGIN
    x_min := wert[1].x ; x_max := wert[1].x ;
    y_min := wert[1].y ; y_max := wert[1].y ;
    FOR i := 2 TO anzahl DO
     BEGIN
      IF (wert[i].x - wert[i].fehler_x) < x_min THEN
       x_min := wert[i].x - wert[i].fehler_x ;
      IF (wert[i].x + wert[i].fehler_x) > x_max THEN
       x_max := wert[i].x + wert[i].fehler_x ;
      IF (wert[i].y - wert[i].fehler_y) < y_min THEN
       y_min := wert[i].y - wert[i].fehler_y ;
      IF (wert[i].y + wert[i].fehler_y) > y_max THEN
       y_max := wert[i].y + wert[i].fehler_y ;
     END ;

    x_min := x_min + 0.1 * x_min ;             { Nicht bis an den Rand  }
    x_max := x_max + 0.1 * x_max ;
    y_min := y_min + 0.1 * y_min ;
    y_max := y_max + 0.1 * y_max ;
   END ;

  IF x_min > 0 THEN x_min := 0 ;
  IF y_min > 0 THEN y_min := 0 ;

  IF NOT log_x THEN
   BEGIN
    IF x_max <> x_min THEN
     dx := 600 / ABS ((x_max - x_min)) ;
    null_x := TRUNC (-1 * x_min * dx) ;
   END ;

  IF NOT log_y THEN
   BEGIN
    IF y_max <> y_min THEN
     dy := 399 / ABS ((y_max - y_min)) ;
    null_y := TRUNC (-1 * y_min * dy) ;
   END ;

  IF log_x THEN
   BEGIN
    x_max  := NPwrOfTen (max_pot_x + 1) ;
    x_min  := NPwrOfTen (min_pot_x) ;
    dx     := 600 / ABS (LOG(x_max) - LOG (x_min)) ;
    null_x := TRUNC (-1 * LOG (x_min) * dx) ;
    IF null_x < 0 THEN null_x := 0 ;
   END ;

  IF log_y THEN
   BEGIN
    y_max  := NPwrOfTen (max_pot_y + 1) ;
    y_min  := NPwrOfTen (min_pot_y) ;
    dy     := 399 / ABS (LOG(y_max) - LOG (y_min)) ;
    null_y := TRUNC (-1 * LOG (y_min) * dy) ;
    IF null_y < 0 THEN null_y := 0 ;
   END ;
 END ;


{-------- Zahl_Eingabe : öbernimmt Zahleneingabe -----------------------------}

FUNCTION Zahl_Eingabe (VAR ergebnis : real) : integer ;

 VAR fehler, i        : integer ;
     dummy            : real ;

 BEGIN
  LOOP
   write (chr(27), 'j') ;
   readln (ein_str) ;
   fehler := Zahl_Auswerten (ein_str, dummy) ;
  EXIT IF fehler >= 0 ;
   button := Do_Alert ('[3][ Falsche Eingabe !! ][ Wiederholung ]',1) ;
   write (chr(27), 'k') ;
   write (chr(27), 'j') ;
   FOR i := 1 TO LENGTH (ein_str) DO write (' ') ;
   write (chr(27), 'k?', chr(8)) ;
  END ;
  IF fehler = 0 THEN ergebnis := dummy ;
  Zahl_Eingabe := fehler ;
 END ;


{-------- Do_Quit : Bricht Programm nach RÅckfrage ab ------------------------}

PROCEDURE Do_Quit ;

 BEGIN
  button := Do_Alert ('[2][ Wollen Sie wirklich abbrechen ? ][ Ja | Nein ]',2);
  IF button = 1 THEN
   BEGIN
    Free_Resource ;
    Exit_Gem ;
    Halt ;
   END ;
 END ;


{-------- Do_Show_Info : Zeigt Infobox an ------------------------------------}

PROCEDURE Do_Show_Info ;

 BEGIN
  pushed := Do_Dialog (info_zei, 0) ;
  Obj_SetState (info_zei, pushed, normal|shadowed, true) ;
  End_Dialog (info_zei) ;
 END ;


{-------- Do_Erase : Lîscht Datei --------------------------------------------}

PROCEDURE Do_Erase ;

 BEGIN
  maske := 'A:\*.DAT' ;
  IF Get_In_File (maske, datei_name) THEN
   BEGIN
    button := Do_Alert
              ('[3][Soll ich die Datei wirklich lîschen ?][ Ja | Nein ]',2) ;
    IF button = 1 THEN
     BEGIN
      Set_Mouse (M_Bee) ;
      reset (dummy_file, datei_name) ;
      erase (dummy_file) ;
      Set_Mouse (M_Arrow) ;
     END ;
   END ;
 END ;


{-------- Do_Load : LÑdt Datei -----------------------------------------------}

PROCEDURE Do_Load ;

 VAR i            : integer ;

 BEGIN
  maske := 'A:\*.DAT' ;
  IF Get_In_File (maske, datei_name) THEN
   BEGIN
    Set_Mouse (M_Bee) ;
    reset (daten_file, datei_name) ;
    i := 1 ;
    LOOP
     wert[i] := daten_file^ ;
    EXIT IF eof(daten_file) ;
     i := i + 1 ;
     get (daten_file) ;
    END ;
    Set_Mouse (M_Arrow) ;
    anzahl := i - 1 ;
    Do_Auswerten ;
   END ;
 END ;


{------- Do_Save : Speichert Meûwertedatei auf Diskette ----------------------}

PROCEDURE Do_Save ;

 VAR i            : integer ;

 BEGIN
  maske := 'A:\*.DAT' ;
  IF Get_In_File (maske, datei_name) THEN
   BEGIN
    Set_Mouse (M_Bee) ;
    rewrite (daten_file, datei_name) ;
    FOR i := 1 TO anzahl DO
     BEGIN
      daten_file^ := wert[i] ;
      put (daten_file) ;
     END ;
    Set_Mouse (M_Arrow) ;
   END ;
 END ;


{------- Do_Save_Bild : Speichert Bild zur weiteren Verarbeitung -------------}

PROCEDURE Do_Save_Bild ;

 VAR i                 : integer ;

 BEGIN
  maske := 'A:\*.DOO' ;
  IF Get_In_File (maske, datei_name) THEN
   BEGIN
    Set_Mouse (M_Bee) ;
    FOR i := 1 TO LENGTH (datei_name) DO dummy_name[i] := datei_name[i] ;
    kanal := Fcreate (dummy_name, 0) ;
    count := Fwrite (kanal, 32000, adr_bild) ;
    Set_Mouse (M_Arrow) ;
    IF count < 32000 THEN
     button := Do_Alert
               ('[3][Fehler beim Schreiben aufgetreten !][Abbruch]',1) ;
   END ;
 END ;


{------- Do_Zeige_Bild : Schaltet auf Zeichenbildschirm um -------------------}

PROCEDURE Do_Zeige_Bild ;

 BEGIN
  Hide_Mouse ;
  Setscreen (adr_bild, adr_bild, -1) ;
  read (warten) ;
  Setscreen (adr_menu, adr_menu, -1) ;
  Show_Mouse ;
 END ;


{------ Do_Funktionsparameter : Stellt gewÅnschte Funktion ein ---------------}

PROCEDURE Do_Funktionsparameter ;

 BEGIN
  pushed := Do_Dialog (funktion_zei, 0) ;
  Obj_SetState (funktion_zei, pushed, normal|shadowed, true) ;
  End_Dialog (funktion_zei) ;

  IF Obj_State (funktion_zei, fktexp) & Selected <> 0 THEN
   art := e ;
  IF Obj_State (funktion_zei, fktln)  & Selected <> 0 THEN
   art := l ;
  IF Obj_State (funktion_zei, gerade) & Selected <> 0 THEN
   art := g ;
  IF Obj_State (funktion_zei, fehlfkt) & Selected <> 0 THEN
   fehler_fkt := true
  ELSE
   fehler_fkt := false ;
 END ;


{------ Do_Zeichenparameter : Rechnet Parameter aus Dialog um ----------------}

PROCEDURE Do_Zeichenparameter ;

 VAR i, fehler          : integer ;
     dummy              : real ;

 BEGIN
  pushed := Do_Dialog (para_zei, beschrx) ;
  Obj_SetState (para_zei, pushed, normal|shadowed, true) ;

  IF Obj_State (para_zei, netzzei) & Selected <> 0 THEN
   netz_flag := true
  ELSE
   netz_flag := false ;
  IF Obj_State (para_zei, verbind) & Selected <> 0 THEN
   verb_flag := true
  ELSE
   verb_flag := false ;
  IF Obj_State (para_zei, fehlbalk) & Selected <> 0 THEN
   fehler_balken := true
  ELSE
   fehler_balken := false ;
  IF Obj_State (para_zei, xlin) & selected <> 0 THEN
   log_x := false ;
  IF Obj_State (para_zei, xlog) & selected <> 0 THEN
   log_x := true ;
  IF Obj_State (para_zei, ylin) & selected <> 0 THEN
   log_y := false ;
  IF Obj_State (para_zei, ylog) & selected <> 0 THEN
   log_y := true ;
  IF Obj_State (para_zei, grauto) & selected <> 0 THEN
   auto_flag := true ;
  IF Obj_State (para_zei, grmanu) & selected <> 0 THEN
   auto_flag := false ;

  Get_DEdit (para_zei, beschrx, beschr_x) ;
  Get_DEdit (para_zei, beschry, beschr_y) ;

  IF pushed = skalaein THEN              { Eingabe von Zeichengrenzen ... }
   BEGIN
    IF log_x THEN
     BEGIN
      write (chr(27),'Y',chr(boxzeile+32),chr(boxspalte+32),
             'maximale x-Potenz ..: ?', chr(8)) ;
      fehler := Zahl_Eingabe (dummy) ;
      max_pot_x := TRUNC (dummy) ;
      write (chr(27),'Y',chr(boxzeile+33),chr(boxspalte+32),
             'minimale x-Potenz ..: ?', chr(8)) ;
      fehler := Zahl_Eingabe (dummy) ;
      min_pot_x := TRUNC (dummy) ;
     END
    ELSE
     BEGIN
      write (chr(27),'Y',chr(boxzeile+32),chr(boxspalte+32),
             'Einteilung x-Achse .: ?', chr(8)) ;
      fehler := Zahl_Eingabe (ein_x) ;
     END ;

    IF log_y THEN
     BEGIN
      write (chr(27),'Y',chr(boxzeile+34),chr(boxspalte+32),
             'maximale y-Potenz ..: ?', chr(8)) ;
      fehler := Zahl_Eingabe (dummy) ;
      max_pot_y := TRUNC (dummy) ;
      write (chr(27),'Y',chr(boxzeile+35),chr(boxspalte+32),
             'minimale y-Potenz ..: ?', chr(8)) ;
      fehler := Zahl_Eingabe (dummy) ;
      min_pot_y := TRUNC (dummy) ;
     END
    ELSE
     BEGIN
      write (chr(27),'Y',chr(boxzeile+34),chr(boxspalte+32),
             'Einteilung y-Achse .: ?', chr(8)) ;
      fehler := Zahl_Eingabe (ein_y) ;
     END ;

    IF NOT auto_flag THEN
     BEGIN
      IF NOT log_x THEN
       BEGIN
        write (chr(27),'Y',chr(boxzeile+38),chr(boxspalte+32),
               'maximaler x-Wert ...: ?', chr(8)) ;
        fehler := Zahl_Eingabe (x_max) ;
        write (chr(27),'Y',chr(boxzeile+39),chr(boxspalte+32),
               'minimaler x-Wert ...: ?', chr(8)) ;
        fehler := Zahl_Eingabe (x_min) ;
       END ;
      IF NOT log_y THEN
       BEGIN
        write (chr(27),'Y',chr(boxzeile+41),chr(boxspalte+32),
               'maximaler y-Wert ...: ?', chr(8)) ;
        fehler := Zahl_Eingabe (y_max) ;
        write (chr(27),'Y',chr(boxzeile+42),chr(boxspalte+32),
               'minimaler y-Wert ...: ?', chr(8)) ;
        fehler := Zahl_Eingabe (y_min) ;
       END ;
     END ;
   END ;
  End_Dialog (para_zei) ;
  Do_Auswerten ;
 END ;


{------ Do_Datenstruktur : Ermittelt EingabewÅnsche --------------------------}

PROCEDURE Do_Datenstruktur ;

 BEGIN
  pushed := Do_Dialog (struk_zei, 0) ;
  Obj_SetState (struk_zei, pushed, normal|shadowed, true) ;
  End_Dialog (struk_zei) ;

  IF Obj_State (struk_zei, xauto) & selected <> 0 THEN
   auto_x := true
  ELSE
   auto_x := false ;
  IF Obj_State (struk_zei, yauto) & selected <> 0 THEN
   auto_y := true
  ELSE
   auto_y := false ;
  IF Obj_State (struk_zei, xglobal) & selected <> 0 THEN
   global_x := true
  ELSE
   global_x := false ;
  IF Obj_State (struk_zei, yglobal) & selected <> 0 THEN
   global_y := true
  ELSE
   global_y := false ;
 END ;


{------ Do_Eingabe : Eingabe der Meûwerte ------------------------------------}

PROCEDURE Do_Eingabe (start_wert : integer) ;

 VAR i, z, fehler                      : integer ;
     delta_x, delta_y, start_x, dec_x,
     start_y, dec_y                    : real ;

 BEGIN
  Hide_Mouse ;
  Objc_Draw (eingabe_zei) ;
  IF global_x THEN
   BEGIN
    write (chr(27),'Y',chr(z1+32),chr(s1+32),'   Fehler fÅr ',beschr_x,
           ' ..........: ') ;
    fehler := Zahl_Eingabe (delta_x) ;
   END ;
  IF global_y THEN
   BEGIN
    write (chr(27),'Y',chr(z1+33),chr(s1+32),'   Fehler fÅr ',beschr_y,
           ' ..........: ') ;
    fehler := Zahl_Eingabe (delta_y) ;
   END ;

  IF auto_x THEN
   BEGIN
    write (chr(27),'Y',chr(z1+35),chr(s1+32),'   Startwert ', beschr_x,
           '  ..........: ') ;
    fehler := Zahl_Eingabe (start_x) ;
    write (chr(27),'Y',chr(z1+36),chr(s1+32),'   Inkrement ', beschr_x,
           '  ..........: ') ;
    fehler := Zahl_Eingabe (dec_x) ;
   END ;

  IF auto_y THEN
   BEGIN
    write (chr(27),'Y',chr(z1+38),chr(s1+32),'   Startwert ', beschr_x,
           '  ..........: ') ;
    fehler := Zahl_Eingabe (start_y) ;
    write (chr(27),'Y',chr(z1+39),chr(s1+32),'   Inkrement ', beschr_x,
           '  ..........: ') ;
    fehler := Zahl_Eingabe (dec_y) ;
   END ;

   i := start_wert ;
   REPEAT
    Objc_Draw (eingabe_zei) ;
    z := 0 ;
    write (chr(27),'Y',chr(z1+32),chr(s1+33),'i') ;
    write (chr(27),'Y',chr(z1+32),chr(s1+51),beschr_x) ;
    write (chr(27),'Y',chr(z1+32),chr(s1+84),beschr_y) ;
    line (45, 135, 590, 135, 1, 0, 0, 0, -1, 0) ;
    line (100, 95, 100, 350, 1, 0, 0, 0, -1, 0) ;
    line (350, 95, 350, 350, 1, 0, 0, 0, -1, 0) ;
    REPEAT
     write (chr(27),'Y',chr(z1+34+z),chr(s1+33),i) ;
     IF NOT auto_x THEN
      BEGIN
       write (chr(27),'Y',chr(z1+34+z),chr(s1+44),'?',chr(8)) ;
       fehler := Zahl_Eingabe (wert[i].x) ;
      END
     ELSE
      BEGIN
       wert[i].x := start_x + (i - 1) * dec_x ;
       write (chr(27),'Y',chr(z1+34+z),chr(s1+44),wert[i].x:12:6) ;
      END ;
     IF (NOT global_x) AND (fehler <> 1) THEN
      BEGIN
       write (chr(27),'Y',chr(z1+34+z),chr(s1+58),'+- ?',chr(8)) ;
       fehler := Zahl_Eingabe (wert[i].fehler_x) ;
      END
     ELSE
      wert[i].fehler_x := delta_x ;

     IF fehler <> 1 THEN
      BEGIN
       IF NOT auto_y THEN
        BEGIN
         write (chr(27),'Y',chr(z1+34+z),chr(s1+74),'?',chr(8)) ;
         fehler := Zahl_Eingabe (wert[i].y) ;
        END
       ELSE
        BEGIN
         wert[i].y := start_y + (i - 1) * dec_y ;
         write (chr(27),'Y',chr(z1+34+z),chr(s1+74),wert[i].y:12:6) ;
        END ;
       IF (NOT global_y) AND (fehler <> 1) THEN
        BEGIN
         write (chr(27),'Y',chr(z1+34+z),chr(s1+88),'+- ?',chr(8)) ;
         fehler := Zahl_Eingabe (wert[i].fehler_y) ;
        END
       ELSE
        wert[i].fehler_y := delta_y ;
      END ;
     z := z + 1 ;
     i := i + 1 ;
     IF i > 1000 THEN
      BEGIN
       fehler := 1 ;
       button := Do_Alert ('[3][Maximal 1000 Werte mîglich !][ Abbruch ]', 0) ;
      END ;
    UNTIL (fehler = 1) OR (z > 11) ;
   UNTIL fehler = 1 ;
  End_Dialog (eingabe_zei) ;
  Show_Mouse;
  anzahl := i - 2 ;
  Do_Auswerten ;
 END ;


{------ Do_Aendern : énderung  von Meûwerte ----------------------------------}

PROCEDURE Do_Aendern ;

 VAR hilfs_real      : real ;
     fehler          : integer ;

 BEGIN
  LOOP
   pushed := Do_Dialog (aendern_zei, wertnr) ;
   Get_DEdit (aendern_zei, wertnr, ein_str) ;
   Obj_SetState (aendern_zei, wertnr, normal, true) ;
   zeiger := Zahl_Auswerten (ein_str, hilfs_real) ;
   zeiger := TRUNC (hilfs_real) ;
  EXIT IF ((zeiger <= anzahl) AND (zeiger > 0)) OR (pushed <> wertnr) ;
   button := Do_Alert
             ('[3][ Diesen Wert gibt es nicht !][ nochmal ]',1);
  END ;

  IF pushed = wertnr THEN
   BEGIN
    Hide_Mouse ;
    write (chr(27),'Y',chr(z1+35), chr(s1+36), 'alter x-Wert : ',
           wert[zeiger].x:14:8, '    neuer Wert : ?',chr(8)) ;
    fehler := Zahl_Eingabe (wert[zeiger].x) ;

    write (chr(27),'Y',chr(z1+36), chr(s1+36), 'alter y-Wert : ',
           wert[zeiger].y:14:8, '    neuer Wert : ?',chr(8)) ;
    fehler := Zahl_Eingabe (wert[zeiger].y) ;

    write (chr(27),'Y',chr(z1+38), chr(s1+36), 'FEHLER : ') ;
    write (chr(27),'Y',chr(z1+40), chr(s1+36), 'alter x-Fehler : ',
           wert[zeiger].fehler_x:14:8, '  neuer Wert : ?',chr(8)) ;
    fehler := Zahl_Eingabe (wert[zeiger].fehler_x) ;

    write (chr(27),'Y',chr(z1+41), chr(s1+36), 'alter y-Fehler : ',
           wert[zeiger].fehler_y:14:8, '  neuer Wert : ?',chr(8)) ;
    fehler := Zahl_Eingabe (wert[zeiger].fehler_y) ;
    Show_Mouse ;
   END
  ELSE
   Obj_SetState (aendern_zei, pushed, normal|shadowed, true) ;

  End_Dialog (aendern_zei) ;
  Do_Auswerten ;
 END ;


{------ Do_Werte_Zeigen : Zeigt Meûwerte an ----------------------------------}

PROCEDURE Do_Werte_Zeigen ;

 VAR i, z, fehler, start, help  : integer ;

 BEGIN
  i := 1 ; start := 1 ; help := 1 ;
  REPEAT
   Hide_Mouse ;
   z := 0 ;
   Objc_Draw (anzeigen_zei) ;
   CASE pushed OF
    wertmin   : help := help - 1 ;
    wertplus  : help := help + 1 ;
    weseimin  : help := help - 10 ;
    weseiplu  : help := help + 10 ;
   END ;
   IF (help > 0) AND (help <= anzahl) THEN
    start := help
   ELSE
    help := start ;
   i := start ;
   write (chr(27),'Y',chr(z1+32),chr(s1+32),'i') ;
   write (chr(27),'Y',chr(z1+32),chr(s1+49),beschr_x) ;
   write (chr(27),'Y',chr(z1+32),chr(s1+82),beschr_y) ;
   line (30, 135, 580, 135, 1, 0, 0, 0, -1, 0) ;
   line (100, 95, 100, 320, 1, 0, 0, 0, -1, 0) ;
   line (350, 95, 350, 320, 1, 0, 0, 0, -1, 0) ;
   WHILE (i <= anzahl) AND (z <= 9) DO
    BEGIN
     write (chr(27),'Y',chr(z1+34+z),chr(s1+32),i) ;
     write (chr(27),'Y',chr(z1+34+z),chr(s1+41),wert[i].x:14:8) ;
     write (chr(27),'Y',chr(z1+34+z),chr(s1+56),'+- ',wert[i].fehler_x:7:2) ;
     write (chr(27),'Y',chr(z1+34+z),chr(s1+71),wert[i].y:14:8) ;
     write (chr(27),'Y',chr(z1+34+z),chr(s1+86),'+- ',wert[i].fehler_y:7:2) ;
     z := z + 1 ;
     i := i + 1 ;
    END ;
   Show_Mouse ;
   pushed := Redo_Dialog (anzeigen_zei, 0) ;
   Obj_SetState (anzeigen_zei, pushed, normal|shadowed, true) ;
  UNTIL pushed = wertabbr ;
  End_Dialog (anzeigen_zei) ;
  Do_Auswerten ;
 END ;


{------ Do_Werte_drucken : Druckt Werte aus ----------------------------------}

PROCEDURE Do_Werte_drucken ;

 VAR i                     : integer ;

 BEGIN
  WHILE Drucker_bereit <> -1 DO
   button := Do_Alert ('[3][Drucker ist NICHT bereit !][ nochmal ]',1) ;
  button := Do_Alert
            ('[2][ Werte mit Fehler ausgeben ? ][ Ja | Nein ]', 1) ;
  rewrite (output,'PRN:') ;
  write (chr(27), chr(68), chr(6), chr(0)) ;
  IF button = 1 THEN
   BEGIN
    writeln ('               ---------  Ausgabe einer Meûreihe ---------') ;
    writeln ; writeln ;
    FOR i := 1 TO anzahl DO
     writeln ('   ', i, chr(9),
       beschr_x,'  : ',wert[i].x:14:8,'  ',chr(241),' ', wert[i].fehler_x:7:2,
       '     ' ,
       beschr_y,'  : ',wert[i].y:14:8,'  ',chr(241),' ', wert[i].fehler_y:7:2);
   END
  ELSE
   BEGIN
    writeln ('               ---------  Ausgabe einer Meûreihe ---------') ;
    writeln ; writeln ;
    FOR i := 1 TO anzahl DO
     writeln ('   ', i, chr(9), beschr_x, '  : ', wert[i].x:14:8,'       ',
              beschr_y, '  : ', wert[i].y:14:8) ;
   END ;
  rewrite (output,'CON:') ;
 END ;


{------ Do_Drucke_Bild : Druckt Bild aus  ------------------------------------}

PROCEDURE Do_Drucke_Bild ;


 BEGIN
  WHILE Drucker_bereit <> -1 DO
   button := Do_Alert ('[3][Drucker ist NICHT bereit !][ nochmal ]',1) ;
  rewrite (output,'PRN:') ;
  Hide_Mouse ;
  Setscreen (adr_bild, adr_bild, -1) ;
  Hardcopy ;
  Setscreen (adr_menu, adr_menu, -1) ;
  rewrite (output,'CON:') ;
  Show_Mouse ;
 END ;


{------ Achse_lin_x : Zeichnet x-Achse (linear) ------------------------------}

PROCEDURE Achse_lin_x ;

 VAR i,j                : integer ;

 BEGIN
  IF ein_x = 0 THEN
   button := Do_Alert
   ('[3][Sie haben die Einteilung der|x-Achse NICHT festgelegt][ ach so ! ]',1)
  ELSE
   BEGIN
    strich := TRUNC (x_min / ein_x) * ein_x ;
    WHILE (strich <= x_max) OR (plot_x + strich * dx < 600) DO
     BEGIN
      plot_x := null_x + TRUNC (strich * dx) ;
      IF netz_flag THEN
       line (plot_x+20, 0, plot_x+20, 399, 1, 0, 0, 0, $8888, 1) ;
      line (plot_x+20, 399-null_y-1, plot_x+20, 399-null_y-4,
            1, 0, 0, 0, -1,0) ;
      strich := strich + ein_x ;
     END ;
   END ;
  line (20, 399 - null_y, 620, 399 - null_y, 1, 0, 0, 0, -1, 0) ;
 END ;


{------ Achse_lin_y : Zeichnet y-Achse (linear) ------------------------------}

PROCEDURE Achse_lin_y ;

 VAR i,j                : integer ;

 BEGIN
  IF ein_y = 0 THEN
   button := Do_Alert
   ('[3][Sie haben die Einteilung der|y-Achse NICHT festgelegt][ ach so ! ]',1)
  ELSE
   BEGIN
    strich := TRUNC (y_min / ein_y) * ein_y ;
    WHILE (strich <= y_max) OR (plot_y + strich * dy < 399) DO
     BEGIN
      plot_y := null_y + TRUNC (strich * dy) ;
      IF netz_flag THEN
       line (20, 399-plot_y, 620, 399-plot_y, 1, 0, 0, 0, $8888, 1) ;
      line (null_x+21, 399-plot_y, null_x+24, 399-plot_y,
            1, 0, 0, 0, -1, 0) ;
      strich := strich + ein_y ;
     END ;
   END ;
  line (null_x+20, 0, null_x+20, 399, 1, 0, 0, 0, -1, 0) ;
 END ;


{------ Achse_log_x : Zeichnet x-Achse (logarith.) ---------------------------}

PROCEDURE Achse_log_x ;

 VAR i,j                : integer ;

 BEGIN
  FOR j := min_pot_x TO max_pot_x DO
   BEGIN
    FOR i := 1 TO 9 DO
     BEGIN
      strich := i * NPwrOfTen(j) ;
      strich := LOG (strich) - min_pot_x ;
      plot_x := TRUNC (strich * dx) ;
      IF netz_flag THEN
       line (plot_x+20, 0, plot_x+20, 399, 1, 0, 0, 0, $8888, 1) ;
      line (plot_x+20, 399-null_y-1, plot_x+20, 399-null_y-4,
            1, 0, 0, 0, -1,0) ;
     END ;
   END ;
  line (20, 399 - null_y, 620, 399 - null_y, 1, 0, 0, 0, -1, 0) ;
 END ;


{------ Achse_log_y : Zeichnet y-Achse (logarith.) ---------------------------}

PROCEDURE Achse_log_y ;

 VAR i,j                : integer ;

 BEGIN
  FOR j := min_pot_y TO max_pot_y DO
   BEGIN
    FOR i := 1 TO 9 DO
     BEGIN
      strich := i * NPwrOfTen(j) ;
      strich := LOG (strich) - min_pot_y ;
      plot_y := TRUNC (strich * dy) ;
      IF netz_flag THEN
       line (20, 399 - plot_y, 620, 399 - plot_y, 1, 0, 0, 0, $8888, 1) ;
      line (null_x+21, 399-plot_y, null_x+24, 399-plot_y,
            1, 0, 0, 0, -1, 0) ;
     END ;
   END ;
  line (null_x+20, 0, null_x+20, 399, 1, 0, 0, 0, -1, 0) ;
 END ;


{------- Zeichnen : Zeichnet Punkte eine -------------------------------------}

PROCEDURE zeichnen ;

 VAR  i, j, fehler_r, fehler_l  : integer ;

 BEGIN
  FOR i := 1 TO anzahl DO
   BEGIN
    IF log_x THEN
     plot_x := TRUNC ((LOG (wert[i].x) - min_pot_x) * dx)
    ELSE
     plot_x := null_x + TRUNC (wert[i].x * dx) ;
    IF log_y THEN
     plot_y := TRUNC ((LOG (wert[i].y) - min_pot_y) * dy)
    ELSE
     plot_y := null_y + TRUNC (wert[i].y * dy) ;
    line (plot_x+18,399-plot_y, plot_x+22, 399-plot_y,1, 0, 0, 0, -1, 0) ;
    line (plot_x+20,399-plot_y+2, plot_x+20, 399-plot_y-2,1, 0, 0, 0, -1, 0) ;
    IF verb_flag AND (i < anzahl) THEN
     BEGIN
      IF log_x THEN hilf_x := null_x + TRUNC (LOG(wert[i+1].x) * dx)
      ELSE          hilf_x := null_x + TRUNC (wert[i+1].x * dx) ;
      IF log_y THEN hilf_y := null_y + TRUNC (LOG(wert[i+1].y) * dy)
      ELSE          hilf_y := null_y + TRUNC (wert[i+1].y * dy) ;
      line (plot_x+20, 399-plot_y, hilf_x+20, 399-hilf_y, 1, 0, 0, 0, -1, 0) ;
     END ;
    IF fehler_balken THEN
     BEGIN
      IF wert[i].fehler_x <> 0 THEN
       BEGIN
        IF log_x THEN
         BEGIN
          fehler_r :=
           TRUNC ((LOG (wert[i].x + wert[i].fehler_x) - min_pot_x) * dx) ;
          fehler_l :=
           TRUNC ((LOG (wert[i].x - wert[i].fehler_x) - min_pot_x) * dx) ;
         END
        ELSE
         BEGIN
          fehler_r := plot_x + TRUNC (wert[i].fehler_x * dx) ;
          fehler_l := plot_x - TRUNC (wert[i].fehler_x * dx) ;
         END ;
        line (fehler_r+20,399-plot_y,fehler_l+20,399-plot_y,
              1, 0, 0, 0, -1, 0) ;
        line (fehler_r+20,399-plot_y+2,fehler_r+20,399-plot_y-2,
              1, 0, 0, 0, -1, 0) ;
        line (fehler_l+20,399-plot_y+2,fehler_l+20,399-plot_y-2,
              1, 0, 0, 0, -1, 0) ;
       END ;
      IF wert[i].fehler_y <> 0 THEN
       BEGIN
        IF log_y THEN
         BEGIN
          fehler_r :=
           TRUNC ((LOG (wert[i].y + wert[i].fehler_y) - min_pot_y) * dy) ;
          fehler_l :=
           TRUNC ((LOG (wert[i].y - wert[i].fehler_y) - min_pot_y) * dy) ;
         END
        ELSE
         BEGIN
          fehler_r := plot_y + TRUNC (wert[i].fehler_y * dy) ;
          fehler_l := plot_y - TRUNC (wert[i].fehler_y * dy) ;
         END ;
        line (plot_x+20,399-fehler_r,plot_x+20,399-fehler_l,
              1, 0, 0, 0, -1, 0) ;
        line (plot_x+22,399-fehler_r,plot_x+18,399-fehler_r,
              1, 0, 0, 0, -1, 0) ;
        line (plot_x+22,399-fehler_l,plot_x+18,399-fehler_l,
              1, 0, 0, 0, -1, 0) ;
       END ;
     END ;
   END ;
 END ;


{--------- Berechnen : Berechnung der Ausgleichsfunktion ---------------------}

PROCEDURE Berechnen ;

 VAR  i             : integer ;
      t1, t2        : real ;

 BEGIN
  IF anzahl = 0 THEN
   button := Do_Alert
   ('[3][ Bitte geben Sie zuerst ein paar| Werte ein !][ na gut ]',1)
  ELSE
   BEGIN
    x := 0 ; y := 0 ; xy := 0 ; x2 := 0 ; y2 := 0 ;
    lx := 0 ; ly := 0 ; xx := 0 ; yy := 0 ; nx := 0 ;
    ny := 0 ; ll := 0 ; xf := 0 ; yf := 0 ;
    FOR i := 1 to anzahl DO
     BEGIN
      IF wert[i].x = 0 THEN wert[i].x := wert[i].x + 1E-6 ;
      IF wert[i].y = 0 THEN wert[i].y := wert[i].y + 1E-6 ;
      vx := LN (ABS(wert[i].x)) ;
      vy := LN (ABS(wert[i].y)) ;
      x  := x + wert[i].x ;
      y  := y + wert[i].y ;
      xy := xy + wert[i].x * wert[i].y ;
      x2 := x2 + wert[i].x * wert[i].x ;
      y2 := y2 + wert[i].y * wert[i].y ;
      lx := lx + vx ;
      ly := ly + vy ;
      xx := xx + vx * vx ;
      yy := yy + vy * vy ;
      nx := nx + vy * wert[i].x ;
      ny := ny + vx * wert[i].y ;
      ll := ll + vx * vy ;
     END ;

    mg   := (xy - x * y / anzahl )  / (x2 - x * x / anzahl)  ;
    yg   := y / anzahl - mg * x / anzahl ;
    rg   := mg * (xy - x * y / anzahl) / (y2 - y * y / anzahl) ;
    dag  := 0 ;  { Fehlerberechnung noch nicht implementiert !! }
    dbg  := 0 ;
    rg   := rg * 100 ;

    me   := (nx - x * ly / anzahl)  / (x2 - x * x / anzahl) ;
    ye   := ly / anzahl - me * x / anzahl ;
    ye   := EXP (ye) ;
    dae  := 0 ;
    dbe  := 0 ;
    re   := me * (nx - x * ly / anzahl) / (yy - ly * ly / anzahl) ;
    re   := re * 100 ;

    mln  := (ny - lx * y / anzahl) / (xx - lx * lx / anzahl) ;
    yln  := y / anzahl - mln * lx / anzahl ;
    dal  := 0 ;
    dbl  := 0 ;
    rln  := mln * (ny - lx * y / anzahl)  / (y2 - y * y / anzahl) ;
    rln  := rln * 100 ;
   END ;
 END ;


{-------- Do_Zeichnen_Diagramm : Zeichnet Diagramm ---------------------------}

PROCEDURE Do_Zeichnen_Diagramm ;

 BEGIN
  Hide_Mouse ;
  Setscreen (adr_bild, adr_bild, -1) ;
  button := Do_Alert
  ('[3][Soll ich das alte Diagramm |zuerst lîschen ?][ Ja | Nein]', 1) ;
  IF button = 1 THEN
   write (chr(27),'E') ;
  IF log_x THEN
   Achse_log_x
  ELSE
   Achse_lin_x ;
  IF log_y THEN
   Achse_log_y
  ELSE
   Achse_lin_y ;
  zeichnen ;
  read (warten) ;
  Setscreen (adr_menu, adr_menu, -1) ;
  Show_Mouse ;
 END ;


{-------- Do_Zeichnen_Funktion : Zeichnet Funktion ---------------------------}

PROCEDURE Do_Zeichnen_Funktion ;

 VAR i, j, k                   : integer ;

 BEGIN
  j := 1 ;
  Hide_Mouse ;
  Setscreen (adr_bild, adr_bild, -1) ;
  button := Do_Alert
  ('[3][Soll ich das alte Diagramm |zuerst lîschen ?][ Ja | Nein]', 1) ;
  IF button = 1 THEN
   write (chr(27),'E') ;
  IF log_x THEN
   Achse_log_x
  ELSE
   Achse_lin_x ;
  IF log_y THEN
   Achse_log_y
  ELSE
   Achse_lin_y ;
  zeichnen ;
  Berechnen ;
  LOOP
   FOR i := 1 TO 600 DO
    BEGIN
     plot_x := i ;
     wert_x := (plot_x - null_x) / dx ;
     IF log_x THEN
      wert_x := EXP ((plot_x / dx) * LN(10)) + min_pot_x ;
     CASE art OF
      e    : wert_y := ye * EXP (me * wert_x) ;
      g    : wert_y := mg * wert_x + yg ;
      l    : IF wert_x > 0 THEN
                  wert_y := mln * LN(wert_x) + yln
                 ELSE
                  wert_y := 399 ;
     END ;
     IF log_y THEN
      plot_y := TRUNC ((LOG (wert_y) - min_pot_y) * dy)
     ELSE
      plot_y := null_y + TRUNC (wert_y * dy) ;
     IF (plot_y < 399) AND (plot_y > 0) THEN
      Put_Pixel (plot_x+20, 399-plot_y, 1) ;
    END ;
  EXIT IF (NOT fehler_fkt) OR (j = 3) ;
   j := j + 1 ;
   IF j = 2 THEN
    BEGIN
     mg  := mg  + dag ; yg  := yg  + dbg ;
     mln := mln + dal ; yln := yln + dbl ;
     me  := me  + dbe ; ye  := ye  + dae ;
    END ;
   IF j = 3 THEN
    BEGIN
     mg  := mg  - 2*dag ; yg  := yg  - 2*dbg ;
     mln := mln - 2*dal ; yln := yln - 2*dbl ;
     me  := me  - 2*dbe ; ye  := ye  - 2*dae ;
    END ;
  END ;
  read (warten) ;
  Setscreen (adr_menu, adr_menu, -1) ;
  Show_Mouse ;
 END ;


{-------- Do_Berechnen : Zeigt berechnete Funktion an ------------------------}

PROCEDURE Do_Berechnen ;

 VAR da, db               : real ;
     i                    : integer ;

 BEGIN
  Hide_Mouse ;
  Berechnen ;
  CASE art OF
   e        : BEGIN
               gleichung := 'y = a exp (bx)' ;
               a         := ye ;
               b         := me ;
               fehler    := re ;
               da        := dae ;
               db        := dbe ;
              END ;
   l        : BEGIN
               gleichung := 'y = a ln(x) + b' ;
               a         := mln ;
               b         := yln ;
               fehler    := rln ;
               da        := dal ;
               db        := dbl ;
              END ;
   g        : BEGIN
               gleichung := 'y = ax + b' ;
               a         := mg ;
               b         := yg ;
               fehler    := rg ;
               da        := dag ;
               db        := dbg ;
              END ;
  END ;
  Objc_Draw (fkt_zei) ;
  write (chr(27),'Y',chr(z1+34),chr(s1+35)) ;
  write ('      Ausgleichsfunktion der Art : ', gleichung) ;
  write (chr(27),'Y',chr(z1+35),chr(s1+35)) ;
  write ('                             mit : ') ;
  write (chr(27),'Y',chr(z1+37),chr(s1+35)) ;
  write ('                                    a = ', a:13:8) ;
  write (chr(27),'Y',chr(z1+38),chr(s1+35)) ;
  write ('                                    b = ', b:13:8) ;
  write (chr(27),'Y',chr(z1+39),chr(s1+35)) ;
  write ('      Korrelationskoeffizient    :  r = ', fehler:10:4,' %') ;
  IF fehler_fkt THEN
   BEGIN
    write (chr(27),'Y',chr(z1+41),chr(s1+35)) ;
    write ('      absoluter Fehler von a     : da = ',da:13:8) ;
    write (chr(27),'Y',chr(z1+42),chr(s1+35)) ;
    write ('      absoluter Fehler von b     : db = ',db:13:8) ;
   END ;

  Show_Mouse ;
  pushed := Redo_Dialog (fkt_zei, 0) ;
  Obj_SetState (fkt_zei, pushed, normal|shadowed, true) ;
  End_Dialog (fkt_zei) ;
 END ;


{-------- Event_Loop : die kanonische Ereignisschleife -----------------------}

PROCEDURE Event_Loop ;

 BEGIN
  WHILE true DO
   BEGIN
    event := Get_Event (E_Message, 0, 0, 0, 0, false, 0, 0, 0, 0,
                        false, 0, 0, 0, 0, msg, dummy, dummy, dummy,
                        dummy, dummy, dummy) ;
    IF msg[0] = MN_Selected THEN
     BEGIN
      Menu_Normal (menu_zei, msg[3]) ;
      CASE msg[4] OF
       savedat     : Do_Save ;
       loaddat     : Do_Load ;
       erasedat    : Do_Erase ;
       ende        : Do_Quit ;
       struktur    : Do_Datenstruktur ;
       eingabe     : Do_Eingabe (1) ;
       ergaenz     : Do_Eingabe (anzahl + 1) ;
       aendern     : Do_Aendern ;
       zeigen      : Do_Werte_zeigen ;
       druckdat    : Do_Werte_drucken ;
       diazeich    : Do_Zeichnen_Diagramm ;
       fktzeich    : Do_Zeichnen_Funktion ;
       savepic     : Do_Save_Bild ;
       bildzei     : Do_Zeige_Bild ;
       druckpic    : Do_Drucke_Bild ;
       fktangeb    : Do_Berechnen ;
       fktpara     : Do_Funktionsparameter ;
       zeipara     : Do_Zeichenparameter ;
       info        : Do_Show_Info ;
      END ;
     END ;
   END ;
 END ;


{********                H A U P T P R O G R A M M                   *********}

BEGIN
 IF Init_Gem >= 0 THEN
  BEGIN
   adr_menu := Bild_Ram ;
   adr_bild := adr_menu - $8000 ;
   IF NOT Load_Resource ('MESSWERT.RSC') THEN
    BEGIN
     button := Do_Alert ('[3][RSC-File defekt !][Abbruch]',0) ;
     Exit_Gem ;
     Halt ;
    END ;

   Find_Menu (menu, menu_zei) ;
   Draw_Menu (menu_zei) ;
   Find_Dialog (infobox, info_zei) ;      Center_Dialog (info_zei) ;
   Find_Dialog (funktion, funktion_zei) ; Center_Dialog (funktion_zei) ;
   Find_Dialog (para, para_zei) ;         Center_Dialog (para_zei) ;
   Find_Dialog (fktanz, fkt_zei) ;        Center_Dialog (fkt_zei) ;
   Find_Dialog (einfenst, eingabe_zei) ;  Center_Dialog (eingabe_zei) ;
   Find_Dialog (anzfenst, anzeigen_zei) ; Center_Dialog (anzeigen_zei) ;
   Find_Dialog (aendfens, aendern_zei) ;  Center_Dialog (aendern_zei) ;
   Find_Dialog (einart, struk_zei) ;      Center_Dialog (struk_zei) ;

   Do_Init ;
   Init_Mouse ;
   Do_Show_Info ;
   Event_Loop ;
  END ;
END.
