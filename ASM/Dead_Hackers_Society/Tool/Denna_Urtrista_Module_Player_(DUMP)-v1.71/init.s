
;
; DUMP
; 
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
; 
; init.s


		section	text



		move.l	4(sp),a5				;address to basepage

		move.l	a5,d0					;basepage address
		add.l	#129,d0					;offset to commandline
		move.l	d0,filename			

		move.l	$0c(a5),d0				;length of text segment
		add.l	$14(a5),d0				;length of data segment
		add.l	$1c(a5),d0				;length of bss segment
		add.l	#$1000,d0				;length of stackpointer
		add.l	#$100,d0				;length of basepage
		move.l	a5,d1					;address to basepage
		add.l	d0,d1					;end of program
		and.l	#-2,d1					;make address even
		move.l	d1,sp					;new stackspace
		move.l	d0,-(sp)				;mshrink()
		move.l	a5,-(sp)				;
		move.w	d0,-(sp)				;
		move.w	#$4a,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;



		move.w	#$68,-(sp)				;Dsp_Lock()
		trap	#14					;
		addq.l	#2,sp					;
		
		tst.w	d0					;is dsp locked?
		bne.w	exit_dsplocked				;


		move.w	#$80,-(sp)				;Locksnd()
		trap	#14					;
		addq.l	#2,sp					;
		
		cmp.w	#1,d0					;is soundsystem locked?
		bne.w	exit_sndlocked				;


		move.w	#$2f,-(sp)				;fgetdta() save old dta address
		trap	#1					;
		addq.l	#2,sp					;
		move.l	d0,save_dta				;

		move.l	#dta,-(sp)				;fsetdta() set new dta buffer
		move.w	#$1a,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;


		move.w	#1,-(sp)				;Pdomain()
		move.w	#$119,-(sp)				;enter mint domain
		trap	#1					;
		addq.l	#4,sp					;

		move.l	filename,a0				;commandline checker
		clr.l	d0
.cmdloop:
		cmp.b	#"-",(a0,d0)
		bne.w	.cmddone
		addq.l	#1,d0

.cmd1:		tst.w	quiet					;-q or -Q
		bne.s	.cmd2					;silent mode
		cmp.b	#"q",(a0,d0)
		bne.s	.cmd1b
		move.w	#1,quiet
		bra.w	.ok

.cmd1b:		cmp.b	#"Q",(a0,d0)
		bne.s	.cmd2
		move.w	#1,quiet
		bra.w	.ok

.cmd2:		tst.w	surround				;-s or -S
		bne.s	.cmd3					;surround sound
		cmp.b	#"s",(a0,d0)
		bne.s	.cmd2b
		move.w	#1,surround
		bra.s	.ok

.cmd2b:		cmp.b	#"S",(a0,d0)
		bne.s	.cmd3
		move.w	#1,surround
		beq.s	.ok

.cmd3:		tst.w	interpolation				;-i or -I
		bne.s	.cmd4					;interpolation
		cmp.b	#"i",(a0,d0)
		bne.s	.cmd3b
		move.w	#1,interpolation
		bra.s	.ok

.cmd3b:		cmp.b	#"I",(a0,d0)
		bne.s	.cmd4
		move.w	#1,interpolation

.cmd4:		tst.w	samplenames				;-n or -N
		bne.s	.cmd5					;don't print samplenames
		cmp.b	#"n",(a0,d0)
		bne.s	.cmd4b
		move.w	#1,samplenames
		bra.s	.ok

.cmd4b:		cmp.b	#"N",(a0,d0)
		bne.s	.cmd5
		move.w	#1,samplenames
		



.cmd5:

.ok:		addq.l	#2,d0
		bra.w	.cmdloop


		
.cmddone:	add.l	d0,filename





		move.l	#title_text,d0				;print title text
		bsr.w	print					;

		move.w	#0,-(sp)				;mxalloc() - reserve stram only
		move.l	#8000,-(sp)				;for dma playbuffer
		move.w	#$44,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		tst.l	d0					;check if there is stram enough
		beq.w	exit_nostram				;nope
		move.l	d0,dma_pointer				;store address of stram buffer


		section	text