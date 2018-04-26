	;	TEXT	$000AFC bytes, segment starts at L000+$0
	;	DATA	$000000 bytes
	;	BSS	$000000 bytes
	;	SYMBOLS	$000000 bytes
	;	FLAGS	0003 0000

	COMMENT HEAD=3

	.TEXT

	jmp	start

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Header, probably needs to be this exact format.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Text string can be any length, terminated a 0 byte and further
	; 0 byte if necessary to pad out to an even length.
	dc.b	'MROS LAN Port driver V 1.0 1193 (c)1993 Steinberg',0
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

	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function sets up dev_struct.
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_2:
	lea 	dev_struct(pc),a0

	; Clear dev_struct, up to and including devvers but not devname (which is populated in text segment).
	movea.l	a0,a1
	moveq.l	#(dev_struct_size-8)-1,d0
.loop:
	clr.b	(a1)+
	dbf	d0,.loop

	move.w	#driver_version,devvers(a0)	; Set device version.

	lea 	descriptor_buf(pc),a1		; Store pointer to descriptor_buf in dev_descriptor_buf of dev_struct.
	move.l	a1,(a0)
	move.w	#1,dev_ff(a0)			; Set dev_ff to $0001.
	move.w	#1,mouts(a0)			; Set number of MIDI outs to 1.
	move.w	#1,mins(a0)			; Set number of MIDI ins to 1.
	lea 	driver_start(pc),a1		; Set dev_driver_start and dev_driver_stop to point to their corresponding functions.
	move.l	a1,dev_driver_start(a0)
	lea 	driver_stop(pc),a1
	move.l	a1,dev_driver_stop(a0)

	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function fetches certain variables from MROS.
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_1:
	lea 	vars(pc),a0

	; Clear vars.
	moveq.l	#vars_size-1,d0
.loop:	clr.b	(a0)+
	dbf	d0,.loop

	; Call MROS MEM with opcode 4 (get MROS info).
	; It's possible it could be using the value of a0,
	; which is now pointing to BSS.
	move.w	#4,-(a7)
	trap	#8
	lea 	2(a7),a7

	; This structure is returned when calling MROS MEM with opcode 4
	; during init_func_1. The values are copied to private variables and the
	; structure doesn't appear to be used anywhere else.
	movea.l	d0,a0
	lea 	vars(pc),a1
	move.l	mros_mem4_2(a0),mros_mem_2(a1)
	move.l	mros_mem4_1(a0),mros_mem_1(a1)
	move.l	mros_mem4_put_byte(a0),mros_put_byte(a1)
	move.l	mros_mem4_get_byte(a0),mros_get_byte(a1)

	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; This function fills in the port descriptors.
	; Called by main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_func_3:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	lea 	descriptor_buf(pc),a1

	; Clear descriptor_buf.
	moveq.l	#(descriptor_size/4)-1,d0
.loop:	clr.l	(a1)+
	dbf	d0,.loop

	lea 	fifo_buf(pc),a0			; Set FIFO pointers up.
	move.l	a0,fifo_buf_start(a5)
	move.l	a0,fifo_buf_wr_ptr(a5)
	move.l	a0,fifo_buf_rd_ptr(a5)
	lea 	fifo_buf_size(a0),a0
	move.l	a0,fifo_buf_end(a5)		; This may point to the end of fifo_buf or the start of descriptor_buf.

	lea 	descriptor_buf(pc),a0

	lea 	midibuf(pc),a1
	move.l	a1,start_of_buf(a0)
	lea 	midibuf_size(a1),a1
	move.l	a1,end_of_buf(a0)
	lea 	midibuf_in(pc),a1
	move.l	a1,start_of_in_buf(a0)
	lea 	midibuf_in_size(a1),a1
	move.l	a1,end_of_in_buf(a0)
	lea 	driver_write(pc),a1
	move.l	a1,write_byte_ptr(a0)

	movea.l	(a7)+,a5
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually starts the driver running.
	; d0.l: return code, always 0.
	; Called by MROS.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	lea 	dev_struct(pc),a0

	tst.w	devact(a0)				; Check if already active.
	bne.b	.finish

	move.w	sr,-(a7)				; Interrupts off.
	ori.w	#$0700,sr

	move.l	scc_int_vec_1.w,int_vec_1_save(a5)	; Save and set interrupt vectors.
	move.l	scc_int_vec_2.w,int_vec_2_save(a5)
	move.l	scc_int_vec_3.w,int_vec_3_save(a5)
	move.l	#transmit_isr,scc_int_vec_1.w
	move.l	#receive_isr,scc_int_vec_2.w
	move.l	#receive_isr,scc_int_vec_3.w

	jsr	scc_table_write				; Set up SCC registers.

	move.w	(a7)+,sr				; Restore interrupts.

	tst.w	mros_handle(a5)				; Skip setup if already done.
	bne.b	.skip

	lea 	mem_struct(pc),a0			; MROS MEM struct passed to open MROS.
	move.l	#passed_to_mros_open,(a0)		; Set *a in mem_struct.

	pea	mem_struct(pc)				; Call mros_open with mem_struct.
	clr.w	-(a7)
	trap	#8
	lea 	6(a7),a7

	move.w	d0,mros_handle(a5)			; If it succeeded (nonzero), prevent it from running again.

.skip:
	clr.w	interrupt_lock(a5)
	lea 	descriptor_buf(pc),a0
	clr.w	descriptor_flag(a0)
	lea 	dev_struct(pc),a0
	st.b	devact(a0)				; Mark device active.
.finish:
	movea.l	(a7)+,a5
	moveq.l	#0,d0
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Stops the driver. Called by MROS.
	; Always returns 0 in d0.l.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_stop:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	lea 	dev_struct(pc),a0

	tst.w	devact(a0)			; Do nothing if it's not active.
	beq.b	.finish

	clr.w	devact(a0)			; Mark device inactive.

	move.w	sr,-(a7)
	ori.w	#$0700,sr			; Interrupts off.

	move.l	int_vec_1_save(a5),scc_int_vec_1.w	; Restore interrupt vectors.
	move.l	int_vec_2_save(a5),scc_int_vec_2.w
	move.l	int_vec_3_save(a5),scc_int_vec_3.w

	jsr	scc_ints_off			; Turn SCC interrupts off.

	move.w	(a7)+,sr			; Restore interrupts.

	tst.w	mros_handle(a5)			; Do nothing if MROS is not open.
	beq.b	.finish

	move.w	mros_handle(a5),-(a7)		; Call close_mros via MROS MEM opcode 1, with mros_handle.
	move.w	#1,-(a7)
	trap	#8
	lea 	4(a7),a7
	clr.w	mros_handle(a5)

.finish:
	movea.l	(a7)+,a5
	moveq.l	#0,d0
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by MROS to write data to the driver.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_write:
	lea 	dev_struct(pc),a0

	tst.w	devact(a0)			; If device is inactive, clear descriptor_flag and return.
	beq.b	.finishclear

	move.w	sr,-(a7)			; Interrupts off.
	ori.w	#$0700,sr

	lea 	scc_control_a.w,a0		; Read SCC register 0.
	move.b	#$00,(a0)
	move.b	(a0),d0

	btst.l	#2,d0				; If SCC is not ready for next byte, return.
	beq.b	.finish

	lea 	descriptor_buf(pc),a0
	lea 	vars(pc),a1

	movea.l	mros_get_byte(a1),a1
	jsr	(a1)				; Call mros_get_byte.

	tst.w	d0				; If it returns -1 (no data available), return.
	bmi.b	.finish

	move.b	d0,scc_data_a.w  		; Write data to SCC.

.finish:
	move.w	(a7)+,sr
	rts

.finishclear:
	lea 	descriptor_buf(pc),a0
	clr.w	descriptor_flag(a0)
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Transmit ISR.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transmit_isr:
	movem.l	d0-d2/a0-a1,-(a7)
	lea 	scc_control_a.w,a0

	move.b	#$00,(a0)
	move.b	#$28,(a0)		; Reset transmit interrupt pending.
	move.b	#$00,(a0)
	move.b	#$F8,(a0)		; Reset transmit underrun/EOM latch, reset highest IUS.

	lea 	descriptor_buf(pc),a0
	lea 	vars(pc),a1

	movea.l	mros_get_byte(a1),a1	; Get byte from MROS.
	jsr	(a1)

	tst.w	d0			; If it returned -1, no data is available.
	bmi.b	.skip
	move.b	d0,scc_data_a.w  	; Write data to SCC.
.skip:
	movem.l	(a7)+,d0-d2/a0-a1
	rte



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Receive ISR.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
receive_isr:
	move.w	#$2700,sr
	movem.l	d0-d2/a0-a1/a5,-(a7)
	lea 	scc_control_a.w,a0

	; Get byte from SCC.

	move.b	#$00,(a0)
	move.b	#$78,(a0)			; Reset Rx CRC checker, reset highest IUS?

	lea 	vars(pc),a5
	movea.l	fifo_buf_wr_ptr(a5),a1
	move.b	2(a0),(a1)+			; Read from scc_data_a and write to the FIFO.

	cmpa.l	fifo_buf_end(a5),a1		; Check FIFO write pointer reaching the end and wrap.
	blt.b	.skip
	movea.l	fifo_buf_start(a5),a1
.skip:
	move.l	a1,fifo_buf_wr_ptr(a5)		; Update FIFO write pointer.


	tas	interrupt_lock(a5)		; Acquire the interrupt lock. If other bytes arrive during
	bne.b	.finish				; the following loop (which may be slow due to calling MROS),
						; the subsequent ISR calls will return at this point after
						; putting the bytes in the FIFO.


	lea 	descriptor_buf(pc),a0
	movea.l	mros_mem_1(a5),a1
	move.l	4(a1),descriptor_unknown_1(a0)	; Unknown.
	move.l	(a1),descriptor_unknown_2(a0)


	; Loop sending contents of FIFO into MROS with mros_put_byte.
	movea.l	fifo_buf_rd_ptr(a5),a0
	movea.l	mros_put_byte(a5),a1
.loop:
	move.w	#$2500,sr			; Interrupts on.
	move.b	(a0)+,d0			; Read byte from FIFO.
	cmpa.l	fifo_buf_end(a5),a0		; Check FIFO read pointer reaching the end and wrap.
	blt.b	.skip2
	movea.l	fifo_buf_start(a5),a0
.skip2:
	movem.l	a0-a1,-(a7)
	lea 	descriptor_buf(pc),a0
	jsr	(a1)				; Call mros_put_byte with descriptor_buf in a0.
	movem.l	(a7)+,a0-a1
	move.w	#$2700,sr			; Interrupts off.
	cmpa.l	fifo_buf_wr_ptr(a5),a0		; Keep looping until all bytes in FIFO have been sent to MROS.
	bne.b	.loop

	move.l	a0,fifo_buf_rd_ptr(a5)		; Update FIFO read pointer.
	clr.w	interrupt_lock(a5)

.finish:
	move.w	#$2500,sr			; Interrupts on.
	movem.l	(a7)+,d0-d2/a0-a1/a5
	rte



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Write a table of data to the SCC control port.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scc_table_write:
	lea 	scc_control_a.w,a0
	lea 	scc_control_table(pc),a1
.loop:
	move.b	(a1)+,d0
	bmi.s	.finish			; List is terminated with $ff.
	move.b	d0,(a0)			; Write first byte.
	move.b	(a1)+,(a0)		; Write second byte.
	bra.b	.loop
.finish:
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Disables SCC interrupts except ext ints.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scc_ints_off:
	lea 	scc_control_a.w,a0
	move.b	#$01,(a0)
	move.b	#$01,(a0)
	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Pointer to this function passed into open MROS as *a in the mem_struct.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
passed_to_mros_open:
	cmp.w	#1,d0
	bne.b	.skip
	lea 	descriptor_buf(pc),a0
	clr.w	descriptor_flag(a0)
.skip:	rts


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	dc.l	0

midibuf_size		equ	512		; Size of MIDI output buffer in bytes.
midibuf:
	ds.b		midibuf_size


midibuf_in_size		equ	512		; Size of MIDI input buffer in bytes.
midibuf_in:
	ds.b		midibuf_in_size


fifo_buf_size		equ	512
fifo_buf:
	ds.b		fifo_buf_size


	; For port descriptor entry in descriptor_buf:
	; A pointer to port descriptor is stored in dev_struct and passed into MROS.
start_of_in_buf		equ	$04	; Longword, pointer to start of MIDI input buffer.
end_of_in_buf		equ	$08	; Longword, pointer to end of MIDI input buffer.
descriptor_unknown_1	equ	$16	; Longword, copied from mros_mem_1 struct.
descriptor_unknown_2	equ	$1a	; Longword, copied from mros_mem_1 struct.
start_of_buf		equ	$24	; Longword, pointer to start of MIDI output buffer.
end_of_buf		equ	$28	; Longword, pointer to end of MIDI output buffer.
descriptor_flag		equ	$30	; Word.
write_byte_ptr		equ	$90	; Longword, pointer to write byte function.


descriptor_size		equ	192	; Size of a descriptor entry in bytes.

descriptor_buf:
	ds.b		descriptor_size


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
devname			equ	$38	; Device name, ASCII, 8 bytes, no terminator necessary.

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
	dc.b	'LAN Port'	; $38: devname (8 bytes)


	dc.w	0	; Not part of dev_struct.

mem_struct:
	dc.l	0	; $00: *a
	dc.w	0	; $04: b
	dc.w	0	; $06: c
	dc.w	0	; $08: d
	dc.w	0	; $0a: e
	dc.w	0	; $0c: f
	dc.w	0	; $0e: g
	dc.w	0	; $10: h
	ds.b	14	; $12: i[14]
	dc.b	'LAN',0	; appl_name[16], must be null-terminated.
	ds.b	12


vars_size	equ	62

	; Offsets in vars:
mros_handle		equ	$02	; Word.
mros_mem_1		equ	$0c	; Longword.
mros_mem_2		equ	$10	; Longword.
mros_put_byte		equ	$14	; Longword.
mros_get_byte		equ	$18	; Longword.
int_vec_1_save		equ	$20	; Longword.
int_vec_2_save		equ	$24	; Longword.
int_vec_3_save		equ	$28	; Longword.
fifo_buf_start		equ	$2c	; Longword.
fifo_buf_end		equ	$30	; Longword.
fifo_buf_wr_ptr		equ	$34	; Longword.
fifo_buf_rd_ptr		equ	$38	; Longword.
interrupt_lock		equ	$3c	; Word.


vars:
	ds.b	vars_size


	; Table written to SCC control register A.
	; High byte (register address) is written first, low byte (register contents) second.
	; List is terminated with high byte $ff.
scc_control_table:
	dc.w	$0982			; Reset channel A, with NV set?
	dc.w	$0484			; x32 clock, 1 stop bit, no parity.
	dc.w	$0260			; Interrupt vector = $60.
	dc.w	$03c0			; Receive 8 bits per character, receiver disabled.
	dc.w	$0562			; Transmit 8 bits per character, DTR low, RTS high, transmit disabled.
	dc.w	$0600			; Sync = 0?
	dc.w	$0700			; Sync = 0?
	dc.w	$0901			; Out of reset with VIS set? Or time constant = $01?
	dc.w	$0a00			; Undocumented.
	dc.w	$0b28			; Receive clock = TRxC pin (no Xtal), transmit clock = TRxC pin, TRxC = input.
	dc.w	$0c00			; Undocumented.
	dc.w	$0d00			; Upper byte of time constant = $00.
	dc.w	$0e00			; Baud rate generator disable.
	dc.w	$03c1			; Receive 8 bits per character, receiver enabled.
	dc.w	$056a			; Transmit 8 bits per character, DTR low, RTS high, transmit enabled.
	dc.w	$0f00			; Disable most interrupts.
	dc.w	$0010			; Reset ext/status interrupts.
	dc.w	$0010			; Reset ext/status interrupts.
	dc.w	$0113			; DMA disabled, interrupt on all received characters, transmit and ext interrupt enable.
	dc.w	$0909			; MIE and VIS set.
	dc.b	$ff			; Terminate table.

	; This table is unused.
	dc.b	$00
	dc.w	$0000,$0002,$540e,$0120,$0808,$0812,$5c00



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; MROS structures.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; This structure is returned when calling MROS MEM with opcode 4
	; during init_func_1. The values are copied to private variables and the
	; structure doesn't appear to be used anywhere else.
mros_mem4_2		equ	$4	; Longword, copied to mros_mem_2.
mros_mem4_1		equ	$8	; Longword, copied to mros_mem_1.
mros_mem4_put_byte	equ	$c	; Longword, copied to mros_put_byte.
mros_mem4_get_byte	equ	$10	; Longword, copied to mros_get_byte.



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ST register definitions.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scc_int_vec_1	equ	$01A0
scc_int_vec_2	equ	$01B0
scc_int_vec_3	equ	$01B8
scc_control_a	equ	$8C81
scc_data_a	equ	$8C83