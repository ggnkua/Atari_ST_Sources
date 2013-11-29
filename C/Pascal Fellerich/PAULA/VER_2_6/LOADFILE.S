*************************************************************************
*
*  LOADFILE.S
*  ----------
*
*  Load a MOD file, perform basic check and depack if necessary.
*
*
*
*  last modified: 26-oct-1992
*
*************************************************************************

				include "pdefs.inc"

; -----------------------------------------------------------------------
; Globals:
; -----------------------------------------------------------------------
;
; exported routines:
;
				xdef load_file
				
;
; imported Routines:
;
				xref alloc_fast_ram
				xref free_module
;
; imported Variables:
;
				xref mt_SongDataPtr 	;from ptreplay.s
				xref mt_SongEndPtr
;				xref registered			;from REGISTER.C


; -----------------------------------------------------------------------
; Code:
; -----------------------------------------------------------------------
				text

LZ5TABLE		equ (4+2)*1024				;dictionnary size + reserve

TESTMODE		equ 0


*
* little Fseek...
* d7: handle
file_seek:
		move.w	d1,-(sp)				;seekmode
		move.w	d7,-(sp)				;Handle
		clr.l	-(sp)					;Offset
		move.w	#Fseek,-(sp)
		trap	#1
		lea		10(sp),sp
		rts

*
* little Fread...
* d0: memory base
* d1: amount
* d7: handle
*
file_read:
		move.l	d0,-(sp)				;Membase
		move.l	d1,-(sp)				;amount
		move.w	d7,-(sp)				;Handle
		move.w	#Fread,-(sp)
		trap	#1
		lea 	12(sp),sp
		tst.l	d0						;test return code
		rts

*
* load_file: loads the MODfile whose name is pointed to by a0.
* - loads the file
* - checks the file
* - if '-lz5-' decompresses ist
* - allocs fastram
* returns ERRORCODE in d0.
*
load_file:
		movem.l d3-d7/a3-a5,-(sp)
		link	a6,#-20					;some room on stack
; open the file as read-only:
		clr.w	-(sp)					;Mode
		pea 	(a0)					;Filename
		move.w	#Fopen,-(sp)
		trap	#1
		addq.w	#8,sp
		move.w	d0,d7					;Handle in d7
		bmi		.open_error				;Abbruch.
		moveq	#0,d5					;fehlte in v2.1 !!! -> crash sometimes :-(
		
; get the file length:
		moveq	#2,d1					;FROM_END
		bsr		file_seek
		addq.l	#1,d0
		andi.w	#$FFFE,d0				;gerade machen!
		move.l	d0,d6					;Filelength -> d6
		moveq	#0,d1					;FROM_START
		bsr		file_seek				;reset file.
		cmpi.l	#1500,d6				;unter 1500 Bytes keine Modfile!
		ble		.no_modfile

; read file header to see if it's a -lz5- file.
		move.l	d6,d4					;plen = len
; --- only if registered ---
;		tst.b	registered+1
;		beq		.not_packed
		move.l	sp,d0					;base address
		moveq	#16,d1					;only header
		bsr		file_read				;read 16 bytes
		bmi		.read_error				;sorry, can't read file
		moveq	#0,d1					;FROM_START
		bsr		file_seek				;reset file.

		cmpi.b	#'-',6(sp)				;both packers?
		bne		.not_packed
		cmpi.l	#'-lz5',2(sp)			;larc?
		beq		.is_packed
		cmpi.l	#'-afx',2(sp)			;afx?
		bne		.not_packed				;normales laden....		
.is_packed:
		movep.w	14(sp),d4
		move.b	13(sp),d4
		swap	d4
		movep.w	12(sp),d4
		move.b	11(sp),d4				;unpacked file length
		addq.l	#1,d4
		andi.w	#$fffe,d4				;make even!!!!

		move.l	d4,d0					;length div 16
		lsr.l	#4,d0					;length div 16
		move.l	d0,d1
		lsr.l	#1,d1					;length div 32
		add.l	d1,d0					;d0: length div 10.66
		add.l	#LZ5TABLE,d0			;plus unpack Table RAM 4Kbyte
		andi.w	#$fffe,d0				;even!
		move.l	d0,-8(a6)				;bonusbytes!
		add.l	d0,d4					;total length
		
;		move.w	registered(pc),d5		;Flag: it's packed!
		st		d5
		cmp.l	d6,d4					;pack/unpack ratio
		bmi		.no_modfile				;Fehler!

.not_packed:
		move.l	d4,d0					;LÑnge des Bereiches
		move.l	d4,-4(a6)				;fÅr spÑter merken!
		addq.l	#8,d0					;4 bonus bytes
		bsr 	alloc_fast_ram			;try to get some fastram!
		tst.l	d0
		beq.s	.low_memory				;kein Speicher mehr da :-(

; Player langsam auf kommende Datei vorbereiten:
		move.l	d0,mt_SongDataPtr		;YEAH!
		move.l	d0,a5					;destination fÅr Unpacker
		adda.l	d4,a0					;Zum Pufferstart addieren
		clr.l	(a0)+					;4 Bonusbytes lîschen
		move.l	a0,mt_SongEndPtr		;und ModFileEnd hochsetzen

		sub.l	d6,d4					;Differenz zwischen pack/unpack
		add.l	d4,d0					;-> Startadresse!
		movea.l	d0,a4					;data base for unpacker
		move.l	d6,d1					;real file length
		bsr		file_read
		tst.l	d0						;Check for errors
		bmi.s	.read_error
		tst.b	d5						;packed file?
		beq.s	.all_done
		bsr		unpack_lz5
		move.l	-8(a6),d0				;additional bytes
		lea		mt_SongEndPtr,a0
		neg.l	d0
		add.l	d0,(a0)					;decrement Song Endpointer
		movea.l	(a0),a0					;get endpointer
		clr.l	-4(a0)					;clear last lword (4 bonus bytes)
		movea.l	mt_SongDataPtr,a1		;start pointer
;	add.l	-4(a6),d0				;new blocksize
;	addq.l	#8,d0
;	move.l	d0,-(sp)
;	move.l	mt_SongDataPtr,-(sp)	;Block Address
		suba.l	a1,a0					;calculate new block size
		pea		(a0)					;push block size
		addq.l	#4,(sp)					;increment blksize by 4 for safety
		pea		(a1)					;push block address
		clr.w	-(sp)
		move.w	#Mshrink,-(sp)			;Block runterkÅrzen!
		trap	#1
		lea		12(sp),sp
.all_done:
		moveq	#E_OK,d0
.exit_close:
		move.l	d0,-(sp)				;Fehlercode merken
		move.w	d7,-(sp)				;Close file & bye bye
		move.w	#Fclose,-(sp)
		trap	#1
		addq.w	#4,sp					;Fclose sollte immer klappen
		move.l	(sp)+,d0				;Fehlercode zurÅck!
.exit_load:
		unlk	a6
		movem.l (sp)+,d3-d7/a3-a5
		rts

; Error during Fopen()
.open_error:
		cmpi.w	#-20,d0					;BIOS Errors?
		bge.s	.bios_error
		moveq	#E_FILENOTFOUND,d0
		bra.s	.exit_load 				;Exit, nothing to close !
.bios_error:
		moveq	#E_PHYSDRIVE,d0
		bra.s	.exit_load
		
; out of memory :-(
.low_memory:
		moveq	#E_MEMORY,d0
		bra.s	.exit_close 			;now close & exit !

; bullshit loaded:
.no_modfile:
		moveq	#E_MODFILE,d0
		bra.s	.exit_close

; Error during Fread()-call: free the module & return Error!
.read_error:
		bsr		free_module
		moveq	#E_PHYSDRIVE,d0
		bra.s	.exit_close


;
; larc unpacker:
;
; input:	a4 = packed data
; 			a5 = destination
;
unpack_lz5:
		move.l	d7,-(sp)
		move.l	#$20202020,d0
		move.w	#1024-1,d1
		move.l	a5,a2			;Adresse merken
.loop:	move.l	d0,(a5)+		;lz5-Tabelle 4KB auffÅllen mit Spaces
		dbra	d1,.loop
		
hdr_l0005:
        movep.w 14(a4),d4
        move.b  13(a4),d4
        swap    d4
        movep.w 12(a4),d4
        move.b  11(a4),d4      ;unpacked file length
		move.l	d4,d2
		
        moveq   #2,d0
        add.b   (a4),d0			;add Header length + 2 
        adda.w  d0,a4			;data start
        movea.l a5,a3			;destination
        moveq   #0,d7
        move.l  a5,d5
        sub.l   #$0fed,d5		; 4077 abziehen
        move.w  #$0fff,d3
        dbra    d7,hdr_l0008
hdr_l0007:

	if TESTMODE
	cmp.l a5,a4
	bcc	.ok
	illegal
.ok:
	endc
	
        move.b  (a4)+,d6		;hole Datenbyte
        moveq   #7,d7
hdr_l0008:
        lsr.b   #1,d6
        bcc.s   hdr_l0009
        move.b  (a4)+,(a5)+		;copy data
        subq.l  #1,d4
        ble.s   hdr_l000b		;Abbruch wenn fertig
        dbra    d7,hdr_l0008
        bra.s   hdr_l0007
hdr_l0009:
        movep.w 1(a4),d0		
        lsr.w   #4,d0
        move.b  (a4)+,d0
        move.l  a5,d1			;zielstelle...
        sub.l   d5,d1			;Offset wiedergewinnen (in 4096 byte table)
        and.w   d3,d1			;12 bit
        sub.w   d1,d0			
        neg.w   d0
        and.w   d3,d0
        neg.w   d0
        lea     -1(a5,d0.w),a0
        moveq   #$0f,d1
        and.b   (a4)+,d1
        addq.w  #2,d1
        moveq   #1,d0
        add.w   d1,d0
hdr_l000a:
        move.b  (a0)+,(a5)+
        dbra    d1,hdr_l000a

	if TESTMODE
	cmp.l a5,a4
	bcc	.ok
	illegal
.ok:
	endc
        sub.l   d0,d4
        ble.s   hdr_l000b
        dbra    d7,hdr_l0008
        bra.s   hdr_l0007
hdr_l000b:
		lea		4096(a2),a1			;MOD ans Ziel kopieren!
.loop:	move.l	(a1)+,(a2)+
		subq.l	#4,d2
		bpl.s	.loop
		move.l	(sp)+,d7
		rts

;--<eof>----------------------------------------------------------------
