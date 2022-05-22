STEitson	LEA $FFFF8909.W,A0
.read		MOVEP.L 0(A0),D0		; major design flaw in ste
		DCB.W 15,$4E71			; h/ware we must read the
		MOVEP.L 0(A0),D1		; frame address twice
		LSR.L #8,D0			; since it can change
		LSR.L #8,D1			; midway thru a read!
		CMP.L D0,D1			; so we read twice and
		BNE.S .read			; check the reads are
						; the same!!!!
