page	66, 120					;
;$_init						;
;***********************************************;
;       LHarc version 1.13 (c) Yoshi 1988-89.	;
;       self-extract module : 1989/ 5/ 4	;
;						;
; HTAB = 8					;
;***********************************************;
						;
_TEXT	segment	byte public 'CODE'		;
_TEXT	ends					;
						;
DGROUP	group	_BSS				;
	assume	cs:_TEXT, ds:DGROUP		;
						;
		public	THRESHOLD, F, N_CHAR, T	;
THRESHOLD	equ	2			;
F		equ	60			;
N_CHAR		equ	(256 - THRESHOLD + F)	;
T		equ	(N_CHAR * 2 - 1)	;
R		equ	(T - 1)			;
N		equ	1000h			;
MAX_FREQ	equ	8000h			;
CRC16		equ	0a001h			;
						;
LzHead	struc					;
	HeadSiz	db	?			;
	HeadChk	db	?			;
	HeadID	db	3 dup (?)		;
	Method	db	?			;
		db	?			;
	PacSiz	dw	2 dup (?)		;
	OrgSiz	dw	2 dup (?)		;
	FTime	dw	?			;
	FDate	dw	?			;
	FAttr	dw	?			;
	FnLen	db	?			;
	Fname	db	14 dup (?)		;
LzHead	ends					;
						;
_BSS	segment	para public 'BSS'		;
	public	freq, prnt, son			;
	public	d_len, d_code			;
	public	crctbl				;
	public	cpyhdr, outfile			;
	public	curcrc, iobuf, iolen, crcflg, orgcrc
						;
freq		dw	(T + 1) dup (?)		;
prnt		dw	(T + N_CHAR) dup (?)	;
son		dw	T dup (?)		;
d_len		db	100h dup (?)		;
d_code		db	100h dup (?)		;
crctbl		dw	100h dup (?)		;
text_buf	db	N dup (?)		;
text_ptr	dw	2 dup (?)		;
cpyhdr		LzHead	1 dup (<?>)		;
outfile		dw	1 dup (?)		;
orgcrc		dw	1 dup (?)		;
curcrc		dw	1 dup (?)		;
iobuf		dw	1 dup (?)		;
crcflg		db	1 dup (?)		;
iolen		db	1 dup (?)		;
endBBS		label	byte			;
_BSS		ends				;
						;
_TEXT	segment	byte public 'CODE'		;
	assume	cs:_TEXT, ds:DGROUP		;
						;
	org	0100h				;
						;
	public	start, main			;
	public	BSSseg				;
	public	cright, chglen, crlf, space	;
start:						;
	jmp	short main			;
BSSseg	dw	(endofcode - start + 10fh) / 10h; don't move this
mes_yn	equ	space - 1			;
space	db	' $'				;
cright	db	"LHarc's SFX 1.13S (c)Yoshi, 1989."
	db	13, 10, 10, '$'			;
chglen	db	01h, 04h, 0ch, 18h, 30h		; next byte must not be 3?h
overwt	db	'Overwrite $'			;
yesno	db	'[Y/N] $'			;
memory	db	'Memory$'			;
write	db	'Write$'			;
header	db	'Header$'			;
crcmes	db	'CRC'				;
error	db	' Error'			;
crlf	db	13, 10, '$'			;
						;
;-----------------------------------------------;
;	メインルーチン				;
;-----------------------------------------------;
main:						;
	cld					;
	mov	sp, offset start		;
	mov	bx, offset cright		;
	call	mesout				;
	mov	ax, cs				;
	add	ax, BSSseg			;
	mov	ds, ax				;
	mov	es, ax				;
	add	ax, (endBBS - freq + 0fh) / 10h	;
	cmp ax, cs:[0002h]
	jBE $_1
		mov	bx, offset memory	;
		jmp	errout			;
$_1:
;----------------				;
; make CRC table				;
;----------------				;
	mov	di, offset crctbl		;
	xor	dx, dx				;
$_2:
		mov	ax, dx			;
		mov	cx, 8			;
$_4:
			shr ax, 1
			jNC $_6
				xor	ax, CRC16
$_6:
		LOOP $_4
$_5:
		stosw				;
	inc dl
	jNZ $_2
$_3:
;-------------------------			;
; make table for position			;
;-------------------------			;
	mov	si, offset _TEXT:chglen		;
	mov	di, offset DGROUP:d_len		;
	mov	ax, 1				; d_len = real length - 2
	mov	dx, 0020h			;
$_7:
		cmp ah, cs:[si]
		jNE $_9
			inc	al		;
			inc	si		;
			shr	dx, 1		;
$_9:
		mov	cx, dx			;
$_10:
			mov	[di + d_code - d_len], ah
			stosb			;
		LOOP $_10
$_11:
		inc	ah			;
	cmp ah, 040h
	jL $_7
$_8:
;-----------------------------------------------;
	mov	text_ptr + 2, cs		;
	mov	text_ptr, offset _TEXT:endofcode;
	jmp	mn1				;
						;
$_12:
		xor	ch, ch			;
		push	cx			; cx = HeadSiz
		mov	di, offset DGROUP:cpyhdr;
		lodsw				; ah = HeadChk
		stosw				;
$_14:
			sub	ah, [si]	;
			movsb			; copy header to _BSS seg.
		LOOP $_14
$_15:
						; di = end of cpyhdr
		pop	cx			;
		pop	ds			;
		mov	text_ptr, si		;
		jne	errhdr			;
						;
		mov	bx, offset DGROUP:cpyhdr.Fname
		mov	dx, bx			;
		add	bl, [bx - 1]		;
		adc	bh, 0			;
						;
		mov	ax, [bx]		; may be CRC
		mov	orgcrc, ax		;
						;
		sub	di, bx			; bx end of Fname
		mov	word ptr crcflg, di	; if 2, crc supported.
						; iolen = 0 also.
						;
		mov	di, offset DGROUP:cpyhdr.HeadID	; check ID & sum
		cmp	word ptr [di], 'l-'	;
		jne	errhdr			;
		mov	ax, 2[di]		;
		xchg	al, ah			;
		sub	ax, 'h0'		;
		mov	bp, ax			; bp = method
		cmp	ax, 0001h		;
		ja	errhdr			;
		cmp	byte ptr 4[di], '-'	;
						;
		jE $_16
errhdr:						;
			mov	bx, offset header
			jmp	errout		;
$_16:
						;
		mov	ax, 1			;
		cmp	word ptr cpyhdr.FnLen, 2101h ; 01h, '!'
		je	mn7			;
						;
		mov	byte ptr [bx], ' '	;
		mov	cx, bx			;
		sub	cx, dx			;
		inc	cx			;
		push	bx			;
		mov	bx, ax			; ax = 1
		mov	ah, 40h			;
		int	21h			; display file name
		pop	bx			;
		mov	byte ptr [bx], 0	;
						;
		mov	ax, 4300h		; get file attr
		int	21h			;   for check existence
		jc	mn5			;
						;
		mov	bx, offset overwt	; prompt
		call	mesout			;
		call	getyn			;
		je	mn5			;
						;
		mov	ax, cpyhdr.PacSiz	; skip file
		mov	dx, cpyhdr.PacSiz + 2	;
						;
		call	adjust			;
		jmp	mn6			;
mn5:						;
		mov	cl, 20h			; ch may be 0
		mov	ah, 3ch			;
		int	21h			; create file
		jNC $_17
			jmp	errwrite	;
$_17:
mn7:						;
		mov	outfile, ax		;
						;
		xor	ax, ax			;
		mov	curcrc, ax		;
;		mov	iolen, al		; already iolen = 0
						;
		or bp, bp
		jZ $_18
			call	Decode		;
		jmp short $_19
$_18:
			call	copyall		;
$_19:
						;
$_20:
		sub iolen, 8
		jL $_22
			dec	word ptr text_ptr
		jmp $_20
$_22:
$_21:
		call	adjust0			;
						;
		mov	dx, cpyhdr.FDate	;
		mov	cx, cpyhdr.FTime	;
		mov	bx, outfile		;
		cmp	bx, 1			;
		je	mn8			;
		mov	ax, 5701h		; set date
		int	21h			;
		call	close			;
						;
		cmp crcflg, 2
		jNE $_23
			mov	ax, curcrc	;
			cmp	ax, orgcrc	;
			jne	errcrc		;
$_23:
		jmp	mn6			;
mn8:						;
		call	getyn			;
		jne	exit			;
mn6:						;
		mov	bx, offset crlf		;
		call	mesout			;
mn1:						;
		push	ds			;
		lds	si, dword ptr text_ptr	;
		mov	cl, [si]		;
	or cl, cl
	jZ $_24
	jmp $_12
$_13:
$_24:
	pop	ds				;
exit:						;
	mov	ax, 4c00h			;
	int	21h				;
resident:					;
						;
;-----------------------------------------------;
;	エラー処理				;
;-----------------------------------------------;
	public	errhdr, errwrite, errout	;
errcrc:						;
	call	unlink				;
	mov	bx, offset crcmes		;
	jmp	short errout1			;
						;
errwrite:					;
	call	close				;
	call	unlink				;
	mov	bx, offset write		;
						;
errout:						;
	call	mesout				;
	mov	bx, offset error		;
errout1:					;
	call	mesout				;
	mov	ax, 4c01h			;
	int	21h				;
						;
;-----------------------------------------------;
;	get 'Y' or 'N'				;
;-----------------------------------------------;
getyn	proc	near				;
	mov	bx, offset yesno		; prompt
	call	mesout				;
$_25:
		mov	ah, 08h			;
		int	21h			;
		and	al, 0dfh		;
	cmp al, 'Y'
	jE $_27
	cmp al, 'N'
	jNE $_25
$_26:
$_27:
	mov	bx, offset mes_yn		;
	mov	cs:[bx], al			;
	call	mesout				;
	cmp	al, 'Y'				;
	ret					;
getyn	endp					;
;-----------------------------------------------;
;	バッファの出力				;
;-----------------------------------------------;
	public	putbuf				;
putbuf	proc	near				;
	mov	dx, offset text_buf		;
	mov	cx, di				;
	mov	bx, outfile			;
	mov	ah, 40h				; write to file
	int	21h				;
	jc	errwrite			;
	sub ax, cx
	jE $_28
		cmp	bx, 1			;
		jne	errwrite		;
$_28:
						;
	push	si				;
	mov	si, dx				;
	jcxz	putbuf9				;
	mov	ax, curcrc			;
$_29:
		xor	al, [si]		;
		inc	si			;
		mov	bl, al			; crc & 0xff
		xor	bh, bh			;
		mov	al, ah			; crc >> 8
		xor	ah, ah			;
		shl	bx, 1			;
		xor	ax, crctbl[bx]		;
	LOOP $_29
$_30:
	mov	curcrc, ax			;
putbuf9:					;
	call	adjust0				;
						;
	pop	si				;
	cmp	outfile, 1			;
	je	return				;
	mov	ah, 02h				;
	mov	dl, '.'				;
	jmp	short int21_ret			; int	21h
						; ret
putbuf	endp					;
						;
;-----------------------------------------------;
;	ファイルの close			;
;-----------------------------------------------;
	public	close				;
close	proc	near				;
	mov	bx, outfile			;
	mov	ah, 3eh				;
	jmp	short int21_ret			; int	21h
						; ret
close	endp					;
						;
;-----------------------------------------------;
;	ファイルの削除				;
;-----------------------------------------------;
	public	unlink				;
unlink	proc	near				;
	mov	dx, offset cpyhdr.Fname		;
	mov	ah, 41h				; unlink
int21_ret:					;
	int	21h				;
return:						;
	ret					;
unlink	endp					;
						;
;-----------------------------------------------;
;	adjust text pointer			;
;-----------------------------------------------;
;	dx_ax : add count			;
;-----------------------------------------------;
	public	adjust0, adjust1, adjust	;
adjust0	proc	near				;
	xor	ax, ax				;
adjust1	proc	near				;
	cwd					;
adjust	proc	near				;
	mov	si, offset text_ptr		;
						;
	add	word ptr [si], 10h		;
	dec	word ptr 2[si]			;
						;
	add	ax, [si]			;
	adc	dx, 0				;
	mov	cx, ax				;
	and	cx, 000fh			;
	mov	[si], cx			;
	sub	ax, cx				;
	or	ax, dx				;
	mov	cl, 4				;
	ror	ax, cl				;
	add	2[si], ax			;
	ret					;
adjust	endp					;
adjust1	endp					;
adjust0	endp					;
						;
;-----------------------------------------------;
;	そのまま出力				;
;-----------------------------------------------;
	public	copyall				;
copyall	proc	near				;
	xor	di, di				;
$_31:
		mov	bx, offset DGROUP:cpyhdr.OrgSiz
		sub	[bx], di		;
		sbb	word ptr 2[bx], 0	;
		mov	cx, N			;
		jNE $_34
			mov	ax, [bx]	;
			or	ax, ax		;
			jz	cpyend		;
		cmp ax, cx
		jAE $_34
			mov	cx, ax		;
$_34:
						;
		push	cx			;
		mov	di, offset text_buf	;
		lds	si, dword ptr text_ptr	;
		rep	movsb			;
		push	es			;
		pop	ds			;
		pop	di			;
		call	putbuf			;
		mov	ax, di			;
		call	adjust1			;
	jmp $_31
$_33:
$_32:
cpyend:						;
	ret					;
copyall	endp					;
						;
;-----------------------------------------------;
;	メッセージの出力			;
;-----------------------------------------------;
	public	mesout				;
mesout	proc	near				;
	push	ds				;
	push	ax				;
	push	dx				;
	push	cs				;
	pop	ds				;
	mov	dx, bx				;
	mov	ah, 09h				;
	int	21h				;
	pop	dx				;
	pop	ax				;
	pop	ds				;
	ret					;
mesout	endp					;
						;
;-----------------------------------------------;
;	木構造の再構築				;
;-----------------------------------------------;
		public	reconst			;
reconst	proc	near				;
	push	si				;
						;
	xor	si, si				;
	mov	di, si				;
$_35:
		mov	bx, son[si]		;
		lodsw				; freq[si]
		cmp bx, bp
		jB $_37
			inc	ax		;
			shr	ax, 1		;
			mov	son[di], bx	;
			stosw			; mov	freq[di], ax
						; add	di, 2
$_37:
	cmp si, bp
	jB $_35
$_36:
	xor	si, si				;
$_38:
		push	si			;
		lodsw				; freq[si]
		add	ax, [si]		; freq[bx]
		mov	[di], ax		; freq[di], ax
						;
		mov	bx, di			;
$_40:
			dec	bx		;
			dec	bx		;
		cmp ax, [bx]
		jB $_40
$_41:
		inc	bx			;
		inc	bx			;
						;
		push	ax			;
		push	di			;
		std				;
		jmp	short rc1		;
$_42:
			mov	ax, [di - 2]	; freq[di - 2]
			mov	cx, son[di - 2]	;
			mov	son[di], cx	;
			stosw			; freq[di], ax
rc1:						;
		cmp di, bx
		jA $_42
$_43:
		cld				;
		pop	di			;
		pop	[bx]			; freq[bx]
		pop	son[bx]			;
						;
		lodsw				; add	si, 2
		scasw				; add	di, 2
	cmp di, bp
	jB $_38
$_39:
	xor	si, si				;
$_44:
		mov	di, son[si]		;
		mov	prnt[di], si		;
		cmp di, bp
		jAE $_46
			mov	prnt[di + 2], si;
$_46:
		lodsw				; add	si, 2
	cmp si, bp
	jB $_44
$_45:
						;
	pop	si				;
	ret					;
reconst	endp					;
						;
;-----------------------------------------------;
;	木構造の更新				;
;-----------------------------------------------;
;	si : prnt[c + T]			;
;-----------------------------------------------;
	public	update				;
update	proc	near				;
	or freq[R * 2], 0
	jNS $_47
		call	near ptr reconst	;
$_47:
	mov	si, ds:prnt[si + bp]		;
$_48:
		mov	di, si			; lea	di, freq[si]
		mov	ax, [di]		;
		scasw	; inc	di		;
			; inc	di		;
		scasw
		jNE $_50
			mov	cx, 0ffffh	; must large enough
			repe	scasw		;
			sub	di, 4		; offset freq + 4
						;
			mov	bx, son[si]	;
			mov	prnt[bx], di	;
			cmp bx, bp
			jAE $_51
				mov	prnt[bx + 2], di
$_51:
			xchg	bx, son[di]	;
			mov	prnt[bx], si	;
			cmp bx, bp
			jAE $_52
				mov	prnt[bx + 2], si
$_52:
			mov	son[si], bx	;
						;
			mov	si, di		;
$_50:
		inc	word ptr [si]		; freq[si]
		mov	si, prnt[si]		;
	or si, si
	jNZ $_48
$_49:
	ret					;
update	endp					;
						;
;-----------------------------------------------;
;	ＨＵＦの解読				;
;-----------------------------------------------;
		public	DecodeChar		;
DecodeChar	proc	near			;
	push	bp				;
	mov	bp, T * 2			;
	mov	si, son[R * 2]			;
	mov	dx, DGROUP:iobuf		;
	mov	cl, DGROUP:iolen		;
	xor	ch, ch				;
$_53:
		jcxz	GetBuf			;
dc2:						;
		shr	si, 1			;
		shl	dx, 1			;
		adc	si, 0			;
		shl	si, 1			;
		mov	si, son[si]		;
		dec	cx			;
	cmp si, bp
	jB $_53
$_54:
	mov	DGROUP:iobuf, dx		;
	mov	DGROUP:iolen, cl		;
	sub	si, bp				;
	push	si				;
	call	near ptr update			;
	pop	ax				;
	shr	ax, 1				;
	pop	bp				;
	ret					;
DecodeChar	endp				;
						;
	public	GetBuf				;
GetBuf:						;
	call	getc				;
	mov	dh, al				;
	call	getc				;
	mov	dl, al				;
	mov	cl, 16				;
	jmp	short dc2			;
						;
;-----------------------------------------------;
;	getc					;
;	    ax: 1 byte (return)			;
;-----------------------------------------------;
	public	getc				;
getc	proc	near				;
	push	es				;
	les	bx, dword ptr text_ptr		;
	mov	al, es:[bx]			;
	inc	text_ptr			;
	xor	ah, ah				;
	pop	es				;
	ret					;
getc	endp					;
						;
;-----------------------------------------------;
;	入力からｎビットを得る			;
;-----------------------------------------------;
;	cl : n bits				;
;-----------------------------------------------;
		public	GetNBits		;
GetNBits	proc	near			;
	push	cx				;
	mov	dx, DGROUP:iobuf		;
	cmp iolen, 8
	jG $_55
		call	getc			;
		mov	cl, 8			;
		sub	cl, DGROUP:iolen	;
		shl	ax, cl			;
		or	dx, ax			;
		add	DGROUP:iolen, 8		;
$_55:
	pop	cx				;
	mov	ax, dx				;
	shl	dx, cl				;
	mov	DGROUP:iobuf, dx		;
	sub	DGROUP:iolen, cl		;
	mov	dx, -1				;
	shr	dx, cl				;
	not	dx				;
	and	ax, dx				;
	ret					;
GetNBits	endp				;
						;
;-----------------------------------------------;
;	位置情報の解読				;
;-----------------------------------------------;
		public	DecodePosition		;
DecodePosition	proc	near			;
	mov	cx, 8				;
	call	near ptr GetNBits		;
	xchg	al, ah				;
	mov	si, ax				;
	mov	dl, d_code[si]			;
	mov	dh, 0				;
	mov	cl, 6				;
	shl	dx, cl				;
	push	dx				;
	mov	cl, d_len[si]			; ch == 0
	call	near ptr GetNBits		;
	or	ax, si				;
	rol	ax, cl				;
	and	ax, 003fh			;
	pop	dx				;
	add	ax, dx				;
	ret					;
DecodePosition	endp				;
						;
;-----------------------------------------------;
;	Decode					;
;-----------------------------------------------;
	public	Decode				;
Decode	proc	near				;
	mov	si, offset DGROUP:cpyhdr.OrgSiz	;
	lodsw					;
	or	ax, [si]			;
	jNZ $_56
		jmp	de9			;
$_56:
;----------------------------			;
;  ＨＵＦ用の木構造の初期化			;
;----------------------------			;
	public	StartHuff			;
StartHuff:					;
	mov	ax, 1				;
	mov	cx, N_CHAR			;
	push	cx				;
	xor	di, di				; mov	di, offset DGROUP:freq
	rep	stosw				;
	mov	ax, T * 2			;
	xor	dx, dx				;
	pop	cx				;
	mov	di, offset DGROUP:son		;
	mov	bx, offset DGROUP:prnt[T * 2]	;
$_57:
		stosw				;
		inc	ax			; add	ax, 2
		inc	ax			;
		mov	[bx], dx		;
		inc	bx			; add	bx, 2
		inc	bx			;
		inc	dx			; add	dx, 2
		inc	dx			;
	LOOP $_57
$_58:
						;
	xor	si, si				;
	mov	di, N_CHAR * 2			;
	mov	cx, N_CHAR - 1			;
$_59:
		mov	son[di], si		;
		mov	prnt[si], di		;
		lodsw				; mov	ax, freq[si]
		add	ax, [si]		; add	ax, freq[si + 2]
		mov	prnt[si], di		;
		stosw				; mov	freq[di], ax
		lodsw				;
	LOOP $_59
$_60:
	xor	ax, ax				;
	mov	iobuf, ax			;
;	mov	iolen, al			;
	mov	DGROUP:prnt[R * 2], ax		; prnt[R * 2], 0
	dec	ax				;
	mov	[di], ax			; freq[T * 2], -1
;----------------------------			;
						;
	mov	al, 20h				;
	mov	cx, F				;
	mov	di, offset DGROUP:text_buf + N - F
	rep	stosb				;
						;
	xor	di, di				;
	mov	bp, N - 1			;
$_61:
		push	di			;
		call	near ptr DecodeChar	;
;		$_if				;
		or	ah, ah			;
		jnz	de1			;
			pop	di		;
			mov	cx, 1		;
			push	cx		;
			jmp	short de2	;
;		$_else				;
de1:						;
			push	ax		;
			call	near ptr DecodePosition
			pop	cx		;
			pop	di		;
			mov	si, di		;
			sub	si, ax		;
			dec	si		;
			and	si, bp		;
			sub	cx, 255 - THRESHOLD
			push	cx		;
$_63:
				mov	al, DGROUP:text_buf[si]
				inc	si	;
				and	si, bp	;
de2:						;
				mov	DGROUP:text_buf[di], al
				inc	di	;
				cmp di, bp
				jBE $_65
					push	cx
					call	putbuf
					pop	cx
$_65:
				and	di, bp	;
			LOOP $_63
$_64:
			pop	cx		;
;		$_elseif			;
		mov	bx, offset DGROUP:cpyhdr.OrgSiz
		sub	[bx], cx		;
		pushf				;
		sbb	word ptr 2[bx], 0	;
		pop	ax			;
		lahf				;
		and	ah, al			;
		sahf				;
	jG $_61
$_62:
	call	putbuf				;
de9:						;
	ret					;
Decode	endp					;
						;
	public	endofcode			;
endofcode:					;
_TEXT	ends					;
	end	start				;
