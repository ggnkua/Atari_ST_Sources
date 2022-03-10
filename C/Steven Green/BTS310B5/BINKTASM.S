
		xdef	port_ptr,device_addr
		xdef	real_flush,init_driver,set_driver,set_new_port
		xdef	get_dcd,get_cts
		xdef	SENDBYTE,SENDCHARS,MODEM_IN,OUT_EMPTY
		xdef	dtr_on,dtr_off,CHAR_AVAIL,OUT_FULL,PEEKBYTE

		IMPORT	time_release,HardCTS

device_addr:
		dc.l	0
version:
		dc.w	0

init_driver:
		move.l	device_addr(pc),a0	* Beim ersten Start: Tabelle ermitteln
		jsr			(a0)
		lea			device_addr(pc),a0
		move.l	d0,(a0)
set_driver:
		move.l	device_addr(pc),a0	* Tabelle nach a0

		move.w	80(a0),version
		
		move.l	#time_release,86(a0)
		move.w	port_ptr,d0
		addq.w	#1,d0
		move.w	d0,82(a0)
		move.w	HardCTS,84(a0)
		move.w	version(pc),d0
		rts

; SUPER
get_dcd:
		move.l	device_addr(pc),a0
		jmp			(a0)

; SUPER
get_cts:
		move.l	device_addr(pc),a0
		addq.w	#4,a0
		jmp			(a0)

SENDBYTE:
		move.l	device_addr(pc),a0
		addq.w	#8,a0
		jmp			(a0)

SENDCHARS:
		move.l	device_addr(pc),-(sp)
		add.l		#12,(sp)
		rts

set_new_port:
		move.l	device_addr(pc),a0
		lea			16(a0),a0
		jmp			(a0)

MODEM_IN:
		move.l	device_addr(pc),a0
		lea			20(a0),a0
		jmp			(a0)

CHAR_AVAIL:
		move.l	device_addr(pc),a0
		lea			24(a0),a0
		jmp			(a0)

OUT_FULL:
		move.l	device_addr(pc),a0
		lea			28(a0),a0
		jmp			(a0)

PEEKBYTE:
		move.l	device_addr(pc),a0
		lea			32(a0),a0
		jmp			(a0)

; SUPER
dtr_on:
		move.l	device_addr(pc),a0
		lea			36(a0),a0
		jmp			(a0)

; SUPER
dtr_off:
		move.l	device_addr(pc),a0
		lea			40(a0),a0
		jmp			(a0)

OUT_EMPTY:
		move.l	device_addr(pc),a0
		lea			44(a0),a0
		jmp			(a0)

real_flush:
		moveq #0,d0
		rts

		end
