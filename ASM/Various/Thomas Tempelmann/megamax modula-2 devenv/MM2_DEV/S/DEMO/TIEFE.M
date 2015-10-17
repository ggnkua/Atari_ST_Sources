MODULE Tiefe; (*$E MOS *)

(*
 * Zeigt, wie man auf einfache Weise mit den Line A-Routinen Linien zeichnet.
 *
 * Einfach mal Åbersetzen und starten!
 *)

(*
Stand    Vers  Autor              Kennung Beschreibung
-----------------------------------------------------------------------------
13.12.85 1.0   Volker Ritzhaupt   VR      Grundversion
21.11.87 1.1   VR / TT                    Atari-Version
14.01.91 1.2   TT                         Verw. von TABLE statt ASSEMBLER/DC.W
----------------------------------------------------------------------------*)

FROM SYSTEM IMPORT CADR;

FROM LineA IMPORT LineAVars, PtrLineAVars,
                  Line, LineAVariables;

FROM GrafBase IMPORT WritingMode,
                     Pnt;


VAR     Data,
        A,
        B,
        C,
        D,
        H,
        I,
        J,
        L,
        YCoord,
        XCoord,
        Counter,
        X               :INTEGER;
        Col             :CARDINAL;

CONST
        Size=2;
        XGuys=3;
        YGuys=1;
        XInit=20;       (* XInit und YInit bestimmen gemeinsam die *)
        YInit=40;       (* Lage des Gesamtbildes.                  *)


TABLE Daten:
        998,0,9,14,9,12,11,11,22,12,34,11,37,12,37,4,42,3,51,4,52,6,
        52,12,60,13,79,20,75,23,60,24,51,23,53,30,55,28,58,26,62,26,
        65,27,67,30,67,38,65,46,61,52,57,51,58,60,63,67,67,80,68,87,
        69,86,70,89,71,90,75,100,80,113,998,0,52,113,53,106,51,98,
        53,96,52,95,52,92,69,86,52,92,52,95,70,89,52,95,52,92,55,90,
        54,87,50,85,44,76,42,66,40,65,42,66,43,72,41,71,39,69,36,64,
        37,61,48,59,37,61,36,59,39,57,49,56,40,57,42,55,50,53,48,48,
        49,42,50,41,51,43,52,46,53,50,54,55,56,56,59,60,998,0,57,33,
        60,29,62,29,65,35,63,40,62,45,60,48,58,45,61,40,61,33,58,35,
        57,33,998,0,50,41,48,42,47,48,45,49,40,48,38,43,33,40,33,46,
        33,37,33,40,38,43,38,47,40,32,44,31,49,32,50,41,998,0,50,41,
        50,40,48,41,46,47,998,0,37,11,52,12,52,7,37,7,998,0,49,34,
        49,27,47,20,46,17,44,18,43,19,42,17,39,20,37,29,38,33,40,34,
        42,31,43,31,43,19,43,30,38,31,43,30,49,31,37,30,37,31,43,31,
        41,32,41,30,998,0,9,14,23,20,34,21,31,30,28,27,23,27,20,32,
        20,40,21,47,23,52,28,49,28,65,29,84,16,93,16,94,19,95,14,113,
        998,0,29,84,41,88,45,87,53,86,51,85,41,87,35,83,998,0,40,83,
        41,84,42,84,43,82,44,83,45,83,46,82,998,0,45,67,45,67,998,0,
        45,69,46,69,998,0,46,71,48,71,998,0,47,74,48,74,998,0,48,77,
        48,77,998,0,29,35,28,30,25,29,22,33,22,40,24,45,26,48,27,44,
        25,43,25,36,27,35,29,35,998,0,34,21,39,15,45,14,48,15,52,20,
        53,30,998,0,23,24,29,17,36,15,45,14,50,14,54,16,59,21,998,0,
        28,24,33,16,40,15,45,14,50,16,55,20,56,25,998,0,35,18,40,15,
        45,14,49,15,52,19,998,0,36,27,37,20,41,15,45,14,50,16,53,20,
        998,0,36,27,37,20,41,16,42,15,45,16,47,15,49,16,50,22,51,26,
        998,0,29,84,25,97,29,99,22,103,27,113,998,0,29,84,31,100,
        34,110,35,113,998,0,29,84,30,90,31,95,33,101,39,94,42,91,
        45,90,50,91,53,93,49,100,42,101,39,94,42,101,41,101,41,105,
        39,113,41,105,48,103,50,110,51,113,998,0,48,103,49,100,998,0,
        53,100,54,99,55,100,54,101,53,100,998,0,55,105,56,104,57,105,
        56,106,55,105,
        999,0;

PROCEDURE ReadData (VAR x: INTEGER);
  TYPE PtrInt = POINTER TO INTEGER;
  BEGIN
    (*$A+*)
    Data:= PtrInt (CADR (Daten) + VAL (LONGCARD, x*2))^;
    (*$A=*)
    INC (x)
  END ReadData;


VAR     vars: PtrLineAVars;

BEGIN
  vars:=LineAVariables ();
  WITH vars^ DO
    writingMode:=replaceWrt;
    plane1:=TRUE;
    lineMask:=$FFFF;
    lastLine:=TRUE;
    clipping:=TRUE;
    minClip:=Pnt(0,0);
    maxClip:=Pnt(639,399);
  END;
  
  YCoord:=YInit;
  FOR H:=1 TO YGuys DO
    XCoord:=XInit;
    FOR I:=1 TO XGuys DO
      Counter:=0;
      REPEAT
        ReadData(Counter);
        A:=Data;
        ReadData(Counter);
        B:=Data;
        IF A=998 THEN
          ReadData(Counter);
          C:=Data;
          ReadData(Counter);
          D:=Data;
        END;
        IF A<900 THEN
          Line ( Pnt ((C+XCoord)*Size,(D+YCoord)*Size),
                 Pnt ((A+XCoord)*Size,(B+YCoord)*Size) );
          C:=A;
          D:=B;
        END;
      UNTIL A=999;
      XCoord:=XCoord+70;
    END;
    YCoord:=YCoord+122;
  END;
END Tiefe.
