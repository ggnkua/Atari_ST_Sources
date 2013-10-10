

.sv_hp	move.b	#$e,$ffff8800.w	;
	move.b	$ffff8800,d0	;
	bchg	#6,d0		;Commute sagement le HP.
	move.b	d0,8802.w	;
