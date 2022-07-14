
	; swallow "comment" directive (used to set prg flags)
	macro comment HEAD
	endm

	; turn "section text/data/bss" to "text/data/bss"
	macro section
	\1
	endm

	include replay.s
