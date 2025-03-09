;MAUSDRV 1.1, TSR
;erlaubt es, eine Microsoft-kompatible Maus an der Midi-Schnittstelle
;zu betreiben, und zwar gleichzeitig mit der Keyboardmaus. (Beide MÑuse
;beeinfluûen denselben Mauszeiger auf dem Bildschirm.)
;Martin Rogge, letzte énderung 30.11.93

cookiestring    equ "ncMR"
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
                dc.b "XBRAncMR" ;
old_midisys:    dc.l 0
midisys:        move.b  $FFFFFC04.w,d0
                btst    #7,d0
                beq.s   midi_end        ; Interrupt nicht von Midi-ACIA
                btst    #0,d0
                beq.s   midi_end        ; kein Zeichen vorhanden
                lea     header(pc),a0
                move.b  $FFFFFC06.w,d0  ; Midi Byte
                bpl.s   midi_end        ; bit 7 muû gesetzt sein
                btst    #6,d0
                bne.s   byte0           ; bit 6 gesetzt => Headerbyte
                move.b  3(a0),d1        ; temp
                bpl.s   byte2           ; temp wurde bereits verschoben
;
byte1:          lsl.b   #2,d0           ; Nutzdaten um Vorzeichen und Offset
                lsr.b   #1,d1           ; aus dem Header erweitern
                roxr.b  #1,d0
                lsr.b   #1,d1
                roxr.b  #1,d0
                move.b  d0,1(a0)        ; dx
                move.b  d1,3(a0)        ; temp
midi_end:       rts
;
byte0:          move.b  d0,3(a0)        ; Originalheader merken (in temp)
                lsr.b   #4,d0
                andi.b  #%11,d0         ; Maustasten Links-Rechts
                ori.b   #$F8,d0
                move.b  d0,(a0)
                rts
;
byte2:          lsl.b   #2,d0           ; Nutzdaten um Vorzeichen und Offset
                lsr.b   #1,d1           ; aus dem Header erweitern
                roxr.b  #1,d0
                lsr.b   #1,d1
                roxr.b  #1,d0
                move.b  d0,2(a0)        ; dy
send_packet:    movea.l mvecp(pc),a1
                movea.l (a1),a1
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
                movea.l d0,a0
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
                movea.l d0,a0
                move.l  old_midisys(pc),28(a0)
nodestall:      rts
;
                data
mvecp:          dc.l 0
header:         dc.b $F8
dx:             dc.b 0
dy:             dc.b 0
temp:           dc.b 0
;
cookiedata:     dc.b "v1.1"
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
                dc.b 27,"p","            MAUSDRV 1.1   TSR          ",27,"q"
                dc.b 13,10,"Ω Martin Rogge @ KI          30.11.1993",13,10,0
;
                end
