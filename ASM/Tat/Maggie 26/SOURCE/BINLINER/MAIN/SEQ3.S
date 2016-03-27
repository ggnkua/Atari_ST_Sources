;-----------------------------------------------------------------------

		include	sequence\seqdec.s

;-----------------------------------------------------------------------
kick_in_script:
		system
		clear
		music
		quit
		
main_script:
		load	worship_data
		execute	worship_data,0,0,0
		execute	worship_data,1,-1,-1
		wait	$3c,0
;-----------------------------------------------------------------------
		quit
		even

;-----------------------------------------------------------------------

worship_data:
		DC.L	load_address_3
		DC.W	0			;active flag
		DC.B	"DATA\WORSHIP.PRG",0	;filename
		EVEN

;-----------------------------------------------------------------------

	even
