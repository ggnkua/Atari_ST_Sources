; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - Foxenstein -
;    a NoCrew production MCMXCV
;
;    (c) Copyright NoCrew 1995
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DSP module.

DMA_MEM_SIZE	equ	32768

	include	dsp_io.equ
;	include	macrodsp.s
;	include	macrosnd.s
	include	falcmacr.s

	section	text

init_DSP	move.l	#DMA_mem,d0
	move.l	d0,DMA_logic
	add.l	#DMA_MEM_SIZE,d0
	move.l	d0,DMA_physic

	Dsp_Lock
	locksnd
	sndstatus	#1
	Dsp_FlushSubroutines
	buffoper	#%0000		* flush FIFOs
	dsptristate	#1,#1
	Dsp_RequestUniqueAbility
	move.w	d0,DSP_abil

	devconnect	#1,#%0001,#0,#1,#0	* DSPXMIT->DMAREC
	Dsp_ExecProg #dsp_beg,#(dsp_end-dsp_beg)/3,DSP_abil

	; Launch
	bsr.w	CPU_sync
	* Upload sinus table
	Dsp_BlkUnpacked #DSP_sin,#1024,#0,#0
	* Upload blitter table
	move.l	#960,DSP_command
	Dsp_BlkUnpacked #DSP_command,#1,#0,#0
	moveq	#0,d2
	move.w	#960-1,d0
.1	move.l	#960,d3
	tst.w	d2
	beq.s	.nope
	divu.w	d2,d3
	subq.w	#1,d3
	mulu.w	#2*80,d3
	bra.s	.resume
.nope	move.w	#0,d3
.resume	ext.l	d3
	move.l	d3,DSP_command
	movem.l	d0-d7/a0-a6,-(sp)
	Dsp_BlkUnpacked #DSP_command,#1,#0,#0
	movem.l	(sp)+,d0-d7/a0-a6
	addq.w	#1,d2
	dbra	d0,.1
	moveq	#0,d0

	Dsp_BlkUnpacked #screen,#4,#0,#0
	rts

exit_DSP	buffoper	#%0000		* flush FIFOs
	sndstatus	#1
	Dsp_Unlock
	rts

DSP_key	move.l	#DSP_KEY,DSP_command+0
	move.l	d0,DSP_command+4
	Dsp_BlkUnpacked #DSP_command,#2,#0,#0
	rts

DSP_screen	move.l	#DSP_SCREEN,DSP_command+0
	move.l	(a0)+,DSP_command+4
	move.l	(a0)+,DSP_command+8
	move.l	(a0)+,DSP_command+12
	move.l	(a0)+,DSP_command+16
	Dsp_BlkUnpacked #DSP_command,#5,#0,#0
	rts

CPU_sync	Dsp_BlkUnpacked #0,#0,#DSP_command,#1
	cmp.l	#CPU_SYNC,DSP_command
	bne.s	CPU_sync
	rts

DMA_flipp	bsr	CPU_sync

	move.l	DMA_logic,d0
	move.l	DMA_physic,DMA_logic
	move.l	d0,DMA_physic

	buffoper	#%0000		* flush FIFOs
	lea	([DMA_logic],0*DMA_MEM_SIZE.l),a0
	lea	([DMA_logic],1*DMA_MEM_SIZE.l),a1
	setbuffer	#1,a0,a1
	buffoper	#%0100		* activate DMA

	move.l	#DSP_SYNC,DSP_command
	Dsp_BlkUnpacked #DSP_command,#1,#0,#0
	rts

	section	data
dsp_beg
	incbin	foxen.dsp	; DSP binary file
dsp_end
DSP_sin	incbin	make_sin.gfa\1024x24.sin

	section	bss
DSP_abil	ds.w	1
LOD_mem	ds.b	96*1024

DSP_command	ds.l	256

DMA_logic	ds.l	1
DMA_physic	ds.l	1
DMA_mem	ds.b	DMA_MEM_SIZE
	ds.b	DMA_MEM_SIZE
