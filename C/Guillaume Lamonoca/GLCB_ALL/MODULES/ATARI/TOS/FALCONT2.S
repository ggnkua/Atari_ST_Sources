;falcont2.s (module de base pour falcon (mode true color) (partie asm)
;a linker avec falcontc.c
;dans Options->Assembler choisir "Privileged Instructions"
;Guillaume LAMONOCA
;Supelec (94)
;Regis ROY
;Supelec (95)

;pour devpac 2, remplacer IF par IFD, et produire un objet DRI sur disk
;pour desactiver keymap[], donnez lui la valeur 0

KEYMAP	equ		1

	xref	lastvbl,vblflag,vblclock,mousex,mousey,fmousex,fmousey
	xref	statek,lstatek,swapflag,endflag,startflag,mousemode
	xref	pt_ecr_actif,pt_ecr_travail
	xref	mousebob,mousefond,lastbob,g_oldx,g_oldy
	xref	bufferflag,nbrbuffer,msebuffer,msebufptr,mousek
	xref	xmax,ymax,xcur,ycur,matrice,haut,larg,ecran,matrice2
	xref	recal,recal2,masque,masque2
	xref	psn,psv,psf,psadr,pslen
	xref	inuse,splstart,splcour,splend,splrep,splvol,splfreq,spl_tab
	xref	suiveuse,old_fa07,old_fa19,old_fa1f,old_118,old_134,old_400
	xref	keybbufptr,keybbuffer,adrunbuf,fbufnbr,fbuffer,fbufin,fbufout
	xref	kbdbuf,kbdptr,kbdcnt,codekey,keymap,kbufferflag,nbrkbuffer
	xref	bmsce,bmdst,bmlen,gc,roffset,tccolor,fbcolor

	xdef	mse_it,kbd_it,cls,swaps2,refreshscreen,bmovea,bmoveb
	xdef	copyba,putpba,affchara
	xdef	playsa

	xdef	initsblfunc,getsblrez,setsblrez,sblon

	
	IF KEYMAP
	xdef	unbuf
	ENDC




initsblfunc:
	move.l	#'OSBL',d0
	jsr	gc
	move.l	d0,fbase
	rts


;void getsblrez(INFO_BLOC **blact,INFO_BLOC **firstbloc)
;			 Renvoie l'adresse du premier bloc de resolution
;			 et l'adresse du bloc de resolution actuel

getsblrez:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	a0,a5
	move.l	a1,a6
	movem.l	a5/a6,-(a7)
	move.w	#1,d0
	move.l fbase,a4
	jsr	(a4)
	movem.l	(a7)+,a5/a6
	move.l	a0,(a5)
	move.l	a1,(a6)
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;void setsblrez(INFO_BLOC *newbloc)
;	 Se place dans la resolution definie par newbloc

setsblrez:
	movem.l	d3-d7/a2-a6,-(a7)
	move.l	a0,a5
	move.l	#0,oldst
	move.l	#1,d0
	bsr	_Spr
	tst.l	d0
	bne.b	nos
	move.l	#0,d0
	bsr	_Spr
	move.l	d0,oldst
nos:
	move.l	a5,a0
	move.w	#2,d0
	move.l fbase,a4
	jsr (a4)
	move.l	oldst,d0
	beq	nos2
	bsr	_Spr
nos2:
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;int sblon(void)		
; Renvoie 1 si la carte est en fonction sinon 0 

sblon:
	movem.l	d3-d7/a2-a6,-(a7)
	move	#3,d0
	move.l fbase,a4
	jsr (a4)
	movem.l	(a7)+,d3-d7/a2-a6
	rts

_Spr:
	move.l	d0,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts




mse_it:
			movem.l D0-D7/A0-A6,-(A7)
			move.l	$4ba,lastvbl
			addq #1,vblclock
			clr.b vblflag
			move fmousex,mousex
			move fmousey,mousey
			move.b statek,lstatek
			
			tst.b swapflag
			beq.s noswp
			
			move.l pt_ecr_actif,A0
			move.l pt_ecr_travail,pt_ecr_actif
			move.l A0,pt_ecr_travail

noswp:
			tst.b mousemode
			beq stop

			tst.b startflag
			beq.s suite

			tst.b swapflag
			bne.s swp
			
			tst.b endflag
			bne.s hid
			
			btst.b #5,lstatek
			beq.s suite
hid:
			move.l pt_ecr_actif,A1
			bra.s call
swp:
			move.l pt_ecr_travail,A1
call:
			bsr bloc

suite:
			tst.b endflag
			beq.s svte

			clr.b endflag
			clr.b mousemode
			bra.s stop
svte:		
			tst.b swapflag
			bne.s sivte
			tst.b startflag
			beq.s sivte

			btst.b #5,lstatek
			beq.s stop
sivte:
			st startflag
			bsr getback
			bsr bob
			move mousex,g_oldx
			move mousey,g_oldy	
			bclr.b #5,lstatek
stop:		
			clr.b swapflag

			move.b lstatek,statek

	IF KEYMAP
			move.l	adrunbuf,A2
			
fag:		
			tst.w	fbufnbr
			beq.s	ffend

			jsr (A2)
			bra.s	fag

ffend:		
			
	ENDC
			movem.l (A7)+,D0-D7/A0-A6
			rts


bob:
			move.l pt_ecr_actif,A1
			move.l A1,lastbob
			move mousex,D1
			lsl.w #1,D1
			ext.l D1
			adda.l D1,A1
			move mousey,D1
			mulu #640,D1
			adda.l D1,A1
			move.l mousebob,A0

			move #15,D3
			move.l #608,A2
			clr.l D6
			move mousex,D2
			cmp #304,D2
			blt.s ok
			subi.w #320,D2
			neg.w D2
			move.w D2,D3
			subq.w #1,D3
			lsl.w #1,D2
			move.l #640,A2
			suba.w D2,A2
			move.w D3,D6
			subi.w #15,D6
			neg.w D6
			lsl.w #1,D6
			ext.l D6
ok:
			move #15,D4
			move mousey,D2
			cmp #184,D2
			blt.s good
			subi.w #200,D2
			neg.w D2
			subq.w #1,D2
			move.w D2,D4
good:
			move.w D3,D5
lpal:
			move.w (A0)+,D0
			beq.s trsp
			move.w D0,(A1)
trsp:
			addq.l #2,A1
			dbf.w  D5,lpal
			adda.l A2,A1
			adda.l D6,A0
			dbf.w  D4,good
			rts

bloc:
			move.l lastbob,A1
			move g_oldx,D0
			move D0,D1
			lsl.w #1,D1
			ext.l D1
			adda.l D1,A1
			move g_oldy,D1
			mulu #640,D1
			adda.l D1,A1
			lea mousefond,A0

			move #15,D3
			move.l #608,A2
			clr.l D6
			move g_oldx,D2
			cmp #304,D2
			blt.s okg2
			subi.w #320,D2
			neg.w D2
			move.w D2,D3
			subq.w #1,D3
			lsl.w #1,D2
			move.l #640,A2
			suba.w D2,A2
			move.w D3,D6
			subi.w #15,D6
			neg.w D6
			lsl.w #1,D6
			ext.l D6
okg2:
			move #15,D4
			move g_oldy,D2
			cmp #184,D2
			blt.s goodg2
			subi.w #200,D2
			neg.w D2
			subq.w #1,D2
			move.w D2,D4
goodg2:
			move.w D3,D5
lpalg2:
			move.w (A0)+,(A1)+
			dbf.w  D5,lpalg2
			adda.l A2,A1
			adda.l D6,A0
			dbf.w  D4,goodg2
			rts
			
getback:
			move mousex,D0
			move.l pt_ecr_actif,A1
			move D0,D1
			lsl.w #1,D1
			ext.l D1
			adda.l D1,A1
			move mousey,D1
			mulu #640,D1
			adda.l D1,A1
			lea mousefond,A0

			move #15,D3
			move.l #608,A2
			clr.l D6
			move mousex,D2
			cmp #304,D2
			blt.s okg3
			subi.w #320,D2
			neg.w D2
			move.w D2,D3
			subq.w #1,D3
			lsl.w #1,D2
			move.l #640,A2
			suba.w D2,A2
			move.w D3,D6
			subi.w #15,D6
			neg.w D6
			lsl.w #1,D6
			ext.l D6
okg3:
			move #15,D4
			move mousey,D2
			cmp #184,D2
			blt.s goodg3
			subi.w #200,D2
			neg.w D2
			subq.w #1,D2
			move.w D2,D4
goodg3:
			move.w D3,D5
lpalg3:
			move.w (A1)+,(A0)+
			dbf.w  D5,lpalg3
			adda.l A2,A1
			adda.l D6,A0
			dbf.w  D4,goodg3
			rts







kbd_it:
	IF KEYMAP


			MOVEM.L	D0-D1/A0,-(A7)

			lea		$fffffc00,A0
			move.b	(A0),D0
			btst	#7,D0
			beq.s	fit_end
			btst	#0,D0
			beq.s	fit_end

			move.b	2(A0),D0

			lea		fbuffer,A0
			move.w 	fbufin,D1
			move.b	D0,0(A0,D1.w)
			addq.w	#1,D1
			andi.w	#$ff,D1
			move.w	D1,fbufin
			addq.w	#1,fbufnbr
			
fit_end:
			MOVEM.L	(A7)+,D0-D1/A0
			RTS
						
unbuf:		
			MOVEM.L	D0-D3/A0-A1,-(A7)
			lea		kbdbuf,A0

			lea		fbuffer,A1
			move.w	fbufout,D1
			clr.w	D0
			move.b	0(A1,D1.w),D0
			addq.w	#1,D1
			andi.w	#$ff,D1
			move.w	D1,fbufout
			subq.w	#1,fbufnbr

			tst.w	kbdcnt
			bne.s	kbody
			CMPI.w	#$F6,D0
			BLT.s	kkey
khead:
			clr.w	kbdptr
			cmp.w	#$FE,d0
			blt.s	kmse
			move.w	#2,kbdcnt
			bra.s	kbody
kmse:
			move.w	#3,kbdcnt
kbody:
			move.w	kbdptr,D1
			move.b	D0,0(A0,D1.w)
			addq.w	#1,kbdptr
			subq.w	#1,kbdcnt
			beq.s	msepack
			bra		it_end

kkey:
			clr.w	D1
			move.b	D0,D1
			andi.w	#127,D1
			lea		codekey,A0
			move.b	0(A0,D1.w),D1
			lea		keymap,A0

			btst	#7,D0
			beq.s	kdown
kup:
			clr.b	0(A0,D1.w)
			bra		it_end
			
kdown:
			move.b	#1,0(A0,D1.w)
			bsr 	put_in_kbuff
			bra		it_end
	ENDC
			MOVEM.L	D0-D3/A0-A1,-(A7)
msepack:
			MOVE.B	(A0),D3
			and.w	#$ff,d3
			cmp.w	#$fe,d3
			bge		joypack
			MOVE.B	D3,D1
			ANDI.B	#$F8,D1
			CMPI.B	#$F8,D1
			bne		it_end
			MOVE.B	1(A0),D0
			OR.B	2(A0),D0
			BNE.S	it_2
			BCLR.B	#5,statek
			BRA.S	it_1
it_2:
			BSET.B	#5,statek
			MOVE.W	fmousex,D0
			MOVE.B	1(A0),D1
			EXT.W	D1
			ADD.W	D1,D0
			MOVE.W	fmousey,D1
			MOVE.B	2(A0),D2
			EXT.W	D2
			ADD.W	D2,D1
			BSR		it_4
			MOVE.W	D0,fmousex
			MOVE.W	D1,fmousey
it_1:
			ANDI.W	#3,D3
			LSR.B	#1,D3
			BCC.S	it_0
			BSET	#1,D3
it_0:
			MOVE.B	statek,D1
			ANDI.W	#3,D1
			CMP.B	D1,D3
			BEQ		it_end
			MOVE.W	D3,mousek
			EOR.B	D3,D1
			ROR.B	#2,D1
			OR.B	D1,D3
			MOVE.B	D3,statek
			clr 	D0
			move.b	D3,D0
			andi	#$c0,D3
			beq.s	it_end
			tst.b	bufferflag
			beq.s	it_end
			move	nbrbuffer,D3
			cmp		#32,D3
			beq.s	it_end
			move	msebufptr,D2
			lea		msebuffer,A0
			move	D0,0(A0,D2.w)
			move	fmousex,2(A0,D2.w)
			move	fmousey,4(A0,D2.w)
			move	vblclock,6(A0,D2.w)
			addq	#8,D2
			andi	#255,D2
			addq	#1,D3
			move	D3,nbrbuffer
			move	D2,msebufptr
it_end:
			MOVEM.L	(A7)+,D0-D3/A0-A1
			RTS
joypack:
			lea		keymap,a1
			move.b	1(a0),d2
			move.b	d2,d0
			move.b	oldjoy,d1
			eor.b	d1,d0
			beq.b	it_end
			move.b	d2,oldjoy
			move.b	d2,d3
			move.b	d0,d1
			and.b	#1,d1
			beq.s	bas
			move.w	#'^',d1
			and.b	#1,d3
			beq		khautup
			move.b	#1,0(a1,d1.w)
			bsr 	put_in_kbuff
			bra.b	bas
khautup:
			clr.b	0(a1,d1.w)
bas:
			move.b	d0,d1
			and.b	#2,d1
			beq.s	gauche
			move.w	#'v',d1
			move.b	d2,d3
			and.b	#2,d3
			beq		kbasup
			move.b	#1,0(a1,d1.w)
			bsr		put_in_kbuff
			bra.b	gauche
kbasup:
			clr.b	0(a1,d1.w)
gauche:
			move.b	d0,d1
			and.b	#4,d1
			beq.s	droite
			move.w	#'<',d1
			move.b	d2,d3
			and.b	#4,d3
			beq		kgauup
			move.b	#1,0(a1,d1.w)
			bsr		put_in_kbuff
			bra.b	droite
kgauup:
			clr.b	0(a1,d1.w)
droite:
			move.b	d0,d1
			and.b	#8,d1
			beq		it_end
			move.w	#'>',d1
			move.b	d2,d3
			and.b	#8,d3
			beq		kdroitup
			move.b	#1,0(a1,d1.w)
			bsr 	put_in_kbuff
			bra		button
kdroitup:
			clr.b	0(a1,d1.w)
button:			
			move.b	d0,d1
			and.b	#$80,d1
			beq		it_end
			move.w	#' ',d1
			move.b	d2,d3
			and.b	#8,d3
			beq		kbutup
			move.b	#1,0(a1,d1.w)
			bsr 	put_in_kbuff
			bra		it_end
kbutup:
			clr.b	0(a1,d1.w)
			bra		it_end

			
it_4:
			TST.W	D0
			BGE.S	it_5
			CLR.W	D0
			BRA.S	it_6
it_5:
			CMP.W	xmax,D0
			BLE.S	it_6
			MOVE.W	xmax,D0
it_6:
			TST.W	D1
			BGE.S	it_7
			CLR.W	D1
			RTS
it_7:
			CMP.W	ymax,D1
			BLE.S	it_8
			MOVE.W	ymax,D1
it_8:
			RTS


put_in_kbuff:
			tst.b	kbufferflag
			beq		pikbend
			move	nbrkbuffer,D3
			cmp.w	#256,D3
			beq		pikbend
			move	keybbufptr,D2
			lea		keybbuffer,A0
			move.b	D1,0(A0,D2.w)
			addq	#1,D2
			andi	#255,D2
			addq	#1,D3
			move	D3,nbrkbuffer
			move	D2,keybbufptr
pikbend:	
			rts






;void cls(void)
cls:
		clr.w	xcur
		clr.w	ycur
		move.l pt_ecr_travail,A0
		move.w	fbcolor,D1
		swap D1
		move.w  fbcolor,D1
		move.w #31999,D0
w0:
		move.l D1,(A0)+
		dbf.w D0,w0
		
		rts


swaps2:
	move.l pt_ecr_travail,D0
	sub.l roffset,D0
	lsr #8,D0
	move.l D0,$FF8200
	st swapflag
	rts


;static void refreshscreen()
refreshscreen:
	move.l pt_ecr_actif,D0
	sub.l roffset,D0
	lsr #8,D0
	move.l D0,$FF8200
	st vblflag
	rts




bmovea:
		move.l bmsce,A0
		move.l bmdst,A1
		move.l bmlen,D0
lp:		move.b (A0)+,(A1)+
		subq.l #1,D0
		bne lp
		rts
		
		
bmoveb:
		move.l bmsce,A0
		move.l bmdst,A1
		move.l bmlen,D0
		adda.l D0,A0
		adda.l D0,A1
lpi:	move.b -(A0),-(A1)
		subq.l #1,D0
		bne lpi
		rts
		
		


copyba:
		move.w	larg,D2
		addq.w	#1,D2
		move.l	matrice,D0
		or.l	matrice2,D0
		or.w	D2,D0
		and.w	#3,D0
		beq fastc
		
		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
		move.w  larg,D2

l3z:
		move	D2,D1
l4z:
		move.w	(A0)+,(A1)+
		dbf		D1,l4z
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,l3z

		rts
fastc:
		move.l 	matrice,A0
		move.l	matrice2,A1
		move.w	haut,D0
		move.w	larg,D2
		addq.w	#1,D2
		lsr.w 	#1,D2
		subq.w	#1,D2
fl3z:
		move	D2,D1
fl4z:
		move.l	(A0)+,(A1)+
		dbf		D1,fl4z
		adda.l	recal,A0
		adda.l	recal2,A1
		dbf	 	D0,fl3z

		rts



putpba:
		move.l d3,-(a7)
		move.l matrice,A0
		move.l matrice2,A1		
		move.w haut,D0
		move.w larg,D2
cont_18b:
		move.w D2,D1 
cont_19b:      
		move.w (A0)+,D3
		beq.w trspp
		move.w D3,(A1)
trspp:
		addq.l #2,A1
		dbf.w  D1,cont_19b
		adda.l recal,A0
		adda.l recal2,A1
		dbf.w  D0,cont_18b
		move.l (a7)+,d3
		rts


		
affchara:
		movem.l d3-d7/a2,-(a7)
		move.w fbcolor,D5
		move.w tccolor,D6
		move.l ecran,A1
		move.l matrice,A0
		move.l	A0,A2
		adda.l	#8,A2
		move.w #7,D0
cont_c133:      
		move.b (A0)+,D2
		move.b (A2)+,D3

		move.w #7,D4
cont_c134:
		lsl.b #1,D2
		bcs.s crg1
		move.w D5,(A1)
crg1:
		lsl.b #1,D3
		bcc.s crg4
		move.w D6,(A1)
crg4:
		addq.l #2,A1

		dbf.w D4,cont_c134

		adda.l recal,A1
		dbf.w D0,cont_c133

		movem.l (a7)+,d3-d7/a2
		rts
		




playsa:
	MOVEM.L D0-D7/A0-A6,-(A7)

	TST.L	psadr
	BNE.S	playspl

stopspl:
	TST.B	inuse
	BEQ		plend
	PEA	stop_it(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	MOVEQ	#0,D0
	BRA		plend

playspl:
	TST.B	inuse
	BNE		plend
	MOVE.L	psadr,D0
	MOVE.L	D0,splstart
	MOVE.L	D0,splcour
	ADD.L	pslen,D0
	MOVE.L	D0,splend
	MOVE.W	psn,splrep
	MOVE.W	psv,splvol
	MOVE.W	psf,D0
	MOVE.W	D0,splfreq

	PEA	init_itspl(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	PEA	init_dosnd(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	PEA	level_128(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	PEA	init_sndchp(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	PEA	set_freq(PC)
	MOVE.W	#$26,-(A7)
	TRAP	#14
	LEA	$1E(A7),A7
	MOVE.L	#1,suiveuse
	MOVE.W	splfreq,D0
	EXT.L	D0
	ST		inuse
	BRA		plend

stop_it:
	BSR level_128
	BSR	restore_it
	CLR.L	suiveuse
	CLR.B	inuse
	RTS

level_128:
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	BCLR	#5,$FFFFFA07.W
	BCLR	#5,$FFFFFA0F.W
	MOVE.B	#8,$FFFF8800.W
	MOVE.B	#$D,$FFFF8802.W
	MOVE.B	#9,$FFFF8800.W
	MOVE.B	#9,$FFFF8802.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE.B	#8,$FFFF8802.W
	MOVE.W	(A7)+,SR
	RTS

restore_it:
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	BTST	#5,old_fa07
	BEQ.S	rst1
	MOVE.B	old_fa07,$FFFFFA07.W
	MOVE.B	old_fa19,$FFFFFA19.W
	MOVE.B	old_fa1f,$FFFFFA1F.W
	MOVE.L	old_134,$134.W
rst1:
	MOVE.L	old_118,$118.W
	MOVE.L	old_400,$400.W
	MOVE.W	(A7)+,SR
	RTS


set_freq:
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.W	splfreq,D0
	BSR	calc_freq
	PEA it_spl(PC)
	MOVE.W	D4,-(A7)
	MOVE.W	D5,-(A7)
	CLR.W	-(A7)
	MOVE.W	#$1F,-(A7)
	TRAP	#14
	LEA	$C(A7),A7
	MOVE.W	(A7)+,SR
	RTS

calc_freq:
	CMPI.W	#$32,D0
	BGE.S	cf1
	MOVEQ	#$32,D0
cf1:
	CMPI.W	#$4D58,D0
	BLE.S	cf2
	MOVE.W	#$4D58,D0
cf2:
	MOVE.W	D0,D2
	MOVE.L	#$00258000,D0
	DIVU	D2,D0
	SWAP	D0
	MOVE.W	D0,D1
	ADD.W	D1,D1
	CLR.W	D0
	SWAP	D0
	CMP.W	D2,D1
	BLT.S	cf3
	ADDQ.W	#1,D0
cf3:
	LEA	tab_freq(PC),A0
	MOVE.W	#$7FFF,D1
	MOVEQ	#7,D2
cf4:
	MOVE.L	D0,D3
	DIVU	(A0)+,D3
	CMPI.W	#$FF,D3
	BGT.S	cf5
	SWAP	D3
	CMP.W	D1,D3
	BGE.S	cf5
	MOVE.W	D3,D1
	SWAP	D3
	MOVE.W	D3,D4
	MOVE.W	D2,D5
cf5:
	CMPI.W	#1,D2
	DBEQ	D2,cf4
	MOVE.L	#$00258000,D0
	MOVEQ	#7,D1
	SUB.W	D5,D1
	ADD.W	D1,D1
	MOVE.W	D4,D2
	LEA	tab_freq(PC),A0
	MULU	0(A0,D1.W),D2
	DIVU	D2,D0
	MOVE.W	D0,splfreq
	RTS

tab_freq:
	DC.W	200,100,64,50,16,10,4

init_itspl:
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.B	$FFFFFA07.W,old_fa07
	BTST	#5,old_fa07
	BEQ.S	ii3
	MOVE.L	$134.W,old_134
	MOVE.B	$FFFFFA19.W,old_fa19
ii1:
	MOVE.B	$FFFFFA1F.W,D0
	CMPI.B	#1,D0
	BNE.S	ii1
ii2:
	MOVE.B	$FFFFFA1F.W,D0
	CMPI.B	#1,D0
	BEQ.S	ii2
	MOVE.B	$FFFFFA1F.W,old_fa1f
ii3:
	LEA		$90,A0
	MOVE.L	$118.W,old_118
	MOVE.L	$118.W,(A0)
	LEA	kbd_rt(PC),A0
	MOVE.L	A0,$118.W
	MOVE.L	$400.W,old_400
	LEA	ii4(PC),A0
	MOVE.L	A0,$400.W
	MOVE.W	(A7)+,SR
ii4:
	RTS


kbd_rt:
	MOVE.B	$FFFFFA09.W,-(A7)
	BCLR	#5,$FFFFFA09.W
	MOVE	SR,-(A7)
	MOVE.W	#$2500,SR
	TRAP	#4
	move	(A7)+,SR
	MOVE.B	(A7)+,$FFFFFA09.W
	RTE

init_dosnd:
	PEA	mes_dosnd(PC)
	MOVE.W	#$20,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
	RTS

mes_dosnd:
	DC.W	$FF00

init_sndchp:
	MOVE	SR,-(A7)
	ORI.W	#$700,SR
	MOVE.B	#7,$FFFF8800.W
	MOVE.B	$FFFF8800.W,D0
	ANDI.B	#$C0,D0
	ORI.B	#$3F,D0
	MOVE.B	D0,$FFFF8802.W
	MOVE.W	(A7)+,SR
	RTS


it_spl:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	CLR.W	D0
	
	MOVEA.L	splcour,A0
	MOVE.B	(A0)+,D0
	MOVE.W	splvol,D1
	BEQ.S	bv
	ASR.B	D1,D0
bv:
	ADDI.B	#128,D0
	MOVE.L	A0,splcour
	CMPA.L	splend,A0
	BNE.S	its4
	SUBQ.W	#1,splrep
	BNE.S	its2
	BSR	stop_it
	BRA.S	its5
its2:
	ADDQ.L	#1,suiveuse
	MOVE.L	splstart,splcour
its4:
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	LEA	$FFFF8800.W,A0
	LEA spl_tab,A1
	MOVE.B	0(A1,D0.W),0(A0)
	MOVE.B	1(A1,D0.W),2(A0)
	MOVE.B	2(A1,D0.W),0(A0)
	MOVE.B	3(A1,D0.W),2(A0)
	MOVE.B	4(A1,D0.W),0(A0)
	MOVE.B	5(A1,D0.W),2(A0)
its5:
	MOVEM.L	(A7)+,D0-D1/A0-A1
	BCLR	#5,$FFFFFA0F.W
	RTE

plend:
	MOVEM.L (A7)+,D0-D7/A0-A6
	rts

oldst:	ds.l	1
fbase:	ds.l	1


oldjoy:	dc.b 0
