*-------------------------------------------------------------------------------

.MACRO XBRA label
				dc.l		'XBRA'
				dc.l		KENNUNG
		label:	dc.l		0
.ENDM

*-------------------------------------------------------------------------------

.MACRO ErrorHandler old,message,flag
				move.l		old(pc),-(sp)
				pea			message
				move.b		flag+1(pc),-(sp)
				bra			ERROR_HANDLER
.ENDM

*-------------------------------------------------------------------------------

.MACRO TrapHandler old,flag
				move.l		old(pc),-(sp)
				move.b		flag+1(pc),-(sp)
				bra			TRAP_HANDLER
.ENDM

*-------------------------------------------------------------------------------

.MACRO PrintError message
				lea			message,a3
				bsr			PRINT_ERROR
.ENDM

*-------------------------------------------------------------------------------

.MACRO MessageC label,string
				.DATA
		label:	dc.b		string,0
				.EVEN
				.TEXT
.ENDM

*-------------------------------------------------------------------------------

.MACRO MessageP label,string
				.DATA
				.LOCAL		ende
		label:	dc.b		ende-label-1,string
		ende:	.EVEN
				.TEXT
.ENDM

*-------------------------------------------------------------------------------
