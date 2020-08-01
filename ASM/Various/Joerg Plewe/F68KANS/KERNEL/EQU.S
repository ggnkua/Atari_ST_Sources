*****************************************************************

*       for codegeneration during runtime:
jmp_code        EQU $4EFC
jsr_code        EQU $4EAA       ;jsr    off(seg)
jsrSB_code      EQU $4EAD       ;jsr    off(SB)
move_seg_code   EQU $246B       ;move.l off(DT),seg
rts_code        EQU $4E75
bsr_code        EQU $6100
bsrb_code       EQU $61
movesp_anull    EQU $205F
moveimm_sp      EQU $2D3C



BKSP            EQU $08
CR              EQU 13

*headsize        EQU 10
of              EQU $8000       ;half a code segment
bytesperblock   EQU 2000

* Constants for header:
headsize		EQU	8
cfaoffset 		EQU 0
lfaoffset		EQU 4
nameoffset		EQU 8


localcodesize	EQU $10


