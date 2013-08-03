*******************************************************************************
*               PEACEBUG, Get Resolution                           15.03.1995 *
*               ------------------------                                      *
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

SUPERVISOR:     move.w      #4,-(sp)
                trap        #14                     ; Getrez
                addq.w      #2,sp
                move.w      d0,d7
                bmi.s       .rez_error
                cmpi.w      #7,d7
                bhi.s       .rez_error

                movea.l     $5a0.w,a0               ; cookie pointer
                move.l      a0,d0
                beq.s       .not_found
                subq.w      #4,a0
.search:        addq.w      #4,a0
                tst.l       (a0)                    ; search for PEACEBUGs
                beq.s       .not_found              ; cookie jar
                cmpi.l      #'PBUG',(a0)+
                bne.s       .search

                movea.l     (a0),a0                 ; gotcha
                movea.l     24(a0),a1
                tas         102(a1)                 ; set SCREEN_LOCK!
                bne.s       .screen_locked
                mulu        #6,d7
                lea         RESOLUTION(pc,d7.l),a2
                movem.w     (a2),d0-d2
                tst.w       d0
                beq.s       .rez_error
                lea         42(a1),a2
                clr.l       (a2)+                   ; OFFSET_X, OFFSET_Y
                move.w      d0,(a2)+                ; BILD_BREITE
                move.w      d0,(a2)+                ; ZEILEN_LAENGE
                move.w      d1,(a2)+                ; BILD_HOEHE
                mulu        d2,d0
                move.w      d0,(a2)+                ; SCREEN_BREITE
                move.w      d1,(a2)+                ; SCREEN_HOEHE
                move.w      d2,(a2)+                ; PLANES
                movea.l     16(a0),a2
                jsr         (a2)                    ; NEW_FORMAT
                movea.l     20(a0),a2
                jsr         (a2)                    ; PRINT_SCREEN
                clr.b       102(a1)                 ; clear SCREEN_LOCK!
                pea         success_message(pc)
                bra.s       .message

.screen_locked: pea         screen_message(pc)      ; SCREEN_LOCK was set
                bra.s       .message

.rez_error:     pea         rez_message(pc)         ; unknown resolution
                bra.s       .message

.not_found:     pea         fail_message(pc)        ; Peacebug not found
.message:       move.w      #9,-(sp)
                trap        #1                      ; Cconws
                addq.w      #6,sp
                rts

*******************************************************************************

RESOLUTION:     dc.w        320/8,200,4             ; ST-Low
                dc.w        640/8,200,2             ; ST-Mid
                dc.w        640/8,400,1             ; ST-High
                dc.w        0,0,0
                dc.w        640/8,480,4             ; TT-Mid
                dc.w        0,0,0
                dc.w        1280/8,960,1            ; TT-High
                dc.w        320/8,480,8             ; TT-Low

                .DATA
success_message:dc.b        13,10,27,112,' Resolution adapted to GETREZ ',27,113,13,10,0
rez_message:    dc.b        13,10,' Unknown resolution',7,13,10,0
screen_message: dc.b        13,10,' At the moment PEACEBUG''s screen interface is locked.',7,13,10,0
fail_message:   dc.b        13,10,' PEACEBUG not found',7,13,10,0

*******************************************************************************

                .BSS
                ds.b        1024
STACK:          .END
