*****************************************
*					*
*  a program to change key entries in	*
*    the BIOS key translation tables	*
*     by Andy Beveridge  14/1/1986	*
*					*
*****************************************
*					*
* This version has been fixed so that	*
* it works with TOS in ROM as well !!!	*
*	    17th feb 1986		*
*					*
*****************************************

esc		equ	$1b		;ascii code for <escape>

cconws		equ	$09		;GEMDOS code for write string
ptermres	equ	$31		;GEMDOS code for ptermres()
keytbl		equ	16		;XBIOS code for keytbl()
gosuper		equ	38		;XBIOS code for supexec()

conterm		equ	$484		;console flags

illegal		macro
		dc.w	$4afc		;illegal opcode
		endm

		text

tstart		pea	initstr		;point to console init string
		move.w	#cconws,-(sp)	;push code for cconws()
		trap	#1		;call GEMDOS
		addq.l	#6,sp		;tidy up the stack

		pea	keycl
		pea	keyshift
		pea	keytran
		move.w	#keytbl,-(sp)	;keytbl() code onto stack
		trap	#14		;XBIOS
		lea	14(sp),sp	;restore stack pointer

		pea	klikoff
		move.w	#gosuper,-(sp)
		trap	#14
		addq.l	#6,sp

finished	move.l	#tend-tstart+$100,-(sp)
		move.w	#ptermres,-(sp)
		trap	#1		;GEMDOS

		illegal

klikoff		move.b	#2,conterm
		rts

initstr		dc.b	esc,'b','0'	;foreground colour 0 (white)
		dc.b	esc,'c','1'	;background colour 1 (black)
		dc.b	esc,'v'		;set cursor to wrap at eol
		dc.b	esc,'E'		;clear screen & home cursor
		dc.w	0		;null terminator (& keep alignment)

keytran		dc.b	$00,$1b,'1','2','3','4','5','6'
		dc.b	'7','8','9','0','-','=',$08,$09
		dc.b	'q','w','e','r','t','y','u','i'
		dc.b	'o','p','[',']',$0d,$00,'a','s'
		dc.b	'd','f','g','h','j','k','l',';'
		dc.b	$27,'`',$00,'#','z','x','c','v'
		dc.b	'b','n','m',',','.','/',$00,$00
		dc.b	$00,' ',$00,$00,$00,$00,$00,$00

		dc.b	$00,$00,$00,$00,$00,$00,$00,$05
		dc.b	$10,$00,'-',$02,$00,$06,'+',$00
		dc.b	$0e,$00,$01,$04,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	'\',$19,$0b,'(',')','/','*','7'
		dc.b	'8','9','4','5','6','1','2','3'
		dc.b	'0','.',$0d,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keyshift	dc.b	$00,$1b,'!',$22,$9c,'$','%','^'
		dc.b	'&','*','(',')','_','+',$08,$09
		dc.b	'Q','W','E','R','T','Y','U','I'
		dc.b	'O','P','{','}',$0D,$00,'A','S'
		dc.b	'D','F','G','H','J','K','L',':'
		dc.b	'@',$ff,$00,'~','Z','X','C','V'
		dc.b	'B','N','M','<','>','?',$00,$00
		dc.b	$00,' ',$00,$00,$00,$00,$00,$00

		dc.b	$00,$00,$00,$00,$00,$00,$00,$37
		dc.b	$38,$00,'-',$34,$00,$36,'+',$00
		dc.b	$32,$00,$30,$7f,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	'|',$00,$00,'(',')','/','*','7'
		dc.b	'8','9','4','5','6','1','2','3'
		dc.b	'0','.',$0d,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00

keycl		dc.b	$00,$1b,'1','2','3','4','5','6'
		dc.b	'7','8','9','0','-','=',$08,$09
		dc.b	'Q','W','E','R','T','Y','U','I'
		dc.b	'O','P','[',']',$0d,$00,'A','S'
		dc.b	'D','F','G','H','J','K','L',';'
		dc.b	$27,'`',$00,'#','Z','X','C','V'
		dc.b	'B','N','M',',','.','/',$00,$00
		dc.b	$00,' ',$00,$00,$00,$00,$00,$00

		dc.b	$00,$00,$00,$00,$00,$00,$00,$05
		dc.b	$10,$00,'-',$02,$00,$06,'+',$00
		dc.b	$0e,$00,$01,$04,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00
		dc.b	'\',$19,$0b,'(',')','/','*','7'
		dc.b	'8','9','4','5','6','1','2','3'
		dc.b	'0','.',$0d,$00,$00,$00,$00,$00
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00

tend		dc.w	0

		end
