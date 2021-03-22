IMPLEMENTATION MODULE MoreIO;
(*$B+,R-,S-*)

(* ----------------------------------------------------------------------------
 * AUTOR:    Dieter Hametner und Thomas Tempelmann.
 * ERSTELLT: 01.04.90 mit Megamax Modula-2 V2.2
 * ----------------------------------------------------------------------------
 * Treibermodul.
 *
 * NÑheres siehe Definitions-Text
 *
 * Durch Setzen von 'ConfirmClose' auf FALSE wird erreicht, daû
 * beim Ende des damit gelinkten Programms nicht mehr die Meldung
 * '- END -' ausgegeben und auf einen Tastendruck gewartet wird.
 *)

FROM SYSTEM     IMPORT  LONGWORD,       ADDRESS;
IMPORT  Terminal,
        InOutBase,
        VT52;
FROM Strings    IMPORT  String,         MaxChars,       Delete;
FROM MOSGlobals IMPORT  MemArea;
FROM ResCtrl    IMPORT  RemovalCarrier, CatchRemoval;
FROM PrgCtrl    IMPORT  TermProcess;
FROM StrConv    IMPORT  StrToLInt;
FROM GrafBase   IMPORT  GetScreen;

(* ------------------------------------------------------------------------- *)

CONST
  ConfirmClose = TRUE;   (* TRUE -> Bei Prg-Ende wird auf Taste gewartet *)
  
  MaxScreen    = 24L;
  HalfMaxScreen= MaxScreen DIV 2L + 1L;
  
  ESC          = 33C;
  LF           = 12C;
  CR           = 15C;
  BS           = 10C;
  
  MORE         = "- MORE -";
  ENDE         = "- END -";
  STEP         = "- STEP: ";
  SMSG         = "- MORE: Output suppressed! -";

(* ------------------------------------------------------------------------- *)

TYPE
  escState     = (normalEsc, escEsc, gotoXEsc, gotoYEsc);
  escStateDesc = RECORD
                   state  : escState;
                   lnsave : LONGINT;
                   revers : BOOLEAN;
                   wrapon : BOOLEAN;
                   numrow : CARDINAL;
                 END;

(* ------------------------------------------------------------------------- *)

VAR ok         : BOOLEAN;
    waitAtEnd  : BOOLEAN;
    
    lncount    : LONGINT;
    rowcount   : CARDINAL;
    terminated : BOOLEAN;
    nullout    : BOOLEAN;
    vt52       : escStateDesc;

(* ------------------------------------------------------------------------- *)

PROCEDURE reverseOn;
  BEGIN
    IF NOT vt52.revers THEN
      Terminal.WriteString (VT52.Seq[VT52.reverseOn]);
    END;
  END reverseOn;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE reverseOff;
  BEGIN
    IF NOT vt52.revers THEN
      Terminal.WriteString (VT52.Seq[VT52.reverseOff]);
    END;
  END reverseOff;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE NullScreen (on : BOOLEAN);
  BEGIN
    Terminal.WritePg;
    IF on THEN
      reverseOn;
      Terminal.WriteString (VT52.GotoRowColSeq (12, vt52.numrow DIV 2 - 14));
      Terminal.WriteString (SMSG);
      reverseOff;
      Terminal.WriteLn;
      nullout := TRUE;
      lncount := 1L;
    ELSE
      nullout := FALSE;
      lncount := -MaxScreen;
      rowcount := 0;
    END;
  END NullScreen;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE ScreenOn;
  BEGIN
    NullScreen (FALSE);
  END ScreenOn;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE ScrollOff;
  BEGIN
    lncount := 1L;
  END ScrollOff;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE ScrollOn;
  BEGIN
    lncount := 0L;
  END ScrollOn;

(* ------------------------------------------------------------------------- *)

PROCEDURE ScreenOff;
  BEGIN
    NullScreen (TRUE);
  END ScreenOff;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE clearLine;
  BEGIN
    Terminal.WriteString (VT52.Seq[VT52.clearLine]);
    Terminal.WriteString (VT52.Seq[VT52.left]);
  END clearLine;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE More (REF s : ARRAY OF CHAR);

  (* Wird aufgerufen wenn ein LF aufgetreten ist. Falls 'lncount = 0' ist
   * werden die MORE - Aktionen abgefragt.
   *)

  VAR ch        : CHAR;
      success   : BOOLEAN;
      helpcount : CARDINAL;

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
  
  PROCEDURE setcount (c : CHAR) : LONGINT;
    
    (* Liest die Schrittweite fÅr 'lncount' ein. Falls eine falsche Zahl
     * eingegeben wurde, wird eine ganze Bildschirmseite weitergescrollt.
     *)
    VAR count   : LONGINT;
        digits  : ARRAY [0..20] OF CHAR;
        dpos    : CARDINAL;
        valid   : BOOLEAN;
    BEGIN
      count := 0;                                         (* Initialisierung *)
      dpos  := 0;
      
      reverseOn;
      Terminal.WriteString (STEP);
      
      LOOP                                                (* Eingabeschleife *)
        IF (c = BS) THEN
          IF dpos > 0 THEN
            Terminal.WriteString (VT52.Seq[VT52.left]);
            Terminal.WriteString (VT52.Seq[VT52.clearEOL]);
            DEC (dpos);
          END;
        ELSE
          IF (c < '0') OR (c > '9') THEN EXIT; END;
          IF dpos <= 20 THEN
            digits[dpos] := c;   INC (dpos);
            Terminal.Write (c);
          END;
        END;
        Terminal.GetChar (c);
      END;
      IF dpos <= 20 THEN digits[dpos] := 0C; END;
      
      dpos := 0;                                       (* lncount bestimmen. *)
      count := StrToLInt  (digits, dpos, valid);
      IF valid THEN
        CASE CAP (c) OF
        | CR  : ;
        | 'D' : IF count < MaxLInt DIV HalfMaxScreen THEN
                  count := count * HalfMaxScreen;
                ELSE
                  count := HalfMaxScreen;
                END;
        ELSE
          IF count < MaxLInt DIV MaxScreen THEN
            count := count * (MaxScreen - 1L);
          ELSE
            count := MaxScreen - 1L;
          END;
        END;
      ELSE
        count := MaxScreen - 1L;
      END;
      
      reverseOff;                                               (* AufrÑumen *)
      clearLine;
      RETURN count;
    END setcount;

  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

  PROCEDURE checkkey (ch : CHAR) : BOOLEAN;
    (*  Liefert 'TRUE' und konfiguriert 'More' entsprechend, wenn eine gÅltige
     *  Kommandotaste gedrÅckt wurde.
     *  'FALSE' in allen anderen FÑllen.
     *)
    VAR valid : BOOLEAN;
    BEGIN
      valid := TRUE;
      CASE CAP (ch) OF
      | CR         : lncount := -1L;
      | ESC        : NullScreen (TRUE);
      | ' '        : lncount := - MaxScreen + 1L;
      | 'D'        : lncount := - HalfMaxScreen;
      | 'G'        : lncount := 0L;
      | 'Q'        : IF NOT terminated THEN
                       terminated := TRUE;
                       waitAtEnd := FALSE;
                       TermProcess (0);
                     END;
      | '0' .. '9' : lncount := - setcount (ch);
      ELSE
        valid := FALSE;
      END;
      RETURN valid;
    END checkkey;
    
  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)
(*
                    0123456789012345678901234567890123456789
*)
  PROCEDURE Help (VAR count : CARDINAL) : CHAR;
    CONST
    NOHELP = " sorry! no help onthis screen! : ";
    HELP1  = " valid keys: 0..9, RET, SPC, D, Q, G, ESC (other: more help): ";
    HELP2  = " 0..9: repeat following command 'STEP' times! (more help): ";
    HELP3  = " RET: scroll 'STEP' lines! (more help): ";
    HELP4  = " SPC: scroll 'STEP' screens! (more help): ";
    HELP5  = " D: scroll 'STEP' halfscreens! (more help): ";
    HELP6  = " Q: terminate program! (more help): ";
    HELP7  = " G: go-mode (scroll until any key pressed)! (more help): ";
    HELP8  = " ESC: toggle screen on/off! (more help): ";
    HELP9  = " (other): show help messages! (more info): ";
    HELP0  = " Idea and realization by DIETER HAMETNER (West Germany, 1990): ";
    VAR ch : CHAR;
    BEGIN
      reverseOn;
      Terminal.WriteString (s);
      IF (count > 0) THEN
        IF vt52.numrow = 40 THEN
          Terminal.WriteString (NOHELP);
        ELSE
          CASE count OF
          |  1 : Terminal.WriteString (HELP1);
          |  2 : Terminal.WriteString (HELP2);
          |  3 : Terminal.WriteString (HELP3);
          |  4 : Terminal.WriteString (HELP4);
          |  5 : Terminal.WriteString (HELP5);
          |  6 : Terminal.WriteString (HELP6);
          |  7 : Terminal.WriteString (HELP7);
          |  8 : Terminal.WriteString (HELP8);
          |  9 : Terminal.WriteString (HELP9);
          | 10 : Terminal.WriteString (HELP0);
          ELSE
          END;
        END;
      END;
      Terminal.GetChar (ch);
      reverseOff;
      clearLine;
      INC (count);
      IF count = 11 THEN count := 0; END;
      RETURN ch;
    END Help;
    
  (* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *)

  BEGIN
    IF Terminal.KeyPressed () THEN
      Terminal.GetChar (ch);
      IF ch = ESC THEN
        NullScreen (NOT nullout);
        RETURN;
      END;
      IF lncount > 0L THEN
        lncount := 0L;
      END;
    END;
    IF lncount = 0L THEN
      helpcount := 0;
      REPEAT
      UNTIL checkkey (CAP (Help (helpcount)));
    END;
  END More;

(* ------------------------------------------------------------------------- *)

PROCEDURE vt52Emul(c : CHAR);
  
  (* Wird aufgerufen falls 'vt52.state' # 'normalEsc' oder das aktuelle
   * Zeichen 'c' = ESC ist. Diese Prozedur wertet die Escape-Sequenzen aus.
   *)
  BEGIN
    WITH vt52 DO
      CASE state OF
      | normalEsc: IF c = ESC THEN state := escEsc; END;
      | escEsc   : state := normalEsc;
                   CASE c OF
                   | 'A',
                     'I' : IF lncount > -MaxScreen THEN
                             DEC (lncount);
                           END;
                   | 'B' : IF lncount < 1L THEN
                             INC (lncount);
                           END;
                   | 'E',
                     'H' : lncount := -MaxScreen;
                   | 'Y' : state := gotoYEsc;
                   | 'j' : lnsave := lncount;
                   | 'k' : lncount := lnsave;
                   | 'p' : revers := TRUE;
                   | 'q' : revers := FALSE;
                   | 'v' : wrapon := TRUE;
                   | 'w' : wrapon := FALSE;
                   ELSE
                   END;
      | gotoXEsc : state := normalEsc;
      | gotoYEsc : state := gotoXEsc;
                   lncount := -MaxScreen + LONG (ORD (c) - 32);
      END; (* CASE *)
    END; (* WITH *)
  END vt52Emul;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE WriteLn;
  BEGIN
    IF NOT nullout THEN
      Terminal.WriteLn;
      INC (lncount); rowcount := 0;
    END;
    More (MORE);
  END WriteLn;
  
(* ------------------------------------------------------------------------- *)

PROCEDURE Open (x,y: CARDINAL);
  BEGIN
    waitAtEnd:= FALSE;
  END Open;

(* ------------------------------------------------------------------------- *)

PROCEDURE Close;
  BEGIN
    IF waitAtEnd & ConfirmClose THEN
      (*
       * Am Programmende auf Tastendruck warten,
       * wenn zuletzt Ausgaben gemacht wurden, die sonst nicht mehr
       * gesehen wÅrden.
       *)
      terminated := TRUE;
      waitAtEnd:= FALSE;
      lncount := 0L;
      More (ENDE);
    END
  END Close;

(* ------------------------------------------------------------------------- *)

PROCEDURE Read (VAR c: CHAR);
  BEGIN
    waitAtEnd:= FALSE;
    IF nullout THEN NullScreen (FALSE) END;;
    Terminal.Read (c);
    IF c = CR THEN rowcount := 0; ELSE INC (rowcount); END;
    IF vt52.wrapon AND (rowcount = vt52.numrow) THEN
      rowcount := 0; INC (lncount); More (MORE);
    END;
  END Read;

(* ------------------------------------------------------------------------- *)

PROCEDURE Write (c: CHAR);
  BEGIN
    IF NOT nullout THEN
      waitAtEnd:= TRUE;
      Terminal.Write (c);
      IF (vt52.state # normalEsc) OR (c = ESC) THEN vt52Emul (c); END;
      IF c = CR THEN rowcount := 0; ELSE INC (rowcount); END;
      IF c = LF THEN INC (lncount); More (MORE); END;
      IF vt52.wrapon AND (rowcount = vt52.numrow) THEN
        rowcount := 0; INC (lncount);
      END;
    END;
    More (MORE);
  END Write;

(* ------------------------------------------------------------------------- *)

PROCEDURE ReadString (VAR c:ARRAY OF CHAR);
  BEGIN
    waitAtEnd:= FALSE;
    IF nullout THEN NullScreen (FALSE) END;;
    Terminal.ReadString (c);
    WriteLn;
  END ReadString;

(* ------------------------------------------------------------------------- *)

PROCEDURE WriteString (REF s: ARRAY OF CHAR);
  VAR str   : String;
      idx   : CARDINAL; (* Position in 'str' *)
      pos   : CARDINAL; (* Position in 's' *)
      exit  : BOOLEAN;
      ch    : CHAR;
  BEGIN
    IF NOT nullout THEN
      waitAtEnd := TRUE;
      pos       := 0;
      LOOP
        idx  := 0;
        exit := FALSE;
        LOOP
          str[idx] := s[pos];
          ch := s[pos];
          INC (pos);
          INC (idx);
          CASE ch OF
          | 0C  : exit := TRUE; EXIT;
          | CR  : rowcount := 0;
          | LF  : INC (lncount); EXIT;
          | ESC : vt52Emul (ch);
          ELSE
            IF vt52.state # normalEsc THEN
              vt52Emul (ch);
              EXIT;                            (* String ausgeben            *)
            END;
            INC (rowcount);
            IF vt52.wrapon AND (rowcount = vt52.numrow) THEN
              rowcount := 0; INC (lncount);
              ch := LF;                        (* Damit More aufgerufen wird *)
              EXIT;                            (* String ausgeben            *)
            END;
          END;
          IF idx > MaxChars THEN EXIT; END;    (* String ausgeben            *)
          IF pos - 1 = HIGH (s) THEN
            exit := TRUE;
            EXIT;
          END;
        END;
        IF idx <= MaxChars THEN
          str[idx] := 0C;
        END;
        Terminal.WriteString (str);
        IF (vt52.state = normalEsc) AND (ch = LF) THEN
          More (MORE);
        END;
        IF exit THEN EXIT; END;                (* WriteString zu Ende!       *)
      END;
    ELSE
      More (MORE);
    END;
  END WriteString;

(* ------------------------------------------------------------------------- *)

PROCEDURE GetInput ( VAR name: ARRAY OF CHAR );
  BEGIN
    ReadString (name);
  END GetInput;

(* ------------------------------------------------------------------------- *)

PROCEDURE GetOutput ( VAR name: ARRAY OF CHAR; VAR append: BOOLEAN );
  BEGIN
    ReadString (name);
    append:= name[0] = '>';
    IF append THEN
      Delete (name,0,1,ok)
    END;
  END GetOutput;

(* ------------------------------------------------------------------------- *)

PROCEDURE OpenError ( VAR msg: ARRAY OF CHAR; VAR retry: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    nullout := FALSE;
    WriteLn;
    WriteString ('Fehler beim ôffnen: ');
    WriteString (msg);
    WriteLn;
    WriteString ('Nochmalige Eingabe ? (J/N) ');
    REPEAT
      Terminal.BusyRead (c);
      c:= CAP (c)
    UNTIL (c='J') OR (c='N');
    retry:= c='J';
    WriteLn;
  END OpenError;

(* ------------------------------------------------------------------------- *)

PROCEDURE IOError ( VAR msg: ARRAY OF CHAR; input: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    nullout := FALSE;
    WriteLn;
    WriteString ('Fehler bei Datei');
    IF input THEN
      WriteString ('eingabe: ')
    ELSE
      WriteString ('ausgabe: ')
    END;
    WriteString (msg);
    WriteLn;
    WriteString ('Datei wird geschlossen. Bitte Taste drÅcken. ');
    Terminal.FlushKbd;
    REPEAT
      Terminal.BusyRead (c);
    UNTIL c#0C;
    WriteLn;
  END IOError;

(* ------------------------------------------------------------------------- *)

VAR pbuf: ARRAY [0..14] OF LONGWORD; pidx: CARDINAL;

PROCEDURE pset (f:BOOLEAN);
  PROCEDURE pswap (VAR l:LONGWORD; v:LONGWORD);
    (*$R+*)
    BEGIN
      IF f THEN pbuf [pidx]:= l; l:= v ELSE l:= pbuf [pidx] END;
      INC (pidx)
    END pswap;
    (*$R=*)
  BEGIN
    pidx:= 0;
    pswap (InOutBase.Read, ADDRESS (Read));
    pswap (InOutBase.Write, ADDRESS (Write));
    pswap (InOutBase.OpenWdw, ADDRESS (Open));
    pswap (InOutBase.CloseWdw, ADDRESS (Close));
    pswap (InOutBase.KeyPressed, ADDRESS (Terminal.KeyPressed));
    pswap (InOutBase.CondRead, ADDRESS (Terminal.CondRead));
    pswap (InOutBase.WriteLn, ADDRESS (WriteLn));
    pswap (InOutBase.WritePg, ADDRESS (Terminal.WritePg));
    pswap (InOutBase.WriteString, ADDRESS (WriteString));
    pswap (InOutBase.ReadString, ADDRESS (ReadString));
    pswap (InOutBase.GotoXY, ADDRESS (Terminal.GotoXY));
    pswap (InOutBase.GetInput, ADDRESS (GetInput));
    pswap (InOutBase.GetOutput, ADDRESS (GetOutput));
    pswap (InOutBase.OpenError, ADDRESS (OpenError));
    pswap (InOutBase.IOError, ADDRESS (IOError));
  END pset;

(* ------------------------------------------------------------------------- *)

PROCEDURE restore;
  BEGIN
    pset (FALSE) (* Wiederherstellen der alten PROC-Werte *)
  END restore;

(* ------------------------------------------------------------------------- *)

VAR tc        : RemovalCarrier;
    st        : MemArea;
    phys, log : ADDRESS;
    rez       : INTEGER;
BEGIN
  CatchRemoval (tc, restore, st);
  pset (TRUE);  (* Retten der alten PROC-Werte und Setzen der Neuen *)
  nullout     := FALSE;
  lncount     := -MaxScreen;
  rowcount    := 0;
  terminated  := FALSE;
  vt52.state  := normalEsc;
  vt52.lnsave := lncount;
  vt52.revers := FALSE;
  vt52.wrapon := TRUE;                      (* nach Einschalten des Rechners *)
  GetScreen (log, phys, rez);
  IF rez = 0 THEN
    vt52.numrow := 40;
  ELSE
    vt52.numrow := 80;
  END;
END MoreIO.
