;***************************************************************
;* ACIA Emulaton v1.0                                          *
;* (c) 1999-2000  XLR8 Software Design                         *
;*                                                             *
;* 07-07-2000 FvN  Keyboard Implementation                     *
;*                                                             *
;***************************************************************
                public  KeyBuffer,KeyInBuffer,KeyBufPos
                align   4

ACIA_RB:        cmp     edi,0fffc02h            ; read Keyboard
                jz      short @@readKey
                cmp     edi,0fffc04h
                jz      short @@readMIDI
                cmp     edi,0fffc00h
                jnz     short @@justRead
                mov     al,b [ebp+0fffc01h]
                or      al,2                    ; receive buffer empty
                ret
@@justRead:     jmp     _ReadB

@@readKey:      call    ReadKeyboard
                mov     b [ebp+0fffc03h],al
                ret
@@readMIDI:     mov     al,2                    ; geen data, buffer leeg
                ret

ACIA_RW:        jmp     _ReadW

ACIA_RL:        jmp     _ReadL

ACIA_WB:        cmp     edi,0fffc02h            ; write Keyboard
                jz      short @@writeKey
;                cmp     edi,0fffc00h
;                jz      short @@writeControl
                jmp     _WriteB
;@@writeControl: ret

@@writeKey:     call    WriteKeyboard
                ret

ACIA_WW:        jmp     _WriteW

ACIA_WL:        jmp     _WriteL


;****************************************************
;* Routine called when read from fffc02
;****************************************************

ReadKeyboard:   push    edx
                mov     edx,d [KeyBufPos]
                sub     edx,d [KeyInBuffer]
                and     edx,16383               ; max 16Kb
                dec     edx
                js      short @@zeroBuffer
                jnz     short @@notLast
                mov     w [ebp+0fffc00h],0       ;Clear GPIP/I4
                or      b [ebp+0fffa00h],10h
                mov     edx,d [KeyInBuffer]
                mov     d [KeyBufPos],0
                mov     d [KeyInBuffer],0
                mov     al,b [KeyBuffer+edx]    ; read keycode
                pop     edx
                ret
@@notLast:      mov     edx,d [KeyInBuffer]
                inc     d [KeyInBuffer]
                mov     al,b [KeyBuffer+edx]    ; read keycode
                pop     edx
                ret
@@zeroBuffer:   pop     edx
                mov     d [KeyBufPos],0
                mov     d [KeyInBuffer],0
                mov     al,0a2h
                ret

WriteKeyboard:  mov     b [ebp+0fffc03h],al
                cmp     al,22
                jnz     @@exit
                mov     al,0feh
                call    SendKeyboard
                xor     eax,eax
                call    SendKeyboard
@@exit:         ret

;****************************************************
;* Actual Keyboard-emulation
;****************************************************

SendKeyboard:   push    edx
                cmp     d [KeyBufPos],16384
                jz      @@BufferFull
                mov     edx,d [KeyBufPos]
                inc     d [KeyBufPos]
                mov     b [KeyBuffer+edx],al    ; Put byte in KeyBuffer
                and     d [KeyBufPos],16383
@@BufferFull:   mov     dl,b [ebp+0fffa08h]
                and     dl,40h
                jz      @@skipIRQ
                or      b [ebp+0fffa0ch],40h            ; Pending
                or      b [ebp+0fffc01h],81h    ; Set IRQ request
                and     b [ebp+0fffa00h],0efh   ; Clear GPIP/I4
                or      b [ebp+0fffa10h],40h    ; notify IRQ
                test    b [ebp+0fffa14h],40h            ; masked?
                jz      short @@skipIRQ
                mov     b [ebp+0fffa16h],46h            ; Vector
                or      b [R_IRQ],1                     ; MFP Irq
@@skipIRQ:      pop     edx
                ret

                .data
                align   4
KeyBuffer:      db      16384 dup (?)           ; 16Kb buffer
KeyInBuffer:    dd      0
KeyBufPos:      dd      0
MouseFreeze:    dd      0

