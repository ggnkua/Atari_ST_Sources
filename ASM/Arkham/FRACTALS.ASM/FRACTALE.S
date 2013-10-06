;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; essai de fractales (JULIA ou MANDELBROT) by TCHOOM/ARKHAM (C) 1993 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 opt o+

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

; init. des variables necessaires

 lea.l $1f8000,a0
 move.w #32768,d5		Numero de Pixel
 move.l #-16384,a2		Xc
 move.l #-10384,d3		Yc
 move.l a2,d2
init_loop
 cmpi.b #$b9,$fffffc02.w
 beq end
 move.l #31,a3			Profondeur 
 move.w #15*4,d4		Couleur
 move.l d2,d0			X0 puis Xn
 move.l d3,d1			Y0 puis Yn

; et c'est parti !!

loop
 move.w d0,d7			Xn.2^13
 muls.w d1,d7			(Xn*Yn).2^26
 swap d7
 rol.l #4,d7			(2*Xn*Yn).2^13
 add.w #5023,d7			Yn+1=(2*Xn*Yn+Yc).2^13

 muls.w d0,d0			(Xn^2).2^26
 muls.w d1,d1			(Yn^2).2^26
 move.l d0,d6			Transfere car carre utile pour test
 sub.l d1,d6			(Xn^2-Yn^2).2^26
 swap d6
 rol.l #3,d6			(Xn^2-Yn^2).2^13
 add.w #-5023,d6		(Xn^2-Yn^2+Xc).2^13

 add.l d1,d0			(Xn+1^2+Yn+1^2).2^26
 cmp.l #(4<<26),d0		Plus grand ou egal a 4 ??
 bhs.s loop2			Oui,on trace
 subq.w #4,d4			Non,decremente couleur
 bne.s ok_colors
 move.w #15*4,d4
ok_colors
 subq.l #1,a3
 cmpa.l #0,a3
 bne.s ok_a3
 moveq.w #0,d4
 bra.s loop2
ok_a3
 move.w d6,d0			Xn+1 devient Xn 
 move.w d7,d1 			Yn+1 devient Yn 
 bra.s loop

loop2 
 lea.l table,a1
 add.w d4,a1
 move.l (a1),a1
 jsr (a1)
 ror.w d5
 bcc.s no_add
 addq.l #8,a0
 cmp.l #$1f8000+200*$a0,a0
 bhs.s end
no_add
 
 addi.w #104,d2
 subq.w #1,x_data
 bne.s ok_xc
 move.w #320,x_data
 move.l a2,d2
 addi.w #104,d3
ok_xc
 bra init_loop

end
 move.w #7,-(sp)
 trap #1
 addq.l #2,sp 
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code pour trace des points de couleurs ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

colors0
 rts
colors1
 or.w d5,(a0)
 rts
colors2
 or.w d5,2(a0)
 rts
colors3
 or.w d5,(a0)
 or.w d5,2(a0)
 rts
colors4
 or.w d5,4(a0)
 rts
colors5
 or.w d5,(a0)
 or.w d5,4(a0)
 rts
colors6
 or.w d5,2(a0)
 or.w d5,4(a0)
 rts
colors7
 or.w d5,(a0)
 or.w d5,2(a0)
 or.w d5,4(a0)
 rts
colors8
 or.w d5,6(a0)
 rts
colors9
 or.w d5,(a0)
 or.w d5,6(a0)
 rts
colors10
 or.w d5,6(a0)
 or.w d5,2(a0)
 rts
colors11
 or.w d5,(a0)
 or.w d5,2(a0)
 or.w d5,6(a0)
 rts
colors12
 or.w d5,4(a0)
 or.w d5,6(a0)
 rts
colors13
 or.w d5,(a0)
 or.w d5,4(a0)
 or.w d5,6(a0)
 rts
colors14
 or.w d5,2(a0)
 or.w d5,4(a0)
 or.w d5,6(a0)
 rts
colors15
 or.w d5,(a0)
 or.w d5,2(a0)
 or.w d5,4(a0)
 or.w d5,6(a0)
 rts

;;;;;;;;;;;;;;;;
; section data ;
;;;;;;;;;;;;;;;;

table
 dc.l colors0,colors1,colors2,colors3,colors4,colors5,colors6,colors7
 dc.l colors8,colors9,colors10,colors11,colors12,colors13
 dc.l colors14,colors15

palette even
 dc.w $000,$100,$200,$300,$400,$500,$600,$700
 dc.w $700,$701,$602,$503,$403,$303,$203,$102


x_data	dc.w 320