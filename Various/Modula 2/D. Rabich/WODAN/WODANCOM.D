(******************************************************************************)
(* Modulname           : CommunicationWodan (DEFINITION)                      *)
(* Copyright           : ST Computer & D. Rabich                              *)
(* Datum               : 10. Juni 1989                                        *)
(* letztes Edier-Datum :  1. September 1989                                   *)
(* Version             : 1.00a                                                *)
(* Entwicklungssystem  : Megamax Modula-2                                     *)
(******************************************************************************)

DEFINITION MODULE CommunicationWodan;
(*$Q+,M-,N-,V+,P-,R-,S-*)


FROM AESEvents    IMPORT MessageBuffer;
FROM SYSTEM       IMPORT ADDRESS;


(* Konstanten fÅr Message-Type *)
CONST ForeignCall   = $4001;          (* Accessory-Fremdaufruf *)
      ForeignAnswer = $4002;


(* Sendet an aufrufende Applikation Message zurÅck *)
PROCEDURE SendToAppl (msgBuffer : MessageBuffer; lParasAdr : ADDRESS);


END CommunicationWodan.

