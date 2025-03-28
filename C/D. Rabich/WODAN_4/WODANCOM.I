(******************************************************************************)
(* Modulname           : CommunicationWodan (IMPLEMENTATION)                  *)
(* Copyright           : ST Computer & D. Rabich                              *)
(* Datum               : 10. Juni 1989                                        *)
(* letztes Edier-Datum :  1. September 1989                                   *)
(* Version             : 1.00a                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

IMPLEMENTATION MODULE CommunicationWodan;
(*$Q+,M-,N-,V+,P-,R-,S-*)


(* GEM-Routinen *)
FROM GEMEnv       IMPORT ApplicationID;
FROM AESEvents    IMPORT MessageBuffer;
FROM AESMisc      IMPORT WriteToAppl;

(* SYSTEM-Routinen *)
FROM SYSTEM       IMPORT ADR,ADDRESS;


(* Typen *)
TYPE ForeignBuffer    = RECORD (* spezieller Message-Puffer *)
                          msgType : CARDINAL;
                          msgID   : CARDINAL;
                          msgOver : CARDINAL;
                          msgSAdr : ADDRESS;
                          msgSpID : CARDINAL;
                          msgFree : LONGCARD
                        END;
     PtrForeignBuffer = POINTER TO ForeignBuffer;


(* sendet Nachricht an aufrufende Applikation *)
PROCEDURE SendToAppl (msgBuffer : MessageBuffer; lParasAdr : ADDRESS);

  VAR LokalBuffer       : MessageBuffer;
      PtrForeignMBuffer : PtrForeignBuffer;
      Sender            : CARDINAL;

  BEGIN
    LokalBuffer       := msgBuffer;
    PtrForeignMBuffer := ADR(LokalBuffer);
    Sender            := PtrForeignMBuffer^.msgID;

    WITH PtrForeignMBuffer^            (* Nachricht zusammenstellen *)
    DO
      msgType := ForeignAnswer;        (* Art der Nachricht     *)
      msgID   := ApplicationID();      (* Eigene ID             *)
      msgOver := 0;                    (* keine šberl„nge       *)
      msgSAdr := lParasAdr;            (* Adresse der Parameter *)
      msgSpID := 10089;                (* magic                 *)
      msgFree := 0L                    (* nicht benutzt         *)
    END;

    WriteToAppl(Sender,LokalBuffer,0)  (* senden *)

  END SendToAppl;


END CommunicationWodan.

