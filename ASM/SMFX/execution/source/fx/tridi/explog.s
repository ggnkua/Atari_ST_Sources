; explog
; assumes pointers to be initialized
; assumes lower memory to be available
;
; todo:
;   - write out exactly where this memory resides
;

;   
LOGS            	EQU 1024
EXPS            	EQU 4096

pivotexp            equ $2800

    SECTION BSS
explog_logpointer			ds.l	1		; 64k aligned
explog_expointer			ds.l	1		; 64k aligned

    SECTION DATA
_log_src:        incbin     lib/explog/LOG.TAB
_exp_src:        incbin     lib/explog/EXP.TAB
    even

	SECTION TEXT
init_exp_log:

.init_log:      
    lea     _log_src,A4    		; skip 0
    move.l  explog_logpointer,a2
    move.l  a2,a3
    add.l   #$10000,a3
    moveq   #-2,d6           	; index
    move.w  #EXPS*2,(A2)+  	; NULL                      ; I changed this, no more bugs
    move.w  #LOGS-1-1,D7
.il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0

    	move.w  d0,(a2)+        ; pos2
    	add.w   #EXPS*2,D0      ; NEG
;    	move.w  d6,d5           ; take negative value into account
 ;   	move.l  d5,a3


    	move.w  d0,-(a3)         ; move in value

  ;  	subq.w  #2,d6
    dbra    D7,.il

.init_exp:      
    move.w  #EXPS*2,D7                          ; d7 = 8096
    lea     _exp_src,a3
    move.l	explog_expointer,a0                 ;  a0 = xxxx0000-xxxx2000
    lea		(a0,d7.w),a1                        ;  a1 = xxxx2000-xxxx4000
    lea		(a1,d7.w),a2                        ;  a2 = xxxx4000-xxxx6000
    move.w  #-4,d6
    move.w  #EXPS-1,D7
.ie:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1
    	; this is specific for the rotation code
        and.w   d6,d0
        and.w   d6,d1


		move.w  d0,(a0)+
		move.w  d1,(a1)+
		move.w  d0,(a2)+
    dbra    D7,.ie

init_exp_low:    
	lea		pivotexp-$2000,a0
    move.w  #-4,d6
	moveq	#0,d0
.cl
		move.l	d0,(a0)+
		cmp.w	#pivotexp,a0
		bne		.cl

    move.w  #EXPS*2,D7
    lea     _exp_src,a3
    lea  	pivotexp,a4           ; $4000
    lea     (a4,d7.w),a5          ; $6000
    lea     (a5,d7.w),a6          ; $8000
    move.w  #EXPS-1,D7            ; $
.ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

  		asr.w	#6,d0
		asr.w	#6,d1
        and.w   d6,d0
        and.w   d6,d1

		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+
    dbra    D7,.ie2
    rts

    