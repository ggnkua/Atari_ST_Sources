;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
; sort2t.asm - test program to sort a list of numbers
; by Heapsort method (most efficient for larger arrays)
; 
; Last Update 16 Sep 87   Version 1.0
;
;

        page    132,66,3,3
        opt     nomd,mex,cre,cex,mu,rc


        include 'sort2.asm'

; sort this list of items in x memory space
        org     x:$0
LIST    dc      44,55,12,42,94,18,06,67

; main program to call SORT2 macro

        org     p:$40
        sort2   LIST,8          ;sort the list of 8 items

        end

