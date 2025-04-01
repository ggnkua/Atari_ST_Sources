
Unit MENUBILD;


(*Erzeugt vom Ressourcemacher 1.1*)
(* B.Volkmer, 1991 *) 

(* Version des RessourceFiles : $0001 *)
(*$F+*)
INTERFACE

Uses Gem, Bios;


CONST
  nObjects =    19;
  nTrees   =     1;
  xObjects =   226;
  xTrees   =   682;

TYPE
 TreeArray    = ARRAY[0..nTrees] OF POINTER;
ObjAddrArray = ARRAY[0..nObjects] OF Object;


VAR
 TreeAddr    : ^TreeArray;
 ObjectAddr  : ^ObjAddrArray;


IMPLEMENTATION


CONST
  GBOX  = 20; USERBLK  = 24;
  GIBOX = 25; GBOXCHAR = 27;


VAR
  i               : INTEGER;
  chW,chH,rezol   : INTEGER;
  RSDATA          : POINTER;


VAR rsdta : POINTER;
PROCEDURE rscdata;
  ASSEMBLER;
  ASM
   LEA  @start,A0
   MOVE.L A0,rsdta
   BRA  @fertig
@start:
    DC.W $0001,$00E2,$00E2,$00E2,$00E2,$00E2,$0024,$00E2
    DC.W $00E2,$02AA,$0013,$0001,$0000,$0000,$0000,$0000
    DC.W $0000,$02AE,$2044,$6573,$6B20,$0020,$4461,$7465
    DC.W $6920,$0020,$496E,$666F,$2000,$2D2D,$2D2D,$2D2D
    DC.W $2D2D,$2D2D,$2D2D,$2D2D,$2D2D,$2D2D,$2D2D,$0020
    DC.W $2044,$6573,$6B2D,$5A75,$6265,$6899,$7220,$3120
    DC.W $2000,$2020,$4465,$736B,$2D5A,$7562,$6568,$9972
    DC.W $2032,$2020,$0020,$2044,$6573,$6B2D,$5A75,$6265
    DC.W $6899,$7220,$3320,$2000,$2020,$4465,$736B,$2D5A
    DC.W $7562,$6568,$9972,$2034,$2020,$0020,$2044,$6573
    DC.W $6B2D,$5A75,$6265,$6899,$7220,$3520,$2000,$2020
    DC.W $4465,$736B,$2D5A,$7562,$6568,$9972,$2036,$2020
    DC.W $0020,$2045,$696E,$7472,$6167,$3100,$2020,$4569
    DC.W $6E74,$7261,$6732,$0020,$2045,$696E,$7472,$6167
    DC.W $3300,$FFFF,$0001,$0005,$0019,$0000,$0000,$0000
    DC.W $0000,$0000,$0000,$0050,$0019,$0005,$0002,$0002
    DC.W $0014,$0000,$0000,$0000,$1100,$0000,$0000,$0050
    DC.W $0201,$0001,$0003,$0004,$0019,$0000,$0000,$0000
    DC.W $0000,$0002,$0000,$000E,$0301,$0004,$FFFF,$FFFF
    DC.W $0020,$0000,$0000,$0000,$0024,$0000,$0000,$0006
    DC.W $0301,$0002,$FFFF,$FFFF,$0020,$0000,$0000,$0000
    DC.W $002B,$0006,$0000,$0008,$0301,$0000,$0006,$000F
    DC.W $0019,$0000,$0000,$0000,$0000,$0000,$0301,$0050
    DC.W $0013,$000F,$0007,$000E,$0014,$0000,$0000,$00FF
    DC.W $1100,$0002,$0000,$0014,$0008,$0008,$FFFF,$FFFF
    DC.W $001C,$0000,$0000,$0000,$0033,$0000,$0000,$0014
    DC.W $0001,$0009,$FFFF,$FFFF,$001C,$0000,$0008,$0000
    DC.W $003A,$0000,$0001,$0014,$0001,$000A,$FFFF,$FFFF
    DC.W $001C,$0000,$0000,$0000,$004F,$0000,$0002,$0014
    DC.W $0001,$000B,$FFFF,$FFFF,$001C,$0000,$0000,$0000
    DC.W $0062,$0000,$0003,$0014,$0001,$000C,$FFFF,$FFFF
    DC.W $001C,$0000,$0000,$0000,$0075,$0000,$0004,$0014
    DC.W $0001,$000D,$FFFF,$FFFF,$001C,$0000,$0000,$0000
    DC.W $0088,$0000,$0005,$0014,$0001,$000E,$FFFF,$FFFF
    DC.W $001C,$0000,$0000,$0000,$009B,$0000,$0006,$0014
    DC.W $0001,$0006,$FFFF,$FFFF,$001C,$0000,$0000,$0000
    DC.W $00AE,$0000,$0007,$0014,$0001,$0005,$0010,$0012
    DC.W $0014,$0000,$0000,$00FF,$1100,$0008,$0000,$000C
    DC.W $0003,$0011,$FFFF,$FFFF,$001C,$0000,$0000,$0000
    DC.W $00C1,$0000,$0000,$000C,$0001,$0012,$FFFF,$FFFF
    DC.W $001C,$0000,$0000,$0000,$00CC,$0000,$0001,$000C
    DC.W $0001,$000F,$FFFF,$FFFF,$001C,$0020,$0000,$0000
    DC.W $00D7,$0000,$0002,$000C,$0001,$0000,$00E2
@fertig:
 END;



BEGIN
 rscdata;
(*Liste der Objektbaum-Adressen relozieren*)

 RSDATA := rsdta;
 TreeAddr := POINTER(LONGINT(RSDATA)+LONGINT(xTrees));
 FOR i := 0 TO nTrees-1 DO
   TreeAddr^[i] := POINTER(LONGINT(TreeAddr^[i])+LONGINT( RSDATA));

(* Object-Specs relozieren, falls notwendig *)
  ObjectAddr := POINTER(LONGINT(RSDATA)+LONGINT(xObjects));
  FOR i := 0 TO nObjects-1 DO BEGIN
  WITH ObjectAddr^[i] DO BEGIN
   IF (typ <> GBOX)  AND (typ <> GIBOX) AND
   (typ <> USERBLK) AND
   (typ <> GBOXCHAR) THEN
   spec.more := POINTER(LONGINT(spec.more)+LONGINT(RSDATA));
   chW := 8; chH := 16;
   rezol := GetRez;
   IF rezol < 2 THEN chH := 8;
   WITH space DO BEGIN
    y:=(y MOD 256) * chH + (y DIV 256);
    x:=(x MOD 256) * chW + (x DIV 256);
    h:=(h MOD 256) * chH + (h DIV 256);
    w:=(w MOD 256) * chW + (w DIV 256);
   END;
  END;
 END;
END.
