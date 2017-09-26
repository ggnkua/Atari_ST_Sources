.export new_gemtrap
.export old_gemtrap
.export aes_info
.export nach_aestrap
.export vdi_info
.export nach_vditrap
.import aes_trace
.import vdi_trace
.import show_aesreturns
.import show_vdireturns
.import aes_is_traced
.import vdi_is_traced
.import ret_semaphore
.import akt_ret
.import ret
.import my_200hz
.import p_run
.import get_prg

.BSS
.EVEN
AES_MAX_REENTRANCE = 64
AES_INFO_SIZE = 24
; 6 longs (0:basepage/4:old_return/8:verbogener_return/12:AESPB/16:prgname/20:appname)
aes_info: ds.b (AES_INFO_SIZE*AES_MAX_REENTRANCE)
aes_sem: ds.w 1

VDI_MAX_REENTRANCE = 32
VDI_INFO_SIZE = 26
; 6 longs, 1 int (0:basepage/4:old_return/8:verbogener_return/12:VDIPB/16:prgname/20:appname/24:outarrays)
vdi_info: ds.b (VDI_INFO_SIZE*VDI_MAX_REENTRANCE)
vdi_sem: ds.w 1

.TEXT
.EVEN
.SUPER

/********* Neuer GEM-Trap (trap #2) ***********/

dc.l 'XBRA'
dc.l 'MANI'
old_gemtrap: ds.l 1
new_gemtrap:

	cmp.w #200,d0		; AES?
	beq is_aes
	cmp.w #115,d0		; VDI?
	bne ende_vditrap

/********* Neuer VDI-Trap ***********/

is_vdi:
	movem.l d0-a6,-(sp)
	move.l d1,-(sp)
	move.l d1,a0		; Zeiger auf VDIPB
	bsr vdi_trace		; LOG-Ausgaben!!!
; in d0: Bit 0: intout gltig, Bit 1: ptsout gltig !
	move.l (sp)+,a3	; VDIPB jetzt in a3

	tst.w vdi_is_traced
	beq.s vditrap_shownoreturns

	tst.w show_vdireturns
	beq.s vditrap_shownoreturns

	move.l p_run,a0
	move.l (a0),a0				; Basepage

	tas.b vdi_sem			; Semaphore testen und setzen
	bne.s vditrap_shownoreturns

	lea.l vdi_info,a2			; Tabelle
	moveq #VDI_MAX_REENTRANCE-1,d1
vdi_such_eintrag1:
	tst.l (a2)					; leer?
	beq.s vditrap_found		; gefunden -> merken
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s vditrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #VDI_INFO_SIZE,a2	; n„chster Eintrag
	dbra d1, vdi_such_eintrag1

	bra.s vditrap_shownoreturns	; Tabelle ist leider voll -> kein Returnwert

vditrap_found:
	move.l a2,a1				; Dieser Eintrag ist leer -> merken!
vdi_such_eintrag2:
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s vditrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #VDI_INFO_SIZE,a2	; n„chster Eintrag
	dbra d1, vdi_such_eintrag2

; Eintrag gefunden (a1)

	move.l a0,(a1)+							; Basepage in erstes long
	clr.b vdi_sem			; Semaphore freigeben
	lea.l (8+7)*4+2(sp),a2					; Zeiger auf zu verbiegende Return-Adresse

	move.l (a2),(a1)+							; alte Return-Adresse in zweites long
	move.l a2,(a1)+							; Adresse des verbogenen Returnwerts (fr etv_term) in drittes long
	move.l a3,(a1)+							; VDIPB-Stack in viertes long
	move.l #nach_vditrap,(a2)				; Return verbiegen
	move.w d0,8(a1)							; d0 in "outarrays"

; get_prg: a0: BASPAG*, d0:aesid, a1:char**prcname, (sp):char**appname
														; a1 zeigt auf fnftes long (prc_name)
	; nix zu tun									; a0: zeigt auf Basepage
	moveq.l #-1,d0									; d0: aesid = -1
	addq.l #4,a1									; sechstes long: app_name
	move.l a1,-(sp)								; ...auf Stack
	subq.l #4,a1									; a1: prc_name = fnftes long
	bsr get_prg
	addq.l #4,sp


vditrap_shownoreturns:
	clr.b vdi_sem			; Semaphore freigeben
	movem.l (sp)+,d0-a6
ende_vditrap:
	move.l old_gemtrap, -(sp)
	rts								; in Trap "reingehen"


.USER


nach_vditrap:						; hier kommt man evtl. wieder raus!
	subq.l #4,sp					; Platz fr alten Returncode
	movem.l d1/a0-a5,-(sp)

	move.l p_run,a0
	move.l (a0),a0				; Basepage

	lea.l vdi_info,a1			; Tabelle
nach_vdi_such_eintrag:
	cmp.l (a1),a0				; Eintrag gefunden?
	beq.s nach_vdi_found
	add.l #VDI_INFO_SIZE,a1	; n„chster Eintrag
	bra.s nach_vdi_such_eintrag
nach_vdi_found:

	move.w sr,d1
	lsr.w #8,d1
vdi_semaphore_wait:
	tas.b ret_semaphore			; Semaphore testen und setzen
	beq.s vdi_semaphore_free
	btst.b #5,d1					; User-Mode?
	beq.s vdi_semaphore_wait	; Dann warten, bis Semaphore frei ist

	bra ende_nach_vditrap	; Returnwert geht jetzt leider nicht

vdi_semaphore_free:

	move.w akt_ret,d1			; aktueller Return-Zaehler
	addq.w #1,akt_ret			; Z„hler hochz„hlen

	and.l #$f,d1				; Ring
	lsl.l #8,d1					; * 256 (sizeof(RETURN))
	lea.l ret,a0				; Adresse Return-Struktur
	adda.l d1,a0				; aktueller Eintrag

	tst.w (a0)					; state != RET_EMPTY ? -> Ringpuffer voll!
	beq.s nach_vditrap_ok	; noch Platz

	subq.w #1,akt_ret			; kein Platz mehr -> wieder zurckz„hlen
	clr.b ret_semaphore		; Semaphore freigeben
	bra ende_nach_vditrap	; raus!

nach_vditrap_ok:				; noch Platz
	move.l 12(a1),a3			; VDIPB
	move.l a0,a2				; Anfang auch in a2 merken
	move.w #1,(a0)+			; ret->state: RET_BUSY eintragen
	clr.b ret_semaphore		; Semaphore freigeben

	move.l my_200hz,(a0)+			; ret->hz200
	move.w #3,(a0)+					; ret->typ: RET_VDI
	addq.l #4,a0						; kein ret->ret
	move.l (a1),(a0)+					; ret->bas
	move.w #-1,(a0)+					; ret->pid bei VDI immer -1
	move.l (a3),a4							; contrl-Array
	move.w (a4)+,(a0)+				; ret->opcode (contrl[0])
	move.w (a4),(a0)+					; ret->contrl1 (contrl[1])
	move.w 4(a4),(a0)+				; ret->contrl3 (contrl[3])
	move.w 8(a4),(a0)+				; ret->contrl5 (contrl[5])
	addq.l #4,a0						; ret->intin0/ret->intin1 berspringen

	move.l a0,a5						; ret->prc_name zum kopieren
	move.l 16(a1),a4						; prcname
	tst.l a4
	beq.s vdi_no_prc_strcpy
	moveq.l #11,d1						; maximal 12 Zeichen kopieren
vdi_prc_strcpy:
	move.b (a4)+,(a5)+				; in ret->prc_name kopieren
	beq.s vdi_no_prc_strcpy
	dbra d1,vdi_prc_strcpy
vdi_no_prc_strcpy:
	clr.b (a5)							; ret->prc_name: 0-Byte am Ende

	add.l #13,a0						; ret->app_name
	move.l a0,a5						; ret->app_name zum kopieren
	move.l 20(a1),a4						; appname
	tst.l a4
	beq.s vdi_no_app_strcpy
	moveq.l #7,d1						; maximal 8 Zeichen kopieren
vdi_app_strcpy:
	move.b (a4)+,(a5)+				; in ret->app_name kopieren
	beq.s vdi_no_app_strcpy
	dbra d1,vdi_app_strcpy
vdi_no_app_strcpy:
	clr.b (a5)							; ret->app_name: 0-Byte am Ende

	add.l #9,a0							; ret->intout

	move.w 24(a1),d1						; outarray-Bits

	btst #0,d1
	beq.s vdi_no_intout
	move.l 12(a3),a4						; intout-Array
	move.l (a4)+,(a0)+				; ret->intout[0/1]
	move.l (a4)+,(a0)+				; ret->intout[2/3]
	move.l (a4)+,(a0)+				; ret->intout[4/5]
	move.l (a4)+,(a0)+				; ret->intout[6/7]
	move.l (a4)+,(a0)+				; ret->intout[8/9]
	move.l (a4)+,(a0)+				; ret->intout[10/11]
	move.l (a4)+,(a0)+				; ret->intout[12/13]
	move.l (a4)+,(a0)+				; ret->intout[14/15]
	bra.s vdi_ptsout
vdi_no_intout:
	add.l #32,a0

vdi_ptsout:
	btst #1,d1
	beq.s vdi_no_ptsout
	move.l 16(a3),a4						; ptsout-Array
	move.l (a4)+,(a0)+				; ret->ptsout[0/1]
	move.l (a4)+,(a0)+				; ret->ptsout[2/3]
	move.l (a4)+,(a0)+				; ret->ptsout[4/5]
	move.l (a4)+,(a0)+				; ret->ptsout[6/7]
	move.l (a4)+,(a0)+				; ret->ptsout[8/9]
	move.l (a4)+,(a0)+				; ret->ptsout[10/11]
	move.l (a4)+,(a0)+				; ret->ptsout[12/13]
	move.l (a4)+,(a0)+				; ret->ptsout[14/15]
	move.l (a4)+,(a0)+				; ret->ptsout[16/17]
	move.l (a4)+,(a0)+				; ret->ptsout[18/19]
	move.l (a4)+,(a0)+				; ret->ptsout[20/21]
	move.l (a4)+,(a0)+				; ret->ptsout[22/23]
	move.l (a4)+,(a0)+				; ret->ptsout[24/25]
	move.l (a4)+,(a0)+				; ret->ptsout[26/27]
	move.l (a4)+,(a0)+				; ret->ptsout[28/29]
	move.l (a4)+,(a0)+				; ret->ptsout[30/31]
	bra.s vdi_ptsout_ok
vdi_no_ptsout:
	add.l #64,a0

vdi_ptsout_ok:

	move.l (a3),a4							; contrl-Array
	move.w 12(a4),(a0)+				; ret->contrl6 (contrl[6])

	move.w #2,(a2)						; state: RET_READY eintragen

ende_nach_vditrap:
	move.l 4(a1),(7*4)(sp)			; alten Returnwert auf Stack
	clr.l (a1)							; Eintrag wird wieder frei
	movem.l (sp)+,d1/a0-a5			; Register wiederherstellen

	rts									; endgltig zurckspringen



/********* Neuer AES-Trap ***********/

.SUPER

is_aes:
	movem.l d0-a6,-(sp)
	move.l d1,-(sp)
	move.l d1,a0		; Zeiger auf AESPB
	bsr aes_trace		; LOG-Ausgaben!!! 
	move.l (sp)+,a3	; AESPB jetzt in a3

	tst.w aes_is_traced
	beq.s aestrap_shownoreturns

	tst.w show_aesreturns
	beq.s aestrap_shownoreturns

	move.l p_run,a0
	move.l (a0),a0				; Basepage

	tas.b aes_sem			; Semaphore testen und setzen
	bne.s aestrap_shownoreturns

	lea.l aes_info,a2			; Tabelle
	moveq #AES_MAX_REENTRANCE-1,d0
aes_such_eintrag1:
	tst.l (a2)					; leer?
	beq.s aestrap_found		; dann benutzen
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s aestrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #AES_INFO_SIZE,a2	; n„chster Eintrag
	dbra d0,aes_such_eintrag1

	bra.s aestrap_shownoreturns	; Tabelle ist leider voll -> kein Returnwert

aestrap_found:
	move.l a2,a1				; Dieser Eintrag ist leer -> merken!
aes_such_eintrag2:
	cmp.l (a2),a0				; Eintrag mit geicher Basepage gefunden?
	beq.s aestrap_shownoreturns	; Reentranz innerhalb desselben Prozesses kann ich nicht...
	add.l #AES_INFO_SIZE,a2	; n„chster Eintrag
	dbra d0,aes_such_eintrag2

; Eintrag gefunden (a1)

	move.l a0,(a1)+							; Basepage in erstes long
	clr.b aes_sem			; Semaphore freigeben
	lea.l (8+7)*4+2(sp),a2					; Zeiger auf zu verbiegende Return-Adresse
	move.l (a2),(a1)+							; alte Return-Adresse in zweites long
	move.l a2,(a1)+							; Adresse des verbogenen Returnwerts (fr etv_term) in drittes long
	move.l a3,(a1)+							; AESPB-Stack in viertes long
	move.l #nach_aestrap,(a2)				; Return verbiegen

; get_prg: a0: BASPAG*, d0:aesid, a1:char**prcname, (sp):char**appname

	moveq.l #-1,d0								; d0: aesid = -1 (zun„chst)

	move.l (a3),a4								; contrl-Feld
	cmp.w #10,(a4)								; appl_init -> Dann stimmt AES-ID nicht, also d0 auf -1 gesetzt lassen
	beq.s aestrap_appl_init
	move.l 4(a3),a4							; global-Feld
	move.w 4(a4),d0							; d0: aesid (global[2])
aestrap_appl_init:
														; a1 zeigt auf fnftes long (prc_name)
	; nix zu tun									; a0: zeigt auf Basepage
	addq.l #4,a1									; sechstes long: app_name
	move.l a1,-(sp)								; ...auf Stack
	subq.l #4,a1									; a1: prc_name = fnftes long
	bsr get_prg
	addq.l #4,sp

aestrap_shownoreturns:
	clr.b aes_sem			; Semaphore freigeben
	movem.l (sp)+,d0-a6
ende_aestrap:
	move.l old_gemtrap, -(sp)
	rts								; in Trap "reingehen"

.USER

nach_aestrap:						; hier kommt man evtl. wieder raus!
	subq.l #4,sp					; Platz fr alten Returncode
	movem.l d1/a0-a5,-(sp)

	move.l p_run,a0
	move.l (a0),a0				; Basepage
	lea.l aes_info,a1			; Tabelle
nach_aes_such_eintrag:
	cmp.l (a1),a0				; Eintrag gefunden?
	beq.s nach_aes_found
	add.l #AES_INFO_SIZE,a1	; n„chster Eintrag
	bra.s nach_aes_such_eintrag
nach_aes_found:

	move.w sr,d1
	lsr.w #8,d1
aes_semaphore_wait:
	tas.b ret_semaphore			; Semaphore testen und setzen
	beq.s aes_semaphore_free
	btst.b #5,d1					; User-Mode?
	beq.s aes_semaphore_wait	; Dann warten, bis Semaphore frei ist

	bra ende_nach_aestrap	; Returnwert geht jetzt leider nicht

aes_semaphore_free:

	move.w akt_ret,d1			; aktueller Return-Zaehler
	addq.w #1,akt_ret			; Z„hler hochz„hlen

	and.l #$f,d1				; Ring
	lsl.l #8,d1					; * 256 (sizeof(RETURN))
	lea.l ret,a0				; Adresse Return-Struktur
	adda.l d1,a0				; aktueller Eintrag

	tst.w (a0)					; state != RET_EMPTY ? -> Ringpuffer voll!
	beq.s nach_aestrap_ok	; noch Platz

	subq.w #1,akt_ret			; kein Platz mehr -> wieder zurckz„hlen
	clr.b ret_semaphore		; Semaphore freigeben
	bra ende_nach_aestrap	; raus!

nach_aestrap_ok:				; noch Platz
	move.l 12(a1),a3			; AESPB
	move.l a0,a2				; Anfang auch in a2 merken
	move.w #1,(a0)+			; ret->state: RET_BUSY eintragen
	clr.b ret_semaphore		; Semaphore freigeben

	move.l my_200hz,(a0)+			; ret->hz200
	move.w #4,(a0)+					; ret->typ: RET_AES
	move.l 12(a3),a4						; intout-Array
	move.l (a4),(a0)+					; ret->ret: intout[0]
	move.l (a1),(a0)+					; ret->bas
	move.l 4(a3),a4						; global-Array
	move.w 4(a4),(a0)+				; ret->pid (global[2])
	move.l (a3),a4							; contrl-Array
	move.w (a4)+,(a0)+				; ret->opcode (contrl[0])
	move.w (a4),(a0)+					; ret->contrl1 (contrl[1])
	move.w 4(a4),(a0)+				; ret->contrl3 (contrl[3])
	addq.l #2,a0						; contrl5 berspringen (VDI)
	move.l 8(a3),a4						; intin-Array
	move.l (a4),(a0)+					; ret->intin0/ret->intin1

	move.l a0,a5						; ret->prc_name zum kopieren
	move.l 16(a1),a4						; prcname
	tst.l a4
	beq.s no_prc_strcpy
	moveq.l #11,d1						; maximal 12 Zeichen kopieren
prc_strcpy:
	move.b (a4)+,(a5)+				; in ret->prc_name kopieren
	beq.s no_prc_strcpy
	dbra d1,prc_strcpy
no_prc_strcpy:
	clr.b (a5)							; ret->prc_name: 0-Byte am Ende

	add.l #13,a0						; ret->app_name
	move.l a0,a5						; ret->app_name zum kopieren
	move.l 20(a1),a4						; appname
	tst.l a4
	beq.s no_app_strcpy
	moveq.l #7,d1						; maximal 8 Zeichen kopieren
app_strcpy:
	move.b (a4)+,(a5)+				; in ret->app_name kopieren
	beq.s no_app_strcpy
	dbra d1,app_strcpy
no_app_strcpy:
	clr.b (a5)							; ret->app_name: 0-Byte am Ende

	add.l #9,a0							; ret->intout

	move.l 12(a3),a4						; intout-Array
	move.l (a4)+,(a0)+				; ret->intout[0/1]
	move.l (a4)+,(a0)+				; ret->intout[2/3]
	move.l (a4)+,(a0)+				; ret->intout[4/5]
	move.l (a4)+,(a0)+				; ret->intout[6/7]
	move.l (a4)+,(a0)+				; ret->intout[8/9]
	move.l (a4)+,(a0)+				; ret->intout[10/11]
	move.l (a4)+,(a0)+				; ret->intout[12/13]
	move.l (a4)+,(a0)+				; ret->intout[14/15]
	move.l 20(a3),a4						; addrout-Array
	move.l (a4)+,(a0)+				; ret->addrout[0]
	move.l (a4)+,(a0)+				; ret->addrout[1]
	move.l (a4)+,(a0)+				; ret->addrout[2]
	move.l (a4)+,(a0)+				; ret->addrout[3]
	move.l (a4)+,(a0)+				; ret->addrout[4]
	move.l (a4)+,(a0)+				; ret->addrout[5]
	move.l (a4)+,(a0)+				; ret->addrout[6]
	move.l (a4)+,(a0)+				; ret->addrout[7]
	move.l (a4)+,(a0)+				; ret->addrout[8]
	move.l (a4)+,(a0)+				; ret->addrout[9]
	move.l (a4)+,(a0)+				; ret->addrout[10]
	move.l (a4)+,(a0)+				; ret->addrout[11]
	move.l (a4)+,(a0)+				; ret->addrout[12]
	move.l (a4)+,(a0)+				; ret->addrout[13]
	move.l (a4)+,(a0)+				; ret->addrout[14]
	move.l (a4)+,(a0)+				; ret->addrout[15]

	move.w 18(a2),d1					; ret->opcode
	cmp.w #23,d1						; ret->opcode == 23 (evnt_mesag?)
	beq.s nach_aestrap_msgbuf
	cmp.w #25,d1						; ret->opcode == 25 (evnt_multi?)
	bne.s nach_aestrap_no_msgbuf
	move.w 26(a2),d1					; ret->intin0
	btst #4,d1							; MU_MESAG gesetzt?
	beq.s nach_aestrap_no_msgbuf
nach_aestrap_msgbuf:

	addq.l #2,a0						; ret->contrl6 berspringen

	move.l 16(a3),a4						; addrin-Array
	move.l (a4),a4							; Zeiger auf msgbuf aus addrin[0]
	move.l (a4)+,(a0)+				; ret->msgbuf[0/1]
	move.l (a4)+,(a0)+				; ret->msgbuf[2/3]
	move.l (a4)+,(a0)+				; ret->msgbuf[4/5]
	move.l (a4)+,(a0)+				; ret->msgbuf[6/7]

nach_aestrap_no_msgbuf:

	move.w #2,(a2)						; state: RET_READY eintragen

ende_nach_aestrap:
	move.l 4(a1),(7*4)(sp)			; alten Returnwert auf Stack
	clr.l (a1)							; Eintrag wird wieder frei
	movem.l (sp)+,d1/a0-a5			; Register wiederherstellen

	rts									; endgltig zurckspringen
