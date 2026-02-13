* BASE
        move.l   4(sp),a4        ;Adresse Base Page
        move     $80(a4),-(sp)
        pea      buffer
        bsr      bindec
        pea      buffer
        move     #9,-(sp)
        trap     #1
        add.l    #6,sp
        lea      $81(a4),a4      ;Adresse Kommando
         
loop    move.b   (a4)+,d2        ;hole ein Byte
        move     d2,-(sp)        ;drucke via CONOUT
        move     #2,-(sp)
        trap     #1
        addq.l   #4,sp
        cmpi.b   #13,d2          ;war es CR?
        bne      loop            ;nein, weiter

        move     #1,-(sp)        ;warte auf Taste
        trap     #1
        addq.l   #2,sp
        clr      -(sp)           ;und zum Desktop
        trap     #1
        include  "bindec.s"
        bss
buffer  ds.w     3
        end


