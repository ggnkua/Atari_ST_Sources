	output "E:\pure.c\lib\trap_10.O"

	opt P=68000
	
	text
	
	export trap_10
	
trap_10:
	swap d0
	move #$3130,d0
	swap d0
	and #$ff,d0
	lsl #8,d1
	or d1,d0
	trap #10
	rts
	
	end