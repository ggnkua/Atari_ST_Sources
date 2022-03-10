(**************************************************************************)
MODULE Bootedit; (*                    Remo Hofer           5.  6. 87     *)
(*                                     letzte Modifikation 29. 10. 91 RHo *)
(* compiliert mit TDI-Modula 2 Compilerversion 3.00a                      *)
(* v 1.2 mit 4-spaltiger Darstellung                                      *)
(* v 1.3 evt. laden der ACC's von C:\ beim booten von A:\                 *)
(* v 1.4 Writeprotect Fehlermeldung                                       *)
(* v 1.5 Mausunterstuetzung                                               *)
(* v 1.6 rechte Maustaste fuer Programmabbruch                            *)
(* v 1.7 Timing beim starten verbessert                                   *)
(**************************************************************************)

FROM Strings IMPORT CompareResults, Compare, Concat, Pos;
FROM GEMDOS IMPORT SetDTA, SetDrv, GetDrv, SFirst, SNext, Rename,
     RawScanIn, ConIS, ConOut, ConWS;
FROM XBIOS IMPORT  KeyboardWS, SuperExec;
FROM SYSTEM IMPORT ADDRESS, ADR, REGISTER;

CONST
  Titel  = "           Accessory- & Autostart-Editor v 1.7 (c) 1991 by Remo Hofer           ";
  PressK = "Press any key to enter BOOTEDIT!";
  Exit   = "All right, forget it!";
  Ok     = "                  okay                  ";
  Err1   = " Maybe there're some more PRG's around! ";(* Fehlermeldungen *)
  Err2   = " Maybe there're some more ACC's around! ";
  Err3   = "      Too much accessories active!      ";
  Err4   = "          Cannot change State!          ";(* v 1.4 *)
  Bye    = "               bye, bye...              ";
  Myself = "BOOTEDIT.PRG"; (* Name des Programs *)
  Maxfiles = 36; (* Anzahl Files, die pro Typ max. gezeigt werden *)
  TimeToWait = 200; (* Zeit fuer Start in 200stel Sekunden v 1.7 *)
  ShowTime = 100; (* Zeit fuer Schlussformel v 1.7 *)
  Xok = 20;(* Koordinaten *)
  Yok = 23;
  Xprg = 45;
  Xacc = 5;
  Y = 3;
  Xstart = 20;
  Ystart = 3;
  Esc = 33C;(* Steuerzeichen *)
  Inverse = "p";
  Normal = "q";
  Home = "E";
  CurOff = "f";
  EraseToEnd = "J";
  Return = 34C;(* Scan-Codes *)
  Enter = 162C;
  Space = 71C;
  MouseButton = 164C;(* v 1.5 *)
  RightMouseButton = 165C;(* v 1.6 *)
  Up = 110C;
  Down = 120C;
  Left = 113C;
  Right = 115C;
  
TYPE
  FILENAME = ARRAY [0..11] OF CHAR;
  PATHNAME = ARRAY [0..79] OF CHAR;
  FELD = ARRAY [0..Maxfiles+1] OF FILENAME;
  MOUSEMODE = (Cursor, Relative);(* v 1.5 *)
  DRIVEMAP = SET OF [0..31];

VAR
  drive: CARDINAL;
  prgpath, accpath, str: PATHNAME;
  prg, acc: FELD;
  i, j, k: INTEGER;
  sysTime, end, drives: LONGCARD;
  ch: CHAR;
  inprg, inSpalte2: BOOLEAN;(* Welche Spalte? *)
  adr: ADDRESS;

(*------------------------------------------------------------------------*)

PROCEDURE Write(ch: CHAR);
  BEGIN
    ConOut(ch);
  END Write;
  
PROCEDURE WriteLn;
  BEGIN
    ConOut(15C); ConOut(12C);
  END WriteLn;
  
PROCEDURE WriteString(VAR str: ARRAY OF CHAR);
  BEGIN
    ConWS(str);
  END WriteString;

PROCEDURE Read(VAR scan: CHAR);(* Scan-Code lesen *)
  VAR dummy: CHAR;
  BEGIN
    RawScanIn(dummy, scan); (* Einlesen ohne Echo *)
  END Read;

PROCEDURE ClearBuffer; (* Tastatur-Buffer leeren *)
  VAR c: CHAR;
  BEGIN
    WHILE ConIS() DO Read(c); END;
  END ClearBuffer;

PROCEDURE GotoXY(x, y: INTEGER);
  BEGIN
    IF x<0 THEN x:=0 ELSE IF x>79 THEN x:=79; END; END;
    IF y<0 THEN y:=0 ELSE IF y>24 THEN y:=24; END; END;
    Write(Esc); Write("Y"); Write(CHR(y+32)); Write(CHR(x+32));
  END GotoXY;

PROCEDURE ReadFilenames(VAR path: PATHNAME; VAR files: FELD);
(* File-Arrays mit Filenamen fÅllen *)
  VAR
    eintrag: ARRAY [0..43] OF CHAR;
    found, more, i, j: INTEGER;
  BEGIN
    FOR i:=1 TO Maxfiles+1 DO files[i]:=" "; END;
    SetDTA(ADR(eintrag));
    SFirst(path, 0, found);(* erstes File *)
    IF found>=0 THEN
      i:=1;
      REPEAT
        j:=0;
        WHILE eintrag[j+30]<>0C DO (* Filename Åbernehmen *)
          files[i,j]:=eintrag[j+30];
          INC(j);
        END;
        SNext(more);(* Gibt es noch mehr Files? Dann hol sie! *)
        INC(i);
      UNTIL (more<0) OR (i>Maxfiles+1);(* keine Files mehr oder Array voll*)
    END;
  END ReadFilenames;

PROCEDURE LastChar(VAR name: FILENAME;VAR c: CHAR;VAR i: INTEGER);
(* Position und Char des Filenamen (3. Zeichen nach Punkt) *)
  VAR
    found: BOOLEAN;
    where: CARDINAL;
    punkt: ARRAY [0..0] OF CHAR;
  BEGIN
    punkt:=".";
    found:=Pos(name,punkt,1,where);
    IF found THEN i:=where+3; c:=name[i]; ELSE i:=-1; c:=0C; END;
  END LastChar;

PROCEDURE WriteFilename(name: FILENAME);
(* schreib Filename ohne Extension, aber mit Marke *)
  VAR
    c: CHAR;
    x: INTEGER;
  BEGIN
    IF name[0]<>" " THEN
      LastChar(name, c, x);
      IF (c="G") OR (c="C") THEN Write("*"); ELSE Write(" "); END;
      Write(" "); x:=0;
      WHILE name[x]<>"." DO Write(name[x]); INC(x); END;
      WHILE x<9 DO Write(" "); INC(x); END;
    END;
  END WriteFilename;

PROCEDURE Select(zeile: INTEGER; iprg: BOOLEAN);(* unterlege Eintrag *)
  BEGIN
    IF zeile=0 THEN
      GotoXY(Xok,Yok); WriteString(Ok);
    ELSE
      IF iprg THEN
        IF i>(Maxfiles DIV 2) THEN
          GotoXY(Xprg+20,Y+zeile-18);
        ELSE
          GotoXY(Xprg,Y+zeile);
        END;
        WriteFilename(prg[i]);
      ELSE
        IF i>(Maxfiles DIV 2) THEN
          GotoXY(Xacc+20,Y+zeile-18);
        ELSE
          GotoXY(Xacc,Y+zeile);
        END;
        WriteFilename(acc[i]);
      END;
    END;
  END Select;

PROCEDURE Status(zeile: INTEGER; inprg: BOOLEAN);(* Ñndere Marked-Status *)
  VAR
    c1, c2: CHAR;
    ort: INTEGER;
    new, old: FILENAME;
    newp, oldp, path: PATHNAME;
  BEGIN
    Write(Esc); Write(Inverse);
    IF inprg THEN(* wenn es sich um Auto-Prg handelt *)
      c1:="G";
      old:=prg[zeile];
      path:=prgpath;
      IF i>(Maxfiles DIV 2) THEN
        GotoXY(Xprg+20,Y+zeile-18);
      ELSE
        GotoXY(Xprg,Y+zeile);
      END;
    ELSE (* wenn es sich um Acc. handelt *)
      c1:="C";
      old:=acc[zeile];
      path:=accpath;
      IF i>(Maxfiles DIV 2) THEN
        GotoXY(Xacc+20,Y+zeile-18);
      ELSE
        GotoXY(Xacc,Y+zeile);
      END;
    END;
    LastChar(old, c2, ort);
    new:=old;
    IF c2=c1 THEN new[ort]:="X"; ELSE new[ort]:=c1; END;
    (* Ñndere letztes Zeichen *)
    Concat(path,old,oldp); Concat(path,new,newp);
    Rename(oldp, newp);(* Benenne Datei um *)
    IF REGISTER(0)=0 THEN (* Fehler aufgetreten ?  v 1.4 *)
      IF inprg THEN prg[zeile]:=new; ELSE acc[zeile]:=new; END;
      WriteFilename(new); Write(Esc); Write(Normal);(* neuer Eintrag *)
    ELSE
      Error(Err4,zeile);
    END;
  END Status;

PROCEDURE SkipMyself(VAR files: FELD);
(* streiche mich (das Prg) aus der Liste *)
  VAR
    z: INTEGER;
  BEGIN
    FOR z:=1 TO Maxfiles+1 DO
      IF Compare(files[z],Myself)=Equal THEN files[z]:=" "; END;
    END;
  END SkipMyself;

PROCEDURE Sort(VAR a: FELD);(* Insertion Sort *)
  VAR i, j: INTEGER; x: FILENAME;
  BEGIN
    FOR i:=2 TO Maxfiles+1 DO
      x:=a[i]; a[0]:=x; j:=i-1;
      WHILE ((Compare(x,a[j])=Less) OR (a[j,0]=" ")) AND (x[0]<>" ") DO
  (* x<a[j] unter BerÅcks., dass leere EintrÑge am Schluss sein sollen *) 
        a[j+1]:=a[j]; DEC(j);
      END;
      a[j+1]:=x;
    END;
  END Sort;

PROCEDURE Test(): BOOLEAN;(* Sind mehr als 6 Acc. aktiv? *)
  VAR
    anzahl, x, dummy: INTEGER;
    c: CHAR;
  BEGIN
    anzahl:=0;
    FOR x:=1 TO Maxfiles DO
      IF acc[x,0]<>" " THEN
      (* wenn nicht leerer Eintrag prÅfe letztes Zeichen *)
        LastChar(acc[x], c, dummy);
        IF c="C" THEN INC(anzahl); END;
      END;
    END;
    IF anzahl>6 THEN RETURN FALSE; ELSE RETURN TRUE; END;
  END Test;

PROCEDURE Error(VAR err: ARRAY OF CHAR; zeile: INTEGER);
(* schreibt Fehlermeldung *)
  VAR c:CHAR;
  BEGIN
    GotoXY(Xok,Yok); Write(Esc); Write(Inverse);
    WriteString(err); Write(Esc); Write(Normal);
    Read(c);(* warte auf Bestaetigung *)
    GotoXY(Xok,Yok);
    IF zeile=0 THEN Write(Esc); Write(Inverse); END;
    WriteString(Ok); Write(Esc); Write(Normal);
    (* restauriere OK-Button *)
  END Error;

PROCEDURE Noentry():BOOLEAN;(* wenn an dieser Stelle kein Eintrag ist *)
  BEGIN
    IF i<>0 THEN
      IF inprg THEN RETURN (prg[i,0]=" "); ELSE RETURN (acc[i,0]=" "); END;
      (* in welcher Spalte sind wir? *)
    ELSE
      RETURN FALSE;(* Eintrag vorhanden! *)
    END;
  END Noentry;

(* v 1.7 *)
(*$S-*)
PROCEDURE GetTime;
  VAR hz200[04BAH]: LONGCARD;
  BEGIN
    sysTime := hz200;
  END GetTime;
(*$S=*)

PROCEDURE Start(): BOOLEAN;
(* Wartet eine Sekunde auf Tastendruck, um Hauptprogramm zu beginnen! *)
  VAR
    end: LONGCARD; dummy: INTEGER;
  BEGIN
    ClearBuffer;
    WriteString(PressK); Write(7C); (* Startmeldung zeigen, Glocke *)
    SuperExec(GetTime);
    end := sysTime + TimeToWait;
    REPEAT
      SuperExec(GetTime);
    UNTIL (sysTime >= end) OR ConIS();
    IF ConIS() THEN (* Wenn eine Taste gedrÅckt wurde! *)
      ClearBuffer;
      RETURN TRUE; (* Hauptprogramm ausfÅhren *)
    ELSE
      RETURN FALSE; (* Hauptprogramm nicht ausfÅhren *)
    END;
  END Start;

PROCEDURE InitMouse(mode: MOUSEMODE);
(* Maus soll Cursortasten simulieren v 1.5 *)
  VAR
    str: ARRAY [0..3] OF CHAR;
    len, i: CARDINAL;
  BEGIN
    IF mode=Cursor THEN (* Cursorsimulation einschalten *)
      str[0]:=CHR(0AH);
      str[1]:=CHR(50); (* Ansprechung in x-Richtung *)
      str[2]:=CHR(10); (*     "          y     "    *)
      len:=2;
    ELSE (* Relative Maus einschalten *)
      str[0]:=CHR(08H);
      len:=0;
    END;
    KeyboardWS(str,len);
  END InitMouse;

(*------------------------------------------------------------------------*)

BEGIN (* main *)
  InitMouse(Cursor);(* Maus simuliert Cursortasten v 1.5 *)
  IF Start() THEN (* Wenn eine Taste gedrÅckt wurde *)
    Write(Esc); Write(CurOff);(* Schalte Cursor aus *)
    Write(Esc); Write(Home); (* oben links *)
    Write(Esc); Write(Inverse);(* inverse Schrift *)
    WriteString(Titel); (* Titelzeile *)
    Write(Esc); Write(Normal);(* invers aus *)
    GotoXY(Xacc,2); WriteString("Accessories:");
    GotoXY(Xprg,2); WriteString("Auto-Folder:");
    GetDrv(drive);(* aktuelles Laufwerk/Partition *)
    prgpath:="X:\AUTO\"; prgpath[0]:=CHR(drive+ORD("A")); (* setze Pfade *)
    accpath:="X:\"; accpath[0]:=CHR(drive+ORD("A"));      (* zusammen!   *)
    SetDrv(drive, drives); (* v 1.3 / v 1.7 *)
    IF (drive < 2) AND (2 IN DRIVEMAP(drives)) THEN (* v 1.3 *)
      accpath[0]:="C";
    END;
    Concat(prgpath, "*.PR?", str); ReadFilenames(str, prg);(* Suchmaske *)
    Concat(accpath, "*.AC?", str); ReadFilenames(str, acc);
    SkipMyself(prg);(* Ich gehîre nicht in die Liste *)
    Sort(prg);(* sortiere Listen *)
    Sort(acc);
    FOR i:=1 TO Maxfiles DO
      IF i>18 THEN j:=20; k:=18; ELSE j:=0; k:=0; END;
      GotoXY(Xacc+j,Y+i-k); WriteFilename(acc[i]);
      GotoXY(Xprg+j,Y+i-k); WriteFilename(prg[i]);(* gib Listen aus *)
    END;
    IF prg[Maxfiles,0]<>" " THEN Error(Err1,0);END;(* bei vollen Listen *)
    IF acc[Maxfiles+1,0]<>" " THEN Error(Err2,0); END;(* Fehlermeldung! *)
    GotoXY(Xok,Yok); WriteString(Ok); (* Male OK-Button! *)
    i:=1;(* Wir sind in der ersten Zeile. *)
    IF acc[1,0]=" " THEN (*Wenn es Acc hat, dann nimm diese Spalte zuerst!*)
      inprg:=TRUE;
      IF prg[1,0]=" " THEN i:=0;END;(*Wenn Tabelle leer, gehe zu OK-Button*)
    ELSE
      inprg:=FALSE;
    END;
    inSpalte2:=FALSE;
    Write(Esc); Write(Inverse); Select(i,inprg); Write(Esc); Write(Normal);
    (* erster Eintrag unterlegen *)
    LOOP (* na, dann mach mal! *)
      ClearBuffer;
      Read(ch);(* Was will der Benutzer *)
      IF ch=RightMouseButton THEN (* v 1.6 *)
        IF Test() THEN EXIT; ELSE Error(Err3,i); END;
      ELSIF (ch=Enter) OR (ch=Return) OR (ch=Space) OR (ch=MouseButton) THEN
        IF i=0 THEN (* Sind wir auf OK-Button? *)
          IF Test() THEN EXIT; ELSE Error(Err3,i); END;
          (* Wenn nicht zuviele Acc dann mach fertig *)
        ELSE (* Wir sind nicht auf OK *)
          IF inprg THEN (* Sind wir in Prg-Spalte? *)
            Status(i,TRUE);(* Marke Ñndern, Spalte mitÅbergeben *)
          ELSE
            Status(i,FALSE);
          END;
        END;
      ELSE(* kein Return oder... gedrÅckt *)
        Select(i,inprg);(* alter Eintrag normal restaurieren *)
        CASE ch OF(* neuer Eintrag bestimmen (Spalte,Zeile) *)
          Down:
            INC(i);
            IF inSpalte2 THEN
              IF i=1 THEN i:=(Maxfiles DIV 2)+1; END;
              IF i>Maxfiles THEN i:=0; END;
            ELSE
              IF i>Maxfiles DIV 2 THEN i:=0; END;
            END;
            IF Noentry() THEN i:=0; END;|
          Up:
            REPEAT
              DEC(i);
              IF inSpalte2 THEN
                IF i=Maxfiles DIV 2 THEN i:=0; END;
                IF i<0 THEN i:=Maxfiles; END;
              ELSE
                IF i<0 THEN i:=Maxfiles DIV 2; END;
              END;
            UNTIL NOT(Noentry()) OR (i=0);|
          Left:
            IF NOT(i=0) THEN
              k:=i;
              REPEAT
                i:=k;
                IF inSpalte2 THEN
                  inSpalte2:=FALSE;
                  i:=i-(Maxfiles DIV 2);
                  k:=i;
                ELSE
                  inSpalte2:=TRUE;
                  inprg:=NOT(inprg);
                  i:=i+(Maxfiles DIV 2);
                  k:=i;
                END;
              UNTIL NOT(Noentry());
            END;|
          Right:
            IF NOT(i=0) THEN
              k:=i;
              REPEAT
                i:=k;
                IF NOT(inSpalte2) THEN
                  inSpalte2:=TRUE;
                  i:=i+(Maxfiles DIV 2);
                  k:=i;
                ELSE
                  inSpalte2:=FALSE;
                  inprg:=NOT(inprg);
                  i:=i-(Maxfiles DIV 2);
                  k:=i;
                END;
              UNTIL NOT(Noentry());
            END;|
          ELSE(* nicht aufgefÅhrte Scancodes Åberspringen *)
        END;(* CASE *)
        Write(Esc); Write(Inverse);
        Select(i,inprg);           (* neuer Eintrag unterlegen *)
        Write(Esc); Write(Normal);
      END;(* IF *)
    END;(* LOOP *)
    GotoXY(Xok,Yok); WriteString(Bye);
    SuperExec(GetTime);(* v 1.7 *)
    end := sysTime + ShowTime;
    REPEAT SuperExec(GetTime); UNTIL sysTime >= end;(* Warte ein Weilchen *)
    Write(Esc); Write(Home);(* Bildschirm lîschen; Cursor nach oben links *)
  ELSE
    WriteLn; WriteString(Exit); WriteLn;
  END;
  InitMouse(Relative); (* normale Maus v 1.5 *)
END Bootedit.
(**************************************************************************)
(* (c) 1991 by Remo Hofer, Oetlingerstrasse 1, CH-4054 Basel, Switzerland *)
(* E-Mail: X.400: S=hofer;OU=urz;O=unibas;P=SWITCH;A=ARCOM;C=CH           *)
(* RFC822: <hofer@urz.unibas.ch> or <hofer%urz.unibas.ch@CERNVAX.BITNET>  *)
(* HEPNET/SPAN: CHGATE::YOGI::HOFER or 20579::48130::HOFER                *)
(**************************************************************************)
