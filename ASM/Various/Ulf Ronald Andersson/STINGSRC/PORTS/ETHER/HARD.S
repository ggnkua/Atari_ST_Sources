
;*********************************************************************
;*                                                                   *
;*     Low Level Port : EtherNet Network Interface                   *
;*                                                                   *
;*                                                                   *
;*      Version 1.0                     from 28. September 1997      *
;*                                                                   *
;*      Module for assembler subroutines                             *
;*                                                                   *
;*********************************************************************


             .export   check_hardware            ;" Function for checking presence
             .import   rdp, rap                  ;" LANCE register addresses
             .import   memory                    ;" Etherhardware memory address
             .export   cache_on                  ;" Function for switching Caches on
             .export   cache_off                 ;" Function for switching Caches off
             .import   _cpu                      ;" Code specifies CPU type
             .export   bus_error                 ;" Catch and exit of bus errors
             .export   berr_off                  ;" Do not catch bus errors anymore


;-------------------------------------------------------------------------------------)

bus_vec      =         $0008

check_hardware:
             move.w    sr, d0                    ;" Get CPU status
             or.w      #$0700, sr                ;" Disable all interrupts
             move.w    d0, status                ;" Save status word
             move.l    sp, stack                 ;" Save stack pointer
             move.l    bus_vec, saved_bus        ;" Save bus error vector
             move.l    #failure, bus_vec         ;" Install bus error handler
             clr.l     d0                        ;" Preset hardware not okay

             move.l    rap, a0                   ;" Address of LANCE address register
             move.w    #0, (a0)                  ;" Select LANCE register CSR0
             move.l    rdp, a0                   ;" Address of LANCE data register
             move.w    #4, (a0)                  ;" Set STOP bit
             move.w    (a0), d0                  ;" Reread LANCE register CSR0

             move.l    memory, a0                ;" Fetch address of supposed memory
             move.w    (a0), d0                  ;" Save contents of word
             move.w    #$affe, (a0)              ;" Write test word
             cmp.w     #$affe, (a0)              ;" Test word okay ?
             bne       failure                   ;" No : Exit (No RAM there)
             move.w    d0, (a0)                  ;" Restore old contents
             add.l     #$4000, a0                ;" Next location to be checked
             move.w    (a0), d0                  ;" Save contents of word
             move.w    #$affe, (a0)              ;" Write test word
             cmp.w     #$affe, (a0)              ;" Test word okay ?
             bne       failure                   ;" No : Exit (No RAM there)
             move.w    d0, (a0)                  ;" Restore old contents
             add.l     #$4000, a0                ;" Next location to be checked
             move.w    (a0), d0                  ;" Save contents of word
             move.w    #$affe, (a0)              ;" Write test word
             cmp.w     #$affe, (a0)              ;" Test word okay ?
             bne       failure                   ;" No : Exit (No RAM there)
             move.w    d0, (a0)                  ;" Restore old contents
             add.l     #$4000, a0                ;" Next location to be checked
             move.w    (a0), d0                  ;" Save contents of word
             move.w    #$affe, (a0)              ;" Write test word
             cmp.w     #$affe, (a0)              ;" Test word okay ?
             bne       failure                   ;" No : Exit (No RAM there)
             move.w    d0, (a0)                  ;" Restore old contents

             moveq.l   #1, d0                    ;" Hardware okay
failure:
             move.l    saved_bus, bus_vec        ;" Restore bus error vector
             move.l    stack, sp                 ;" Restore stack pointer
             move.w    status, sr                ;" Restore status word
             rts

status:      ds.w      1                         ;" Saved CPU status
stack:       ds.l      1                         ;" Saved stack pointer
saved_bus:   ds.l      1                         ;" Saved bus error vector

;-------------------------------------------------------------------------------------)

cache_on:
             tst.l     _cpu                      ;" Are we run by a 68020 or bigger ?
             beq       skp_on                    ;" No : Skip Cache handling
             movec     cacr, d0                  ;" Fetch Cache Control Register
             or.w      #$0101, d0                ;" Enable Data and Instruction Cache
             movec     d0, cacr                  ;" Set new Cache Control Register
skp_on:      nop                                 ;" Done
             rts

cache_off:
             tst.l     _cpu                      ;" Are we run by a 68020 or bigger ?
             beq       skp_off                   ;" No : Skip Cache handling
             movec     cacr, d0                  ;" Fetch Cache Control Register
             and.w     #$fefe, d0                ;" Disable Data and Instruction Cache
             movec     d0, cacr                  ;" Set new Cache Control Register
skp_off:     nop                                 ;" Done
             rts

;-------------------------------------------------------------------------------------)

GemDos       =         1
Super        =         $20
berr_vec     =         $0008

bus_error:
             bsr       inq_mode                  ;" Inquire CPU mode
             beq       be_user                   ;" User : Do User mode code
             move.w    sr, d1                    ;" Get CPU status
             or.w      #$0700, sr                ;" Disable all interrupts
             move.w    d1, state                 ;" Save status word
             move.l    sp, sav_sstkp             ;" Save Super stack pointer
             move.l    usp, a0                   ;" Get User stack pointer
             move.l    a0, sav_ustkp             ;" Save User stack pointer
             move.l    berr_vec, sav_berr        ;" Save Bus Error vector
             move.l    #exit_berr, berr_vec      ;" Install own vector
             bra       fin_init                  ;" Super mode code done
be_user:     bsr       set_super                 ;" Switch to Super mode
             move.w    sr, d1                    ;" Get CPU status
             and.w     #$dfff, d1                ;" Was called from User mode
             or.w      #$0700, sr                ;" Disable all interrupts
             move.w    d1, state                 ;" Save status word
             move.l    d0, sav_sstkp             ;" Save Super stack pointer
             move.l    usp, a0                   ;" Get User stack pointer
             lea       10(a0), a0                ;" Correct for shifts
             move.l    a0, sav_ustkp             ;" Save User stack pointer
             move.l    berr_vec, sav_berr        ;" Save Bus Error vector
             move.l    #exit_berr, berr_vec      ;" Install own vector
             bsr       set_user                  ;" Switch back to User mode
fin_init:    move.l    (sp), sav_return          ;" Save return address
             clr.w     d0                        ;" Flag indicating normal exit
             rts

exit_berr:
             move.l    sav_sstkp, sp             ;" Clear Super stack
             move.l    sav_ustkp, a0             ;" Get User stack pointer to
             move.l    a0, usp                   ;" Clear User stack
             move.w    state, d0                 ;" Restore CPU status
             or.w      #$0700, d0                ;" Except interrupt mask
             move.w    d0, sr                    ;" Install status
             move.l    sav_return, (sp)          ;" Restore return address
             move.w    #1, d0                    ;" Flag indicating Bus Error
             rts

berr_off:
             bsr       inq_mode                  ;" Inquire CPU mode
             beq       bo_user                   ;" User : Do User mode code
             move.l    sav_berr, berr_vec        ;" Restore Bus Error vector
             move.w    state, sr                 ;" Restore CPU status
             bra       fin_exit                  ;" Super mode code done
bo_user:     bsr       set_super                 ;" Switch to Super mode
             move.l    sav_berr, berr_vec        ;" Restore Bus Error vector
             move.w    state, d1                 ;" Restore CPU status
             or.w      #$2000, d1                ;" Except Super bit, must stay
             move.w    d1, sr                    ;" Install status
             bsr       set_user                  ;" Switch back to User mode
fin_exit:    nop                                 ;" All done
             rts

inq_mode:
             move.l    #1, -(sp)                 ;" Set Flag
             move.w    #Super, -(sp)             ;" For inquiring CPU mode
             trap      #GemDos                   ;" Call GemDos Super()
             addq.l    #6, sp                    ;" Stack correction
             tst.l     d0                        ;" Return value zero ?
             rts

set_super:
             clr.l     -(sp)                     ;" Clear word to be passed
             move.w    #Super, -(sp)             ;" To switch to Super mode
             trap      #GemDos                   ;" Call GemDos Super()
             addq.l    #6, sp                    ;" Stack correction
             rts

set_user:
             move.l    d0, -(sp)                 ;" Pass Super stack pointer
             move.w    #Super, -(sp)             ;" To switch back to User mode
             trap      #GemDos                   ;" Call GemDos Super()
             addq.l    #6, sp                    ;" Stack correction
             rts

state:       ds.w      1                         ;" Saved CPU status
sav_ustkp:   ds.l      1                         ;" Saved User stack pointer
sav_sstkp:   ds.l      1                         ;" Saved Super stack pointer
sav_berr:    ds.l      1                         ;" Saved Bus Error vector
sav_return:  ds.l      1                         ;" Saved return address

;-------------------------------------------------------------------------------------)

             .end
