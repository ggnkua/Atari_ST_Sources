;;;;;;;;;;;;;;;;;;;;;
; editeur de sample ;
;;;;;;;;;;;;;;;;;;;;;

 dc.w $a00a
 dc.w $a000
 suba.l #602,a0
 move.l a0,coord_mouse

; precalcule positions de la souris

 lea.l souris,a1
 moveq.w #15,d0
pre_pos
 lea.l fleche,a0
 move.w #15,d1
pre_pos2
 move.l (a0),(a1)+
 move.l 4(a0),(a1)+
 roxr.w (a0)
 roxr.w 4(a0)
 roxr.w 2(a0)
 roxr.w 6(a0)
 addq.l #8,a0
 dbf d1,pre_pos2
 dbf d0,pre_pos

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 lea.l neo+128,a0
 lea.l $1f8000,a1
 move.w #7999,d0
aff_ecr
 move.l (a0)+,(a1)+
 dbf d0,aff_ecr

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancienne souris

 move.l old_mouse,a0
 moveq.l #0,d0
n set 0
 rept 15
 move.l d0,n(a0)
 move.l d0,n+8(a0)
n set n+$a0
 endr

; gestion de la souris

 move.l coord_mouse,a0
 move.w (a0)+,d0		X mouse
 move.w (a0),d1			Y mouse

 cmpi.w #319-16,d0			Clipping
 blo.s no_bleme
 move.w #319-16,d0
 move.w d0,-(a0)
no_bleme

 lea.l $1f8000+4,a1

 mulu.w #160,d1
 add.w d1,a1

 move.w d0,d1
 divu.w #2,d0
 andi.w #$ffff-7,d0
 add.w d0,a1
 move.l a1,old_mouse
 divu.w #8,d0
 mulu.w #16,d0
 sub.w d0,d1
 mulu.w #8*16,d1
 lea.l souris,a0
 add.w d1,a0

n set 0
 rept 15
 move.l (a0)+,n(a1)
 move.l (a0)+,n+8(a1)
n set n+$a0
 endr

; test des boutons de la souris

 bsr test_button
 btst #0,d0
 bne.s left_push

fin_prog
 bra prog

test_button
 move.l coord_mouse,a0
 addq.l #6,a0
 move.w (a0),d0
 rts

left_push
 move.l old_mouse,a0
 subq.w #4,a0
 jsr invert

wait_left
 bsr test_button
 btst #0,d0
 bne.s wait_left

 move.l old_mouse,a0
 subq.w #4,a0
 jsr invert
 bra fin_prog

invert
 moveq.w #15,d1
invert2 not.l (a0)
 not.l 8(a0)
 not.l 16(a0)
 lea.l $a0(a0),a0
 dbf d1,invert2
 rts
 


 bra fin_prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

palette
 dc.w $000,$111,$333,$555
 dc.w $020,$020,$020,$020
 dc.w $040,$040,$040,$040
 dc.w $060,$060,$060,$060

souris	ds.l 512
coord_mouse dc.l 0
old_mouse   dc.l $1f8004
neo incbin shit.neo 
fleche incbin fleche.dat

                                                                                                                  