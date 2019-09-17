*******************
*  Set input mode *
*******************

setmode:  move.w    #33,contrl        * Set input mode
          move.w    #0,contrl+2
          move.w    #2,contrl+6
          move.w    grhandle,contrl+12
          move.w    d0,intin
          move.w    d1,intin+2        * Parameters in D0 and D1
          jsr       vdi
          rts

