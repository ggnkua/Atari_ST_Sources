
	include a:\util.lib
	
	supervis	#0
	
	setscreen	#0,#$70000,#$70000
	loadpal	palette
	clr.b	$484.w
	cmp.b	#$1d,$fffffc02.w	key control
	bne.s	loading
	print	txt_code
	pea	buffer
	move.w	#$0a,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	buffer+2,a0
	lea	code,a1
loop	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bne.s	loading
	cmp.l	#end_code,a1
	bne.s	loop
	move.l	#"O.K.",$200.w
	print	good_code
wait2	getkey
	cmp.b	#" ",d0
	bne.s	wait2
loading	print	txt_intro
	jsr	decomp_pic
wait	getkey
	cmp.b	#" ",d0
	bne.s	wait
	loadpal	pic+2
	setscreen2	#0,#$78000
	pterm
	
decomp_pic	lea pic+34,a5
	move.l #$78000,a3
dec10	move.l #$c7,d4
	move.l #6,a0
	moveq #4,d6
	moveq #$28,d7
dec9	clr.b d1
	move.l a3,a4
dec8	move.l a4,-(sp)
	clr.b d3
dec7	move.b (a5)+,d0
	tst.b d0
	bmi.s dec1
	addq.b #1,d0
dec3	move.b (a5)+,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec2
	add.l a0,a4
dec2	subq.b #1,d0
	bne.s dec3
	bra.s dec4
dec1	neg.b d0
	addq.b #1,d0
	move.b (a5)+,d2
dec6	move.b d2,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec5
	add.l a0,a4
dec5	subq.b #1,d0
	bne.s dec6
dec4	cmp.b d7,d3
	BNE.S DEC7
	move.l (sp)+,a4
	addq.l #2,a4
	addq.b #1,d1
	cmp.b d6,d1
	bne.s dec8
	add.l #$a0,a3
	dbra d4,dec9
	rts

	section data

palette	dc.w $000,$777,$777,$777,$777,$777,$777,$777
	dc.w $777,$777,$777,$777,$777,$777,$777,$777

pic	incbin a:\loader\load.pc1

txt_code	dc.b $1b,"E"
	dc.b "Ok boy, enter the PASSWORD !",$0D,$0A
	DC.B ">",0
buffer	dc.b 24,0
	ds.b 24
code	dc.b "PLIZ,GIVE ME THE SOURCES"
END_CODE	EQU *

good_code	dc.b $0a,$0d,$0a,$0d
	dc.b "THAT'S RIGHT,NOW REACH TO THE END",$0A,$0D
	DC.B "AND PRESS SPACE TO GET THE DESKTOP...",0

txt_intro	dc.b $1b,"E"
	*     1234567890123456789012345678901234567890
	dc.b "THE MISFITS SOFTWARE PROUDLY PRESENTS :",$0D,$0A
	DC.B "---------------------------------------",$0D,$0A,$0D,$0A
	DC.B "       THE ANOTHER ILLUSION DEMO",$0D,$0A
	DC.B "       -------------------------",$0D,$0A,$0D,$0A,$0A,$0D
	DC.B "  COPY IT IN NORMAL MODE/ALL SECTORS.",$0D,$0A,$0D,$0A,$0A,$0D
	DC.B " TO CONTACT MISFITS SOFTWARE,WRITE TO:",$0D,$0A
	DC.B "                 VIXIT",$0D,$0A
	DC.B "          CHEZ SANCHEZ MORENO",$0D,$0A
	DC.B "           8 RUE DE PROVENCE",$0D,$0A
	DC.B "           38130  ECHIROLLES",$0D,$0A
	DC.B "                FRANCE.",$0D,$0A,$0D,$0A,$0D,$0A,$0A,$0D
	DC.B "    PRESS SPACE TO RUN THE DEMO ...",0

	END