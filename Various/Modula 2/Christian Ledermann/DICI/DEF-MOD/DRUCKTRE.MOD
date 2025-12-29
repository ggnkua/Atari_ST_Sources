IMPLEMENTATION MODULE DruckTreiber;

(************************************************************************
 * Druckertreiber-Modul fÅr LPR-Modula2                                 *
 *                                                                      *
 * V2.0, (c) 9/1989 by Uwe Ischebeck, Ringstr.31, 6900 Heidelberg       *
 *                                                                      *
 * Beschreibung im DEF-Modul                                            *
 ************************************************************************)

IMPORT GEMDOS;

FROM SYSTEM IMPORT ADR, LONG, SHORT, TSIZE, ADDRESS;

VAR anzahl : LONGINT;
    dummy : INTEGER;
    CRLF : ARRAY[0..1] OF CHAR;
    

PROCEDURE Sloeschen;
  VAR i:INTEGER;
  BEGIN
    S.LQ:=FALSE;                     (* LQ-flag lîschen          *)
    FOR i:=0 TO MaxFunc DO           (* Codetabelle lîschen      *)
      S.c[i]:=0 END;
    FOR i:=0 TO 255 DO               (* Zeichentabelle lîschen   *)
      S.z[i]:=0 END;
    S.n:=NIL;                        (* Zeiger auf Namen lîschen *)
    S.geladen:=FALSE;                (* keine Anpassung geladen  *)
  END Sloeschen;
    

PROCEDURE ConfigPrinter( GemdosPrnOutHandle : INTEGER; 
                         name : ARRAY OF CHAR; ersatz : CHAR );
  VAR i, num, FileHandle : INTEGER;
      anzahl : LONGINT;
      ok : BOOLEAN;
  BEGIN
    ok:=FALSE;
    Sloeschen;                          (* Lîschen aller Tabellen    *)
    i:=0;                               (* Name der CFG-Datei in die *)
    WHILE (i<=HIGH(S.d)) & (i<=HIGH(name)) DO 
      S.d[i]:=name[i];                  (* Tabelle kopieren          *)
      INC(i);               
    END;
    GEMDOS.Open(S.d,0,FileHandle);       (* CFG-Datei îffnen         *)
    CfgError:=GEMDOS.ErrorNo;
    IF (CfgError=0) AND (FileHandle<0) THEN CfgError:=FileHandle END;
    IF CfgError=0 THEN
      anzahl:=SIZE(S.a);                 (* Datei einlesen           *)
      GEMDOS.Read( FileHandle, anzahl, ADR(S.a) );
      CfgError:=GEMDOS.ErrorNo;
      IF CfgError=0 THEN
        IF GemdosPrnOutHandle>=0 THEN    (* Ausgabehandle festlegen  *)
          S.filehandle:=GemdosPrnOutHandle END;
        S.ersatz:=ersatz;                (* unbek. Druckzeichen      *)
        i:=0;
        WHILE (S.a[i]#0C) & (i<80) DO    (* Ende des Namens finden   *)
          INC(i) END;                    (* (durch 0C terminiert)    *)
        IF i<80 THEN                     (* i<80: Namensende gefunden *)
          S.n:=ADR(S.a[8]);              (* Name beginnt an 8.Stelle *)
          INC(i);                        (* 0C Åberspringen          *)
          FOR num:=0 TO 5 DO             (* Config-Parameter         *)
            S.par[num]:=S.a[i];          (* Åbertragen               *)
            INC(i)
           END;
          WHILE S.a[i]#0C DO             (* Funktionstabelle 0-terminiert *)
            num:=ORD(S.a[i+1]);          (* FktNummer an 2.Stelle,   *)
            S.c[num]:=i;                 (* FktLÑnge an 1.Stelle     *)
            i:=i+ORD(S.a[i]);            (* nÑchste Fkt              *)
          END (* Funktionen festlegen *);
          INC(i);                        (* 0hex Åberspringen        *)
          WHILE S.a[i]#0C DO             (* Zeichentabelle 0-terminiert *)
            num:=ORD(S.a[i+1]);          (* Aufbau wie Fkt-Tabelle   *)
            S.z[num]:=i;
            i:=i+ORD(S.a[i]);            (* nÑchstes Zeichen         *)
          END (* Zeichentabelle festlegen *);
          S.geladen:=TRUE;               (* Flag "Anpassung geladen" *)
        END (* IF i<80 (Wahrscheinlichkeit fÅr CFG-Datei groû) *)
      END (* IF file read *);
      ok:=GEMDOS.Close(FileHandle);
    END (* IF file opened *);
  END ConfigPrinter;

PROCEDURE PrintHandle( handle : INTEGER );
  BEGIN
    IF handle>=0 THEN S.filehandle:=handle END; 
  END PrintHandle;
  
PROCEDURE PrintDirektString( str : ARRAY OF CHAR );
  VAR l : INTEGER;
  BEGIN
    l:=0;
    LOOP (* Wie lang ist "str", da evtl. nicht mit 0C terminiert *)
      IF l>HIGH(str) THEN EXIT
      ELSIF str[l]=0C THEN EXIT   END;
      INC(l) 
    END;
    anzahl:=LONG(l);
    GEMDOS.Write(S.filehandle,anzahl,ADR(str) ); (* Ausgabe *)
  END PrintDirektString;
  
PROCEDURE Steuer( nr : INTEGER; VAR wert : INTEGER );
  VAR i, l, p, p80, p81 : INTEGER;
  BEGIN
    IF (nr>=0) AND (nr<=MaxFunc) THEN (* Eine erlaubte FunktionsNr? *)
      IF S.geladen THEN               (* Anpassung geladen?         *)
        IF S.LQ THEN                  (* Wenn Schînschrift, dann    *)
          CASE nr OF                  (* LQ-Funktionen verwenden.   *)
            6..1BH:  IF ((nr-6) MOD 4)<2 THEN  (* dadurch weniger   *)
                       i:=nr+2;                (* Programmieraufwand*)
                     END;                      (* fÅr verschiedene  *)
          | 28H..2EH: IF NOT ODD(nr) THEN      (* SchriftqualitÑten *)
                        i:=nr+1;
                      END;
          ELSE i:=nr
          END;
          IF S.c[i]#0 THEN nr:=i END;
        END;
        p:=S.c[nr];
        IF p#0 THEN
          l:=ORD(S.a[p]);
          IF l>2 THEN
            IF wert>=0 THEN
              p80:=0; p81:=0;
              FOR i:=p+2 TO p+l DO              (* EnthÑlt die Fkt den *)
                IF S.a[i]=200C THEN p80:=i END; (* Platzhalter 80hex   *)
                IF S.a[i]=201C THEN p81:=i END; (* oder 81hex ?        *)
              END;            (* Dann muût Du den "wert" da einsetzen: *)
              IF p80>0 THEN 
                S.a[p80]:=CHR(wert MOD 256);
                IF p81>0 THEN S.a[p81]:=CHR(wert DIV 256) END; 
                wert:=-1;
              END;
            END;
            anzahl:=LONG(l-2);                 (* und jetzt ausgeben *)
            GEMDOS.Write(S.filehandle,anzahl,ADR(S.a[S.c[nr]+2]) );
            IF p81>0 THEN S.a[p81]:=201C END; (* Platzhalter wieder  *)
            IF p80>0 THEN S.a[p80]:=200C END; (* einsetzen!          *)
          END;
        END;
      ELSE (* keine Konfiguration geladen, hier evtl. Defaultdruck   *)
      END;
    END;
  END Steuer;
    
PROCEDURE PrintSteuer( nr, wert : INTEGER );
  BEGIN Steuer( nr, wert )
  END PrintSteuer;

PROCEDURE SetLQ( lq : BOOLEAN );
  BEGIN
    S.LQ:=lq
  END SetLQ;
          
PROCEDURE PrintLn;
  BEGIN                                 (* wenn eine Anpassung geladen *)
    IF S.geladen THEN PrintSteuer(1,dummy); (* ist, den Code fÅr Zeilenende*)
                 ELSE PrintDirektString(CRLF) END; (* schicken, sonst  *)
  END PrintLn;                          (* 0Dhex und 0Ahex             *)
  
PROCEDURE PrintFormFeed;
  BEGIN
    PrintSteuer(01EH,dummy)                 (* nur wenn Anpassung geladen  *)
  END PrintFormFeed;
        
PROCEDURE PrintChar(c:CHAR);
  VAR l,p : INTEGER;
      adresse : ADDRESS;
  BEGIN 
    anzahl:=1; p:=S.z[ORD(c)];
    IF p#0 THEN                      (* druckt die fÅr das Zeichen "c" *)
      l:=ORD(S.a[p])-2;              (* notwendige Zeichenkette,       *)
      IF l>0 THEN
        anzahl:=LONG(l);
        adresse:=ADR(S.a[p+2]);
      ELSE                           (* wenn das Zeichen nicht verfÅg- *)
        IF S.ersatz=0C THEN adresse:=NIL (* bar ist --> Ersatzzeichen  *)
                       ELSE adresse:=ADR(S.ersatz) END;
      END
    ELSE                             (* Zeichen wurde nicht umdefiniert*)
      adresse:=ADR(c)                (* Ausdruck direkt.                   *)
    END;
    IF adresse#NIL THEN
      GEMDOS.Write(S.filehandle,anzahl,adresse ) END;
  END PrintChar;
        
PROCEDURE PrintString( ein : ARRAY OF CHAR );
  VAR i : INTEGER;
  BEGIN 
    i:=0;
    LOOP
      IF i>HIGH(ein) THEN EXIT   (* schickt alle Zeichen von "ein" *)
      ELSIF ein[i]=0C THEN EXIT  (* an die Prozedur PrintChar      *)
      END;
      PrintChar(ein[i]); INC(i)
    END (* LOOP *)
  END PrintString;

PROCEDURE PrintString4(s0, s1, s2, s3 : INTEGER; str : ARRAY OF CHAR );
  VAR s : ARRAY[0..3] OF INTEGER;
      i : INTEGER;
  BEGIN                (* Mache aus den Parametern s0..s3 ein Array *)
    s[0]:=s0; s[1]:=s1; s[2]:=s2; s[3]:=s3; i:=0;
    WHILE i<4 DO
      IF s[i]>=0 THEN
        IF i<3 THEN Steuer(s[i],s[i+1])
               ELSE Steuer(s[i],dummy) END;
      END;
      INC(i);
    END;
    PrintString(str);                        (* Zeichenkette drucken *)
  END PrintString4;
  
PROCEDURE PrintDirekt( c : CHAR );
  BEGIN
    anzahl:=1;
    GEMDOS.Write(S.filehandle,anzahl,ADR(c) );
  END PrintDirekt;
  
PROCEDURE PrintDirektLn;
  BEGIN PrintDirektString(CRLF) END PrintDirektLn;

BEGIN   
  S.filehandle:=3;         (* Initialisieren *)
  S.geladen:=FALSE;
  S.ersatz:=0C;
  CRLF[0]:=15C; CRLF[1]:=12C;
  dummy:=-1;
END DruckTreiber.
