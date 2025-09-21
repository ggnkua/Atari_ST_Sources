                EXPORT  fsel_input, fsel_exinput
                IMPORT  aes, global, addrin

fsel_exinput:   cmp.w   #$140,global            ;AES-Version >= 1.4?
                blo.b   fsel_input              ;Nein, normaler Aufruf
                move.l  8(A7),addrin+8          ;label
                move.l  #$5B000203,D0
                bra.b   fsel_2ai1io
fsel_input:     move.l  #$5A000202,D0
fsel_2ai1io:    movem.l A0/A1,addrin            ;inpath, insel
                bsr     aes
                move.l  4(A7),A1
                move.w  (A0),(A1)               ;exbutton zurÅckgeben
                rts


