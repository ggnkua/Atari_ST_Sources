;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3D FACE PLEINE AVEC ROUTINE DE FACES SYSTEMES ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a000
 move.l a0,line_a
 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 pea 0.w
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2
 clr.w $ffff8240.w
 move.w #$707,$ffff8242.w
 move.w #$777,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; trace une face

 move.w #0,d7
trace
 move.w #0,d0
 move.w #0,d1
 move.w #50,d2
 move.w #50,d3
 movem.l d0-d3,-(sp)
 bsr face
 movem.l (sp)+,d0-d3
 addq.w #1,d7
 cmp.w #50,d7
 bne.s trace

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$200,$ffff8240.w
no_shift
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de tracage de faces ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

face
 move.l line_a,a0
 move.l 12(a0),a1
 move.w d0,(a1)+		X1
 move.w d1,(a1)+		Y1
 move.w d2,(a1)+		X2
 move.w d1,(a1)+		Y2
 move.w d2,(a1)+		X3
 move.w d3,(a1)+		Y3
 move.w d0,(a1)+		X4
 move.w d3,(a1)+		Y4
 move.w d0,(a1)+		X1
 move.w d1,(a1)+		Y1
 move.l 4(a0),a1		
 move.w #4,2(a1)		Carre
 move.w d7,40(a1)		Ligne a remplir
 lea.l 24(a0),a1
 move.w #1,(a1)+		Valeur de chaques plans
 move.w #0,(a1)+
 move.w #0,(a1)+
 move.w #0,(a1)
 lea.l 36(a0),a1
 move.w #0,(a1)			Mode d'ecriture
 lea.l 46(a0),a1
 move.l #style,(a1)+
 move.w #3,(a1)+
 lea.l 54(a0),a1
 move.w #1,(a1)+
 move.w #0,(a1)+
 move.w #0,(a1)+
 move.w #319,(a1)+
 move.w #199,(a1)+
 dc.w $a006			Go !
 rts

line_a		ds.l 1
style		dc.w $5555,$5555,$5555,$5555

