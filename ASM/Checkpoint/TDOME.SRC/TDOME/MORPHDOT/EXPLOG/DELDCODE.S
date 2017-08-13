;---------------------------------------------------------
;
; normal 2bit delta decoder
;
; A0...delta stream
; A1...output
;
; D5...current value
;
                move.w  (A0)+,D0        ; get 16 bit -> 8 deltas
                REPT 8
                rol.w   #2,D0           ; get 2 bit
                moveq   #3,D1           ; 2 bit mask
                and.w   D0,D1           ; get & mask
                add.w   D1,D5           ; value+=delta
                move.w  D5,(A1)+        ; output value
                ENDR

;---------------------------------------------------------
;
; table-based 2bit delta decoder
;
; A0...delta stream
; A1...output
; A2...delta table
;
; D5...current value
;
                moveq   #0,D0
                move.b  (A0)+,D0        ; 4 deltas
                lsl.w   #2+1,D0         ; 4 combinations, 16 bit each
                lea     0(A2,D0.w),A3   ; pointer to delta table
                REPT 4
                add.w   (A3)+,D5
                move.w  D5,(A1)+
                ENDR

;---------------------------------------------------------

