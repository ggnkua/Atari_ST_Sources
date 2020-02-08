****** Beispiel ****** (ASM1.S in KAPA5.TOS auf der Diskette)

; Programm zum Ausgeben eines Zeichens


GEMDOS EQU 1
CONOUT EQU 2


     MOVE.W  #'A',-(SP)     ;legt den ASCII Wert von A auf den
                            ;Stack

     MOVE.W  #CONOUT,-(SP)  ;schreibt die Funktionsnummer auf
                            ;den Stack

     TRAP    #GEMDOS        ;ruft das Betriebssystem
     ADDQ.l  #4,SP          ;setzt den Stackpointer wieder
                            ;auf seinen alten Wert

; Raus aus dem Programm (QUIT)

     CLR.W   -(SP)          ;Åbergibt 0 auf den Stack
