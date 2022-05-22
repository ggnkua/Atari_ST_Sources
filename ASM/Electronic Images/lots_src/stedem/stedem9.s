;-----------------------------------------------------------------------;
; STE 24 hour Demo , programmed at the TLT convention Sweden 1991       ;
; Coded by : Martin Griffiths (Griff)					;
; Font by  : Lawrence Mcdonald(Master)					;
; Piccy converted by : The Phantom         				;
;-----------------------------------------------------------------------;

demo		EQU 0			; 1 for no traps

Start		
		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		ENDC

		MOVE #$2700,SR
		MOVE.L SP,oldsp
		LEA stack,SP
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,oldmfp
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		JSR shiftit			; preshift screen
		MOVEM.L $FFFF8240.W,D0-D7
		LEA oldmfp+32,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+	; save mfp
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.W $FFFF820E.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		move.b #$21,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		move.b #$21,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.L #first_vbl,$70.W
		MOVE.L #phbl,$68.W
		MOVE.L #topbord,$134.W
		MOVE.L log_base,A0
		MOVE #((16384*3)/16)-1,D0
		MOVEQ #0,D1
.clp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+			; clear screen(s)
		DBF D0,.clp
		LEA mt_data,A0
		BSR rotfile
		MOVE #80,$FFFF820E.W		; two screens wide
		MOVE #$2300,SR
MAINLOOP
waitkey		LEA log_base,A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		move vbl_timer,d0
.waitvb		cmp vbl_timer,d0
		beq.s .waitvb
		MOVEM.L curr_pal,D0-D6/A0
		MOVEM.L D0-D6/A0,$FFFF8240.W
		BSR playframe
		BSR calc_dist
		BSR calc_dist

scroll48	MOVE.L scr_point(PC),A3
		MOVE scrx(PC),D0
		TST switching
		BNE not_next
		ADDQ #8,scrlpos
		CMP #160,scrlpos
		BNE.S .ok
		CLR scrlpos		
.ok		ADD #384,D0
		CMP #3*384,D0
		BNE.S not_next
		ADDQ.L #1,A3
		MOVE.B 1(A3),D0
		BNE.S not_wrap
		LEA text(PC),A3
not_wrap	MOVE.L A3,scr_point
		MOVEQ #0,D0
not_next	MOVE D0,scrx
		CLR D1
		MOVE.B (A3)+,D1
		ADD D1,D1
		ADD D1,D1
		LEA char_tab(PC),A1
		MOVE.L (A1,D1),A0
		ADDA.W D0,A0
		MOVE.L log_base+4,A1
		ADD scrlpos(PC),A1
		MOVE.L A1,-(SP)
		LEA 640(A1),A1

		LEA 384(A0),A2
		CMP #2*384,D0
		BNE.S plot_end
case_4		CLR D0
		MOVE.B (A3),D0
		ADD D0,D0
		ADD D0,D0
		LEA char_tab(PC),A2
		MOVE.L (A2,D0),A2
i		SET 152
plot_end	eor #8,switching
		move switching(PC),d6
		REPT 47
		MOVEM.W (A0)+,D0-D3
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		MOVE.W (A2)+,D0
		MOVE.W (A2)+,D1
		MOVE.W (A2)+,D2
		MOVE.W (A2)+,D3
		ROR.L D6,D0
		ROR.L D6,D1
		ROR.L D6,D2
		ROR.L D6,D3
		MOVEM.W D0-D3,i(a1)
		MOVEM.W D0-D3,i-160(a1)
i		SET i+320
		ENDR
continue
		lea.l disttab(pc),a5
		add.w dist_ptr(pc),a5
		lea hbl1+4(pc),a1
i		SET 0
		rept 147
		move.l (a5)+,a0
		lea i*208(a0),a0
		move.l a0,Hsize*i(a1)
i		SET i+1	
		endr
		rept 53
		move.l (a5)+,a0
		add.l #i*208,a0
		move.l a0,Hsize*i(a1)
i		SET i+1	
		endr


		MOVE.L (SP)+,scrl_base
		BSR Fade_in
		BTST.B #0,$FFFFFC00.W
		BEQ waitkey
		CMP.B #$39+$80,$FFFFFC02.W
		BNE waitkey
		MOVE #$2700,SR
		LEA oldmfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.W (A0)+,$FFFF820E.W
		MOVE #$2300,SR
		IFEQ demo
		CLR -(SP)
		TRAP #1
		ENDC
		MOVE.L oldsp(PC),SP
		RTS
oldsp		DC.L 0

Fade_in		TST fadeing
		BEQ nofade
		SUBQ #1,fadeing1
		BNE nofade
		MOVE #4,fadeing1
		SUBQ #1,fadeing
		LEA curr_pal(PC),A0
		MOVE.L pic_ptr(PC),A1
		LEA 2(A1),A1		dest palette
		MOVEQ #15,D4
col_lp		MOVE (A0),D0		reg value
		MOVE (A1)+,D1		dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 		MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done		MOVE D0,(A0)+
		DBF D4,col_lp
nofade		RTS

pic_ptr		DC.L pic	
curr_pal	DS.W 16
fadeing		DC.W 7
fadeing1	DC.W 4
switching	DC.W 0
scr_point	DC.L text
scrx		DC.W 0
scrlpos		DC.W 0
scrl_base	dc.l 0
text		
 dc.b "                 WELCOME TO THE   ELECTRONIC IMAGES   STE DEMO   THE VERY FIRST ONE WE "
 DC.B "EVER DID     CREDITS FOR THIS SUPERLAME DEMO GO TOOOO     MASTER     THE FUCKING FONT    "
 DC.B "COUNT ZERO    THE SHIT MUSIC IN NOISETRACKER... THIS DEMO WAS CODED BY GRIFF IN TWENTY FOUR HOURS...... TRY TO DO THIS ON A STANDARD ST!!!!  "
 DC.B "RIP ANYTHING YOU WANT... MUSIC, GRAFIX, BUT FOR GODS SAKE DON'T TOUCH THE CODE OR "
 DC.B "GRIFF WILL GO MAD...       WELL, ENOUGH 0OF THE BULLSHIT... HERE I "
 DC.B "SIT AT THE END OF THE FEBRUARY TLT COPYPARTY... MASTER AND I HAVE JUST HAD A REALLY "
 DC.B "WEIRD SANDWICH     HOW WOULD YOU DESCRIBE THE SANDWICH, MASTER??     HE SAYS IT'S "
 DC.B "REALLY FUCKING WEIRD... A MIXURE OF SHIT AND SPICES... WHAT, ARE YOU WRITING THIS SHIT "
 DC.B "DOWN?    (AT THIS POINT, HE LEFT, SWEARING.)     TO GO WITH THE SANDWICH, WE ALSO HAD SOME "
 DC.B "VERY NICE SWEDISH CIDER WHICH IS MUCH NICER THAN THE CRAP IN ENGLAND.... WHO AM I, "
 DC.B "I HEAR YOU SHOUTING... TELL US WHO THE FUCK YOU ARE?  IT'S COUNT ZERO... THE FOOL WHO WAS "
 DC.B "PURSUADED TO DO THE MUSIC FOR THIS DEMO.   GRIFF IS ON THE OTHER TABLE IN FRONT OF ME, TRYING "
 DC.B "DESPERATELY TO FINISH THIS STE SCREEN, SINCE HE HASN'T GOT AN STE OF HIS OWN AND AFTER WE "
 DC.B "LEAVE SWEDEN, HE WON'T BE ABLE TO WORK ON THE SCREEN.       MASTER SAYS I HAVE TO PUT A JOKE IN "
 DC.B "THE SCROLLTEXT NOW, BECAUSE WE ARE RUNNING OUT OF THINGS TO SAY    SO....    THERE I WAS, WITH JULIE IN THE SACK, "
 DC.B "WHEN I THRUSTED HARD, AND BROKE HER BACK... (ARRGH... THAT WAS MASTER'S SICK LITTLE RHYME...)     "
 DC.B " OOOOOKKKKKKK TIME FOR THE GREETINGS, YEAH, RAA RAA, HOORAY...    WHO SHALL WE GREET... ERRRR .... "
 DC.B "I KNOW... WE'LL MAKE IT FUCKING IMPOSSIBLE FOR YOU TO READ THE GREETINGS, BECAUSE WE'RE TIRED AND SILLY... READY???    GO...  "
 DC.B "GREETINGS TO... ANCOOL(MAD,DRUNKANDWHATANICECARTRIDGE)TCB(GOODGAME,GOODGAME)TEXMADMAXTLT(THANKSFORINVITINGUSTOTHECOPYPARTY!!EVENIFWEDIDMISSTHEPIZZA,THEFUCKINGWEIRDSANDWICHESWEREGOOD)"
 DC.B "ELECTRA(FUCKINGGREATDEMO...GRIFFWASAMAZED...)TKTULMSYNC(WHENAREYOUGOINGTORELEASETHEFULLVERSIONOFAUDIOSCULPTURE??)THEEMPIRETOMMYGREENFACE(ALSODRUNK!)  AND A BIG GREETING TO WHO EVER KICKED THE DOOR TO THE SCHOOL IN... SILLY BOY   "
 DC.B "CAN'T THINK OF ANY MORE GREETINGS BECAUSE WE'RE TIRED (ME AND MASTER) AND SO WE'RE GOING TO TRY AND FIND SOMEWHERE TO SLEEP FOR TONIGHT... PROBABLY IN THE SNOW SOMEWHERE.)"
 DC.B "..... UNTIL THEN, KEEP WARM, STAY HAPPY, FEEL GIRLS, CODE SCREENS AND WAIT FOR THE NEXT INNER CIRCLE DEMO WHICH WILL BE AROUND LATER THAN YOU THINK... BYYYEEEEEEE            "
 DC.B "      ....... CHICKENSPLIT..        "
 DC.B 0
 
		EVEN


char_tab	rept 33
		dc.l bigfontspce
		endr
		dc.l bigfont+(30*1152)		; !
		dc.l bigfontspce 		; "
		dc.l bigfontspce 		; #
		dc.l bigfontspce 		; $
		dc.l bigfontspce 		; %
		dc.l bigfontspce 		; &
		dc.l bigfont+(29*1152)		; '
		dc.l bigfont+(32*1152)		; (
		dc.l bigfont+(33*1152)		; )
		dc.l bigfontspce 		; *
		dc.l bigfontspce 		; +
		dc.l bigfont+(28*1152)		; ,
		dc.l bigfont+(26*1152)		; -
		dc.l bigfont+(27*1152)		; .
		dc.l bigfontspce 		; /
		dc.l bigfontspce 		; 0
		dc.l bigfontspce 		; 1
		dc.l bigfontspce 		; 2
		dc.l bigfontspce 		; 3 
		dc.l bigfontspce 		; 4
		dc.l bigfontspce 		; 5
		dc.l bigfontspce 		; 6
		dc.l bigfontspce 		; 7
		dc.l bigfontspce 		; 8
		dc.l bigfontspce 		; 9
		dc.l bigfontspce 		; :
		dc.l bigfontspce 		; ;
		dc.l bigfontspce 		; <
		dc.l bigfontspce 		; =
		dc.l bigfontspce 		; >
		dc.l bigfont+(31*1152)		; ?
		dc.l bigfontspce 		; @
i		set 0
		rept 26
		dc.l bigfont+i
i		set i+1152
		endr

; Vbl sets of hbls etc

first_vbl	ADDQ #1,vbl_timer
		CMP #4,vbl_timer
		BNE.S .notyet
		MOVE.L #my_vbl,$70.W
.notyet		RTE

my_vbl		CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl1,$120.W
		MOVE.B #1,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W

		ADDQ #1,vbl_timer
		RTE

topbord		MOVE #$2100,sr
		STOP #$2100
		CLR.B $FFFFFA19.W
		DCB.W 78,$4E71
		CLR.B $FFFF820A.W
		DCB.W 18,$4E71
		MOVE.B #2,$FFFF820A.W
phbl		RTE
hbl1
		rept 200
		move.l a6,usp
		move.l #0,d7
		lea $ffff8203.w,a6
		movep.l d7,(a6)
		move.l usp,a6
		add.l #Hsize,$120.w
		rte
		endr
endh
Hsize		EQU (endh-hbl1)/200
		move.l a6,usp
		move.l scrl_base(PC),d7
		lea $ffff8203.w,a6
		movep.l d7,(a6)
		MOVE.L #$00000045,$FFFF8240.W
		MOVE.L #$01010212,$FFFF8240+4.W
		MOVE.L #$03230434,$FFFF8240+8.W
		MOVE.L #$05450034,$FFFF8240+12.W
		MOVE.L #$00010012,$FFFF8240+16.W
		MOVE.L #$00230000,$FFFF8240+20.W
		MOVE.L #$00000000,$FFFF8240+24.W
		MOVE.L #$00000000,$FFFF8240+28.W
		move.l usp,a6
		clr.b $fffffa1b.w
		move.b #26,$fffffa21.w
		move.l #hbl_bot,$120.w
		move.b #8,$fffffa1b.w
		move.b #100,$fffffa21.w
		rte

hbl_bot		MOVEM.L D0/A0,-(SP)
		MOVE #$FA21,A0
		MOVE.B (A0),D0
.syncb		CMP.B (A0),D0
		BEQ.S .syncb
noplist		DCB.W 129,$4E71 
		MOVE.B #0,$FF820A
		DCB.W 12,$4E71
		MOVE.B #2,$FF820A
		MOVEM.L (SP)+,D0/A0
		RTE
		
calc_dist	LEA dist_ang(PC),A1
		MOVE (A1),D0
		ADD dist_step(PC),D0
		AND #$3FF,D0
		MOVE D0,(A1)
		MOVE dister(pc),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S notwang
 		SUB maxi_dist(PC),D1
		MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
nrapwave	MOVE.L (A1)+,(A2)+
		MOVE.L A1,wave_ptr
notwang		MOVE D1,dister
		LEA trig_tab(PC),A0
		MOVE (A0,D0),D0
		MULS size(PC),D0
		LSL.L #2,D0
		SWAP D0
		ADD #48,D0
		MOVE dist_ptr(PC),D1
		ADDQ #4,D1
		CMP #200*4,D1
		BNE notendbuf
		CLR D1
notendbuf	MOVE.W D1,dist_ptr
		MOVE D0,D2
		lsr #1,d0
		and.w #$fff8,d0
		and #15,d2
		mulu #41600,d2
		lea preshifts,a2
		adda.l d2,a2
		adda.w d0,a2 
		LEA disttab(PC,D1),A0
		MOVE.L A2,(199*4)(A0)
		MOVE.L A2,-4(A0)
		rts

		dc.l preshifts
disttab		REPT 400
		DC.L preshifts+24
		ENDR


trig_tab	rept 2
		dc.l	$0000019B,$032304BE,$064507DE,$09630AF9,$0C7C0E0E 
		dc.l	$0F8C111A,$1293141B,$158F1710,$187D19F7,$1B5C1CCE 
		dc.l	$1E2B1F93,$20E62244,$238E24E1,$261F2766,$289929D4 
		dc.l	$2AFA2C27,$2D412E5F,$2F6B307B,$31783279,$33673458 
		dc.l	$35363616,$36E437B3,$3871392E,$39DA3A85,$3B203BB9 
		dc.l	$3C413CC7,$3D3E3DB0,$3E143E73,$3EC43F0F,$3F4E3F85 
		dc.l	$3FB03FD3,$3FEB3FFA,$40003FFA,$3FEB3FD2,$3FB03F83 
		dc.l	$3F4E3F0C,$3EC43E6F,$3E143DAB,$3D3E3CC1,$3C413BB2 
		dc.l	$3B203A7E,$39DA3926,$387137AA,$36E4360C,$3536344D 
		dc.l	$3367326E,$3178306F,$2F6B2E53,$2D412C1A,$2AFA29C6 
		dc.l	$28992758,$261F24D2,$238E2235,$20E61F83,$1E2B1CBE 
		dc.l	$1B5C19E7,$187D1700,$158F140A,$12931109,$0F8C0DFC 
		dc.l	$0C7C0AE8,$096307CC,$064504AC,$03230189,$0000FE64 
		dc.l	$FCDCFB41,$F9BAF821,$F69CF506,$F383F1F1,$F073EEE5 
		dc.l	$ED6CEBE4,$EA70E8EF,$E782E608,$E4A3E331,$E1D4E06C 
		dc.l	$DF19DDBB,$DC71DB1E,$D9E0D899,$D766D62B,$D505D3D8 
		dc.l	$D2BED1A0,$D094CF84,$CE87CD86,$CC98CBA7,$CAC9C9E9 
		dc.l	$C91BC84C,$C78EC6D1,$C625C57A,$C4DFC446,$C3BEC338 
		dc.l	$C2C1C24F,$C1EBC18C,$C13BC0F0,$C0B1C07A,$C04FC02C 
		dc.l	$C014C005,$C000C005,$C014C02D,$C04FC07C,$C0B1C0F3 
		dc.l	$C13BC190,$C1EBC254,$C2C1C33E,$C3BEC44D,$C4DFC581 
		dc.l	$C625C6D9,$C78EC855,$C91BC9F3,$CAC9CBB2,$CC98CD91 
		dc.l	$CE87CF90,$D094D1AC,$D2BED3E5,$D505D639,$D766D8A7 
		dc.l	$D9E0DB2D,$DC71DDCA,$DF19E07C,$E1D4E341,$E4A3E618 
		dc.l	$E782E8FF,$EA70EBF5,$ED6CEEF6,$F073F203,$F383F517 
		dc.l	$F69CF833,$F9BAFB53,$FCDCFE76
		endr
dist_ptr	DC.W 0
dist_ang	DC.W 0
dist_step	DC.W 4
maxi_dist	DC.W 512
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 2,512,20
		DC.W 2,512,10
		DC.W 4,512,20
		DC.W 6,512,30
		DC.W 8,512,40
		DC.W 6,1024,20
		DC.W 8,1024,8
		DC.W 8,512,30
		DC.W 8,1024,30
		DC.W -1

log_base	DC.L $f6000
		DC.L $fb000
vbl_timer	DC.W 0

; The rotfile(STE playback)

speed=49    timer d (pre-div 4)

rotfile:BRA.W mt_init
	BRA.W playframe
	BRA.W setpos

; Set position

setpos	AND #$FF,D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS
 	
playframe:
	BSR Vbl_play
	BSR mt_music
	RTS

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play:
	LEA ptrs(PC),A5
	MOVEM.L (A5),D0-D1
	EXG D0,D1
	MOVEM.L D0-D1,(A5)
	MOVE.L	D1,temp			
	MOVE.B	temp+1(pc),$ffff8903.w
	MOVE.B	temp+2(pc),$ffff8905.w
	MOVE.B	temp+3(pc),$ffff8907.w
	ADD.L #500,D1
	MOVE.L	D1,temp
	MOVE.B	temp+1(pc),$ffff890f.w
	MOVE.B	temp+2(pc),$ffff8911.w
	MOVE.B	temp+3(pc),$ffff8913.w
	MOVE.W	#%0000000000000001,$ffff8920.w
	MOVE.W	#1,$ffff8900.w
	
	LEA freqs(PC),A3
	LEA.L ch1s(PC),A5
	LEA chan1buf(pc),A0
	BSR add1
	LEA.L ch2s(PC),A5
	LEA chan2buf(pc),A0
	BSR add1
	LEA.L ch3s(PC),A5
	LEA chan3buf(pc),A0
	BSR add1
	LEA.L ch4s(PC),A5
	LEA chan4buf(pc),A0
	BSR add1
combine
	LEA chan1buf(PC),A0
	LEA chan2buf(PC),A1
	LEA chan3buf(PC),A2
	LEA chan4buf(PC),A3
	MOVE.L ptrs(PC),A4
	MOVEQ #0,D0
	MOVEQ #0,D1
	MOVE #$80,D2
	REPT 250
	MOVE.B (A0)+,D0
	MOVE.B (A1)+,D1
	ADD.W D0,D1
	LSR #1,D1
	EOR.B D2,D1
	MOVE.B D1,(A4)+
	MOVE.B (A2)+,D0
	MOVE.B (A3)+,D1
	ADD.W D0,D1
	LSR #1,D1
	EOR.B D2,D1
	MOVE.B D1,(A4)+
	ENDR
	RTS

; (fall through)
add1	MOVE.L (A5),A2			; current sample end address(shadow amiga!)
	MOVE.W 4(A5),D6			; sample length
	NEG.W D6
	MOVEM.W 6(A5),D1/D2		; period/volume
	ADD.W D1,D1
	ADD.W D1,D1
	MOVE.L 0(A3,D1),D1
	MOVE.W D1,D4
	SWAP D1
	LEA  vols(PC),A1
	CMP #-2,D6
	BNE.S .vcon
	MOVEQ.L	#0,D4
	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D2
.vcon	LSL.W #8,D2
	ADD.W D2,A1
	MOVEQ.L	#0,D2
	MOVEQ.L	#0,D3
	MOVEQ #124,D0
makelp	MOVE.B (A2,D6),D2
	MOVE.B (A1,D2),(A0)+
	ADD.W D4,D3
	ADDX.W D1,D6
	BCS.S lpvoice1
CONT1	MOVE.B (A2,D6),D2
	MOVE.B (A1,D2),(A0)+
	ADD.W D4,D3
	ADDX.W D1,D6
	DBCS  D0,makelp
	BCS.S lpvoice
CONT	NEG.W D6
	MOVE.L A2,(A5)
	MOVE.W D6,4(A5)
doneadd	RTS

lpvoice	MOVE.L 10(a5),A2		; loop addr
	MOVE.W 14(a5),D6		; loop length
	NEG.W D6
	CMP.W #-2,D6
	BEQ.S .vcoff
	DBF D0,makelp
	BRA.W CONT
.vcoff	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D4
	LEA  vols(PC),A1
	DBF D0,makelp
 	BRA.W CONT

lpvoice1
	MOVE.L 10(a5),A2		; loop addr
	MOVE.W 14(a5),D6		; loop length
	NEG.W D6
	CMP.W #-2,D6
	BNE.S CONT1
.vcoff	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D4
	LEA  vols(PC),A1
 	BRA.W CONT1

nulsamp	ds.l 1
	
;********************************************
;* ----- Protracker V1.1A Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1990  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; low B of n_cmd
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

; Initialise module

mt_init	MOVE.L	A0,mt_SongDataPtr
	LEA	mt_mulu(PC),A1
	MOVE.L	A0,D0
	ADDQ.L	#8,D0
	ADDQ.L	#4,D0
	MOVEQ	#$1F,D1
	MOVEQ	#$1E,D3
mt_lop4	MOVE.L	D0,(A1)+
	ADD.L	D3,D0
	DBRA	D1,mt_lop4
	LEA	$3B8(A0),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
mt_lop2 MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BLE.S	mt_lop
	MOVE.L	D1,D2
mt_lop	DBRA	D0,mt_lop2
	ADDQ.W	#1,d2
	ASL.L	#8,D2
	ASL.L	#2,D2
	LEA	4(A1,D2.L),A2
	LEA	mt_SampleStarts(PC),A1
	ADD.W	#$2A,A0
	MOVEQ	#$1E,D0
mt_lop3 CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.B	D1,2(A0)
	MOVE.W	(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	D3,A0
	DBRA	D0,mt_lop3
	LEA	mt_speed(PC),A1
	MOVE.B	#6,(A1)
	MOVEQ	#0,D0
	MOVE.B	D0,mt_SongPos-mt_speed(A1)
	MOVE.B	D0,mt_counter-mt_speed(A1)
	MOVE.W	D0,mt_PattPos-mt_speed(A1)
STspecific:
	LEA 	nulsamp+3(PC),A2
	LEA	ch1s(pc),A0
	BSR	initvoice
	LEA	ch2s(pc),A0
	BSR	initvoice
	LEA	ch3s(pc),A0
	BSR	initvoice
	LEA	ch4s(pc),A0
	BSR	initvoice
Init_Ste
	LEA.L setsam_dat(pc),a6
	MOVEQ	#3,d6
mwwritx:MOVE.W	#$7ff,$ffff8924.w
mwwritx2:
	CMP.W	#$07ff,$ffff8924.w
	BNE.S	mwwritx2
	MOVE.W	(a6)+,$ffff8922.w
	DBF	d6,mwwritx
	MOVE.L	#steshit1,temp			
	MOVE.B	temp+1(pc),$ffff8903.w
	MOVE.B	temp+2(pc),$ffff8905.w
	MOVE.B	temp+3(pc),$ffff8907.w
	MOVE.L	#steshit2,temp
	MOVE.B	temp+1(pc),$ffff890f.w
	MOVE.B	temp+2(pc),$ffff8911.w
	MOVE.B	temp+3(pc),$ffff8913.w
	MOVE.W	#%0000000000000001,$ffff8920.w
	MOVE.W	#1,$ffff8900.w
	rts

initvoice:
	MOVE.L	A2,(A0)			; point voice to nul sample
	MOVE.W	#2,4(A0)		
	MOVE.W	D0,6(A0)		; period=0
	MOVE.W	D0,8(A0)		; volume=0
	MOVE.L	A2,10(A0)		; and loop point to nul sample
	MOVE.W	#2,14(A0)
	RTS
ptrs		DC.L steshit1
		DC.L steshit2
steshit1	ds.b 500
steshit2	ds.b 500
chan1buf	ds.b 256
chan2buf	ds.b 256
chan3buf	ds.b 256
chan4buf	ds.b 256


setsam_dat:	dc.w	%0000000011010100  	*mastervol
		dc.w	%0000010010000110  	*treble
		dc.w	%0000010001000110  	*bass
		dc.w	%0000000000000001  	*mixer
temp		dc.l 0

ch1s	DS.W 8
ch2s	DS.W 8
ch3s	DS.W 8
ch4s	DS.W 8

mt_music
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PattPos(PC),D1

	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	MOVE.W	n_period(A6),6(A5)
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D6
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D6,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVEQ.l	 #0,D0
	MOVE.W	n_length(A6),D0
	ADD.W	D0,D0
	ADD.L	D0,(A5)			; point to end of sample
	MOVE.W	D0,4(A5)		; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.L	D0,-(SP)
	MOVEQ.L	#0,D0
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.W	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.W	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.W	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.W	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVE.L	(SP)+,D0

mt_dskip
	ADD.W	#16,mt_PattPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PattPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
mt_nnpysk
	CMP.W	#1024,mt_PattPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D6
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D6,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	RTS	

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PattPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.L D0,-(SP)
	MOVEQ #0,D0
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),D0
	ADD D0,D0
	ADD.L D0,(A5)
	MOVE.W D0,4(A5)			; Set length
	MOVEQ #0,D0
	MOVE.L	n_loopstart(A6),10(A5)	; loop sample ptr
	MOVE.L	n_replen(A6),D0
	ADD D0,D0
	ADD.L D0,10(A5)
	MOVE.W D0,14(A5)
	MOVE.L (SP)+,D0
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	CLR.B	n_funkoffset(A6)
	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS

mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
		dc.b 0

mt_PattPos	dc.w 0

mt_mulu		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

freqs		dc.l 0
		incbin D:\STEDEMO.INC\freq_49.bin
		even
vols		incbin D:\STEDEMO.INC\pt_volta.dat
		even
mt_data		incbin D:\STEDEMO.INC\waaa
		even

bigfontspce	DS.W 768
bigfont		INCBIN  D:\STEDEMO.INC\bigfont1.DAT
		even

; Preshift the picture.

shiftit		LEA pic+34,A0
		LEA preshifts,A1
		MOVE.L A1,A2
		MOVEQ #0,D0
copyfirst	MOVE #199,D6
.LP		
		MOVE.L 136(A0),(A1)+
		MOVE.L 140(A0),(A1)+
		MOVE.L 144(A0),(A1)+
		MOVE.L 148(A0),(A1)+
		MOVE.L 152(A0),(A1)+
		MOVE.L 156(A0),(A1)+
		REPT 20
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		ENDR	
		MOVE.L -160(A0),(A1)+
		MOVE.L -156(A0),(A1)+
		MOVE.L -152(A0),(A1)+
		MOVE.L -148(A0),(A1)+
		MOVE.L -144(A0),(A1)+
		MOVE.L -140(A0),(A1)+
		DBF D6,.LP
; a2 points to first preshift
		MOVE.L A2,A1		
		ADD.L #41600,A1
; a1 now points to second preshift		
		MOVEQ #14,D7
copyshift	MOVE.L A1,-(SP)
		MOVE.L #(41600/16)-1,D6
.LP		MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		MOVE.L (A2)+,(A1)+
		DBF D6,.LP
		MOVE.L (SP)+,A1
		MOVE #199,D6
.linelp		REPT 4
		LSL 200(A1)
		ROXL 192(A1)
		ROXL 184(A1)
		ROXL 176(A1)
		ROXL 168(A1)
		ROXL 160(A1)
		ROXL 152(A1)
		ROXL 144(A1)
		ROXL 136(A1)
		ROXL 128(A1)
		ROXL 120(A1)
		ROXL 112(A1)
		ROXL 104(A1)
		ROXL 96(A1)
		ROXL 88(A1)
		ROXL 80(A1)
		ROXL 72(A1)
		ROXL 64(A1)
		ROXL 56(A1)
		ROXL 48(A1)
		ROXL 40(A1)
		ROXL 32(A1)
		ROXL 24(A1)
		ROXL 16(A1)
		ROXL 8(A1)
		ROXL (A1)
		ADDQ #2,A1
		ENDR
		LEA 200(A1),A1
		DBF D6,.linelp
		DBF D7,copyshift
		RTS 

oldmfp		DS.L 22
pic		INCBIN D:\STEDEMO.INC\EAGLE.PI1
		SECTION BSS
		DS.L 129
stack		DS.L 2
preshifts	