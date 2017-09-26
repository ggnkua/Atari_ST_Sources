.export new_gemdostrap
.export old_gemdostrap
.export dos_info
.export nach_gemdostrap
.import gemdos_trace
.import gemdos_is_traced
.import show_gemdosreturns
.import ret_semaphore
.import akt_ret
.import ret
.import my_200hz
.import p_run
.import get_prg

.BSS
.EVEN
DOS_MAX_REENTRANCE = 32
DOS_INFO_SIZE = 24
; 6 longs (0:basepage/4:old_return/8:verbogener_return/12:parameterstack/16:prcname/20:appname)
dos_info: ds.b (DOS_INFO_SIZE*DOS_MAX_REENTRANCE)
dos_sem: ds.w 1

.TEXT
.EVEN
.SUPER

/********* Neuer Gemdos-Trap (trap #1) ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_gemdostrap: ds.l 1
new_gemdostrap:
	movem.l d0-a6,-(sp)
	move.l usp,a0
	btst.b #5,(8+7)*4(sp)	; SR am Stack: Aufruf aus User-Mode?
	beq.s have_stack			; Dann ist USP der richtige Stack
	lea.l (8+7)*4+6(sp),a0	; Ansonsten Stackabschnitt mit Parametern in a0
	tst.w $59e					; longframe?
	beq.s have_stack
	addq.l #2,a0
have_stack:

	move.l a0,-(sp)
	bsr gemdos_trace			; LOG-Ausgaben!!!
	move.l (sp)+,d1			; Parameter-Stack

	tst.w gemdos_is_traced
	beq.s dostrap_shownoreturns

	tst.w show_gemdosreturns
	beq.s dostrap_shownoreturns

	move.l d1,a0
	move.w (a0),d2				; Opcode
	tst.w d2						; Opcode 0: Pterm0
	beq.s dostrap_shownoreturns
	cmp.w #76, d2				; Opcode 76: Pterm
	beq.s dostrap_shownoreturns
	cmp.w #49, d2				; Opcode 49: Ptermres
	beq.s dostrap_shownoreturns

	move.l p_run,a0
	move.l (a0),a0				; Basepage

	tas.b dos_sem			; Semaphore testen und setzen
	bne.s dostrap_shownoreturns

	lea.l dos_info,a2			; Tabelle
	moveq #DOS_MAX_REENTRANCE-1,d0
dos_such_eintrag1:
	tst.l (a2)					; leer?
	beq.s dostrap_found		; dann gleich benutzen
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s dostrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #DOS_INFO_SIZE,a2	; n„chster Eintrag
	dbra d0, dos_such_eintrag1

	bra.s dostrap_shownoreturns	; Tabelle ist leider voll -> kein Returnwert

dostrap_found:
	move.l a2,a1				; Dieser Eintrag ist leer -> merken!
dos_such_eintrag2:
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s dostrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #DOS_INFO_SIZE,a2	; n„chster Eintrag
	dbra d0,dos_such_eintrag2

; Eintrag gefunden (a1)

	move.l a0,(a1)+							; Basepage in erstes long
	clr.b dos_sem			; Semaphore freigeben
	lea.l (8+7)*4+2(sp),a2					; Zeiger auf zu verbiegende Return-Adresse
	move.l (a2),(a1)+							; alte Return-Adresse in zweites long
	move.l a2,(a1)+							; Adresse des verbogenen Returnwerts (fr etv_term) in drittes long
	move.l d1,(a1)+							; Parameter-Stack in viertes long
	move.l #nach_gemdostrap,(a2)			; Return verbiegen

; get_prg: a0: BASPAG*, d0:aesid, a1:char**prcname, (sp):char**appname

														; a1 zeigt auf fnftes long (prc_name)
	; nix zu tun									; a0: zeigt auf Basepage
	moveq.l #-1,d0									; d0: aesid = -1
	addq.l #4,a1									; sechstes long: app_name
	move.l a1,-(sp)								; ...auf Stack
	subq.l #4,a1									; a1: prc_name = fnftes long
	bsr get_prg
	addq.l #4,sp

dostrap_shownoreturns:
	clr.b dos_sem			; Semaphore freigeben
	movem.l (sp)+,d0-a6
ende_gemdostrap:
	move.l old_gemdostrap, -(sp)
	rts									; in Trap "reingehen"

.USER

nach_gemdostrap:						; hier kommt man evtl. wieder raus!
	subq.l #4,sp						; Platz fr alten Returncode
	movem.l d1/a0-a4,-(sp)

	move.l p_run,a0
	move.l (a0),a0				; Basepage
	lea.l dos_info,a1			; Tabelle
nach_dos_such_eintrag:
	cmp.l (a1),a0				; Eintrag gefunden?
	beq.s nach_dos_found
	add.l #DOS_INFO_SIZE,a1	; n„chster Eintrag
	bra.s nach_dos_such_eintrag
nach_dos_found:

	move.w sr,d1
	lsr.w #8,d1
dos_semaphore_wait:
	tas.b ret_semaphore			; Semaphore testen und setzen
	beq.s dos_semaphore_free
	btst.b #5,d1					; User-Mode?
	beq.s dos_semaphore_wait	; Dann warten, bis Semaphore frei ist

	bra ende_nach_gemdostrap	; Returnwert geht jetzt leider nicht

dos_semaphore_free:

	move.w akt_ret,d1			; aktueller Return-Zaehler
	addq.w #1,akt_ret			; Z„hler hochz„hlen

	and.l #$f,d1				; Ring
	lsl.l #8,d1					; * 256 (sizeof(RETURN))
	lea.l ret,a0				; Adresse Return-Tabelle
	adda.l d1,a0				; aktueller Eintrag

	tst.w (a0)					; state != RET_EMPTY ? -> Ringpuffer voll!
	beq.s nach_gemdostrap_ok	; noch Platz

	subq.w #1,akt_ret			; kein Platz mehr -> wieder zurckz„hlen
	clr.b ret_semaphore		; Semaphore freigeben
	bra.s ende_nach_gemdostrap	; raus!

nach_gemdostrap_ok:			; noch Platz
	move.l 12(a1),a3					; Parameter-Stack
	move.l a0,a2				; Anfang auch in a2 merken
	move.w #1,(a0)+					; ret->state: RET_BUSY eintragen
	clr.b ret_semaphore		; Semaphore freigeben

	move.l my_200hz,(a0)+			; ret->hz200
	move.w #2,(a0)+					; ret->typ: RET_GEMDOS
	move.l d0,(a0)+					; ret->ret: d0
	move.l (a1),(a0)+					; ret->bas
	move.w #-1,(a0)+					; ret->pid bei Gemdos immer -1
	move.w (a3),(a0)+					; ret->opcode (vom Parameter-Stack)

	add.l #10,a0						; AES-Zeugs berspringen, ret->prc_name
	move.l a0,a3						; ret->prc_name zum kopieren
	move.l 16(a1),a4						; prcname
	tst.l a4
	beq.s dos_no_prc_strcpy
	moveq.l #11,d1						; maximal 12 Zeichen kopieren
dos_prc_strcpy:
	move.b (a4)+,(a3)+				; in ret->prc_name kopieren
	beq.s dos_no_prc_strcpy
	dbra d1,dos_prc_strcpy
dos_no_prc_strcpy:
	clr.b (a3)							; ret->prc_name: 0-Byte am Ende

	add.l #13,a0						; ret->app_name
	move.l 20(a1),a4						; appname
	tst.l a4
	beq.s dos_no_app_strcpy
	moveq.l #7,d1						; maximal 8 Zeichen kopieren
dos_app_strcpy:
	move.b (a4)+,(a0)+				; in ret->app_name kopieren
	beq.s dos_no_app_strcpy
	dbra d1,dos_app_strcpy
dos_no_app_strcpy:
	clr.b (a0)							; ret->app_name: 0-Byte am Ende

	move.w #2,(a2)						; state: RET_READY eintragen

ende_nach_gemdostrap:
	move.l 4(a1),(6*4)(sp)			; alten Returnwert auf Stack
	clr.l (a1)							; Eintrag wird wieder frei
	movem.l (sp)+,d1/a0-a4			; Register wiederherstellen

	rts									; endgltig zurckspringen
