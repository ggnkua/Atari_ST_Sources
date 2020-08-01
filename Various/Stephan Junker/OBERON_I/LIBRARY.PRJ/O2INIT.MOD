MODULE O2Init; (* SJ 15.10.94 *)

(*$-k+c *)

IMPORT
  S:=SYSTEM;


VAR
  Basepage- : S.PTR;
  isAcc- : BOOLEAN;
  loader-: BOOLEAN;
  modList-, blockRoot-: S.PTR; (* Private - parameter from O2LOAD.PRG *)



(* needs to be patched in order to avoid LINK command! *)

PROCEDURE Start*;
 BEGIN
  ASSEMBLER

SysInit:
  MOVE.L  A0,D3           ; wenn A0 # 0 ist
  BNE     IsAcc           ; dann ist es Accessory

  MOVEA.L 4(SP),A0        ; Basepageadresse holen
  BRA  NoAcc
IsAcc:
  MOVE.B  #1,isAcc
NoAcc:
  MOVE.L  A0,Basepage

  TST.L  (A0)    ; test loader mark
  BPL  NoLoader

  MOVE.B  #1,loader
  NEG.L  (A0)
  CLR.B  isAcc
  MOVE.L  4(SP),blockRoot
  MOVE.L  8(SP),modList
  BRA.B  SysInit2
NoLoader:
  MOVEA.L 12(A0),A5       ; Gr”že des TEXT-Segments
  ADDA.L  20(A0),A5       ;+ Gr”že des DATA-Segments
  ADDA.L  28(A0),A5       ;+ Gr”že des BSS-Segments
  ADDA.L  #256,A5    ;+ Gr”že Basepage
  MOVE.L  A5,D1           ;= Gesamtl„nge des Programms
  AND.B   #$FE,D1         ;L„nge nun gerade
  ADD.L   A0,D1           ;+ Programmstart (Basepageadresse)
  MOVEA.L D1,SP           ;Stack endet dort

  TST.L  D3
  BNE  SysInit2

  MOVE.L  A5,-(SP)        ;Programml„nge
  MOVE.L  A0,-(SP)        ;Adresse der Basepage
  MOVE.L  #$4A0000,-(SP)  ;Funktionsnummer + Dummyword (0)
  TRAP    #1              ;Mshrink(0,Basepageadr,Prgl„nge)
  LEA     12(SP),SP       ;Nur noch den Stack korrigieren
SysInit2:
(*$-p no optimization of JSR *)
  JSR  DummyProc  ; the linked main modules are
  JSR  DummyProc  ; entered here
  JSR  DummyProc
  JSR  DummyProc
  JSR  DummyProc
  NOP             ; otherwise linker had to be changed...
  CLR.W  -(SP)
  TRAP  #1    ; Pterm0()

DummyProc:
  RTS
(*$+p *)

  END;
 END Start;

(*$-c *)

END O2Init.

