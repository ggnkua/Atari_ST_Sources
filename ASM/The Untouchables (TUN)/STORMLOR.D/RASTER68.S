;
; Rasters without Timer B -using the HBL ($68.w)
; Code by Tony Bennett
; VERSION II of illusion.s
;
; Devpak v2.23         Tabs set to 10
;


	pea	xxx(pc)
	move	#38,-(sp)		;exec in super mode
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)		;exit
	trap	#1


*------------------
xxx	clr.b	$ffff8203.w	;set screen back (& clear)

	move.b	#$12,$fffffc02.w	;disable mouse

	move	#5,-(sp)		; disable #5 on MFP
	move	#26,-(sp)
	trap	#14
	addq.l	#4,sp

	move.l	$70.w,oldvbl	;save the old vbl
	move.l	$68.w,oldhbl	;save the old hbl

	move.l	#vbl,$70.w	;install vbl
	move.l	#hbl,$68.w	;install hbl
	move	#$2100,sr		; set int. level

scan:	cmp.b	#$39,$fffffc02.w	;check ikbd for space bar?
	bne.s	scan

	move.l	oldhbl,$68.w	;install old hbl
	move.l	oldvbl,$70.w	;install old vbl

	move	#5,-(sp)		; enable #5 interrupt
	move	#27,-(sp)
	trap	#14
	addq.l	#4,sp
	
	move.b	#8,$fffffc02.w	;enable mouse
	move	#$777,$ffff8240.w	;border=white

	rts			;user mode


*------------------
hbl:	dcb.w	88,$4e71		;synchronize
	move.l	a0,-(sp)		;save a0
	move.l	offset(pc),a0	;get offset into color palette
	move	(a0)+,$ffff8240.w	;next color -> next scanline
	move.l	a0,offset		;store next color
	move.l	(sp)+,a0		;put back a0
	rte			;end HBL


vbl:	move.l	#pal,offset	;reload palette

skip2	cmp	#$ff,which_way	;are we going up or down?
	beq.s	skip
	addq.l	#2,counter	;increment counter
	cmp.l	#588,counter	;check for end of palette
	bne.s	nope		;are we there yet?

	move	#$ff,which_way	;change direction
	bra.s	skip

nope	move.l	counter(pc),d0	;get value in 'counter' and use it
	add.l	d0,offset		;as an offset into the color table.
	rte

skip	tst	which_way		;which way?
	beq.s	skip2
	subq.l	#4,counter	;going down...
	tst.l	counter		;are we at bottom?
	bne.s	nope
	
	clr	which_way		;change direction
	rte

*------------------
	section	data
counter	dc.l	0
offset	dc.l	0
which_way	dc.w	0
oldhbl	dc.l	0
oldvbl	dc.l	0

; the palette must contain at least twice the amount which can be
; displayed on the screen at any one time.....!!

pal	*ds.w	310	<-----Try removing the *
	dc.w	5,5,5,5			;1
	dc.w	5,6,5,6
	dc.w	6,6,6,6
	dc.w	7,6,7,7
	dc.w	7,7,7,$107
	dc.w	7,$107,$107,$107
	dc.w	$107,$107,$207,$107
	dc.w	$207,$207,$207,$207
	dc.w	$207,$307,$207,$307
	dc.w	$307,$307,$307,$307
	dc.w	$407,$307,$407,$407
	dc.w	$407,$407,$407,$507
	dc.w	$407,$507,$507,$507
	dc.w	$507,$507,$607,$507
	dc.w	$607,$607,$607,$607
	dc.w	$607,$707,$607,$707
	dc.w	$707,$707,$707,$707
	dc.w	$706,$707,$706,$706
	dc.w	$706,$706,$706,$705
	dc.w	$706,$705,$705,$705
	dc.w	$705,$705,$704,$705
	dc.w	$704,$704,$704,$704
	dc.w	$704,$703,$704,$703
	dc.w	$703,$703,$703,$703
	dc.w	$702,$703,$702,$702
	dc.w	$702,$702,$702,$701
	dc.w	$702,$701,$701,$701
	dc.w	$701,$701,$700,$701
	dc.w	$700,$700,$700,$700
	dc.w	$700,$710,$700,$710
	dc.w	$710,$710,$710,$710
	dc.w	$720,$710,$720,$720
	dc.w	$720,$720,$720,$730
	dc.w	$720,$730,$730,$730
	dc.w	$730,$730,$740,$730
	dc.w	$740,$740,$740,$740
	dc.w	$740,$750,$740,$750
	dc.w	$750,$750,$750,$750
	dc.w	$760,$750,$760,$760
	dc.w	$760,$760,$760,$770
	dc.w	$760,$770,$770,$770
	dc.w	$770,$770
*------------------				;2
	dc.w	$760,$770,$770,$770
	dc.w	$760,$760,$760,$770
	dc.w	$760,$750,$760,$760
	dc.w	$750,$750,$750,$750
	dc.w	$740,$750,$740,$750
	dc.w	$740,$740,$740,$740
	dc.w	$730,$730,$740,$730
	dc.w	$720,$730,$730,$730
	dc.w	$720,$720,$720,$730
	dc.w	$720,$710,$720,$720
	dc.w	$710,$710,$710,$710
	dc.w	$700,$710,$700,$710
	dc.w	$700,$700,$700,$700
	dc.w	$701,$701,$700,$701
	dc.w	$702,$701,$700,$701
	dc.w	$702,$702,$702,$701
	dc.w	$702,$703,$702,$702
	dc.w	$703,$703,$703,$703
	dc.w	$704,$703,$704,$703
	dc.w	$704,$704,$704,$704
	dc.w	$705,$705,$704,$705
	dc.w	$706,$705,$705,$705
	dc.w	$706,$706,$706,$705
	dc.w	$706,$707,$706,$706
	dc.w	$707,$707,$707,$707
	dc.w	$607,$707,$607,$707
	dc.w	$607,$607,$607,$607
	dc.w	$507,$507,$607,$507
	dc.w	$407,$507,$607,$507
	dc.w	$407,$407,$407,$507
	dc.w	$407,$307,$407,$407
	dc.w	$307,$307,$307,$307
	dc.w	$207,$307,$207,$307
	dc.w	$207,$207,$207,$207
	dc.w	$207,$207,$107,$207
	dc.w	7,$107,$107,$107
	dc.w	7,7,7,$107
*------------------				;3
	dc.w	7,$107,$107,$107
	dc.w	$107,$107,$207,$107
	dc.w	$207,$207,$207,$207
	dc.w	$207,$307,$207,$307
	dc.w	$307,$307,$307,$307
	dc.w	$407,$307,$407,$407
	dc.w	$407,$407,$407,$507
	dc.w	$407,$507,$507,$507
	dc.w	$507,$507,$607,$507
	dc.w	$607,$607,$607,$607
	dc.w	$607,$707,$607,$707
	dc.w	$707,$707,$707,$707
	dc.w	$706,$707,$706,$706
	dc.w	$706,$706,$706,$705
	dc.w	$706,$705,$705,$705
	dc.w	$705,$705,$704,$705
	dc.w	$704,$704,$704,$704
	dc.w	$704,$703,$704,$703
	dc.w	$703,$703,$703,$703
	dc.w	$702,$703,$702,$702
	dc.w	$702,$702,$702,$701
	dc.w	$702,$701,$701,$701
	dc.w	$701,$701,$700,$701
	dc.w	$700,$700,$700,$700
	dc.w	$700,$710,$700,$710
	dc.w	$710,$710,$710,$710
	dc.w	$720,$710,$720,$720
	dc.w	$720,$720,$720,$730
	dc.w	$720,$730,$730,$730
	dc.w	$730,$730,$740,$730
	dc.w	$740,$740,$740,$740
	dc.w	$740,$750,$740,$750
	dc.w	$750,$750,$750,$750
	dc.w	$760,$750,$760,$760
	dc.w	$760,$760,$760,$770
	dc.w	$760,$770,$770,$770
	dc.w	$770,$770
*------------------				;4
	dc.w	$760,$770,$770,$770
	dc.w	$760,$760,$760,$770
	dc.w	$760,$750,$760,$760
	dc.w	$750,$750,$750,$750
	dc.w	$740,$750,$740,$750
	dc.w	$740,$740,$740,$740
	dc.w	$730,$730,$740,$730
	dc.w	$720,$730,$730,$730
	dc.w	$720,$720,$720,$730
	dc.w	$720,$710,$720,$720
	dc.w	$710,$710,$710,$710
	dc.w	$700,$710,$700,$710
	dc.w	$700,$700,$700,$700
	dc.w	$701,$701,$700,$701
	dc.w	$702,$701,$700,$701
	dc.w	$702,$702,$702,$701
	dc.w	$702,$703,$702,$702
	dc.w	$703,$703,$703,$703
	dc.w	$704,$703,$704,$703
	dc.w	$704,$704,$704,$704
	dc.w	$705,$705,$704,$705
	dc.w	$706,$705,$705,$705
	dc.w	$706,$706,$706,$705
	dc.w	$706,$707,$706,$706
	dc.w	$707,$707,$707,$707
	dc.w	$607,$707,$607,$707
	dc.w	$607,$607,$607,$607
	dc.w	$507,$507,$607,$507
	dc.w	$407,$507,$607,$507
	dc.w	$407,$407,$407,$507
	dc.w	$407,$307,$407,$407
	dc.w	$307,$307,$307,$307
	dc.w	$207,$307,$207,$307
	dc.w	$207,$207,$207,$207
	dc.w	$207,$207,$107,$207
	dc.w	7,$107,$107,$107
	dc.w	7,7,7,$107
	dc.w	7,6,7,7
	dc.w	6,6,6,6
	dc.w	5,6,5,6

