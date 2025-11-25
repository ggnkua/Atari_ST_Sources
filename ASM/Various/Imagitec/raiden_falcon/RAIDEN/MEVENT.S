; Event table makefile
; Assemble as ATARI EXECUTEABLE to LEVEL_X\EVENT.BIN
; Base of program is at BASE_ADDRESS+((Base_Address&$00ff)+2)
	Opt	D-
	Include	Macros.s
	Include	Level_1\Event.SRC