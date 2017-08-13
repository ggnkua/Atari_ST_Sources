;------------------------------------------------------
get_x_offsets:  >PART

*   DC.L $4AFC4E71

;;;     lea     uv_map,A0
                lea     uv_X,A0

                lea     x_offsets(PC),A1
                lea     x_offsets_delta(PC),A2

                moveq   #0,D1           ; prev

                move.w  (A0),D0         ; 1st u
                move.w  D0,D5
                and.w   #-2,D0
                move.w  D0,first_x_offset

                moveq   #-4,D6
                move.w  #UV_X/4-1,D7
go_x:
                move.w  (A0)+,D0
                sub.w   D5,D0           ; -1st u

                and.w   D6,D0

                move.w  D0,(A1)+        ; x_offsets

                sub.w   D1,D0           ;-prev

                move.w  D0,(A2)+        ; x_offsets_delta

                add.w   D0,D1           ; prev

                dbra    D7,go_x

                move.w  #4,(A2)+        ; x_offsets_delta END

                lea     x_offsets_delta(PC),A0

                rts
                ENDPART
get_y_offsets:  >PART

*   DC.L $4AFC4E71

;;;     lea     uv_map+2,A0
                lea     uv_Y,A0

                lea     y_offsets(PC),A1

                moveq   #0,D1           ; prev

                move.w  #UV_Y-1,D7
go_y:
                move.w  (A0)+,D0
                mulu    #XW,D0

                move.l  D0,(A1)+

;  sub.l   D1,D0           ; -prev
;  move.w  D0,(A1)+
;  add.l   D0,D1
                dbra    D7,go_y

                lea     y_offsets(PC),A0

                rts
                ENDPART
;------------------------------------------------------

