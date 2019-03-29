        clr.l -(sp)
        move #$20,-(sp)
        trap #1                              Supervisor mode
        move.l d0,2(sp)                      Save the user stack
        
        bsr muzak                            Init.muzak
        
        move.l #muzak+8,$4d2.w               Play muzak
        
... Insert your program here ...

        clr.l $4d2.w                         Stop muzak
        bsr muzak+4                          Cut resident-sounds
        
        trap #1                              User mode
        addq.l #6,sp
        
... Insert the end of your program here ( PTERM0, Chaining,... ) ...

muzak	incbin dedicace.thk