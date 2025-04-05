
		output	.tos

		section	text
		
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

main:
		pea	menu
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		

.key:
		;wait for key
		move.w	#8,-(sp)
		trap	#1
		addq.l	#2,sp

		cmpi.w	#'w',d0
		beq.s	.read
		cmp.w	#'W',d0
		beq.s	.read

		cmp.w	#'q',d0
		beq.w	exit
		cmp.w	#'Q',d0
		beq.w	exit

		bra.s	.key

		;read old bootsector
.read:		move.w	#8,d0
		bsr.w	rw_boot


transfer_boot:
off:		equ	$1a
		lea.l	bootcode,a0
		move.w	#(bootcode_end-bootcode)/2,d7
		move.l	#boots+off+2,a1
.loop:		move.w	(a0)+,(a1)+
		dbra	d7,.loop
		move.w	#$6000+off,boots

make_exec:
		move.w	#1,-(sp)
		move.w	#-1,-(sp)
		move.l	#-1,-(sp)
		move.l	#boots,-(sp)
		move.w	#18,-(sp)
		trap	#14
		lea	14(sp),sp
		move.w	d0,checksum

write_boot:	move.w  #9,d0
		bsr.w	rw_boot


		bra.w	main

exit:		clr.w	-(sp)
		trap	#1


; subroutine reads and writes bootcode from disk
; to/from buffer
rw_boot:
                move.w  #1,-(SP)
                move.l  #0,-(SP)
                move.w  #1,-(SP)
                move.w  #0,-(SP)
                clr.l   -(SP)
                move.l  #boots,-(SP)
                move.w  D0,-(SP)
                trap    #14
                lea     20(SP),SP
                rts




                section	data

menu:		dc.b	"---------------------------",13,10
		dc.b	"Cernit Trandafir bootsector",13,10
		dc.b	"---------------------------",13,10
		dc.b	"Insert disk in drive A and ",13,10
		dc.b	"'w' to write bootsector    ",13,10
		dc.b	"'q' to quit                ",13,10,0

		even

boots:		ds.b	510
checksum:	ds.w	1


bootcode:	move.l	$044e.w,a0		;screen addr
		lea.l	.pic(pc),a1		;gfx

		;set palette black
		lea.l	$ffff8240.w,a2
		moveq.l	#0,d0
		move.w	#8-1,d7
.black:		move.l	d0,(a2)+
		dbra	d7,.black

		;clear screen
		move.l	a0,a2
		move.w	#32000/4-1,d7
.cls:		move.l	d0,(a2)+
		dbra	d7,.cls

		;copy logo to screen
		lea.l	96*160+56(a0),a0
		move.w	#12-1,d7
.y:

q:		set	0
		rept	6
		move.w	(a1)+,q(a0)
q:		set	q+8
		endr
		
		lea.l	160(a0),a0

		dbra	d7,.y

		;vsync
		move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		
		;set text white
		move.w	#$0fff,$ffff8242.w


		rts

.pic:		incbin	'text9612.1pl'
		even

bootcode_end:	dc.b	0

; BOOTSECTOR CODE END
;
; stack
stkstart:	ds.l	256
stackend:	ds.l	1

