* traps.s / 19.3.91 / MATRIX / WA


		.export	inst_buserr,remove_buserr
		.export	berr_flag
		.export	rd_byte,wr_byte

		.include	"gemdos.i"

		.super
		
;------------------------------------ get_excv_base -----------------
;	extern PROC **get_excv_base ( void ) ;

		.export get_excv_base
get_excv_base:	tst		_longframe
				bne		gex_680X0
				
	gex_68000:	sub.l	a0,a0
				rts
				.mc68020
	gex_680X0:	movec	vbr,a0
				.mc68000
				rts


;------------------------------------------------ enable_irq ------------
; void enable_irq ( unsigned oldsr ) ;

				.export	enable_irq
enable_irq:		move	d0,sr
				rts

;------------------------------------------------ disable_irq ------------
; unsigned disable_irq ( void ) ;

				.export	disable_irq
disable_irq:	move	sr,d0
				ori		#$0700,sr
				rts


BUSERRVEC		= 2

*--------------------------------- wr_byte -----------
wr_byte:	move.b	d0,(a0)
			nop		; buserr problems ???
			nop
			rts
				
*--------------------------------- rd_byte -----------
rd_byte:	clr.l	d0
			move.b	(a0),d0
			nop		; buserr problems ???
			nop
			rts
				
*--------------------------------- break_point -----------
		.export	break_point
break_point:	illegal
				rts
				
*--------------------------------- cpu_reset -----------
		.export	cpu_reset
cpu_reset:		reset
				bra		cpu_reset
				
				
*--------------------------------- buserror --------------
*		bus error routine
*

	    dc.l    "XBRA"		; XBRA-structure
      	dc.l    "M_BE"
oldvec: dc.l    -1

buserror:
		move	#TRUE,berr_flag
		
		tst		_longframe
		bne		be_680X0
  be_68000:
		addq.l	#$8,sp		; Forget 68000 diagnostic information
		rte

  be_680X0:
		bclr	#0,10(sp)	; clear DF in SSW ( fault/rerun data cycle )
		rte

		.user


*----------------------------------- inst_buserr ---------
*		install local bus error routine	
*
inst_buserr:
		movem.l	d0-d2/a0-a2,-(sp)

		move	#FALSE,berr_flag
		
		pea		buserror
		move	#BUSERRVEC,-(sp)
		call_bios	setexc
		addq.l	#8,sp
		move.l	d0,oldvec
		movem.l	(sp)+,d0-d2/a0-a2
		rts
		




*----------------------------------- remove_buserr ---------
*		remove local bus error routine
*
remove_buserr:
		movem.l	d0-d2/a0-a2,-(sp)
		move.l	oldvec,-(sp)
		move	#BUSERRVEC,-(sp)
		call_bios	setexc
		addq.l	#8,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;......... CPU cache enable .............................

			.super
			.mc68030

ED	.equ	(1<<8)
EI	.equ	(1<<0)
EDI	.equ	ED|EI

			.xdef	cache0
cache0:		tst		_longframe
			beq		c0_exit
			
			movec	cacr,d0
			andi.l	#!EDI,d0
			movec	d0,cacr
  c0_exit:	rts

			.xdef	cache1
cache1:		tst		_longframe
			beq		c1_exit
			
			movec	cacr,d0
			ori.l	#EDI,d0
			movec	d0,cacr
  c1_exit:	rts
			


		.bss
berr_flag:	ds		1

