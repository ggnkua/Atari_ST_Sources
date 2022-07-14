	global mt_init,mt_stop_Paula,init_inter,stop_inter
	global mt_physic_buf,mt_logic_buf,mt_patternpos,mt_songpos

	; swallow "comment" directive (used to set prg flags)
	macro comment HEAD
	endm

	; turn "section text/data/bss" to "text/data/bss"
	macro section
	\1
	endm

	include ../replay/gas/replay.s

| vim: set ts=16:
