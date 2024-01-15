; Joypad device driver for FreeMiNT
; (C) 2005 Peter Persson
;
; (very) inspired by Draco's xdd-skeleton example driver.
;
;  - if 16 bytes are read, FreeBSD compatible joystick data if returned
;  - if 12 bytes are read, Linux (old implementation) compatible joystick data is returned
;
; Changelog:
;  - v0.0.1 (2005-12-16)	First version
;


JOY_SETTIMEOUT    equ	$6A41	; set timeout
JOY_GETTIMEOUT    equ	$6A42	; get timeout
JOY_SET_X_OFFSET  equ	$6A43	; set offset on X-axis
JOY_SET_Y_OFFSET  equ	$6A44	; set offset on Y-axis
JOY_GET_X_OFFSET  equ	$6A45	; get offset on X-axis
JOY_GET_Y_OFFSET  equ	$6A46	; get offset on Y-axis

;

BUF_SIZE	equ	20	; size of joypad buffer

;

	include	gemdos.i
	include	xbios.i
	include	errno.i
	include	file.i
	include	kernel.i
	include	ssystem.i


	SECTION	TEXT

; --------------------------------------
;            Initalisation
; --------------------------------------

init:
		RSSET	4
.kerinfoptr	rs.l	1

	; init pointer to kerinfo

	lea	KERNEL,a0
	move.l	.kerinfoptr(sp),(a0)


	; init device descriptor for joypad #0

	lea	jp0_descriptor,a0
	lea	jp0_devtab,a1
	move.l	a1,dev_descr.driver(a0)
	move.l	#S_IFCHR|S_IWUSR|S_IWGRP|S_IWOTH,dev_descr.fmode(a0)
	clr.w	dev_descr.dinfo(a0)

	; init device  descriptor for joypad #1

	lea	jp1_descriptor,a0
	lea	jp1_devtab,a1
	move.l	a1,dev_descr.driver(a0)
	move.l	#S_IFCHR|S_IWUSR|S_IWGRP|S_IWOTH,dev_descr.fmode(a0)
	clr.w	dev_descr.dinfo(a0)

	; init device descriptor for analog joystick #0

	lea	ja0_descriptor,a0
	lea	ja0_devtab,a1
	move.l	a1,dev_descr.driver(a0)
	move.l	#S_IFCHR|S_IWUSR|S_IWGRP|S_IWOTH,dev_descr.fmode(a0)
	clr.w	dev_descr.dinfo(a0)

	; init device  descriptor for analog joystick #1

	lea	ja1_descriptor,a0
	lea	ja1_devtab,a1
	move.l	a1,dev_descr.driver(a0)
	move.l	#S_IFCHR|S_IWUSR|S_IWGRP|S_IWOTH,dev_descr.fmode(a0)
	clr.w	dev_descr.dinfo(a0)

	; mount /dev/joypad0

	pea	jp0_descriptor	; mount the device on /dev
	pea	jp0_name
	move.w	#DEV_INSTALL,-(sp)
	kdos	D_cntl
	lea	$0a(sp),sp
	tst.l	d0
	bmi.s	.error

	; mount /dev/joypad1

	pea	jp1_descriptor	; mount the device on /dev
	pea	jp1_name
	move.w	#DEV_INSTALL,-(sp)
	kdos	D_cntl
	lea	$0a(sp),sp
	tst.l	d0
	bmi.s	.error

	; mount /dev/joya0

	pea	ja0_descriptor	; mount the device on /dev
	pea	ja0_name
	move.w	#DEV_INSTALL,-(sp)
	kdos	D_cntl
	lea	$0a(sp),sp
	tst.l	d0
	bmi.s	.error

	; mount /dev/joya1

	pea	ja1_descriptor	; mount the device on /dev
	pea	ja1_name
	move.w	#DEV_INSTALL,-(sp)
	kdos	D_cntl
	lea	$0a(sp),sp
	tst.l	d0
	bmi.s	.error


	; done

	moveq	#$01,d0		; success
	rts

.error:
	moveq	#$00,d0		; failure
	rts



; --------------------------------------
;              Open
; --------------------------------------


jp0_open:
	move.l	#jp0_busy,a0
	bra	do_open

jp1_open:
	move.l	#jp1_busy,a0
	bra	do_open

ja0_open:
	move.l	#ja0_busy,a0
	bra	do_open

ja1_open:
	move.l	#ja1_busy,a0
;	bra	do_open



do_open:
	; check if busy

	tst.w	(a0)
	beq.s	.ok

	moveq	#EBUSY,d0	; return busy
	rts

	; open

.ok:	move.w	#1,(a0)		; mark as busy
	moveq	#E_OK,d0	; return ok
	rts



; --------------------------------------
;              Close
; --------------------------------------


jp0_close:
	move.l	#jp0_busy,a0
	bra	do_close

jp1_close:
	move.l	#jp1_busy,a0
	bra	do_close

ja0_close:
	move.l	#ja0_busy,a0
	bra	do_close

ja1_close:
	move.l	#ja1_busy,a0
;	bra	do_close


do_close:

	; check if already closed

	tst.w	(a0)
	bne	.ok

	moveq	#EERROR,d0	; return generic error
	rts

	; close

.ok:	move.w	#0,(a0)		; mark as not-busy
	moveq	#E_OK,d0	; return ok
	rts



; --------------------------------------
;              Fread
; --------------------------------------


; prepare joypad 0 for reading

jp0_read:
	bsr port0_get_buttons
	move.w	d0,jp0_butmask+2

	bsr port0_get_special
	move.w	d0,jp0_butmask

	; Process & write joypad directions

	and.w	#$f000,d0		;
	rol.w	#7,d0		; adapt for lut

	move.l	#jp_dir_lut,a0
	move.l	(a0,d0.w),jp0_x	; process x
	move.l	4(a0,d0.w),jp0_y	; process y

	move.l #jp0_data,a1	; source buffer address
	bra do_read



; prepare joypad 1 for reading

jp1_read:
	bsr port1_get_buttons
	move.w	d0,jp1_butmask+2

	bsr port1_get_special
	move.w	d0,jp1_butmask

	; Process & write joypad directions

	and.w	#$f000,d0		;
	rol.w	#7,d0		; adapt for lut

	move.l	#jp_dir_lut,a0
	move.l	(a0,d0.w),jp1_x	; process x
	move.l	4(a0,d0.w),jp1_y	; process y

	move.l #jp1_data,a1	; source buffer address
	bra do_read



; prepare analog joystick 0 for reading

ja0_read:
	bsr port0_get_buttons
	move.w	d0,ja0_butmask+2

	bsr port0_get_special
	move.w	d0,ja0_butmask

	bsr port0_get_analog_x
	move.b	d0,ja0_x+3

	bsr port0_get_analog_y
	move.b	d0,ja0_x+3

	move.l	#ja0_data,a1 ;
	bra	do_read



; prepare analog joystick 1 for reading

ja1_read:
	bsr port1_get_buttons
	move.w	d0,ja1_butmask+2

	bsr port1_get_special
	move.w	d0,ja1_butmask

	bsr port1_get_analog_x
	move.b	d0,ja1_x+3

	bsr port1_get_analog_y
	move.b	d0,ja1_x+3

	move.l	#ja1_data,a1;
;	bra	do_read



; return data from the buffer pointed to by A1

do_read:	RSSET	4
.fileptr	rs.l	1
.buf		rs.l	1
.count		rs.l	1

	move.l	.buf(sp),a0	; destination address for data
	move.l	.count(sp),d0	; number of bytes to read

	; if 12 bytes are requested, return linux style data

	cmp.l	#12,d0
	beq	.linux

	; if 16 bytes are requested, return linux style data

	cmp.l	#16,d0
	beq	.bsd

	; for other sizes, don't do anything
	; (stupid really, I should perhaps do somethingh here)
	moveq	#0,d0	; return 0 bytes

	rts


.linux:	; return linux (old implementation) compatible data
	move.l	8(a1),(a0)+	; buttons
	move.l	0(a1),(a0)+	; x
	move.l	4(a1),(a0)	; y
	; at this stage, d0=12
	rts

.bsd:	; return freebsd compatible data
	move.l	0(a1),d1		; x
	add.l	12(a1),d1		; add x offset
	move.l	d1,(a0)+		;
	
	move.l	4(a1),d1		; y
	add.l	16(a1),d1		; add y offset
	move.l	d1,(a0)+		;

	btst.b	#0,11(a1)		;
	sne	3(a0)		; b0
	btst.b	#1,11(a1)		;
	sne	7(a0)		; b1
	
	and.l	#1,(a0)+		; b0
	and.l	#1,(a0)		; b1

	; at this stage, d0=16
	rts

; --------------------------------------
;              Fwrite
; --------------------------------------

write:	move.l #0,d0		;
	rts


; --------------------------------------
;              Ioctl
; --------------------------------------

jp0_ioctl:
	move.l	#jp0_data,a1
	bra do_ioctl
jp1_ioctl:
	move.l	#jp1_data,a1
	bra do_ioctl
ja0_ioctl:
	move.l	#ja0_data,a1
	bra do_ioctl
ja1_ioctl:
	move.l	#ja1_data,a1
;	bra do_ioctl


do_ioctl:
		RSSET	4
.fileptr	rs.l	1
.cmd		rs.w	1
.arg		rs.l	1

	move.w	.cmd(sp),d0	; get cmd
	move.l	.arg(sp),a0	; get argument

	; check commands

	cmp.w	#FIONREAD,d0
	beq.s	.fionread
	cmp.w	#FIONWRITE,d0
	beq.s	.fionwrite
	cmp.w	#FIOEXCEPT,d0
	beq.s	.fioexcept

	cmp.w	#JOY_SETTIMEOUT,d0
	beq.s	.set_timeout
	cmp.w	#JOY_GETTIMEOUT,d0
	beq.s	.get_timeout
	cmp.w	#JOY_SET_X_OFFSET,d0
	beq.s	.set_x
	cmp.w	#JOY_SET_Y_OFFSET,d0
	beq.s	.set_y
	cmp.w	#JOY_GET_X_OFFSET,d0
	beq.s	.get_x
	cmp.w	#JOY_GET_Y_OFFSET,d0
	beq.s	.get_y

	; unsupported command

	moveq	#EINVAL,d0
	rts

.fionread:
	move.l	#(BUF_SIZE),(a0)	; <BUF_SIZE> no. of bytes can be read
	moveq	#E_OK,d0		; return ok
	rts

.fionwrite:
	move.l	#0,(a0)		; 0 bytes can be written
	moveq	#E_OK,d0		; return ok
	rts

.fioexcept:
	move.l	#0,(a0)		; no exceptional conditions
	moveq	#E_OK,d0		; return ok
	rts

.set_timeout:
	move.l	(a0),20(a1)	; timeout
	moveq	#E_OK,d0
	rts
	
.get_timeout:
	move.l	20(a1),(a0)	; timeout
	moveq	#E_OK,d0
	rts
.set_x:
	move.l	(a0),12(a1)	; x-corr
	moveq	#E_OK,d0
	rts

.set_y:
	move.l	(a0),16(a1)	; y-corr
	moveq	#E_OK,d0
	rts

.get_x:
	move.l	12(a1),(a0)	; x-corr
	moveq	#E_OK,d0
	rts

.get_y:
	move.l	16(a1),(a0)	; y-corr
	moveq	#E_OK,d0
	rts
	


; --------------------------------------
;              Lseek
; --------------------------------------

lseek:	moveq	#ESPIPE,d0
	rts



; --------------------------------------
;              Datime
; --------------------------------------

datime:
		RSSET	4
.fileptr	rs.l	1
.timeptr	rs.l	1
.wrflag		rs.w	1


	tst.w	.wrflag(sp)	;
	bne.s	.set		;

	; get time/date

.get:	move.l	.timeptr(sp),a0 ;
	move.l	#0,(a0)		; return dummy date/time (0)
	moveq	#E_OK,d0	; return ok
	rts

	; set time/date

.set:	moveq	#EINVAL,d0	; return error
	rts



; --------------------------------------
;              Select
; --------------------------------------


select:	moveq	#1,d0		; always ready for I/O
	rts



; --------------------------------------
;              Unselect
; --------------------------------------


unselect:
	rts			; do nothing




; --------------------------------------
;         Hardware access
; --------------------------------------


port0_get_analog_x:
	move.b	$ffff9211,d0
	rts

port0_get_analog_y:
	move.b	$ffff9213,d0
	rts

port1_get_analog_x:
	move.b	$ffff9215,d0
	rts

port1_get_analog_y:
	move.b	$ffff9217,d0
	rts



port0_get_special:

	move.w	#$fff7,$ffff9202
	move.w	$ffff9202,d0
	ror.w	#8,d0
	or.w	#$fff0,d0

	move.w	#$fffb,$ffff9202
	move.w	$ffff9202,d1
	ror.w	#4,d1
	or.w	#$ff0f,d1
	and.w	d1,d0

	move.w	#$fffd,$ffff9202
	move.w	$ffff9202,d1
	or.w	#$f0ff,d1
	and.w	d1,d0

	move.w	#$fffe,$ffff9202
	move.w	$ffff9202,d1
	rol.w	#4,d1
	or.w	#$0fff,d1
	and.w	d1,d0

	eor.w	#$ffff,d0

	rts


port1_get_special:

	move.w	#$ff7f,$ffff9202
	move.w	$ffff9202,d0
	ror.w	#4,d0
	ror.w	#8,d0
	or.w	#$fff0,d0

	move.w	#$ffbf,$ffff9202
	move.w	$ffff9202,d1
	ror.w	#8,d1
	or.w	#$ff0f,d1
	and.w	d1,d0

	move.w	#$ffdf,$ffff9202
	move.w	$ffff9202,d1
	ror.w	#4,d1
	or.w	#$f0ff,d1
	and.w	d1,d0

	move.w	#$ffef,$ffff9202
	move.w	$ffff9202,d1
	or.w	#$0fff,d1
	and.w	d1,d0

	eor.w	#$ffff,d0

	rts
	
	
port0_get_buttons:

	move.w	#$fff7,$ffff9202	;
	move.w	$ffff9200,d0	;
	or.w	#$fffd,d0
	rol.w	#5,d0		; Option = b6

	move.w	#$fffb,$ffff9202	;
	move.w	$ffff9200,d1	;
	or.w	#$fffd,d1
	rol.w	#1,d1		; Fire C = b2
	and.w	d1,d0		; Option + C

	move.w	#$fffd,$ffff9202	;
	move.w	$ffff9200,d1	; Fire B = b1
	or.w	#$fffd,d1
	and.w	d1,d0		; Option + C + B

	move.w	#$fffe,$ffff9202	; 
	move.w	$ffff9200,d1	; 
	or.w	#$fffc,d1
	ror.b	#1,d1		; Fire A = b0, Pause = b8
	and.w	d1,d0		; Option + C + B + A + Pause

	eor.w	#$ffff,d0

	rts


port1_get_buttons:

	move.w	#$ff7f,$ffff9202	;
	move.w	$ffff9200,d0	;
	or.w	#$fff7,d0
	rol.w	#3,d0		; Option = b6

	move.w	#$ffbf,$ffff9202	;
	move.w	$ffff9200,d1	;
	or.w	#$fff7,d1
	ror.w	#1,d1		; Fire C = b2
	and.w	d1,d0		; Option + C

	move.w	#$ffdf,$ffff9202	;
	move.w	$ffff9200,d1	; 
	or.w	#$fff7,d1
	ror.w	#2,d1		; Fire B = b1
	and.w	d1,d0		; Option + C + B

	move.w	#$ffef,$ffff9202	; 
	move.w	$ffff9200,d1	;
	or.w	#$fff3,d1
	ror.b	#3,d1		; Fire A = b0, Pause = b8
	and.w	d1,d0		; Option + C + B + A + Pause

	eor.w	#$ffff,d0

	rts

; --------------------------------------
;              Data
; --------------------------------------

	SECTION	DATA

jp0_devtab:	; function table for joypad0
	dc.l	jp0_open,write,jp0_read,lseek
	dc.l	jp0_ioctl,datime,jp0_close
	dc.l	select,unselect

jp1_devtab:	; function table for joypad1
	dc.l	jp1_open,write,jp1_read,lseek
	dc.l	jp1_ioctl,datime,jp1_close
	dc.l	select,unselect

ja0_devtab:	; function table for analog joystick 0
	dc.l	ja0_open,write,ja0_read,lseek
	dc.l	ja0_ioctl,datime,ja0_close
	dc.l	select,unselect

ja1_devtab:	; function table for analog joystick 1
	dc.l	ja1_open,write,ja1_read,lseek
	dc.l	ja1_ioctl,datime,ja1_close
	dc.l	select,unselect

	; device names

jp0_name:	dc.b	"u:\dev\joypad0",$00	; filename for joypad 0
jp1_name:	dc.b	"u:\dev\joypad1",$00	; filename for joypad 1
ja0_name:	dc.b	"u:\dev\joya0",$00		; filename for analog joystick 0
ja1_name:	dc.b	"u:\dev\joya1",$00		; filename for analog joystick 1

	even

; look-up table, used to convert joypad directions
; to suitable values
	
jp_dir_lut:
	dc.l 128, 128	
	dc.l 128, 0	
	dc.l 128, 255	
	dc.l 128, 128	
	dc.l 0, 128	
	dc.l 0, 0		
	dc.l 0, 255	
	dc.l 0, 128	
	dc.l 255, 128	
	dc.l 255, 0	
	dc.l 255, 255	
	dc.l 255, 128	
	dc.l 128, 128	
	dc.l 128, 0	
	dc.l 128, 255	
	dc.l 128, 128	


; busy flags (not in BSS since they must be set to 0 during startup anyway..
;

jp0_busy:		dc.w 0
jp1_busy:		dc.w 0
ja0_busy:		dc.w 0
ja1_busy:		dc.w 0

; Joypad 0 buffer
;

jp0_data:
jp0_x:		dc.l 0
jp0_y:		dc.l 0
jp0_butmask:	dc.l 0
jp0_offset_x:	dc.l -10
jp0_offset_y:	dc.l 10
jp0_timelimit:	dc.l 0

; Joypad 1 buffer
;

jp1_data:
jp1_x:		dc.l 0
jp1_y:		dc.l 0
jp1_butmask:	dc.l 0
jp1_offset_x:	dc.l 0
jp1_offset_y:	dc.l 0
jp1_timelimit:	dc.l 0


; Analog joystick 0 buffer
;

ja0_data:
ja0_x:		dc.l 0
ja0_y:		dc.l 0
ja0_butmask:	dc.l 0
ja0_offset_x:	dc.l 0
ja0_offset_y:	dc.l 0
ja0_timelimit:	dc.l 0

; Analog joystick 1 buffer
;

ja1_data:
ja1_x:		dc.l 0
ja1_y:		dc.l 0
ja1_butmask:	dc.l 0
ja1_offset_x:	dc.l 0
ja1_offset_y:	dc.l 0
ja1_timelimit:	dc.l 0



; --------------------------------------
;              BSS
; --------------------------------------

		SECTION	BSS

KERNEL:	ds.l	1		; pointer to kerinfo
jp0_descriptor:	ds.b	DEV_DESCR	; device descriptor structures
jp1_descriptor:	ds.b	DEV_DESCR	;
ja0_descriptor:	ds.b	DEV_DESCR	;
ja1_descriptor:	ds.b	DEV_DESCR	;


	END
