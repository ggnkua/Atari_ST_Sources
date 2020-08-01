; FORST.S: Forth for MC68000
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
	section	text 
	even 
;
	include globals.s
	include header.s
	include	strtfin.s
;
; ForST system words:
;
	include shell.s		;this file MUST stay in this position
	include actions.s
	include compile.s
	include	allmacs.s
	include heads.s
	include	bmaths.s
	include vars.s
	include io.s
	include expect.s
	include files.s
;
; user words:
;
	include maths.s
	include memory.s
	include gemdos.s
	include bios.s
	include gem.s
	include	vt52.s
	include extend.s
;
	bss
;
	ds.b	wspace		;space for code and stacks
	ds.b	hspace		;space for headers
;
