;
;       Martin Griffiths March 1994.
;       

.386

; Some VGA register equates.

AC_INDEX        equ  03c0h   ;Attribute controller index register
MISC_OUTPUT     equ  03c2h   ;Miscellaneous Output register
SC_INDEX        equ  03c4h   ;Sequence Controller Index
GC_INDEX        equ  03ceh   ; Graphics controller Index
CRTC_INDEX      equ  03d4h   ;CRT Controller Index
DAC_READ_INDEX  equ  03c7h   ;
DAC_WRITE_INDEX equ  03c8h   ;
DAC_DATA        equ  03c9h   ;
INPUT_STATUS_0  equ   03dah   ;Input status 0 register

_TEXT segment para public use32 'CODE'

assume cs:_TEXT, ds:_DATA

; Clear Screen
; EAX -> area to clear.

PUBLIC ClearScr_

ClearScr_       PROC    NEAR
                pushad
                mov     EDI,EAX
                mov     DX,SC_INDEX
                mov     ax,0f02h
                out     dx,ax                 ; enable writes to all four planes
                mov     ECX,19200 / 4
                xor     EAX,EAX
                rep     STOSD
                popad
                RET

ClearScr_       ENDP

_TEXT ends
                
_DATA segment para public use32 'DATA'

_DATA ends
                
                end
