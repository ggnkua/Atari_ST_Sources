;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FRACTALES JULIA ET MANDELBROT BY TCHOOM/ARKHAM  (c) 1993 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a00a
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

 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l #cycle,$4d2

 lea.l frac_table,a0
slide
 move.w (a0)+,Xz+2
 move.w (a0)+,Yz+2
 move.w (a0)+,D_Xz+2
 move.w (a0)+,D_Yz+2
 move.w (a0)+,Xc+2	
 move.w (a0)+,Yc+2
 move.w (a0)+,D_Xc+2
 move.w (a0)+,D_Yc+2
 move.w (a0)+,deept+2
 pea (a0)
 bsr fractale
 move.w #150,d7
att_vbl move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 cmpi.b #$b9,$fffffc02.w
 beq end
 dbf d7,att_vbl
 move.l (sp)+,a0
 cmp.w #$ffff,(a0)
 bne.s slide
 lea.l frac_table,a0
 bra.s slide

end
 clr.l $4d2
 cmpi.b #$b9,$fffffc02.w
 bne.s end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

cycle
 subq.w #1,compt
 bne.s cycle2
 move.w #4,compt
 movem.l $ffff8242.w,d0-d6
 move.w $ffff825e.w,d7
 movem.l d0-d6,$ffff8244.w
 move.w d7,$ffff8242.w
cycle2
 rts


;;;;;;;;;;;;;;;;;;;;
; DESSINE FRACTALE ;
;;;;;;;;;;;;;;;;;;;;

fractale
 move.w #320,x_data
 lea.l $1f8000,a0
 clr.l (a0)
 clr.l 4(a0)              
 move.w #32768,d5		Numero de Pixel
 move.w Xc+2,r_Xc+2
 move.w Xz+2,r_Xz+2
init_loop
deept move.w #0,d2		
Xz move.w #0,d0			
Yz move.w #0,d1			
 move.w #15*4,d4		

 cmpi.b #$b9,$fffffc02.w
 beq end

; et c'est parti !!

loop
 move.w d0,d7			Xn.2^13
 muls.w d1,d7			(Xn*Yn).2^26
 swap d7
 rol.l #4,d7			(2*Xn*Yn).2^13
Yc add.w #0,d7			Yn+1=(2*Xn*Yn+Yc).2^13

 muls.w d0,d0			(Xn^2).2^26
 muls.w d1,d1			(Yn^2).2^26
 move.l d0,d6			Transfere car carre utile pour test
 sub.l d1,d6			(Xn^2-Yn^2).2^26
 swap d6
 rol.l #3,d6			(Xn^2-Yn^2).2^13
Xc add.w #0,d6			(Xn^2-Yn^2+Xc).2^13

 add.l d1,d0			(Xn+1^2+Yn+1^2).2^26
 cmp.l #(4<<26),d0		Plus grand ou egal a 4 ??
 bhs.s loop2			Oui,on trace
 subq.w #4,d4			Non,decremente couleur
 bne.s ok_colors
 move.w #15*4,d4
ok_colors
 subq.w #1,d2
 bne.s ok_d2
 moveq.w #0,d4
 bra.s loop2
ok_d2
 move.w d6,d0			Xn+1 devient Xn 
 move.w d7,d1 			Yn+1 devient Yn 
 bra.s loop

loop2 
 lea.l table,a1
 move.l (a1,d4.w),a1
 jsr (a1)
 ror.w d5
 bcc.s no_add
 addq.l #8,a0
 clr.l (a0)
 clr.l 4(a0)
 cmp.l #$1f8000+200*$a0,a0
 blo.s no_add
 rts
no_add

; incremente Xc et Xz
 
D_Xc add.w #0,Xc+2
D_Xz add.w #0,Xz+2

 subq.w #1,x_data
 bne.s ok_xc_z
 move.w #320,x_data

r_Xc move.w #0,Xc+2
D_Yc add.w #0,Yc+2

r_Xz move.w #0,Xz+2
D_Yz add.w #0,Yz+2

ok_xc_z

 bra init_loop

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

table 	dc.l colors0,colors1,colors2,colors3,colors4,colors5,colors6,colors7
	dc.l colors8,colors9,colors10,colors11,colors12,colors13
	dc.l colors14,colors15
palette dc.w $000,$100,$200,$300,$400,$500,$600,$700
	dc.w $700,$701,$602,$503,$403,$303,$203,$102
x_data	dc.w 320

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATAS DES DIFFERENTES FRACTALES ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; info:MANDELBROT commence avec 0,0,0,0

frac_table
 dc.w 0,0,0,0,-16384,-10384,95,104,25		; espace mandelbrot
 dc.w -16384,-10384,104,104,-5023,5023,0,0,31	; espace julia
 dc.w 0,0,0,0,2700,4000,1,1,60			; zoom mandelbrot
 dc.w 3384,-4384,4,5,-5023,5023,0,0,40		; zoom julia
 dc.w $ffff

compt dc.w 1
