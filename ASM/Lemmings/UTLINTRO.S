;-------------------------------------------------------------------------;
;	       	       The Lemmings Utility Disk Intro                    ;
;									  ;
;		            Coded By Quantum Man			  ;
;-------------------------------------------------------------------------;
	opt	o+,ow-,d+


	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000				do Mshrink
	trap	#1				call gemdos
	lea	$c(sp),sp			correct stack

;-------------------------------------------------------------------------;
; the above is the STANDARD gem start. We will only use the ram space	  ;
; that is strictly required. The rest may go back to gem.		  ;	
;-------------------------------------------------------------------------;
;			Now start my code for demo			  ;
;-------------------------------------------------------------------------;


start	move.l	sp,oldusp
	pea	newsp
	move.w	#$20,-(a7)			go into supermode
	trap	#1				call gemdos
	addq.l	#6,a7				correct stack
	move.l	d0,OLDSTK			save old stack

	move.w	#2,-(a7)			get physic address
	trap	#14				call xbios
	addq.l	#2,a7				correct stack
	move.l	d0,PHYSIC			save physic address

	move.w	#3,-(a7)			get logic address
	trap	#14				call xbios
	addq.l	#2,a7				correct stack
	move.l	d0,LOGIC			save logic address

	move.w	#4,-(sp)			get present screen res
	trap	#14				call xbios
	addq.l	#2,a7				correct stack
	move.w	d0,OLDRES			save present screen res

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,OLDPAL			save old palette

	move.b	#0,$484.w			turn off keyclick
	move.b	#$12,$fffffc02.w		turn off mouse interrupt

	move.w	#1,-(a7)			choose medium res
	move.l	#-1,-(a7)			don't change physic
	move.l	#-1,-(a7)			don't change logic
	move.w	#5,-(a7)			set new res
	trap	#14				call xbios
	lea	12(a7),a7			correct stack

	moveq	#6,d1				set up fade loop counter
f_blak	
	rept	4
	jsr	sync				wait vbl
	endr

	sub	#$111,$ffff8240.w		decrease colour by $111
	dbra	d1,f_blak			decrement and carry on
	lea	$ffff8240.w,a0			make all colours black
	clr.l	(a0)+
	clr.l	(a0)+

	move.l	#ASCII,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#$777,$ffff8246.w

	move.l	$70.w,OLDVBL			save old vbl
	move.l	$120.w,OLDTIMB			save old timer b
	move.b	$fffffa1b.w,OLDA1B
	move.b	$fffffa21.w,OLDA21
	move.b	$fffffa07.w,OLDA07
	move.b	$fffffa09.w,OLDA09
	move.b	$fffffa13.w,OLDA13

	move.w	#$2700,sr			stop interrupts
	move.l	#timer_b,$120.w			put my routine on the hbl
	move.l	#my_vbl,$70.w			put my routine on the vbl
	clr.b	$fffffa07.w			enable timer b
	clr.b	$fffffa09.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w
	move.w	#$2300,sr			enable interrupts

*----------

main	btst	#0,$fffffc00.w
	beq.s	main
	cmp.b	#$02,$fffffc02.w		has key '1' been pressed?			
	beq	file1				yes! I'll load'n'exit
	cmp.b	#$03,$fffffc02.w		has key '2' been pressed?			
	beq	file2				yes! I'll load'n'exit
	cmp.b	#$04,$fffffc02.w		has key '3' been pressed?			
	beq	file3				yes! I'll load'n'exit
	cmp.b	#$05,$fffffc02.w		has key '4' been pressed?			
	beq	file4				yes! I'll load'n'exit
	cmp.b	#$06,$fffffc02.w		has key '5' been pressed?			
	beq	file5				yes! I'll load'n'exit
	bra.s	main				no! then loop again

*----------

file1	jsr	off
	lea	game1(pc),a6
	bra	loader

file2	jsr	off
	lea	game2(pc),a6
	bra	loader

file3	jsr	off
	lea	game3(pc),a6
	bra	loader

file4	jsr	off
	lea	game4(pc),a6
	bra	loader

file5	jsr	off
	lea	game5(pc),a6


loader	move.l	oldusp,sp
	pea	null
	pea	null
	move.l	a6,-(a7)			set filename 
	clr.w	-(a7)				choose load and execute
	move.w	#$4b,-(a7)			execute chosen file
	trap	#1				call gemdos
	lea	16(a7),a7			correct stack

	bra	start

; Change these filenames !!!!!

game1	dc.b "c:\copiers\fcopypro.prg",0
	even
game2	dc.b "f:\sndtrack.ers\pt_st20\pt.prg",0
	even
game3	dc.b "e:\packers\atomic\atomic.3_5\atom_v35.prg",0
	even
game4	dc.b "e:\packers\spacker2\spacker2.prg",0
	even
game5	dc.b "e:\monst2.tos",0
	even

*----------

my_vbl	clr.b	$fffffa1b.w			stop timer b
	move.b	#1,$fffffa21.w			increment for each level
	move.l	#timer_b,$120.w
	move.b	#8,$fffffa1b.w			enable timer b
	rte

*----------

timer_b	clr.b	$fffffa1b.w
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	#$fa21,a0
	move.b	#0,(a0)
	move.b	#8,$fffffa1b.w

	move.b	(a0),d0
wait	cmp.b	(a0),d0
	beq.s	wait

	move.w	#194-1,d1
	move.l	#COLS,a1
loop	move.w	(a1)+,$ffff8240.w
	move.b	(a0),d0
wait2	cmp.b	(a0),d0
	beq.s	wait2
	dbra	d1,loop

	movem.l	(sp)+,d0-d1/a0-a1
	bclr	#0,$fffffa0f.w
	rte

*----------

sync	move.w	#37,-(sp)			wait for vertical blank
	trap	#14				call xbios
	addq.l	#2,sp				correct stack
	rts

*----------

off	move.w	#$2700,sr			stop interrupts
	move.l	OLDVBL,$70.w			restore old vbl
	move.l	OLDTIMB,$120.w			restore old timer b
	move.b	OLDA1B,$fffffa1b.w
	move.b	OLDA21,$fffffa21.w
	move.b	OLDA07,$fffffa07.w
	move.b	OLDA09,$fffffa09.w
	move.b	OLDA13,$fffffa13.w
	move.w	#$2300,sr			enable interrupts

	move.w	OLDRES,-(a7)			choose medium res
	move.l	PHYSIC,-(a7)			restore old physic
	move.l	LOGIC,-(a7)			restore old logic
	move.w	#5,-(a7)			set new res
	trap	#14				call xbios
	lea	12(a7),a7			correct stack

	movem.l	OLDPAL,d0-d7
	movem.l	d0-d7,$ffff8240.w		restore old palette

	move.b	#-1,$484.w			turn on keyclick
	move.b	#8,$fffffc02.w			turn on mouse interrupt

	move.l	OLDSTK,-(a7)			back into
	move.w	#$20,-(a7)			usermode
	trap	#1				call gemdos
	addq.l	#6,sp

	rts

*----------

OLDSTK	dc.l	0
OLDRES	dc.l	0
PHYSIC	dc.l	0
LOGIC	dc.l	0
OLDVBL	ds.l	1
OLDTIMB	ds.l	1
OLDPAL	ds.l	8
OLDA1B	ds.b	1
OLDA21	ds.b	1
OLDA07	ds.b	1
OLDA09	ds.b	1
OLDA13	ds.b	1

;		       12345678901234567890123456789012345678901234567890123456789012345678901234567890
ASCII	dc.b	$d,$a,"+------------------------------------------------------------------------------+"
	dc.b	$d,$a,"|                        The Lemmings  Utilities Disk 1                        |"
	dc.b	$d,$a,"+------------------------------------------------------------------------------+",$d,$a
	dc.b	$d,$a,"[ A ] - Fastcopy Pro       [ B ] - Speed Packer v3    [ C ] - Easy Rider v2",$d,$a
	dc.b	$d,$a,"[ D ] - Speed Packer v2    [ E ] - Mon ST v2.25       [ F ] - Mega Depacker v2",$d,$a
	dc.b	$d,$a,"[ G ] - Cheetah v3         [ H ] - Fuzion Mega Ripper",$d,$a
	dc.b	"",0

COLS	dc.w	$000,$100,$200,$300,$400,$500,$600,$700,$700,$700,$700,$700
	dc.w	$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007
	dc.w	$006,$005,$004,$003,$002,$001,$000,$000

null	dc.l	0
oldusp	ds.l	1

	ds.b	200
newsp	ds.l	0