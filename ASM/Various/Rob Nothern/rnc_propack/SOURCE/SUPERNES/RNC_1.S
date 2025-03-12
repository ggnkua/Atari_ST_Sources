;---------------------------------------------------------
; PRO-PACK Unpack Source Code - Super NES, Method 1
;
; Copyright (c) 1992 Rob Northen Computing
;
; File: RNC_1.S
;
; Date: 9.03.92
;---------------------------------------------------------

;---------------------------------------------------------
; Unpack Routine - Super NES, Method 1
;
; To unpack a packed file (in any data bank) to an output
; buffer (in any data bank) Note: the packed and unpacked
; files are limited to 65536 bytes in length.
;
; To call (assumes 16-bit accumulator)
;
;   PEA pack_file&$FFFF     ; push low word of packed file
;   PEA ^pack_file          ; push high word of packed file
;   PEA destn_buf&$FFFF     ; push low word of output buffer
;   PEA ^destn_buf          ; push high word of output buffer
;   JSL UNPACK              ; unpack file to output buffer
;   PLA
;   PLA
;   PLA
;   PLA
;
; On exit,
;
; A, X, Y undefined, M=0, X=0
;---------------------------------------------------------

;---------------------------------------------------------
; Equates
;---------------------------------------------------------

BUFF1   EQU $               ; 16-bit address of $21 byte z-page buffer
BUFF2   EQU $               ; 24-bit address of $1A0 byte buffer

IN      EQU BUFF1
OUT     EQU IN+4
WRKBUF  EQU OUT+2
COUNTS  EQU WRKBUF+3
BLOCKS  EQU COUNTS+2
BITBUFL EQU BLOCKS+2
BITBUFH EQU BITBUFL+2
BUFBITS EQU BITBUFH+2
BITLEN  EQU BUFBITS+2
HUFCDE  EQU BITLEN+2
HUFBSE  EQU HUFCDE+2
TEMP1   EQU HUFBSE+2
TEMP2   EQU TEMP1+2
TEMP3   EQU TEMP2+2
TEMP4   EQU TEMP3+2

TMPTAB  EQU 0               ; indexed from BUFF2
RAWTAB  EQU TMPTAB+$20      ; indexed from BUFF2
POSTAB  EQU RAWTAB+$80      ; indexed from BUFF2
SLNTAB  EQU POSTAB+$80      ; indexed from BUFF2

;---------------------------------------------------------

UNPACK
        REP $39             ; 16-bit AXY, clear D and C
        LDA 6,S             ; read low word of output address
        STA OUT
        LDA 8,S             ; read high word of packed file
        STA IN+2
        LDA 10,S            ; read low word of packed file
        STA IN

        LDA 4,S
        PHB                 ; save current data bank
        XBA
        PHA                 ; push 2 bytes
        PLB                 ; 0
        PLB                 ; make output buffer default data bank
        LDA #BUFF2&$FFFF
        STA WRKBUF
        LDA #^BUFF2
        STA WRKBUF+2

        LDA #17
        ADC IN
        STA IN
        LDA [IN]
        AND #$FF
        STA BLOCKS
        INC IN
        LDA [IN]
        STA BITBUFL
        STZ BUFBITS
        LDA #2
        JSR GTBITS

UNPACK2
        LDY #RAWTAB
        JSR MAKEHUFF
        LDY #POSTAB
        JSR MAKEHUFF
        LDY #SLNTAB
        JSR MAKEHUFF
        LDA #16
        JSR GTBITS
        STA COUNTS
        JMP UNPACK8

UNPACK3
        LDY #POSTAB
        JSR GTVAL
        STA TEMP2
        LDA OUT
        CLC
        SBC TEMP2
        STA TEMP3
        LDY #SLNTAB
        JSR GTVAL
        INC A
        INC A
        LSR A
        TAX
        LDY #0
        LDA TEMP2
        BNE UNPACK5
        SEP $20             ; 8-bit accumulator
        LDA (TEMP3),Y
        XBA
        LDA (TEMP3),Y
        REP $20             ; 16-bit accumulator
UNPACK4
        STA (OUT),Y
        INY
        INY
        DEX
        BNE UNPACK4
        BRA UNPACK6
UNPACK5
        LDA (TEMP3),Y
        STA (OUT),Y
        INY
        INY
        DEX
        BNE UNPACK5
UNPACK6
        BCC UNPACK7
        SEP $20             ; 8-bit accumulator
        LDA (TEMP3),Y
        STA (OUT),Y
        INY
        REP $21             ; 16-bit accumulator, clear carry
UNPACK7
        TYA
        ADC OUT
        STA OUT

UNPACK8
        LDY #RAWTAB
        JSR GTVAL
        TAX
        BEQ UNPACK14
        LDY #0
        LSR A
        BEQ UNPACK10
        TAX
UNPACK9
        LDA [IN],Y
        STA (OUT),Y
        INY
        INY
        DEX
        BNE UNPACK9
UNPACK10
        BCC UNPACK11
        SEP $20         ; 8-bit accumulator
        LDA [IN],Y
        STA (OUT),Y
        REP $21         ; 16-bit accumulator, clear carry
        INY
UNPACK11
        TYA
        ADC IN
        STA IN
        TYA
        ADC OUT
        STA OUT
        STZ BITBUFH
        LDA BUFBITS
        TAY
        ASL A
        TAX
        LDA [IN]
        CPY #0
        BEQ UNPACK13
UNPACK12
        ASL A
        ROL BITBUFH
        DEY
        BNE UNPACK12
UNPACK13
        STA TEMP1
        LDA >MSKTAB,X
        AND BITBUFL
        ORA TEMP1
        STA BITBUFL
UNPACK14
        DEC COUNTS
        BEQ @1
        JMP UNPACK3
@1
        DEC BLOCKS
        BEQ @2
        JMP UNPACK2
@2
        PLB                 ; restore old data bank
        RTL

;-----------------------------------------------------------

GTVAL
        LDX BITBUFL
        BRA GTVAL3
GTVAL2
        INY
        INY
GTVAL3
        TXA
        AND [WRKBUF],Y
        INY
        INY
        CMP [WRKBUF],Y
        BNE GTVAL2
        TYA
        ADC #(15*4+1)
        TAY
        LDA [WRKBUF],Y
        PHA
        XBA
        AND #$FF
        JSR GTBITS
        PLA
        AND #$FF
        CMP #2
        BCC GTVAL4
        DEC A
        ASL A
        PHA
        LSR A
        JSR GTBITS
        PLX
        ORA >BITTAB,X
GTVAL4
        RTS

BITTAB
        DW  1
        DW  2
        DW  4
        DW  8
        DW  $10
        DW  $20
        DW  $40
        DW  $80
        DW  $100
        DW  $200
        DW  $400
        DW  $800
        DW  $1000
        DW  $2000
        DW  $4000
        DW  $8000

;-----------------------------------------------------------

GTBITS
        TAY
        ASL A
        TAX
        LDA >MSKTAB,X
        AND BITBUFL
        PHA
        LDA BITBUFH
        LDX BUFBITS
        BEQ GTBITS3
GTBITS2
        LSR A
        ROR BITBUFL
        DEY
        BEQ GTBITS4
        DEX
        BEQ GTBITS3
        LSR A
        ROR BITBUFL
        DEY
        BEQ GTBITS4
        DEX
        BNE GTBITS2
GTBITS3
        INC IN
        INC IN
        LDA [IN]
        LDX #16
        BRA GTBITS2
GTBITS4
        DEX
        STX BUFBITS
        STA BITBUFH
        PLA
GTBITS5
        RTS

MSKTAB
        DW  0
        DW  1
        DW  3
        DW  7
        DW  $F
        DW  $1F
        DW  $3F
        DW  $7F
        DW  $FF
        DW  $1FF
        DW  $3FF
        DW  $7FF
        DW  $FFF
        DW  $1FFF
        DW  $3FFF
        DW  $7FFF
        DW  $FFFF

;-----------------------------------------------------------

MAKEHUFF
        STY TEMP4
        LDA #5
        JSR GTBITS
        BEQ GTBITS5
        STA TEMP1
        STA TEMP2
        LDY #0
MAKEHUFF2
        PHY
        LDA #4
        JSR GTBITS
        PLY
        STA [WRKBUF],Y
        INY
        INY
        DEC TEMP2
        BNE MAKEHUFF2
        STZ HUFCDE
        LDA #$8000
        STA HUFBSE
        LDA #1
        STA BITLEN
MAKEHUFF3
        LDA BITLEN
        LDX TEMP1
        LDY #0
MAKEHUFF4
        CMP [WRKBUF],Y
        BNE MAKEHUFF8
        PHX
        STY TEMP3
        ASL A
        TAX
        LDA >MSKTAB,X
        LDY TEMP4
        STA [WRKBUF],Y
        INY
        INY
        LDA #16
        SEC
        SBC BITLEN
        PHA
        LDA HUFCDE
        STA TEMP2
        LDX BITLEN
MAKEHUFF5
        ASL TEMP2
        ROR A
        DEX
        BNE MAKEHUFF5
        PLX
        BEQ MAKEHUFF7
MAKEHUFF6
        LSR A
        DEX
        BNE MAKEHUFF6
MAKEHUFF7
        STA [WRKBUF],Y
        INY
        INY
        STY TEMP4
        TYA
        CLC
        ADC #(15*4)
        TAY
        LDA BITLEN
        XBA
        SEP $20             ; 8-bit accumulator
        LDA TEMP3
        LSR A
        REP $21             ; 16-bit accumulator, clear carry
        STA [WRKBUF],Y
        LDA HUFBSE
        ADC HUFCDE
        STA HUFCDE
        LDA BITLEN
        LDY TEMP3
        PLX
MAKEHUFF8
        INY
        INY
        DEX
        BNE MAKEHUFF4
        LSR HUFBSE
        INC BITLEN
        CMP #16
        BNE MAKEHUFF3
        RTS

