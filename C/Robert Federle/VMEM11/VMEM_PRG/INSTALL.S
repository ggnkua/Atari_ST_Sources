		EXPORT exit
		EXPORT errno

		IMPORT cj_insert
		IMPORT vm_config, vm_close, vm_info, vm_alloc
		IMPORT vm_free, vm_address, vm_fill, vm_copy
		IMPORT vm_load, vm_save, vm_write, vm_read

ILLEGAL_FUNCTION	equ -$1234

start:
		movea.l	4(sp),a6		; Basepageadresse holen
		movea.w	#$100+$200,a5	; Gr”že der Basepage + Stackgr”že (512 Byte)
		adda.l	12(a6),a5		; + Gr”že des TEXT-Segments
		adda.l	20(a6),a5		; + Gr”že des DATA-Segments
		adda.l	28(a6),a5		; + Gr”že des BSS-Segments
		move.l	a5,d1			; = Gesamtl„nge des Programms
		and.w	#$FFFE,d1		; L„nge nun gerade
		add.l	a6,d1			; + Programmstart (Basepageadresse)
		move.l	d1,sp			; Stack endet dort
		clr.w	-(sp)			; Returncode = 0
		move.l	a5,-(sp)		; Programml„nge

		bsr.b	install			; Routinen installieren
		bne.b	exit

		pea		mess_ok(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#$31,-(sp)		; Funktionsnummer
		trap	#1				; Ptermres (Prgl„nge, Retcode)

exit:
		move.w	d0,-(sp)		; Retcode
		move.w	#$4c,-(sp)
		trap	#1				; Pterm (Retcode)

install:
		move.l	#"VMEM",d0		; Cookie-Name
		move.l	#service,d1		; Adresse der Service-Routine
		jsr		cj_insert		; Cookie einfgen
		tst.w	d0
		rts

service:
		cmp.w	#12,d7			; Funktionsnummer steht in D7
		bhs.b	_illegal		; >= 12, dann Fehler
		add.w	d7,d7			; Nummer * 4
		add.w	d7,d7
		lea		tab(pc,d7.l),a1	; Zeiger auf Tabelle
		move.l	(a1),a1			; Adresse der Funktion holen
		jmp		(a1)			; Funktion aufrufen

_illegal:
vm_copy:
		move.w	#ILLEGAL_FUNCTION,d0
		rts

tab:
		dc.l vm_config, vm_close, vm_info, vm_alloc
		dc.l vm_free, vm_address, vm_fill, vm_copy
		dc.l vm_load, vm_save, vm_write, vm_read

mess_ok:
		dc.b 13,10,"************************************"
		dc.b 13,10,"*  Virtual Memory V1.1 installed.  *"
		dc.b 13,10,"************************************",13,10,0
		EVEN
errno:
		dc.w 0
