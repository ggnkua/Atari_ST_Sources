(************************************************
* Projekt  : Boot-Routinen-Installation         *
*----------+------------------------------------*
* Stand    : 21.05.1990                         *
* Autor    : Jrgen Fischer, 2980 Norden        *
* Compiler : FTL Modula-2  (V1.18)              *
*----------+------------------------------------*
* Bemerkungen :                                 *
* Dieses Programm ist weitgehend frei von FTL   *
* Modula-2 spezifischen Modulen und Funktionen  *
* und sollte daher auf vielen Compilern nach    *
* kleinen Modifikationen lauff„hig sein.        *
*************************************************
************ (c) Jrgen Fischer 1990 ************
************************************************)
MODULE BootInstall ;

FROM SYSTEM IMPORT
  ADDRESS, ADR, BYTE, WORD ;
FROM BIOS IMPORT
  RCON, bconout, rwabs ;
FROM FileSystem IMPORT
  File, Lookup, Close, ReadWord ;
FROM InOut IMPORT
  WriteString, WriteCard, ReadString, WriteLn,
  Read, Write ;

(*
  Bemerkung zur BIOS-Importliste:
  
  Parameter sind unter FTL Modula-2 bedingt durch
  seine Stackbehandlung in umgekehrter Reihen-
  folge zu bergeben als z.B. in C.

  PROCEDURE bconout ( char :     WORD ;
                      dev  : CARDINAL
                    ) : INTEGER ;

    Gibt ein Zeichen aus und untersttzt dabei
    mehrere Ausgabekan„le (-ger„te).

    Kanal RCON (RAWCON/Kennung 5):
     Dieser Ausgabekanal gibt wie CON (Kennung 2)
     auf den Bildschirm aus, ignoriert dabei aber
     Steuerzeichen und die VT52-Terminal-
     Emulation.

  PROCEDURE rwabs ( drv, recno,
                    count       : CARDINAL ;
                    buffer      :  ADDRESS ;
                    rwflag      : CARDINAL 
                  ) : LONGINT ;

    Liest/Schreibt Sektoren von Diskette.

    drv       Laufwerk (A=0; B=1; ...)
    recno     1. Sektor (logische Nummer )
    count     Anzahl der zuschreibenden/
              zulesenden Sektoren
    buffer    Adresse des Puffers
    rwflag    Operation (2 lesen; 3 schreiben)


  Bemerkung zur FileSystem-Importliste:
    Dieses Modul wurde von mir in FTL Modula-2
    implementiert, da es zwar nicht mitgeliefert
    wird, aber als Standardmodul fr jedes
    Modula-2-System verfgbar sein sollte.
    Daher sollte dieses Programm auch auf den
    meisten Compilern zum Laufen zu bringen sein.
    FTL-Programmierer mssen das Programm auf das
    Modul 'Streams' umstricken !!!
 
    ACHTUNG:
    f.res  ist als bool'sche Variable definiert;
           TRUE bedeutet ok; FALSE Fehler (muž
           ggfs. angepažt werden)
*)

CONST
  (* Maximale L„nge der Bootroutine in Byte *)
  BootLen       =    480 ;
  (* Opcode am Anfang des Bootsektors       *)
  BootBranch    = 0601CH ;


TYPE
  (* Fllbytes im Bootsektor fr Routinennamen *)
  Filler        =       ARRAY [ 0..5 ] OF CHAR ;
  (* Platzhalter fr die Formatdaten *)
  Formatdata    =      ARRAY [ 0..21 ] OF CHAR ;
  (* Puffertyp fr Bootroutine *)
  Bootroutine   = ARRAY [ 1..BootLen ] OF CHAR ;
  (* Bootsektoraufbau *)
  Bootsector    = RECORD
                    Branch :    CARDINAL ;
                    FILLER :      Filler ;
                    Format :  Formatdata ;
                    BOOT   : Bootroutine ;
                    CHKSUM :    CARDINAL
                  END (* Bootsector *) ;
                  
VAR
  (* Puffer fr zuladenden Bootsektor *)
  Bootsec  :  Bootsector ;
  (* Puffer fr zuladende Bootroutine *)
  Bootrout : Bootroutine ;
  (* Name der geladenen Bootroutine *)
  Bootname :      Filler ;
  (* Dummy zur Zeicheneingabe *)
  ch       :        CHAR ;
  (* Dummy fr Funktionsaufrufe *)
  reply    :     INTEGER ;

  (* Gibt eine LONGCARD-Varible auf dem
     Bildschirm aus *)
  PROCEDURE WriteLong ( card   : LONGCARD ;
                        places : CARDINAL ) ;
  VAR
    buf   : ARRAY [ 0..15 ] OF CHAR ;
    index :                 INTEGER ;
  BEGIN
    IF card = 0 THEN
      buf [ 15 ] := '0' ;
      index := 14
    ELSE
      index := 15 ;
      WHILE ( index >= 0 ) & ( card # 0 ) DO
        buf [ index ] :=
          CHR (
                ORD ('0') +
                CARDINAL ( card MOD 10 )
              ) ;
        card := card DIV 10 ;
        DEC ( index )
      END (* WHILE *)
    END (* IF *) ;
    places := places - 14 + CARDINAL ( index ) ;
    WHILE places > 0 DO
      Write ( ' ' ) ;  DEC ( places )
    END (* WHILE *) ;
    WHILE index < 15 DO
      INC ( index ) ;
      Write ( buf [ index ] )
    END (* WHILE *)
  END WriteLong ;

  (* Liest einen Block von Diskette *)
  PROCEDURE ReadBlock ( VAR f      :     File ;
                            block  :  ADDRESS ;
                            Length : LONGCARD ) :
 BOOLEAN ;
  TYPE
    pWORD = POINTER TO WORD ;
  VAR
    buf : pWORD ;
  BEGIN
    buf := block ;
    Length := Length DIV 2 ;
    WHILE ( Length > 0 ) & ~f.eof DO
      ReadWord ( f, buf^ ) ;
      (* Zeiger auf n„chstes Wort *)
      buf := pWORD ( LONGCARD ( buf ) + 2 ) ;
      DEC ( Length )
    END (* WHILE *)
    RETURN Length = 0
  END ReadBlock ;

  (* Bootroutine mit 0E5h fllen *)  
  PROCEDURE Init ;
  VAR
    index : INTEGER ;
  BEGIN
    (* VT52: Clear Screen *)
    Write ( 33C ) ;  Write ( 'E' ) ;
    (* VT52: Wrap at end of line *)
    Write ( 33C ) ;  Write ( 'v' ) ;
    WriteString ( 'BOOTINST - Installations') ;
    WriteString ( 'programm fr Bootsektor' ) ;
    WriteString ( 'routinen' ) ;
    WriteLn ;
    WriteString ( '(c) Jrgen Fischer 1990' ) ;
    WriteLn ;
    FOR index := 1 TO BootLen DO
      Bootrout [ index ] := CHR ( 0E5H )
    END (* FOR *)
  END Init ;

  (* Bootroutine aus einer Programmdatei
     nachladen *)
  PROCEDURE LoadBootroutine () : BOOLEAN ;
  CONST
    (* Opcode am Anfang einer Programmdatei *)
    ProgramBranch = 0601AH ;
  TYPE
    (* Struktur des Programmdateikopf *)
    ProgramHeader = RECORD
                      PhBranch : CARDINAL ;
                      PhTLen   : LONGCARD ;
                      PhDLen   : LONGCARD ;
                      PhBLen   : LONGCARD ;      
                      PhSLen   : LONGCARD ;
                      PhRes1   : LONGCARD ;      
                      PhRes2   : LONGCARD ;      
                      PhFlag   : CARDINAL        
                    END (* ProgramHeader *) ;
  VAR
    (* Puffer fr Dateinamen *)
    fname : ARRAY [ 0..127 ] OF CHAR ;           
    file  :                     File ;
    (* Programmkopf der Bootroutine *)
    PH    :            ProgramHeader ;
  BEGIN
    WriteString ( 'Name der Programmdatei mit') ;
    WriteString ( ' der Bootroutine ' ) ;
    WriteString ( 'eingeben:' ) ;
    ReadString ( fname ) ;
    WriteLn ;

    (* Leereingabe bricht Installationslauf ab *)
    IF fname [ 0 ] = 0C THEN
      RETURN FALSE
    END (* IF *) ;
    
    WriteString ( 'Lade Bootroutine...' ) ;
    WriteLn ;

    (* Datei ”ffnen *)
    Lookup ( file, fname, FALSE ) ;

    (* Datei existiert ? *)
    IF file.res THEN                             
      (* Programmkopf laden,
         Programmdatei gltig ? *)
      IF ReadBlock ( file,
                     ADR ( PH ), SIZE ( PH ) ) &
         ( PH.PhBranch = ProgramBranch ) THEN
        WITH PH DO
          (* Segmentinformationen ausgeben *)
          WriteString
            ( 'TEXT-Segmentl„nge : ' ) ;
          WriteLong ( PhTLen, 10 ) ;
          WriteLn ;
          WriteString
            ( 'DATA-Segmentl„nge : ' ) ;
          WriteLong ( PhDLen, 10 ) ;
          WriteLn ;
          WriteString
            ( 'BS-Segmentl„nge   : ' ) ;
          WriteLong ( PhBLen, 10 ) ;
          WriteLn ;

          (* BS-Segment darf sich zur Laufzeit
             mit CHKSUM berschneiden *) 
          IF PhBLen >= 2 THEN
            DEC ( PhBLen, 2 )
          END (* IF *) ;

          (* Bootprogramm darf (inklusive Daten) 
             nicht zu lang sein *)
          IF PhTLen +
             PhDLen +
             PhBLen <= BootLen THEN

            (* Bootroutine laden
               (nur TEXT- und Datensegment) *)
            IF ReadBlock ( file,
                           ADR ( Bootrout ),
                           PhTLen + PhDLen ) THEN
              WriteString
                ( 'Name der Bootroutine ' ) 
              WriteString
                ( '(max. 6 Zeichen): ' ) ;
              ReadString ( Bootname ) ;
              WriteLn ;

              RETURN TRUE
            ELSE
              (* Datei zu kurz *)
              WriteString
                ( 'Programmdatei besch„digt.' )
            END (* IF *)
          ELSE
            (* Programm zu lang *)
            WriteString
              ( 'Programm zu lang fr' ) ;
            WriteString
              ( 'Bootsektor (max. ' ) ;
            WriteCard ( BootLen, 3 ) ;
            WriteString
              ( ' Bytes inklusive Daten).' )
          END (* IF *)
        END (* WITH *)
      ELSE
        (* Ungltiger Dateikopf *)
        WriteString
          ( 'Keine gltige Programmdatei.' )
      END (* IF *) ;
      Close ( file )
    ELSE
      (* Datei konnte nicht ge”ffnet werden *)
      WriteString ( 'Datei nicht gefunden.' )
    END (* IF *) ;
    WriteLn ;
    RETURN FALSE
  END LoadBootroutine ;

  (* Geladene Bootroutine installieren *)        
     
  PROCEDURE InstallLoop ;
  TYPE
    Sector  = ARRAY [ 1..256 ] OF CARDINAL ;
    pSector =            POINTER TO Sector ;
    
    (* šberprft, ob der geladene Bootsektor
       ausfhrbar ist. *)
    PROCEDURE Executeable () : BOOLEAN ;
    VAR
      ptr          :  pSector ;
      index, summe : CARDINAL ;
    BEGIN
      (* Summe ber alle W”rter des Sektors
         bilden *)
      summe := 0 ;
      ptr := ADR ( Bootsec ) ;
      FOR index := 1 TO 256 DO
        INC ( summe, ptr^ [ index ] )
      END (* FOR *) ;
      (* Ausfhrbar, wenn Wortsumme = 1234h *) 
      RETURN summe = 1234H
    END Executeable ;

    (*
      Bootsektordaten ausgeben und abfragen ob
      der Bootsektor berschieben werden darf
    *)
    PROCEDURE ReallyOverwrite () : BOOLEAN ;
    VAR
      index : CARDINAL ;      

    BEGIN
      WITH Bootsec DO
        WriteString (
             'Dieser Bootsektor ist ausfhrbar !'
                    ) ;
        WriteLn ;
        WriteString ( 'FILLER       :' ) ;
        WriteString ( FILLER ) ;
        WriteLn ;
        WriteString ( 'Routinenstart:' ) ;
        WriteCard   ( Branch MOD 100H + 2, 7 ) ;
        WriteLn ;
        WriteString
          ( 'ASCII-Dump der BOOT-Routine :' ) ;
        (* Ab Routinenbeginn listen *)
        FOR index :=
          ( Branch MOD 100H - 27 ) TO BootLen DO

          IF index MOD 64 = 1 THEN
            WriteLn
          END (* IF *) ;
          reply :=
            bconout ( BOOT [ index ], RCON )
        END (* FOR *) ;
        WriteLn ;
        WriteLn ;
        WriteString
          ( 'Soll er wirklich berschrieben' ) ;
        WriteString
          ( ' werden ? (ESC=Abbruch) ' ) ;
        Read ( ch ) ;
        WriteLn
      END (* WITH *) ;
      RETURN ch # 33C
    END ReallyOverwrite ;

    (* CHKSUM so berechnen, daž die Bootsektor-
       wortsumme 1234h ergibt *)
    PROCEDURE MakeMagic ;
    VAR
      ptr          :  pSector ;
      index, summe : CARDINAL ;
    BEGIN
      (* Die ersten 255 W”rter addieren *)
      summe := 0 ;
      ptr := ADR ( Bootsec ) ;
      FOR index := 1 TO 255 DO
        INC ( summe, ptr^ [ index ] )
      END (* FOR *) ;
      (* CHKSUM anpassen, damit Gesamtsumme
         gleich 1234h ist *)
      Bootsec.CHKSUM := 1234H - summe
    END MakeMagic ;
   
  BEGIN
    LOOP
      WriteString
        ( 'Diskette in Laufwerk A: einlegen ' ) ;
      WriteString
        ( 'und Taste drcken (ESC=Ende).' ) ;
      Read ( ch ) ;
      WriteLn ;
      IF ch = 33C THEN
        EXIT  (* Bei ESCAPE abbrechen *)
      END (* IF *) ;

      (* Bootsektor von Diskette lesen *)
      IF rwabs ( 0, 0, 1,
                 ADR ( Bootsec ), 2 ) = 0 THEN
        (* Falls nicht Bootsektor nicht
           ausfhrbar ist, Installation
           vornehmen, sonst vorher
           sicherheitshalber nachfragen. *)
        IF ~Executeable()     OR
            ReallyOverwrite() THEN
          WITH Bootsec DO
            (* Sprungopcode eintragen *)
            Branch := BootBranch ;
            (* Routinennamen eintragen *)
            FILLER := Bootname ;
            (* Bootroutine eintragen *)
            BOOT   := Bootrout        
          END (* WITH *) ;
          (* Wortsumme auf 1234h bringen *)
          MakeMagic ; 
          (* Bootsektor zurckschreiben *)
          IF rwabs
              ( 0, 0, 1, ADR ( Bootsec ), 3 ) # 0
          THEN
            WriteString ( 'Schreibfehler.' )

          END (* IF *)
        END (* IF *)
      ELSE
        WriteString ( 'Lesefehler.' )
      END (* IF *) ;
      WriteLn
    END (* LOOP *)      
  END InstallLoop ;
                      
BEGIN
  Init ;               (* Bootroutine l”schen, *)
  IF LoadBootroutine() THEN   (* Routine laden *)
    InstallLoop            (* und installieren *)
  END (* IF *)
END BootInstall .
