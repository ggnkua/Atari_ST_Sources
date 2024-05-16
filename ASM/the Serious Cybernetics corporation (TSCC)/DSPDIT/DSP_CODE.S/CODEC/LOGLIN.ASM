;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Companded CODEC to Linear PCM Data Conversion Macros
; 
; Last Update 20 Apr 87   Version 1.0
;
loglin  ident   1,0
;
; These macros convert 8 bit companded data received from CODEC A/D
; converters used in telecommunications applications to 13 bit, linear
; fractional data.  The internal mu/a-law lookup tables in the DSP56001
; X data ROM are used to minimize execution time.  Three companded
; formats are supported for the Motorola MC14400 CODEC series and
; similar devices.
;
; Macro Calls:          smlin - sign magnitude to linear conversion
;                               with mu-law companding.
;                       mulin - mu-law companded to linear conversion.
;                       allin - a-law companded to linear conversion
;                               with CCITT (G7.12) format.
;
;                       No macro arguments are required.  However, these
;                       macros assume that the scaling modes are off
;                       (S1=0, S0=0).
;
; Input data is in the 8 most significant bits of a1.  The remaining
; bits of a are ignored.
;
;  -------------------------------------------------------
; | Sign |    Chord Number    |       Step Number         |
; | Bit  |                    |                           |
; |__23__|__22_____21_____20__|__19_____18_____17_____16__|
;
; Output data is in the 56 bit accumulator a.  The linear fraction is
; in the 13 most significant bits of a1 and the 11 least significant
; bits are zero.
;
; Alters Data ALU Registers
;       x1      x0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 0 locations on System Stack
;
; Latest Revision - April 15, 1987
; Tested and verified - April 20, 1987
;
; smlin - sign magnitude to linear conversion
;
smlin   macro
_shift  equ     $80                     ;shift constant
_mutable        equ     $100            ;base address of mu-law table
;
        not     a       a1,b            ;invert input bits, save input
        lsl     a       #>_shift,x0     ;shift out sign bit, get shift constant
        lsr     a       #_mutable,x1    ;shift in zero, get table base
        tfr     x1,a    a1,x1           ;swap table base and offset
        mac     x1,x0,a                 ;shift offset down and add to base
        move            a,r0            ;move to address register
        nop
        lsl     b       x:(r0),a        ;c=sign bit, lookup linear data
        neg     a       a,b             ;a=negative result, b=positive result
        tcs     b,a                     ;if pos sign, correct result
        endm
;
; mulin - mu-law to linear conversion
;
mulin   macro
_shift  equ     $80                     ;shift constant
_mutable        equ     $100            ;base address of mu-law table
;
        move            a1,b            ;save input
        lsl     a       #>_shift,x0     ;shift out sign bit, get shift constant
        lsr     a       #_mutable,x1    ;shift in zero, get table base
        tfr     x1,a    a1,x1           ;swap table base and offset
        mac     x1,x0,a                 ;shift offset down and add to base
        move            a,r0            ;move to address register
        nop
        lsl     b       x:(r0),a        ;c=sign bit, lookup linear data
        neg     a       a,b             ;a=negative result, b=positive result
        tcs     b,a                     ;if pos sign, correct result
        endm
;
; allin - a-law to linear conversion
;
allin   macro
_shift  equ     $80                     ;shift constant
_atable equ     $180                    ;base address of a-law table
;
        move            a1,b            ;save input
        lsl     a       #>_shift,x0     ;shift out sign bit, get shift constant
        lsr     a       #_atable,x1     ;shift in zero, get table base
        tfr     x1,a    a1,x1           ;swap table base and offset
        mac     x1,x0,a                 ;shift offset down and add to base
        move            a,r0            ;move to address register
        nop
        lsl     b       x:(r0),a        ;c=sign bit, lookup linear data
        neg     a       a,b             ;a=negative result, b=positive result
        tcs     b,a                     ;if positive sign, correct result
        endm
