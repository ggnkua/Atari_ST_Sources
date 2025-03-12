;-------------------------------------------------------------------------------
; PRO-PACK Unpack Source Code - IBM PC, Method 1
;
; Copyright (c) 1991,92 Rob Northen Computing, UK. All Rights Reserved.
;
; File: RNC_1.ASM
;
; Date: 6.4.92
;-------------------------------------------------------------------------------

                .MODEL  compact

;-------------------------------------------------------------------------------
; Conditional Assembly Flags
;-------------------------------------------------------------------------------

CHECKSUMS       EQU     1               ; set this flag to 1 if you require
                                        ; the data to be validated

PROTECTED       EQU     1               ; set this flag to 1 if you are unpacking
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

TABLE_SIZE      EQU     16*8
MIN_LENGTH      EQU     2
HEADER_LEN      EQU     18

;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------

getrawREP       MACRO
IFE PROTECTED
                rep     movsb
ELSE
getrawREP2:
                lodsb
                xor     al,BYTE PTR cs:[key]
                stosb
                loop    getrawREP2
                ror     cs:[key],1
ENDIF
                ENDM

;-------------------------------------------------------------------------------
; Code Segment
;-------------------------------------------------------------------------------

                .CODE

; these variables must be in the same segment as the code

IF PROTECTED
key             dw      ?
ENDIF
IF CHECKSUMS
crc_u           dw      ?
crc_p           dw      ?
crc_table       db      200h-(3*TABLE_SIZE) dup(?)
ENDIF
raw_table       db      TABLE_SIZE dup(?)
pos_table       db      TABLE_SIZE dup(?)
len_table       db      TABLE_SIZE dup(?)
input_hi        dw      2 dup(?)
unpack_len      dw      2 dup(?)
pack_len        dw      2 dup(?)
pack_paras      dw      ?
counts          dw      ?
blocks          db      ?
bit_buffl       dw      ?
bit_buffh       dw      ?
ds_save         dw      ?
es_save         dw      ?
bit_count       db      ?

;------------------------------------------------------------------------------
; PRO-PACK Unpack Routine - IBM PC, Method 1
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
;       add  sp,10
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
                ARG input:DATAPTR, output:DATAPTR, protect_key:WORD
ELSE
                ARG input:DATAPTR, output:DATAPTR
ENDIF

                USES si,di,ds
                cld
IF PROTECTED
                mov     ax,WORD PTR protect_key
                mov     cs:[key],ax
ENDIF
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
                cmp     ax,4e52h
                jne     not_pack
                lodsw
                cmp     ax,143h
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
                mov     si,HEADER_LEN-1
                lodsb
                mov     cs:[blocks],al
                xor     di,di
                mov     cs:[bit_count],0
                mov     ax,[si]
                mov     cs:[bit_buffl],ax
                push    es
                mov     al,2
                call    input_bits
unpack6:
                mov     cs:[ds_save],ds
                mov     cs:[es_save],es
                mov     dx, offset raw_table
                call    make_huftable
                mov     dx,offset pos_table
                call    make_huftable
                mov     dx,offset len_table
                call    make_huftable
                mov     al,16
                call    input_bits
                mov     cs:[counts],ax
                jmp     unpack9
unpack8:
                mov     dx,offset pos_table
                call    input_value
                push    cx
                mov     dx,offset len_table
                call    input_value
                add     cx,MIN_LENGTH
                pop     ax
                inc     ax
                mov     dx,si
                mov     si,di
                sub     si,ax
                mov     ds,cs:[es_save]
                rep     movsb
                mov     ds,cs:[ds_save]
                mov     si,dx
unpack9:
                mov     dx,offset raw_table
                call    input_value
                jcxz    unpack10
                getrawREP
                mov     cl,cs:[bit_count]
                mov     ax,[si]
                mov     bx,ax
                rol     ax,cl
                mov     dx,1
                shl     dx,cl
                dec     dx
                and     cs:[bit_buffl],dx
                and     dx,ax
                mov     ax,[si+2]
                shl     bx,cl
                shl     ax,cl
                or      ax,dx
                or      cs:[bit_buffl],bx
                mov     cs:[bit_buffh],ax
unpack10:
                dec     cs:[counts]
                jne     unpack8
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
                dec     cs:[blocks]
                jne     unpack6
                pop     ds
IF CHECKSUMS
                xor     si,si
                mov     cx,cs:[unpack_len]
                mov     dx,cs:[unpack_len+2]
                call    crc_block
                cmp     cs:[crc_u],bx
                jne     pack_crc
ENDIF
                mov     ax,cs:[unpack_len]
                mov     dx,cs:[unpack_len+2]
                jmp     unpack_end
not_pack:
                mov     ax,NOT_PACKED
                jmp     unpack_end
pack_crc:
                mov     ax,PACKED_CRC
                jmp     unpack_end
unpack_crc:
                mov     ax,UNPACKED_CRC
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

input_value     PROC
                xchg    dx,si
                mov     cx,cs:[bit_buffl]
                mov     ax,cs
                mov     ds,ax
input_value2:
                lodsw
                mov     bx,ax
                and     bx,cx
                lodsw
                cmp     ax,bx
                jne     input_value2
                mov     cx,16*4-4[si]
                mov     ds,cs:[ds_save]
                xchg    dx,si
                mov     al,ch
                call    input_bits
                xor     ch,ch
                cmp     cl,2
                jb      input_value3
                dec     cl
                mov     al,cl
                call    input_bits
                mov     bx,1
                shl     bx,cl
                or      ax,bx
                mov     cx,ax
input_value3:
                ret
input_value     ENDP

input_bits      PROC
                push    cx
                mov     cl,al
                mov     ax,cs:[bit_buffh]
                mov     bx,cs:[bit_buffl]
                mov     ch,cs:[bit_count]
                mov     dx,1
                shl     dx,cl
                dec     dx
                and     dx,bx
                push    dx
                sub     ch,cl
                jae     input_bits3
                add     ch,cl
input_bits2:
                xchg    cl,ch
                mov     dx,1
                shl     dx,cl
                dec     dx
                and     dx,ax
                ror     dx,cl
                shr     ax,cl
                shr     bx,cl
                or      bx,dx
                add     si,2
                mov     ax,[si]
                xchg    cl,ch
                sub     cl,ch
                mov     ch,16
                sub     ch,cl
input_bits3:
                mov     dx,1
                shl     dx,cl
                dec     dx
                and     dx,ax
                ror     dx,cl
                shr     ax,cl
                shr     bx,cl
                or      bx,dx
                mov     cs:[bit_buffh],ax
                mov     cs:[bit_buffl],bx
                mov     cs:[bit_count],ch
                pop     ax
                pop     cx
                ret
input_bits      ENDP

make_huftable   PROC
                push    es
                push    di
                push    dx
                sub     sp,16
                mov     al,5
                call    input_bits
                mov     cx,ax
                jcxz    make_huftable7
                mov     di,sp
                push    cx
make_huftable2:
                mov     al,4
                call    input_bits
                mov     ss:[di],al
                inc     di
                loop    make_huftable2
                pop     cx
                push    si
                mov     si,sp
                add     si,2
                mov     di,ss:16[si]
                mov     al,1
                xor     bx,bx
                mov     dx,8000h
                push    cs
                pop     es
make_huftable3:
                push    cx
                push    si
make_huftable4:
                cmp     al,ss:[si]
                jne     make_huftable6
                push    ax
                push    bx
                push    cx
                mov     cl,al
                mov     ax,1
                shl     ax,cl
                dec     ax
                stosw
                mov     al,cl
                mov     cl,16
                sub     cl,al
                shr     bx,cl
                mov     cl,al
                xor     ax,ax
make_huftable5:
                rcr     bx,1
                rcl     ax,1
                loop    make_huftable5
                stosw
                mov     ax,si
                sub     ax,sp
                sub     ax,12
                mov     ah,ss:[si]
                mov     es:16*4-4[di],ax
                pop     cx
                pop     bx
                pop     ax
                add     bx,dx
make_huftable6:
                inc     si
                loop    make_huftable4
                pop     si
                pop     cx
                shr     dx,1
                inc     al
                cmp     al,17
                jne     make_huftable3
                pop     si
make_huftable7:
                add     sp,16
                pop     dx
                pop     di
                pop     es
                ret
make_huftable   ENDP

IF CHECKSUMS
crc_block       PROC
                push    ds
                push    es
                push    cx
                push    cs
                pop     es
                mov     di,offset crc_table
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
                mov     di,offset crc_table
                pop     cx
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