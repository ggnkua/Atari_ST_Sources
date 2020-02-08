;Programm zum Umschalten in den Supervisor Mode
;in KapA5.TOS Datei ASM2.S
;****** Von User in den Supervisor Mode *******
;
TEXT
GEMDOS EQU 1
SUPER  EQU 20
;
         CLR.L   -(SP)        ;
         MOVE.W  #SUPER,-(SP) ; Funktionsnummer auf den Stack
         TRAP    #GEMDOS      ; GEMDOS TRAP
         ADDQ.L  #6,SP        ; Stack auf alten Wert
;
;*************************************
;In 'D0' befindet sich jetzt der User Stackpointer
;
;****** Rette alten Stackpointer ********
;
          MOVE.L  D0,OLDSTACK ; User Stackpointer retten
;
;****************************************
;
;Ab jetzt Supervisormode !
;
;Hier kann man jetzt z.B. Auf die Hardwareregister zugreifen
;oder die Systemvektoren
;
;
;******* ZurÅck in den Usermode ********
;
          MOVE.L   OLDSTACK(PC),-(SP);  Alten Stackpointer
                                     ;  auf Stack
          MOVE.W  #SUPER,-(SP)       ;  Funktionsnummer auf Stack
          TRAP    #GEMDOS            ;  GEMDOS TRAP
          ADDQ.L  #6,SP              ;  Stackpointer auf alte
                                     ;  Position
;
;****************************************
;
;       ******* QUIT ******
;
          CLR.W   -(SP)   ; Funktionsnummer auf Stack
          TRAP    #GEMDOS ; GEMDOS TRAP
;
DATA  ;  Gibt  an, daû jetzt nur  noch  Daten  kommen,  wird
      ;  vom Bertriebssystem angelegt und nicht mit dem
      ;  Programm abgespeichert
;
OLDSTACK: DS.L 1  ; Ein Langwort fÅr alten Stackpointer
                  ; reservieren
