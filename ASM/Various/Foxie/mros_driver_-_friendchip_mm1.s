	;	TEXT	$001952 bytes, segment starts at L0000+$0
	;	DATA	$000000 bytes
	;	BSS	$004000 bytes, segment starts at U1952
	;	SYMBOLS	$000000 bytes
	;	FLAGS	0003 0000

	COMMENT HEAD=3

	.TEXT

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Header, probably needs to be this exact format.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Text string can be any length, terminated a 0 byte and further
	; 0 byte if necessary to pad out to an even length.
	jmp	start
	dc.b	'MROS Friendchip MM1 Driver V 1.03 1092 (c)1992 Steinberg',0,0
driver_version	equ	$0103
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
	; Return code is 0.
	clr.w	-(a7)
	move.l	prog_size(pc),-(a7)
	move.w	#$0031,-(a7)	; Ptermres
	trap	#1		; Gemdos




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Main.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
	bsr  	init_func_1			; Fetch variables from MROS.
	bsr  	init_func_2			; Set up dev_struct.
	bsr  	init_func_3			; Fill in the port descriptors.

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
	moveq.l	#(dev_struct_size-8)-1,d0
.loop:	clr.b	(a1)+
	dbf	d0,.loop

	move.w	#driver_version,devvers(a0)		; Set device version.

	lea 	descriptor_buf(pc),a1
	move.l	a1,(a0)					; Store pointer to descriptor_buf in dev_descriptor_buf of dev_struct.
	st.b	dev_ff(a0)				; Set dev_ff upper byte.
	move.w	#num_outs,devmouts(a0)			; Set number of MIDI outs to 8.
	lea 	driver_start(pc),a1			; Set dev_driver_start and dev_driver_stop to point to their corresponding functions.
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
.loop:	clr.b	(a0)+
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

	lea 	vars(pc),a5		; Not actually used.
	lea 	descriptor_buf(pc),a1

	; Clear all of descriptor_buf including lastport (1536 bytes total).
	move.w	#((descriptor_size*num_outs)/4)-1,d0
.loop1:	clr.l	(a1)+
	dbf	d0,.loop1

	lea 	descriptor_buf(pc),a0
	lea 	midibuf(pc),a1
	lea 	driver_write(pc),a2

	; Fill in all 8 port descriptors.
	moveq.l	#num_outs-1,d0
.loop2:	move.l	a1,start_of_buf(a0)	; Store pointer to start of 512 byte part of midibuf.
	lea 	midibuf_size(a1),a1	; Move to next 512 byte block.
	move.l	a1,end_of_buf(a0)	; Store pointer to end of 512 byte buffer.
	move.l	a2,write_byte_ptr(a0)	; Store pointer to driver_write.
	lea 	descriptor_size(a0),a0	; Move to next port descriptor.
	dbf	d0,.loop2

	movem.l	(a7)+,a2/a5
	rts




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Actually starts the driver running.
	; Returns with a pointer to dev_struct in a0.
	; d0.l return code: 0 on success, -1 on failure.
	; Called by MROS.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start:
	move.l	a5,-(a7)
	lea 	vars(pc),a5
	bsr  	init_func_1		; Clear variables and fetch variables from MROS.
	lea 	dev_struct(pc),a0
	clr.w	devact(a0)		; Set device to inactive.
	bsr  	driver_start_helper	; This is where most of the startup code is.
	movea.l	(a7)+,a5		; driver_start_helper returns success/failure in d0.l.
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Stops the driver. Called by MROS.
	; Always returns 0 in d0.l.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_stop:
	move.l	a5,-(a7)
	lea 	vars(pc),a5

	; If mros_other_struct_val is nonzero, return without doing anything.
	; mros_other_struct *must* exist. Only the first pointer is checked.
	movea.l	mros_mem_struct(a5),a0
	movea.l	mros_mem_struct_ptr(a0),a0
	tst.w	mros_other_struct_val(a0)
	bne.b	.skip

	; Turn off and clear interrupts.
	bclr.b	#0,interrupt_mask_reg.w
	bclr.b	#0,interrupt_enable_reg.w
	move.b	#$FE,interrupt_pending_reg.w  
	move.b	#$FE,interrupt_in_service_reg.w

	; Mark device as inactive.
	lea 	dev_struct(pc),a0
	clr.w	devact(a0)
.skip:
	movea.l	(a7)+,a5
	moveq.l	#0,d0
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by driver_start.
	; Returns with a pointer to dev_struct in a0.
	; d0.l return code: 0 on success, -1 on failure.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_start_helper:
	; Check both instances of mros_other_struct. If one of them exists and
	; has mros_other_struct_val set to nonzero, fail.
	; If neither instance of mros_other_struct exists, it will succeed.
	lea 	vars(pc),a1
	movea.l	mros_mem_struct(a1),a0
	move.l	mros_mem_struct_ptr(a0),d0
	beq.b	.skip
	movea.l	d0,a1
	tst.w	mros_other_struct_val(a1)
	bne.b	.fail
.skip:
	move.l	mros_mem_struct_ptr2(a0),d0
	beq.b	.skip2
	movea.l	d0,a1
	tst.w	mros_other_struct_val(a1)
	bne.b	.fail
.skip2:

	move.w	sr,-(a7)
	ori.w	#$0700,sr			; Interrupts off.
	lea 	vars(pc),a0
	port_clear_all	a0			; Clear port_bitfield.
	move.l	#printer_isr,int_vec_mfp0.w  	; Set interrupt vector.
	bclr.b	#0,active_edge_reg.w  		; Interrupt on high-low edge.
	bset.b	#0,interrupt_enable_reg.w  	; Enable ints.
	bset.b	#0,interrupt_mask_reg.w  	; Unmask ints.
	move.b	#$FE,interrupt_pending_reg.w  	; Clear interrupt pending.
	move.b	#$FE,interrupt_in_service_reg.w	; Clear interrupt in service.
	move.w	(a7)+,sr			; Interrupts on.

	; Return with dev_struct in a0 and return code (d0.l) = 0.
	lea 	dev_struct(pc),a0
	st.b	devact(a0)			; Set devact in dev_struct indicating device is active.
	moveq.l	#0,d0
	rts
.fail:
	; Return with dev_struct in a0 and return code (d0.l) = -1.
	lea 	dev_struct(pc),a0
	clr.w	devact(a0)			; Clear devact in dev_struct indicating device is inactive.
	moveq.l	#-1,d0
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Called by MROS to write data to the driver.
	; a0 points to a structure containing the port number.
	; The data is queued up in MROS and is actually read during
	; the ISR by calling mros_get_byte. The ISR is triggered by this function.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
driver_write:
	move.w	sr,-(a7)
	ori.w	#$0700,sr			; Interrupts off until end of routine.
	move.w	driver_write_portnum(a0),d0	; Fetch probably port number.
	and.w	#num_outs_mask,d0		; Mask port number to 0-7.
	lea 	vars(pc),a1
	port_set_bit	d0,a1			; Set port_bitfield to indicate port is being addressed.
	bset.b	#0,active_edge_reg.w		; Trigger interrupt by toggling active edge.
	bclr.b	#0,active_edge_reg.w
	move.w	(a7)+,sr
	rts



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
	; ISR.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printer_isr:
	move.l	a5,-(a7)
	lea 	vars(pc),a5

	move.w	#$2700,sr		; Interrupts off, temporarily.

	st.b	int_in_service(a5)	; Set interrupt in service flag.

	; If no bits are set in port_bitfield, return from ISR and clear interrupt.
	port_test_all	a5		; port_bitfield.
	beq.w  	.finish_isr

	movem.l	d0-d3/a0-a4,-(a7)

	move.w	#$2500,sr		; Allow MFP interrupts.
	movea.l	mros_get_byte(a5),a2
	lea 	lastport(pc),a3		; Last port descriptor.
	lea 	temp_output_buf_end(pc),a4

	; Populate temp_output_buf by calling MROS to get a byte for each port.
	; Starts from the highest port and works backwards.
	moveq.l	#num_outs-1,d3
.loop:
	moveq.l	#-1,d0			; Default to -1 if no data.
	port_test_bit	d3,a5		; port_bitfield, check to see if port is set.
	beq.b	.skip			; Not set, just write -1.
	movea.l	a3,a0			; Port descriptor in a0, required by MROS call.
	move.w	#$2700,sr		; Interrupts off for this call.
	jsr	(a2)			; Call mros_get_byte. Returns data in d0.
	tst.w	d1			; If it returns zero in d1.w, bitfield clearing is skipped. It might be set to zero to indicate more data is waiting?
	beq.b	.skip
	port_clear_bit	d3,a5		; Clear port_bitfield for that port.
.skip:
	move.w	#$2500,sr		; Allow MFP interrupts.
	move.w	d0,-(a4)		; Write data to temp_output_buf, -1 if no data.
	lea 	-descriptor_size(a3),a3	; Move to previous port descriptor.
	dbf	d3,.loop


	moveq.l	#0,d3			; Port counter.
	moveq.l	#num_outs-1,d1		; Loop counter.
	lea 	ym_base.w,a0		; a0 = YM address/read data.
	lea 	2(a0),a1		; a1 = YM write data.
	move.w	#$2700,sr		; Interrupts off from here until rte.


	; Wait until busy line is low.
.wait:	btst.b	#0,mfp_gpio_reg.w  
	bne.b	.wait


	; Set both YM ports to outputs.
	move.b	#$07,(a0)
	move.b	(a0),d2
	or.b	#$C0,d2
	move.b	d2,(a1)


	; Loop through all 8 ports, writing data.
	; a4 points to a buffer containing 8 words, one for each port.
	; -1 means no data for that port.
	; d1.w is the loop counter (7-0), d3.w is the port counter (0-7).
.loop2:	move.w	(a4)+,d0
	bmi.b	.continue		; No data for this port.
	move.b	#$0F,(a0)
	move.b	d0,(a1)			; Write data to printer port.
	move.b	#$0E,(a0)
	move.b	(a0),d2
	bclr	#$05,d2			; Strobe line low.
	move.b	d2,(a1)
	bset	#$05,d2			; Strobe line high.
	move.b	d2,(a1)
	move.b	#$0F,(a0)
	move.b	d3,(a1)			; Write port number to printer port.
	move.b	#$0E,(a0)
	move.b	(a0),d2
	bclr	#$05,d2			; Strobe line low.
	move.b	d2,(a1)
	bset	#$05,d2			; Strobe line high.
	move.b	d2,(a1)
.continue:
	addq.w	#1,d3
	dbf	d1,.loop2		; Loop.

	movem.l	(a7)+,d0-d3/a0-a4
.finish_isr:
	clr.w	int_in_service(a5)	; Clear interrupt in service flag.
	movea.l	(a7)+,a5
	move.b	#$FE,interrupt_in_service_reg.w	; Clear printer port interrupt.
	rte				; Return from printer interrupt handler.



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; port_bitfield manipulation macros.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
port_set_bit	MACRO
		bset.b	\1,(\2)
		ENDM

port_clear_bit	MACRO
		bclr.b	\1,(\2)
		ENDM

port_clear_all	MACRO
		clr.w	(\1)
		ENDM

port_test_bit	MACRO
		btst.b	\1,(\2)
		ENDM

port_test_all	MACRO
		tst.b	(\1)
		ENDM



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Data.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; Increasing this beyond 8 requires some code modifications to the bitfield macros.
	; Increasing beyond 16 requires making port_bitfield bigger.
num_outs	equ	8
num_outs_mask	equ	7


	; Contains 8 buffers of 512 bytes - one for each port, passed into MROS.
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


	; Each descriptor is 192 bytes in size, there are 8 descriptors - one for each port.
	; lastport is a pointer to the last descriptor.
descriptor_size	equ	192	; Size of a descriptor entry in bytes.
descriptor_buf:
	ds.b	((num_outs-1)*descriptor_size)
lastport:
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
	dc.b	'MM1',0,0,0,0,0 ; $38: devname (8 bytes)



	; Temporary output buffer, one word for each port. Used within ISR.
temp_output_buf:
	ds.w	num_outs
temp_output_buf_end:


vars_size	equ	28	; Size of vars structure in bytes.

	; Offsets in vars:
port_bitfield	equ	$00	; Word, bitfield: one bit for each port, set by driver_write. High byte only. Low byte sometimes overwritten with 0.
int_in_service	equ	$02	; Word, set when interrupt handler is running, cleared on exit. High byte only. Low byte sometimes overwritten with 0.
mros_mem_1	equ	$08	; Longword, loaded from value returned during MROS MEM init.
mros_mem_2	equ	$0c	; Longword, loaded from value returned during MROS MEM init.
mros_get_byte	equ	$14	; Longword, points to an MROS routine called in the ISR, loaded from value returned during MROS MEM init.
mros_mem_struct	equ	$18	; Longword, points to a data structure returned by MROS MEM during init.

vars:
	dc.w	0	; port_bitfield
	dc.w	0	; int_in_service

	dc.l	0

	dc.l	0	; mros_mem_1
	dc.l	0	; mros_mem_2

	dc.l	0

	dc.l	0	; mros_get_byte
	dc.l	0	; mros_mem_struct



	.BSS

U1952:				; BSS is possibly unused.
	ds.b	$00004000



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

	; mros_mem_struct:
mros_mem_struct_ptr2	equ	$04	; Longword, pointer to another instance of other_struct.
mros_mem_struct_ptr	equ	$08	; Longword, pointer to other_struct.

	; mros_other_struct
mros_other_struct_val	equ	$1c	; Word.

	; Struct passed into driver_write:
driver_write_portnum	equ	$3A	; Word, port number 0-7.




	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ST register definitions.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int_vec_mfp0			equ	$100
ym_base				equ	$ffff8800
mfp_gpio_reg			equ	$fffffa01
active_edge_reg			equ	$fffffa03
interrupt_enable_reg		equ	$fffffa09
interrupt_pending_reg		equ	$fffffa0d
interrupt_in_service_reg	equ	$fffffa11
interrupt_mask_reg		equ	$fffffa15