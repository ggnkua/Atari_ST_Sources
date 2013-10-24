		opt c+,d-

;run this loader before you pack a game and it will build a
;table of all gemdos load code which you can analyse by pressing reset
;table starts at $14000
;examine it to see exactly how each file is loaded and you will be
;able to decide how best to pack each file (remember chunkfiles suck)
;if the game crashes it is probably because the table is full and the main
;prg file has been overwritten.this usually happens because a file has been
;loaded 1 byte at a time which causes a mass of code in the table
;note this file as you cannot pack it unless you want to chunk it or
;single part the game
;then remove **** in code below.reassemble and this code will not
;add to its table when only 1 byte is loaded from a file
;note that this may give you a false reading for the files found in the
;table but you could assume that the offending file eg file.set which was
;loaded 1 byte at a time therefore any *.set files are also loaded in this
;crap fashion.
;pay attention to files that may be loaded to odd addresses as most depackers
;do not allow for this
;when you use reset you must insert a disk which reserves low memory and boots
;your monitor prg in high memory otherwise no data will be left in memory to
;be examined
	
main	MOVEA.L	4(A7),A5
	move.l #$14000,d0	
	move.l a5,d1
	sub.l d1,d0
	add.l #$3000,d0
	move.l #$14000,mem	;start address of table tht will be created x $3000

	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7
	lea $14000,a7
CHEAT	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01
	move.l d0,2(sp)
	MOVE.L	$84.w,tr1
	MOVE.L	#T1,$84.w
	TRAP	#$01
	ADDQ.L	#6,A7
	clr.w -(sp)
	pea $ffffffff
	move.l (a7),-(sp)
	move.w #5,-(sp)
	trap #14
	lea $c(a7),a7
	pea text
	move.w #9,-(sp)
	trap #1
	ADDQ.L #6,SP
	MOVE.W #7,-(SP)
	TRAP #1
	ADDQ.L #2,SP
stkk	clr.l $60000
	pea $60000
	move.l (a7),-(sp)
	move.l #gam3,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7
	clr.w -(sp)
	trap #1
mem	dc.l 0

T1		movem.l	a0-a6/d0-d7,reg
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0
		bne.s 	ok1
		move.l 	usp,a1
ok1		cmp.w #$3e,(a1)
		beq one
		cmp.w #$4b,(a1)
		beq.s two
		cmp.w #$3d,(a1)
		beq.s two2
		cmp.w #$4e,(a1)
		beq.s two
		cmp.w #$42,(a1)
		beq.s loads
				
		


		cmpi.w 	#$3f,(a1)
		beq.s read2



nope
		
open		movem.l 	reg,a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0
loadit		dc.l 	$0
one		
		move.l mem,a0
		move.w (a1),(a0)+	;store gemdos 3e in table
		move.l a0,mem
		bra.s open
two
		move.l mem,a0
		move.w (a1),(a0)+	;store gemdos 4e in table
		move.l 2(a1),(a0)+	;store filename address
		move.l a0,mem
		bra open
two2
		move.l mem,a0
		move.w (a1),(a0)+	;store gemdos 3d in table
		move.l 2(a1),a1		;store a filename in table
		moveq.l #$11,d0
hy		move.b (a1)+,(a0)+
		dbf d0,hy
		move.l a0,mem
		bra open
loads
		move.l mem,a0
		move.w (a1),(a0)+	;store gemdos 42 in table
		move.w 2(a1),(a0)+	;store handle
		MOVE.l 4(A1),(A0)+	;store data
		move.w 8(a1),(a0)+	;store operation code (0,1,2)
		move.l a0,mem
		bra open
read2		move.l mem,a0
****		cmp.l #1,4(a1)
****		beq openol
;above 2 lines reduce volume of data being stored in table
;only use if size being read is 1 and is cause of table filling up
		move.w (a1),(a0)+	;store 3f in table
		move.l 4(a1),(a0)+	;store size being read
		move.l 8(a1),(a0)+	;store address being read to
		move.l a0,mem
		bra openol
openol
read		move.l 	$8(a1),loadit
		move.l $2(a7),ex3f
		move.l #cls,$2(a7)
		bra open
siz2		dc.l 0
cls			
		movem.l d0-d7/a0-a6,-(sp)
		move.l d0,siz2
		bsr close
		movem.l (a7)+,d0-d7/a0-a6
		move.l siz2,d0
NODEC		dc.w $4ef9
ex3f		dc.l 0
FLAG		DC.L 0
MEM		DC.L 0,0,0

sav		dc.l 0

siz42		dc.l 0


stksav		dc.l 0
;do not worry about the code below as we are not depacking anything
;we are only analysing load code 
;go to end of src
close		move.l loadit(pc),a1
		cmp.l #$41544d35,(a1)
		bne ret
		move.l $4(a1),siz2
		move.l a1,-(sp)
gg		lea -$80(a1),a1
		lea 	savdat(pc),a0
		moveq.l #$7f,d0
kk		move.b 	(a1)+,(a0)+
		dbf 	d0,kk
		move.l (a7),a1
		lea -$80(a1),a0
		moveq.l #12,d0
		add.l $8(a1),d0
xc		move.b (a1)+,(a0)+
		subq.l #1,d0
		bne.s xc
		move.l	(a7),a1
		lea -$80(a1),a0
		bsr.s	DEPACK
		move.l (sp)+,a0
		lea -$80(a0),a0
		lea	savdat(pc),a1
		moveq.l	#$7f,d0
kk2		move.b	(a1)+,(a0)+
		dbf	d0,kk2
ret		rts
MODE:	EQU	0
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0
DEPACK                       
depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc


reg		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
savdat		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

gam3		dc.b 'cvap',0	;prg to execute
text		dc.b "TRAP #1",13,10
		DC.B 0
;this src can be adapted and improved to suit whatever game you
;find it will not cope with
;its main problem is if the table fills up.if a crash occurs ,
;reset and find your answer in the table.you may then have to
;patch this src to get you further into whatever you are analysing
;it is a useful util for gemdos crap
;i also have a loader somewhere which is an improvement on the 
;3f,4e only loaded in that is does cater for the basic 42 instructions
;which only jump to the start and end of files (nothing special) but
;it is another means of finding the filesize and it does need
;simulating if you are going to pack those files
		
	even
end	nop