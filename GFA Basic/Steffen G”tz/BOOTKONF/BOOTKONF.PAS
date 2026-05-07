PROGRAM BootKonfiguration;

{ ******************************************************************** }
{ *                                                                  * }
{ *    Eine Harddiskhilfe von YETIsoft, (C)1989 Steffen Gîtz         * }
{ *                                                                  * }
{ ******************************************************************** }

{ ------------------------------------------------------------------------

  Die Beschreibung des Programms BOOTKONF.PRG (1.5) findet man
  in der Datei BOOTKONF.DOC(.TXT) auf dieser Diskette.
                
  ------------------------------------------------------------------------ }
  
CONST Version           = '1.5 (17.03.89)';
      KonfigDatei       = 'BOOTKONF.KON';
      HistoryDatei      = 'BOOTKONF.HIS';
      KeyStart          = '0';
      KeyEnd            = '9';
      leftblanks        = '          ';
      EndString         = 'END';
      YesSymbol         = '+';
      NoSymbol          = '-';
      maxZeilen         = 100;
      max_CString_laenge=90;
           

TYPE  KeyTyp    = KeyStart..KeyEnd;
      TabTyp    = ( Zeile, Spalte );
      ZeigerTyp = RECORD
                    Index    : INTEGER;
                    TabArt   : TabTyp;
                    Feldmax  : INTEGER;
                    Position : ARRAY[ KeyTyp ] OF INTEGER;
                  END;
      Str       = STRING[ 80 ];
      CString   = PACKED ARRAY[ 1..max_CString_laenge ] OF CHAR;

  { fÅr die Uhrenbehandlung: }
        
     t_tag   = 1..31;
     t_monat = 1..12;
     t_jahr  = 0..9999;
     t_datum = RECORD tag   : t_tag;
                      monat : t_monat;
                      jahr  : t_jahr
               END;
     t_sek   = 0..59;
     t_min   = 0..59;
     t_std   = 0..23;
     t_zeit  = RECORD sek : t_sek;
                      min : t_min;
                      std : t_std
               END;

      

VAR  Konfig : ARRAY[ 1..maxZeilen ] OF Str;
     max    : INTEGER;
     Antwort, AlteAntwort : CHAR;
     MENUZeiger, AUTOZeiger, ACCZeiger, DESKTOPZeiger : ZeigerTyp;
     KeyMax   : KeyTyp;
     History  : TEXT;
     Laufwerk : Str;
     alteEinstellung, neueEinstellung : Str;
     DatumUndZeit : Str;
     Dummy        : INTEGER;
     Init, Test   : BOOLEAN;
     LoRes        : BOOLEAN;


PROCEDURE inverse_on;
{ Schaltet inverse Schrift ein (Farbe von Schrift und Hintergrund getauscht). }
  BEGIN write (chr (27), 'p')
  END;

PROCEDURE inverse_off;
{ Schaltet inverse Schrift aus. }
  BEGIN write (chr (27), 'q')
  END;

PROCEDURE WriteBlanks;
BEGIN
  Write(leftblanks);
END;


PROCEDURE Read_Key( VAR ch : CHAR );
{         --------
 liest ohne Echo ch = CHR der Taste, wobei fÅr RETURN und Sondertasten
 auch ' ' (CHR(32)) gelesen wird. Wird gebraucht, da das normale Read(ch)
 bei Eingabe von RETURN oder Ctrl-Z einen EOF-Laufzeitfehler produziert!
 }
VAR sci, chi : INTEGER;
    c : LONG_INTEGER;

  Function BConin ( dev:Integer) : Long_Integer;
  BIOS(2);

BEGIN
  c  := BConin(2); { 2 = CON: }
  sci:=Int( ShR(c,16) );
  chi:=Int( c mod 256 );
  IF (chi>0) AND (chi<128) THEN ch:=CHR( chi ) ELSE ch:=' ';
END; { Read_Key }


PROCEDURE ERRORHALT( line : Str );
{         ---------
 Zeigt die Zeile line an und bricht nach eingabe von RETURN das Programm ab.
}
BEGIN
  WriteBlanks;  inverse_on; WriteLn('FEHLER:'); inverse_off;
  WriteBlanks;  inverse_on; WriteLn( line ); inverse_off;
  WriteBlanks;  inverse_on; Write('Programmabbruch mit <RETURN>.');
                      inverse_off;
  ReadLn;
  HALT;
END;

     
FUNCTION Getrez : INTEGER; XBIOS(4); 
{        ------
 Die aktuelle physikalische Bildschirmauflîsung wird ermittelt.
 Diese Funktion greift "unterhalb" des GEM und ist daher ATARI-spezifisch!
 Es werden verschiedene Werte zurÅckgegeben, siehe bei den Konstanten. }


FUNCTION SetColor ( colornum, color : Integer ) : Integer; XBIOS(7);
{ Setzt Farbe colornum auf den Farbwert color, wobei color eine Hexazahl ist
  mit dem Wert $RGB mit R,G,B aus [0..7] jeweiliger Farbanteil ! }


PROCEDURE SetScreen ( ph_base, log_base : LONG_INTEGER; Rez : INTEGER ); XBIOS(5);
{         ---------
 Setzt Adresse fÅr den physikalischen und logischen Bildschirmspeicher
 und Ñndert die Bildschirmauflîsung.
 Falls irgendwo als Parameter -1 Åbergeben wird bleibt die aktuelle Ein-
 stellung erhalten.
}


PROCEDURE Get_Drive ( VAR Drv : Str );
{         ---------
 Ermittelt das aktuelle Laufwerk.
}
VAR  drive, error, knopf : INTEGER;

  FUNCTION DGetDrv : INTEGER; GEMDOS($19);
  
BEGIN { Get_Drive }
  drive:=DGetDrv;
  Drv := Concat ( Chr( drive + Ord ('A') ), ':' );
END;  { Get_Drive }


PROCEDURE Pas_to_CStr ( Ps : Str; VAR Cs : CString );
{         -----------
 Wandelt einen Pascal-String in einen CString um.
}
VAR i : INTEGER;
BEGIN
  i:=1;
  WHILE (i<=Length(Ps)) AND (i<max_CString_laenge) DO
  BEGIN
    Cs[i]:=Ps[i];
    i:=i+1;
  END;
  Cs[i]:=Chr(0); { LÑnge! }
END; { Pas_to_CStr }
  

PROCEDURE Rename( altName, neuName : Str );
{         ------
 Die Datei mit dem Namen altName wird der neue Name neuName gegeben.
}
VAR Calt, Cneu : CString;
    error : INTEGER;

  FUNCTION FRename( null : INTEGER; VAR Calt, Cneu : CString ):INTEGER;
  GEMDOS($56);

BEGIN
  IF Test THEN
  BEGIN
    WriteBlanks; inverse_on;
    Write('TEST-Modus: kein Plattenzugriff! Weiter mit RETURN');
    inverse_off;
    ReadLn;
  END
  ELSE
  BEGIN
    Pas_to_CStr( altName, Calt );
    Pas_to_CStr( neuName, Cneu );
    error:=FRename( 0, Calt, Cneu );
    IF error<>0 THEN ERRORHALT('Rename klappt nicht. Konifgurationsdatei ÅberprÅfen!');
  END;
END;


PROCEDURE KonfigLesen( KonfigDatei : Str );
{         -----------
 Die Konfigurationsdatei wird in das ARRAY Konfig eingelesen, wobei die
 Kommentarzeilen wegelassen werden.
}
VAR Datei : TEXT;
    i : INTEGER;
BEGIN
  i:=1;
  Reset( Datei, KonfigDatei );
  WHILE NOT(EOF(Datei)) AND (i<=maxZeilen) DO
  BEGIN
    ReadLn( Datei, Konfig[ i ] );
    IF Pos( '*', Konfig[ i ] ) <> 1 THEN i:=i+1;
  END;
  Close( Datei );
  IF i>maxZeilen THEN 
    ERRORHALT( Concat( KonfigDatei,' enthÑlt mehr Zeilen (ohne Kommentar) als erlaubt!' ) );
END;
    

PROCEDURE ZeigerFinden( ident : Str; Art : TabTyp; VAR Z : ZeigerTyp );
{         ------------
 Das Wort ident wird an erster Position einer Zeile im Konfig-ARRAY gesucht.
 Z zeigt dann auf die gefundene Zeile.
 Falls Art=Spalte, Zeile  werden noch die Spalten-, Zeilenpositionen 
 der KeyTypen ermittelt.
}
VAR i, j : INTEGER;
    found : BOOLEAN;
    k : KeyTyp;
    ch : CHAR;
BEGIN
  i:=1; found:=FALSE; Z.TabArt:=Art;
  WHILE (i<maxZeilen) AND NOT(found) DO
  BEGIN
    IF Pos( ident, Konfig[i] )=1 THEN
    BEGIN
      found:=TRUE;
      Z.Index:=i;
      IF Art=Spalte THEN
      BEGIN
        FOR k:=KeyStart TO KeyEnd DO
          Z.Position[ k ]:=Pos( k, Konfig[ Z.Index ] );
      END
      ELSE
      BEGIN
        j:=1;
        WHILE Konfig[ Z.Index+j ]<>EndString DO
        BEGIN
          ch:=Konfig[ Z.Index+j ][ 1 ];
          IF ch IN [ KeyStart..KeyEnd ] THEN Z.Position[ ch ]:=j;
          j:=j+1;
        END;
      END;
    END
    ELSE i:=i+1;
  END;
  IF NOT(found) THEN ERRORHALT( Concat('Zeiger auf "',ident,'" nicht gefunden!') );
END;


FUNCTION MenuAbfragen( M : ZeigerTyp; VAR KeyMax : KeyTyp ) : CHAR;
{        ------------
 Das MenÅ wird angezeigt, auf einen Tastendruck gewartet, und dieser
 zurÅckgegeben.
}
VAR i, last : INTEGER;
    ch : CHAR;
BEGIN
  i:=1; last:=1;
  WriteBlanks; WriteLn('KonfigurationsmenÅ:'); WriteLn;
  WHILE Pos( EndString, Konfig[ M.Index+i ] )<>1 DO
  BEGIN
    WriteLn( leftblanks, Konfig[ M.Index+i ] );
    last:=i;
    i:=i+1;
  END;
  ch:=CHR(ORD(KeyStart)+last-1);
  IF ch>KeyEnd THEN ERRORHALT('zuviele Zeilen im MENU Teil.')
               ELSE KeyMax:=ch;
  WriteLn;
  WriteBlanks; WriteLn( 'Taste ', KeyStart, '-', KeyMax, ' wÑhlt neue Konfiguration.');
  WriteBlanks; Write( 'Jede andere Taste behÑlt alte Einstellungen bei. -> ');
  Read_Key( ch ); Write( ch );
  MenuAbfragen:=ch;
END;


PROCEDURE Umbenennen( neuk, altk : KeyTyp; LwOrdner, Suffix : Str; Z : ZeigerTyp );
{         ----------
 Je nach KonfigurationsÑnderung werden die Dateien umbenannnt.
}
VAR i : INTEGER;
    FileName, altName, neuName, Suff : Str;
    altSym, neuSym : CHAR;
BEGIN
  Suff:=Copy(Suffix,1,2);
  IF Z.TabArt=Spalte THEN
  BEGIN
    i:=1;
    WHILE Pos( EndString, Konfig[ Z.Index+i ] )<>1 DO
    BEGIN
      altSym:=Konfig[ Z.Index+i ][ Z.Position[ altk ] ];
      neuSym:=Konfig[ Z.Index+i ][ Z.Position[ neuk ] ];
      IF ( altSym = NoSymbol ) AND ( neuSym = YesSymbol ) THEN
      BEGIN
        FileName:=Copy( Konfig[ Z.Index+i ], 1, Pos( '.', Konfig[ Z.Index+i ] ) - 1 );
        FileName:=Concat( LwOrdner, FileName );
        altName:=Concat( FileName, '.', Suff );
        neuName:=Concat( FileName, '.', Suffix );
        WriteBlanks; WriteLn( 'Rename: ',altName,' -> ',neuName );
        Rename( altName, neuName );
      END
      ELSE
      IF ( altSym = YesSymbol ) AND ( neuSym = NoSymbol ) THEN
      BEGIN
        FileName:=Copy( Konfig[ Z.Index+i ], 1, Pos( '.', Konfig[ Z.Index+i ] ) - 1 );
        FileName:=Concat( LwOrdner, FileName );
        neuName:=Concat( FileName, '.', Suff );
        altName:=Concat( FileName, '.', Suffix );
        WriteBlanks; WriteLn( 'Rename: ',altName,' -> ',neuName );
        Rename( altName, neuName );
      END;
      i:=i+1;
    END;
  END;
END;


PROCEDURE DESKTOPumbenennen(  neuk, altk : KeyTyp; Lw : Str; D : ZeigerTyp );
{         -----------------
 Je nach KonfigurationsÑnderung werden die DESKTOP.INF Dateien umbenannt.
}
VAR i, lalt, lneu : INTEGER;
    altFileName, neuFileName : Str;
    
  PROCEDURE NameRausziehen( VAR Zeile : Str );
  VAR i, l : INTEGER;
      found: BOOLEAN;
  BEGIN
    l:=Length( Zeile );
    i:=2; found:=FALSE;
    IF l<i THEN ERRORHALT('Fehler im Teil DESKTOP.')
    ELSE
    BEGIN
      WHILE (i<l) AND NOT(found) DO
      BEGIN
        IF Zeile[i]<>' ' THEN
        BEGIN
          found:=TRUE;
          Delete( Zeile, 1, i-1 );
        END
        ELSE i:=i+1;
      END;
      IF NOT(found) THEN ERRORHALT('Fehler im Teil DESKTOP.');
    END;
  END;

BEGIN
  i:=1; lalt:=1; lneu:=1;
  WHILE Pos( EndString, Konfig[ D.Index+i ] )<>1 DO
  BEGIN
    IF Pos( neuk, Konfig[ D.Index+i ] ) = 1 THEN lneu:=i;
    IF Pos( altk, Konfig[ D.Index+i ] ) = 1 THEN lalt:=i;
    i:=i+1;
  END;
  altFileName:=Konfig[ D.Index+lalt ];
  neuFileName:=Konfig[ D.Index+lneu ];
  NameRausziehen( altFileName );
  NameRausziehen( neuFileName );
  altFileName:=Concat(Lw,altFileName);
  neuFileName:=Concat(Lw,neuFileName);
  WriteBlanks; WriteLn('Rename: ',Lw,'DESKTOP.INF ->',altFileName);
  Rename( Concat(Lw,'DESKTOP.INF'), altFileName );
  WriteBlanks; WriteLn('   und: ',neuFileName,' -> ',Lw,'DESKTOP.INF');
  Rename( neuFileName, Concat(Lw,'DESKTOP.INF') );
END;


{ -------------  Unterprogramme zur Behandlung der Uhr:  -------------- }

FUNCTION TgetTime : INTEGER; GEMDOS($2C);
FUNCTION TgetDate : INTEGER; GEMDOS($2A);

PROCEDURE Datum_lesen ( VAR date : t_datum );
{ Datum der Systemuhr nach INTEGER (16 Bits) lesen:
  Datum in Bitverteilung :    111111
                              5432109  8765  43210
                              -------  ----  -----
                Bedeutung:     Jahr    Monat  Tag
                     Mask:      $7F     $F    $1F
  Hinweis: & entspricht bitweise UND !                 }
VAR d : INTEGER;
BEGIN
  d := TgetDate;
  date.tag := d & $1F;
  d := ShR(d,5);
  date.monat := d & $F;
  d := ShR(d,4);
  date.jahr := ( d & $7F ) + 1980;
END; { Datum_lesen }

PROCEDURE Zeit_lesen ( VAR zeit : t_zeit );
{ Zeit der Systemuhr lesen: }
{ Zeit der Systemuhr nach INTEGER (16 Bits) lesen:
  Zeit in Bitverteilung :    11111  1
                             54321  098765  43210
                             -----  ------  -----
                Bedeutung:   Stunde  Min.    sec
                     Mask:     $1F   $3F     $1F    }
VAR z : INTEGER;
BEGIN
  z := TgetTime;
  zeit.sek := ( ( z & $1F ) MOD 30 ) * 2;
  z := ShR(z,5);
  zeit.min := ( z & $3F ) MOD 60;
  z := ShR(z,6);
  zeit.std := ( z & $1F ) MOD 24;
END; { Zeit_lesen }

{ --- lokale Prozedur: (wird nur von dat_to_str und time_to_str benutzt) }
Procedure i_KALBER_Str ( i : integer; VAR w : Str );
{ Die positive Integerzahl 'i' wird in den String 'w' verwandelt }
var z:Char;
begin
  w:=' ';
  while i>= 10 do
  begin
    z:=Chr( i mod 10 + Ord('0') );
    Insert(z,w,1);
    i:=i div 10;
  end;
  z:=Chr( i + Ord('0') );
  Insert(z,w,1);
  Delete(w,Length(w),1);
end; { i_KALBER_Str }
{ --------------------------------------------------------------------- }

PROCEDURE dat_to_str ( para : t_datum; VAR erg : Str );
{ wandelt die in para Åbergebene Datum in die 'formatierte' (00.00.0000) }
{ Zeichenkette erg um.                                                   }
VAR help : Str;
    laenge : INTEGER;

BEGIN  { dat_to_str }
  erg:='00.00.0000 ';
  WITH para DO
  BEGIN
    i_KALBER_Str(tag,help);
    laenge:=LENGTH(help);
    DELETE(erg,3-laenge,laenge);
    INSERT(help,erg,3-laenge);
    i_KALBER_Str(monat,help);
    laenge:=LENGTH(help);
    DELETE(erg,6-laenge,laenge);
    INSERT(help,erg,6-laenge);
    i_KALBER_Str(jahr,help);
    laenge:=LENGTH(help);
    DELETE(erg,11-laenge,laenge);
    INSERT(help,erg,11-laenge);
  END;
  DELETE(erg,11,1);
END; { dat_to_str }

PROCEDURE time_to_str ( para : t_zeit; VAR erg : Str );
{ wandelt die in para Åbergebene Zeit in die 'formatierte' (00:00:00) }
{ Zeichenkette erg um.                                                }
VAR help : Str;
    laenge : INTEGER;

BEGIN  { time_to_str }
  erg:=' 0:00:00 ';
  WITH para DO
  BEGIN
    i_KALBER_Str(std,help);
    laenge:=LENGTH(help);
    DELETE(erg,3-laenge,laenge);
    INSERT(help,erg,3-laenge);
    i_KALBER_Str(min,help);
    laenge:=LENGTH(help);
    DELETE(erg,6-laenge,laenge);
    INSERT(help,erg,6-laenge);
    i_KALBER_Str(sek,help);
    laenge:=LENGTH(help);
    DELETE(erg,9-laenge,laenge);
    INSERT(help,erg,9-laenge);
  END;
  DELETE(erg,9,1);
END; { time_to_str }

PROCEDURE ErmittleDatumUndZeit( VAR DuZ : Str );
VAR zeit  : t_zeit;
    datum : t_datum;
    zeitS, datumS : Str;
BEGIN
  Zeit_lesen( zeit );
  Datum_lesen( datum );
  time_to_str( zeit, zeitS );
  dat_to_str( datum, datumS );
  DuZ:=Concat(datumS,' ',zeitS);
END;
  
{ ------------------------------------------------------------------- }


PROCEDURE HistoryLesen( HisDat : Str; VAR alteZeile : Str );
{         ------------
 Lesen der alten Einstellungszeile.
}
BEGIN
  Reset( History, HisDat );
  WHILE NOT(EOF(History)) DO
  BEGIN
    ReadLn( History, alteZeile );
  END;
  Close( History );
END;


PROCEDURE HistorySchreiben( HisDat : Str; neueZeile : Str );
{         ----------------
 Schreiben von neueZeile in die Datei.
}
BEGIN
  Rewrite( History, HisDat );
  Write( History, neueZeile );
  Close( History );
END;

FUNCTION InitAntwortFragen : CHAR;
VAR ch : CHAR;
BEGIN
  WriteLn;
  WriteBlanks; WriteLn('Erstellen einer neuen Datei: ',HistoryDatei);
  WriteBlanks; WriteLn('mit der Voreinstellung X fÅr die letzte MenÅwahl.');
  WriteBlanks; WriteLn('SPACE oder Sondertasten brechen das Programm ab!');
  WHILE NOT( ch IN [ KeyStart..KeyEnd ] ) AND (ch<>' ') DO
  BEGIN
    WriteBlanks; Write( 'X = ' );
    Read_Key( ch ); Write( ch );
    WriteLn;
  END;
  InitAntwortFragen:=ch;
END;


 {---------------------  H A U P T P R O G R A M M  ----------------------}
 
BEGIN

  { Falls niedrige Auflîsung dann in mittlere umschalten: }
  IF Getrez=0 THEN 
  BEGIN
    LoRes:=TRUE;
    Setscreen( -1, -1, 1 );
    Dummy:=SetColor(0,$777); { Standardfarben oder Lieblingspalette! }
    Dummy:=SetColor(1,$700);
    Dummy:=SetColor(2,$060);
    Dummy:=SetColor(3,$000);
  END
  ELSE LoRes:=False;

  { Argumente der Kommandozeile? }
  Test:=OPTION('TEST') OR OPTION('test');
  Init:=OPTION('INIT') OR OPTION('init');
    
  ErmittleDatumUndZeit( DatumUndZeit );
  Get_Drive( Laufwerk );
  WriteLn;
  WriteBlanks; WriteLn('Bootlaufwerk: ',Laufwerk,'               Heute: ',DatumUndZeit);
  WriteBlanks; WriteLn('<------------------------------------------------------->');
  WriteBlanks; WriteLn('<   Bootkonfiguration ', Version , ' von Steffen Gîtz   >');
  WriteBlanks; WriteLn('<---------------< (C) 1989 by YETIsoft >---------------->');
  WriteLn;
  
  IF Test THEN
  BEGIN
    WriteBlanks; inverse_on;
    Write('**** TEST-Modus: Es wird nichts auf Platte verÑndert! ***');
    inverse_off;
    WriteLn;
  END;
  
  IF Init THEN
  BEGIN
    IF Test THEN
    BEGIN
      WriteBlanks; WriteLn('Bitte nur eine Option angeben!')
    END
    ELSE
    BEGIN
      Antwort:=InitAntwortFragen;
      IF Antwort<>' ' THEN
      BEGIN
        neueEinstellung:=Concat( DatumUndZeit, ' > ', Antwort, ' erzeugt mit INIT-Option!' );
        WriteLn;
        WriteBlanks; WriteLn('Konfiguration wird geschrieben.');
        HistorySchreiben( Concat(Laufwerk,'\AUTO\',HistoryDatei), neueEinstellung );
      END
      ELSE
      BEGIN
        WriteBlanks; WriteLn('Programmabruch! Es wird nichts geschrieben.');
      END;
    END;
    WriteLn;
    WriteBlanks; Write('Das war''s schon. Ende mit RETURN.');
    ReadLn;
  END
  ELSE
  BEGIN
  
    HistoryLesen( Concat(Laufwerk,'\AUTO\',HistoryDatei), alteEinstellung );
    WriteBlanks; WriteLn('Letzte Einstellung vom ');
    WriteBlanks; inverse_on; WriteLn( alteEinstellung ); inverse_off;
    WriteLn;
    
    AlteAntwort:=alteEinstellung[ 23 ];
    IF NOT( AlteAntwort IN [ KeyStart..KeyEnd ] ) THEN
      ERRORHALT('Fehler in der Historydatei (alte Antwort muû auf Pos. 23 stehen).');
         
    KonfigLesen( Concat(Laufwerk,'\AUTO\',KonfigDatei) );
    ZeigerFinden( 'MENU', Zeile, MENUZeiger );
    Antwort:=MenuAbfragen( MENUZeiger, KeyMax );
    WriteLn;
    WriteLn;
    IF ( Antwort IN [ KeyStart..KeyMax ] ) AND ( Antwort<>AlteAntwort ) THEN
    BEGIN
      WriteBlanks; WriteLn('Umkonfiguration gestartet.');
      WriteLn;
      ZeigerFinden( 'AUTO', Spalte, AUTOZeiger );
      Umbenennen( Antwort, AlteAntwort, Concat(Laufwerk,'\AUTO\'), 'PRG', AUTOZeiger );
      ZeigerFinden( 'ACC', Spalte, ACCZeiger );
      Umbenennen( Antwort, AlteAntwort, Laufwerk, 'ACC', ACCZeiger );
      ZeigerFinden( 'DESKTOP', Zeile, DESKTOPZeiger );
      DESKTOPumbenennen( Antwort, AlteAntwort, Laufwerk, DESKTOPZeiger );
      WriteLn;
      WriteBlanks; WriteLn('Umkonfiguration beendet.');
      neueEinstellung:=Concat( DatumUndZeit, ' > ',
                               Konfig[ MENUZeiger.Index + MENUZeiger.Position[ Antwort ] ] );
      IF NOT(Test) THEN HistorySchreiben( Concat(Laufwerk,'\AUTO\',HistoryDatei), neueEinstellung );
    END 
    ELSE 
    BEGIN 
      WriteBlanks; WriteLn('Keine Umkonfiguration notwendig.');
    END;
    
  END;

  IF Test THEN
  BEGIN
    WriteBlanks; inverse_on;
    Write('************ Ende des Testlaufs. Programmende mit RETURN!');
    inverse_off;
    ReadLn;
  END;
  
  { wieder zurÅckschalten: }
  IF LoRes THEN Setscreen( -1, -1, 0 );
  
END.

