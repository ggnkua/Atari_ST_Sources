IMPLEMENTATION MODULE CleanUp;
(* 8ung!! Zugriff auf den M2-PD des Runtime-Systems GEMX ber Register A5! *)
(* Geht nur, weil der M2-Terminator (a la TDI's altem GEMX) Offset -40 hat.*)
(* ½ 1993-95 ROLF SCHRADER. * 11.11.93 ~ 16.2.94 *)

(*$S-,$Q+         Compiler Options: No stack checks, but local quick jumps.*)

FROM  SYSTEM IMPORT ADDRESS, REGISTER, SETREG, CODE;

CONST MAXCLO = 49; LINK = 4E56H;

TYPE  HANDLE = POINTER TO ADDRESS;
      TPOINT = POINTER TO PROC;

VAR   Close: ARRAY [0..MAXCLO] OF PROC;
      Count: CARDINAL;
      oTerm: PROC;
      pTerm: TPOINT;

PROCEDURE Install (Closer: PROC);
 BEGIN INC(Count); Close[Count] := Closer END Install;

PROCEDURE preTerm;
 BEGIN WHILE (Count > 0) DO DEC (Count); Close[Count+1] END;  (* !Sequenz: *)
   END preTerm;              (* K”nnte ja sein, daž ein Closer buggy ist...*)

PROCEDURE nTerm;             (*$P-      Link-Code w„r anfangs blož st”rend.*)
 BEGIN SETREG (15, REGISTER(15) -4); (* Damit der Terminator intakt bleibt.*)
       CODE (LINK, 0);                              (* Freut den Debugger. *)
       PreTerm;                                     (* Der grože Aufwasch. *)
   oTerm;  END nTerm;        (*$P+*)                (* Journey of NoReturn.*)

PROCEDURE ModTerm;
 VAR   pV: POINTER TO INTEGER;
 BEGIN pV := ADDRESS (pTerm) +4;
       pV^:= ExValue;                               (* An aufrufende Shell.*)
   pTerm^; END ModTerm;

PROCEDURE aMPD (): ADDRESS;                   (* -> Main ProcessDescriptor.*)
 VAR   p: HANDLE;
 BEGIN p := REGISTER (13); WHILE (p^ # 0) DO p := p^ END;  RETURN p END aMPD;

BEGIN  ExValue := 0;
       PreTerm := preTerm;
   Count := 0;
   pTerm := aMPD () -40;                            (* TDI's M2-Terminator.*)
   oTerm := pTerm^;                                 (* Vektor gerettet ... *)
   pTerm^:= nTerm;                                  (* ... und umgebogen!  *)
   END CleanUp .
