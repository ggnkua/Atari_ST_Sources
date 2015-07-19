
	LEA	$40000,A0
O:
	MOVE.B	(A0)+,D0
	CMP.B	#',',D0
	BNE.S	PAVIRG
	CMP.B	#' ',-2(A0)
	BEQ.S	BUG
	CMP.B	#' ',(A0)
	BNE.S	BUG
	BRA.S	O
PAVIRG:
	CMP.B	#'(',D0
	BNE.S	PAGAU
	CMP.B	#' ',-2(A0)
	BNE.S	BUG
	CMP.B	#' ',(A0)
	BEQ.S	BUG
	BRA.S	O
PAGAU:
	CMP.B	#')',D0
	BNE.S	PADRO
	CMP.B	#' ',-2(A0)
	BEQ.S	BUG
	CMP.B	#',',(A0)
	BEQ.S	O
	CMP.B	#'.',(A0)
	BEQ.S	O
	CMP.B	#' ',(A0)
	BNE.S	BUG
	BRA.S	O
PADRO:
	TST.B	D0
	BNE.S	O
BUG:	ILLEGAL

