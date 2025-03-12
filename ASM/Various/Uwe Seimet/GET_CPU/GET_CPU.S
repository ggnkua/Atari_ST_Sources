*************************************
*               GET_CPU             *
*                                   *
* Identifizierung des Prozessortyps *
*     (c) MAXON Computer GmbH       *
*     Januar 1991 by Uwe Seimet     *
*************************************


SETEXC  = 5
BIOS    = 13


SUPEXEC = 38
XBIOS   = 14


        text

*Dieses Unterprogramm liefert in D7 Angaben
*ber den Prozessor ($00, $10, $20, $30)
get_cpu:
        pea newpriv(pc)     ;neuer Vektor
        move #8,-(sp)       ;fr Privileg-
        move #SETEXC,-(sp)  ;verletzung
        trap #BIOS
        addq.l #8,sp
        move.l d0,d5

*auf 68000-prfen

        move sr,d0          ;Exception,
                            ;falls kein 68000
        moveq #$00,d7       ;Flag fr 68000
        bra.b exit

*auf 68010 prfen

newpriv:
        or #$0300,sr        ;zurck in
                            ;Usermodus
        moveq #$10,d7       ;Flag fr 68010
        moveq #1,d0
        lea table,a0
        tst.b (0,a0,d0*4)
        bne.b exit          ;68010 erkannt-

*auf 68020 prfen

        pea testmmu(pc)
        move #SUPEXEC,-(sp)
        trap #XBIOS         ;auf PMMU testen
        addq.l #6,sp
        move mmureg,d7      ;Prozessortyp

exit:   move.l d5,-(sp)     ;alten Vektor
        move #8,-(sp)       ;wiederherstellen
        move #SETEXC,-(sp)
        trap #BIOS
        addq.l #8,sp

*D7 enth„lt nun den Prozessortyp
*($00, $10, $20, $30) im low word

         rts


*auf externe PMMU oder 68030 testen
testmmu:
        move.l $02c,d0      ;LINEF-Vektor
        move.l #linef,$02c
        moveq #$20,d7       ;Flag fr 68020
        pmove crp,mmureg    ;Exception,
                            ;falls keine PMMU
                            ;=> 68020
        pmovefd mmureg,crp  ;Exception,
                            ;falls kein 68030
                            ;sondern PMMU
                            ;=> 68020

*sonst 68030

        moveq #$30,d7

linef:  move.l d0,$02c      ;alter Vektor
        move d7,mmureg      ;Prozessor merken
        rts


*Hilfstabelle
table:  dc.b 0,0,0,1,0,0,0,0


        bss

mmureg: ds.l 2


