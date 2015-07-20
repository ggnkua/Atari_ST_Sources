*******************************************************************************
*               PEACEBUG, History                                  15.03.1995 *
*               -----------------                                             *
*                                                                             *
* written by:   Emanuel Mîcklin                                               *
*               Rainfussweg 7                                                 *
*               CH-8038 ZÅrich                                                *
*               peace@soziologie.unizh.ch                                     *
*                                                                             *
* written with: PASM                                                          *
*******************************************************************************

HISTORY         EQU 20                              ; additional history entries

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
                movea.l     24(a0),a1               ; SCREEN_PARAMETER
                moveq       #HISTORY,d0
                mulu        48(a1),d0               ; * ZEILEN_LAENGE
                movea.l     36(a0),a0               ; PARAMETER
                add.l       126(a0),d0              ; + original length
                move.l      d0,-(sp)
                movea.l     118(a0),a0
                jsr         (a0)                    ; NEW_HISTORY
                tst.l       (sp)+
                beq.s       .malloc_failed
                pea         success_message(pc)
                bra.s       .message

.malloc_failed: pea         malloc_message(pc)      ; memory allocation failed
                bra.s       .message

.not_found:     pea         fail_message(pc)        ; Peacebug not found
.message:       move.w      #9,-(sp)
                trap        #1                      ; Cconws
                addq.w      #6,sp
                rts

*******************************************************************************
                .DATA
success_message:dc.b        13,10,27,112,' History expanded ',27,113,13,10,0
malloc_message: dc.b        13,10,' Memory allocation has failed.',7,13,10,0
fail_message:   dc.b        13,10,' PEACEBUG not found',7,13,10,0

*******************************************************************************

                .BSS
                ds.b        1024
STACK:          .END
