	XREF	slb_init
	XREF 	slb_exit
	XREF 	slb_open
	XREF 	slb_close

	XREF	test_fun
	XREF	start_of_text

	TEXT
start_of_text:
	DC.L	$70004afc
	DC.L	name
	DC.L	1
	DC.L	0
	DC.L	slb_init
	DC.L	slb_exit
	DC.L	slb_open
	DC.L	slb_close
	DC.L	0
	DC.L	0, 0, 0, 0, 0, 0, 0, 0
	DC.L	1

	DC.L	test_fun

name:		DC.B	'shared.slb',0

	END