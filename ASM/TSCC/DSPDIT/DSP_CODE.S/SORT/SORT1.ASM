;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 11 Sep 87   Version 1.0
;
; Sorting by Straight Selection
;
sort1   macro   ARRAY,N_ITEMS   
sort1   ident   1,1

; reference: Niklaus Writh, "Algorithms + Data Structures = Programs", 
;            Prentice-Hall, 1976, Program 2.3, page 64
;
; ARRAY = location of an array of numbers in X memory space, 
;         first item is located at ARRAY.
; N_ITEMS = number of items in the array
;
; register usage:
;       r0=(j)          r1=(k)          r2=(i)
;       r4=j'           n1=-2 offset
;       a=x             b       
;       y0              
;       uses 4 words of stack
;       assumes m0..m2 = $ffff
;
        move            #N_ITEMS,r4        
        move            #ARRAY,r2
        move            #-2,n1  

        do      #N_ITEMS-1,_loop2
        lua     (r2)+,r0
        move    x:(r2),a        y:(r4)-,b
        move    x:(r0)+,b 
        move    r0,r1

        do      r4,_loop1
        cmp     b,a     x:(r0)+,b       b,y0
        tge     y0,a    r0,r1
_loop1
        move    x:(r2),y0
        move    a,x:(r2)+
        move    y0,x:(r1+n1)
_loop2
        endm

