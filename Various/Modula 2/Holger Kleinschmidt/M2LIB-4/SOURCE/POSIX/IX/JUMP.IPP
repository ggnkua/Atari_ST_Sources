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
#ifdef MM2
(*$X+ 68881 Mnemonics *)
#endif
(*****************************************************************************)
(* 14-Jul-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
INLINE_CODE_IMPORT

#ifndef MM2
FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, UNSIGNEDLONG;

FROM types IMPORT
(* TYPE *) int;

FROM OSCALLS IMPORT
(* PROC *) Psigreturn, Psigblock;

FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* VAR  *) SIGMASK,
(* PROC *) GetFPU;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* Wenn die Reihenfolge oder Anzahl der globalen Variablen geaendert wird,
 * muss evtl. auch der Assemblercode geaendert werden (siehe HM)!
 *)
VAR
#if (defined LPRM2) || (defined SPCM2)
  (* LONG, damit SETREG bei der Erweiterung auf LONG kein zusaetzliches
   * Register benutzt.
   *)
  hasMask    : UNSIGNEDLONG;
  hasFpu     : UNSIGNEDLONG;
#else
  hasMask    : UNSIGNEDWORD;
  hasFpu     : UNSIGNEDWORD;
#endif
  fpu        : FPUInfo;
#ifndef MM2
  SIGMASKadr : ADDRESS;
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
BEGIN
 SETREG(0, hasFpu);
(*
setjmp:
  movea.l  (SP)+,A6      ; A6 -> lokale Variablen des Aufrufers
  movea.l  (SP)+,A4      ; A4 -> globale Variablen des Aufrufers
  movea.l  (SP)+,A1      ; A1 := RTN-Adresse
  movea.l  (SP)+,A0      ; A0 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l  D2-D7/A1-A7,(A0) ; CPU-Register und RTN-Adr. in <env> sichern
  tst.w    D0
  beq.b    ret
  fmovem.x FP1-FP7,13*4(A0) ; FPU-Register in <env> sichern
ret:
  clr.w    (SP)          ; Funktionswert := 0
  jmp      (A1)          ; zurueck zum Aufrufer
*)
 CODE(2C5FH,285FH);
 CODE(225FH,205FH,48D0H,0FEFCH,4A40H,6706H,0F228H,0F07FH);
 CODE(0034H,4257H,4ED1H);
END setjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );

BEGIN
 Psigreturn;
 SETREG(1, hasFpu);
(*
longjmp:
  movea.l  12+2(A6),A0   ; A0 -> <env>
  move.w   12(A6),D0     ; D1 := <val>
  bne.b    setregs       ; B: Wert <> Null uebernehmen
  moveq    #1,D0         ; Wert Null auf Eins korrigieren
setregs:
  tst.w    D1
  beq.b    setcpu
  fmovem.x 13*4(A0),FP1-FP7 ; FPU-Register auf Wert vor "setjmp()"
setcpu:
  movem.l  (A0),D2-D7/A1-A7 ; CPU-Register, RTN-Adr. auf Wert vor "setjmp()"
  move.w   D0,(SP)       ; Funktionswert := <val>
  jmp      (A1)          ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206EH,000EH);
 CODE(302EH,000CH,6602H,7001H,4A41H,6706H,0F228H,0D07FH);
 CODE(0034H,4CD0H,0FEFCH,3E80H,4ED1H);
END longjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;

BEGIN
(*
sigsetjmp:
  move.l   A4,D1          ; Zeiger auf eigene globale Variablen sichern
  movea.l  (SP)+,A6       ; A6 -> lokale Variablen des Aufrufers
  movea.l  (SP)+,A4       ; A4 -> globale Variablen des Aufrufers
  movea.l  (SP)+,A0       ; A0 := RTN-Adresse
  move.w   (SP)+,D0       ; D0 := <savemask>
  movea.l  (SP)+,A1       ; A1 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  move.w   D0,13*4+7*12+4(A1)
  movem.l  D2-A0/A2-A7,(A1)
  exg      A4,D1          ; A4 -> eigene globale Variablen
  nop                     ; ersetzt durch: SETREG(0, hasFpu)
  nop
  beq.b    l0
  fmovem.x FP1-FP7,13*4(A1) ; FPU-Register in <env> sichern
l0:
  pea      (A0)           ; RTN-Adresse fuer rts
  tst.w    13*4+7*12+4(A1) ; Prozessmaske in <env> sichern ?
  beq.b    ende           ; B: nein
  nop                     ; ersetzt durch: SETREG(0, hasMask)
  nop
  beq.b    tos            ; B: 'Psigblock' nicht verfuegbar
  movem.l  D1/D2/A1/A2,-(SP)
  clr.l    -(SP)          ; Psigblock(0) -> D0 := MiNT-Prozessmaske
  move.w   #$0116,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movem.l  (SP)+,D1/D2/A1/A2
  bra.b    save
tos:
  nop                     ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop
  move.l   (A0),D0        ; D0 := TOS-Prozessmaske
save:
  move.l   D0,13*4+7*12(A1)    ; Prozessmaske in <env> sichern
ende:
  movea.l  D1,A4          ; A4 -> globale Variablen des Aufrufers
  clr.w    4(SP)          ; Funktionswert gleich Null
  rts
*)
 CODE(220CH,2C5FH);
 CODE(285FH,205FH,301FH,225FH,3340H,008CH,48D1H,0FDFCH);
 CODE(0C38CH);
 SETREG(0, hasFpu);
 CODE(6706H,0F229H,0F07FH,0034H,4850H);
 CODE(4A69H,008CH,6724H);
 SETREG(0, hasMask);
 CODE(6714H,48E7H,6060H);
 CODE(42A7H,3F3CH,0116H,4E41H,5C8FH,4CDFH,0606H,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2010H,2340H,0088H,2841H,426FH,0004H);
 CODE(4E75H);
END sigsetjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );

BEGIN
 Psigreturn;
 SETREG(0, hasMask);
(*
siglongjmp:
  movea.l  12+2(A6),A1    ; A1 -> <env>
  tst.w    13*4+7*12+4(A1) ; Prozessmaske restaurieren ?
  beq.b    ende           ; B: nein
  move.l   13*4+7*12(A1),D1 ; D1 := Prozessmaske
  tst.w    D0             ; 'Psigsetmask' verfuegbar?
  beq.b    tos            ; B: nein
  move.l   A1,-(SP)       ; die Åbrigen Register brauchen nicht gesichert
                          ; zu werden, da am Schluss sowieso die neuen Werte
                          ; aus <env> geladen werden.
  move.l   D1,-(SP)       ; Psigsetmask(D1)
  move.w   #$0117,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movea.l  (SP)+,A1
  bra.b    ende
tos:
  nop                     ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  move.l   D1,(A0)
ende:
  move.w   12(A6),D0      ; D0 := <val>
  bne.b    setregs        ; B: Wert <> Null uebernehmen
  moveq    #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  nop                     ; durch SETREG(1, hasFpu) ersetzt
  nop
  beq.b    setcpu
  fmovem.x 13*4(A1),FP1-FP7 ; FPU-Register auf Wert vor "setjmp()"
setcpu:
  movem.l  (A1),D2-A0/A2-A7 ; CPU-Register auf Wert vor "sigsetjmp()"
  move.w   D0,(SP)        ; Funktionswert := <val>
  jmp      (A0)           ; zurueck wie nach "sigsetjmp()"-Aufruf
*)
 CODE(226EH,000EH);
 CODE(4A69H,008CH,671EH,2229H,0088H,4A40H,6710H,2F09H);
 CODE(2F01H,3F3CH,0117H,4E41H,5C8FH,225FH,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2081H,302EH,000CH,6602H,7001H);
 SETREG(1, hasFpu);
 CODE(6706H,0F229H,0D07FH,0034H,4CD1H,0FDFCH,3E80H,4ED0H);
END siglongjmp;

#elif (defined HM2)

(* Es kann nicht mit __PROCFRAME_OFF__ gearbeitet werden, da die globalen
 * Variablen ueber Register A5 angesprochen werden, das erst im
 * Prozedurprolog fuer dieses Modul gesetzt wird.
 *)

PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
BEGIN
 SETREG(0, hasFpu);
(*
setjmp:
  movea.l  (SP)+,A5       ; A5 -> globale Variablen Aufrufer
  movea.l  (SP)+,A6       ; A6 -> lokale Variablen Aufrufer
  movea.l  (SP)+,A1       ; A1 := RTN-Adresse
  movea.l  (SP)+,A0       ; A0 -> <env>
; Parameter, Link und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l  D2-D7/A1-A7,(A0) ; CPU-Register und RTN-Adr. in <env> sichern
  tst.w    D0
  beq.b    ret
  fmovem.x FP1-FP7,13*4(A0) ; FPU-Register in <env> sichern
ret:
  moveq    #0,D0          ; Funktionswert := 0
  jmp      (A1)           ; zurueck zum Aufrufer
*)
 CODE(2A5FH,2C5FH);
 CODE(225FH,205FH,48D0H,0FEFCH,4A40H,6706H,0F228H,0F07FH);
 CODE(0034H,7000H,4ED1H);
END setjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );

BEGIN
 Psigreturn;
 SETREG(1, hasFpu);
(*
longjmp:
  movea.l  12(SP),A0      ; A0 -> <env>
#ifdef __LONG_WHOLE__
  move.l   12+4(SP),D0    ; D0 := <val>
#else
  move.w   12+4(SP),D0    ; D0 := <val>
#endif
  bne.b    setregs        ; B: Wert <> Null uebernehmen
  moveq    #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  tst.w    D1
  beq.b    setcpu
  fmovem.x 13*4(A0),FP1-FP7 ; FPU-Register auf Wert vor "setjmp()"
setcpu:
  movem.l  (A0),D2-D7/A1-A7 ; CPU-Register, RTN-Adr. auf Wert vor "setjmp()"
  jmp      (A1)           ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206FH,000CH);
#ifdef __LONG_WHOLE__
 CODE(202FH,0010H);
#else
 CODE(302FH,0010H);
#endif
 CODE(6602H,7001H,4A41H,6706H,0F228H,0D07FH);
 CODE(0034H,4CD0H,0FEFCH,4ED1H);
END longjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;

BEGIN
(*
sigsetjmp:
  move.l   A5,D1          ; Zeiger auf eigene globale Variablen sichern
  movea.l  (SP)+,A5       ; A5 -> globale Variablen des Aufrufers
  movea.l  (SP)+,A6       ; A6 -> lokale Variablen des Aufrufers
  movea.l  (SP)+,A0       ; A0 := RTN-Adresse
  movea.l  (SP)+,A1       ; A1 -> <env>
; Parameter und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l  D2-A0/A2-A7,(A1)
  exg      A5,D1          ; A5 -> eigene globale Variablen
  nop                     ; ersetzt durch: SETREG(0, hasFpu)
  nop
  beq.b    l0
  fmovem.x FP1-FP7,13*4(A1)
l0:
  move.w   (SP)+,D0       ; D0 := <savemask>
  pea      (A0)           ; RTN-Adresse fuer rts
  move.w   D0,13*4+7*12+4(A1)  ; <savemask> in <env> sichern
  beq.b    ende           ; B: Prozessmaske nicht sichern
  nop                     ; ersetzt durch: SETREG(0, hasMask)
  beq.b    tos            ; B: 'Psigblock' nicht verfuegbar
  movem.l  D1/D2/A1/A2,-(SP)
  clr.l    -(SP)          ; Psigblock(0) -> D0 := MiNT-Prozessmaske
  move.w   #$0116,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movem.l  (SP)+,D1/D2/A1/A2
  bra.b    save
tos:
  nop                     ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop                     ;
  move.l   (A0),D0        ; D0 := TOS-Prozessmaske
save:
  move.l   D0,13*4+7*12(A1)    ; Prozessmaske in <env> sichern
ende:
  movea.l  D1,A5          ; A5 -> globale Variablen des Aufrufers
  moveq    #0,D0          ; Funktionswert gleich Null
  rts
*)
 CODE(220DH,2A5FH);
 CODE(2C5FH,205FH,225FH,48D1H,0FDFCH,0C38DH);
 SETREG(0, hasFpu);
 CODE(6706H,0F229H,0F07FH,0034H,301FH,4850H,3340H,008CH);
 CODE(6722H);
 SETREG(0, hasMask);
 CODE(6714H,48E7H,6060H,42A7H,3F3CH,0116H);
 CODE(4E41H,5C8FH,4CDFH,0606H,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2010H,2340H,0088H,2A41H,7000H,4E75H);
END sigsetjmp;

(*----------------------------------------------------------------------------*)

PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );

BEGIN
 Psigreturn;
 SETREG(0, hasMask);
(*
siglongjmp:
  movea.l  12(SP),A1      ; A1 -> <env>
  tst.w    13*4+7*12+4(A1) ; Prozessmaske restaurieren ?
  beq.b    ende           ; B: nein
  move.l   13*4+7*12(A1),D1 ; D1 := Prozessmaske
  tst.w    D0             ; 'Psigsetmask' verfuegbar?
  beq.b    tos            ; B: nein
  move.l   A1,-(SP)       ; die Åbrigen Register brauchen nicht gesichert
                          ; zu werden, da am Schluss sowieso die neuen Werte
                          ; aus <env> geladen werden.
  move.l   D1,-(SP)       ; Psigsetmask(D1)
  move.w   #$0117,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movea.l  (SP)+,A1
  bra.b    ende
tos:
  nop                     ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  move.l   D1,(A0)
ende:
#ifdef __LONG_WHOLE__
  move.l   12+4(SP),D0    ; D0 := <val>
#else
  move.w   12+4(SP),D0    ; D0 := <val>
#endif
  bne.b    setregs        ; B: Wert <> Null uebernehmen
  moveq    #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  nop                     ; durch SETREG(1, hasFpu) ersetzt
  nop
  beq.b    setcpu
  fmovem.x 13*4(A1),FP1-FP7 ; FPU-Register auf Wert vor "sigsetjmp()"
setcpu:
  movem.l  (A1),D2-A0/A2-A7 ; CPU-Register auf Wert vor "sigsetjmp()"
  jmp      (A0)           ; zurueck wie nach "sigsetjmp()"-Aufruf
*)
 CODE(226FH,000CH);
 CODE(4A69H,008CH,671EH,2229H,0088H,4A40H,6710H,2F09H);
 CODE(2F01H,3F3CH,0117H,4E41H,5C8FH,225FH,6006H);
 SETREG(8, SIGMASKadr);
 CODE(2081H);
#ifdef __LONG_WHOLE__
 CODE(202FH,0010H);
#else
 CODE(302FH,0010H);
#endif
 CODE(6602H,7001H);
 SETREG(1, hasFpu);
 CODE(6706H,0F229H,0D07FH,0034H,4CD1H,0FDFCH,4ED0H);
END siglongjmp;

#elif (defined TDIM2)

__PROCFRAME_OFF__
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
BEGIN
 SETREG(0, hasFpu);
(*
setjmp:
  movea.l  (SP)+,A1      ; A1 := RTN-Adresse
  movea.l  (SP),A0       ; A0 -> <env>, nicht abraeumen, macht Aufrufer
; RTN-Adresse ist jetzt vom Stack abgeraeumt
  movem.l  D2-D7/A1-A7,(A0) ; CPU-Register und RTN-Adr. in <env> sichern
  tst.w    D0
  beq.b    ret
  fmovem.x FP1-FP7,13*4(A0) ; FPU-Register in <env> sichern
ret:
  clr.w    4(SP)         ; Funktionswert := 0
  jmp      (A1)          ; zurueck zum Aufrufer
*)
 CODE(225FH,2057H);
 CODE(48D0H,0FEFCH,4A40H,6706H,0F228H,0F07FH,0034H,426FH);
 CODE(0004H,4ED1H);
END setjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );

BEGIN
 Psigreturn;
 SETREG(1, hasFpu);
(*
longjmp:
  movea.l  4+2(SP),A0    ; A0 -> <env>
  move.w   4(SP),D0      ; D0 := <val>
  bne.b    setregs       ; B: Wert <> Null uebernehmen
  moveq    #1,D0         ; Wert Null auf Eins korrigieren
setregs:
  movem.l  (A0),D2-D7/A1-A7 ; CPU-Register, RTN-Adr. auf Wert vor "setjmp()"
  tst.w    D1
  beq.b    setcpu
  fmovem.x 13*4(A0),FP1-FP7 ; FPU-Register auf Wert vor "setjmp()"
setcpu:
  movem.l  (A0),D2-D7/A1-A7 ; CPU-Register, RTN-Adr. auf Wert vor "setjmp()"
  move.w   D0,4(SP)      ; Funktionswert := <val>
  jmp      (A1)          ; zurueck wie nach "setjmp()"-Aufruf
*)
 CODE(206FH,0006H);
 CODE(302FH,0004H,6602H,7001H,4CD0H,0FEFCH,4A41H,6706H);
 CODE(0F228H,0D07FH,0034H,4CD0H,0FEFCH,3F40H,0004H,4ED1H);
END longjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;

BEGIN
(*
sigsetjmp:
  movea.l  (SP)+,A0       ; A0 := RTN-Adresse
  move.w   (SP),D0        ; D0 := <savemask>
  movea.l  2(SP),A1       ; A1 -> <env>
; Parameter und RTN-Adresse sind jetzt vom Stack abgeraeumt
  movem.l  D2-A0/A2-A7,(A1)
  nop                     ; ersetzt durch: SETREG(1, hasFpu)
  nop
  nop
  beq.b    l0
  fmovem.x FP1-FP7,13*4(A1)
l0:
  pea      (A0)           ; RTN-Adresse fuer rts
  move.w   D0,13*4+7*12+4(A1)  ; <savemask> in <env> sichern
  beq.b    ende           ; B: Prozessmaske nicht sichern
  nop                     ; ersetzt durch: SETREG(0, hasMask)
  nop
  nop
  beq.b    tos            ; B: 'Psigblock' nicht verfuegbar
  movem.l  D2/A1/A2,-(SP)
  clr.l    -(SP)          ; Psigblock(0) -> D0 := MiNT-Prozessmaske
  move.w   #$0116,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movem.l  (SP)+,D2/A1/A2
  bra.b    save           ;
tos:
  nop                     ; ersetzt durch: SETREG(8, SIGMASKadr)
  nop
  nop
  move.l   (A0),D0        ; D0 := TOS-Prozessmaske
save:
  move.l   D0,13*4+7*12(A1)    ; Prozessmaske in <env> sichern
ende:
  clr.w    4+4+2(SP)      ; Funktionswert gleich Null
  rts
*)
 CODE(205FH,3017H);
 CODE(226FH,0002H,48D1H,0FDFCH);
 SETREG(1, hasFpu);
 CODE(6706H);
 CODE(0F229H,0F07FH,0034H,4850H,3340H,008CH,6728H);
 SETREG(0, hasMask);
 CODE(6714H,48E7H,2060H,42A7H,3F3CH,0116H);
 CODE(4E41H,5C8FH,4CDFH,0604H,6008H);
 SETREG(8, SIGMASKadr);
 CODE(2010H,2340H,0088H,426FH,000AH,4E75H);
END sigsetjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );

BEGIN
 Psigreturn;
 SETREG(0, hasMask);
(*
siglongjmp:
  movea.l  4+2(SP),A1     ; A1 -> <env>
  tst.w    13*4+7*12+4(A1)     ; Prozessmaske restaurieren ?
  beq.b    ende           ; B: nein
  move.l   13*4+7*12(A1),D1    ; D1 := Prozessmaske
  tst.w    D0             ; 'Psigsetmask' verfuegbar?
  beq.b    tos            ; B: nein
  move.l   A1,-(SP)       ; die Åbrigen Register brauchen nicht gesichert
                          ; zu werden, da am Schluss sowieso die neuen Werte
                          ; aus <env> geladen werden.
  move.l   D1,-(SP)       ; Psigsetmask(D1)
  move.w   #$0117,-(SP)   ;
  trap     #1             ;
  addq.l   #6,SP          ;
  movea.l  (SP)+,A1
  bra.b    ende
tos:
  nop                     ; durch SETREG(8, SIGMASKadr) ersetzt
  nop
  nop
  move.l   D1,(A0)
ende:
  move.w   4(SP),D0       ; D0 := <val>
  bne.b    setregs        ; B: Wert <> Null uebernehmen
  moveq    #1,D0          ; Wert Null auf Eins korrigieren
setregs:
  nop                     ; durch SETREG(1, hasFpu) ersetzt
  nop
  nop
  beq.b    setcpu
  fmovem.x 13*4(A1),FP1-FP7 ; FPU-Register auf Wert vor "sigsetjmp()"
setcpu:
  movem.l  (A1),D2-A0/A2-A7 ; CPU-Register auf Wert vor "sigsetjmp()"
  move.w   D0,4+2(SP)     ; Funktionswert := <val>
  jmp      (A0)           ; zurueck wie nach "sigsetjmp()"-Aufruf
*)
 CODE(226FH,0006H);
 CODE(4A69H,008CH,6720H,2229H,0088H,4A40H,6710H,2F09H);
 CODE(2F01H,3F3CH,0117H,4E41H,5C8FH,225FH,6008H);
 SETREG(8, SIGMASKadr);
 CODE(2081H,302FH,0004H,6602H,7001H);
 SETREG(1, hasFpu);
 CODE(6706H,0F229H,0D07FH,0034H,4CD1H,0FDFCH);
 CODE(3F40H,0006H,4ED0H);
END siglongjmp;
__PROCFRAME_ON__

#elif (defined MM2)

__PROCFRAME_OFF__
PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
BEGIN
 ASSEMBLER
   MOVEA.L  (A7)+,A1            ; A1 := RTN-Adresse und vom Stack abraeumen
   MOVEA.L  -(A3),A0            ; A0 -> <env>
   MOVEM.L  D2-D7/A1-A7,(A0)    ; CPU-Register und RTN-Adr. in <env> sichern
   TST.W    hasFpu
   BEQ.S    ret
   FMOVEM.X FP1-FP7,13*4(A0)    ; FPU-Register in <env> sichern
ret:
   MOVEQ    #0,D0               ; Funktionswert := 0
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L   D0,(A3)+            ; Funktionswert := 0
#else
   MOVE.W   D0,(A3)+            ; Funktionswert := 0
#endif
#endif
   JMP      (A1)                ; zurueck zum Aufrufer
 END;
END setjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE longjmp ((* EIN/ -- *) VAR env : JmpBuf;
                   (* EIN/ -- *)     val : int    );

BEGIN
 Psigreturn;
 ASSEMBLER
#ifdef __LONG_WHOLE__
   MOVE.L   -(A3),D0            ; D0 := <val>, Flags setzen
#else
   MOVE.W   -(A3),D0            ; D0 := <val>, Flags setzen
#endif
   MOVEA.L  -(A3),A0            ; A0 -> <env>, Flags nicht veraendern
; Parameterstack abgeraeumt
   BNE.S    setregs             ; B: Wert <> Null uebernehmen
   MOVEQ    #1,D0               ; Wert Null auf Eins korrigieren
setregs:
   TST.W    hasFpu
   BEQ.S    setcpu
   FMOVEM.X 13*4(A0),FP1-FP7    ; FPU-Register auf Wert vor "setjmp()"
setcpu:
   MOVEM.L  (A0),D2-D7/A1-A7    ; CPU-Register, RTN-Adr. auf Wert vor "setjmp()"
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L   D0,(A3)+            ; Funktionswert := <val>
#else
   MOVE.W   D0,(A3)+            ; Funktionswert := <val>
#endif
#endif
   JMP      (A1)                ; zurueck wie nach "setjmp()"-Aufruf
 END;
END longjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE sigsetjmp ((* -- /AUS *) VAR env      : SigJmpBuf;
                     (* EIN/ -- *)     savemask : UNSIGNEDWORD ): int;

BEGIN
 ASSEMBLER
   MOVEA.L  (A7)+,A0            ; A0 := RTN-Adresse und vom Stack abraeumen
   MOVE.W   -(A3),D1            ; D1 := <savemask>
   MOVEA.L  -(A3),A1            ; A1 -> <env>
   MOVEM.L  D2-A0/A2-A7,(A1)    ; CPU-Register und RTN-Adr. in <env> sichern
   TST.W    hasFpu
   BEQ.S    l0
   FMOVEM.X FP1-FP7,13*4(A1)    ; FPU-Register in <env> sichern
l0:
   PEA      (A0)                ; RTN-Adresse fuer rts
   MOVE.W   D1,13*4+7*12+4(A1)  ; <savemask> in <env> sichern
   BEQ.S    ende
   TST.W    hasMask
   BEQ.S    tos
   MOVEM.L  D2/A1/A2,-(SP)
   CLR.L    -(SP)               ; Psigblock(0) -> D0
   MOVE.W   #$0116,-(SP)
   TRAP     #1
   ADDQ.L   #6,SP
   MOVEM.L  (SP)+,D2/A1/A2
   BRA.S    save
tos:
   MOVE.L   SIGMASK,D0
save:
   MOVE.L   D0,13*4+7*12(A1)
ende:
   MOVEQ    #0,D0               ; Funktionswert := 0
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L   D0,(A3)+            ; Funktionswert := 0
#else
   MOVE.W   D0,(A3)+            ; Funktionswert := 0
#endif
#endif
   RTS                          ; zurueck zum Aufrufer
 END;
END sigsetjmp;
__PROCFRAME_ON__
(*----------------------------------------------------------------------------*)
__PROCFRAME_OFF__
PROCEDURE siglongjmp ((* EIN/ -- *) VAR env : SigJmpBuf;
                      (* EIN/ -- *)     val : int       );

BEGIN
 Psigreturn;
 ASSEMBLER
#ifdef __LONG_WHOLE__
   MOVE.L   -(A3),D1            ; D1 := <val>
#else
   MOVE.W   -(A3),D1            ; D1 := <val>
   EXT.L    D1
#endif
   MOVEA.L  -(A3),A1            ; A1 -> <env>
; Parameterstack abgeraeumt
   TST.W    13*4+7*12+4(A1)     ; Prozessmaske restaurieren ?
   BEQ.S    ende                ; B: nein
   MOVE.L   13*4+7*12(A1),D0    ; D0 := Prozessmaske
   TST.W    hasMask             ; 'Psigsetmask' verfuegbar?
   BEQ.S    tos                 ; B: nein
   MOVEM.L  D1/A1,-(SP)
   MOVE.L   D0,-(SP)            ; Psigsetmask(D0)
   MOVE.W   #$0117,-(SP)        ;
   TRAP     #1                  ;
   ADDQ.L   #6,SP               ;
   MOVEM.L  (SP)+,D1/A1
   BRA.S    ende
tos:
   MOVE.L   D0,SIGMASK          ; TOS-Prozessmaske setzen
ende:
   MOVE.L   D1,D0               ; <val> gleich Null ?
   BNE.S    setregs             ; B: Wert <> Null uebernehmen
   MOVEQ    #1,D0               ; Wert Null auf Eins korrigieren
setregs:
   TST.W    hasFpu
   BEQ.S    setcpu
   FMOVEM.X 13*4(A1),FP1-FP7    ; FPU-Register auf Wert vor "sigsetjmp()"
setcpu:
   MOVEM.L  (A1),D2-A0/A2-A7    ; CPU-Register auf Wert vor "sigsetjmp()"
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L   D0,(A3)+            ; Funktionswert := <val>
#else
   MOVE.W   D0,(A3)+            ; Funktionswert := <val>
#endif
#endif
   JMP      (A0)                ; zurueck wie nach "sigsetjmp()"-Aufruf
 END;
END siglongjmp;
__PROCFRAME_ON__

#elif (defined FTLM2)

PROCEDURE setjmp ((* -- /AUS *) VAR env : JmpBuf ): int;
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

BEGIN
 Psigreturn;
(*
longjmp:
  movea.l 8+2(A6),A0       ; A0 -> <env>
  move.w  8(A6),D0         ; D0 := <val>
  bne.b   setregs          ; B: Wert <> Null uebernehmen
  moveq   #1,D0            ; Wert Null auf Eins korrigieren
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
#endif

(*===========================================================================*)

CONST EINVFN = 0FFFFFFE0H; (* = er.EINVFN als (UN)SIGNEDLONG-Konstante *)

BEGIN (* jump *)
#ifndef MM2
 SIGMASKadr := ADR(SIGMASK);
#endif
 IF Psigblock(0) = EINVFN THEN
   (* Wenn der 'Psigblock'-Aufruf unterstuetzt wird, kann dieses Bitmuster
    * nicht auftreten, weil SIGSTOP (Bit 17) und SIGCONT (Bit 19) nicht
    * blockiert werden/sein koennen. Es wird angenommen, dass das Ergebnis
    * des Tests auch fuer 'Psigsetmask' gilt.
    *)
   hasMask := 0;
 ELSE
   hasMask := 1;
 END;
 GetFPU(fpu);
 IF (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{}) THEN
   hasFpu := 1;
 ELSE
   hasFpu := 0;
 END;
END jump.
