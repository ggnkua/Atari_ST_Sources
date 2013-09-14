*            
* big.s:       written by Slavik Lozben
*              switch over to the big monitor

GEMDOS		=	$01
XBIOS		=	$0E
CCONOUT		=	$02
BAS_AD		=	$c00000
SETSCREEN	=	$05
LINEA_INIT	=	$A000		; get line A pointers



*
* device specific settings
*

HREZ		=	1280		; horizontal rez
VREZ		=	960		; vert rez
BYTES_LN	=	160		; bytes per line
LINE_WR		= 	160		; line wrap
PLANES		=	1		; number of planes






_startup:	move.w	#-1,-(sp)
		move.l	#-1,-(sp)
		move.l	#BAS_AD,-(sp)
		move.w	#SETSCREEN,-(sp)
		trap	#XBIOS
		add.l	#12,sp

		dc.w	LINEA_INIT	; get line A pointers

*   Set the proper font data adr and offset table adr

		movea.l	8(a1),a1
		move.l	76(a1),-22(a0)	; v_fnt_ad <- 8x16 font data adr
		move.w	38(a1),-18(a0)	; init font end ADE.
		move.w	36(a1),-16(a0)	; init font start ADE.
		move.w	80(a1),-14(a0)	; init font wrap.
		move.l	72(a1),-10(a0)	; v_off_ad <- 8x16 offset table addr

		moveq.l	#0,d2		; clear the hi word of dividend
		move.l	d2,d3		; clear the hi word of dividend
		move.w	#HREZ-1,d2	; d2 <- horizontal rez - 1
		move.w	d2,-692(a0)	; set DEV_TAB[0] (x max)
		move.w	#VREZ-1,d3	; d3 <- verticall rez - 1
		move.w	d3,-690(a0)	; set DEV_TAB[1] (y max)
		addq.w	#1,d2		; 1 origin
		addq.w	#1,d3		; 1 origin
		move.w	d2,-12(a0)	; hz resolution
		move.w	d3,-4(a0)	; vert resolution

		move.w	82(a1),d0	; fetch form height.
		move.w	d0,-46(a0)	; init cell height.
		move.w	#LINE_WR,d1	; fetch bytes/line.
		move.w	d1,2(a0)	; set v_lin_wr
		mulu	d0,d1
		move.w	d1,-40(a0)	; byte disp to next vert alpha cell
		divu	d0,d3		; vertical res/cell height.
		subq.w	#1,d3		; 0 origin.
		move.w	d3,-42(a0)	; max alpha cell y
		divu	52(a1),d2	; horizontal res/cell width.
		subq.w	#1,d2		; 0 origin.
		move.w	d2,-44(a0)	; max alpha cell X

		move.l	#BAS_AD,-34(a0) ; curr alpha cursor address
		move.w	#0,-30(a0)	; byte offset from screen base to 1st cell
		move.l	#0,-28(a0)	; curr cell X,Y pos
		move.w	#BYTES_LN,-2(a0); set bytes per line
		move.w	#PLANES,(a0)	; set number of planes


*   Clear big screen

		move.w	#27,-(sp)	; push escape character
		move.w	#CCONOUT,-(sp)
		trap	#GEMDOS
		addq.l	#4,sp

		move.w	#69,-(sp)	; push "E" character
		move.w	#CCONOUT,-(sp)
		trap	#GEMDOS
		addq.l	#4,sp

		clr.w	-(sp)		; terminate
		trap	#GEMDOS
		illegal
	.end
