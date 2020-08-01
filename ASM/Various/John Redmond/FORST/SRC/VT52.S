; VT52.S: VT-52 emulation words
; Copyright <C> John Redmond, 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even
;	
doesc:  push    d0
        moveq.l #$1b,d0
        push    d0
        bsr     _conout
        bsr     _conout
        rts
;
_tab:   moveq.l #$59,d0
        bsr     doesc
        moveq.l #$20,d0
        add.l   (a6)+,d0
        push    d0
        bsr     _conout
        moveq.l #$20,d0
        add.l   (a6)+,d0
        push    d0
        bsr     _conout
        rts
;
_cursup: moveq.l #$41,d0
        bsr     doesc
        rts
;
_cursdn: moveq.l #$42,d0
        bsr     doesc
        rts
;
_cursrt: moveq.l #$43,d0
        bsr     doesc
        rts
;
_curslft: moveq.l #$44,d0
        bsr     doesc
        rts
;
_cls:   moveq.l #$45,d0
        bsr     doesc
        rts
;
_scursup: moveq.l #$49,d0
        bsr     doesc
        rts
;
_kdown: moveq.l #$4a,d0
        bsr     doesc
        rts
;
_kright:moveq.l #$4b,d0
        bsr     doesc
        rts
;
_iline: moveq.l #$4c,d0
        bsr     doesc
        rts
;
_kline: moveq.l #$4d,d0
        bsr     doesc
        rts
;
_curson: moveq.l #$65,d0
        bsr     doesc
        rts
;
_cursoff: moveq.l #$66,d0
        bsr     doesc
        rts
;
	section	data
	even
;
	dc.b	$83,'TA','B'!$80
	ptrs	_tab,16
;
	dc.b	$86,'CURSUP',$a0
	ptrs	_cursup,20
;
	dc.b	$86,'CURSDN',$a0
	ptrs	_cursdn,20
;
	dc.b	$86,'CURSRT',$a0
	ptrs	_cursrt,20
;
	dc.b	$87,'CURSLF','T'!$80
	ptrs	_curslft,20
;
	dc.b	$87,'SCURSU','P'!$80
	ptrs	_scursup,20
;
	dc.b	$85,'KDOW','N'!$80
	ptrs	_kdown,18
;
	dc.b	$86,'KRIGHT',$a0
	ptrs	_kright,20
;
	dc.b	$85,'ILIN','E'!$80
	ptrs	_iline,18
;
	dc.b	$85,'KLIN','E'!$80
	ptrs	_kline,18
;
	dc.b	$86,'CURSON',$a0
	ptrs	_curson,20
;
	dc.b	$87,'CURSOF','F'!$80
	ptrs	_cursoff,20
;
