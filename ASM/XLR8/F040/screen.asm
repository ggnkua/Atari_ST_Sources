;*************************
;* Falcon screen emulation
;*
;*	This is the video-emulator. It emulates all current screensizes and depts.
;*	It heavily relies on the use of MMX !!!!!

DrawVBL:        call    SetPaletteF


                xor     eax,eax                 ; Find out the colorMode
                xor     ebx,ebx
                mov     ax,w [ebp+0ff8266h]     ; Falcon Shift
                cmp     ax,10h
                jnz     short @@col1
                mov     bl,3*4                  ;256 colors
                jmp     short @@colorDone
@@col1:         cmp     ax,400h                 ;2 colors
                jz      short @@colorDone
                cmp     ax,100h
                jnz     short @@col2
                mov     bl,4*4                  ;TrueColor
                jmp     short @@colorDone
@@col2:         mov     ax,w [ebp+0ff8260h]     ; ST Shift
                cmp     ax,0
                jnz     short @@col3
                mov     bl,2*4                  ;16 colors
                jmp     short @@colorDone
@@col3:         cmp     ax,100h
                jnz     short @@colorDone
                mov     bl,1*4                  ;4 colors

@@colorDone:
                mov     cx,w [ebp+0ff82c2h]     ; Falcon VideoMode
                mov     ax,w [ebp+0ff82c2h]     ; Falcon VideoMode
                and     cx,12                   ; mask off pixelDivider
                test    b [ebp+0ff8007h],40h    ; VGA or TV ?
                jz      short @@VGA
                add     ecx,4
@@VGA:          shl     cx,3

                add     ebx,ecx                 ; screenWide routine offset
                mov     edx,d [DrawTable+ebx]
                mov     d [DrawRoutine],edx     ; Draw Subroutine (64Bytes)
                xor     ecx,ecx
                xor     edx,edx
                mov     cx,w [VesaTable+ebx+2]  ; Screen Wide
                mov     dx,w [VesaTable+ebx]    ; Needed vesa mode
                mov     d [CurrentWide],ecx

                mov     d [SourceAdd],0         ; low

                mov     ebx,240                 ; Falcon mode
                cmp     w [ebp+0ff82aah],3ffh
                jz      short @@ST_Mode
                mov     ebx,200                 ; ST low
;                cmp     dx,111h
;                jz      short @@ST_Mode
                mov     dx,100h
@@ST_Mode:      test    b [ebp+0ff8007h],40h    ; VGA or TV ?
                jz      short @@VGA2
                shr     al,1
                not     al
@@VGA2:         test    al,1
                jnz     short @@Low
                add     ebx,ebx                 ; Double height
                mov     d [SourceAdd],ecx       ; interlace to double height
@@Low:          mov     d [CurrentHeight],ebx
                cmp     edx,d [CurrentMode]     ; test if VesaMode is changed
                jz      short @@noNewMode
                mov     d [CurrentMode],edx
                call    SetVesaMode

@@noNewMode:    mov     eax,d [CurrentWide]
                cmp     eax,d [OldWide]
                jnz     short @@newMouse
                mov     eax,d [CurrentHeight]
                cmp     eax,d [OldHeight]
                jz      short @@noChange
@@newMouse:     mov     eax,d [CurrentWide]
                mov     ebx,d [CurrentHeight]
                mov     d [OldWide],eax
                mov     d [OldHeight],ebx
                call    SetMouse
                mov     d [SourceOffset],0
                mov     d [DestOffset],0
@@noChange:
                xor     eax,eax
                mov     ah,[ebp+0ff8200h]       ; Screen Hi
                mov     al,[ebp+0ff8202h]       ; Screen Mid
                shl     eax,8
                mov     al,[ebp+0ff820dh]       ; Screen Lo
                and     eax,0fffffeh
                lea     esi,[ebp+eax]

                mov     ebx,d [DrawRoutine]
                jmp     ebx



                align 4
DrawTable:      dd      nute,nute,nute,nute,nute,160,160,160
                dd      c320_2,c320_4,c320_16,c320_256,c320_64k,320,320,320
                dd      c640_2,c640_4,c640_16,c640_256,c640_64k,640,640,640
                dd      nute,nute,nute,nute,nute,160,160,160
VesaTable:      dd      0,0,0,0, 0,0,0,0
                dw      101h,320,101h,320,101h,320,101h,320,111h,320,0,0,0,0,0,0
                dw      101h,640,101h,640,101h,640,101h,640,111h,640,0,0,0,0,0,0
                dw      101h,0,101h,0,101h,0,101h,0,111h,0,0,0,0,0,0,0

c320_2:         mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable2

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,3
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c320_2_1
                shr     ecx,1
c320_2_1:       push    ecx
                mov     ecx,10                  ; 320 bytes
c320_2_2:       xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                movq    mm2,8[edi+eax*8]
                movq    mm3,8[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm4,4096[edi+eax*8]
                movq    mm5,4096[edi+ebx*8]
                movq    mm6,4104[edi+eax*8]
                movq    mm7,4104[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm2
                movq    16[edx],mm1
                movq    24[edx],mm3
                movq    32[edx],mm4
                movq    40[edx],mm6
                movq    48[edx],mm5
                movq    56[edx],mm7
                add     esi,4
                add     dx,64
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c320_2_2
                mov     eax,d [SourceAdd]
                shr     eax,3
                add     esi,eax
                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c320_2_1
                ret

c320_4:         mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable2

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,2
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c320_4_1
                shr     ecx,1
c320_4_1:       push    ecx
                mov     ecx,10                  ; 320 bytes
c320_4_2:       xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                movq    mm2,8[edi+eax*8]
                movq    mm3,8[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,4096[edi+eax*8]
                por     mm1,4096[edi+ebx*8]
                por     mm2,4104[edi+eax*8]
                por     mm3,4104[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,5[esi]       ; twisted
                mov     bl,4[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm4,[edi+eax*8]
                movq    mm5,[edi+ebx*8]
                movq    mm6,8[edi+eax*8]
                movq    mm7,8[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,7[esi]       ; twisted
                mov     bl,6[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm4,4096[edi+eax*8]
                por     mm5,4096[edi+ebx*8]
                por     mm6,4104[edi+eax*8]
                por     mm7,4104[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm2
                movq    16[edx],mm1
                movq    24[edx],mm3
                movq    32[edx],mm4
                movq    40[edx],mm6
                movq    48[edx],mm5
                movq    56[edx],mm7
                add     esi,8
                add     dx,64
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c320_4_2

                mov     eax,d [SourceAdd]
                shr     eax,2
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c320_4_1

                ret

c320_16:        mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable2

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,1
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c320_16_1
                shr     ecx,1
c320_16_1:      push    ecx
                mov     ecx,20                  ; 320 bytes
c320_16_2:      xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                movq    mm2,8[edi+eax*8]
                movq    mm3,8[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,4096[edi+eax*8]
                por     mm1,4096[edi+ebx*8]
                por     mm2,4104[edi+eax*8]
                por     mm3,4104[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,5[esi]       ; twisted
                mov     bl,4[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,8192[edi+eax*8]
                por     mm1,8192[edi+ebx*8]
                por     mm2,8200[edi+eax*8]
                por     mm3,8200[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,7[esi]       ; twisted
                mov     bl,6[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,12288[edi+eax*8]
                por     mm1,12288[edi+ebx*8]
                por     mm2,12296[edi+eax*8]
                por     mm3,12296[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm2
                movq    16[edx],mm1
                movq    24[edx],mm3
                add     esi,8
                add     dx,32
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c320_16_2

                mov     eax,d [SourceAdd]
                shr     eax,1
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c320_16_1
                ret

c320_256:       mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable2

                add     esi,d [SourceOffset]    ; interlace
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c320_256_1
                shr     ecx,1
c320_256_1:     push    ecx
                mov     ecx,20                  ; 320 bytes
c320_256_2:     xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                movq    mm2,8[edi+eax*8]
                movq    mm3,8[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,4096[edi+eax*8]
                por     mm1,4096[edi+ebx*8]
                por     mm2,4104[edi+eax*8]
                por     mm3,4104[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,5[esi]       ; twisted
                mov     bl,4[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,8192[edi+eax*8]
                por     mm1,8192[edi+ebx*8]
                por     mm2,8200[edi+eax*8]
                por     mm3,8200[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,7[esi]       ; twisted
                mov     bl,6[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,12288[edi+eax*8]
                por     mm1,12288[edi+ebx*8]
                por     mm2,12296[edi+eax*8]
                por     mm3,12296[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,9[esi]       ; twisted
                mov     bl,8[esi]        ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,16384[edi+eax*8]
                por     mm1,16384[edi+ebx*8]
                por     mm2,16392[edi+eax*8]
                por     mm3,16392[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,11[esi]       ; twisted
                mov     bl,10[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,20480[edi+eax*8]
                por     mm1,20480[edi+ebx*8]
                por     mm2,20488[edi+eax*8]
                por     mm3,20488[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,13[esi]       ; twisted
                mov     bl,12[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,24576[edi+eax*8]
                por     mm1,24576[edi+ebx*8]
                por     mm2,24584[edi+eax*8]
                por     mm3,24584[edi+ebx*8]
                xor     eax,eax
                xor     ebx,ebx
                mov     al,15[esi]       ; twisted
                mov     bl,14[esi]       ; twisted
                add     eax,eax
                add     ebx,ebx
                por     mm0,28672[edi+eax*8]
                por     mm1,28672[edi+ebx*8]
                por     mm2,28680[edi+eax*8]
                por     mm3,28680[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm2
                movq    16[edx],mm1
                movq    24[edx],mm3
                add     esi,16
                add     dx,32
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c320_256_2

                add     esi,d [SourceAdd]

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c320_256_1
                ret

c320_64k:
                xor     eax,eax
                mov     ah,[ebp+0ff8200h]       ; Screen Hi
                mov     al,[ebp+0ff8202h]       ; Screen Mid
                shl     eax,8
                mov     al,[ebp+0ff820dh]       ; Screen Lo
                and     eax,0fffffeh
                lea     esi,[ebp+eax]

                mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                mov     eax,d [SourceOffset]    ; interlace
                add     eax,eax
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,1280
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c320_64k_1
                shr     ecx,1
c320_64k_1:     push    ecx
                mov     ecx,40
c320_64k_2:

                mov     ax,[esi]
                mov     bx,2[esi]
                mov     [edx],ax
                mov     2[edx],ax
                mov     4[edx],bx
                mov     6[edx],bx
                mov     ax,4[esi]
                mov     bx,6[esi]
                mov     8[edx],ax
                mov     10[edx],ax
                mov     12[edx],bx
                mov     14[edx],bx
                mov     ax,8[esi]
                mov     bx,10[esi]
                mov     16[edx],ax
                mov     18[edx],ax
                mov     20[edx],bx
                mov     22[edx],bx
                mov     ax,12[esi]
                mov     bx,14[esi]
                mov     24[edx],ax
                mov     26[edx],ax
                mov     28[edx],bx
                mov     30[edx],bx
                add     esi,16
                add     dx,32
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c320_64k_2
                mov     eax,d [SourceAdd]
                add     eax,eax
                add     esi,eax
                add     dx,1280
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c320_64k_1
                ret

;------------------------------------------------------------------ 640

c640_2:         mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,3
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c640_2_1
                shr     ecx,1
c640_2_1:       push    ecx
                mov     ecx,10
c640_2_2:       xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]
                mov     bl,[esi]
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                mov     al,3[esi]
                mov     bl,2[esi]
                movq    mm2,[edi+eax*8]
                movq    mm3,[edi+ebx*8]
                mov     al,5[esi]
                mov     bl,4[esi]
                movq    mm4,[edi+eax*8]
                movq    mm5,[edi+ebx*8]
                mov     al,7[esi]
                mov     bl,6[esi]
                movq    mm6,[edi+eax*8]
                movq    mm7,[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm1
                movq    16[edx],mm2
                movq    24[edx],mm3
                movq    32[edx],mm4
                movq    40[edx],mm5
                movq    48[edx],mm6
                movq    56[edx],mm7
                add     esi,8
                add     dx,64
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c640_2_2  

                mov     eax,d [SourceAdd]
                shr     eax,3
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c640_2_1  
                ret

c640_4:         mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,2
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c640_4_1
                shr     ecx,1
c640_4_1:       push    ecx
                mov     ecx,10                  ; 320 bytes
c640_4_2:       xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]
                mov     bl,[esi]
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                mov     al,3[esi]
                mov     bl,2[esi]
                por     mm0,2048[edi+eax*8]
                por     mm1,2048[edi+ebx*8]
                mov     al,5[esi]
                mov     bl,4[esi]
                movq    mm2,[edi+eax*8]
                movq    mm3,[edi+ebx*8]
                mov     al,7[esi]
                mov     bl,6[esi]
                por     mm2,2048[edi+eax*8]
                por     mm3,2048[edi+ebx*8]
                mov     al,9[esi]
                mov     bl,8[esi]
                movq    mm4,[edi+eax*8]
                movq    mm5,[edi+ebx*8]
                mov     al,11[esi]
                mov     bl,10[esi]
                por     mm4,2048[edi+eax*8]
                por     mm5,2048[edi+ebx*8]
                mov     al,13[esi]
                mov     bl,12[esi]
                movq    mm6,[edi+eax*8]
                movq    mm7,[edi+ebx*8]
                mov     al,15[esi]
                mov     bl,14[esi]
                por     mm6,2048[edi+eax*8]
                por     mm7,2048[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm1
                movq    16[edx],mm2
                movq    24[edx],mm3
                movq    32[edx],mm4
                movq    40[edx],mm5
                movq    48[edx],mm6
                movq    56[edx],mm7
                add     esi,16
                add     dx,64
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c640_4_2

                mov     eax,d [SourceAdd]
                shr     eax,2
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c640_4_1  
                ret

c640_16:        mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,1
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c640_16_1
                shr     ecx,1
c640_16_1:      push    ecx
                mov     ecx,20                  ; 320 bytes
c640_16_2:      xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]       ; twisted
                mov     bl,[esi]        ; twisted
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                mov     al,3[esi]       ; twisted
                mov     bl,2[esi]       ; twisted
                por     mm0,2048[edi+eax*8]
                por     mm1,2048[edi+ebx*8]
                mov     al,5[esi]       ; twisted
                mov     bl,4[esi]       ; twisted
                por     mm0,4096[edi+eax*8]
                por     mm1,4096[edi+ebx*8]
                mov     al,7[esi]       ; twisted
                mov     bl,6[esi]       ; twisted
                por     mm0,6144[edi+eax*8]
                por     mm1,6144[edi+ebx*8]
                mov     al,9[esi]       ; twisted
                mov     bl,8[esi]       ; twisted
                movq    mm2,[edi+eax*8]
                movq    mm3,[edi+ebx*8]
                mov     al,11[esi]       ; twisted
                mov     bl,10[esi]       ; twisted
                por     mm2,2048[edi+eax*8]
                por     mm3,2048[edi+ebx*8]
                mov     al,13[esi]       ; twisted
                mov     bl,12[esi]       ; twisted
                por     mm2,4096[edi+eax*8]
                por     mm3,4096[edi+ebx*8]
                mov     al,15[esi]       ; twisted
                mov     bl,14[esi]       ; twisted
                por     mm2,6144[edi+eax*8]
                por     mm3,6144[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm1
                movq    16[edx],mm2
                movq    24[edx],mm3
                add     esi,16
                add     dx,32
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c640_16_2

                mov     eax,d [SourceAdd]
                shr     eax,1
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c640_16_1
                ret

c640_256:       mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable

                add     esi,d [SourceOffset]    ; interlace
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c640_256_1
                shr     ecx,1
c640_256_1:     push    ecx
                mov     ecx,20                  ; 320 bytes
c640_256_2:     xor     eax,eax
                xor     ebx,ebx
                mov     al,1[esi]
                mov     bl,[esi]
                movq    mm0,[edi+eax*8]
                movq    mm1,[edi+ebx*8]
                mov     al,3[esi]
                mov     bl,2[esi]
                por     mm0,2048[edi+eax*8]
                por     mm1,2048[edi+ebx*8]
                mov     al,5[esi]
                mov     bl,4[esi]
                por     mm0,4096[edi+eax*8]
                por     mm1,4096[edi+ebx*8]
                mov     al,7[esi]
                mov     bl,6[esi]
                por     mm0,6144[edi+eax*8]
                por     mm1,6144[edi+ebx*8]
                mov     al,9[esi]
                mov     bl,8[esi]
                por     mm0,8192[edi+eax*8]
                por     mm1,8192[edi+ebx*8]
                mov     al,11[esi]
                mov     bl,10[esi]
                por     mm0,10240[edi+eax*8]
                por     mm1,10240[edi+ebx*8]
                mov     al,13[esi]
                mov     bl,12[esi]
                por     mm0,12288[edi+eax*8]
                por     mm1,12288[edi+ebx*8]
                mov     al,15[esi]
                mov     bl,14[esi]
                por     mm0,14336[edi+eax*8]
                por     mm1,14336[edi+ebx*8]
                mov     al,17[esi]
                mov     bl,16[esi]
                movq    mm2,[edi+eax*8]
                movq    mm3,[edi+ebx*8]
                mov     al,19[esi]
                mov     bl,18[esi]
                por     mm2,2048[edi+eax*8]
                por     mm3,2048[edi+ebx*8]
                mov     al,21[esi]
                mov     bl,20[esi]
                por     mm2,4096[edi+eax*8]
                por     mm3,4096[edi+ebx*8]
                mov     al,23[esi]
                mov     bl,22[esi]
                por     mm2,6144[edi+eax*8]
                por     mm3,6144[edi+ebx*8]
                mov     al,25[esi]
                mov     bl,24[esi]
                por     mm2,8192[edi+eax*8]
                por     mm3,8192[edi+ebx*8]
                mov     al,27[esi]
                mov     bl,26[esi]
                por     mm2,10240[edi+eax*8]
                por     mm3,10240[edi+ebx*8]
                mov     al,29[esi]
                mov     bl,28[esi]
                por     mm2,12288[edi+eax*8]
                por     mm3,12288[edi+ebx*8]
                mov     al,31[esi]
                mov     bl,30[esi]
                por     mm2,14336[edi+eax*8]
                por     mm3,14336[edi+ebx*8]
                movq    [edx],mm0
                movq    8[edx],mm1
                movq    16[edx],mm2
                movq    24[edx],mm3
                add     esi,32
                add     dx,32
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c640_256_2

                mov     eax,d [SourceAdd]
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c640_256_1
                ret

c640_64k:       mov     d [VesaBank],0          ; Bank 0
                call    SetVesaBank
                mov     edx,0a0000h             ; Screen Segment

                lea     edi,ShiftTable

                mov     eax,d [SourceOffset]    ; interlace
                shr     eax,1
                add     esi,eax
                add     edx,d [DestOffset]
                mov     eax,d [SourceAdd]
                xor     d [SourceOffset],eax
                mov     eax,640
                xor     d [DestOffset],eax

                mov     ecx,d [CurrentHeight]
                cmp     ecx,400
                jl      short c640_64k_1
                shr     ecx,1
c640_64k_1:     push    ecx
                mov     ecx,20
c640_64k_2:     movq    mm0,[esi]
                movq    mm1,8[esi]
                movq    mm2,16[esi]
                movq    mm3,24[esi]
                movq    mm4,32[esi]
                movq    mm5,40[esi]
                movq    mm6,48[esi]
                movq    mm7,56[esi]
                movq    [edx],mm0
                movq    8[edx],mm1
                movq    16[edx],mm2
                movq    24[edx],mm3
                movq    32[edx],mm4
                movq    40[edx],mm5
                movq    48[edx],mm6
                movq    56[edx],mm7
                add     esi,64
                add     dx,64
                jnc     short @@noLfb
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb:        dec     ecx
                jnz     c640_64k_2

                mov     eax,d [SourceAdd]
                shr     eax,1
                add     esi,eax

                add     dx,640
                jnc     short @@noLfb2
                inc     d [VesaBank]
                call    SetVesaBank
@@noLfb2:       pop     ecx
                dec     ecx
                jnz     c640_64k_1
                ret

nute:           ret

SetMouse:       mov     ax,7                    ; horizontal
                xor     ecx,ecx
                mov     edx,d [CurrentWide]
                shl     edx,3
                int     33h
                mov     ax,8                    ; vertical
                xor     ecx,ecx
                mov     edx,d [CurrentHeight]
                shl     edx,3
                int     33h
                mov     ecx,d [CurrentWide]     ; centre mouse
                mov     edx,d [CurrentHeight]
                mov     ax,4
                int     33h
                mov     ax,1ah
                mov     ebx,d [CurrentWide]
                shr     ebx,1
                mov     ecx,d [CurrentHeight]
                add     ecx,ecx
                add     ecx,d [CurrentHeight]
                shr     ecx,1
                mov     dx,32
                int     33h

                mov     ecx,d [CurrentWide]     ; centre mouse
                mov     edx,d [CurrentHeight]

                call    CorrectMouse

;                mov     w OldMouseX,cx
;                mov     w oldMouseK,dx
                ret

SetVesaMode:    mov     ax,4f02h                ; Set Vesa Mode
                mov     ebx,d [CurrentMode]
                int     10h
                ret

SetVesaBank:    pushad
                mov     edx,d [VesaBank]
                mov     ax,4f05h
                xor     ebx,ebx
                int     10h
                popad
                ret
VesaBank:       dd      0


;**************************************************
; Palette Functions

SetPaletteF:
                test    d [ColorModeST],-1
                jnz     @@STEcolor

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
                ret

@@STEcolor:     lea     esi,[ebp+0ff8240h]      ; STE palette
                mov     dx,3c8h
                xor     eax,eax
                out     dx,al
                inc     dx
                mov     ecx,16
@@setpalSTE:    mov     al,1[esi]
                and     eax,15
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
                ret
                align 4
@@STEcolorTable:
                db      000h,088h,011h,099h,022h,0aah,033h,0bbh
                db      044h,0cch,055h,0ddh,066h,0eeh,077h,0ffh
                align 4
