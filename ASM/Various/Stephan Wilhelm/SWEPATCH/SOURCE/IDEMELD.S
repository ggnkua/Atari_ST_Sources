; Dieser Patch verÑndert folgende Bereiche der Bootroutine:

; Bildschirmausgabe des Bootlaufwerks 

; Patch des Rootprogramms von HDDRIVER fÅr Atapi-Laufwerke
; Normalerweise werden IDE-Laufwerke vom Rootprogramm direkt angesprochen.
; Das ist aber nicht nîtig,da TOS3.06 bereits die Funktion DMAREAD() mit
; IDE-UnterstÅtzung bietet.Auûerdem lassen sich Atapi-Laufwerke mit den
; IDE-Routinen des Rootprogramms nicht korrekt ansprechen. Daher wird die
; Abfrage auf IDE aus dem Rootprogramm entfernt,damit die Funktion DMAREAD()
; benutzt wird.Die Funktion DMAREAD() muû zusÑtzlich fÅr ATAPI-Laufwerke
; modifiziert werden.DafÅr ist der Patch ATAPI.S anzuwenden. 

	  org 	$7fe60400

	  movem.l	d0-a6,-(sp)
	  move.w	d4,-(sp)
	  pea   	lfwtxt(pc)
	  move.w	#9,-(sp)
	  trap	        #1
	  addq.w	#6,sp
          move.w        #-1,-(sp) 
          move.w        #11,-(sp)    ; KBSHIFT 
          trap          #13 
          addq.l        #4,a7 
          btst          #3,d0        ; ALT-Taste gedrÅckt ?
          beq.s         nfloppy      ; dann dorthin...
          addq.l        #2,sp
          pea	        floppytxt(pc)    ; boot von floppy melden
          bra.s         txtout2
nfloppy:  move.w	(sp),d4
          cmp.b	        #8,d4
	  bge.s		noacsi
	  move.w	#48,-(sp)
	  pea		acsitxt(pc)      ; boot von ACSI melden 
	  bra.s		txtout1
noacsi:	  cmp.b		#$10,d4
	  bge.s		noscsi
	  move.w	#40,-(sp)
	  pea		scsitxt(pc)      ; boot von SCSI melden
	  bra.s		txtout1
noscsi:	  move.w	#32,-(sp)
	  pea		idetxt(pc)       ; boot von IDE melden
txtout1:  move.w	#9,-(sp)
	  trap		#1
	  addq.w	#6,sp
	  move.w	(sp)+,d0
	  move.w	(sp)+,d4
	  add.b		d4,d0
	  move.w	d0,-(sp)
	  move.w	#2,-(sp)
	  move.w	#3,-(sp)
	  trap		#13
	  addq.w	#6,sp
	  pea		extext(pc)
txtout2:  move.w	#9,-(sp)
	  trap		#1
	  addq.w	#6,sp
	  movem.l	(sp)+,d0-a6
	  movea.l	$4c6,a0
          cmp.w   	#$0804,$be(a0)      ; Rootprogramm von HDDRIVER ? 
          bne.s   	ndmaptch            ; wenn nein,kein patch
          cmp.l   	#$00046614,$c0(a0)  ; Rootprogramm von HDDRIVER ? 
          bne.s   	ndmaptch            ; wenn nein,kein patch
          move.w  	#$4e71,$be(a0)      ; nop einsetzen fÅr Zugriff via DMAREAD 
          move.l  	#$4e714e71,$c0(a0)  ; nop einsetzen fÅr Zugriff via DMAREAD
ndmaptch: move.l	#$444d4172,d3
	  jmp		$7fe00b9e

lfwtxt:		dc.b 13,10
		dc.b "boot"
		dc.b " from "
		dc.b 0,0
acsitxt:	dc.b "ACSI",0,0
scsitxt:	dc.b "SCSI",0,0
idetxt:		dc.b "IDE",0
floppytxt:      dc.b "FLOPPY"
                dc.b " ..."
                dc.b 13,10,0,0
extext:		dc.b " ...",13,10,0,0

