;*************************************
;* Vertical Sync
;*************************************
Vsync	macro
	Call	_Vsync
	endm

_Vsync   proc
                mov     dx,3dah
@@vsync1:       in      al,dx
                test    al,8
                jnz     @@vsync1
@@vsync2:       in      al,dx
                test    al,8
                jz      @@vsync2
                ret
ENDP

;*************************************
;* Set Palette
;* In  : ESI = Palette
;*************************************
SetPalette      proc
                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx
                mov     cx,768
@setpal:        lodsb
                out     dx,al
                loop    @setpal
                ret
                ENDP

SetScreen macro ScrMode
                mov     ax,ScrMode
                int     10h
                endm

;*************************************
;* Set Color
;* SetColor Color, Red, Green, Blue
;*************************************
SetColor macro ccolor,cred,cgreen,cblue
                mov     eax,cblue*1000000h+cgreen*10000h+cred*100h+ccolor
                Call    SetColor_
                ENDM
SetColor_:      mov     dx,3c8h
                mov     cx,3
                out     dx,al
                inc     dx
SetColor__:     shr     eax,8
                out     dx,al
                loop    SetColor__
                ret
