***********************************************
* Atari ST Printer Buffer by Richard Phillips *
* Atari ST User Januar 1988. Assemble to disc *
* as PBUFFER.TTP. Enter any size between 10-  *
* 9999 kBytes in the command line!		 *
***********************************************
	
* General system variables
palmode  equ $448
vblqueue equ $456
nvbls	equ $454
savptr	equ $4a2
dumpflg	equ $4ee

* Gemdos functions used
term	equ 0
conin	equ 7
prntln	equ 9
k_proces equ $31
malloc	equ $48
setblock equ $4a

* Bios functions used
bconout	equ 3
setexec  equ 5
bconstat equ 8
kbshift  equ 11

* XBios functions used
getrez	equ 4
supexec	equ 38

* Gemdos functions revectored
prntout	equ 5
prntstat equ $11

* 68000 vectors changed
trap1	equ 33

* Initialisation routine
buffer	move.l 4(sp),a6
	pea banner
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	pea init
	move.w #supexec,-(sp)
	trap #14
	addq.l #6,sp
	tst.w buf_flg
	bpl no_err
	pea err_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	bra exit
no_err	bsr prnt_sz
	pea success
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
exit	pea exit_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	move.w #conin,-(sp)
	trap #1
	addq.l #2,sp
	tst.w buf_flg
	bmi no_buf
	clr.w -(sp)
	move.l #code_end-buffer,-(sp)
	move.w #k_proces,-(sp)
	trap #1

* Called if installation error
no_buf	move.w #term,-(sp)
	trap #1

* Installation
init	bsr rels_mem
	tst.w buf_flg
	bmi initexit
	bsr get_size
	tst.w buf_flg
	bmi initexit
	bsr get_time
	bsr init_vbl
	tst.w buf_flg
	bmi initexit
	bsr get_mem
	tst.w buf_flg
	bmi initexit
	bsr setvec 
	move.l vbl_adr,a0
	move.l #buf_vbl,(a0)
initexit	rts

* Give unused memory back to Gemdos
rels_mem	move.l $c(a6),d0
	add.l $14(a6),d0
	add.l $1c(a6),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a6,-(sp)
	clr.w -(sp)
	move.w #setblock,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bne rels_err
	rts

* called if error occurs
rels_err	subq.w #1,buf_flg
	pea blk_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Get size of buffer
get_size	lea $81(a6),a0
	tst.b (a0)+
	beq usage
	subq.l #1,a0
spc_loop	cmp.b #' ',(a0)+
	beq spc_loop
	subq.l #1,a0
	cmp.b #' ',(a0)
	ble cmd_err
	move.l a0,a1
	move.l a0,strt_adr
	clr.l d0
num_loop	cmp.b #' ',(a1)
	bgt not_end
	clr.b (a1)
	bra end_str
not_end	cmp.b #'0',(a1)
	blt cmd_err
	cmp.b #'9',(a1)+
	bgt cmd_err
	addq.l #1,d0
	bra num_loop
end_str	cmp.b #2,d0
	blt too_smll
	cmp.b #4,d0
	bgt too_lrge
	move.l buf_size,d0
get_num	mulu #10,d0
	move.b (a0)+,d1
	sub.b #'0',d1
	add.l d1,d0
	tst.b (a0)
	bne get_num
	move.l #10,d1
	asl.l d1,d0
	move.l d0,buf_size
	move.l #-1,-(sp)
	move.w #malloc,-(sp)
	trap #1
	addq.l #6,sp
	cmp.l buf_size,d0
	blt too_lrge
	rts

* Called if no command supplied
usage	sub.w #1,buf_flg
	pea usge_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Dud command line
cmd_err	sub.w #1,buf_flg
	pea cmd_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Buffer too small
too_smll	sub.w #1,buf_flg
	pea smll_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Buffer too large
too_lrge	sub.w #1,buf_flg
	pea lrge_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Get vertical blank timing
get_time	move.w #getrez,-(sp)
	trap #14
	addq.l #2,sp
	move.w #70,d1
	cmp.w #2,d0
	beq got_time
	move.w #50,d1
	cmp.w #0,palmode
	beq got_time
	move.w #60,d1
got_time	mulu #30,d1
	move.w d1,v_blank
	rts

* Get free slot in VBL table
init_vbl	move.l vblqueue,a0
	move.w nvbls,d0
slt_loop	tst.l (a0)
	beq free_slt
	addq.l #4,a0
	dbra d0,slt_loop
	subq.w #1,buf_flg
	pea vbl_err
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

free_slt	move.l a0,vbl_adr
	rts

* Reserve memory for buffer
get_mem	move.l buf_size,-(sp)
	move.w #malloc,-(sp)
	trap #1
	addq.l #6,sp
	cmp.l #0,d0
	bls mem_err
	move.l d0,buf_adr
	rts

* Called if error allocating memory
mem_err	subq.w #1,buf_flg
	pea mem_str
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Revector Gemdos TRAP #1
setvec	pea gemdos
	move.w #trap1,-(sp)
	move.w #setexec,-(sp)
	trap #13
	addq.l #8,sp
	move.l d0,old_dos
	rts

* Print buffer size
prnt_sz	move.l strt_adr,-(sp)
	move.w #prntln,-(sp)
	trap #1
	addq.l #6,sp
	rts

* Mimic Gemdos exception handler
gemdos	lea 6(sp),a0
	move.w (sp),d0
	btst #13,d0
	bne in_super
	move.l usp,a0
in_super	cmp.w #prntstat,(a0)
	beq buf_stat
	cmp.w #prntout,(a0)
	beq into_buf
	move.l old_dos,-(sp)
	rts

* Get buffer status
buf_stat	move.l chr_cnt,d0
	cmp.l buf_size,d0
	beq buf_full
	move.l #-1,d0
	rte

buf_full	clr.l d0
	rte

* Put character in buffer
into_buf	move.l chr_cnt,d0
	cmp.l buf_size,d0
	beq chk_buf
	move.l buf_adr,a1
	add.l head_ptr,a1
	move.b 3(a0),(a1)
	addq.l #1,head_ptr
	move.l head_ptr,d0
	cmp.l buf_size,d0
	blt no_wrap
	clr.l head_ptr
no_wrap	addq.l #1,chr_cnt
	move.l #-1,d0
	rte

* Wait for time-out
chk_buf	clr.w time_out
chk_time	move.l chr_cnt,d0
	cmp.l buf_size,d0
	bne into_buf
	move.w time_out,d0
	cmp.w v_blank,d0
	blt chk_time
	clr.l d0
	rte

* VBL exception handler
buf_vbl	tst.l chr_cnt
	beq buf_exit
	tst.w dumpflg
	bmi not_dump
	move.w #-1,dumpflg
	rts
not_dump	move.l savptr,old_ptr
	move.l #new_ptr+46,savptr
	move.w #-1,-(sp)
	move.w #kbshift,-(sp)
	trap #13
	addq.l #4,sp
	move.l old_ptr,savptr
	btst #2,d0
	beq nt_flush
	btst #3,d0
	beq nt_flush
	clr.l chr_cnt
	clr.l head_ptr
	clr.l tail_ptr
	rts

* Print character
nt_flush	addq.w #1,time_out
	tst.w buf_on
	bne vbl_exit
	move.w #-1,buf_on
prnt_buf	tst.l chr_cnt
	beq buf_exit
	move.l savptr,old_ptr
	move.l #new_ptr+46,savptr
	clr.w -(sp)
	move.w #bconstat,-(sp)
	trap #13
	addq.l #4,sp
	move.l old_ptr,savptr
	tst.l d0
	beq buf_exit
	move.l #new_ptr+46,savptr
	move.l buf_adr,a0
	add.l tail_ptr,a0
	move.b (a0),d0
	and.w #$ff,d0
	move.w d0,-(sp)
	clr.w -(sp)
	move.w #bconout,-(sp)
	trap #13
	addq.l #6,sp
	move.l old_ptr,savptr
	tst.l d0
	beq buf_exit
	addq.l #1,tail_ptr
	move.l tail_ptr,d0
	cmp.l buf_size,d0
	blt no_alter
	clr.l tail_ptr
no_alter	subq.l #1,chr_cnt
	bra prnt_buf
buf_exit	clr.w buf_on
vbl_exit	rts

* General purpose variables
old_dos	ds.l 1
old_ptr	ds.l 1
new_ptr	ds.b 46
buf_adr	ds.l 1
head_ptr	ds.l 1
tail_ptr	ds.l 1
chr_cnt	ds.l 1
time_out	ds.w 1
buf_on	ds.w 1
v_blank	ds.w 1
buf_size	ds.l 1

* Initialisation variables
vbl_adr	ds.l 1
strt_adr	ds.l 1
buf_flg	ds.w 1

* end of code
code_end

* strings
banner	dc.b 'Atari ST Printer'
	dc.b ' Buffer.',13,10
	dc.b 'By Richard Phillips.'
	dc.b 13,10,13,10,0
usge_str	dc.b 'Usage : pbuffer.ttp'
	dc.b ' <size>.',10,13,0
cmd_str	dc.b 'Error in command line'
	dc.b ' parameter.',10,13,0
smll_str	dc.b 'Buffer size too small.'
	dc.b 10,13,0
lrge_str	dc.b 'Buffer size too big.'
	dc.b 10,13,0
blk_str	dc.b 'Can',39,'t release nem'
	dc.b 'ory.',13,10,0
mem_str	dc.b 'Error in memory allocat'
	dc.b 'ion.',13,10,0
vbl_err	dc.b 'No free VBL slots.',13
	dc.b 10,0
success	dc.b 'K Printer Buffer instal'
	dc.b 'led.',13,10,0
err_str	dc.b 13,10,'No printer buffer'
	dc.b ' installed.',13,10,0
exit_str	dc.b 13,10,'Press any key to'
	dc.b ' exit.',0
the_end	end
