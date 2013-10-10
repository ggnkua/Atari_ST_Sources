
.text
.include atari

;
; DSP Host interface constants
;
ICR	=	$ffffa200		; Interrupt Control Register
CVR	=	$ffffa201		; Command Vector Register
ISR	=	$ffffa202		; Interrupt Status Register
IVR	=	$ffffa203		; Interrupt Vector Register
RXH	=	$ffffa205		; Receive byte High
RXM	=	$ffffa206		; Receive byte Mid
RXL	=	$ffffa207		; Receive byte Low
TXH	=	$ffffa205		; Transmit byte High
TXM	=	$ffffa206		; Transmit byte Mid
TXL	=	$ffffa207		; Transmit byte Low

PSGSEL  = 	$ffff8800		; PSG select register
PSGWR	=	$ffff8802		; PSG write register

HZ200	=	$4ba			; 200 hz timer

VECTBASE = 	$17			; Beginning DSP vector number
					; used by subroutines
XYSIZE	=	$4000			; Size of X or Y memory space
					; Subtract from dspcurtop to get
					; top of X memory
YTOP	=	$3eff			; Top of usable y memory space

DSP_VECT_BASE_ADDR	= $2e		; Beginning DSP vector address
VECTSIZE =	16			; Number of DSP words in vector table

TOS_TABLE_SIZE = $18			; Number of bytes in our HC vector
					; table + Header info
VECTOFFSET =	120			; Offset to the beginning of the 
					; vector table

VECTCOPYSIZE = 72			; Amount to copy over from data to
					; bss for romming

; VARIABLES

.globl	_dsp_lockflag			; Dsp semaphore
.globl	_vect_table			; Table of DSP HC interrupt vectors
.globl	_dspcurtop			; Top of usable program area/bottom
					; of subroutine area
.globl	_progtop			; Top of reserved program area
.globl	_unique_ability			; Unique Ability flag for DSP progs 
.globl	_progability			; Ability of the current DSP program
					; 0 if no program installed
.globl	_subarray

.globl	_vector_copy			; copy data to bss

; SUBROUTINES
.globl	_DspExBoot
.globl	_Send_Load_Info
.globl	_Dsp_Move_Block
.globl	_Dsp_Run_SubLoader
.globl	_DspRunSubroutine
.globl	_DspTriggerHC
.globl	_DspLock
.globl	_DspUnlock
.globl	_dsp_set_vector
.globl	_dsp_load_vectors
.globl	_DspAvailable
.globl	_DspReserve
.globl	_DspRequestUniqueAbility
.globl	_DspGetProgAbility
.globl	_DspInqSubrAbility
.globl	_dsp_send_vectors
.globl	_DspHf0
.globl	_DspHf1
.globl	_DspHf2
.globl	_DspHf3
.globl	_DspHStat

.text

;
;	Bootstrap the DSP and download a 512 word program into
;	DSP internal ram
;
_DspExBoot:
;
;	Reset DSP:	Bring up PSGWR bit 4
;			Wait awhile, bring it back down
;			Reset code from R. Stedmans diagnostic code
;
	move.w	sr,save_sr
	move.w	#$2700,sr

	move.b	#14,PSGSEL
	move.b	PSGSEL,d0
	andi.b	#$ef,d0
	move.b	d0,PSGWR
	ori.b	#$10,d0
	move.b	d0,PSGWR
	move.w	save_sr,sr

	move.l	HZ200,d0			; wait 2 timer ticks
	addq.l	#2,d0
.timloop:
	move.l	HZ200,d1
	cmp.l	d0,d1
	blt	.timloop

	move.w	sr,save_sr
	move.w	#$2700,sr

	move.b	#14,PSGSEL
	move.b	PSGSEL,d0

	andi.b	#$ef,d0
	move.b	d0,PSGWR
	move.w	save_sr,sr

	move.l	8(sp),d0
	move.l	#512,d1
	sub.l	d0,d1				; Leftover amount to send
	sub.l	#1,d0
	move.l	4(sp),a0
.loop1:
	move.b	(a0)+,TXH			; Transfer info to DSP
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop1
	move.l	d1,d1
	beq	.out
	sub.l	#1,d1
.loop2:
	move.b	#0,TXH				; Pad with 512 - size zeros
	move.b	#0,TXM
	move.b	#0,TXL
	dbra	d1,.loop2
.out:
	rts

;
;	Send location and size to the DSP process via the host port
;
_Send_Load_Info:
	move.b	5(sp),TXH		; Grab least sig 3 bytes of long 
	move.b	6(sp),TXM		; on the stack and send it to 
	move.b	7(sp),TXL		; the loader program (Location)
	move.b	9(sp),TXH		; Grab least sig 3 bytes of the
	move.b	10(sp),TXM		; next long word (Size)
	move.b	11(sp),TXL
	rts

;	Invoke the move block host command then pass the source address
;	destination address and size to the DSP.

_Dsp_Move_Block:
	move.b	#$96,CVR		; High bit set plus vector #$16
.loop1:
	btst.b	#7,CVR			; Wait for DSP to respond by 
	bne	.loop1			; clearing bit 7 of CVR
	move.b	5(sp),TXH		; Grab least sig 3 bytes of long 
	move.b	6(sp),TXM		; on the stack and send it to 
	move.b	7(sp),TXL		; the loader program (source)
	move.b	9(sp),TXH		; Grab least sig 3 bytes of the
	move.b	10(sp),TXM		; next long word (destination)
	move.b	11(sp),TXL
	move.b	13(sp),TXH		; (size)
	move.b	14(sp),TXM
	move.b	15(sp),TXL
	rts

;
;	Invoke Subroutine loader by triggering interrupt #$15
;
_Dsp_Run_SubLoader:
	move.b	#$95,CVR		; High bit set plus vector #$15
.loop1:
	btst.b	#7,CVR			; Wait for DSP to respond
	bne	.loop1
	rts

;
;	Download to the DSP, the current subroutine vector table
;
_dsp_load_vectors:
	move.b	#$95,CVR		; High bit set plus vector #$15
.loop1:					; Invoke DSP subroutine/memory loader
	btst.b	#7,CVR			; Wait for DSP to respond
	bne	.loop1
	move.b	#0,TXH
	move.b	#0,TXM
	move.b	#DSP_VECT_BASE_ADDR,TXL ; Send address of table to load in
	move.b	#0,TXH		
	move.b	#0,TXM
	move.l	#VECTSIZE,d0		; Send size of table
	move.b	d0,TXL
	
	subq	#1,d0			; Set up for dbra
	lea	_vect_table,a0		; to copy vector table into DSP
.loop2:
	move.b	(a0)+,TXH		; Send over table
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL
	dbra	d0,.loop2
	rts

;
;	Trigger a host command corresponding to the given subroutine handle
;
_DspRunSubroutine:
	move.w 	4(sp),d0		; Grab the handle from the stack
	move.w	d0,d1
	cmp.b	#$17,d0			; Do range checking $17 < handle < 1e
	blt	.err_exit
	cmp.b	#$1e,d0
	bgt	.err_exit		; Handle represents vector number to 
;
;	If we've gotten this far, then send the subroutines address
;	to it via the host port before executing the subroutine.
;	The address should be waiting when the subroutine executes
;
	sub.w	#VECTBASE,d1
	muls	#6,d1			; Offset into table (2 DSP WORDS )
	add.w	#3,d1			; Skip JSR and go to address
	lea	_vect_table,a0
	add	d1,a0
	move.b	(a0)+,TXH		; Send address to dsp process
	move.b	(a0)+,TXM
	move.b	(a0)+,TXL

	ori.b	#$80,d0			; be ored in with high bit for DSP HC

	move.b	d0,CVR			; Tell DSP you want an interrupt

	move.w	#0,d0			; Successful launch of subroutine
	bra	.norm_exit

.err_exit:
	move.w	#$ffff,d0
.norm_exit:
	rts		

;
;	Invoke Host command based on the given vector
;	Note: For now allow all host commands to go through
;
_DspTriggerHC:
	move.w	4(sp),d0
	ori.b	#$80,d0
	move.b	d0,CVR
	rts

;
;	Invoke system semaphore to lock up the DSP
;
_DspLock:
	move.w	dsp_lockflag,d0		; Get the dsp semaphore
	bne	.exit1			; If not zero return busy value
	move.w	#$ffff,d1		; Mark semaphore as busy
	move.w	d1,dsp_lockflag		; and return not busy to user
.exit1:
	rts

;
;	Free the DSP for other processes
;
_DspUnlock:
	move.w	#0,dsp_lockflag		; Mark semaphore as not busy
	rts

;
;	Install a subroutine address into our local vector table
;
_dsp_set_vector:
	move.l	4(sp),d0
	move.l	#0,d1
	move.w	8(sp),d1
	sub.w	#VECTBASE,d1
	muls	#6,d1			; Offset into table (2 DSP WORDS )
	add.w	#4,d1			; Skip JSR and first byte of addr
	lea	_vect_table,a0
	add	d1,a0
	move.w	d0,(a0)+		; Moving word on possible byte 
	rts				; boundary... 68030 specific code

;
;	Return amount of free DSP ram in the system
;
_DspAvailable:
	move.l	4(sp),a0		; Address to put available x memory
	move.l	8(sp),a1		; Address to put available y memory
	move.l	#YTOP,(a1)
	move.l  _dspcurtop,d0		; Top of X memory = dspcurtop - 16K
	sub.l	#XYSIZE,d0
	move.l	d0,(a0)			
	rts

;
;	Reserve DSP memory from the system
;
_DspReserve:
	move.l	4(sp),d0		; Get requested amount of X memory
	add.l	#XYSIZE,d0		; Add 16K to check with top of P ram
	move.l	_dspcurtop,d1
	cmp.l	d1,d0			; If it goes into subroutine space
	bgt	.err_exit		; return an error value
	move.l	d0,_progtop		; else store new program top value
	move.l	8(sp),d0		; Get requested Y memory
	cmp.l	#YTOP,d0		; Cmp to top of Y mem (16K - 256)
	bgt	.err_exit		; Branch if error 
	move.w	#0,d0			; Return OK (Don't need to store..
	jmp	.norm_exit		; 	     reserved Y memory.
.err_exit:
	move.w	#$ffff,d0
.norm_exit:
	rts

;
;	Return a unique value to the calling process to be used to
;	identify their dsp processes.
;
_DspRequestUniqueAbility:
	move.w	_unique_ability,d0
	add.w	#1,d0
	move.w	d0,_unique_ability
	rts	

;
;	Return the ability of the current DSP program
;
_DspGetProgAbility:
	move.w	_progability,d0
	rts

;
;	Check to see if there is a DSP process which matches the requested
;	ability.
;
;	Subroutine Structure:
;				long 	location;
;				long 	size;
;				int	vector;
;				int	ability;
;
_DspInqSubrAbility:
	move.w	4(sp),d1		; Get requested ability
	lea	_subarray,a0		; Load up our subroutine structure
	move.l	#$16,d0			; Lowest vector/handle in table
.loop:
	addq	#1,d0
	cmp.w	10(a0),d1		; compare ability to first entry
	beq	.found			; bail if found with handle in d0
	lea	12(a0),a0		; Go to next array element
	cmp.l	#$1e,d0			; Are we at the end of the list?
	bne	.loop			; No, repeat above
	move.w	#0,d0			; Ability not found	
.found:	
	rts

;
;	Place our HC vector table into the applications program
;	This includes our 3 tos vectors and the 8 subroutine vectors
;	This is the last block of data sent to the load program routine
;	therefore tack on a $ffffff at the end to tell the loader to
;	stop loading and commence execution.
;
_dsp_send_vectors:
	lea	field_header,a1		; Get our own vector table
	move.l	#TOS_TABLE_SIZE,d0	; Get count
	subq	#1,d0
.waitsend:
.loop1:
	btst	#1,ISR				; Wait for DSP 
	beq	.waitsend
	move.b	(a1)+,TXH			; Transfer info to DSP
	move.b	(a1)+,TXM
	move.b	(a1)+,TXL
	dbra	d0,.loop1
	rts

;
;	Set or Read the value of HF0, bit 3 of the ICR
;	if parameter = ffff, return the value of the bit.
;	if parameter = 0, clear the bit
;	if parameter = 1, set the bit
;
_DspHf0:
	move.w	4(sp),d1
	cmp.w	#$ffff,d1
	beq	.inquire
	cmp.w	#1,d1
	bne	.chk_clr
	bset	#3,ICR
	bra	.done
.chk_clr:
	cmp.w	#0,d1
	bne	.done
	bclr	#3,ICR
	bra	.done
.inquire:
	move.w	#0,d0
	btst	#3,ICR
	beq	.done
	move.w	#1,d0
.done:
	rts


_DspHf1:
	move.w	4(sp),d1
	cmp.w	#$ffff,d1
	beq	.inquire
	cmp.w	#1,d1
	bne	.chk_clr
	bset	#4,ICR
	bra	.done
.chk_clr:
	cmp.w	#0,d1
	bne	.done
	bclr	#4,ICR
	bra	.done
.inquire:
	move.w	#0,d0
	btst	#4,ICR
	beq	.done
	move.w	#1,d0
.done:
	rts

_DspHf2:
	move.w	#0,d0
	btst	#3,ISR
	beq	.done
	move.w	#1,d0
.done:
	rts


_DspHf3:
	move.w	#0,d0
	btst	#4,ISR
	beq	.done
	move.w	#1,d0
.done:
	rts

_DspHStat:
	move.b	ISR,d0
	move.b	CVR,d1
	rts


_vector_copy:
	move.l	#VECTCOPYSIZE,d0
	lea	field_header,a0
	lea	vectdata,a1
	subq	#1,d0
.cpyloop:
	move.b	(a1)+,(a0)+
	dbra	d0,.cpyloop
	rts
	
.bss
dsp_lockflag:	.ds.w	1		; Semaphore for using DSP
save_sr:	.ds.w	1		; temp save sr (take this out later)

field_header:	.ds.b	9		; Program memory
					; Block location = p:$2a
					; Block size not including last header
_tos_vectors:	
		.ds.b	12
					; Subroutine loader (vector $15)

					; Block mover	    (vector $16)
_vect_table:	.ds.b	48		; Begin HC vector table (vector $17)
					; Address of vector goes here.
					; Consists of 0bf080 (DSP JSR)
					; and the addresses to be filled in
last_field:	.ds.b	3

.data
;
vectdata:
;field_header:
		.dc.b	$00,$00,$00	; Program memory
		.dc.b	$00,$00,$2a	; Block location = p:$2a
		.dc.b	$00,$00,$14	; Block size not including last header
;tos_vectors:
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$7e,$ef	; Subroutine loader (vector $15)
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$7e,$dc	; Block mover	    (vector $16)
;_vect_table:
		.dc.b	$0b,$f0,$80	; Begin HC vector table (vector $17)
		.dc.b	$00,$7f,$00	; Address of vector goes here.
		.dc.b	$0b,$f0,$80	; Consists of 0bf080 (DSP JSR)
		.dc.b	$00,$00,$00	; and the addresses to be filled in
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
		.dc.b	$0b,$f0,$80
		.dc.b	$00,$00,$00
;last_field:
		.dc.b	$00,$00,$03

.end
