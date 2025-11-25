	
	Include	"D:\Raiden\Include\jaguar.inc'	

Start	Lea	$809000.l,a0
	Clr.l	d0
.Loop	Add.l	(a0)+,d0
	Cmp.l	#$a00000,a0
	Bne.s	.Loop
	ILLEGAL
