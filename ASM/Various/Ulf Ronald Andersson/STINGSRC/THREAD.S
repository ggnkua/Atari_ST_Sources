
;*********************************************************************
;*                                                                   *
;*     STinG : API and IP kernel package                             *
;*                                                                   *
;*                                                                   *
;*      Version 1.2                       from 12. January 1997      *
;*                                                                   *
;*      Module for Pseudo-Threading and Semaphors                    *
;*                                                                   *
;*********************************************************************


             .export   set_flag                  ;" Function for setting a semaphor
             .export   clear_flag                ;" Function for clearing a semaphor
             .import   semaphors                 ;" Address of semaphor array
             .export   check_sum                 ;" Code for calculating IP checksum

             .export   install_PrivVio           ;" Install PrivVio exception vector
             .export   uninst_PrivVio            ;" Uninstall PrivVio exception vector
             .export   protect_exec              ;" Code for execution without interupts
             .export   lock_exec                 ;" Code for (un)locking interupts

             .import   poll_ports                ;" Thread handling IP traffic
             .import   clean_up                  ;" Thread expiring dgram timeouts
             .export   install_timer             ;" Function for installing timer
             .export   active                    ;" Flag for being active
             .export   fraction                  ;" Time between thread calls
             .export   sting_clock               ;" STinG internal clock


;-------------------------------------------------------------------------------------)

set_flag:
             lea     semaphors, a0               ;" Address of semaphor array
             move.w  4(sp), d1                   ;" Number of semaphor from stack
             move.l  #1, d0                      ;" Preset TRUE in case of lock
             tas     (a0, d1.w)                  ;" Test semaphor, and set bit 7
             bne     denied                      ;" Was set ? Return TRUE
             or.b    #$ff, (a0, d1.w)            ;" Now the lock is ours
             clr.l   d0                          ;" And return FALSE
denied:      nop
             rts

clear_flag:
             lea     semaphors, a0               ;" Address of semaphor array
             move.w  4(sp), d1                   ;" Number of semaphor from stack
             clr.b   (a0, d1.w)                  ;" Clear semaphor
             rts

;-------------------------------------------------------------------------------------)

check_sum:
             and.b   #$ef, ccr                   ;" Clear extended carry
             clr.l   d1                          ;" Clear accumulator
             move.l  (a0)+, d2                   ;" Fetch 1st longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             move.l  (a0)+, d2                   ;" Fetch 2nd longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             move.l  (a0)+, d2                   ;" Fetch 3rd longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             move.l  (a0)+, d2                   ;" Fetch 4th longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             move.l  (a0)+, d2                   ;" Fetch 5th longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             tst.w   d0                          ;" Any options ?
             beq     no_byte                     ;" No : Then finish it

             clr.l   d2                          ;" For adding carries
             addx.l  d2, d1                      ;" Add carry to the accumulator
             addx.l  d2, d1                      ;" Again if another overflow
             move.b  d0, remain                  ;" Save last bits of length
             and.l   #$ffff, d0                  ;" Extend to longword
             lsr.l   #2, d0                      ;" Length by 4 is loop count
             subq.l  #1, d0                      ;" Subtract one for loop
             bmi     no_loop                     ;" No looping ? Go away
             and.b   #$ef, ccr                   ;" Clear extended carry
loop:        move.l  (a1)+, d2                   ;" Fetch longword (4 bytes)
             addx.l  d2, d1                      ;" Add it to accumulator
             dbra    d0, loop                    ;" Loop it
             clr.l   d2                          ;" For adding carries
             addx.l  d2, d1                      ;" Add carry to the accumulator
             addx.l  d2, d1                      ;" Again if another overflow

no_loop:     and.b   #$ef, ccr                   ;" Clear extended carry
             btst    #1, remain                  ;" Do we have 2 or 3 remaining bytes ?
             beq     no_word                     ;" No ...
             move.w  (a1)+, d2                   ;" Else fetch another word
             addx.l  d2, d1                      ;" And add it to the accumulator
no_word:     btst    #0, remain                  ;" Do we have another remaining byte ?
             beq     no_byte                     ;" No ...
             move.w  (a1)+, d2                   ;" Else fetch another word
             clr.b   d2                          ;" But only use upper byte
             addx.l  d2, d1                      ;" And add it to the accumulator

no_byte:     move.l  d1, d0                      ;" Save high word
             swap    d1                          ;" Transfer it to low word
             addx.w  d1, d0                      ;" Add both words
             clr.w   d2                          ;" For adding carries
             addx.w  d2, d0                      ;" Add carry to the accumulator
             addx.w  d2, d0                      ;" Again if another overflow
             and.l   #$ffff, d0                  ;" And truncate to word length
             eor.w   #$ffff, d0                  ;" Invert the result
             rts

remain:      ds.w    1                           ;" Storage for last two length bits

;-------------------------------------------------------------------------------------)

Bios         =       13                          ;" Trap number for Bios
XBios        =       14                          ;" Trap number for XBios
Setexc       =       5                           ;" Bios function number for Setexc
Gettime      =       23                          ;" XBios function number for Gettime
Supexec      =       38                          ;" XBios function number for Supexec
PrivVio      =       8                           ;" Vector number for Privilege Violation
v_200_Hz     =       69                          ;" Vector number for 200 Hz timer
longframe    =       $59e                        ;" Flag for extended stack format

install_PrivVio:
             movem.l d1-d2/a0-a2, -(sp)          ;" Save registers
             move.l  #-1, -(sp)                  ;" We just want to read
             move.w  #PrivVio, -(sp)             ;" The Privilege Violation vector
             move.w  #Setexc, -(sp)              ;" Call Bios Setexc
             trap    #Bios                       ;" Do it
             addq.l  #8, sp                      ;" Stack correction
             move.l  d0, old_PrivVio             ;" Save old vector
             pea     my_PrivVio                  ;" Now set our handler
             move.w  #PrivVio, -(sp)             ;" The Privilege Violation vector
             move.w  #Setexc, -(sp)              ;" Call Bios Setexc
             trap    #Bios                       ;" Do it
             addq.l  #8, sp                      ;" Stack correction
             pea     calc_frame                  ;" Execute calc_frame in Super mode
             move.w  #Supexec, -(sp)             ;" Call XBios Supexec
             trap    #XBios                      ;" Do it
             addq.l  #6, sp                      ;" Stack correction
             movem.l (sp)+, d1-d2/a0-a2          ;" Restore registers
             rts

calc_frame:
             tst.w   longframe                   ;" Do we have a 68000 CPU ?
             beq     cpu_ok                      ;" Yes, there's no extra stack word
             addq.w  #2, framesize               ;" Adjust framesize for 680X0
cpu_ok:      nop
             rts

uninst_PrivVio:
             movem.l d1-d2/a0-a2, -(sp)          ;" Save registers
             move.l  old_PrivVio, -(sp)          ;" Set old handler
             move.w  #PrivVio, -(sp)             ;" The Privilege Violation vector
             move.w  #Setexc, -(sp)              ;" Call Bios Setexc
             trap    #Bios                       ;" Do it
             addq.l  #8, sp                      ;" Stack correction
             movem.l (sp)+, d1-d2/a0-a2          ;" Restore registers
             rts

;-------------------------------------------------------------------------------------)

protect_exec:
             move.l  4(sp), a0                   ;" Fetch parameter to be passed
             move.l  8(sp), a1                   ;" Fetch function code address
prot_exec:   or.w    #$0000, sr                  ;" Cause PrioVio in User mode
             move.w  sr, -(sp)                   ;" Save status
             or.w    #$0700, sr                  ;" In Super mode : Disable interupts
             move.l  a0, -(sp)                   ;" Pass parameter
             jsr     (a1)                        ;" Call user function
             addq.l  #4, sp                      ;" Stack correction
             move.w  (sp)+, sr                   ;" Restore interupt flags
             rts

lock_exec:
             or.w    #$0000, sr                  ;" Cause PrioVio in User mode
             tst.w   d0                          ;" Lock, or Unlock ?
             beq     sup_lock                    ;" Lock : Do locking
             move.w  d0, sr                      ;" Restore status
             rts

sup_lock:
             move.w  sr, d0                      ;" Save status
             or.w    #$0700, sr                  ;" In Super mode : Disable interupts
             rts

;-------------------------------------------------------------------------------------)

             .dc.l   'XBRA'                      ;" XBRA structure for
             .dc.l   'STNG'                      ;" STinG ...
old_PrivVio: .ds.l   1                           ;" Old Privilege Violation vector

my_PrivVio:
             cmp.l   #prot_exec, 2(sp)           ;" Caused by the 'protect' code ?
             beq     prot_code                   ;" Yes, ok, let's do some work
             cmp.l   #lock_exec, 2(sp)           ;" Caused by the 'locking' code ?
             beq     lock_code                   ;" Yes, ok, let's do some work
             move.l  old_PrivVio, -(sp)          ;" Naah, stupid user program, bomb !
             rts

prot_code:
             or.w    #$0700, sr                  ;" Disable interupts now
             move.l  a0, -(sp)                   ;" Pass parameter
             jsr     (a1)                        ;" Call user function
             addq.l  #4, sp                      ;" Stack correction
             move.w  (sp), d1                    ;" Fetch status word
             adda.w  framesize, sp               ;" Discard exception frame
             move.w  d1, sr                      ;" Restore flags, leave Super mode 
             rts

lock_code:
             move.w  (sp), d1                    ;" Fetch status word
             adda.w  framesize, sp               ;" Discard exception frame
             tst.w   d0                          ;" Lock, or Unlock ?
             beq     usr_lock                    ;" Lock : Do locking
             and.w   #$0700, d0                  ;" Isolate interupt flags
             and.w   #$f8ff, d1                  ;" Reset interupt flags
             or.w    d0, d1                      ;" And copy them in
             move.w  d1, sr                      ;" Restore status
             rts

usr_lock:
             move.w  d1, d0                      ;" Save status
             or.w    #$0700, d1                  ;" In Super mode : Disable interupts
             move.w  d1, sr                      ;" Restore flags, leave Super mode 
             rts

framesize:   dc.w    6                           ;" With 68000 only 6 as value

;-------------------------------------------------------------------------------------)

install_timer:
             movem.l d1-d2/a0-a2, -(sp)          ;" Save registers
             move.w  #Gettime, -(sp)             ;" Call XBios Gettime
             trap    #XBios                      ;" Do it
             addq.l  #2, sp                      ;" Stack correction
             move.l  d0, d2                      ;" A copy for the 'hours'
             lsr.l   #8, d2                      ;" Shift 'hours' to LSBs
             lsr.l   #3, d2                      ;" MC 68000 can't shift 11 bits
             and.l   #$1f, d2                    ;" Mask 'hours' bits
             mulu.w  #360, d2                    ;" Multiply by 3600000 for ms
             mulu.w  #10000, d2                  ;" MC 68000 can't multiply longs
             move.l  d0, d1                      ;" A copy for the 'minutes'
             lsr.l   #5, d1                      ;" Shift 'minutes' to LSBs
             and.l   #$3f, d1                    ;" Mask 'minutes' bits
             mulu.w  #60000, d1                  ;" Multiply by 60000 for ms
             lsl.l   #1, d0                      ;" Shift 'seconds' to right place
             and.l   #$3f, d0                    ;" Mask 'seconds' bits
             mulu.w  #1000, d0                   ;" Multiply by 1000 for ms
             add.l   d1, d2                      ;" Add 'minutes' part
             add.l   d0, d2                      ;" Add 'seconds' part
             move.l  d2, sting_clock             ;" Store result in clock

             move.l  #-1, -(sp)                  ;" We just want to read
             move.w  #v_200_Hz, -(sp)            ;" The 200 Hz timer vector
             move.w  #Setexc, -(sp)              ;" Call Bios Setexc
             trap    #Bios                       ;" Do it
             addq.l  #8, sp                      ;" Stack correction
             move.l  d0, old_200_Hz              ;" Save old vector
             pea     my_200_Hz                   ;" Now set our handler
             move.w  #v_200_Hz, -(sp)            ;" The 200 Hz timer vector
             move.w  #Setexc, -(sp)              ;" Call Bios Setexc
             trap    #Bios                       ;" Do it
             addq.l  #8, sp                      ;" Stack correction
             movem.l (sp)+, d1-d2/a0-a2          ;" Restore registers
             move.l  sp, sys_stack               ;" Use STinG stack as system stack
             rts

;-------------------------------------------------------------------------------------)

             .dc.l   'XBRA'                      ;" XBRA structure for
             .dc.l   'STNG'                      ;" STinG ...
old_200_Hz:  .ds.l   1                           ;" Old 200 Hz timer vector

my_200_Hz:
             add.l   #5, sting_clock             ;" Count stack internal clock
             cmp.l   #86400000, sting_clock      ;" Test for one day [ms]
             bmi     clk_ok                      ;" If the day has elapsed, then
             sub.l   #86400000, sting_clock      ;" Reduce by one day [ms]
clk_ok:      subq.w  #1, traffic                 ;" Count down for IP traffic
             bne     early_a                     ;" Is it time for it ?
             move.w  fraction, traffic           ;" Yes : Reset counter
             bset    #0, tm_exec                 ;" Signal : Do work
early_a:     subq.w  #1, cleaning                ;" Count down for Cleaning up
             bne     early_b                     ;" Is it time for it ?
             move.w  #200, cleaning              ;" Yes : Reset counter
             bset    #1, tm_exec                 ;" Signal : Do work
early_b:     tas     tm_sema                     ;" STinG work still on ?
             bmi     lazy                        ;" Yes : Do nothing here
             tst.w   tm_exec                     ;" Something to do ?
             beq     stale                       ;" No : Do nothing
             tst.w   active                      ;" Are we switched active ?
             beq     stale                       ;" No : Do nothing
             move.w  (sp), interupt              ;" Fetch status from stack
             and.w   #$0400, interupt            ;" Interupt level >= 4 ?
             bne     stale                       ;" Yes : Do nothing
             tas     tm_busy                     ;" Have we been busy recently ?
             bpl     here_we_go                  ;" No : Let's get busy then
stale:       clr.w   tm_busy                     ;" Allow clients to work
             clr.w   tm_sema                     ;" Release stale work lock
lazy:        move.l  old_200_Hz, -(sp)           ;" Jump to system handler
             rts

active:      .dc.w   0                           ;" Flag for active
traffic:     .dc.w   1                           ;" Counter for IP traffic
fraction:    .dc.w   10                          ;" Divide by this
cleaning:    .dc.w   1                           ;" Counter for Cleaning up
tm_sema:     .dc.w   0                           ;" Execution semaphore
tm_exec:     .dc.w   0                           ;" Execution flags
tm_busy:     .dc.w   0                           ;" Flag for been busy
sting_clock: .dc.l   0                           ;" Internal clock
sys_stack:   .dc.l   0                           ;" Stack address for STinG
interupt:    .ds.w   1                           ;" Interupt level of code
cpu_state:   .ds.l   16                          ;" Space for CPU registers

here_we_go:
             tst.w   longframe                   ;" Do we have a 68000 CPU ?
             beq     cpu_fixed                   ;" Yes, no extra stack word
             clr.w   -(sp)                       ;" Extra stack word for 680X0
cpu_fixed:   pea     keep_going                  ;" Install exception stack frame
             move.w  sr, -(sp)                   ;" For return to STinG work
             move.l  old_200_Hz, -(sp)           ;" Jump to system handler
             rts

keep_going:
             movem.l d0-d7/a0-a7, cpu_state      ;" Save CPU register
             move.w  (sp), d0                    ;" Fetch status from stack
             bset    #13, d0                     ;" Stay in Super mode
             move.w  d0, sr                      ;" Lower interupt level
             move.l  sys_stack, sp               ;" Install our stack
             bclr    #0, tm_exec                 ;" IP traffic to do ?
             beq     dont_a                      ;" No : Skip it
             bsr     poll_ports                  ;" Execute IP traffic routine
dont_a:      bclr    #1, tm_exec                 ;" Clean up to do ?
             beq     dont_b                      ;" No : Skip it
             bsr     clean_up                    ;" Execute clean up routine
dont_b:      movem.l cpu_state, d0-d7/a0-a7      ;" Restore CPU register
             clr.w   tm_sema                     ;" STinG work finished
             rte

;-------------------------------------------------------------------------------------)

             .end
