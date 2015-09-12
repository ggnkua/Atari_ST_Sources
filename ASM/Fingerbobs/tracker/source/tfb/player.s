;-------------------------------------------------------------------------
;
; Fingerbobs STE Soundtracker Module Player - For Demo Club
;
; Written by Oberje' 2/12/90 - 29/12/90 (c)1990 Fingerbobs
;
; Source code tidied and properly commented ( Some scrolltext too! )
; done on 1/1/91
;
; The code is in two fairly discrete parts. The Chooser part which
; is the section that lets the user choose a module and then loads
; it.
; The player is the part that plays the module and draws volume
; bars etc....
; The scroller routine was written in under an hour and it bloody
; worked first time!!!! ( Incredible!!! )
; Error during load causes directory re-read. So to change disks
; just put the new one in the drive and attempt to load something!
; ( This is however unreliable and will more often than not, hang
; the program instead!!! )
;
;-------------------------------------------------------------------------
; 2009/01/26	AJB		Verified buildable under Devapc 3
;						Verfied working under Steem 3.2
;						Config: 8MHz 1MB TOS 1.04
;-------------------------------------------------------------------------

	section	text

begin	jmp	go
	
	dc.b	" Fingerbobs STE Soundtracker Module Player"
	dc.b	" by Oberje' "
	dc.b	" (C)1991 Fingerbobs    "
	dc.b	"'Demo Club' Version    "
	dc.b	"          "

	even

save_sp	ds.l	1

go	bsr	reloc		; Relocate player
	bsr	do_btab		; Create table for Chooser section
	bsr	init		; Initialisation of screens etc..
	bsr	convert_message	; Convert scrolltext
	jsr	init_scroller	; Initialise Scroller routine
	clr.l	-(a7)		; Supervisor mode
	move.w	#$20,-(a7)	
	trap	#1
	addq.l	#6,a7
	move.l	d0,save_sp
	movem.l	$ffff8240.w,d0-d7	; Save old palette
	movem.l	d0-d7,old_pal		
.loop	bsr	chooser		; Choose a module screen
	tst.b	wanna_leave	;
	bne.s	.go		; Quit?
	bsr	player		; Play a module screen
	bra	.loop		; Repeat till dead....
.go	movem.l	old_pal,d0-d7	
	movem.l	d0-d7,$ffff8240.w	; Restore Palette
	move.l	save_sp,-(a7)
	move.w	#$20,-(a7)	; User Mode
	trap	#1
	addq.l	#6,a7
	bsr	de_init		; De-Init
	clr	-(a7)		; Exit
	trap	#1

;-------------------------------------------------------------------------
; Save old screen vars and set new
;-------------------------------------------------------------------------
init	move.w	#4,-(a7)	;
	trap	#14		;
	addq.l	#2,a7		;
	move.w	d0,old_res	; Old resolution
	move.w	#3,-(a7)	;
	trap	#14		;
	addq.l	#2,a7		;
	move.l	d0,old_screen	; Old screen address
	move.l	#new_screen,d0	;
	addi.l	#512,d0		;
	move.b	#0,d0		;
	move.l	d0,screen_1	;
	clr.w	-(a7)		; Set screen
	move.l	screen_1,-(a7)	;
	move.l	(a7),-(a7)	;
	move.w	#5,-(a7)	;
	trap	#14		;
	lea	12(a7),a7	;
	rts			;
	
;-------------------------------------------------------------------------
; Restore screen
;-------------------------------------------------------------------------
de_init	move.w	old_res,-(a7)	; Restore screen
	move.l	old_screen,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	rts


;--------------------------------------------------------------------------
; A1 = Source
; A5 = Destination
;
; Routine to uncompress a PC1 file. Written by Undercover Elephant.
; It is much better than my routine to do the same!!!
;--------------------------------------------------------------------------
uncomp_degas		
	move.w	#200-1,d5
bpllp2	move.l	a5,a3
	move.w	#4-1,d6
bpllp1	move.l	a3,a0
	lea	160(a0),a2
again	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.w	#127,d0
	bgt	type2
type1	move.b	(a1)+,(a0)+
	move.l	a0,d7
	lsr.w	#1,d7
	bcs.s	tp1skip
	addq.l	#6,a0
tp1skip	dbf	d0,type1
	cmp.l	a2,a0
	bge.s	bpl_end
	bra	again
type2	neg.b	d0
	move.b	(a1)+,d1
tp2loop	move.b	d1,(a0)+
	move.l	a0,d7
	lsr.w	#1,d7
	bcs.s	tp2skip
	addq.l	#6,a0
tp2skip	dbf	d0,tp2loop
	cmp.l	a2,a0
	bge.s	bpl_end
	bra	again
bpl_end	addq.l	#2,a3
	dbf	d6,bpllp1
	add.l	#160,a5
	dbf	d5,bpllp2
	rts

;-------------------------------------------------------------------------
; The CHOOSER part of the program
;-------------------------------------------------------------------------
chooser	movem.l	nullcols,d0-d7	; Paint it Black!
	movem.l	d0-d7,$ffff8240.w
	move.w	#$2700,sr	; Uncomp PC1 screen
	lea	picture2,a1	;
	move.l	screen_1,a5	;
	adda.l	#6,a5		;
	bsr	uncomp_degas	;
	move.w	#$2300,sr	;
	lea	$ffff8240.w,a0	; Set Palette
	move.l	#$00000777,(a0)+
	move.l	#$03330444,(a0)+
	move.l	#$05550666,(a0)+
	move.l	#$07770700,(a0)+
	move.l	#$08880222,(a0)+
	move.l	#$03330444,(a0)+
	move.l	#$05550666,(a0)+
	move.l	#$07770700,(a0)+
	move.w	#0,$ffff8900.w	; DMA Sound Disabled
	move.l	#s_start,d0	; Sample Start
	move.b	d0,$ffff8907.w
	asr.w	#8,d0
	move.b	d0,$ffff8905.w
	swap	d0
	move.b	d0,$ffff8903.w
	move.l	#s_end,d0	; Sample End
	move.b	d0,$ffff8913.w
	asr.w	#8,d0
	move.b	d0,$ffff8911.w
	swap	d0
	move.b	d0,$ffff890f.w
	move.w	#%10000001,d0	; MONO - 12KHz
	move.w	d0,$ffff8920.w
	move.w	#3,$ffff8900.w	; DMA Sound : Repeat frame forever
	move.w	#$2700,sr		; Block irq
	move.b	$fffffa07.w,old1	; Save
	move.b	$fffffa09.w,old2
	move.l	#null,$120.w		; Null HBL
	clr.b	$fffffa07.w		;
	clr.b	$fffffa09.w		; All IRQ's off!
	or.b	#1,$fffffa07.w		;
	or.b	#1,$fffffa13.w		; Except HBL!!
	move.w	#$2300,sr
	move.l	$70.w,old_vbl		; New VBL
	move.l	#choose_vbl,$70.w	
	move.b	#0,keypress		; No keypress ( yet! )
cont_error
	bsr	choose_main		; Main Loop!
	tst.b	wanna_leave	;
	bne.s	.skip		; Miss out Load if Exit selected
	lea	load_list,a0
	moveq	#0,d0
	move.w	file_at,d0
	add.w	d0,d0	
	add.w	d0,d0   
	move.w	d0,d1
	add.w	d0,d0 	
	add.w	d1,d0	
	lea	(a0,d0.w),a0	; A0=address of filename of file selected
	lea	fname,a1	; Copy!
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	bsr	load_in		; Try to load the file!
.skip	
	move.w	#0,$ffff8900.w	; DMA Sound Disabled
	move.w	#$2700,sr	; BLOCK irq
	move.l	#null,$120.w	; Null HBL again
	move.b	old1,$fffffa07.w	; Old
	move.b	old2,$fffffa09.w	;
	move.l	old_vbl,$70.w	; Old VBL
	move.w	#$2300,sr	;
	rts
;
; Status messages ( Bitmap )
;
stat_ok	dc.w	$7be7,$3e89,$e00e,$0090,$0000,$0000
	dc.w	$8088,$888a,$0211,$00a0,$0000,$0000
	dc.w	$708f,$8889,$c011,$00c0,$0000,$0000
	dc.w	$0888,$8888,$2211,$18a1,$8000,$0000
	dc.w	$f088,$887b,$c00e,$1891,$8000,$0000
stat_error
	dc.w	$7be7,$3e89,$e01f,$79e3,$9e00,$0000
	dc.w	$8088,$888a,$0210,$4514,$5100,$0000
	dc.w	$708f,$8889,$c01e,$79e4,$5e00,$0000
	dc.w	$0888,$8888,$2210,$5144,$5400,$0000
	dc.w	$f088,$887b,$c01f,$4d33,$9300,$0000
stat_loading
	dc.w	$7be7,$3e89,$e010,$71cf,$1c89,$e000
	dc.w	$8088,$888a,$0210,$8a28,$88ca,$0000
	dc.w	$708f,$8889,$c010,$8be8,$88aa,$6000
	dc.w	$0888,$8888,$2210,$8a28,$889a,$2000
	dc.w	$f088,$887b,$c01e,$722f,$1c89,$e000
stat_depacking
	dc.w	$7be7,$3e89,$e01e,$7de3,$8f24,$e44f
	dc.w	$8088,$888a,$0211,$4114,$5028,$4650
	dc.w	$708f,$8889,$c011,$79e7,$d030,$4553
	dc.w	$0888,$8888,$2211,$4104,$5028,$44d1
	dc.w	$f088,$887b,$c01e,$7d04,$4f24,$e44f
;
; Print status message
;
display_status			
	move.l	screen_1,a0
	adda.l	#$a0*194+2,a0
	moveq	#4,d7
.loop
	move.w	(a1)+,(a0)
	move.w	(a1)+,8(a0)
	move.w	(a1)+,16(a0)
	move.w	(a1)+,24(a0)
	move.w	(a1)+,32(a0)
	move.w	(a1)+,40(a0)
	lea	$a0(a0),a0
	dbf	d7,.loop
	rts
;
; VBL
;
choose_vbl				
	move.w	#$888,$ffff8250.w
	addq.l	#1,$466.w
	move.l	d0,-(a7)
	move.b	$fffffc02.w,d0	; Key keyboard byte
	btst	#7,d0		; Test 'PRESS'
	bne.s	.over		; Nope ( Ignore key releases )
	move.b	d0,keypress	; Save it for main program
.over	move.l	(a7)+,d0
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#1,$fffffa21.w	; 50 lines
	move.l	#ch_hbl_2,$120.w
	move.w	#21,nlines	; 40 Lines
	move.l	#rasters_1,at_raster
	move.b	#8,$fffffa1b.w	; TB On
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	do_scroller
	movem.l	(a7)+,d0-d7/a0-a6
	rte
nlines		ds.w	1
at_raster	ds.l	1
rasters_1		; 'Fingerbobs' Rasters
	dc.w	$aaa
	dc.w	$333
	dc.w	$bbb
	dc.w	$444
	dc.w	$ccc
	dc.w	$555
	dc.w	$ddd
	dc.w	$666
	dc.w	$eee
	dc.w	$777
	dc.w	$fff
	dc.w	$777
	dc.w	$eee
	dc.w	$666
	dc.w	$ddd
	dc.w	$555
	dc.w	$ccc
	dc.w	$444
	dc.w	$bbb
	dc.w	$333
	dc.w	$aaa
rasters_2		; 'THE DEMO CLUB' Rasters
	dc.w	$f00
	dc.w	$f80
	dc.w	$f10
	dc.w	$f90
	dc.w	$f20
	dc.w	$fa0
	dc.w	$f30
	dc.w	$fb0
	dc.w	$f40
	dc.w	$fc0
	dc.w	$f50
	dc.w	$fd0
	dc.w	$f60
	dc.w	$f60
	dc.w	$fe0
	dc.w	$fe0
	dc.w	$f70
	dc.w	$f70
	dc.w	$f70
	dc.w	$ff0
	dc.w	$ff0
	dc.w	$ff0
	dc.w	$ff0
	dc.w	$f70
	dc.w	$f70
	dc.w	$f70
	dc.w	$fe0
	dc.w	$fe0
	dc.w	$f60
	dc.w	$f60
	dc.w	$fd0
	dc.w	$f50
	dc.w	$fc0
	dc.w	$f40
	dc.w	$fb0
	dc.w	$f30
	dc.w	$fa0
	dc.w	$f20
	dc.w	$f90
	dc.w	$f10
	dc.w	$f80
	dc.w	$f00
barasters			; Barrel Rasters
	dc.w	$9,$f22
	dc.w	$2,$faa
	dc.w	$a,$f33
	dc.w	$3,$fbb
	dc.w	$b,$fbb
	dc.w	$4,$f44
	dc.w	$4,$f44
	dc.w	$c,$fcc
	dc.w	$c,$fcc
	dc.w	$5,$f55
	dc.w	$5,$f55
	dc.w	$d,$fdd	
	dc.w	$d,$fdd	
	dc.w	$6,$f66
	dc.w	$6,$f66
	dc.w	$6,$fee	
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$12f,$fff	; Centre
	dc.w	$6,$fee	
	dc.w	$6,$f66
	dc.w	$6,$f66
	dc.w	$d,$fdd	
	dc.w	$d,$fdd	
	dc.w	$5,$f55
	dc.w	$5,$f55
	dc.w	$c,$fcc
	dc.w	$c,$fcc
	dc.w	$4,$f44
	dc.w	$4,$f44
	dc.w	$b,$fbb
	dc.w	$3,$fbb
	dc.w	$a,$f33
	dc.w	$2,$faa
	dc.w	$9,$f22
	dc.w	0,$222
ch_hbl_2
	move.l	a0,usp
	move.l	at_raster,a0
	move.w	(a0)+,$ffff8250.w
	move.l	a0,at_raster
	move.l	usp,a0
	subq.w	#1,nlines
	beq.s	ch_hbl_2_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#2,$fffffa21.w	; 2 lines
	move.b	#8,$fffffa1b.w	; TB Off
	bclr.b	#0,$fffffa0f.w
	rte	
ch_hbl_2_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#4,$fffffa21.w	; 50 lines
	move.l	#ch_hbl_1,$120.w
	move.w	#41,nlines	; 40 Lines
	move.l	#barasters,at_raster
	move.b	#8,$fffffa1b.w	; TB On
	bclr.b	#0,$fffffa0f.w
	rte	
ch_hbl_1
	move.l	a0,usp
	move.l	at_raster,a0
	move.l	(a0)+,$ffff8240.w
	move.l	a0,at_raster
	move.l	usp,a0
	subq.w	#1,nlines
	beq.s	ch_hbl_1_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#2,$fffffa21.w	; 2 lines
	move.b	#8,$fffffa1b.w	; TB Off
	bclr.b	#0,$fffffa0f.w
	rte	
ch_hbl_1_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#2,$fffffa21.w	; 50 lines
	move.l	#ch_hbl_3,$120.w
	move.w	#39,nlines	; 40 Lines
	move.l	#rasters_2,at_raster
	move.b	#8,$fffffa1b.w	; TB On
	bclr.b	#0,$fffffa0f.w
	rte	
ch_hbl_3
	move.l	a0,usp
	move.l	at_raster,a0
	move.w	(a0)+,$ffff8250.w
	move.l	a0,at_raster
	move.l	usp,a0
	subq.w	#1,nlines
	beq.s	ch_hbl_3_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#2,$fffffa21.w	; 2 lines
	move.b	#8,$fffffa1b.w	; TB Off
	bclr.b	#0,$fffffa0f.w
	rte	
ch_hbl_3_end
	move.b	#0,$fffffa1b.w	; TB Off
	bclr.b	#0,$fffffa0f.w
	rte	
;-------------------------------------------------------------------------
; The interesting bit
;-------------------------------------------------------------------------
create_directory
	lea	dir_space,a0	; Clear out old directory
	move.w	#(16*20)-1,d7
	moveq	#0,d0
.clear_loop
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d7,.clear_loop

	pea	dta		; Set DTA
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	dir_space,a6	; Next Pos to write to.
	lea	load_list,a5	;
	move.b	#0,no_files	;

	move.w	#0,-(a7)	; Attrib	SFIRST
	pea	template	; Search
	move.w	#$4e,-(a7)
	trap	#1		; Sfirst
	addq.l	#8,a7
	tst.l	d0
	bmi	.end
.loop
	addq.b	#1,no_files
	lea	dta+30,a4	; Filename
	movem.l	(a4),d0-d2
	movem.l	d0-d2,(a5)
	lea	12(a5),a5	; Store in Load list
	bsr	in_show_list	; Draw onto show list
	lea	18*16(a6),a6
	
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.l	d0
	bpl.s	.loop		; Again if more files!
	
.end	rts

ender	ds.w	1

in_show_list
	sf.b	ender
	moveq	#9-1,d7
.letter_loop
	moveq	#0,d0
	move.b	(a4)+,d0	; Next char
	tst.b	ender		;
	beq.s	.ok		;
.blunk	move.w	#" ",d0
	bra.s	.ok2		; This code strips .MOD from listing
.ok	cmpi.b	#'.',d0
	seq.b	ender
	beq.s	.blunk
.ok2	subi.b	#32,d0		;
	asl.w	#5,d0		; x32	
	lea	dir_set,a0	;
	lea	(a0,d0.w),a0	;
	move.w	(a0)+,0*18(a6)	; Copy letter
	move.w	(a0)+,1*18(a6)
	move.w	(a0)+,2*18(a6)
	move.w	(a0)+,3*18(a6)
	move.w	(a0)+,4*18(a6)
	move.w	(a0)+,5*18(a6)
	move.w	(a0)+,6*18(a6)
	move.w	(a0)+,7*18(a6)
	move.w	(a0)+,8*18(a6)
	move.w	(a0)+,9*18(a6)
	move.w	(a0)+,10*18(a6)
	move.w	(a0)+,11*18(a6)
	move.w	(a0)+,12*18(a6)
	move.w	(a0)+,13*18(a6)
	move.w	(a0)+,14*18(a6)
	move.w	(a0)+,15*18(a6)
	lea	2(a6),a6
	dbf	d7,.letter_loop
	rts	
;-------------------------------------------------------------------------
; Create Barrel tables
; ( This combines the two displacement tables into a third
;   table. )
;-------------------------------------------------------------------------
do_btab
	lea	btab_1,a1	; Turn line numbers to line offsets
	move.w	#80-1,d7
.loop
	move.l	(a1),d0
	mulu	#18,d0
	andi.l	#$ffff,d0
	move.l	d0,(a1)+
	dbf	d7,.loop
	lea	btab_1,a1	; Turn X Displacement into
	lea	btab_2,a2	; Word offset & Pixel offset
	lea	btab_u,a3	; and store together with line offset
	move.w	#80-1,d7	; in new table!
.loopy
	move.l	(a1)+,(a3)+	; Line offset
	moveq	#0,d0
	move.b	(a2)+,d0
	move.w	d0,d1
	and.w	#$f,d1
	asr.w	#4,d0
	asl.w	#3,d0
	move.w	d0,(a3)+	; Word offset
	move.w	d1,(a3)+	; Pixel offset
	dbf	d7,.loopy

	rts

;-------------------------------------------------------------------------
; MAIN LOOP for CHOOSER
;-------------------------------------------------------------------------
choose_main
	lea	stat_ok,a1
	bsr	display_status	; OK!

	move.w	#0,file_at	; Initial stuff for barrel
	move.l	#show_space,list_at
	bsr	create_directory 
	subq.b	#1,no_files
	bsr	show_directory3
	sf.b	wanna_leave
	move.b	#0,keypress

.loop	move.w	#37,-(a7)	; VSYNC
	trap	#14		;
	addq.l	#2,a7		;
	move.b	keypress,d0	; Test for key
	tst.b	d0		;
	beq.s	.loop		;
	cmp.b	#$52,d0		; INSERT = Load
	beq	.exit
	cmp.b	#$48,d0		; Up Arrow
	beq	.up
	cmp.b	#$50,d0		; Down Arrow
	beq	.down
	cmp.b	#$44,d0		; F10 = Quit
	beq	.exit2
	bra	.loop
.exit	rts
.exit2	st.b	wanna_leave
	rts
	
.down	move.w	file_at,d0
	cmp.b	no_files,d0
	beq.s	.loop	
	addi.w	#1,d0
	move.w	d0,file_at
	moveq	#16,d6
.neep
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	add.l	#18,list_at
	bsr	show_directory3
	dbf	d6,.neep
	move.b	#0,keypress
	bra	.loop

.up	move.w	file_at,d0
	tst.b	d0
	beq	.loop	
	subi.w	#1,d0
	move.w	d0,file_at
	moveq	#16,d6
.neep2
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	sub.l	#18,list_at
	bsr	show_directory3
	dbf	d6,.neep2
	move.b	#0,keypress
	bra	.loop

wanna_leave	ds.w	1

;
; Actually draw the barrel
;
show_directory3			; Abnormal Barreling!
	move.l	screen_1,a6
	add.l	#5*8+$a0*45,a6
	lea	btab_u,a1
	move.l	list_at,d0
	moveq	#0,d1
	move.w	#80-1,d7
.loop
	move.l	(a1)+,a3	; Line offset
	lea	(a3,d0.l),a3	; Line address
	move.w	(a1)+,d5	; Word offset
	lea	(a6,d5.w),a0	; Word Address
	move.w	(a1)+,d1	; Pixel offset

cnt	set	8
	rept	9
	move.l	(cnt*2)-2(a3),d5
	asr.l	d1,d5
	move.w	d5,(cnt*8)(a0)
cnt	set	cnt-1
	endr

	lea	$a0(a6),a6
	dbf	d7,.loop
	rts

;-------------------------------------------------------------------------
; Load file!
;-------------------------------------------------------------------------
load_in	lea	stat_loading,a1
	bsr	display_status	; LOADING!
	move.w	#0,-(a7)
	pea	fname
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	Error
	move.w	d0,d7
	pea	music
	pea	$fffff	
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi	Error
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.l	d0
	bmi	Error
	move.l	#music,music_at	; Default
	lea	music,a0
	cmp.l	#"LSD!",(a0)
	beq	unpack
	rts
Error	
	lea	stat_error,a1
	bsr	display_status	; ERROR!
	lea	4(a7),a7
	bra	cont_error
	
unpack	lea	stat_depacking,a1
	bsr	display_status	; DEPACKING!
	move.l	#space,music_at
	lea	music,a0
	lea	space,a1
	bsr	DEPACK
	rts
;
; Automation 2.3 Depack code
;
; Enter A0 = Packed Data
;       A1 = Output to..
;
; Areas can overlap but A1 should be around
; 5k after A0
;
DEPACK	addq.l	#4,a0
	MOVEA.L	A0,A4
	MOVE.L	(A0)+,D5
	ADDA.L	D5,A1
	ADDA.L	(A0),A0
	SUBA.L	#4,A0
	TST.W	-(A0)			Test if it's a dummy.
	BPL.S	L652BC			NO. Valid data.
	SUBQ.L	#1,A0			Adjust it.
L652BC	MOVE.B	-(A0),D0
L652BE	LSL.B	#1,D0
	BNE.S	L652C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652C6	BCC.S	L65322			Go do the REPEATS.
	CLR.W	D1			Clear size count.
	LSL.B	#1,D0
	BNE.S	L652D2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652D2	BCC.S	L65316			If ZERO then its a 1 byte repeat
	LEA	L6530E(PC),A3		Lower table? BIT sizes.
	MOVEQ	#3,D3			Initial index.
L652DA	CLR.W	D1			Clear size count.
	MOVE.B	0(A3,D3.W),D2		Get the BITsize.
	EXT.W	D2			Clear the crap.
	MOVEQ	#-1,D4			Set all the bits.
	LSL.W	D2,D4			Fill with X zero bits.
	NOT.W	D4			Invert the BITS.
	SUBQ.W	#1,D2			Adjust bit size.
L652EA	LSL.B	#1,D0
	BNE.S	L652F2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652F2	ROXL.W	#1,D1			Collect the size.
	DBF	D2,L652EA
	TST.W	D3			??? No zeroes in the table.
	BEQ.S	L65302
	CMP.W	D1,D4
	DBNE	D3,L652DA
L65302	MOVE.B	4(A3,D3.W),D2		Upper table. ADJUSTMENTS.
	EXT.W	D2			Clear crap.
	ADD.W	D2,D1			Adjust JUNK's count size.
	BRA.s	L65316
L6530E	DC.B	$A,3,2,2,$E,7,4,1
L65316	MOVE.B	-(A0),-(A1)		Transfer BYTES of junk.
	DBF	D1,L65316
L65322	MOVEA.L	A4,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	gohome
	LEA	L65368(PC),A3		Little table.
	MOVEQ	#3,D2
L65332	LSL.B	#1,D0
	BNE.S	L6533A
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6533A	BCC.S	L65340
	DBF	D2,L65332
L65340	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3		Get the BIT size.
	BEQ.S	L6535C			If ZERO no more bit to collect.
	EXT.W	D3			Clear the crap.
	SUBQ.W	#1,D3			Adjust for looping
L6534E	LSL.B	#1,D0
	BNE.S	L65356
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L65356	ROXL.W	#1,D1
	DBF	D3,L6534E
L6535C	MOVE.B	5(A3,D2.W),D3		Get any ADJUSTMENTS.
	EXT.W	D3
	ADD.W	D3,D1
	BRA.s	L65372			Go to normal REPEAT routine.
L65368	DC.B	$A,2,1,0,0,$A,6,4	Little table.
	DC.B	3,2
L65372	CMPI.W	#2,D1			2byte repeat.
	BEQ.S	rep			Yeh. Use A3's small table.
	LEA	L653AC(PC),A3		ELSE use the big table.
	MOVEQ	#1,D3			Only two bits to collect.
L6537E	LSL.B	#1,D0
	BNE.S	L65386
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L65386	BCC.S	L6538C			If first bit zero then leave
	DBF	D3,L6537E
L6538C	ADDQ.W	#1,D3			Adjust index into the table.
	CLR.W	D2			UGH!!
	MOVE.B	0(A3,D3.W),D4		Fetch offset's bitsize.
	EXT.W	D4			Clear the crap.
L65396	LSL.B	#1,D0
	BNE.S	L6539E
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6539E	ROXL.W	#1,D2			Collect offset.
	DBF	D4,L65396
	LSL.W	#1,D3			Align with upper table.
	ADD.W	4(A3,D3.W),D2		Add the adjustment to the offset.
	BRA.S	L653DC			Go to MAIN repeat routine.
L653AC	DC.B	$B,4,7,0,1,$20		Offset bit sizes.
	DC.B	0,0,0,$20,0,0		Adjustments to the offsets.
rep	CLR.W	D2			Clear offset register.
	MOVEQ	#5,D3			SMALL 6bit offset
	CLR.W	D4			Set the ADJUSTER.
	LSL.B	#1,D0
	BNE.S	L653C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L653C6	BCC.S	L653CC			If CLEAR then small offset.
	MOVEQ	#8,D3			LARGE 9bit offset.
	MOVEQ	#$40,D4			Set the ADJUSTER.
L653CC	LSL.B	#1,D0
	BNE.S	L653D4
	MOVE.B	-(A0),D0		Reload the data register.
	ROXL.B	#1,D0			and shift first bit.
L653D4	ROXL.W	#1,D2			Collect the offset.
	DBF	D3,L653CC
	ADD.W	D4,D2			Add any ADJUSTER to offset.
L653DC	LEA	0(A1,D2.W),A2		Calc address of repeated string.
	EXT.L	D1			Clear the shit in the LENGTH.
	ADDA.L	D1,A2			LENGTH + address = string end.
	SUBQ.W	#1,D1			Adust LENGTH for looping.
L653E6	MOVE.B	-(A2),-(A1)		Transfer the bytes.
	DBF	D1,L653E6
	BRA	L652BE
gohome	RTS

;-------------------------------------------------------------------------	
; BYTESCROLLER Code
;-------------------------------------------------------------------------	
convert_message		; Convert messaage to ref. correct symbols etc...
	lea	message,a0
	lea	.chars,a1
.loop	moveq	#0,d0	; 99 - Blank, others -32 give actual pix data offsets
	move.b	(a0),d0
	beq.s	.end
	move.b	(a1,d0.w),d0
	move.b	d0,(a0)+
	bra.s	.loop
.end	rts
.chars	dc.b	99
	dc.b	99,99,99,99,99,99,99,99,99,99
	dc.b	99,99,99,99,99,99,99,99,99,99	
	dc.b	99,99,99,99,99,99,99,99,99,99
	dc.b	99,99,58,72,79,80,99,99,78,73
	dc.b	74,79,99,75,76,77,80,62,63,64
	dc.b	65,66,67,68,69,70,71,60,61,99
	dc.b	99,99,59,79,32,33,34,35,36,37
	dc.b	38,39,40,41,42,43,44,45,46,47
	dc.b	48,49,50,51,52,53,54,55,56,57,99
show_buffer	; Print buffer to screen
	move.l	screen_1,a1
	adda.l	#145*$a0,a1
	rept	10*25		
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	lea	2(a1),a1
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	lea	2(a1),a1
	endr
	rts
scroll_buffer	; Scroll a buffer
	rept	25
	movem.l	6(a0),d0-d7/a5-a6
	movem.l	d0-d7/a5-a6,(a0)
	movem.l	46(a0),d0-d7/a5-a6
	movem.l	d0-d7/a5-a6,40(a0)
	movem.l	86(a0),d0-d7/a5
	movem.l	d0-d7/a5,80(a0)
	lea	120(a0),a0
	endr
	rts
restart_letter
	move.l	#message,here	;Start of scrolltext
get_letter
	move.l	here,a0		;Get address of next letter's pix data
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.s	restart_letter
	move.l	a0,here
	cmpi.b	#99,d0	
	beq	do_space
	subi.b	#32,d0		;Get offset
	mulu	#26*12,d0	;Bytes per char
	lea	charset,a0
	lea	(a0,d0.w),a0
	move.l	a0,letter_at	
	rts
do_space
	move.l	#d_space,letter_at
	rts
init_scroller 
	move.l	#message,here	;Start of scrolltext
	move.l	#rout_1,do_scroller+2
	bsr	get_letter
	rts
do_scroller
	jmp	$0		; Jump to rout_1,2,3 or 4
				; one rout for each byte slice
				; of the scroller
rout_1	lea	buffer_2,a0
	bsr	show_buffer
	lea	buffer_1,a0
	bsr	scroll_buffer
	lea	buffer_1_end,a0
	lea	buffer_2_end,a2
	move.l	letter_at,a1
	rept	25
	move.b	0(a1),1(a0)
	move.b	2(a1),3(a0)
	move.b	4(a1),5(a0)
	move.b	1(a2),(a0)
	move.b	3(a2),2(a0)
	move.b	5(a2),4(a0)
	lea	20*6(a0),a0
	lea	12(a1),a1
	lea	20*6(a2),a2
	endr	
	move.l	#rout_2,do_scroller+2
	rts
rout_2	lea	buffer_1,a0
	bsr	show_buffer
	lea	buffer_2,a0
	bsr	scroll_buffer
	lea	buffer_2_end,a0
	move.l	letter_at,a1
	rept	25
	move.w	0(a1),0(a0)
	move.w	2(a1),2(a0)
	move.w	4(a1),4(a0)
	lea	12(a1),a1
	lea	20*6(a0),a0
	endr	
	move.l	#rout_3,do_scroller+2
	rts
rout_3	lea	buffer_2,a0
	bsr	show_buffer
	lea	buffer_1,a0
	bsr	scroll_buffer
	lea	buffer_1_end,a0
	lea	buffer_2_end,a2
	move.l	letter_at,a1
	rept	25
	move.b	6(a1),1(a0)
	move.b	8(a1),3(a0)
	move.b	10(a1),5(a0)
	move.b	1(a2),(a0)
	move.b	3(a2),2(a0)
	move.b	5(a2),4(a0)
	lea	20*6(a0),a0
	lea	12(a1),a1
	lea	20*6(a2),a2
	endr	
	move.l	#rout_4,do_scroller+2
	rts
rout_4	lea	buffer_1,a0
	bsr	show_buffer
	lea	buffer_2,a0
	bsr	scroll_buffer
	lea	buffer_2_end,a0
	move.l	letter_at,a1
	rept	25
	move.w	6(a1),0(a0)
	move.w	8(a1),2(a0)
	move.w	10(a1),4(a0)
	lea	12(a1),a1
	lea	20*6(a0),a0
	endr	
	bsr	get_letter
	move.l	#rout_1,do_scroller+2
	rts

;-------------------------------------------------------------------------
; PLAYER CODE
;-------------------------------------------------------------------------
player	movem.l	nullcols,d0-d7	; Paint it Black!
	movem.l	d0-d7,$ffff8240.w
	move.w	#$2700,sr
	lea	picture,a1
	move.l	screen_1,a5
	bsr	uncomp_degas
	move.w	#$2300,sr
	movem.l	piccols,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	show_module_name
	move.b	#0,pch0		; Previous Channel Indicators
	move.b	#0,pch1		; used when 'sliding' volume bars
	move.b	#0,pch2
	move.b	#0,pch3
	move.b	#$12,$fffffc02.w	; Tell mouse to fuck off
	move.w	#$2700,sr		; Block irq
	move.b	$fffffa07.w,old1	; Save
	move.b	$fffffa09.w,old2
	move.l	#null,$120.w		; Null HBL
	clr.b	$fffffa07.w		;
	clr.b	$fffffa09.w		; Kill MFP interrupts
	or.b	#1,$fffffa07.w		;
	or.b	#1,$fffffa13.w		; Except HBL!!
	move.w	#$2300,sr
	
	move.l	music_at,a0		; Module Address
	bsr	code+28+4		; Init Module
	move.l	$70.w,old_vbl		; New VBL
	move.l	#new_vbl,$70.w	
	bsr	code+28+8		; Start music

	move.b	#0,keypress		; No keypress ( yet! )

program move.w	#37,-(a7)	; VSYNC
	trap	#14		;
	addq.l	#2,a7		;
	bsr	bars		; Draw volume bars
	move.b	keypress,d0	; Test for key
	tst.b	d0		;
	beq.s	program		;
	move.w	#$2700,sr	; BLOCK irq
	move.l	#null,$120.w	; Null HBL again
	move.b	old1,$fffffa07.w	; Old
	move.b	old2,$fffffa09.w	;
	move.w	#$2300,sr	;
	move.b	#$8,$fffffc02.w	; Mouse back on
	move.l	old_vbl,$70.w	; Old VBL
	bsr	code+28+12	; Stop DMA sound
	move.l	screen_1,a0	; Clear screen
	move.w	#1999,d0
	moveq	#0,d1
.clean_it
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,.clean_it
	rts			

old_vbl	ds.l	1

	even

new_vbl	addq.l	#1,$466.w	; fr_clock4
	movem.l	d0-d7/a0-a6,-(a7)
	move.b	$fffffc02.w,d0	; Key keyboard byte
	btst	#7,d0		; Test 'PRESS'
	bne.s	.over		; Nope ( Ignore key releases )
	move.b	d0,keypress	; Save it for main program
.over	jsr	barvbl		; HBL controller
	jsr	code+28+16	; STE Soundtracker
	movem.l	(a7)+,d0-d7/a0-a6
	rte

keypress	ds.w	1

barvbl	move.l	#hbl1,$120.w	; Install HBL
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#58,$fffffa21.w	; 50 lines
	move.l	#hbl4,$120.w
	move.w	#28,nlines	; 40 Lines
	move.l	#rasters_3,at_raster
	move.b	#8,$fffffa1b.w	; TB On
	move.w	#$700,$ffff8242.w	; Set Bars to RED
	rts

null	bclr.b	#0,$fffffa0f.w
	rte

rasters_3
	dc.w	$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f	
	dc.w	$7,$e,$6,$d,$5,$c,$4,$b,$3,$a,$2,$9,$1,$0
	dc.w	$0

hbl4	move.l	a0,usp
	move.l	at_raster,a0
	move.w	(a0)+,$ffff8240.w
	move.l	a0,at_raster
	move.l	usp,a0
	subq.w	#1,nlines
	beq.s	hbl4_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#1,$fffffa21.w	; 2 lines
	move.b	#8,$fffffa1b.w	; TB Off
	bclr.b	#0,$fffffa0f.w
	rte	
hbl4_end
	move.b	#0,$fffffa1b.w	; TB Off
	move.b	#115-58-28,$fffffa21.w	; 50 lines
	move.l	#hbl1,$120.w
	move.b	#8,$fffffa1b.w	; TB On
	bclr.b	#0,$fffffa0f.w
	rte	

hbl1	move.b	#0,$fffffa1b.w
	move.w	#$070,$ffff8242.w	; Set Bars to GREEN
	move.b	#20,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr.b	#0,$fffffa0f.w
	move.l	#hbl2,$120.w
	rte

hbl2	move.b	#0,$fffffa1b.w
	move.w	#$007,$ffff8242.w	; Set Bars to BLUE
	move.b	#40,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr.b	#0,$fffffa0f.w
	move.l	#hbl3,$120.w
	rte

hbl3	move.b	#0,$fffffa1b.w
	move.w	#$750,$ffff8242.w	; Set Bars to BLUE
	bclr.b	#0,$fffffa0f.w
	rte
;
; Relocate .ROT file
; ( It is not pos independant! )
;
reloc	lea	code(PC),a0
	move.l	2(a0),d0
	add.l	$6(a0),d0
	add.l	$E(a0),d0
	lea	$1C(a0),a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,d1
	add.l	d0,a1
	move.l	(a1)+,d0
	add.l	d0,a2
	add.l	d1,(a2)
	moveq	#0,d0
rel_lp	move.b	(a1)+,d0
	beq.s	reldone
	cmp.b	#1,d0
	beq.s	rel_1
	add.l	d0,a2
	add.l	d1,(a2)
	bra.s	rel_lp
rel_1	lea	$fe(a2),a2
	bra.s	rel_lp
reldone	rts

step	equ	7
line	equ	102

bars	moveq	#0,d0
	move.b	code+48,d0	; Ch0
	moveq	#0,d1
	move.b	pch0,d1
	cmp.b	d0,d1
	bls.s	.ch0
	move.b	d1,d0
	subq.b	#step,d0
.ch0	
	move.b	d0,pch0
	lsr.b	#2,d0		; 6 Bits only
	move.l	screen_1,a0
	adda.l	#line*$a0+8*6,a0
	bsr	draw_bars	;

	moveq	#0,d0
	move.b	code+49,d0	; Ch1
	moveq	#0,d1
	move.b	pch1,d1
	cmp.b	d0,d1
	bls.s	.ch1
	move.b	d1,d0
	subq.b	#step,d0
.ch1	
	move.b	d0,pch1
	lsr.b	#2,d0		; 6 Bits only
	move.l	screen_1,a0
	adda.l	#line*$a0+8*8,a0
	bsr	draw_bars	;

	moveq	#0,d0
	move.b	code+50,d0	; Ch2
	moveq	#0,d1
	move.b	pch2,d1
	cmp.b	d0,d1
	bls.s	.ch2
	move.b	d1,d0
	subq.b	#step,d0
.ch2
	move.b	d0,pch2
	lsr.b	#2,d0		; 6 Bits only
	move.l	screen_1,a0
	adda.l	#line*$a0+8*10,a0
	bsr	draw_bars	;

	moveq	#0,d0
	move.b	code+51,d0	; Ch3
	moveq	#0,d1
	move.b	pch3,d1
	cmp.b	d0,d1
	bls.s	.ch3
	move.b	d1,d0
	subq.b	#step,d0
.ch3
	move.b	d0,pch3
	lsr.b	#2,d0		; 6 Bits only
	move.l	screen_1,a0
	adda.l	#line*$a0+8*12,a0
	bsr	draw_bars	;
	rts

draw_bars
	move.l	d0,d1
	lea	bar_data,a1
	asl.l	#7,d1
	lea	(a1,d1.w),a1
xx	set	0
	rept	64
	move.w	(a1)+,xx(a0)
xx	set	$a0+xx
	endr
	rts

show_module_name	; Print ( Centered ) Module name ( 20 Chars )
	move.l	music_at,a0
	moveq	#0,d0
	moveq	#20-1,d1
.loop	tst.b	(a0)+
	beq.s	.over
	addq.b	#1,d0		; D0 = No of Chars used.
	dbf	d1,.loop
.over
	move.l	d0,d7
	subi.w	#20,d0
	neg.w	d0		; d0 = 20 - d0
	asr.b	#1,d0		; d0 = d0 / 2

	move.l	music_at,a1
	move.l	screen_1,a6
	add.l	#$a0*11,a6
	asl.l	#3,d0
	lea	(a6,d0.w),a6
	subq.w	#1,d7		; For DBF		
.letter_loop
	moveq	#0,d1
	move.b	(a1)+,d1
	cmp.b	#"a",d1
	blt.s	.ego
	sub.b	#$20,d1
.ego	subi.b	#32,d1		;
	asl.w	#5,d1		; x32	
	lea	dir_set,a0	;
	lea	(a0,d1.w),a0	;
	move.w	(a0)+,0*$a0(a6)	; Copy letter
	move.w	(a0)+,1*$a0(a6)
	move.w	(a0)+,2*$a0(a6)
	move.w	(a0)+,3*$a0(a6)
	move.w	(a0)+,4*$a0(a6)
	move.w	(a0)+,5*$a0(a6)
	move.w	(a0)+,6*$a0(a6)
	move.w	(a0)+,7*$a0(a6)
	move.w	(a0)+,8*$a0(a6)
	move.w	(a0)+,9*$a0(a6)
	move.w	(a0)+,10*$a0(a6)
	move.w	(a0)+,11*$a0(a6)
	move.w	(a0)+,12*$a0(a6)
	move.w	(a0)+,13*$a0(a6)
	move.w	(a0)+,14*$a0(a6)
	move.w	(a0)+,15*$a0(a6)
	lea	8(a6),a6
	dbf	d7,.letter_loop
	rts
;
; Common Data Area
;
screen_1	ds.l	1
old_screen	ds.l	1
old_pal		ds.w	16
old_res		ds.w	1
music_at	ds.l	1
old1		ds.l	1
old2		ds.l	1
;
; Player Data Area
;
bar_data
cc	set	1		; Nifty assembler directives
	rept	64		; to create bar data!!!
 	dcb.w	(64-cc),0
 	dcb.w   cc,-2
cc	set	1+cc
	endr

nullcols	dc.l	0,0,0,0,0,0,0,0

	even

pch0	ds.b	1
pch1	ds.b	1
pch2	ds.b	1
pch3	ds.b	1

code	incbin	..\rot\stev.rot	; Tracker .ROT

	even
	
pic	incbin	bar2hole.pc1	; Picture ( Player )
picture	equ	pic+34
piccols	equ	pic+2

pic2	incbin	bar3hole.pc1	; Other Picture ( Chooser )
picture2	equ	pic2+34
piccols2	equ	pic2+2

	even

;
; Chooser Data Area
;
fname	dc.b	"suburbia.mod",0,0

;-------------------------------------------------------------------------
; Data for Chooser
;-------------------------------------------------------------------------

btab_u	ds.b	8*80

btab_1	dc.l	21,28,33,36,39,42,44,47
	dc.l	49,51,53,55,57,59,61,63
	dc.l	64,66,67,69,70,72,73,75
	dc.l	76,77,78,79,80,81,82,83
	dc.l	84,85,86,87,88,89,90,91	   \ Centre of barrel
	dc.l	92,93,94,95,96,97,98,99    / ( Selection )
	dc.l	100,101,102,103,104,105,106,107
	dc.l	108,110,111,113,114,116,117,119
	dc.l	120,122,124,126,128,130,132,134
	dc.l	136,139,141,144,147,150,155,162	
	
btab_2	dc.b	0,3,5,7,8,9,10,10
	dc.b	11,11,11,12,12,12,12,13
	dc.b	13,13,13,13,14,14,14,14
	dc.b	14,14,14,15,15,15,15,15
	dc.b	16,16,16,16,16,16,16,16
	dc.b	16,16,16,16,16,16,16,16
	dc.b	15,15,15,15,15,14,14,14
	dc.b	14,14,14,14,13,13,13,13
	dc.b	13,12,12,12,11,11,11,11
	dc.b	10,10,9,8,7,5,3,0

show_space	ds.w	9*(17*5)
dir_space	ds.w	9*(17*25)
load_list	ds.b	12*20	
	
list_at	ds.l	1

dir_set		incbin	16.fnt

no_files	ds.w	1	; No of files read in directory search
file_at		ds.w	1

template	dc.b	"*.mod",0
	
	even

dta	ds.b	44


	even

in	incbin	sample1.sam
s_start	equ	in+12
	even
s_end	equ	s_start+59990

	even


;
; Scroller Vars
;

; Scrolltext
message	
 dc.b "                 "
 dc.b "       THE DEMO CLUB PROUDLY PRESENTS..........          T-H-E   F-I-N-G-E-R-B-O-B-S   S-T-E   S-O-U-N-D-T-R-A-C-K-E-R   M-O-D-U-L-E   P-L-A-Y-E-R                  "
 DC.B "      INSTRUCTIONS : USE THE CURSOR UP AND DOWN KEYS TO MOVE UP AND DOWN THE MODULE LIST.         PRESS INSERT TO LOAD THE HIGHLIGHTED MODULE.        "
 DC.B "      WHEN IN MODULE PLAYER, PRESS ANY KEY TO RETURN TO SELECTION SCREEN.        "
 DC.B " THE LOADER WILL AUTOMATICALLY UNPACK MODULES THAT HAVE BEEN PACKED WITH THE AUTOMATION PACKER! ( THATS A BIT HANDY!! )      "
 DC.B "    CREDITS FOR THIS AMAZING PROGRAM GO TO.........        "
 DC.B "    OBERJE : CODING AND SAMPLING ( SAMPLE IS 12KHZ OF 'JUSTIFY MY LOVE' BY MADONNA, IT IS A BIT REPETATIVE BUT IT IS GOOD QUALITY! )        "
 DC.B "     STICK OF RIPPED OFF : GIVING ME THE FONT USED ON THE 'BARREL'.        "
 DC.B "   THE BLACK CATS : FOR THIS FABBO TCB LIKE FONT. I RIPPED IT FROM THE DELIRIOUS DEMO.         "
 DC.B "   PIXAR : SOME GRAPHICS E.G THE FINGERBOBS LOGO ETC...      "
 DC.B "     UNDERCOVER ELEPHANT : THE DEGAS *.PC1 DECOMPACTER I HAVE USED. IT IS BETTER THAN MY ROUTINE!!!       "
 DC.B " ( FINGERBOBS CAN BE CONTACTED AT       6 CARRON TERRACE, STONEHAVEN, AB3 2HX, SCOTLAND         AND LET ME JUST MAKE IT CLEAR THAT I WILL PERSONALLY "
 DC.B "CASTRATE ANYONE WHO ADDRESSES STUFF TO ME IN 'ENGLAND'!!!!!!!!      )    "
 DC.B "        "
 DC.B " HERE ARE SOME DETAILS OF THE TRACKER. IT PLAYS WITH THE STEREO 12 KHZ DMA MODE. IT IMPLEMENTS ALL SOUNDTRACKER COMMANDS, BUT DOES NOT IMPLEMENT THE NOISETRACKER 'TONE PORTAMNETO' AND 'VIBRATO' COMMANDS. "
 DC.B " IT HAS REALTIME VOLUME VARIATION. IT TAKES APPROXIMATELY 55 PERCENT CPU TIME. THE SAMPLE RENDERING TECHNIQUE USED MEANS THAT THIS TIME CANNOT BE IMPROVED ON SIGNIFICANTLY, SO I AM ON THE LOOKOUT FOR A BETTER TECHNIQUE.  "
 DC.B "  THE ROUTINE IS NOT PERFECT "
 DC.B " ( NOT BY A LONG SHOT! ) BUT IT WILL PLAY MOST MODULES REASONABLY WELL.       "
 DC.B " BEFORE WE GO ANY FURTHER, HERE COME THE GREETINGS................."
 DC.B " HUGS AND KISSES TO.........     ALL INNER CIRCLE MEMBERS,    VANTAGE AND ST CONNEXION - YO DUDES! HOPE YOU LIKE MY PLAYER!,      SAMMY JOE AND THE LOST BOYS, ANOTHER JUICY ARTICLE ON ITS WAY!!!,      STICK AND BILBO OF RIPPED OFF "
 DC.B "- THE STE DISK WILL BE READY SOON! PROMISE!,    "
 DC.B "    FM OF THE STORM MASTERS - I LIKED YOUR FM TRACKER!,     JOHN PASS OF THE DEMO CLUB - I HOPE THIS PROGRAM IS WHAT YOU WERE LOOKING FOR!,      GORDON AT JUSAVO BBS,       ROB AND THE BOMB SQUAD,       CHARON AND NATO,  "      
 DC.B "    LEELEE,       FLASH,      SOMMERVI,     BOOTS,     HAXTY-BABES,      BRUNO,      DJ NANACUBE,     "
 DC.B "  JAKE AT CALEDONIA P.D.L - I WILL DO YOU SOMETHING AS SOON AS POSS!,     "
 DC.B "     FROSTY THE SNOWMAN,      MOB OF AUTOMATION - I WILL DO YOU AN INTRO REAL SOON!,      "
 DC.B "     MICRODEAL - THANX FOR SUCH PROMPT ACTION AT SENDING ME MY UPGRADE TO MASTERSOUND. THE NEW SOFTWARE IS FANTASTIC!!!,      "
 DC.B "      !!! BIG WET KISSES TO THE PEOPLE AT ST FORMAT FOR CHOOSING TO PRINT A PICTURE OF MY INNER CIRCLE SCREEN!!!!!!      "
 DC.B "     ADDITIONAL GREETS TO.......    THE EMPIRE - I REALLY LOVE YOUR NOISTRACKER,BUT WHEN ARE YOU GOING TO INCLUDE STE SUPPORT?,         THE CAREBEARS,     THE EXCEPTIONS,   GHOST,    VECTOR,    AND JUST ABOUT EVERY "
 DC.B "OTHER ST CREW WITH A FEW NOTABLE EXCEPTIONS, BUT I WON'T GO INTO THAT JUST NOW!!!!             HMM WELL I THINK "
 DC.B "THAT JUST ABOUT WRAPPS UP THE GREETINGS,   ...... APOLOGIES IF I MANAGED TO MISS YOU OUT THAT'S JUST LIFE!!!           "
 DC.B "    WELL I THINK IT'S TIME TO BREAK WITH THE BORING STUFF LETS HAVE SOME OF THESE..............................."
 DC.B ".......*******************.........AAAAAAAAAAAARRRRRRRRRRRRRGGGGGGH!........********......*******..........."
 DC.B "...... WHEEEEEEE! THAT WAS FUN! HOW ABOUT A FEW OF THESE........$$$$$$$$$$$$$$$$$$$$$$.........HMM NOT SO MUCH FUN, BUT I NEVER REALLY EXPECTED IT TO LAST!        "
 DC.B "          "
 DC.B "    WELL, I RECKON THAT THIS MUCH SCROLL TEXT IS ENOUGH TO SEPARATE THE MEN FROM THE BOYS.........NOW WE CAN GO ONTO THE 18 RATED STUFF..........."
 DC.B "    HA HA! ONLY KIDDING, I CAN'T REALLY THINK OF ANYTHING OFFENSIVE TO SAY,      APART FROM...... KYLIE MINOGUE            "
 DC.B "   OH DEAR!, SORRY COULDN'T HELP IT! IT JUST SLIPPED OUT! HA HA!!!!!  AAAAAAAAAAAARRRRRRRRRRRRGGGHH!      "
 DC.B "    I AM LISTENING TO 'CARTER THE UNSTOPPABLE SEX MACHINE' ON MY CD PLAYER JUST NOW, IT IS GREAT! THE LYRICS ARE A BIT UNUSUAL, BUT THE MUSIC IS WIIIILLD! "
 DC.B "  SOME OTHER GROUPS/MUSIC I LIKE JUST NOW ARE    THE BELOVED, RIDE, BELINDA CARLISLE, ALPHAVILLE.  I HAVE LOTS OF RECORDS AND CD'S BUT THOSE ARE THE ONLY "
 DC.B "ONES I HAVE LISTENED TO FOR ABOUT 3 WEEKS!     OK, LISTEN TO THIS.......... "
 DC.B """WELL I REMEMBER MICKEY DOYLE, HE JUST SHUFFLED OFF THIS MORTAL COIL, WITH NO MESSAGE FOR 'THAT SPECIAL GIRL', JUST THANK YOU AND GOODBYE CRUEL WORLD, "
 DC.B "THEN FOR THE SAKE OF AULD LANG SYNE, HE PUT HIS HEAD ON THE RAILWAY LINE, LOOKED UP AT THE MORNING SUN, AND WAITED FOR THE TRAIN TO COME"""
 DC.B "       SEE WHAT I MEAN ABOUT THE LYRICS?       BLINKY FLIP!            "
 DC.B " OH WELL, ENUFF! I'D BETTER QUIT WAFFLING NOW, BUT BEFORE I GO, A FINAL PARTING MESSAGE OF THANKS TO ST CONNEXION FOR CREATING THIER ST SOUNDTRACKERS, "
 DC.B " I WOULD NOT HAVE BOTHERED WITH THIS, IF NOT FOR YOU GUYS!       "
 DC.B "                     OK LETS WRAPPPPPPPPPP                   "
 dc.b 0

charset	incbin	32.fnt	;Le Font!
d_space	ds.b	26*12	

here		ds.l	1
letter_at	ds.l	1
buffer_1	ds.b	26*6*20
buffer_2	ds.b	26*6*20
buffer_1_end	equ	buffer_1+114
buffer_2_end	equ	buffer_2+114

;
; Common Data Area
;
new_screen	ds.b	32512

music	ds.b	5*1024
space	equ	*




