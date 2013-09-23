
	section	text

;-----------------------------------------------------------------------
;-- FPU control register -----------------------------------------------
;-----------------------------------------------------------------------

; set fpu to round all floats->ints down
fpu_rnd_floor:	macro
		fmove.l	#16*1+32*0,fpcr
		endm

; set fpu to round all floats->ints up
fpu_rnd_ceil:	macro
		fmove.l	#16*1+32*1,fpcr
		endm

;-----------------------------------------------------------------------
;--- CPU control register ----------------------------------------------
;-----------------------------------------------------------------------

;
; In all macros d0 is trashed !!
;

;--- Data cache --------------------------------------------------------

cpu_data_burst:	macro
		movec	cacr,d0
		bset	#12,d0
		movec	d0,cacr
		endm

cpu_data_no_burst:	macro
		movec	cacr,d0
		bclr	#12,d0
		movec	d0,cacr
		endm

cpu_data_enable:	macro
		movec	cacr,d0
		bset	#8,d0
		movec	d0,cacr
		endm

cpu_data_disable:	macro
		movec	cacr,d0
		bclr	#8,d0
		movec	d0,cacr
		endm

cpu_data_freeze:	macro
		movec	cacr,d0
		bset	#9,d0
		movec	d0,cacr
		endm

cpu_data_no_freeze:	macro
		movec	cacr,d0
		bclr	#9,d0
		movec	d0,cacr
		endm

cpu_data_clear:	macro
		movec	cacr,d0
		bset	#11,d0
		movec	d0,cacr
		endm

;--- Instruction cache -------------------------------------------------

cpu_instr_enable:	macro
		movec	cacr,d0
		bset	#0,d0
		movec	d0,cacr
		endm

cpu_instr_disable:	macro
		movec	cacr,d0
		bclr	#0,d0
		movec	d0,cacr
		endm

cpu_instr_burst:	macro
		movec	cacr,d0
		bset	#4,d0
		movec	d0,cacr
		endm

cpu_instr_no_burst:	macro
		movec	cacr,d0
		bclr	#4,d0
		movec	d0,cacr
		endm

cpu_instr_freeze:	macro
		movec	cacr,d0
		bset	#1,d0
		movec	d0,cacr
		endm

cpu_instr_no_freeze:	macro
		movec	cacr,d0
		bclr	#1,d0
		movec	d0,cacr
		endm

cpu_instr_clear:	macro
		movec	cacr,d0
		bset	#3,d0
		movec	d0,cacr
		endm
