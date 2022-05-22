

;
; V-II Turbo Z clipper!  Fast off-plane checks and best cycles on worst case!
; I would say its a cool 10% faster now; even faster on more complex objects as
; it now does the 'fast' clip test and should run in a cache just peachy, since
; it is now entirely register-based, apart from one out-of-loop store!  Now I'll
; put on the dark glasses...
;
; Best maths version of similar triangles - new version here uses the greater
; extent of the line past Z clip for coherent results!  Oho!  I'm lengthy!
;
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
; Clips face at CURRFC (or one poly!).

z_clip_face:
                movea.l currfc(PC),A3   ; Get current face address.
                move.l  A3,thisface     ; Store for reference.
                move.l  (A3)+,colour    ; Get colour and type.
                bmi     noface          ; Negative - no more faces.
                cmpi.w  #2,type         ; Yikes!  Check for circle!
                beq     drawcircle
                movea.l A3,A6           ; Get adress for later ops.
                move.w  (A3)+,p_data    ; Get data.
                move.l  (A3)+,D0        ; Get number of points (skips face adj).
                movea.l A3,A5
                move.w  D0,poly         ; Store at poly list.
                addq.w  #1,D0           ; Adjust because of DBRA.
                movea.w D0,A4           ; Store points to do in z clip counter.

                lea     rotted(PC),A0   ; Get rotated points address.
                lea     poly+2(PC),A1   ; Get link coordinates address.
                movea.l #0,A2           ; Set coordinate counter to 0.

                move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.
                movem.w D0-D2,first_vals ; Store for wrap.
                bra.s   special_join    ; Skip loopback bit.

zloop_main:     move.w  (A3)+,D0        ; Get link pointer.
                movem.w 0(A0,D0.w),D0-D2 ; Get X,Y,Z.
                move.w  (A3),D3         ; Get next link pointer.
                movem.w 0(A0,D3.w),D3-D5 ; Get next points' X,Y,Z.
special_join:
                cmp.w   D2,D5           ; Check for largest extent.
                blt     z_ok1           ; Points in clockwise order, both used.
; Else points in anticlockwise order (going back) store only one point.
                exg     D2,D5           ; But first, sort 'em (major axis).
                exg     D0,D3
                exg     D1,D4
                cmp.w   #hither*8,D2    ; Quick reject test.
                blt.s   discard_both_a
                cmp.w   #hither*8,D5
                bgt.s   in_range_swp

                move.w  #hither*8,D6
                sub.w   D5,D6           ; Zmax-Z2
                move.w  D2,D7
                sub.w   #hither*8,D7    ; Z1-Zmax
                sub.w   D2,D5           ; Z2-Z1

                sub.w   D3,D0           ; X1-X2
                muls    D6,D0
                neg.w   D5              ; Now Z1-Z2
                divs    D5,D0
                add.w   D0,D3           ; Add to X2

                sub.w   D4,D1           ; Y1-Y2
                muls    D6,D1
                divs    D5,D1
                add.w   D1,D4           ; Add to Y2.

;                asr.w   #1,D3           ; Scale up.
;                asr.w   #1,D4           ; Scale up.
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.
                addq.w  #1,A2           ; Add 1 new point.

; Now check for next point...
discard_both_a:
                subq.w  #1,A4           ; Minus one point done...
                cmpa.w  #1,A4           ; Last point?
                bgt.s   zloop_main      ; If not, continue Z clipping...
                beq.s   last_zpnt_a     ; If last, then do one last 'join'.
                bra     finished_z      ; <=0, all points done, exit.
last_zpnt_a:
                move.w  (A3)+,D0        ; Yes, so we get last point
                movem.w 0(A0,D0.w),D0-D2 ; and make the second end
                movem.w first_vals(PC),D3-D5 ; the first point.
                bra.s   special_join    ; And do the clip.

in_range_swp:
                asl.l   #8,D4
                asl.l   #8,D3           ; Scale up.
                divs    D5,D3           ; And do perspective (/ Z + Horizon).
                divs    D5,D4           ; And do perspective (/ Z + Horizon).
                add.w   #scx,D3         ; Add X screen center.
                add.w   #scy,D4         ; Add Y screen center.
                addq.w  #1,A2           ; Add ONE new point to list.
                move.w  D3,(A1)+        ; Store X.
                move.w  D4,(A1)+        ; Store Y.

; Now check for next point...
                subq.w  #1,A4           ; Minus one point done...
                cmpa.w  #1,A4           ; Last point?
                bgt     zloop_main      ; If not, continue Z clipping...
                beq.s   last_zpnt_a     ; If last, then do one last 'join'.
                bra     finished_z      ; <=0, all points done, exit.

z_ok1:
; Points in clockwise (going forward) order, store both.
                cmp.w   #hither*8,D2    ; First, a quick reject test!
                blt.s   discard_both_b
                cmp.w   #hither*8,D5
                bgt.s   in_range

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

                move.w  #hither*8,D6
                sub.w   D5,D6           ; Zmax-Z2
                move.w  D2,D7
                sub.w   #hither*8,D7    ; Z1-Zmax
                sub.w   D2,D5           ; Z2-Z1

                sub.w   D3,D0           ; X1-X2
                muls    D6,D0
                neg.w   D5              ; Now Z1-Z2
                divs    D5,D0
                add.w   D0,D3           ; Add to X2

                sub.w   D4,D1           ; Y1-Y2
                muls    D6,D1
                divs    D5,D1
                add.w   D1,D4           ; Add to Y2.

;                asr.w   #1,D3           ; Scale up.
;                asr.w   #1,D4           ; Scale up.
                add.w   #scx,D3         ; Add screen's X center.
                add.w   #scy,D4         ; Add screen's Y center.
                move.w  D3,(A1)+        ; Store screene'd X.
                move.w  D4,(A1)+        ; Store screene'd Y.
                addq.w  #2,A2           ; Add 2 new points.

; Now check for next point...
discard_both_b:
                subq.w  #1,A4           ; Minus one point done...
                cmpa.w  #1,A4           ; Last point?
                bgt     zloop_main      ; If not, continue Z clipping...
                beq.s   last_zpnt_b     ; If last, then do one last 'join'.
                bra.s   finished_z      ; <=0, all points done, exit.
last_zpnt_b:
                move.w  (A3)+,D0        ; Yes, so we get last point
                movem.w 0(A0,D0.w),D0-D2 ; and make the second end
                movem.w first_vals(PC),D3-D5 ; the first point.
                bra     special_join    ; And do the clip.
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

; Now check for next point...
                subq.w  #1,A4           ; Minus one point done...
                cmpa.w  #1,A4           ; Last point?
                bgt     zloop_main      ; If not, continue Z clipping...
                beq.s   last_zpnt_b     ; If last, then do one last 'join'.
                bra.s   finished_z      ; <=0, all points done, exit.

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


