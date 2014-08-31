
;*********************************************************************
;*                                                                   *
;*     Low Level Port : Serielle Schnittstellen                      *
;*                                                                   *
;*                                                                   *
;*      Version 1.0                     from 28. September 1997      *
;*                                                                   *
;*      Module for assembler subroutines                             *
;*                                                                   *
;*********************************************************************


             .export   execute                   ;" Function to execute status calls
             .export   send                      ;" Function for sending data
             .export   receive                   ;" Function for receiving data
             .export   inq_cd                    ;" Function for inquiring DCD status
             .export   set_dtr                   ;" Function for setting DTR status
             .export   choose_magic              ;" Function for getting a random magic


;-------------------------------------------------------------------------------------)

execute:
             movem.l   d3-d7/a2-a6, cpu_state    ;" Save CPU register
             jsr       (a0)                      ;" Call status code
             movem.l   cpu_state, a2-a6/d3-d7    ;" Restore CPU register
             rts

;-------------------------------------------------------------------------------------)

send:
             movem.l   d3-d7/a2-a6, cpu_state    ;" Save CPU register
             move.l    4(sp), code               ;" Get function for sending bytes
             move.l    8(sp), a0                 ;" Pointer to real 'walk'
             move.l    (a0), walk                ;" Get pointer into buffer
             move.l    12(sp), a0                ;" Pointer to real 'remain'
             move.w    (a0), remain              ;" Get number of remaining bytes
             move.l    16(sp), status            ;" Get function for checking status
send_lp:
             clr.l     d0                        ;" Prepare parameter set
             move.l    walk, a0                  ;" Fetch next byte
             move.b    (a0)+, d0                 ;" And include it into parameters
             move.l    a0, walk                  ;" Save pointer
             move.l    d0, -(sp)                 ;" And pass parameters
             move.l    code, a0                  ;" Function for sending bytes
             jsr       (a0)                      ;" Call it
             sub.w     #1, remain                ;" One less bytes to send
             clr.w     -(sp)                     ;" Prepare stack for status check
             move.l    status, a0                ;" Function for checking status
             jsr       (a0)                      ;" Call it
             addq.l    #6, sp                    ;" Stack correction
             tst.w     d0                        ;" Test : Buffer full ?
             beq       end_send                  ;" Yes : Terminate
             tst.w     remain                    ;" Test : More bytes to send ?
             bne       send_lp                   ;" Yes : Loop
end_send:
             move.l    8(sp), a0                 ;" Pointer to real 'walk'
             move.l    walk, (a0)                ;" Save pointer into buffer
             move.l    12(sp), a0                ;" Pointer to real 'remain'
             move.w    remain, (a0)              ;" Save number of remaining bytes
             movem.l   cpu_state, a2-a6/d3-d7    ;" Restore CPU register
             rts

;-------------------------------------------------------------------------------------)

receive:
             movem.l   d3-d7/a2-a6, cpu_state    ;" Save CPU register
             move.l    4(sp), code               ;" Get function for sending bytes
             move.l    8(sp), a0                 ;" Pointer to real 'walk'
             move.l    (a0), walk                ;" Get pointer into buffer
             move.l    12(sp), a0                ;" Pointer to real 'remain'
             move.w    (a0), remain              ;" Get amount of remaining space
             move.l    16(sp), status            ;" Get function for checking status
             move.w    20(sp), mark              ;" Get end-of-data definition
recve_lp:
             clr.w     -(sp)                     ;" Prepare stack for receive
             move.l    code, a0                  ;" Function for receiving a byte
             jsr       (a0)                      ;" Call it
             move.l    walk, a0                  ;" Pointer into buffer
             move.b    d0, (a0)+                 ;" Save received byte
             move.l    a0, walk                  ;" Save advanced pointer
             clr.w     -(sp)                     ;" Prepare stack for status check
             move.l    status, a0                ;" Function for checking status
             jsr       (a0)                      ;" Call it
             addq.l    #4, sp                    ;" Stack correction
             move.l    walk, a0                  ;" Pointer into buffer
             clr.w     d1                        ;" Prepare register
             move.b    -1(a0), d1                ;" Recall received byte
             cmp.w     mark, d1                  ;" Datagram end found ?
             beq       end_recve                 ;" Yes : Terminate
             sub.w     #1, remain                ;" No space left anymore ?
             beq       end_recve                 ;" Yes : Terminate
             tst.w     d0                        ;" Test : Buffer empty ?
             bne       recve_lp                  ;" No : Loop
end_recve:
             move.l    8(sp), a0                 ;" Pointer to real 'walk'
             move.l    walk, (a0)                ;" Save pointer into buffer
             move.l    12(sp), a0                ;" Pointer to real 'remain'
             move.w    remain, (a0)              ;" Save amount of remaining space
             movem.l   cpu_state, a2-a6/d3-d7    ;" Restore CPU register
             rts

;-------------------------------------------------------------------------------------)

inq_cd:
             move.l    #$5482, d0                ;" Do a Fcntl (..., TIOCCTLGET);
             move.l    #$0010, status            ;" Inquire Carrier Detect
             bsr       exec_hsm                  ;" Call HSMODEM code
             move.w    #$0010, d0                ;" Preset return to DCD = TRUE
             tst.l     d0                        ;" Error occured ?
             bmi       cd_set                    ;" Yes, return TRUE
             move.l    status, d0                ;" Otherwise get status
cd_set:      and.w     #$0010, d0                ;" And isolate DCD
             rts

set_dtr:
             clr.l     status + 4                ;" Preset status to DTR = FALSE
             tst.w     d0                        ;" Was that intended ?
             beq       dtr_ok                    ;" Yes, OK
             move.l    #$0002, status + 4        ;" Otherwise set DTR = TRUE
dtr_ok:      move.l    #$5483, d0                ;" Do a Fcntl (..., TIOCCTLSET);
             move.l    #$0002, status            ;" Data Terminal Ready is meant
             bsr       exec_hsm                  ;" Call HSMODEM code
             rts

exec_hsm:
             movem.l   d3-d7/a2-a6, cpu_state    ;" Save CPU register
             move.l    a0, a2                    ;" Command code
             lea       status, a1                ;" Pointer for return value
             clr.l     a0                        ;" No file descriptor
             jsr       (a2)                      ;" Call HSMODEM code
             movem.l   cpu_state, a2-a6/d3-d7    ;" Restore CPU register
             rts

;-------------------------------------------------------------------------------------)

bus_vec      =         $08
_vblqueue    =         $456
_frclock     =         $466
vid_c_hi     =         $ffff8205
vid_c_med    =         $ffff8207
vid_c_low    =         $ffff8209

choose_magic:
             movem.l   d1-d2, -(sp)              ;" Save D1 and D2
             move.w    sr, status                ;" Save status word
             or.w      #$0700, sr                ;" Disable all interrupts
             move.l    sp, stack                 ;" Save stack pointer
             move.l    bus_vec, saved_bus        ;" Save bus error vector
             move.l    #failure, bus_vec         ;" Enable our bus error handler

             move.b    vid_c_low, d0             ;" Video counter low byte
             asl.l     #8, d0                    ;" In bits 8 bis 15
             move.b    vid_c_med, d0             ;" Video counter medium byte
             asl.l     #8, d0                    ;" In bits 8 bis 15
             move.b    vid_c_hi, d0              ;" Video counter high byte
             asl.l     #8, d0                    ;" Whole counter in D0
skip_it:     move.l    _vblqueue, d1             ;" Queue pointer, little random
             eor.l     d1, d0                    ;" Exclusive or'd
             move.l    _frclock, d1              ;" Number of screen refreshs
             move.w    d1, d2                    ;" Is pretty random
             mulu.w    d2, d1                    ;" Now squared
             and.l     #$1f, d1                  ;" But only between 0 and 31
             rol.l     d1, d0                    ;" Rotate as many times

             move.l    saved_bus, bus_vec        ;" Restore bus error vector
             move.l    stack, sp                 ;" Restore stack pointer
             move.w    status, sr                ;" Restore status word
             movem.l   (sp)+, d1-d2              ;" Restore D1 and D2
             rts

failure:
             move.l    stack, sp                 ;" Restore stack pointer
             bra       skip_it                   ;" Continue

;-------------------------------------------------------------------------------------)

walk:        ds.l      1                         ;" Pointer into buffer
remain:      ds.w      1                         ;" Remaining bytes
mark:        ds.w      1                         ;" End-of-data mark
code:        ds.l      1                         ;" Pointer to code to be called
status:      ds.l      2                         ;" Pointer to check function
stack:       ds.l      1                         ;" Saved stack pointer
saved_bus:   ds.l      1                         ;" Saved bus error vector

cpu_state:   ds.l      10                        ;" Save area for CPU registers

;-------------------------------------------------------------------------------------)

             .end
