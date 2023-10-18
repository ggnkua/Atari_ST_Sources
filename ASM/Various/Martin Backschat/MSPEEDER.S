; EXPORT off_mspeeder,on_mspeeder
target          equ $0600

off_mspeeder:                           ; Mausbeschl. ausschalten
                movem.l d1-a6,-(sp)
                lea     deinit,a4
                bsr     call
                movem.l (sp)+,d1-a6
                rts
on_mspeeder:                            ;Mausbeschl. einschalten
                bsr     off_mspeeder
                movem.l d1-a6,-(sp)
                lea     init,a4
                bsr     call
                movem.l (sp)+,d1-a6
                rts

call:
                move.w  #34,-(sp)       ; Vektorliste von
                trap    #14             ; Tastaturproz.-
                movea.l d0,a3           ; Interrupts holen
                move.l  a4,-(sp)
                move.w  #38,-(sp)
                trap    #14
                addq.l  #8,sp
                rts
deinit:
                cmpi.l  #'TOSm',target+4
                bne     exit
                move.l  target+8,d0
                beq     exit
                move.l  d0,16(a3)
exit:
                clr.l   target+4
                rts

init:
                lea     start(pc),a0
                lea     end(pc),a1
                lea     target,a2
copyarea:
                move.w  (a0)+,(a2)+
                cmpa.l  a0,a1
                bne     copyarea
                movea.l 16(a3),a1       ; alter Mausvektor
                move.l  a1,target+8     ; alten Inhalt retten
                move.l  #target+12,16(a3) ; eigenen Mausvektor setzen
                rts                     ; fertig

start:
                dc.l 'XBRA','TOSm' ; FCopy MouseSpeeder
old:            dc.l 0
turbo:
                movem.l d0-d2/a0,-(sp)  ; benîtigte Register retten
                cmpi.b  #$f8,(a0)       ; ist es ein Mausinterrupt ?
                bcs     msend           ; nein
                cmpi.b  #$fc,(a0)+
                bcc     msend           ; nein

                move.b  (a0)+,d0        ; x-Bewegung
                move.b  (a0)+,d1        ; y-Bewegung
                cmpi.b  #2,d0
                bls.s   l01
                move.b  d0,d2
                bpl.s   l00
                neg.b   d2
l00:            mulu    d2,d0
l01:            cmpi.b  #2,d1
                bls.s   l03
                move.b  d1,d2
                bpl.s   l02
                neg.b   d2
l02:            mulu    d2,d1
l03:            move.b  d1,-(a0)        ; und Werte wieder zurÅckschreiben
                move.b  d0,-(a0)
msend:
                movem.l (sp)+,d0-d2/a0  ; Register wieder wiederherstellen
                move.l  old(pc),-(sp)
                rts
