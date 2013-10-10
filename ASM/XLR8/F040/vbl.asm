;*********************************
;* Screen Handling

VBL:

                test    w [ebp+0ff8266h],71h
                jz      @@STEcolor

                lea     esi,[ebp+0ff9800h]      ; F030 palette
                mov     al,[ebp+0ff8266h]
                and     eax,15
                shl     eax,4
                add     esi,eax
                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx
                mov     ecx,d CurrentColors
@@setpal030:    mov     al,b 1[esi]
                shr     al,2
                out     dx,al
                mov     al,b [esi]               ; wrapped!
                shr     al,2
                out     dx,al
                mov     al,b 2[esi]
                shr     al,2
                out     dx,al
                add     esi,4
                dec     ecx
                jnz     short @@setpal030
                jmp     short @@ScreenOut

@@STEcolor:     lea     esi,[ebp+0ff8240h]      ; STE palette
                mov     dx,3c8h
                xor     eax,eax
                out     dx,al
                inc     dx
                mov     ecx,16
@@setpalSTE:    mov     al,1[esi]
                mov     al,b [@@STEcolorTable+eax]
                out     dx,al
                mov     al,[esi]               ; wrapped!
                shr     al,4
                mov     al,b [@@STEcolorTable+eax]
                out     dx,al
                mov     al,[esi]
                and     al,15
                mov     al,b [@@STEcolorTable+eax]
                out     dx,al
                add     esi,2
                dec     ecx
                jnz     short @@setpalSTE
                jmp     short @@ScreenOut
@@STEcolorTable:db      80h,00h,90h,10h,0a0h,020h,0b0h,030h,0c0h,040h,0d0h,050h,0e0h,060h,0f0h,070h
@@ScreenOut:
                xor     eax,eax
                mov     ah,[ebp+0ff8200h]       ; Screen Hi
                mov     al,[ebp+0ff8202h]       ; Screen Mid
                shl     eax,8
                mov     al,[ebp+0ff820dh]       ; Screen Lo
                lea     esi,[ebp+eax]

                lea     edx,ShiftTable
                mov     edi,0a0000h

                mov     ecx,32000/8
Copy16:
                xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                movq    mm0,[edx+eax*8]
                movq    mm1,[edx+ebx*8]
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                por     mm0,2048[edx+eax*8]
                por     mm1,2048[edx+ebx*8]
                mov     al,5[esi]       ; twisted
                mov     bl,4[esi]       ; twisted
                por     mm0,4096[edx+eax*8]
                por     mm1,4096[edx+ebx*8]
                mov     al,7[esi]       ; twisted
                mov     bl,6[esi]       ; twisted
                por     mm0,6144[edx+eax*8]
                por     mm1,6144[edx+ebx*8]
                movq    [edi],mm0
                movq    8[edi],mm1
                
                add     esi,8
                add     edi,16
                dec     ecx
                jnz     Copy16


ExitVBL:
                or      b [R_IRQ],2                     ; VBL Irq
                ret
SetFalconMode:  mov     eax,d CurrentMode
                int     10h
                call    VBL
                mov     ax,7
                mov     cx,0
                mov     dx,319
                int     33h
                mov     ax,8
                mov     cx,0
                mov     dx,199
                int     33h
                mov     ax,4
                mov     cx,160
                mov     dx,100
                int     33h
                ret

ShowF030Screen: mov     eax,d CurrentMode
                int     10h
                call    VBL
                and     b [R_IRQ],0fdh
                ret

                .data
ShiftTable:     include shifttab.inc            ; MMX-shifter table
CurrentMode:    dd      -1                      ; Current Graphic mode change
CurrentColors:  dd      16                      ; Number of colors in palette
