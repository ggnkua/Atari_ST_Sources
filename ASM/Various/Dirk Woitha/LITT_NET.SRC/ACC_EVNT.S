;
;                 Der Rahmen fÅr ein Accessory.
;                 -----------------------------
;
;        Das Programm, welches als Accessory laufen soll,
;        muû mit dem Label ACC_PGM beginnen und mit RTS
;        enden. Es darf alle Register verÑndern.
;        Ein Programmteil, der wÑhrend der Initialisierung
;        des Accessories (also vor der EVENT-Schleife) aus-
;        gefÅhrt werden soll, muû mit dem Label ACC_RTM
;        beginnen und mit RTS enden; er darf alle Register
;        verÑndern. (Liefert diese Routine eine Zahl ungleich
;        Null in D0 zurÅck, wird das Accessory nicht ange-
;        meldet!)
;        ACC_MSGS muû Pointer auf Mitteilungen enthalten
;        (Ende-Marke: 0.l), die (als Alarm-Boxen) vor Eintritt
;        in die Event-Schleife ausgegeben werden.
;        Der Accessory-Name muû ebenfalls definiert werden.
;
;        ZusÑtzlich werden noch Timer-Events produziert. Dazu mÅssen
;        Low- und High-Teil des Counter-Wertes definiert werden.
;        Bei Eintritt eines Timer-Events wird die Routine ACC_ETIM
;        ausgefÅhrt.
;
;        Es ist also   m i n d e s t e n s   nîtig:
;
;        acc_rtm   moveq #0,d0
;                  rts
;        acc_pgm   rts
;        acc_etim  rts
;
;        acc_name  dc.b   '  <name>',0
;        acc_msgs  dc.l   {<Box-Text 1>,...,<Box-Text n>,}0
;        accclow   dc.w   <counter (low)>
;        accchigh  dc.w   <counter (high)>
;
;
;        Der verfÅgbare Stack ist 0.5 KByte groû.
;
;        Gleichzeit werden komfortable AES-Aufrufe
;        zur VerfÅgung gestellt:
;
;        1) A5 zeigt auf intin(0)
;           A6 zeigt auf addrin(0)
;
;        2) AES:
;
;           move.w   #fktnr,d0         ;Funktionsnummer --> contrl(0)
;           move.l   #$aabbccdd,d1     ;$00aa --> contrl(1)
;                                       $00bb --> contrl(2)
;                                       $00cc --> contrl(3)
;                                       $00dd --> contrl(4)
;           bsr      aescall
;
;           RÅckgabewerte:
;           --------------
;             D0 enthÑlt intout(0)
;             D1 enthÑlt addrout(0)
;
;
;
;   ibST 02/88 #2.1


            .INCLUDE 'CONST.IS'


            .TEXT 


            lea.l     STACK(pc),sp          ;Stackpointer initialisieren
            lea.l     INTIN(pc),a5
            lea.l     ADDRIN(pc),a6         ;Pointer auf die Eingabe-Arrays

            moveq.l   #APPL_INIT,d0
            move.l    #$00010000,d1
            bsr       AESCALL               ;Applikation anmelden
            move.w    d0,AP_ID              ;Applikation-Identifikation merken
            bmi       FEHLER                ;Programmende, falls Fehler

            move.w    #GRAF_HANDLE,d0
            move.l    #$00050000,d1
            bsr       AESCALL               ;Graphik anmelden
            move.w    d0,GRF_HAND           ;Identifikation merken

            lea.l     CONTRL(pc),a0
            move.w    #V_OPNVWK,(a0)
            clr.w     2(a0)
            move.w    #11,6(a0)
            move.w    GRF_HAND(pc),12(a0)
            movea.l   a5,a0
            moveq.l   #9,d0
FILLOOP:    move.w    #1,(a0)+
            dbf       d0,FILLOOP
            move.w    #2,(a0)
            bsr       VDICALL               ;VDI initialisieren


;-----   Verhalten des Accessories wÑhrend der Anmeldung   -----

            movem.l   a5/a6,-(sp)
            bsr       ACC_RTM
            movem.l   (sp)+,a5/a6
            tst.l     d0
            bne.s     WAIT                  ;bei Fehler kann es ewig warten


;-----   Jetzt wird es ernst ...   -----

            move.w    #MENU_REGISTER,d0
            move.l    #$01010100,d1
            move.w    AP_ID(pc),(a5)
            move.l    #ACC_NAME,(a6)
            bsr       AESCALL               ;Accessory anmelden

;-----   Mitteilungen ausgeben   -----

            lea.l     ACC_MSGS(pc),a4

AMS_LOOP:   move.w    #FORM_ALERT,d0
            move.l    #$01010100,d1
            move.w    #1,(a5)
            move.l    (a4)+,(a6)
            beq.s     WAIT                  ;Ende der Mitteilungen
            bsr       AESCALL
            bra.s     AMS_LOOP

;-----   Warten, bis Accessory aktiviert wird   -----

WAIT:       move.w    #EVNT_MULTI,d0
            move.l    #$10070100,d1
            move.l    #EV_BUFF,(a6)

            move.w    #%110000,(a5)         ;Timer und Message
            move.w    ACCCLOW(pc),28(a5)
            move.w    ACCCHIGH(pc),30(a5)

            bsr       AESCALL               ;auf Ereignis warten

            btst      #4,d0
            beq.s     TST_EVT

            cmpi.w    #AC_OPEN,EV_BUFF
            beq.s     DO_ACC                ;kein Accessory gewÑhlt
TST_EVT:    
            btst      #5,d0
            bne.s     DO_ETIM               ;Timer-Event
            bra       WAIT

;-----  Aufruf eines Programmes, welches dann als Accessory lÑuft   -----

DO_ACC:     movem.l   a5/a6,-(sp)
            bsr       ACC_PGM
            movem.l   (sp)+,a5/a6

;-----   Ende des Accessories   -----

            bra.s     WAIT                  ;wieder warten


;-----   Aufruf bei Timer-Event   -----

DO_ETIM:    bsr       ACC_ETIM
            bra.s     WAIT                  ;wieder warten


;-----   Hilfsroutinen   -----

FEHLER:     clr.w     -(sp)
            trap      #GEMDOS


AESCALL:    lea.l     CONTRL(pc),a0
            move.w    d0,(a0)               ;Funktionsnummer eintragen
;            movep.l   d1,3(a0)              ;welch raffinierter Trick!!
            .DC.l $03c80003
            move.l    #AESPB,d1
            move.w    #AES,d0
            trap      #GEM
            move.w    INTOUT(pc),d0         ;RÅckgabewerte
            move.l    ADDROUT(pc),d1
            rts       


VDICALL:    move.l    #VDIPB,d1
            move.w    #VDI,d0
            trap      #GEM
            rts       


;-----   Daten   -----

            .DATA 

AESPB:      .DC.l CONTRL
            .DC.l GLOBAL
            .DC.l INTIN
            .DC.l INTOUT
            .DC.l ADDRIN
            .DC.l ADDROUT

VDIPB:      .DC.l CONTRL
            .DC.l INTIN
            .DC.l PTSIN
            .DC.l INTOUT
            .DC.l PTSOUT


;-----   Hilfsspeicher   -----

            .BSS 

CONTRL:     .DS.w 11
GLOBAL:     .DS.w 15
INTIN:      .DS.w 128
PTSIN:      .DS.w 128
INTOUT:     .DS.w 128
PTSOUT:     .DS.w 128
ADDRIN:     .DS.w 128
ADDROUT:    .DS.w 128

EV_BUFF:    .DS.b 16

AP_ID:      .DS.w 1

GRF_HAND:   .DS.w 1

            .DS.b 512
STACK:      


            .TEXT 



            .END 


