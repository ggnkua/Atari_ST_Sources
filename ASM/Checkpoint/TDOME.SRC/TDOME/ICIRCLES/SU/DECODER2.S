;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
;
; Delta Decoder, 8bit delta offsets                               (w)2009'defjam
;                                                                    2012,2014
; NORMAL VERSION 320x200
;
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                OPT D+

                >PART ' init '

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w

                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                bsr     wait_vbl
                clr.b   $FFFF8260.w

                ENDPART

                movem.l colors,D0-D7
                movem.l D0-D7,$FFFF8240.w


                lea     delta_data,A0
                bsr     init_delta_decoder

;-------------------------------------------------------------------------------
loop:
                bsr     swap_screens
                bsr     wait_vbl
                bsr     wait_vbl

                move.l  screen1,D0
                move.l  D0,draw_screen_delta

                bsr     delta_play_frame

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop

;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

screen0:        DC.L 0
screen1:        DC.L 0

                ENDPART
vbl:            >PART

                movem.l D0-A6,-(SP)

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; A0.input
init_delta_decoder:>PART
                move.l  A0,delta_Ptr
                bsr.s   tf_init
                rts
                ENDPART

delta_play_frame:
                bsr.s   tf_decode
                bsr     tf_next_frame
                rts

;--------------------------------------------
tf_frame:       DC.W 0
max_frame:      DC.W 0
restart_frame:  DC.W 0
frame_table_adr:DC.L 0
delta_Ptr:      DC.L 0
draw_screen_delta:DC.L 0
;--------------------------------------------
tf_init:        >PART
                bsr     make_absolut_table

;    lea     output_start,A0
                movea.l delta_Ptr(PC),A0

                move.w  (A0)+,max_frame
                move.w  (A0)+,restart_frame
                move.l  A0,frame_table_adr

                clr.w   tf_frame
                rts
                ENDPART
tf_decode:      >PART

                move.w  tf_frame(PC),D0
                lsl.w   #3,D0
                movea.l frame_table_adr(PC),A0
                movem.l 0(A0,D0.w),A0-A1
;
; A0
; .w 320er blocks
; .l rest
; .w data 1st
; .w .w .w .... deltagfx
;
; A1
; .b .b .b .... deltaoffsets
;
                movea.l draw_screen_delta(PC),A2
                move.w  (A0)+,D1        ; 320er blocks
                move.w  (A0)+,D2        ; rest

                move.w  D1,D3
                or.w    D2,D3
                beq     tf_no_out

                adda.l  (A0)+,A2        ; 1st entry starts with a long offset
                move.w  (A0)+,(A2)+

                moveq   #0,D0

                subq.w  #1,D1
                bcs     no_tf320
tf320:
                REPT 320
                move.b  (A1)+,D0
                adda.w  D0,A2
                move.w  (A0)+,(A2)+
                ENDR
                dbra    D1,tf320
no_tf320:
                neg.w   D2
                add.w   #320,D2
                mulu    #6,D2
                jmp     tf_rest(PC,D2.w)
tf_rest:
                REPT 320
                move.b  (A1)+,D0
                adda.w  D0,A2
                move.w  (A0)+,(A2)+
                ENDR
tf_no_out:
                rts
                ENDPART
tf_next_frame:  >PART

                move.w  max_frame(PC),D0
                lea     tf_frame(PC),A0
                addq.w  #1,(A0)
                cmp.w   (A0),D0
                bne.s   de_more_tf
                move.w  restart_frame(PC),(A0)
de_more_tf:
                rts
                ENDPART
make_absolut_table:>PART

;   lea     output_start,A0
                movea.l delta_Ptr(PC),A0

                move.l  A0,D0
                addq.l  #4,A0           ; header
                move.w  #512-1,D1
mat:
                add.l   D0,(A0)+
                add.l   D0,(A0)+
                dbra    D1,mat
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; A0-->A1
memclr:         >PART

                move.l  A1,D0
                sub.l   A0,D0           ; block length

                movem.l zero,D1-A0/A2-A6 ; 13*4 = 52

                divu    #4*(13*4),D0
                subq.w  #1,D0
                bcs.s   mc0n
mc0:
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                dbra    D0,mc0
mc0n:
                swap    D0
                subq.w  #1,D0
                bcs.s   mc1n
mc1:
                move.b  D1,-(A1)
                dbra    D0,mc1
mc1n:
                rts
                ENDPART
;-------------------------------------------------------------------------------

                DATA
zero:
                DS.L 16

c0              SET $0777
c1              SET $0700
c2              SET $0070
c3              SET $0007
colors:         >PART
                DC.W $0000      ;            0 ;

                DC.W c0         ;    0       1 ;

                DC.W c1         ;   1        2 ;
                DC.W c1         ;   10       3 ;

                DC.W c2         ;  2         4 ;
                DC.W c2         ;  2 0       5 ;
                DC.W c2         ;  21        6 ;
                DC.W c2         ;  210       7 ;

                DC.W c3         ; 3          8 ;
                DC.W c3         ; 3  0       0 ;
                DC.W c3         ; 3 1       10 ;
                DC.W c3         ; 3 10      11 ;
                DC.W c3         ; 32        12 ;
                DC.W c3         ; 32 0      13 ;
                DC.W c3         ; 321       14 ;
                DC.W c3         ; 3210      15 ;

                ENDPART

delta_data:
                PATH 'C:\0NEW\TDOME\'
                PATH 'ICIRCLES\SU\'
                IBYTES 'SU.DEL'

;-------------------------------------------------------------------------------
                BSS
                DS.B 512
stack:          DS.B 2

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
E:
                END
