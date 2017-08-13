TEST            EQU 1
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
ZF_BITS         EQU 12
ZF_EXT          EQU 1<<ZF_BITS
;-------------------------------------------------------------------------------
ROT_FRAMES      EQU 64
ROT_BITS        EQU 6
;-------------------------------------------------------------------------------
                RSSET 0
x:              RS.W 1
y:              RS.W 1
z:              RS.W 1
u:              RS.W 1
v:              RS.W 1
vertex_size:    RS.L 0
;-------------------------------------------------------------------------------

                OPT D+

                >PART ' init machine '

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1

                move    #$2700,SR
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                lea     stack,SP

                move.l  #vbl,$00000070.w
                lea     rte(PC),A0
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w

                move    #$2300,SR

                bsr     wait_vbl
                clr.b   $FFFF8260.w

                lea     screen0(PC),A0
                move.l  #scr_ram,D0
                clr.b   D0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w  ; screen1
                ENDPART

                movem.l colors0,D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

                bsr     init_test_samples

                bsr     Init_Oszi

                bsr     init_sintab

                bsr     precalc_rotations

                clr.w   frame_total

loop:
                bsr     swap_screens
                bsr     wait_vbl
                clr.w   $FFFF8240.w

                bsr     new_samples_rnd

                bsr     DO_OSZI_ALL


                move.w  #$0007,$FFFF8240.w

                addq.w  #1,frame_total

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne.s   loop

                move.w  xmin,D0
                move.w  ymin,D1

                movea.w xmax,A0
                movea.w ymax,A1

                DC.L $4AFC4E71
                bra     loop

;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts
                ENDPART
;-------------------------------------------------------------------------------
vbl:            >PART
                movem.l D0-A6,-(SP)

                movea.l sub_vbl(PC),A0
                jsr     (A0)

                movem.l (SP)+,D0-A6
                addq.l  #1,$00000466.w
rte:            rte
                ENDPART
sub_vbl:        DC.L rts
rts:            rts
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
inc_w:          >PART
                moveq   #5-1,D0
                lea     w0(PC),A0
                lea     w0_inc(PC),A1
iwl:
                move.w  (A0),D1
                add.w   (A1)+,D1
                and.w   #SIN_MASK,D1
                move.w  D1,(A0)+
                dbra    D0,iwl
                rts
                ENDPART
                >PART 'angles'
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0
yr:             DC.W 256*2

w0_inc:         DC.W 11*2
w1_inc:         DC.W 13*2
w2_inc:         DC.W -14*2
w3_inc:         DC.W -7*2

yr_inc:         DC.W 8*2*2
                ENDPART
;-------------------------------------------------------------------------------
init_sintab:    >PART           ;; 36 bytes!   (and the quality fit's !!)

;
; 36bytes Sine-generator   MC68000!!  (no 030 muls.l!) (w)`99 defjam/checkpoint!
;   * BUT a bit erroranous
;   * this version a bit corrected !?

size            SET 2048

;; Erweiterungsfaktor ist 65536*16384

sin_inc         SET 3294198     ;GENAU: 3294198     ;; 2*PI / size
cos_inc         SET -20212      ;   10106*2     ;; ((2*PI)^2) / (size^2)


                lea     sintab,A0
                moveq   #0,D0           ;oe

                move.l  #1*sin_inc,D3
                move.w  #2048-1,D7
init_sin_:
                move.l  D0,D4
                swap    D4
                move.w  D4,2048*2(A0)
                move.w  D4,(A0)+
                muls    #cos_inc,D4

                add.l   D4,D4
                swap    D4
                ext.l   D4

                add.l   D4,D3           ;sin_inc - erg1
                add.l   D3,D0           ;oe + sin_inc
                dbra    D7,init_sin_
                rts

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
                IFNE TEST
;-------------------------------------------------------------------------------
instr_cycle:    >PART
                move.l  #svbl,$00000070.w
                move    #$2300,SR
sloop:
                lea     stack,SP
                move    #$2300,SR
                clr.b   $FFFF8201.w
                clr.b   $FFFF8203.w

                bsr     wait_vbl_cc
                move    #$2700,SR

                moveq   #0,D0
                moveq   #0,D1

                movea.l screen1,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                moveq   #10,D7

;get synced
                move.l  D0,resd0+2
sts:            move.b  $FFFF8209.w,D0
                beq.s   sts
                not.w   D0
                lsl.w   D0,D0

;sync to $0 - $A0 Position!
w:              move.b  $FFFF8209.w,D0
                bne.s   w

resd0:          move.l  #$00000000,D0
                DS.W 40,$00004E71

uzi:
;Sync_Pos should be Zero now!!   (1 nop before --> Sync_pos=2 !)
                move.b  $FFFF8209.w,_1st+3 ;3
;--------------------------------------------------------------------
your_code_here:


es:
;--------------------------------------------------------------------
                move.b  $FFFF8209.w,_2nd+3 ;3            move.b (a3),d4 [2]
;Maximum_Count_Cycles = (160 - 6)/2 = 77 Nops!

_2nd:           move.b  #0,D0
_1st:           sub.b   #0,D0
                sub.b   #12,D0
                lsr.b   #1,D0           ;/2 = nop's
                and.l   #$000000FF,D0

                lea     stack,SP
                DC.L $4AFC4E71

                move.w  #$0700,$FFFF8240.w
                move.w  #$0000,$FFFF8240.w
                jmp     sloop

svbl:           addq.l  #1,$00000466.w
                rte
wait_vbl_cc:
                clr.l   $00000466.w
wv_cc:          tst.l   $00000466.w
                beq.s   wv_cc
                rts

                ENDPART
;-------------------------------------------------------------------------------
                ENDC



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
DO_OSZI_ALL:    >PART
                bsr     get_rotation_frame
                bsr     clear_eor_buffer
                bsr     oszi
                bsr     output_eor_buffer
                rts
                ENDPART
;-------------------------------------------------------------------------------
get_rotation_frame:>PART
                move.w  frame_total(PC),D0
                moveq   #ROT_FRAMES-1,D1
                and.w   D0,D1
                move.w  D1,frame
; get start side
                lsr.w   #ROT_BITS,D0
                and.w   #3,D0           ; 4 sides
                mulu    #320,D0
                move.w  D0,side_o_offset
                rts
                ENDPART
frame_total:    DC.W 0          ; total frame
frame:          DC.W 0          ; rotation frame
side_o_offset:  DC.W 0          ; oszi history side offset
;-------------------------------------------------------------------------------
; x,y,z, u,v
proj_z:         DC.W -800
z_zoom:         DC.W 0
                >PART ' cube constants '
; xy_t_scale = 0.398 * 16384 = 6520

xy_t_scale:     DC.W 6630       ; DC.W 6650       ;6520       ; 2^14

; scale_x = 2*100
; scale_y = 36.5
; scale_z = 2*100

MX              SET 1000        ;
MY              SET 275         ;
MZ              SET 1000        ;

UT              SET 319         ;
VT              SET 0           ; not used
;-------------------------------------------------------------------------------
uv_set0:        DC.W 0*UT,0     ; u,v
uv_set1:        DC.W 1*UT,0     ; u,v
                ENDPART
cube_vertices:  >PART

                DC.W 8          ; amount vertices

                DC.W -MX,MY,-MZ ; x,y,z  (0)
                DC.W 0*UT,0*VT  ; u,v

                DC.W MX,MY,-MZ  ; x,y,z  (1)
                DC.W 1*UT,0*VT  ; u,v

                DC.W MX,-MY,-MZ ; x,y,z  (2)
                DC.W 1*UT,1*VT  ; u,v

                DC.W -MX,-MY,-MZ ;x,y,z  (3)
                DC.W 0*UT,1*VT  ; u,v
;--------------------------------------------
                DC.W -MX,MY,MZ  ; x,y,z  (4)
                DC.W 1*UT,0*VT  ; u,v

v5_uv:          DC.W MX,MY,MZ   ; x,y,z  (5)
                DC.W 0*UT,0*VT  ; u,v

                DC.W MX,-MY,MZ  ; x,y,z  (6)
                DC.W 0*UT,1*VT  ; u,v

                DC.W -MX,-MY,MZ ; x,y,z  (7)
                DC.W 1*UT,1*VT  ; u,v
;--------------------------------------------
                ENDPART
;-------------------------------------------------------------------------------
check_minmax:   >PART
*   DC.L $4AFC4E71

                cmp.w   xmin(PC),D0
                bge.s   nxmin
                move.w  D0,xmin
nxmin:
                cmp.w   xmax(PC),D0
                ble.s   nxmax
                move.w  D0,xmax
nxmax:
                cmp.w   ymin(PC),D1
                bge.s   nymin
                move.w  D1,ymin
nymin:
                cmp.w   ymax(PC),D1
                ble.s   nymax
                move.w  D1,ymax
nymax:
                rts

xmin:           DC.W $7FFF
xmax:           DC.W $8000
ymin:           DC.W $7FFF
ymax:           DC.W $8000

                ENDPART
;-------------------------------------------------------------------------------
calc_cube_points:>PART

*    DC.L $4AFC4E71

                bsr     set_rotation

                lea     cube_vertices(PC),A0
                move.w  (A0)+,D6
                subq.w  #1,D6

                lea     _3d_result,A1
ccp_l:
                movem.w (A0)+,D0-D2     ; x,y,z

                move.w  D0,D3           ;xx
                move.w  D2,D4
                muls    ycos(PC),D0     ; x*cos
                muls    ysin(PC),D4     ; z*sin
                add.l   D4,D0

                muls    ycos(PC),D2     ; z*cos
                muls    ysin(PC),D3     ; x*sin
                sub.l   D3,D2

                swap    D0
                swap    D2
                bsr     get_zf

                move.w  D2,D3
                muls    xy_t_scale(PC),D3 ; 2^14
                moveq   #14,D4
                asr.l   D4,D3

                muls    D3,D0
                muls    D3,D1

                moveq   #ZF_BITS,D3
                asr.l   D3,D0
                moveq   #ZF_BITS+2,D3
                asr.l   D3,D1

                add.w   #160,D0
                add.w   #100,D1

*   bsr     check_minmax

                move.w  D0,x(A1)        ; xt
                move.w  D1,y(A1)        ; yt
                move.w  D2,z(A1)        ; zf

                movem.w (A0)+,D3-D4     ; u,v
                move.w  D3,u(A1)
                move.w  D4,v(A1)

                lea     vertex_size(A1),A1
                dbra    D6,ccp_l
                rts
                ENDPART
; D2...z
get_zf:         >PART           ; D2.z --> D2.zf
                move.w  proj_z(PC),D3
                sub.w   D2,D3           ; proj_z - z

                neg.w   D2
                add.w   z_zoom(PC),D2   ; z_zoom - z
                ext.l   D2
                moveq   #ZF_BITS,D4
                asl.l   D4,D2
                divs    D3,D2           ;(z_zoom-z)/(proj_z-z)
                neg.w   D2
                add.w   #ZF_EXT,D2
                rts
                ENDPART
set_rotation:   >PART
                lea     sintab,A0
                adda.w  yr(PC),A0
                move.w  (A0),ysin
                move.w  COS(A0),ycos
                rts
ysin:           DC.W 0
ycos:           DC.W 0
                ENDPART
;-------------------------------------------------------------------------------
cube_faces_XX:  >PART
                DC.W 0,1
                DC.W 1,5
uv_v0:          DC.W 0,0
uv_v1:          DC.W 0,0
                ENDPART
;-------------------------------------------------------------------------------
calc_cube_span: >PART

                move.w  #$7FFF,x0_oszi  ; start
                move.w  #$8000,x1_oszi  ; end

                movem.l A0-A3,-(SP)

                moveq   #vertex_size,D5
                moveq   #vertex_size,D6
                mulu    (A2)+,D5
                mulu    (A2)+,D6

                lea     _3d_result,A0
                lea     (A0),A1
                adda.w  D5,A0
                adda.w  D6,A1

                move.l  uv_v0(PC),u(A0)
                move.l  uv_v1(PC),u(A1)

                movem.w x(A0),D0-D1
                movem.w x(A1),D2-D3

                cmp.w   D0,D2
                ble.s   dc_hidden

                bsr     calc_line_span

                lea     values,A0
                movem.w x0_oszi(PC),D0-D1
                bsr     make_U_deltas

                subq.w  #1,x1_oszi      ; end

dc_hidden:
                movem.l (SP)+,A0-A3
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0.v0
; A1.v1
calc_line_span: >PART

                lea     values,A3

*    DC.L $4AFC4E71

                cmp.w   x0_oszi(PC),D0
                bge.s   cls_x0
                move.w  D0,x0_oszi      ; start
cls_x0:
                cmp.w   x1_oszi(PC),D2
                ble.s   cls_x1
                move.w  D2,x1_oszi      ; end
cls_x1:
                sub.w   D0,D2           ; dx
                move.w  D2,dx

                lsl.w   #2,D0
                adda.w  D0,A3           ; values start

                move.w  D2,D5
                move.l  #$00007FFF,D6
                divs    D5,D6           ; 1/dx
;---------------------------------------------------
; adjust y
                sub.w   #100,D1
                sub.w   #100,D3
o               SET (66*2048)/50
                mulu    #o,D1
                mulu    #o,D3
                moveq   #11,D4
                lsr.l   D4,D1
                lsr.l   D4,D3
;---------------------------------------------------
                sub.w   D1,D3           ; dy
                muls    D6,D3           ; dy/dx
                asl.l   #1,D3
                swap    D1
                clr.w   D1
                add.l   #$00008000,D1   ; 0.5
                move.l  D1,D0
                move.l  D3,y_inc        ; inc
;---------------------------------------------------
; D0,A0 Y

*   DC.L $4AFC4E71

; Zf
                move.w  z(A0),D2        ; z0
                move.w  z(A1),D5        ; z1
                sub.w   D2,D5           ; z1-z0
                muls    D6,D5           ; 1/dx
                asl.l   #1,D5
                movea.l D5,A2
                swap    D2
*  clr.w   D2
                move.w  #$8000,D2
;--------------------------------------------------
; U
                move.w  u(A0),D1        ; u0
                move.w  u(A1),D5        ; u1

                mulu    z(A0),D1        ; U0 * Z0
                mulu    z(A1),D5        ; U1 * Z0
                lsr.l   #8,D1
                lsr.l   #8,D5

                sub.w   D1,D5           ; u1-u0
                muls    D6,D5           ; 1/dx
                asl.l   #1,D5
                movea.l D5,A1
                swap    D1
*  clr.w   D1
                move.w  #$8000,D1
; D1,A1 U
; D2,A2 Z

*  DC.L $4AFC4E71

                movea.l y_inc(PC),A0
                move.w  dx(PC),D6

                moveq   #(16-ZF_BITS)+4,D4
calc_span_loop:
                swap    D0
                move.b  D0,(A3)+        ; Y
                swap    D0
                move.b  #$FE,(A3)+      ; sample masker

                swap    D2              ; Zint
                move.l  D1,D5
                divu    D2,D5           ; U/Z
                lsr.w   D4,D5
                move.w  D5,(A3)+
                swap    D2

                add.l   A0,D0           ; y_step
                add.l   A1,D1           ; u_step
                add.l   A2,D2           ; z_step
                dbra    D6,calc_span_loop
                rts

dx:             DC.W 0
y_inc:          DC.L 0

                ENDPART
;-------------------------------------------------------------------------------
; A0...array
; D0...x_start
; D1...x_end
make_U_deltas:  >PART

*  DC.L $4AFC4E71

                move.w  D1,D6
                subq.w  #1,D6

                sub.w   D0,D6
                bpl.s   opp
                DC.L $4AFC4E71
                rts
opp:
                lsl.w   #2,D0
                adda.w  D0,A0

                addq.l  #2,A0
                move.w  (A0)+,D1
mUd:
                addq.l  #2,A0
                move.w  (A0),D0
                sub.w   D1,D0
                move.w  D0,(A0)+
                add.w   D0,D1
                dbra    D6,mUd
                rts
                ENDPART
;-------------------------------------------------------------------------------
precalc_rotations:>PART

*  DC.L $4AFC4E71

                lea     rot_list,A0
                lea     rot_pre_data,A1

                move.w  #ROT_FRAMES-1,-(SP)
                clr.w   frame
pc_frames:
                move.l  A1,(A0)+
                pea     (A0)

                move.w  frame(PC),D0
                and.w   #ROT_FRAMES-1,D0
                mulu    #COS/ROT_FRAMES,D0 ; 90 degrees/frames
                and.w   #COS-2,D0       ;    90 degrees
                move.w  D0,yr

                movem.l A0-A3,-(SP)
                bsr     calc_cube_points
                movem.l (SP)+,A0-A3

                move.l  uv_set0(PC),uv_v0
                move.l  uv_set1(PC),uv_v1
; .w x_start
; .w x_end
; .w x_start
; .w x_end
; 320*2*2 data
                lea     cube_faces_XX(PC),A2
; edge 01
                bsr     calc_cube_span
                move.l  x0_oszi(PC),(A1)+ ; x_start
                addq.l  #4,A2           ;   next face(edge)
; edge 15
                bsr     calc_cube_span
                move.l  x0_oszi(PC),(A1)+ ; x_start

                bsr     copy_span_data

                movea.l (SP)+,A0
                addq.w  #1,frame
                subq.w  #1,(SP)
                bpl     pc_frames
                addq.l  #2,SP

*    DC.L $4AFC4E71
                rts
                ENDPART
copy_span_data: >PART
                lea     values,A0
                moveq   #(320*2*2)/16-1,D0
csdl:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D0,csdl
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; OSZI - MAIN ROUTINE
;-------------------------------------------------------------------------------
;----------------------------------------- little oszilloscope -----------------
OszY            SET 50          ; height
EOR_BUFFER_OFFSET SET 50*4      ;((100-OszY))*2
;---------------------------------------
OI              SET 1
OSZI_MAX        EQU 2048*OI

INSERT_POS      EQU 320         ;512

x0_oszi:        DC.W 0          ; start
x1_oszi:        DC.W 319        ; end

o_pos:          DC.W 0          ; history "scroll" offset
values_ptr:     DC.L 0          ; ZZyy, U table

spl_work_ptr:   DC.L samples
;---------------------------------------
oszi:           >PART

                bsr.s   do_oszi

* addi.w  #23,o_pos       ; 23

                addi.w  #24,o_pos

                rts
do_oszi:
*    DC.L $4AFC4E71

                bsr     copy_oszi       ; new data

                lea     rot_list,A0
                move.w  frame(PC),D0
                and.w   #ROT_FRAMES-1,D0
                lsl.w   #2,D0
                movea.l 0(A0,D0.w),A0

                lea     8(A0),A1        ; skip x start,end values
                move.l  A1,values_ptr

                move.w  side_o_offset(PC),D1 ; start side offset
; side A
                move.l  (A0)+,D0        ; x_start, x_end
                cmp.w   #$8000,D0
                beq.s   cube_none0
                move.l  D0,x0_oszi

                movem.l D1/A0,-(SP)
                bsr.s   do_cube_part_oszi
                movem.l (SP)+,D1/A0
cube_none0:
;side B
                add.w   #320,D1         ; next side offset
                move.l  (A0)+,D0        ; x_start, x_end
                cmp.w   #$8000,D0
                beq.s   cube_none1
                move.l  D0,x0_oszi

*   DC.L $4AFC4E71

                bsr.s   do_cube_part_oszi
cube_none1:
                rts
;--------------------------------------------------------------
; D1...side offset
do_cube_part_oszi:
                lea     oszi_hist,A0    ; samples history

                move.w  o_pos(PC),D2
                add.w   D1,D2           ; + side offset
                move.w  #OSZI_MAX-1,D3
                and.w   D3,D2

*   DC.L $4AFC4E71

;;; lea     values,A3       ; ZZ, Oszi values

                movea.l values_ptr(PC),A3 ; ZZ, Oszi values


                move.w  x0_oszi(PC),D0
                lsl.w   #2,D0
                adda.w  D0,A3
oszi_set_values:
                lea     eor_buffer+100*4,A2

di0             SET 2
di1             SET -2+200*4
                move.l  #(di1<<16)|di0,D4

                move.w  x0_oszi(PC),D0
                lsl.w   #3,D0
                lea     x_table_eor,A1
                adda.w  D0,A1
                move.w  (A1)+,D1        ; pixel
                adda.w  (A1)+,A2        ; Offset eor_buffer
                move.l  (A1)+,D4        ; X_INC eor_buffer

                lea     oszi_code_pointers,A1
                movem.w x0_oszi(PC),D5-D6
                sub.w   D5,D6           ; length
                lsl.w   #2,D6
                move.l  0(A1,D6.w),-(SP)

                lea     y_tab_scaled,A1
                rts                     ; start filling!
oszi_set_x_start:
                REPT 320
; D0    value
; D1    pix
; D2,D3 pos
; D4    X_INC eor_buffer
;
; A0    oszi
; A1    y_tab
; A2    eor_buffer
; A3    values
                move.w  (A3)+,D0        ; ZZ|FE

                add.w   (A3)+,D2        ; Oszi Pos increment DELTA_STEP!
                and.w   D3,D2
                and.b   0(A0,D2.w),D0   ; read sample & MASK $FE !

                move.w  0(A1,D0.w),D0   ; y scale

                eor.w   D1,0(A2,D0.w)   ; set pixel
                neg.w   D0
                eor.w   D1,0(A2,D0.w)   ; set pixel

                ror.w   #1,D1           ; next pix
                bcc.s   *+4
                adda.w  D4,A2           ; X_INC eor_buffer
                swap    D4
                ENDR
oszi_set_x_end:
oszi_code_size  SET (oszi_set_x_end-oszi_set_x_start)/320
                rts


xinc:           DC.L 0
xi2:            DC.L 0

                ENDPART
;---------------------------------------
copy_oszi:      >PART

*    movea.l spl_play_ptr(PC),A0
                movea.l spl_work_ptr(PC),A0

                lea     oszi_hist,A1

                move.w  o_pos(PC),D0
                add.w   #INSERT_POS,D0

                move.w  #OSZI_MAX-1,D1

                and.w   D1,D0
                adda.w  D0,A1           ; dest offset

                lea     ocopy_320+320*2(PC),A2

                sub.w   D0,D1           ; rest length
                cmp.w   #320,D1         ; exceeds bound?
                ble.s   oc_le
                move.w  #320,D1
oc_le:
; end size(wrap)
                move.w  #320,D2
                sub.w   D1,D2

                add.w   D1,D1
                add.w   D2,D2
                neg.w   D1
                neg.w   D2
                jsr     0(A2,D1.w)

                lea     oszi_hist,A1    ; wrap!
                jmp     0(A2,D2.w)
ocopy_320:
                REPT 320
                move.b  (A0)+,(A1)+
                ENDR
                rts
                ENDPART
;-------------------------------------------------------------------------------
clear_eor_buffer:>PART

*   DC.L $4AFC4E71

                lea     eor_buffer,A3
                lea     EOR_BUFFER_OFFSET(A3),A3
                lea     (20)*200*2(A3),A3

                lea     -100*4(A3),A3   ; adjust

                movem.l zero(PC),D0-D6/A0-A2 ; 10*4 = 40 bytes
                move.w  #320/32-1,-(SP)
ceb3:
; 100 lines * 4 = 400 bytes
                REPT 10         ; 400 bytes
                movem.l D0-D6/A0-A2,-(A3)
                ENDR
                lea     -100*4(A3),A3   ; skip!
                subq.w  #1,(SP)
                bpl.s   ceb3
                addq.l  #2,SP
                rts

                ENDPART
;-------------------------------------------------------------------------------
output_eor_buffer:>PART

*    DC.L $4AFC4E71

*    movea.l spl_work_ptr(PC),A0
*    lea     eor_buffer,A0
*    move.w  #$0FF0,3*2(A0)
*    move.w  #$0FF0,7*2(A0)

                lea     eor_buffer,A0
                lea     EOR_BUFFER_OFFSET(A0),A0

                movea.l screen1(PC),A1
                lea     50*160(A1),A1
                addq.l  #6,A1           ; plane3,0

                move.w  #320/32-1,-(SP)
oeb:
o               SET 0
                movem.l (A0)+,D0-D6
                move.l  D0,(A1)
o               SET o+160
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D4,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D5,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D6,D0
                move.l  D0,o(A1)
o               SET o+160
; 7 lines
;--------------------------------------------------
; 100 - 7 = 93
;  93 / 6 = 15, rest 3

                REPT 15
; 6 lines
                movem.l (A0)+,D1-D6
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D4,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D5,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D6,D0
                move.l  D0,o(A1)
o               SET o+160
                ENDR
;----------------------------------------------------
                movem.l (A0)+,D1-D3
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160

                lea     100*4(A0),A0    ; skip

                lea     16(A1),A1

                subq.w  #1,(SP)
                bpl     oeb
                addq.l  #2,SP

                rts
                ENDPART
;-------------------------------------------------------------------------------
Init_Oszi:      >PART

                bsr     init_oszi_code_pointers
                bsr     init_x_table_eor
                bsr     init_y_tab      ;y_tab (fr oszi)
                rts
                ENDPART
;---------------------------------------
init_x_table_eor:>PART

*   DC.L $4AFC4E71

; .w pixel
; .w Offset eor_buffer
; .l X_INC eor_buffer

                lea     x_table_eor,A0
di0             SET 2
di1             SET -2+200*4
                move.l  #(di1<<16)|di0,D4
                moveq   #0,D0
                move.w  #$8000,D1
                move.w  #320-1,D6
ixte:
                move.w  D1,(A0)+        ; pixel
                move.w  D0,(A0)+        ; Offset eor_buffer
                move.l  D4,(A0)+        ; X_INC eor_buffer
                ror.w   #1,D1
                bcc.s   ixte2
                add.w   D4,D0           ; eor_buffer X inc
                swap    D4
ixte2:
                dbra    D6,ixte
                rts
                ENDPART
;---------------------------------------
init_oszi_code_pointers:>PART
                lea     oszi_code_pointers,A0
                lea     oszi_set_x_end(PC),A1
                move.w  #321-1,D6
soop:
                lea     -oszi_code_size(A1),A1
                move.l  A1,(A0)+
                dbra    D6,soop
                rts
                ENDPART
;---------------------------------------
init_y_tab:     >PART
; -128...+127

*   DC.L $4AFC4E71

                lea     y_tab_scaled,A0

                moveq   #-4,D1
                move.w  #$00FE,D5

yscaleO         SET (256*(OszY-1))/128

                moveq   #64,D3
iytab_scales:
                moveq   #64,D0
                sub.w   D3,D0

                move.w  #yscaleO,D4
                muls    D0,D4
                asr.l   #6,D4

                move.w  #256-1,D6
iytab2:
                moveq   #127,D0
                sub.w   D6,D0
                move.w  D0,D2           ; for index

                muls    D4,D0           ; *yscale
                asr.l   #8-2,D0
                bpl.s   y_is_pos
                neg.w   D0
y_is_pos:
                cmp.w   #2*4,D0
                bge.s   notMin
                moveq   #1*4,D0
notMin:
                and.w   D1,D0           ; -4 mask
                and.w   D5,D2           ; $00FE  index
                move.w  D0,0(A0,D2.w)   ;

                subq.w  #2,D6
                bpl.s   iytab2

                lea     256(A0),A0
                dbra    D3,iytab_scales

                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
init_test_samples:>PART
                lea     samples,A0
                move.w  #320-1,D6
                moveq   #0,D0

                move.l  #$1337C0DE,D2
its:
                move.w  D0,D1
                and.w   #127,D1

                move.b  D1,(A0)
*      move.b  #127,(A0)

                move.w  D2,D1
                lsr.w   #3,D1

                and.w   #1023,D1
                lsr.w   #2,D1
                cmp.w   #127,D1
                ble.s   *+2
                moveq   #127,D1

                addq.l  #5,D2
                rol.l   D2,D2
                move.b  D1,(A0)         *** SET

                addq.l  #1,A0
                addq.w  #1,D0
                dbra    D6,its
                rts
                ENDPART
;-------------------------------------------------------------------------------
rnd:            DC.L $1337C0DE
new_samples_rnd:>PART
                move.l  rnd(PC),D0
                moveq   #127,D6
                lea     samples,A0

                REPT 320
                move.w  D0,D1
                and.w   D6,D1
                move.b  D1,(A0)+
                addq.l  #5,D0
                rol.l   D0,D0
                ENDR
                move.l  D0,rnd
                rts
                ENDPART
;-------------------------------------------------------------------------------

                DATA
zero:           DS.L 16

screen0:        DC.L 0
screen1:        DC.L 0

colors0:        >PART

c0              SET $0777
c1              SET $0772
c2              SET $0004

                DC.W $0000

                DC.W c0         ;0
                DC.W c1         ; 1
                DC.W c0         ;01

                DC.W c2         ;  2
                DC.W c0         ;0 2
                DC.W c1         ; 12
                DC.W c0         ;012
                DC.W c0         ;   3

                DC.W c0         ;0  3
                DC.W c0         ; 1 3
                DC.W c0         ;01 3
                DC.W c0         ;  23
                DC.W c0         ;0 23
                DC.W c0         ; 123
                DC.W c0         ;0123
                ENDPART
;-------------------------------------------------------------------------------
                BSS

                >PART ' oszi bss'

_3d_result:     DS.B 8*vertex_size

x_table_eor:    DS.B 321*8
oszi_code_pointers:DS.L 321
y_tab_scaled:   DS.B (64+1)*256 ; -128...+127, step 2

oszi_hist:      DS.B OSZI_MAX

eor_buffer:     DS.B 200*(320/8) ; 8000 bytes

; ZZxx               (Y)
; Oszi Pos increment (U)
values:         DS.W 320*2

rot_list:       DS.L ROT_FRAMES

; .w x_start
; .w x_end
; .w x_start
; .w x_end
; 320*2*2 data
rot_pre_data:
o               SET 2+2+2+2
o               SET o+320*2*2
                DS.B ROT_FRAMES*o

                ENDPART

samples:        DS.W 330

sintab:         DS.W 2048*2

                DS.B 256
scr_ram:
                DS.B 2*32000

                DS.B 512
stack:          DS.B 4
;-------------------------------------------------------------------------------
                END
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


