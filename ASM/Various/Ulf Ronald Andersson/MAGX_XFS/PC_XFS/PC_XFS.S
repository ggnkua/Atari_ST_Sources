; pc_xfs.s vom 23.06.1996
;
; Autor:
; Thomas Binder
; (binder@rbg.informatik.th-darmstadt.de)
;
; Zweck:
; Assembler-Teil der Pure-C-Schnittstelle fÅr MagiC-3-Filesysteme.
; Alle Elemente der MX_XFS- und der MX_DEV-Struktur werden als Pure-
; C-kompatible Funktionsaufrufe realisiert. Bei den Funktionen der
; Schnittstellen, die mehr als ein Funktionsergebnis liefern, werden
; entsprechend temporÑre Long-Arrays zur Ablage der weiteren
; Ergebnisse bereitgestellt. Eine genau Beschreibung, wie diese
; Schnittstelle zu benutzen ist, findet sich in der Begleit-
; dokumentation.
;
; History:
; 04.11.-
; 05.11.1995: Erstellung
; 06.11.1995: "Frontends" fÅr die Kernel-Funktionen eingebaut, da
;             diese leider nicht alle fÅr Pure C nîtigen Register
;             retten (genauer: A2 kann verÑndert werden).
; 11.11.1995: my_sprintf korrigiert: Die Parameter werden jetzt
;             richtig auf dem Stack Åbergeben.
;             SÑmtliche Frontends der Kernelfunktionen waren falsch,
;             ein Wunder, daû das erst jetzt aufgefallen ist.
; 12.11.1995: fopen, xattr und attrib mÅssen wie sfirst bei Bedarf 
;             in a0 einen Zeiger auf einen symbolischen Link liefern,
;             daher wurden die entsprechenden Frontends angepaût.
; 23.11.1995: Fehler im Frontend fÅr sfirst beseitigt.
; 11.12.1995: Frontends fÅr die neuen Kernelfunktionen DMD_rdevinit
;             und proc_info geschrieben.
; 27.12.1995: Fehler entfernt, der zur Folge hatte, daû der Zeiger
;             auf my_int_malloc teilweise Åberschrieben wurde.
;             my_int_malloc hatte auûerdem bisher den RÅckgabewert
;             im falschen Register geliefert.
; 28.12.1995: chmod, chown und dcntl liefern bei Bedarf ebenfalls in
;             a0 einen Zeiger auf einen symbolischen Link, also
;             wurden die Frontends der beiden Funktionen erweitert.
; 31.12.1995: Der Frontend von path2DD wurde an das neue Parameter-
;             layout angepaût (siehe pc_xfs.h)
; 13.02.1996: Sourcecode aufgerÑumt und fertig kommentiert.
; 16.06.1996: Kein selbstmodifizierender Code mehr fÅr die Aufrufe
;             C-Funktionen als Subroutinen
; 23.06.1996: Wrapper fÅr neue Kernelfunktionen von MagiC 5
;             eingebaut: my_mxalloc, my_mfree und my_mshrink.

	include	"mgx_xfs.inc"
	include "pc_xfs.inc"

	export	install_xfs,real_xfs
	export	real_kernel

; Makro zum Retten von Registern. Als Parameter erhÑlt es eine Nummer
; und die zu rettenden Register im movem-Format; wird es nur mit
; Nummer benutzt, werden automatisch d1-d2/a0-a1 gerettet. a6 wird
; immer gerettet. Die Nummer hat dabei nur dann eine Bedeutung, wenn
; die erste Zeile des Makros aktiv ist (die standardmaessig durch
; if 0 ausgeklammert ist): Dann wird die Nummer als Long in 0x6f0
; abgelegt, was einem helfen kann, wenn es AbstÅrze gibt und man
; nicht weiû, welche XFS-Funktion nun betroffen ist.
macro pushr number,which
if 0
	move.l	#number,$6f0.w
endif
ifnb which
	movem.l	which/a6,-(sp)
else
	movem.l	d1-d2/a0-a1/a6,-(sp)
endif
endm

; Wie oben, nur ohne Nummer und zum ZurÅckholen der geretteten
; Register
macro popr which
ifnb which
	movem.l	(sp)+,which/a6
else
	movem.l	(sp)+,d1-d2/a0-a1/a6
endif
endm

	text

; install_xfs
;
; Diese Funktion Åbernimmt die Umsetzung der vom C-Programm
; gelieferten XFS-Struktur in das MagiC-Format, meldet das XFS dann
; an und bildet die C-Version der Kernelstruktur.
;
; Eingabe:
; a0: Zeiger auf die THE_MGX_XFS-Struktur, die angemeldet werden soll
;
; RÅckgabe:
; a0: Zeiger auf THE_MX_KERNEL-Struktur, wenn die Anmeldung geklappt
;     hat, sonst 0
module install_xfs
	import	the_xfs_sync,my_xfs,my_mx_kernel

	movem.l	a2-a3,-(sp)
	moveq	#0,d0
; Ist ein Nullzeiger Åbergeben worden, gleich abbrechen
	tst.l	a0
	beq.w	failure

; Ansonsten die einzelnen Funktionspointer und den Namen des XFS
; in die jeweiligen Zielstrukturen eintragen.
	lea		_xfs_name(a0),a2
	lea		the_xfs_sync,a3
	move.w	#_xfs_sync,d0
	moveq	#0,d1
copy_xfs:
	move.l	(a2,d0.w),(a3,d1.w)
	addq.w	#4,d1
	addq.w	#4,d0
	cmpi.w	#_xfs_end,d0
	bne.s	copy_xfs
	lea		_xfs_name(a0),a2
	lea		my_xfs,a3
	move.w	#7,d0
copy_name:
	move.b	(a2)+,(a3)+
	dbra	d0,copy_name

; Jetzt das XFS mit der "echten" Struktur per Dcntl anmelden, bei
; Fehler abbrechen
	pea		my_xfs
	clr.l	-(sp)
	move.w	#KER_INSTXFS,-(sp)
	move.w	#$130,-(sp)		; Dcntl
	trap	#1
	lea		12(sp),sp
	tst.l	d0
	bmi.s	failure

; Zeiger auf die tatsÑchliche Kernelstruktur speichern und die
; Variablen in die C-Struktur Åbertragen (auch wenn das C-Programm
; auf sie eigentlich nur Åber real_kernel zugreifen soll)
	move.l	d0,real_kernel
	move.l	d0,a0
	lea		my_mx_kernel,a1
	move.w	mxk_version(a0),mxk_version(a1)
	move.l	mxk_act_pd(a0),mxk_act_pd(a1)
	move.l	mxk_act_appl(a0),mxk_act_appl(a1)
	move.l	mxk_keyb_app(a0),mxk_keyb_app(a1)
	move.l	mxk_pe_slice(a0),mxk_pe_slice(a1)
	move.l	mxk_pe_timer(a0),mxk_pe_timer(a1)
	move.w	mxk_int_msize(a0),mxk_int_msize(a1)
	move.l	a1,d0
failure:
	move.l	d0,a0
	movem.l	(sp)+,a2-a3
	rts
endmod

; Es folgen jetzt die Routinen, die fÅr die einzelnen XFS-Funktionen
; tatsÑchlich angemeldet sind. Sie rufen die zugehîrigen C-Funktionen
; mit dem richtigen Parameterformat auf und wandeln ggf. die
; RÅckgabewerte in das vom Kernel erwartete Format um. Jede einzelne
; Funktion zu beschreiben schenke ich mir...
my_sync:
	pushr	1
	move.l	the_xfs_sync(pc),a6
	jsr		(a6)
	popr
	rts

my_pterm:
	pushr	2
	move.l	the_xfs_pterm,a6
	jsr		(a6)
	popr
	rts

my_garbcoll:
	pushr	3
	move.l	the_xfs_garbcoll,a6
	jsr		(a6)
	popr
	rts

my_freeDD:
	pushr	4
	move.l	the_xfs_freeDD,a6
	jsr		(a6)
	popr
	rts

my_drv_open:
	pushr	5
	move.l	the_xfs_drv_open,a6
	jsr		(a6)
	popr
	rts

my_drv_close:
	pushr	6
	move.l	the_xfs_drv_close,a6
	jsr		(a6)
	popr
	rts

my_path2DD:
	pushr	7,d2
	lea		-12(sp),sp
	pea		8(sp)
	pea		8(sp)
	pea		8(sp)
	move.l	the_xfs_path2DD,a6
	jsr		(a6)
	lea		12(sp),sp
	move.l	(sp)+,d1
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	popr	d2
	rts

my_sfirst:
	pushr	8,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	the_xfs_sfirst,a6
	jsr		(a6)
	addq.l	#8,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_snext:
	pushr	9,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_snext,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_fopen:
	pushr	10,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_fopen,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_fdelete:
	pushr	11
	move.l	the_xfs_fdelete,a6
	jsr		(a6)
	popr
	rts

my_link:
	pushr	12
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.w	d2,d0
	move.l	the_xfs_link,a6
	jsr		(a6)
	addq.l	#8,sp
	popr
	rts

my_xattr:
	pushr	13,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	the_xfs_xattr,a6
	jsr		(a6)
	addq.l	#8,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_attrib:
	pushr	14,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_attrib,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_chown:
	pushr	15,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_chown,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_chmod:
	pushr	16,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_chmod,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_dcreate:
	pushr	17
	move.l	the_xfs_dcreate,a6
	jsr		(a6)
	popr
	rts

my_ddelete:
	pushr	18
	move.l	the_xfs_ddelete,a6
	jsr		(a6)
	popr
	rts

my_DD2name:
	pushr	19
	move.l	the_xfs_DD2name,a6
	jsr		(a6)
	popr
	rts

my_dopendir:
	pushr	20
	move.l	the_xfs_dopendir,a6
	jsr		(a6)
	popr
	rts

my_dreaddir:
	pushr	21
	move.l	d2,-(sp)
	move.l	d1,-(sp)
	move.l	the_xfs_dreaddir,a6
	jsr		(a6)
	addq.l	#8,sp
	popr
	rts

my_drewinddir:
	pushr	22
	move.l	the_xfs_drewinddir,a6
	jsr		(a6)
	popr
	rts

my_dclosedir:
	pushr	23
	move.l	the_xfs_dclosedir,a6
	jsr		(a6)
	popr
	rts

my_dpathconf:
	pushr	24
	move.l	the_xfs_dpathconf,a6
	jsr		(a6)
	popr
	rts

my_dfree:
	pushr	25
	move.l	the_xfs_dfree,a6
	jsr		(a6)
	popr
	rts

my_wlabel:
	pushr	26
	move.l	the_xfs_wlabel,a6
	jsr		(a6)
	popr
	rts

my_rlabel:
	pushr	27
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	the_xfs_rlabel,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_symlink:
	pushr	28
	move.l	d0,-(sp)
	move.l	the_xfs_symlink,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_readlink:
	pushr	29
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	the_xfs_readlink,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_dcntl:
	pushr	30,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	the_xfs_dcntl,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

; Ab hier folgen die Routinen, die das AusfÅhren der Kernelfunktionen
; Åbernehmen und dabei dafÅr sorgen, daû die Register gerettet werden
my_fast_clrmem:
	pushr	31,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_fast_clrmem(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_toupper:
	pushr	32,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_toupper(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my__sprintf:
	move.l	4(sp),d0
	pushr	33,d3-d7/a2-a5
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	real_kernel,a6
	move.l	mxk__sprintf(a6),a6
	jsr		(a6)
	lea		12(sp),sp
	popr	d3-d7/a2-a5
	rts

my_appl_yield:
	pushr	34,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_appl_yield(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_appl_suspend:
	pushr	35,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_appl_suspend(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_appl_begcritic:
	pushr	36,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_appl_begcritic(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_appl_endcritic:
	pushr	37,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_appl_endcritic(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_evnt_IO:
	pushr	38,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_evnt_IO(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_evnt_mIO:
	pushr	39,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_evnt_mIO(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_evnt_emIO:
	pushr	40,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_evnt_emIO(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_appl_IOcomplete:
	pushr	41,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_appl_IOcomplete(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_evnt_sem:
	pushr	42,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_evnt_sem(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_Pfree:
	pushr	43,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_Pfree(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_int_malloc:
	pushr	44,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_int_malloc(a6),a6
	jsr		(a6)
	move.l	d0,a0
	popr	d3-d7/a2-a5
	rts

my_int_mfree:
	pushr	45,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_int_mfree(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_resv_intmem:
	pushr	46,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_resv_intmem(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_diskchange:
	pushr	47,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_diskchange(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_DMD_rdevinit:
	pushr	48,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_DMD_rdevinit(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_proc_info:
	pushr	49,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_proc_info(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_mxalloc:
	pushr	50,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_mxalloc(a6),a6
	jsr		(a6)
	move.l	d0,a0
	popr	d3-d7/a2-a5
	rts

my_mfree:
	pushr	51,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_mfree(a6),a6
	jsr		(a6)
	popr	d3-d7/a2-a5
	rts

my_mshrink:
	pushr	52,d3-d7/a2-a5
	move.l	real_kernel,a6
	move.l	mxk_mshrink(a6),a6
	jsr		(a6)
	move.l	d0,a0
	popr	d3-d7/a2-a5
	rts

	data

; Diese Struktur wird tatsÑchlich beim Kernel angemeldet und enthÑlt
; Zeiger auf die weiter oben zu findenen Aufrufroutinen
my_xfs:
	dc.b	0,0,0,0,0,0,0,0	; xfs_name
	dc.l	0				; xfs_next
	dc.l	0				; xfs_flags
	dc.l	0				; xfs_init
	dc.l	my_sync			; xfs_sync
	dc.l	my_pterm		; xfs_pterm
	dc.l	my_garbcoll		; xfs_garbcoll
	dc.l	my_freeDD		; xfs_freeDD
	dc.l	my_drv_open		; xfs_drv_open
	dc.l	my_drv_close	; xfs_drv_close
	dc.l	my_path2DD		; xfs_path2DD
	dc.l	my_sfirst		; xfs_sfirst
	dc.l	my_snext		; xfs_snext
	dc.l	my_fopen		; xfs_fopen
	dc.l	my_fdelete		; xfs_fdelete
	dc.l	my_link			; xfs_link
	dc.l	my_xattr		; xfs_xattr
	dc.l	my_attrib		; xfs_attrib
	dc.l	my_chown		; xfs_chown
	dc.l	my_chmod		; xfs_chmod
	dc.l	my_dcreate		; xfs_dcreate
	dc.l	my_ddelete		; xfs_ddelete
	dc.l	my_DD2name		; xfs_DD2name
	dc.l	my_dopendir		; xfs_dopendir
	dc.l	my_dreaddir		; xfs_dreaddir
	dc.l	my_drewinddir	; xfs_drewinddir
	dc.l	my_dclosedir	; xfs_dclosedir
	dc.l	my_dpathconf	; xfs_dpathconf
	dc.l	my_dfree		; xfs_dfree
	dc.l	my_wlabel		; xfs_wlabel
	dc.l	my_rlabel		; xfs_rlabel
	dc.l	my_symlink		; xfs_symlink
	dc.l	my_readlink		; xfs_readlink
	dc.l	my_dcntl		; xfs_dcntl

; Hier steht der Zeiger auf die beim Kernel angemeldete Struktur, den
; man fÅr das korrekte Belegen eines DMD braucht.
real_xfs:
	dc.l	my_xfs

; In diese Tabelle werden spÑter von install_xfs die Adressen der
; XFS-C-Funktionen eingetragen, um sie in den vorgeschalteten
; Assemblerroutinen ohne Offsetberechnungen anspringen zu kînnen.
the_xfs_sync:
	dc.l	0
the_xfs_pterm:
	dc.l	0
the_xfs_garbcoll:
	dc.l	0
the_xfs_freeDD:
	dc.l	0
the_xfs_drv_open:
	dc.l	0
the_xfs_drv_close:
	dc.l	0
the_xfs_path2DD:
	dc.l	0
the_xfs_sfirst:
	dc.l	0
the_xfs_snext:
	dc.l	0
the_xfs_fopen:
	dc.l	0
the_xfs_fdelete:
	dc.l	0
the_xfs_link:
	dc.l	0
the_xfs_xattr:
	dc.l	0
the_xfs_attrib:
	dc.l	0
the_xfs_chown:
	dc.l	0
the_xfs_chmod:
	dc.l	0
the_xfs_dcreate:
	dc.l	0
the_xfs_ddelete:
	dc.l	0
the_xfs_DD2name:
	dc.l	0
the_xfs_dopendir:
	dc.l	0
the_xfs_dreaddir:
	dc.l	0
the_xfs_drewinddir:
	dc.l	0
the_xfs_dclosedir:
	dc.l	0
the_xfs_dpathconf:
	dc.l	0
the_xfs_dfree:
	dc.l	0
the_xfs_wlabel:
	dc.l	0
the_xfs_rlabel:
	dc.l	0
the_xfs_symlink:
	dc.l	0
the_xfs_readlink:
	dc.l	0
the_xfs_dcntl:
	dc.l	0

; Dies ist die Kernelstruktur, die von install_xfs zurÅckgeliefert
; wird
my_mx_kernel:
	dc.w	0
	dc.l	my_fast_clrmem
	dc.l	my_toupper
	dc.l	my__sprintf
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	my_appl_yield
	dc.l	my_appl_suspend
	dc.l	my_appl_begcritic
	dc.l	my_appl_endcritic
	dc.l	my_evnt_IO
	dc.l	my_evnt_mIO
	dc.l	my_evnt_emIO
	dc.l	my_appl_IOcomplete
	dc.l	my_evnt_sem
	dc.l	my_Pfree
	dc.w	0
	dc.l	my_int_malloc
	dc.l	my_int_mfree
	dc.l	my_resv_intmem
	dc.l	my_diskchange
	dc.l	my_DMD_rdevinit
	dc.l	my_proc_info
	dc.l	my_mxalloc
	dc.l	my_mfree
	dc.l	my_mshrink

; Hier steht spÑter der Zeiger auf die echte Kernelstruktur
real_kernel:
	dc.l	0

; EOF
