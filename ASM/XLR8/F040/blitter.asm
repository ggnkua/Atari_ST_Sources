;****************************************************************
;*                                                              *
;* Atari Blitter Emulation v1.0.5                               *
;* (c) 2000  XLR8 Software Design                               *
;*                                                              *
;* 02-07-2000 FvN  Finaly working                               *
;* 07-07-2000 Now Blits after a write to bit 7 of FF8A3C. So    *
;*            no timing-problems with the Blitter anymore.      *
;*                                                              *
;*	ToDo:	Remove a bug that shows on some pop-up boxes, just	*
;*			do not know where it goed wrong.					*
;*																*
;****************************************************************

                ALIGN   4

Blitter_WB:
                and   edi,0ffffffh
                xor   EDI,1
                mov   b [ebp+EDI],al
                xor   EDI,1
                test  b [ebp+0ff8a3dh],80h            ; BitBlit!
                je    short @@skipBlit
                call  Blitter
@@skipBlit:     ret

                ALIGN   4
Blitter_WW:
                and   edi,0ffffffh
                mov   w [ebp+EDI],ax
                test  b [ebp+0ff8a3dh],80h            ; BitBlit!
                je    short @@skipBlit
                call  Blitter
@@skipBlit:     ret
                ALIGN   4
Blitter_WL:
                and   edi,0ffffffh
                rol   eax,16
                mov   d [ebp+EDI],eax
                test  b [ebp+0ff8a3dh],80h            ; BitBlit!
                je    short @@skipBlit
                call  Blitter
@@skipBlit:     ret

                ALIGN   4
Blitter:        pushad
                and     d [ebp+0ff8a2eh],0fffefffeh
                and     d [ebp+0ff8a20h],0fffefffeh
                and     b [ebp+0ff8a3dh],7fh            ; End of bitBlit
                mov     esi,d [ebp+0ff8a24h]               ; Source Adress
                rol     esi,16
                and     esi,0fffffeh
                mov     edi,d [ebp+0ff8a32h]               ; Dest Adress
                lea     esi,[ebp+esi]
                rol     edi,16
                and     edi,0fffffeh
                movsx   eax,w [ebp+0ff8a20h]              ; Source X
                lea     edi,[ebp+edi]
                movsx   ebx,w [ebp+0ff8a22h]              ; Source Y
                mov     d SourceX,eax
                mov     d SourceY,ebx
                movsx   eax,w [ebp+0ff8a2eh]              ; Dest X
                movsx   ebx,w [ebp+0ff8a30h]              ; Dest Y
                mov     d DestX,eax
                mov     d DestY,ebx
                xor     eax,eax
                xor     ecx,ecx
                mov     ax,w [ebp+0ff8a36h]             ;Count X
                mov     cx,w [ebp+0ff8a38h]             ;Count Y
                mov     d CountX,eax
                mov     d CountX1,eax
                mov     d CountY,ecx

                mov     ax,[ebp+0ff8a2ah]       ; m2
                mov     w Mask2,ax
                mov     ax,[ebp+0ff8a28h]       ; m1
                mov     bx,[ebp+0ff8a2ch]       ; m3
                mov     w Mask1,ax
                mov     w Mask3,bx

                mov     al,b [ebp+0ff8a3dh]             ; Line
                and     eax,15
                mov     d HTline,eax
                mov     al,b [ebp+0ff8a3ch]             ; Skew
                and     eax,15
                mov     d Skew,eax

                mov     al,b [ebp+0ff8a3bh]             ; HOP
                and     eax,3
                mov     d HOP,eax
                shl     eax,6                           ; *64
                mov     bl,b [ebp+0ff8a3ah]             ; Logic Opcode
                and     ebx,15
                mov     edx,d [BlitTab+eax+ebx*4]       ; Get RenderSubroutine
                mov     d BlitSub,edx

;*********************************
;* The Blitter
;*********************************

                cmp     d CountX,1                      ; Single word
                jz      BlitSingle

                mov     al,b [ebp+0ff8a3ch]
                shr     al,6
                jz      BlitNormal
                dec     al
                jz      BlitNFSR
                dec     al
                jz      BlitFXSR

;------------------------------------------ NFSR & FXSR
;                JMP     BlitEnd

                mov     ecx,d Skew
AABlitSkewLoop:
                mov     edx,d CountX1
                mov     d CountX,edx
                mov     dx,w Mask1

                xor     eax,eax
                mov     ax,[esi]
                rol     eax,16

                test    cl,-1
                jz      short AAnoShift
;                rol     eax,16
                ror     eax,cl
AAnoShift:
                test    d SourceX,-1
                jns     short AAnegative
                rol     eax,16
AAnegative:
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16

                dec     d CountX
                cmp     d CountX,1
                je      AABlit_last
AABlit_loopx:
                mov     dx,w Mask2
                add     esi,d SourceX
                add     edi,d DestX

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                rol     eax,16
                ror     eax,cl
                rol     eax,16

                mov     dx,-1
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16
                dec     d CountX
                cmp     d CountX,1
                jne     AABlit_loopx

AABlit_last:    add     esi,d SourceX
                add     edi,d DestX
                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                shl     eax,16
                shr     eax,cl
                rol     eax,16

                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

AABlit_2:       add     esi,d SourceY
                add     edi,d DestY

                inc     d HTline
                and     d HTline,15

                dec     d CountY
                test    d CountY,-1
                jnz     AABlitSkewLoop
                jmp     BlitEnd

;------------------------------------------ NFSR 40
BlitNFSR:       ;jmp     BlitEnd
                mov     ecx,d Skew
BBBlitSkewLoop:
                mov     edx,d CountX1
                mov     d CountX,edx
                mov     dx,w Mask1

                xor     eax,eax
                mov     ax,[esi]

                test    cl,-1
                jz      short BBnoShift
                rol     eax,16
                ror     eax,cl
BBnoShift:
                test    d SourceX,-1
                jns     short BBnegative
                rol     eax,16
BBnegative:
                test    b [ebp+0ff8a3ch],80h

                jz      short BBBlit_nofsx

;               rol     eax,16
                push    ax
                add     esi,d SourceX
                xor     eax,eax
                mov     ax,[esi]
                ror     eax,cl
                pop     bx
                or      ax,bx
                ror     eax,16
BBBlit_nofsx:
                test    b [ebp+0ff8a3ch],40h
                jz      short BBBlit_fsx
                ror     eax,16

BBBlit_fsx:
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16

                dec     d CountX
                cmp     d CountX,1
                je      BBBlit_last
BBBlit_loopx:
                mov     dx,w Mask2
                add     esi,d SourceX
                add     edi,d DestX

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                rol     eax,16
                ror     eax,cl
                test    b [ebp+0ff8a3ch],40h
                jnz     short BBBlit_fsx2
                rol     eax,16
BBBlit_fsx2:
                mov     dx,-1

                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16
                dec     d CountX
                cmp     d CountX,1
                jne     BBBlit_loopx

BBBlit_last:    add     esi,d SourceX
                add     edi,d DestX
                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

                test    b [ebp+0ff8a3ch],40h
                jnz     short BBBlit_3

                mov     ax,[esi]
                shl     eax,16
                shr     eax,cl
                rol     eax,16

                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

BBBlit_2:       add     esi,d SourceY
                add     edi,d DestY

                inc     d HTline
                and     d HTline,15

                dec     d CountY
                test    d CountY,-1
                jnz     BBBlitSkewLoop
                jmp     BlitEnd
BBBlit_3:       sub     esi,d SourceX
                jmp     short BBBlit_2

                jmp     BlitEnd

;------------------------------------------ FXSR 80
BlitFXSR:       ;jmp     BlitEnd
                mov     ecx,d Skew
CCBlitSkewLoop:
                mov     edx,d CountX1
                mov     d CountX,edx
                mov     dx,w Mask1

                xor     eax,eax
                mov     ax,[esi]
                rol     eax,16

                test    cl,-1
                jz      short CCnoShift
                rol     eax,16
                ror     eax,cl
CCnoShift:
                test    d SourceX,-1
                jns     short CCnegative
                rol     eax,16
CCnegative:
;                test    b [ebp+0ff8a3ch],80h
;                jz      short CCBlit_nofsx

                rol     eax,16
                push    ax
                add     esi,d SourceX
                xor     eax,eax
                mov     ax,[esi]
                ror     eax,cl
                pop     bx
                or      ax,bx
                ror     eax,16
;CCBlit_nofsx:
;                test    b [ebp+0ff8a3ch],40h
;                jz      short CCBlit_fsx
;                ror     eax,16
;
;CCBlit_fsx:
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16

                dec     d CountX
                cmp     d CountX,1
                je      CCBlit_last
CCBlit_loopx:
                mov     dx,w Mask2
                add     esi,d SourceX
                add     edi,d DestX

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                rol     eax,16
                ror     eax,cl
;                test    b [ebp+0ff8a3ch],40h
;                jnz     short CCBlit_fsx2
                rol     eax,16
;CCBlit_fsx2:
                mov     dx,-1

                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16
                dec     d CountX
                cmp     d CountX,1
                jne     CCBlit_loopx

CCBlit_last:    add     esi,d SourceX
                add     edi,d DestX
                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

;                test    b [ebp+0ff8a3ch],40h
;                jnz     short CCBlit_3

                mov     ax,[esi]
                shl     eax,16
                shr     eax,cl
                rol     eax,16

                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

CCBlit_2:       add     esi,d SourceY
                add     edi,d DestY

                inc     d HTline
                and     d HTline,15

                dec     d CountY
                test    d CountY,-1
                jnz     CCBlitSkewLoop
                jmp     BlitEnd
CCBlit_3:       sub     esi,d SourceX
                jmp     short CCBlit_2

                jmp     BlitEnd

;------------------------------------------ Normal
BlitNormal:
                mov     ecx,d Skew
DDBlitSkewLoop:
                mov     edx,d CountX1
                mov     d CountX,edx
                mov     dx,w Mask1

                xor     eax,eax
                mov     ax,[esi]

                test    cl,-1
                jz      short DDnoShift
                rol     eax,16
                ror     eax,cl
DDnoShift:
                test    d SourceX,-1
                jns     short DDnegative
                rol     eax,16
DDnegative:
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16

                dec     d CountX
                cmp     d CountX,1
                je      DDBlit_last
DDBlit_loopx:
                mov     dx,w Mask2
                add     esi,d SourceX
                add     edi,d DestX

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                rol     eax,16
                ror     eax,cl
                rol     eax,16

                mov     dx,-1
                push    eax
                call    d BlitSub
                pop     eax

                shr     eax,16
                dec     d CountX
                cmp     d CountX,1
                jne     DDBlit_loopx

DDBlit_last:    add     esi,d SourceX
                add     edi,d DestX
                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

                mov     ax,[esi]
                shl     eax,16
                shr     eax,cl
                rol     eax,16

                mov     dx,w Mask3

                push    eax
                call    d BlitSub
                pop     eax

DDBlit_2:       add     esi,d SourceY
                add     edi,d DestY

                inc     d HTline
                and     d HTline,15

                dec     d CountY
                test    d CountY,-1
                jnz     DDBlitSkewLoop
                jmp     BlitEnd

;************************************************************** Single

BlitSingle:     ;jmp     BlitEnd

                mov     ecx,d Skew
Blit1LoopP:     xor     eax,eax
                mov     ax,[esi]
                ror     eax,cl

                test    d SourceX,-1
                jns     short @@negative
                rol     eax,16
@@negative:

                mov     dx,w Mask1             ; mask1

                test    b [ebp+0ff8a3ch],80h
                jz      short Blit_nofsx1
              
                rol     eax,16
                mov     bx,ax
                add     esi,d SourceX
                xor     eax,eax
                mov     ax,[esi]
                ror     eax,cl
                or      ax,bx
Blit_nofsx1:
                test    b [ebp+0ff8a3ch],40h
                jz      short Blit_fsx1
                ror     eax,16
Blit_fsx1:
                push    ebx
                call    d BlitSub
                pop     ebx

BlitS_NFSR:     add     esi,d SourceY
                add     edi,d DestY
                dec     d CountY
                inc     d HTline
                and     d HTline,15
                test    d CountY,-1
                jnz     Blit1LoopP


BlitEnd:        popad
                ret


BlitTab:        ; Blit All One

                dd      Blit0,Blit0,Blit0,Blit0,Blit0,Blit0,Blit0,Blit0
                dd      Blit0,Blit0,Blit0,Blit0,Blit0,Blit0,Blit0,Blit0

                ; BlitHalftone

                dd      Blit1_0,Blit1_1,Blit1_2,Blit1_3,Blit1_4,Blit1_5,Blit1_6,Blit1_7
                dd      Blit1_8,Blit1_9,Blit1_a,Blit1_b,Blit1_c,Blit1_d,Blit1_e,Blit1_f

                ; BlitSource

                dd      Blit2_0,Blit2_1,Blit2_2,Blit2_3,Blit2_4,Blit2_5,Blit2_6,Blit2_7
                dd      Blit2_8,Blit2_9,Blit2_a,Blit2_b,Blit2_c,Blit2_d,Blit2_e,Blit2_f

                ; BlitSourceHT

                dd      Blit3_0,Blit3_1,Blit3_2,Blit3_3,Blit3_4,Blit3_5,Blit3_6,Blit3_7
                dd      Blit3_8,Blit3_9,Blit3_a,Blit3_b,Blit3_c,Blit3_d,Blit3_e,Blit3_f


;****************************************
;* BitBlit Routines
;*
;* ESI = source adres
;* EDI = dest adres
;*  AX = Source data
;****************************************


Blit0:          mov     ax,-1           ; All 1
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

;****************************************************** HalfTone

Blit1_0:        not     dx
                and     [edi],dx
                ret

Blit1_1:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                and     ax,bx           ; S AND
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_2:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx              
                and     ax,bx           ; S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret


Blit1_3:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                and     ax,dx
                not     dx
                and     [edi],dx
                or      [edi],ax
                ret

Blit1_4:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax
                and     ax,bx           ; NOT S AND D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_5:        ret                     ; Dest

Blit1_6:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                xor     ax,bx           ; S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_7:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                or      ax,bx           ; S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_8:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx
                not     ax
                and     ax,bx           ; NOT S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_9:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax
                xor     ax,bx           ; NOT S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_a:        ;mov     ebx,d HTline
                ;mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     ax,[edi]        ; NOT D
                not     ax
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_b:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx              
                or      ax,bx           ; S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_c:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                not     ax              ; NOT S
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_d:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax              
                or      ax,bx           ; NOT S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_e:        mov     ebx,d HTline
                mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx
                not     ax
                or      ax,bx           ; NOT S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit1_f:        mov     ax,-1           ; All 1
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret
        
;****************************************************** Source
Blit2_0:        not     dx
                and     [edi],dx
                ret

Blit2_1:        mov     bx,[edi]
                and     ax,bx           ; S AND D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_2:        mov     bx,[edi]
                not     bx              
                and     ax,bx           ; S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret


Blit2_3:        and     ax,dx
                not     dx
                and     [edi],dx
                or      [edi],ax
                ret

Blit2_4:        mov     bx,[edi]
                not     ax
                and     ax,bx           ; NOT S AND D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_5:        ret                     ; Dest

Blit2_6:        mov     bx,[edi]
                xor     ax,bx           ; S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_7:        mov     bx,[edi]
                or      ax,bx           ; S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_8:        mov     bx,[edi]
                not     bx
                not     ax
                and     ax,bx           ; NOT S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_9:        mov     bx,[edi]
                not     ax
                xor     ax,bx           ; NOT S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_a:        mov     ax,[edi]
                not     ax              ; NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_b:        mov     bx,[edi]
                not     bx              
                or      ax,bx           ; S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_c:        not     ax              ; NOT S
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_d:        mov     bx,[edi]
                not     ax              
                or      ax,bx           ; NOT S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_e:        mov     bx,[edi]
                not     bx
                not     ax
                or      ax,bx           ; NOT S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit2_f:        mov     ax,-1           ; All 1
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

;****************************************************** HalfTone & Source

Blit3_0:        not     dx
                and     [edi],dx
                ret

Blit3_1:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                and     ax,bx           ; S AND
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_2:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx              
                and     ax,bx           ; S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret


Blit3_3:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                and     ax,dx
                not     dx
                and     [edi],dx
                or      [edi],ax
                ret

Blit3_4:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax
                and     ax,bx           ; NOT S AND D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_5:        ret                     ; Dest

Blit3_6:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                xor     ax,bx           ; S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_7:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                or      ax,bx           ; S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_8:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx
                not     ax
                and     ax,bx           ; NOT S AND NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_9:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax
                xor     ax,bx           ; NOT S XOR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_a:        ;mov     ebx,d HTline
                ;mov     ax,[ebp+0ff8a00h+ebx*2]
                mov     ax,[edi]        ; NOT D
                not     ax
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_b:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx              
                or      ax,bx           ; S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_c:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                not     ax              ; NOT S
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_d:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     ax              
                or      ax,bx           ; NOT S OR D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_e:        mov     ebx,d HTline
                and     ax,[ebp+0ff8a00h+ebx*2]
                mov     bx,[edi]
                not     bx
                not     ax
                or      ax,bx           ; NOT S OR NOT D
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

Blit3_f:        mov     ax,-1           ; All 1
                and     ax,dx           ; mask off
                not     dx
                and     [edi],dx        ; free masked bits
                or      [edi],ax        ; store
                ret

                .data
BlitSub:        dd      0
SourceX:        dd      0
SourceY:        dd      0
DestX:          dd      0
DestY:          dd      0
CountX:         dd      0
CountX1:        dd      0
CountY:         dd      0
Skew:           dd      0
HTline:         dd      0
HOP:            dd      0
Mask1:          dw      0
Mask2:          dw      0
Mask3:          dw      0
