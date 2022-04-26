	
	jmp	main(pc)

loadstart	move.l	#stack,a7
	
	move.l	#save_ints,a1
	sub.l	#loadstart,a1
	add.l	#$100+4,a1
	
	move.l	a1,-(sp)
	move.l	#loadstart-$100-4,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

* execute prog
	
	clr.l	-(sp)
	clr.l	-(sp)
	move.l	filename,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
stop	clr.w	-(sp)
	trap	#1

	ds.w $100
stack	dc.w 0

filename	ds.l	1
loadflg	ds.l	1
file1	dc.b	"a:\00FF.WAR",0
	even
file2	dc.b	"a:\z_out.prg",0
	even
file3	dc.b	"a:\steiload.prg",0
	even
file4	dc.b	"a:\steiload.prg",0
	even
file5	dc.b	"a:\steiload.prg",0
	even
file6	dc.b	"a:\steiload.prg",0
	even
file7	dc.b	"a:\steiload.prg",0
	even
file8	dc.b	"a:\steiload.prg",0
	even
file9	dc.b	"a:\steiload.prg",0
	even



save_ints	move.b	$fffffa07.w,mfpa07	*save interrupts
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	rts
init_ints	clr.b	$fffffa09.w		*init interrupts
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs,a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#33,$fffffa07.w
	move.b	#33,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#hbl1,$120
	clr.b	$fffa1b
	move.b	#60,$fffa21
	move.l	#replay_rot+$8918,$134
	move.l	#vbi,$70.w
	rts
mfp_freqs	dc.b	24			*10 and 8.3 Khz
	dc.b	29
ret_ints	move.b	mfpa07,$fffffa07.w
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	rts
mfpa07	dc.b	0
mfpa09	dc.b	0
mfpa13	dc.b	0
mfpa15	dc.b	0
mfpa19	dc.b	0
mfpa1f	dc.b	0
old134	dc.l	0
oldvbl	dc.l	0
main	pea	0			*supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	move.l	usp,a0			*save usp
	move.l	a0,save_usp
	move.l	$44e,scrbase

	move.w	#160,vu1		;Init da vu:z
	move.w	#160,vu2
	move.w	#160,vu3
	move.w	#160,vu4
	
	move.w	#7,d0
	lea	$ff8240,a0
fixpal	clr.l	(a0)+
	dbra.w	d0,fixpal
	
	jsr	save_ints
	clr.b	$fffa07
	clr.b	$fffa09

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.l	#flashdat,flashcnt
	
	lea	font+34+(160*37*4),a0
	move.l	scrbase,a1
	
putlogo	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1	
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1	
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1	
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1	
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)
	lea	32(a1),a1	
	cmp.l	#font+34+(160*37*4)+160*52,a0
	bne	putlogo
	
	lea	dotdata,a0
	lea	copyspace,a1
	move.w	#3099,d0
copylp1	move.l	(a0)+,(a1)+
	dbra.w	d0,copylp1
	
	jsr	scrlinit
	
	lea	module,a0			*a0=module start
	moveq	#-1,d0			*-1=the default soundtable 0=the other
	jsr	replay_rot+$24		*init. replay routine
	jsr	init_ints			*init. interrupts
	clr.w	wfnc
demo_loop	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	addq.w	#1,hz
	cmp.w	#4,hz
	bne	nochg
	clr.w	hz
	
	addq.l	#2,flashcnt
	move.l	flashcnt,a0
	cmp.w	#$ffff,(a0)
	bne	nowrap3
	move.l	#flashdat,flashcnt
nochg	move.l	flashcnt,a0
nowrap3	move.w	(a0),$ff8250
	move.w	#$222,$ff8248
	move.w	#$222,$ff8258
	move.w	#$444,$ff8244
	move.w	#$444,$ff8254
	move.w	#$666,$ff8242
	move.w	#$666,$ff8252
	
	clr.b	$fffa1b
	move.l	#hbl1,$120
	move.b	#66,$fffa21
	move.b	#$8,$fffa1b
	
	move.w	replay_rot+$562,voice1
	move.w	replay_rot+$564,voice2
	move.w	replay_rot+$566,voice3
	move.w	replay_rot+$568,voice4
	
	jsr	plane4
	jsr	putdotz
	
	jsr	clrvus
	jsr	fixvu
	jsr	putvu
	jsr	copyvus
	
	cmp.b	#185,$fffc02
	beq	quitfix
	jmp	demo_loop
	
quitfix	jmp	quit

*****************************************************

putdotz	move.l	scrbase,d4	;Backup
	lea	dotdata,a0
	add.l	fldcnt,a0
	
	rept	100
	move.l	d4,a1		;Scrbase to a1
	add.w	(a0)+,a1		;Add offset from scrbase
	lea	122(a0),a0
	clr.w	(a1)		;Sudda da pixl
	endr
	

	addq.l	#4,fldcnt
	cmp.l	#23324,fldcnt
	bne	nowrap
	clr.l	fldcnt
nowrap	lea	dotdata,a0
	add.l	fldcnt,a0
	
	rept	100

	move.l	d4,a1		;Scrbase to a1
	add.w	(a0)+,a1		;Add offset from scrbase
	move.w	(a0)+,d0		;Put nibble in d0
	lea	120(a0),a0
	or.w	d0,(a1)		;Put da pixel
	
	endr
	
	rts
	
fixvu	cmp.w	#0,voice1
	beq	no1
	move.w	#160*30,vu1
	jmp	vuc2
no1	cmp.w	#160,vu1
	beq	vuc2
	sub.w	#160,vu1
vuc2	cmp.w	#0,voice2
	beq	no2
	move.w	#160*30,vu2
	jmp	vuc3
no2	cmp.w	#160,vu2
	beq	vuc3
	sub.w	#160,vu2
vuc3	cmp.w	#0,voice3
	beq	no3
	move.w	#160*30,vu3
	jmp	vuc4
no3	cmp.w	#160,vu3
	beq	vuc4
	sub.w	#160,vu3
vuc4	cmp.w	#0,voice4
	beq	no4
	move.w	#160*30,vu4
	jmp	ret1
no4	cmp.w	#160,vu4
	beq	ret1
	sub.w	#160,vu4
ret1	rts	
	
putvu	move.l	scrbase,a1
	add.l	#6+160*100+64,a1
	move.l	a1,d2		;For comparision
	move.w	vudat,d0
	sub.w	vu1,a1
	
putlp1	move.w	d0,(a1)
	lea	160(a1),a1
	cmp.l	d2,a1
	bne	putlp1
	

	move.l	scrbase,a1
	add.l	#6+160*100+64+8,a1
	move.l	a1,d2		;For comparision
	move.w	vudat,d0
	sub.w	vu2,a1

putlp2	move.w	d0,(a1)
	lea	160(a1),a1
	cmp.l	d2,a1
	bne	putlp2
	

	move.l	scrbase,a1
	add.l	#6+160*100+64+16,a1
	move.l	a1,d2		;For comparision
	move.w	vudat,d0
	sub.w	vu3,a1
	
putlp3	move.w	d0,(a1)
	lea	160(a1),a1
	cmp.l	d2,a1
	bne	putlp3
	

	move.l	scrbase,a1
	add.l	#6+160*100+64+24,a1
	move.l	a1,d2		;For comparision
	move.w	vudat,d0
	sub.w	vu4,a1

putlp4	move.w	d0,(a1)
	lea	160(a1),a1
	cmp.l	d2,a1
	bne	putlp4
	rts
	
clrvus	move.l	scrbase,a0
	add.l	#6+160*70+64,a0
	move.w	#29,d0

clrlp1	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	lea	160(a0),a0
	dbra	d0,clrlp1
	rts

copyvus	move.l	scrbase,a0
	add.l	#6+160*70+64,a0
	move.w	#29,d0
	lea	(a0),a1
	add.l	#60*160,a1
	
movelp1	move.w	(a0),(a1)
	move.w	8(a0),8(a1)
	move.w	16(a0),16(a1)
	move.w	24(a0),24(a1)
	lea	160(a0),a0
	lea	-160(a1),a1
	dbra	d0,movelp1
	rts



plane4	move.l	scrbase,a0
	add.l	#160*163,a0
	move.w	#35,d1
nextline	movep.l	1(a0),d0		;byte 1-8 av 39
	movep.l	d0,(a0)
	movep.l	8(a0),d0
	movep.l	d0,1(a0)
	movep.l	9(a0),d0
	movep.l	d0,8(a0)
	movep.l	16(a0),d0
	movep.l	d0,9(a0)
	movep.l	17(a0),d0
	movep.l	d0,16(a0)
	movep.l	24(a0),d0
	movep.l	d0,17(a0)
	movep.l	25(a0),d0
	movep.l	d0,24(a0)
	movep.l	32(a0),d0
	movep.l	d0,25(a0)
	movep.l	33(a0),d0		;byte 9-16 av 39
	movep.l	d0,32(a0)
	movep.l	40(a0),d0
	movep.l	d0,33(a0)
	movep.l	41(a0),d0
	movep.l	d0,40(a0)
	movep.l	48(a0),d0
	movep.l	d0,41(a0)
	movep.l	49(a0),d0
	movep.l	d0,48(a0)
	movep.l	56(a0),d0
	movep.l	d0,49(a0)
	movep.l	57(a0),d0
	movep.l	d0,56(a0)
	movep.l	64(a0),d0
	movep.l	d0,57(a0) 
	movep.l	65(a0),d0		;byte 17-24 av 39
	movep.l	d0,64(a0)
	movep.l	72(a0),d0
	movep.l	d0,65(a0)
	movep.l	73(a0),d0
	movep.l	d0,72(a0)
	movep.l	80(a0),d0
	movep.l	d0,73(a0)
	movep.l	81(a0),d0
	movep.l	d0,80(a0)
	movep.l	88(a0),d0
	movep.l	d0,81(a0)
	movep.l	89(a0),d0
	movep.l	d0,88(a0)
	movep.l	96(a0),d0
	movep.l	d0,89(a0) 
	movep.l	97(a0),d0		;byte 25-32 av 39
	movep.l	d0,96(a0)
	movep.l	104(a0),d0
	movep.l	d0,97(a0)
	movep.l	105(a0),d0
	movep.l	d0,104(a0)
	movep.l	112(a0),d0
	movep.l	d0,105(a0)
	movep.l	113(a0),d0
	movep.l	d0,112(a0)
	movep.l	120(a0),d0
	movep.l	d0,113(a0)
	movep.l	121(a0),d0
	movep.l	d0,120(a0)
	movep.l	128(a0),d0
	movep.l	d0,121(a0)
	movep.l	129(a0),d0		;byte 33-39 av 39
	movep.l	d0,128(a0)
	movep.l	136(a0),d0
	movep.l	d0,129(a0)
	movep.l	137(a0),d0
	movep.l	d0,136(a0)
	movep.l	144(a0),d0
	movep.l	d0,137(a0)
	movep.l	145(a0),d0
	movep.l	d0,144(a0)
	movep.l	152(a0),d0
	movep.l	d0,145(a0)
	movep.l	153(a0),d0
	movep.l	d0,152(a0)
	lea	160(a0),a0
	dbra.w	d1,nextline
	addq.b	#$01,stepcount
	cmp.b	#$04,stepcount
	bne.w	jump1
	jsr	nextchar
	jmp	plup
jump1	cmp.b	#$02,stepcount
	beq.w	blup1
	addq.l	#$1,fontdat
	jmp	plup
blup1	addq.l	#$7,fontdat
plup	move.l	scrbase,a1
	add.l	#160*163+153,a1

	move.l	fontdat,a0
	move.w	#35,d0 
moredat	movep.l	(a0),d1
	movep.l	d1,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbra.w	d0,moredat
	rts
	
scrlinit	move.l	#font+34,fontstart
	move.l	#scrltxt,txtcount
	move.b	#$03,stepcount
	rts

**********			4plane32line-scroll-subs

nextchar	clr.b	stepcount
	clr.l	d0
	addq.l	#$1,txtcount
	move.l	txtcount,a0
	move.b	(a0),d0
	sub.b	#$20,d0
	cmp.b	#$d0,d0
	bne	jump2
	jsr	scrlwrap
jump2	clr.l	flum
	mulu	#$4,d0
	move.w	d0,flum+2
	move.b	#$00,flum+2
	move.l	flum,d0
	move.l	fontstart,d1
	lea	fontvect,a0
	add.l	d0,a0
	add.l	(a0),d1
	move.l	d1,fontdat
	rts
scrlwrap	lea	txtcount,a0
	lea	scrltxt,a1
	move.l	a1,(a0)
	move.l	(a0),d0
	move.l	d0,a0
	move.l	#$00000000,d0
	move.b	(a0),d0
	sub.b	#$20,d0
	rts

hbl1	move.w	#$700,$ff8250
	clr.b	$fffa1b
	move.b	#34,$fffa21
	move.l	#hbl2,$120
	move.b	#8,$fffa1b
	rte
	
hbl2	move.w	#$007,$ff8250
	clr.b	$fffa1b
	move.b	#62,$fffa21
	move.l	#hbl3,$120
	move.b	#8,$fffa1b
	rte
	
hbl3	move.w	#$300,$ff8250
	move.w	#$410,$ff8252
	move.w	#$520,$ff8254
	move.w	#$631,$ff8256
	move.w	#$742,$ff8258
	move.w	#$752,$ff825a
	move.w	#$764,$ff825c
	move.w	#$777,$ff825e
	clr.b	$fffa1b
	
	rte
	
clrscr	move.l	scrbase,a0
	move.w	#7999,d0
clrscr2	clr.l	(a0)+
	dbra.w	d0,clrscr2
	rts


**********			4plane32line-scroll-data

hz	ds.l	1
vu1	ds.w	1
vu2	ds.w	1
vu3	ds.w	1
vu4	ds.w	1
vudat	dc.w	%0111111111111111

voice1	ds.w	1
voice2	ds.w	1
voice3	ds.w	1
voice4	ds.w	1

flashcnt	ds.l	1
flashdat	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$600,$500,$400,$300,$200,$100,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$001,$002,$003
	dc.w	$004,$005,$006,$007,$006,$005,$004,$003
	dc.w	$002,$001,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$101,$212,$323,$434,$545,$656,$767
	dc.w	$656,$545,$434,$323,$212,$101,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$010,$121,$232,$343,$454,$565
	dc.w	$676,$777,$676,$565,$454,$343,$232,$121
	dc.w	$010,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$ffff

fldcnt	ds.l	1
dotdata	incbin	a:\fildat4.bin
copyspace	ds.l	3100		;23324 bytes=field-data-copy!

scrbase	ds.l	1 

flum	ds.l	1
fontstart	ds.l	1
txtcount	ds.l	1
stepcount	ds.l	1
fontdat	ds.l	1
font	incbin	a:\hummelok.pi1
save_sp	ds.l	1

fontvect
	dc.l	17840,$2eb0,17840,17840,17840,17840,17840,$2ec0,17840,17840
	dc.l	17840,17840,$4560,$2ed0,$2ea0,17840,17840,17840,17840,17840
	dc.l	17840,17840,17840,17840,17840,17840,17840,17840,17840,17840
	dc.l	17840,17840,17840,0,$10,$20,$30,$40,$50,$60
	dc.l	$70,$80,$90,$1720,$1730,$1740,$1750,$1760,$1770,$1780
	dc.l	$1790,$17a0,$17b0,$2e40,$2e50,$2e60,$2e70,$2e80,$2e90,$2ea0
	dc.l	17840,17840,17840,17840,17840,17840,17840,17840,17840,17840
	dc.l	17840,17840,17840,17840,17840,17840,17840,17840,17840,17840
	dc.l	17840,17840,17840,17840,17840,17840,17840,17840,17840,17840

scrltxt
 DC.B	"  HALLO OCH HEJ ALLA FOLKE FANS! HOPPAS DU FATTAR HUR MAN SKA GORA EN STARFLIGHT NU!!..     SNYGVE FUCKS OFF!     "


	dc.b	$f0
	even

info	DC.B	13,10,13,10,13,10,13,10
	dc.b	"~ FLOKE RULES ~"
	dc.b	"                     ",0
	dc.b	0
	even
	

quit	jsr	ret_ints
	
	jsr	clrscr
	
keybuf1	btst	#0,$fffffc00.w
	beq	next1
	move.b	$fffc02,d0
	jmp	keybuf1
	
next1	lea	info,a0
	
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.b	$fffa1b
	move.l	#lines,$120
	move.l	#vbl2,$70
	clr.b	$fffa09
	clr.b	$fffa15
	move.b	#33,$fffffa07
	move.b	#33,$fffffa13
	move.b	#1,$fffa21
	move.b	#8,$fffa1b

wait	cmp.w	#1,flum
	bne.s	wait
	clr.w	flum
	cmp.b	#$82,$fffffc02
	bne	not1
	move.l	#file1,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not1	cmp.b	#$83,$fffffc02
	bne	not2
	move.l	#file2,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not2	cmp.b	#$84,$fffffc02
	bne	not3
	move.l	#file3,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not3	cmp.b	#$85,$fffffc02
	bne	not4
	move.l	#file4,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not4	cmp.b	#$86,$fffffc02
	bne	not5
	move.l	#file5,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not5	cmp.b	#$87,$fffffc02
	bne	not6
	move.l	#file6,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not6	cmp.b	#$88,$fffffc02
	bne	not7
	move.l	#file7,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not7	cmp.b	#$89,$fffffc02
	bne	not8
	move.l	#file8,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
not8	cmp.b	#$8a,$fffffc02
	bne	not9
	move.l	#file9,filename
	move.w	#1,loadflg
	move.b	$fffc02,d0
	
not9	cmp.w	#1,loadflg
	beq	keybuf2
	
	jmp	wait
	
keybuf2	move.w	$fffc02,d0
	move.b	$fffc02,d0

next2	jsr	ret_ints
	
	move.w	#$777,$ff8240
	lea	$ff8242,a0
	
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	
	move.l	$4,flum
	
	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	cmp.w	#1,loadflg
	beq.s	load
	
	move.l	flum,a0
	jmp	(a0)	;Reset if no load

load	jmp	loadstart

vbl2	move.w	#1,flum
	move.l	#lines,$120
	clr.b	$fffa1b
	move.l	#lines,$120
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	lea	bars,a0
	rte

lines	move.w	(a0)+,$ff8240
	clr.b	$fffa1b
	bclr	#0,$fffa0f
	move.b	#8,$fffa1b
	rte

bars	dcb.w	10,$000
	dc.w	$001
	dc.w	$000
	dc.w	$001
	dc.w	$000
	dcb.w	10,$001
	dc.w	$002
	dc.w	$001
	dc.w	$002
	dc.w	$001
	dcb.w	10,$002
	dc.w	$003
	dc.w	$002
	dc.w	$003
	dc.w	$002
	dcb.w	10,$003
	dc.w	$004
	dc.w	$003
	dc.w	$004
	dc.w	$003
	dcb.w	10,$004
	dc.w	$005
	dc.w	$004
	dc.w	$005
	dc.w	$004
	dcb.w	10,$005
	dc.w	$006
	dc.w	$005
	dc.w	$006
	dc.w	$005
	dcb.w	10,$006
	dc.w	$007
	dc.w	$006
	dc.w	$007
	dc.w	$006
	dcb.w	10,$007
	dc.w	$006
	dc.w	$007
	dc.w	$006
	dc.w	$007
	dcb.w	10,$006
	dc.w	$005
	dc.w	$006
	dc.w	$005
	dc.w	$006
	dcb.w	10,$005
	dc.w	$004
	dc.w	$005
	dc.w	$004
	dc.w	$005
	dcb.w	10,$004
	dc.w	$003
	dc.w	$004
	dc.w	$003
	dc.w	$004
	dcb.w	10,$003
	dc.w	$002
	dc.w	$003
	dc.w	$002
	dc.w	$003
	dcb.w	10,$002
	dc.w	$001
	dc.w	$002
	dc.w	$001
	dc.w	$002          
	dcb.w	10,$001
	dc.w	$000	
	dc.w	$001
	dc.w	$000	
	dc.w	$001
	dcb.w	10,$000

vbi	movem.l	d0-d5/a0-a1,-(sp)		*save registers
	jsr	replay_rot+$28		*call replay routine
	move.w	#1,wfnc			*set video flag
	movem.l	(sp)+,d0-d5/a0-a1		*pop registers
	rte
save_usp	dc.l	0
physbase	ds.l 1
wfnc	dc.w	0
save_stk	dc.l	0
replay_rot	incbin	a:\tracker.rot
		even
module		incbin 	b:\modules.mod\complica.mod
