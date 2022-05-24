;       
;
;

.486
extrn   moveblock_ :near
extrn   idct_ :near
extrn	fillbfr_ : near

_TEXT segment para public use32 'CODE'

PUBLIC getbits_
PUBLIC showbits32_
PUBLIC getbits32_
PUBLIC startcode_
PUBLIC getbits1_,getbits6_,getbits8_
PUBLIC showbits1_,showbits5_,showbits6_,showbits9_,showbits10_,showbits11_,showbits16_,showbits23_
PUBLIC endian_convert_
PUBLIC flushbits_

assume cs:_TEXT, ds:_DATA

;
;
;
		ALIGN 16

fillbfr		proc	near
		sub	[_ld_bitpos],32
		add	[_ld_rdptr],4
		cmp	[_ld_rdptr],OFFSET _ld_rdbfr+8192
		jz	fillbfr_refill
		ret

fillbfr_refill:	push	eax
		call	fillbfr_
		pop 	eax
		ret
fillbfr		endp

showbitsQ	MACRO _X,_Y
		mov	_Y,[esi]	
		mov	edi,4[esi]
		shld	_Y,edi,cl
		shr	_Y,32-_X
		ENDM

flushbitsQ	MACRO _X
		LOCAL _flush_nrf
		add	cl,_X
		jnc	_flush_nrf
		add	esi,4
		sub	cl,32
		cmp	esi,OFFSET _ld_rdbfr+8192
		jnz	_flush_nrf
		call	fillbfr_refill
		mov	esi, OFFSET _ld_rdbfr
_flush_nrf:				
		ENDM

getbitsQ	MACRO _X,_Y
		showbitsQ _X,_Y
		flushbitsQ _X
		ENDM


showbits	MACRO _X
		push	ecx
		push	esi
		mov	cl,[_ld_bitpos]
		mov	esi,[_ld_rdptr]
		mov	eax,[esi]	
		mov	esi,4[esi]
		shld	eax,esi,cl
		shr	eax,32-_X
		pop	esi
		pop	ecx
		ENDM

getbits		MACRO _X
		push	ecx
		push	esi
		mov	cl,[_ld_bitpos]
		mov	esi,[_ld_rdptr]
		mov	eax,[esi]	
		mov	esi,4[esi]
		shld	eax,esi,cl
		shr	eax,32-_X
		add	cl,_X
		mov	[_ld_bitpos],cl	
		pop	esi
		pop	ecx
		jc	fillbfr	
		ENDM

getbits1_	proc near
		getbits 1
		ret
getbits1_	endp
getbits6_	proc near
		getbits 6
		ret
getbits6_	endp
getbits8_	proc near
		getbits 8 
		ret
getbits8_	endp

showbits16_	proc near
		showbits 16
		ret
showbits16_	endp

showbits1_	proc near
		showbits 1
		ret
showbits1_	endp

showbits5_	proc near
		showbits 5 
		ret
showbits5_	endp
showbits6_	proc near
		showbits 6
		ret
showbits6_	endp
showbits9_	proc near
		showbits 9 
		ret
showbits9_	endp
showbits10_	proc near
		showbits 10
		ret
showbits10_	endp
showbits11_	proc near
		showbits 11 
		ret
showbits11_	endp
showbits23_	proc near
		showbits 23 
		ret
showbits23_	endp

;
;
;
		ALIGN 16

endian_convert_ proc near
		push ebx
		push edx
endian_lp:	mov ebx,[edx]
		bswap ebx
		mov [edx],ebx
		add edx,4
		dec eax
		jnz endian_lp
		pop edx
		pop ebx
		ret
endian_convert_ endp

;
;
;
		ALIGN 16

startcode_	proc near 
		mov	eax,7
		and	al,[_ld_bitpos]
		je	nah
		sub	[_ld_bitpos],al
startcode_lp:	mov	eax,8
		call	flushbits_
nah:	 	showbits 24
		cmp	eax,1
		jne	startcode_lp	
		ret
startcode_	endp

;
;
;
		ALIGN 16

showbits32_	proc near 
		push	ecx
		push	edx
		mov	cl,[_ld_bitpos]
		mov	edx,[_ld_rdptr]
		mov	eax,[edx]	
		mov	edx,4[edx]
		shld	eax,edx,cl
		pop	edx
		pop	ecx
		ret
showbits32_ 	endp 

;
;
;
		ALIGN 16

getbits_	proc near
		push	ebp
		push	ecx
		mov	cl,[_ld_bitpos]
		mov	ebp,[_ld_rdptr]
		mov	ch,al
		mov	eax,4[ebp]
		mov	ebp,[ebp]	
		shld	ebp,eax,cl
		mov	cl,ch
		xor	eax,eax
		shld	eax,ebp,cl
		add	[_ld_bitpos],cl
		pop	ecx
		pop	ebp
		jc	fillbfr	
		ret
getbits_	endp

;
;
;
		ALIGN 16

getbits32_	proc near
		push	ecx
		push	edx
		mov	cl,[_ld_bitpos]
		mov	edx,[_ld_rdptr]
		mov	eax,[edx]	
		mov	edx,4[edx]
		shld	eax,edx,cl
		add	[_ld_bitpos],32
		pop	edx
		pop	ecx
		jc	fillbfr	
		ret
getbits32_	endp

;
;
;
		ALIGN 16

flushbits_	proc near
		add	[_ld_bitpos],al
		jc	fillbfr	
		ret
flushbits_	endp

;
;
;
		ALIGN 16

getDClum	MACRO 
		showbitsQ 15,eax 
		mov 	eax,[eax*4+_dc_lum]
		flushbitsQ al 
		shr	eax,16
		ENDM

getDCchrom	MACRO 
		showbitsQ 16,eax 
		mov 	eax,[eax*4+_dc_chrom]
		flushbitsQ al 
		shr	eax,16
		ENDM

setDC		MACRO _X
		mov 	ebx,[_dc_dct_pred+(_X*4)]
		add	eax,ebx
		mov 	[_dc_dct_pred+(_X*4)],eax
		ENDM

		PUBLIC 	getintrablocks_

		ALIGN 16

getintrablocks_	proc	near
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		push	ebp
		mov	esi,[_ld_rdptr]
		mov	cl,[_ld_bitpos]
		getDClum
		lea	ebp,_ld_block+(0*128)
		setDC 0
		call	getintrablock_
		getDClum
		lea	ebp,_ld_block+(1*128)
		setDC 0
		call	getintrablock_
		getDClum
		lea	ebp,_ld_block+(2*128)
		setDC 0
		call	getintrablock_
		getDClum
		lea	ebp,_ld_block+(3*128)
		setDC 0
		call	getintrablock_

		getDCchrom
		lea	ebp,_ld_block+(4*128)
		setDC 1 
		call	getintrablock_

		getDCchrom
		lea	ebp,_ld_block+(5*128)
		setDC 2 
		call	getintrablock_
		mov	[_ld_bitpos],cl
		mov	[_ld_rdptr],esi

		IF 1 
		lea	eax,_ld_block+(0*128)
		call	idct_
		mov	eax,0
		call	moveblock_
		lea	eax,_ld_block+(1*128)
		call	idct_
		mov	eax,1
		call	moveblock_
		lea	eax,_ld_block+(2*128)
		call	idct_
		mov	eax,2
		call	moveblock_
		lea	eax,_ld_block+(3*128)
		call	idct_
		mov	eax,3
		call	moveblock_
		lea	eax,_ld_block+(4*128)
		call	idct_
		mov	eax,4
		call	moveblock_
		lea	eax,_ld_block+(5*128)
		call	idct_
		mov	eax,5
		call	moveblock_
		endif
_nah:		pop 	ebp
		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax
		ret
getintrablocks_ endp
; EBP -> Block
; EAX -> DC Value
		PUBLIC 	getintrablock_
		ALIGN 16

getintrablock_	proc	near
		sal	eax,3
		mov	[ebp],ax
		xor	eax,eax
		mov	2[ebp],ax
_I = 4
		rept 	31
		mov	_I[ebp],eax
_I = _I + 4
		endm
		mov	edx,1		; i = 1;
_getintra_lp:
		showbitsQ 17,eax
		mov	eax,[eax*4+_huff_next]
		flushbitsQ al		; flushbits(tab->len)
		cmp	ah,64
		jae	_getintra1
		add	dl,ah	 	; i+=tab->run;
		sar	eax,16
		mov	edi,[_zig_zag_scan+edx*4]
		imul	eax,[_ld_quant_scale]		; val*quant_scale
		imul	eax,[_ld_intra_quantizer_matrix+edi*4]		
		inc	edx
		sar	eax,3
		mov	word ptr [ebp+edi*2],ax
		jmp	_getintra_lp	

_getintra1:	jne	_getintra2
		ret
_getintra2:
		getbitsQ	14,eax
		add	dl,ah		; i+=getbits(6)
		and	eax,255
		jz	_getintra_valzero
		cmp	eax,128
		jl	_getintra3
		jg	_getintra_valhigher
		getbitsQ	8,eax
_getintra_valhigher:
		sub	eax,256
		jmp	_getintra3
_getintra_valzero:
		getbitsQ	8,eax	
_getintra3:	mov	edi,[_zig_zag_scan+edx*4]
		imul	eax,[_ld_quant_scale]		; val*quant_scale
		imul	eax,[_ld_intra_quantizer_matrix+edi*4]		
		inc	edx
		sar	eax,3
		mov	word ptr [ebp+edi*2],ax
		jmp	_getintra_lp

getintrablock_	endp

_TEXT           ends

_DATA segment para public use32 'DATA'
extrn   _ld_block : byte 
extrn   _ld_quant_scale : dword
extrn   _ld_intra_quantizer_matrix : dword
extrn   _zig_zag_scan : dword
extrn   _huff_next : dword
extrn   _dc_lum   : dword
extrn   _dc_chrom : dword
extrn 	_ld_rdbfr : near 
extrn 	_ld_rdptr : dword 
extrn   _dc_dct_pred : dword
_ld_bitpos	db	0	
		db	0
		db	0
		db	0
PUBLIC _ld_bitpos

; val/flush bits (9bit table lookup)

;EXPORT getCBP
			
			
;getCBP:		showbitsS	9
;			move.l	(coded_block_pattern,pc,d0*4),d0
;			flushbitsS  d0
;			swap	d0
;			rts
			
coded_block_pattern LABEL WORD
        db    -1, 0, -1, 0, 39, 9, 27, 9, 59, 9, 55, 9, 47, 9, 31, 9
        db    58, 8, 58, 8, 54, 8, 54, 8, 46, 8, 46, 8, 30, 8, 30, 8
        db    57, 8, 57, 8, 53, 8, 53, 8, 45, 8, 45, 8, 29, 8, 29, 8
        db    38, 8, 38, 8, 26, 8, 26, 8, 37, 8, 37, 8, 25, 8, 25, 8
        db    43, 8, 43, 8, 23, 8, 23, 8, 51, 8, 51, 8, 15, 8, 15, 8
        db    42, 8, 42, 8, 22, 8, 22, 8, 50, 8, 50, 8, 14, 8, 14, 8
        db    41, 8, 41, 8, 21, 8, 21, 8, 49, 8, 49, 8, 13, 8, 13, 8
        db    35, 8, 35, 8, 19, 8, 19, 8, 11, 8, 11, 8, 7, 8, 7, 8
        db    34, 7, 34, 7, 34, 7, 34, 7, 18, 7, 18, 7, 18, 7, 18, 7
        db    10, 7, 10, 7, 10, 7, 10, 7, 6, 7, 6, 7, 6, 7, 6, 7 
        db    33, 7, 33, 7, 33, 7, 33, 7, 17, 7, 17, 7, 17, 7, 17, 7
        db     9, 7, 9, 7, 9, 7, 9, 7, 5, 7, 5, 7, 5, 7, 5, 7
        db    63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6 
        db     3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6 
        db    36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6 
        db    24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6 
        db    62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5
        db    62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5
        db     2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5 
        db     2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5 
        db    61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5 
        db    61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5
        db     1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5 
        db     1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5 
        db    56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5 
        db    56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5 
        db    52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5 
        db    52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5 
        db    44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5 
        db    44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5 
        db    28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5 
        db    28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5 
        db    40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5 
        db    40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5 
        db    20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5 
        db    20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5 
        db    48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5 
        db    48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5 
        db    12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5 
        db    12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5 
        db    32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4 
        db    32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4 
        db    32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4 
        db    32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4 
        db    16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4 
        db    16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4 
        db    16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4 
        db    16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4 
        db     8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4 
        db     8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4 
        db     8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4 
        db     8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4
        db     4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
        db     4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
        db     4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
        db     4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3 
        db    60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3


_DATA		ends
                end
