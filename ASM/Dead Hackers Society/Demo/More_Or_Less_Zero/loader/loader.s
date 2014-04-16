; loader.s
;
; loader for More Or Less Zero by Dead Hackers Society

music_size:	equ	618487
floppy:		equ	1

		output	.tos
		opt	p=68000

		section	text
begin:

		move.l	4(sp),a5			;address to basepage
		move.l	$0c(a5),d0			;length of text segment
		add.l	$14(a5),d0			;length of data segment
		add.l	$1c(a5),d0			;length of bss segment
		add.l	#$100,d0			;length of basepage
		add.l	#$1000,d0			;length of stackpointer
		move.l	a5,d1				;address to basepage
		add.l	d0,d1				;end of program
		and.l	#-2,d1				;make address even
		move.l	d1,sp				;new stackspace

		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)			;
		move.w	d0,-(sp)			;
		move.w	#$4a,-(sp)			;
		trap	#1				;
		lea	12(sp),sp			;

		clr.l	-(sp)				;supervisormode
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		move.l	d0,save_stack			;


		movem.l	$ffff8240.w,d0-d7		;save old pal
		movem.l	d0-d7,save_pal			;


		move.b	$484.w,save_keymode		;save keyclick
		bclr	#0,$484				;keyclick off

		bsr.w	blackset



;-------------- reserve mem and load dma sample (mem is freed after mainpart) 
		move.l	#music_size,-(sp)		;malloc()
		move.w	#72,-(sp)			;dma music space
		trap	#1				;
		addq.l	#6,sp				;
		tst.l	d0				;
		beq.w	exit				;
		move.l	d0,dma_adr
		move.l	d0,$40.w

		move.w	#0,-(sp)			;fopen()
		pea	music_fn			;
		move.w	#$3d,-(sp)			;
		trap	#1				;
		addq.l	#8,sp				;
		tst.l	d0				;
		bmi.w	exit				;
		move.w	d0,filenumber			;

		move.l	dma_adr,-(sp)			;fread()
		move.l	#music_size,-(sp)		;load dma music
		move.w	filenumber,-(sp)		;
		move.w	#$3f,-(sp)			;
		trap	#1				;
		lea.l	12(sp),sp			;

		move.w	filenumber,-(sp)		;fclose()
		move.w	#$3e,-(sp)			;
		trap	#1				;
		addq.l	#4,sp				;



		ifne	floppy
;-------------- load and run change disk
change_disk:
		pea	null				;env
		pea	null				;cmd
		pea	change_fn			;pushfilename
		move.w	#3,-(sp)			;load
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;

		tst.l	d0				;change disk screen not found? exit!
		bmi.w	exit

		move.l	d0,save_adr			;bp addr
		pea	null				;env
		move.l	save_adr,-(sp)			;bp addr
		pea	null				;fn
		move.w	#4,-(sp)			;go
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;

		move.l	save_adr,-(sp)			;mfree
		move.w	#$49,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
		endc

;-------------- load and run main part -----------------------
main_part:	bsr.w	blackset
		bsr.w	clear_kbd

		pea	null				;env
		pea	null				;cmd
		pea	part1_fn			;fn
		move.w	#3,-(sp)			;load
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;
		move.l	d0,save_adr			;bp addr

		tst.l	d0
		bpl.s	.run
		ifne	floppy
		cmp.l	#-33,d0
		beq.w	change_disk
		endc
		bra.w	exit

.run:		pea	null				;env
		move.l	save_adr,-(sp)			;bp addr
		pea	null				;fn
		move.w	#4,-(sp)			;go
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;

		move.l	save_adr,-(sp)			;mfree()
		move.w	#$49,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		move.l	dma_adr,-(sp)			;mfree()
		move.w	#$49,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
;-------------------------------------------------------



;-------------- load and run end part ----------------
end_part:	bsr.w	blackset
		bsr.w	clear_kbd

		pea	null				;env
		pea	null				;cmd
		pea	part2_fn			;fn
		move.w	#3,-(sp)			;load
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;

		tst.l	d0
		bmi.w	exit

		move.l	d0,save_adr			;bp addr
		pea	null				;env
		move.l	save_adr,-(sp)			;bp addr
		pea	null				;fn
		move.w	#4,-(sp)			;go
		move.w	#$4b,-(sp)			;pexec()
		trap	#1				;
		lea.l	16(sp),sp			;

		move.l	save_adr,-(sp)			;mfree
		move.w	#$49,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;
;-------------------------------------------------------


exit:		bsr.w	blackset
		bsr.w	clear_kbd

		move.b	save_keymode,$484.w		;restore keyclick
		clr.l	$040.w

		movem.l	save_pal,d0-d7			;restore palette
		movem.l	d0-d7,$ffff8240.w		;

		move.l	save_stack,-(sp)		;exit supervisor
		move.w	#32,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		clr.w	-(sp)				;pterm()
		trap	#1				;



blackset:	lea.l	$ffff8240.w,a0
		move.w	#8-1,d7
.loop:		clr.l	(a0)+
		dbra	d7,.loop
		rts

clear_kbd:
		move.w	#2,-(sp)
		move.w	#1,-(sp)
		trap	#13
		addq.l	#4,sp
		
		tst.l	d0
		beq.s	.ok
		
		move.w	#2,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.l	#4,sp

		bra.s	clear_kbd

.ok:		rts



		section	data

change_fn:	dc.b	'change.bin',0
		even
part1_fn:	dc.b	'part1.bin',0
		even
part2_fn:	dc.b	'part2.bin',0
		even
music_fn:	dc.b	'part1.mus',0
		even

null:		dc.l	0,0,0,0,0,0,0
		even


		section	bss

save_resvalid:	ds.l	1
save_resvect:	ds.l	1
save_pal:	ds.l	8
save_stack:	ds.l	1
save_adr:	ds.l	1
cpu060:		ds.w	1
save_keymode:	ds.w	1
dma_adr:	ds.l	1
filenumber:	ds.w	1

		section	text
