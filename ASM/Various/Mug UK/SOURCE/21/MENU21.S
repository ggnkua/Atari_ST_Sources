		opt		o+,w-
 list +

* MENU CODED BY  M M M ,
* FOR NEW ORDER ,
* CONTAINS SCROLLER ,
* VERSION 3. SOMETHING,
* HOPE ITS EASIER FOR 
* YOU ALL TO USE ;
* HOPE TO SEE IT IN USE SOON .

 list -

		move.l		4(a7),a3
		move.l		$c(a3),d0
		add.l		$14(a3),d0
		move.l		d0,-(sp)
		move.l		a3,-(sp)
		clr.w		-(sp)
		move.w		#$4a,-(sp)
		trap		#1
		lea		$c(a7),sp


		move.l		a7,save_stk
		move.l		#mikes_stk,a7

		move.l		#stk_store,a0
		move.l		save_stk,a1
		sub.l		#160,a1
		move.l		#80,d0
saveit		move.l		(a1)+,(a0)+
		dbra		d0,saveit

		move.w		#2,-(sp)
		trap		#14
		addq.l		#2,sp
		move.l		d0,sav_screen
		sub.l		#120*256,d0
		move.l		d0,screen

		move.l		screen,a0
		move.l		#8000,d0
cls		clr.l		(a0)+
		dbra		d0,cls


		move.l		#0,-(sp)
		move.w		#$20,-(sp)
		trap		#1
		addq.l		#6,sp
		move.l		d0,ssp_save

		lea		piccy+2,a0	;change palette to
		move.l		a0,$45a		;degas pics colours

		move.l		#screen2,d0
		clr.b		d0
		move.l		d0,scr2

      		move.w		#0,-(sp)	;0=low rez
		move.l 		scr2,-(sp)	;dont change scr addrs
		move.l 		#-1,-(sp)
		move.w 		#5,-(sp)
		trap 		#14		;change rez
		add.l 		#12,sp

		jsr		shift

		move.l		tune_no,d0
		jsr		music
		move.l		#music+8,$4de

textmake	lea		text,a0
		lea		mstart,a1

nextchar	moveq		#0,d0
		move.b		(a0)+,d0
		cmp.b		#64,d0
		beq		endit
		cmp.b		#95,d0
		beq		a_change
		cmp.b		#48,d0
		bge		testnum
		bne		notnum
testnum		cmp.b		#57,d0
		ble		number
notnum		cmp.b		#32,d0
		beq		itsaspace
		sub.b		#61,d0
		mulu		#4608,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar		
a_change	move.l		#change_wave,(a1)+
		bra		nextchar
number		sub.l		#19,d0
		mulu		#4608,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar
exp_mark	move.l		#36,d0
		mulu		#4608,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar
full_stop	move.l		#40,d0
		mulu		#4608,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar
comma		move.l		#37,d0
		mulu		#4608,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar
itsaspace	moveq		#0,d0
		add.l		#chars,d0
		move.l		d0,(a1)+
		bra		nextchar
endit		move.l		#-99,(a1)+
		move.l		#-99,(a1)+
		move.l		#-99,(a1)+


		move.l		screen,a0
		lea		lastlaya,a1
		lea		lastlayb,a2
		moveq		#29,d0
		
fudge		move.l		a0,(a1)+
		move.l		a0,(a2)+
		dbra		d0,fudge



		move.w		#2,-(sp)	;disable level2
		move.w		#26,-(sp)	;ints
		trap		#14
		addq.l		#4,sp

		move.w		#5,-(sp)	;disable level5
		move.w		#26,-(sp)	;ints
		trap		#14
		addq.l		#4,sp
	
		move.b		#$12,$fffffc02	;mouse off

		move.l		#vbl_set,$4d2

	*****************************************************


main1		move.l		screen,d0
		move.l		scr2,screen
		move.l		d0,scr2
	
		move.l		#screen,a0
		move.b		1(a0),$ff8201
		move.b		2(a0),$ff8203

		bsr		drawup
		bsr		raster
		move.l		main,a0
		jmp		(a0)

main2		bsr		clearup
		bsr		scroller
		bsr		new_mus
		bsr		raster
		bsr		new_speed
		bra		end

new_speed	move.b		$fffc02,d0

		cmp.b		#$4A,d0
		beq		slow_sc
		
		cmp.b		#$4E,d0
		beq		fast_sc

		rts
		
slow_sc		cmp.l		#0,speed
		bhi		slow
		rts

fast_sc		cmp.l		#4608,speed
		blo		fast
		rts
	
slow		sub.l		#576,speed
		rts

fast		add.l		#576,speed
		rts

end		move.b		$fffc02,d0

		cmp.b		#$2,d0	;key test
		beq		load_drop	;1 - 0 are in hex
					;but $2 is key 1
		cmp.b		#$3,d0	;i.e 1 = $2 and 0 = $b
		beq		load_drop	;add extra as required

		cmp.b		#$4,d0
		beq		load_drop

		move.l		main,a0
		jmp		(a0)

	****************************************************

drawup		cmp.w		#198,linecounter
		bne		notyet
		move.l		#main2,main

		move.l		#horiza,-(sp)	;enable timer b
		move.w		#199,-(sp)	;int every 1 line
		move.w		#8,-(sp)
		move.w		#1,-(sp)
		move.w		#31,-(sp)
		trap		#14
		add.l		#12,sp


		rts

notyet		move.l		screen,a0
		lea		piccy+34,a1
		add.l		offset,a1

		move.w		linecounter,d0

nextline	movem.l		(a1)+,d1-d7/a2-a4
		movem.l		d1-d7/a2-a4,(a0)
		movem.l		(a1)+,d1-d7/a2-a4
		movem.l		d1-d7/a2-a4,40(a0)
		movem.l		(a1)+,d1-d7/a2-a4
		movem.l		d1-d7/a2-a4,80(a0)
		movem.l		(a1)+,d1-d7/a2-a4
		movem.l		d1-d7/a2-a4,120(a0)

		add.l		#160,a0

		dbra		d0,nextline
		sub.l		#160,offset
		addq.w		#1,linecounter

jumpit		rts
	
	*****************************************************
				
clearup		lea		cla,a1
		move.l		(a1),a3
		moveq		#0,d0
		
		moveq		#29,d2
nwclear		move.l		(a3)+,a2
		
		moveq		#1,d1
nclear		move.l		d0,(a2)
		move.w		d0,4(a2)
		move.l		d0,4960(a2)
		move.w		d0,4964(a2)
		dbra		d1,nclear
		dbra		d2,nwclear
		rts
	*******************************************************

scroller	move.l		screen,a0
		lea		cla,a3
		move.l		(a3),a2

stscrol		move.l		messoff,a3
		move.l		wave,a4
		move.l		speed,d1
		add.l		d1,finpos
		cmp.l		#4608,finpos
		blt.s		noreset 
		sub.l		#4608,finpos
		move.w		counta,d6
		move.w		countb,counta
		move.w		d6,countb
		cmp.w		#9,counta
		bne.s		hop
		addq.l		#4,a3

hop		cmp.l		#-99,(a3)
		bne.s		noreset
		move.l		#message,a3

noreset		move.l		a3,messoff
		sub.l		#40,a3
		move.l		finpos,d5

		cmp.w		#8,counta
		bne		missit
 
		move.l		(a3)+,a1
		cmp.l		#change_wave,a1
		bne.s		tryagain_a
		move.l		wave_sav,a5
		move.l		scr_sav,a6
		move.l		(a6)+,screenoff
		move.l		(a5)+,wave
		cmp.l		#-99,(a5)
		bne		not99
		move.l		#waveset,a5
		move.l		#screenset,a6
not99		move.l		a5,wave_sav
		move.l		a6,scr_sav
		addq.l		#4,a3
		addq.l		#4,messoff
tryagain_a	add.l		d5,a1
		add.l		screenoff,a0
		add.l		(a4)+,a0
		move.l		a0,(a2)+
		moveq		#3,d1
	
nextl		move.w		4(a1),(a0)
		move.w		10(a1),2(a0)
		move.w		16(a1),4(a0)
		move.w		22(a1),160(a0)
		move.w		28(a1),162(a0)
		move.w		34(a1),164(a0)
		move.w		40(a1),320(a0)
		move.w		46(a1),322(a0)
		move.w		52(a1),324(a0)
		move.w		58(a1),480(a0)
		move.w		64(a1),482(a0)
		move.w		70(a1),484(a0)
		move.w		76(a1),640(a0)
		move.w		82(a1),642(a0)
		move.w		88(a1),644(a0)
		move.w		94(a1),800(a0)
		move.w		100(a1),802(a0)
		move.w		106(a1),804(a0)
		move.w		112(a1),960(a0)
		move.w		118(a1),962(a0)
		move.w		124(a1),964(a0)
		move.w		130(a1),1120(a0)
		move.w		136(a1),1122(a0)
		move.w		142(a1),1124(a0)

		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,nextl
		move.w		counta,d2

nlett		sub.l		#5120,a0
		add.l		(a4)+,a0
		move.l		a0,(a2)+
		move.l		(a3),a1
		cmp.l		#change_wave,a1
		bne.s		no_changea
		addq.l		#4,a3
		move.l		(a3),a1
no_changea	add.l		d5,a1

		moveq		#3,d1
		
fword		move.w		0(a1),d0
		or.w		d0,(a0)
		move.w		6(a1),d0
		or.w		d0,2(a0)
		move.w		12(a1),d0
		or.w		d0,4(a0)
		move.w		18(a1),d0
		or.w		d0,160(a0)
		move.w		24(a1),d0
		or.w		d0,162(a0)
		move.w		30(a1),d0
		or.w		d0,164(a0)
		move.w		36(a1),d0
		or.w		d0,320(a0)
		move.w		42(a1),d0
		or.w		d0,322(a0)
		move.w		48(a1),d0
		or.w		d0,324(a0)
		move.w		54(a1),d0
		or.w		d0,480(a0)
		move.w		60(a1),d0
		or.w		d0,482(a0)
		move.w		66(a1),d0
		or.w		d0,484(a0)
		move.w		72(a1),d0
		or.w		d0,640(a0)
		move.w		78(a1),d0
		or.w		d0,642(a0)
		move.w		84(a1),d0
		or.w		d0,644(a0)
		move.w		90(a1),d0
		or.w		d0,800(a0)
		move.w		96(a1),d0
		or.w		d0,802(a0)
		move.w		102(a1),d0
		or.w		d0,804(a0)
		move.w		108(a1),d0
		or.w		d0,960(a0)
		move.w		114(a1),d0
		or.w		d0,962(a0)
		move.w		120(a1),d0
		or.w		d0,964(a0)
		move.w		126(a1),d0
		or.w		d0,1120(a0)
		move.w		132(a1),d0
		or.w		d0,1122(a0)
		move.w		138(a1),d0
		or.w		d0,1124(a0)

		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,fword
		bra.s		here
		
missit		move.w		counta,d2
		move.l		screen,a0
		add.l		screenoff,a0
		cmp.l		#change_wave,(a3)
		bne.s		nochange
		move.l		wave_sav,a5
		move.l		scr_sav,a6
		move.l		(a6)+,screenoff
		move.l		(a5)+,wave
		cmp.l		#-99,(a5)
		bne		not99b
		move.l		#waveset,a5
		move.l		#screenset,a6
not99b		move.l		a5,wave_sav
		move.l		a6,scr_sav
		addq.l		#4,a3
		addq.l		#4,messoff
nochange	bra.s		skip

here		sub.l		#5120,a0
		addq.l		#8,a0
skip		add.l		(a4)+,a0
		move.l		a0,(a2)+
		move.l		(a3),a1
		add.l		d5,a1

		moveq		#3,d1

sword		move.w		2(a1),(a0)
		move.w		8(a1),2(a0)
		move.w		14(a1),4(a0)
		move.w		20(a1),160(a0)
		move.w		26(a1),162(a0)
		move.w		32(a1),164(a0)
		move.w		38(a1),320(a0)
		move.w		44(a1),322(a0)
		move.w		50(a1),324(a0)
		move.w		56(a1),480(a0)
		move.w		62(a1),482(a0)
		move.w		68(a1),484(a0)
		move.w		74(a1),640(a0)
		move.w		80(a1),642(a0)
		move.w		86(a1),644(a0)
		move.w		92(a1),800(a0)
		move.w		98(a1),802(a0)
		move.w		104(a1),804(a0)
		move.w		110(a1),960(a0)
		move.w		116(a1),962(a0)
		move.w		122(a1),964(a0)
		move.w		128(a1),1120(a0)
		move.w		134(a1),1122(a0)
		move.w		140(a1),1124(a0)


		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,sword


		sub.l		#5120,a0
		addq.l		#8,a0
		add.l		(a4)+,a0
		move.l		a0,(a2)+
		move.l		(a3)+,a1
		add.l		d5,a1

		moveq		#3,d1

tword		move.w		4(a1),(a0)
		move.w		10(a1),2(a0)
		move.w		16(a1),4(a0)
		move.w		22(a1),160(a0)
		move.w		28(a1),162(a0)
		move.w		34(a1),164(a0)
		move.w		40(a1),320(a0)
		move.w		46(a1),322(a0)
		move.w		52(a1),324(a0)
		move.w		58(a1),480(a0)
		move.w		64(a1),482(a0)
		move.w		70(a1),484(a0)
		move.w		76(a1),640(a0)
		move.w		82(a1),642(a0)
		move.w		88(a1),644(a0)
		move.w		94(a1),800(a0)
		move.w		100(a1),802(a0)
		move.w		106(a1),804(a0)
		move.w		112(a1),960(a0)
		move.w		118(a1),962(a0)
		move.w		124(a1),964(a0)
		move.w		130(a1),1120(a0)
		move.w		136(a1),1122(a0)
		move.w		142(a1),1124(a0)

		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,tword
		dbra		d2,nlett

		sub.l		#5120,a0
		add.l		(a4)+,a0
		move.l		a0,(a2)+
		move.l		(a3),a1
		cmp.l		#change_wave,a1
		bne.s		no_changec
		addq.l		#4,a3
		move.l		(a3),a1
no_changec	add.l		d5,a1

		moveq		#3,d1
		
lword		move.w		0(a1),d0
		or.w		d0,(a0)
		move.w		6(a1),d0
		or.w		d0,2(a0)
		move.w		12(a1),d0
		or.w		d0,4(a0)
		move.w		18(a1),d0
		or.w		d0,160(a0)
		move.w		24(a1),d0
		or.w		d0,162(a0)
		move.w		30(a1),d0
		or.w		d0,164(a0)
		move.w		36(a1),d0
		or.w		d0,320(a0)
		move.w		42(a1),d0
		or.w		d0,322(a0)
		move.w		48(a1),d0
		or.w		d0,324(a0)
		move.w		54(a1),d0
		or.w		d0,480(a0)
		move.w		60(a1),d0
		or.w		d0,482(a0)
		move.w		66(a1),d0
		or.w		d0,484(a0)
		move.w		72(a1),d0
		or.w		d0,640(a0)
		move.w		78(a1),d0
		or.w		d0,642(a0)
		move.w		84(a1),d0
		or.w		d0,644(a0)
		move.w		90(a1),d0
		or.w		d0,800(a0)
		move.w		96(a1),d0
		or.w		d0,802(a0)
		move.w		102(a1),d0
		or.w		d0,804(a0)
		move.w		108(a1),d0
		or.w		d0,960(a0)
		move.w		114(a1),d0
		or.w		d0,962(a0)
		move.w		120(a1),d0
		or.w		d0,964(a0)
		move.w		126(a1),d0
		or.w		d0,1120(a0)
		move.w		132(a1),d0
		or.w		d0,1122(a0)
		move.w		138(a1),d0
		or.w		d0,1124(a0)

		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,lword

		cmp.w		#8,counta
		bne		finlay

		sub.l		#5120,a0
		addq.l		#8,a0
		add.l		(a4)+,a0
		move.l		a0,(a2)+
		move.l		(a3),a1
		add.l		d5,a1

		moveq		#3,d1
		
vlword		move.w		2(a1),(a0)
		move.w		8(a1),2(a0)
		move.w		14(a1),4(a0)
		move.w		20(a1),160(a0)
		move.w		26(a1),162(a0)
		move.w		32(a1),164(a0)
		move.w		38(a1),320(a0)
		move.w		44(a1),322(a0)
		move.w		50(a1),324(a0)
		move.w		56(a1),480(a0)
		move.w		62(a1),482(a0)
		move.w		68(a1),484(a0)
		move.w		74(a1),640(a0)
		move.w		80(a1),642(a0)
		move.w		86(a1),644(a0)
		move.w		92(a1),800(a0)
		move.w		98(a1),802(a0)
		move.w		104(a1),804(a0)
		move.w		110(a1),960(a0)
		move.w		116(a1),962(a0)
		move.w		122(a1),964(a0)
		move.w		128(a1),1120(a0)
		move.w		134(a1),1122(a0)
		move.w		140(a1),1124(a0)

		add.l		#144,a1
		add.l		#1280,a0
		dbra		d1,vlword

finlay		rts

	*******************************************************
shift		lea		shiftset,a1
		lea		workarea,a2
		moveq		#0,d6
		moveq		#39,d3
nletter		lea		chop_set,a0
		add.l		whichlet,a0		

		moveq		#95,d4
firstpart	move.l		d6,(a2)
		move.w		d6,2(a2)
		move.l		(a0)+,2(a2)
		move.w		(a2),(a1)+
		move.l		2(a2),(a1)+
		dbra		d4,firstpart

		moveq		#6,d2
nshift		moveq		#95,d1
nbit		lea		shiftset,a0
		move.l		d6,(a2)
		move.w		d6,2(a2)
		add.l		lastpos,a0
		add.l		whichshift,a0

		move.w		(a0)+,(a2)
		move.l		(a0)+,2(a2)
	
		move.l		(a2),d0
		lsl.l		#2,d0
		swap		d0
		move.w		d0,(a1)+
		move.l		2(a2),d0
		lsl.l		#2,d0
		move.l		d0,(a1)+

		addq.l		#6,lastpos
		dbra		d1,nbit
		move.l		#0,lastpos
		add.l		#576,whichshift
		dbra		d2,nshift
		add.l		#576,whichshift
		add.l		#384,whichlet
		dbra		d3,nletter
		
		rts

	***************************************************

new_mus		moveq		#0,d0
		move.b		$fffc02,d0
		cmp.b		#$3b,d0       ;function key
		blt.s		no_go
		cmp.b		#$3c,d0       ;function key
		bgt.s		no_go
		move.l		tune_no,d1
		sub.b		#$3a,d0       ;function key

		cmp.b		d1,d0
		beq.s		no_go
		cmp.b		#0,d0
		beq.s		no_go

		move.l		d0,tune_no

		move.l		tune_no,d0
		jsr		music
		move.l		#music+8,$4de

no_go		rts

	****************************************************


load_drop  	move.b		d0,keypressed
		bset		#1,$ff820a  
		move.l		#rcols,$45a
		move.b		#$8,$fffffc02		;mouse on

		clr.l		$4de
		clr.l		$4d6
		clr.l		$4da
		clr.l		$4d2
		PEA		stopm_d
		MOVE.W		#$20,-(A7)
		TRAP		#14
		ADDQ.L		#6,A7
		bset		#5,$fffa09


		move.l		#stk_store,a0
		move.l		save_stk,a1
		sub.l		#160,a1
		move.l		#80,d0
unsaveit	move.l		(a0)+,(a1)+
		dbra		d0,unsaveit

		move.w 		#0,-(sp)	
		move.l 		sav_screen,-(sp)
		move.l 		#-1,-(sp)       ;changed
		move.w 		#5,-(sp)
		trap 		#14		
		add.l 		#12,sp
		move.l		ssp_save,-(sp)
		move.w		#$20,-(sp)
		trap		#1
		addq.l		#6,sp


		move.w		#8,-(sp)	;disable timer 8
		move.w		#26,-(sp)	;ints
		trap		#14
		addq.l		#4,sp

		move.w		#2,-(sp)	;enable level 2
		move.w		#27,-(sp)	;ints
		trap		#14
		addq.l		#4,sp

		move.w		#5,-(sp)	;enable	level 5
		move.w		#27,-(sp)	;ints
		trap		#14
		addq.l		#4,sp

		cmp.b		#$39,keypressed
		beq		drop

		moveq		#0,d0
		move.b		keypressed,d0
		subq.b		#2,d0
		mulu		#4,d0
		lea		filenames,a0
		add.l		d0,a0
		pea		env
		pea		com
		move.l		(a0),-(sp)
		move.w		#0,-(sp)
		move.w		#$4b,-(sp)
		trap		#1
		add.l		#16,sp


drop		clr.w 		-(sp)
		move.w		#$4c,-(sp)
		trap 		#1			; ret to assem

	***********************************************************

horiza		move.l		a0,-(sp)
		lea		goldcols,a0
		move.l		(a0)+,$ff8240
		move.l		(a0)+,$ff8244
		move.l		(a0)+,$ff8248
		move.l		(a0),$ff824c
		move.l		(sp)+,a0

		move.l		#horiz,$120
		move.b		#0,$fffa1b
		move.b		#1,$fffa21
		move.b		#8,$fffa1b

		bclr		#0,$fffa0f	;release int
		rte

horiz		move.b		#0,$ff820a
		nop
		nop
		nop
		move.b		#2,$ff820a
		move.l		#shutdownhoriz,$120
		move.b		#0,$fffa1b
		move.b		#1,$fffa21
		move.b		#8,$fffa1b

		bclr		#0,$fffa0f	;release int
		rte

shutdownhoriz	move.b		#0,$fffa1b	;disable timer
		bclr		#0,$fffa0f	;release int
		rte

	**********************************************************

vbl_set		move.l		#horiza,$120
		move.b		#0,$fffa1b
		move.b		#199,$fffa21
		move.b		#8,$fffa1b
		lea		piccy+2,a0	
		move.l		(a0)+,$ff8240
		move.l		(a0)+,$ff8244
		move.l		(a0)+,$ff8248
		move.l		(a0)+,$ff824c
		move.l		(a0)+,$ff8250
		move.l		(a0)+,$ff8254
		move.l		(a0)+,$ff8258
		move.l		(a0)+,$ff825c

		rts

	**********************************************************

raster		;move.w		#$777,$ff8240
		move.w		#37,-(sp)
		trap		#14
		addq.l		#2,sp
		;move.w		#$000,$ff8240
		rts
		

	***********************************************************


env		dc.l		0
com		dc.l		0

sav_screen	dc.l		0
ssp_save	dc.l		0
screen		dc.l		0	
scr2		dc.l		0
save_stk	dc.l		0
rcols		dc.w		$777,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
linecounter	dc.l		0
keypressed	dc.w		0

main		dc.l		main1

	********************************************************
	********************************************************
	********** L O O K   B E L O W   T H I S ***************
	********************************************************
	********************************************************



		;**************************************
		;* type in the scroller below leave   *
		;* 20 spaces at the begining,20 at    *
		;* end ; then end with the @ sign     *
		;* always use uppercase letters       *
		;* its a good idea to leave about     *
		;* 11 spaces at the start of the text *
		;* as i have done .		      *
		;**************************************

text	dc.b	"                     "
	dc.b	"      HI_          "
	DC.B	" KALAMAZOO HERE_          "
	DC.B	" WITH THE SOURCE_          "
	DC.B	" MENU TWENTY ONE_          "
	DC.B	" THIS DISK   LIKE ALL OTHER DISKS FROM THE SOURCE IS_          "
	DC.B	" PUBLIC DOMAIN_              "
	dc.b	" SORRY FOR THE POOR PICCIE BUT IM NO ARTIST AND IVE"
	DC.B	" COMPLETLY RAN OUT OF PICTURES    SO I HAD TO DO ONE"
	DC.B	" MYSELF    SO UNTIL I GET ANY"
	DC.B	" MORE PICTURES   YOULL HAVE TO PUT UP WITH MINE_             "
	DC.B	" THERE ARE THREE DEMOS ON THIS DISK_          "
	DC.B	" THE EMPIRE NOISETRACKER_          "
	DC.B	" THE EMPIRE MODULE REPLAY PROG_          "
	DC.B	" THANX GO TO   T B E   OF   AUTOMATION    FOR THOSE TWO_          "
	DC.B	" AND THE SYNC SOUNDTRACKER    YES IT IS EXACTLY THE SAME"
	DC.B	" ONE AS WHICH APPEARED ON THE SOURCE NUMBER SIX    THE"
	DC.B	" REASONS FOR THIS WILL BE EXPLAINED_          "
	DC.B	" THE EMPIRE NOISETRACKER WILL NOT ACCEPT PACKED MODULES  "
	DC.B	" LIKE THE ONES TO APPEAR ON OUR MENUS   SO WHAT YOU DO"
	DC.B	" IF YOU WANT TO USE IT IS AS FOLLOWS_          "
	DC.B	" STEP ONE          BOOT UP THE SYNC MODULE PLAYER ON"
	DC.B	" EITHER THIS DISK  OR  THE SOURCE NUMBER SIX_          "
	DC.B	" STEP TWO          LOAD IN THE MODULE WHICH YOU WANT TO"
	DC.B	" RUN ON THE EMPIRE NOISETRACKER_          "
	DC.B	" STEP THREE          INSERT A BLANK FORMATED DISK_          "
	DC.B	" STEP FOUR          SAVE THE UNPACKED MODULE ONTO THE BLANK DISK_          "
	DC.B	" STEP FIVE          REPEAT FROM STEP TWO FOR MORE MODULES_          "
	DC.B	" STEP SIX          RESET THE MACHINE AND LOAD IN THE"
	DC.B	" EMPIRE NOISETRACKER_          "
	DC.B	" STEP SEVEN          INSERT THE DISK WITH THE UNPACKED"
	DC.B	" MODULES ON AND LOAD IN THE REQUIRED MODULE_               "
	DC.B	" THANX GO TO   THE BALD EAGLE   FOR THOSE TIPS_          "
	DC.B	" FOR THOSE OF YOU WHO WILL FIND THIS TOO DIFFICULT I"
	DC.B	" HAVE INCLUDED SOME UNPACKED MODULES IN THE FOLDER"
	DC.B	"   NOISE MOD       ALL OF THE OTHER MODULES ON THIS"
	DC.B	" DISK ARE PACKED AND ARE FOR USE WITH THE EMPIRE REPLAY"
	DC.B	" PROGRAM  AND THE  SYNC MODULE PLAYER  WHICH WILL"
	DC.B	" RUN PACKED AND UNPACKED MODULES_               "
	DC.B	" THERE ARE ALSO SOME PACKED MODULES ON THIS DISK FOR USE"
	DC.B	" WITH ANY OF THE SOUNDTRACKER DEMOS TO APPEAR ON OUR"
	DC.B	" DISKS_          "
	DC.B	" THESE MODULES WHERE SUPPLIED BY_          "
	DC.B	" KLAMPIT_          "
	DC.B	" SO THANX GO TO YOU_          "
	DC.B	" BUT AS IVE SAID THEY WILL NOT RUN ON THE EMPIRE NOISETRACKER"
	DC.B	" OR THE EQUINOX SOUNDTRACKER ON DISK SEVEN_               "
	DC.B	" WELL NOW ITS"
	DC.B	" GREETINGS TIME_          "
	DC.B	" GREETZ GO TO THE FOLLOWING   IN ALPHABETICAL ORDER_          "
	DC.B	" AENIGMATICA_          "
	DC.B	" AGGRESSION_          "
	DC.B	" AUTOMATION_          "
	DC.B	" CAPTAIN WIBBLE_          "
	DC.B	" DAL SNUFFS_          "
	DC.B	" DODGYSOFT_          "
	DC.B	" FLAME OF FINLAND_          "
	DC.B	" FORDY_          "
	DC.B	" G FORCE_          "
	DC.B	" INNER CIRCLE_          "
	DC.B	" KLAMPIT_          "
	DC.B	" KIE_          "
	DC.B	" MANTRONIX_          "
	DC.B	" MERCURY OF TOTE_          "
	DC.B	" NECROMANCER_          "
	DC.B	" NEW ORDER_          "
	DC.B	" RIPPED OFF_          "
	DC.B	" SEWER SOFTWARE  ESP SEWER RAT_          "
	DC.B	" ST CONNEXIONS_          "
	DC.B	" SYNC_          "
	DC.B	" THE BALD EAGLE_          "
	DC.B	" THE CAREBEARS_          "
	DC.B	" THE DISK MAP CREW_          "
	DC.B	" THE EMPIRE_          "
	dc.b	" THE FCC_          "
	DC.B	" THE LOST BOYS_          "
	DC.B	" THE MEDWAY BOYS_          "
	DC.B	" THE MOB ON ICELAND_          "
	DC.B	" THE MONSTER_          "
	DC.B	" THE MR MEN_          "
	DC.B	" THE OVERLANDERS_          "
	DC.B	" THE POMPEY PIRATES_          "
	DC.B	" THE QUARTET_          "
	DC.B	" THE REPLICANTS_          "
	DC.B	" THE REST OF THE SOURCE_          "
	DC.B	" THE UNION_          "
	DC.B	" WEASEL_          "
	DC.B	"                    "
	DC.B	" I MUST APOLOGISE TO THE REST OF THE SOURCE   "
	DC.B	" ESP JUMPING JACK FLASH FOR BEING FASTER THAN NORMAL"
	DC.B	" WITH MY MENUS    "
	DC.B	" SO FAR THE LAST MENU WHICH I HAVE SEEN BY ANY OTHER"
	DC.B	" MEMBER OF THE GROUP WAS DISK SIXTEEN      I WAS TOLD TO"
	DC.B	" LEAVE SEVENTEEN AND EIGHTEEN FOR FROSTY  AND NUMBER"
	DC.B	" TWENTY FOR DAL SNUFFS  SO I FINISHED DISK NINETEEN"
	DC.B	" A FEW DAYS AGO AND HAVE NOW DONE NUMBER TWENTY"
	DC.B	" ONE      SO I APOLOGISE TO THOSE PEOPLE WHO WILL HAVE"
	DC.B	" BIG GAPS IN THEIR COLLECTIONS_          "
	DC.B	" SORRY_               "
	DC.B	" AS ALWAYS    IF THERE ARE ANY CODERS   ARTISTS  "
	DC.B	" OR MUSICIANS WHO WOULD LIKE TO DO SOME WORK FOR US"
	DC.B	" THEN GET IN TOUCH_              "
	DC.B	" THATS IT FOR THIS TIME FOLKS_                    "
	DC.B	" BYE                                              "
	dc.b	"                    @"

tune_no		dc.l		1      ;change tune number here		
		even
music		incbin		teramis2.mus
piccy		incbin		menu21.pi1	;put degas piccy here
						;make sure PI1 format

filenames	dc.l		file1		;add as required
		dc.l		file2		;file 3 ,file 4 etc
		dc.l		file3		
		even
file1		dc.b		'noise.kal',0	;add as required
		even				;always use ,0
file2		dc.b		'player.kal',0	;and    even
		even
file3		dc.b		'sync.kal',0
		even

	********************************************************
	********************************************************
	********** L O O K   A B O V E   T H I S ***************
	********************************************************
	********************************************************


stopm_d		dc.b		7,$FF,6,0,8,0,9,0,$A,0

goldcols	dc.w		$000,$077,$066,$055,$044,$033,$022,$011 ; scroller colours!!
		dc.w		$000,$000,$000,$000,$000,$000,$000,$000
chop_set	incbin		CHOP2
lastpos		dc.l		0
whichshift	dc.l		0
whichlet	dc.l		0
workarea	dcb.l		3,0
offset		dc.l		31840
speed		dc.l		576*3
finpos		dc.l		0
messoff		dc.l		message

cla		dc.l		lastlaya
clb		dc.l		lastlayb
lastlaya	dcb.l		30,0
lastlayb	dcb.l		30,0
counta		dc.w		9
countb		dc.w		8
screenset	dc.l		33440,36480,31520,31680
		dc.l		33920,33120,32160

change_wave	dc.l		0	;just a flag !!
wave_sav	dc.l		waveset
scr_sav		dc.l		screenset
screenoff	dc.l		32160
wave		dc.l		wave1
waveset		dc.l		wave2,wave3,wave4
		dc.l		wave5,wave6,wave7,wave1,-99

wave1		dcb.l		30,0
wave2		dcb.l		10,-160
		dcb.l		10,160
		dcb.l		10,-160
wave3		dcb.l		30,-160
wave4		dcb.l		30,160
wave5		dcb.l		15,160
		dcb.l		15,-160
wave6		dcb.l		15,-160
		dcb.l		15,160
wave7		dcb.l		8,-160
		dcb.l		8,160
		dcb.l		8,-160
		dcb.l		8,160

mstart		dcb.l		22,0
message		ds.l		4500    ;change if scroller becomes corrupted
		ds.b		256
screen2		ds.l		11000
stk_store	ds.l		100
		ds.l		40
mikes_stk	ds.l		40
chars		dcb.l		4608,0
shiftset	ds.l		1	;for 200k after this point is the preshifted char set
