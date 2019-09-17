;Set Position of Mouse Pointer
;ENTRY: Stack = X Position in Unsigned Word
;               Y Position in Unsigned Word
;               return address in Long
;EXIT:  Mouse pointer moved to position requested
;       REMEMBER to add 4 to stack pointer upon return
;USES:  d0-d2/a0-a2

                TEXT
Set_Mouse_XY    dc.w    $a00a           ;hide mouse (if not already hidden)
                dc.w    $a000           ;a0 contains LineA table pointer
                move.w  6(sp),-$25a(a0) ;move mouse
                move.w  4(sp),-$258(a0)
                move.l  8(a0),a0        ;pointer to INTIN
                move.w  #1,(a0)         ;only show mouse to one level
                dc.w    $a009           ;show mouse (if not previously hidden)          
                rts
                
