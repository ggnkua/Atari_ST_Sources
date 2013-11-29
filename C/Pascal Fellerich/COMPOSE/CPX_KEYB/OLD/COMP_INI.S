; cpxstart.asm
;=============================================================================
; Startup file for CPXs
;
; 'Save_vars' is the area to store your default variables.
; Add more dc.w's as necessary
;
; Assemble with Mad Mac
;
; For Mark Williams - Use  'cpx_init_'
; For Alcyon        - Use  '_cpx_init'
;
;  
;


	globl	    cpxstart
	globl	    save_vars
	globl	    cpx_init
	
	text

cpxstart:
	jmp  cpx_init


	data

save_vars:
	ds.b 128			;path
	dc.w 0				;filetype
	dc.w 1,1,1,1,3		;config data
	dc.w 1				;language (english is default)
	dc.b "'", "^", "`", '"'
	dc.b "¹", "ø", "~", "|"
	ds.b 8				;string with deadkeys
	
;extern struct safe {
;	char	loadfile[128];			/* welche Datei wird geladen!? */
;	short	filetype;				/* 0 none, 1 KBD, 2 CKB */
;	short	extkey, compose, alt_nnn, deadkey;
;	short	mapping;				/* cfg data for those fn's */
;	short	language;
;	char	keys[16];				/* deadkeys */
;} save_vars;

	end
