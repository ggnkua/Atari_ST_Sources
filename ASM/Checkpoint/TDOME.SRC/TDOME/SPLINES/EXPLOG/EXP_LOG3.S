;-------------------------------------------------------------------------------
;
; EXP,LOG multiplication                           (w)2010 lsl&Defjam/Checkpoint
;                                                     2011
;-------------------------------------------------------------------------------
LOGS            EQU 4096        ; 1024
EXPS            EQU 4096

EXP_RESULT_DESC_BITS EQU 9

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;*** FIXED: Multiplication with 0 ***  (table adjusted)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                OPT D+
;-------------------------------------------------------------------------------
                bsr     init_exp_log
;-------------------------------------------------------------------------------
exp_log_test:   PART
                DC.L $4AFC4E71

                lea     logtab0,A0
                lea     exptab0,A1
tloop:
*    move.w  #23,D0
*    move.w  #-23,D1

                move.w  #2400,D0
                move.w  #2400,D1

                add.w   D0,D0
                add.w   D1,D1

                move.w  0(A0,D0.w),D2   ; log(a)
                move.w  0(A0,D1.w),D3   ; log(b)
                add.w   D2,D3           ; log(a)+log(b)
                move.w  0(A1,D3.w),D0   ; exp( log(a) + log(b)
                ext.l   D0

                moveq   #EXP_RESULT_DESC_BITS,D7
                asl.l   D7,D0

                DC.L $4AFC4E71

a_:             DC.W 0
b_:             DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
init_exp_log:   >PART
*    DC.L $4AFC4E71

                bsr.s   init_log
                bsr.s   init_exp
                rts
                ENDPART
init_log:       >PART
                lea     log_src+2,A4    ; skip 0

                lea     logtab0,A0      ; pos
                lea     (A0),A1         ; neg

                move.w  #-EXPS*2,(A0)+  ; NULL

                move.w  #LOGS-1-1,D7
il:
                move.w  (A4)+,D0        ; log

                add.w   D0,D0

                move.w  D0,(A0)+        ; pos

                add.w   #EXPS*2,D0      ; NEG
                move.w  D0,-(A1)        ; neg

                dbra    D7,il
                rts
                ENDPART
init_exp:       >PART

                move.w  #EXPS*2,D7

                lea     exp_src,A4

                lea     exptab0,A0

; A0  pos
; A1  NEG
; A2  pos  (NEG*NEG->pos)
; A3  NULL

                lea     0(A0,D7.w),A1
                lea     0(A1,D7.w),A2

                move.w  #EXPS-1,D7
ie:
                move.w  (A4)+,D0
                move.w  D0,D1
                neg.w   D1

                move.w  D0,(A0)+        ; pos
                move.w  D1,(A1)+        ; NEG
                move.w  D0,(A2)+        ; pos  (NEG*NEG->pos)

                dbra    D7,ie
                rts
                ENDPART

log_src:        IBYTES 'LOG.TAB'
exp_src:        IBYTES 'EXP.TAB'
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                BSS
                PART ' exp log BSS '
                DS.W LOGS       ; negative values
logtab0:        DS.W LOGS       ; positive values

                DS.W EXPS*2     ; NULL
exptab0:
                DS.W EXPS       ; pos
                DS.W EXPS       ; NEG
                DS.W EXPS       ; pos  (NEG*NEG->pos)
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                END
