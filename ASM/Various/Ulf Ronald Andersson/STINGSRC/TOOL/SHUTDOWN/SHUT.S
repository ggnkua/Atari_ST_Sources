
;*********************************************************************
;*                                                                   *
;*     STinG : Shutdown Tool                                         *
;*                                                                   *
;*                                                                   *
;*      Version 1.0                      from 15. December 1997      *
;*                                                                   *
;*********************************************************************


             .export   unlink_vectors            ;" Function for unlinking STinG
             .export   disable_interrupts        ;" Function for forbidding interrupts
             .export   enable_interrupts         ;" Function for allowing interrupts


;-------------------------------------------------------------------------------------)

unlink_vectors:
             movem.l a0-a1, -(sp)                ;" Save CPU registers
             move.w  sr, -(sp)                   ;" Save CPU status
             or.w    #$0700, sr                  ;" Disable all interupts
             lea     $00000114, a0               ;" 200 Hz timer vector address
             bsr     unlink_vec                  ;" Unlink STinG handler
             move.l  d0, -(sp)                   ;" Save return value
             lea     $00000020, a0               ;" PrivVio vector address
             bsr     unlink_vec                  ;" Unlink STinG handler
             or.l    (sp)+, d0                   ;" Combine return values
             move.w  (sp)+, sr                   ;" Restore CPU status
             movem.l (sp)+, a0-a1                ;" Restore CPU registers
             rts

unlink_vec:
             move.l  (a0), a1                    ;" Read vector
             moveq.l #1, d0                      ;" Set status 'Not found'
             cmp.l   #'XBRA', -12(a1)            ;" XBRA identifier ?
             bne     give_up                     ;" No : Does not support XBRA :-(
             cmp.l   #'STNG',  -8(a1)            ;" Is it STinG ?
             beq     found                       ;" Yes : We found it
             lea     -4(a1), a0                  ;" Address old vector as new start
             bra     unlink_vec                  ;" And loop

found:
             clr.l   d0                          ;" Set status 'Found'
             move.l  -4(a1), (a0)                ;" Unlink this XBRA entry
give_up:
             rts

;-------------------------------------------------------------------------------------)

disable_interrupts:
             move.w  sr, stat_reg                ;" Save status register
             or.w    #$0700, sr                  ;" Mask away all interrupts
             rts

enable_interrupts:
             move.w  stat_reg, sr                ;" Restore old interrupt mask
             rts

stat_reg:    ds.w    1                           ;" Storage for status register

;-------------------------------------------------------------------------------------)

             .end
