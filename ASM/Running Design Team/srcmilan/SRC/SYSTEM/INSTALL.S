

		text


; ---------------------------------------------------------
; system initialisieren/installieren
installSystem
		bsr	registerMyApplication

		bsr	installSupervisor
		bsr	installVideo
		bsr	installKeyboardIrq
		bsr	initLineA
		bsr	initDirectories
		bsr	initAudio
		bsr	initTilesGfx

		rts


; ---------------------------------------------------------
; urspruenglichen systemzustand wiederherstellen
restoreSystem
		bsr	restoreAudio
		bsr	restoreKeyboardIrq
		bsr	restoreVideo
		bsr	deinstallSupervisor

		bsr	unregisterMyApplication

		rts


; ---------------------------------------------------------
; supervisor modus einschalten
installSupervisor
		clr.l	-(sp)
		move.w	#32,-(sp)	; super()
		trap	#1
		addq.l	#6,sp
		move.l	d0,stackUSPPtr

		rts


; ---------------------------------------------------------
; supervisor modus ausschalten
deinstallSupervisor
		move.l	stackUSPPtr,-(sp)
		move.w	#32,-(sp)	; super()
		trap	#1
		addq.l	#6,sp

		rts


; ---------------------------------------------------------
; linea routinen initialisieren
initLineA
		dc.w	$a000
		move.l	a0,lineaParPtr

		move.l	a0,d0
		bsr	binToHex
		move.l	(a0),ltLineAParameterM
		move.l	4(a0),ltLineAParameterM+4
		lea	ltLineAParameter,a0
		bsr	logString

		rts


; ---------------------------------------------------------
; pfade setzen, temporaere verzeichnisse erstellen
initDirectories
		pea	idTempPath
		move	#57,-(sp)
		trap	#1			; d_create
		addq.l	#6,sp

		pea	idSavePath
		move	#57,-(sp)
		trap	#1			; d_create
		addq.l	#6,sp

		rts	


; ---------------------------------------------------------
; loescht daten- und instructioncache
clearCache
		nop
		dc.w	$f4f8			; cpusha dc/ic

		rts


; ---------------------------------------------------------
; 13.08.00/vk
; initialisiert den speicherbereich fuer die texturdaten.
initTilesGfx
		move.w	#%0011,d0					; bevorzugt tt-ram
		move.l	#TILESDIMENSION*TILESDIMENSION*2*NBOFTILES,d1	; arraygroesse
		bsr	allocateMemory
		tst.l	d0
		bne.s	itgNoMemoryError

		lea	ltTilesGfxNoMemoryError,a0			; keinen speicher mehr bekommen
		bsr	logString					; fehler protokollieren

		lea	stopSystemData,a0
		move.w	#SSNOTENOUGHMEMORY,SSCODE(a0)
		bsr	stopSystem					; und system anhalten

itgNoMemoryError

		lea	tilesGfxPtrArray,a0
		moveq	#NBOFTILES-1,d7
itgLoop		move.l	d0,(a0)+					; array mit pointern auf die jeweiligen kacheln fuellen
		addi.l	#TILESDIMENSION*TILESDIMENSION*2,d0
		dbra	d7,itgLoop

		lea	ltTilesGfxMemoryOk,a0
		bsr	logString

		rts





		data


idTempPath	dc.b	"temp",0
		even
idSavePath	dc.b	"save",0
		even



		bss


stackUSPPtr	ds.l	1
lineaParPtr	ds.l	1
