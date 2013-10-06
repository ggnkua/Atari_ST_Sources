
;****************************************************************************
;
;   X6502.SH
;
;   - 6502 opcodes and other asm defines
;
;   11/25/88 created
;
;   09/06/93 13:00
;
***************************************************************************

; register definitions of 6502 registers 

; drDATA  D0.w  scratch
; drA     D1.w  accumulator
; drX     D2.w  index X
; drY     D3.w  index Y
; drC     D4.w  carry bit
; drV     D5.w  overflow bit
; drDNZ   D6.l  decimal, negative, zero bits
; drEA    D7.l  effective address register

; arEA    A0 ; pointer to mem[ea] and otherwise all purpose register
; arWSTAT A1 ; pointer to array of write status bytes
; arSP    A2 ; 6502 stack pointer
; arPC    A3 ; 6502 program counter
; arBASE  A4 ; pointer to op00, from which all other addresses are based 
; arEMUL  A5 ; pointer to op00 + offset into opcodes (for interrupts)


; exit codes from interpreter 
EXIT_BREAK      =  0
EXIT_INVALID    =  1
EXIT_ALTKEY     =  2

; opcode for RTS 
OP_RTS  =    $4E75

; status bits of the P register: (6502)  NV_BDIZC 

NBIT = $80
VBIT = $40
BBIT = $10
DBIT = $08
IBIT = $04
ZBIT = $02
CBIT = $01

; status bits of the CCR register: (68000)  ___XNZVC 

BITV = $02
BITN = $08
BITZ = $04
BITC = $01
BITX = $10

iRTS    = 0
iIRQ    = 2
iVBI    = 6
iDLI    = 10
iFX     = 14
iDec    = 16
iBin    = 18


    .abs

bScan:  ds.b    1   ; scan line (0 - 255)
bMode:  ds.b    1   ; ANTIC mode (0 - 15)
uStart: ds.w    1   ; start of screen block (6502 address)
uLen:   ds.w    1   ; length of screen block (6502 bytes)
uEnd:   ds.w    1   ; end of screen block (6502 address)
uChbase: ds.w    1   ; character base (6502 address)
cb:     ds.w    1   ; count of bytes on scan line (8-12, 16-24, 32-48)
pfPlot: ds.l    1   ; pointer to byte plot function
plPtrs: ds.l    1   ; pointer to screen pointers
sizeDL:

    .macro setorg label, offset
    .bytes set (\offset-($-\label))/2
    .assert .bytes >= 0
    .assert .bytes < 128
    .iif .bytes > 0, dcb.w .bytes,$00FF
    .endm

    .macro opinit
.op:
    rts             ; exit due to F5 or trace
;.opIRQ:
    bra     IRQ
;.opVBI:
    bra     NMI
;.opDLI:
    bra     DLI
;.opFX:
    nop
;.opcode:
    .endm

; quickly save and restore 6502 variables 
    .macro  SAVEREGS
    movem.l D0-D7/A0-A5,-(sp)
    .endm

    .macro  LOADREGS
    movem.l (sp)+,D0-D7/A0-A5
    .endm

; finished executing an opcode, go to dispatch routine 
    .macro  dispatch

	.if 1
        move.b  (a3)+,$+6-op00(a4)
        jmp     0(a5)
	.else
        move.b  (a3)+,d0
        lsl.w   #8,d0
        jmp     0(a5,d0.w)
	.endif
    .endm

    .macro unused
;    move.w  #2,_exit_code
;    rts
    dispatch
;    move.b  (a3)+,$+6-op00(a4)
;    jmp     0(a5)
    .endm

; Effective Address calculation macros 

; (zp,X) 44 cycles 
    .macro  EA_zpXind
    clr.w   d7        
    move.b  (a3)+,d7
    add.b   d2,d7    
    move.l  d7,a0   
    movep.w 1(a0),d7 
    move.b  (a0),d7 
    move.l  d7,a0
    .endm

; zp 16 cycles 
    .macro  EA_zp
    clr.w   d7
    move.b  (a3)+,d7
    move.l  d7,a0
    .endm

; same as zp, except used before a LDA to save 4 cycles 
    .macro  EA_Azp
    move.b  (a3)+,d1
    move.l  d1,a0
    .endm

; same as zp, except used before a LDX to save 4 cycles 
    .macro  EA_Xzp
    move.b  (a3)+,d2
    move.l  d2,a0
    .endm

; same as zp, except used before a LDY to save 4 cycles 
    .macro  EA_Yzp
    move.b  (a3)+,d3
    move.l  d3,a0
    .endm

; abs 32 cycles 
    .macro  EA_abs
    movep.w 1(a3),d7 
    move.b  (a3),d7
    addq.w  #2,a3
    move.l  d7,a0
    .endm

; abs,X 36 cycles
    .macro  EA_absX
    movep.w 1(a3),d7 
    move.b  (a3),d7
    addq.w  #2,a3
    add.w   d2,d7
    move.l  d7,a0
    .endm

; abs,Y 36 cycles 
    .macro EA_absY
    movep.w 1(a3),d7 
    move.b  (a3),d7
    addq.w  #2,a3
    add.w   d3,d7
    move.l  d7,a0
    .endm

; (zp),Y 44 cycles 
    .macro  EA_zpYind
    clr.w   d7
    move.b  (a3)+,d7
    move.l  d7,a0
    movep.w 1(a0),d7 
    move.b  (a0),d7
    add.w   d3,d7
    move.l  d7,a0
    .endm

; zp,X 20 cycles 
    .macro  EA_zpX
    clr.w   d7
    move.b  (a3)+,d7
    add.b   d2,d7
    move.l  d7,a0
    .endm

; zp,X 16 cycles, before a LDA 
    .macro  EA_AzpX
    move.b  (a3)+,d1
    add.b   d2,d1
    move.l  d1,a0
    .endm

; zp,Y 20 cycles 
    .macro  EA_zpY
    clr.w   d7
    move.b  (a3)+,d7
    add.b   d3,d7
    move.l  d7,a0
    .endm

    .macro  WriteService
    move.b  0(a1,d7),d0
    bmi.s   .ws
    move.b  d6,(a0)
    dispatch
.ws:
;    move.b  d0,$+8-op00(a4)
;    move.b  d6,d0
;    jmp     $80(a4)
    lsl.w   #8,d0
    move.b  #$80,d0
    pea     0(a4,d0.w)
    move.b  d6,d0
    rts
    .endm

    .macro  WriteAService
    move.b  0(a1,d7),d0
    bmi.s   .was
    move.b  d1,(a0)
    dispatch
.was:
;    move.b  d0,$+8-op00(a4)
;    move.b  d1,d0
;    jmp     $80(a4)
    lsl.w   #8,d0
    move.b  #$80,d0
    pea     0(a4,d0.w)
    move.b  d1,d0
    rts
    .endm

    .macro  WriteXService
    move.b  0(a1,d7),d0
    bmi.s   .wxs
    move.b  d2,(a0)
    dispatch
.wxs:
;    move.b  d0,$+8-op00(a4)
;    move.b  d2,d0
;    jmp     $80(a4)
    lsl.w   #8,d0
    move.b  #$80,d0
    pea     0(a4,d0.w)
    move.b  d2,d0
    rts
    .endm

    .macro WriteYService
    move.b  0(a1,d7),d0
    bmi.s   .wys
    move.b  d3,(a0)
    dispatch
.wys:
;    move.b  d0,$+8-op00(a4)
;    move.b  d3,d0
;    jmp     $80(a4)
    lsl.w   #8,d0
    move.b  #$80,d0
    pea     0(a4,d0.w)
    move.b  d3,d0
    rts
    .endm

    .extern op00, op01, op02, op03, op04, op05, op06, op07
    .extern op08, op09, op0A, op0B, op0C, op0D, op0E, op0F
    .extern op10, op11, op12, op13, op14, op15, op16, op17
    .extern op18, op19, op1A, op1B, op1C, op1D, op1E, op1F
    .extern op20, op21, op22, op23, op24, op25, op26, op27
    .extern op28, op29, op2A, op2B, op2C, op2D, op2E, op2F
    .extern op30, op31, op32, op33, op34, op35, op36, op37
    .extern op38, op39, op3A, op3B, op3C, op3D, op3E, op3F
    .extern op40, op41, op42, op43, op44, op45, op46, op47
    .extern op48, op49, op4A, op4B, op4C, op4D, op4E, op4F
    .extern op50, op51, op52, op53, op54, op55, op56, op57
    .extern op58, op59, op5A, op5B, op5C, op5D, op5E, op5F
    .extern op60, op61, op62, op63, op64, op65, op66, op67
    .extern op68, op69, op6A, op6B, op6C, op6D, op6E, op6F
    .extern op70, op71, op72, op73, op74, op75, op76, op77
    .extern op78, op79, op7A, op7B, op7C, op7D, op7E, op7F
    .extern op80, op81, op82, op83, op84, op85, op86, op87
    .extern op88, op89, op8A, op8B, op8C, op8D, op8E, op8F
    .extern op90, op91, op92, op93, op94, op95, op96, op97
    .extern op98, op99, op9A, op9B, op9C, op9D, op9E, op9F
    .extern opA0, opA1, opA2, opA3, opA4, opA5, opA6, opA7
    .extern opA8, opA9, opAA, opAB, opAC, opAD, opAE, opAF
    .extern opB0, opB1, opB2, opB3, opB4, opB5, opB6, opB7
    .extern opB8, opB9, opBA, opBB, opBC, opBD, opBE, opBF
    .extern opC0, opC1, opC2, opC3, opC4, opC5, opC6, opC7
    .extern opC8, opC9, opCA, opCB, opCC, opCD, opCE, opCF
    .extern opD0, opD1, opD2, opD3, opD4, opD5, opD6, opD7
    .extern opD8, opD9, opDA, opDB, opDC, opDD, opDE, opDF
    .extern opE0, opE1, opE2, opE3, opE4, opE5, opE6, opE7
    .extern opE8, opE9, opEA, opEB, opEC, opED, opEE, opEF
    .extern opF0, opF1, opF2, opF3, opF4, opF5, opF6, opF7
    .extern opF8, opF9, opFA, opFB, opFC, opFD, opFE, opFF

    .extern _rgDL, _lMemory, _lScrPtrs, _lWStat0, _uAtMin, _uAtRAM, _lScr
    .extern _clearDL, _newDL, _Redraw
    .extern _fRedraw, _fIsMono
    .extern rgwRainbow
    
    ; GTIA write locations
    .extern _hposp0, _hposp1, _hposp2, _hposp3
    .extern _hposm0, _hposm1, _hposm2, _hposm3
    .extern _sizep0, _sizep1, _sizep2, _sizep3
    .extern _sizem
    .extern _grafp0, _grafp1, _grafp2, _grafp3, _grafm
    .extern _colpm0, _colpm1, _colpm2, _colpm3
    .extern _colpf0, _colpf1, _colpf2, _colpf3, _colbk
    .extern _vdelay
    .extern _gractl
    .extern _hitclr
    .extern _consol

    ; POKEY write locations
    .extern _audf1, _audc1, _audf2, _audc2    
    .extern _audf3, _audc3, _audf4, _audc4
    .extern _audctl
    .extern _stimer
    .extern _skrest
    .extern _potgo
    .extern _serout
    .extern _irqen
    .extern _skctl

    ; PIA write locations
    .extern _porta, _portb, _pactl, _pbctl

    ; ANTIC write locations
    .extern _dmactl, _chactl
    .extern _dlistl, _dlisth
    .extern _hscrol, _vscrol
    .extern _pmbase, _chbase
    .extern _wsync
    .extern _nmien, _nmires
    

    .extern _ROMC000, _ROMD800, _ROMFAST, _ROME000

