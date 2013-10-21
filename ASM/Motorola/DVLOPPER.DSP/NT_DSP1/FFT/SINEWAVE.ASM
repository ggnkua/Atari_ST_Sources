;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Full-Cycle Sinewave Table Generator Macro.
; 
; Last Update 25 Nov 86   Version 1.1
;
sinewave        macro   points
sinewave        ident   1,1
;
;       sinewave - macro to generate a full cycle sinewave table.
;               If points = 256 and sinewave is ORGed at Y:$100,
;               the sinewave table generated is identical to the
;               DSP56001 Y Data ROM contents.  Note that the base
;               address and memory space must be specified before
;               the macro is called.
;
;       points - number of points (1 - 65536)
;
; Latest revision - 25-Nov-86
;
pi      equ     3.141592654
freq    equ     2.0*pi/@cvf(points)

count   set     0
        dup     points
        dc      @sin(@cvf(count)*freq)
count   set     count+1
        endm

        endm    ;end of sinewave macro
