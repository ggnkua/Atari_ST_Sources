; Z clipper routine.  Uses midpoint subdivsion for more accurate calcs.
; Midpoints are slower than a similar triangle divide, but are acurate to
; a full 32 bits, and that's essential with low Z clip planes.
; Clips face at CURRFC (or one poly!).
; This is an optimized version...  The midpoint parameters I left out; check
; file 'ZCLIP.S' for the register usage (though U can see here anyway!).

z_clip_face:
                movea.l currfc(PC),A3   ; Get current face address.
                move.l  A3,thisface     ; Store for reference.
                move.l  (A3)+,colour    ; Get colour and type.
                bmi     noface          ; Negative - no more faces.
                cmpi.w  #3,type         ; Yikes!  Check for circle!
                beq     drawcircle
                movea.l A3,A6
                move.w  (A3)+,p_data    ; Get data.
                move.l  (A3)+,D0        ; Get number of points.
                movea.l A3,A5
                move.w  D0,poly         ; Store at poly list.
                addq.w  #1,D0           ; Adjust because of DBRA.
                move.w  D0,z_counter    ; Store in z clip counter.

                lea     rotted(PC),A0   ; Get rotated points address.
                lea     poly+2(PC),A1   ; Get link coordinates address.
                movea.l #0,A2           ; Set coordinate counter to 0.

                move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.
                movem.w D0-D2,first_vals ; Store for wrap.
                bra.s   skip_mama       ; Skip loopback bit.

mama:           move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.

skip_mama:      moveq   #0,D6           ; Line clip flag to 0.
                cmpi.w  #hither,D2      ; First point past plane?
                bgt.s   nozedp1         ; No...  Skip.
                bset    #0,D6           ; Yes, set clip flag 1.
nozedp1:        cmpi.w  #hither,D5      ; Second point past plane?
                bgt.s   nozedp2         ; No...  Skip.
                bset    #1,D6           ; Yes, set clip flag 2.
nozedp2:
                tst.w   D6              ; D6 = 0?
                beq     in_range        ; > Both points in range.

                cmpi.w  #3,D6           ; Both points out?
                beq     discard_both    ; Yep, discard line.

                btst    #1,D6           ; Point 2 out?
                beq.s   point_2_out     ; Yep, go clip that one.
                move.l  D1,D6           ; Else calc screen coords.
                move.l  D0,D7           ; Store 'em since used later for midP.
                asl.l   #8,D1           ; Scale up.
                asl.l   #8,D0           ; Scale up.
                divs    D2,D0           ; And do perspective (/ Z + Horizon).
                divs    D2,D1           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D0         ; Add screen's X center.
                add.w   #scy,D1         ; Add screen's Y center.
                move.w  D0,(A1)+        ; Store screene'd X.
                move.w  D1,(A1)+        ; Store screene'd Y.
                move.l  D6,D1           ; Restore for midpoint calculations.
                move.l  D7,D0

                move.w  #hither,D6      ; Get Z clip plane.

                cmp.w   D2,D5           ; Is D0>D1? (Z2>Z1)
                bgt.s   binary_search1  ; Yes...  Don't interchange.
                exg     D2,D5           ; No...  Interchange them.
                exg     D0,D3
                exg     D1,D4
binary_search1:
                movea.w D3,A4           ; Store X2.
                movea.w D4,A5           ; Store Y2.
                add.w   D0,D3           ; X1+X2.
                asr.w   #1,D3           ; / 2.
                add.w   D1,D4           ; Y1+Y2.
                asr.w   #1,D4           ; / 2.

                move.w  D5,D7           ; Store for calculation.
                add.w   D2,D7           ; Z1 + Z2.
                asr.w   #1,D7           ; Divide by 2; midpoint.
                cmp.w   D7,D6           ; Compare them.
                bgt.s   use_a1          ; Greater than destination...  Use A.
                beq.s   search_found1   ; Same...  Found match.
                move.w  D7,D5           ; Smaller...  Z2=Zm.  Use B.
                bra.s   binary_search1  ; Continue search.
use_a1:         move.w  D7,D2           ; Z1=Zm...  Use A.
                move.w  D3,D0           ; X1=Xm.
                move.w  D4,D1           ; Y1=Ym.
                move.w  A4,D3           ; Restore X2.
                move.w  A5,D4           ; Restore Y2.
                bra.s   binary_search1  ; Continue search.
search_found1:
                ext.l   D3
                ext.l   D4

                move.w  #hither,D2      ; Get Z clip plnae.
                asl.l   #8,D4           ; Scale up.
                asl.l   #8,D3           ; Scale up.
                divs    D2,D3           ; And do perspective (/ Z + Horizon).
                divs    D2,D4           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.
                addq.w  #2,A2           ; Add 2 new points.
; Since 1 inclusive.
                bra.s   continue_zclip  ; Cont the clip.

point_2_out:
                move.w  #hither,D6      ; Get Z clip plane.

                cmp.w   D2,D5           ; Is D0>D1? (Z2>Z1)
                bgt.s   binary_search2  ; Yes...  Don't interchange.
                exg     D2,D5           ; No...  Interchange them.
                exg     D0,D3
                exg     D1,D4
binary_search2:
                movea.w D3,A4           ; Store X2.
                movea.w D4,A5           ; Store Y2.
                add.w   D0,D3           ; X1+X2.
                asr.w   #1,D3           ; / 2.
                add.w   D1,D4           ; Y1+Y2.
                asr.w   #1,D4           ; / 2.

                move.w  D5,D7           ; Store for calculation.
                add.w   D2,D7           ; Z1 + Z2.
                asr.w   #1,D7           ; Divide by 2; midpoint.
                cmp.w   D7,D6           ; Compare them.
                bgt.s   use_a2          ; Greater than destination...  Use A.
                beq.s   search_found2   ; Same...  Found match.
                move.w  D7,D5           ; Smaller...  Z2=Zm.  Use B.
                bra.s   binary_search2  ; Continue search.
use_a2:         move.w  D7,D2           ; Z1=Zm...  Use A.
                move.w  D3,D0           ; X1=Xm.
                move.w  D4,D1           ; Y1=Ym.
                move.w  A4,D3           ; Restore X2.
                move.w  A5,D4           ; Restore Y2.
                bra.s   binary_search2  ; Continue search.
search_found2:
                ext.l   D3
                ext.l   D4

                move.w  #hither,D2      ; Get Z clip plane.
                asl.l   #8,D4           ; Scale up.
                asl.l   #8,D3           ; Scale up.
                divs    D2,D3           ; And do perspective (/ Z + Horizon).
                divs    D2,D4           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.

                addq.w  #1,A2           ; Add ONE new point to list.
; Since 1 is out.
                bra.s   continue_zclip  ; Continue Z clip.

in_range:
                asl.l   #8,D1
                asl.l   #8,D0           ; Scale up.
                divs    D2,D0           ; And do perspective (/ Z + Horizon).
                divs    D2,D1           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D0         ; Add X screen center.
                add.w   #scy,D1         ; Add Y screen center.
                addq.w  #1,A2           ; Add ONE new point to list.
                move.w  D0,(A1)+        ; Store X.
                move.w  D1,(A1)+        ; Store Y.

continue_zclip:
discard_both:
                subq.w  #1,z_counter    ; Have we finished all points?
                beq.s   finished_z      ; Yep.  Go set new number of 'em.

                cmpi.w  #1,z_counter    ; No...  Last point?
                bne     mama            ; No...  Do Zclip.

                move.w  (A3)+,D0        ; Yes, so we get last point
                movem.w 0(A0,D0.w),D0-D2 ; and make the second end
                movem.w first_vals(PC),D3-D5 ; the first point.
                bra     skip_mama       ; And do the clip.

first_vals:     DS.W 3

finished_z:

                move.l  A3,currfc       ; Store next poly addr.

                move.w  A2,D0           ; Copy it to a data register.  Duuuh!
                cmp.w   #3,D0           ; Check if poly is outside the Z plane.
                blt     z_clip_face     ; Yep...  Don't draw it!
                subq.w  #1,D0           ; Now adjust No of points to DBRA.
                move.w  D0,poly         ; And store it.

*                bra.s   skipclock       ; Don't do another clockwise check!
* (Ahem!  Above was when I attempted a on-the fly-zclip clockwise check!)

