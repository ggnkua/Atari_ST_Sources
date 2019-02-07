IMPLEMENTATION MODULE jump;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 18-Apr-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
INLINE_CODE_IMPORT

#ifndef MM2
FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD;

FROM types IMPORT
(* TYPE *) int;

FROM OSCALLS IMPORT
(* PROC *) Psigreturn;

FROM DosSystem IMPORT
(* PROC *) MiNTVersion;

FROM DosSupport IMPORT
(* VAR  *) SIGMASK;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* Wenn die Reihenfolge oder Anzahl der globalen Variablen geaendert wird,
 * muss evtl. auch der Assemblercode geaendert werden (siehe HM)!
 *)
VAR
  MiNT       : UNSIGNEDWORD;
#ifndef MM2
  SIGMASKadr : ADDRESS;
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
(*T*)
BEGIN
(*
setjmp:
  movea.l (SP)+,A6      ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A4      ; A4 -> globale Variablen des Aufrufers
  movea.l (SP)+,A1      ; A1 := RTN-Adresse
  movea.l (SP)+,A0      ; A0 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l A1/A4-A7,(A0) ; Register und RTN-Adr. in <env> sichern
  clr.w   (SP)          ; Funktionswert := 0
  jmp     (A1)          ; zurueck zum Aufrufer
*)
 INLINE(2C5FH);
 INLINE(285FH);
 INLINE(225FH);
 INLINE(205FH);
 INLINE(48D0H,0F200H);
 INLINE(4257H);
 INLINE(4ED1H);
END setjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
(*T*)
BEGIN
 Psigreturn;
(*
longjmp:
  movea.l 12+2(A6),A0   ; A0 -> <env>
  move.w  12(A6),D0     ; D0 := <val>
  bne.s   setregs       ; B: Wert <> Null uebernehmen
  moveq   #1,D0         ; Wert Null auf eins korrigieren
setregs:
  movem.l (A0),A1/A4-A7 ; Register auf Wert vor "setjmp()"
  move.w  D0,(SP)       ; Funktionswert := <val>
  jmp     (A1)          ; zurueck wie nach "setjmp()"-Aufruf
*)
 INLINE(206EH,000EH);
 INLINE(302EH,000CH);
 INLINE(6602H);
 INLINE(7001H);
 INLINE(4CD0H,0F200H);
 INLINE(3E80H);
 INLINE(4ED1H);
END longjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;
(**)
BEGIN
 SETREG(0, MiNT);
(*
; MiNT rettet die Register D1-D7/A1-A7 bei Betriebssystemaufrufen, deshalb
; koennen die Register A1 und A2 als Zwischenspeicher benutzt werden

sigsetjmp:
  move.l  A4,D2          ; Zeiger auf eigene globale Variablen fuer TOS sichern
  movea.l (SP)+,A6       ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A4       ; A4 -> globale Variablen des Aufrufers
  movea.l (SP)+,A1       ; A1 := RTN-Adresse
  move.w  (SP)+,D1       ; D1 := <savemask>
  movea.l (SP)+,A2       ; A2 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l A1/A4-A7,(A2)
  move.w  D1,5*4+4(A2)   ; Signalmaske in <env> sichern ?
  beq.s   ende           ; B: nein
  tst.w   D0             ; MiNT aktiv ?
  beq.s   tos            ; B: nein
  clr.l   -(SP)          ; Psigblock(0) -> D0 := MiNT-Signalmaske
  move.w  #$0116,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   save
tos:
  exg     D2,A4          ; A4 -> eigene globale Variablen
  nop                    ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop
  move.l  (A0),D0        ; D0 := TOS-Signalmaske
  exg     D2,A4          ; A4 -> globale Variablen des Aufrufers
save:
  move.l  D0,5*4(A2)     ; Signalmaske in <env> sichern
ende:
  clr.w   (SP)           ; Funktionswert gleich Null
  jmp     (A1)
*)
 CODE(240CH,2C5FH,285FH,225FH,321FH,245FH,48D2H,0F200H);
 CODE(3541H,0018H,671EH,4A40H,670CH,42A7H,3F3CH,0116H);
 CODE(4E41H,5C8FH,600AH,0C58CH);
 SETREG(8, SIGMASKadr);
 CODE(2010H,0C58CH,2540H,0014H,4257H,4ED1H);
END sigsetjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );
(**)
BEGIN
 Psigreturn;
 SETREG(0, MiNT);
(*
siglongjmp:
  movea.l 12+2(A6),A2    ; A2 -> <env>
  tst.w   5*4+4(A2)      ; Signalmaske restaurieren ?
  beq.s   ende           ; B: nein
  move.l  5*4(A2),D1     ; D1 := Signalmaske
  tst.w   D0             ; MiNT aktiv ?
  beq.s   tos            ; B: nein
  move.l  D1,-(SP)       ; Psigsetmask(D1)
  move.w  #$0117,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   ende
tos:
  nop                    ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  move.l  D1,(A0)
ende:
  move.w  12(A6),D0      ; D0 := <val>
  bne.s   setregs        ; B: Wert <> Null uebernehmen
  moveq   #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  movem.l (A2),A1/A4-A7  ; Register auf Wert vor "setjmp()"
  move.w  D0,(SP)        ; Funktionswert := <val>
  jmp     (A1)           ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(246EH,000EH,4A6AH,0018H,671AH,222AH,0014H,4A40H);
 CODE(670CH,2F01H,3F3CH,0117H,4E41H,5C8FH,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2081H,302EH,000CH,6602H,7001H,4CD2H,0F200H);
 CODE(3E80H,4ED1H);
END siglongjmp;

#elif (defined HM2)

(* Es kann nicht mit __PROCFRAME_OFF__ gearbeitet werden, da die Variablen
 * ueber Register A5 angesprochen werden, das erst im Prozedurprolog
 * fuer dieses Modul gesetzt wird.
 *)

PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
(*T*)
BEGIN
(*
setjmp:
  movea.l (SP)+,A5       ; A5 -> globale Variablen Aufrufer
  movea.l (SP)+,A6       ; A6 -> lokale variablen Aufrufer
  movea.l (SP)+,A1       ; A1 := RTN-Adresse
  movea.l (SP)+,A0       ; A0 -> <env>
; Parameter und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l D2-D7/A1-A7,(A0) ; Register und RTN-Adr. in <env> sichern
  moveq   #0,D0          ; Funktionswert := 0
  jmp     (A1)           ; zurueck zum Aufrufer
*)
 CODE(2A5FH,2C5FH,225FH,205FH,48D0H,0FEFCH,7000H,4ED1H);
END setjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
(*T*)
BEGIN
 Psigreturn;
(*
longjmp:
  movea.l 12(SP),A0      ; A0 -> <env>
#ifdef __LONG_WHOLE__
  move.l  12+4(SP),D0    ; D0 := <val>
#else
  move.w  12+4(SP),D0    ; D0 := <val>
#endif
  bne.s   setregs        ; B: Wert <> Null uebernehmen
  moveq   #1,D0          ; Wert Null auf eins korrigieren
setregs:
  movem.l (A0),D2-D7/A1-A7 ; Register auf Wert vor "setjmp()"
  jmp     (A1)           ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206FH,000CH);
#ifdef __LONG_WHOLE__
 CODE(202FH,0010H);
#else
 CODE(302FH,0010H);
#endif
 CODE(6602H,7001H,4CD0H,0FEFCH,4ED1H);
END longjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;
(*T*)
BEGIN
(*
; MiNT rettet die Register D1-D7/A1-A7 bei Betriebssystemaufrufen, deshalb
; kann Register A1 als Zwischenspeicher benutzt werden

sigsetjmp:
  move.l  A5,D1          ; Zeiger auf eigene globale Variablen fuer TOS sichern
  movea.l (SP)+,A5       ; A5 -> globale Variablen des Aufrufers
  movea.l (SP)+,A6       ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A0       ; A0 := RTN-Adresse
  movea.l (SP)+,A1       ; A1 -> <env>
  move.w  (SP)+,D0       ; D0 := <savemask>
; Parameter und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l D2-A0/A2-A7,(A1)
  pea     (A0)           ; RTN-Adresse fuer rts
  move.w  D0,13*4+4(A1)  ; <savemask> in <env> sichern
  beq.s   ende           ; B: Prozessmaske nicht sichern
  exg     A5,D1          ; A5 -> eigene globale Variablen
  nop                    ; ersetzt durch: SETREG(1, MiNT)
  beq.s   tos            ; B: MiNT ist nicht aktiv
  clr.l   -(SP)          ; Psigblock(0) -> D0 := MiNT-Prozessmake
  move.w  #$0116,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   save
tos:
  nop                    ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop                    ;
  move.l  (A0),D0        ; D0 := TOS-Prozessmaske
save:
  exg     A5,D1          ; A5 -> globale Variablen des Aufrufers
  move.l  D0,13*4(A1)    ; Prozessmaske in <env> sichern
ende:
  moveq   #0,D0
  rts
*)
 CODE(220DH,2A5FH,2C5FH,205FH,225FH,301FH,48D1H,0FDFCH);
 CODE(4850H,3340H,0038H,671EH,0C38DH);
 SETREG(1, MiNT);
 CODE(670CH,42A7H,3F3CH,0116H,4E41H,5C8FH,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2010H,0C38DH,2340H,0034H,7000H,4E75H);
END sigsetjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );
(*T*)
BEGIN
 Psigreturn;
 SETREG(0, MiNT);
(*
siglongjmp:
  movea.l 12(SP),A1      ; A1 -> <env>
  tst.w   13*4+4(A1)     ; Signalmaske restaurieren ?
  beq.s   ende           ; B: nein
  move.l  13*4(A1),D1    ; D1 := Signalmaske
  tst.w   D0             ; MiNT aktiv ?
  beq.s   tos            ; B: nein
  move.l  D1,-(SP)       ; Psigsetmask(D1)
  move.w  #$0117,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   ende
tos:
  nop                    ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  move.l  D1,(A0)
ende:
#ifdef __LONG_WHOLE__
  move.l  12+4(SP),D0    ; D0 := <val>
#else
  move.w  12+4(SP),D0    ; D0 := <val>
#endif
  bne.s   setregs        ; B: Wert <> Null uebernehmen
  moveq   #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  movem.l (A1),D2-A0/A2-A7 ; Register auf Wert vor "setjmp()"
  jmp     (A0)           ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(226FH,000CH,4A69H,0038H,671AH,2229H,0034H,4A40H);
 CODE(670CH,2F01H,3F3CH,0117H,4E41H,5C8FH,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2081H);
#ifdef __LONG_WHOLE__
 CODE(202FH,0010H);
#else
 CODE(302FH,0010H);
#endif
 CODE(6602H,7001H,4CD1H,0FDFCH);
 CODE(4ED0H);
END siglongjmp;

#elif (defined TDIM2)

__PROCFRAME_OFF__
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
(*T*)
BEGIN
(*
setjmp:
  movea.l (SP)+,A1      ; A1 := RTN-Adresse
  movea.l (SP),A0       ; A0 -> <env>, nicht abraeumen, macht Aufrufer
; RTN-Adresse ist jetzt vom Stack abgeraeumt
  movem.l A1/A5-A7,(A0) ; Register und RTN-Adr. in <env> sichern
  clr.w   4(SP)         ; Funktionswert := 0
  jmp     (A1)          ; zurueck zum Aufrufer
*)
 CODE(225FH);
 CODE(2057H);
 CODE(48D0H,0E200H);
 CODE(426FH,0004H);
 CODE(4ED1H);
END setjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
(*T*)
BEGIN
 Psigreturn;
(*
longjmp:
  movea.l 4+2(SP),A0    ; A0 -> <env>
  move.w  4(SP),D0      ; D0 := <val>
  bne.s   setregs       ; B: Wert <> Null uebernehmen
  moveq   #1,D0         ; Wert Null auf eins korrigieren
setregs:
  movem.l (A0),A1/A5-A7 ; Register auf Wert vor "setjmp()"
  move.w  D0,4(SP)      ; Funktionswert := <val>
  jmp     (A1)          ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206FH,0006H);
 CODE(302FH,0004H);
 CODE(6602H);
 CODE(7001H);
 CODE(4CD0H,0E200H);
 CODE(3F40H,0004H);
 CODE(4ED1H);
END longjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;
(**)
BEGIN
 SETREG(0, MiNT);
(*
; MiNT rettet die Register D1-D7/A1-A7 bei Betriebssystemaufrufen, deshalb
; koennen die Register A1 und A2 als Zwischenspeicher benutzt werden

sigsetjmp:
  movea.l (SP)+,A1       ; A1 := RTN-Adresse
  move.w  (SP),D1        ; D1 := <savemask>
  movea.l 2(SP),A2       ; A2 -> <env>
; Parameter und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l A1/A5-A7,(A2)
  move.w  D1,4*4+4(A2)   ; Signalmaske sichern ?
  beq.s   ende           ; B: nein
  tst.w   D0             ; MiNT aktiv ?
  beq.s   tos            ; B: nein
  clr.l   -(SP)          ; Psigblock(0) -> D0 := MiNT-Signalmaske
  move.w  #$0116,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   save           ;
tos:
  nop                    ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop
  nop
  move.l  (A0),D0        ; D0 := TOS-Signalmaske
save:
  move.l  D0,4*4(A2)     ; Signalmaske in <env> sichern
ende:
  clr.w   4+2(SP)        ; Funktionswert gleich Null
  jmp     (A1)
*)
 CODE(225FH,3217H,246FH,0002H,48D2H,0E200H,3541H,0014H);
 CODE(671CH,4A40H,670CH,42A7H,3F3CH,0116H,4E41H,5C8FH);
 CODE(6008H);
 SETREG(8, SIGMASKadr);
 CODE(2010H,2540H,0010H,426FH,0006H,4ED1H);
END sigsetjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );
(**)
BEGIN
 Psigreturn;
 SETREG(0, MiNT);
(*
siglongjmp:
  movea.l 4+2(SP),A2     ; A2 -> <env>
  tst.w   4*4+4(A2)      ; Signalmaske restaurieren ?
  beq.s   ende           ; B: nein
  move.l  4*4(A2),D1     ; D1 := Signalmaske
  tst.w   D0             ; MiNT aktiv ?
  beq.s   tos            ; B: nein
  move.l  D1,-(SP)       ; Psigsetmask(D1)
  move.w  #$0117,-(SP)   ;
  trap    #1             ;
  addq.l  #6,SP          ;
  bra.s   ende
tos:
  nop                    ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  nop
  move.l  D1,(A0)
ende:
  move.w  4(SP),D0       ; D0 := <val>
  bne.s   setregs        ; B: Wert <> Null uebernehmen
  moveq   #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  movem.l (A2),A1/A5-A7  ; Register auf Wert vor "setjmp()"
  move.w  D0,4+2(SP)     ; Funktionswert := <val>
  jmp     (A1)           ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(246FH,0006H,4A6AH,0014H,671CH,222AH,0010H,4A40H);
 CODE(670CH,2F01H,3F3CH,0117H,4E41H,5C8FH,6008H);
 SETREG(8, SIGMASKadr);
 CODE(2081H,302FH,0004H,6602H,7001H,4CD2H);
 CODE(0E200H,3F40H,0006H,4ED1H);
END siglongjmp;
__PROCFRAME_ON__

#elif (defined MM2)

__PROCFRAME_OFF__
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
(*T*)
BEGIN
 ASSEMBLER
   MOVEA.L (A7)+,A1            ; A1 := RTN-Adresse und vom Stack abraeumen
   MOVEA.L -(A3),A0            ; A0 -> <env>
   MOVEM.L D3-D7/A1/A3-A7,(A0) ; Register und RTN-Adr. in <env> sichern
   MOVEQ   #0,D0               ; Funktionswert := 0
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0,(A3)+            ; Funktionswert := 0
#else
   MOVE.W  D0,(A3)+            ; Funktionswert := 0
#endif
#endif
   JMP     (A1)                ; zurueck zum Aufrufer
 END;
END setjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
(*T*)
BEGIN
 Psigreturn;
 ASSEMBLER
#ifdef __LONG_WHOLE__
   MOVE.L  -(A3),D0            ; D0 := <val>, Flags setzen
#else
   MOVE.W  -(A3),D0            ; D0 := <val>, Flags setzen
#endif
   MOVEA.L -(A3),A0            ; A0 -> <env>, Flags nicht veraendern
; Parameterstack abgeraeumt
   BNE.S   setregs             ; B: Wert <> Null uebernehmen
   MOVEQ   #1,D0               ; Wert Null auf eins korrigieren
setregs:
   MOVEM.L (A0),D3-D7/A1/A3-A7 ; Register auf Wert vor "setjmp()"
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0,(A3)+            ; Funktionswert := <val>
#else
   MOVE.W  D0,(A3)+            ; Funktionswert := <val>
#endif
#endif
   JMP     (A1)                ; zurueck wie nach "setjmp()"-Aufruf
 END;
END longjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;
(**)
BEGIN
 ASSEMBLER
; MiNT rettet die Register D1-D7/A1-A7 bei Betriebssystemaufrufen, deshalb
; koennen die Register A1, A2 und D1 als Zwischenspeicher benutzt werden

   MOVEA.L (A7)+,A1            ; A1 := RTN-Adresse und vom Stack abraeumen
   MOVE.W  -(A3),D1            ; D1 := <savemask>
   MOVEA.L -(A3),A2            ; A2 -> <env>
   MOVEM.L D3-D7/A1/A3-A7,(A2) ; Register und RTN-Adr. in <env> sichern
   MOVE.W  D1,11*4+4(A2)       ; <savemask> in <env> sichern
   BEQ.S   ende
   TST.W   MiNT
   BEQ.S   tos
   CLR.L   -(SP)
   MOVE.W  #$0116,-(SP)
   TRAP    #1
   ADDQ.L  #6,SP
   BRA.S   save
tos:
   MOVE.L  SIGMASK,D0
save:
   MOVE.L  D0,11*4(A2)
ende:
   MOVEQ   #0,D0               ; Funktionswert := 0
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0,(A3)+            ; Funktionswert := 0
#else
   MOVE.W  D0,(A3)+            ; Funktionswert := 0
#endif
#endif
   JMP     (A1)                ; zurueck zum Aufrufer
 END;
END sigsetjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );
(**)
BEGIN
 Psigreturn;
 ASSEMBLER
#ifdef __LONG_WHOLE__
   MOVE.L  -(A3),D1            ; D1 := <val>, Flags setzen
#else
   MOVE.W  -(A3),D1            ; D1 := <val>, Flags setzen
   EXT.L   D1
#endif
   MOVEA.L -(A3),A2            ; A2 -> <env>
; Parameterstack abgeraeumt
   TST.W   11*4+4(A2)          ; Signalmaske restaurieren ?
   BEQ.S   ende                ; B: nein
   MOVE.L  11*4(A2),D0         ; D0 := Signalmaske
   TST.W   MiNT                ; MiNT aktiv ?
   BEQ.S   tos                 ; B: nein
   MOVE.L  D0,-(SP)            ; Psigsetmask(D0)
   MOVE.W  #$0117,-(SP)        ;
   TRAP    #1                  ;
   ADDQ.L  #6,SP               ;
   BRA.S   ende
tos:
   MOVE.L  D0,SIGMASK          ; TOS-Signalmaske setzen
ende:
   MOVE.L  D1,D0               ; <val> gleich Null ?
   BNE.S   setregs             ; B: Wert <> Null uebernehmen
   MOVEQ   #1,D0               ; Wert Null auf Eins korrigieren
setregs:
   MOVEM.L (A2),D3-D7/A1/A3-A7 ; Register auf Wert vor "setjmp()"
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0,(A3)+            ; Funktionswert := <val>
#else
   MOVE.W  D0,(A3)+            ; Funktionswert := <val>
#endif
#endif
   JMP     (A1)                ; zurueck wie nach "setjmp()"-Aufruf
 END;
END siglongjmp;
__PROCFRAME_ON__

#elif (defined FTLM2)

PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
(*T*)
BEGIN
(*
setjmp:
  movea.l (SP)+,A3         ; A3 -> globale Variablen des Aufrufers
  movea.l (SP)+,A6         ; A6 -> lokale Variablen des Aufrufers
  movea.l (SP)+,A1         ; A1 := RTN-Adresse
  movea.l (SP)+,A0         ; A0 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l A1/A3/A6-A7,(A0) ; Register und RTN-Adr. in <env> sichern
  moveq   #0,D0            ; Funktionswert := 0;
  jmp     (A1)             ; zurueck zum Aufrufer
*)
 CODE(265FH);
 CODE(2C5FH);
 CODE(225FH);
 CODE(205FH);
 CODE(48D0H,0CA00H);
 CODE(7000H);
 CODE(4ED1H);
END setjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
(*T*)
BEGIN
 Psigreturn;
(*
longjmp:
  movea.l 8+2(A6),A0       ; A0 -> <env>
  move.w  8(A6),D0         ; D0 := <val>
  bne.s   setregs          ; B: Wert <> Null uebernehmen
  moveq   #1,D0            ; Wert Null auf eins korrigieren
setregs:
  movem.l (A0),A1/A3/A6-A7 ; Register auf Wert vor "setjmp()"
  jmp     (A1)             ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206EH,000AH);
 CODE(302EH,0008H);
 CODE(6602H);
 CODE(7001H);
 CODE(4CD0H,0CA00H);
 CODE(4ED1H);
END longjmp;

#elif (defined TSM2_1)
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
BEGIN
 RETURN(SetJmp(env));
END setjmp;

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );
BEGIN
 LongJmp(env, val);
END longjmp;

#else
#  error *** compiler not (yet) supported
#endif

(*===========================================================================*)

BEGIN (* jump *)
 MiNT       := VAL(UNSIGNEDWORD,MiNTVersion());
#ifndef MM2
 SIGMASKadr := ADR(SIGMASK);
#endif
END jump.
