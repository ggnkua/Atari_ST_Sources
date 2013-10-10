                p586
                p587
                model flat
                locals @@
                .Stack 1000h
                .code
q               equ     qword ptr
w               equ     word ptr
b               equ     byte ptr
d               equ     dword ptr
o               equ     offset

Window          macro   wx,wy,ww,wh,wtitle
                mov     ebx,wx
                mov     eax,wy
                mov     ecx,ww
                mov     esi,wh
                lea     edi,@@wintext
                Call    _Window
                jmp     short @@jumpwin
@@wintext:      db      wtitle
                db      0
                align   4
@@jumpwin:
                endm

Set80x50        macro
                Call    _Set80x50
                endm
