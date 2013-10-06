

; ---------------------------------------------------------
		text
; ---------------------------------------------------------


; ---------------------------------------------------------
; anwendung im system registrieren (aes/vdi)
; bildschirmattribute erfragen
; ---------------------------------------------------------
registerMyApplication

		lea	ltAESRegister,a0
		bsr	logString

	; appl_init(), AES
		lea	aesContrl,a0
		move.w	#10,(a0)+		; appl_init()
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#1,(a0)+
		move.w	#0,(a0)
		bsr	callAES

	; graf_handle(), AES
		lea	aesContrl,a0
		move.w	#77,(a0)+		; graf_handle()
		move.w	#0,(a0)+
		move.w	#5,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)
		bsr	callAES
		move.w	aesIntout,aesHandle	; handle merken

	; v_opnvwk(), VDI
		lea	vdiIntin,a0
		move.w	#0,(a0)+		; akt. aufloesung
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#2,(a0)+		; rc-koordinaten
		move.w	#0,(a0)
		lea	vdiContrl,a0
		move.w	#100,(a0)+		; v_opnvwk()
		move.w	#0,(a0)+
		move.w	#6,(a0)+
		move.w	#11,(a0)+
		move.w	#45,(a0)+
		move.w	aesHandle,(a0)
		bsr	callVDI
		move.w	vdiContrl+12,vdiHandle

	; vq_scrninfo(), VDI
		move.w	#2,vdiIntin
		lea	vdiContrl,a0
		move.w	#102,(a0)
		move.w	#0,2(a0)
		move.w	#1,6(a0)
		move.w	#1,10(a0)
		move.w	aesHandle,12(a0)		; handle
		bsr	callVDI

		lea	vdiIntout,a0
;		move.w	4(a0),bpp
;		move.w	10(a0),lineoffset		; byteoffset pro zeile
;		move.l	12(a0),d0
;		move.l	d0,screen_1
;		move.l	d0,screen_2


		rts



; ---------------------------------------------------------
; anwendung vom system abmelden (aes/vdi)
; ---------------------------------------------------------
unregisterMyApplication

		lea	ltAESUnregister,a0
		bsr	logString

	; v_clsvwk(), VDI
		lea	vdiContrl,a0
		move.w	#101,(a0)+		; v_clsvwk()
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	vdiHandle,(a0)
		bsr	callVDI
		move.w	vdiContrl+12,vdiHandle

	; appl_exit(), AES
		lea	aesContrl,a0
		move.w	#19,(a0)+		; appl_exit()
		move.w	#0,(a0)+
		move.w	#0,(a0)+
		move.w	#1,(a0)+
		move.w	#0,(a0)
		bsr	callAES

		rts


; ---------------------------------------------------------
; vdi aufrufen
; ---------------------------------------------------------
callVDI
		move.w	#$73,d0		; opcode vdi
		move.l	#vdiPblock,d1	; adresse parameterblock
		trap	#2
		rts


; ---------------------------------------------------------
; aes aufrufen
; ---------------------------------------------------------
callAES		
		move.w	#200,d0		; opcode aes
		move.l	#aesPblock,d1	; adresse parameterblock
		trap	#2
		rts




; ---------------------------------------------------------
		data
; ---------------------------------------------------------


aesPblock	dc.l	aesContrl
		dc.l	aesGlobal
		dc.l	aesIntin
		dc.l	aesIntout
		dc.l	aesAdrin
		dc.l	aesAdrout

vdiPblock	dc.l	vdiContrl
		dc.l	vdiIntin
		dc.l	vdiPtsin
		dc.l	vdiIntout
		dc.l	vdiPtsout



; ---------------------------------------------------------
		bss
; ---------------------------------------------------------


; parameterbloecke fuer vdi-aufrufe/-ausgaben
vdiContrl	ds.w	12
vdiIntin	ds.w	1024
vdiIntout	ds.w	512
vdiPtsin	ds.w	1024
vdiPtsout	ds.w	256

; parameterbloecke fuer aes-aufrufe/-ausgaben
aesContrl	ds.w	5
aesGlobal	ds.w	15
aesIntin	ds.w	16
aesIntout	ds.w	10
aesAdrin	ds.l	8
aesAdrout	ds.l	2

; ermittelte handles (kennung) des bildschirms
aesHandle	ds.w	1
vdiHandle	ds.w	1
