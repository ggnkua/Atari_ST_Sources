;***************************************************************
;* MC68030 Debugger v0.8.5                                     *
;* (c) 1999-2000  XLR8 Software Design                         *
;* Frans van Nispen (xlr8@tref.nl)                             *
:* 															   *
:* This debugger acts just like MonST						   *
:* 															   *
;* 02-07-2000 FvN  HexSearch, Trace over BreakPoints, added    *
;*                 USP,ISP,CACR and VBR registers              *
;*                                                             *
;***************************************************************


                .586p
                .Model Flat
                .Stack 1000h
                .Code
                include std.inc
                include m68030\m68030.inc

                extrn   d68030          ; disassembler
                extrn   KeyBuffer,KeyInBuffer,KeyBufPos
                extrn   Falcon030,ShowF030Screen,TimerC,Cycles,CycleCount
                public  F030RAM,BRK,DISK

MemCol          equ     7h     ; Color of Disassembled memory
ROM=0e00000h
ROM_KB=512*1024
MemStart=0ff8a00h

Start:
                Set80x50                        ; set 80x50 textmode
                lea     ebp,F030RAM             ; FalconRam 16Mb
                Call    InitFalcon

Debug:          lea     edi,M68030_Reset
                call    edi

                call    DrawScreen

Main:
                mov     ax,0c00h        ; Clear Keyboard
                int     21h

                in      al,60h
                cmp     al,42h          ; F8=TraceInto
                jne     short @@Run
                Call    Trace030
                jmp     @@traceDone

@@Run:          cmp     al,3fh          ; F5=Run
                jne     short @@Trace
                lea     eax,Falcon030
                call    eax
                Set80x50                        ; set 80x50 textmode
                call    DrawScreen
                jmp     @@traceDone

@@Trace:        cmp     al,44h          ; F10=Trace
                jne     @@1

                mov     esi,d [R_PC]
                lea     esi,[ebp+esi]
                lea     edi,DisString
                lea     eax,d68030
                call    eax
                add     edx,esi         ; next adres
                sub     edx,ebp
@@loopTrace:    push    edx
                Call    Trace030
                pop     edx
                cmp     edx,d [R_PC]
                jz      short @@traceDone
                in      al,60h
                cmp     al,29h
                jz      short @@traceDone

                mov     ax,101h
                add     w [ebp+0fffa0ah],ax
                add     w [ebp+0fffa22h],ax


                jmp     short @@loopTrace

@@traceDone:    mov     edx,d [R_PC]
                cmp     d [DisWinStart],edx
                jg      short @@newDisStart
                cmp     d [DisWinEnd],edx
                jg      short @@trace_
@@newDisStart:  mov     d [DisWinStart],edx
@@trace_:       mov     dx,w WinColor
                Call    ShowDisW
                mov     dx,0707h
                Call    ShowRegisters
                mov     dx,w WinColor+2
                Call    ShowMemR
                jmp     WaitUpKey

@@1:            cmp     al,3eh                  ; F4
                jne     short @@2
@@waitF4:       in      al,60h
                test    al,al
                jns     short @@waitF4
                lea     ebx,ShowF030Screen
                call    ebx
@@1loop:        in      al,60h
                cmp     al,3eh
                jne     short @@1loop
                Set80x50                        ; set 80x50 textmode
                call    DrawScreen
                jmp     WaitUpKey

@@2:            cmp     al,41h                  ; F7=Step
                jne     short @@21
                mov     esi,d [R_PC]
                lea     esi,[ebp+esi]
                lea     edi,DisString
                lea     eax,d68030
                call    eax
                add     edx,esi         ; next adres
                sub     edx,ebp
                mov     d [R_PC],edx
                jmp     @@traceDone

@@21:           cmp     al,48h                  ; L,R,U,D,PgUp,PgDn
                jl      short @@3
                cmp     al,53h
                jg      short @@3
                xor     ebx,ebx
                mov     bl,al
                sub     bl,48h
                mov     edx,d @@AddTable[ebx*4]
                mov     eax,d WinPnt
                mov     ebx,d [eax]
                sub     ebx,edx
                and     ebx,0ffffffh
                mov     d [eax],ebx
                jmp     ShowWindows
@@AddTable:     dd      4,120,0,2,0,-2,0,0,-4,-120,-8000h,8000h

@@3:            cmp     al,15                   ; TAB
                jne     Key4
                mov     eax,d WinPnt
                mov     ebx,d WinPnt+4
                mov     d WinPnt,ebx
                mov     d WinPnt+4,eax
                mov     ax,w WinColor
                mov     bx,w WinColor+2
                mov     w WinColor,bx
                mov     w WinColor+2,ax
ShowWindows:    mov     dx,w WinColor
                Call    ShowDisW
                mov     dx,w WinColor+2
                Call    ShowMemW
                mov     dx,1717h
                call    ShowInfoW
                jmp     WaitUpKey

Key4:           cmp     al,50                   ; M
                jne     Key5
                mov     dx,3f31h
                Window  20,40,40,3,"Enter new Window Startadress"
                mov     edi,22*2+42*160+0b8000h
                call    getinput
                test    eax,eax
                js      ShowWindows
                mov     eax,d WinPnt
                and     edx,0ffffffh
                mov     [eax],edx
                jmp     ShowWindows
Key5:           cmp     al,19                   ; R
                jne     Key6

                jmp     WaitUpKey
Key6:           cmp     al,48                   ; B
                jne     Key7
                mov     dx,0707h
                Call    ShowDisW
                mov     dx,1717h
                Call    ShowMemW
                mov     dx,3f31h
                Window  20,40,40,3,"Enter BreakPoint"
                mov     edi,22*2+42*160+0b8000h
                call    getinput
                test    eax,eax
                js      ShowWindows
                and     edx,0ffffffh
                mov     d BRK,edx
                call    ShowRegisters
                jmp     ShowWindows

                jmp     WaitUpKey
Key7:           cmp     al,34                   ; G
                jne     Key8
                mov     dx,3f31h
                Window  20,40,40,3,"Enter Search adres"
                mov     edi,22*2+42*160+0b8000h
                call    getinput
                test    eax,eax
                js      Cont7

                and     edx,0fffffeh
                mov     d SearchPnt,edx
Cont7:
                mov     dx,3f31h

                Window  20,40,40,3,"Enter Search Hex"

                mov     edi,22*2+42*160+0b8000h
                call    getinput
                test    eax,eax
                js      ShowWindows

                mov     d SearchHex,edx

                mov     eax,d Hcount
                sub     eax,5
                js      @@word
                mov     d SearchMode,1           ; long
                jmp     short Search
@@word:         mov     eax,d Hcount
                sub     eax,3
                js      @@byte
                mov     d SearchMode,2           ; long
                jmp     short Search
@@byte:         mov     d SearchMode,3           ; long

Search:         mov     esi,d SearchPnt
                mov     eax,d SearchHex
                cmp     d SearchMode,3
                jz      SearchB
                and     esi,0fffffeh
                cmp     d SearchMode,1
                jz      SearchL
                cmp     d SearchMode,2
                jz      SearchW
                jmp     NoSearch

SearchL:        rol     eax,16
@@loop:         cmp     eax,d [ebp+esi]
                jz      Found
                add     esi,2
                and     esi,0ffffffh
                jnz     short @@loop
                jmp     NoSearch

SearchW:
                cmp     ax,w [ebp+esi]
                jz      Found
                add     esi,2
                and     esi,0ffffffh
                jnz     short SearchW
                jmp     NoSearch

SearchB:
                cmp     al,b [ebp+esi]
                jz      Found
                inc     esi
                and     esi,0ffffffh
                jnz     short SearchB
                jmp     NoSearch

Found:          mov     eax,d WinPnt
                and     esi,0ffffffh
                mov     [eax],esi
                add     esi,2
                and     esi,0fffffeh
                mov     d SearchPnt,esi

NoSearch:       call    ShowRegisters
                jmp     ShowWindows

Key8:           cmp     al,49                   ; N
                jne     Key9
                Window  20,40,40,2,"Searching...."
                test    d SearchMode,-1
                jnz     Search
                call    ShowRegisters
                jmp     ShowWindows
Key9:

                dec     al              ; Esc=Exit
                jnz     Main

                mov     ax,3
                int     10h


                mov     ax,4c00h
                int     21h
WaitUpKey:      in      al,60h
                test    al,al
                jns     short WaitUpKey
                jmp     Main

Error:          mov     eax,900h                ; Print
                int     21h
                mov     ax,4c00h
                int     21h

;*************************
;* trace 1 instruction
;*************************
Trace030:       mov     eax,0
                mov     d [M68030_ICount],eax           ; 1 instructie

                mov     ebx,d [BRK]                     ; remove BreakPnt
                mov     d [BRK1],ebx                    ; for Trace only
                mov     d [BRK],eax

                lea     edi,M68030_Run
                call    edi

                mov     ebx,d [BRK1]                    ; Restore BrealPnt
                mov     d [BRK],ebx

                ret

;*************************
;* Build registerwindow
;*************************
ShowRegW:       Window  0,1,78,12,"M68030 Registers"
ShowRegisters:  mov     edi,0b8000h+4+3*160             ; data registers
                mov     ecx,8
                lea     esi,R_D0
@@loop:         Call    ShowDx
                add     esi,4
                add     edi,160
                dec     ecx
                jnz     short @@loop

                mov     edi,0b8000h+50+3*160            ; adres registers
                mov     ecx,8
                lea     esi,R_A0
@@loop1:        Call    ShowAx
                add     esi,4
                add     edi,160
                dec     ecx
                jnz     short @@loop1
                mov     ax,'IS'                         ; ISP
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     ax,"P="
                mov     b 4[edi],ah
                mov     b 6[edi],al
                push    edi
                add     edi,10
                mov     edx,d [R_ISP]
                Call    ShowHex8
                pop     edi

                add     edi,160
                mov     ax,'MS'                         ; MSP
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     ax,"P="
                mov     b 4[edi],ah
                mov     b 6[edi],al
                add     edi,10
                mov     edx,d [R_MSP]
                Call    ShowHex8

;                mov     edi,0b8000h+80+11*160            ; adres registers
                add     edi,4
                mov     ax,'CA'                         ; CACR
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     ax,"CR"
                mov     b 4[edi],ah
                mov     b 6[edi],al
                mov     ax," ="
                mov     b 8[edi],ah
                mov     b 10[edi],al
                add     edi,14
                mov     edx,d [R_CACR]
                Call    ShowHex8

;                mov     edi,0b8000h+80+11*160            ; adres registers
                add     edi,4
                mov     ax,'VB'                         ; VBR
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     ax,"R "
                mov     b 4[edi],ah
                mov     b 6[edi],al
                mov     al,"="
                mov     b 8[edi],al
                add     edi,12
                mov     edx,d [R_VBR]
                Call    ShowHex8

                
                mov     edi,0b8000h+4+12*160            ; pc
                mov     ax,'PC'
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     al,':'
                mov     b 4[edi],al
                add     edi,8
                mov     edx,d [R_PC]
                mov     ecx,8
                mov     bl,10
                Call    ShowHex

                mov     edi,0b8000h+4+11*160
                mov     ax,'SR'
                mov     b [edi],ah
                mov     b 2[edi],al
                mov     al,':'
                mov     b 4[edi],al
                add     edi,8

                 mov   edx,d [R_CCR]
                 mov   ah,b [R_XC]
		 mov   ECX,edx
		 and   ECX,1
		 shr   eax,4
		 and   eax,01Ch 		; X, N & Z

		 or    eax,ECX 				; C

		 mov   ECX,edx
		 shr   ECX,10
		 and   ECX,2
		 or    eax,ECX				; O
		 mov   ah,b [R_SR_H] 	; T, S & I
                 mov    dx,ax
                 push   eax

                Call    ShowHex4

                pop     edx
                add     edi,4
                mov     ecx,5
                shl     dl,3
@@lloop:        mov     al,b [@@CCRtab+ecx]
                shl     dl,1
                jc      short @@pnt
                mov     al,'.'
@@pnt:          mov     b [edi],al
                add     edi,2
                dec     ecx
                jne     short @@lloop
                add     edi,6

                mov     dl,b [R_IRQ]
                call    ShowHex2

                ret
@@CCRtab:       db " CVZNX"
                align   4

ShowDx:         pushad
                mov     eax,8
                sub     eax,ecx                 ; Dx
                add     al,'0'
                mov     b [edi],"d"
                mov     b [edi+2],al
                mov     b [edi+6],"="
                add     edi,10

                mov     edx,d [esi]
                Call    ShowHex8

                add     edi,4                   ; Skip 2 spaces
                mov     ecx,4                   ; 4 chars
                mov     edx,d [esi]
                mov     bl,MemCol
                mov     bh,0f0h
@@loop1:        rol     edx,8
                cmp     dl,0
                jnz     short @@1
                mov     dl,'_'
@@1:            mov     b [edi],dl
                and     b [edi+1],bh
                or      b [edi+1],bl
                add     edi,2
                dec     ecx
                jnz     short @@loop1
                popad
                ret

; Show LongWord in EDX
ShowHex6:       mov     ecx,6
                rol     edx,8
                mov     bl,14
                jmp     short ShowHex
ShowHex4:       mov     ecx,4
                mov     bl,5
                or      dx,dx
                jz      @@1
                mov     bl,4
@@1:            rol     edx,16
                jmp     short ShowHex
ShowHex2:       mov     ecx,2
                mov     bl,5
                or      dl,dl
                jz      @@1
                mov     bl,2
@@1:            ror     edx,8
                jmp     short ShowHex
ShowHex8:       mov     ecx,8                   ; 8 nibbles
                mov     bl,15
                or      edx,edx
                jz      ShowHex
                mov     bl,3
ShowHex:
                push    eax
                push    ecx
                mov     bh,0f0h
@@loop:         rol     edx,4                   ; shift nibble
                mov     al,dl
                and     eax,15
                mov     al,b HexTab[eax]
                mov     b [edi],al
                and     b 1[edi],bh
                or      b 1[edi],bl
                add     edi,2
                dec     ecx
                jnz     short @@loop
                pop     ecx
                pop     eax
                ret

ShowAx:         pushad
                mov     eax,8
                sub     eax,ecx                 ; Ax
                add     al,'0'
                mov     b [edi],"a"
                mov     b [edi+2],al
                mov     b [edi+6],"="
                add     edi,10
                mov     edx,d [esi]
                Call    ShowHex8
                add     edi,4                   ; Skip 2 spaces
                mov     eax,d [esi]             ; get Ax
                and     eax,0ffffffh            ; mask 24 bits
                test    al,1                    ; odd?
                jne     short @@odd

                mov     ecx,5                   ; 5 words
                Call    ShowMem
                popad
                ret

@@loop1:        push    ecx
                mov     ecx,4                   ; 4 nibbles
                mov     dx,w [eax]              ; get mem
                mov     b [edi+32],dl
                mov     b [edi+34],dh
@@loop2:        rol     dx,4
                mov     bl,dl
                and     ebx,15
                mov     bl,b HexTab[ebx]
                mov     b [edi],bl
                add     edi,2
                dec     ecx
                jnz     short @@loop2
                pop     ecx
                add     edi,2
                add     eax,2
                and     eax,0ffffffh            ; wrap?
                dec     ecx
                jnz     short @@loop1

                popad
                ret

@@odd:          and     eax,0fffffeh            ; EAX=falcon Adres
                mov     b [edi],0
                mov     b [edi+2],0
                add     edi,4
                mov     dl,b [ebp+eax]
                add     eax,2
                mov     b [edi+32],dl
                rol     dl,4
                mov     bl,dl
                and     ebx,15
                mov     bl,b HexTab[ebx]
                mov     b [edi],bl
                rol     dl,4
                mov     bl,dl
                and     ebx,15
                mov     bl,b HexTab[ebx]
                mov     b 2[edi],bl
                add     edi,6

                mov     ecx,4                   ; 4 words
                Call    ShowMem

                popad
                ret

ShowMem:        lea     ebx,[edi+ecx*8]         ; edi+8*aantal
                add     ebx,ecx                 ; edx=edi+9*aantal
                add     ebx,ecx                 ; edx=edi+10*aantal
                mov     d [@@screen],ebx
@@loop3:        push    ecx
                push    eax
                mov     bh,0f0h
                lea     eax,[ebp+eax]           ; PC Adres
                mov     dx,w [eax]              ; get mem
                push    edx
                mov     ecx,d [@@screen]
                or      dh,dh
                jnz     short @@1
                mov     dh,'_'
@@1:            mov     bl,MemCol
                mov     b [ecx],dh
                or      dl,dl
                jnz     short @@2
                mov     dl,'_'
@@2:            mov     b [ecx+2],dl
                and     b [ecx+1],bh
                or      b [ecx+1],bl
                and     b [ecx+3],bh
                or      b [ecx+3],bl
                add     ecx,4
                mov     d [@@screen],ecx
                mov     ecx,4                   ; 4 nibbles
                pop     edx
@@loop4:        rol     dx,4
                mov     bl,dl
                and     ebx,15
                mov     bl,b HexTab[ebx]
                mov     b [edi],bl
                and     b 1[edi],0f0h
                mov     bl,7
                test    dx,dx
                jz      short @@3
                mov     bl,15
@@3:            or      b 1[edi],bl
                add     edi,2
                dec     ecx
                jnz     short @@loop4
                pop     eax
                pop     ecx
                add     edi,2
                add     eax,2
                and     eax,0ffffffh            ; wrap?
                dec     ecx
                jnz     short @@loop3
                ret
@@screen:       dd      0

HexTab:         db      '0123456789ABCDEF'

;***********************************
;* Show DisAssembly
;***********************************
ShowDisW:       Window  0,15,52,32,"Disassemble"

ShowDis:        mov     edi,0b8000h+4+17*160
                mov     ecx,30                          ; 30 lines

                mov     esi,d DisWinStart               ; StartAdres window
                lea     esi,[ebp+esi]
@@loop:         push    ecx
                push    edi
                lea     edi,DisString
                lea     eax,d68030
                call    eax
                pop     edi

                push    edx
                mov     edx,esi
                sub     edx,ebp
                Call    ShowHex6
                mov     ax,': '
                mov     b [edi],ah
                cmp     d [R_PC],edx
                jnz     short @@2
                mov     al,'>'
@@2:            mov     b 2[edi],al
                add     edi,4

                lea     ebx,DisString
                mov     cl,4
                cmp     d BRK,edx               ; breakpoint
                je      short @@1
                mov     cl,15
                cmp     d [ebx],'part'
                jne     short @@noTrap
                mov     cl,3
@@noTrap:       cmp     d [R_PC],edx
                jnz     short @@1
                mov     cl,10
@@1:
                mov     ch,0f0h
                pop     edx
                add     esi,edx
                mov     edx,edi
@@print:        mov     al,b [ebx]
                test    al,al
                jz      short @@done
                inc     ebx
                mov     b [edx],al
                and     b 1[edx],ch
                or      b 1[edx],cl
                add     edx,2
                jmp     short @@print
@@done:         add     edi,160-16
                pop     ecx
                dec     ecx
                jnz     short @@loop

                mov     edx,esi
                sub     edx,ebp
                mov     d [DisWinEnd],edx

                ret
DisWinStart:    dd      0e00030h
DisWinEnd:      dd      0

;***********************************
;* Show Memory
;***********************************
ShowMemW:       Window  54,15,24,32,"Memory"

ShowMemR:       mov     edi,0b8000h+98+7*2+17*160
                mov     ecx,30                          ; 26 lines

                mov     esi,d MemWinStart               ; StartAdres window
@@loop:         pushad
                mov     edx,esi
                Call    ShowHex6
                mov     ax,': '
                mov     b [edi],ah
                mov     b 2[edi],al
                add     edi,4
                mov     ecx,2                   ; 3 words
                mov     eax,esi                 ; Falcon Adress
                Call    ShowMem
                popad
                add     edi,160
                add     esi,4
                dec     ecx
                jnz     short @@loop

                ret

MemWinStart:    dd      MemStart

;***********************************
;* Show Info
;***********************************
ShowInfoW:      ret
                Window  54,41,24,6,"Info"

                mov     edi,0b8000h+98+6*2+42*160

                lea     esi,KeyBuffer                     ; StartAdres window
                mov     edx,d [KeyBufPos]
                sub     edx,d [KeyInBuffer]
                call    ShowHex6
                add     edi,2
                mov     edx,d [KeyBufPos]
                call    ShowHex6
                add     edi,2
                mov     edx,d [KeyInBuffer]
                call    ShowHex6

                mov     ecx,5
                add     edi,160-14*3+2
@@loop:         pushad
                mov     ecx,8
@@lp:           mov     dl,b [esi]
                inc     esi
                push    ecx
                Call    ShowHex2
                pop     ecx
                add     edi,2
                dec     ecx
                jnz     short @@lp
                popad
                add     edi,160
                add     esi,8
                dec     ecx
                jnz     short @@loop

                ret

;*****************************************
;* Print a ASCIIZ-string to EDI (screen) *
;* String in EDX, color in CL            *
;*****************************************
printEDI:       pushad
@@print:        mov     al,b [edx]
                test    al,al
                jz      short @@done
                inc     edx
                mov     b [edi],al
                mov     b 1[edi],cl
                add     edi,2
                jmp     short @@print
@@done:         popad
                ret

;***********************************
;* Window, make a window with title
;***********************************
_Window:        mov     d [_WinX],ebx
                mov     d [_WinY],eax
                mov     d [_WinW],ecx
                mov     d [_WinH],esi
                mov     d [_WinS],edi
                mov     ecx,160
                push    edx
                imul    ecx
                add     ebx,ebx
                pop     edx
                add     eax,ebx
                lea     edi,[eax+0b8000h]
                mov     esi,edi


                mov     ecx,d [_WinW]
                mov     b [edi],"É"
                add     edi,2
                mov     b -1[edi],dh
@@line:         mov     b [edi],"Í"
                mov     b 1[edi],dh
                add     edi,2
                dec     ecx
                jnz     short @@line
                mov     b [edi],"»"
                mov     b 1[edi],dh

                mov     edi,esi
                add     edi,6
                mov     b [edi],"["
                mov     b 1[edi],dh
                mov     b 2[edi]," "
                mov     b 3[edi],dh
                add     edi,4
                push    esi
                mov     esi,d [_WinS]
                mov     ecx,d [_WinW]
                sub     ecx,2
@@stringCopy:   mov     al,b [esi]
                add     esi,1
                test    al,al
                jz      short @@exitCopy
                mov     b [edi],al
                mov     b 1[edi],dh
                add     edi,2
                dec     ecx
                jnz     short @@stringCopy
@@exitCopy:     
                mov     b [edi]," "
                mov     b 1[edi],dh
                mov     b 2[edi],"]"
                mov     b 3[edi],dh
                pop     esi

                add     esi,160                 ; next line
                mov     edi,esi

                mov     ebx,d [_WinH]
@@lineLp:       mov     ecx,d [_WinW]
                mov     b [edi],"º"
                add     edi,2
                mov     b -1[edi],dh
@@line1:        mov     b [edi]," "
                mov     b 1[edi],dl
                add     edi,2
                dec     ecx
                jnz     short @@line1
                mov     b [edi],"º"
                mov     b 1[edi],dh

                add     esi,160                 ; next line
                mov     edi,esi
                dec     ebx
                jnz     short @@lineLp

                mov     ecx,d [_WinW]
                mov     b [edi],"È"
                add     edi,2
                mov     b -1[edi],dh
@@line2:        mov     b [edi],"Í"
                mov     b 1[edi],dh
                add     edi,2
                dec     ecx
                jnz     short @@line2
                mov     b [edi],"¼"
                mov     b 1[edi],dh


                ret

;*************************************
;* Set 80x50 textmode
;*************************************
_Set80x50:      mov     ax,1200h+2      ; 0=200, 1=350, 2=400
                mov     bl,30h
                int     10h
                mov     ax,3
                int     10h
                mov     ax,1110h+2      ; 4=8x16, 2=8x8
                mov     bl,0
                int     10h
                ret

;*************************************
;* SetUp Debugger screenlayout.
;*************************************
DrawScreen:     mov     edi,0b8000h
                lea     edx,TitleString
                mov     cl,6eh
                call    printEDI

                test    d [CycleCount],-1
                jz      noMhz
                mov     edi,0b8000h+142         ; claculate average speed
                mov     edx,d [Cycles]
                mov     eax,d [Cycles+4]
                mov     ebx,d [CycleCount]
                div     ebx
                mov     ebx,100000 ;0             ; for convert to Mhz
                mul     d [RefreshRate]         ; cycles/sec
                div     ebx
                mov     ebx,d [Cycles]
                shr     ebx,1
                cmp     edx,ebx
                jl      short @@noAdd
                inc     eax
@@noAdd:        mov     bl,100          ; 100 tallen
                div     bl
                add     al,'0'
                mov     b [edi],al
                shr     eax,8
                mov     bl,10
                add     edi,2
                div     bl
                add     al,'0'
                mov     b [edi],al
                shr     eax,8
                add     edi,2
                add     al,'0'
                mov     b [edi],al

                sub     edi,12
                mov     eax,d [Cycles+8]        ; calculate current speed
                add     eax,d [Cycles+12]
                shr     eax,1
                mov     ebx,100000 ;0             ; for convert to Mhz
                mul     d [RefreshRate]         ; cycles/sec
                div     ebx
                mov     ebx,d [Cycles]
                shr     ebx,1
                cmp     edx,ebx
                jl      short @@noAdd2
                inc     eax
@@noAdd2:       mov     bl,100          ; 100 tallen
                div     bl
                add     al,'0'
                mov     b [edi],al
                shr     eax,8
                mov     bl,10
                add     edi,2
                div     bl
                add     al,'0'
                mov     b [edi],al
                shr     eax,8
                add     edi,2
                add     al,'0'
                mov     b [edi],al


noMhz:
                mov     edi,0b8000h+49*160
                lea     edx,BottomString
                mov     cl,70h
                call    printEDI

                mov     dx,1717h
                Call    ShowRegW
                mov     dx,w WinColor+2
                Call    ShowMemW
                mov     dx,w WinColor
                Call    ShowDisW
                mov     dx,1717h
                Call    ShowInfoW
                ret

getinput:       mov     ax,0c00h
                int     21h
                mov     d Hcount,0
                mov     d @@number,0
                mov     al,'_'
                mov     b [edi],al
@@loop:
                mov     ax,700h
                int     21h
                cmp     al,'='
                jne     @@hex
                mov     b [edi],al
                add     edi,2
                mov     ax,700h
                int     21h
                cmp     al,'p'
                je      @@pc
                cmp     al,'P'
                je      @@pc
                cmp     al,'a'
                je      @@ar
                cmp     al,'A'
                je      @@ar
                cmp     al,'d'
                je      @@dr
                cmp     al,'D'
                je      @@dr
                cmp     al,13
                je      @@exit
                cmp     al,27
                jne     @@loop
@@error:        mov     eax,-1          ; error
                ret
@@exit:         cmp     d Hcount,0
                jne     short @@newvalue
                mov     eax,-1          ; no change
                ret
@@newvalue:     mov     eax,0
                mov     edx,d @@number
                ret
@@pc:           mov     b [edi],al
                add     edi,2
                mov     al,'_'
                mov     b [edi],al
                mov     ax,700h
                int     21h
                cmp     al,'c'
                je      short @@pc1
                cmp     al,'C'
                jne     short @@exit
@@pc1:          mov     b [edi],al
                add     edi,2
                mov     eax,0
                mov     edx,d [R_PC]
                ret
@@ar:           mov     b [edi],al
                add     edi,2
                mov     al,'_'
                mov     b [edi],al
                mov     ax,700h
                int     21h
                cmp     al,'0'
                jl      short @@exit
                cmp     al,'7'
                jg      short @@exit
@@ar1:          mov     b [edi],al
                add     edi,2
                sub     al,'0'
                and     eax,7
                mov     edx,d [R_A0+eax*4]
                mov     eax,0
                ret
@@dr:           mov     b [edi],al
                add     edi,2
                mov     al,'_'
                mov     b [edi],al
                mov     ax,700h
                int     21h
                cmp     al,'0'
                jl      @@exit
                cmp     al,'7'
                jg      @@exit
@@dr1:          mov     b [edi],al
                add     edi,2
                sub     al,'0'
                and     eax,7
                mov     edx,d [R_D0+eax*4]
                mov     eax,0
                ret
@@hexloop:      mov     ax,700h
                int     21h
@@hex:          cmp     al,13
                je      short @@hexexit
                cmp     al,27
                je      @@error
                cmp     al,'0'
                jl      short @@hexloop
                cmp     al,'9'
                jle     short @@hexadd
                and     al,0dfh         ; UPPER Case
                cmp     al,'A'
                jl      short @@hexloop
                cmp     al,'F'
                jg      short @@hexloop
                sub     al,7
@@hexadd:       sub     al,'0'
                shl     d [@@number],4
                and     eax,15
                add     d [@@number],eax
                mov     al,b [HexTab+eax]
                mov     b [edi],al
                add     edi,2
                mov     al,'_'
                mov     b [edi],al
                add     d [Hcount],1
                cmp     d [Hcount],8
                jne     @@hexloop
@@hexexit:      cmp     d [Hcount],0
                jz      @@error
                mov     eax,0
                mov     edx,d @@number
                ret

@@number:       dd      0
Hcount:         dd      0

;*************************************
;* SetUp Falcon memory ..
;*************************************
InitFalcon:     mov     eax,3d00h               ; Open File
                lea     edx,TOSpath
                int     21h
                jc      ErrorTos
                mov     ebx,eax                 ; Handle
                mov     eax,3f00h               ; fread
                mov     ecx,ROM_KB              ; FalconTOS=512Kb
                lea     edx,[ebp+ROM]           ; TOS starts at $E00000
                int     21h
                jc      ErrorTos
                mov     eax,3e00h               ; fclose
                int     21h

                mov     eax,3d00h               ; Open File
                lea     edx,DISKname
                int     21h
                jc      @@noDisk
                mov     ebx,eax                 ; Handle
                mov     eax,3f00h               ; fread
                mov     ecx,720*1024            ; 720Kb disk
                lea     edx,DISK                ; Empty Place for disk
                int     21h
                jc      @@noDisk
                mov     eax,3e00h               ; fclose
                int     21h

@@noDisk:       mov     ecx,ROM_KB/2          ; Convert to Intelformat
                lea     esi,[ebp+ROM]
@@loop:         mov     ax,w [esi]
                rol     ax,8
                mov     w [esi],ax
                add     esi,2
                dec     ecx
                jnz     short @@loop

                mov     eax,d [ebp+ROM]    ; Rom Copy for Resetvector
                mov     d [ebp],eax
                mov     eax,d [ebp+ROM+4]
                mov     d [ebp+4],eax

                mov     w [ebp+0ff8006h],09665h ;14Mb=0a265h 4Mb=09665h
                                                ;1MB=8265h 8Mb=a065h
                ret


ErrorTos:       lea     edx,ErrorTos_
                jmp     Error
ErrorTos_:      db      'Falcon.TOS not found!',13,'$'

        even
TOSpath:        db      'Falcon.tos',0

DISKname:       db      'disk.st',0
TitleString:    db      '  TOS 404 v0.2.5 Beta          ATARI Falcon030 Emulator    Speed : 000/000 Mhz. ',0
BottomString:   db      'F5=Run  F7=Skip  F8=Trace into  F10=Trace over  `=Debugger             Esc=Exit ',0
DisString:      db      80 DUP (' ')
                align   4

                .Data
RefreshRate:    dd      60              ; 60Hz screen refresh
WinPnt:         dd      DisWinStart,MemWinStart
WinColor:       dw      0f07h,1717h
BRK:            dd      0
BRK1:           dd      0
SearchPnt:      dd      0
SearchHex:      dd      0
SearchMode:     dd      0
_WinX           dd      0
_WinY           dd      0
_WinW           dd      0
_WinH           dd      0
_WinS           dd      0
DISK:           dd      184320 DUP (?)          ; Disk A                
F030RAM         dd      4*1024*1024 DUP (?)     ; always 16MB!
                END Start
   