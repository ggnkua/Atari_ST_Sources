IMPLEMENTATION MODULE LongSupport;
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
(* 27-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
INLINE_CODE_IMPORT


FROM PORTAB IMPORT
(* CONST*) MINSIGNEDLONG,
(* TYPE *) SIGNED, UNSIGNED;
#ifndef MM2
FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* PROC *) GetFPU;
#endif

FROM LowLong IMPORT
(* PROC *) fractpart, intpart, scale, fraction, exponent;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#ifndef MM2
VAR
  fpu    : FPUInfo;
  hasFpu : BOOLEAN;
#endif

#if LONGREAL_var
VAR
  null : LONGREAL;
  one  : LONGREAL;

TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;
#else
CONST
  null = LRC(0.0,0);
  one  = LRC(1.0,0);
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE min ((* EIN/ -- *) x : LONGREAL;
               (* EIN/ -- *) y : LONGREAL ): LONGREAL;

BEGIN
 IF x < y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END min;

(*---------------------------------------------------------------------------*)

PROCEDURE max ((* EIN/ -- *) x : LONGREAL;
               (* EIN/ -- *) y : LONGREAL ): LONGREAL;
BEGIN
 IF x > y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END max;

(*---------------------------------------------------------------------------*)

PROCEDURE clip ((* EIN/ -- *) x     : LONGREAL;
                (* EIN/ -- *) lower : LONGREAL;
                (* EIN/ -- *) upper : LONGREAL ): LONGREAL;

BEGIN
 IF (lower <= upper) & (x <= lower) THEN
   RETURN(lower);
 ELSIF x >= upper THEN
   RETURN(upper);
 ELSE
   RETURN(x);
 END;
END clip;

(*---------------------------------------------------------------------------*)

PROCEDURE frexp ((* EIN/ -- *)     real : LONGREAL;
                 (* -- /AUS *) VAR exp  : INTEGER  ): LONGREAL;

BEGIN
#ifdef MM2
 exp := exponent(real);
 RETURN(fraction(real));
#else
 exp := exponent(real) + 1;
 RETURN(scale(fraction(real), -1));
#endif
END frexp;

(*---------------------------------------------------------------------------*)

PROCEDURE ldexp ((* EIN/ -- *) mant : LONGREAL;
                 (* EIN/ -- *) exp  : INTEGER   ): LONGREAL;

BEGIN
 RETURN(scale(mant, exp));
END ldexp;

(*---------------------------------------------------------------------------*)

PROCEDURE modf ((* EIN/ -- *)     real : LONGREAL;
                (* -- /AUS *) VAR int  : LONGREAL ): LONGREAL;

BEGIN
 int := intpart(real);
 RETURN(fractpart(real));
END modf;

(*---------------------------------------------------------------------------*)

PROCEDURE fmod ((* EIN/ -- *) real : LONGREAL;
                (* EIN/ -- *) div  : LONGREAL ): LONGREAL;

BEGIN
 IF div = null THEN
   RETURN(null);
 ELSE
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   div    EQU 12
   real   EQU div+8
   RETURN EQU real+8
#elif (defined TDIM2)
   div    EQU 8
   real   EQU div+8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
   div    EQU real+8
#endif

   fmove.d real(a6),fp0
   fmod.d  div(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   lea     16(SP),SP
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5400H,0014H);
   CODE(0F22EH,5421H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5400H,0008H);
   CODE(0F22EH,5421H,0010H);
#elif (defined TDIM2)
   CODE(0F22EH,5400H,0010H);
   CODE(0F22EH,5421H,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,001CH);
   CODE(4E5EH,285FH,205FH,4FEFH,0010H,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0018H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
   RETURN(real - div * intpart(real / div));
(*
   Folgendes waere auch moeglich, liefert aber eine geringere
   Genauigkeit:

     RETURN(div * fractpart(real / div));

   Erklaerung (hoffentlich richtig...):

   Wegen der endlichen Stellenzahl ist das Ergebnis der Division
   real / div in den meisten Faellen nicht mathematisch exakt.
   Das Ergebnis laesst sich in die Vorkommastellen und die Nachkommastellen
   unterteilen. Haelt sich die absolute Groesse des Werts in Grenzen, koennen
   alle Vorkommastellen repraesentiert werden, d.h das Ergebnis
   von intpart(real / div) ist mathematisch exakt, solange der Exponent
   eine bestimmte Groesse nicht ueberschreitet; das Ergebnis von
   fractpart(real / div) jedoch, also die Nachkommastellen, ist i.allg.
   nicht exakt, wenn nicht das Ergebnis mit der gegebenen Stellenzahl
   repraesentiert werden kann. Hinzu kommt noch, dass die Genauigkeit
   einer Zahl durch fractpart() abnimmt, da ja nur die Bits der Nachkomma-
   stellen benutzt werden koennen, um einen kompletten Realwert darzustellen,
   waehrend der unbekannte Rest mit Nullen aufgefuellt wird.
   Bei intpart werden zwar fuer das Ergebnis auch nur die Vorkommabits
   verwendet, aber da die Nachkommastellen sowieso gleich Null sind,
   entsteht ein Ergebnis mit voller Genauigkeit. Da folgendes gilt:

     fractpart(x) = x - intpart(x),

   erkennt man auch die durch die Subtraktion moegliche Stellenausloeschung
   bei fractpart, wenn x ungefaehr ganzzahlig ist (nur wenige Nachkommabits).

   D.h. also bei: div * intpart(real / div) geht keine Genauigkeit
   verloren, waehrend: div * fractpart(real / div) durch
   fractpart und die damit verbundene Stellenausloeschung und die
   nicht exakten Nachkommastellen an Genauigkeit verliert.

   Bei:

     real - div * intpart(real / div);

   kann es durch die Subtraktion natuerlich auch zu einer Stellenausloeschung
   kommen, wenn der Rest sehr klein ist, also div ein mehr oder weniger
   ganzzahliges Vielfache von real ist, aber in diesem Fall ist auch die
   andere Variante nicht besser, denn durch die Division von real und div
   entsteht dann ein Wert, der wiederum fast ganzzahlig ist, wodurch
   bei fractpart ja wieder eine Stellenausloeschung entsteht:

   Beispiele:

   o fmod(3.5, 1.5):

     1. Variante:

       3.5 / 1.5 = 2.3333...x  ist nicht exakt repraesentierbar
       damit ist auch
       fractpart(3.5 / 1.5) = 0.3333...x nicht exakt repraesentierbar
       und
       1.5 * 0.3333...x = 0.500...y  nicht genau

     2. Variante:

       intpart(3.5 / 1.5) = 2.0  ist exakt darstellbar
       damit ist auch
       1.5 * 2.0 = 3.0  exakt darstellbar
       und ebenfalls
       3.5 - 3.0 = 0.5

   o fmod(3.001, 1.5):

     1. Variante:

       3.001 / 1,5 = 2.0006666...x  nicht exakt darstellbar
       zusaetzlich Stellenausloeschung bei
       fractpart(3.001 / 1.5) = 0.0006666...x
       Ergebnis
       1.5 * 0.0006666...x = 0.001000...y  nicht genau

     2. Variante:

       Exaktes Ergebnis bei
       intpart(3.001 / 1.5) = 2.0
       und
       1.5 * 2.0 = 3.0
       aber Stellenausloeschung bei
       3.001 - 3.0 = 0.001
*)
#ifndef MM2
 END;
#endif
 END;
END fmod;

(*---------------------------------------------------------------------------*)

PROCEDURE floor ((* EIN/ -- *) real : LONGREAL ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+8
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
#endif

   fmove.d x(a6),fp0
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen
   moveq   #-$31,d0    ; Rundungsmodus loeschen
   and.l   d1,d0       ;
   ori.b   #$20,d0     ; Rundung nach -Inf setzen
   fmove.l d0,fpcr     ;
   fint.x  fp0         ; runden
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5400H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5400H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0000H,0020H);
   CODE(0F200H,9000H);
   CODE(0F200H,0001H);
   CODE(0F201H,9000H);
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF fractpart(real) >= null THEN
   RETURN(intpart(real));
 ELSE
   RETURN(intpart(real) - one);
 END;
#ifndef MM2
 END;
#endif
END floor;

(*---------------------------------------------------------------------------*)

PROCEDURE ceil ((* EIN/ -- *) real : LONGREAL ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+8
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
#endif

   fmove.d x(a6),fp0
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen
   moveq   #-$31,d0    ; Rundungsmodus loeschen
   and.l   d1,d0       ;
   ori.b   #$30,d0     ; Rundung nach +Inf setzen
   fmove.l d0,fpcr     ;
   fint.x  fp0         ; runden
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5400H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5400H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0000H,0030H);
   CODE(0F200H,9000H);
   CODE(0F200H,0001H);
   CODE(0F201H,9000H);
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF fractpart(real) > null THEN
   RETURN(intpart(real) + one);
 ELSE
   RETURN(intpart(real));
 END;
#ifndef MM2
 END;
#endif
END ceil;

(*---------------------------------------------------------------------------*)

PROCEDURE float ((* EIN/ -- *) card : UNSIGNED ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   card   EQU 12
   RETURN EQU card+4
#elif (defined TDIM2)
   card   EQU 8
   RETURN EQU card+4
#elif (defined HM2)
   card   EQU 8
#endif

   move.l  card(a6),d0
   ; Argument auf Definitionsbereich transformieren
   addi.l  #$80000000,d0   ; = subi.l #$80000000
   fmove.l d0,fp0          ; wandeln
   ; und zuruecktransformieren
   fsub.l  #$80000000,fp0  ; ~ fadd.l #$080000000,fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(202EH,000CH);
#elif (defined HM2)
   CODE(202EH,0008H);
#elif (defined TDIM2)
   CODE(202EH,0008H);
#endif
   CODE(0680H,8000H,0000H);
   CODE(0F200H,4000H);
   CODE(0F23CH,4028H,8000H,0000H);
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(LONGREAL,card));
#elif (defined LPRM2) || (defined SPCM2)
 IF card <= 2147483647D THEN
   RETURN(FLOATD(VAL(LONGINT,card)));
 ELSE
   RETURN(FLOATD(VAL(LONGINT,card - 2147483648D)) + 2147483.648D3);
 END;
#elif (defined HM2)
 RETURN(LFLOAT(card));
#elif (defined TDIM2)
 RETURN(FLOATD(card));
#endif
#ifndef MM2
 END;
#endif
END float;

(*---------------------------------------------------------------------------*)

PROCEDURE real ((* EIN/ -- *) int : SIGNED ): LONGREAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   int    EQU 12
   RETURN EQU int+4
#elif (defined TDIM2)
   int    EQU 8
   RETURN EQU int+4
#elif (defined HM2)
   int    EQU 8
#endif

   fmove.l int(a6),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4000H,000CH);
#elif (defined HM2)
   CODE(0F22EH,4000H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,4000H,0008H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,7400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,7400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(LONGREAL,int));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(FLOATD(int));
#elif (defined HM2)
 RETURN(LFLOAT(int));
#elif (defined TDIM2)
 IF int >= 0 THEN
   RETURN(FLOATD(LONGCARD(int)));
 ELSE
   RETURN(-FLOATD(LONGCARD(-int)));
 END;
#endif
#ifndef MM2
 END;
#endif
END real;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc ((* EIN/ -- *) real : LONGREAL ): UNSIGNED;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+8
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
#endif

   fintrz.d real(a6),fp0    ; Nachkommastellen weg
   ; auf Definitionsbereich transformieren
   fadd.l   #$80000000,fp0  ; ~ fsub.l #$080000000,fp0
   fmove.l  fp0,d0          ; wandeln
   ; zuruecktransformieren
   subi.l   #$80000000,d0   ; = addi.l #$80000000,d0
#if (defined LPRM2) || (defined SPCM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5403H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5403H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5403H,0008H);
#endif
   CODE(0F23CH,4022H,8000H,0000H);
   CODE(0F200H,6000H);
   CODE(0480H,8000H,0000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2) || (defined HM2)
 RETURN(TRUNC(real));
#elif (defined LPRM2) || (defined SPCM2)
 IF real < 2147483.648D3 THEN
   RETURN(VAL(LONGCARD,TRUNCD(real)));
 ELSE
   RETURN(VAL(LONGCARD,TRUNCD(real - 2147483.648D3)) + 2147483648D);
 END;
#elif (defined TDIM2)
 RETURN(TRUNCD(real));
#endif
#ifndef MM2
 END;
#endif
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE int ((* EIN/ -- *) real : LONGREAL ): SIGNED;
#ifdef HM2
VAR int : SIGNED;
#endif
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+8
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
#endif

   fintrz.d real(a6),fp0    ; Nachkommastellen weg
   fmove.l  fp0,d0          ; wandeln
#if (defined LPRM2) || (defined SPCM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5403H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5403H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5403H,0008H);
#endif
   CODE(0F200H,6000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(SIGNED,real));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(TRUNCD(real));
#elif (defined HM2)
 IF real >= null THEN
   RETURN(VAL(SIGNED,TRUNC(real)));
 ELSE
   RETURN(-VAL(SIGNED,TRUNC(-real)));
 END;
#elif (defined TDIM2)
 IF real >= null THEN
   RETURN(SIGNED(TRUNCD(real)));
 ELSE
   RETURN(-SIGNED(TRUNCD(-real)));
 END;
#endif
#ifndef MM2
 END;
#endif
END int;

(*---------------------------------------------------------------------------*)

PROCEDURE entier ((* EIN/ -- *) real : LONGREAL ): SIGNED;

VAR int : SIGNED;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+8
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+8
#elif (defined HM2)
   real   EQU 8
#endif

   fmove.d x(a6),fp0
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen
   moveq   #-$31,d0    ; Rundungsmodus loeschen
   and.l   d1,d0       ;
   ori.b   #$20,d0     ; Rundung nach -Inf setzen
   fmove.l d0,fpcr     ;
   fmove.l fp0,d0      ; nach LONGINT wandeln
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,5400H,000CH);
#elif (defined HM2)
   CODE(0F22EH,5400H,0008H);
#elif (defined TDIM2)
   CODE(0F22EH,5400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0000H,0020H);
   CODE(0F200H,9000H);
   CODE(0F200H,6000H);
   CODE(0F201H,9000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF real >= null  THEN
#if (defined MM2)
   RETURN(VAL(SIGNED,real));
#elif (defined LPRM2) || (defined SPCM2)
   RETURN(TRUNCD(real));
#elif (defined HM2)
   RETURN(SIGNED(TRUNC(real)));
#elif (defined TDIM2)
   RETURN(SIGNED(TRUNCD(real)));
#endif
 ELSE
#if (defined MM2)
   int := VAL(SIGNED,real);
#elif (defined LPRM2) || (defined SPCM2)
   int := TRUNCD(real);
#elif (defined HM2)
   int := -VAL(SIGNED,TRUNC(-real));
#elif (defined TDIM2)
   int := -SIGNED(TRUNCD(-real));
#endif
   IF int = MINSIGNEDLONG THEN
     RETURN(MINSIGNEDLONG);
   END;
#if (defined MM2)
   IF VAL(LONGREAL,int) = real THEN
#elif (defined LPRM2) || (defined SPCM2)
   IF FLOATD(int) = real THEN
#elif (defined HM2)
   IF LFLOAT(int) = real THEN
#elif (defined TDIM2)
   IF -FLOATD(LONGCARD(-int)) = real THEN
#endif
     (* Wenn |<real>| eine glatte Zahl ist,
      * dann nicht um Eins verringern.
      *)
     RETURN(int);
   ELSE
     RETURN(int - LIC(1));
   END;
 END;
#ifndef MM2
 END;
#endif
END entier;

BEGIN (* LongSupport *)
#ifndef MM2
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
#if LONGREAL_var
 WITH cast DO
   lc1 := 000000000H; lc2 := 000000000H; null := lr;
   lc1 := 03FF00000H; (* wie oben *)     one  := lr;
 END;
#endif
END LongSupport.
