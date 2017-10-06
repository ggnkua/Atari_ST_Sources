;MICE
PTR     DAT    0
START   MOV    #12    PTR
LOOP    MOV    @PTR   <5
        DJN    LOOP   PTR
        SPL    @3
        ADD    #653   2
        JMZ    -5     -6
        DAT    833
END
