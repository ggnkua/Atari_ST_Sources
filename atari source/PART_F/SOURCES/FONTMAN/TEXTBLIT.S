;-----------------------------------------------------------------------------
;
;	textblit.s
;
;	Print a string with TextBlt
;
;	27dec89	moj	Derived from TEXTBLIT.S
;	09jan90	moj	Mangled into two separate routines:
;			start, which stores pointers, saves registers, etc.
;			brit, which actually prints the string
;	11jan90 ks	Hacked to call text blit directly, names changed
;-----------------------------------------------------------------------------

	.globl	_text_init
	.globl	_linea_text

	.text
	.even

;--------------------------------
; Equates

INIT		equ	$A000	; Line A Init
TEXTBLT		equ	$A008	; TextBlt

first_ade	equ	36	; header offset to value of first displayable
				; character in font

off_table	equ	72	; header offset to pointer to offset table
data_table	equ	76	; header offset to pointer to font data
form_width	equ	80	; header offset to total width of font
form_height	equ	82	; header offset to total height of font

letter_a	equ	65	; ASCII for capital "A"

;--------------------------------
; Assorted Line-A Equates

WMODE	equ	36
CLIP	equ	54
SCALDIR	equ	68
MONO	equ	70
SRCX	equ	72
SRCY	equ	74
DSTX	equ	76
DSTY	equ	78
DELX	equ	80
DELY	equ	82
FBASE	equ	84
FWIDTH	equ	88
STYLE	equ	90
SCALE	equ	102
TEXTFG	equ	106
SCRTCHP	equ	108
SCRPT2	equ	112
TEXTBG	equ	114

;--------------------------------
; THE DREADED REGISTER MAP
;
; a2 -> font offset table
; a3 -> Line-A Variable Structure
; a4 -> pointers to system fonts/particular system font
; a5 -> string to be printed
;
;-------------------------------------------------------------------------------
;
; _text_init:	Initialize Line-A, store pointers, save registers.
;		Pass in:  Nothing.
;

;--------------------------------
; Line-A Init, store pointers,
; easy set-up stuff

_text_init:	
	link	a6, #0
	movem.l	d1-d7/a1-a5, -(sp)

	dc.w	INIT			; Line-A Init
	move.l	a0, _base		; store Line-A variables base pointer

	move.l	-460(a0),a1			; Address of system font

	move.l	a1, _font		; store font header pointer
	move.l	32(a2), txtblt		; pointer to text blit

	move.l	data_table(a1),FBASE(a0); Address of font data
	move.w	form_width(a1),FWIDTH(a0); total width of font form
	
	clr.w	SRCY(a0)		; start at top of char
	move.w	form_height(a1),DELY(a0); height of font
	move.w	#15,TEXTFG(a0)	; Foreground color
	move.w	#0,TEXTBG(a0)	; Background color

	clr.w	STYLE(a0)		; No styling
	clr.w	SCALE(a0)		; No scaling
	move.w	#1,MONO(a0)		; Monospaced font
	move.w	#8,DELX(a0)		; width of desired char
	clr.w	CLIP(a0)		; Clipping off

	movem.l	(sp)+, d1-d7/a1-a5
	unlk	a6

	rts				; Return

;---------------------------------------
; The BIG excitement:  PRINT THE STRING!
;
; XPOS, YPOS, STRING, WRITING MODE
;
	.even
_linea_text:
	link	a6, #0
	movem.l	d1-d7/a1-a5,-(sp)	; appease MWC
	move.l	_base,a3		; restore line-a base and font ptr

	move.l	8(a6),DSTX(a3)		; set up x and y coordinates
	move.l	12(a6),a5		; ...and pointer to string
	move.w	16(a6),WMODE(a3)	; Writing mode

	move.l	_font,a4
	move.l	off_table(a4),a2	; address of offset table

	clr.l	d0			; clear this just to be sure...
	move.b	(a5)+,d0

grab:
	sub.b	first_ade(a4),d0	; letter's offset in font
	lsl.b	#1,d0			; x2 for _word_ offset in
					; offset table
	move.w	(a2,d0),SRCX(a3)	; x of desired character

	move.l	a2, -(sp)
	move.l	a3, -(sp)
	move.l	a4, -(sp)
	movea.l	txtblt, a0
	jsr	(a0)
	move.l	(sp)+, a4
	move.l	(sp)+, a3
	move.l	(sp)+, a2

	move.b	(a5)+,d0
	bne.b	grab

return:	
	movem.l	(sp)+,d1-d7/a1-a5		; restore registers
	unlk	a6
	rts				; return (duh)


	.data

_base:	.dc.l	1		; -> base of Line-A variables
_font:	.dc.l	1		; -> fonts
txtblt:	.dc.l	1
	
