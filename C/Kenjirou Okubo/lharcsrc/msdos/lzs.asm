page	66, 120					;
;$_init						;
;***********************************************;
;       LHarc version 1.13b (c) Yoshi 1988-89.	;
;           LZSS module : 1989/ 5/14		;
;						;
;       この部分は、奥村晴彦氏のＬＺＡＲＩ法の	;
;       Ｃソースを参考に記述した。		;
;       また、高速化のために三木和彦氏の LArc	;
;       のソースリストを参考にさせて頂いた。	;
;						;
; HTAB = 8					;
;***********************************************;
						;
extrn	__fgetc:near				;
extrn	__fputc:near				;
						;
;***************************************	;
;	getc macro				;
;	    bx: address of FILE struc		;
;	    ax: input char (return)		;
;***************************************	;
getc@	macro					;
	local	getc1, getc2			;
	dec	word ptr [bx]			;
	jl	getc1				;
	inc	word ptr [bx+10]		;
	mov	bx, [bx+10]			;
	mov	al, [bx-1]			;
	xor	ah, ah				;
	jmp	getc2				;
getc1:						;
	push	dx				;
	push	cx				;
	push	bx				;
	call	__fgetc				;
	pop	bx				;
	pop	cx				;
	pop	dx				;
getc2:						;
	endm					;
						;
getc_crc@	macro				;
	local	getc1, getc2			;
	dec	word ptr [bx]			;
	jl	getc1				;
	inc	word ptr [bx+10]		;
	mov	bx, [bx+10]			;
	mov	al, [bx-1]			;
	xor	ah, ah				;
	jmp	getc2				;
getc1:						;
	call	crcgetc				;
getc2:						;
	endm					;
						;
;***************************************	;
;	putc macro				;
;	    ax: output char			;
;	    bx: address of FILE struc		;
;***************************************	;
putc@	macro					;
	local	putc1, putc2			;
	inc	word ptr [bx]			;
	jge	putc1				;
	inc	word ptr [bx+10]		;
	mov	bx, [bx+10]			;
	mov	[bx-1], al			;
	jmp	short putc2			;
putc1:						;
	call	fputc				;
putc2:						;
	endm					;
						;
putc_crc@	macro				;
	local	putc1, putc2			;
	inc	word ptr [bx]			;
	jge	putc1				;
	inc	word ptr [bx+10]		;
	mov	bx, [bx+10]			;
	mov	[bx-1], al			;
	jmp	short putc2			;
putc1:						;
	call	crcputc				;
putc2:						;
	endm					;
						;
DGROUP	group	_DATA,_BSS			;
EGROUP	group	_EXTRA				;
						;
	name	lzsub				;
_TEXT	segment	byte public 'CODE'		;
	assume	cs:_TEXT,ds:DGROUP,es:EGROUP,ss:DGROUP
_TEXT	ends					;
						;
_DATA	segment word public 'DATA'		;
mark	db	'o'				;
_DATA	ends					;
						;
_BSS	segment word public 'BSS'		;
_BSS	ends					;
						;
_EXTRA	segment word public			;
_EXTRA	ends					;
						;
_TEXT	segment					;
						;
extrn	DGROUP@		:word			;
extrn	_outfile	:word			;
extrn	_infname	:word			;
extrn	_outfname	:word			;
extrn	_codesize	:word			;
extrn	_crc		:word			;
extrn	_copying	:byte			;
extrn	_crcflg		:byte			;
extrn	_tstflg		:byte			;
extrn	_error		:near			;
extrn	_ftell		:near			;
extrn	_fseek		:near			;
						;
N		equ	4096			; バッファの大きさ
F		equ	60			; 先読みバッファの大きさ
THRESHOLD	equ	2			;
NIL		equ	N			; 木の末端
ROOTMK		equ	-1			;
F_OLD		equ	18			; ＬＡｒｃ用の先読み
						;   バッファの大きさ
	public	_text_buf, _match_position, _match_length
	public	_rson, _lson, _dad, _root, _buf2, _buf3
	public	len				;
	public	crctbl				;
	public	extra				;
						;
_BSS			segment			;
crctbl			dw	100h dup (?)	;
extra			dw	1 dup (?)	;
_match_position		dw	1 dup (?)	;
_match_length		dw	1 dup (?)	;
len			dw	1 dup (?)	;
_buf2			db	4096 dup (?)	;
_buf3			db	4096 dup (?)	;
_rson			dw	(N + 1) dup (?)	;
_lson			dw	(N + 1) dup (?)	;
_dad			dw	(N + 1) dup (?)	;
_root			dw	(N + 1) dup (?)	;
_text_buf		db	(N + F - 1) dup (?)
_BSS			ends			;
						;
;-----------------------------------------------;
;	木構造の初期化				;
;-----------------------------------------------;
public	_InitTree				;
_InitTree	proc	near			;
	push	di				;
	mov	bx, 1000h			;
	mov	ah, 48h				; get memory
	int	21h				;
	jNC $_1
		xor	ax, ax			;
		push	ax			;
		mov	ax, 15			; MEMOVRERR
		push	ax			;
		call	_error			;
$_1:
	mov	DGROUP:extra, ax		;
	cld					;
	mov	es, ax				;
	mov	ax, NIL * 2			;
	mov	cx, 8000h			;
	mov	di, 0				;
	rep	stosw				;
	mov	bx, ds				;
	mov	es, bx				;
	mov	cx, N				;
	mov	di, offset DGROUP:_dad		;
	rep	stosw				;
	pop	di				;
	ret					;
_InitTree	endp				;
						;
;-----------------------------------------------;
;	木構造に節を追加			;
;-----------------------------------------------;
public	_InsertNode				;
_InsertNode	proc	near			;
	push	si				;
	push	di				;
	mov	es, DGROUP:extra		;
	mov	bx, di				; di = r
	shl	bx, 1				;
        add	di, offset DGROUP:_text_buf	;
						;
	mov	ax, [di]			;
	xor	ah, [di + 2]			;
	shl	ax, 1				; si = p
	mov	si, ax				;
						;
	mov	ax, NIL * 2			;
	mov	DGROUP:_rson[bx], ax		;
	mov	DGROUP:_lson[bx], ax		;
						;
	cmp	word ptr EGROUP:[si], ax	; NIL * 2
	jne	in10				;
		mov	EGROUP:[si], bx		;
		mov	DGROUP:_dad[bx], ROOTMK	;
		mov	DGROUP:_root[bx], si	;
		jmp	in9			;
in10:						;
		mov	bp, EGROUP:[si]		;
	mov	cx, ds				;
	mov	es, cx				;
	cld					;
	inc	di				;
	mov	dx, di				;
	;$_while TRUE				;
in11:						;
		mov	di, dx			;
		mov	si, bp			;
		shr	si, 1			;
		add	si, offset DGROUP:_text_buf + 1
		mov	cx, F-1			;
		repe	cmpsb			;
		mov	si, bp			;
		je	in7			;
in0:						;
		ja	in2			;
			mov	bp, DGROUP:_rson[si]
			cmp	bp, ax		; NIL * 2
			jne	in11		;
				mov	DGROUP:_rson[si], bx
				mov	DGROUP:_dad[bx], si
				jmp	in9	;
in2:						;
			mov	bp, DGROUP:_lson[si]
			cmp	bp, ax		; NIL * 2
			jne	in11		;
				mov	DGROUP:_lson[si], bx
				mov	DGROUP:_dad[bx], si
				jmp	in9	;
	;$_enddo				;
in7:						;
	mov	di, DGROUP:_lson[si]		;
	mov	DGROUP:_dad[di], bx		;
	mov	DGROUP:_lson[bx], di		;
	mov	di, DGROUP:_rson[si]		;
	mov	DGROUP:_dad[di], bx		;
	mov	DGROUP:_rson[bx], di		;
	mov	di, DGROUP:_dad[si]		;
	mov	DGROUP:_dad[bx], di		;
						;
	mov	word ptr DGROUP:_dad[si], ax	; NIL * 2
	or di, di
	jNS $_2
						; ROOTMK
		mov	es, DGROUP:extra	;
		mov	di, DGROUP:_root[si]	;
		mov	DGROUP:_root[bx], di	;
		mov	EGROUP:[di], bx		;
		jmp	short in9		;
$_2:
	cmp DGROUP:_rson[di], si
	jNE $_3
		mov	DGROUP:_rson[di], bx	;
	jmp short $_4
$_3:
		mov	DGROUP:_lson[di], bx	;
$_4:
						;
in9:						;
	pop	di				;
	pop	si				;
	ret					;
_InsertNode	endp				;
						;
;-----------------------------------------------;
;	木構造に節を追加し、最も		;
;	一致した情報を返す。			;
;-----------------------------------------------;
public	_MatchInsertNode			;
_MatchInsertNode	proc	near		;
	push	si				;
	push	di				;
	mov	es, DGROUP:extra		;
	mov	bx, di				; di = r
	shl	bx, 1				;
        add	di, offset DGROUP:_text_buf	;
	mov	ax, [di]			;
	xor	ah, [di + 2]			;
	shl	ax, 1				; si = p
	mov	si, ax				;
						;
	mov	ax, NIL * 2			;
	mov	DGROUP:_rson[bx], ax		;
	mov	DGROUP:_lson[bx], ax		;
						;
	mov	al, F - 1			;
	cmp	word ptr EGROUP:[si], NIL * 2	;
	jne	min10				;
		mov	EGROUP:[si], bx		;
		mov	DGROUP:_dad[bx], ROOTMK	;
		mov	DGROUP:_root[bx], si	;
		jmp	min9			;
min10:						;
		mov	bp, EGROUP:[si]		;
	mov	cx, ds				;
	mov	es, cx				;
	cld					;
	inc	di				;
	mov	dx, di				;
	;$_while TRUE				;
min11:						;
		mov	di, dx			;
		mov	si, bp			;
		shr	si, 1			;
		add	si, offset DGROUP:_text_buf + 1
		mov	cx, F - 1		;
		repe	cmpsb			;
		lahf				;
		je	min7			;
		cmp	cx, F - THRESHOLD - 1	;
		jge	min0			;
		cmp	cl, al			;
		jg	min0			;
		je	min5			;
			mov	al, cl		;
			sub	di, si		;
			and	di, N - 1	;
			mov	DGROUP:_match_position, di
			jmp	min0		;
min5:						;
			sub	di, si		;
			and	di, N - 1	;
			cmp	di, DGROUP:_match_position
			jge	min6		;
				mov	DGROUP:_match_position, di
min6:						;
						;
min0:						;
		mov	si, bp			;
		sahf				;
		ja	min2			;
			mov	bp, DGROUP:_rson[si]
			cmp	bp, NIL * 2	;
			jne	min11		;
				mov	DGROUP:_rson[si], bx
				mov	DGROUP:_dad[bx], si
				jmp	min9	;
min2:						;
			mov	bp, DGROUP:_lson[si]
			cmp	bp, NIL * 2	;
			jne	min11		;
				mov	DGROUP:_lson[si], bx
				mov	DGROUP:_dad[bx], si
				jmp	min9	;
	;$_enddo				;
min7:						;
	mov	al, -1				;
	sub	di, si				;
	and	di, N - 1			;
	mov	DGROUP:_match_position, di	;
						;
	mov	si, bp				;
	mov	di, DGROUP:_lson[si]		;
	mov	DGROUP:_dad[di], bx		;
	mov	DGROUP:_lson[bx], di		;
	mov	di, DGROUP:_rson[si]		;
	mov	DGROUP:_dad[di], bx		;
	mov	DGROUP:_rson[bx], di		;
	mov	di, DGROUP:_dad[si]		;
	mov	DGROUP:_dad[bx], di		;
						;
	mov	word ptr DGROUP:_dad[si], NIL * 2
	or di, di
	jNS $_5
		mov	es, DGROUP:extra	;
		mov	di, DGROUP:_root[si]	;
		mov	DGROUP:_root[bx], di	;
		mov	EGROUP:[di], bx		;
		jmp	short min9		;
$_5:
	cmp DGROUP:_rson[di], si
	jNE $_6
		mov	DGROUP:_rson[di], bx	;
	jmp short $_7
$_6:
		mov	DGROUP:_lson[di], bx	;
$_7:
						;
min9:						;
	dec	word ptr DGROUP:_match_position	;
	cbw					;
	neg	ax				;
	add	ax, F - 1			;
	mov	DGROUP:_match_length, ax	;
	pop	di				;
	pop	si				;
	ret					;
_MatchInsertNode	endp			;
						;
;-----------------------------------------------;
;	木構造から節を削除			;
;-----------------------------------------------;
public	_DeleteNode				;
_DeleteNode	proc	near			;
	push	si				;
	push	di				;
	mov	es, DGROUP:extra		;
						;
	mov	dx, NIL * 2			;
	shl	si, 1				;
	cmp word ptr DGROUP:_dad[si], dx
	jNE $_8
		jmp	dn9			;
$_8:
	cmp word ptr DGROUP:_rson[si], dx
	jNE $_10
		mov	di, DGROUP:_lson[si]	;
		jmp short $_9
$_10:
	cmp word ptr DGROUP:_lson[si], dx
	jNE $_11
		mov	di, DGROUP:_rson[si]	;
		jmp short $_9
$_11:
		mov	di, DGROUP:_lson[si]	;
		mov	ax, DGROUP:_rson[di]	;
		cmp ax, dx
		jE $_13
$_14:
				mov	di, ax	;
				mov	ax, DGROUP:_rson[di]
			cmp ax, dx
			jNE $_14
$_15:
			mov	ax, DGROUP:_lson[di]
			mov	bx, DGROUP:_dad[di]
			mov	cx, bx		;
			mov	DGROUP:_rson[bx], ax
			mov	bx, DGROUP:_lson[di]
			mov	DGROUP:_dad[bx], cx
			mov	ax, DGROUP:_lson[si]
			mov	DGROUP:_lson[di], ax
			mov	bx, DGROUP:_lson[si]
			mov	DGROUP:_dad[bx], di
$_13:
		mov	ax, DGROUP:_rson[si]	;
		mov	DGROUP:_rson[di], ax	;
		mov	bx, DGROUP:_rson[si]	;
		mov	DGROUP:_dad[bx], di	;
$_12:
$_9:
	mov	bx, DGROUP:_dad[si]		;
	mov	DGROUP:_dad[di], bx		;
	or bx, bx
	jNS $_16
		mov	bx, DGROUP:_root[si]	;
		mov	DGROUP:_root[di], bx	;
		mov	EGROUP:[bx], di		;
	jmp short $_17
$_16:
		cmp DGROUP:_rson[bx], si
		jNE $_18
			mov	DGROUP:_rson[bx], di
		jmp short $_19
$_18:
			mov	DGROUP:_lson[bx], di
$_19:
$_17:
	mov	DGROUP:_dad[si], dx		;
dn9:						;
	pop	di				;
	pop	si				;
	ret					;
_DeleteNode	endp				;
						;
extrn	_textsize	:word			;
						;
extrn	_infile		:word			;
extrn	_StartModel	:near			;
extrn	_EncodeChar	:near			;
extrn	_EncodePosition	:near			;
extrn	_EncodeEnd	:near			;
						;
extrn	_outfile	:word			;
extrn	_DecodeChar	:near			;
extrn	_DecodePosition	:near			;
						;
extrn	_blkcnt		:word			;
extrn	_curcnt		:word			;
extrn	_nxtcnt		:word			;
						;
;-----------------------------------------------;
;	LArc type 5 の buffer 初期化		;
;-----------------------------------------------;
public	InitBuf					;
InitBuf	proc	near				;
	cld					;
	mov	di, ds				;
	mov	es, di				;
	mov	di, offset DGROUP:_text_buf	;
	mov	al, 0				;
	mov	bx, 13				;
$_20:
		mov	cx, bx			;
		rep	stosb			;
		inc	al			;
	jNZ $_20
$_21:
$_22:
		stosb				;
		inc	al			;
	jNZ $_22
$_23:
$_24:
		dec	al			;
		stosb				;
	jNZ $_24
$_25:
	mov	cx, 128				;
	rep	stosb				;
	mov	cx, 128				;
	mov	al, 20h				;
	rep	stosb				;
	ret					;
InitBuf	endp					;
						;
;-----------------------------------------------;
;	LZHUF の encode				;
;-----------------------------------------------;
public	_Encode					;
_Encode	proc	near				;
	push	si				;
	push	di				;
	push	bp				;
	mov	ax,word ptr DGROUP:_textsize	;
	or	ax,word ptr DGROUP:_textsize + 2;
	jNZ $_26
		jmp	en05			;
$_26:
	call	near ptr _StartModel		;
	call	near ptr _InitTree		;
	call	near ptr InitBuf		;
	mov	cx, F				;
	sub	di, cx				;
en01:						;
	mov	bx, DGROUP:_infile		;
	getc_crc@				;
	or	ax, ax				;
	js	en02				;
	stosb					;
	loop	en01				;
en02:						;
	mov	ax, F				;
	sub	ax, cx				;
	mov	word ptr len, ax		;
	xor	ax, ax				;
	mov	word ptr DGROUP:_textsize, ax	;
	mov	word ptr DGROUP:_textsize + 2, ax
	mov	di, N - F			;
	mov	si, di				;
	mov	cx, F				;
$_27:
		dec	di			;
		push	cx			;
		call	_InsertNode		;
		pop	cx			;
	LOOP $_27
$_28:
	mov	di, si				;
	call	near ptr _MatchInsertNode	;
	xor	si, si				;
$_29:
		mov	bx, word ptr DGROUP:_match_length
		cmp bx, word ptr len
		jLE $_31
			mov	bx, word ptr len;
			mov	word ptr DGROUP:_match_length, bx
$_31:
		push	si			;
		push	di			;
		cmp bx, THRESHOLD
		jG $_32
			mov	word ptr DGROUP:_match_length, 1
			mov	bl, byte ptr DGROUP:_text_buf[di]
			mov	bh, 0		;
			call	near ptr _EncodeChar
		jmp short $_33
$_32:
			add	bx, 255 - THRESHOLD
			call	near ptr _EncodeChar
			mov	bx, DGROUP:_match_position
			call	near ptr _EncodePosition
$_33:
		pop	di			;
		pop	si			;
		mov	ax, word ptr DGROUP:_match_length
		add	word ptr DGROUP:_textsize, ax
		adc	word ptr DGROUP:_textsize + 2, 0
		jmp	short en03		;
$_34:
			call	near ptr _InsertNode
en03:						;
			call	near ptr _DeleteNode
			mov	bx, DGROUP:_infile
			getc_crc@		;
			or ax, ax
			jS $_36
				mov	byte ptr DGROUP:_text_buf[si], al
				cmp si, F - 1
				jAE $_37
					mov	DGROUP:_text_buf[si + N], al
$_37:
			jmp short $_38
$_36:
				dec	word ptr len
$_38:
			inc	si		;
			inc	di		;
			and	si, N - 1	;
			and	di, N - 1	;
		dec _match_length
		jNZ $_34
$_35:
		call	near ptr _MatchInsertNode
	cmp len, 0
	jLE $_39
	jmp $_29
$_30:
$_39:
	call	near ptr _EncodeEnd		;
						;
	mov	es, DGROUP:extra		;
	mov	ah, 49h				; release memory
	int	21h				;
en05:						;
	pop	bp				;
	pop	di				;
	pop	si				;
	ret					;
_Encode	endp					;
						;
;-----------------------------------------------;
;	LZHUF の decode				;
;-----------------------------------------------;
	public	_Decode				;
_Decode	proc	near				;
	push	si				;
	push	di				;
	push	bp				;
	mov	ax, word ptr DGROUP:_textsize	;
	or	ax, word ptr DGROUP:_textsize+2	;
	jNZ $_40
		jmp	de9			;
$_40:
	call	near ptr _StartModel		;
	call	near ptr InitBuf		;
	mov	di, N - F			;
$_41:
		push	di			;
		call	near ptr _DecodeChar	;
		mov	di, ax			;
		cmp ax, 256
		jGE $_43
			pop	di		;
			mov	bx, word ptr DGROUP:_outfile
			putc_crc@		;
			mov	byte ptr DGROUP:_text_buf[di], al
			inc	di		;
			and	di, N - 1	;
			sub	DGROUP:_textsize, 1
			sbb	DGROUP:_textsize + 2, 0
		jmp short $_44
$_43:
			call	near ptr _DecodePosition
			mov	cx, di		;
			pop	di		;
			mov	si, di		;
			sub	si, ax		;
			dec	si		;
			and	si, N - 1	;
			sub	cx, 255 - THRESHOLD
			sub	DGROUP:_textsize, cx
			sbb	DGROUP:_textsize + 2, 0
			mov	dx, DGROUP:_outfile
$_45:
				mov	al, DGROUP:_text_buf[si]
				mov	DGROUP:_text_buf[di], al
				inc	si	;
				inc	di	;
				and	si, N - 1
				and	di, N - 1
				mov	bx, dx	;
				putc_crc@	;
			LOOP $_45
$_46:
$_44:
		mov	ax, word ptr DGROUP:_textsize+2
	or ax, ax
	jS $_47
	or ax, word ptr DGROUP:_textsize
	jZ $_47
	jmp $_41
$_42:
$_47:
de9:						;
	call	crcend				;
	pop	bp				;
	pop	di				;
	pop	si				;
	ret					;
_Decode	endp					;
						;
;-----------------------------------------------;
;	LArc type 5 の decode			;
;-----------------------------------------------;
		public	_DecodeOld		;
_DecodeOld	proc	near			;
	push	si				;
	push	di				;
	push	bp				;
	push	ds				;
	pop	es				;
	mov	ax, word ptr DGROUP:_textsize	;
	or	ax, word ptr DGROUP:_textsize+2	;
	jNZ $_48
		jmp	do9			;
$_48:
	call	near ptr InitBuf		;
	mov	di, N - F_OLD			;
	mov	dl, 80h				;
$_49:
		rol dl, 1
		jNC $_51
			mov	bx, word ptr DGROUP:_infile
			getc@			;
			mov	dh, al		;
$_51:
		mov	bx, word ptr DGROUP:_infile
		getc@				;
		test dh, dl
		jZ $_52
			mov	bx, word ptr DGROUP:_outfile
			putc_crc@		;
			mov	byte ptr DGROUP:_text_buf[di], al
			inc	di		;
			and	di, N - 1	;
			sub	DGROUP:_textsize, 1
			sbb	DGROUP:_textsize + 2, 0
		jmp short $_53
$_52:
			mov	cl, al		;
			mov	bx, word ptr DGROUP:_infile
			getc@			;
			mov	ch, al		;
			shr	ch, 1		;
			shr	ch, 1		;
			shr	ch, 1		;
			shr	ch, 1		;
			mov	si, cx		;
			and	ax, 000fh	;
			add	ax, 3		;
			mov	cx, ax		;
			sub	DGROUP:_textsize, cx
			sbb	DGROUP:_textsize + 2, 0
$_54:
				mov	al, DGROUP:_text_buf[si]
				mov	DGROUP:_text_buf[di], al
				mov	bx, DGROUP:_outfile
				putc_crc@	;
				inc	si	;
				inc	di	;
				and	si, N - 1
				and	di, N - 1
			LOOP $_54
$_55:
$_53:
		mov	ax, word ptr DGROUP:_textsize+2
	or ax, ax
	jS $_56
	or ax, word ptr DGROUP:_textsize
	jZ $_56
	jmp $_49
$_50:
$_56:
do9:						;
	call	crcend				;
	pop	bp				;
	pop	di				;
	pop	si				;
	ret					;
_DecodeOld	endp				;
						;
;-----------------------------------------------;
;	sub-module for 				;
;	  calculate CRC in buffer		;
;-----------------------------------------------;
;	ax = _crc				;
;	cx = length				;
;	si = buffer				;
;-----------------------------------------------;
MAXBLK	equ	64				;
						;
	public	crcsub				;
crcsub	proc	near				;
	jcxz	crcsub9				;
	mov	ax, DGROUP:_curcnt		;
	inc	DGROUP:_curcnt			;
	cmp ax, DGROUP:_nxtcnt
	jB $_57
		push	bx			;
		push	dx			;
		push	cx			;
		push	ax			;
		mov	ah, 40h			; output char to stderr
		mov	bx, 2			;
		mov	cx, 1			;
		mov	dx, offset DGROUP:mark	;
		int	21h			;
		pop	ax			;
		pop	cx			;
		cmp DGROUP:_blkcnt, MAXBLK
		jBE $_58
			mov	bx, MAXBLK	; calculation of next blk
			mul	bx		;
			mov	bx, DGROUP:_blkcnt
			dec	bx		;
			add	ax, bx		;
			adc	dx, 0		;
			inc	bx		;
			div	bx		;
			inc	ax		;
			mul	bx		;
			mov	bx, MAXBLK	;
			div	bx		;
		jmp short $_59
$_58:
			inc	ax		;
$_59:
		mov	DGROUP:_nxtcnt, ax	;
		pop	dx			;
		pop	bx			;
$_57:
	mov	ax, DGROUP:_crc			;
	push	bx				;
$_60:
		xor	al, [si]		;
		inc	si			;
		mov	bl, al			; crc & 0xff
		xor	bh, bh			;
		mov	al, ah			; crc >> 8
		xor	ah, ah			;
		shl	bx, 1			;
		xor	ax, crctbl[bx]		;
	LOOP $_60
$_61:
	pop	bx				;
	mov	DGROUP:_crc, ax			;
crcsub9:					;
	ret					;
crcsub	endp					;
						;
;-----------------------------------------------;
;	get CRC for putc in buffer		;
;-----------------------------------------------;
	public	crcbuf				;
crcbuf	proc	near				;
	push	cx				;
	push	si				;
	mov	cx, 10[bx]			;
	mov	si, 8[bx]			;
	sub	cx, si				;
	mov	bl, 4[bx]			;
	call	crcsub				;
	pop	si				;
	pop	cx				;
	ret					;
crcbuf	endp					;
						;
;-----------------------------------------------;
;	end process of CRC for putc		;
;-----------------------------------------------;
	public	crcend				;
crcend	proc	near				;
	mov	bx, DGROUP:_outfile		;
	test word ptr 2[bx], 0200h
	jZ $_62
	cmp  byte ptr 4[bx], 01h
	jE $_63
$_62:
		call	crcbuf			;
$_63:
	ret					;
crcend	endp					;
						;
;-----------------------------------------------;
;	CRC & putc				;
;-----------------------------------------------;
	public	crcputc				;
crcputc	proc	near				;
	push	bx				;
	push	ax				;
	test word ptr 2[bx], 0200h
	jZ $_64
	cmp  byte ptr 4[bx], 01h
	jE $_65
$_64:
		call	crcbuf			;
	jmp short $_66
$_65:
		xor	al, byte ptr DGROUP:_crc;
		mov	bl, al			;
		xor	bh, bh			;
		shl	bx, 1			;
		mov	ax, crctbl[bx]		;
		xor	al, byte ptr DGROUP:_crc + 1
		mov	DGROUP:_crc, ax		;
$_66:
	pop	ax				;
	pop	bx				;
	cmp DGROUP:_tstflg, 0
	jE $_67
		push	cx			;
		push	bx			;
		mov	cx, 6[bx]		;
		neg	cx			;
		mov	[bx], cx		;
		mov	cx, 8[bx]		;
		inc	cx			;
		mov	10[bx], cx		;
		mov	bx, cx			;
		mov	[bx - 1], al		;
		pop	bx			;
		pop	cx			;
		ret				;
$_67:
						;
	public	fputc				;
fputc	proc	near				;
	push	dx				;
	push	cx				;
	push	bx				;
	push	ax				;
	call	__fputc				;
	inc	sp				;
	inc	sp				;
	pop	bx				;
	or ax, ax
	jNS $_68
		push	DGROUP:_outfname	;
		mov	ax, 14			; WTERR
		push	ax			;
		call	near ptr _error		;
$_68:
	pop	cx				;
	pop	dx				;
	ret					;
fputc	endp					;
crcputc	endp					;
						;
;-----------------------------------------------;
;	CRC & getc				;
;-----------------------------------------------;
	public	crcgetc				;
crcgetc	proc	near				;
	push	dx				;
	push	cx				;
	push	bx				;
	call	__fgetc				;
	pop	bx				;
	or ax, ax
	jS $_69
		push	si			;
		push	ax			;
		mov	si, 8[bx]		;
		mov	cx, [bx]		;
		inc	cx			;
		call	crcsub			;
		pop	ax			;
		pop	si			;
$_69:
	pop	cx				;
	pop	dx				;
	ret					;
crcgetc	endp					;
						;
;-----------------------------------------------;
;	make CRC table				;
;-----------------------------------------------;
	public	_mkcrc				;
_mkcrc	proc	near				;
	mov	bx, offset DGROUP:crctbl	;
	xor	dx, dx				;
$_70:
		mov	ax, dx			;
		mov	cx, 8			;
$_72:
			shr ax, 1
			jNC $_74
				xor	ax, 0a001h
$_74:
		LOOP $_72
$_73:
		mov	[bx], ax		;
		inc	bx			;
		inc	bx			;
	inc dl
	jNZ $_70
$_71:
	ret					;
_mkcrc	endp					;
						;
;-----------------------------------------------;
;	get CRC for _copyfile			;
;-----------------------------------------------;
	public	_getcrc				;
_getcrc	proc	near				;
	push	si				;
	push	cx				;
	mov	si, offset DGROUP:_buf2		;
	call	crcsub				;
	pop	cx				;
	pop	si				;
	ret					;
_getcrc	endp					;
						;
;-----------------------------------------------;
;	高速コピー				;
;-----------------------------------------------;
; void copyfile(FILE *f0, FILE *f1, long size)	;
;-----------------------------------------------;
	public	_copyfile			;
_copyfile	proc	near			;
__f0	=	4				;
__f1	=	6				;
__size	=	8				;
	push	bp				;
	mov	bp, sp				;
	mov	DGROUP:_crc, 0			;
	mov	ax, __size[bp]			;
	or	ax, __size + 2[bp]		;
	jNZ $_75
		jmp	cf9			;
$_75:
						;
	push	si				;
	push	di				;
	mov	si, __f0[bp]			;
	mov	di, __f1[bp]			;
						;
	push	si				;
	call	_ftell				;
	pop	cx				;
	mov	cx, dx				;
	mov	dx, ax				;
	mov	bl, 4[si]			;
	xor	bh, bh				;
	mov	si, bx				; fd0
	mov	ax, 4200h			;
	int	21h				; lseek
						;
	push	di				;
	call	_ftell				;
	pop	cx				;
	mov	cx, dx				;
	mov	dx, ax				;
	mov	bl, 4[di]			;
	xor	bh, bh				;
	mov	di, bx				; fd1
	mov	ax, 4200h			;
	int	21h				; lseek
						;
	mov	dx, offset DGROUP:_buf2		;
$_76:
		mov	cx, 0a000h		;
		cmp DGROUP:_crcflg, 0
		jE $_78
			mov	cx, 01000h	;
$_78:
		cmp word ptr __size + 2[bp], 0
		jNZ $_79
		cmp cx, __size[bp]
		jBE $_79
			mov	cx, __size[bp]	;
$_79:
		mov	bx, si			;
		mov	ah, 3fh			;
		int	21h			;
		jC $_80
		cmp ax, cx
		jE $_81
$_80:
			push	DGROUP:_infname	;
			mov	ax, 13		; RDERR
			push	ax		;
			call	_error		;
$_81:
		cmp DGROUP:_tstflg, 0
		jNE $_82
			mov	bx, di		;
			mov	ah, 40h		;
			int	21h		;
			jC $_83
				dec	bx	; STDOUT ?
				jne	cf1	;
				mov	ax, cx	;
cf1:						;
				inc	bx	;
			cmp ax, cx
			jE $_84
$_83:
				push	DGROUP:_outfname
				mov	ax, 14	; WTERR
				push	ax	;
				call	_error	;
$_84:
$_82:
		sub	__size[bp], ax		;
		sbb	word ptr __size + 2[bp], 0
		cmp DGROUP:_crcflg, 0
		jE $_85
			call	_getcrc		;
$_85:
		mov	ax, __size[bp]		;
		or	ax, __size + 2[bp]	;
	jNZ $_76
$_77:
						;
	xor	cx, cx				;
	mov	bx, di				;
	mov	ah, 40h				; to abandon rest of old file
	int	21h				;
						;
	push	cx				;
	mov	dx, cx				;
	mov	bx, si				;
	mov	ax, 4201h			; lseek
	int	21h				;
	push	dx				;
	push	ax				;
	push	word ptr __f0[bp]		;
	call	near ptr _fseek			;
	add	sp, 8				;
						;
	xor	cx, cx				;
	push	cx				;
	mov	dx, cx				;
	mov	bx, di				;
	mov	ax, 4201h			; lseek
	int	21h				;
	push	dx				;
	push	ax				;
	push	word ptr __f1[bp]		;
	call	near ptr _fseek			;
	add	sp, 8				;
						;
	pop	di				;
	pop	si				;
cf9:						;
	pop	bp				;
	ret					;
_copyfile	endp				;
						;
_TEXT	ends					;
	end					;
