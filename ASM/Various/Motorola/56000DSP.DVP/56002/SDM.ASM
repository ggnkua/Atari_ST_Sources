;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
;single X doubble multiplication using DP mode of 56K core
;*******************************************************************
 
          org     p:$40
          move #$10,r1                 ;; pointer to x lsp
          move #$20,r2                 ;; pointer to x msp
          move #$20,r6                 ;; pointer to y msp (single)
          move #$80,r0                 ;; pointer to products
; x*y  x is 48-bit, y is 24 bit data
;          clr a #0,y0
          ori #$40,mr                  ;enter DP mode
          move #$787654,x0             ;x0=lsp of x=0.9411111
          move #>$1,x1                  ;x1=msp of x
          move #$7dfe45,y1             ;y1=y=0.9843222
          mac  x0,y1,a                 ;a=lspx*y
          mac  y1,x1,a     a0,x:(r0)+  ;mspx*y+(lspx*y)>>24,save lsp of result to x
          move a,l:(r0)               ;; result msp
          andi #$bf,mr                 ;; exit DP mode
