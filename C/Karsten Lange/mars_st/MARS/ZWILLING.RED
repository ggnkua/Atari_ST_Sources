;Zwilling 

dat1            dat     0
dat2            dat     99
start           mov     @dat1   @dat2
                add     #1      dat1
                add     #1      dat2
                cmp     dat1    #9
                jmp     start
                mov     #99     94
                jmp     94
