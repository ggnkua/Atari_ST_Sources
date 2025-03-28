(******************************************************************************)
(* Modulname           : WodanAcc                                             *)
(* Copyright           : ST Computer & D. Rabich                              *)
(* Datum               :  1. Juni 1989                                        *)
(* letztes Edier-Datum :  1. September 1989                                   *)
(* Version             : 1.00a                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

MODULE WodanAcc;
(*$Q+,M-,N-,V+,P-,R-,S-*)

(* String-Routinen *)
FROM Strings      IMPORT String, Length, Empty;

(* TOS-Routinen *)
FROM XBIOS        IMPORT SuperExec, KeyboardVectors;

(* verschiedene, systemnahe Routinen *)
FROM MOSGlobals   IMPORT MemArea;
FROM Calls        IMPORT SysNewCaller, CallExtRegs, Registers;
FROM SysUtil1     IMPORT SuperPeek, SuperLPeek, SuperLPoke;
FROM SYSTEM       IMPORT ADR, VAL, ADDRESS, LONGWORD, WORD, BYTE;
FROM XBRA         IMPORT Carrier, Install, Installed, Create, Remove,
                         PreviousEntry;

(* Keyboard-Routinen *)
FROM KbdCtrl      IMPORT LookKey, GetKey, Key, PutKey, CtrlKey, CtrlSet;
FROM Keyboard     IMPORT KeyCap, IsAlternate, SpecialKey, SpecialCode;

(* Routinen fÅr die GEM-Umgebung *)
FROM HandleWodan  IMPORT StringArray, InitParameter, HandleAcc, CancelAcc,
                         InitAcc, NoInstallation, SetStringAdr;


CONST MyXBRA  = 'DRRH'; (* reservierte XBRA-Kennung! *)
(* Alle mit DRR beginnenden XBRA-Kennungen sind fÅr      *)
(* Dietmar (R.) Rabich reserviert. H steht fÅr Hermes.   *)
(* Der Name von Wodan war wÑhrend der Testphase Hermes.  *)


VAR   at, entry, vector,
      kbdentry          : ADDRESS;
      kbdstack          : ARRAY [1..800] OF CARDINAL;
      kbdwsp, termwsp   : MemArea;
      kbdv              : POINTER TO ADDRESS;
      carrier           : Carrier;
      ok, InstOK        : BOOLEAN;
      macro             : StringArray;


(* String in den Tastaturpuffer schreiben *)
PROCEDURE kbdWriteString (s : ARRAY OF CHAR);

  VAR i : CARDINAL;
      k : Key;

  BEGIN
    IF ~Empty (s)
    THEN
      k.scan := 0;         (* kein Scan-Code    *)
      k.ctrl := CtrlSet{}; (* keine Sondertaste *)
      FOR i := 0 TO Length (s) - 1 (* Character fÅr Character in den *)
      DO                           (* Puffer schreiben               *)
        k.ch := s[i];
        PutKey (k, ok)
      END
    END
  END kbdWriteString;


(* nachschauen, ob Taste bereitsteht und ggf. String schreiben *)
PROCEDURE hdlKbd (VAR r : Registers);

  VAR k : Key;

  BEGIN
    CallExtRegs (PreviousEntry (entry), r);
    LookKey (k, ok);           (* Taste im Tastaturpuffer? *)
    IF ok
    THEN
      IF IsAlternate(k)        (* mit Alternate gedrÅckt?        *)
      THEN
        GetKey (k, ok);        (* Taste aus dem Puffer entfernen *)
        (* dafÅr unseren String hineinschreiben ...              *)
        kbdWriteString (macro[SpecialKey(k)])
      END
    END
  END hdlKbd;


(* Wodan installieren bzw. entfernen *)
PROCEDURE Aktion (On : BOOLEAN);

  BEGIN

    IF On
    THEN
      IF ~InstOK                                 (* schon einmal installiert? *)
      THEN
        kbdwsp.bottom := ADR (kbdstack);         (* Stackbereich bestimmen    *)
        kbdwsp.length := SIZE (kbdstack);
        SysNewCaller (hdlKbd, FALSE, kbdwsp, kbdentry); (* Entry-Code erzeugen*)
        InstOK := kbdentry # NIL
      END;
      IF InstOK
      THEN
        vector := ADDRESS (KeyboardVectors ()) + $20L; (* Vektor holen *)
        IF NOT Installed (MyXBRA, vector, at)
        THEN
          Create (carrier, MyXBRA, kbdentry, entry);   (* installieren *)
          Install (entry, at)
        END
      ELSE
        NoInstallation
      END
    ELSE
      vector := ADDRESS (KeyboardVectors()) + $20L;  (* Vektor holen   *)
      IF Installed (MyXBRA, vector, at)              (* installiert?   *)
      THEN
        Remove(at)                                   (* dann entfernen *)
      END
    END
  END Aktion;


(* Wodan installieren *)
PROCEDURE Init () : BOOLEAN;

 VAR success : BOOLEAN;

 BEGIN

  InstOK := FALSE;

  success := InitAcc ();         (* Accessory installieren           *)

  SetStringAdr (ADR(macro));     (* Adresse der Strings bekanntgeben *)

  IF success
  THEN
    Aktion (InitParameter())     (* erste Installation               *)
  END;

  RETURN success

 END Init;


(* Hauptprogramm *)
BEGIN
 IF Init() THEN           (* installieren   *)

  WHILE TRUE DO           (* Endlosschleife *)
   Aktion (HandleAcc())
  END

 ELSE

  CancelAcc

 END
END WodanAcc.

