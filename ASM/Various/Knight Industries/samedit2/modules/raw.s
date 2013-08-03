; Sam-Edit 2 version 2.0 raw data module
; for Devpac 3

	OUTPUT	D:\SamEdit2\SOURCE\RAW.SEM

	SECTION	data

moduleName		dc.b	'Raw Data Module',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.1 (05/01/1998)',0
moduleFunctions	dc.w	%00000
moduleID		dc.b	'Data',0

; functions Bit:  0  = ID
;           Bit:  1  = Load
;           Bit:  2  = Save
;           Bit:  3  = Update Header
;           Bit:  4  = Intel byte order if set (required)

	SECTION	bss
; info table
	rsreset
sampleModuleAddress	rs.l	1
sampleHeaderSize	rs.w	1
sampleDataSize	rs.l	1
sampleAddress	rs.l	1
sampleFrequency	rs.l	1
sampleChannels	rs.w	1
sampleResolution	rs.w	1
sampleSigned	rs.w	1
sampleLoaded	rs.w	1
sampleSaveStatus	rs.w	1
sampleMode	rs.w	1	; 0 = mem, 1 = d2d
sampleModuleFunctions	rs.w	1
samplePathname	rs.b	256	; holds directory+file
sampleInfoSize	rs.w	0


	SECTION	text

start
	rts