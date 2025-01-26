;---------------------------------------------------------
; PRO-PACK Unpack Source Code - Nintendo Gameboy, Method 2
;
; Copyright [c) 1992 Rob Northen Computing
;
; File: RNC_2.S
;
; Date: 23.03.92
;
; V1.0 - Original
; V1.1 - Optimized by Jeff Frohwein, 99-Jul-25
;        Unpacking is now ~7% faster.
;---------------------------------------------------------

HDLEN	EQU 18

;---------------------------------------------------------
; PRO-PACK Unpack Routine - Gameboy, Method 2
;
; On entry,
;   HL points to PACKED data in ROM
;   DE points to RAM area for the UNPACKED data
; On exit,
;   all general purpose registers are undefined - A,B,C,D,E,H,L.
;   ROM bank not preserved
;---------------------------------------------------------

Unpack:
        LD BC,HDLEN
        ADD HL,BC
        SCF
        LD A,[HL+]      ; NOTE: This data fetch requires that the data
        ADC A,A         ; pointed to by HL is in one ROM bank and that the
        ADD A,A         ; fetch will not cross ROM boundaries.
        JP XLOOP

;---------------------------------------------------------

FETCH3:
        LD A,[hl+]
        ADC A,A
        jr BACK3
FETCH4:
        LD A,[hl+]
        ADC A,A
        jr BACK4
FETCH5:
        LD A,[hl+]
        ADC A,A
        Jr BACK5
FETCH6:
        LD A,[hl+]
        ADC A,A
        Jr BACK6
FETCH7:
        LD A,[hl+]
        ADC A,A
        jr BACK7
RAW:
        LD C,4
X4BITS:
        ADD A,A
        JR Z,FETCH7
BACK7:
        RL B
        DEC C
        JR NZ,X4BITS

        PUSH AF
        LD A,3
        ADD A,B
        ADD A,A
        LD C,A
RAWLPB:
        LD A,[hl+]
        LD [DE],A
        INC DE

        LD A,[hl+]
        LD [DE],A
        INC DE

        DEC C
        JR NZ,RAWLPB

        POP AF
        Jr XLOOP

;---------------------------------------------------------

FETCH0:
        LD A,[hl+]
        ADC A,A
        JR C,SMALLS
GETLEN:
        ADD A,A
        JR Z,FETCH3
BACK3:
        RL C
        ADD A,A
        JR Z,FETCH4
BACK4:
        JR NC,COPY
        ADD A,A
        JR Z,FETCH5
BACK5:
        DEC C
        PUSH HL

        LD H,A
        LD A,C
        ADC A,A
        LD C,A
        CP 9
        LD A,H

        POP HL
        JR Z,RAW

;---------------------------------------------------------

COPY:
        ADD A,A
        JR Z,FETCH6
BACK6:
        JR NC,BYTEDISP
        ADD A,A
        JR NZ,SKIP0
        LD A,[hl+]
        ADC A,A
SKIP0:
        RL B
        ADD A,A
        JR NZ,SKIP1
        LD A,[hl+]
        ADC A,A
SKIP1:
        JR C,BIGDISP
        INC B
        DEC B
        JR NZ,BYTEDISP
        INC B
ANOTHER:
        ADD A,A
        JR NZ,DISPX
        LD A,[hl+]
        ADC A,A
DISPX:
        RL B
BYTEDISP:
        PUSH AF
        LD A,E
        SUB [HL]
        PUSH HL
        LD L,A
        LD A,D
        SBC A,B
        LD H,A
        DEC HL
BYTELP:
        LD A,[hl+]
        LD [DE],A
        INC DE
        DEC C
        JR NZ,BYTELP

        POP HL
        INC HL

        POP AF
        JR XLOOP

;---------------------------------------------------------

GETBITS:
        LD A,[hl+]
        ADC A,A
        JR C,STRING
XBYTE:
        ld b,a          ; Took out 'push af' - JF, 99-Jul-25
        LD A,[hl+]
        LD [DE],A
        INC DE
        ld a,b          ; Took out 'pop af' - JF, 99-Jul-25
XLOOP:
        ADD A,A
        JR C,CHKZ

        ld b,a          ; Took out 'push af' - JF, 99-Jul-25
        LD A,[hl+]
        LD [DE],A
        INC DE
        ld a,b          ; Took out 'pop af' - JF, 99-Jul-25

        ADD A,A
        JR NC,XBYTE
CHKZ:
        JR Z,GETBITS

;---------------------------------------------------------

STRING:
        LD BC,2
        ADD A,A
        JR Z,FETCH0
        JR NC,GETLEN
SMALLS:
        ADD A,A
        JR Z,FETCH1
BACK1:
        JR NC,BYTEDISP

        INC C
        ADD A,A
        JR Z,FETCH2
BACK2:
        JR NC,COPY

        LD C,[HL]
        INC HL
        INC C
        DEC C
        JR Z,OVERNOUT

        PUSH AF

        LD A,C
        ADD A,8
        LD C,A

        POP AF
        Jr COPY

;---------------------------------------------------------

BIGDISP:
        ADD A,A
        JR NZ,SKIP2
        LD A,[hl+]
        ADC A,A
SKIP2:
        RL B
        SET 2,B
        ADD A,A
        JR NZ,SKIP3
        LD A,[hl+]
        ADC A,A
SKIP3:
        JR C,BYTEDISP
        Jr ANOTHER
FETCH1:
        LD A,[hl+]
        ADC A,A
        jr BACK1
FETCH2:
        LD A,[hl+]
        ADC A,A
        jr BACK2
OVERNOUT:
        ADD A,A
        JR NZ,CHECK4END

        LD A,[hl+]
        ADC A,A
CHECK4END:
        JR C,XLOOP
        RET