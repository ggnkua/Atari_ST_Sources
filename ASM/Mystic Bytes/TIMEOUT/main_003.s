  		output		main.prg
print		macro
                move.w		#9,-(sp)
                trap 		#1
                addq.l 		#6,sp
                endm
;------------------------------------------------------------------------------            
            	clr.l 		-(sp)
            	move.w 		#$20,-(sp)
            	trap 		#1           
	        addq.l		#6,sp
;------------------------------------------------------------------------------	        
	        move.b		#18,$fffffc02.w	   	
;------------------------------------------------------------------------------
		move.w  	#363,d0
            	move.w  	d0,-(a7)
            	move.w  	#3,-(a7)                 ;VsetMode option
            	pea     	$370000	
            	pea     	$370000
            	move.w  	#5,-(a7)
            	trap    	#14
            	lea     	14(a7),a7
		move		d0,mode
		
		move.b 		#%110,$484.w
		move.l 		#trap_5,$88+8.w    
;------------------------------------------------------------------------------
                pea		begin
	   	print

		move.w		#7,-(sp)
		trap		#1
		addq.l		#2,sp
		
		cmp.b		#"o",d0
		beq.b		on
		move.b		#14,$fff8800
		move.b		$ffff8800,d0
		bclr		#5,d0
		move.b		#14,$fff8800
		move.b		d0,$fffff8802
		bra		set
on		move.b		#14,$fff8800
		move.b		$ffff8800,d0
		bset		#5,d0
		move.b		#14,$fff8800
		move.b		d0,$fffff8802
set
		pea 		clr_scr(pc)
		print
;------------------------------------------------------------------------------
	   	
	   	lea 		Module,a0
	   	lea 		out,a1
	   	bsr 		DEPACK
	   	
	   	lea 		out,a0
	   	lea		Module,a1
	   	move.l		#234650,d7
rew_module	move.b 		(a0)+,(a1)+
		subq.l 	 	#1,d7
		bne.b 		rew_module	   	
;------------------------------------------------------------------------------		
		bsr 		mul_instal
           	;----------------
           	moveq 		#5,d0
           	move.w 		#20,d1
          	trap 		#3
          	;----------------
          	lea 		task,a0
          	moveq 		#1,d0
          	trap 		#3                   
          	
		
		pea 		ok(pc)
		print
;------------------------------------------------------------------------------			   	
                pea 		init_spl(pc)
                print
;------------------------------------------------------------------------------			   	
	   	lea.l		Module,a0
	   	lea.l		WorkSpace,a1
	   	bsr		MGTK_Init_Module_Samples	; Initialise tout le bordel
;------------------------------------------------------------------------------			   	
	   	tst.w 		d0
	   	bpl.b 		no_prob_1
	   	pea 		error(pC)
	   	print 
	   	bra.b 		skip_music	   	
no_prob_1   	pea		ok(pc)
		print
;------------------------------------------------------------------------------			   	
		pea 		dsp_ini(pc)
		print
;------------------------------------------------------------------------------			   	
                bsr		MGTK_Init_DSP
;------------------------------------------------------------------------------			   	
  		tst.w		d0
                bpl.b 		no_prob_2
		pea		error(pc)
		print
		bra.b		skip_music
no_prob_2
		pea 		ok(pc)
		print
;------------------------------------------------------------------------------			   	
		bsr		MGTK_Save_Sound
	   	bsr		MGTK_Init_Sound
	   	moveq.l		#3,d0				; 32.78 KHz
	   	bsr		MGTK_Set_Replay_Frequency		
	   	st		MGTK_Restart_Loop		; Loop On
	   	bsr		MGTK_Play_Music
;------------------------------------------------------------------------------			   	
                
                
skip_music	pea		inf_task(pc)
		print
                
                 
          	pea		ok(pc)
          	print
          	
          	pea 		line(pc)
          	print   
          	
          	pea		load(pc)
          	print
          	
          	clr.b		ww       	
;---------------------------------------------------------------------------                                                                                                          
wait_		tst.b		flag
		beq.b		not_ready	
		
		tst.b		last
		beq.b		not_last
		st.b		exit
not_last        clr.b		flag
		moveq		#0,d0
		move.l		adr,a0
		jsr		(a0)
	  	
	  	tst.b		exit
	  	bne.b		last_ok	
 
not_ready	cmp.b		#1,$fffffffc02.w
		bne.b		wait_
;---------------------------------------------------------------------------                                                                                                          
last_ok	                	    	
	    	bsr		MGTK_Stop_Music
	    	bsr		MGTK_Restore_Sound
		
key		cmp.b		#1,$fffffc02.w
		bne.b		key

                move.w  	mode,-(a7)
            	move.w  	#3,-(a7)                ;VsetMode option
            	pea     	$370000
            	pea     	$370000
            	move.w  	#5,-(a7)
            	trap    	#14
            	lea     	14(a7),a7
		
                move.b		#8,$fffffc02.w
                move.l 		#$ffffffffffff,$ffffff9800.w 
            	move.w 		#2,d0
            	trap   		#3
;---------------------------------------------------------------------------                                                                                                                                
            	clr.l 		-(sp)
            	trap 		#1 
;---------------------------------------------------------------------------           
;ICE Depack routine as used in JAM packer V4.0
; Useage:	MOVE.L #$packed_data_start_address,A0
;		MOVE.L #$place_to_put_unpacked_data,A1
;		BSR	DEPACK
;---------------------------------------------------------------------------
         section text
DEPACK:
	;MOVE.W	$FFFF8240.W,-(SP)
	movem.l d0-a6,-(sp)
	ADDQ.L	#4,A0			;GET PAST ICE! HEADER
	bsr.s	ice04
	lea	-8(a0,d0.l),a5
	bsr.s	ice04
	move.l	d0,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.b	-(a5),d7
	bsr	ice06
	;MOVE.W	(SP)+,$FFFF8240.W
ice03:	movem.l (sp)+,d0-a6
	rts
ice04:	moveq	#3,d1
ice05:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,ice05
	rts
ice06:	bsr.s	ice0a
	bcc.s	ice09
	moveq	#0,d1
	bsr.s	ice0a
	bcc.s	ice08
	lea	ice17(pc),a1
	moveq	#4,d3
ice07:	move.l	-(a1),d0
	bsr.s	ice0c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice07
	add.l	20(a1),d1
ice08:	move.b	-(a5),-(a6)
	dbra	d1,ice08
ice09:	cmpa.l	a4,a6
	bgt.s	ice0f
	rts
ice0a:	add.b	d7,d7
	bne.s	ice0b
	move.b	-(a5),d7
	addx.b	d7,d7
ice0b:	rts
ice0c:	moveq	#0,d1
ice0d:	add.b	d7,d7
	bne.s	ice0e
	move.b	-(a5),d7
	;MOVE.W	D7,$FFFF8240.W
	addx.b	d7,d7
ice0e:	addx.w	d1,d1
	dbra	d0,ice0d
	rts
ice0f:	lea	ice18(pc),a1
	moveq	#3,d2
ice10:	bsr.s	ice0a
	dbcc	d2,ice10
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice11
	bsr.s	ice0c
ice11:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice13
	lea	ice19(pc),a1
	moveq	#1,d2
ice12:	bsr.s	ice0a
	dbcc	d2,ice12
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice0c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	ice15
	sub.w	d4,d1
	bra.s	ice15
ice13:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	ice0a
	bcc.s	ice14
	moveq	#8,d0
	moveq	#$3f,d2
ice14:	bsr.s	ice0c
	add.w	d2,d1
ice15:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice16:	move.b	-(a1),-(a6)
	dbra	d4,ice16
	bra	ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice17:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice18:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice19:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f
;------------------------------------------------
;LZW Depack routine for the JAM packer V4.0
;It is kept simple to minimise depack time.
;------------------------------------------------------
UNPACK:
	;MOVE.W	$FFFF8240.W,-(A7)
	MOVE.L	A0,A4
	MOVE.L	A1,A6
	ADDA.L	8(A0),A4
	ADDA.L	4(A0),A6
	MOVE.L	A6,A5			;KEEP COPY TO CHECK AGAINST
	MOVE.L	4(A0),D4
	MOVE.B	#$20,D3

	MOVE.W	#$0FED,D5
	MOVEA.L A6,A3			;KEEP ADDR OF END OF SPACES

	MOVEQ	#$00,D7			;START UNPACK ROUTINE
TOPDEP:	DBF	D7,NOTUSED
	MOVE.B	-(A4),D6		;GET COMMAND BYTE
	MOVEQ	#$07,D7
NOTUSED:
	LSR.B	#1,D6
	BCC.S	COPY			;BIT NOT SET, COPY FROM UNPACKED AREA 
	MOVE.B	-(A4),-(A6)		;COPY BYTES FROM PACKED AREA
	ADDQ.W	#1,D5
	SUBQ.L	#1,D4
	BGT.S	TOPDEP
	BRA.S	EXITUP
COPY:	MOVE.B	-2(A4),D0
	LSL.W	#4,D0
	MOVE.B	-(A4),D0
	;MOVE.W	D0,$FFFF8240.W
	SUB.W	D5,D0
	NEG.W	D0
	AND.W	#$0FFF,D0
	LEA	1(A6,D0.W),A0
	MOVEQ	#$0F,D1
	AND.B	-(A4),D1
	ADDQ.W	#2,D1
	MOVEQ	#$01,D0
	ADD.W	D1,D0
	CMPA.L	A5,A0
	BGT.S	SPACES
	
WRITE:	MOVE.B	-(A0),-(A6)
	DBF	D1,WRITE
BACK:	ADD.L	D0,D5
	SUB.L	D0,D4
	BGT.S	TOPDEP
EXITUP:	;MOVE.W	(A7)+,$FFFF8240.W
	RTS

SPACES: CMPA.L	A5,A0
	BLE.S	WRITE
	MOVE.B	D3,-(A6)		;COPY OUT SPACES
	SUBQ.L	#1,A0
	DBF	D1,SPACES
	BRA.S	BACK

;---------------------------------------------------------------------------	
trap_5		cmp.w		#1,d0
		bne.b		ch_n1
		lea		Videl_320_100_True,a0
		moveq		#-1,d0
		bsr 		Init_Video
  		clr.b		rez
  		rte
ch_n1		cmp.w		#2,d0
		bne.b		ch_n3
		lea		Videl_768_256_256,a0
		moveq		#-1,d0
		bsr		Init_Video
		move.w 		#%110,$fffff82c2.w						
		move.w  	#20,$fffff82a8
                clr.b		rez2
		rte
ch_n3		cmp.w		#3,d0
		bne.b		ch_n4
		bsr		DEPACK
		rte
ch_n4		cmp.w 		#4,d0
		bne.b		ch_n5
		move.w 		MGTK_Music_Position,d0
		move.w 		MGTK_Pattern_Position,d1
		rte
ch_n5           cmp.w		#5,d0
		bne.b		ch_n6
		lea		Videl_384_128_True,A0
		moveq		#-1,d0
		bsr		Init_Video
		move.w 		#%0001,$ffff82c2.w
            	move.w 		#20+10,$ffff8288.w 
            	move.w 		#180,$ffff828a.w 
            	move.w 		#170-35,$ffff82a8.w            
            	move.w 		#550-35+2,$ffff82aa.w
            	move.w 		#wide,$ff8210   
            	clr.b		rez
            	rte
wide        	= 		384	 
ch_n6		cmp.w		#6,d0	
		bne.b		ch_n7
		move.l		d1,d0
		bsr		MGTK_P56_Loader
ch_n7		cmp.w		#7,d0
		bne.b		ch_n8		
		lea		pic,a0
		rte		
ch_n8				
		rte  		

;---------------------------------------------------------------------------	
task        	tst.b 		ww
		bne.b		task

		move.w 		#0,-(sp)
		pea		n1(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer1
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap 		#1
		lea		12(sp),sp

		lea		bufer1,a0
		bsr 		relocate
		
		lea		bufer1,a0
		move.l  	a0,adr
		st		flag	
;----------------------------------------------				
not_yet_started	tst.b		flag
		bne.b		not_yet_started
		
		move.w 		#0,-(sp)
		pea		n2(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer3
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap 		#1
		lea		12(sp),sp

		lea		bufer3,a0
		lea		bufer2,a1
		bsr		UNPACK

		lea		bufer2,a0
		bsr 		relocate
		
		moveq		#1,d0
		jsr		bufer2	
	
		lea		bufer2,a0
		move.l  	a0,adr
		st		flag		
;----------------------------------------------		
not_yet_started2 tst.b		flag
		bne.b		not_yet_started2
		
rez_sw		tst.b		rez	
		bne.b		rez_sw
		
		move.w 		#0,-(sp)
		pea		n3(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer3
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap 		#1
		lea		12(sp),sp

		lea		bufer3,a0
		lea		bufer1,a1
		bsr		UNPACK


		lea		bufer1,a0
		bsr 		relocate
		
		moveq		#1,d0
		jsr		bufer1
	
		lea		bufer1,a0
		move.l  	a0,adr
		st		flag	
;----------------------------------------------		
not_yet_started3 tst.b		flag
		bne.b		not_yet_started3
		
		move.w 		#0,-(sp)
		pea		n4(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer2
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap 		#1
		lea		12(sp),sp

		lea		bufer2,a0
		bsr 		relocate
		
		moveq		#1,d0
		jsr		bufer2
	
		lea		bufer2,a0
		move.l  	a0,adr
		st		flag	
				
;----------------------------------------------		
not_yet_started4 tst.b		flag
		bne.b		not_yet_started4
		
		move.w 		#0,-(sp)
		pea		n5(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer1
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap #1
		lea		12(sp),sp


		lea		bufer1,a0
		bsr 		relocate
		
		
		moveq		#1,d0
		jsr		bufer1
		
		lea		bufer1,a0
		move.l  	a0,adr
		st		flag	
;----------------------------------------------		
not_yet_started5 tst.b		flag
		bne.b		not_yet_started5

		
		move.w 		#0,-(sp)
		pea		n6(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer2
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap #1
		lea		12(sp),sp

		lea		bufer2,a0
		bsr 		relocate
		
		moveq		#1,d0	
		jsr		bufer2
	
		lea		bufer2,a0
		move.l  	a0,adr
		st		flag	
;----------------------------------------------		
not_yet_started6 tst.b		flag
		bne.b		not_yet_started6

rez_sw2		tst.b		rez2	
		bne.b		rez_sw2
		
		move.w 		#0,-(sp)
		pea		n7(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer1
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap #1
		lea		12(sp),sp


		lea		bufer1,a0
		bsr 		relocate
		
		moveq		#1,d0	
		jsr		bufer1
	
		lea		bufer1,a0
		move.l  	a0,adr
		st		flag	
;----------------------------------------------		
not_yet_started7 tst.b		flag
		bne.b		not_yet_started7

		
		move.w 		#0,-(sp)
		pea		n8(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer2
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap #1
		lea		12(sp),sp


		lea		bufer2,a0
		bsr 		relocate
		
		moveq		#1,d0	
		jsr		bufer2
	
		lea		bufer2,a0
		move.l  	a0,adr
		st		flag
;----------------------------------------------		
not_yet_started8 tst.b		flag
		bne.b		not_yet_started8

		
		move.w 		#0,-(sp)
		pea		n9(pc)
		move.w 		#$3d,-(sp)
		trap 		#1
		addq.l 		#8,sp
		
		pea		bufer3
		move.l 		#-1,-(sp)
		move.w		d0,-(sp)
		move.w 		#$3f,-(sp)
		trap #1
		lea		12(sp),sp

		
		lea		bufer3,a0
		lea		bufer1,a1
		bsr		UNPACK



		lea		bufer1,a0
		bsr 		relocate
		
		moveq		#1,d0	
		jsr		bufer1
	
		lea		bufer1,a0
		move.l  	a0,adr
		st		flag
		st		last														
rr 		bra.b 		rr
;---------------------------------------------------------------------------	
ph_branch       EQU $00           ; Startbranch im Header    [Headerinfos]
ph_tlen         EQU $04-2         ; L„nge Textsegment
ph_dlen         EQU $08-2         ; L„nge Datasegment
ph_blen         EQU $0C-2         ; L„nge BSS-Segment
ph_slen         EQU $10-2         ; L„nge Symboltabelle
ph_res1         EQU $14-2         ; reserviert
ph_res2         EQU $18-2         ;     "
ph_flag         EQU $1C-2         ; res. bzw. Relozierflag
ph_len		    EQU	ph_flag+2
relocate:         
        	move.l  ph_tlen(A0),D0      
        	add.l   ph_dlen(A0),D0      
        	add.l   ph_slen(A0),D0      
        	lea     ph_len(A0,D0.l),A1  
        	lea     ph_len(A0),A0       
        	move.l  A0,D0               
        	move.l  (A1)+,D1            
        	beq.b   end_rel             
        	adda.l  D1,A0               
        	add.l   D0,(A0)             
        	moveq   #0,D1               
        	moveq   #1,D2               
rel_loop: 	move.b  (A1)+,D1            
        	beq   	end_rel             
        	cmp.b   D2,D1               
        	beq.b   add_254             
        	adda.l  D1,A0               
        	add.l   D0,(A0)             
        	bra.b   rel_loop            
add_254: 	lea     254(A0),A0          
        	bra.b   rel_loop            
end_rel:  	rts         
;---------------------------------------------------------------------------	            	include  d:\unimult4.s
            	include	 d:\unimult4.s
            	include  d:\amiga\video.s
            	Section	BSS
	    	ds.l		20832/4				; WorkSpace, Maxi 20832 octets
WorkSpace   	ds.l		1					; first of the BSS section
	    	incdir  d:\amiga\
	    	Include	'd:\amiga\AMGDSPI2.S'
;---------------------------------------------------------------------------                                               
		even
mode		ds.w 1
adr		ds.l 1
flag		ds.b 1
rez		dc.b 1
rez2		dc.b 1
in_progres	dc.b 0
last		dc.b 0
exit		dc.b 0
		even
;---------------------------------------------------------------------------                                               
clr_scr         
		dc.b "           Decrunching Nodule          -----> ",0
ok		dc.b "  OK!",13,10,0
error		dc.b "  ERROR!",13,10,0
;---------------------------------------------------------------------------                                             
init_spl	dc.b "           Initialising Module Samplse -----> ",0
dsp_ini		dc.b "           Initialising DSP            -----> ",0
swich		dc.b "           Swiching  To                -----> No Sound...",13,10,0
inf_task	dc.b "     ---------------------------------------------------",13,10
		dc.b "           Starting Background Task    -----> ",0
line		dc.b "     ---------------------------------------------------",13,10,0		
load		dc.b "           loading ....",13,10
                dc.b "     ---------------------------------------------------",13,10
                dc.b "           Decrunching ....",13,10
                dc.b "     ---------------------------------------------------",13,10,0
begin        	dc.b 27,"E"
        	dc.b "----------------------------------------------------------------",13,10  
        	dc.b "     ___.  _____  __.__    ______    _____   __.__    ___.      ",13,10
        	dc.b "    /   |__\   / /  |  \  /   __/sK!/     \ /  |  \  /   |__    ",13,10
        	dc.b "   /   ___/.\_/\/       \/    __)_ /   /   \   |   \/   ___/_   ",13,10
        	dc.b "  /    \    \   \    /   \    \   \\   \    /      /    \    \  ",13,10
        	dc.b "  \_________/___/___/____/________/ \______/\_____/\_________/  ",13,10
        	dc.b 13,10
        	dc.b "                 -  Mystic Bytes production '98  -",13,10,13,10                                                     
        	dc.b "                       speaker: [ "
        	dc.b 27,"p","O",27,"q","n; oFf ]",13,10,13,10      
        	dc.b "-----------------------------------------------------------------",13,10,0
       	        even
;---------------------------------------------------------------------------                                             
ww		dc.b 1
n1		dc.b "m1.dat",0
n2		dc.b "m2.dat",0
n3		dc.b "m3.dat",0
n4		dc.b "m4.dat",0
n5		dc.b "m5.dat",0
n6		dc.b "m6.dat",0
n7		dc.b "m7.dat",0
n8		dc.b "m8.dat",0
n9		dc.b "m9.dat",0
;---------------------------------------------------------------------------                                               
Module	    	IncBin	d:\pozostal.s\time_out.s\texmas8.dat		; last of the DATA section
out		ds.b 270000
pic		incbin	d:\hohoho\mess2.565
;---------------------------------------------------------------------------                                               
		section bss
bufer3		ds.b 310000
bufer1		ds.b 1200000
bufer2		ds.b 1200000
 
 