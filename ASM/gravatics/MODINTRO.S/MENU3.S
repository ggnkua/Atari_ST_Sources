
        opt     d+

* macros

super   MACRO                   ;macro to go to supervisor
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,oldsp
        ENDM

unsuper MACRO                   ;macro to go to user
        move.l  oldsp,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        ENDM

* main program

        move.l  4(a7),a3        ; base page
        move.l  #mystack,a7
        move.l  $c(a3),d0       ; text len
        add.l   $14(a3),d0      ; data len
        add.l   $1c(a3),d0      ; BSS len
        add.l   #$100,d0        ; basepage
        move.l  d0,-(sp)
        move.l  a3,-(sp)
        clr.w   -(sp)
        move.w  #$4a,-(sp)
        trap    #1              ; release memory
        add.l   #12,sp

	

        super

	jmp	bmain

	lea	mod_nm1,a4		; load song
	lea	module,a5
	move.l	#150000,a6
	bsr	open

	lea	rot_nm1,a4		; load song
	lea	replay_rot,a5
	move.l	#50000,a6
	bsr	open

	jmp	bmain

*	*	*	*	*	*	*	*	*	*

open	clr.w	-(sp)			; load a file
	move.l	a4,-(sp)		; a4 -> filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	diskerr
	move.w	d0,-(sp)		; store file handle

read	move.l	a5,-(sp)		; read file to data area
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	move.l	d0,d7			; store length

close	move.w	#$3e,-(sp)		; close file
	trap	#1			; handle already on stack
	addq.l	#4,sp
	move.l	d7,d0
	tst.l	d0			; d0=bytes loaded, -ve=err
diskerr	rts

*	*	*	*	*	*	*	*	*	*

bmain   ;move.l  #-1,-(sp)       ;disable mouse
        ;move.l  #-1,-(sp)
        ;clr.l   -(sp)
        ;trap    #14
        ;add     #12,sp
	
	move	#12,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A00A


	move.w	#2,-(sp)
	trap	#14
	move.l	d0,scr_addr
	addq	#2,sp

        move.l  scr_addr,a0      ;copy screen
        move.l  #(main+34),a1
        move.l  #7999,d7
p_cpy_2 move.l  (a1)+,(a0)+
        dbf     d7,p_cpy_2

        move.l  #$ff8240,a0     ;copy palette
        move.l  #(main+2),a1
        move.l  #7,d7
c_pal_2 move.l  (a1)+,(a0)+
        dbf     d7,c_pal_2

        moveq.l #1,d1           ;for interupts
               ;scroll once normally
        movem.l d0-d5/a0-a1,vb2_reg

************************************************************************
* Replay routine that replays -TCB TRACKER- modules  in normal ST mode *
* Made by Anders Nilsson  10/8/90                                      *
* Uses d6-d7/a2-a6 and usp                                             *
************************************************************************
x:
	jmp	amain			*jump to main
save_ints:
	move.b	$fffffa07.w,mfpa07	*save interrupts
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	rts
init_ints:	
	clr.b	$fffffa09.w		*init interrupts
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs,a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#replay_rot+$8918,$134
	move.l	#vbl2,$70
	rts
ret_ints:	
	move.b	mfpa07,$fffffa07.w	*restore interrupts
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	rts

amain:
	move.l	usp,a0			*save usp
	move.l	a0,save_usp

	lea	module,a0		*a0=module start
	moveq	#0,d0			*-1=the default soundtable 0=the other
	jsr	replay_rot+$24		*init. replay routine
	
	jsr	save_ints		*save interrupts
	jsr	init_ints		*init. interrupts
	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	* your routines here..... remember d0-d5/a0-a1 !!!!!!

;	cmp.b	#185,$fffc02		*space

;	cmp.b	#'1',$fffffc02.w
;	bne	demo_loop		*yes/no
;	jsr	ret_ints		*restore interrupts

	cmp.b	#59,$fffffc02.w
	bne	check2
	bra	go1

check2
	cmp.b	#60,$fffffc02.w
	bne	check3
	bra	go2

check3
	cmp.b	#61,$fffffc02.w
	bne	demo_loop
	bra	go3

go1
	move.l	#mess1,l_message
	move.l	#name1,nm_ptr
	jmp	shutdown	

go2	
	move.l	#mess2,l_message
	move.l	#name2,nm_ptr
	jmp	shutdown

go3
	move.l	#mess3,l_message
	move.l	#name3,nm_ptr


shutdown:
	jsr	ret_ints
	move.l	save_usp,a0
	move.l	a0,usp

reset:
	

	move	#8,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A009

	jsr	mouseon

	jmp	load

*exit:
	move.w	#20,-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	
fin     bra.s   fin

* vbl 2 routine

vbl2    movem.l d0-d5/a0-a1,-(sp)
	jsr	replay_rot+$28		*call replay routine
	move.w	#1,wfnc			*set video flag
	
	move.l	#950,d0			;How to waste god knows
wt	dbf	d0,wt			;how many clock cycles.
        movem.l vb2_reg,d0-d5/a0-a1
        
        movem.l d0-d5/a0-a1,vb2_reg
        movem.l (sp)+,d0-d5/a0-a1
        rte


* labels n prog space

        ds.l    100             stack space
mystack ds.w    1               (stacks go backwards)
oldint  dc.l    0
oldsp   dc.l    0

mes_p   dc.l    0
	dc.w	0
chr_ptr dc.l    0
	dc.w	0
vb2_reg ds.l    15              ;buffs for vbl2 regs
scr_addr:
	dc.l	0
mfp_freqs:
	dc.b	24			*10 and 8.3 Khz
	dc.b	29
bar1	dc.b	0
bar2	dc.b	0
bar3	dc.b	0
bar4	dc.b	0
bar1v	dc.b	0
bar2v	dc.b	0
bar3v	dc.b	0
bar4v	dc.b	0
save_usp:
	dc.l	0
wfnc:
	dc.w	0
save_stk:
	dc.l	0
replay_rot:				*the replay routine
	incbin	"a:\tracker.rot",0
;	ds.b	50000
	even
module:					*the module
	incbin	"a:\cimp.mod",0

;	ds.b	80000


mod_nm1	;incbin	"A:\buggin.mod",0
rot_nm1	;incbin	"A:\tracker.rot",0
	even
mfpa07:	dc.b	0			*vars for interrupt saving
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0

* include files

main    incbin  "a:\world.pi1"
        even
font    ;incbin  "a:\font.pi1"





mouseon:
	move	#8,-(sp)
	move	#4,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	dc.w	$A009
	rts


test:
	cmp.b	#57,$fffffc02.w
	beq	prep
	jmp	test

prep:
	move.l	#name1,nm_ptr
	bra	load

;	cmp.w	#0,2000
;	bne	nx1			;goto desktop
;	move.l	#men_nm,nm_ptr
;	bra	load			;load	
;nx1	cmp.w	#1,2000
;	bne	term
;	move.l	#tcb_nm,nm_ptr
;	bra	load

term	unsuper
	clr.w	-(sp)
	trap	#1

load	clr.w	2000
	unsuper
	pea	env_str
	pea	cmd_str
	move.l	nm_ptr,-(sp)
	move.l	#$4b0000,-(sp)
	trap	#1
	add	#16,sp
	clr.w	-(sp)
	trap	#1	

	ds.l	50			stack space
;mystack	ds.w	1			(stacks go backwards)
tcb_nm	dc.b	"99.sss"
name1	dc.b	"desktop.inf"
name2	dc.b	"desktop.inf"
name3	dc.b	"concept.prg"
nm_ptr	dc.l	0
;oldsp	dc.l	0
env_str	dc.b	0,0
cmd_str	dc.b	0,0
l_message	ds.l	1
mess1	dc.b	13,'Loading 1st PRG file...',0
mess2	dc.b	13,'Loading 2nd PRG file...',0
mess3	dc.b	13,'Loading 3rd PRG file...',0


