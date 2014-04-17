*-------------------------------------------------------------------------------
* ACHTUNG: D0.l und A0.l kînnen verÑndert werden, alle andern Register werden
*		   gerettet. Alle Routinen mÅssen im Supervisormodus aufgerufen werden.
*
* BeginOs,EndOs: Diese beiden Routinen mÅssen vor und nach einem OS Aufruf
*				 erfolgen. Sie setzen das SR und den SP auf vernÅnftige Werte.
*				 ACHTUNG: die OS Routinen dÅrfen A6 und D6 NICHT verÑndern.
*
* DCREATE: Create directory
* ---> A2.l = Pfadname
* <--- flag.mi = Fehler
* DDELETE: Delete directory
* ---> A2.l = Pfadname
* <--- flag.mi = Fehler
* DFREE: Get drive free space
* ---> D3.w = gewÅnschtes Laufwerk
* <--- A0.l = Pointer auf Diskinfostruktur
* <--- flag.mi = Fehler
* DGETDRV: Get default drive
* ---> DRIVE wird gesetzt
* DGETPATH: Get current directory
* ---> PATH wird gesetzt
*
* DSETPATH: Setzt das aktuelle Laufwerk und den Pfad. Wird ein leerer
*			Pfad Åbergeben, wird der aktuelle Pfad genommen. Das
*			aktuelle Laufwerk und der aktuelle Pfad wird gerettet.
*			Sie kînnen mit RESTORE_PATH wieder restauriert werden.
* ---> A2.l = Pfadname
* ---> DRIVE wird gesetzt
* ---> PATH wird gesetzt
* <--- flag.eq = alles io, flag.ne = Pfad konnte nicht gesetzt werden
*
* RESTORE_PATH: Das Laufwerk und der Pfad, die vor dem Aufruf von
*				DSETPATH aktiv waren, werden restauriert.
* ---> DRIVE wird restauriert
* ---> PATH wird restauriert
*
* FCLOSE: Close file
* <--- flag.mi = Fehler
* FCREATE: Create File
* ---> A2.l = Filename
* <--- flag.mi = Fehler
* FDELETE: Delete File
* ---> A2.l = Filename
* <--- flag.ne = Fehler
* FGETDTA: Get DTA
* <--- A0.l = Zeiger auf aktuelle DTA
* FOPEN: Open file
* ---> D0.w = r 0, w 1, rw 2
* ---> A2.l = Filename
* <--- flag.mi = Fehler
* FREAD: Read from file
* ---> D3.l = Anzahl Bytes
* ---> A3.l = dahin wird geladen
* <--- cmp.l D0,D3 ---> bne.s error
* FSEEK: Seek file pointer from file begin
* ---> D3.l = Anzahl Bytes vom Dateianfang
* <--- cmp.l D0,D3 ---> bne.s error
* FSEEK_END: Seek file pointer to the end of the file
* <--- flag.ne = Operation missglÅckt
* FSETDTA: Set DTA
* ---> A3.l = neue DTA-Adresse
* FSFIRST: Search First
* ---> A2.l = gesuchter Filename
* <--- flag.ne = File nicht gefunden
* FSNEXT: Search next
* <--- flag.ne = File nicht gefunden
* FWRITE: Write to file
* ---> D3.l = Anzahl Bytes
* ---> A3.l = von hier ab speichern
* <--- cmp.l d0,d3 ---> bne.s error
*-------------------------------------------------------------------------------

		.EXPORT		DCREATE,DDELETE,DFREE,DGETDRV,DGETPATH
		.EXPORT		DSETPATH,RESTORE_PATH,FCLOSE,FCREATE,FDELETE
		.EXPORT		FGETDTA,FOPEN,FREAD,FSEEK,FSEEK_END
		.EXPORT		FSFIRST,FSNEXT,FWRITE,FSETDTA
		.EXPORT		BeginOs,EndOs
		.EXPORT		PRINT,DRIVE,PATH,DRIVE_BOOT,PATH_BOOT,HANDLE

*-------------------------------------------------------------------------------

		.DATA
		.EVEN
ACTUAL_PATH:									; wird benutzt, falls der angegebene
				dc.b	'A:\.',0				; Pfad ungÅltig ist (---> DSETPATH)
		.EVEN

*-------------------------------------------------------------------------------

		.BSS
PRINT:			ds.b	1						; RawMessage_C zum Pfad printen
DRIVE:			ds.b	2						; aktuelles Laufwerk
PATH:			ds.b	254						; aktueller Pfad

DRIVE_TMP:		ds.b	2						; temporÑres Laufwerk
PATH_TMP:		ds.b	254						; temporÑrer Pfad


DRIVE_BOOT:		ds.b	2					  	; Boot Laufwerk
PATH_BOOT:		ds.b	254						; Boot Pfad

*---------------

LocalFlag:		ds.b 1
				.EVEN

DISKINFO:										; DISKINFO-Struktur
B_FREE:			ds.l	1
B_TOTAL:		ds.l	1
B_SECSIZ:		ds.l	1
B_CLSIZ:		ds.l	1

HANDLE: 		ds.w	1						; Handle der offenen Datei

*------------------------------------------------------------------------------

		.TEXT
BeginOs:		movem.l		d1-d7/a1-a6,-(sp)
				move.l		13*4(sp),a5
				movea.l		sp,a6				; a6 = Stackpointer
				move		sr,d7				; d7 = Statusregister
				move		#$2300,sr
				lea			_STACK_OS,sp
				jmp			(a5)

*-------------------------------------------------------------------------------

EndOs:			move.l		(sp)+,a5
				move.w		d7,sr
				movea.l		a6,sp
				move.l		a5,13*4(sp)
				movem.l		(sp)+,d1-d7/a1-a6
				rts

*-------------------------------------------------------------------------------

DCREATE:		bsr.s		BeginOs
				pea			(a2)
				move.w		#57,-(sp)
				trap		#1
				addq.w		#6,sp
				bsr.s		EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

DDELETE:		bsr.s		BeginOs
				pea			(a2)
				move.w		#58,-(sp)
				trap		#1
				addq.w		#6,sp
				bsr.s		EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

DFREE:			bsr.s		BeginOs
				moveq		#0,d0
				move.b		DRIVE,d0
				sub.b		#'A'-1,d0
				move.w		d0,-(sp)
				pea			DISKINFO
				move.w		#54,-(sp)
				trap		#1
				addq.w		#8,sp
				bsr.s		EndOs
				lea			DISKINFO,a0
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

DGETDRV:		bsr			BeginOs
				move.w		#25,-(sp)
				trap		#1
				addq.w		#2,sp
				addi.b		#'A',d0
				move.b		d0,DRIVE
				move.b		#':',DRIVE+1
				bsr			EndOs
				rts

*-------------------------------------------------------------------------------

DGETPATH:		bsr			BeginOs
				clr.w		-(sp)
				pea			PATH
				move.w		#71,-(sp)
				trap		#1
				addq.w		#8,sp
				lea			PATH,a0
				bsr			PUT_SLASH
				bsr			EndOs
				rts

*-------------------------------------------------------------------------------

* 1. altes Drive retten
* 2. neues Drive setzen
* 3. alten Pfad auf neuem Drive retten
* 4. neuen Pfad auf neuem Drive setzen
DSETPATH:		bsr			BeginOs
				move.l		a2,a5

				move.w		#25,-(sp)			; Dgetdrv
				trap		#1
				addq.w		#2,sp
				addi.b		#'A',d0
				move.b		d0,DRIVE_TMP
				move.b		#':',DRIVE_TMP+1

				tst.b		(a5)				; Pfad leer?
				bne.s		.cont

				lea			ACTUAL_PATH,a5
				move.b		DRIVE_TMP,(a5)+
				move.b		#':',(a5)+
				move.w		#$2E00,(a5)			; $2E=.
				subq.w		#2,a5

.cont:			cmpi.b		#':',1(a5)			; Drive vorhanden?
				bne.s		.no_drive

				lea			Convert,a0
				moveq		#0,d3
				move.b		(a5),d3
				move.b		(a0,d3.w),d3
				subi.b		#'A',d3
				move.w		d3,-(sp)			; Drive
				move.w		#14,-(sp)
				trap		#1					; Dsetdrv
				addq.w		#4,sp
				addq.w		#2,a5
				
.no_drive:		clr.w		-(sp)				; aktuelles Drive
				pea			PATH_TMP			; Dgetpath
				move.w		#71,-(sp)
				trap		#1
				addq.w		#8,sp
				lea			PATH_TMP,a0
				bsr			PUT_SLASH
			
				pea			(a5)
				move.w		#59,-(sp)
				trap		#1					; Dsetpath
				addq.w		#6,sp
				tst.w		d0
				smi			LocalFlag

				bsr			EndOs
				bsr			DGETDRV
				bsr			DGETPATH
				tst.b		LocalFlag
				rts

*-------------------------------------------------------------------------------

* 1. alter Pfad auf neuem Drive restaurieren
* 2. altes Drive restaurieren
RESTORE_PATH:	bsr			BeginOs
				pea			PATH_TMP
				move.w		#59,-(sp)
				trap		#1					; Dsetpath
				addq.w		#6,sp
				moveq		#0,d3
				move.b		DRIVE_TMP,d3
				subi.b		#'A',d3
				move.w		d3,-(sp)			; Drive
				move.w		#14,-(sp)
				trap		#1					; Dsetdrv
				addq.w		#4,sp
				bsr			EndOs
				bsr			DGETDRV
				bra			DGETPATH

*-------------------------------------------------------------------------------

FCLOSE:			bsr			BeginOs
				move.w		HANDLE,-(sp)
				move.w		#62,-(sp)
				trap		#1
				addq.w		#4,sp
				clr.w		HANDLE
				bsr			EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

FCREATE:		bsr			BeginOs
				clr.w		-(sp)
				pea			(a2)
				move.w		#60,-(sp)
				trap		#1
				addq.w		#8,sp
				bsr			EndOs
				tst.l		d0
				bpl.s		.ende
				clr.w		HANDLE
				moveq		#-1,d0
				rts
.ende:			move.w		d0,HANDLE
				rts

*-------------------------------------------------------------------------------

FDELETE:		bsr			BeginOs
				pea			(a2)
				move.w		#65,-(sp)
				trap		#1
				addq.w		#6,sp
				bsr			EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

FGETDTA:		bsr			BeginOs
				move.l		d0,-(sp)
				move.w		#47,-(sp)
				trap		#1
				addq.w		#2,sp
				movea.l		d0,a0
				move.l		(sp)+,d0
				bsr			EndOs
				rts

*-------------------------------------------------------------------------------

FOPEN:			bsr			BeginOs
				move.w		d0,-(sp)				; Modus
				pea			(a2)					; Name
				move.w		#61,-(sp)
				trap		#1
				addq.w		#8,sp
				bsr			EndOs
				tst.l		d0
				bpl.s		.ende
				clr.w		HANDLE
				moveq		#-1,d0
				rts
.ende:			move.w		d0,HANDLE
				rts

*-------------------------------------------------------------------------------

FREAD:			bsr			BeginOs
				pea			(a3)
				move.l		d3,-(sp)
				move.w		HANDLE,-(sp)
				move.w		#63,-(sp)
				trap		#1
				lea			12(sp),sp
				cmp.l		d0,d3
				sne			d0
				bsr			EndOs
				tst.b		d0
				rts

*-------------------------------------------------------------------------------

FSEEK:			move.l		d4,-(sp)
				moveq		#0,d4				; vom Fileanfang
				bsr.s		SEEKEN
				move.l		(sp)+,d4
				cmp.l		d0,d3
				rts

FSEEK_END:		movem.l		d3-d4,-(sp)
				moveq		#0,d3				; Offset 0
				moveq		#2,d4				; vom Dateiende
				bsr.s		SEEKEN
				movem.l		(sp)+,d3-d4
				moveq		#0,d0
				rts

SEEKEN:			bsr			BeginOs
				move.w		d4,-(sp)			; Modus
				move.w		HANDLE,-(sp)		; Handle
				move.l		d3,-(sp)			; Offset
				move.w		#66,-(sp)
				trap		#1
				lea			10(sp),sp
				bsr			EndOs
				rts

*-------------------------------------------------------------------------------

FSETDTA:		bsr			BeginOs
				pea			(a3)
				move.w		#26,-(sp)
				trap		#1
				addq.w		#6,sp
				bsr			EndOs
				rts

*-------------------------------------------------------------------------------

FSFIRST:		bsr			BeginOs
				move.w		#%110111,-(sp)
				pea			(a2)
				move.w		#78,-(sp)
				trap		#1
				addq.w		#8,sp
				bsr			EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

FSNEXT:			bsr			BeginOs
				move.w		#79,-(sp)
				trap		#1
				addq.w		#2,sp
				bsr			EndOs
				tst.w		d0
				rts

*-------------------------------------------------------------------------------

FWRITE: 		bsr			BeginOs
				pea			(a3)
				move.l		d3,-(sp)
				move.w		HANDLE,-(sp)
				move.w		#64,-(sp)
				trap		#1
				lea			12(sp),sp
				cmp.l		d0,d3
				sne			d0
				bsr			EndOs
				tst.b		d0
				rts

*-------------------------------------------------------------------------------

* ---> A0.l = Pfad, Nullterminiert
PUT_SLASH:		move.l		a0,-(sp)
SEARCH_SLASH:	tst.b		(a0)+				; Stringende suchen
				bne.s		SEARCH_SLASH
				cmpi.b		#'\',-2(a0)
				beq.s		SLASH_SCHON_DA
				move.b		#'\',-1(a0)
				clr.b		(a0)
SLASH_SCHON_DA:	movea.l		(sp)+,a0
				rts
