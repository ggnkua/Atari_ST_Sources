;MAUSDRV 1.1, TSR
;erlaubt es, eine Microsoft-kompatible Maus an der Midi-Schnittstelle
;zu betreiben, und zwar gleichzeitig mit der Keyboardmaus. (Beide MÑuse
;beeinfluûen denselben Mauszeiger auf dem Bildschirm.)
;Martin Rogge, letzte énderung 30.11.93
;
;MAUSDRV 3.0. TSR
;Anpassung an das MouseSystems-Protokoll
;Martin Rogge, 26.5.95

cookiestring    = "ncMR"
;
;
                move.l  4(sp),a0        ; Basepageadresse holen
                move.l  #$0100,d1       ; BasepagelÑnge
                add.l   $0C(a0),d1      ; +TextlÑnge
                add.l   $14(a0),d1      ; +DatenlÑnge
                move.l  $1C(a0),d7      ; +BSS-lÑnge
                add.l   d7,d1
                move.l  d1,termlen
                add.l   a0,d1
                move.l  d1,bssend
;
                pea     cook(pc)
                move.w  #38,-(sp)       ; Supexec()
                trap    #14
                addq.l  #6,sp
                tst.w   retcode
                beq.s   weiter
                move.w  #-1,-(sp)
                move.w  #76,-(sp)       ; Pterm()
                trap    #1
;
weiter:         pea     text(pc)
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp
                bsr     install
;
                move.w  #0,-(sp)
                move.l  termlen(pc),-(sp)
                move.w  #49,-(sp)       ; Ptermres()
                trap    #1
;
cook:           move.l  $05A0.w,a0
                move.l  a0,d0
                beq.s   fehler          ; cookie jar ist nicht vorhanden
;
                move.l  a0,a1
                moveq   #1,d2
                bra.s   schlunz2
schlunz:        addq.l  #8,a1
                addq.l  #1,d2           ; ZÑhler der tatsÑchlichen EintrÑge
schlunz2:       cmp.l   #cookiestring,(a1)
                beq.s   fehler         ; Treiber schon installiert
                tst.l   (a1)
                bne.s   schlunz         ; nicht letzter Eintrag im jar
                move.l  4(a1),d0        ; LÑnge des jars
                cmp.l   d2,d0
                bls.s   fehler          ; kein Platz im cookie jar
;
cookend:        move.l  #cookiestring,(a1)+
                move.l  #cookiedata,(a1)+
                clr.l   (a1)+
                move.l  d0,(a1)
                clr.w   retcode
                rts
;
fehler:         st      retcode
                rts
;
                dc.b    "XBRAncMR" ;
old_midisys:    dc.l 0
midisys:        move.b  $FFFFFC04.w,d0
                btst    #7,d0
                beq.s   byte0_end       ; Interrupt nicht von Midi-ACIA
                btst    #0,d0
                beq.s   byte0_end       ; kein Zeichen vorhanden
                lea     header(pc),a0
                move.w  4(a0),d0
                lea     jumptable(pc),a1
                move.l  (a1,d0.w),a1
                move.b  $FFFFFC06.w,d0  ; Midi Byte
                jmp     (a1)
;
byte0:          move.b  d0,d1
                and.b   #$F0,d1
                cmp.b   #$80,d1
                bne.s   byte0_end
                and.w   #7,d0
                lea     headertable(pc),a1
                move.b  (a1,d0.w),(a0)
                move.w  #4,4(a0)
byte0_end:      rts
;
byte1:          move.b  d0,1(a0)
                move.w  #8,4(a0)
                rts
;
byte2:          neg.b   d0
                move.b  d0,2(a0)
                move.w  #12,4(a0)
                move.l  mvecp(pc),a1
                move.l  (a1),a1
                jmp     (a1)            ; durch den Mausvektor springen
;
byte3:          move.b  d0,1(a0)
                move.w  #16,4(a0)
                rts
;
byte4:          neg.b   d0
                move.b  d0,2(a0)
                clr.w   4(a0)
                move.l  mvecp(pc),a1
                move.l  (a1),a1
                jmp     (a1)            ; durch den Mausvektor springen
;
install:        ; zum Setzen der Baudrate entkommentieren 
;                move.w  #-1,-(sp)
;                move.w  #-1,-(sp)
;                move.w  #-1,-(sp)
;                move.w  #%10001000,-(sp)
;                clr.w   -(sp)
;                move.w  #7,-(sp)        ; #7 fÅr 1200 Baud
;                move.w  #15,-(sp)       ; Rsconf()
;                trap    #14
;                lea     14(sp),sp
;
                bset    #7,state
                bne.s   noinstall       ; schon aktiv
                move.w  #34,-(sp)       ; Kbdvbase()
                trap    #14
                addq.l  #2,sp
                move.l d0,a0
                move.l  28(a0),old_midisys
                move.l  #midisys,28(a0)
                lea     16(a0),a0
                move.l  a0,mvecp
noinstall:      rts
;
destall:        bclr    #7,state
                beq.s   nodestall       ; nicht aktiv
                move.w  #34,-(sp)       ; Kbdvbase()
                trap    #14
                addq.l  #2,sp
                move.l d0,a0
                move.l  old_midisys(pc),28(a0)
nodestall:      rts
;
mvecp:          dc.l 0
header:         dc.b 0
dx:             dc.b 0
dy:             dc.b 0,0
nr:             dc.w 0
;
headertable:    dc.b $FB,$FB,$FB,$FA,$FB,$FB,$F9,$F8
jumptable:      dc.l byte0,byte1,byte2,byte3,byte4
;
cookiedata:     dc.b "v3.0"
installp:       dc.l install
destallp:       dc.l destall
                dc.l midisys
state:          dc.w 0
;
retcode:        dc.w 0
termlen:        dc.l 0
bssend:         dc.l 0
;
text:           dc.b 13,10
                dc.b 27,"p","            MAUSDRV 3.0   TSR          ",27,"q"
                dc.b 13,10,"Ω Martin Rogge @ KI          26.05.1995",13,10,0
;
;

