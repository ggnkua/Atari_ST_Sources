;-------------------------------------------------------------------------------
; PRO-PACK Unpack Source Code - IBM PC, Method 2
;
; Copyright (c) 1991,92 Rob Northen Computing, UK. All Rights Reserved.
;
; File: RNC_2.ASM
;
; Date: 6.04.92
;-------------------------------------------------------------------------------

                .MODEL compact

;-------------------------------------------------------------------------------
; Conditional Assembly Flags
;-------------------------------------------------------------------------------

CHECKSUMS       EQU     0               ; set this flag to 1 if you require
                                        ; data to be validated

PROTECTED       EQU     0               ; set this flag to 1 if you are unpacking
                                        ; files packed with the "-K" option

;-------------------------------------------------------------------------------
; Return Codes
;-------------------------------------------------------------------------------

NOT_PACKED      EQU     0
PACKED_CRC      EQU     -1
UNPACKED_CRC    EQU     -2

;-------------------------------------------------------------------------------
; Other Equates
;-------------------------------------------------------------------------------

HEADER_LEN      EQU     18

;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

reload          MACRO
                lodsb
                adc al,al
                ENDM

getbit          MACRO
                add al,al
                ENDM

getraw          MACRO
                movsb
IF PROTECTED
                xor     es:[di-1],dl
                ror     dx,1
ENDIF
                ENDM

getrawREP       MACRO
IFE PROTECTED
                rep     movsw
ELSE
getrawREP2:
                movsw
                xor     es:[di-1],dl
                xor     es:[di-2],dl
                loop    getrawREP2
                ror     dx,1
ENDIF
                ENDM

;-------------------------------------------------------------------------------
; Code Segment
;-------------------------------------------------------------------------------

                .CODE

; these variables must be in same segment as the code

IF CHECKSUMS
crc_u           dw      ?
crc_p           dw      ?
buffer          db      200h dup(?)
ENDIF

input_hi        dw      2 dup(?)
unpack_len      dw      2 dup(?)
pack_len        dw      2 dup(?)
pack_paras      dw      ?

;------------------------------------------------------------------------------
; PRO-PACK Unpack Routine - IBM PC, Method 2
;
; C Prototype,
;
; EXTERN long far Unpack(void far *input, void far *output, int key)
;
; Input and Output must point to an address on a paragraph boundary.
;
; Returns,
;       Length of unpacked file in bytes OR error code
;            0 = not a packed file
;           -1 = packed data crc error
;           -2 = unpacked data crc error
;
; To Call from Assembler,
;
;       push KEY                ; pass only if packed file is protected
;       push SEG output
;       push OFFSET output
;       push SEG input
;       push OFFSET input
;       call Unpack
;       add sp,10
;
; Input and Output must point to an address on a paragraph boundary.
;
; On exit,
;       AX = length of unpacked file in bytes OR error code (low word)
;       DX = length of unpacked file in bytes OR error code (high word)
;            0 = not a packed file
;           -1 = packed data crc error
;           -2 = unpacked data crc error
;
; Note: The packed file can be unpacked 'over itself', ie the input buffer is
; the same as the output buffer. If so the bytes in the last paragraph of the
; output buffer at the end of the unpacked file will be corrupted.
;------------------------------------------------------------------------------
                PUBLIC  C Unpack
Unpack          PROC C FAR
IF PROTECTED
                ARG input:DATAPTR, output:DATAPTR, key:WORD
ELSE
                ARG input:DATAPTR, output:DATAPTR
ENDIF
                USES si,di,ds
                cld
                mov     si,WORD PTR input
                mov     ax,WORD PTR input+2
                mov     cl,4
                shr     si,cl
                add     ax,si
                mov     ds,ax
                mov     di,WORD PTR output
                mov     ax,WORD PTR output+2
                shr     di,cl
                add     ax,di
                mov     es,ax
                xor     si,si
                lodsw
                cmp     ax,4E52h
                jne     not_pack
                lodsw
                cmp     ax,243h
                jne     not_pack
                call    read_long
                mov     cs:[unpack_len],ax
                mov     cs:[unpack_len+2],bx
                call    read_long
IF CHECKSUMS
                mov     cs:[pack_len],ax
                mov     cs:[pack_len+2],bx
                call    read_long
                mov     cs:[crc_p],ax
                mov     cs:[crc_u],bx
                mov     si,HEADER_LEN
                mov     cx,cs:[pack_len]
                mov     dx,cs:[pack_len+2]
                call    crc_block
                cmp     cs:[crc_p],bx
                jne     pack_crc
                mov     ax,cs:[pack_len]
                mov     bx,cs:[pack_len+2]
ENDIF
                add     ax,HEADER_LEN
                adc     bx,0
                call    convert_paras
                mov     cs:[pack_paras],ax
                mov     dx,ds
                mov     bx,es
                add     dx,ax
                cmp     dx,bx
                jbe     unpack4
                mov     al,ds:[16]
                xor     ah,ah
                neg     cl
                and     cl,0fh
                add     ax,cx
                add     ax,cs:[unpack_len]
                xor     bx,bx
                adc     bx,cs:[unpack_len+2]
                call    convert_paras
                mov     bx,es
                add     bx,ax
                cmp     bx,dx
                jbe     unpack4
                std
unpack2:
                mov     ax,1000h
                cmp     ax,cs:[pack_paras]
                jbe     unpack3
                mov     ax,cs:[pack_paras]
unpack3:
                sub     cs:[pack_paras],ax
                sub     dx,ax
                sub     bx,ax
                mov     ds,dx
                mov     es,bx
                mov     cl,3
                shl     ax,cl
                mov     cx,ax
                shl     ax,1
                dec     ax
                dec     ax
                mov     si,ax
                mov     di,ax
                rep     movsw
                cmp     cx,cs:[pack_paras]
                jne     unpack2
                mov     es,dx
                mov     ds,bx
                cld
unpack4:
IF CHECKSUMS
                push    es
ENDIF
                mov     si,HEADER_LEN
                xor     di,di
                stc
                reload
                getbit
IF PROTECTED
                mov     dx,key
ENDIF
                jmp     PackBits2

Fetch0:
                reload
                jmp     Back0

PackRaw:
                mov     cl,4
PackRaw2:
                getbit
                jz      Fetch0
Back0:
                adc     bh,bh
                loop    PackRaw2
                mov     cl,3
                add     cl,bh
                add     cl,cl
                getrawREP
                jmp     PackBits2

Fetch1:
                reload
                jmp     Back1
Fetch2:
                reload
                jmp     Back2
Fetch3:
                reload
                jmp     Back3
Fetch4:
                reload
                jmp     Back4
Fetch5:
                reload
                jmp     Back5
Fetch6:
                reload
                jmp     Back6
Fetch7:
                reload
                jmp     Back7

PackLen:
                getbit
                jz      Fetch1
Back1:
                adc     cl,cl
                getbit
                jz      Fetch2
Back2:
                jnc     PackCopy
                getbit
                jz      Fetch3
Back3:
                dec     cx
                adc     cl,cl
                cmp     cl,9
                jz      PackRaw

PackCopy:
                getbit
                jz      Fetch4
Back4:
                jnc     ByteDisp
                getbit
                jz      Fetch5
Back5:
                adc     bh,bh
                getbit
                jz      Fetch6
Back6:
                jc      PackDisp
                or      bh,bh
                jnz     ByteDisp
                inc     bh
PackCopy2:
                getbit
                jz      Fetch7
Back7:
                adc     bh,bh

ByteDisp:
                mov     bl,[si]
                inc     si
                mov     bp,si
                mov     si,di
                dec     si
                sub     si,bx
                cli
                rep     movs byte ptr es:[di],es:[si]
                sti
                mov     si,bp
                jmp     PackBits2

PackBits:
                reload
                jc      PackString
PackBits1:
                getraw
PackBits2:
                getbit
                jc      PackBits3
                getraw
                getbit
                jnc     PackBits1
PackBits3:
                jz      PackBits

PackString:
                mov     cx,2
                sub     bh,bh
                getbit
                jz      Fetch8
Back8:
                jnc     PackLen
                getbit
                jz      Fetch9
Back9:
                jnc     ByteDisp
                inc     cx
                getbit
                jz      Fetch10
Back10:
                jnc     PackCopy
                mov     cl,[si]
                inc     si
                or      cl,cl
                jz      PackEnd
                add     cx,8
                jmp     PackCopy

PackDisp:
                getbit
                jz      Fetch11
Back11:
                adc     bh,bh
                or      bh,4
                getbit
                jz      Fetch12
Back12:
                jc      ByteDisp
                jmp     PackCopy2

Fetch8:
                reload
                jmp     Back8
Fetch9:
                reload
                jmp     Back9
Fetch10:
                reload
                jmp     Back10
Fetch11:
                reload
                jmp     Back11
Fetch12:
                reload
                jmp     Back12

PackEnd:
                push    ax
                mov     bx,di
                and     di,0fh
                add     di,8000h
                mov     cl,4
                shr     bx,cl
                mov     ax,es
                add     ax,bx
                sub     ax,800h
                mov     es,ax
                mov     bx,si
                and     si,0fh
                shr     bx,cl
                mov     ax,ds
                add     ax,bx
                mov     ds,ax
                pop     ax
                getbit
                jnz     PackEnd2
                reload
PackEnd2:
                jc      PackBits2

IF CHECKSUMS
                pop     ds
                xor     si,si
                mov     cx,cs:[unpack_len]
                mov     dx,cs:[unpack_len+2]
                call    crc_block
                cmp     cs:[crc_u],bx
                jne     unpack_crc
ENDIF
                mov     ax,cs:[unpack_len]
                mov     dx,cs:[unpack_len+2]
                jmp     unpack_end
not_pack:
                xor     ax,ax
                jmp     unpack_fail
pack_crc:
                mov     ax,PACKED_CRC
                jmp     unpack_fail
unpack_crc:
                mov     ax,UNPACKED_CRC
unpack_fail:
                cwd
unpack_end:
                ret
Unpack          ENDP

read_long       PROC
                call    read_word
                mov     bx,ax
read_long       ENDP

read_word       PROC
                lodsw
                xchg    ah,al
                ret
read_word       ENDP

convert_paras   PROC
                mov     cl,4
                xor     bh,bh
                ror     bx,cl
                push    ax
                shr     ax,cl
                or      ah,bh
                pop     cx
                and     cx,0fh
                je      convert_paras2
                inc     ax
convert_paras2:
                ret
convert_paras   ENDP

IF CHECKSUMS
crc_block       PROC
                push    ds
                push    es
                push    cs
                pop     es
                mov     di,offset buffer
                push    cx
                xor     bx,bx
crc_block2:
                mov     ax,bx
                mov     cx,8
crc_block3:
                shr     ax,1
                jnc     crc_block4
                xor     ax,0a001h
crc_block4:
                loop    crc_block3
                stosw
                inc     bl
                jne     crc_block2
                pop     cx
                mov     di,offset buffer
                jcxz    crc_block5
                inc     dx
crc_block5:
                lodsb
                xor     bl,al
                mov     al,bh
                xor     bh,bh
                shl     bx,1
                mov     bx,es:[bx+di]
                xor     bl,al
                cmp     si,0
                jnz     crc_block6
                mov     ax,ds
                add     ah,10h
                mov     ds,ax
crc_block6:
                loop    crc_block5
                dec     dx
                jnz     crc_block5
                pop     es
                pop     ds
                ret
crc_block       ENDP
ENDIF
                END

