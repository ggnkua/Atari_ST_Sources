;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Catalogue d'une disquette ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 dc.w $a00a

 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$567,$ffff825e.w
 move.w #$777,$ffff8246.w

loop_cat
 bsr r_screen

 lea.l intro,a0
 jsr print

 pea $90000
 move.w #$1a,-(sp)
 trap #1
 addq.l #6,sp

 move.w #$0,-(sp)
 pea name
 move.w #$4e,-(sp)
 trap #1
 addq.l #8,sp

catalogue
 lea.l $9001e,a0
 jsr print
reg
 lea retour1,a0
 jsr print

 cmp.l #retour1,reg+2 
 bne.s no_ret1
 move.l #retour2,reg+2
 bra.s no_ret2
no_ret1
 move.l #retour1,reg+2
no_ret2

 move.w #$4f,-(sp)
 trap #1
 addq.l #2,sp
 tst.w d0
 beq.s catalogue

 lea.l fin_cat,a0
 jsr print

wkey
 cmpi.b #$1c,$fffffc02.w
 beq loop_cat
 cmpi.b #$b9,$fffffc02.w
 bne.s wkey
 rts

r_screen
 clr.w -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 rts

print
 pea (a0) 
 move.w #9,-(sp)
 trap #1
 addq.l #6,sp
 rts

intro 	dc.b "***** ",27,"p"," CATALOGUE DE LA DISQUETTE ",27,"q"," *****",10,10,13
	dc.b 27,"C",27,"C",27,"C",27,"C",0
name  	dc.b "*.*",0
retour1 dc.b "               ",9,8,8,8,8,8,8,8,8,8,8,8,8,0
retour2 dc.b 10,13
	dc.b 27,"C",27,"C",27,"C",27,"C",0
fin_cat	dc.b 10,10,13,"      Please insert other disk",0

