* _aes.s - low-level interface to AES
* 920628 kbad

* lattice ASM synonym file
	include as68.syn

    XDEF __aes,@_aes

    TEXT

* int _aes(short func, void *apb);

__aes:
	move.w	4(sp),d0
	move.l	6(sp),a0
@_aes:
	movem.l	d2/a2,-(sp)
	move.l	crystab(pc,d0.w),d1
	move.l	(a0),a1
	movep.l	d1,1(a1)
	move.l	12(a0),-(sp)
	move.l	a0,d1
	move.w	#200,d0
	trap	#2
	move.l	(sp)+,a0
	move.w	(a0),d0
	ext.l	d0
	movem.l	(sp)+,d2/a2
	rts

crystab:
* byte-packed control array counts, for setting contrl[0..3].
* note that rsrc_gaddr binding should manually set control[4] to 1,
* and set it back to 0 after calling _aes()

* appl	     _init     _read	 _write    _find     _tplay
	dc.l $0a000100,$0b020101,$0c020101,$0d000101,$0e020101
*	     _trecord			   _search   _exit
	dc.l $0f010101,$10000000,$11000000,$12010301,$13000100

* evnt	     _keybd    _button   _mouse    _mesag    _timer
	dc.l $14000100,$15030500,$16050500,$17000101,$18020100
*	     _multi    _dclick
	dc.l $19100701,$1a020100,$1b000000,$1c000000,$1d000000

* menu	     _bar      _icheck   _ienable  _tnormal  _text
	dc.l $1e010101,$1f020101,$20020101,$21020101,$22010102
*	     _register _popup    _attach   _istart   _settings
	dc.l $23010101,$24020102,$25020102,$26030101,$27010101

* objc	     _add      _delete   _draw     _find     _offset
	dc.l $28020101,$29010101,$2a060101,$2b040101,$2c010701
*	     _order    _edit     _change   _sysvar
	dc.l $2d020101,$2e040201,$2f080101,$30040300,$31000000

* form	     _do       _dial     _alert    _error    _center
	dc.l $32010101,$33090100,$34010101,$35010100,$36000501
*	     _keybd    _button
	dc.l $37030301,$38020201,$39000000,$3a000000,$3b000000

	dc.l $3c000000,$3d000000,$3e000000,$3f000000,$40000000
	dc.l $41000000,$42000000,$43000000,$44000000,$45000000

* graf	     _rubberbox _dragbox _movebox  _growbox  _shrinkbox
	dc.l $46040300,$47080300,$48060100,$49080100,$4a080100
*	     _watchbox _slidebox _handle   _mouse    _mkstate
	dc.l $4b040101,$4c030101,$4d000500,$4e010101,$4f000500

* scrp	     _read     _write
	dc.l $50000101,$51000101,$52000000,$53000000,$54000000
	dc.l $55000000,$56000000,$57000000,$58000000,$59000000

* fsel	     _input    _exinput
	dc.l $5a000202,$5b000203,$5c000000,$5d000000,$5e000000
	dc.l $5f000000,$60000000,$61000000,$62000000,$63000000

* wind	     _create   _open     _close    _delete   _get
	dc.l $64050100,$65050100,$66010100,$67010100,$68020500
*	     _set      _find     _update   _calc     _new
	dc.l $69060100,$6a020100,$6b010100,$6c060500,$6d000000

* rsrc	     _load     _free     _gaddr    _saddr    _obfix
	dc.l $6e000101,$6f000100,$70020100,$71020101,$72010101
*	     _rcfix
	dc.l $73000101,$74000000,$75000000,$76000000,$77000000

* shel	     _read     _write    _get      _put      _find
	dc.l $78000102,$79030102,$7a010101,$7b010101,$7c000101
*	     _environ
	dc.l $7d000103

    END
