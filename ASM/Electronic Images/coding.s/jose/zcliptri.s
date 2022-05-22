; Z clipper routine.  New and improved, it is greener and uses less of the
; world's resources by using 0.00000000001 volts less to calculate the Z plane
; clipped coordinates!  Nowadays I've been thinking of other processors (030 and
; 040) that have divides of 20 cycles (for 030) and 1 (for 040!!), which means
; that the midpoint subdivision routine is slower, since it will execute more
; instructions (loads more) and there's no more advantage over the divide (which
; takes a bloody 140 cycles on a 68000!!).  Even now, I think this way is faster
; than the midpoint!!  It seems more colinear too, resulting in less jitter; it
; is now impossible to lock the machine (since there's no midpoint routine to
; search for a number it can't find!), so there you go!
; There is one downside to all this - roundoff errors occur, making polygons
; sharing the same point become disjoint.  Maybe I'll code in a roundoff adjust
; one day!
; Clips face at CURRFC (or one poly!).

z_clip_face:
                movea.l currfc(PC),A3   ; Get current face address.
                move.l  A3,thisface     ; Store for reference.
                move.l  (A3)+,colour    ; Get colour and type.
                bmi     noface          ; Negative - no more faces.
                cmpi.w  #3,type         ; Yikes!  Check for circle!
                beq     drawcircle
                movea.l A3,A6           ; Get adress for later ops.
                move.w  (A3)+,p_data    ; Get data.
                move.l  (A3)+,D0        ; Get number of points (skips face adj).
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

                sub.w   D0,D3           ; X1-X0
                move.w  #hither,D6      ; Z clip plane.
                sub.w   D2,D6           ; Zt-Z0
                muls    D3,D6           ; (X1-X0)*(Zt-Z0)
                sub.w   D2,D5           ; Z1-Z0
                divs    D5,D6           ; (X1-X0)*(Zt-Z0)/(Z1-Z0)
                add.w   D6,D0           ; +X0 is new X.

                sub.w   D1,D4           ; Y1-Y0
                move.w  #hither,D6      ; Z clip plane.
                sub.w   D2,D6           ; Zt-Z0
                muls    D4,D6           ; (Y1-Y0)*(Zt-Z0)
                divs    D5,D6           ; Use Z1-Z0 from above (same op).
                add.w   D6,D1           ; +Y0 is new Y.

;                illegal
                asl.w   #3,D0           ; Scale up.
                asl.w   #3,D1           ; Scale up.
                add.w   #scx,D0         ; Add screen's X center.
                add.w   #scy,D1         ; Add screen's Y center.
                move.w  D0,(A1)+        ; Store screene'd X.
                move.w  D1,(A1)+        ; Store screene'd Y.
                addq.w  #2,A2           ; Add 2 new points.
; Since 1 inclusive.
                bra.s   continue_zclip  ; Cont the clip.

point_2_out:
                sub.w   D0,D3           ; X1-X0
                move.w  #hither,D6      ; Z clip plane.
                sub.w   D2,D6           ; Zt-Z0
                muls    D3,D6           ; (X1-X0)*(Zt-Z0)
                sub.w   D2,D5           ; Z1-Z0
                divs    D5,D6           ; (X1-X0)*(Zt-Z0)/(Z1-Z0)
                add.w   D6,D0           ; +X0 is new X.

                sub.w   D1,D4           ; Y1-Y0
                move.w  #hither,D6      ; Z clip plane.
                sub.w   D2,D6           ; Zt-Z0
                muls    D4,D6           ; (Y1-Y0)*(Zt-Z0)
                divs    D5,D6           ; Use Z1-Z0 from above (same op).
                add.w   D6,D1           ; +Y0 is new Y.

                asl.w   #3,D0           ; Scale up.
                asl.w   #3,D1           ; Scale up.
                add.w   #scx,D0         ; Add screen's X center.
                add.w   #scy,D1         ; Add screen's Y center.
                move.w  D0,(A1)+        ; Store screene'd X.
                move.w  D1,(A1)+        ; Store screene'd Y.

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
* (Ahem!  Above was when I attempted an on-the fly-zclip clockwise check!)

