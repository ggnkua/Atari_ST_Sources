;***************************************************************
;* DSP Host Interface 0.1                                      *
;* (c) 1999-2000  XLR8 Software Design                         *
;*                                                             *
;* 07-07-2000 FvN  DummyLoad for DSP interface                 *
;*                                                             *
;***************************************************************

DSP_RB:         mov     b [ebp+0fffa00h],01000001b
                mov     w [ebp+0ffa202h],-1             ; set DSP flags
                jmp     _ReadB

DSP_RW:         mov     b [ebp+0fffa00h],01000001b
                mov     w [ebp+0ffa202h],-1             ; set DSP flags
                jmp     _ReadW

DSP_RL:         mov     b [ebp+0fffa00h],01000001b
                mov     w [ebp+0ffa202h],-1             ; set DSP flags
                jmp     _ReadL

DSP_WB:         jmp     _WriteB

DSP_WW:         jmp     _WriteW

DSP_WL:         jmp     _WriteL
