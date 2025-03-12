
*********************************************************************
*
* SpinUp - Custom FDC system
* by Neil Stewart (C)1994 Black Scorpion
*
*********************************************************************

;TESTCODE

	ifd	TESTCODE
FORMAT
FORMATDATA
BOOTSECTOR
DEBUG
	include	"fdc.i"
	endc
	
*********************************************************************
* Other useful hardware registers
* The MFP regs are listed in 'mfp.i'
*********************************************************************

fdc_data	= $ffff8604	; WORD (mask off top byte when reading)
fdc_mode	= $ffff8606	; WORD
fdc_density	= $ffff860e	; WORD
dmahigh		= $ffff8609	; BYTE
dmamid		= $ffff860b	; BYTE
dmalow		= $ffff860d	; BYTE
psg_select	= $ffff8800	; BYTE
psg_data	= $ffff8802	; BYTE

*********************************************************************
* PSG port A register number
*********************************************************************

psg_porta	= 14

*********************************************************************
* Floppy lock and FDC interrupt vector
*********************************************************************

flock		= $43e
fdc_vec		= $11c
timerd_vec	= $110
frclock		= $466

*********************************************************************
* FDC/DMA Mode control masks
*********************************************************************

m_a0		= $02
m_a1		= $04
m_hdc		= $08
m_seccnt	= $10
m_nodma		= $40
m_fdc		= $80
m_write		= $100

; Masks to use instead of m_a0,m_a1 to select register

m_commandreg	= $00
m_trackreg	= $02
m_sectorreg	= $04
m_datareg	= $06

*********************************************************************
; Various useful modes
*********************************************************************

mode_clearfifo1		= m_write|m_fdc|m_seccnt
mode_clearfifo2		= m_fdc|m_seccnt
mode_statusreg		= m_commandreg|m_fdc
mode_commandreg		= m_commandreg|m_fdc
mode_trackreg		= m_trackreg|m_fdc
mode_sectorreg		= m_sectorreg|m_fdc
mode_datareg		= m_datareg|m_fdc
mode_seccnt		= m_seccnt|m_fdc

*********************************************************************
* FDC Command masks
* Main command types (with allowed supplementary values)
*********************************************************************

c_restore	= $00	; nomotorcheck,verify,steprate
c_seek		= $10	; nomotorcheck,verify,steprate
c_step		= $20	; nomotorcheck,verify,steprate,updatetrack
c_stepin	= $40	; nomotorcheck,verify,steprate,updatetrack
c_stepout	= $60	; nomotorcheck,verify,steprate,updatetrack
c_readsector	= $80	; nomotorcheck,multiple,settling
c_writesector	= $a0	; nomotorcheck,multiple,settling,compensate,erased_dmark
c_writetrack	= $f0	; nomotorcheck,settling,compensate
c_interrupt	= $d0	; force interrupt without interrupt

; Supplementary values (extra controls)

c_nomotorcheck	= $08
c_verify	= $04
c_steprate6	= $00
c_steprate12	= $01
c_steprate2	= $02
c_steprate3	= $03
c_updatetrack	= $10
c_multiple	= $10
c_erased_dmark	= $01
c_settling	= $04
c_compensate	= $02

*********************************************************************
* FDC status register - bit allocations
*********************************************************************

s_busy		= 0
s_datarequest	= 1
s_index		= 1
s_lostdata	= 2
s_track0	= 2
s_crcerror	= 3
s_rnf		= 4
s_spinup	= 5
s_rectype	= 5
s_writeprotect	= 6
s_motoron	= 7

; Useful error test masks
; AND s_seekerror after a type 1 command (if verify is used)
; AND s_readerror after a read sector command
; AND s_write error after a write sector
; If the result of the AND operation is 0, then there was no
; error - otherwise, further error checking is required.

s_seekerror	= 1<<s_crcerror|1<<s_rnf
s_readerror	= 1<<s_lostdata|1<<s_crcerror|1<<s_rnf
s_writeerror	= s_readerror|1<<s_writeprotect
s_formaterror	= 1<<s_writeprotect|1<<s_lostdata

*********************************************************************
* Density control equates
* These values must be placed in fdc_density to select drive density
*********************************************************************

density_dd	= $80
density_hd	= $83
density_ed	= $b0

*********************************************************************
* Error/Status codes
*********************************************************************

e_notfinished	= 0
e_ok		= 1
e_generalerror	= -1
e_timeout	= -2
e_diskend	= -3
e_invalidformat	= -4
e_lostdataerror	= -5
e_writeprotect	= -6
e_rnferror	= -7
e_crcerror	= -8

*********************************************************************
* Some useful macros for accessing FDC registers
*********************************************************************

fdc_setmode	macro	(mode)
		move.w	\1,fdc_mode.w
		endm

fdc_setdata	macro	(data)
		move.w	\1,fdc_data.w
		endm

fdc_getdata	macro	(&data)
		move.w	fdc_data.w,\1
		and.w	#$ff,\1
		endm

fdc_command	macro	(command)
		sf	fdc_done
		fdc_setmode	#mode_commandreg
		fdc_setdata	\1
		endm

fdc_command_w	macro	(command)
		sf	fdc_done
		fdc_setmode	#mode_commandreg|m_write
		fdc_setdata	\1
		endm

fdc_status	macro	(&status)
		fdc_setmode	#mode_commandreg
		fdc_getdata	\1
		endm

*********************************************************************
* Header file structure
*********************************************************************

			rsreset
h_starttrack	rs.w	1
h_startside		rs.w	1
h_numsectors	rs.w	1
h_format		rs.w	1
h_alternatesides	rs.w	1

*********************************************************************
* TEST CODE
*********************************************************************

	ifd	TESTCODE
main	
	G_SUPER	#0

	CACHE	0

	move.l	#12288*5,p_timeout
	move.w	#2,p_retries
	bsr	fdc_init
start
	rept	0
	move.w	#0,p_drive
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#80,p_numtracks
	move.w	#79,p_maxtrack
	move.w	#0,p_maxside
	move.w	#fmt_restore,p_flags
	move.l	#st_10,p_tracktable
	bsr	fdc_format
	endr

	rept	0
	move.w	#0,p_drive
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#10,p_numtracks
	move.w	#79,p_maxtrack
	move.w	#1,p_maxside
	move.w	#fmt_restore|fmt_sectormap,p_flags
;	move.w	#fmt_restore,p_flags
	move.l	#falcon_trackweird,p_tracktable
;	move.l	#st_1024,p_tracktable
	bsr	fdc_format
	endr

	rept	0
	move.w	#80,bp_tracks
	move.w	#18,bp_sectors
	move.w	#2,bp_sides
	move.w	#1,bp_spc
	move.w	#112*2,bp_direntries
	move.l	#$779235,bp_serial
;	move.l	#0,bp_bootcode
	move.l	#my_boot,bp_bootcode
	move.w	#my_boot_size,bp_bootsize
	move.b	#$f0,bp_media
	bsr	fdc_create_bootsector

	move.w	#0,p_drive
	move.w	#1,p_density
	bsr	fdc_write_bootsector

	move.w	#0,p_drive
	move.w	#1,p_density
	move.w	#18,p_maxsector
;	bsr	fdc_write_fats
	endr

	rept	0
	move.l	#outbuffer,p_buffer
	move.w	#0,p_drive
	move.w	#0,p_density
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#1,p_sector
	move.w	#9*10,p_numsectors
	move.w	#79,p_maxtrack
	move.w	#9,p_maxsector
	move.w	#1,p_maxside
	move.w	#2,p_secsize
	move.l	#ftw_sectormap,p_secmap
	move.w	#rwf_write|rwf_restore|rwf_sectormap,p_flags
;	move.w	#rwf_write|rwf_restore,p_flags
	bsr	fdc_readwrite
	endr

	rept	1
	move.l	#inbuffer,p_buffer
	move.w	#0,p_drive
	move.w	#0,p_density
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#2,p_sector
	move.w	#1,p_numsectors
	move.w	#79,p_maxtrack
	move.w	#9,p_maxsector
	move.w	#1,p_maxside
	move.w	#2,p_secsize
	move.w	#rwf_write|rwf_restore,p_flags
	bsr	fdc_readwrite
	endr

	bsr	kill_drive
	bsr	fdc_kill
check
	fdc_setmode	#mode_trackreg
	fdc_getdata	d0
	moveq	#0,d1
	move.b	fdc_done,d1
	moveq	#0,d2
	move.b	dmahigh,d2
	lsl.l	#8,d2
	move.b	dmamid,d2
	lsl.l	#8,d2
	move.b	dmalow,d2
checked

doneall
	clr.w	-(sp)
	trap	#1

bugger
;	dc.b	2,2,2,2,2,2,2,2,2
	dc.b	2,2,2,2,2,2,2,2,3
	even

testproggy
;	incbin	"e:\fdc\booter.s"
;	incbin	"e:\fdc\booter.prg"
	even

	endc

*********************************************************************
* FDC_INIT & FDC_KILL
* Fdc_init must be called before proceeding with floppy routines
* and fdc_kill must be used afterwards. Fdc_init locks out the
* system's disk access and sets up an interrupt structure. Fdc_kill
* restores the system to the way it was before (cleanly). This
* system lets you use custom routines alongside GEMDOS stuff without
* interference (although not both at once).
* The FDC system also uses timer D to count clock ticks for timeout
* testing. These occur at 12288Hz, so 12288 in the timeout counter means
* 'timeout after 1 second'.
*********************************************************************

fdc_init
	pushall
	move.w	sr,-(sp)
	move.w	#$2700,sr
	st	flock.w

	move.l	fdc_vec.w,old_fdc_vec
	move.l	#dummy_fdc,fdc_vec.w

	bset.b	#M_B_FDC,M_ENABLE_B.w
	sne	mfp_was_enabled
	bset.b	#M_B_FDC,M_MASK_B.w
	sne	mfp_was_masked

	move.l	timerd_vec.w,old_timerd_vec
	move.l	#new_timerd,timerd_vec.w

	move.b	M_CONTROL_CD.w,d0
	and.b	#$f0,d0
	move.b	d0,M_CONTROL_CD.w
	move.b	#1,M_DATA_D.w		; clock/200 = 12288 Hz
	or.b	#$7,d0
	move.b	d0,M_CONTROL_CD.w

	bset.b	#M_B_TIMERD,M_ENABLE_B.w
	sne	timer_was_enabled
	bset.b	#M_B_TIMERD,M_MASK_B.w
	sne	timer_was_masked
	
	move.w	(sp)+,sr
	popall
	rts

fdc_kill
	pushall
	move.w	sr,-(sp)
	move.w	#$2700,sr

	tst.b	timer_was_enabled
	bne.s	.leave_enable
	bclr.b	#M_B_TIMERD,M_ENABLE_B.w
.leave_enable
	tst.b	timer_was_masked
	bne.s	.leave_mask
	bclr.b	#M_B_TIMERD,M_MASK_B.w
.leave_mask
	move.l	old_timerd_vec,timerd_vec.w

	tst.b	mfp_was_enabled
	bne.s	.leave_enable2
	bclr.b	#M_B_FDC,M_ENABLE_B.w
.leave_enable2
	tst.b	mfp_was_masked
	bne.s	.leave_mask2
	bclr.b	#M_B_FDC,M_MASK_B.w
.leave_mask2
	move.l	old_fdc_vec,fdc_vec.w

	sf	flock.w
	move.w	(sp)+,sr
	popall
	rts

*********************************************************************
* FDC_WAIT & DUMMY_FDC
* Fdc_wait & dummy_fdc allow very simple floppy access, although the
* interrupt system is much more elegant. Dummy_fdc is the default
* FDC vector and simply sets a flag when it is executed. Fdc_wait
* will wait in a loop until this flag (fdc_done) is set. For example,
* to execute a sequence of commands properly, you simply clear
* the flag (eg. using 'sf fdc_done'), issue the command and then
* call fdc_wait, which will return when the command has been completed.
* Dummy_fdc puts the FDC status in the variable fdc_status, which
* you can check afterwards for any errors.
*********************************************************************

fdc_wait
	move.l	d0,-(sp)
	move.l	p_timeout,d0
.wait
	tst.b	fdc_done
	bne.s	.done
	clr.w	fdc_timerdone
.wait_timer
	tst.w	fdc_timerdone
	beq.s	.wait_timer
	subq.l	#1,d0
	bne.s	.wait

	fdc_command	#c_interrupt
	moveq	#10-1,d0
.wait2
	clr.w	fdc_timerdone
.wait_timer2
	tst.w	fdc_timerdone
	beq.s	.wait_timer2
	dbf	d0,.wait2
	fdc_status	d0
	move.b	#e_timeout,fdc_done
.done
	move.l	(sp)+,d0
	rts

dummy_fdc
	move.l	d0,-(sp)
	fdc_status	d0
	move.w	d0,fdc_errors
	move.b	#1,fdc_done
	bclr.b	#M_B_FDC,M_INSERVICE_B.w
	move.l	(sp)+,d0
	rte

new_timerd
	move.w	#1,fdc_timerdone
	bclr.b	#M_B_TIMERD,M_INSERVICE_B.w
	rte
	
*********************************************************************
* SELECT_DRIVE & KILL_DRIVE
* These two routines let you select an active floppy drive/side
* and then switch them off.
*
* Select_drive takes two parameters:
*	d0 = drive number (0=A , 1=B)
*	d1 = side (0=Side 1 , 1=Side 2)
*
* Kill_drive will wait until the drive motor has stopped and then
* switch the drive off.
*********************************************************************

select_drive
	movem.l	d0-d2,-(sp)
	move.w	sr,-(sp)
	move.w	#$2700,sr	
	move.b	#psg_porta,psg_select.w
	move.b	psg_select.w,d2
	and.b	#$f8,d2
	or.b	#6,d2
	and.b	#1,d1
	eor.b	#1,d1
	or.b	d1,d2
	moveq	#2,d1
	and.b	#1,d0
	lsl.b	d0,d1
	eor.b	d1,d2
	move.b	d2,psg_data.w
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d2
	rts

kill_drive
	movem.l	d0-d2,-(sp)
	cmp.b	#e_timeout,fdc_done
	beq.s	.wait_over
	move.l	p_timeout,d1
.wait
	fdc_status	d0
	btst	#s_motoron,d0
	beq.s	.wait_over
	clr.w	fdc_timerdone
.wait_timer
	tst.w	fdc_timerdone
	beq.s	.wait_timer
	tst.b	fdc_done
	bpl.s	.wait
	subq.l	#1,d1
	bne.s	.wait
.wait_over
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	#psg_porta,psg_select.w
	move.b	psg_select.w,d2
	and.b	#$f8,d2
	or.b	#6,d2
	move.b	d2,psg_data.w
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d2
	rts

*********************************************************************
* Simple FDC register access routines
* Fdc_clearfifo - clear the FDC's DMA buffer (alway do before
* a data transfer command).
* Fdc_setreg(register,value) - set an FDC register
* Fdc_getreg(register,value) - read an FDC register -> d1
*********************************************************************

fdc_clearfifo
	fdc_setmode	#mode_clearfifo1
	fdc_setmode	#mode_clearfifo2
	rts
	
fdc_setreg
; d0 = register, d1 = value
	move.l	d0,-(sp)
	or.w	fdc_write,d0
	fdc_setmode	d0
	fdc_setdata	d1
	move.l	(sp)+,d0
	rts

fdc_getreg
; d0 = register, value -> d1
	move.l	d0,-(sp)
	or.w	fdc_write,d0
	fdc_setmode	d0
	fdc_getdata	d1
	move.l	(sp)+,d0
	rts

*********************************************************************
* Read/Write Sector System
* Advanced features:
*	Ability to use a sector map (different sector sizes in track)
*	Alternate side switching or end of side switching
*********************************************************************

; Flag masks
; 'Alternatesides' makes the system switch sides at the end of a
; track and only steps in after side 2 (if there are two sides).
; If it is off, the system reads from the same side until it
; reaches the end and then switches sides automatically.
; 'Autodensity' tells the system to calculate the density by itself.
; As this is based on 'p_maxsectors', it should only be used for
; basic 512 byte (non-mapped) sector formats.

rwf_write		= $01	; write sectors
rwf_alternatesides	= $02	; alternate sides at each track boudary
rwf_restore		= $04	; do a restore before read
rwf_autodensity		= $08	; calculate density from maxsectors
rwf_sectormap		= $10	; use a sectormap
rwf_driveoff		= $20	; kill drive after transfer

fdc_readwrite

	pushall

	move.w	p_drive,d0
	move.w	p_side,d1
	bsr	select_drive

; Calculate density and seekspeed codes

	move.w	p_flags,d0
	and.w	#rwf_autodensity,d0
	bne.s	.autodensity
	move.w	p_density,d1
	bra.s	.got_density
.autodensity
	lea	tb_density,a0
	move.w	p_maxsector,d0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
.got_density
	add.w	d1,d1
	lea	tb_densitycode,a0
	move.w	(a0,d1.w),p_densitycode
	lea	tb_seekspeed,a0
	move.w	(a0,d1.w),p_seekspeed

; Set write flag

	clr.w	p_writeflag
	clr.w	fdc_write
	move.w	p_flags,d0
	and.w	#rwf_write,d0
	beq.s	.no_write
	not.w	p_writeflag
	move.w	#m_write,fdc_write
.no_write

; Set density in hardware

	move.w	p_densitycode,fdc_density.w

; Perform a restore (if needed)

	move.w	p_flags,d0
	and.w	#rwf_restore,d0
	beq	.no_restore
	bsr	fdc_restore
	tst.b	fdc_done
	bmi	.ERROR
.no_restore

; Seek to first used track

	bsr	fdc_seek
	tst.b	fdc_done
	bmi	.ERROR

; Now we start to transfer the data

.transfer_loop

; Check if we have transfered all sectors - exit if we have

	tst.w	p_numsectors
	bgt	.not_all_done
	move.b	#1,fdc_done
	bra	.DONE
.not_all_done

; Check if sector has passed off end of track
; If it has, then we perform a step in (or switch sides)

	move.w	p_sector,d0
	cmp.w	p_maxsector,d0
	ble	.sector_ok
	move.w	#1,p_sector

; Do we try do switch sides ?

	move.w	p_flags,d0
	and.w	#rwf_alternatesides,d0
	beq.s	.just_step_in

; Yes, but check we can do so.

	move.w	p_side,d0
	addq.w	#1,d0
	cmp.w	p_maxside,d0
	ble.s	.side_ok
	clr.w	p_side
	move.w	p_drive,d0
	moveq	#0,d1
	bsr	select_drive
	bra.s	.just_step_in

.side_ok
	move.w	d0,p_side
	move.w	d0,d1
	move.w	p_drive,d0
	bsr	select_drive
	bra	.sector_ok
		
; Step in, check that we have not passed the end of the disk

.just_step_in
	move.w	p_track,d0
	addq.w	#1,d0
	cmp.w	p_maxtrack,d0
	ble	.track_ok

; Reached last track
; If we can switch sides, then we do that.
; If we cannot, then we return an end of disk error.

	move.w	p_side,d0
	addq.w	#1,d0
	cmp.w	p_maxside,d0
	bgt.s	.end_of_disk
	move.w	d0,p_side
	move.w	d0,d1
	move.w	p_drive,d0
	bsr	select_drive

; Perform a restore (to start of next side)

	bsr	fdc_restore
	tst.b	fdc_done
	bmi	.ERROR
	clr.w	p_track
	bra	.sector_ok

.end_of_disk
	move.b	#e_diskend,fdc_done
	bra	.ERROR

; Next track OK, so send step_in command

.track_ok
	bsr	fdc_stepin
	tst.b	fdc_done
	bmi	.ERROR
	bra	.transfer_loop

; Sector number OK, so we read it.

.sector_ok
	bsr	fdc_rw_sector
	tst.b	fdc_done
	bmi	.ERROR
	addq.w	#1,p_sector
	subq.w	#1,p_numsectors
	bra	.transfer_loop

.DONE
.ERROR
	move.w	p_flags,d0
	and.w	#rwf_driveoff,d0
	beq.s	.keep_drive_running
	bsr	kill_drive
.keep_drive_running

	popall
	rts

*********************************************************************
; Floppy Control Parameters
; A sectormap is used if the flag is set. In this case, .sectorsize
; is not used and the values in the sectormap are used instead.
; The table pointed to by p_secmap must contain enough entries
; so that we can handle disk errors properly.
*********************************************************************

p_params
p_buffer	ds.l	1	; dma input/output buffer
p_density	ds.w	1	; density (0=DD, 1=HD, 2=ED)
p_flags		ds.w	1	; various flags
p_track		ds.w	1	; start track number
p_side		ds.w	1	; start side (0 or 1)
p_drive		ds.w	1	; drive number (0 or 1)
p_sector	ds.w	1	; start sector
p_numsectors	ds.w	1	; number of sectors to read
p_numtracks	ds.w	1	; number of tracks to format
p_maxtrack	ds.w	1	; maximum track
p_maxsector	ds.w	1	; maximum sector
p_maxside	ds.w	1	; maximum side (0 or 1)
p_secsize	ds.w	1	; sector size (0=128 bytes,...)
p_secmap	ds.l	1	; address of sector size map
p_timeout	ds.l	1	; timeout (counted in VBLs/clock ticks)
p_retries	ds.w	1	; number of retries
p_tracktable	ds.l	1	; pointer to track format info

; These parameters are calculated

p_seekspeed	ds.w	1
p_densitycode	ds.w	1
p_writeflag	ds.w	1
p_triesleft	ds.w	1

*********************************************************************
* Restore head to track 0
*********************************************************************

fdc_restore
	pushall
	move.w	p_retries,p_triesleft
.try_again
	move.w	#c_restore,d0
	or.w	p_seekspeed,d0
	fdc_command	d0
	bsr	fdc_wait
	tst.b	fdc_done
	bmi.s	.ERROR
	move.w	fdc_errors,d0
	and.w	#s_seekerror,d0
	beq.s	.restore_ok
	subq.w	#1,p_triesleft
	bgt.s	.try_again
	bsr	fdc_seekerr_examine
.restore_ok
	move.w	#mode_trackreg,d0
	moveq	#0,d1
	bsr	fdc_setreg
.ERROR
	popall
	rts

*********************************************************************
* Seek to the track in p_track
*********************************************************************

fdc_seek
	pushall
	move.w	p_retries,p_triesleft
.try_again
	move.w	#mode_datareg,d0
	move.w	p_track,d1
	bsr	fdc_setreg
	move.w	#c_seek,d0
	or.w	p_seekspeed,d0
	fdc_command	d0
	bsr	fdc_wait
	tst.b	fdc_done
	bmi.s	.ERROR
	move.w	fdc_errors,d0
	and.w	#s_seekerror,d0
	beq.s	.seek_ok
	subq.w	#1,p_triesleft
	bgt.s	.try_again
	bsr	fdc_seekerr_examine
.seek_ok
.ERROR
	popall
	rts

*********************************************************************
* Step in/out a track
*********************************************************************

fdc_stepin
	pushall
	move.w	#c_stepin|c_updatetrack,d1
	addq.w	#1,p_track
	bra.s	fdc_step_do
fdc_stepout
	pushall
	move.w	#c_stepout|c_updatetrack,d1
	subq.w	#1,p_track
fdc_step_do
	or.w	p_seekspeed,d1
	move.w	p_retries,p_triesleft
.try_again
	fdc_command	d1
	bsr	fdc_wait	
	tst.b	fdc_done
	bmi.s	.ERROR
	move.w	fdc_errors,d0
	and.w	#s_seekerror,d0
	beq.s	.stepin_ok
	subq.w	#1,p_triesleft
	bgt.s	.try_again
	bsr	fdc_seekerr_examine
.stepin_ok	
	popall
.ERROR
	rts

*********************************************************************
* Examine the status register after a seek/step error and
* set the correct error code in fdc_done.
*********************************************************************

fdc_seekerr_examine
	pushall
	move.w	fdc_errors,d0
	btst	#s_crcerror,d0
	beq.s	.not_crcerror
	move.b	#e_crcerror,fdc_done
	bra.s	.DONE
.not_crcerror
	btst	#s_rnf,d0
	beq.s	.not_rnferror
	move.b	#e_rnferror,fdc_done
	bra.s	.DONE
.not_rnferror
	move.b	#e_generalerror,fdc_done
.DONE
	popall
	rts

*********************************************************************
* Read write a sector on the current track
*********************************************************************

fdc_rw_sector
	pushall
	move.w	p_retries,p_triesleft
.try_again
	bsr	fdc_clearfifo

; Set DMA start address

	move.b	p_buffer+3,dmalow.w
	move.b	p_buffer+2,dmamid.w
	move.b	p_buffer+1,dmahigh.w

	move.w	#mode_seccnt,d0
	move.w	#2,d1
	bsr	fdc_setreg

	move.w	#mode_sectorreg,d0
	move.w	p_sector,d1
	bsr	fdc_setreg
	tst.w	p_writeflag
	bne.s	.write_sector
	move.w	#c_readsector,d0
	or.w	p_seekspeed,d0
	fdc_command	d0
	bra.s	.got_readwrite
.write_sector
	move.w	#c_writesector|c_compensate,d0
	or.w	p_seekspeed,d0
	fdc_command_w	d0
.got_readwrite
	bsr	fdc_wait
	tst.b	fdc_done
	bmi	.ERROR

	move.w	fdc_errors,d0
	move.w	#s_readerror,d1
	tst.w	p_writeflag
	beq.s	.not_write
	move.w	#s_writeerror,d1
.not_write
	and.w	d0,d1
	beq.s	.transfer_ok
	subq.w	#1,p_triesleft
	bgt	.try_again
	bsr	fdc_rwerr_examine
	bra.s	.ERROR
.transfer_ok

	moveq	#0,d0
	move.b	dmahigh.w,d0
	lsl.w	#8,d0
	move.b	dmamid.w,d0
	lsl.l	#8,d0
	move.b	dmalow.w,d0
	
; Move our pointer onwards (using sector size)

	move.l	p_buffer,a0
	move.w	p_secsize,d0
	move.w	p_flags,d1
	and.w	#rwf_sectormap,d1
	beq.s	.got_size
	tst.l	p_secmap
	beq.s	.got_size
	move.l	p_secmap,a1
	move.w	p_sector,d1
	subq.w	#1,d1
	moveq	#0,d0
	move.b	(a1,d1.w),d0
.got_size
	add.w	d0,d0
	lea	tb_sectorsize,a1
	add.w	(a1,d0.w),a0
	move.l	a0,p_buffer

.ERROR
.DONE
	popall
	rts

*********************************************************************
* Examine the status register after a read/write error and
* set the correct error code in fdc_done.
*********************************************************************

fdc_rwerr_examine
	pushall
	move.w	fdc_errors,d0
	btst	#s_crcerror,d0
	beq.s	.not_crcerror
	move.b	#e_crcerror,fdc_done
	bra.s	.DONE
.not_crcerror
	btst	#s_rnf,d0
	beq.s	.not_rnferror
	move.b	#e_rnferror,fdc_done
	bra.s	.DONE
.not_rnferror
	btst	#s_lostdata,d0
	beq.s	.not_lostdataerror
	move.b	#e_lostdataerror,fdc_done
	bra.s	.DONE
.not_lostdataerror

	tst.w	p_writeflag
	beq.s	.no_wp_check
	btst	#s_writeprotect,d0
	beq.s	.not_wperror
	move.b	#e_writeprotect,fdc_done
	bra.s	.DONE
.not_wperror
.no_wp_check
	move.b	#e_generalerror,fdc_done
.DONE
	popall
	rts

*********************************************************************
* Format System
* Advanced features:
*	Ability to use a sector map (different sector sizes in track)
*	Alternate side switching or end of side switching
* This uses the same set of parameters and flags as the read/write
* system.
*********************************************************************

	ifd	FORMAT

; Flag masks
; 'Alternatesides' makes the system switch sides at the end of a
; track and only steps in after side 2 (if there are two sides).
; If it is off, the system formats the same side until it
; reaches the end and then switches sides automatically.

fmt_alternatesides	= $01	; alternate sides at each track boudary
fmt_restore		= $02	; do a restore before starting
fmt_sectormap		= $04	; use sectormap
fmt_driveoff		= $08	; kill drive after transfer

fdc_format

	pushall

	move.l	p_tracktable,a0
	lea	track_table,a1
	bsr	fdc_copy_tracktable

	bsr	fdc_estimate_track
	tst.w	d0
	bpl	.estimate_ok
	move.b	#e_invalidformat,fdc_done
	bra	.ERROR
.estimate_ok

	bsr	fdc_generate_track

	move.w	p_drive,d0
	move.w	p_side,d1
	bsr	select_drive

; Calculate density and seekspeed codes

	move.w	t_density,d1
	add.w	d1,d1
	lea	tb_densitycode,a0
	move.w	(a0,d1.w),p_densitycode
	lea	tb_seekspeed,a0
	move.w	(a0,d1.w),p_seekspeed

; Set write flag

	move.w	#1,p_writeflag
	move.w	#m_write,fdc_write

; Set density in hardware

	move.w	p_densitycode,fdc_density.w

; Perform a restore (if needed)

	move.w	p_flags,d0
	and.w	#fmt_restore,d0
	beq	.no_restore
	bsr	fdc_restore
	tst.b	fdc_done
	bmi	.ERROR
.no_restore

; Seek to first used track

	bsr	fdc_seek
	tst.b	fdc_done
	bmi	.ERROR

.transfer_loop

; Check if we have transfered all tracks - exit if we have

	tst.w	p_numtracks
	bgt	.not_all_done
	move.b	#1,fdc_done
	bra	.DONE
.not_all_done
	subq.w	#1,p_numtracks

; Fix the ID fields for this track & side

	move.w	p_track,d0
	move.w	p_side,d1
	lea	t_id_list,a0
	move.w	t_numsectors,d7
	beq	.fixed_ids
	subq.w	#1,d7
.fix_id_loop
	move.l	(a0)+,a1
	move.b	d0,ti_track(a1)
	move.b	d1,ti_side(a1)
	dbf	d7,.fix_id_loop
.fixed_ids

; Format the track

	bsr	fdc_writetrack

;(*) do some error checking

; Do we try do switch sides ?

	move.w	p_flags,d0
	and.w	#fmt_alternatesides,d0
	beq.s	.just_step_in

; Yes, but check we can do so.

	move.w	p_side,d0
	addq.w	#1,d0
	cmp.w	p_maxside,d0
	ble.s	.side_ok
	clr.w	p_side
	move.w	p_drive,d0
	moveq	#0,d1
	bsr	select_drive
	bra.s	.just_step_in

.side_ok
	move.w	d0,p_side
	move.w	d0,d1
	move.w	p_drive,d0
	bsr	select_drive
	bra	.transfer_loop
		
; Step in, check that we have not passed the end of the disk

.just_step_in
	move.w	p_track,d0
	addq.w	#1,d0
	cmp.w	p_maxtrack,d0
	ble	.track_ok

; Reached last track
; If we can switch sides, then we do that.
; If we cannot, then we return an end of disk error.

	move.w	p_side,d0
	addq.w	#1,d0
	cmp.w	p_maxside,d0
	bgt.s	.end_of_disk
	move.w	d0,p_side
	move.w	d0,d1
	move.w	p_drive,d0
	bsr	select_drive

; Perform a restore (to start of next side)

	bsr	fdc_restore
	tst.b	fdc_done
	bmi	.ERROR
	clr.w	p_track
	bra	.transfer_loop

.end_of_disk
	move.b	#e_diskend,fdc_done
	bra	.ERROR

; Next track OK, so send step_in command

.track_ok
	bsr	fdc_stepin
	tst.b	fdc_done
	bmi	.ERROR
	bra	.transfer_loop

.DONE
.ERROR
	move.w	p_flags,d0
	and.w	#fmt_driveoff,d0
	beq.s	.keep_drive_running
	bsr	kill_drive
.keep_drive_running

	popall
	rts

*********************************************************************
* Write a track
*********************************************************************

fdc_writetrack
	pushall
	move.w	p_retries,p_triesleft
.try_again
	bsr	fdc_clearfifo

	move.w	#mode_seccnt,d0
	move.w	#64,d1
	bsr	fdc_setreg

; Set DMA start address (points to track buffer)

	move.l	#track_buffer,d0
	move.b	d0,dmalow.w
	ror.l	#8,d0
	move.b	d0,dmamid.w
	ror.l	#8,d0
	move.b	d0,dmahigh.w

; Write the current track

	move.w	#c_writetrack|c_compensate,d0
	or.w	p_seekspeed,d0
	fdc_command_w	d0
	bsr	fdc_wait
	tst.b	fdc_done
	bmi.s	.ERROR
	move.w	fdc_errors,d0
	and.w	#s_formaterror,d0
	beq.s	.restore_ok
	subq.w	#1,p_triesleft
	bgt	.try_again
	bsr	fdc_formaterr_examine
.restore_ok

.ERROR
	popall
	rts

*********************************************************************
* Examine the status register after a read/write error and
* set the correct error code in fdc_done.
*********************************************************************

fdc_formaterr_examine
	pushall
	move.w	fdc_errors,d0
	btst	#s_lostdata,d0
	beq.s	.not_lostdataerror
	move.b	#e_lostdataerror,fdc_done
	bra.s	.DONE
.not_lostdataerror
	btst	#s_writeprotect,d0
	beq.s	.not_wperror
	move.b	#e_writeprotect,fdc_done
	bra.s	.DONE
.not_wperror
	move.b	#e_generalerror,fdc_done
.DONE
	popall
	rts

*********************************************************************
* Routines to generate tracks for formatting
*********************************************************************

tt_gap4e	= $4e
tt_gap00	= $00
tt_sync		= $f5
tt_crd		= $f7
tt_dam		= $fb
tt_id		= $fe
tt_gap1min	= 32
tt_gap2min	= 3
tt_gap4min	= 24
tt_gap5min	= 16

		rsreset
ti_id		rs.b	1
ti_track	rs.b	1
ti_side		rs.b	1
ti_sector	rs.b	1
ti_length	rs.b	1
ti_crc		rs.b	1
ti_skip		rs.b	0

track_table
t_numsectors	ds.w	1
t_sectorsize	ds.w	1
t_density	ds.w	1
t_gap1		ds.w	1
t_gap2		ds.w	1
t_gap2sync	ds.w	1
t_gap3a		ds.w	1
t_gap3b		ds.w	1
t_gap3sync	ds.w	1
t_gap4		ds.w	1
t_sectormap	ds.l	1
end_track_table
track_tabsize	= end_track_table-track_table


fdc_estimate_track
	moveq	#0,d0
	move.w	t_gap1,d0
	add.w	#tt_gap5min,d0
	moveq	#0,d7
	move.w	t_numsectors,d6
	beq	.ERROR
	subq.w	#1,d6
.sector_loop
	add.w	t_gap2,d0
	add.w	t_gap2sync,d0
	add.w	t_gap3a,d0
	add.w	t_gap3b,d0
	add.w	t_gap3sync,d0
	add.w	t_gap4,d0
	
	move.w	p_flags,d1
	and.w	#fmt_sectormap,d1
	beq	.no_sectormap
	tst.l	t_sectormap
	beq.s	.no_sectormap
	move.l	t_sectormap,a1
	moveq	#0,d5
	move.b	(a1,d7.w),d5
	bra.s	.got_sectorsize
.no_sectormap
	move.w	t_sectorsize,d5
.got_sectorsize
	add.w	d5,d5
	lea	tb_sectorsize,a1
	move.w	(a1,d5.w),d5
	add.w	#3,d5
	add.w	d5,d0

	add.w	#ti_skip,d0
	addq.w	#1,d7
	dbf	d6,.sector_loop

	moveq	#0,d1
	move.w	t_density,d1
	add.w	d1,d1
	lea	tb_densitytrack,a0
	move.w	(a0,d1.w),d1
	sub.w	d0,d1
	bge.s	.DONE

.ERROR
	neg.w	d1		; negate overflow amount
	moveq	#-1,d0
.DONE
	rts

fdc_generate_track
	movem.l	d1-a6,-(sp)

	lea	track_buffer,a0
	lea	t_id_list,a6

	move.w	t_gap1,d0
	move.w	#tt_gap4e,d1
	bsr	.fill

	moveq	#0,d7
	move.w	t_numsectors,d6
	beq	.ERROR
	subq.w	#1,d6
.sector_loop

	move.w	t_gap2,d0
	move.w	#tt_gap00,d1
	bsr	.fill
	move.w	t_gap2sync,d0
	move.w	#tt_sync,d1
	bsr	.fill

	move.l	a0,(a6)+		; put id address in list
	move.b	#tt_id,(a0)+
	clr.b	(a0)+
	clr.b	(a0)+
	move.w	d7,d5
	addq.w	#1,d5
	move.b	d5,(a0)+
	moveq	#0,d5
	move.w	p_flags,d1
	and.w	#fmt_sectormap,d1
	beq.s	.no_sectormap
	tst.l	t_sectormap
	beq.s	.no_sectormap
	move.l	t_sectormap,a1
	move.b	(a1,d7.w),d5
	bra.s	.got_sectorsize
.no_sectormap
	move.w	t_sectorsize,d5
.got_sectorsize
	move.b	d5,(a0)+

	move.b	#tt_crd,(a0)+

	move.w	t_gap3a,d0
	move.w	#tt_gap4e,d1
	bsr	.fill
	move.w	t_gap3b,d0
	move.w	#tt_gap00,d1
	bsr	.fill
	move.w	t_gap3sync,d0
	move.w	#tt_sync,d1
	bsr	.fill

	move.b	#tt_dam,(a0)+
	lea	tb_sectorsize,a1
	add.w	d5,d5
	move.w	(a1,d5.w),d5
	move.w	d5,d0
	move.w	#$0,d1		(*) e5
	bsr	.fill
	move.b	#tt_crd,(a0)+

	move.w	t_gap4,d0
	move.w	#tt_gap4e,d1
	bsr	.fill
	
	addq.w	#1,d7
	dbf	d6,.sector_loop

	move.w	t_density,d0
	add.w	d0,d0
	lea	tb_densitytrack,a1
	move.w	(a1,d0.w),d0
	move.l	a0,d1
	sub.l	#track_buffer,d1
	sub.w	d1,d0
	cmp.w	#tt_gap5min,d0
	blt.s	.ERROR
	move.w	#tt_gap4e,d1
	bsr	.fill
	moveq	#0,d0
	bra.s	.DONE

.ERROR
	moveq	#-1,d0
.DONE
	movem.l	(sp)+,d1-a6
	rts

.fill
	subq.w	#1,d0
	bmi.s	.filled
.fill_lp
	move.b	d1,(a0)+
	dbf	d0,.fill_lp
.filled
	rts

fdc_copy_tracktable
	pushall
	move.w	#track_tabsize/2-1,d0
.lp
	move.w	(a0)+,(a1)+
	dbf	d0,.lp
	popall
	rts

	endc

*********************************************************************
* Useful format tables
*********************************************************************

	ifd	FORMATDATA

st_9
	dc.w	10,2,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	0
st_1024
	dc.w	4,3,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	0
st_10
	dc.w	10,2,0		; numsectors, size, density
	dc.w	60		; gap 1
	dc.w	12,3		; gap 2
	dc.w	22,12,3		; gap 3
	dc.w	40		; gap 4
	dc.l	0		; sectormap

ftw1
falcon_trackweird1
	dc.w	9,2,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	ftw_sectormap1
ftw_sectormap1
	dc.b	3,2,2,2,2,2,2,2,2
	even
ftw2
falcon_trackweird2
	dc.w	9,2,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	ftw_sectormap2
ftw_sectormap2
	dc.b	2,2,2,3,2,2,2,2,2
	even
ftw3
falcon_trackweird3
	dc.w	9,2,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	ftw_sectormap3
ftw_sectormap3
	dc.b	2,2,2,2,2,2,2,2,3
	even
ftw4
falcon_trackweird4
	dc.w	9,2,0
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	ftw_sectormap4
ftw_sectormap4
	dc.b	2,2,2,2,2,3,2,2,2
	even

pc_18
	dc.w	18,2,1
	dc.w	60
	dc.w	12,3
	dc.w	22,12,3
	dc.w	40
	dc.l	0

	endc
	
*********************************************************************
* Bootsector System
* This is a set of routines to create and write bootsectors and/or
* initialise the FAT/Directory tables on the disk.
*********************************************************************

	ifd	BOOTSECTOR

*********************************************************************
* Generate a boot sector
*********************************************************************

		rsreset
bs_bra		rs.b	2
bs_filler	rs.b	6
bs_serial	rs.b	3
bs_bps		rs.b	2
bs_spc		rs.b	1
bs_res		rs.b	2
bs_nfats	rs.b	1
bs_ndirs	rs.b	2
bs_nsects	rs.b	2
bs_media	rs.b	1
bs_spf		rs.b	2
bs_spt		rs.b	2
bs_nsides	rs.b	2
bs_nhid		rs.b	2
bs_bootcode	rs.b	480
bs_checksum	rs.b	2

bt_branch	= $601c
bt_intelbranch	= $601c	(*) fix this value
bt_checksum	= $1234

; Parameters for creator

bp_params
bp_tracks	ds.w	1
bp_sectors	ds.w	1
bp_sides	ds.w	1
bp_spc		ds.w	1
bp_direntries	ds.w	1
bp_serial	ds.l	1
bp_bootcode	ds.l	1
bp_bootsize	ds.w	1
bp_media	ds.b	1
		even

bootsector_buffer
		ds.b	512

putintel	macro	src,dest
		movem.l	d7/a6,-(sp)
		move.w	\1,d7
		lea	\2,a6
		move.b	d7,(a6)
		lsr.w	#8,d7
		move.b	d7,1(a6)
		movem.l	(sp)+,d7/a6
		endm

getintel	macro	src,dest
		movem.l	d7/a6,-(sp)
		lea	\1,a6
		move.b	(a6),d7
		lsl.w	#8,d7
		move.b	1(a6),d7
		move.w	d7,\2
		movem.l	(sp)+,d7/a6
		endm

fdc_create_bootsector
	pushall

; BRANCH command

	lea	bootsector_buffer,a0
	putintel	#0,bs_bra(a0)

; OEM string

	move.l	#" IBM",bs_filler(a0)
	move.b	#$90,bs_filler(a0)
	clr.w	bs_filler+4(a0)

; SERIAL number

	move.l	bp_serial,d0
	move.b	d0,bs_serial+2(a0)
	lsr.l	#8,d0
	move.b	d0,bs_serial+1(a0)
	lsr.l	#8,d0
	move.b	d0,bs_serial(a0)

; BPS, SPC, RESERVED, NFATS & NDIRS

	putintel	#512,bs_bps(a0)
	move.w	bp_spc,d0
	move.b	d0,bs_spc(a0)
	putintel	#1,bs_res(a0)
	move.b	#2,bs_nfats(a0)
	putintel	bp_direntries,bs_ndirs(a0)

; NSECTS

	move.w	bp_tracks,d0
	mulu	bp_sides,d0
	mulu	bp_sectors,d0
	putintel	d0,bs_nsects(a0)

; Calculate and write Sectors Per Fat (SPF)
; SPF = (NSECTS * 12 / 4096 / SPC) + 1

	mulu	#12,d0
	asr.l	#8,d0
	asr.l	#4,d0
	divu	bp_spc,d0
	addq.w	#1,d0
	putintel	d0,bs_spf(a0)

; MEDIA byte

	move.b	bp_media,bs_media(a0)

	putintel	bp_sectors,bs_spt(a0)
	putintel	bp_sides,bs_nsides(a0)
	putintel	#0,bs_nhid(a0)

; Wipe the bootcode area

	lea	bs_bootcode(a0),a1
	move.w	#480-1,d0
.wipe
	clr.b	(a1)+
	dbf	d0,.wipe

; If we want an executable bootsector, then we create an Atari
; checksummed version (non-Intel words) and copy the code into
; the bootsector buffer.

	tst.l	bp_bootcode
	beq	.no_bootcode

	move.w	bp_bootsize,d7
	ble	.ERROR
	cmp.w	#480-2,d7
	bgt	.ERROR

	move.w	#bt_branch,bs_bra(a0)

	move.l	bp_bootcode,a1
	lea	bs_bootcode(a0),a2
	subq.w	#1,d7
.copy
	move.b	(a1)+,(a2)+
	dbf	d7,.copy

	move.l	a0,a1
	moveq	#0,d0
	move.w	#510/2-1,d7
.checksum
	add.w	(a1)+,d0
	dbf	d7,.checksum

	move.w	#bt_checksum,d1
	sub.w	d0,d1
	move.w	d1,bs_checksum(a0)
	bra	.done_bootcode	

; If the bootsector is not to be executable, then we create one with
; an invalid checksum and an Intel branch code at the start (to be
; PC compatible).

.no_bootcode

	putintel	#bt_intelbranch,bs_bra(a0)

	move.l	a0,a1
	moveq	#0,d0
	move.w	#510/2-1,d7
.checksum_intel
	add.w	(a1)+,d0
	dbf	d7,.checksum_intel

	move.w	#bt_checksum,d1
	sub.w	d0,d1
	addq.w	#1,d1
	move.w	d1,bs_checksum(a0)

.done_bootcode

	moveq	#1,d0
	bra.s	.DONE
.ERROR
	moveq	#0,d0
.DONE
	popall
	rts

*********************************************************************
* Write the bootsector in the buffer to disk
* Remember to set up p_drive and p_density
*********************************************************************

fdc_write_bootsector
	move.l	#bootsector_buffer,p_buffer
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#1,p_sector
	move.w	#1,p_numsectors
	move.w	#0,p_maxtrack
	move.w	#1,p_maxsector
	move.w	#1,p_maxside
	move.w	#2,p_secsize
	move.w	#rwf_write|rwf_restore,p_flags
	bsr	fdc_readwrite
	rts

*********************************************************************
* Write MSDOS fat entries (in FATs 1 and 2)
* The first 3 bytes must be $f7,$ff,$ff
* Remember to set up p_drive, p_density and p_maxsector
* Bootsector info must also be set up so we know the floppy
* geometry to find the FATs.
*********************************************************************

fdc_write_fats
	pushall

	lea	bootsector_buffer,a1
	move.l	a1,a0
	move.w	#512/4-1,d0
.wipe
	clr.l	(a0)+
	dbf	d0,.wipe

	move.l	a1,a0
	move.b	#$f7,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+

; SPF = (NSECTS * 12 / 4096 / SPC) + 1

	move.w	bp_tracks,d0
	mulu	bp_sides,d0
	mulu	bp_sectors,d0
	mulu	#12,d0
	asr.l	#8,d0
	asr.l	#4,d0
	divu	bp_spc,d0
	addq.w	#1,d0

	moveq	#2,d1
	moveq	#1,d2

.fat_loop
	move.l	a1,p_buffer
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	d1,p_sector
	move.w	#1,p_numsectors
	move.w	#1,p_maxtrack
	move.w	#1,p_maxside
	move.w	#2,p_secsize
	move.w	#rwf_write|rwf_restore,p_flags
	bsr	fdc_readwrite

	add.w	d0,d1
.chop_loop
	cmp.w	p_maxsector,d1
	ble.s	.sector_ok
	addq.w	#1,p_track
	sub.w	p_maxsector,d1
	bra.s	.chop_loop

.sector_ok
	dbf	d2,.fat_loop

	popall
	rts

	endc

fdc_writeprotect
	move.l	#.not,p_buffer
	move.w	#0,p_drive
	move.w	#0,p_density
	move.w	#0,p_track
	move.w	#0,p_side
	move.w	#2,p_sector
	move.w	#1,p_numsectors
	move.w	#79,p_maxtrack
	move.w	#9,p_maxsector
	move.w	#1,p_maxside
	move.w	#2,p_secsize
	move.w	#rwf_write|rwf_restore,p_flags
	bsr		fdc_readwrite
	moveq		#0,d0
	cmp.b		#e_writeprotect,fdc_done
	bne.s		.not
	moveq		#1,d0
.not	rts

*********************************************************************
* Seek speed/density tables & other system vars
*********************************************************************

fdc_minsector	dc.w	1
fdc_maxsector	dc.w	40
fdc_maxtrack	dc.w	82
fdc_mintrack	dc.w	0

tb_density		; converts sectors-per-track to density number
	dc.b	-1
	dcb.b	11,0
	dcb.b	11,1
	dcb.b	18,2
	even

tb_densitycode		; converts density number to hardware code
	dc.w	density_dd
	dc.w	density_hd
	dc.w	density_ed

tb_densitytrack
	dc.w	6250,6250*2,6250*4

tb_seekspeed		; converts density number to seek speed code
	dc.w	c_steprate3
	dc.w	c_steprate6
	dc.w	c_steprate6	; ED really needs 12ms

tb_sectorsize		; converts sectorsize code to actual size
	dc.w	128,256,512,1024
	
*********************************************************************
* Various system variables
*********************************************************************

	ifd	TESTCODE
obfile
	incbin	"crap.prg"
outbuffer	= obfile+28
	endc

	section	bss

old_fdc_vec		ds.l	1
old_timerd_vec		ds.l	1
mfp_was_enabled		ds.b	1
mfp_was_masked		ds.b	1
timer_was_enabled	ds.b	1
timer_was_masked	ds.b	1
fdc_done		ds.b	1
			even
fdc_write		ds.w	1
fdc_errors		ds.w	1
fdc_timerdone		ds.w	1

track_buffer		ds.b	6250*MAX_DENSITY

t_id_list		ds.l	50

	ifd	TESTCODE
inbuffer		ds.b	512*50
	endc

	section	text
	