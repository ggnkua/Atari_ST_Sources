*-------------------------------------------------------------------------------
* FRAME_LENGTH: Gibt die L„nge des Stackframes zurck, im Fehlerfall -1.
* ---> D0.w = Framenummer (0-15)
* <--- D0.w = Framel„nge oder Fehler
* ACHTUNG: beim 68000er wird 3 zurckgegeben!
*
* CREATE_FRAME:	Erzeugt zuoberst einen Stackframe im Short-Format falls dies
*				n”tig ist (MC68010-MC68040).
*
* CREATE_FRAME_PC: Erzeugt einen Stackframe im Short-Format falls dies n”tig ist.
*				   Der Frame wird vor den PC geschoben (auf dem Stack).
*-------------------------------------------------------------------------------

		.EXPORT		FRAME_LENGTH,CREATE_FRAME,CREATE_FRAME_PC

*-------------------------------------------------------------------------------

FRAME_LENGTH:	tst.b		CPU
				beq.s		.no_frame
				add.w		d0,d0
				move.w		FRAME_TABELLE(pc,d0.w),d0
				rts
.no_frame:		moveq		#3,d0
				rts

*---------------

FRAME_TABELLE:	dc.w		4,4,6,6,8,-1,-1,30,29,10,16,46,12,-1,-1,-1

*-------------------------------------------------------------------------------

CREATE_FRAME:	tst.b		CPU
				beq.s		.M68000
				subq.w		#2,sp
				move.l		2(sp),(sp)
				move.w		VEKTOR_OFFSET,4(sp)
.M68000:		rts

*-------------------------------------------------------------------------------

CREATE_FRAME_PC:tst.b		CPU
				beq.s		.M68000
				subq.w		#2,sp
				move.l		2(sp),(sp)
				move.l		6(sp),4(sp)
				clr.w		8(sp)
.M68000:		rts
