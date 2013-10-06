

		text


; ---------------------------------------------------------
; 27.01.00/vk
; schreibt den string, auf den a0 zeigt, in das logfile.
; a0 = string
; rettet alle register.
logString
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	a0,logPtr

	; logfile oeffnen oder neu erstellen

		clr.w	-(sp)
		pea	logfile
		move.w	#61,-(sp)		; fopen
		trap	#1
		addq.l	#8,sp
		tst.w	d0			; datei erfolgreich geoeffnet?
		bpl.s	lsLogNow		; ja -> string schreiben

		clr.w	-(sp)
		pea	logfile
		move.w	#60,-(sp)		; fcreate
		trap	#1
		addq.l	#8,sp
		tst.w	d0			; datei erfolgreich erstellt?
		bmi	lsOut			; nein -> kein log moeglich
lsLogNow

	; schreibposition ans dateiende setzen

		move.w	d0,d7			; handle merken
		move.w	#2,-(sp)		; seekmode
		move.w	d7,-(sp)		; handle
		clr.l	-(sp)			; seekoffset
		move.w	#66,-(sp)		; fseek
		trap	#1
		lea	10(sp),sp

	; laenge des zu schreibenden strings bestimmen

		movea.l	logPtr,a1
		moveq	#0,d6
lsCountLoop	tst.b	(a1)+
		beq.s	lscFoundEnd
		addq.w	#1,d6
		bra.s	lsCountLoop
lscFoundEnd

	; und ins logfile schreiben

		lea	datestring,a0
		bsr	date2ascii
		pea	datestring		; buffer
		move.l	#11,-(sp)		; bufferlen
		move.w	d7,-(sp)		; handle
		move.w	#64,-(sp)		; fwrite()
		trap	#1
		lea	12(sp),sp

		lea	timestring,a0
		bsr	time2ascii
		pea	timestring		; buffer
		move.l	#10,-(sp)		; bufferlen
		move.w	d7,-(sp)		; handle
		move.w	#64,-(sp)		; fwrite()
		trap	#1
		lea	12(sp),sp

		move.l	logPtr,-(sp)		; buffer
		move.l	d6,-(sp)		; bufferlen
		move.w	d7,-(sp)		; handle
		move.w	#64,-(sp)		; fwrite()
		trap	#1
		lea	12(sp),sp

	; datei wieder schliessen

		move.w	d7,-(sp)
		move.w	#62,-(sp)		; fclose()
		trap	#1
		addq.w	#4,sp
		
lsOut
		movem.l	(sp)+,d0-d7/a0-a6
		rts




		data


logfile			dc.b	"running.log",0
			even

			IFEQ LANGUAGE
ltRunningStart		dc.b	"Running programme starts up...",13,10,0
ltRunningEnd		dc.b	"Running programme stopped.",13,10,0
			ELSE
ltRunningStart		dc.b	"Programm Running startet...",13,10,0
ltRunningEnd		dc.b	"Programm Running wurde gestoppt.",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltAESRegister		dc.b	"Registering Running application within AES.",13,10,0
ltAESUnregister		dc.b	"Unregistering Running application within AES.",13,10,0
			ELSE
ltAESRegister		dc.b	"Registriere Running-Applikation innerhalb AES.",13,10,0
ltAESUnregister		dc.b	"Entferne Running aus der Registrierung innerhalb AES.",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltVideoStart		dc.b	"Init of the video subsystem is starting... ",13,10,0
ltVideoEnd		dc.b	"Init of the video subsystem ends successfull.",13,10,0
ltVideoDriverVersion	dc.b	"Found _VDI cookie, graphic driver version 0x"
ltVideoDriverVersionM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoDriverFlags	dc.b	"Graphic driver is capable of the following functions: 0x"
ltVideoDriverFlagsM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoXBiosPhysbase	dc.b	"_physbase (XBIOS) returns 0x"
ltVideoXBiosPhysbaseM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoCurrentID	dc.b	"Current video id is 0x"
ltVideoCurrentIDM	dc.b	0,0,0,0,".",13,10,0
ltVideoNoCookieJar	dc.b	"No cookie jar found on your system. Aborting.",13,10,0
ltVideoNoVDICookie	dc.b	"No cookie _VDI found on your system. Aborting.",13,10,0
ltVideoSettingTo	dc.b	"Trying to set video mode id 0x"
ltVideoSettingToM	dc.b	0,0,0,0,".",13,10,0
ltVideoReset		dc.b	"Resetting video system to default resolution.",13,10,0
ltVideoScreenInRamError	dc.b	"Not enough memory to build up off-screen buffer in ram.",13,10,0
ltVideoScrInfoError	dc.b	"Calling _setscreen() returns an illegal screeninfo structure.",13,10,0
ltVideoXBiosLogbase	dc.b	"_logbase (XBIOS) returns 0x"
ltVideoXBiosLogbaseM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoAllocPage	dc.b	"Allocation of video memory of a second page returns 0x"
ltVideoAllocPageM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoAllocPageFailed	dc.b	"Allocation of video memory for second page failed. Some features will not be available.",13,10,0
ltVideoFreePage		dc.b	"Freeing video memory for second page.",13,10,0
ltVideoFirstPage	dc.b	"Video memory for first page is located at 0x"
ltVideoFirstPageM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoFrameBuffer	dc.b	"Address of the frame buffer is 0x"
ltVideoFrameBufferM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ELSE
ltVideoStart		dc.b	"Initialisierung des Grafik-Subsystems beginnt... ",13,10,0
ltVideoEnd		dc.b	"Initialisierung des Grafik-Subsystems beendet.",13,10,0
ltVideoDriverVersion	dc.b	"_VDI Cookie gefunden, Grafiktreiberversion ist 0x"
ltVideoDriverVersionM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoDriverFlags	dc.b	"Grafiktreiber implementiert die folgenden Funktionen: 0x"
ltVideoDriverFlagsM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoXBiosPhysbase	dc.b	"_physbase (XBIOS) liefert 0x"
ltVideoXBiosPhysbaseM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoCurrentID	dc.b	"Aktuelle Video-ID ist 0x"
ltVideoCurrentIDM	dc.b	0,0,0,0,".",13,10,0
ltVideoNoCookieJar	dc.b	"Kein Cookie Jar auf dem System gefunden.",13,10,0
ltVideoNoVDICookie	dc.b	"Im Cookie Jar wurde kein _VDI Cookie gefunden.",13,10,0
ltVideoSettingTo	dc.b	"Versuche, die Video-ID 0x"
ltVideoSettingToM	dc.b	0,0,0,0," zu setzen.",13,10,0
ltVideoReset		dc.b	"Grafiksubsystem wird auf die vorherige Auflîsung zurÅckgesetzt.",13,10,0
ltVideoScreenInRamError	dc.b	"Nicht genug Speicher fÅr die Offscreen-Bildschirme im RAM.",13,10,0
ltVideoScrInfoError	dc.b	"Der Aufruf von _setscreen liefert eine illegale screeninfo-Struktur.",13,10,0
ltVideoXBiosLogbase	dc.b	"_logbase (XBIOS) liefert 0x"
ltVideoXBiosLogbaseM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoAllocPage	dc.b	"Speicheranforderung (Video-RAM) fÅr eine zweite Seite lieferte die Adresse 0x"
ltVideoAllocPageM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoAllocPageFailed	dc.b	"Speicheranforderung (Video-RAM) fehlgeschlagen. Einige Funktionen werden nicht verfÅgbar sein.",13,10,0
ltVideoFreePage		dc.b	"Speicher (Video-RAM) fÅr zweite Seite wird freigegeben.",13,10,0
ltVideoFirstPage	dc.b	"Video-RAM fÅr erste Seite liegt an Adresse 0x"
ltVideoFirstPageM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltVideoFrameBuffer	dc.b	"Adresse des Frame-Buffers ist 0x"
ltVideoFrameBufferM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltKeyIrqStart		dc.b	"Init of routine for keyboard interrupt is starting ...",13,10,0
ltKeyIrqEnd		dc.b	"Init of routine for keyboard interrupt ends successfull.",13,10,0
ltKeyIrqReset		dc.b	"Setting routine for keyboard interrupt back to TOS routine.",13,10,0
ltKeyKbdvbaseAddress	dc.b	"The address of the kbdvbase-structure is 0x"
ltKeyKbdvbaseAddressM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ELSE
ltKeyIrqStart		dc.b	"Initialisierung der eigenen Tastatur-Interruptroutine beginnt...",13,10,0
ltKeyIrqEnd		dc.b	"Eigene Tastatur-Interruptroutine erfolgreich initialisiert.",13,10,0
ltKeyIrqReset		dc.b	"Setze Tastatur-Interruptroutine zurÅck auf TOS-Routine.",13,10,0
ltKeyKbdvbaseAddress	dc.b	"Adresse der kbdvbase-Struktur ist 0x"
ltKeyKbdvbaseAddressM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltLineAParameter	dc.b	"Init of Linea-subsystem: parameter pointer is 0x"
ltLineAParameterM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ELSE
ltLineAParameter	dc.b	"Initialisierung des LineA-Subsystems: Adresse des Parameterblocks ist 0x"
ltLineAParameterM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltSoundStart		dc.b	"Init of the sound system is starting ...",13,10,0
ltSoundEnd		dc.b	"Init of the sound system ends successfull.",13,10,0
ltSoundNoCookieJar	dc.b	"No cookie jar found on your system.",13,10,0
ltSoundNoSNDCookie	dc.b	"No cookie _SND found on your system.",13,10,0
ltSoundNoSoundAvailable	dc.b	"There is no sound system available for Running application.",13,10,0
ltSoundCookieValue	dc.b	"Found _SND cookie, cookie value is 0x"
ltSoundCookieValueM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltSoundCodec		dc.b	"A codec is available on your system.",13,10,0
ltSoundNoCodec		dc.b	"There is no codec available on your system.",13,10,0
ltSoundFailed		dc.b	"Sound system init failed.",13,10,0
ltSoundLocked		dc.b	"Sound system locked for Running application.",13,10,0
ltSoundLockFailed	dc.b	"Returncode 0x"
ltSoundLockFailedM	dc.b	0,0,0,0,0,0,0,0,": Sound system could not be locked for Running application",13,10
			dc.b	"                     (0x00000080 seems like an old driver of milanblaster).",13,10,0
ltSoundSetmontracksError	dc.b	"_setmontracks(0) failed. No audio system will be available.",13,10,0
ltSoundSettracksError	dc.b	"_settracks(0,0) failed. No audio system will be available.",13,10,0
ltSoundSetmodeError	dc.b	"_setmode(<value>) failed. No audio system will be available.",13,10,0
ltSoundSoundcmdError	dc.b	"_soundcmd(6,2) failed. No audio system will be available.",13,10,0
ltSoundSetbufferError	dc.b	"_setbuffer(0,<start>,<end>) failed. No audio system will be available.",13,10,0
ltSoundDevconnectError	dc.b	"_devconnect(0,12,0,0,1) failed. No audio system will be available.",13,10,0
ltSoundSetinterruptError	dc.b	"_setinterrupt(0,1) failed. No audio system will be available.",13,10,0
ltSoundAllocBufferError	dc.b	"Memory allocation for audio buffers failed. No audio system will be available.",13,10,0
ltSoundBuffoperError	dc.b	"_buffoper(<value>) failed. The audio system will not be available.",13,10,0
ltSoundOk		dc.b	"Sound system successfully installed.",13,10,0
ltSoundDoubleInit	dc.b	"Sound system is still initialized. No double initialization possible.",13,10,0
			ELSE
ltSoundStart		dc.b	"Initialisierung des Soundsystems gestartet...",13,10,0
ltSoundEnd		dc.b	"Soundsystem wurde erfolgreich initialisiert.",13,10,0
ltSoundNoCookieJar	dc.b	"Kein Cookie Jar auf dem System gefunden.",13,10,0
ltSoundNoSNDCookie	dc.b	"Im Cookie Jar wurde kein _SND Cookie gefunden.",13,10,0
ltSoundNoSoundAvailable	dc.b	"FÅr Running steht kein Soundsystem zur VerfÅgung.",13,10,0
ltSoundCookieValue	dc.b	"_SND Cookie gefunden, Wert des Cookies ist 0x"
ltSoundCookieValueM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltSoundCodec		dc.b	"Codec auf dem System verfÅgbar.",13,10,0
ltSoundNoCodec		dc.b	"Kein Codec auf dem SystemverfÅgbar.",13,10,0
ltSoundFailed		dc.b	"Initialisierung des Soundsystems fehlgeschlagen.",13,10,0
ltSoundLocked		dc.b	"Soundsystem konnte erfolgreich fÅr Running reserviert werden.",13,10,0
ltSoundLockFailed	dc.b	"RÅckkehrcode 0x"
ltSoundLockFailedM	dc.b	0,0,0,0,0,0,0,0,": Soundsystem konnte nicht fÅr Running reserviert werden",13,10
			dc.b	"                         (0x00000080 schlieût auf einen alten Milanblaster-Treiber).",13,10,0
ltSoundSetmontracksError	dc.b	"_setmontracks(0) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundSettracksError	dc.b	"_settracks(0,0) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundSetmodeError	dc.b	"_setmode(<value>) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundSoundcmdError	dc.b	"_soundcmd(6,2) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundSetbufferError	dc.b	"_setbuffer(0,<start>,<end>) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundDevconnectError	dc.b	"_devconnect(0,12,0,0,1) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundSetinterruptError	dc.b	"_setinterrupt(0,1) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundAllocBufferError	dc.b	"Speicheranforderung fÅr Soundsystem fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundBuffoperError	dc.b	"_buffoper(<value>) fehlgeschlagen. Kein Soundsystem verfÅgbar.",13,10,0
ltSoundOk		dc.b	"Soundsystem wurde erfolgreich initialisiert.",13,10,0
ltSoundDoubleInit	dc.b	"Soundsystem ist bereits initialisiert. Keine Doppelinitialisierung mîglich.",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltTilesGfxMemoryOk	dc.b	"Memory for textures could be allocated.",13,10,0
ltTilesGfxNoMemoryError	dc.b	"Memory for textures could not be allocated.",13,10,0
			ELSE
ltTilesGfxMemoryOk	dc.b	"Speicheradresse fÅr Texturen konnte erfolgreich angefordert werden.",13,10,0
ltTilesGfxNoMemoryError	dc.b	"Speicher fÅr Texturen konnte nicht allokiert werden.",13,10,0
			ENDC
			even

			IFEQ LANGUAGE
ltMemoryTryToGet	dc.b	"Trying to allocate 0x"
ltMemoryTryToGetM	dc.b	0,0,0,0,0,0,0,0," bytes of memory (mode 0x"
ltMemoryTryToGetM2	dc.b	0,0,0,0,").",13,10,0
ltMemorySuccessfull	dc.b	"Allocation of memory successfull, memory address is 0x"
ltMemorySuccessfullM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltMemoryErrorLBlock	dc.b	"Allocation of memory not successfull. Largest free block has 0x"
ltMemoryErrorLBlockM	dc.b	0,0,0,0,0,0,0,0," bytes.",13,10,0
ltMemoryTryToFree	dc.b	"Trying to free memory block at 0x"
ltMemoryTryToFreeM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltMemoryFreeSuccess	dc.b	"Freeing of memory successfull.",13,10,0
ltMemoryFreeError	dc.b	"Freeing of memory not successfull, returncode is 0x"
ltMemoryFreeErrorM	dc.b	0,0,0,0,".",13,10,0
			ELSE
ltMemoryTryToGet	dc.b	"Versuche, 0x"
ltMemoryTryToGetM	dc.b	0,0,0,0,0,0,0,0," Bytes RAM-Speicher (Modus  0x"
ltMemoryTryToGetM2	dc.b	0,0,0,0,") zu allokieren...",13,10,0
ltMemorySuccessfull	dc.b	"Zuweisung von RAM-Speichers erfolgreich, die Adresse ist 0x"
ltMemorySuccessfullM	dc.b	0,0,0,0,0,0,0,0,".",13,10,0
ltMemoryErrorLBlock	dc.b	"Zuweisung von RAM-Speicher nicht erfolgreich. Grîûter freier Speicherblock ist 0x"
ltMemoryErrorLBlockM	dc.b	0,0,0,0,0,0,0,0," Bytes.",13,10,0
ltMemoryTryToFree	dc.b	"Versuche, RAM-Speicherblock an Adresse 0x"
ltMemoryTryToFreeM	dc.b	0,0,0,0,0,0,0,0," freizugeben.",13,10,0
ltMemoryFreeSuccess	dc.b	"Freigabe von RAM-Speicher erfolgreich.",13,10,0
ltMemoryFreeError	dc.b	"Freigabe von RAM-Speicher nicht erfolgreich, RÅckkehrcode ist 0x"
ltMemoryFreeErrorM	dc.b	0,0,0,0,".",13,10,0
			ENDC
			even




		bss


logPtr		ds.l	1

