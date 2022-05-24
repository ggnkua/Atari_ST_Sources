; 3D world shite

demo		EQU 0

os              EQU 0           ; 1 leave interrupts on.  0=off.

scx             EQU 159
scy             EQU 79

hither          EQU 64          ; Nearest to viewer Z clip window.
yonder          EQU 32767       ; Furthest to viewer (no object) window.


		ifeq demo
		clr.w -(sp)
		pea -1.w
		pea -1.w
		move.w #5,-(sp)
		trap #14
		lea 12(sp),sp
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

		elseif

		org $10000

		endc

		move.l sp,oldspmine
		move.l #mystack,a7

                lea     screens+256(PC),A0
                move.l  A0,D0
                clr.b   D0
                move.l  D0,scrn1
                add.l   #32000,D0
                move.l  D0,scrn2
                add.l   #32000,D0
                move.l  D0,scrn3

                movea.l scrn1(PC),A0
                move.w  #5999,D0
                moveq   #0,D1
clean:          move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,clean
		ifne demo
		jsr	$508
		endc


                lea     $FFFF8240.w,A0
                move.w  #$00,(A0)+      ; 0
                move.w  #$0667,(A0)+    ; 1
                move.w  #$0445,(A0)+    ; 2
                move.w  #$0223,(A0)+    ; 3
                move.w  #$0110,(A0)+    ; 4
                move.w  #$0332,(A0)+    ; 5
                move.w  #$0554,(A0)+    ; 6

                move.w  #$0444,(A0)+    ; 7

                move.w  #$0700,(A0)+    ; 8
                move.w  #$0770,(A0)+    ; 9

                move.w  #$0274,(A0)+    ; 10
                move.w  #$62,(A0)+      ; 11
                move.w  #$30,(A0)+      ; 12

                move.w  #$0751,(A0)+    ; 13
                move.w  #$0630,(A0)+    ; 14
                move.w  #$0776,(A0)+    ; 15

                move    #$2700,SR
                move.l  $70.w,oldvbl
                move.l  $0110.w,dsave   ; Install difference counter.
                move.l  #vbl,$70.w
                move.l  #divzero,$14.w
                move.b  $FFFFFA07.w,sa1
                move.b  $FFFFFA09.w,sa2
                move.b  $FFFFFA15.w,sa3
                move.b  $FFFFFA1D.w,sa4
                move.b  $FFFFFA25.w,sa5
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                clr.b   $FFFFFA13.w
                clr.b   $FFFFFA15.w
                bclr    #3,$FFFFFA17.w
                move.l  #divzero,$0110.w ; A dummy RTE
                ori.b   #%10000,$FFFFFA09.w
                ori.b   #%10000,$FFFFFA15.w
                move.b  #0,$FFFFFA1D.w
                move.b  #1,$FFFFFA25.w  ; 48 Hz.
                move.b  #7,$FFFFFA1D.w
                move    #$2300,SR

                move.b  lcount(PC),D0
.sync1          cmp.b   lcount(PC),D0
                beq.s   .sync1
                move.b  lcount(PC),D0
.sync2          cmp.b   lcount(PC),D0
                beq.s   .sync2

                move.w  #0,D0
                move.w  #512,D2
                move.w  #512,D4
                lea     ob_matrix(PC),A0
                bsr     make_matrix
                lea     ob_matrix(PC),A0
                lea     house+18(PC),A2 ; Get destination poly address.
                lea     dummy(PC),A4    ; Coordinate offset.
                lea     house+16,A1
                move.w  (A1)+,D7        ; Get number of points -1.
                bsr     rotate_object


key:


                move.b  lcount(PC),D0
                bne.s   over
sync:           cmp.b   lcount(PC),D0
                beq.s   sync

over:           clr.b   lcount
                move.l  scrn2(PC),D0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                move.l  scrn1(PC),-(SP)
                move.l  scrn2(PC),scrn1
                move.l  scrn3(PC),scrn2
                move.l  (SP)+,scrn3


*                move.w  #$03,$FFFF8240.w

                andi.b  #%11110000,$FFFFFA1D.w
                moveq   #0,D0
                move.w  step(PC),D0
                move.b  $FFFFFA25.w,D0
                clr.b   step+1
                move.w  fstep(PC),D1
                move.w  D0,fstep
                clr.b   $FFFFFA25.w
                ori.b   #%101,$FFFFFA1D.w
                sub.w   D0,D1
                ext.l   D1
                lsl.l   #8,D1
                divu    #310,D1
                move.w  D1,unit

*                clr.l   number
*                move.w  D1,number+2
*                move.b  #0,txpos
*                move.b  #180,typos
*                bsr     conv

*                tst.w   D2
*                bmi.s   ohno
*                cmpi.w  #$C8,D2
*                bge.s   uok
*ohno:
*                move.w  #$C8,unit
*                move.w  #$0300,$FFFF8240.w
*uok:

                moveq   #1,D0
                mulu    unit(PC),D0
                mulu    #330,D0
                swap    D0
                subq.w  #1,D0
                bge.s   d0ok
                moveq   #0,D0
d0ok:

                lea     frametab(PC),A0
                lsl.w   #8,D0
                add.w   D0,D0
                lea     0(A0,D0.w),A0
                move.l  A0,whichtab


                movea.l whichtab(PC),A0
                move.w  rotatex(PC),D0
                move.w  D0,D1
                sub.w   oldrx(PC),D0
                move.w  D1,oldrx
                bsr     getframe
                move.w  D0,usery
;
                move.w  rotatey(PC),D0
                move.w  D0,D1
                sub.w   oldry(PC),D0
                move.w  D1,oldry
                bsr     getframe
                move.w  D0,userx


                lea     object18(PC),A3
                move.w  #3,D0           ; Object X angle.
                bsr     getframe
                add.w   D0,10(A3)
                move.w  #8,D0           ; Object Y angle.
                bsr     getframe
                add.w   D0,12(A3)
                move.w  #1,D0           ; Object Z angle.
                bsr     getframe
                add.w   D0,14(A3)

                move.w  #2,D0
                bsr     getframe
                add.w   D0,8(A3)


                move.w  #34,D0
                bsr     getframe
                sub.w   D0,object11+4
                move.w  #12,D0
                bsr     getframe
                add.w   D0,object11+10

*                move.w  object11+4(PC),viewx
;                moveq   #0,D0
;                moveq   #0,D1
;                move.w  object11+4(PC),D0
;               move.w  viewx(PC),D1
;               sub.w   D1,D0
;                asr.w   #4,D0
;                neg.w   D0
;                move.w  D0,viewry
;                move.b  #10,txpos
;                move.b  #16,typos
;                move.w  D0,number+2
;                bsr     conv
*                addi.w  #400,viewx
*                move.w  #50,viewy
*                move.w  object11+8(PC),viewz




;                move.w  userx(PC),number+2
;                move.b  #30,txpos
;                move.b  #180,typos
;                bsr     conv

*                move.w  #1,userz

*                move.w  unit(PC),D1

                move.b  #0,txpos
                move.b  #0,typos
                move.w  D1,number+2
*                bsr     conv

                movea.l scrn2(PC),A0
                lea     32000(A0),A0
                move.w  #200,D7
                bsr     cls

;                move.b  #0,txpos
;                move.b  #0,typos
;                move.w  objects(PC),number+2
;                bsr     conv

                clr.w   objects
                clr.l   root

next_object:    movea.l oblist(PC),A0
                move.w  (A0),D0
                bmi.s   endobjects
                movea.l (A0)+,A1
                move.l  A1,curr_obj
                move.l  (A0)+,(A1)+
                move.w  (A0)+,(A1)+
                addq.w  #2,A1
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  A0,oblist
                bsr.s   sort_object
                bra.s   next_object

endobjects:     bsr     treesort
                lea     object1(PC),A0
                move.l  A0,oblist
                lea     obdraws(PC),A0
                move.l  A0,drawpointer
                bra     no_objects

objects:        DC.W 0

*       move.w  #$004,$ffff8240.w

;                >PART 'frame compensates and rotation'

sort_object:
                movea.l curr_obj(PC),A3 ; Get object address.

                movem.w userx(PC),D4-D6
                add.w   D4,viewrx
                add.w   D5,viewry
                add.w   D6,viewrz
                clr.l   userx           ; WANK!  Keeps adding to viewer!
                clr.w   userz           ; So this does the job!

                move.w  viewrx(PC),D0   ; X angle.
                move.w  viewry(PC),D2   ; Y angle.
                move.w  viewrz(PC),D4   ; Z angle.

                lea     view_matrix(PC),A0
                bsr     make_matrix

; Rotate object's position into OBX,OBY,OBZ respectively so we can check
; if object is within Z clip area/screen boundary after rotation.
                lea     view_matrix(PC),A0 ; Matrix in A0.
                movea.l A3,A1           ; Source in A1.
                lea     obx(PC),A2      ; Destination in A2.
                moveq   #0,D7           ; Number of points -1.
                bsr     rotate_view

; Check object against screen boundaries by parallel projecting it and using
; the object's with to the X and Y.

                moveq   #0,D2

                btst    #1,15(A3)
                bne     itsaroad

; Y check...
                moveq   #0,D0           ; Make sure upper D0 is clear.
                move.w  oby(PC),D0      ; Get Y position.
                bpl.s   posiy           ; Positive?  Skip.
                neg.w   D0              ; Negative...  Then make positive.
posiy:          sub.w   6(A3),D0        ; Subtract width.

*                cmp.w   6(A3),D0        ; Check it for center
*                bgt.s   notiny
*                addq.w  #1,D2

notiny:         ext.l   D0              ; Make it longword.
                lsl.l   #8,D0           ; Scale up.
                move.w  obz(PC),D1      ; Get Z.
                divs    D1,D0           ; Divide by Z (project it).
checky:         cmpi.w  #110,D0         ; Check it agains screen Y + leeway.
                bge     noface          ; If outside, discard object.

; X check...
                moveq   #0,D0
                move.w  obx(PC),D0
                bpl.s   posix
                neg.w   D0
posix:          sub.w   6(A3),D0

*                cmp.w   6(A3),D0
*                bgt.s   notinx
*                addq.w  #1,D2
notinx:
                ext.l   D0
                lsl.l   #8,D0
                move.w  obz(PC),D1
                divs    D1,D0
checkx:         cmp.w   #170,D0         ; Object is to eft or right of widow?
                bge     noface          ; Yep...  Don't rotate/draw it!

*                cmpi.w  #2,D2
*                bne.s   not_in_target
*                move.w  #$0700,$FFFF8240.w
*not_in_target:

itsaroad:
                move.w  #0,zclipflag    ; Set Z clip flag to be OFF.

                movea.l curr_obj(PC),A3

                move.w  obz(PC),D0      ; Get Z position of object.
                sub.w   6(A3),D0        ; Add width of object.
                cmpi.w  #hither+64,D0   ; Has it gone past clip plane?
                bgt.s   no_z_clip       ; No...  Don't clip.
                move.w  #1,zclipflag
*                move.w  #$0700,$FFFF8240.w ; Yes...  Clip.
no_z_clip:
                cmpi.w  #yonder,D0
                bgt     noface

                move.w  obz(PC),D0
                add.w   6(A3),D0
                cmpi.w  #hither,D0
                bgt.s   not_past_plane
*                move.w  #$70,$FFFF8240.w
                bra     noface
not_past_plane:

                addq.w  #1,objects

                movea.l drawpointer(PC),A0
                movea.l A0,A1
                lea     10(A0),A0
                movea.l curr_obj(PC),A2
                move.l  A2,(A0)+
                move.l  obx(PC),(A0)+   ; Object positions.
                move.w  obz(PC),(A0)+
                move.l  8(A2),(A0)+
                move.w  12(A2),(A0)+
                move.w  zclipflag(PC),(A0)+
                move.w  14(A2),(A0)+
                move.l  A0,drawpointer

                move.w  obz(PC),D0
                btst    #1,15(A2)
                beq.s   noroad
                move.w  #32767,D0
noroad:         bsr     insert

                rts

*                eori.w  #$0777,$FFFF8240.w

draw_object:
                lea     10(A1),A1       ; Skip sort thang.
                movea.l (A1)+,A3
                move.l  A3,curr_obj
                move.l  (A1)+,obx
                move.w  (A1)+,obz
                move.l  (A1)+,8(A3)
                move.w  (A1)+,12(A3)
                move.w  (A1)+,zclipflag
                move.w  (A1)+,14(A3)

; Now we rotate all those points.
                move.w  14(A3),D0       ; Get object flags.
                btst    #0,D0           ; Check for object rotation.
                bne.s   ob_rot          ; Yep...  So go to combine matrices.
                lea     view_matrix(PC),A0
                bra.s   do_ob_rots      ; Else use view matrix only.

ob_rot:         lea     ob_matrix(PC),A0
                move.w  8(A3),D0
                move.w  10(A3),D2
                move.w  12(A3),D4
                bsr     make_matrix
                lea     tot_matrix(PC),A0
                lea     view_matrix(PC),A1
                lea     ob_matrix(PC),A2
                bsr     mat_mul
                lea     tot_matrix(PC),A0

do_ob_rots:
                lea     rotted(PC),A2   ; Get destination poly address.
                movea.l curr_obj(PC),A1 ; Get object address.
                lea     obx(PC),A4      ; Coordinate offset.
                lea     16(A1),A1       ; Skip object positions etc.
                move.w  (A1)+,D7        ; Get number of points -1.
                bsr     rotate_object
                move.l  A1,currfc

;                ENDPART


;                >PART 'poly faces and Zclip'

nxtface:
                tst.w   zclipflag
                bne.s   z_clip_face

; Select points and copy them to the polygon list.
                movea.l currfc(PC),A0   ; Get current face address.
                lea     rotted(PC),A1   ; Get translated points address.
                lea     poly(PC),A2     ; Get address where to copy to.
                move.w  (A0)+,colour    ; Get colour.
                bmi     noface          ; Negative - no more faces.
                move.w  (A0)+,D0        ; Get number of points.
                move.w  D0,(A2)+        ; Store at poly list.
dopnts:         move.w  (A0)+,D1        ; Get offset
                movem.w 0(A1,D1.w),D1-D3 ; Get X,Y,Z.
                asl.l   #8,D1           ; Scale up X.
                asl.l   #8,D2           ; Scale up Y.
                divs    D3,D1           ; Do perspective.
                divs    D3,D2           ; Ditto.
                add.w   #scx,D1         ; Add screen offset.
                add.w   #scy,D2         ; Ditto.
                move.w  D1,(A2)+        ; Store X.
                move.w  D2,(A2)+        ; Store Y.
                dbra    D0,dopnts       ; Do for points.

                move.l  A0,currfc
                bra     cont_face


; Z clipper routine.  Uses midpoint subdivsion for more accurate calcs.
; Midpoints are slower than a similar triangle divide, but are acurate to
; a full 32 bits, and that's essential with low Z clip planes.
; Clips face at CURRFC (or one poly!).
; This is an optimized version...  The midpoint parameters I left out; check
; file 'ZCLIP.S' for the register usage (though U can see here anyway!).

z_clip_face:
                movea.l currfc(PC),A3   ; Get current face address.
                move.w  (A3)+,colour    ; Get colour.
                bmi     noface          ; Negative - no more faces.
                move.w  (A3)+,D0        ; Get number of points.
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

                move.l  #hither,D6      ; Get Z clip plane.

                cmp.l   D2,D5           ; Is D0>D1? (Z2>Z1)
                bgt.s   binary_search1  ; Yes...  Don't interchange.
                exg     D2,D5           ; No...  Interchange them.
                exg     D0,D3
                exg     D1,D4
binary_search1:
                movea.l D3,A5           ; Store X2.
                movea.l D4,A6           ; Store Y2.
                add.l   D0,D3           ; X1+X2.
                asr.l   #1,D3           ; / 2.
                add.l   D1,D4           ; Y1+Y2.
                asr.l   #1,D4           ; / 2.

                move.l  D5,D7           ; Store for calculation.
                add.l   D2,D7           ; Z1 + Z2.
                asr.l   #1,D7           ; Divide by 2; midpoint.
                cmp.l   D7,D6           ; Compare them.
                bgt.s   use_a1          ; Greater than destination...  Use A.
                beq.s   search_found1   ; Same...  Found match.
                move.l  D7,D5           ; Smaller...  Z2=Zm.  Use B.
                bra.s   binary_search1  ; Continue search.
use_a1:         move.l  D7,D2           ; Z1=Zm...  Use A.
                move.l  D3,D0           ; X1=Xm.
                move.l  D4,D1           ; Y1=Ym.
                move.l  A5,D3           ; Restore X2.
                move.l  A6,D4           ; Restore Y2.
                bra.s   binary_search1  ; Continue search.
search_found1:

                move.l  #hither,D2      ; Get Z clip plnae.
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
                move.l  #hither,D6      ; Get Z clip plane.

                cmp.l   D2,D5           ; Is D0>D1? (Z2>Z1)
                bgt.s   binary_search2  ; Yes...  Don't interchange.
                exg     D2,D5           ; No...  Interchange them.
                exg     D0,D3
                exg     D1,D4
binary_search2:
                movea.l D3,A5           ; Store X2.
                movea.l D4,A6           ; Store Y2.
                add.l   D0,D3           ; X1+X2.
                asr.l   #1,D3           ; / 2.
                add.l   D1,D4           ; Y1+Y2.
                asr.l   #1,D4           ; / 2.

                move.l  D5,D7           ; Store for calculation.
                add.l   D2,D7           ; Z1 + Z2.
                asr.l   #1,D7           ; Divide by 2; midpoint.
                cmp.l   D7,D6           ; Compare them.
                bgt.s   use_a2          ; Greater than destination...  Use A.
                beq.s   search_found2   ; Same...  Found match.
                move.l  D7,D5           ; Smaller...  Z2=Zm.  Use B.
                bra.s   binary_search2  ; Continue search.
use_a2:         move.l  D7,D2           ; Z1=Zm...  Use A.
                move.l  D3,D0           ; X1=Xm.
                move.l  D4,D1           ; Y1=Ym.
                move.l  A5,D3           ; Restore X2.
                move.l  A6,D4           ; Restore Y2.
                bra.s   binary_search2  ; Continue search.
search_found2:

                move.l  #hither,D2      ; Get Z clip plane.
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

cont_face:
; do clockwise / anticlockwise test
;
;
;       (a1) points to X1 Y1 X2 Y2 X3 Y3 etc etc after translation.

                movem.w poly+2(PC),D0-D5
                sub.w   D0,D2           ; P1x-P0x
                sub.w   D1,D3           ; P1y-P0y
; D2=Dx1 D3=Dy1
                sub.w   D0,D4           ; P2x-P0x
                sub.w   D1,D5           ; P2y-P0y
; D4=Dx2 D5=Dy2
                muls    D2,D5           ; Dx1*Dy2
                muls    D3,D4           ; Dy1*Dx2
                sub.l   D4,D5

                bmi     nxtface         ; Negative or zero = not visible.

skipclock:

;                ENDPART


;                >PART 'raster convert and polyfill'

drawpoly:
                lea     poly(PC),A5     ; Get polygon pointer.
                move.w  (A5)+,D1        ; Get number of points.
                movea.l A5,A0           ; Copy to A0.
                move.w  D1,D0           ; And number of points.

                move.w  #201,D3         ; Dummy high value.
                move.w  #-1,D4          ; Dummy low value.
                move.w  #320,D5         ; Same for X.
                move.w  #-1,D6

; Find X and Y maximums and minimums in poly.
findmic:        move.w  (A0)+,D7        ; Get X coordinate.
                cmp.w   D7,D5           ; Compare with high val.
                ble.s   nolesc          ; Not smaller...  Skip.
                move.w  D7,D5           ; Smaller...  Now new Min X.
nolesc:         cmp.w   D7,D6           ; Check if it's bigger.
                bge.s   nobic           ; No...  Skip.
                move.w  D7,D6           ; Yep, get this Max X.
nobic:          move.w  (A0)+,D7        ; Get Y coordinate.
                cmp.w   D7,D3           ; Compare with high val.
                ble.s   noles2          ; Not smaller...  Skip.
                move.w  D7,D3           ; Smaller...  Now new Min Y.
noles2:         cmp.w   D7,D4           ; Check if it's bigger.
                bge.s   clip            ; No...  Skip.
                move.w  D7,D4           ; Yep, get this Max Y.
clip:           dbra    D1,findmic      ; Do for points.

*                add.w   D5,D5
*                add.w   D5,D5           ; Min X * 4.
*                add.w   D6,D6
*                add.w   D6,D6           ; Max X * 4.

                addq.w  #1,D0           ; Adjust for clipper.
                bsr     polyclip        ; CLIP POLYGON.
                cmp.w   #3,D0           ; <3 points, poly outside.
                blt     nxtface
                move.w  D0,D7           ; Do not adjust D7!
                subq.w  #1,D0           ; Adjust D1 for DBRA.

                add.w   D7,D7
                add.w   D7,D7           ; * 4 for duplicate pointer.
                movea.l A5,A0           ; Start of list in A0.
                movea.l A5,A3           ; End of list in A3.
                adda.w  D7,A3           ; Now duplicate pointer.



****  RASTER CONVERT POLYGON  ****

                lea     divtab(PC),A2   ; Get division table address.

; Find lowest Y and higest Y and make a duplicate points list.
                move.w  D0,D1           ; Number of points.
                move.w  #201,D0         ; Dummy high value.
                moveq   #-1,D3          ; Dummy low value.
findmin:        move.l  (A0)+,D4        ; Get Y coordinate.
                cmp.w   D4,D0           ; Compare with high val.
                ble.s   noless          ; Not smaller...  Skip.
                move.w  D4,D0           ; Smaller...  Now new MinY.
                movea.l A0,A1           ; Get address from X.
noless:         cmp.w   D4,D3           ; Check if it's bigger.
                bge.s   nobig           ; No...  Skip.
                move.w  D4,D3           ; Yep, get this.
nobig:          move.l  D4,(A3)+        ; To next coordinates and copy.
                dbra    D1,findmin      ; Do for points.
                subq.w  #4,A1           ; Adjust A1 because of (A0)+.
* A1 now contains address to right scan of table, from the X.
* D0 contains the minimum Y value.
* D3 contains maximum Y value.

                move.w  D0,starty       ; Store beginning Y.
                sub.w   D0,D3           ; Make now total Y's.
                move.w  D3,D1           ; Duplicate for right edge.

; Point A0 to duplicate coordinates (second list).
                movea.l A1,A0           ; Copy start pointer address to A0.
                adda.w  D7,A0           ; Now point to duplicate coords.
* A0 now contains address to left scan of table, from the X.
* We now have A0 for delta X L calcs and A1 for delta X R calcs.



***  Process left edge.

                lea     lpoints(PC),A3  ; Get left edge table address.

doleft:
; Get number of Y's.
                move.w  -2(A0),D0       ; Get destination Y for left.
                sub.w   2(A0),D0        ; For left edge get difference.
                move.w  D0,D7

* D7 now contains the destination Y.
* D0 contains the Y difference for left edge.

; Left edge Delta.
                move.w  -4(A0),D4       ; Get destination X.
                move.w  (A0),D5         ; Duplicate for start from screen.
                sub.w   D5,D4           ; Difference of X's.
; D5 has start lX.

* (A2) Points to division table.
                add.w   D0,D0           ; Make word access.
                lsl.w   #3,D4           ; Delta X times 8.
                muls    0(A2,D0.w),D4   ; Nab int and frac parts.
                move.w  D4,D6           ; Fraction part in D6.
                swap    D4              ; Swap for integer for ADDX.
; D4 contains frac and int.

                add.w   D5,D5           ; Start X * 4.
                add.w   D5,D5

                sub.w   D7,D3           ; Subtract for number of Y's.

                add.w   D7,D7
                move.w  D7,D0
                add.w   D7,D7
                add.w   D7,D0           ; * 6 for each routine.
                lea     erouts(PC),A4   ; Get end of routines address.
                suba.w  D0,A4           ; And point to proper line.

                moveq   #0,D0           ; Make sure D0 is clear.

; A3 points to raster scan convert table to write the left edge to.

                jmp     (A4)            ; Jump to routines.

; ...  these routines.
; Fill table with left gradient addition results.
                REPT 199
                move.w  D5,(A3)+
                add.w   D6,D0
                addx.w  D4,D5
                ENDR
erouts:

                tst.w   D3
                ble.s   outl            ; Exit if we've reached bottom.
                subq.w  #4,A0           ; If not, move on.

                bra     doleft
outl:
                move.w  D5,(A3)+        ; Cater for missing line.
                move.w  #319,(A3)+      ; End of list - to fool Hline.


***  Now process right edge.

                lea     rpoints(PC),A3  ; Get right edge table address.

doright:
; Get number of Y's.
                move.w  6(A1),D0        ; Get destination Y for right.
                sub.w   2(A1),D0        ; For left edge get difference.
                move.w  D0,D7

* D7 now contains the destination Y.
* D0 contains the Y difference for right edge.

; Right edge Delta.
                move.w  4(A1),D4        ; Get destination X.
                move.w  (A1),D5         ; Duplicate for start from screen.
                sub.w   D5,D4           ; Difference of X's.
; D5 has start rX.

* (A2) Points to division table.
                add.w   D0,D0           ; Make word access.
                lsl.w   #3,D4           ; Delta X times 8.
                muls    0(A2,D0.w),D4   ; Nab int and frac parts.
                move.w  D4,D6           ; Get fraction.
                swap    D4              ; Swap for integer for ADDX.
; D4 contains frac and int.

                add.w   D5,D5           ; Start X * 4.
                add.w   D5,D5


                sub.w   D7,D1           ; Subtract for number of Y's.

                add.w   D7,D7
                move.w  D7,D0
                add.w   D7,D7
                add.w   D7,D0           ; * 6 for each routine.
                lea     rrouts(PC),A4   ; Get end of routines.
                suba.w  D0,A4

                moveq   #0,D0           ; Make sure D0 is clear.

; A3 points to raster scan convert table to write the right edge to.

                jmp     (A4)            ; Jump to routines.

; ...  these routines.
; Fill table with right gradient addition results.
                REPT 199
                move.w  D5,(A3)+
                add.w   D6,D0
                addx.w  D4,D5
                ENDR
rrouts:

                tst.w   D1
                ble.s   outr            ; Exit if we've reached bottom.
                addq.w  #4,A1           ; If not, move on.

                bra     doright
outr:
                move.w  D5,(A3)+        ; Cater for missing line.
                move.w  #1,(A3)+        ; Fool Hline drawer X2>X1!



****  DRAW HLINES  ***

; Set routines to colour.
                move.w  colour(PC),D0   ; Colour
                cmpi.w  #15,D0
                bgt     a_hash
                add.w   D0,D0           ; Word access.
                lea     coltab(PC),A0
                lea     col1(PC),A2
                adda.w  0(A0,D0.w),A2
                move.l  (A2)+,D4
                move.l  (A2)+,D5        ; Colour data (8 bytes).
                lea     mcol1(PC),A0
                lea     mcol2(PC),A1
                move.l  (A2)+,D0
                move.l  (A2)+,D1        ; Get instructions.
                move.l  D0,(A0)+        ; Self modify 1rst chunk thing.
                move.l  D1,(A0)+
                move.l  D0,(A1)+        ; Self modify special case.
                move.l  D1,(A1)+
                lea     chunk2(PC),A0
                move.l  (A2)+,(A0)+     ; Self modify end chunk.
                move.l  (A2)+,(A0)+


                movea.l scrn2(PC),A0
                lea     lpoints(PC),A3
                lea     rpoints(PC),A4
                move.w  starty(PC),D0
                add.w   D0,D0
                lea     yoffs(PC),A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lefted(PC),A1
                lea     righted(PC),A2

                moveq   #-4,D7

drawit:         move.w  D7,D0
                and.w   (A3)+,D0
                move.l  0(A1,D0.w),D0
                move.w  D7,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.

                beq     chunk1
                bgt     doned

drawit2:        add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                not.w   D1

mcol1:          or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+

                jmp     jumpit(PC,D2.w)

chunk20:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk19:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk18:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk17:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk16:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk15:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk14:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk13:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk12:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk11:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk10:        move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk9:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk8:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk7:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk6:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk5:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk4:         move.l  D4,(A0)+
                move.l  D5,(A0)+
chunk3:         move.l  D4,(A0)+
                move.l  D5,(A0)+
                swap    D2
                move.w  D2,D3
jumpit:         not.w   D3
chunk2:         or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                move.w  D7,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D7,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                blt     drawit2
                bgt.s   doned           ; If > 0 then poly crosses.

chunk1:         add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both edges.
                move.w  D0,D1
                not.w   D1
mcol2:          or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                lea     160(A5),A5
                movea.l A5,A0
                move.w  D7,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D7,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                blt     drawit2
                beq.s   chunk1


doned:                                  ; Here when we've drawn all lines.
                bra     nxtface

a_hash:

                add.w   D0,D0           ; Word access.
                lea     coltab(PC),A0
                lea     col1(PC),A2
                adda.w  0(A0,D0.w),A2
                move.l  (A2)+,D4
                move.l  (A2)+,D5        ; Colour data (8 bytes).
                move.l  (A2)+,D6
                move.l  (A2)+,D7        ; Rotated colour data or second hash.

                movea.l scrn2(PC),A0
                lea     lpoints(PC),A3
                lea     rpoints(PC),A4
                move.w  starty(PC),D0
                btst    #0,D0
                beq.s   h_notodd
                exg     D6,D4
                exg     D7,D5
h_notodd:       add.w   D0,D0
                lea     yoffs(PC),A1
                adda.w  0(A1,D0.w),A0
                movea.l A0,A5

                lea     lefted(PC),A1
                lea     righted(PC),A2

                moveq   #-4,D3

hash_drawit:    move.w  D3,D0
                and.w   (A3)+,D0
                move.l  0(A1,D0.w),D0
                move.w  D3,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.

                beq     hash_chunk1
                bgt     hash_doned

hash_drawit2:   add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                swap    D0
                move.w  D1,D0

; First chunk...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                jmp     hash_jumpit(PC,D2.w)

h_chunk20:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk19:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk18:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk17:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk16:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk15:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk14:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk13:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk12:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk11:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk10:      move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk9:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk8:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk7:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk6:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk5:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk4:       move.l  D4,(A0)+
                move.l  D5,(A0)+
h_chunk3:       move.l  D4,(A0)+
                move.l  D5,(A0)+

                move.l  D2,D1           ; Draw left edge.
                swap    D1
hash_jumpit:    move.w  D1,D2
; Last chunk...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D2,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D2,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                move.w  D3,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D3,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                blt.s   hash_drawit22
                beq     hash_chunk12
                bra     hash_doned      ; If > 0 then poly crosses.

hash_chunk1:    add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both (inverse) edges.
                move.w  D0,D1
                swap    D0
                move.w  D1,D0

; One chunk merge...
                move.l  (A0),D1
                eor.l   D4,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D5,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                move.w  D3,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D3,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                beq     hash_chunk12
                bgt     hash_doned

********* Alternate second line...  Gets rid of EXG's.

hash_drawit22:  add.w   D0,D0
                adda.w  D0,A0           ; Add screen offset (X)
                swap    D0              ; Get mask.

                move.w  D0,D1           ; Draw left edge.
                swap    D0
                move.w  D1,D0

; First chunk...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                jmp     hash_jumpit2(PC,D2.w)

h2_chunk20:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk19:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk18:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk17:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk16:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk15:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk14:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk13:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk12:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk11:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk10:     move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk9:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk8:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk7:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk6:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk5:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk4:      move.l  D6,(A0)+
                move.l  D7,(A0)+
h2_chunk3:      move.l  D6,(A0)+
                move.l  D7,(A0)+

                move.l  D2,D1           ; Draw left edge.
                swap    D1
hash_jumpit2:   move.w  D1,D2
; Last chunk...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D2,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D2,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                move.w  D3,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D3,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                blt     hash_drawit2
                beq     hash_chunk1
                bgt.s   hash_doned      ; If > 0 then poly crosses.

hash_chunk12:   add.w   D0,D0
                adda.w  D0,A0           ; Screen offset.
                swap    D0              ; Get mask.
                swap    D2              ; Get mask.
                and.w   D2,D0           ; Combine both (inverse) edges.
                move.w  D0,D1
                swap    D0
                move.w  D1,D0

; One chunk merge...
                move.l  (A0),D1
                eor.l   D6,D1
                and.l   D0,D1
                eor.l   D1,(A0)+
                move.l  (A0),D1
                eor.l   D7,D1
                and.l   D0,D1
                eor.l   D1,(A0)+

                lea     160(A5),A5
                movea.l A5,A0
                move.w  D3,D0
                and.w   (A3)+,D0        ; (Drawit again) Saves one branch!  Russ.
                move.l  0(A1,D0.w),D0
                move.w  D3,D2
                and.w   (A4)+,D2
                move.l  0(A2,D2.w),D2
                add.w   D0,D2           ; Number of chunks.
                blt     hash_drawit2
                beq     hash_chunk1

hash_doned:                             ; Here when we've drawn all lines.
                bra     nxtface

;                ENDPART


noface:                                 ; Here when no more faces.
                rts

*       illegal

no_objects:

waitk:

*                movea.l scrn2(PC),A0
*                lea     (160*(scy-8))+72(A0),A0
*                move.l  #%111111110000000011111111,D0
*                move.l  #%11111111000000001111111100000000,D1
*                move.l  #%110000000000000011000000,D2
*                move.l  #%11000000000000001100000000,D3
*                or.l    D0,(A0)
*                or.l    D0,4(A0)
*                or.l    D1,8(A0)
*                or.l    D1,12(A0)
*                or.l    D0,2560(A0)
*                or.l    D0,2560+4(A0)
*                or.l    D1,2560+8(A0)
*                or.l    D1,2560+12(A0)

*                or.l    D2,160(A0)
*                or.l    D2,160+4(A0)
*                or.l    D3,160+8(A0)
*                or.l    D3,160+12(A0)
*                or.l    D2,2400(A0)
*                or.l    D2,2400+4(A0)
*                or.l    D3,2400+8(A0)
*                or.l    D3,2400+12(A0)

;                clr.w   $FFFF8240.w

                cmpi.b  #57+$80,$fffffc02.w
                beq.s   quit

;                movea.l whichtab(PC),A0
;                move.b  button(PC),D0
;                and.b   #3,D0
;                cmpi.b  #1,D0
;                bne.s   noright
;                move.w  #20,D0
;                bsr     getframe
;                add.w   D0,viewz
;noright:        cmpi.b  #2,D0
;                bne.s   noleft
;                move.w  #20,D0
;                bsr     getframe
;                sub.w   D0,viewz
;noleft:
                bra     key


; Not needed if reset-quit (as above)
quit:           move    #$2700,SR
                move.l  oldvbl(PC),$70.w
                move.l  dsave(PC),$0110.w
                move.b  sa1(PC),$FFFFFA07.w
                move.b  sa2(PC),$FFFFFA09.w
                move.b  sa3(PC),$FFFFFA15.w
                move.b  sa4(PC),$FFFFFA1D.w
                move.b  sa5(PC),$FFFFFA25.w
                move    #$2300,SR
		move.w #$8240,a0
		rept 8
		clr.l (a0)+
		endr

		ifeq demo
                move.w  #$0777,$FFFF8240.w
                move.w  #$00,$FFFF8242.w
                move.w  #$00,$FFFF8244.w
                move.w  #$00,$FFFF8246.w
                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP
                clr.w   -(SP)
                trap    #1
		endc
		move.l oldspmine(pc),sp
		rts

oldspmine	dc.l 0
vbl: 		movem.l	d0-a6,-(sp)
		ifne demo
		jsr	$504
		endc
		movem.l	(sp)+,d0-a6
           	subi.w  #256,step
                addq.b  #1,lcount

                move.l  A1,-(SP)
                move.l  D0,-(SP)

                movea.l seqpointer(PC),A1
                subq.w  #1,vcount
                bne.s   noseq
                lea     14(A1),A1
                cmpi.w  #-99,(A1)
                bne.s   seqok
		bra	quit
seqok:          move.w  12(A1),vcount
                move.l  A1,seqpointer

noseq:          move.w  (A1)+,D0
                add.w   D0,viewrx
                move.w  (A1)+,D0
                add.w   D0,viewry
                move.w  (A1)+,D0
                add.w   D0,viewrz

                move.w  (A1)+,D0
                add.w   D0,viewx
                move.w  (A1)+,D0
                add.w   D0,viewy
                move.w  (A1)+,D0
                add.w   D0,viewz

                move.l  (SP)+,D0
                movea.l (SP)+,A1

*                eori.w  #$77,$FFFF8240+30.w
divzero:        rte


fstep:          DS.W 1          ; Last step increase.
step:           DS.W 1          ; Space for step increase.
unit:           DS.W 1          ; Actual unit increase after calcs.


;                >PART 'Treesort'

;
; the following structure defines objects to be sorted
;
; 1. do a clr.l root
;
; 2. just repeated call 'insert' with a1 pointing at structure
;    and d0 the value to be sorted
;
; 3. do a jsr treesort with a4 pointing at the routine to call
;    for each object
;
                RSRESET

depth:          RS.W 1
lptr:           RS.L 1
rptr:           RS.L 1
obsize:         RS.B 1

;
;
;--------------------------------------------------------------------------
;
; file:         treesort.s
; programmer:   Russell Payne
; date:         14th September 1989
; version:      1.0
;
;       depth sorting routine used to implement the
;       'painters' algorithm by drawing distant objects
;       before near objects. entries are inserted into
;       a binary tree structure, which is then in-order
;       traversed to sort the entries.
;       for more information see "data structures and
;       program design" by r.kruse, pages 327-332
;
;--------------------------------------------------------------------------

root:           DC.L 0

;--------------------------------------------------------------------------
;
; insert node into the binary tree
;
; d0 = distance away for this object
; a1 = pointer to object structure
; root = pointer to the root of the binary tree
;
;--------------------------------------------------------------------------

insert:         move.w  D0,depth(A1)    ;this objects depth
                moveq   #0,D1
                move.l  D1,lptr(A1)
                move.l  D1,rptr(A1)     ;terminal node
                move.l  root(PC),D1
                beq.s   emptys          ;test for empty tree
nextnode:       movea.l D1,A2
                cmp.w   depth(A2),D0
                bgt.s   try_right
                move.l  lptr(A2),D1     ;empty left node?
                bne.s   nextnode
                move.l  A1,lptr(A2)
                rts
try_right:      move.l  rptr(A2),D1     ;empty right node?
                bne.s   nextnode
                move.l  A1,rptr(A2)
                rts
emptys:         lea     root(PC),A2
                move.l  A1,(A2)         ;object is first entry
                rts

;--------------------------------------------------------------------------
;
; treesort
;
; perform an inorder traversal on the binary
; tree constructed by the above procedure
;
; root = pointer to the root of the binary tree
;
;--------------------------------------------------------------------------

treesort:       move.l  root(PC),D0
                beq.s   empty           ;empty tree
goright:        movea.l D0,A1
                move.l  A1,-(SP)        ;save pointer to this node
                move.l  rptr(A1),D0
                beq.s   norights
                bsr.s   goright         ;recursive descent
                movea.l (SP),A1
norights:
                move.l  D0,-(SP)
                bsr     draw_object
                move.l  (SP)+,D0

                movea.l (SP)+,A1        ;pointer to current
                move.l  lptr(A1),D0     ;node
                bne.s   goright
empty:          rts

;                ENDPART


; -------------------------------->
;
; 3D SUBROUTINES.
;
;                >PART 'screen clear (to 200 lines)'

; D7=Number of lines to clear, A0=Screen address (end of screen to clear).
cls:            moveq   #$00,D0
                move.l  D0,D1
                move.l  D0,D2
                move.l  D0,D3
                move.l  D0,D4
                move.l  D0,D5
                move.l  D0,D6
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3

                lsl.w   #4,D7
                neg.w   D7
                lea     clsrouts(PC),A4
                jmp     0(A4,D7.w)
                REPT 200
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                movem.l D0-D6/A1-A3,-(A0)
                ENDR
clsrouts:       rts

;                ENDPART

;                >PART 'Generate a 3x3 matrix'

**********************************
* Generate a 3x3 matrix.
make_matrix:

; Generate object matrix angles (X,Y,Z) held in D0,D2,D4.
; 3x3 matrix to write to in A0.
; Trashes D0-D7, A1-A2.
                lea     sintab(PC),A1   ; SET UP MATRIX.
                lea     512(A1),A2
                move.w  #1023,D6
mat_xangle:
*               move.w  xang(PC),D0
                and.w   D6,D0
                add.w   D0,D0
                move.w  0(A1,D0.w),D1   ; Sin X into D1
                move.w  0(A2,D0.w),D0   ; Cos X into D0.
mat_yangle:
*               move.w  yang(PC),D2
                and.w   D6,D2
                add.w   D2,D2
                move.w  0(A1,D2.w),D3   ; Sin Y into D3
                move.w  0(A2,D2.w),D2   ; Cos Y into D2.
mat_zangle:
*               move.w  zang(PC),D4
                and.w   D6,D4
                add.w   D4,D4
                move.w  0(A1,D4.w),D5   ; Sin Z into D5
                move.w  0(A2,D4.w),D4   ; Cos Z into D4.

* D0=CosX
* D1=SinX
* D2=CosY
* D3=SinY
* D4=CosZ
* D5=SinZ
*
* Cy*Cz,Cy*Sz,Sy
* !Sx*Sy!*Cz+Cx*-Sz,!Sx*Sy!*Sz+Cx*Cz,-Sx*Cy
* ;Cx*-Sy;*Cz+Sx*-Sz,;Cx*-Sy;*Sz+Sx*Cz,Cx*Cy

gen_mat_x:      move.w  D4,D6           ; Store CosZ.
                muls    D2,D4           ; CosY * CosZ.
                add.l   D4,D4
                swap    D4
                move.w  D4,(A0)+        ; > M1,1
                move.w  D6,D4           ; Restore Cos Z.
                move.w  D5,D6           ; Store SinZ.
                muls    D2,D5           ; CosY * SinZ.
                add.l   D5,D5
                swap    D5
                move.w  D5,(A0)+        ; > M2,1
                move.w  D6,D5
                move.w  D3,(A0)+        ; > M3,1 = SinY. Also stores d3!
                move.w  D3,D7           ; Store for later use.
gen_mat_y:      muls    D1,D3           ; SinX * SinY
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D0,D5           ; CosX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,2.
                move.w  A4,D3           ; Fetch SinX * SinY.
                move.w  D6,D5           ; Restore SinZ.
                muls    D5,D3           ; * SinZ.
                move.w  D4,D6           ; Store CosZ.
                muls    D0,D4           ; CosX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D6,D4           ; Restore CosZ.
                move.w  D3,(A0)+        ; > M2,2
                move.w  D7,D3           ; Restore SinY.
                move.w  D1,D6           ; Store SinX.
                neg.w   D1              ; SinX = -SinX.
                muls    D2,D1           ; -SinX * CosY.
                add.l   D1,D1
                swap    D1
                move.w  D1,(A0)+        ; > M3,2.
                move.w  D6,D1           ; Restore SinX.
gen_mat_z:      neg.w   D3              ; SinY = -SinY.
                muls    D0,D3           ; CosX * -SinY.
                add.l   D3,D3
                swap    D3
                movea.w D3,A4           ; Store for later.
                muls    D4,D3           ; * CosZ.
                move.w  D5,D6           ; Store SinZ.
                neg.w   D5              ; SinZ = -SinZ.
                muls    D1,D5           ; SinX * -SinZ.
                add.l   D5,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M1,3
                move.w  A4,D3           ; Get CosX * -SinY.
                muls    D6,D3           ; * SinZ.
                muls    D1,D4           ; SinX * CosZ.
                add.l   D4,D3
                add.l   D3,D3
                swap    D3
                move.w  D3,(A0)+        ; > M2,3
                muls    D0,D2           ; CosX * CosY.
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+        ; > M3,3

                rts

;                ENDPART

;                >PART 'Rotate viewpoint'

; Rotate object's coordinates.
; Matrix in A0.
; Start of object's X,Y,Z coordinates in A1.
; Rotated (destination) points in A2.
; Coordinate offset (to X,Y,Z) in A4 as X,Y,Z displacement.
; Number of points minus one in D7.
; On exit, A1 points to end of last coordinates rotated.
rotate_view:

                move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z

                sub.w   viewx(PC),D5
                sub.w   viewy(PC),D4
                sub.w   viewz(PC),D3

                move.w  D5,D0           ; Store old X.

                move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D5        ; X * M1,1.
                muls    (A0)+,D1        ; Y * M2,1.
                muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.

                move.w  D3,D2           ; Store old Z.
                muls    (A0)+,D0        ; X * M1,2.
                muls    (A0)+,D4        ; Y * M2,2.
                muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

                muls    (A0)+,D1        ; X * M1,3.
                muls    (A0)+,D0        ; Y * M2,3.
                muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.
                move.w  D3,(A2)+        ; Store Z.

                rts

;                ENDPART

;                >PART 'Rotate objects coordinates'

; Rotate object's coordinates.
; Matrix in A0.
; Start of object's X,Y,Z coordinates in A1.
; Rotated (destination) points in A2.
; Coordinate offset (to X,Y,Z) in A4 as X,Y,Z displacement.
; Number of points minus one in D7.
; On exit, A1 points to end of last coordinates rotated.
rotate_object:

nexp:           move.w  (A1)+,D5        ; X
                move.w  (A1)+,D4        ; Y
                move.w  (A1)+,D3        ; Z

                move.w  D5,D0           ; Store old X.

xnew:           move.w  D4,D1           ; Store old Y.
                move.w  D3,D2           ; Store old Z.
m11:            muls    (A0)+,D5        ; X * M1,1.
m21:            muls    (A0)+,D1        ; Y * M2,1.
m31:            muls    (A0)+,D2        ; Z * M3,1.
                add.l   D1,D5           ; X * M1,1 + Y * M2,1.
                add.l   D2,D5           ; Above instr + Z * M3,1.
                add.l   D5,D5
                swap    D5

                move.w  D0,D1           ; Store old X.
                move.w  D4,D6           ; Store old Y.

* That bit above has to be done because if it is included with the
* 4 channel player then it cannot use D6 or D7.


ynew:           move.w  D3,D2           ; Store old Z.
m12:            muls    (A0)+,D0        ; X * M1,2.
m22:            muls    (A0)+,D4        ; Y * M2,2.
m32:            muls    (A0)+,D2        ; Z * M3,2.
                add.l   D0,D4           ; X * M1,2 + Y * M2,2
                add.l   D2,D4           ; Above instr + Z * M3,2.
                add.l   D4,D4
                swap    D4

                move.w  D6,D0           ; Get old Y.

znew:
m13:            muls    (A0)+,D1        ; X * M1,3.
m23:            muls    (A0)+,D0        ; Y * M2,3.
m33:            muls    (A0)+,D3        ; Z * M3,3.
                add.l   D1,D3           ; X * M1,3 + Y * M2,3
                add.l   D0,D3           ; Above instr + Z * M3,3.
                add.l   D3,D3           ; Adjust for fraction (X2).
                swap    D3              ; And divide by 32767 (max RAD).

                lea     -18(A0),A0      ; Restore matrix pointer to start.

perspec:

*                ext.l   D5
*                ext.l   D4
*                asl.l   #8,D5
*                asl.l   #8,D4

*                divs    D3,D5           ; And do perspective (/ Z + Horizon).
*                divs    D3,D4           ; And do perspective (/ Z + Horizon).

*                add.w   #scx,D5
*                add.w   #scy,D4

                add.w   (A4),D5
                add.w   2(A4),D4
                add.w   4(A4),D3

                move.w  D5,(A2)+        ; Store X.
                move.w  D4,(A2)+        ; Store Y.
                move.w  D3,(A2)+        ; Store Z.

                dbra    D7,nexp         ; Next point.
                rts

;                ENDPART

;                >PART '3x3 Matrix multiplier'

; Multiply two 3x3 matrices together.
; The two matrices are pointed to by A1 and A2.
; The destination matrix is held in A0.
mat_mul:
                REPT 3

                move.w  (A2),D0
                muls    (A1),D0
                move.w  6(A2),D1
                muls    2(A1),D1
                move.w  12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  2(A2),D0
                muls    (A1),D0
                move.w  2+6(A2),D1
                muls    2(A1),D1
                move.w  2+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                move.w  4(A2),D0
                muls    (A1),D0
                move.w  4+6(A2),D1
                muls    2(A1),D1
                move.w  4+12(A2),D2
                muls    4(A1),D2
                add.l   D0,D1
                add.l   D1,D2
                add.l   D2,D2
                swap    D2
                move.w  D2,(A0)+

                addq.w  #6,A1

                ENDR
                rts

;                ENDPART


; <--------------------------------


* COLOUR TABLE.
coltab:         DC.W col1-cstart
                DC.W col2-cstart
                DC.W col3-cstart
                DC.W col4-cstart
                DC.W col5-cstart
                DC.W col6-cstart
                DC.W col7-cstart
                DC.W col8-cstart
                DC.W col9-cstart
                DC.W col10-cstart
                DC.W col11-cstart
                DC.W col12-cstart
                DC.W col13-cstart
                DC.W col14-cstart
                DC.W col15-cstart
                DC.W col16-cstart
; Hash colours...
oset            SET 0
                REPT 30
                DC.W (hashes+oset)-cstart
oset            SET oset+16
                ENDR

* COLOUR DATA AND ROUTINES. > 15 is hash colours (and no slef-modifying).
cstart:
col1:           DC.L $00,$00
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col2:           DC.L $FFFF0000,$00
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col3:           DC.L $FFFF,$00
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col4:           DC.L $FFFFFFFF,$00
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
col5:           DC.L $00,$FFFF0000
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col6:           DC.L $FFFF0000,$FFFF0000
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col7:           DC.L $FFFF,$FFFF0000
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col8:           DC.L $FFFFFFFF,$FFFF0000
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
col9:           DC.L $00,$FFFF
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col10:          DC.L $FFFF0000,$FFFF
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col11:          DC.L $FFFF,$FFFF
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col12:          DC.L $FFFFFFFF,$FFFF
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
col13:          DC.L $00,$FFFFFFFF
                and.w   D1,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col14:          DC.L $FFFF0000,$FFFFFFFF
                or.w    D0,(A0)+
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col15:          DC.L $FFFF,$FFFFFFFF
                and.w   D1,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                and.w   D3,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
col16:          DC.L $FFFFFFFF,$FFFFFFFF
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D0,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+
                or.w    D2,(A0)+

; HASH DEFINITIONS - Second hash is the 'rotated' hash.  Coukld do ROR's to get
; the other hash, but this allows weirdo hashes.
hashes:
*                IBYTES '33SHADES.FE4'


;                >PART 'Russ poly clipper'

* POLYGON CLIPPER (By Russ Payne, using Sutherland-Hodgman algorithm)
* A5 - Vertex list.
* D0 - Verteces.
** Returns with d0 verteces..
* Writes new coordinates to A5.
* (clipper at label POLYCLIP)

L0000:          DS.W 310
polyclip:       lea     L0000(PC),A1
                cmp.w   #199,D4
                ble.s   L0001
                pea     L001A(PC)
L0001:          tst.w   D3
                bpl.s   L0002
                pea     L000B(PC)
L0002:          cmp.w   #$013F,D6
                ble.s   L0003
                pea     L003D(PC)
L0003:          tst.w   D5
                bpl.s   L0004
                pea     L002A(PC)
L0004:          cmp.w   D6,D5
                bvs.s   L0005
                cmp.w   D4,D3
                bvc.s   L0006
L0005:          pea     L0007(PC)
L0006:          rts
L0007:          move.w  D0,D6
                add.w   D6,D6
                subq.w  #1,D6
                move.l  #$3FFF,D3
                move.l  #-$3FFF,D4
                moveq   #0,D1
                movea.l A5,A6
L0008:          move.w  (A6)+,D1
                ext.l   D1
                bpl.s   L0009
                cmp.l   D4,D1
                bge.s   L000A
                move.w  D4,-2(A6)
                dbra    D6,L0008
                rts
L0009:          cmp.l   D3,D1
                ble.s   L000A
                move.w  D3,-2(A6)
L000A:          dbra    D6,L0008
                rts
L000B:          subq.w  #2,D0
                bgt.s   L000C
                rts
L000C:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
L000D:          move.l  (A5)+,D2
                tst.w   D1
                bmi.s   L0010
                tst.w   D2
                bmi.s   L0011
                move.l  D1,(A1)+
L000E:          move.l  D2,D1
                dbra    D0,L000D
                move.l  D7,D2
                tst.w   D1
                bmi.s   L0012
                tst.w   D2
                bmi.s   L0013
                move.l  D1,(A1)+
L000F:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L0010:          tst.w   D2
                bmi.s   L000E
                bsr.s   L0014
                bra.s   L000E
L0011:          move.l  D1,(A1)+
                bsr.s   L0017
                bra.s   L000E
L0012:          tst.w   D2
                bmi.s   L000F
                bsr.s   L0014
                bra.s   L000F
L0013:          move.l  D1,(A1)+
                bsr.s   L0017
                bra.s   L000F
L0014:          move.w  D2,D3
                beq.s   L0016
                move.w  D1,D4
                sub.w   D1,D3
                neg.w   D4
                swap    D1
                swap    D2
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0015
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                cmp.w   #319,D4
                sne     D5
                andi.w  #1,D5
                add.w   D5,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                clr.w   (A1)+
                rts
L0015:          move.w  D1,(A1)+
                swap    D1
                swap    D2
                clr.w   (A1)+
L0016:          rts
L0017:          move.w  D1,D4
                beq.s   L0019
                move.w  D2,D3
                sub.w   D1,D3
                neg.w   D4
                swap    D1
                swap    D2
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0018
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                tst.w   D4
                sne     D5
                ext.w   D5
                add.w   D5,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                clr.w   (A1)+
                rts
L0018:          move.w  D1,(A1)+
                swap    D1
                swap    D2
                clr.w   (A1)+
L0019:          rts
L001A:          subq.w  #2,D0
                bgt.s   L001B
                rts
L001B:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
                move.w  #199,D6
L001C:          move.l  (A5)+,D2
                cmp.w   D6,D1
                bgt.s   L001F
                cmp.w   D6,D2
                bgt.s   L0020
                move.l  D1,(A1)+
L001D:          move.l  D2,D1
                dbra    D0,L001C
                move.l  D7,D2
                cmp.w   D6,D1
                bgt.s   L0021
                cmp.w   D6,D2
                bgt.s   L0022
                move.l  D1,(A1)+
L001E:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L001F:          cmp.w   D6,D2
                bge.s   L001D
                bsr.s   L0023
                bra.s   L001D
L0020:          move.l  D1,(A1)+
                bsr.s   L0026
                bra.s   L001D
L0021:          cmp.w   D6,D2
                bge.s   L001E
                bsr.s   L0023
                bra.s   L001E
L0022:          move.l  D1,(A1)+
                bsr.s   L0026
                bra.s   L001E
L0023:          move.w  D2,D3
                sub.w   D1,D3
                move.w  D1,D4
                sub.w   D6,D4
                move.w  D6,D5
                sub.w   D2,D5
                swap    D1
                swap    D2
                cmp.w   D4,D5
                bgt.s   L0025
                neg.w   D4
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0024
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0024:          move.w  D2,(A1)+
                move.w  D6,(A1)+
                swap    D1
                swap    D2
                rts
L0025:          move.w  D1,D4
                sub.w   D2,D4
                beq.s   L0024
                neg.w   D3
                muls    D5,D4
                divs    D3,D4
                add.w   D2,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0026:          cmp.w   D6,D1
                beq.s   L0029
                move.w  D2,D3
                sub.w   D1,D3
                move.w  D6,D4
                sub.w   D1,D4
                move.w  D2,D5
                sub.w   D6,D5
                swap    D1
                swap    D2
                cmp.w   D4,D5
                bgt.s   L0028
                move.w  D2,D5
                sub.w   D1,D5
                beq.s   L0027
                muls    D5,D4
                divs    D3,D4
                add.w   D1,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
                rts
L0027:          move.w  D2,(A1)+
                move.w  D6,(A1)+
                swap    D1
                swap    D2
                rts
L0028:          move.w  D1,D4
                sub.w   D2,D4
                beq.s   L0027
                neg.w   D5
                neg.w   D3
                muls    D5,D4
                divs    D3,D4
                add.w   D2,D4
                swap    D1
                swap    D2
                move.w  D4,(A1)+
                move.w  D6,(A1)+
L0029:          rts
L002A:          subq.w  #2,D0
                bgt.s   L002B
                rts
L002B:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
L002C:          move.l  (A5)+,D2
                tst.l   D1
                bmi.s   L002F
                tst.l   D2
                bmi.s   L0030
                move.l  D1,(A1)+
L002D:          move.l  D2,D1
                dbra    D0,L002C
                move.l  D7,D2
                tst.l   D1
                bmi.s   L0031
                tst.l   D2
                bmi.s   L0032
                move.l  D1,(A1)+
L002E:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L002F:          tst.l   D2
                bmi.s   L002D
                bsr.s   L0033
                bra.s   L002D
L0030:          move.l  D1,(A1)+
                bsr.s   L0038
                bra.s   L002D
L0031:          tst.l   D2
                bmi.s   L002E
                bsr.s   L0033
                bra.s   L002E
L0032:          move.l  D1,(A1)+
                bsr.s   L0038
                bra.s   L002E
L0033:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L0035
                swap    D2
                move.w  D2,D4
                beq.s   L0037
                swap    D1
                move.w  D1,D5
                neg.w   D5
                cmp.w   D2,D5
                bgt.s   L0034
                neg.w   D3
                neg.w   D4
                muls    D4,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0034:          muls    D5,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0035:          swap    D2
                tst.w   D2
                beq.s   L0036
                clr.w   (A1)+
                move.w  D1,(A1)+
L0036:          swap    D2
                rts
L0037:          swap    D2
                rts
L0038:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L003A
                swap    D1
                move.w  D1,D4
                beq.s   L003C
                swap    D2
                move.w  D2,D5
                neg.w   D5
                cmp.w   D1,D5
                bgt.s   L0039
                neg.w   D4
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L0039:          neg.w   D3
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                clr.w   (A1)+
                move.w  D3,(A1)+
                rts
L003A:          swap    D1
                tst.w   D1
                beq.s   L003B
                clr.w   (A1)+
                move.w  D2,(A1)+
L003B:          swap    D1
                rts
L003C:          swap    D1
                rts
L003D:          subq.w  #2,D0
                bgt.s   L003E
                rts
L003E:          movea.l A1,A6
                move.l  (A5)+,D1
                move.l  D1,D7
                movea.w #319,A2
                moveq   #-1,D6
                move.w  A2,D6
                swap    D6
L003F:          move.l  (A5)+,D2
                cmp.l   D6,D1
                bgt.s   L0042
                cmp.l   D6,D2
                bgt.s   L0043
                move.l  D1,(A1)+
L0040:          move.l  D2,D1
                dbra    D0,L003F
                move.l  D7,D2
                cmp.l   D6,D1
                bgt.s   L0044
                cmp.l   D6,D2
                bgt.s   L0045
                move.l  D1,(A1)+
L0041:          movea.l A6,A5
                move.l  A1,D0
                sub.l   A6,D0
                asr.w   #2,D0
                lea     124(A6),A1
                rts
L0042:          cmp.l   D6,D2
                bgt.s   L0040
                bsr.s   L0046
                bra.s   L0040
L0043:          move.l  D1,(A1)+
                bsr.s   L004B
                bra.s   L0040
L0044:          cmp.l   D6,D2
                bgt.s   L0041
                bsr.s   L0046
                bra.s   L0041
L0045:          move.l  D1,(A1)+
                bsr.s   L004B
                bra.s   L0041
L0046:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L0049
                swap    D2
                swap    D1
                move.w  A2,D5
                sub.w   D2,D5
                beq.s   L0048
                move.w  D1,D4
                sub.w   A2,D4
                cmp.w   D4,D5
                bgt.s   L0047
                neg.w   D4
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L0047:          neg.w   D3
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L0048:          swap    D1
                swap    D2
                rts
L0049:          swap    D2
                cmp.w   A2,D2
                beq.s   L004A
                move.w  A2,(A1)+
                move.w  D1,(A1)+
L004A:          swap    D2
                rts
L004B:          move.w  D2,D3
                sub.w   D1,D3
                beq.s   L004E
                swap    D2
                swap    D1
                move.w  A2,D4
                sub.w   D1,D4
                beq.s   L004D
                move.w  D2,D5
                sub.w   A2,D5
                cmp.w   D4,D5
                bgt.s   L004C
                muls    D4,D3
                move.w  D2,D4
                sub.w   D1,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D1,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L004C:          neg.w   D3
                neg.w   D5
                muls    D5,D3
                move.w  D1,D4
                sub.w   D2,D4
                divs    D4,D3
                swap    D1
                swap    D2
                add.w   D2,D3
                move.w  A2,(A1)+
                move.w  D3,(A1)+
                rts
L004D:          swap    D1
                swap    D2
                rts
L004E:          swap    D1
                cmp.w   A2,D1
                beq.s   L004F
                move.w  A2,(A1)+
                move.w  D2,(A1)+
L004F:          swap    D1
                rts

;                ENDPART


;                >PART 'number conversion routine'

**************** Number conversion routine.

conv:           movem.l D0-D5/A0-A1,-(SP)
                moveq   #4,D5
                move.l  number(PC),D0
                rol.l   D5,D0
                moveq   #8-1,D2
loop:           move.b  D0,D1
                and.b   #%1111,D1
                cmpi.b  #10,D1
                blt.s   lten
                sub.b   #10,D1
                add.b   #'A',D1
                bra.s   putit
lten:           add.b   #'0',D1
putit:          bsr.s   shoveit
                addq.b  #1,txpos
                rol.l   D5,D0
                dbra    D2,loop
                movem.l (SP)+,D0-D5/A0-A1
                rts

shoveit:        moveq   #0,D3
                moveq   #0,D4
                move.b  txpos(PC),D3
                move.b  typos(PC),D4
                lea     yoffs(PC),A1
                add.w   D4,D4
                movea.l scrn1(PC),A0
                adda.w  0(A1,D4.w),A0
                lea     xtab(PC),A1
                move.b  0(A1,D3.w),D3
                adda.w  D3,A0
                lea     font(PC),A1
                moveq   #0,D3
                move.b  D1,D3
                sub.b   #32,D3
                lsl.w   #3,D3
                adda.w  D3,A1
                move.b  (A1)+,(A0)
                move.b  (A1)+,160(A0)
                move.b  (A1)+,320(A0)
                move.b  (A1)+,480(A0)
                move.b  (A1)+,640(A0)
                move.b  (A1)+,800(A0)
                move.b  (A1)+,960(A0)
                move.b  (A1),1120(A0)
                rts


number:         DS.L 1

font:           DC.L $00,$00,$10101010,$10001000,$240000,$00,$24247E24,$7E242400,$107C907C,$127C1000,$440810,$20440000
                DC.L $18241828,$45827D00,$100000,$00,$04081010,$10080400,$20100808,$08102000,$4428FE,$28440000,$10107C,$10100000
                DC.L $00,$1020,$7C,$00,$00,$1000,$020408,$10204000,$7C868A92,$A2C27C00,$10301010,$10107C00
                DC.L $7C82027C,$8080FE00,$7C82021C,$02827C00,$0C142444,$84FE0400,$FC8080FC,$02827C00,$7C8280FC,$82827C00,$FE820408,$10101000
                DC.L $7C82827C,$82827C00,$7C82827E,$02027C00,$1000,$10000000,$1000,$10200000,$08102040,$20100800,$7C00,$7C000000
                DC.L $20100804,$08102000,$7C82020C,$10001000,$7C829EA2,$9C807E00,$7C8282FE,$82828200,$FC8282FC,$8282FC00,$7C828080,$80827C00
                DC.L $FC828282,$8282FC00,$FE8080F8,$8080FE00,$FE8080F8,$80808000,$7E80808E,$82827C00,$828282FE,$82828200,$7C101010,$10107C00
                DC.L $02020202,$02827C00,$828488F0,$88848200,$80808080,$8080FE00,$82C6AA92,$82828200,$82C2A292,$8A868200,$7C828282,$82827C00
                DC.L $FC8282FC,$80808000,$7C828282,$8A847A00,$FC8282FC,$88848200,$7C82807C,$02827C00,$FE101010,$10101000,$82828282,$82827C00
                DC.L $82828282,$44281000,$82828292,$AAC68200,$82442810,$28448200,$82824428,$10101000,$FE040810,$2040FE00,$1C101010,$10101C00
                DC.L $80402010,$08040200,$38080808,$08083800,$10284482,$00,$00,$FE00,$100000,$00,$7804,$7C847800
                DC.L $8080F884,$8484F800,$7880,$80807800,$04047C84,$84847C00,$7884,$F8807800,$0C103810,$10101000,$7884,$847C0478
                DC.L $8080F884,$84848400,$10003010,$10103800,$08000808,$08080830,$808890E0,$90888400,$30101010,$10103800,$EC92,$92828200
                DC.L $F884,$84848400,$7884,$84847800,$F884,$8484F880,$7C84,$84847C04,$F884,$80808000,$7880,$78047800
                DC.L $10107C10,$10100C00,$8484,$84847C00,$8282,$44281000,$8282,$82542800,$8448,$30488400,$8484,$847C0478
                DC.L $7C08,$10207C00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

xtab:           DC.B 0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73
                DC.B 80,81,88,89,96,97,104,105,112,113,120,121,128,129,136,137
                DC.B 144,145,152,153

txpos:          DS.B 1
typos:          DS.B 1

*********************

;                ENDPART

;------------------------------------------------------------------;

;                >PART 'subroutines'

;
; Get frame compensated value (max is 255) and max delay is 10 frames (!!).
; Input in D0 - Output in D0.  Smashed A0 and D1.
;
getframe:
                tst.w   D0
                bpl.s   d0isplus
                neg.w   D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                neg.w   D0
                rts
d0isplus:       add.w   D0,D0
                move.w  0(A0,D0.w),D0
                rts


;                ENDPART

;------------------------------------------------------------------;


yoffs:
yoff            SET 0
                REPT 200
                DC.W yoff
yoff            SET yoff+160
                ENDR


oldsp:          DS.L 1
oldvbl:         DS.L 1
dsave:          DS.L 1

viewx:          DC.W 20000
viewy:          DC.W 350
viewz:          DC.W 1300

oldry:          DC.W 0
oldrx:          DC.W 0
rotatex:        DC.W 0
rotatey:        DC.W 0

viewrx:         DC.W 0
viewry:         DC.W 256
viewrz:         DC.W 0

obx:            DC.W 0
oby:            DC.W 0
obz:            DC.W 0

dummy:          DS.W 3

view_matrix:    DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

ob_matrix:      DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

tot_matrix:     DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0


sa1:            DS.B 1
sa2:            DS.B 1
sa3:            DS.B 1
sa4:            DS.B 1
sa5:            DS.B 1

lcount:         DS.B 1

                EVEN

scrn1:          DS.L 1
scrn2:          DS.L 1
scrn3:          DS.L 1

userx:          DC.W 0
usery:          DC.W 0
userz:          DC.W 0

maxy:           DC.W 0

vcount:         DC.W 300

seqpointer:     DC.L seq
seq:            DC.W 0,0,0      ; Stay
                DC.W 0,0,0
                DC.W 300

                DC.W 0,0,0      ; Follow dart
                DC.W -40,0,0
                DC.W 390

                DC.W 0,2,0      ; Swing round (see cube)
                DC.W -20,-1,0
                DC.W 110

                DC.W 0,1,0      ; Slow swing.
                DC.W -10,-1,0
                DC.W 60

                DC.W 0,0,0      ; Wait a little
                DC.W 0,0,0
                DC.W 130

                DC.W 0,1,0      ; Pan and move back
                DC.W -2,0,0
                DC.W 230

                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 100

                DC.W 0,0,0      ; Move back.
                DC.W -4,0,0
                DC.W 80

                DC.W 0,-2,0     ; And move back and pan
                DC.W -4,0,0
                DC.W 130

                DC.W 0,0,0
                DC.W 0,1,-8
                DC.W 75

                DC.W 0,-2,0     ; Move down and pan house.
                DC.W 0,1,-9
                DC.W 75

                DC.W 0,-2,0     ; Do extra 'pan'
                DC.W 0,0,0
                DC.W 50

                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 40

                DC.W 1,0,0      ; Now see top of roof!
                DC.W 0,-3,0
                DC.W 200

                DC.W 0,2,0
                DC.W 0,0,0
                DC.W 250

                DC.W -1,2,0
                DC.W 2,0,0
                DC.W 10

                DC.W -1,0,0
                DC.W 4,0,0
                DC.W 200

                DC.W 0,1,0
                DC.W 0,0,0
                DC.W 100

                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 50

                DC.W 0,1,0      ; Follow dart
                DC.W 0,0,0
                DC.W 100

                DC.W 0,2,0
                DC.W 0,0,0
                DC.W 150

                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 150

                DC.W 1,0,0      ; Look down
                DC.W 0,0,0
                DC.W 200

                DC.W 1,0,0      ; And fart out of here!
                DC.W 0,-200,0
                DC.W 10

                DC.W 0,0,0
                DC.W 0,-200,0
                DC.W 50

                DC.W 0,3,0
                DC.W 0,-200,0
                DC.W 74

                DC.W 0,3,0
                DC.W 0,50,0
                DC.W 17

                DC.W 0,0,0
                DC.W -12,0,32
                DC.W 100

                DC.W -1,0,0     ; Swoop down
                DC.W 0,130,10
                DC.W 202

                DC.W 0,0,0
                DC.W 0,0,-10
                DC.W 25

                DC.W 0,0,3
                DC.W 0,0,-30
                DC.W 300

                DC.W -99

divtab:
                DC.W 0
dival           SET 1
                REPT 200
                DC.W 32767/dival
dival           SET dival+1
                ENDR

zclipflag:      DS.W 1

colour:         DS.W 1

poly:           DC.W 0          ; Number of points for this poly.
                DS.L 31         ; Space for 30 points per poly.  (X and Y)

rotted:         DS.B 128*6      ; Space for 128 rotated points (total object).

z_counter:      DS.W 1

currfc:         DC.L 0          ; Current face (in link list).

drawpointer:    DC.L obdraws
obdraws:
                REPT 30
                DS.B 10
                DS.L 1          ; Object address.
                DS.W 3          ; Object position.
                DS.W 3          ; Object angles.
                DS.W 1          ; Z clip flag
                DS.W 1          ; Objects own rotations.
                ENDR

oblist:         DC.L object1

; 'Street' 1
object1:
                DC.L square     ; Shape
                DC.W 0,0,1600   ; Position
                DC.W 0,0,0      ; Angle
                DC.W %0         ; Object flag
object2:        DC.L square
                DC.W 1150,0,2300 ; 1000,1600
                DC.W 0,0,0
                DC.W %0
object3:        DC.L square
                DC.W 2300,0,600
                DC.W 0,0,0
                DC.W %0
object4:        DC.L square
                DC.W 2000,0,2100 ; 3000,0,1600
                DC.W 0,0,0
                DC.W %0
object5:        DC.L square
                DC.W 2000,0,-400
                DC.W 0,0,0
                DC.W %0

; 'Street' 2
object6:        DC.L house      ; Shape
                DC.W 0,350,0    ; Position
                DC.W 0,0,0      ; Angle
                DC.W %0         ; Object flag
object7:        DC.L square
                DC.W 1000,0,1000
                DC.W 0,0,0
                DC.W %0
object8:        DC.L house
                DC.W 2000,350,1000
                DC.W 0,0,0
                DC.W %0
;object9:        DC.L square
;                DC.W 3000,0,1000
;                DC.W 0,0,0
;                DC.W %0

object10:       DC.L house
                DC.W 2600,350,1000
                DC.W 0,0,0
                DC.W %0

object11:       DC.L triang
                DC.W 24000,0,1300
                DC.W 256,0,256
                DC.W %1

object12:       DC.L road1
                DC.W 270,400,170
                DC.W 0,0,0
                DC.W %10
object12b:      DC.L road1
                DC.W 1600,400,170
                DC.W 0,0,0
                DC.W %10
object12c:      DC.L road1
                DC.W 1600,400,2400
                DC.W 0,0,0
                DC.W %10


object13:       DC.L road2
                DC.W 800,400,1300
                DC.W 0,0,0
                DC.W %10
object14:       DC.L road2
                DC.W 1800,400,1300
                DC.W 0,0,0
                DC.W %10

objectl:        DC.L road2
                DC.W 1300,400,100
                DC.W 0,0,0
                DC.W %10

object15:       DC.L lamppost
                DC.W 110,100,-400 ; 100
                DC.W 0,0,0
                DC.W %0
;object16:       DC.L lamppost
;                DC.W 150,100,0
;                DC.W 0,0,0
;                DC.W %0
object17:       DC.L lamppost
                DC.W 110,100,400
                DC.W 0,0,0
                DC.W %0

object15a:      DC.L lamppost
                DC.W 1450,100,-90
                DC.W 0,0,0
                DC.W %0
object16a:      DC.L lamppost
                DC.W 1800,100,330
                DC.W 0,0,0
                DC.W %0
object17a:      DC.L lamppost
                DC.W 1450,100,800
                DC.W 0,0,0
                DC.W %0


object18:       DC.L cube
                DC.W 1600,200,-1000
                DC.W 0,0,0
                DC.W %1

                DC.L -99



curr_obj:       DC.L square     ; Address of object.

lamppost:
                DC.W 0,0,0
                DC.W 430
                DC.W 64,0,0
                DC.W %0

                DC.W 8-1        ; Points list.  Number of points.
                DC.W -5,-5,-5
                DC.W 5,-5,-5
                DC.W -10,300,-5
                DC.W -20,300,-5
                DC.W -5,-5,5
                DC.W 5,-5,5
                DC.W -10,300,5
                DC.W -20,300,5
; Link list:
                DC.W 10         ; Colour
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 12
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 11
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 11
                DC.W 4-1
                DC.W 4*6,0*6,3*6,7*6
                DC.W 15
                DC.W 4-1
                DC.W 4*6,5*6,1*6,0*6

                DC.W -99,-99,-99


house:          DC.W 0,0,0
                DC.W 135
                DC.W 0,0,0
                DC.W 0

                DC.W 10-1
                DC.W -200/2,100/2,150/2
                DC.W 200/2,100/2,150/2
                DC.W 200/2,-80/2,150/2
                DC.W -200/2,-80/2,150/2
                DC.W -200/2,100/2,-150/2
                DC.W 200/2,100/2,-150/2
                DC.W 200/2,-80/2,-150/2
                DC.W -200/2,-80/2,-150/2
                DC.W -200/2,150/2,0
                DC.W 200/2,150/2,0

                DC.W 6
                DC.W 4-1
                DC.W 0*6,1*6,2*6,3*6
                DC.W 4
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6

                DC.W 5
                DC.W 5-1
                DC.W 0*6,3*6,7*6,4*6,8*6
                DC.W 5
                DC.W 5-1
                DC.W 1*6,9*6,5*6,6*6,2*6
; Roof
                DC.W 6
                DC.W 4-1
                DC.W 8*6,9*6,1*6,0*6
                DC.W 5
                DC.W 4-1
                DC.W 4*6,5*6,9*6,8*6
; Floor.
;                DC.W 1
;                DC.W 4-1
;                DC.W 6*6,7*6,3*6,2*6
                DC.W -99,-99,-99

road1:          DC.W 0,0,1
                DC.W 1012
                DC.W 0,0,0
                DC.W 0
                DC.W 4-1
                DC.W 150,0,1000
                DC.W 150,0,-1000
                DC.W -150,0,-1000
                DC.W -150,0,1000
                DC.W 7
                DC.W 4-1
                DC.W 0*6,1*6,2*6,3*6
*                DC.W 7
*                DC.W 4-1
*                DC.W 3*6,2*6,1*6,0*6
                DC.W -99,-99,-99

road2:          DC.W 0,0,1
                DC.W 1012
                DC.W 0,0,0
                DC.W 0
                DC.W 4-1
                DC.W 1000,0,150
                DC.W 1000,0,-150
                DC.W -1000,0,-150
                DC.W -1000,0,150
                DC.W 7
                DC.W 4-1
                DC.W 0*6,1*6,2*6,3*6
*                DC.W 7
*                DC.W 4-1
*                DC.W 3*6,2*6,1*6,0*6
                DC.W -99,-99,-99


cube:           DC.W 0,0,3000   ; X,Y,Z position of object.
                DC.W 18         ; Width of object.
                DC.W 0,0,0      ; X,Y,Z ANGLES of object
                DC.W %1         ; Flags for object.

                DC.W 8-1        ; Points list.  Number of points.
                DC.W -30,-30,-30
                DC.W 30,-30,-30
                DC.W 30,30,-30
                DC.W -30,30,-30
                DC.W -30,-30,30
                DC.W 30,-30,30
                DC.W 30,30,30
                DC.W -30,30,30
; Link list:
                DC.W 1          ; Colour
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 3
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 2
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 2
                DC.W 4-1
                DC.W 4*6,0*6,3*6,7*6
                DC.W 9
                DC.W 4-1
                DC.W 4*6,5*6,1*6,0*6
                DC.W 9
                DC.W 4-1
                DC.W 3*6,2*6,6*6,7*6
                DC.W -99,-99,-99


square:         DC.W 0,0,3000   ; X,Y,Z position of object.
                DC.W 430        ; Width of object.
                DC.W 64,0,0     ; X,Y,Z ANGLES of object
                DC.W %1         ; Flags for object.

                DC.W 8-1        ; Points list.  Number of points.
                DC.W -100,-150,-100
                DC.W 100,-150,-100
                DC.W 100,400,-100
                DC.W -100,400,-100
                DC.W -100,-100,100
                DC.W 100,-100,100
                DC.W 100,400,100
                DC.W -100,400,100
; Link list:
                DC.W 1          ; Colour
                DC.W 4-1        ; Number of (linked) points.
                DC.W 0*6,1*6,2*6,3*6
                DC.W 3
                DC.W 4-1
                DC.W 7*6,6*6,5*6,4*6
                DC.W 2
                DC.W 4-1
                DC.W 1*6,5*6,6*6,2*6
                DC.W 2
                DC.W 4-1
                DC.W 4*6,0*6,3*6,7*6
                DC.W 15
                DC.W 4-1
                DC.W 4*6,5*6,1*6,0*6
;                DC.W 5
;                DC.W 4-1
;                DC.W 3*6,2*6,6*6,7*6
                DC.W -99,-99,-99


triang:         DC.W 0,0,1600   ; X,Y,Z position of object.
                DC.W 142        ; Width of object.
                DC.W 0,0,0      ; X,Y,Z ANGLES of object
                DC.W %1

                DC.W 5-1
                DC.W 0,-100,0
                DC.W -100,100,0
                DC.W 0,100,-20
                DC.W 100,100,0
                DC.W 0,100,20
; Link list:
                DC.W 13
                DC.W 3-1
                DC.W 1*6,0*6,2*6
                DC.W 14
                DC.W 3-1
                DC.W 0*6,3*6,2*6
                DC.W 14
                DC.W 3-1
                DC.W 4*6,0*6,1*6
                DC.W 13
                DC.W 3-1
                DC.W 3*6,0*6,4*6
                DC.W 8
                DC.W 4-1
                DC.W 1*6,2*6,3*6,4*6
                DC.W -99,-99,-99


; ------------------------------------ **  * *

; Sin table and frame compensate table.
;                >PART 'Sin table'

sintab:         DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
                DC.W $7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
                DC.W $7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
                DC.W $7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
                DC.W $7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
                DC.W $7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
                DC.W $7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
                DC.W $7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
                DC.W $7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
                DC.W $7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
                DC.W $73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
                DC.W $70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
                DC.W $6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
                DC.W $6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
                DC.W $66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
                DC.W $62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
                DC.W $5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
                DC.W $5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
                DC.W $55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
                DC.W $5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
                DC.W $4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
                DC.W $471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
                DC.W $41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
                DC.W $3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
                DC.W $36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
                DC.W $30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
                DC.W $2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
                DC.W $2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
                DC.W $1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
                DC.W $18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
                DC.W $12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53
                DC.W $0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710
                DC.W $0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$C9
                DC.W $00,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82
                DC.W $F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D
                DC.W $F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00
                DC.W $ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD
                DC.W $E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA
                DC.W $E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99
                DC.W $DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F
                DC.W $D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF
                DC.W $CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD
                DC.W $C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C
                DC.W $C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0
                DC.W $BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C
                DC.W $B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463
                DC.W $B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69
                DC.W $AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1
                DC.W $AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D
                DC.W $A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1
                DC.W $A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F
                DC.W $9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA
                DC.W $9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604
                DC.W $9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F
                DC.W $9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E
                DC.W $8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2
                DC.W $8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D
                DC.W $89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1
                DC.W $877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF
                DC.W $8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409
                DC.W $83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F
                DC.W $8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182
                DC.W $8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4
                DC.W $809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033
                DC.W $8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002
                DC.W $8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020
                DC.W $8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C
                DC.W $809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147
                DC.W $8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250
                DC.W $8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7
                DC.W $83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B
                DC.W $8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A
                DC.W $877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973
                DC.W $89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6
                DC.W $8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0
                DC.W $8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0
                DC.W $9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525
                DC.W $9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB
                DC.W $9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90
                DC.W $9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3
                DC.W $A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1
                DC.W $A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977
                DC.W $AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32
                DC.W $AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320
                DC.W $B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D
                DC.W $B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87
                DC.W $BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9
                DC.W $C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891
                DC.W $C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C
                DC.W $CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425
                DC.W $D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19
                DC.W $DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024
                DC.W $E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643
                DC.W $E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72
                DC.W $ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD
                DC.W $F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0
                DC.W $F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37
                DC.W $00,$C9,$0192,$025B,$0324,$03ED,$04B6,$057E
                DC.W $0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3
                DC.W $0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200
                DC.W $12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
                DC.W $18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
                DC.W $1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
                DC.W $2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
                DC.W $2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
                DC.W $30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
                DC.W $36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
                DC.W $3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
                DC.W $41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
                DC.W $471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
                DC.W $4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
                DC.W $5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
                DC.W $55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
                DC.W $5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
                DC.W $5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
                DC.W $62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
                DC.W $66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
                DC.W $6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
                DC.W $6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
                DC.W $70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
                DC.W $73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
                DC.W $7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
                DC.W $7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
                DC.W $7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
                DC.W $7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
                DC.W $7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
                DC.W $7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
                DC.W $7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
                DC.W $7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE

;                ENDPART

;                >PART 'Frame compensate table'

whichtab:       DC.L frametab
frametab:
                DC.L 1,131075,262149,393223,524297,655371,786445,917519
                DC.L 1048593,1179667,1310741,1441815,1572889,1703963,1835037,1966111
                DC.L 2097185,2228259,2359333,2490407,2621481,2752555,2883629,3014703
                DC.L 3145777,3276851,3407925,3538999,3670073,3801147,3932221,4063295
                DC.L 4194369,4325443,4456517,4587591,4718665,4849739,4980813,5111887
                DC.L 5242961,5374035,5505109,5636183,5767257,5898331,6029405,6160479
                DC.L 6291553,6422627,6553701,6684775,6815849,6946923,7077997,7209071
                DC.L 7340145,7471219,7602293,7733367,7864441,7995515,8126589,8257663
                DC.L 8388737,8519811,8650885,8781959,8913033,9044107,9175181,9306255
                DC.L 9437329,9568403,9699477,9830551,9961625,10092699,10223773,10354847
                DC.L 10485921,10616995,10748069,10879143,11010217,11141291,11272365,11403439
                DC.L 11534513,11665587,11796661,11927735,12058809,12189883,12320957,12452031
                DC.L 12583105,12714179,12845253,12976327,13107401,13238475,13369549,13500623
                DC.L 13631697,13762771,13893845,14024919,14155993,14287067,14418141,14549215
                DC.L 14680289,14811363,14942437,15073511,15204585,15335659,15466733,15597807
                DC.L 15728881,15859955,15991029,16122103,16253177,16384251,16515325,16646399
                DC.L 2,262150,524298,786446,1048594,1310742,1572890,1835038
                DC.L 2097186,2359334,2621482,2883630,3145778,3407926,3670074,3932222
                DC.L 4194370,4456518,4718666,4980814,5242962,5505110,5767258,6029406
                DC.L 6291554,6553702,6815850,7077998,7340146,7602294,7864442,8126590
                DC.L 8388738,8650886,8913034,9175182,9437330,9699478,9961626,10223774
                DC.L 10485922,10748070,11010218,11272366,11534514,11796662,12058810,12320958
                DC.L 12583106,12845254,13107402,13369550,13631698,13893846,14155994,14418142
                DC.L 14680290,14942438,15204586,15466734,15728882,15991030,16253178,16515326
                DC.L 16777474,17039622,17301770,17563918,17826066,18088214,18350362,18612510
                DC.L 18874658,19136806,19398954,19661102,19923250,20185398,20447546,20709694
                DC.L 20971842,21233990,21496138,21758286,22020434,22282582,22544730,22806878
                DC.L 23069026,23331174,23593322,23855470,24117618,24379766,24641914,24904062
                DC.L 25166210,25428358,25690506,25952654,26214802,26476950,26739098,27001246
                DC.L 27263394,27525542,27787690,28049838,28311986,28574134,28836282,29098430
                DC.L 29360578,29622726,29884874,30147022,30409170,30671318,30933466,31195614
                DC.L 31457762,31719910,31982058,32244206,32506354,32768502,33030650,33292798
                DC.L 3,393225,786447,1179669,1572891,1966113,2359335,2752557
                DC.L 3145779,3539001,3932223,4325445,4718667,5111889,5505111,5898333
                DC.L 6291555,6684777,7077999,7471221,7864443,8257665,8650887,9044109
                DC.L 9437331,9830553,10223775,10616997,11010219,11403441,11796663,12189885
                DC.L 12583107,12976329,13369551,13762773,14155995,14549217,14942439,15335661
                DC.L 15728883,16122105,16515327,16908549,17301771,17694993,18088215,18481437
                DC.L 18874659,19267881,19661103,20054325,20447547,20840769,21233991,21627213
                DC.L 22020435,22413657,22806879,23200101,23593323,23986545,24379767,24772989
                DC.L 25166211,25559433,25952655,26345877,26739099,27132321,27525543,27918765
                DC.L 28311987,28705209,29098431,29491653,29884875,30278097,30671319,31064541
                DC.L 31457763,31850985,32244207,32637429,33030651,33423873,33817095,34210317
                DC.L 34603539,34996761,35389983,35783205,36176427,36569649,36962871,37356093
                DC.L 37749315,38142537,38535759,38928981,39322203,39715425,40108647,40501869
                DC.L 40895091,41288313,41681535,42074757,42467979,42861201,43254423,43647645
                DC.L 44040867,44434089,44827311,45220533,45613755,46006977,46400199,46793421
                DC.L 47186643,47579865,47973087,48366309,48759531,49152753,49545975,49939197
                DC.L 4,524300,1048596,1572892,2097188,2621484,3145780,3670076
                DC.L 4194372,4718668,5242964,5767260,6291556,6815852,7340148,7864444
                DC.L 8388740,8913036,9437332,9961628,10485924,11010220,11534516,12058812
                DC.L 12583108,13107404,13631700,14155996,14680292,15204588,15728884,16253180
                DC.L 16777476,17301772,17826068,18350364,18874660,19398956,19923252,20447548
                DC.L 20971844,21496140,22020436,22544732,23069028,23593324,24117620,24641916
                DC.L 25166212,25690508,26214804,26739100,27263396,27787692,28311988,28836284
                DC.L 29360580,29884876,30409172,30933468,31457764,31982060,32506356,33030652
                DC.L 33554948,34079244,34603540,35127836,35652132,36176428,36700724,37225020
                DC.L 37749316,38273612,38797908,39322204,39846500,40370796,40895092,41419388
                DC.L 41943684,42467980,42992276,43516572,44040868,44565164,45089460,45613756
                DC.L 46138052,46662348,47186644,47710940,48235236,48759532,49283828,49808124
                DC.L 50332420,50856716,51381012,51905308,52429604,52953900,53478196,54002492
                DC.L 54526788,55051084,55575380,56099676,56623972,57148268,57672564,58196860
                DC.L 58721156,59245452,59769748,60294044,60818340,61342636,61866932,62391228
                DC.L 62915524,63439820,63964116,64488412,65012708,65537004,66061300,66585596
                DC.L 5,655375,1310745,1966115,2621485,3276855,3932225,4587595
                DC.L 5242965,5898335,6553705,7209075,7864445,8519815,9175185,9830555
                DC.L 10485925,11141295,11796665,12452035,13107405,13762775,14418145,15073515
                DC.L 15728885,16384255,17039625,17694995,18350365,19005735,19661105,20316475
                DC.L 20971845,21627215,22282585,22937955,23593325,24248695,24904065,25559435
                DC.L 26214805,26870175,27525545,28180915,28836285,29491655,30147025,30802395
                DC.L 31457765,32113135,32768505,33423875,34079245,34734615,35389985,36045355
                DC.L 36700725,37356095,38011465,38666835,39322205,39977575,40632945,41288315
                DC.L 41943685,42599055,43254425,43909795,44565165,45220535,45875905,46531275
                DC.L 47186645,47842015,48497385,49152755,49808125,50463495,51118865,51774235
                DC.L 52429605,53084975,53740345,54395715,55051085,55706455,56361825,57017195
                DC.L 57672565,58327935,58983305,59638675,60294045,60949415,61604785,62260155
                DC.L 62915525,63570895,64226265,64881635,65537005,66192375,66847745,67503115
                DC.L 68158485,68813855,69469225,70124595,70779965,71435335,72090705,72746075
                DC.L 73401445,74056815,74712185,75367555,76022925,76678295,77333665,77989035
                DC.L 78644405,79299775,79955145,80610515,81265885,81921255,82576625,83231995
                DC.L 6,786450,1572894,2359338,3145782,3932226,4718670,5505114
                DC.L 6291558,7078002,7864446,8650890,9437334,10223778,11010222,11796666
                DC.L 12583110,13369554,14155998,14942442,15728886,16515330,17301774,18088218
                DC.L 18874662,19661106,20447550,21233994,22020438,22806882,23593326,24379770
                DC.L 25166214,25952658,26739102,27525546,28311990,29098434,29884878,30671322
                DC.L 31457766,32244210,33030654,33817098,34603542,35389986,36176430,36962874
                DC.L 37749318,38535762,39322206,40108650,40895094,41681538,42467982,43254426
                DC.L 44040870,44827314,45613758,46400202,47186646,47973090,48759534,49545978
                DC.L 50332422,51118866,51905310,52691754,53478198,54264642,55051086,55837530
                DC.L 56623974,57410418,58196862,58983306,59769750,60556194,61342638,62129082
                DC.L 62915526,63701970,64488414,65274858,66061302,66847746,67634190,68420634
                DC.L 69207078,69993522,70779966,71566410,72352854,73139298,73925742,74712186
                DC.L 75498630,76285074,77071518,77857962,78644406,79430850,80217294,81003738
                DC.L 81790182,82576626,83363070,84149514,84935958,85722402,86508846,87295290
                DC.L 88081734,88868178,89654622,90441066,91227510,92013954,92800398,93586842
                DC.L 94373286,95159730,95946174,96732618,97519062,98305506,99091950,99878394
                DC.L 7,917525,1835043,2752561,3670079,4587597,5505115,6422633
                DC.L 7340151,8257669,9175187,10092705,11010223,11927741,12845259,13762777
                DC.L 14680295,15597813,16515331,17432849,18350367,19267885,20185403,21102921
                DC.L 22020439,22937957,23855475,24772993,25690511,26608029,27525547,28443065
                DC.L 29360583,30278101,31195619,32113137,33030655,33948173,34865691,35783209
                DC.L 36700727,37618245,38535763,39453281,40370799,41288317,42205835,43123353
                DC.L 44040871,44958389,45875907,46793425,47710943,48628461,49545979,50463497
                DC.L 51381015,52298533,53216051,54133569,55051087,55968605,56886123,57803641
                DC.L 58721159,59638677,60556195,61473713,62391231,63308749,64226267,65143785
                DC.L 66061303,66978821,67896339,68813857,69731375,70648893,71566411,72483929
                DC.L 73401447,74318965,75236483,76154001,77071519,77989037,78906555,79824073
                DC.L 80741591,81659109,82576627,83494145,84411663,85329181,86246699,87164217
                DC.L 88081735,88999253,89916771,90834289,91751807,92669325,93586843,94504361
                DC.L 95421879,96339397,97256915,98174433,99091951,100009469,100926987,101844505
                DC.L 102762023,103679541,104597059,105514577,106432095,107349613,108267131,109184649
                DC.L 110102167,111019685,111937203,112854721,113772239,114689757,115607275,116524793
                DC.L 8,1048600,2097192,3145784,4194376,5242968,6291560,7340152
                DC.L 8388744,9437336,10485928,11534520,12583112,13631704,14680296,15728888
                DC.L 16777480,17826072,18874664,19923256,20971848,22020440,23069032,24117624
                DC.L 25166216,26214808,27263400,28311992,29360584,30409176,31457768,32506360
                DC.L 33554952,34603544,35652136,36700728,37749320,38797912,39846504,40895096
                DC.L 41943688,42992280,44040872,45089464,46138056,47186648,48235240,49283832
                DC.L 50332424,51381016,52429608,53478200,54526792,55575384,56623976,57672568
                DC.L 58721160,59769752,60818344,61866936,62915528,63964120,65012712,66061304
                DC.L 67109896,68158488,69207080,70255672,71304264,72352856,73401448,74450040
                DC.L 75498632,76547224,77595816,78644408,79693000,80741592,81790184,82838776
                DC.L 83887368,84935960,85984552,87033144,88081736,89130328,90178920,91227512
                DC.L 92276104,93324696,94373288,95421880,96470472,97519064,98567656,99616248
                DC.L 100664840,101713432,102762024,103810616,104859208,105907800,106956392,108004984
                DC.L 109053576,110102168,111150760,112199352,113247944,114296536,115345128,116393720
                DC.L 117442312,118490904,119539496,120588088,121636680,122685272,123733864,124782456
                DC.L 125831048,126879640,127928232,128976824,130025416,131074008,132122600,133171192
                DC.L 9,1179675,2359341,3539007,4718673,5898339,7078005,8257671
                DC.L 9437337,10617003,11796669,12976335,14156001,15335667,16515333,17694999
                DC.L 18874665,20054331,21233997,22413663,23593329,24772995,25952661,27132327
                DC.L 28311993,29491659,30671325,31850991,33030657,34210323,35389989,36569655
                DC.L 37749321,38928987,40108653,41288319,42467985,43647651,44827317,46006983
                DC.L 47186649,48366315,49545981,50725647,51905313,53084979,54264645,55444311
                DC.L 56623977,57803643,58983309,60162975,61342641,62522307,63701973,64881639
                DC.L 66061305,67240971,68420637,69600303,70779969,71959635,73139301,74318967
                DC.L 75498633,76678299,77857965,79037631,80217297,81396963,82576629,83756295
                DC.L 84935961,86115627,87295293,88474959,89654625,90834291,92013957,93193623
                DC.L 94373289,95552955,96732621,97912287,99091953,100271619,101451285,102630951
                DC.L 103810617,104990283,106169949,107349615,108529281,109708947,110888613,112068279
                DC.L 113247945,114427611,115607277,116786943,117966609,119146275,120325941,121505607
                DC.L 122685273,123864939,125044605,126224271,127403937,128583603,129763269,130942935
                DC.L 132122601,133302267,134481933,135661599,136841265,138020931,139200597,140380263
                DC.L 141559929,142739595,143919261,145098927,146278593,147458259,148637925,149817591
                DC.L 10,1310750,2621490,3932230,5242970,6553710,7864450,9175190
                DC.L 10485930,11796670,13107410,14418150,15728890,17039630,18350370,19661110
                DC.L 20971850,22282590,23593330,24904070,26214810,27525550,28836290,30147030
                DC.L 31457770,32768510,34079250,35389990,36700730,38011470,39322210,40632950
                DC.L 41943690,43254430,44565170,45875910,47186650,48497390,49808130,51118870
                DC.L 52429610,53740350,55051090,56361830,57672570,58983310,60294050,61604790
                DC.L 62915530,64226270,65537010,66847750,68158490,69469230,70779970,72090710
                DC.L 73401450,74712190,76022930,77333670,78644410,79955150,81265890,82576630
                DC.L 83887370,85198110,86508850,87819590,89130330,90441070,91751810,93062550
                DC.L 94373290,95684030,96994770,98305510,99616250,100926990,102237730,103548470
                DC.L 104859210,106169950,107480690,108791430,110102170,111412910,112723650,114034390
                DC.L 115345130,116655870,117966610,119277350,120588090,121898830,123209570,124520310
                DC.L 125831050,127141790,128452530,129763270,131074010,132384750,133695490,135006230
                DC.L 136316970,137627710,138938450,140249190,141559930,142870670,144181410,145492150
                DC.L 146802890,148113630,149424370,150735110,152045850,153356590,154667330,155978070
                DC.L 157288810,158599550,159910290,161221030,162531770,163842510,165153250,166463990

;                ENDPART

		ds.b	2048
mystack:	ds.l 3

;------------------------------------- **  * *


; For edge and chunk calculations.

; Left edge masks & offsets.
lefted:
cchunk          SET 0
                REPT 20
                DC.W %1111111111111111,cchunk
                DC.W %111111111111111,cchunk
                DC.W %11111111111111,cchunk
                DC.W %1111111111111,cchunk
                DC.W %111111111111,cchunk
                DC.W %11111111111,cchunk
                DC.W %1111111111,cchunk
                DC.W %111111111,cchunk
                DC.W %11111111,cchunk
                DC.W %1111111,cchunk
                DC.W %111111,cchunk
                DC.W %11111,cchunk
                DC.W %1111,cchunk
                DC.W %111,cchunk
                DC.W %11,cchunk
                DC.W %1,cchunk
cchunk          SET cchunk+4
                ENDR
; Right edge masks & offsets.
righted:
cchunk          SET 0
                REPT 20
                DC.W %1000000000000000,-cchunk
                DC.W %1100000000000000,-cchunk
                DC.W %1110000000000000,-cchunk
                DC.W %1111000000000000,-cchunk
                DC.W %1111100000000000,-cchunk
                DC.W %1111110000000000,-cchunk
                DC.W %1111111000000000,-cchunk
                DC.W %1111111100000000,-cchunk
                DC.W %1111111110000000,-cchunk
                DC.W %1111111111000000,-cchunk
                DC.W %1111111111100000,-cchunk
                DC.W %1111111111110000,-cchunk
                DC.W %1111111111111000,-cchunk
                DC.W %1111111111111100,-cchunk
                DC.W %1111111111111110,-cchunk
                DC.W %1111111111111111,-cchunk
cchunk          SET cchunk+4
                ENDR
		SECTION BSS
; For raster scan convert.
starty:         DS.W 1          ; Y start value.
lpoints:        DS.W 202        ; Space for 200 X pairs left edge.
rpoints:        DS.W 202        ; Space for 200 X pairs right edge.

screens:        DS.L 1
		DS.B 100000
                END
