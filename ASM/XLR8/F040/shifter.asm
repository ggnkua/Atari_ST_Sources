;***************************************************************
;* Video Shifter Interface v1.0                                *
;* (c) 1999-2000  XLR8 Software Design                         *
;*                                                             *
;* 07-07-2000 FvN  Change to old ST modes                      *
;*                                                             *
;***************************************************************

Shift_RB:       jmp     _ReadB

Shift_RW:       jmp     _ReadW

Shift_RL:       jmp     _ReadL

Shift_WB:       cmp     edi,0ff8260h    ; ST shift
                jz      short @@ST
                cmp     edi,0ff8266h    ; F030 shift
                jnz     _WriteB
                mov     d [ColorModeST],0
                jmp     _WriteB
@@ST:           mov     d [ColorModeST],-1
                jmp     _WriteB

Shift_WW:       cmp     edi,0ff8260h    ; ST shift
                jz      short @@ST
                cmp     edi,0ff8266h    ; F030 shift
                jz      short @@F030
                jmp     _WriteW
@@ST:           mov     d [ColorModeST],-1
                jmp     _WriteW
@@F030:         mov     d [ColorModeST],0
                jmp     _WriteW

Shift_WL:       cmp     edi,0ff8260h    ; ST shift
                jz      short @@ST
                cmp     edi,0ff8266h    ; F030 shift
                jz      short @@F030
                jmp     _WriteL
@@ST:           mov     d [ColorModeST],-1
                jmp     _WriteL
@@F030:         mov     d [ColorModeST],0
                jmp     _WriteL
