;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; routine de face personnelle ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

; rempli ligne de l'ecran suivant x1 et x2

 lea.l $1f8000,a0
 move.w #5,d0
 move.w #5,d1

 move.w d1,d2
 sub.w d0,d2		Dx
 lsr.w #4,d2
 beq one_word	 	Cas particulier:X1 et X2 sont ds le meme mot !
 add.w d2,d2
 add.w d2,d2
 lea.l fill_line,a1
 add.w d2,a1
 move.l (a1),r_rts+2
 move.l a1,r_rts+6
 move.w #$8550,(a1)+	Pose or.w d2,(a0)
 move.w #$4e75,(a1)	Pose RTS

 lea.l pix_debut,a1
 add.w d0,d0 
 add.w d0,d0
 add.w d0,a1
 add.w (a1)+,a0		Adresse ecran au mot pres !
 move.w (a1),d0		Mot de depart

 lea.l pix_fin,a1
 add.w d1,d1
 add.w d1,a1
 move.w (a1),d2		Mot de fin

 move.w #$ffff,d1
 jsr fill_line		 
r_rts move.l #0,fill_line
suite

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$225,$ffff8240.w
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
; code pour remplir une ligne ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

one_word			; cas particulier
 lea.l pix_debut,a1
 add.w d0,d0 
 add.w d0,d0
 add.w d0,a1
 add.w (a1)+,a0		Adresse ecran au mot pres !
 move.w (a1),d0		Mot de depart
 lea.l pix_fin,a1
 add.w d1,d1
 add.w d1,a1	
 and.w (a1),d0		Mot de fin
 or.w d0,(a0)
 bra.s suite

fill_line
 or.w d0,(a0)			; 4 octets de code
 addq.w #8,a0			; pour remplir un mot
 rept 19
 move.w d1,(a0)			; idem !
 addq.w #8,a0
 endr
 rts

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

pix_debut 
n set 0
 rept 20
 dc.w n,$ffff,n,32767,n,16383,n,8191
 dc.w n,4095,n,2047,n,1023,n,511,n,255
 dc.w n,127,n,63,n,31,n,15,n,7,n,3,n,1
n set n+8
 endr

pix_fin
 rept 20
 dc.w 32768,49152,57344,61440
 dc.w 63488,64512,65024,65280
 dc.w 65408,65472,65504,65520
 dc.w 65528,65532,65534,65535
 endr