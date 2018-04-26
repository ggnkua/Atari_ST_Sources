	;	TEXT	$000B62 bytes, segment starts at L0000+$0
	;	DATA	$000000 bytes
	;	BSS	$001000 bytes, segment starts at U0B62
	;	SYMBOLS	$000000 bytes
	;	FLAGS	0007 0000

	COMMENT HEAD=7

	.TEXT

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Header, probably needs to be this exact format.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Text string can be any length, terminated a 0 byte and further
	; 0 byte if necessary to pad out to an even length.
	; This is actually MODEM.DRV for the C-Lab Export, despite the wrong name.
	jmp	start
	dc.b	'MROS CLAB MIDIEX V 1.0 0592 (c)1993 SSSSSSSSS',0
driver_version	equ	$0100
prog_size	dc.l	0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Program start.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
	movea.l	a7,a5
	movea.l	$04(a5),a5		; Get basepage and add up size.
	move.l	$0C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$100,d0
	move.l	d0,prog_size.l		; Store program size.

	; Main sets up everything.
	bsr  	main

	; Terminate and stay resident.
	; d0 is not used for the return value.
	move.w	#0,-(a7)
	move.l	prog_size.l,d0
	move.l	d0,-(a7)
	move.w	#$0031,-(a7)	; Ptermres
	trap	#1		; Gemdos



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
	bsr  	init_func_1
	bsr  	init_func_2
	bsr  	init_func_3

	; Pass dev_struct into MROS IOM. Opcode $14 (publish driver).
	pea	dev_struct(pc)
	move.w	#$14,-(a7)
	trap	#10
	addq.l	#6,a7

	; Return with pointer to vars in a5. Unused.
	lea 	vars(pc),a5
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function sets up dev_struct.
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_2:
	lea 	dev_struct(pc),a0

	; Clear dev_struct, up to and including devvers but not devname (which is populated in text segment).
	movea.l	a0,a1
	moveq	#(dev_struct_size-8)-1,d0
.loop:
	clr.b	(a1)+
	dbf	d0,.loop

	move.w	#driver_version,devvers(a0)	; Set device version.

	lea 	descriptor_buf1(pc),a1
	move.l	a1,(a0)				; Store pointer to descriptor_buf in dev_descriptor_buf of dev_struct.
	st	dev_ff(a0)			; Set dev_ff upper byte.
	move.w	#num_outs,devmouts(a0)		; Set number of MIDI outs to 3.
	lea 	driver_start(pc),a1		; Set dev_driver_start and dev_driver_stop to point to their corresponding functions.
	move.l	a1,dev_driver_start(a0)
	lea 	driver_stop(pc),a1
	move.l	a1,dev_driver_stop(a0)

	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function fetches certain variables from MROS.
	; Called by main and driver_start.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_1:
	lea 	vars(pc),a5
	movea.l	a5,a0

	; Clear vars.
	move.w	#vars_size-1,d0
.loop:
	clr.b	(a0)+
	dbf	d0,.loop

	; Call MROS MEM with opcode 4 (get MROS info).
	; It's possible it could be using the value of a0,
	; which is now pointing to BSS.
	move.w	#4,-(a7)
	trap	#8
	lea 	2(a7),a7

	; MROS returns a data structure in d0 = a0. Copy certain values to private variables.
	movea.l	d0,a0
	lea 	vars(pc),a5
	move.l	mros_mem4_2(a0),mros_mem_2(a5)
	move.l	mros_mem4_1(a0),mros_mem_1(a5)
	move.l	mros_mem4_get_byte(a0),mros_get_byte(a5)
	move.l	mros_mem4_struct(a0),mros_mem_struct(a5)

	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function fills in the port descriptors.
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_3:
	movem.l	a2/a5,-(a7)
	lea 	vars(pc),a5
	lea 	descriptor_buf1(pc),a1

	; Clear descriptor_buf1, descriptor_buf2 and descriptor_buf3.
	move.w	#((descriptor_size*num_outs)/4)-1,d0
.loop:	clr.l	(a1)+
	dbf	d0,.loop

	lea 	descriptor_buf1(pc),a0
	lea 	midibuf(pc),a1
	lea 	driver_write(pc),a2

	moveq.l	#num_outs-1,d0
.loop2:
	move.l	a1,start_of_buf(a0)
	lea 	midibuf_size(a1),a1
	move.l	a1,end_of_buf(a0)
	move.l	a2,write_byte_ptr(a0)
	lea 	descriptor_size(a0),a0
	dbf	d0,.loop2

	movem.l	(a7)+,a2/a5
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually starts the driver running.
	; d0.l return code: always 0.
	; Called by MROS.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start:
	move.l	a5,-(a7)
	lea 	vars(pc),a5

	bsr.w  	init_func_1

	; Configure UART through TOS.
	move.w	#-1,-(a7)	; scr
	move.w	#-1,-(a7)	; tsr
	move.w	#-1,-(a7)	; rsr
	move.w	#$0008,-(a7)	; ucr, asynchronous, divide by one, 8 bits, no parity, 1 stop bit.
	move.w	#$0000,-(a7)	; ctr, no flow control.
	move.w	#$0005,-(a7)	; baud = 1920 (at divide by one, this is 30720 baud - within 1.7% of 31250 baud).
	move.w	#15,-(a7)	; Rsconf
	trap	#14		; Xbios
	lea 	14(a7),a7

	; Save old ISR and set ISR.
	lea 	send_error_isr.l,a0
	move.l	int_vec_mfp0.w,old_isr_save.l
	move.l	a0,int_vec_mfp0.w  

	move.b	interrupt_enable_reg.w,d0
	bclr.l	#$02,d0				; Disable send buffer empty interrupt.
	bset.l	#$01,d0				; Enable send error interrupt.
	move.b	d0,interrupt_enable_reg.w  
	move.b	#$FD,interrupt_in_service_reg.w	; Clear send error interrupt.

	lea 	ym_base.w,a0
	move.b	#14,(a0)
	move.b	(a0),d1
	bclr.l	#$03,d1				; Set both RTS and DTR pins positive.
	bclr.l	#$04,d1
	move.b	d1,2(a0)

	lea 	dev_struct(pc),a0
	st.b	devact(a0)			; Set devact in dev_struct indicating device is active.
	moveq.l	#0,d0
	movea.l	(a7)+,a5
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Stops the driver. Called by MROS.
	; Always returns 0 in d0.l.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_stop:
	move.l	a5,-(a7)
	lea 	vars(pc),a5

	move.b	interrupt_enable_reg.w,d0
	bclr.l	#2,d0				; Send buffer empty interrupt off.
	bclr.l	#1,d0				; Send error interrupt off.
	move.b	d0,interrupt_enable_reg.w

	move.l	old_isr_save.l,int_vec_mfp10.w	; Restore original ISR.

	lea 	dev_struct(pc),a0		; Mark device as inactive.
	clr.w	devact(a0)

	movea.l	(a7)+,a5
	moveq.l	#0,d0
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by MROS to write data to the driver.
	; a0 points to a structure containing the port number.
	; The data is queued up in MROS and is actually read during
	; the ISR by calling mros_get_byte. The ISR main routine is triggered
	; by this function.
	; This returns with interrupts disabled.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_write:
	move.w	driver_write_portnum(a0),d0

	and.w	#num_outs_mask,d0		; Mask port number 0-3.

	lea 	vars(pc),a1
	move.b	(a1),d1				; port_bitfield
	bset.b	d0,(a1)				; Set corresponding bit in port_bitfield.

	tst.b	d1				; If no other writes are waiting, trigger the write routine.
	beq.b	write_byte_hardware

	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ISR.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
send_error_isr:
	move.w	d0,-(a7)
	ori.w	#$0700,sr			; Interrupts off.

	move.b	#$FD,interrupt_in_service_reg.w	; Clear both send error and buffer empty interrupts.

	jsr	write_byte_hardware

	move.w	(a7)+,d0
	rte


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually write the byte to the hardware.
	; Called by the ISR and the driver_write routine.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
write_byte_hardware:
	ori.w	#$0700,sr			; Interrupts off.

	move.l	a5,-(a7)
	lea 	vars(pc),a5

	; If no bits are set in port_bitfield, return from ISR and clear interrupt.
	tst.b	(a5)				; port_bitfield.
	beq.w  	.finish

	movem.l	d0-d2/a0-a2,-(a7)

	movea.l	mros_get_byte(a5),a2

	btst.b	#0,(a5)				; Data waiting on port 1?
	beq.b	.port2

	; Read data from port 1 by calling mros_get_byte.
	lea 	descriptor_buf1(pc),a0		; Pass descriptor in a0.
	jsr	(a2)				; mros_get_byte. Returns data in d0.
	tst.w	d1				; If it returns zero in d1.w, bitfield clearing is skipped. It might be set to zero to indicate more data is waiting?
	beq.b	.skip
	bclr.b	#0,(a5)				; Clear port_bitfield for that port.
.skip:
	lea 	ym_base.w,a0			; Set RTS positive and DTR negative.
	move.b	#14,(a0)
	move.b	(a0),d1
	bclr.l	#3,d1
	bset.l	#4,d1
	move.b	d1,2(a0)
	move.b	d0,usart_data.w			; Write data to USART.
	bra.b	.finish2

.port2:
	btst.b	#1,(a5)				; Data waiting on port 2?
	beq.b	.port3

	; Read data from port 2 by calling mros_get_byte.
	lea 	descriptor_buf2(pc),a0		; Pass descriptor in a0.
	jsr	(a2)				; mros_get_byte. Returns data in d0.
	tst.w	d1				; If it returns zero in d1.w, bitfield clearing is skipped. It might be set to zero to indicate more data is waiting?
	beq.b	.skip2
	bclr.b	#1,(a5)				; Clear port_bitfield for that port.
.skip2:
	lea 	ym_base.w,a0			; Set RTS negative and DTR positive.
	move.b	#14,(a0)
	move.b	(a0),d1
	bset.l	#3,d1
	bclr.l	#4,d1
	move.b	d1,2(a0)
	move.b	d0,usart_data			; Write data to USART.
	bra.b	.finish2

.port3:
	btst.b	#2,(a5)				; Data waiting on port 3?
	beq.b	.finish2

	; Read data from port 2 by calling mros_get_byte.
	lea 	descriptor_buf3(pc),a0		; Pass descriptor in a0.
	jsr	(a2)				; mros_get_byte. Returns data in d0.
	tst.w	d1				; If it returns zero in d1.w, bitfield clearing is skipped. It might be set to zero to indicate more data is waiting?
	beq.b	.skip3
	bclr	#2,(a5)				; Clear port_bitfield for that port.
.skip3:
	lea 	ym_base.w,a0			; Set RTS and DTR positive.
	move.b	#14,(a0)
	move.b	(a0),d1
	bclr.l	#3,d1
	bclr.l	#4,d1
	move.b	d1,2(a0)
	move.b	d0,usart_data.w			; Write data to USART.


.finish2:
	movem.l	(a7)+,d0-d2/a0-a2
.finish:
	movea.l	(a7)+,a5
	move.b	transmit_status_reg.w,d0	; Read transmit status register to clear send error interrupt.
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


num_outs	equ	3
num_outs_mask	equ	3


old_isr_save:
	dc.l	0

	; Contains 3 buffers of 512 bytes - one for each port, passed into MROS.
	; Most likely for buffering output data.
midibuf_size	equ	512		; Size of each port buffer in bytes.
midibuf:
	ds.b	(num_outs*midibuf_size)

	; For port descriptor entry in descriptor_buf:
	; A pointer to port descriptor is stored in dev_struct and passed into MROS.
	; The port descriptor is also passed into mros_get_byte in the ISR.
start_of_buf	equ	$24	; Longword, pointer to start of data buffer.
end_of_buf	equ	$28	; Longword, pointer to end of data buffer.
write_byte_ptr	equ	$90	; Longword, pointer to write byte function.


descriptor_size	equ	192	; Size of a descriptor entry in bytes.

descriptor_buf1:		; All three buffers must be contiguous.
	ds.b	descriptor_size
descriptor_buf2:
	ds.b	descriptor_size
descriptor_buf3:
	ds.b	descriptor_size


dev_struct_size	equ	64	; Size of dev_struct in bytes.

	; Offsets in dev_struct:
dev_descriptor_buf	equ	$00	; Points to array of descriptor_buf structures, one for each output.
dev_b			equ	$04	; Word
dev_ff			equ	$06	; Word, Set to $ff00 during initialisation.
dev_d			equ	$08	; Word
dev_e			equ	$0a	; Word
dev_f_ptr		equ	$0c
dev_g_ptr		equ	$10
dev_h_ptr		equ	$14
dev_i_ptr		equ	$18
devact			equ	$1c	; Word, not equal to zero if device is active.
devnum			equ	$1e	; Word, device number.
devmins			equ	$20	; Word, number of MIDI ins (0=none).
devmouts		equ	$22	; Word, number of MIDI outs, set to 8 during initialisation.
dev_driver_start	equ	$24	; Set to point to driver_start during initialisation.
dev_driver_stop		equ	$28
dev_l_ptr		equ	$2c
dev_m			equ	$30	; Word
dev_n			equ	$32	; Word
dev_o			equ	$34	; Word
devvers			equ	$36	; Word, version number.
devname			equ	$38	; Device name, ASCII, 8 bytes including terminator.

dev_struct:
	dc.l	0	; $00: *a
	dc.w	0	; $04: b
	dc.w	0	; $06: c
	dc.w	0	; $08: d
	dc.w	0	; $0a: e
	dc.l	0	; $0c: *f
	dc.l	0	; $10: *g
	dc.l	0	; $14: *h
	dc.l	0	; $18: *i
	dc.w	0	; $1c: devact
	dc.w	0	; $1e: devnum
	dc.w	0	; $20: devmins
	dc.w	0	; $22: devmouts
	dc.l	0	; $24: *j
	dc.l	0	; $28: *k
	dc.l	0	; $2c: *l
	dc.w	0	; $30: m
	dc.w	0	; $32: n
	dc.w	0	; $34: o
	dc.w	0	; $36: devvers
	dc.b	'MODEM',0,0,0	; $38: devname (8 bytes)


vars_size	equ	32	; Size of vars structure in bytes.

	; Offsets in vars:
port_bitfield	equ	$00	; Word, bitfield: one bit for each port, set by driver_write. High byte only.
mros_mem_1	equ	$0c	; Longword, loaded from value returned during MROS MEM init.
mros_mem_2	equ	$10	; Longword, loaded from value returned during MROS MEM init.
mros_get_byte	equ	$18	; Longword, points to an MROS routine called in the ISR, loaded from value returned during MROS MEM init.
mros_mem_struct	equ	$1c	; Longword, points to a data structure returned by MROS MEM during init.


vars:
	dc.w	0	; port_bitfield

	dc.w	0	; offset $2
	dc.l	0	; offset $4
	dc.l	0	; offset $8

	dc.l	0	; mros_mem_1
	dc.l	0	; mros_mem_2

	dc.l	0	; offset $14

	dc.l	0	; mros_get_byte
	dc.l	0	; mros_mem_struct



	.BSS

U0B62:					; BSS is possibly unused.
	ds.b	$FFE


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; MROS structures.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; This structure is returned when calling MROS MEM with opcode 4
	; during init_func_1. The values are copied to private variables and the
	; structure doesn't appear to be used anywhere else.
mros_mem4_2		equ	$4	; Longword, copied to mros_mem_2.
mros_mem4_1		equ	$8	; Longword, copied to mros_mem_1.
mros_mem4_get_byte	equ	$10	; Longword, copied to mros_get_byte.
mros_mem4_struct	equ	$20	; Longword, copied to mros_mem_struct.

	; Struct passed into driver_write:
driver_write_portnum	equ	$3A	; Word, port number 0-2.


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ST register definitions.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_vec_mfp10			equ	$124
ym_base				equ	$ffff8800
interrupt_enable_reg		equ	$fffffa07
interrupt_in_service_reg	equ	$fffffa0f
transmit_status_reg		equ	$fffffa2d
usart_data			equ	$fffffa2f