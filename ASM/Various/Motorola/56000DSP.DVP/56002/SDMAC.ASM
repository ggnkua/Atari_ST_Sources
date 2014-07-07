;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
;single X doubble mac using DP mode of 56002
;*******************************************************************
Ncnt      equ $10
          org     p:$40
          move #$10,r1                 ;; pointer to x lsp
          move #$20,r2                 ;; pointer to x msp
          move #$20,r6                 ;; pointer to y msp (single)
          move #Ncnt,m6                ;; to restore y pointer before second rep
          move #$80,r0                 ;; pointer to products
          clr a #0,y0
          ori #$40,mr                  ;; enter DP mode
 
          move x:(r1)+,x0 y:(r6)+,y1   ;; load y and lsp of x
          rep #Ncnt
          mac  x0,y1,a	x:(r1)+,x0 y:(r6)+,y1        ;; load y and lsp of x
 
          move x:(r2)+,x1 y:(r6)+,y1   ;; load y and lsp of x
          mac  y1,x1,a     a0,x:(r0)+  ;; msp*msp -> a, lsp of result -> x:(r0)+
          andi #$bf,mr                 ;; exit DP mode
 
          move x:(r2)+,x1 y:(r6)+,y1   ;; load y and lsp of x
          rep  #Ncnt-1
          mac  y1,x1,a	x:(r2)+,x1 y:(r6)+,y1        ;; load y and lsp of x
 
          move a,l:(r0)+               ;; result msp
