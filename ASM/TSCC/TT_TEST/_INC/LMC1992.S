setlmc1992
          move.w      sr,-(sp)
          move.w      #$2700,sr                           ;interrupts off 
                                                          ;during start of
                                                          ;operation
          move.w      #%11111111111,$ffff8924.w           ;set microwire mask
          move.w      d0,$ffff8922.w
.waitstart
          cmpi.w      #%11111111111,$ffff8924.w           ;wait for microwire
                                                          ;write to start
          beq.s       .waitstart
          move.w      (sp)+,sr                            ;now microwire write
                                                          ;started we can
                                                          ;safely re-enable
                                                          ;interrupts
.waitend
          cmpi.w      #%11111111111,$ffff8924.w           ;wait for microwire 
                                                          ;write to finish
          bne.s       .waitend
          rts
