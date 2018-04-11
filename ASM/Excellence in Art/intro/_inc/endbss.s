oldrez:	ds.w 1
oldvbl:	ds.l	1
old114:	ds.l	1
;oldusp:	ds.l	1
oldpal: ds.w 16
old8260: ds.l 1
old820a: ds.l 1
old8265:	ds.b 1
old820f:	ds.b 1
old8e21: ds.b 1
	even

physbase:	ds.l 1
old8203: ds.b 1
old8201: ds.b 1
old820d: ds.b 1
old484: ds.b 1

;	ifne HBL_ENABLE
;old07	ds.b 1
;old09	ds.b 1
;old13	ds.b 1
;old1b	ds.b 1
;old21	ds.b 1
;	even
;oldhbl	ds.l 1
;	endif

	even
startupsp: ds.l 1

; From DHS' demosystem
save_hbl:		ds.l	1			;HBL vector
save_vbl:		ds.l	1			;VBL vector
save_timer_a:		ds.l	1			;Timer-A vector
save_timer_b:		ds.l	1			;Timer-B vector
save_timer_c:		ds.l	1			;Timer-C vector
save_timer_d:		ds.l	1			;Timer-D vector
save_acia:		ds.l	1			;ACIA vector
save_usp:		ds.l	1			;USP
save_mfp:		ds.b	16			;MFP
