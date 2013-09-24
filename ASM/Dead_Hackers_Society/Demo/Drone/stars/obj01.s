
		;x,y,z,-


.s:		set	220
.y:		set	-5
.z:		set	100

	rept	12
		dc.w	-7*.s,.y*.s,.z,0
		dc.w	-6*.s,.y*.s,.z,0
		dc.w	-5*.s,.y*.s,.z,0
		dc.w	-4*.s,.y*.s,.z,0
		dc.w	-3*.s,.y*.s,.z,0
		dc.w	-2*.s,.y*.s,.z,0
		dc.w	-1*.s,.y*.s,.z,0
		dc.w	0*.s,.y*.s,.z,0
		dc.w	1*.s,.y*.s,.z,0
		dc.w	2*.s,.y*.s,.z,0
		dc.w	3*.s,.y*.s,.z,0
		dc.w	4*.s,.y*.s,.z,0
		dc.w	5*.s,.y*.s,.z,0
		dc.w	6*.s,.y*.s,.z,0
		dc.w	7*.s,.y*.s,.z,0
.y:		set	.y+1
	endr


