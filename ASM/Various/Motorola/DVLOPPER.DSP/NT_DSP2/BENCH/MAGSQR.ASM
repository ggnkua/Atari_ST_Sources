;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
magsqr macro
magsqr ident   1,0
;
; MAGSQR Magnitude Squared Macro
;
; x1 = real input
; x0 = imaginary input
; a  = real*real + imag*imag   (unrounded, double precision output)
;
magsqr  mpy     x0,x0,a         x1,x0   ;imag*imag
        mac     x0,x0,a                 ;+real*real
        endm
