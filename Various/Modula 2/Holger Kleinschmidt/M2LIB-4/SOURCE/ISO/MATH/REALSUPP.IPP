IMPLEMENTATION MODULE RealSupport;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
#ifdef __LONG_REAL__
(*$!r+: Modul muss mit $r- uebersetzt werden! *)
#else
(*$!r-: Modul muss mit $r+ uebersetzt werden! *)
#endif
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

#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM IMPORT LONG, SHORT;
#endif

FROM PORTAB IMPORT
(* CONST*) MINSIGNEDLONG,
(* TYPE *) SIGNED, UNSIGNED;
#ifndef MM2
FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* PROC *) GetFPU;
#endif

#if (defined HM2) && (defined __LONG_REAL__)
FROM LowLong IMPORT
#else
FROM LowReal IMPORT
#endif
(* PROC *) fractpart, intpart, scale, fraction, exponent;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#ifndef MM2
VAR
  fpu    : FPUInfo;
  hasFpu : BOOLEAN;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#endif

PROCEDURE min ((* EIN/ -- *) x : REAL;
               (* EIN/ -- *) y : REAL ): REAL;

BEGIN
 IF x < y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END min;

(*---------------------------------------------------------------------------*)

PROCEDURE max ((* EIN/ -- *) x : REAL;
               (* EIN/ -- *) y : REAL ): REAL;
BEGIN
 IF x > y THEN
   RETURN(x);
 ELSE
   RETURN(y);
 END;
END max;

(*---------------------------------------------------------------------------*)

PROCEDURE clip ((* EIN/ -- *) x     : REAL;
                (* EIN/ -- *) lower : REAL;
                (* EIN/ -- *) upper : REAL ): REAL;

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

PROCEDURE frexp ((* EIN/ -- *)     real : REAL;
                 (* -- /AUS *) VAR exp  : INTEGER  ): REAL;

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

PROCEDURE ldexp ((* EIN/ -- *) mant : REAL;
                 (* EIN/ -- *) exp  : INTEGER   ): REAL;

BEGIN
 RETURN(scale(mant, exp));
END ldexp;

(*---------------------------------------------------------------------------*)

PROCEDURE modf ((* EIN/ -- *)     real : REAL;
                (* -- /AUS *) VAR int  : REAL ): REAL;

BEGIN
 int := intpart(real);
 RETURN(fractpart(real));
END modf;

(*---------------------------------------------------------------------------*)

PROCEDURE fmod ((* EIN/ -- *) real : REAL;
                (* EIN/ -- *) div  : REAL ): REAL;

BEGIN
 IF div = 0.0 THEN
   RETURN(0.0);
 ELSE
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   div    EQU 12
   real   EQU div+4
   RETURN EQU real+4
#elif (defined TDIM2)
   div    EQU 8
   real   EQU div+4
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#ifdef __LONG_REAL__
   div    EQU real+8
#else
   div    EQU real+4
#endif
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fmove.d real(a6),fp0
   fmod.d  div(a6),fp0
#else
   fmove.s real(a6),fp0
   fmod.s  div(a6),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4400H,0010H);
   CODE(0F22EH,4421H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5400H,0008H);
   CODE(0F22EH,5421H,0010H);
#else
   CODE(0F22EH,4400H,0008H);
   CODE(0F22EH,4421H,000CH);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4400H,000CH);
   CODE(0F22EH,4421H,0008H);
#endif
#ifdef HM2
(*$!f-:
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0014H);
   CODE(4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
   (* Erklaerung in 'LongSupport' *)
   RETURN(real - div * intpart(real / div));
#ifndef MM2
 END;
#endif
 END;
END fmod;

(*---------------------------------------------------------------------------*)

PROCEDURE floor ((* EIN/ -- *) real : REAL ): REAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+4
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fmove.d x(a6),fp0
#else
   fmove.s x(a6),fp0
#endif
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen
   moveq   #-$31,d0    ; Rundungsmodus loeschen
   and.l   d1,d0       ;
   ori.b   #$20,d0     ; Rundung nach -Inf setzen
   fmove.l d0,fpcr     ;
   fint.x  fp0         ; runden
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4400H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5400H,0008H);
#else
   CODE(0F22EH,4400H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4400H,0008H);
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
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF fractpart(real) >= 0.0 THEN
   RETURN(intpart(real));
 ELSE
   RETURN(intpart(real) - 1.0);
 END;
#ifndef MM2
 END;
#endif
END floor;

(*---------------------------------------------------------------------------*)

PROCEDURE ceil ((* EIN/ -- *) real : REAL ): REAL;
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+4
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fmove.d x(a6),fp0
#else
   fmove.s x(a6),fp0
#endif
   fmove.l fpcr,d1     ; alten Rundungsmodus holen und sichern
;   moveq   #$ff-$30,d0 ; Rundungsmodus loeschen
   moveq   #-$31,d0    ; Rundungsmodus loeschen
   and.l   d1,d0       ;
   ori.b   #$30,d0     ; Rundung nach +Inf setzen
   fmove.l d0,fpcr     ;
   fint.x  fp0         ; runden
   fmove.l d1,fpcr     ; alten Rundungsmodus wiederherstellen
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4400H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5400H,0008H);
#else
   CODE(0F22EH,4400H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4400H,0008H);
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
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF fractpart(real) > 0.0 THEN
   RETURN(intpart(real) + 1.0);
 ELSE
   RETURN(intpart(real));
 END;
#ifndef MM2
 END;
#endif
END ceil;

(*---------------------------------------------------------------------------*)

PROCEDURE float ((* EIN/ -- *) card : UNSIGNED ): REAL;
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
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
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
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(REAL,card));
#elif (defined LPRM2) || (defined SPCM2)
 IF card <= 2147483647D THEN
   RETURN(FLOAT(VAL(LONGINT,card)));
 ELSE
   RETURN(FLOAT(VAL(LONGINT,card - 2147483648D)) + 2147483.648E3);
 END;
#elif (defined HM2)
 RETURN(FLOAT(card));
#elif (defined TDIM2)
 RETURN(FLOAT(card));
#endif
#ifndef MM2
 END;
#endif
END float;

(*---------------------------------------------------------------------------*)

PROCEDURE real ((* EIN/ -- *) int : SIGNED ): REAL;
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
   fmove.s fp0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(a6)
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
#ifdef __LONG_REAL__
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
#else
   CODE(0F200H,6400H); (* fmove.s fp0,D0 *)
#endif
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,6400H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22EH,6400H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(REAL,int));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(FLOAT(int));
#elif (defined HM2)
 RETURN(FLOAT(int));
#elif (defined TDIM2)
 IF int >= 0 THEN
   RETURN(FLOAT(LONGCARD(int)));
 ELSE
   RETURN(-FLOAT(LONGCARD(-int)));
 END;
#endif
#ifndef MM2
 END;
#endif
END real;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc ((* EIN/ -- *) real : REAL ): UNSIGNED;
#if (defined LPRM2) || (defined SPCM2)
VAR tmp : LONGREAL;
#endif
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+4
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fintrz.d real(a6),fp0    ; Nachkommastellen weg
#else
   fintrz.s real(a6),fp0    ; Nachkommastellen weg
#endif
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
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4403H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5403H,0008H);
#else
   CODE(0F22EH,4403H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4403H,0008H);
#endif
   CODE(0F23CH,4022H,8000H,0000H);
   CODE(0F200H,6000H);
   CODE(0480H,8000H,0000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2) || (defined HM2)
 RETURN(TRUNC(real));
#elif (defined LPRM2) || (defined SPCM2)
 tmp := LONG(real);
 IF tmp < 2147483.648D3 THEN
   RETURN(VAL(LONGCARD,TRUNCD(tmp)));
 ELSE
   RETURN(VAL(LONGCARD,TRUNCD(tmp - 2147483.648D3)) + 2147483648D);
 END;
#elif (defined TDIM2)
 RETURN(TRUNCD(LONG(real)));
#endif
#ifndef MM2
 END;
#endif
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE int ((* EIN/ -- *) real : REAL ): SIGNED;
#ifdef HM2
VAR int : SIGNED;
#endif
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+4
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fintrz.d real(a6),fp0    ; Nachkommastellen weg
#else
   fintrz.s real(a6),fp0    ; Nachkommastellen weg
#endif
   fmove.l  fp0,d0          ; wandeln
#if (defined LPRM2) || (defined SPCM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4403H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5403H,0008H);
#else
   CODE(0F22EH,4403H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4403H,0008H);
#endif
   CODE(0F200H,6000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
#if (defined MM2)
 RETURN(VAL(SIGNED,real));
#elif (defined LPRM2) || (defined SPCM2)
 RETURN(TRUNCD(LONG(real)));
#elif (defined HM2)
 IF real >= 0.0 THEN
   RETURN(VAL(SIGNED,TRUNC(real)));
 ELSE
   RETURN(-VAL(SIGNED,TRUNC(-real)));
 END;
#elif (defined TDIM2)
 IF real >= 0.0 THEN
   RETURN(SIGNED(TRUNCD(LONG(real))));
 ELSE
   RETURN(-SIGNED(TRUNCD(LONG(-real))));
 END;
#endif
#ifndef MM2
 END;
#endif
END int;

(*---------------------------------------------------------------------------*)

PROCEDURE entier ((* EIN/ -- *) real : REAL ): SIGNED;

VAR int : SIGNED;

BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   real   EQU 12
   RETURN EQU real+4
#elif (defined TDIM2)
   real   EQU 8
   RETURN EQU real+4
#elif (defined HM2)
   real   EQU 8
#endif

#if (defined HM2) && (defined __LONG_REAL__)
   fmove.d x(a6),fp0
#else
   fmove.s x(a6),fp0
#endif
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
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   move.l  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22EH,4400H,000CH);
#elif (defined HM2)
#ifdef __LONG_REAL__
   CODE(0F22EH,5400H,0008H);
#else
   CODE(0F22EH,4400H,0008H);
#endif
#elif (defined TDIM2)
   CODE(0F22EH,4400H,0008H);
#endif
   CODE(0F201H,0B000H);
   CODE(70CFH);
   CODE(0C081H);
   CODE(0000H,0020H);
   CODE(0F200H,9000H);
   CODE(0F200H,6000H);
   CODE(0F201H,9000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(2D40H,0010H);
   CODE(4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2D40H,000CH);
   CODE(4E5EH,4E75H);
#endif
 ELSE
#endif
 IF real >= 0.0  THEN
#if (defined MM2)
   RETURN(VAL(SIGNED,real));
#elif (defined LPRM2) || (defined SPCM2)
   RETURN(TRUNCD(LONG(real)));
#elif (defined HM2)
   RETURN(SIGNED(TRUNC(real)));
#elif (defined TDIM2)
   RETURN(SIGNED(TRUNCD(LONG(real))));
#endif
 ELSE
#if (defined MM2)
   int := VAL(SIGNED,real);
#elif (defined LPRM2) || (defined SPCM2)
   int := TRUNCD(LONG(real));
#elif (defined HM2)
   int := -VAL(SIGNED,TRUNC(-real));
#elif (defined TDIM2)
   int := -SIGNED(TRUNCD(LONG(-real)));
#endif
   IF int = MINSIGNEDLONG THEN
     RETURN(MINSIGNEDLONG);
   END;
#if (defined MM2)
   IF VAL(REAL,int) = real THEN
#elif (defined LPRM2) || (defined SPCM2)
   IF FLOAT(int) = real THEN
#elif (defined HM2)
   IF FLOAT(int) = real THEN
#elif (defined TDIM2)
   IF -FLOAT(LONGCARD(-int)) = real THEN
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

#ifndef MM2
BEGIN (* RealSupport *)
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
#endif
END RealSupport.
