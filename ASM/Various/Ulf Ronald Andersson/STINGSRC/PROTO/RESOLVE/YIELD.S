
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : DNS Resolver                           */
/*                                                                   */
/*      Version 1.0                      from 13. January 1997       */
/*                                                                   */
/*********************************************************************/


            .export   _appl_yield                ;" Function for AES task switch

            .export   wait_flag                  ;" Function for waiting for semaphore
            .export   rel_flag                   ;" Function for releasing semaphore


;-------------------------------------------------------------------------------------)

_appl_yield:
            move.w  #$c9, d0                     ;" Opcode for _appl_yield
            trap    #2                           ;" Call GEM dispatcher
            rts

;-------------------------------------------------------------------------------------)

wait_flag:
            tas     (a0)                         ;" Test semaphor, and set bit 7
            bne     wait_flag                    ;" Was set ? Then loop
            or.b    #$ff, (a0)                   ;" Now the lock is ours
            rts

rel_flag:
            clr.b   (a0)                         ;" Clear semaphor
            rts

;-------------------------------------------------------------------------------------)

            .end
