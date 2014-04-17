;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Binary-to-Gray Code Conversion Macro
; 
; Last Update 30 Mar 87   Version 1.0
;
bingray macro
bingray ident   1,0
;
;       This macro converts a binary value in register A1 to a GRAY coded
;   number in A1.  Register X0 is used as a temporary register.
;
        lsr     a  a1,x0        ;shift bits, copy a
        eor     x0,a            ;xor adjacent bits to do gray code
        endm
