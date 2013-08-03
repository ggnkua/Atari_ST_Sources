*************************************************************************
*									*
*				TRANFM.S				*
*									*
*************************************************************************
*************************************************************************
*									*
*	TRANSFORM FORM							*
*									*
*		This function transforms a raster area from standard	*
*	format to device-specific format or from device-specific to	*
*	standard format. The operation is a toggle, changing the 	*
*	current state. 							*
*		The number of planes specified in the source MFDB	*
*	determines the number of planes transformed. The source 	*
*	format flag is toggled and placed in the destination. The 	*
*	user is required to ensure that the other parameters in the	*
*	destination MFDB are correct.					*
*									*
*************************************************************************
*									*
*	C BINDING							*
*									*
*	Procedure Name	vr_trnfm( handle, psrcMFDB, pdesMFDB )		*
*									*
*	Data Types	WORD vr_trnfm();				*
*			WORD handle;					*
*			WORD *psrcMFDB;					*
*			WORD *pdesMFDB;					*
*									*
*	Input Arguments handle = contrl[6]				*
*			psrcMFDB = contrl[7-8]				*
*			pdesMFDB = contrl[9-10]				*
*									*
*************************************************************************

*****************
*  Equates	*
*****************
v_pl_dspl	.equ	$10000		;# of bytes between video planes
rev_vid		.equ	1		;for selecting reverse video transform
*
*  MEMORY FORM DEFINITION BLOCK OFFSETS
*
MF_BAS_AD	.equ	0        	;memory form base address
*                                       ;0 = physical device
MF_WDTH_PIX	.equ	4        	;form width in pixels 
MF_HGHT_PIX	.equ	6          	;form height in pixels
MF_WRD_WDTH	.equ	8       	;form width in words
MF_FORMAT	.equ	10	        ;form format flag
*                                       ;0 = device specific, 1 = standard
MF_PLANES	.equ	12	        ;number of memory planes
*
*  CONTRL ARRAY OFFSETS
*
C_S_MFDB	.equ	14	        ;pointer to source MFDB
C_D_MFDB	.equ	18        	;pointer to destination MFDB

*************************
*  Global Declarations	*
*************************

		.globl	_TRAN_FM	;TRANSFORFM FORM entry point

*************************
*  Global references	*
*************************

		.globl	_CONTRL		;CONTRL array address
		.globl	_v_bas_ad	;address of first plane of video screen
		.globl	_v_lin_wr	;# of words in a screen raster line
		.globl	_v_planes	;number of video screen planes
		.globl	_DEV_TAB	;DEVICE TABLE[1] = y resolution - 1	
		.text

*************************************************************************
*  Registers used  -  D0/D7, A0/A3                              	*
*									*
*************************************************************************
*
*  Get source and destination MFDB pointers from the user CONTROL array
*
_TRAN_FM:
	movem.l	d4-d7,-(sp)		;save 'C' registers
	movea.l	_CONTRL,a0		;get CONTROL array address
	move.l	C_S_MFDB(a0),d0		;get source MFDB address
	bmi.w	exit			;for an invalid address
	moveq.l	#-1,d1			;get mask of all ones
	andi.b	#$fe,d1			;clear least significant bit of mask
	and.b	d1,d0			;force source ptr. even word alignment
	movea.l	d0,a1			;source MFDB pointer
	move.l	C_D_MFDB(a0),d0		;get destination MFDB address
	bmi.w	exit			;for an invalid address
	and.b	d1,d0			;force dest. ptr. even word alignment
	movea.l	d0,a2			;destination MFDB pointer
*
*  Determine if source is a physical device or a raster area
*
	move.l	MF_BAS_AD(a1),d0	;get source form starting address
	bmi.w	exit			;for an invalid address
	and.l	d1,d0			;force source addr. even word alignment
	beq.b	s_physcl_dev		;for a physical device
*
*  Source is device independent( raster area ).
*
	move.w	MF_PLANES(a1),d2	;get # of source planes
	ble.w	exit			;for an invalid # of planes
	move.w	MF_HGHT_PIX(a1),d3	;get source form height in pixels
	ble.w	exit			;for an invalid form height
	move.w	MF_WRD_WDTH(a1),d4	;get source form width in words
	ble.w	exit			;for an invalid form width
	clr.l	d5			;indicate consequetive planes
	movea.l	d0,a0			;source form starting address
	bra.b	dest_form		;get destination form parameters
*
*  Source is device dependent( physical device ).
*
s_physcl_dev:
 	movea.l	_v_bas_ad,a0		;get screen starting address
	move.w	_v_planes,d2		;get # of video planes
	move.w	_v_lin_wr,d3		;get # of bytes in raster line
	lsr.w	#1,d3			;get # of words in raster line
	move.w	_DEV_TAB+2,d4		;get # of raster lines per plane - 1
	addq.w	#1,d4			;get # of raster lines per plane
	move.l	#v_pl_dspl,d5		;get # of bytes between video planes
*
*  Determine if destination is a physical device or a raster area
*
dest_form:
	move.l	MF_BAS_AD(a2),d0	;get destination form starting addr.
	bmi.w	exit			;for an invalid destination address
	and.l	d1,d0			;force dest. addr. even word alignment
	beq.b	d_physcl_dev		;for a physical device
*
*  Destination is device independent( raster area ).
*
	movea.l	d0,a3			;get destination starting address
	clr.l	d6			;indicate consequetive planes
	bra.b	plane_len		;calculate words per source plane
*
*  Destination is device dependent( physical device ).
*
d_physcl_dev:
	movea.l	_v_bas_ad,a3		;get screen starting adress
	move.l	#v_pl_dspl,d6		;get # of bytes between video planes
*
*  Calculate the size of the source plane in words
*
plane_len:
	mulu	d3,d4			;get # of words per source plane
*
*  Set the destination MFDB format flag to the opposite of the source
*  MFDB format flag.
*
	tst.w	MF_FORMAT(a1)		;source format flag zero or one?
	bne.b	clr_flag		;for source format flag = 1
	move.w	#1,MF_FORMAT(a2)	;set dest. format flag to one
	bra.b	tran_type		;determine transformation type
clr_flag:
	clr.w	MF_FORMAT(a2)		;set dest. format flag to zero
*
*  Determine if transformation is completely overlapped( in place ) or
*  completely non-overlapped( out of place ).
*
tran_type:
	move.l	d6,d3			;save # of bytes between dest. planes
	subq.w	#1,d2			;adjust # of planes to transform
	subq.w	#1,d4			;adjust # of words per source plane
	move.w	d4,d0			;save # of words per source plane
	cmpa.l	a0,a3			;source address = dest. address?
ifne rev_vid
	beq.b	exit			;for completely overlapped transform
endc
ifeq rev_vid
	beq.b	in_place		;for completely overlapped transform
endc
*
*  Transformation is completely non-overlapped
*
out_of_place:
	move.l	a0,d6			;save source starting address
	move.l	a3,d7			;save destination starting address
	bra.b	out_loop		;transform first plane
out_plane:
	add.l	d5,d6			;advance to next source plane
	add.l	d3,d7			;advance to next dest. plane
	movea.l	d6,a0			;address of next source plane
	movea.l	d7,a3			;address of next dest. plane
	move.w	d0,d4			;# of words to transform
ifne rev_vid
out_loop:
	move.w	(a0)+,(a3)+		;word of source written to destination
endc
ifeq rev_vid
out_loop:
	move.w	(a0)+,d1		;word of source needs to be inverted
	not.w	d1			;invert source word
	move.w	d1,(a3)+		;write inverted source to destination
endc
	dbra	d4,out_loop		;next word of source
	dbra	d2,out_plane		;transform next plane of source
	bra.b	exit			;all through with transformation
*
*  Transformation is completely overlapped
*
ifeq rev_vid
in_place:
	move.l	a0,d6			;save source starting address
	bra.b	in_loop 		;transform first plane
in_plane:
	add.l	d5,d6			;advance to next source plane
	movea.l	d6,a0			;address of next source plane
	move.w	d0,d4			;# of words to transform
in_loop:
	not.w	(a0)+   		;word of source written to destination
	dbra	d4,in_loop		;next word of source
	dbra	d2,in_plane		;transform next plane of source
endc
*					;all through with transformation
*
exit:
	movem.l	(sp)+,d4-d7		;restore 'C' registers
	rts				;return to 'C' calling procedure
	.end
