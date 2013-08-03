	PEA	.text(PC)
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	MOVE.W	#8,-(A7)
	TRAP	#1
	ADDQ.L	#2,A7
	BRA	.skiptext

.text	DC.B	27,"E"
	dc.b	"---- Avena 3d system test ----",13,10,10
	dc.b	"7/8/9 4/5/6  : Rotation (NumberPad)",13,10
	dc.b	"    +/-      : Size    ",13,10
	dc.b	"      1/2    : left/right ",13,10,10

	dc.b	"Avena internal release",13,10
	dc.b	"Code/Objects : tat",13,10
	dc.b	0
	EVEN
.skiptext