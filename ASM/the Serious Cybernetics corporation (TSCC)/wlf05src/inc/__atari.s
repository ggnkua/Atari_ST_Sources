*********************************
*
*  d0.l macro *AllocSomeMem(u32 size,u16 mode)
*
* Try to allocate a fastram block
*
*********************************
		
STRAM		=	0
TTRAM		=	3
		
AllocSomeMem	macro

		cmpi.w	#2,computer	; TT030 or Falcon030?
		blt.s	.\@malloc	; no, then use malloc

		move.w	#\2,-(sp)
		pea.l	\1
		move.w	#$44,-(sp)	; mxalloc
		trap	#1
		addq.l	#8,sp
		
		bra.s	.\@ret

.\@malloc	pea.l	\1
		move.w	#$48,-(sp)	; malloc()
		trap	#1
		addq.l	#6,sp	
.\@ret
		endm
	

		
*********************************
*
*  void macro FreeSomeMem(u32 *Block)
*
* Release a previously reserved block
*
*********************************

FreeSomeMem	macro

		move.l	\1,-(sp)
		move.w	#$49,-(sp)	; mfree()
		trap	#1
		addq.l	#6,sp
		endm


*********************************
*
*  void ClearBlock(a0.l *block, d0.l amount, d1.l pattern)
*
* Clear a block as fast as possible
*
*********************************
		section	text
ClearBlock	adda.l	d0,a0	; Point to end of block

		move.l	d0,d2	; amount mod 512
		andi.w	#511,d0
		lsr.l	#8,d2	; amount/512
		lsr.l	d2
		swap.w	d0
		move.w	d2,d0
		
		subq.w	#1,d0
		bmi.s	.skipchunks

		move.l	d1,d2	; Spread pattern accross
		move.l	d1,d3	; available registers
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		movea.l	d1,a1
		movea.l	d1,a2
		movea.l	d1,a3
		movea.l	d1,a4
		movea.l	d1,a5
		movea.l	d1,a6
		
.chunks				; Fill 512 byte chunks
	rept	9
		movem.l	d1-d7/a1-a6,-(a0)
	endr
		movem.l	d1-d7/a1-a4,-(a0)
		dbra	d0,.chunks
		
.skipchunks	swap.w	d0	; Fill remaining longwords
		tst.w	d0
		beq.s	.skipalign

		moveq.l	#31,d2
		and.w	d0,d2
		neg.l	d2
		
		lsr.w	#5,d0
		
		add.l	d2,d2
		jmp	.entry(pc,d2.l)
		
.align	
	rept	32
		move.b	d1,-(a0)
	endr
.entry		dbra	d0,.align
		
.skipalign	rts



*********************************
*
*  void MoveBlock(a0.l *source, a1.l *dest, d0.l amount)
*
* Copy a block as fast as possible
*
*********************************

MoveBlock	move.l	d0,d1	; amount % 512
		andi.w	#511,d0
		lsr.l	#8,d1	; amount/512
		lsr.l	d1
		swap.w	d0
		move.w	d1,d0

		
		subq.w	#1,d0
		bmi.w	.skipchunks
.chunks				; Blit 512 byte chunks
	rept	10
		movem.l	(a0)+,d1-d7/a2-a6
		movem.l	d1-d7/a2-a6,(a1)
		lea.l	12*4(a1),a1
	endr
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,(a1)
		lea.l	8*4(a1),a1
		dbra	d0,.chunks
		
.skipchunks	swap.w	d0	; Blit remaining longwords
		tst.w	d0
		beq.s	.skipalign

		moveq.l	#31,d1
		and.w	d0,d1
		neg.l	d1
		
		lsr.w	#5,d0
		
		add.l	d1,d1
		jmp	.entry(pc,d1.l)
.align	
	rept	32
		move.b	(a0)+,(a1)+
	endr
.entry		dbra	d0,.align

.skipalign	rts



*********************************
*
*  void d_lz77(a0.l *lz77data, a1.l *dest)
*
* Very! fast lz77 decompression routine
* 68000 version
*
*********************************

d_lz77		addq.l	#4,a0		; Skip original length
		bra.s	.loadtag

.literal
	rept	8
		move.b	(a0)+,(a1)+     ; Copy 8 bytes literal string
	endr
         
.loadtag	move.b	(a0)+,d0	; Load compression TAG
		beq.s	.literal	; 8 bytes literal string?


		moveq.l	#8-1,d1         ; Process TAG per byte/string
.search		add.b	d0,d0		; TAG <<= 1
		bcs.s	.compressed

		move.b  (a0)+,(a1)+     ; Copy another literal byte
		dbra	d1,.search

		bra.s	.loadtag


.compressed	moveq.l	#0,d2
		move.b  (a0)+,d2        ; Load compression specifier
		beq.s	.break		; End of stream, exit

		moveq.l	#$0f,d3		; Mask out stringlength
		and.l	d2,d3

		lsl.w	#4,d2		; Compute string location
		move.b	(a0)+,d2
		movea.l	a1,a2
		suba.l	d2,a2


		add.w	d3,d3		; Jump into unrolled string copy loop
		neg.w	d3
		jmp     .unroll(pc,d3.w)

	rept	15
		move.b	(a2)+,(a1)+
	endr
.unroll		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+

		dbra	d1,.search

		bra.s	.loadtag

.break		rts



*********************************
*
*  void macro InitAtari()
*
* Determine machine type and initialise system
* accordingly
*
*********************************

InitAtari	macro
	
		movea.l 4(sp),a5	; Address to basepage
		move.l	$0c(a5),d0	; Length of text segment
		add.l	$14(a5),d0	; Length of data segment
		add.l	$1c(a5),d0	; Length of bss segment
		addi.l	#$1100,d0	; Length of basepage +
					; Length of stackpointer
		move.l	a5,d1		; Address to basepage
		add.l	d0,d1		; End of program
		addq.l	#1,d1
		bclr.l	#0,d1		; Make address even
		movea.l d1,sp		; New sp

		mshrink	d0,a5

	
		AllocSomeMem	64256,STRAM	; Reserve 2 screens in ST-RAM
		
		tst.l	d0		; Error?
		bne.s	\@malloc_ok

		lea	screen_malloc,a0 ; Otherwise display dialog
		form_alert a0
		
		clr.w	-(sp)		; And exit
		trap	#1
		

\@malloc_ok	addi.l	#256,d0 	; Init screens
		clr.b	d0		; Align by 256 bytes
		move.l	d0,ScreenAdr1
		addi.l	#32000,d0
		move.l	d0,ScreenAdr2

		movea.l ScreenAdr1,a0	; Clear screens
		move.w	#64000/16-1,d7

\@cls		clr.l	(a0)+
		dbra	d7,\@cls


		clr.l	-(sp)		; Super()
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,save_stack

		lea.l	my_stack,sp
      


; Determine machinetype via cookiejar

		move.l	#"_VDO",d1	; Cookie we are looking for
		move.l	$05a0.w,d0	; Get address of cookie jar in d0
		beq.s	\@init_nojar	; If zero, there's no jar.
		movea.l d0,a0		; Move the address of the jar to a0

\@init_search	tst.l	(a0)		; Is this jar entry the last one ?
		beq.s	\@init_nofind	; Yes, the cookie was not found
		cmp.l	(a0),d1 	; Does this cookie match what we're looking for?
		beq.s	\@init_foundit	; Yes, it does.
		addq.l	#8,a0		; Advance to the next jar entry
		bra.s	\@init_search	; and start over

\@init_nofind	moveq.l	#-1,d0		; A negative (-1) means cookie not found
		bra.s	\@init_cookieexit
\@init_nojar	moveq.l	#-2,d0		; A negative (-2) means there's no jar
		bra.s	\@init_cookieexit
\@init_foundit	moveq.l	#0,d0		; A null in d0 means the cookie was found.

\@init_cookieexit 
		tst.l	d0		; If not 0, assume ST
		bne.s	\@init_st
		cmpi.l	#$010000,4(a0)	; 1=STE
		beq.s	\@init_ste
		cmpi.l	#$020000,4(a0)	; 2=TT030
		beq.s	\@init_tt
		cmpi.l	#$030000,4(a0)	; 3=Falcon
		beq.s	\@init_falc
		bra.s	\@init_st	; If nothing else, assume ST

\@init_ste	move.w	#1,computer
		bra.s	\@init_st
		
\@init_tt	move.w	#2,computer
		
\@init_st	move.l	$ffff8200.w,save_phy
		move.l	$ffff8260.w,save_res
		clr.b	$ffff8260.w	; Set 320x200x4bpp (ST)
		
		bra.w	\@init_video_done
		
\@init_falc	move.w	#3,computer

		lea	save_f030video,a0
		move.l	$ffff8200.w,(a0)+ ; vidhm
		move.w	$ffff820c.w,(a0)+ ; vidl
		move.l	$ffff8282.w,(a0)+ ; h-regs
		move.l	$ffff8286.w,(a0)+
		move.l	$ffff828a.w,(a0)+
		move.l	$ffff82a2.w,(a0)+ ; v-regs
		move.l	$ffff82a6.w,(a0)+
		move.l	$ffff82aa.w,(a0)+
		move.w	$ffff82c0.w,(a0)+ ; vco
		move.w	$ffff82c2.w,(a0)+ ; c_s
		move.l	$ffff820e.w,(a0)+ ; offset
		move.w	$ffff820a.w,(a0)+ ; sync
		move.b	$ffff8256.w,(a0)+ ; p_o
		clr.b	(a0)		 ; test of ST(E) or falcon mode
		cmpi.w	#$b0,$ffff8282.w ; hht < $b0?
		sle.b	(a0)+		; Set flag
		move.w	$ffff8266.w,(a0)+ ;f_s
		move.w	$ffff8260.w,(a0)+ ;st_s
		
		move.w	#$59,-(sp)	; Check monitortype (falcon)
		trap	#14		;
		addq.l	#2,sp		;
		cmp.w	#1,d0		; if 1 = RGB
		beq.s	\@rgb50 	;
		cmp.w	#3,d0		; if 3 = TV
		beq.s	\@rgb50 	; Otherwise assume VGA (ignore mono..)
	
		
\@vga60 	move.l	#$170012,$ffff8282.w ; Falcon 60hz vga
		move.l	#$01020e,$ffff8286.w
		move.l	#$0d0012,$ffff828a.w
		move.l	#$041903ff,$ffff82a2.w
		move.l	#$3f008d,$ffff82a6.w
		move.l	#$03ad0415,$ffff82aa.w
		move.w	#$0200,$ffff820a.w
		move.w	#$0186,$ffff82c0.w
		clr.w	$ffff8266.w
		clr.b	$ffff8260.w
		move.w	#$05,$ffff82c2.w
		move.w	#$50,$ffff8210.w
	  
		
		
		bra.s	\@init_video_done
		
\@rgb50 	move.l	#$300027,$ffff8282.w ; Falcon 50hz rgb
		move.l	#$070229,$ffff8286.w
		move.l	#$1e002a,$ffff828a.w
		move.l	#$02710265,$ffff82a2.w
		move.l	#$2f0081,$ffff82a6.w
		move.l	#$0211026b,$ffff82aa.w
		move.w	#$0200,$ffff820a.w
		move.w	#$0185,$ffff82c0.w
		clr.w	$ffff8266.w
		clr.b	$ffff8260.w
		clr.w	$ffff82c2.w
		move.w	#$50,$ffff8210.w
		
\@init_video_done 

		move.b	$ffff820a.w,sys_sync
		bclr.b	#1,$ffff820a.w	; Switch to NTSC mode

		lea.l	$ffff8240.w,a0
		
		movem.l	(a0),d0-d7 ; Save palette
		movem.l d0-d7,save_pal

		clr.l	(a0)+		; Black palette
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+

		move.w	#$2700,sr	; Save MFP-settings

		****
		lea.l	$1010.w,a0
		lea.l	save,a1
		move.w	#64*65-1,d0
\@sss		move.l	(a0)+,(a1)+
		dbra	d0,\@sss
		***********

		lea.l	sys_vars,a0
		move.l  $0070.w,(a0)+
		move.l  $0068.w,(a0)+
		move.l  $0110.w,(a0)+
		move.l	$0114.w,(a0)+
		move.l	$0118.w,(a0)+
		move.l  $0120.w,(a0)+
		move.l	$0134.w,(a0)+
		lea.l	$fffffa00.w,a1
		move.b	$01(a1),(a0)+
		move.b	$03(a1),(a0)+
		move.b	$05(a1),(a0)+
		move.b  $07(a1),(a0)+
		move.b  $09(a1),(a0)+
		move.b	$0b(a1),(a0)+
		move.b	$0d(a1),(a0)+
		move.b	$0f(a1),(a0)+
		move.b  $11(a1),(a0)+
		move.b  $13(a1),(a0)+
		move.b  $15(a1),(a0)+
		move.b  $17(a1),(a0)+
		move.b	$19(a1),(a0)+
		move.b  $1b(a1),(a0)+
		move.b	$1d(a1),(a0)+
		move.b	$1f(a1),(a0)+
		move.b  $21(a1),(a0)+
		move.b  $23(a1),(a0)+
		move.b  $25(a1),(a0)+
		move.b  $0484.w,(a0)

		moveq.l	#$12,d0		; Mouse off
		bsr.w	send_ikbd
	
		move.l	#idle_frcount,$70.w	; New vbl
		move.l  #idle,$68.w		; New hbl
		move.l	#idle,$110.w
		move.l	#IO_CheckInput,$118.w		
		move.l	#idle,$120.w
		
		move.b	#%00000001,$07(a1)	; Enable timer b
		move.b	#%00000001,$13(a1)
	
		move.b	#%01010000,$09(a1)	; Enable IKBD irq & timer d
		move.b	#%01010000,$15(a1)
		
		move.b	#%110,$1d(a1)		; timer d delay 
		move.b	#117,$25(a1)		; (2457600/100/117 ~210Hz)
			
		move.b	#%01000000,$17(a1)	; Automatic end of interrupt
	
		clr.b	$484.w	; Keyclick & repeat off
		move.w	#$2300,sr

		
		AllocSomeMem	418.w,STRAM	; Allocate space for sound buffers
		addq.l	#1,d0
		bclr.l	#0,d0
		
		movea.l	d0,a0
		lea.l	208(a0),a1
		movem.l	a0-a1,SFXBuffer1
		endm
	
	
		section	data
screen_malloc	dc.b	'[1][ malloc(): could not allocate| screens.][ OK ]'
		even
	
computer	dc.w 0		; 0=st 1=ste 2=tt 3=falc
			
		section bss
save_stack	ds.l 1		; Old stackpointer
save_phy	ds.l 1		; Old physbase
save_res	ds.l 1		; Old screen resolution
save_pal	ds.l 8		; Old colours
save_f030video	ds.b 32+12+2	; Old falcon video

sys_vars	ds.l 19		; mfp
sys_sync	ds.b 1
		even

		ds.l	256	; Stackspace
my_stack	ds.l	1
	
	
	
	
*******************************
*
*  void macro RestoreAtari()
*
* Restore system settings and exit to
* desktop
*
*******************************

		section	text
RestoreAtari	macro
		move.b	sys_sync,$ffff820a.w

		lea.l	$ffff8240.w,a0	; Set palette
					; to black
	rept	8
		clr.l   (a0)+
	endr
		
	    	move.w	#$2700,sr	; Restore mfp
		lea	sys_vars,a0
		move.l  (a0)+,$0070.w
		move.l  (a0)+,$0068.w
		move.l  (a0)+,$0110.w
		move.l	(a0)+,$0114.w
		move.l	(a0)+,$0118.w
		move.l  (a0)+,$0120.w
		move.l	(a0)+,$0134.w
		lea	$fffffa00.w,a1
		move.b	(a0)+,$01(a1)
		move.b	(a0)+,$03(a1)
		move.b	(a0)+,$05(a1)
		move.b  (a0)+,$07(a1)
		move.b  (a0)+,$09(a1)
		move.b	(a0)+,$0b(a1)
		move.b	(a0)+,$0d(a1)
		move.b	(a0)+,$0f(a1)
		move.b  (a0)+,$11(a1)
		move.b  (a0)+,$13(a1)
		move.b  (a0)+,$15(a1)
		move.b  (a0)+,$17(a1)
		move.l	a0,a2
		clr.b	$19(a1)
		clr.b	$1b(a1)
		clr.b	$1d(a1)
		addq.l	#3,a0
		move.b	(a0)+,d0 $1f(a1)
		move.b  (a0)+,d0 $21(a1)
		move.b  (a0)+,d0 $23(a1)
		move.b  (a0)+,d0 $25(a1)
		move.b	(a2)+,$19(a1)
		move.b	(a2)+,$1b(a1)
		move.b	(a2)+,$1d(a1)
		move.b  (a0)+,$0484.w
		
		****
		lea.l	$1010.w,a0
		lea.l	save,a1
		move.w	#64*65-1,d0
.rrr		move.l	(a1)+,(a0)+
		dbra	d0,.rrr
		***********
			
		moveq.l	#8,d0		; Mouse on
		bsr.w	send_ikbd

		move.w	#$2300,sr
	      
		cmpi.w	#3,computer
		beq.s	\@falcrestore

\@strestore
	ifeq	1
		move.w	save_res,-(sp)	; Restore screenadr & resolution (st)
		move.l	save_phys,-(sp)
		move.l	#-1,-(sp) ;save_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp
	endc

		move.l	save_phy,$ffff8200.w
		move.l	save_res,$ffff8260.w
		
		bra.s	\@video_done
		
\@falcrestore	clr.w	$ffff8266.w	; Falcon-shift clear
		lea	save_f030video,a0
		move.l	(a0)+,$ffff8200.w ;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w ;l
		move.l	(a0)+,$ffff8282.w ;h-regs
		move.l	(a0)+,$ffff8286.w ;
		move.l	(a0)+,$ffff828a.w ;
		move.l	(a0)+,$ffff82a2.w ;v-regs
		move.l	(a0)+,$ffff82a6.w ;
		move.l	(a0)+,$ffff82aa.w ;
		move.w	(a0)+,$ffff82c0.w ;vco
		move.w	(a0)+,$ffff82c2.w ;c_s
		move.l	(a0)+,$ffff820e.w ;offset
		move.w	(a0)+,$ffff820a.w ;sync
		move.b	(a0)+,$ffff8256.w ;p_o
		tst.b	(a0)+		;st(e) comptaible mode?
		bne.s	\@falcok
		move.w	(a0),$ffff8266.w ;falcon-shift
		bra.s	\@video_done
\@falcok	move.w	2(a0),$ffff8260.w ;st-shift
		lea	save_f030video,a0
		move.w	32(a0),$ffff82c2.w ;c_s
		move.l	34(a0),$ffff820e.w ;offset
		
		
\@video_done	movem.l save_pal,d0-d7	; Restore palette
		movem.l d0-d7,$ffff8240.w

		move.l	save_stack,-(sp); Return to user mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp


		move.l	error_string,d0	; Did an error occur ?
		beq.s	\@pterm		; no, then exit
		
		form_alert d0		; Otherwise display error-dialog
		
\@pterm		clr.w	 -(sp)		;pterm()
		trap	  #1		;

		endm

		section	data
error_string	dc.l	0		; pointer to possible error message		



*******************************
*
*  bool d0.b macro mshrink(block.l, length.l)
*
* Try to reserve a certain block of memory
*
*******************************

mshrink		macro	longword,longword

		move.l	\1,-(sp)
		move.l	\2,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)	;mshrink()
		trap	#1
		lea.l	12(sp),sp

		endm


		
*******************************
*
*  void macro form_alert(*String)
*
* Create an AES alert box displaying the specified text
*
*******************************

form_alert	macro	pointer
		
		move.l	\1,addr_in

		bsr.w	call_aes
		endm


call_aes	move.l	#aes_params,d1
		move.w	#200,d0		function number
		trap	#2
	
		rts

		section	data
aes_params	dc.l	control		aes pointer structure
		dc.l	global
		dc.l	int_in
		dc.l	int_out
		dc.l	addr_in
		dc.l	addr_out
		
control		dc.w	52		form_alert
		dc.w	1		control1-4
		dc.w	1
		dc.w	1
		dc.w	0		

		section	bss		
global		ds.w	14
int_in		ds.w	16
int_out		ds.w	7
addr_in		ds.l	3
addr_out	ds.l	1