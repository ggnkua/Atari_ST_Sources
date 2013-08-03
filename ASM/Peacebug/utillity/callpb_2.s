*******************************************************************************
*               PEACEBUG, Call Debugger 2                          15.03.1995 *
*               -------------------------                                     *
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
                movea.l     72(a0),a0
                move.l      #MESSAGE,-4(a0)
                pea         .come_back(pc)          ; return address
                move.w      sr,-(sp)
                jmp         (a0)                    ; CALL_DEBUGGER_1

.not_found:     pea         fail_message(pc)        ; Peacebug not found
                move.w      #9,-(sp)
                trap        #1                      ; Cconws
                addq.w      #6,sp
.come_back:     rts

*******************************************************************************

                .DATA
MESSAGE:        dc.b        'Called by CALL_DEBUGGER_2. Continue with GoPC',0
fail_message:   dc.b        13,10,' PEACEBUG not found',7,13,10,0

*******************************************************************************

                .BSS
                ds.b        1024
STACK:          .END
