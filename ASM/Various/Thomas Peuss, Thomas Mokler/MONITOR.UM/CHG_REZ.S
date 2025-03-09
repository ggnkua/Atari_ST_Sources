*********************************************************************
*                                                                   *
*  MONITORUMSCHALTACCESSORY  V1.1                         *
*                                                           *
*  by Thomas Mokler Thomas Peuss                      *
*                                                               *
*  (c) MAXON Computer 1991             *
*                                                                   *
*********************************************************************
resvector:      EQU $042A
resvalid:       EQU $0426
                TEXT
        lea stack(PC),SP ;jedem Acc sein Stack

        lea contrl(PC),A0 ;Accessory als Application anmelden
        move.w #10,(A0)
        move.w #0,2(A0)
        move.w #1,4(A0)
        move.l #0,6(A0)
        bsr aes
        move.w intout(PC),appid ;Applicationskennung sichern

        lea addrin,A2
        lea contrl(PC),A0 ;Accessory in MenÅleiste eintragen
        move.w #35,(A0)
        move.w #1,2(A0)
        move.w #1,4(A0)
        move.w #1,6(A0)
        move.w #0,8(A0)
        lea intin(PC),A1
        move.w appid(PC),(A1)
        lea accname(PC),A1
        move.l A1,(A2)
        bsr aes
        move.w intout(PC),accid ;Accessorykennung sichern

loop:   lea msgbuff(PC),A1
        lea addrin(PC),A2
        lea contrl(PC),A0 ;auf Ereignis warten
        move.w #23,(A0)
        move.w #0,2(A0)
        move.w #1,4(A0)
        move.w #1,6(A0)
        move.w #0,8(A0)
        move.l A1,(A2)
        bsr aes
        lea msgbuff(PC),A1
        cmpi.w #40,(A1)
        beq.s main
        bne.s loop

main:   lea txt(PC),A1
        bsr form_alert
        cmp.w #2,D5
        bne.s loop

        move.w #4,-(SP)
        trap #14
        addq.l #2,SP
        cmp.w #2,D0
        bne.s mono

color:
        move.l #0,-(SP)
        move.w #$20,-(SP)
        trap #1
        addq.l #6,SP
        lea oldsp(PC),A0
        move.l D0,(A0)
        lea oldmagic(PC),A0
        lea oldres(PC),A1
        move.l resvalid,(A0)
        move.l resvector,(A1)
        move.l #$31415926,resvalid
        move.l #rst,resvector

        move.l oldsp(PC),-(SP)
        move.w #$20,-(SP)
        trap #1
        addq.l #6,SP

        move.w #64,-(SP)
        move.w #$1E,-(SP)
        trap #14
        addq.l #4,SP
        bra.s wait


mono:   move.w #191,-(SP)
        move.w #$1D,-(SP)
        trap #14
        addq.l #4,SP

wait:   move.l #$0FFFFF,D0
wait_loop:
        nop
        dbra D0,wait_loop

        move.l #0,-(SP)
        move.w #$20,-(SP)
        trap #1
        addq.l #6,SP
        lea oldsp(PC),A0
        move.l D0,(A0)

        bsr.s resback

        move.l oldsp(PC),-(SP)
        move.w #$20,-(SP)
        trap #1
        addq.l #6,SP

quit:   lea msg(PC),A1
        bsr.s form_alert
        bra loop

form_alert:
        lea contrl(PC),A0
        move.w #52,(A0)
        move.w #1,2(A0)
        move.w #1,4(A0)
        move.w #1,6(A0)
        move.w #0,8(A0)
        move.w #1,intin
        move.l A1,addrin
        bsr.s aes
        move.w intout(PC),D5
        rts

resback:move.l oldres(PC),resvector
        move.l oldmagic(PC),resvalid
        rts

aes:    move.l #aespb,D1
        move.w #$C8,D0
        trap #2
        rts

rst:    move.w #0,-(SP)
        move.l #-1,-(SP)
        move.l #-1,-(SP)
        move.w #5,-(SP)
        trap #1
        lea $0C(SP),SP
        bsr.s resback
        lea -$7800,A0
        move.b #7,(A0)
        move.b #$C0,2(A0)
        move.b #$0E,(A0)
        move.b #$47,2(A0)
        move.b $FC0003,D0
        ext.w D0
        lea tabelle,A0
        adda.w 0(A0,D0.w),A6
        lea oldmagic(PC),A0
        cmpi.l #$31415926,(A0)
        beq.s another
        jmp (A6)
another:movea.l oldres,A1
        jmp (A1)

                DATA
tabelle:        DC.W 62,62,68
msg:            DC.B "[1][Monitorumschaltbox|nicht angeschlossen|oder abgeschaltet ? ]"
                DC.B "[Abbruch]",0,0
accname:        DC.B '  neuer Monitor',0 ;ACCESSORYNAME
txt:            DC.B '[2][    (C) 1990 by T. Mokler|       und T. Peuû | |Auflôsung wirklich wechseln ? ]'
                DC.B '[Nein|Ja]',0
                EVEN
aespb:          DC.L contrl,global,intin,intout,addrin,addrout
                BSS
oldsp:          DS.L 1
oldmagic:       DS.L 1
oldres:         DS.L 1
appid:          DS.W 1
accid:          DS.W 1
msgbuff:        DS.B 16
contrl:         DS.W 1          ;AES
                DS.W 1          ;INTIN
                DS.W 1          ;INTOUT
                DS.W 1          ;ADDRIN
                DS.W 1          ;ADDROUT
global:         DS.W 15
intin:          DS.W 2          ;WORT-EINGABEN
intout:         DS.W 2          ;WORT-AUSGABEN
addrin:         DS.L 2          ;ADR.-EINGABEN
addrout:        DS.L 2          ;ADR.-AUSGEBEN
                DS.L 25         ;STAPEL
stack:          END



