	;	TEXT	$000564 bytes, segment starts at L0000+$0
	;	DATA	$000B48 bytes, segment starts at T0564
	;	BSS	$000000 bytes
	;	SYMBOLS	$000000 bytes
	;	FLAGS	0001 0000

	COMMENT HEAD=1

	.TEXT

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Header, probably needs to be this exact format.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Text string can be any length, terminated a 0 byte and further
	; 0 byte if necessary to pad out to an even length.
	jmp	start.l
	dc.b	'MROS MO4 Driver V 1.0 0395 (c)1995 Steinberg',0,0
driver_version	equ	$0104
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

	; Main sets up everything. The program size in d0 is passed into it.
	jsr	main

	; Terminate and stay resident.
	clr.w	-(a7)
	move.l	prog_size.l,-(a7)
	move.w	#$0031,-(a7)	; Ptermres
	trap	#1		; Gemdos




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Call MROS MEM.
	; Parameters on stack.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MROS_MEM:
	move.l	(a7)+,return_save.l
	trap	#8
	move.l	return_save.l,-(a7)
	rts

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Call MROS TRAP9.
	; Parameters on stack.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MROS_TRAP9:
	move.l	(a7)+,return_save.l
	trap	#9
	move.l	return_save.l,-(a7)
	rts

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Call MROS IOM.
	; Parameters on stack.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MROS_IOM:
	move.l	(a7)+,return_save.l
	trap	#10
	move.l	return_save.l,-(a7)
	rts

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Temporary return address save area for MROS_ calls.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_save:
	ds.l	1


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Driver write routines, called by MROS.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_write_port1:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	bset.b	#0,port_bitfield(a5)		; Mark port as having data waiting.
	bra.b	driver_write

driver_write_port2:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	bset.b	#1,port_bitfield(a5)		; Mark port as having data waiting.
	bra.b	driver_write

driver_write_port3:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	bset.b	#2,port_bitfield(a5)		; Mark port as having data waiting.
	bra.b	driver_write

driver_write_port4:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	bset.b	#3,port_bitfield(a5)		; Mark port as having data waiting.

driver_write:
	tst.w	hardware_ready(a5)		; Skip calling write_byte_hardware if it's not ready to accept data.
	beq.b	.skip
	bra.b	.dowrite

	; This part seems to be redundant?
	bpl.b	.dowrite
	bsr.w  	reset_hardware
	tst.w	hardware_ready(a5)
	bne.b	.dowrite
.skip:
	movea.l	(a7)+,a5
	rts

.dowrite:
	clr.w	hardware_ready(a5)
	bsr.w  	write_byte_hardware		; Actually write the data to the hardware.
	movea.l	(a7)+,a5
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Reset hardware.
	; Writes four zero bytes to the printer port.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset_hardware:
	movem.l	d0-d1/a5,-(a7)
	move.w	sr,-(a7)
	movea.w	#ym_data,a5
	ori.w	#$0700,sr		; Interrupts off.

	move.b	#15,ym_base.w
	move.b	#0,(a5)			; Set data lines to 0.

	move.b	#14,ym_base.w
	move.b	ym_base.w,d0		; Fetch port A status.
	move.w	d0,d1
	and.b	#$DF,d1			; Strobe low value.
	or.b	#$20,d0			; Strobe high value.

	move.b	d1,(a5)			; Pulse strobe low-high four times.
	move.b	d0,(a5)			; This gets the hardware back to a state where
	move.b	d1,(a5)			; it's expecting a port bitfield, regardless
	move.b	d0,(a5)			; of what state it's currently in.
	move.b	d1,(a5)
	move.b	d0,(a5)
	move.b	d1,(a5)
	move.b	d0,(a5)			; End with strobe high.

	move.b	mfp_gpio_reg.w,d0		; Fetch busy line status.
	move.b	#$FE,interrupt_pending_reg.w	; Clear busy interrupt.
	lea 	vars(pc),a5
	and.w	#1,d0
	eori.w	#1,d0				; Invert bit 0 of d0 (busy input).
	move.w	d0,hardware_ready(a5)		; Conditionally mark hardware ready.

	move.w	(a7)+,sr
	movem.l	(a7)+,d0-d1/a5
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually write the byte to the hardware.
	; a5 must point to vars.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
write_byte_hardware:
	ori.w	#$0700,sr			; Interrupts off.

	move.w	port_bitfield-1(a5),port_bitfield_copy-1(a5)
	beq.w  	.finish				; No data to transmit.

	move.w	#$2400,sr			; Interrupts on.

	movem.l	d0-d3/a0-a3,-(a7)
	movea.l	(a5),a2				; a2 = mros_get_byte_copy.
	lea 	tempbuf(pc),a3
	moveq.l	#-1,d3				; d3 = number of data bytes-1.

	; Populate tempbuf with the data bytes, and set d3 to the number of bytes - 1.

	btst.b	#0,port_bitfield_copy(a5)	; Check if data is waiting on port 0.
	beq.b	.skipport0
	addq.w	#1,d3				; Increment byte counter.
	lea 	descriptor_buf1.l,a0
	ori.w	#$0700,sr			; Interrupts off.
	jsr	(a2)				; Call mros_get_byte with a0 = descriptor_buf.
	move.b	d0,(a3)+			; Data byte is returned in d0.b.
	tst.w	d1				; If d1.w is zero, more data is waiting.
	beq.b	.skipclear0			; Skip the bitfield clear if more data is waiting.
	bclr.b	#0,port_bitfield(a5)
.skipclear0:
	move.w	#$2400,sr			; Interrupts on.
.skipport0:
	btst.b	#1,port_bitfield_copy(a5)	; Check if data is waiting on port 1.
	beq.b	.skipport1
	addq.w	#1,d3				; Increment byte counter.
	lea 	descriptor_buf2.l,a0
	ori.w	#$0700,sr			; Interrupts off.
	jsr	(a2)				; Call mros_get_byte with a0 = descriptor_buf.
	move.b	d0,(a3)+			; Data byte is returned in d0.b.
	tst.w	d1				; If d1.w is zero, more data is waiting.
	beq.b	.skipclear1			; Skip the bitfield clear if more data is waiting.
	bclr.b	#1,port_bitfield(a5)
.skipclear1:
	move.w	#$2400,sr			; Interrupts on.
.skipport1:
	btst.b	#2,port_bitfield_copy(a5)	; Check if data is waiting on port 2.
	beq.b	.skipport2
	addq.w	#1,d3				; Increment byte counter.
	lea 	descriptor_buf3.l,a0
	ori.w	#$0700,sr			; Interrupts off.
	jsr	(a2)				; Call mros_get_byte with a0 = descriptor_buf.
	move.b	d0,(a3)+			; Data byte is returned in d0.b.
	tst.w	d1				; If d1.w is zero, more data is waiting.
	beq.b	.skipclear2			; Skip the bitfield clear if more data is waiting.
	bclr.b	#2,port_bitfield(a5)
.skipclear2:
	move.w	#$2400,sr			; Interrupts on.
.skipport2:
	btst.b	#3,port_bitfield_copy(a5)	; Check if data is waiting on port 3.
	beq.b	.skipport3
	addq.w	#1,d3				; Increment byte counter.
	lea 	descriptor_buf4.l,a0
	ori.w	#$0700,sr			; Interrupts off.
	jsr	(a2)				; Call mros_get_byte with a0 = descriptor_buf.
	move.b	d0,(a3)+			; Data byte is returned in d0.b.
	tst.w	d1				; If d1.w is zero, more data is waiting.
	beq.b	.skipclear3			; Skip the bitfield clear if more data is waiting.
	bclr.b	#3,port_bitfield(a5)
.skipclear3:
	move.w	#$2400,sr			; Interrupts on.
.skipport3:

	; Write the port bitfield.

	lea 	tempbuf(pc),a3
	lea 	ym_base.w,a1			; a1 = ym_base.
	lea 	2(a1),a2			; a2 = ym_data.
	ori.w	#$0700,sr			; Interrupts off from here until end of routine.
	move.b	#15,(a1)
	move.b	port_bitfield_copy(a5),(a2)	; Write port bitfield.
	move.b	#14,(a1)
	move.b	(a1),d0
	move.w	d0,d1
	and.b	#$DF,d1				; Strobe values.
	or.b	#$20,d0

	; Loop writing all the data bytes in tempbuf.
.loop:
	move.b	#14,(a1)
	move.b	d1,(a2)				; Pulse strobe.
	move.b	d0,(a2)
	move.b	#15,(a1)
	move.b	(a3)+,(a2)			; Write data.
	dbf	d3,.loop

	move.b	#14,(a1)
	move.b	d1,(a2)				; Pulse strobe.
	move.b	d0,(a2)

	move.b	mfp_gpio_reg.w,d0
	move.b	#$FE,interrupt_pending_reg.w	; Clear interrupt.
	and.w	#1,d0				; Set hardware_ready if busy line was 0.
	subq.w	#1,d0
	or.w	d0,hardware_ready(a5)

	move.w	#$2400,sr			; Interrupts on.
	movem.l	(a7)+,d0-d3/a0-a3
	rts

.finish:
	ori.w	#1,hardware_ready(a5)		; Mark hardware as ready again.
	move.w	#$2400,sr			; Interrupts on.
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ISR.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printer_isr:
	movem.l	a5,-(a7)
	lea 	vars(pc),a5
	move.w	#$2400,sr				; Interrupts on.
	bsr.w  	write_byte_hardware
	movem.l	(a7)+,a5
	move.b	#$FE,interrupt_in_service_reg.w		; Clear interrupt.
	rte



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by driver_start.
	; d0.l return code: 1 on success, 0 on failure (hardware not connected).
	; If it fails, it always marks the hardware as connected.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start_helper:
	lea 	vars(pc),a0
	move.l	trap9val.l,trap9val_copy(a0)	; Take copies of variables.
	move.l	mros_get_byte.l,(a0)		; mros_get_byte_copy.

	clr.w	port_bitfield-1(a0)		; Clear port_bitfield.
	move.w	#1,hardware_ready(a0)		; Mark hardware as ready.

	move.b	mfp_gpio_reg.w,d0		; Test busy line.
	and.w	#1,d0
	bne.s	.fail				; If busy is high, fail.
	bsr.w  	setup_interrupt
	bsr.w  	reset_hardware			; This may unmark hardware_ready if it doesn't respond correctly.
	moveq.l	#1,d0
	rts
.fail:
	moveq.l	#0,d0
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by driver_start_helper.
	; Sets up the printer busy interrupt.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_interrupt:
	move.l	a2,-(a7)

	; Use TOS to assign the ISR vector.
	move.l	#printer_isr,-(a7)
	move.w	#0,-(a7)
	move.w	#$0D,-(a7)	; Mfpint
	trap	#14		; Xbios
	addq.w	#8,a7

	andi.b	#$FE,active_edge_reg.w		; Interrupt on high-to-low transition.
	ori.b	#$01,interrupt_enable_reg.w	; Interrupts enabled.
	ori.b	#$01,interrupt_mask_reg.w
	move.b	#$FE,interrupt_in_service_reg.w	; Clear interrupt.

	movea.l	(a7)+,a2
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by driver_stop.
	; Always returns 0 in d0.l.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_stop_helper:
	andi.b	#$FE,interrupt_enable_reg.w	; Disable printer busy interrupt.
	andi.b	#$FE,interrupt_mask_reg.w
	moveq.l	#0,d0
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Variables.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tempbuf:
	ds.b	4				; One data byte for each port, used in write_byte_hardware.

	; Offsets in vars:
mros_get_byte_copy	equ	$00		; Long.
trap9val_copy		equ	$04		; Long.
port_bitfield		equ	$09		; Byte. Sometimes cleared as a word at $08.
port_bitfield_copy	equ	$0d		; Byte?
hardware_ready		equ	$10		; Word, nonzero if the hardware is ready to accept data.

vars:
	dc.l	0	; Offset $0.
	dc.l	0	; Offset $4.
	dc.l	0	; Offset $8.
	dc.l	0	; Offset $c.
	dc.l	0	; Offset $10.
	dc.l	0	; Offset $14.



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
	move.l	a2,-(a7)

	; Call MROS_TRAP9 with opcode $28. Its purpose is unknown.
	; The low 16 bits of the program size (d0) are passed into it.
	; It may return something in d0.l, or leave d0.l unchanged.
	moveq.l	#$28,d0
	move.w	d0,-(a7)
	jsr	MROS_TRAP9
	addq.w	#2,a7
	move.l	d0,trap9val.l

	; Call MROS MEM with opcode 4 (get MROS info).
	; It's possible it could be using the value of a0,
	; which might be returned by MROS_TRAP9.
	; In other drivers, a0 would point to the start of BSS.
	moveq	#4,d1
	move.w	d1,-(a7)
	jsr	MROS_MEM
	addq.w	#2,a7

	; MROS returns a data structure in d0 = a2.
	; This may be redundant.
	movea.l	d0,a2

	; Call MROS MEM with opcode 4 again.
	; It may be using the value of a2, but probably not.
	moveq.l	#$4,d0
	move.w	d0,-(a7)
	jsr	MROS_MEM
	addq.w	#2,a7

	; MROS returns a data structure in d0 = a2.
	; Copy the mros_get_byte function pointer into mros_get_byte.
	movea.l	d0,a2
	movea.l	mros_mem4_get_byte(a2),a2
	move.l	a2,mros_get_byte.l

	jsr	init_func

	; Return 0.
	clr.w	d0
	movea.l	(a7)+,a2
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func:
	move.l	a2,-(a7)
	lea 	dev_struct.l,a2

	; Clear descriptor_buf1.
	move.l	#descriptor_size,d1
	clr.w	d0
	lea 	-$0B00(a2),a0			; Points to start of descriptor_buf1.
	jsr	memset

	; Populate descriptor_buf1.
	move.l	#midibuf1,-$0ADC(a2)		; start_of_buf in descriptor_buf1.
	move.l	#midibuf2,-$0AD8(a2)		; end_of_buf in descriptor_buf1.
	move.l	#driver_write_port1,-$0A70(a2)	; write_byte_ptr in descriptor_buf1.

	; Clear descriptor_buf2.
	move.l	#descriptor_size,d1
	clr.w	d0
	lea 	-$0A40(a2),a0			; Points to start of descriptor_buf2.
	jsr	memset

	; Populate descriptor_buf2.
	move.l	#midibuf2,-$0A1C(a2)		; start_of_buf in descriptor_buf1.
	move.l	#midibuf3,-$0A18(a2)		; end_of_buf in descriptor_buf1.
	move.l	#driver_write_port2,-$09B0(a2)	; write_byte_ptr in descriptor_buf1.

	; Clear descriptor_buf3.
	move.l	#descriptor_size,d1
	clr.w	d0
	lea 	-$0980(a2),a0			; Points to start of descriptor_buf3.
	jsr	memset

	; Populate descriptor_buf3.
	move.l	#midibuf3,-$095C(a2)		; start_of_buf in descriptor_buf1.
	move.l	#midibuf4,-$0958(a2)		; end_of_buf in descriptor_buf1.
	move.l	#driver_write_port3,-$08F0(a2)	; write_byte_ptr in descriptor_buf1.

	; Clear descriptor_buf4.
	move.l	#descriptor_size,d1
	clr.w	d0
	lea 	-$08C0(a2),a0			; Points to start of descriptor_buf4.
	jsr	memset

	; Populate descriptor_buf4.
	move.l	#midibuf4,-$089C(a2)		; start_of_buf in descriptor_buf1.
	move.l	a2,-$0898(a2)			; end_of_buf in descriptor_buf1.
	move.l	#driver_write_port4,-$0830(a2)	; write_byte_ptr in descriptor_buf1.

	; Clear dev_struct.
	moveq.l	#dev_struct_size,d1
	clr.w	d0
	movea.l	a2,a0
	jsr	memset

	; Populate dev_struct.
	move.l	#descriptor_buf1,(a2)		; dev_descriptor_buf.
	move.w	#$0001,dev_ff(a2)
	clr.w	devmins(a2)
	move.w	#4,devmouts(a2)			; 4 outputs.
	move.l	#driver_start,dev_driver_start(a2)
	move.l	#driver_stop,dev_driver_stop(a2)
	move.w	#driver_version,devvers(a2)
	move.b	#$4D,devname(a2)		; Set name.
	move.b	#$4F,devname+1(a2)
	move.b	#$34,devname+2(a2)
	clr.b	devname+3(a2)

	; Pass dev_struct into MROS IOM. Opcode $14 (publish driver).
	pea	(a2)				; dev_struct.
	moveq.l	#$14,d0
	move.w	d0,-(a7)
	jsr	MROS_IOM
	addq.w	#6,a7

	movea.l	(a7)+,a2
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually starts the driver running.
	; d0.l return code: 0 on success, $0000ffff on failure.
	; Called by MROS.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start:
	jsr	driver_start_helper		; Returns 1 on success, 0 on failure.
	subq.w	#1,d0
	bne.s	.fail
	move.w	#1,dev_struct_devact.l		; Mark device active.
	rts
.fail:
	clr.w	dev_struct_devact.l		; Mark device inactive.
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Stops the driver. Called by MROS.
	; Always returns 0 in d0.l.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_stop:
	clr.w	dev_struct_devact.l		; Mark device inactive.
	jsr	driver_stop_helper
	rts




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Memset(a0, d0, d1).
	; d0.b = data.
	; d1.l = length in bytes.
	; a0 = start address (can start on any boundary).
	; Returns with a0 equal to the value passed into the function.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memset:
	move.l	a0,-(a7)

	adda.l	d1,a0				; a0 points to end of buffer.

	move.l	a0,d2				; Check if end address is odd.
	btst.l	#0,d2
	beq.b	.skip

	; End address is odd. Write a byte to the end to make it even, and decrement length (d1).
	; If the length goes negative, exit.
	subq.l	#1,d1
	bcs.w  	.finish
	move.b	d0,-(a0)

.skip:
	; Duplicate the byte in d0 to fill all four bytes of d2.
	move.b	d0,-(a7)
	move.w	(a7)+,d2
	move.b	d0,d2
	move.w	d2,d0
	swap	d2
	move.w	d0,d2

	; d0 = length in 1K units.
	; If length is less than 1K, skip ahead to .lessthan1K.
	move.l	d1,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	beq.b	.lessthan1K

	; Set up all the registers with data ready for movem.
	movem.l	d1/d3-d7/a2-a6,-(a7)
	move.l	d2,d1
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	movea.l	d2,a1
	movea.l	d2,a2
	movea.l	d2,a3
	movea.l	d2,a4
	movea.l	d2,a5
	movea.l	d2,a6


.loop:	; Unrolled movem loop writing 1K at a time.
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a2,-(a0)
	subq.l	#1,d0
	bne.b	.loop

	movem.l	(a7)+,d1/d3-d7/a2-a6
	and.w	#$3FF,d1		; Just leave the modulo 1K in d1.w.

.lessthan1K:

	; Write the remainder in longword chunks.
	move.w	d1,d0
	lsr.w	#2,d0
	beq.b	.lessthanlongword
	subq.w	#1,d0
.loop2:
	move.l	d2,-(a0)
	dbf	d0,.loop2

.lessthanlongword:

	; Write the remainder in bytes.
	and.w	#3,d1
	beq.b	.finish
	subq.w	#1,d1
.loop3:
	move.b	d2,-(a0)
	dbf	d1,.loop3

.finish:
	movea.l	(a7)+,a0
	rts




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	.DATA

	; For port descriptor entry in descriptor_buf:
	; A pointer to port descriptor is stored in dev_struct and passed into MROS.
	; The port descriptor is also passed into mros_get_byte in the ISR.
start_of_buf	equ	$24	; Longword, pointer to start of data buffer.
end_of_buf	equ	$28	; Longword, pointer to end of data buffer.
write_byte_ptr	equ	$90	; Longword, pointer to write byte function.


	; Each descriptor is 192 bytes in size, there are 4 descriptors - one for each port.
descriptor_size	equ	192	; Size of a descriptor entry in bytes.
descriptor_buf1:		; All four buffers must be contiguous.
	ds.b	descriptor_size
descriptor_buf2:
	ds.b	descriptor_size
descriptor_buf3:
	ds.b	descriptor_size
descriptor_buf4:
	ds.b	descriptor_size


	; Buffers for each port, passed into MROS.
	; Most likely for buffering output data.
midibuf_size	equ	512		; Size of each port buffer in bytes.
midibuf1:
	ds.b	midibuf_size
midibuf2:
	ds.b	midibuf_size
midibuf3:
	ds.b	midibuf_size
midibuf4:
	ds.b	midibuf_size


dev_struct_size	equ	64	; Size of dev_struct in bytes.

	; Offsets in dev_struct:
dev_descriptor_buf	equ	$00	; Points to descriptor_buf.
dev_b			equ	$04	; Word
dev_ff			equ	$06	; Word, Set to $0001 during initialisation.
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
dev_struct_devact:
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
	ds.b	8	; $38: devname (8 bytes)

trap9val:
	ds.l	1	; Returned from MROS trap9, or alternatively it may be the program size in bytes.

mros_get_byte:
	ds.l	1


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

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ST register definitions.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ym_base				equ	$ffff8800
ym_data				equ	$8802		; Word.
mfp_gpio_reg			equ	$fffffa01
active_edge_reg			equ	$fffffa03
interrupt_enable_reg		equ	$fffffa09
interrupt_pending_reg		equ	$fffffa0d
interrupt_in_service_reg	equ	$fffffa11
interrupt_mask_reg		equ	$fffffa15