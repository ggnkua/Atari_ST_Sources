*-------------------------------------------------------------------------------
* TestCPU: Testet die CPU.
* <--- d0.b = erkannte CPU (0=MC68000, ..., 4=MC68040)
*
* TestFPU: Testet die FPU.
* <--- d0.b: -1 = FPU vorhanden
*			  0 = FPU nicht vorhanden
* <--- d1.b: -1 = Linef vorhanden
*			  0 = Linef nicht vorhanden
*
* FlushCache: l”scht den/die Caches (MC68020/30/40)
*-------------------------------------------------------------------------------

		.EXPORT		TestCPU,TestFPU,FlushCache

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.TEXT
TestCPU:		move.w		sr,-(sp)
				ori.w		#$700,sr
				movem.l		d1-a6,-(sp)

				moveq		#0,d7					; MC68000
				move.l		$10.w,d1
				move.l		#.CPU_ILLEGAL,$10.w
				move		ccr,d0
				move.l		d1,$10.w

				moveq		#1,d7					; MC68010
				lea			.jump-2(pc),a0
				moveq		#2,d0
				jmp			(a0,d0.w*2)
.jump:		 	bra.s		.CPU_ERKANNT

				moveq		#4,d7					; MC68040
				move.l		$2c.w,d1
				move.l		#.CPU_LINEF,$2C.w
				cinva		bc
				move.l		d1,$2c.w
				bra.s		.CPU_ERKANNT

.NO_M68040:		movec		cacr,d0					; cacr lesen
				move.l		d0,d1
				bset		#13,d1					; Bit 13 setzen
				movec		d1,cacr					; cacr schreiben
				movec		cacr,d1					; cacr lesen
				movec		d0,cacr					; cacr restaurieren
				moveq		#2,d7					; MC68020
				tst.w		d1						; Bit 13 gesetzt?
				beq.s		.CPU_ERKANNT
				moveq		#3,d7					; sonst MC68030

.CPU_ERKANNT:	move.b		d7,d0
				movem.l		(sp)+,d1-a6
				move.w		(sp)+,sr
				rts

*---------------

.CPU_ILLEGAL:	move.l		d1,$10.w
				move.l		#.CPU_ERKANNT,2(sp)
				rte

.CPU_LINEF:		move.l		d1,$2c.w
				move.l		#.NO_M68040,2(sp)
				rte

*-------------------------------------------------------------------------------

TestFPU:		movem.l		d2-a6,-(sp)
				moveq		#0,d0					; FPU nicht vorhanden
				moveq		#0,d1					; LINEF nicht vorhanden

				pea			.cont(pc)				; Test MC68881/STE
				jsr			TestBusOn
				move.w		FPSTAT.w,d0				; FPU Register vorhanden?
				jsr			TestBusOff
				addq.w		#4,sp
				moveq		#-1,d0					; FPU vorhanden

.cont:			movea.l		$2c.w,a0				; Test MC68882/TT
				move.l		#.no_linef,$2c.w
				fnop
				move.l		a0,$2c.w
				moveq		#-1,d0					; FPU vorhanden
				moveq		#-1,d1					; LINEF vorhanden

.no_FPU:		movem.l		(sp)+,d2-a6
				rts

*---------------

.no_linef:		move.l		a0,$2c.w
				move.l		#.no_FPU,2(sp)
				rte

*-------------------------------------------------------------------------------

FlushCache:		movem.l		d0-d1,-(sp)
				bsr			TestCPU
				move.b		d0,d1			; MC68000?
				beq.s		.ende
				cmpi.b		#1,d1			; MC68010?
				beq.s		.ende
				cmpi.b		#4,d1			; MC68040
				beq.s		.cinv
				dc.w		$4e7a,$0002		; MOVEC CACR,D0
				bset		#3,d0
				cmpi.b		#2,d1			; MC68020?
				beq.s		.mc68020
				bset		#11,d0
.mc68020:		dc.w		$4e7b,$0002		; MOVEC D0,CACR
				bra.s		.ende
.cinv:			dc.w		$f498			; CINVA IC
				dc.w		$f478			; CPUSHA DC
.ende:			movem.l		(sp)+,d0-d1
				rts
