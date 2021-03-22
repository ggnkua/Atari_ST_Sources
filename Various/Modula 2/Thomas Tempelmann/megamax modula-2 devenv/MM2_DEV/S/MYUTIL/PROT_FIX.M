MODULE PROT_FIX;

(*
 * Dieses Programm behebt einen Fehler von PROTOS. Der Fehler in Protos
 * Ñuûert sich darin, daû das Modula-System bei aktivem "Abbruch mit Ctrl-C"
 * (s. Parameter/Shell-Dialogbox) bei Start von Programmen (z.B. DECODE)
 * meist eine Privilegsverletzung anzeigt (8 Bomben).
 *
 * Wer Protos anwendet, sollte unbedingt dieses Programm Åbersetzen
 * und linken (voll optimiert, KEINE Treiber - auch nicht M2Init).
 * Dann muû es direkt nach Protos im AUTO-Ordner stehen. Das heiût:
 * Es muû direkt nach Protos gestartet werden! Notfalls den AUTO-Ordner
 * lîschen und die Programme in der richtigen Reihenfolge neu hinein-
 * kopieren.
 *
 * Wenn es richtig installiert wurde, gibt es die Meldung
 * "Protos-Fix installiert" aus. Ist Protos nicht davor installiert,
 * kommt stattdessen die invertierte Meldung
 * "Protos-Fix: Protos nicht installiert!".
 *)

(*$ M-  Keine Symbole ablegen *)
(*$ N+  Runtime-Modul nicht automatisch importieren *)
(*$ L-  FÅr Assembler: Keine Codeerzeugung vom Compiler am Prozedurbeginn *)

FROM SYSTEM IMPORT ASSEMBLER, BYTE, ADDRESS;

CONST
      (* base page constants *)
      codestart = 8;
      codelen   = 12;
      datastart = 16;
      datalen   = 20;
      bssstart  = 24;
      bsslen    = 28;
      parent    = 36;
      
      (* XBIOS functions *)
      SupExec = 38;
      
      (* GEMDOS functions *)
      Pterm0  = $00;
      Cconws  = $09;
      Super   = $20;
      Malloc  = $48;
      Mshrink = $4A;
      Pterm   = $4C;
      PtermRes= $31;


VAR     active: BYTE;
        old, vec: ADDRESS;

PROCEDURE protosFix;
  BEGIN
    ASSEMBLER
        ; Prolog fÅr XBRA-Kennung
        ASC     'XBRA'
        ASC     'PrFx'
last:   DC.L    0

(* gescheiterter Versuch: Super-Aufrufe werden nicht durch Protos geleitet
        ; Hier kommen alle GEMDOS-Aufrufe vorbei; wir prÅfen, ob ein
        ; Super-Aufruf vorliegt
        BTST    #5,(A7)         ; aus welchem Modus kommt Aufruf?
        BNE     fromSuper
        
        MOVE.L  A0,-(A7)
        MOVE.L  USP,A0
        CMPI.W  #Super,(A0)     ; ist es ein Super-Aufruf?
        MOVE.L  A0,(A7)+
        BEQ     skipProtos      ; ja -> Protos-Handler Åberspringen
        BRA     callProtos

fromSuper:
        CMPI.W  #Super,6(A7)    ; ist es ein Super-Aufruf?
        BEQ     skipProtos      ; ja -> Protos-Handler Åberspringen
*)

(* wir verhindern allg. ein Reentry im Protos - geht auch schief, da Protos
   die RÅcksprung-Adr nicht aus seinem XBRA-Header liest.
        TAS     active
        BNE     skipProtos
        
callProtos:
        ; zuerst einmal RÅcksprung aus Protos hierher umlenken
        MOVE.L  A0,-(A7)     ; A0 retten
        MOVE.L  last(PC),A0  ; Zeiger auf Protos laden
        MOVE.L  -4(A0),old   ; VorgÑnger von Protos merken
        MOVE.L  A0,vec       ; Vektor auch merken
        PEA     fix2(PC)
        MOVE.L  (A7)+,-4(A0) ; RÅcksprung-Vektor auf 'fix2' lenken
        MOVE.L  (A7)+,A0     ; A0 zurÅck
        
        MOVE.L  vec,-(A7)    ; Protos aufrufen
        RTS

fix2:   ; hier springt Protos am Ende hin
        MOVE.L  A0,-(A7)
        MOVE.L  vec,A0
        MOVE.L  old,-4(A0)
        MOVE.L  (A7)+,A0
        MOVE.L  old,-(A7)
        CLR.B   active
        RTS
*)

skipProtos:
        ; Protos Åberspringen: den Vektor vor Protos anspringen
        SUBQ.L  #4,A7        ; Platz auf Stack machen
        MOVE.L  A0,-(A7)     ; A0 retten
        MOVE.L  last(PC),A0  ; Zeiger auf Protos laden
        MOVE.L  -4(A0),4(A7) ; VorgÑnger von Protos
        MOVE.L  (A7)+,A0     ; A0 zurÅck
        ; ...hier folgt ein "RTS"
    END
  END protosFix;

BEGIN
  ASSEMBLER
        ; in den Supervisor-Modus
        CLR.L   -(A7)
        MOVE    #Super,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
  
        ; PrÅfen, ob Protos installiert ist, und zwar Åber XBRA-Kennung;
        LEA     $84,A0            ; TRAP #1-Vektor
next:   MOVE.L  (A0),A1
        CMPI.L  #$58425241,-12(A1); Ist dies ein XBRA-Eintrag?
        BNE.W   exit              ; nein -> Protos nicht zu finden
        CMPI.L  #$50524F54,-08(A1); Ist es "PROT"?
        BEQ     found
        LEA     -4(A1),A0
        BRA     next              ; weiter in XBRA-Kette nach "PROT" suchen

found:  ; eigenen TRAP #1-Handler vor Protos installieren
        LEA     protosFix,A2
        ADDA.W  #12,A2            ; XBRA-Header Åberspringen
        MOVE.L  A2,(A0)           ; Vektor ersetzen
        MOVE.L  A1,-4(A2)         ; Vektor auf Protos in XBRA-Strukt. eintragen
        CLR.B   active            ; Semaphore lîschen
        
        ; Erfolgsmeldung ausgeben
        PEA     okTxt(PC)
        MOVE.W  #Cconws,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        
        ; Benîtigen Platz des Programms ermitteln:
        MOVE.L  4(A7),A5          ; pointer to base page
        MOVE.L  codelen(A5),D0
        ADD.L   datalen(A5),D0
        ADD.L   bsslen(A5),D0
        ADDI.L  #256,D0           ; D0: total length of static program space
        
        ; Programm beenden und resident machen (Programmcode nicht freigeben)
        CLR.W   -(A7)             ; exitcode = 0
        MOVE.L  D0,-(A7)          ; workspace of process
        MOVE    #PtermRes,-(A7)   ; terminate and stay resident
        TRAP    #1

okTxt:  DC.B    13,10             ; CR, LF
        ASC     'Protos-Fix installiert'
        DC.B    13,10,0           ; CR, LF

errTxt: DC.B    13,10,27,'p'      ; CR, LF, reverse on
        ASC     'Protos-Fix: Protos nicht installiert'
        DC.B    13,10,27,'q',0    ; CR, LF, reverse off

exit:
        ; Fehlermeldung ausgeben
        PEA     errTxt(PC)
        MOVE.W  #Cconws,-(A7)
        TRAP    #1
        MOVE.W  #Pterm0,(A7)      ; terminate process
        TRAP    #1
  END
END PROT_FIX.
