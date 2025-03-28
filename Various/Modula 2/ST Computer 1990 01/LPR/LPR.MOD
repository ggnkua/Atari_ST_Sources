IMPLEMENTATION MODULE XBios;

FROM SYSTEM IMPORT REG, SETREG, INLINE, SHORT, LONG ;

CONST
  XBIOSTRAP  = 4E4EH;    (* trap    #14      *)
  PushWord   = 3F00H;    (* move.w  d0,-(sp) *)
  PushLong   = 2F00H;    (* move.l  d0,-(sp) *)
  Pop        = 508FH;    (* ADDQ.L  #x,sp    *)
  TwoBytes   = 0400H;    (* Masken fuer #x   *)
  FourBytes  = 0800H;
  SixBytes   = 0C00H;
  EightBytes = 0000H;
  RegD0      =     0;    (* Wert fuer SETREG *)

(* Hier muessten weitere Routinen stehen. *)

PROCEDURE kbrate(delay, repeat : INTEGER) : CARDINAL;
BEGIN
  SETREG(RegD0,LONG(repeat)); (* repeat nach D0                     *)
  INLINE(PushWord);           (* D0 auf den Stack                   *)
  SETREG(RegD0,LONG(delay));  (* delay nach D0                      *)
  INLINE(PushWord);           (* D0 auf den Stack                   *)
  SETREG(RegD0,35D);          (* Kommandowort fuer kbrate nach D0   *)
  INLINE(PushWord);           (* D0 auf den Stack                   *)
  INLINE(XBIOSTRAP);          (* XBIOS per Trap aufrufen            *)
  INLINE(Pop+SixBytes);       (* Sechs Bytes vom Stack nehmen       *)
  RETURN SHORT(REG(RegD0));   (* Ergebniswert aus D0 zurueckliefern *)
END kbrate;

(* Hier k„men die restlichen XBIOS-Routinen. *)

END XBios.
