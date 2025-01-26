;---------------------------------------------------------
; PRO-PACK Unpack Source Code - Super NES, Method 2
;
; Copyright (c) 1992 Rob Northen Computing
;
; File: RNC_2.S
;
; Date: 04.03.92
;---------------------------------------------------------

;---------------------------------------------------------
; Unpack Routine - Super NES, Method 2
; (enhancement by Robert Trevellyan)
;
; To unpack a packed file (in any data bank) to an output
; buffer (in any data bank) Note: the packed and unpacked
; files are limited to 65536 bytes in length.
;
; To call (assumes 16 bit accumulator, X and Y),
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
; registers A, X, Y are undefined, status bits M=0, X=0
;---------------------------------------------------------

;---------------------------------------------------------
; Zero-Page Addresses
;---------------------------------------------------------

IN      EQU     $           ; long address of packed file    (4 bytes)
OUT     EQU     IN+4        ; short address of output buffer (2 bytes)
SPOS    EQU     OUT+2       ; (3 bytes)
SLEN    EQU     SPOS+3      ; (2 bytes)

;---------------------------------------------------------
; Macros
;---------------------------------------------------------

RELOAD  MACRO
        LDA [IN],Y
        INY
        ROL A
        ENDM

GETBIT  MACRO
        ASL A
        ENDM

GETRAW  MACRO
        LDA [IN],Y
        STA (OUT)
        INY
        INC OUT
        BNE @\@
        INC OUT+1
@\@
        ENDM

;---------------------------------------------------------

UNPACK
        REP $38             ; 16-bit AXY, clear decimal flag
        LDA 6,S             ; read low word of output address
        STA OUT
        LDA 8,S             ; read high word of packed file
        STA IN+2
        LDA 10,S            ; read low word of packed file
        STA IN

        SEP $21             ; 8-bit accumulator, set carry flag
        LDA 4,S             ; read high word of output address
        PHB                 ; save current data bank
        PHA
        PLB                 ; make output buffer default data bank
        STZ SPOS+2
        STZ SLEN+1
        LDX #0
        LDY #18             ; skip 18 byte pack header
        RELOAD
        GETBIT
        JMP XLOOP

;---------------------------------------------------------

FETCH0
        RELOAD
        BRA BACK0

RAW
        LDX #4
X4BITS
        GETBIT
        BEQ FETCH0
BACK0
        ROL SPOS+1
        DEX
        BNE X4BITS
        LDX SPOS+1
        INX
        INX
        INX
        PHA
        REP $20             ; 16-bit accumulator
        TYA
        ADC IN
        STA IN
        LDY #0
RAWLP
        LDA [IN],Y
        STA (OUT),Y
        INY
        INY
        LDA [IN],Y
        STA (OUT),Y
        INY
        INY
        DEX
        BNE RAWLP
        TYA
        ADC OUT
        STA OUT
        SEP $20             ; 8-bit accumulator
        PLA
        JMP XLOOP

;---------------------------------------------------------

FETCH1
        RELOAD
        BRA BACK1
FETCH2
        RELOAD
        BRA BACK2
FETCH3
        RELOAD
        BRA BACK3
FETCH4
        RELOAD
        BRA BACK4
FETCH5
        RELOAD
        BRA BACK5
FETCH6
        RELOAD
        BRA BACK6
FETCH7
        RELOAD
        BRA BACK7

GTLEN
        GETBIT
        BEQ FETCH1
BACK1
        ROL SLEN
        GETBIT
        BEQ FETCH2
BACK2
        BCC COPY
        GETBIT
        BEQ FETCH3
BACK3
        DEC SLEN
        ROL SLEN
        LDX SLEN
        CPX #9
        BEQ RAW
        LDX #0

;---------------------------------------------------------

COPY
        GETBIT
        BEQ FETCH4
BACK4
        BCC BYTEDISP
        GETBIT
        BEQ FETCH5
BACK5
        ROL SPOS+1
        GETBIT
        BEQ FETCH6
BACK6
        BCC @1
        JMP BIGDISP
@1
        CPX SPOS+1
        BNE BYTEDISP
        INC SPOS+1
ANOTHER
        GETBIT
        BEQ FETCH7
BACK7
        ROL SPOS+1
BYTEDISP
        PHA
        LDA [IN],Y
        STA SPOS
        INY
        PHY
        REP $21             ; 16-bit accumulator, clear carry
        LDA SPOS
        PHA
        LDA OUT
        SBC SPOS
        STA SPOS
        LDY #0
        LSR SLEN
        LDX SLEN
        PLA
        BNE BYTEDISP3
        SEP $20             ; 8-bit accumulator
        LDA (SPOS),Y
        XBA
        LDA (SPOS),Y
        REP $20             ; 16-bit accumulator
BYTEDISP2
        STA (OUT),Y
        INY
        INY
        DEX
        BNE BYTEDISP2
        BRA BYTEDISP4
BYTEDISP3
        LDA (SPOS),Y
        STA (OUT),Y
        INY
        INY
        DEX
        BNE BYTEDISP3
BYTEDISP4
        SEP $20             ; 8-bit accumulator
        BCC BYTEDISP5
        LDA (SPOS),Y
        STA (OUT),Y
BYTEDISP5
        TYA
        ADC OUT
        STA OUT
        BCC @1
        INC OUT+1
@1
        PLY
        PLA
        BRA XLOOP

;---------------------------------------------------------

GTBITS
        RELOAD
        BCS STRING
XBYTE
        XBA
        GETRAW
        XBA
XLOOP
        GETBIT
        BCS CHKZ
        XBA
        GETRAW
        XBA
        GETBIT
        BCC XBYTE
CHKZ
        BEQ GTBITS

;---------------------------------------------------------

STRING
        STZ SPOS+1
        STZ SLEN
        INC SLEN
        INC SLEN
        GETBIT
        BEQ FETCH8
BACK8
        BCS SMALLS
        JMP GTLEN
SMALLS
        GETBIT
        BEQ FETCH9
BACK9
        BCS @1
        JMP BYTEDISP
@1
        INC SLEN
        GETBIT
        BEQ FETCH10
BACK10
        BCS @1
        JMP COPY
@1
        XBA
        LDA [IN],Y
        STA SLEN
        XBA
        INY
        CPX SLEN
        BEQ OVERNOUT
        XBA
        LDA SLEN
        CLC
        ADC #8
        STA SLEN
        XBA
        JMP COPY
BIGDISP
        GETBIT
        BEQ FETCH11
BACK11
        XBA
        LDA SPOS+1
        ROL A
        ORA #4
        STA SPOS+1
        XBA
        GETBIT
        BEQ FETCH12
BACK12
        BCC @1
        JMP BYTEDISP
@1
        JMP ANOTHER
FETCH8
        RELOAD
        BRA BACK8
FETCH9
        RELOAD
        BRA BACK9
FETCH10
        RELOAD
        BRA BACK10
FETCH11
        RELOAD
        BRA BACK11
FETCH12
        RELOAD
        BRA BACK12
OVERNOUT
        GETBIT
        BNE CHECK4END
        RELOAD
CHECK4END
        BCC @1
        JMP XLOOP
@1
        PLB                 ; restore old data bank
        REP $30             ; 16-bit AXY
        RTL

