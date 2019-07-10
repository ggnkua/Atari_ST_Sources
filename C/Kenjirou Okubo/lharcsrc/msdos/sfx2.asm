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
BufSiz		equ	04000h			;
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
	Fname	db	80h dup (?)		;
LzHead	ends					;
						;
_BSS	segment	para public 'BSS'		;
	public	freq, prnt, son			;
	public	d_len, d_code			;
	public	crctbl				;
	public	cpyhdr, infile, outfile		;
	public	inpptr				;
	public	curcrc, iobuf, iolen, crcflg, orgcrc
	public	myname, keyword, keyword2, keycnt
	public	param, pathname, fnnext, swchar	;
						;
freq		dw	(T + 1) dup (?)		;
prnt		dw	(T + N_CHAR) dup (?)	;
son		dw	T dup (?)		;
d_len		db	100h dup (?)		;
d_code		db	100h dup (?)		;
crctbl		dw	100h dup (?)		;
text_buf	db	N dup (?)		;
inpbuf		db	BufSiz dup (?)		;
inpptr		dw	1 dup (?)		;
cpyhdr		LzHead	1 dup (<?>)		;
infile		dw	1 dup (?)		;
outfile		dw	1 dup (?)		;
orgcrc		dw	1 dup (?)		;
curcrc		dw	1 dup (?)		;
iobuf		dw	1 dup (?)		;
crcflg		db	1 dup (?)		;
iolen		db	1 dup (?)		;
myname		db	80h dup (?)		;
keyword		db	80h dup (?)		;
keyword2	db	80h dup (?)		;
param		dw	20 dup (?)		;
pathname	db	80h dup (?)		;
fnnext		dw	1 dup (?)		;
fnptr		dw	1 dup (?)		;
swchar		db	1 dup (?)		;
endBBS		label	byte			;
_BSS		ends				;
						;
_TEXT	segment	byte public 'CODE'		;
	assume	cs:_TEXT			;
						;
	org	0100h				;
						;
	public	start, main			;
	public	BSSseg				;
	public	cright, chglen, crlf, space	;
	public	absent, myself, broken, extend	;
start:						;
	jmp	main				;
						;
BSSseg	=	(endofcode - start + 10fh) / 10h;
mes_yn	equ	space - 1			;
space	db	' ', 0				;
cright	db	"LHarc's SFX 1.13L (c)Yoshi, 1989."
	db	13, 10, 10, 0			;
absent	db	'Rename to '			;
myself	db	'            ', 0		;
chglen	db	01h, 04h, 0ch, 18h, 30h		; next byte must not be 3?h
overwt	db	'Overwrite ', 0			;
yesno	db	'[Y/N] ', 0			;
broken	db	'Broken file ', 0		;
write	db	'Write', 0			;
header	db	'Header', 0			;
crcmes	db	'CRC'				;
error	db	' Error'			;
crlf	db	13, 10, 0			;
auto	db	8, 'AUTOLARC'			;
autoflg	db	'.'				;
	db	'BAT'				;
extend	db	0				;
attrib	db	0				;
keycnt	dw	0				;
						;
envseg	=	002ch				;
cmdcnt	=	0080h				;
cmdline	=	0081h				;
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
	mov	es, ax				;
						;
	assume	es:DGROUP			;
;-----------------------------------------------;
;	Get options				;
;-----------------------------------------------;
	public	getopt				;
getopt:						;
	mov	ax, 3700h			;
	int	21h				; get switch char
	mov	si, cmdline			;
	mov	es:swchar, dl			;
						;
	mov	es:fnnext, offset DGROUP:pathname
$_1:
	    lodsb				;
	    call isspace
	    jE $_3
		cmp al, es:swchar
		jE $_4
		cmp al, '-'
		jNE $_5
$_4:
lp0:						;
		    lodsb			;
		    call isspace
		    jE $_6
			cmp al, 'e'
			jNE $_8
			    lodsb		;
			    mov	    di, offset DGROUP:pathname
			    mov	    ah, '\'	;
			    call    trans_t	;
			    mov	    al, ah	;
			    call isdelim2
			    jE $_9
				mov	al, '\'	;
				stosb		;
$_9:
			    mov	    es:fnnext, di
			    dec	    si		;
			    jmp short $_7
$_8:
			cmp al, 'x'
			jNE $_10
			    inc	    cs:extend	;
			    jmp short $_7
$_10:
			cmp al, 'a'
			jNE $_11
			    inc	    cs:attrib	;
$_11:
$_7:
			jmp	lp0		;
$_6:
		jmp short $_12
$_5:
		    mov	    di, offset DGROUP:keyword
		    mov	    dx, di		;
		    call    trans		;
		    sub	    di, dx		;
		    mov	    cs:keycnt, di	;
$_12:
lp1:						;
$_3:
	cmp al, 0dh
	jNE $_1
$_2:
						;
public	mnlp1					;
mnlp1:						;
	push	es				;
	pop	ds				;
						;
	assume	ds:DGROUP			;
;-----------------------------------------------;
;	Get my name				;
;-----------------------------------------------;
	mov	ah, 30h				;
	int	21h				; get DOS ver.
	push	ds				;
	cmp al, 3
	jB $_13
		mov	ax, cs:[envseg]		;
		mov	es, ax			;
		xor	ax, ax			;
		mov	di, ax			;
		mov	cx, -1			;
$_14:
			repne	scasb		;
			scasb			;
		jNE $_14
$_15:
		inc	ax			;
		scasw				;
		push	es			;
		pop	ds			;
		mov	dx, di			;
		je	openme			;
	jmp short $_16
$_13:
		mov	ax, cs:[0002h]		;
		sub	ax, 38h			;
		mov	ds, ax			;
		mov	dx, 0009h		;
		jmp	short openme		;
$_16:
brknenv:					;
	push	cs				;
	pop	ds				;
	mov	dx, offset myself		;
openme:						;
	mov	ax, 3d00h			;
	int	21h				; Open Myself
	jNC $_17
		cmp	dx, offset myself	;
		jne	brknenv			;
		mov	bx, offset absent	;
		call	mesout			;
		mov	bx, offset crlf		;
		jmp	errout1			;
$_17:
	pop	ds				;
	mov	infile, ax			;
						;
	mov	bx, ax				;
	xor	cx, cx				;
exehdr	=	20h				;
	mov	dx, (endofcode - start) + exehdr;
	mov	ax, 4200h			;
	int	21h				; Move a File Pointer
	jNC $_18
		mov	bx, offset broken	; Broken file
		jmp	errout			;
$_18:
	push	ds				;
	pop	es				;
;-----------------------------------------------;
;	Get Key-word from SFX-file		;
;-----------------------------------------------;
	mov	di, offset DGROUP:keyword2	;
	lea	dx, [di + 79]			;
	mov	si, dx				;
	mov	cx, 1				;
	mov	bx, infile			;
$_19:
		mov	[si], ch		; for error detect (ch = 0)
		mov	ah, 3fh			;
		int	21h			; Read 1 char
		mov	al, [si]		;
		stosb				;
	or al,al
	jNZ $_19
$_20:
;---------------------------------------	;
;	make CRC table				;
;---------------------------------------	;
	mov	di, offset crctbl		;
	xor	dx, dx				;
$_21:
		mov	ax, dx			;
		mov	cx, 8			;
$_23:
			shr ax, 1
			jNC $_25
				xor	ax, CRC16
$_25:
		LOOP $_23
$_24:
		stosw				;
	inc dl
	jNZ $_21
$_22:
;---------------------------------------	;
; make table for position			;
;---------------------------------------	;
	mov	si, offset _TEXT:chglen		;
	mov	di, offset DGROUP:d_len		;
	mov	ax, 1				; d_len = real length - 2
	mov	dx, 0020h			;
$_26:
		cmp ah, cs:[si]
		jNE $_28
			inc	al		;
			inc	si		;
			shr	dx, 1		;
$_28:
		mov	cx, dx			;
$_29:
			mov	[di + d_code - d_len], ah
			stosb			;
		LOOP $_29
$_30:
		inc	ah			;
	cmp ah, 040h
	jL $_26
$_27:
;---------------------------------------	;
						;
	public mainloop				;
mainloop:					;
$_31:
						;
; Get Header ---------------------------	;
		mov	DGROUP:cpyhdr.HeadSiz, 0;
		mov	bx, infile		;
		mov	cx, 1			;
		mov	dx, offset DGROUP:cpyhdr.HeadSiz
		mov	ah, 3fh			;
		int	21h			; Read header size
		dec	cx			; cx = 0
		add	cl, DGROUP:cpyhdr.HeadSiz
		jNZ $_34
			jmp	exit		;
$_34:
		inc	dx			;
		mov	si, dx			;
						;
		inc	cx			;
		mov	ah, 3fh			;
		int	21h			; Read header
						;
; Test Header Sum ----------------------	;
		lodsb				;
		mov	di, si			; cpyhdr.HeadID
		dec	cx			;
$_35:
			sub	al, [si]	;
			inc	si		;
		LOOP $_35
$_36:
		or	al, al			;
		jne	errhdr			;
		xchg	di, si			; di = end of cpyhdr
						;
; Test Header ID -----------------------	;
		lodsw				;
		cmp	ax, 'l-'		;
		jne	errhdr			;
		lodsw				;
		xchg	al, ah			;
		sub	ax, 'h0'		;
		mov	bp, ax			; bp = method
		cmp	ax, 0001h		;
		ja	errhdr			;
		lodsb				;
		cmp	al, '-'			;
		jE $_37
errhdr:						;
			mov	bx, offset header
			jmp	errout		;
$_37:
						;
; Get original CRC ---------------------	;
		mov	bx, offset DGROUP:cpyhdr.Fname
		mov	dx, bx			;
		mov	cl, [bx - 1]		; ch = 0
		add	bx, cx			;
						;
		mov	ax, [bx]		; may be CRC
		mov	orgcrc, ax		;
						;
		sub	di, bx			; bx  = end of Fname
		mov	word ptr crcflg, di	; if 2, crc supported.
						; iolen = 0 also.
						;
; Test Special File ? ------------------	;
		mov	ax, 1			;
		mov	fnptr, dx		;
		cmp	word ptr DGROUP:cpyhdr.FnLen, 2101h ; 01h, '!'
		jNE $_38
			jmp	mn7		;
$_38:
						;
		mov	si, dx			;
		mov	di, offset auto + 1	; AUTOLARC.BAT ?
		mov	cl, 12			; ch may be 0
		push	es			;
		push	cs			;
		pop	es			;
		rep	cmpsb			;
		pop	es			;
		je	mn2			;
						;
; -x switch ----------------------------	;
		mov	si, dx			;
		cmp cs:extend, 0
		jNE $_39
$_40:
				lodsb		;
				call isdelim2
				jNE $_43
					mov	dx, si
					jmp short $_42
$_43:
				call iskanji
				jNE $_44
					inc	si
$_44:
$_42:
			cmp si, bx
			jB $_40
$_41:
			mov	si, dx		;
$_39:
						;
; -eDIRECTORY --------------------------	;
		mov	al, [si]		;
		call isdelim2
		jE $_45
			mov	cx, bx		;
			sub	cx, dx		;
			mov	dx, offset DGROUP:pathname
			mov	di, fnnext	;
			rep	movsb		;
			mov	bx, di		;
		jmp short $_46
$_45:
			mov	ax, word ptr DGROUP:pathname
			cmp ah, ':'
			jNE $_47
				dec	dx	;
				dec	dx	;
				mov	di, dx	;
				mov	[di], ax; brakes FnLen and
$_47:
$_46:
		mov	fnptr, dx		;
		mov	cx, 1			;
						;
; Display File name --------------------	;
mn2:						;
		mov	word ptr [bx], 0 * 256 + ' '
		mov	bx, dx			;
		push	dx			;
		call	dispent			; output file name
		pop	dx			;
		mov	byte ptr [bx - 1], 0	;
						;
		jcxz	mn9			; AUTOLARC.BAT ?
						;
; Check Existence of File --------------	;
		mov	ax, 4300h		; get file attr
		int	21h			;   (for MS-DOS 3.3)
		jc	mn5			;
						;
		mov	bx, offset overwt	; prompt
		call	mesout			;
		call	getyn			;
		je	mn1			;
						;
; Skip to next File --------------------	;
		mov	dx, DGROUP:cpyhdr.PacSiz	; skip file
		mov	cx, DGROUP:cpyhdr.PacSiz + 2
						;
		mov	bx, infile		;
		mov	ax, 4201h		;
		int	21h			; Move a File Pointer
		jmp	mn6			;
mn9:						;
		mov	cs:autoflg, 0dh		;
						;
; Make Directories ---------------------	;
mn5:						;
		mov	si, dx			;
		lodsb				;
		jmp	short mn0		;
$_48:
			lodsb			;
			call isdelim2
			jNE $_50
				mov	byte ptr [si - 1], 0
				mov	ah, 39h	; make dir
				int	21h	;
				mov	byte ptr [si - 1], '\'
$_50:
mn0:						;
			call iskanji
			jNE $_51
				inc	si	;
$_51:
		cmp al, 0
		jNE $_48
$_49:
						;
; Create a New File --------------------	;
mn1:						;
		mov	cl, 20h			; ch may be 0
		mov	ah, 3ch			;
		int	21h			; Create a File
		jNC $_52
			jmp	errwrite	;
$_52:
						;
; Decode -------------------------------	;
mn7:						;
		mov	outfile, ax		;
						;
		mov	curcrc, 0		;
;		mov	iolen, 0		; already iolen = 0
		mov	inpptr, -1		;
						;
		push	dx			;
		or bp, bp
		jZ $_53
			call	Decode		;
		jmp short $_54
$_53:
			call	copyall		;
$_54:
		pop	si			;
						;
; Set Time-Stamp -----------------------	;
		mov	bx, outfile		;
		cmp	bx, 1			; file '!' ?
		je	mn8			;
						;
		mov	dx, DGROUP:cpyhdr.FDate	;
		mov	cx, DGROUP:cpyhdr.FTime	;
		mov	ax, 5701h		; set date
		int	21h			;
		mov	bx, outfile		;
		call	close			;
						;
; Check CRC ----------------------------	;
		mov	dx, si			;
		cmp crcflg, 2
		jNE $_55
			mov	ax, curcrc	;
			cmp	ax, orgcrc	;
			jne	errcrc		;
$_55:
						;
; Set File Attributes ------------------	;
		cmp attrib, 0
		jE $_56
			mov	cl, byte ptr DGROUP:cpyhdr.FAttr
			mov	ch, 0		;
			mov	ax, 4301h	;
			int	21h		; Set File Attributes
$_56:
		jmp	mn6			;
mn8:						;
		call	getyn			;
		jne	exit1			;
mn6:						;
		mov	bx, offset crlf		;
		call	mesout			;
	jmp $_31
$_33:
$_32:
	public	exit				;
exit:						;
	push	ds				;
	pop	es				;
	cmp cs:autoflg, 0dh
	jNE $_57
		mov	cx, keycnt		;
		jcxz	exit1			;
		inc	cx			;
		mov	si, offset DGROUP:keyword
		mov	di, offset DGROUP:keyword2
	repe cmpsb
	jNE $_57
		push	cs			;
		pop	es			;
		mov	bx, (offset resident - start + 100h + 15) / 16
		mov	ah, 4ah			;
		int	21h			;
		push	cs			;
		pop	ds			;
		mov	si, offset auto		;
		int	2eh			; execute
$_57:
exit1:						;
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
	mov	bx, outfile			;
	call	close				;
	call	unlink				;
	mov	bx, offset write		;
						;
errout:						;
	call	mesout				;
	mov	bx, offset error		;
errout1:					;
	call	mesout				;
	mov	bx, infile			;
	call	close				;
	mov	ax, 4c01h			;
	int	21h				;
						;
;-----------------------------------------------;
;	get 'Y' or 'N'				;
;-----------------------------------------------;
	public	getyn				;
getyn	proc	near				;
	mov	bx, offset yesno		; prompt
	call	mesout				;
$_58:
		mov	ah, 08h			;
		int	21h			;
		and	al, 0dfh		;
	cmp al, 'Y'
	jE $_60
	cmp al, 'N'
	jNE $_58
$_59:
$_60:
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
	jE $_61
		cmp	bx, 1			;
		jne	errwrite		;
$_61:
						;
	push	si				;
	mov	si, dx				;
	jcxz	putbuf9				;
	mov	ax, curcrc			;
$_62:
		xor	al, [si]		;
		inc	si			;
		mov	bl, al			; crc & 0xff
		xor	bh, bh			;
		mov	al, ah			; crc >> 8
		xor	ah, ah			;
		shl	bx, 1			;
		xor	ax, crctbl[bx]		;
	LOOP $_62
$_63:
	mov	curcrc, ax			;
putbuf9:					;
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
;	そのまま出力				;
;-----------------------------------------------;
	public	copyall				;
copyall	proc	near				;
	xor	di, di				;
$_64:
		mov	bx, offset DGROUP:cpyhdr.OrgSiz
		sub	[bx], di		;
		sbb	word ptr 2[bx], 0	;
		mov	cx, N			;
		jNE $_67
			mov	ax, [bx]	;
			or	ax, ax		;
			jz	cpyend		;
		cmp ax, cx
		jAE $_67
			mov	cx, ax		;
$_67:
						;
		mov	dx, offset DGROUP:text_buf
		mov	bx, infile		;
		mov	ah, 3fh			;
		int	21h			;
		mov	di, cx			;
		call	putbuf			;
	jmp $_64
$_66:
$_65:
cpyend:						;
	ret					;
copyall	endp					;
						;
;-----------------------------------------------;
;	ファイルの close			;
;-----------------------------------------------;
	public	close				;
close	proc	near				;
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
	mov	dx, fnptr			;
	mov	ah, 41h				; unlink
int21_ret:					;
	int	21h				;
return:						;
	ret					;
unlink	endp					;
						;
;-----------------------------------------------;
;	buffer 入力				;
;-----------------------------------------------;
	public	getbuf				;
getbuf	proc	near				;
	push	ax				;
	push	bx				;
	push	cx				;
	push	dx				;
	mov	bx, infile			;
	mov	dx, offset DGROUP:inpbuf	;
	mov	cx, BufSiz			;
	cmp DGROUP:cpyhdr.PacSiz + 2, 0
	jNE $_68
	cmp cx, DGROUP:cpyhdr.PacSiz
	jBE $_68
		mov	cx, DGROUP:cpyhdr.PacSiz;
$_68:
	sub	DGROUP:cpyhdr.PacSiz, cx	;
	sbb	DGROUP:cpyhdr.PacSiz + 2, 0	;
	mov	ah, 3fh				;
	int	21h				; Read from an Archive
	mov	inpptr, dx			;
	pop	dx				;
	pop	cx				;
	pop	bx				;
	pop	ax				;
	ret					;
getbuf	endp					;
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
	call	dispent				;
	pop	dx				;
	pop	ax				;
	pop	ds				;
	ret					;
mesout	endp					;
						;
;-----------------------------------------------;
;	木構造の再構築				;
;-----------------------------------------------;
	public	reconst				;
reconst	proc	near				;
	push	si				;
						;
	xor	si, si				;
	mov	di, si				;
$_69:
		mov	bx, son[si]		;
		lodsw				; freq[si]
		cmp bx, bp
		jB $_71
			inc	ax		;
			shr	ax, 1		;
			mov	son[di], bx	;
			stosw			; mov	freq[di], ax
						; add	di, 2
$_71:
	cmp si, bp
	jB $_69
$_70:
	xor	si, si				;
$_72:
		push	si			;
		lodsw				; freq[si]
		add	ax, [si]		; freq[bx]
		mov	[di], ax		; freq[di], ax
						;
		mov	bx, di			;
$_74:
			dec	bx		;
			dec	bx		;
		cmp ax, [bx]
		jB $_74
$_75:
		inc	bx			;
		inc	bx			;
						;
		push	ax			;
		push	di			;
		std				;
		jmp	short rc1		;
$_76:
			mov	ax, [di - 2]	; freq[di - 2]
			mov	cx, son[di - 2]	;
			mov	son[di], cx	;
			stosw			; freq[di], ax
rc1:						;
		cmp di, bx
		jA $_76
$_77:
		cld				;
		pop	di			;
		pop	[bx]			; freq[bx]
		pop	son[bx]			;
						;
		lodsw				; add	si, 2
		scasw				; add	di, 2
	cmp di, bp
	jB $_72
$_73:
	xor	si, si				;
$_78:
		mov	di, son[si]		;
		mov	prnt[di], si		;
		cmp di, bp
		jAE $_80
			mov	prnt[di + 2], si;
$_80:
		lodsw				; add	si, 2
	cmp si, bp
	jB $_78
$_79:
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
	jNS $_81
		call	near ptr reconst	;
$_81:
	mov	si, ds:prnt[si + bp]		;
$_82:
		mov	di, si			; lea	di, freq[si]
		mov	ax, [di]		;
		scasw	; inc	di		;
			; inc	di		;
		scasw
		jNE $_84
			mov	cx, 0ffffh	; must large enough
			repe	scasw		;
			sub	di, 4		; offset freq + 4
						;
			mov	bx, son[si]	;
			mov	prnt[bx], di	;
			cmp bx, bp
			jAE $_85
				mov	prnt[bx + 2], di
$_85:
			xchg	bx, son[di]	;
			mov	prnt[bx], si	;
			cmp bx, bp
			jAE $_86
				mov	prnt[bx + 2], si
$_86:
			mov	son[si], bx	;
						;
			mov	si, di		;
$_84:
		inc	word ptr [si]		; freq[si]
		mov	si, prnt[si]		;
	or si, si
	jNZ $_82
$_83:
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
$_87:
		jcxz	getword			;
dc2:						;
		shr	si, 1			;
		shl	dx, 1			;
		adc	si, 0			;
		shl	si, 1			;
		mov	si, son[si]		;
		dec	cx			;
	cmp si, bp
	jB $_87
$_88:
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
	public	getword				;
getword:					;
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
	cmp inpptr, offset inpbuf + BufSiz
	jB $_89
		call	getbuf			;
$_89:
	mov	bx, inpptr			;
	mov	al, [bx]			;
	inc	inpptr				;
	xor	ah, ah				;
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
	jG $_90
		call	getc			;
		mov	cl, 8			;
		sub	cl, DGROUP:iolen	;
		shl	ax, cl			;
		or	dx, ax			;
		add	DGROUP:iolen, 8		;
$_90:
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
	jNZ $_91
		jmp	de9			;
$_91:
	push	ds				;
	pop	es				;
;---------------------------------------	;
;  ＨＵＦ用の木構造の初期化			;
;---------------------------------------	;
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
$_92:
		stosw				;
		inc	ax			; add	ax, 2
		inc	ax			;
		mov	[bx], dx		;
		inc	bx			; add	bx, 2
		inc	bx			;
		inc	dx			; add	dx, 2
		inc	dx			;
	LOOP $_92
$_93:
						;
	xor	si, si				;
	mov	di, N_CHAR * 2			;
	mov	cx, N_CHAR - 1			;
$_94:
		mov	son[di], si		;
		mov	prnt[si], di		;
		lodsw				; mov	ax, freq[si]
		add	ax, [si]		; add	ax, freq[si + 2]
		mov	prnt[si], di		;
		stosw				; mov	freq[di], ax
		lodsw				;
	LOOP $_94
$_95:
	xor	ax, ax				;
	mov	iobuf, ax			;
;	mov	iolen, al			;
	mov	DGROUP:prnt[R * 2], ax		; prnt[R * 2], 0
	dec	ax				;
	mov	[di], ax			; freq[T * 2], -1
;---------------------------------------	;
						;
	mov	al, 20h				;
	mov	cx, F				;
	mov	di, offset DGROUP:text_buf + N - F
	rep	stosb				;
						;
	xor	di, di				;
	mov	bp, N - 1			;
$_96:
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
$_98:
				mov	al, DGROUP:text_buf[si]
				inc	si	;
				and	si, bp	;
de2:						;
				mov	DGROUP:text_buf[di], al
				inc	di	;
				cmp di, bp
				jBE $_100
					push	cx
					call	putbuf
					pop	cx
$_100:
				and	di, bp	;
			LOOP $_98
$_99:
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
	jG $_96
$_97:
	call	putbuf				;
de9:						;
	ret					;
Decode	endp					;
						;
;-----------------------------------------------;
;	is Japanese kanji char			;
;-----------------------------------------------;
	public	iskanji				;
iskanji	proc	near				;
	push	ax				;
	and	al, 0e0h			;
	cmp	al, 080h			;
	je	ik_ret				;
	cmp	al, 0e0h			;
ik_ret:						;
	pop	ax				;
	ret					;
iskanji	endp					;
						;
;-----------------------------------------------;
;	is delimiter of path-name		;
;-----------------------------------------------;
	public	isdelim				;
	public	isdelim2			;
isdelim proc	near				;
	cmp	al, ':'				;
	je	id_ret				;
isdelim2:					;
	cmp	al, '\'				;
	je	id_ret				;
	cmp	al, '/'				;
id_ret:						;
	ret					;
isdelim endp					;
						;
;-----------------------------------------------;
;	is spacing char				;
;-----------------------------------------------;
	public	isspace				;
isspace proc	near				;
	cmp	al, 0dh				;
	je	is_ret				;
	cmp	al, 09h				;
	je	is_ret				;
	cmp	al, ' '				;
is_ret:						;
	ret					;
isspace endp					;
						;
;-----------------------------------------------;
;	transfer from cmd-line			;
;-----------------------------------------------;
	public	trans				;
	public	trans_t				;
trans	proc	near				;
$_101:
		mov	ah, al			;
		stosb				;
		call iskanji
		jNZ $_103
			movsb			;
$_103:
trans_e:					;
		lodsb				;
trans_t:					;
	call isspace
	jNZ $_101
$_102:
	mov	byte ptr es:[di], 0		;
	ret					;
trans	endp					;
						;
;-----------------------------------------------;
;	display ASCIZ char			;
;-----------------------------------------------;
	public	disp				;
disp	proc	near				;
$_104:
		inc	bx			;
		mov	ah, 02h			;
		int	21h			;
dispent:					;
		mov	dl, [bx]		;
	or dl, dl
	jNZ $_104
$_105:
	ret					;
disp	endp					;
						;
	public	endofcode			;
endofcode:					;
_TEXT	ends					;
	end	start				;
