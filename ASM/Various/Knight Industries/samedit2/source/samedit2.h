	OUTPUT	D:\SamEdit2\samedit2.app

minX	equ	640
minY	equ	185

	SECTION	data
resourceFile	dc.b	'samedit2.rsc',0
version	dc.b	'Version: 1.8  (17/06/1998)',0
scrapFile	dc.b	'scrap.raw'

	SECTION	bss
mainWindowHandle	ds.w	1
mainWindowIconise	ds.w	1
mainWindowInfo	ds.b	128

loadInitial	ds.w	1

; sample info table

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

sampleInfoTable	ds.b	sampleInfoSize

	SECTION	text

callModule	MACRO
	lea	sampleHeader,a0
	lea	sampleInfoTable,a1
	move.l	D2DBuffer,d1
	move.l	D2DBuffer+4,d2	; size of buffer
	move.w	\1,d0
	pea	.\@
	move.l	sampleModuleAddress(a1),a2
	jmp	(a2)
.\@
	ENDM