;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 24 Sep 87   Version 1.1 
;
; Sorting by Heapsort method
;
sort2   macro   ARRAY,N_ITEMS   
sort2   ident   1,1

;
; reference: Niklaus Writh, "Algorithms + Data Structures = Programs", 
;            Prentice-Hall, 1976, Program 2.8, page 75
;
; ARRAY = location of an array of numbers in X memory space, 
;         first item is located at ARRAY.
; N_ITEMS = number of items in the array
;
; registers used: r0..r4
;                 a,b,y1,x0,x1
;                 assumes m0..m4 = $ffff
;                 uses 3 words of stack 
;
;
        move    #ARRAY-1,b                      ; constant
        move    #>(N_ITEMS/2)+ARRAY,r0          ;r0=l
        move    #>ARRAY+N_ITEMS-1,r1            ;r1=r
        move    r1,y1

        do      #N_ITEMS/2,_wend1
        move                    (r0)-
        jsr     _sift          
_wend1


        do      #N_ITEMS-1,_wend2
        move    x:ARRAY,x1                      ;x1=x
        move    x:(r1),x0
        move    x0,x:ARRAY
        move    x1,x:(r1)- 
        move    r1,y1   
        jsr     _sift
_wend2  jmp     _end

;
; sift
; 
_sift   move    r0,r3                           ;"i"=l
        move    x:(r0),x1                       ;x=a("i")
_loop3  move    r3,a                            ;a="i"
        subl    b,a     r3,r2                   ;a = 2*i-array, i="i"=j
        move    a,r3
        cmp     y1,a    r3,r4                   ;j-r
        jgt     _wend3
;if j<r
        move    x:(r3)+,x0                      ;a(j)
        jeq     _t1                             ;if j<r
;if a(j)<a(j+1)
        move    x:(r3),a                        ;a(j+1)
        cmp     x0,a                            ;a(j)-a(j+1)
_t1     tle     x0,a    r4,r3
        cmp     x1,a                            ;a(j)-x
        jle     _t13
        move    a,x:(r2)                        ;a(i)=a(j)
        jmp     _loop3
_wend3
_t13    move    x1,x:(r2)                       ;a(i)=x
        rts
_end
        endm


