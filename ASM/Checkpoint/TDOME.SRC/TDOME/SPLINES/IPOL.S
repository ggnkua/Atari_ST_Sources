
loop:
                bsr     swap_screens

                bsr     wait_vbl
                move.w  colors,$FFFF8240.w

                bsr     script_rout

                movea.l screen1,A0
                jsr     clear_1plane

                move.l  ipol_rout(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   mt_loop
                DC.L $4AFC4E71
                bra.s   mt_loop

do_ipol:
                bsr     ipol_main
                bsr     ipol_output
                rts

ipol_rout:      DC.L 0

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
script_rout:    >PART

;     DC.L $4AFC4E71

                move.l  script_sub0(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.l  script_sub1(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

                move.l  script_sub2(PC),D0
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)


                addq.l  #1,t

                subq.l  #1,script_delay
                bpl.s   sr_wait

                moveq   #0,D0
                movea.l script_pos(PC),A0
                movea.l (A0)+,A1
                jsr     (A1)
sr_wait:
                rts

script_pos:     DC.L script
script_delay:   DC.L 0
t:              DC.L 0

script_sub0:    DC.L 0
script_sub1:    DC.L 0
script_sub2:    DC.L 0

                ENDPART
WAIT:           >PART
                move.l  (A0)+,script_delay
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_L:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.l  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_W:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.w  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
MOVE_B:         >PART
                move.l  (A0)+,D0        ; value
                movea.l (A0)+,A1        ; address
                move.b  D0,(A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_L:          >PART
                movea.l (A0)+,A1        ; address
                clr.l   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_W:          >PART
                movea.l (A0)+,A1        ; address
                clr.w   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
CLR_B:          >PART
                movea.l (A0)+,A1        ; address
                clr.b   (A1)
                move.l  A0,script_pos
                rts
                ENDPART
ST:             >PART
                movea.l (A0)+,A1        ; address
                st      (A1)
                move.l  A0,script_pos
                rts
                ENDPART
SF:             >PART
                bra.s   CLR_B
                ENDPART
EXEC:           >PART
                movea.l (A0)+,A1
                move.l  A0,script_pos
                jsr     (A1)
                rts
                ENDPART
HALT:           >PART
                rts
                ENDPART
END:            >PART
                move.l  #'END!',D0
                rts
                ENDPART
ILL:            >PART
                DC.L $4AFC4E71
                move.l  A0,script_pos
                rts
                ENDPART
GOTO:           >PART
                movea.l (A0)+,A0
                move.l  A0,script_pos
                rts
                ENDPART
;-------------------------------------
fade_speed:     DC.W 0
fade_scounter:  DC.W 0
fade_num:       DC.W 0
;-------------------------------------
;-------------------------------------
script:         >PART

                DC.L __init_ipol,C_pre,H_pre
                DC.L __do_ipol

                DC.L __init_ipol,H_pre,E_pre
                DC.L __do_ipol

                DC.L __init_ipol,E_pre,C_pre
                DC.L __do_ipol

                DC.L __init_ipol,C_pre,K_pre
                DC.L __do_ipol

                DC.L __init_ipol,K_pre,P_pre
                DC.L __do_ipol

                DC.L __init_ipol,P_pre,O_pre
                DC.L __do_ipol

                DC.L __init_ipol,O_pre,I_pre
                DC.L __do_ipol

                DC.L __init_ipol,I_pre,N_pre
                DC.L __do_ipol

                DC.L __init_ipol,N_pre,T_pre
                DC.L __do_ipol

                DC.L __init_ipol,T_pre,C_pre
                DC.L __do_ipol

                DC.L GOTO,script



*     DC.L EXEC,__END__

* DC.L GOTO,script
                DC.L HALT

*   DC.L set_fade_speed,1
*   DC.L fade,white,black
*   DC.L wait_fade

                ENDPART
;-------------------------------------
;-------------------------------------

__init_ipol:    >PART
                lea     (A0),A2
                movea.l (A2)+,A0
                movea.l (A2)+,A1
                move.l  A2,script_pos
                bsr     ipol_init
                move.l  #do_ipol,ipol_rout
                rts
                ENDPART
__do_ipol:      >PART
                subq.w  #1,ipol_steps_counter
                bpl.s   dim
                move.l  A0,script_pos
dim:
                rts
                ENDPART

;-------------------------------------
fade:           >PART
                movem.l (A0)+,A1-A2
                movem.l A1-A2,pal0_mf
                move.l  A0,script_pos
                clr.w   fade_num
                clr.w   fade_scounter
                rts
                ENDPART
wait_fade:      >PART
                lea     fade_scounter(PC),A1
                subq.w  #1,(A1)
                bpl.s   wfn
                move.w  fade_speed(PC),(A1)

                lea     fade_num(PC),A1
                move.w  (A1),D0
                bsr.s   fade_hw

                addq.w  #1,(A1)
                cmpi.w  #8,(A1)
                ble.s   wfn
                move.w  #8,(A1)
                move.l  A0,script_pos
wfn:
                rts
                ENDPART
set_fade_speed: >PART
                move.l  (A0)+,D0
                move.w  D0,fade_speed
                move.l  A0,script_pos
                rts
                ENDPART
white:          DS.W 16,$00000777
;-------------------------------------------------------------------------------
; pal0_mf + 0   src
; pal0_mf + 4   dest
; D0...fade_factor
fade_hw:        >PART
*    DC.L $4AFC4E71

                movem.l D0-A6,-(SP)

                move.w  D0,-(SP)        ; fade factor
mfl_fades:
                move.w  (SP),D7         ; fade1
                moveq   #8,D6
                sub.w   D7,D6           ; fade0

                movem.l pal0_mf(PC),A0-A1

                lea     $FFFF8240.w,A6  ; *** DEBUG ***

                move.w  #16-1,-(SP)     ; amount colors
mfl_colors:

; D0.r  D1.g  D2.b
                move.w  (A0)+,D0        ; rgb
                moveq   #7,D2
                and.w   D0,D2           ; b
                lsr.w   #4,D0
                moveq   #7,D1
                and.w   D0,D1           ; g
                lsr.w   #4,D0           ; r
; D0.r  D1.g  D2.b

; D3.r  D4.g  D5.b
                move.w  (A1)+,D3        ; rgb
                moveq   #7,D5
                and.w   D3,D5           ; b
                lsr.w   #4,D3
                moveq   #7,D4
                and.w   D3,D4           ; g
                lsr.w   #4,D3           ; r

                mulu    D6,D0           ; f0
                mulu    D6,D1           ; f0
                mulu    D6,D2           ; f0

                mulu    D7,D3           ; f1
                mulu    D7,D4           ; f1
                mulu    D7,D5           ; f1

                add.w   D3,D0           ; r mix
                add.w   D4,D1           ; g mix
                add.w   D5,D2           ; b mix

                lsr.w   #3,D0
                lsr.w   #3,D1
                lsr.w   #3,D2

                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

*  move.w  D0,(A2)+        ; output

                move.w  D0,(A6)+        ; debug hwcols

                subq.w  #1,(SP)
                bpl.s   mfl_colors
                addq.l  #2,SP

*   addq.w  #1,(SP)
*   cmpi.w  #8,(SP)         ; 0...8
*   ble.s   mfl_fades

                addq.l  #2,SP

                movem.l (SP)+,D0-A6

                rts

pal0_mf:        DC.L 0,0

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------------------------------------------------------------


IPOL_STEP_BITS  EQU 6
IPOL_STEPS      EQU 1<<IPOL_STEP_BITS

ipol_main:      >PART

                lea     ipol_current,A0
                lea     result,A1

im_startjmp:    jmp     0

im_start:
; fastest linear interpolation
a:
                REPT IPOL_PTS_MAX

                move.w  (A0),(A1)+      ; x int                2b
                addi.l  #'CPT!',(A0)+   ; 16:16 interpolate    6b
                move.w  (A0),(A1)+      ; y int                2b
                addi.l  #'CPT!',(A0)+   ; 16:16 interpolate    6b

                ENDR
im_end:
im_size         SET (im_end-im_start)/IPOL_PTS_MAX
                rts

                ENDPART

; A0,A1
ipol_init:      >PART

                move.w  #IPOL_STEPS,ipol_steps_counter

                move.w  (A0)+,D0        ; points
                move.w  (A1)+,D1        ; points

                lea     im_start(PC),A2

                move.w  #IPOL_PTS_MAX,D1
                sub.w   D0,D1
                mulu    #im_size,D1
                adda.l  D1,A2
                move.l  A2,im_startjmp+2
                addq.l  #2+2,A2         ; code modi start

                lea     ipol_current,A3

                move.w  D0,D6
                subq.w  #1,D6
                move.w  D6,amount_points
iil:
; x
                move.w  (A0)+,D0        ; x0
                move.w  (A1)+,D1        ; x1
                sub.w   D0,D1           ; x1-x0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A2)
                addq.l  #8,A2

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; x0<<16   ipol_current.x
; y
                move.w  (A0)+,D0        ; y0
                move.w  (A1)+,D1        ; y1
                sub.w   D0,D1           ; y1-y0
                swap    D1
                clr.w   D1
                asr.l   #IPOL_STEP_BITS,D1
                move.l  D1,(A2)
                addq.l  #8,A2

                swap    D0
                clr.w   D0
                move.l  D0,(A3)+        ; y0<<16   ipol_current.y

                dbra    D6,iil
                rts

                ENDPART

ipol_output:    >PART

                lea     result,A0
                movea.l screen1,A1
                move.w  amount_points(PC),D6
io_l:
                move.w  (A0)+,D0        ;x
                move.w  (A0)+,D1        ;y
                add.w   #160,D0
                add.w   #100,D1

                muls    #160,D1

                moveq   #15,D2
                and.w   D0,D2
                move.w  #$8000,D3
                lsr.w   D2,D3

                asr.w   #1,D0
                and.w   #-8,D0
                add.w   D1,D0

                or.w    D3,0(A1,D0.w)

                dbra    D6,io_l
                rts

                ENDPART


ipol_steps_counter:DC.W 0
amount_points:  DC.W 0

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

