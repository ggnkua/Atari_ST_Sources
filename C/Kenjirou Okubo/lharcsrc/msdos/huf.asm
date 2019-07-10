page	66, 120					;
;$_init						;
;***********************************************;
;	LHarc version 1.13 (c) Yoshi 1988-89.	;
;	adaptive Huffman module : 1989/ 5/ 4	;
;						;
; HTAB = 8					;
;***********************************************;
						;
extrn	__fgetc:near				;
extrn	fputc  :near				;
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
DGROUP	group	_DATA, _BSS			;
	assume	cs:_TEXT, ds:DGROUP		;
						;
_DATA	segment word public 'DATA'		;
						;
;-----------------------------------------------;
;	à íuèÓïÒïÑçÜâªï\			;
;-----------------------------------------------;
	public	_p_len, _p_code			;
	public	_d_len, _d_code			;
_p_len	label	byte				;
	db	003h, 004h, 004h, 004h, 005h, 005h, 005h, 005h
	db	005h, 005h, 005h, 005h, 006h, 006h, 006h, 006h
	db	006h, 006h, 006h, 006h, 006h, 006h, 006h, 006h
	db	007h, 007h, 007h, 007h, 007h, 007h, 007h, 007h
	db	007h, 007h, 007h, 007h, 007h, 007h, 007h, 007h
	db	007h, 007h, 007h, 007h, 007h, 007h, 007h, 007h
	db	008h, 008h, 008h, 008h, 008h, 008h, 008h, 008h
	db	008h, 008h, 008h, 008h, 008h, 008h, 008h, 008h
						;
_p_code	label	byte				;
	db	000h, 020h, 030h, 040h, 050h, 058h, 060h, 068h
	db	070h, 078h, 080h, 088h, 090h, 094h, 098h, 09Ch
	db	0A0h, 0A4h, 0A8h, 0ACh, 0B0h, 0B4h, 0B8h, 0BCh
	db	0C0h, 0C2h, 0C4h, 0C6h, 0C8h, 0CAh, 0CCh, 0CEh
	db	0D0h, 0D2h, 0D4h, 0D6h, 0D8h, 0DAh, 0DCh, 0DEh
	db	0E0h, 0E2h, 0E4h, 0E6h, 0E8h, 0EAh, 0ECh, 0EEh
	db	0F0h, 0F1h, 0F2h, 0F3h, 0F4h, 0F5h, 0F6h, 0F7h
	db	0F8h, 0F9h, 0FAh, 0FBh, 0FCh, 0FDh, 0FEh, 0FFh
						;
;-----------------------------------------------;
;	à íuèÓïÒâì«ï\				;
;-----------------------------------------------;
_d_code	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	01h, 01h, 01h, 01h, 01h, 01h, 01h, 01h
	db	02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
	db	02h, 02h, 02h, 02h, 02h, 02h, 02h, 02h
	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	08h, 08h, 08h, 08h, 08h, 08h, 08h, 08h
	db	09h, 09h, 09h, 09h, 09h, 09h, 09h, 09h
	db	0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah, 0Ah
	db	0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh
	db	0Ch, 0Ch, 0Ch, 0Ch, 0Dh, 0Dh, 0Dh, 0Dh
	db	0Eh, 0Eh, 0Eh, 0Eh, 0Fh, 0Fh, 0Fh, 0Fh
	db	10h, 10h, 10h, 10h, 11h, 11h, 11h, 11h
	db	12h, 12h, 12h, 12h, 13h, 13h, 13h, 13h
	db	14h, 14h, 14h, 14h, 15h, 15h, 15h, 15h
	db	16h, 16h, 16h, 16h, 17h, 17h, 17h, 17h
	db	18h, 18h, 19h, 19h, 1Ah, 1Ah, 1Bh, 1Bh
	db	1Ch, 1Ch, 1Dh, 1Dh, 1Eh, 1Eh, 1Fh, 1Fh
	db	20h, 20h, 21h, 21h, 22h, 22h, 23h, 23h
	db	24h, 24h, 25h, 25h, 26h, 26h, 27h, 27h
	db	28h, 28h, 29h, 29h, 2Ah, 2Ah, 2Bh, 2Bh
	db	2Ch, 2Ch, 2Dh, 2Dh, 2Eh, 2Eh, 2Fh, 2Fh
	db	30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h
	db	38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh
						;
						;
_d_len	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	04h, 04h, 04h, 04h, 04h, 04h, 04h, 04h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	05h, 05h, 05h, 05h, 05h, 05h, 05h, 05h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	06h, 06h, 06h, 06h, 06h, 06h, 06h, 06h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	07h, 07h, 07h, 07h, 07h, 07h, 07h, 07h
	db	08h, 08h, 08h, 08h, 08h, 08h, 08h, 08h
	db	08h, 08h, 08h, 08h, 08h, 08h, 08h, 08h
	even					;
_DATA	ends					;
						;
		public	THRESHOLD, F, N_CHAR, T	;
THRESHOLD	equ	2			;
F		equ	60			;
N_CHAR		equ	(256 - THRESHOLD + F)	;
T		equ	(N_CHAR * 2 - 1)	;
R		equ	(T - 1)			;
MAX_FREQ	equ	8000h			;
						;
_BSS	segment	word public 'BSS'		;
	public	_freq, _prnt, _son		;
	public	_iobuf, _iolen, _iobuf, _iolen	;
						;
_freq	dw	(T + 1) dup (?)			;
_prnt	dw	(T + N_CHAR) dup (?)		;
_son	dw	T dup (?)			;
_iobuf	label	word				;
	dw	1 dup (?)			;
_iolen	label	byte				;
	db	1 dup (?)			;
_BSS	ends					;
						;
extrn	_infile		:word			;
extrn	_outfile	:word			;
extrn	_codesize	:word			;
extrn	_backup2	:byte			;
extrn	_error		:near			;
						;
_TEXT	segment	byte public 'CODE'		;
	assume	cs:_TEXT, ds:DGROUP		;
						;
;-----------------------------------------------;
;	ì¸óÕÇ©ÇÁÇPÉoÉCÉgÇìæÇÈ			;
;-----------------------------------------------;
		public	_GetByte		;
_GetByte	proc	near			;
	mov	dx, DGROUP:_iobuf		;
	cmp _iolen, 8
	jG $_1
		call	_GetBufFill		;
$_1:
	xchg	dl, dh				;
	mov	ax, dx				;
	xor	dl, dl				;
	mov	DGROUP:_iobuf, dx		;
	sub	DGROUP:_iolen, 8		;
	xor	ah, ah				;
	ret					;
_GetByte	endp				;
						;
;-----------------------------------------------;
;	ì¸óÕÇ©ÇÁÇéÉrÉbÉgÇìæÇÈ			;
;-----------------------------------------------;
;	cl : n bits				;
;-----------------------------------------------;
		public	_GetNBits		;
_GetNBits	proc	near			;
	push	cx				;
	mov	dx, DGROUP:_iobuf		;
	cmp _iolen, 8
	jG $_2
		call	_GetBufFill		;
$_2:
	pop	cx				;
	mov	ax, dx				;
	shl	dx, cl				;
	mov	DGROUP:_iobuf, dx		;
	sub	DGROUP:_iolen, cl		;
	mov	dx, -1				;
	shr	dx, cl				;
	not	dx				;
	and	ax, dx				;
	ret					;
_GetNBits	endp				;
						;
;-----------------------------------------------;
;	ÇPÉoÉCÉgì¸óÕ				;
;-----------------------------------------------;
_GetBufFill	proc	near			;
	mov	bx, DGROUP:_infile		;
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
	or ax, ax
	jGE $_3
		inc	ax			;
$_3:
	pop	bx				;
	pop	cx				;
	pop	dx				;
getc2:						;
	mov	cl, 8				;
	sub	cl, DGROUP:_iolen		;
	shl	ax, cl				;
	or	dx, ax				;
	add	DGROUP:_iolen, 8		;
	ret					;
_GetBufFill	endp				;
						;
;-----------------------------------------------;
;	ÇéÉrÉbÉgèoóÕ				;
;-----------------------------------------------;
; ax : code					;
; ch : len					;
;-----------------------------------------------;
		public	_Putcode		;
_Putcode	proc	near			;
	mov	dx, ax				;
	mov	cl, DGROUP:_iolen		;
	shr	ax, cl				;
	or	_iobuf, ax			;
	add	cl, ch				;
	cmp	cl, 8				;
	jae	_PutBuf1			;
_Putcode1:					;
	mov	_iolen, cl			;
	ret					;
						;
_PutBuf1:					;
	mov	al, byte ptr _iobuf + 1		;
	mov	bx, DGROUP:_outfile		;
	putc@					;
	sub	cl, 8				;
	cmp	cl, 8				;
	jae	_PutBuf2			;
	mov	ah, byte ptr _iobuf		;
	mov	al, 0				;
	mov	_iobuf, ax			;
	add	DGROUP:_codesize, 1		;
	adc	DGROUP:_codesize + 2, 0		;
	jmp	_Putcode1			;
						;
_PutBuf2:					;
	mov	al, byte ptr _iobuf		;
	mov	bx, DGROUP:_outfile		;
	putc@					;
	add	DGROUP:_codesize, 2		;
	adc	DGROUP:_codesize + 2, 0		;
	sub	cl, 8				;
	sub	ch, cl				;
	xchg	cl, ch				;
	shl	dx, cl				;
	xchg	cl, ch				;
	mov	_iobuf, dx			;
	jmp	_Putcode1			;
_Putcode	endp				;
						;
;-----------------------------------------------;
;	ÇgÇtÇeópÇÃñÿç\ë¢ÇÃèâä˙âª		;
;-----------------------------------------------;
		public	_StartModel		;
_StartModel	proc	near			;
	push	si				;
	push	di				;
	mov	ax, ds				;
	mov	es, ax				;
	cld					;
						;
	mov	ax, 1				;
	mov	cx, N_CHAR			;
	mov	di, offset DGROUP:_freq		;
	rep	stosw				;
						;
	mov	ax, T * 2			;
	mov	dx, 0				;
	mov	cx, N_CHAR			;
	mov	di, offset DGROUP:_son		;
	mov	bx, offset DGROUP:_prnt[T * 2]	;
$_4:
		stosw				;
		add	ax, 2			;
		mov	[bx], dx		;
		add	bx, 2			;
		add	dx, 2			;
	LOOP $_4
$_5:
						;
	mov	si, 0				;
	mov	di, 2				;
	mov	bx, N_CHAR * 2			;
	mov	cx, N_CHAR - 1			;
$_6:
		mov	ax, _freq[si]		;
		add	ax, _freq[di]		;
		mov	_freq[bx], ax		;
		mov	_son[bx], si		;
		mov	_prnt[si], bx		;
		mov	_prnt[di], bx		;
		add	si, 4			;
		add	di, 4			;
		add	bx, 2			;
	LOOP $_6
$_7:
	xor	ax, ax				;
	mov	_iobuf, ax			;
	mov	_iobuf, ax			;
	mov	_iolen, al			;
	mov	_iolen, al			;
	mov	word ptr DGROUP:_freq[T * 2], -1;
	mov	word ptr DGROUP:_prnt[R * 2], ax; 0
	pop	di				;
	pop	si				;
	ret					;
_StartModel	endp				;
						;
;-----------------------------------------------;
;	ñÿç\ë¢ÇÃçƒç\íz				;
;-----------------------------------------------;
		public	_reconst		;
_reconst	proc	near			;
	push	si				;
	mov	ax, ds				;
	mov	es, ax				;
	xor	si, si				;
	mov	di, si				;
$_8:
		cmp _son[si], T * 2
		jB $_10
			mov	ax, _freq[si]	;
			inc	ax		;
			shr	ax, 1		;
			mov	_freq[di], ax	;
			mov	ax, _son[si]	;
			mov	_son[di], ax	;
			inc	di		;
			inc	di		;
$_10:
		inc	si			;
		inc	si			;
	cmp si, T * 2
	jB $_8
$_9:
	xor	si, si				;
	mov	di, N_CHAR * 2			;
$_11:
		mov	bx, si			;
		inc	bx			;
		inc	bx			;
		mov	ax, _freq[si]		;
		add	ax, _freq[bx]		;
		mov	_freq[di], ax		;
						;
		mov	bx, di			;
$_13:
			dec	bx		;
			dec	bx		;
		cmp ax, _freq[bx]
		jB $_13
$_14:
		inc	bx			;
		inc	bx			;
		mov	cx, di			;
		sub	cx, bx			;
		shr	cx, 1			;
		std				;
		push	cx			;
		push	si			;
		push	di			;
		lea	si, _freq[di]		;
		mov	di, si			;
		dec	si			;
		dec	si			;
		rep	movsw			;
		mov	_freq[bx], ax		;
		pop	di			;
		pop	si			;
		pop	cx			;
						;
		push	si			;
		push	di			;
		lea	si, _son[di]		;
		mov	di, si			;
		dec	si			;
		dec	si			;
		rep	movsw			;
		pop	di			;
		pop	si			;
		mov	_son[bx], si		;
						;
		add	si, 4			;
		add	di, 2			;
	cmp di, T * 2
	jB $_11
$_12:
	xor	si, si				;
$_15:
		mov	di, _son[si]		;
		mov	_prnt[di], si		;
		cmp di, T * 2
		jAE $_17
			mov	_prnt[di + 2], si
$_17:
		inc	si			;
		inc	si			;
	cmp si, T * 2
	jB $_15
$_16:
	pop	si				;
	ret					;
_reconst	endp				;
						;
;-----------------------------------------------;
;	ñÿç\ë¢ÇÃçXêV				;
;-----------------------------------------------;
;	si : prnt[c + T]			;
;-----------------------------------------------;
	public	_update				;
_update	proc	near				;
	cmp _freq[R * 2], MAX_FREQ
	jB $_18
		call	near ptr _reconst	;
$_18:
	mov	si, _prnt[si + T * 2]		;
$_19:
		mov	ax, _freq[si]		;
		inc	ax			;
		mov	_freq[si], ax		;
		lea	di, [si + 2]		;
		cmp ax, _freq[di]
		jA $_21
		jmp $_22
$_21:
$_23:
				inc	di	; add	di, 2
				inc	di	;
			cmp ax, _freq[di]
			jA $_23
$_24:
			dec	di	; sub	di, 2
			dec	di		;
			xchg	ax, _freq[di]	;
			mov	_freq[si], ax	;
						;
			mov	bx, _son[si]	;
			mov	_prnt[bx], di	;
			cmp bx, T * 2
			jAE $_25
				mov	_prnt[bx + 2], di
$_25:
			xchg	bx, _son[di]	;
			mov	_prnt[bx], si	;
			cmp bx, T * 2
			jAE $_26
				mov	_prnt[bx + 2], si
$_26:
			mov	_son[si], bx	;
						;
			mov	si, di		;
$_22:
		mov	si, _prnt[si]		;
	or si, si
	jZ $_27
	jmp $_19
$_20:
$_27:
	ret					;
_update	endp					;
						;
;-----------------------------------------------;
;	ÇgÇtÇeÇÃïÑçÜâª				;
;-----------------------------------------------;
public	_EncodeChar				;
_EncodeChar	proc	near			;
	shl	bx, 1				;
	mov	si, bx				;
	mov	bx, _prnt[bx + T * 2]		;
	mov	ax, 0				;
	mov	ch, 0				;
$_28:
		mov	dx, bx			;
		shr	dx, 1			;
		shr	dx, 1			;
		rcr	ax, 1			;
		inc	ch			;
		mov	bx, _prnt[bx]		;
	cmp bx, R * 2
	jNE $_28
$_29:
	call	_Putcode			;
	call	_update				;
	ret					;
_EncodeChar	endp				;
						;
;-----------------------------------------------;
;	à íuèÓïÒÇÃïÑçÜâª			;
;-----------------------------------------------;
public	_EncodePosition				;
_EncodePosition	proc	near			;
	mov	si, bx				;
	mov	cl, 6				;
	shr	bx, cl				;
	mov	ah, byte ptr DGROUP:_p_code[bx]	;
	mov	al, 0				;
	mov	ch, byte ptr DGROUP:_p_len[bx]	;
	call	near ptr _Putcode		;
	mov	ax, si				;
	mov	ah, al				;
	mov	al, 0				;
	shl	ax, 1				;
	shl	ax, 1				;
	mov	ch, 6				;
	call	near ptr _Putcode		;
	ret					;
_EncodePosition	endp				;
						;
;-----------------------------------------------;
;	ÇgÇtÇeÇÃïÑçÜâªèIóπèàóù			;
;-----------------------------------------------;
		public	_EncodeEnd		;
_EncodeEnd	proc	near			;
$_30:
	cmp DGROUP:_iolen, 0
	jLE $_32
		mov	bx, DGROUP:_outfile	;
		mov	al, byte ptr _iobuf + 1	;
		putc@				;
		sub	_iolen, 8		;
		add	word ptr DGROUP:_codesize, 1
		adc	word ptr DGROUP:_codesize + 2, 0
	jmp $_30
$_32:
$_31:
	ret					;
_EncodeEnd	endp				;
						;
;-----------------------------------------------;
;	ÇgÇtÇeÇÃâì«				;
;-----------------------------------------------;
		public	_DecodeChar		;
_DecodeChar	proc	near			;
	mov	si, _son[R * 2]			;
	mov	dx, DGROUP:_iobuf		;
	mov	cl, DGROUP:_iolen		;
	and	cx, 00ffh			;
	jmp	short dc1			;
$_33:
		shr	si, 1			;
		shl	dx, 1			;
		adc	si, 0			;
		shl	si, 1			;
		mov	si, _son[si]		;
		dec	cx			;
dc1:						;
		jz	GetBuf			;
dc2:						;
	cmp si, T * 2
	jB $_33
$_34:
	mov	DGROUP:_iobuf, dx		;
	mov	DGROUP:_iolen, cl		;
	sub	si, T * 2			;
	mov	dx, si				;
	call	near ptr _update		;
	mov	ax, dx				;
	shr	ax, 1				;
	ret					;
_DecodeChar	endp				;
						;
	public	GetBuf				;
GetBuf:						;
	mov	bx, DGROUP:_infile		;
	getc@					;
	mov	dh, al				;
	mov	bx, DGROUP:_infile		;
	getc@					;
	mov	dl, al				;
	mov	cl, 16				;
	jmp	short dc2			;
						;
;-----------------------------------------------;
;	à íuèÓïÒÇÃâì«				;
;-----------------------------------------------;
		public	_DecodePosition		;
_DecodePosition	proc	near			;
	call	near ptr _GetByte		;
	mov	si, ax				;
	mov	dl, _d_code[si]			;
	mov	dh, 0				;
	mov	cl, 6				;
	shl	dx, cl				;
	push	dx				;
	mov	cl, _d_len[si]			;
	mov	ch, 0				;
	sub	cx, 2				;
	call	near ptr _GetNBits		;
	or	ax, si				;
	rol	ax, cl				;
	and	ax, 003fh			;
	pop	dx				;
	add	ax, dx				;
	ret					;
_DecodePosition	endp				;
_TEXT	ends					;
	end					;
