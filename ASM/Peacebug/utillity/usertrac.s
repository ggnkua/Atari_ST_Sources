*******************************************************************************
*               PEACEBUG, Usertrace                                15.03.1995 *
*               -------------------                                           *
*                                                                             *
* written by:   Emanuel Mîcklin                                               *
*               Rainfussweg 7                                                 *
*               CH-8038 ZÅrich                                                *
*               peace@soziologie.unizh.ch                                     *
*                                                                             *
* written with: PASM                                                          *
*******************************************************************************

                movea.l     4(sp),a0                ; Basepage
                lea         STACK(pc),sp            ; own stack

                move.l      12(a0),d0               ; TEXT length
                add.l       20(a0),d0               ; DATA length
                add.l       28(a0),d0               ; BSS length
                addi.l      #256,d0                 ; Basepage length
                move.l      d0,ProgramLength
                move.l      d0,-(sp)
                pea         (a0)
                move.l      #$4a0000,-(sp)
                trap        #1                      ; Mshrink
                lea         12(sp),sp

                pea         SUPERVISOR(pc)
                move.w      #38,-(sp)
                trap        #14                     ; Supexec
                addq.w      #6,sp

                clr.w       -(sp)
                trap        #1                      ; Pterm0

RETURN:         clr.w       -(sp)
                move.l      ProgramLength(pc),-(sp)
                move.w      #49,-(sp)
                trap        #1                      ; Ptermres

*******************************************************************************

SUPERVISOR:     movea.l     $5a0.w,a0               ; cookie pointer
                move.l      a0,d0
                beq.s       .not_found
                subq.w      #4,a0
.search:        addq.w      #4,a0
                tst.l       (a0)                    ; search for PEACEBUGs
                beq.s       .not_found              ; cookie jar
                cmpi.l      #'PBUG',(a0)+
                bne.s       .search

                movea.l     (a0),a0                 ; gotcha
                move.l      #USERTRACE,40(a0)       ; install usertrace routine
                move.l      #RETURN,(sp)            ; keep resident!
                movea.l     76(a0),a0
                jmp         (a0)                    ; call TRACE_WITHOUT

.not_found:     pea         fail_message(pc)        ; Peacebug not found
                move.w      #9,-(sp)
                trap        #1                      ; Cconws
                addq.w      #6,sp
                rts

*******************************************************************************

                dc.l        break_message
                dc.l        'XBRA'
                dc.l        'UT_1'
                dc.l        0
USERTRACE:      cmpi.l      #-1,d0
                sne         -(sp)
                tst.b       (sp)+
                rts

*******************************************************************************

                .DATA
fail_message:   dc.b        13,10,' PEACEBUG not found',7,13,10,0
break_message:  dc.b        'Break by usertrace, condition d0.l=-1',0

                .BSS
ProgramLength:  ds.l        1
                ds.b        1024
STACK:          .END