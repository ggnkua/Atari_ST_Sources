;************************************************************
;* Atari Falcon 030 Emulator v0.2.4                         *
;* (c) 1999-2000  XLR8 Software Design                      *
;* Code by Frans van Nispen                                 *
;*                                                          *
;* 07-07-2000 FvN  Re-coded the Hardware decoder so it now  *
;*                 supports BusError's and IC Emulation     *
;*                                                          *
;************************************************************

                .586p
                .Model Flat
                .Code
                include std.inc
                include m68030\m68030.inc
                include c:\xlr8\lib\mmx.inc
                include gfx.inc

                extrn   trapcont,trapend,F030RAM,DISK
                public  Falcon030,TimerA,TimerB,TimerC
                public  GemDos,Bios,Xbios,VDI_AES,ShowF030Screen,Cycles
                public  CycleCount

CyclesPerLine   equ     512/4     ; Instuctions per scanline (between IRQ's)
LinesPerVBL     equ     315       ; 60 Hz
Systimer        equ     200       ; Systeem Timer in Hz


Falcon030:      lea     ebp,F030RAM             ; FalconRam 16Mb

                call    SetMouse

                xor     eax,eax
                mov     d [TimerA],eax
                mov     d [VBL_Cycles],eax
                mov     d [CurrentMode],eax

RunLoop:        mov     eax,CyclesPerLine
                add     d [M68030_ICount],eax           ; 1 instructie
                lea     edi,M68030_Run
                call    edi

                in      al,60h
                cmp     al,29h
                jz      GoDebugger


                test    b [ebp+0fffa1ah],8              ; Timer B for Events?
                jz      short @@noLineCounter
                inc     b [ebp+0fffa20h]
@@noLineCounter:

                Call    Interupts030                    ; Handle harware
                add     d [VBL_Cycles],CyclesPerLine

                mov     dx,3dah
                in      al,dx
                test    al,8
                jz      short @@debug                   ; test for VBL

                Call    VBL

                xor     ebx,ebx
                mov     eax,d [VBL_Cycles]
                mov     ecx,d [Cycles+8]
                mov     d [Cycles+8],eax
                mov     d [Cycles+12],ecx
                mov     d [VBL_Cycles],ebx
                add     d [Cycles+4],eax
                adc     d [Cycles],ebx

                inc     d [CycleCount]

@@debug:        test    d Debug,-1
                jz      RunLoop
                mov     d Debug,0
GoDebugger:

                Setcolor 0,0,0,0
                ret                                     ; Go to debugger

Debug:          dd      0
VBL_Cycles:     dd      0

Cycles:         dd      0,0,0,0
CycleCount:     dd      0

                align   4
                include io.asm



;**************************************************
;* HBL handlers, Timers
;**************************************************
Interupts030:
                test    d [TimerA],1
                jnz     NewTimerAdata
                mov     d [TimerA],0

TimerHandlingA:

                mov     al,b [ebp+0fffa18h]             ; TimerA ctrl
                test    al,15
                jz      short @@noTimerA
                test    b [ebp+0fffa06h],20h
                jz      short @@noTimerA
                sub     b [ebp+0fffa1eh],1
                jns     short @@noTimerA
                mov     eax,d TimerAdata
                add     b [ebp+0fffa1eh],al
                or      b [ebp+0fffa0ah],20h            ; Pending
                test    b [ebp+0fffa12h],20h            ; masked?
                jz      short @@noTimerA
                mov     b [ebp+0fffa16h],4dh            ; Vector
                or      b [R_IRQ],1                     ; Timer Irq
                and     b [ebp+0fffa0ah],0dfh          ; Pending
                jmp     TimersEnd
@@noTimerA:
                test    d [TimerB],1
                jnz     NewTimerBdata
                mov     d [TimerB],0
TimerHandlingB:
                mov     al,b [ebp+0fffa1ah]             ; TimerB ctrl
                test    al,15
                jz      short @@noTimerB
                test    b [ebp+0fffa06h],1
                jz      short @@noTimerB
                sub     b [ebp+0fffa20h],1
                jns     short @@noTimerB
                mov     eax,d TimerBdata
                add     b [ebp+0fffa20h],al
                or      b [ebp+0fffa0ah],1           ; Pending
                test    b [ebp+0fffa12h],1           ; masked?
                jz      short @@noTimerB
                mov     b [ebp+0fffa16h],48h            ; Vector
                or      b [R_IRQ],1                     ; Timer Irq
                and     b [ebp+0fffa0ah],0feh          ; Pending
                jmp     TimersEnd
@@noTimerB:

                test    b [ebp+0fffa08h],20h            ; On
                jz      short @@noTimerC
                sub     b [ebp+0fffa22h],1
                sub     d TimerC,1
                jns     short @@noTimerC
                mov     d TimerC,(LinesPerVbl*60)/Systimer   ; 200Hz
                or      b [ebp+0fffa0ch],20h            ; Pending
                test    b [ebp+0fffa14h],20h            ; masked?
                jz      short @@noTimerC
                mov     b [ebp+0fffa16h],45h            ; Vector
                or      b [R_IRQ],1                     ; Timer Irq
;                jmp     TimersEnd
@@noTimerC:

                call    CorrectMouse

TimersEnd:
@@ok:
                mov     w [ebp+0ff8922h],0              ; reset microwire

@@noTimer:      ;or      b [R_IRQ],4                     ; HBL Irq
                ret

NewTimerAdata:  mov     d [TimerA],0
                xor     eax,eax
                mov     al,b [ebp+0fffa1eh]     ; get TimerA data
                mov     d [TimerAdata],eax
                jmp     TimerHandlingA
NewTimerBdata:  mov     d [TimerB],0
                xor     eax,eax
                mov     al,b [ebp+0fffa20h]     ; get TimerB data
                mov     d [TimerBdata],eax
                jmp     TimerHandlingB


CorrectMouse:
                test    d mouse,-1      ; ***************************** mouse
                jz      @@mouseOff
                pushad

                mov     ax,3
                int     33h
                mov     ax,bx
                shr     cx,3
                shr     dx,3
                and     al,1
                and     bl,2
                add     al,al
                shr     bl,1
                or      al,bl
                
                cmp     ax,w OldMouseK
                jnz     @@move
                cmp     cx,w OldMouseX
                jnz     @@move
                cmp     dx,w OldMouseY
                jz      @@skip

@@move:
                mov     bx,cx
                sub     bx,w OldMouseX
                mov     w OldMouseX,cx
                mov     w MouseDx,bx
                mov     cx,dx
                sub     cx,w OldMouseY
                mov     w OldMouseY,dx
                mov     w MouseDy,cx
                mov     w OldMouseK,ax
                or      ax,0f8h
                mov     w MouseCode,ax


@@mouseLoop:    mov     bx,w MouseDx
                cmp     bx,-128
                jge     short @@notMinX
                mov     bx,-128
                jmp     short @@mouseY
@@notMinX:      cmp     bx,127
                jle     short @@mouseY
                mov     bx,127
@@mouseY:       sub     w MouseDx,bx

                mov     cx,w MouseDy
                cmp     cx,-128
                jge     short @@notMinY
                mov     cx,-128
                jmp     short @@mouseD
@@notMinY:      cmp     cx,127
                jle     short @@mouseD
                mov     cx,127
@@mouseD:       sub     w MouseDy,cx

                mov     ax,w MouseCode
                call    SendKeyboard
                mov     ax,bx
                call    SendKeyboard
                mov     ax,cx
                call    SendKeyboard

                mov     ax,w MouseDx
                or      ax,w MouseDy
                jnz     short @@mouseLoop
@@skip:         popad

@@mouseOff:     ret


;**************************************************
;* OS functions
;**************************************************
        include bios.asm

;**************************************************
;* VBL handlers
;**************************************************
VBL:            call    DrawVBL

ExitVBL:        or      b [R_IRQ],2                     ; VBL Irq
                ret

ShowF030Screen: call    SetVesaMode
                call    DrawVBL
                call    DrawVBL
                and     b [R_IRQ],0fdh
                ret

;**************************************************
;* Screen Modes Emulation
;**************************************************
                align   4
                include screen.asm

                align   4
ShiftTable:     include shifttab.inc            ; MMX-shifter table
                align   4
ShiftTable2:    include shifttb2.inc            ; MMX-shifter table

                .data
CurrentMode:    dd      0                       ; Current Graphic mode
DisplayOffset:  dd      0
SourceWide:     dd      0
SourceOffset:   dd      0
SourceAdd:      dd      0
DestOffset:     dd      0
DestAdd:        dd      0
DrawRoutine:    dd      0
OldWide:        dd      0
OldHeight:      dd      0
CurrentWide:    dd      0
CurrentHeight:  dd      0
ColorModeST:    dd      0                       ; Current ColorTable (STE/F030)
CurrentColors:  dd      16                      ; Number of colors in palette
VBIcounter:     dd      0                       ; count line to VBL
TimerA:         dd      0
TimerAdata:     dd      0
TimerB:         dd      0
TimerBdata:     dd      0
TimerC:         dd      (LinesPerVbl*60)/Systimer
TimerCdata:     dd      0
OldMouseX:      dw      160
OldMouseY:      dw      100
OldMouseK:      dw      0
MouseDx:        dw      0
MouseDy:        dw      0
MouseCode:      dw      0
mouse:          dd      0
                END

