        module  math
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Filename:     Math
; Description:  All the math lib. stuff
; System:       Amiga / ST FOTI
; Author:       Dave 
; Date:         23/8/89
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        INCLUDE FOTI.EQU
        include "foti.mac"
        include "worldinc.inc"
        INCLUDE "INSTSTRU.SSS"  
        xref    tantable,_matan,SECTORLIST

long101         equ     $58c50
lat15           equ     $0d2f0

search_value    dc.w    0               ;value to and shape type with
search_mask     dc.w    0
search_quadline dc.w    0               ;0 - 4096
search_item     dc.l    0               ;address of current item in quad ?? (should be sector???)
search_minx     dc.l    0
search_minz     dc.l    0
search_maxx     dc.l    0               ;search rectangle in world co-ords
search_maxz     dc.l    0


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Procedure:    Tangent
; Description:  Returns the tangent of an angle in the range 0-$3FF, where
;               $400 represents an angle of 360 degrees
; Enter with:   d0.w=angle (0-$3ff)
; Exit with:    d1.w=tangent of angle
; Corrupts:     d0,d1,a0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tangent:        xdef    Tangent
        moveq.w #0,d1
        move.b  d0,d1
        add.w   d1,d1
        and.w   #$100,d0        ; check which quadrant the angle lies in
        beq.s   positive
        neg.w   d1
        lea     TanTable+510,a0
        move.w  (a0,d1.w),d1
        neg     d1
        rts
positive:
        lea     TanTable,a0
        move.w  (a0,d1.w),d1   ; get Tan value from table
        rts

;-----------------------------------------------------------------------------
; Procedure:    bearing
; Description:  return bearing of desired target
; Author:       Dave on 68000 Russell Payne on 8086
; Date:         Wednesday 23/8/68 Monday 24th April 1989
;
; Entry:-
;               A0=                     [ds:si] = starting coordinates
;                       X-coord Hi-Lo     +0 = lo-word of x-coord
;                                         +2 = hi-word of x-coord
;                       Y-coord Hi-Lo     +4 = lo-word of y-coord
;                                         +6 = hi-word of y-coord
;               a2=                     [ds:di] = destination coordinates
;                       X-coord Hi-Lo     +0 = lo-word of x-coord
;                                         +2 = hi-word of x-coord
;                       Y-coord Hi-Lo     +4 = lo-word of y-coord
;                                         +6 = hi-word of y-coord
;
; Exit:-
;               D0 = bearing to target (0-1023) (was ax)
;
;-----------------------------------------------------------------------------
bearing         xdef    bearing
        movem.l d1-d3,-(sp)
        move.l  (a0)+,d0                ;Starting X coord
        sub.l   (a2)+,d0                ;Destination X coord/  delta x in d0
        move.l  (a0)+,d1                ;starting Y coord
        sub.l   (a2)+,d1                ;destination Y coord/ delta y in d1
        SCALE                           ;scales d0 / d1 to 16 bits
        bsr.s   arctan
        movem.l (sp)+,d1-d3
        rts
;-----------------------------------------------------------------------------
; Procedure:    arctan
; Description:  return angle in d0 given 2 side lengths
; Author:       Dave
; Date:         Wednesday 23/8/89
;
; Entry:-       d0.w    delta x
;               d1.w    delta y         D0=arctan(d0/d1)
;
; Exit:-        D0      angle   (0-1023)
;-----------------------------------------------------------------------------
zero_dx
        ext.l   d1
        bmi.s   south
north
        moveq   #0,d0                   ;0 degrees
        bra	found_angle
south
        move    #$200,d0                ;180 degrees
        bra.s   found_angle
east
        move    #$100,d0                ;90 degrees
        bra.s   found_angle

arctan          xdef    arctan
        movem.l d1-d6/a0,-(sp)
        lea     _matan(pc),a0
        move    d0,d3                   ;save the values of delta x / y
        move    d1,d4                   ;for use in absolute diff's
        moveq   #9,d5                   ;shift register
	move	#$fffe,d6		;masking register
        ext.l   d0
        bmi.s   Neg_dx                  ;negative delta x
        beq.s   zero_dx                 ;zero delta x
pos_dx
        ext.l   d1
        bmi.s   neg_dy                  ;negative delta y
        beq.s   east                    ;90 degrees
pos_dy
        sub     d3,d4
        bmi.s   dx_gt_dy
        asl.l   d5,d0                   ;dx*512/dy
        divu    d1,d0
        and.w   d6,d0
        move    (a0,d0.w),d0
        bra.s   found_angle
dx_gt_dy
        asl.l   d5,d1                   ;dy*512/dx
        divu    d0,d1
        and.w   d6,d1
        move    #$100,d0
        sub     (a0,d1.w),d0
        bra     found_angle
neg_dy
        neg.l   d1
        neg     d4                      ;find the abs value d3-d4
        sub     d3,d4
        bmi.s   dx_gt_dy_1
        asl.l   d5,d0
        divu    d1,d0                   ;dx*512/dy
        and.w   d6,d0
        move    #$200,d1
        sub     (a0,d0.w),d1
        move    d1,d0
        bra.s   found_angle
dx_gt_dy_1
        asl.l   d5,d1                   ;dy*512/dx
        divu    d0,d1
        and.w   d6,d1
        move    (a0,d1.w),d0
        add     #$100,d0
        bra.s   found_angle
dx_gt_dy_3
        asl.l   d5,d1
        divu    d0,d1                   ;dy*512/dx
        and.w   d6,d1
        move    #$300,d0
        sub     (a0,d1.w),d0
found_angle
        and     #$3ff,d0
        movem.l (sp)+,d1-d6/a0
        rts
west
        move    #$300,d0                ;270 degrees
        bra.s   found_angle
neg_dx
        neg     d3
        neg.l   d0
        ext.l   d1
        bmi.s   neg_dy_1
        beq.s   west
pos_dy_1
        sub     d3,d4
        bmi.s   dx_gt_dy_2
        asl.l   d5,d0                   ;dx*512/dy
        divu    d1,d0
        and.w   d6,d0
        move    #$400,d1
        sub	(a0,d0.w),d1
	move	d1,d0
        bra.s   found_angle
dx_gt_dy_2
        asl.l   d5,d1                   ;dy*512/dx
        divu    d0,d1
        and.w   d6,d1
        move    #$300,d0
        add     (a0,d1.w),d0
        bra.s   found_angle
neg_dy_1
        neg.l   d1
        neg     d4
        sub     d3,d4
        bmi.s   dx_gt_dy_3
        asl.l   d5,d0                   ;dx*512/dy
        divu    d1,d0
        and.w   d6,d0
        move    (a0,d0.w),d0
        add     #$200,d0
        bra.s   found_angle


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    Start_Search
; Description:  initialize the search routine below
; Author:       Dave Whiteside                          /Russell Payne
; Date:         2/10/89                                 /Tuesday 16th May 1989
;
; Entry:-
;               D0 {ax} = object type we are looking for
;               A0.l = minimum x/z of search rectangle
;                       +0 = x-coord
;                       +4 = y-coord
;               A1.l = maximum x/z of search rectangle
;                       +0 = x-coord
;                       +4 = y-coord
;
; Exit:-
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
Start_search    xdef    start_search
        movem.l d0-d1/a0,-(sp)
        and     #$dfff,d0                       ;make sure of type
        move    d0,search_value
        move.w  d0,d1
        and     #$00ff,d1
        beq.s   family_check
        or      #$ff,d0
family_check
        move.w  d0,d1
        andi.w  #$01f00,d1
        beq.s   group_check
        or      #$1f00,d0
group_check
masked_off
        lea     sectorlist,a0                
        move    d0,search_mask
        move.W  #0,search_quadline
        move.l  (a0),search_item
        move.l  (a1)+,search_minx
        move.l  (a1)+,search_minz
        move.l  (a2)+,search_maxx
        move.l  (a2)+,search_maxz
        movem.l (sp)+,d0-d1/a0
        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    Search_Next
; Description:  return ptr to item or carry set if none left
; Author:       Dave Whiteside                          /Russell Payne
; Date:         3/10/89                                 /Tuesday 16th May 1989
;
; Entry:-
;
; Exit:-
;               a0 = item
;               A1 = sector
;           *************************    A2 = shape
;               carry set if none found
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
search_next     xdef    search_next
        lea     sectorlist,a3
        move    search_mask,d7
        move    search_value,d0
        move.l  search_item,a0                  ;The last item used
        move    search_quadline,d2              ;The quad containing it
        cmp     #16384,d2
        beq.s   _the_end
_f1
        tst.l   (a3,d2.w)                       ;is this one dead??
        bne.s   nextone                         ;if not then forward on
_b1
        addq    #4,d2                           ;item list
        cmp     #16384,d2
        beq.s   _the_end
        tst.l   (a3,d2.w)                       ;adr of sector
        beq.s   _b1
_f3
        move.l  (a3,d2.w),a0                    ;sector in a1
        lea     (a3,d2.w),a1
        bra.s   _f2
nextone
        move.l  item_nextptr(a0),a0
        cmp.l   #0,a0
        beq.s   _b1
_f2
        move.l  item_shapedescptr(a0),a2
        move.w  shapedesc_type(a2),d3           
_fullcheck
        and     d7,d3                           ;just grab these fields
        beq.s   nextone
        cmp.w   d3,d0
        bne.s   nextone
_foundone       
        move.l  item_wx(a0),d4                  ;range checks
        cmp.l   search_minx,d4
        bcs.s   nextone
        cmp.l   search_maxx,d4
        bhi.s   nextone
        move.l  item_wz(a0),d4
        cmp.l   search_minz,d4
        bcs.s   nextone
        cmp.l   search_maxz,d4
        bhi.s   nextone
        move.w  d2,search_quadline
        move.l  a0,search_item
fini
        rts
_the_end
        move    #16384,search_quadline
        moveq   #0,d0
        subq    #1,d0                           ;sets the carry for fail
        bra.s   fini


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    Count_Items
; Description:  return number of items of specified type
; Author:       Dave Whiteside                  /Russell Payne
; Date:         3/10/89                         /Tuesday 16th May 1989
;
; Entry:-
;               ax = value to AND type with
;               [ds:si] = minimum x/z of search rectangle
;                         +0 = lo-word of x-coord
;                         +2 = hi-word of x-coord
;                         +4 = lo-word of z-coord
;                         +6 = hi-word of z-coord
;               [ds:di] = maximum x/z of search rectangle
;                         +0 = lo-word of x-coord
;                         +2 = hi-word of x-coord
;                         +4 = lo-word of z-coord
;                         +6 = hi-word of z-coord
;
; Exit:-
;               ax = number of these items
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
count_items     xdef    count_items
        bsr     start_search
        moveq   #0,d0                           ;initialise count
.loop
        move.l  d0,-(sp)                        ;save count
        bsr     search_next                     ;find next
        bcs.s   _done                           ;none left
        move.l  (sp)+,d0                        ;retrive count
        addq    #1,d0                           ;inc count
        bra.s   .loop                           ;loop till end
_done
        move.l  (sp)+,d0                        ;get count
        rts



;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    COLLISION
; Description:  check to see if two objects have collided
; Author:       Russell Payne
; Date:         Friday 5th May 1989
;
; Entry:-
;               ds:si = pointer to 1st object   (ptr to item structure)
;               ds:di = pointer to 2nd object   (ptr to item structure)
;               es = pointer to data containing shape desc'ns (ie FRE_DATA)
;
; Exit:-
;               ax = 0 for no collision
;               ax = 1 for collision
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
collision       xdef    collision

        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    PREDICTED_COLLISION
; Description:  check to see if two objects will collide
; Author:       Russell Payne
; Date:         Friday 12th May 1989
;
; Entry:-
;               ds:si = pointer to 1st object   (ptr to airstruc structure)
;               ds:di = pointer to 2nd object   (ptr to airstruc structure)
;
; Exit:-
;               ax = 0 for no collision
;               ax = 1 for collision
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
predicted_collision     xdef    predicted_collision

        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    FLAT_DISTANCE
; Description:  distance between two points on the ground
; Author:       Dave Whiteside                          /Russell Payne
; Date:         4/10/89                                 /Thursday 6th April 1989
;
; Entry:-
;               (A0)    = Starting coordinates (X.l Y.l)
;               (A2)    = Destination coordinates (X.l Y.l)
;
; Exit:-
;               D0 = distance
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
flat_distance   xdef    flat_distance
        move.l  (a0)+,d0                        ;get start x
        move.l  (a2)+,d1                        ;get fini x
        sub.l   d1,d0                           ;get differance
        bpl.s   sok                             ;positive
        neg.l   d0                              ;make absolute (+ve)
sok
        move.l  (a0)+,d1                        ;get start y
        move.l  (a2)+,d2                        ;get fini y
        sub.l   d2,d1                           ;get differance
        bpl.s   sok1                            ;positive
        neg.l   d1                              ;make absolute (+ve)
sok1
        cmp.l   #32767,d1                       ;is y too big
        bgt.s   _yfailed
        cmp.l   #32767,d0
        ble.s   xy_passed                       ;both in range
_yfailed
        SCALE
        move    d2,d4                           ;save scale count
        bsr.s   distance_2d
        lsl.l   d4,d0
        rts
xy_passed
        bsr.s   distance_2d
        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    DISTANCE_2D
; Description:  compute distance between two points
; Author:       Dave Whiteside          /extracted from EGA Falcon by Russell Payne
; Date:         4/10/89                 /Wednesday 5th April 1989
;
; This routine calculates the distance between two points using approximation.
; A = 128 * SHORT / LONG
; DISTANCE = LONG * COS(A) + SHORT * SIN(A)
;
; Entry:-
;               D0 = delta_x
;               D1 = delta_y
;
; Exit:-
;               D0 = distance
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
POB15   XDEF    POB15
distance_2d     xdef    distance_2d

       and.l   #$ffff,d0                       
       and.l   #$ffff,d1                       ;for security

        move    d0,d2
        or      d1,d2
        beq.s   dist_zero                       ;deltax = deltay =0
        tst.w   d0                              ;is deltax +ve
        bpl.s   sok2
        neg.w   d0                              ;make positive
sok2
        tst.w   d1                              ;is deltay +ve
        bpl.s   sok3
        neg.w   d1                              ;make positive
sok3
        cmp     d1,d0                           ;which is bigger
        ble.s   sok4
        exg.l   d0,d1                           ;the other way arround
sok4
        move    d0,d2                           ;short value
        move    d1,d3                           ;long value
        asl.l   #7,d0
        divu    d1,d0                           ;a = 128 * SHORT / LONG
        SINCOS                                  ;return value in d0 / d1
        mulu    d3,d1                           ;LONG * COS(a)
        mulu    d2,d0                           ;SHORT * SIN(a)
        add.l   d1,d0                           ;result in d0
        asl.l   #1,d0
        swap    d0
        and.l   #$ffff,d0
dist_zero
        rts




;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    intercept
; Description:  return bearing and attitude of target
; Author:       Paul
; Date:         13/12/89
; entry:        a0 = ptr to starting coords  (x.l,y.l,z.l)
;               a2 = ptr to target coords  (x.l,y.l,z.l)
; exit:         d0 = heading (0-$3ff) , d1 = bearing (0-$3ff)
;               d2 = target range
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
intercept       xdef    intercept
        movem.l (a0),d0-d2      ; get starting x,y and z
        movem.l (a2),d3-d5      ; get target x,y and z
        exg.l   d1,d2           ; swap over Sz and Sy
        exg.l   d4,d5           ;  "    "   Dz and Dy
        lea     24+.srce(pc),a0 ; ptr to end of work area
        movem.l d0-d5,-(a0)     ; put the rearranged values into a work
                                ; area
        lea     .dest(pc),a2
        bsr     bearing
        move.w  d0,d1
; d1.w = heading
        lea     .srce(pc),a0
        lea     .dest(pc),a2
        bsr     flat_Distance
        lea     .srce(pc),a0    
        move.l  20(a0),d2        ; get dest Z
        sub.l   8(a0),d2       ; dest Z - source Z
        move.l  d2,12(a0)       ; result into dest X
        bsr     bearing
        exg.l   d0,d1           ; d1 = pitch , d0 = heading
        move.l  16(a0),d2       ; d2 = dest Y
        rts

; temp work space for intercept

.srce   ds.l    3
.dest   ds.l    3


;-------------------------------------------------------------------------
; Procedure:    WORLD_2_SEC
; Description:  Convert 3D world coords into seconds of lat/long
; Author:       Dave                                    /Jim
; Date:         2/10/89                                 /Today
;
; 1" Lat  = 48.26 Y units
; 1" Long = 45.1275 X units
;
; For full discussion see SEC_2_WORLD
;
;
; Exit:-
;               D0.l {ax/bx} = latitude  (in seconds)  ax-lo bx-hi
;               D1.l {cx/dx} = longitude (in seconds)  cx-lo dx-hi
;
; Entry:-
;               D0.l {ax/bx} = world z
;               D1.l {cx/dx} = world x
;-------------------------------------------------------------------------
world_2_sec     xdef    world_2_sec
        lsl.l   #2,d0                           ;*4
        move.l  d0,d2
        lsl.l   #3,d0
        add.l   d0,d2                           ;*4+ *32
        lsl.l   #1,d0
        add.l   d0,d2                           ;*100
        divu    #4826,d2                        ;48.26
        moveq   #0,d0
        move    d2,d0                           /48.26
        lsl.l   #4,d1
        move.l  d1,d2
        lsl.l   #3,d1
        add.l   d1,d2
        lsl.l   #1,d1
        add.l   d1,d2                           ;*400
        divu    #18051,d2
        moveq   #0,d1
        move    d2,d1
        add.l   #long101,d1
        add.l   #lat15,d0

        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    SEC_2_WORLD
; Description:  Convert seconds into 3D world coordinates
; Author:       Dave Whiteside                  /Russell Payne
; Date:         2/10/89                         /Thursday 13th April 1989
;
; 1 3D unit = 64 cm
; 1 degree latitude  = 60.0 nm = 11,119,104 cm
; 1 degree longitude = 56.1 nm = 10,397,376 cm
;
; The world coordinate system origin is based at 101x long 15x lat
;
; 1x longitude = 10397376 cm
; 1' longitude = 173289.6 cm
; 1" longitude = 2888.16 cm
;              = 45.1275 units
;
; 1x latitude  = 11119104 cm
; 1' latitude  = 185318.4 cm
; 1" latitude  = 3088.64 cm
;              = 48.26 units
;
; Entry:-
;               D0.l = latitude  (in seconds)  {ax/bx} ax-lo bx-hi
;               D1.l = longitude (in seconds)  {cx/dx} cx-lo dx-hi
;
; Exit:-
;               D0.l    {ax/bx} = world z
;               D1.l    {cx/dx} = world x
;               D2.l    trashed
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
sec_2_world     xdef    sec_2_world
        sub.l   #lat15,d0                       ;based arround origin
        swap    d0
        tst.w   d0
        beq.s   tinylat
        swap    d0
        lsl.l   #4,d0
        move.l  d0,d2
        lsl.l   #1,d0
        add.l   d2,d0                           ;*48
        bra.s   dolong
tinylat
        swap    d0
        move.l  d0,d2                           ;store x1
        lsl.l   #4,d0
        add.l   d0,d2                           ;store x17
        lsl.l   #6,d0
        add.l   d0,d2                           ;store x1041
        lsl.l   #1,d0
        add.l   d2,d0                           ;d0 = x3089
        asr.l   #6,d0                           ;d0 = d0 /64
dolong
        sub.l   #long101,d1                     ;based arround origin
        swap    d1
        tst     d1
        beq.s   bigok
        swap    d1
        move.l  d1,d2                           ;store x1
        lsl.l   #2,d1                           ;x4
        add.l   d1,d2                           ;store x5
        lsl.l   #1,d1
        add.l   d1,d2                           ;store x13
        lsl.l   #2,d1
        add.l   d2,d1                           ;d1 = x45
        bra.s   common
bigok
        swap    d1
        lsl.l   #3,d1
        move.l  d1,d2                           ;store x8
        lsl.l   #3,d1
        add.l   d1,d2                           ;store x72
        lsl.l   #2,d1
        add.l   d1,d2                           ;store x328
        lsl.l   #1,d1
        add.l   d1,d2                           ;store x840
        lsl.l   #2,d1
        add.l   d2,d1                           ;d1 = x2888
        asr.l   #6,d1                           ; div 64
common
        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    alt_2_world
; Description:  convert altitude in feet into centimetres
; Author:       Dave Whiteside                  /Russell Payne
; Date:         Friday 29/10/89                 /Friday 5th May 1989
;
;               
;               Multiplys by 30
;
; Entry:-
;               d0.l                            /bx/ax = altitude
;
; Exit:-
;               d0.l                            /bx/ax = y-position
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
alt_2_world     xdef    alt_2_world
        mulu    #31130,d0

        rts


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Get_Num: Get a leading rubbish,rubbish terminated number
; Returns: Carry set if number no good
;          Zero set if null terminator before digit
;               or greater then 32 bits or zero
;          Carry clear if number OK
;          d0 holds 32 bit number
;       stomps D0 / D1
;---------------------------------------------------------
get_num
        moveq   #0,d0
        move.l  d0,d1
wait_4_start
        move.b  (a0)+,d1
        beq.s   dead_end                        ;no number at all
        cmp.b   #'0',d1
        blt.s   wait_4_start                    ;less than 0
        cmp.b   #'9',d1
        bgt.s   wait_4_start                    ;greater that 9
start_converting_number
        sub     #$30,d1                          ;make into binary
        add.l   d1,d0                           ;add in as a 'unit' value
        move.b  (a0)+,d1                        ;get next character
        beq.s   end_num                         ;the number has finished 0
        cmp.b   #'0',d1
        blt.s   end_num                         ;the number has finished <0
        cmp.b   #'9',d1
        bgt.s   end_num                         ;the number has finished >9
        muls    #10,d0                          ;multiply for the next units
        bvs.s   num_over                        ;pooee the number has overfloved
        bra.s   start_converting_number
end_num
        or.l    d0,d0                           ;carry clear (correct number)
        rts
num_over
dead_end
        move.l  #-1,d0                          ;must cause overflow
        addq    #1,d0                           ;zero length number (correct zero)
        rts



;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    ASCII_2_BIN_32
; Description:  Convert ASCII decimal into 32 bit binary
; Author:       Russell Payne
; Date:         Friday 7th April 1989
;
; Entry:-       ds:si = pointer to zero terminated string
;
; Exit:-        ax = lo-word
;               bx = hi-word
;               cx = ?
;               dx = ?
;               bp = ?
;               ds:si = error or zero
;               carry set if out of range or non-decimal
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
;
; Procedure:    ASCII_2_BIN
; Description:  Convert ASCII decimal into 16 bit binary
; Author:       Russell Payne
; Date:         Wednesday 5th April 1989
;
; Entry:-       ds:si = pointer to zero terminated string
;
; Exit:-        ax = number
;               carry set if out of range or non-decimal
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
ascii_2_bin_32  xdef    ascii_2_bin_32
ascii_2_bin     xdef    ascii_2_bin
        bsr     get_num
;       bcs     __error
        rts
__error
        





;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    DEGREES_2_SECONDS
; Description:  Convert an ASCII string into seconds from 000,000,000
; Author:       Dave Whiteside   /      Russell Payne
; Date:         12/9/89          /      Tuesday 11th April 1989
;
; Entry:-
;               A0 = ptr to zero terminated ascii string
;
; Exit:-
;               D0 = seconds
;               Stomps. D0 /D1 /D2
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
degrees_2_seconds       xdef    degrees_2_seconds
        bsr.s   get_num                 ;read degrees
        beq.s   badio                   ;0 not allowed
        bcs.s   badio                   ;negative or bad values not allowed
        cmp.l   #179,d0                 ;179
        bgt.s   badio
hours_entry
        muls    #3600,d0                ;convert to seconds
        move.l  d0,d2                   ;save value
        bsr.s   get_num                 ;read minutes
        bcs.s   badio                   ;bad values not allowed
        moveq   #0,d1
        move    #60,d1
        cmp.l   d1,d0                   ;60
        bge.s   badio
        muls    d1,d0                   ;convert to seconds
        add.l   d0,d2                   ;add in the minutes
        bsr.s   get_num                 ;read seconds
        bcs.s   badio                   ;bad values not allowed
        moveq   #0,d1
        move    #60,d1
        cmp.l   d1,d0                   ;60
        bge.s   badio
        add.l   d0,d2                   ;add in the seconds
        rts
badio
        moveq   #0,d0
        subq    #1,d0                   ;carry flag set for error
        rts




;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    TIME_2_SECONDS
; Description:  Convert an ASCII string into seconds from 00:00.00
; Author:       Dave                                    /Russell Payne
; Date:         4/10/89                                 /Friday 7th April 1989
;
; Entry:-
;               a0 = ptr to zero terminated ascii string ds:si
;
; Exit:-
;               D0.l = seconds since 00:00.00
;                       ax = lo-word of seconds since 00:00.00
;                       bx = hi-word of seconds since 00:00.00
;               carry set if error in conversion
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
time_2_seconds  xdef    time_2_seconds
        bsr     get_num
        bcs.s   badio
        cmp     #23,d0
        bra.s   hours_entry


;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    SECONDS_2_DEGREES
; Description:  converts number of seconds into a deg/min/sec format
; Author:       Russell Payne
; Date:         Tuesday 18th April 1989
;
; Entry:-
;               D0 = seconds
;               A2 = ptr to buffer to place time
;
; Exit:-
;               A2 = "nnn,nn,nn"
;
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
seconds_2_degrees       xdef    seconds_2_degrees
        movem.l d0/d1/a2,-(sp)
        divu    #3600,d0                ;find the number of degrees
        bsr.s   three_digis             ;outputs 3 digits from d0.w and clears it d0.w
        move.b  #',',(a2)+              ;the seperator
        swap    d0                      ;seconds (up to 1 degree)
        divu    #60,d0                  ;find the number of minutes
        bsr.s   two_digis               ;outputs 2 digits from d0.w and clears it d0.w
        move.b  #',',(a2)+              ;the seperator
        swap    d0                      ;seconds (up to 1 minute)
        bsr.s   two_digis
        movem.l (sp)+,d0/d1/a2
        rts

;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
; Procedure:    SECONDS_2_TIME
; Description:  converts number of seconds into a time 00:00.00
; Author:       Dave Whiteside {from the IBM version by Russell Payne}
; Date:         11/09/89                {Friday 7th April 1989}
;
; Entry:-
;               d0.l = number of seconds
;               a2 = ptr to buffer to place time
;
; Exit:-
;               a2 = "nn:nn.nn"
;
; Currupts:     Nothing
;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
seconds_2_time  xdef    seconds_2_time
        movem.l d0/d1/a2,-(sp)
        divu    #3600,d0                ;find the number of hours
        bsr.s   two_digis               ;outputs 2 digits from d0.w and clears it d0.w
        move.b  #':',(a2)+              ;the seperator
        swap    d0                      ;seconds (up to 1 hour)
        divu    #60,d0                  ;find the number of minutes
        bsr.s   two_digis               ;outputs 2 digits from d0.w and clears it d0.w
        move.b  #'.',(a2)+              ;the seperator
        swap    d0                      ;seconds (up to 1 minute)
        bsr.s   two_digis
        movem.l (sp)+,d0/d1/a2
        rts


three_digis       xdef    three_digis
        moveq   #0,d1
        move    d0,d1
        divu    #100,d1                 ;for hundreds
        add.b   #$30,d1                 ;convert to ascii
        move.b  d1,(a2)+
        clr.w   d1
        swap    d1
        bra.s   two_dig
two_digis       xdef    two_digis
        moveq   #0,d1
        move    d0,d1
two_dig
        divu    #10,d1                  ;for tens
        add.b   #$30,d1                 ;convert to ascii
        move.b  d1,(a2)+
        swap    d1
        add.b   #$30,d1                 ;convert to ascii
        move.b  d1,(a2)+
        clr.w   d0
        rts                


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PROCEDURE:    Znumout
; DESCRIPTION:  convert an unsignded 16 bit binary number into 5 digit
;               ASCII decimal
; AUTHOR:       Paul
; ENTRY:        A2=ptr to string storeage space, D0=number to convert
Znumout xdef    znumout
        bsr     numout
        subq.l  #4,a2
        moveq.b #'0',d1
        moveq.b #' ',d2
        cmp.b   (a2),d1
        bne.s   znumexit
        move.b  d2,(a2)+
        cmp.b   (a2),d1
        bne.s   znumexit
        move.b  d2,(a2)+
        cmp.b   (a2),d1
        bne.s   znumexit
        move.b  d2,(a2)+
        cmp.b   (a2),d1
        bne.s   znumexit
        move.b  d2,(a2)+
znumexit
        rts


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PROCEDURE:    Numout        
; DESCRIPTION:  unsigned 16 bit ASCII to decimal conversion
; ENTRY:        a2=area to store ASCII characters, D0=number to convert
; AUTHOR:       Paul
Numout  xdef    numout
        move.b  #'0',(a2)
gt10000 sub.w   #10000,d0
        bcs.s   lt10000
        addq.b  #1,(a2)
        bra.s   gt10000

lt10000 add.w   #10000,d0
        addq.l  #1,a2
        move.b  #'0',(a2)
gt1000  sub.w   #1000,d0
        bcs.s   lt1000
        addq.b  #1,(a2)
        bra.s   gt1000

lt1000  add.w   #1000,d0
        addq.l  #1,a2
        move.b  #'0',(a2)
gt100   sub.w   #100,d0
        bcs.s   lt100
        addq.b  #1,(a2)
        bra.s   gt100

lt100   add.w   #100,d0
        addq.l  #1,a2
        move.b  #'0',(a2)
gt10    sub.b   #10,d0
        bcs.s   lt10
        addq.b  #1,(a2)
        bra.s   gt10

lt10    add.b   #'0'+10,d0
        addq.l  #1,a2
        move.b  d0,(a2)
        rts

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PROCEDURE:    Numout32        
; DESCRIPTION:  unsigned 32 bit ASCII to decimal conversion
; ENTRY:        a2=area to store ASCII characters, D0=number to convert
; EXIT:         a string of 10 ascii characters
; AUTHOR:       Paul
; CORRUPTS:     d0,d1,d6,a0,a2,a6

Numout32 xdef Numout32
        move.l  a2,a6           ; save ptr to start
        lea     Table32(pc),a0
        moveq.b #9,d6   ; 10 digit numbers
.newNum
        move.l  (a0)+,d1
        move.b  #'0'-1,(a2)
.loop
        addq.b  #1,(a2)
        sub.l   d1,d0
        bcc.s   .loop
        add.l   d1,d0
        addq.l  #1,a2   ; point to next storeage space
        dbf     d6,.newNum
        moveq.b #9,d6
.wipe0s
        cmp.b   #'0',(a6)
        bne.s   .xit
        move.b  #' ',(a6)+
        dbf     d6,.wipe0s
.xit
        rts     
Table32
        dc.l 1000000000
        dc.l 100000000
        dc.l 10000000
        dc.l 1000000
        dc.l 100000
        dc.l 10000
        dc.l 1000
        dc.l 100
        dc.l 10
        dc.l 1

