;***************************************************************
;* IC emulation unit v1.0                                      *
;* (c) 1999-2000  XLR8 Software Design                         *
;*                                                             *
;* 07-07-2000 FvN  In/Out = EAX, Adres = EDI                   *
;*                 Need to preserve ALL registers              *
;*                                                             *
;***************************************************************

        public  HTabRB,HTabRW,HTabRL,HTabWB,HTabWW,HTabWL
        extrn   DebugExitW,DebugExit,Exception

ReadB:  test  b [R_SR_H],20h      ; Super?
        jz    BusErrorR
_ReadB: xor   EDI,1
	mov   al,b [ebp+EDI]
	xor   EDI,1
        ret
ReadW:  test  b [R_SR_H],20h      ; Super?
        jz    BusErrorR
_ReadW: mov   ax,w [ebp+EDI]
        ret
ReadL:  test  b [R_SR_H],20h      ; Super?
        jz    BusErrorR
_ReadL: mov   eax,d [ebp+EDI]
	rol   eax,16
        ret
WriteB: test  b [R_SR_H],20h      ; Super?
        jz    BusErrorW
_WriteB:xor   EDI,1
        mov   b [ebp+EDI],al
	xor   EDI,1
        ret
WriteW: test  b [R_SR_H],20h      ; Super?
        jz    BusErrorW
_WriteW:mov   w [ebp+EDI],ax
        ret
WriteL: test  b [R_SR_H],20h      ; Super?
        jz    BusErrorW
_WriteL:rol   eax,16
	mov   d [ebp+EDI],eax
        ret

BusErrorW:
        sub   esi,2
        mov   eax,2
        push  ebx
        lea   ebx,Exception
        call  ebx
        pop   ebx
;        lea   eax,DebugExitW
;        mov   d [esp],eax
        ret
AdresErrorW:
        sub   esi,2
        mov   eax,3
        push  ebx
        lea   ebx,Exception
        call  ebx
        pop   ebx
;        lea   eax,DebugExitW
;        mov   d [esp],eax
        ret
BusErrorR:
        sub   esi,2
        mov   eax,2
        push  ebx
        lea   ebx,Exception
        call  ebx
        pop   ebx
;        lea   eax,DebugExit
;        mov   d [esp],eax
        ret
AdresErrorR:
        sub   esi,2
        mov   eax,3
        push  ebx
        lea   ebx,Exception
        call  ebx
        pop   ebx
;        lea   eax,DebugExit
;        mov   d [esp],eax
        ret

;**************************************************
;* BLITTER Emulator
;**************************************************
        include blitter.asm

;**************************************************
;* DSP HostInterface
;**************************************************
        include dsp_host.asm

;**************************************************
;* Video Shifter    
;**************************************************
        include shifter.asm

;**************************************************
;* Keyboard/MIDI Emulation
;**************************************************
        include keyboard.asm



        align 4
        .data

HTabRB:
       rept    64               ; fff0200 - ff8000 -> BusError
        dd      BusErrorR
       endm
        dd      ReadB      ,Shift_RB   ,BusErrorR  ,ReadB       ; 80 82 84 86
        dd      ReadB      ,ReadB      ,ReadB      ,ReadB       ; 88 8A 8C 8E
        dd      BusErrorR  ,ReadB      ,ReadB      ,BusErrorR   ; 90 92 94 96
        dd      ReadB      ,ReadB      ,BusErrorR  ,BusErrorR   ; 98 9A 9C 9E
        dd      BusErrorR  ,DSP_RB     ,BusErrorR  ,BusErrorR   ; A0 A2 A4 A6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; A8 AA AC AE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B0 B2 B4 B6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B8 BA BC BE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C0 C2 C4 C6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C8 CA CC CE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D0 D2 D4 D6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D8 DA DC DE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E0 E2 E4 E6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E8 EA EC EE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; F0 F2 F4 F6
        dd      BusErrorR  ,ReadB      ,ACIA_RB    ,BusErrorR   ; F8 FA FC FE
HTabRW:
       rept    64               ; ff00000 - ff8000 -> adresError
        dd      BusErrorR  
       endm
        dd      ReadW      ,Shift_RW   ,BusErrorR  ,ReadW       ; 80 82 84 86
        dd      ReadW      ,ReadW      ,ReadW      ,ReadW       ; 88 8A 8C 8E
        dd      BusErrorR  ,ReadW      ,ReadW      ,BusErrorR   ; 90 92 94 96
        dd      ReadW      ,ReadW      ,BusErrorR  ,BusErrorR   ; 98 9A 9C 9E
        dd      BusErrorR  ,DSP_RW     ,BusErrorR  ,BusErrorR   ; A0 A2 A4 A6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; A8 AA AC AE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B0 B2 B4 B6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B8 BA BC BE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C0 C2 C4 C6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C8 CA CC CE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D0 D2 D4 D6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D8 DA DC DE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E0 E2 E4 E6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E8 EA EC EE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; F0 F2 F4 F6
        dd      BusErrorR  ,ReadW      ,ACIA_RW    ,BusErrorR   ; F8 FA FC FE
HTabRL:
       rept    64               ; ff00000 - ff8000 -> adresError
        dd      BusErrorR  
       endm
        dd      ReadL      ,Shift_RL   ,BusErrorR  ,ReadL       ; 80 82 84 86
        dd      ReadL      ,ReadL      ,ReadL      ,ReadL       ; 88 8A 8C 8E
        dd      BusErrorR  ,ReadL      ,ReadL      ,BusErrorR   ; 90 92 94 96
        dd      ReadL      ,ReadL      ,BusErrorR  ,BusErrorR   ; 98 9A 9C 9E
        dd      BusErrorR  ,DSP_RL     ,BusErrorR  ,BusErrorR   ; A0 A2 A4 A6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; A8 AA AC AE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B0 B2 B4 B6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; B8 BA BC BE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C0 C2 C4 C6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; C8 CA CC CE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D0 D2 D4 D6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; D8 DA DC DE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E0 E2 E4 E6
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; E8 EA EC EE
        dd      BusErrorR  ,BusErrorR  ,BusErrorR  ,BusErrorR   ; F0 F2 F4 F6
        dd      BusErrorR  ,ReadL      ,ACIA_RL    ,BusErrorR   ; F8 FA FC FE
HTabWB:
       rept    64               ; ff00000 - ff8000 -> adresError
        dd      BusErrorW  
       endm
        dd      WriteB     ,Shift_WB   ,BusErrorW  ,WriteB      ; 80 82 84 86
        dd      WriteB     ,Blitter_WB ,WriteB     ,WriteB      ; 88 8A 8C 8E
        dd      BusErrorW  ,WriteB     ,WriteB     ,BusErrorW   ; 90 92 94 96
        dd      WriteB     ,WriteB     ,BusErrorW  ,BusErrorW   ; 98 9A 9C 9E
        dd      BusErrorW  ,DSP_WB     ,BusErrorW  ,BusErrorW   ; A0 A2 A4 A6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; A8 AA AC AE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B0 B2 B4 B6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B8 BA BC BE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C0 C2 C4 C6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C8 CA CC CE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D0 D2 D4 D6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D8 DA DC DE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E0 E2 E4 E6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E8 EA EC EE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; F0 F2 F4 F6
        dd      BusErrorW  ,WriteB     ,ACIA_WB    ,BusErrorW   ; F8 FA FC FE
HTabWW:
       rept    64               ; ff00000 - ff8000 -> adresError
        dd      BusErrorW  
       endm
        dd      WriteW     ,Shift_WW   ,BusErrorW  ,WriteW      ; 80 82 84 86
        dd      WriteW     ,Blitter_WW ,WriteW     ,WriteW      ; 88 8A 8C 8E
        dd      BusErrorW  ,WriteW     ,WriteW     ,BusErrorW   ; 90 92 94 96
        dd      WriteW     ,WriteW     ,BusErrorW  ,BusErrorW   ; 98 9A 9C 9E
        dd      BusErrorW  ,DSP_WW     ,BusErrorW  ,BusErrorW   ; A0 A2 A4 A6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; A8 AA AC AE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B0 B2 B4 B6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B8 BA BC BE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C0 C2 C4 C6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C8 CA CC CE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D0 D2 D4 D6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D8 DA DC DE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E0 E2 E4 E6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E8 EA EC EE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; F0 F2 F4 F6
        dd      BusErrorW  ,WriteW     ,ACIA_WW    ,BusErrorW   ; F8 FA FC FE
HTabWL:
       rept    64               ; ff00000 - ff8000 -> adresError
        dd      BusErrorW  
       endm
        dd      WriteL     ,Shift_WL   ,BusErrorW  ,WriteL      ; 80 82 84 86
        dd      WriteL     ,Blitter_WL ,WriteL     ,WriteL      ; 88 8A 8C 8E
        dd      BusErrorW  ,WriteL     ,WriteL     ,BusErrorW   ; 90 92 94 96
        dd      WriteL     ,WriteL     ,BusErrorW  ,BusErrorW   ; 98 9A 9C 9E
        dd      BusErrorW  ,DSP_WL     ,BusErrorW  ,BusErrorW   ; A0 A2 A4 A6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; A8 AA AC AE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B0 B2 B4 B6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; B8 BA BC BE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C0 C2 C4 C6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; C8 CA CC CE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D0 D2 D4 D6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; D8 DA DC DE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E0 E2 E4 E6
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; E8 EA EC EE
        dd      BusErrorW  ,BusErrorW  ,BusErrorW  ,BusErrorW   ; F0 F2 F4 F6
        dd      BusErrorW  ,WriteL     ,ACIA_WL    ,BusErrorW   ; F8 FA FC FE
