    .IMPORT pre_cosin            ; array of 2*ITRIGO_ARRAY_SIZE longs
    .IMPORT pre_loffset          ; long*
    .EXPORT bh_xd, bh_yd, bh_rd2 ; long
    .EXPORT bh_xs, bh_ys, bh_ref ; long
    .EXPORT bh_xc, bh_yc         ; long
    .EXPORT bh_out_w, bh_out_h   ; short
    .EXPORT bh_in_w, bh_in_h     ; short
    .EXPORT bh_out_x, bh_out_y   ; short
	.EXPORT BHL32_68030,BHL16_68030,BHLInd_68030
	.EXPORT BHL32_F68030,BHL16_F68030,BHLInd_F68030
    .EXPORT lcosin_fpu

ITRIGO_ARRAY_SIZE EQU (1 << 14)
ITRIGO_ANGLE_MAX  EQU (ITRIGO_ARRAY_SIZE-1)
QUARTER           EQU (ITRIGO_ARRAY_SIZE/4)

; The black hole transformation consists of:
; Rotate the destination pixel around the black hole center
; The closest we are to the black hole, the bigger the rotation angle is
; We have 2 or 3 parts of computation angle for black hole transformation:
; 1: Just before dividing the maximum possible angle (depending on LDV paramter Rotation angle) by:
; CPU: the square of distance to black hole center
; FPU: the distance to black hole center; here we need 68881 instruction FSQRT
; So there are 3 parts in macro calculations:
; 1.  Before dividing by distance or its square
; 1a. (FPU only) Compute distance
; 3.  Divide by either distance or its square and state if the resulting pixel is in source image
; Dividing by distance instead of its square gives better visual results
MACRO BH_COMP_1
    MOVE.L    A6,D0                ; Remember A6=bh_xd
    ADD.L     D0,D0
    ADDQ.L    #1,D0
    MOVE.L    A5,D1                ; Remember A5=bh_rd2
    ADD.L     D0,D1                ; bh_rd2(D1)=1+2*bh_xd(D0)
    MOVE.L    bh_ref(PC),D2
    MOVE.L    D1,A5                ; Save bh_rd2, free D1
    ADDQ.L    #1,D1                ; We need bh_rd2+1 for divide
ENDM

MACRO BH_COMP_2 bail_out_addr
    DIVU.L    D1,D2                ; alpha(D2)=bh_ref/(1+bh_rd2)
    ANDI.L    #ITRIGO_ANGLE_MAX,D2 ; alpha &= ITRIGO_ANGLE_MAX

    LSL.L     #3,D2                ; D2=offset for pre_cosin array
    MOVE.L    A6,D0                ; D0=bh_xd   
    MOVE.L    bh_yd(PC),D1         ; D1=bh_yd   
    MOVE.L    4(A2,D2.L),D3        ; A2->pre_cosin, D3.L=SIN(alpha)
    MOVE.L    (A2,D2.L),D2         ; A2->pre_cosin, D2.L=COS(alpha)

    MOVEQ.L   #16,D6               ; Prepare shifts/assume not in range

    MOVE.L    D0,D4
    MULS.L    D2,D4                ; D4=bh_xd * pre_cos[alpha]
    MOVE.L    D1,D5
    MULS.L    D3,D5                ; D5=bh_yd * pre_sin[alpha]
    SUB.L     D5,D4                ; D4=bh_xd * pre_cos[alpha] - bh_yd * pre_sin[alpha]
    ASR.L     D6,D4
    ADD.L     bh_xc(PC),D4         ; D6=16, assume pixel not in range
    BLT.S     bail_out_addr        ; xs < 0: not in range
    CMP.W     bh_in_w(PC),D4
    BGE.S     bail_out_addr        ; xs >= bh_in_w: not in range
    MOVE.L    D4,A3                ; A3=bh_xs= (D4 >> 16)

    MOVE.L    D0,D4
    MULS.L    D3,D4                ; D4=bh_xd * pre_sin[alpha]
    MOVE.L    D1,D5
    MULS.L    D2,D5                ; D5=bh_yd * pre_cos[alpha]
    ADD.L     D5,D4                ; D4=bh_xd * pre_sin[alpha] + bh_yd * pre_cos[alpha]
    ASR.L     D6,D4
    ADD.L     bh_yc(PC),D4         ; D4.L=bh_ys
    BLT.S     bail_out_addr        ; ys < 0: not in range
    CMP.W     bh_in_h(PC),D4
    BGE.S     bail_out_addr        ; ys >= bh_in_h: not in range
    MOVEQ.L   #0,D6                ; pixel in range
ENDM

; Macro for CPU 68030
MACRO BH_COMPUTE_CPU bail_out_addr
    BH_COMP_1
    BH_COMP_2 bail_out_addr
ENDM

; Macro for using FPU
; What we do with FPU is to compute the square root of D1 which
; Is then the distance to the back hole center instead of its square
MACRO BH_COMPUTE_FPU bail_out_addr
    BH_COMP_1
    FMOVE.L     D1,FP0
    FSQRT       FP0
    FMOVE.L     FP0,D1
    BH_COMP_2 bail_out_addr
ENDM

; Init parameters valid for the entire call
MACRO INIT_BHL
  MOVE.L    pre_cosin,A2
	MOVE.L    pre_loffset,A4          ; A4-->preoffset
	MOVE.L    bh_rd2(PC),A5           ; A5=bh_rd2
	MOVE.L    bh_xd(PC),A6            ; A6=bh_xd
	MOVE.W    bh_out_w(PC),D7
	SUBQ.W    #1,D7                   ; For DBF
ENDM

MACRO INIT_BHL_SYM
  MOVE.L    pre_cosin,A2
	MOVE.L    pre_loffset,A4          ; A4-->preoffset
	MOVE.L    bh_rd2(PC),A5           ; A5=bh_rd2
	MOVE.L    bh_xd(PC),A6            ; A6=bh_xd
	MOVE.W    bh_out_w(PC),D7
  LSR.W     #1,D7                   ; loop to bh_out_w/2 counts
  ADD.W     A6,D7                   ; starting from bh_xd
  MOVE.W    D7,last_xd
ENDM

; Get pixel TC32 -->dest (Dx)
; A4-->pre_loffset
MACRO GET_TCPIXEL32 p,x,y,dest
  MOVE.L    (A4,y.L*4),dest
  ADD.L     x,dest
  MOVE.L    (p,dest.L*4),dest
ENDM

; Set pixel TC32 val(Dx) -->dest
; A4-->pre_loffset
; scratch_Dx scratch variable
MACRO SET_TCPIXEL32 p,x,y,val,scratch_Dx
  MOVE.L    (A4,y.L*4),scratch_Dx
  ADD.L     x,scratch_Dx
  MOVE.L    val,(p,scratch_Dx.L*4)
ENDM

; Get pixel TC16 -->dest (Dx)
; A4-->pre_loffset
MACRO GET_TCPIXEL16 p,x,y,dest
  MOVE.L    (A4,y.L*4),dest
  ADD.L     x,dest
  MOVE.W    (p,dest.L*2),dest
ENDM

; Set pixel TC16 val(Dx) -->dest
; A4-->pre_loffset
; scratch_Dx scratch variable
MACRO SET_TCPIXEL16 p,x,y,val,scratch_Dx
  MOVE.L    (A4,y.L*4),scratch_Dx
  ADD.L     x,scratch_Dx
  MOVE.W    val,(p,scratch_Dx.L*2)
ENDM

; Rotate 90
; x,y,scratch_Dx : registers, y has to be Dx
; #define R90(x,y)  { long _x=x; x=-y; y=_x; }
MACRO R90 x,y,scratch_Dx
  MOVE.L    x,scratch_Dx
  NEG.L     y
  MOVE.L    y,x
  MOVE.L    scratch_Dx,y
ENDM

MACRO PIXINIMG x,y,w,h,bailout
  TST.W     x
  BLT.S     bailout
  TST.W     y
  BLT.S     bailout
  CMP.W     w,x
  BGE.S     bailout
  CMP.W     h,y
  BGE.S     bailout
ENDM

; On sample file 00_1480ms.jpg, Aranym 32bit:
; BHL32_68000 takes about 1450ms
; BHL32_68030 takes about 740ms

; 68030 routine for True Color 32bit
; BHL32_68030(short use_sym, void* in, void* out)
;                   D0,            A0        A1
BHL32_68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context

  TST.W      D0
  BNE        BHL32_68030_sym

  MOVEQ.L   #0,D7
  MOVE.W    bh_out_x(PC),D7
  LSL.L     #2,D7
  ADD.L     D7,A1                   ; A1-->&out[bh_out_x]
  INIT_BHL
bhl32_l030:
  BH_COMPUTE_CPU bhl32_tpir_030     ; -->D6=0:pixel in range
bhl32_tpir_030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl32_setpix_030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
	MOVE.L    (A0,D0.L*4),D0          ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhl32_setpix_030:
  MOVE.L    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
	DBF       D7,bhl32_l030

  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

BHL32_68030_sym:
  INIT_BHL_SYM
bhl32_l030_sym:
  BH_COMPUTE_CPU bhl32_tpir_030_sym ; -->D6=0:pixel in range
bhl32_tpir_030_sym:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl32_setpix_030_sym
	GET_TCPIXEL32  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
bhl32_setpix_030_sym:
  MOVE.L    A6,-(SP)                ; Save bh_xd
  MOVE.L    bh_xc(PC),D2            ; D2=bh_xc
  MOVE.L    bh_yc(PC),D3            ; D3=bh_yc
  ADD.L     D2,A6                   ; A6=bh_xd+bh_xc
  MOVE.L    bh_yd(PC),D7
  ADD.L     D3,D7                   ; D7=bh_yd+bh_yc
  SET_TCPIXEL32 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))

  MOVEQ.L   #2,D1                   ; 3 loops, -1 for DBF
deduc32_030:
  SUB.L     D2,A3                   ; We need now bh_xs(A3) and bh_ys(D4) relative to
  SUB.L     D3,D4                   ; Black Hole center to use R90
  SUB.L     D2,A6                   ; We need now bh_xd(A6) and bh_yd(D7) relative to
  SUB.L     D3,D7                   ; Black Hole center to use R90

  R90       A6,D7,D0                ; Rotate (xd,yd) by PI/4
  R90       A3,D4,D0                ; Rotate (xs,ys) by PI/4

  ADD.L     D2,A3                   ; Now we need coords in image raster
  ADD.L     D3,D4
  ADD.L     D2,A6
  ADD.L     D3,D7

  PIXINIMG  A6,D7,bh_in_w(PC),bh_in_h(PC),dnotinimg32_030 ; Check if pixel in dest is within bounds
  MOVEQ.L   #-1,D0                  ; Assume out of range
  PIXINIMG  A3,D4,bh_in_w(PC),bh_in_h(PC),plotdest32_030 ; Check if pixel in src is within bounds
	GET_TCPIXEL32  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
plotdest32_030:
  SET_TCPIXEL32 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))
dnotinimg32_030:
  DBF D1,deduc32_030

  MOVE.L    (SP)+,A6                ; Restore bh_xd
  ADD.L     #1,A6                   ; bh_xd++
  CMP.W     last_xd(PC),A6
  BLE       bhl32_l030_sym

  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

; 68030 routine for True Color 16bit
; BHL16_68030(short use_sym, void* in, void* out)
;                   D0,            A0        A1
BHL16_68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context

  TST.W      D0
  BNE        BHL16_68030_sym

  MOVEQ.L   #0,D7
  MOVE.W    bh_out_x(PC),D7
  ADD.L     D7,D7
  ADD.L     D7,A1                   ; A1-->&out[bh_out_x]
  INIT_BHL
bhl16_l030:
  BH_COMPUTE_CPU bhl16_tpir_030     ; -->D6=0:pixel in range
bhl16_tpir_030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl16_setpix_030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
	MOVE.W    (A0,D0.L*2),D0          ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhl16_setpix_030:
  MOVE.W    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
	DBF       D7,bhl16_l030

  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

BHL16_68030_sym:
  INIT_BHL_SYM
bhl16_l030_sym:
  BH_COMPUTE_CPU bhl16_tpir_030_sym ; -->D6=0:pixel in range
bhl16_tpir_030_sym:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl16_setpix_030_sym
	GET_TCPIXEL16  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
bhl16_setpix_030_sym:
  MOVE.L    A6,-(SP)                ; Save bh_xd
  MOVE.L    bh_xc(PC),D2            ; D2=bh_xc
  MOVE.L    bh_yc(PC),D3            ; D3=bh_yc
  ADD.L     D2,A6                   ; A6=bh_xd+bh_xc
  MOVE.L    bh_yd(PC),D7
  ADD.L     D3,D7                   ; D7=bh_yd+bh_yc
  SET_TCPIXEL16 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))

  MOVEQ.L   #2,D1                   ; 3 loops, -1 for DBF
deduc16_030:
  SUB.L     D2,A3                   ; We need now bh_xs(A3) and bh_ys(D4) relative to
  SUB.L     D3,D4                   ; Black Hole center to use R90
  SUB.L     D2,A6                   ; We need now bh_xd(A6) and bh_yd(D7) relative to
  SUB.L     D3,D7                   ; Black Hole center to use R90

  R90       A6,D7,D0                ; Rotate (xd,yd) by PI/4
  R90       A3,D4,D0                ; Rotate (xs,ys) by PI/4

  ADD.L     D2,A3                   ; Now we need coords in image raster
  ADD.L     D3,D4
  ADD.L     D2,A6
  ADD.L     D3,D7

  PIXINIMG  A6,D7,bh_in_w(PC),bh_in_h(PC),dnotinimg16_030 ; Check if pixel in dest is within bounds
  MOVEQ.L   #-1,D0                  ; Assume out of range
  PIXINIMG  A3,D4,bh_in_w(PC),bh_in_h(PC),plotdest16_030 ; Check if pixel in src is within bounds
	GET_TCPIXEL16  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
plotdest16_030:
  SET_TCPIXEL16 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))
dnotinimg16_030:
  DBF D1,deduc16_030

  MOVE.L    (SP)+,A6                ; Restore bh_xd
  ADD.L     #1,A6                   ; bh_xd++
  CMP.W     last_xd(PC),A6
  BLE       bhl16_l030_sym

  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

; 68030 routine for bitplances images, converted to indexes
; BHLInd_68030(short use_sym, void* in, void* out)
;                    D0,            A0        A1
BHLInd_68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context

  INIT_BHL
bhlind_l030:
  BH_COMPUTE_CPU bhlind_tpir_030    ; -->D6=0:pixel in range
bhlind_tpir_030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhlind_setpix_030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
	MOVE.B    (A0,D0.L),D0            ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhlind_setpix_030:
  MOVE.B    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
	DBF       D7,bhlind_l030

  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

.EVEN
bh_xd:
    DC.L      0 
bh_yd:
    DC.L      0 
bh_rd2:
    DC.L      0 
bh_xs:
    DC.L      0 
bh_ys:
    DC.L      0 
bh_ref:
    DC.L      0 
bh_xc:
    DC.L      0 
bh_yc:
    DC.L      0 
bh_out_w:
    DC.W      0 
bh_out_h:
    DC.W      0 
bh_in_w:
    DC.W      0 
bh_in_h:
    DC.W      0 
bh_out_x:
    DC.W      0 
bh_out_y:
    DC.W      0
last_xd:
    DC.W      0

; 68030/FPU routine for True Color 32bit
; BHL32_F68030(short use_sym, void* in, void* out)
;                   D0,             A0        A1
;BHL32_F68030:
;    MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context
;    FMOVE.X   FP0,-(SP)
;
;    INIT_BHL
;bhl32_lf030:
;    BH_COMPUTE_FPU bhl32_tpir_f030    ; -->D6=0:pixel in range
;bhl32_tpir_f030:
;    MOVEQ.L   #-1,D0                  ; Assume out of range
;    TST.W     D6
;	BNE.S     bhl32_setpix_f030
;	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
;	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
;	MOVE.L    (A0,D0.L*4),D0          ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
;bhl32_setpix_f030:
;    MOVE.L    D0,(A1)+
;    ADD.L     #1,A6                   ; bh_xd++
;    DBF       D7,bhl32_lf030
;
;    FMOVE.X   (SP)+,FP0
;    MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
;    RTS

BHL32_F68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context
  FMOVE.X   FP0,-(SP)

  TST.W      D0
  BNE        BHL32_F68030_sym

  MOVEQ.L   #0,D7
  MOVE.W    bh_out_x(PC),D7
  LSL.L     #2,D7
  ADD.L     D7,A1                   ; A1-->&out[bh_out_x]
  INIT_BHL
bhl32_lf030:
  BH_COMPUTE_FPU bhl32_tpir_f030     ; -->D6=0:pixel in range
bhl32_tpir_f030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl32_setpix_f030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
	MOVE.L    (A0,D0.L*4),D0          ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhl32_setpix_f030:
  MOVE.L    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
	DBF       D7,bhl32_lf030

  FMOVE.X   (SP)+,FP0
  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

BHL32_F68030_sym:
  INIT_BHL_SYM
bhl32_lf030_sym:
  BH_COMPUTE_FPU bhl32_tpir_f030_sym ; -->D6=0:pixel in range
bhl32_tpir_f030_sym:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl32_setpix_f030_sym
	GET_TCPIXEL32  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
bhl32_setpix_f030_sym:
  MOVE.L    A6,-(SP)                ; Save bh_xd
  MOVE.L    bh_xc(PC),D2            ; D2=bh_xc
  MOVE.L    bh_yc(PC),D3            ; D3=bh_yc
  ADD.L     D2,A6                   ; A6=bh_xd+bh_xc
  MOVE.L    bh_yd(PC),D7
  ADD.L     D3,D7                   ; D7=bh_yd+bh_yc
  SET_TCPIXEL32 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))

  MOVEQ.L   #2,D1                   ; 3 loops, -1 for DBF
deduc32_f030:
  SUB.L     D2,A3                   ; We need now bh_xs(A3) and bh_ys(D4) relative to
  SUB.L     D3,D4                   ; Black Hole center to use R90
  SUB.L     D2,A6                   ; We need now bh_xd(A6) and bh_yd(D7) relative to
  SUB.L     D3,D7                   ; Black Hole center to use R90

  R90       A6,D7,D0                ; Rotate (xd,yd) by PI/4
  R90       A3,D4,D0                ; Rotate (xs,ys) by PI/4

  ADD.L     D2,A3                   ; Now we need coords in image raster
  ADD.L     D3,D4
  ADD.L     D2,A6
  ADD.L     D3,D7

  PIXINIMG  A6,D7,bh_in_w(PC),bh_in_h(PC),dnotinimg32_f030 ; Check if pixel in dest is within bounds
  MOVEQ.L   #-1,D0                  ; Assume out of range
  PIXINIMG  A3,D4,bh_in_w(PC),bh_in_h(PC),plotdest32_f030 ; Check if pixel in src is within bounds
	GET_TCPIXEL32  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
plotdest32_f030:
  SET_TCPIXEL32 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))
dnotinimg32_f030:
  DBF D1,deduc32_f030

  MOVE.L    (SP)+,A6                ; Restore bh_xd
  ADD.L     #1,A6                   ; bh_xd++
  CMP.W     last_xd(PC),A6
  BLE       bhl32_lf030_sym

  FMOVE.X   (SP)+,FP0
  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS
    
BHL16_F68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context
  FMOVE.X   FP0,-(SP)

  TST.W      D0
  BNE        BHL16_f68030_sym

  MOVEQ.L   #0,D7
  MOVE.W    bh_out_x(PC),D7
  ADD.L     D7,D7
  ADD.L     D7,A1                   ; A1-->&out[bh_out_x]
  INIT_BHL
bhl16_lf030:
  BH_COMPUTE_FPU bhl16_tpir_f030    ; -->D6=0:pixel in range
bhl16_tpir_f030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl16_setpix_f030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs(A3)
	MOVE.W    (A0,D0.L*2),D0          ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhl16_setpix_f030:
  MOVE.W    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
	DBF       D7,bhl16_lf030

  FMOVE.X   (SP)+,FP0
  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

BHL16_f68030_sym:
  INIT_BHL_SYM
bhl16_lf030_sym:
  BH_COMPUTE_FPU bhl16_tpir_f030_sym ; -->D6=0:pixel in range
bhl16_tpir_f030_sym:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhl16_setpix_f030_sym
	GET_TCPIXEL16  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
bhl16_setpix_f030_sym:
  MOVE.L    A6,-(SP)                ; Save bh_xd
  MOVE.L    bh_xc(PC),D2            ; D2=bh_xc
  MOVE.L    bh_yc(PC),D3            ; D3=bh_yc
  ADD.L     D2,A6                   ; A6=bh_xd+bh_xc
  MOVE.L    bh_yd(PC),D7
  ADD.L     D3,D7                   ; D7=bh_yd+bh_yc
  SET_TCPIXEL16 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))

  MOVEQ.L   #2,D1                   ; 3 loops, -1 for DBF
deduc16_f030:
  SUB.L     D2,A3                   ; We need now bh_xs(A3) and bh_ys(D4) relative to
  SUB.L     D3,D4                   ; Black Hole center to use R90
  SUB.L     D2,A6                   ; We need now bh_xd(A6) and bh_yd(D7) relative to
  SUB.L     D3,D7                   ; Black Hole center to use R90

  R90       A6,D7,D0                ; Rotate (xd,yd) by PI/4
  R90       A3,D4,D0                ; Rotate (xs,ys) by PI/4

  ADD.L     D2,A3                   ; Now we need coords in image raster
  ADD.L     D3,D4
  ADD.L     D2,A6
  ADD.L     D3,D7

  PIXINIMG  A6,D7,bh_in_w(PC),bh_in_h(PC),dnotinimg16_f030 ; Check if pixel in dest is within bounds
  MOVEQ.L   #-1,D0                  ; Assume out of range
  PIXINIMG  A3,D4,bh_in_w(PC),bh_in_h(PC),plotdest16_f030 ; Check if pixel in src is within bounds
	GET_TCPIXEL16  A0,A3,D4,D0        ; A0-->in_ptr, A3=bh_xs+bh_xc, D4=bh_ys+bh_yc
                                    ; D0=GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc)
plotdest16_f030:
  SET_TCPIXEL16 A1,A6,D7,D0,D5      ; SET_TCPIXEL(out_ptr, bh_xd+bh_xc, bh_yd+bh_yc, GET_TCPIXEL(in_ptr, bh_xs+bh_xc, bh_ys+bh_yc))
dnotinimg16_f030:
   DBF D1,deduc16_f030

  MOVE.L    (SP)+,A6                ; Restore bh_xd
  ADD.L     #1,A6                   ; bh_xd++
  CMP.W     last_xd(PC),A6
  BLE       bhl16_lf030_sym

  FMOVE.X   (SP)+,FP0
  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

; 68030/FPU routine for bitplances images, converted to indexes
; BHLInd_F68030(short use_sym, void* in, void* out)
;                   D0,              A0        A1
BHLInd_F68030:
  MOVEM.L   D0-D7/A2-A6,-(SP)       ; Save context
  FMOVE.X   FP0,-(SP)

  INIT_BHL
bhlInd_lf030:
  BH_COMPUTE_FPU bhlInd_tpir_f030   ; -->D6=0:pixel in range
bhlInd_tpir_f030:
  MOVEQ.L   #-1,D0                  ; Assume out of range
  TST.W     D6
	BNE.S     bhlInd_setpix_f030
	MOVE.L    (A4,D4.L*4),D0          ; D4=bh_ys, D0=pre_loffset[bh_ys]
	ADD.L     A3,D0                   ; D0=pre_loffset[bh_ys] + bh_xs
	MOVE.B    (A0,D0.L),D0            ; D0=in_ptr[pre_loffset[bh_ys] + bh_xs]
bhlInd_setpix_f030:
  MOVE.B    D0,(A1)+
  ADD.L     #1,A6                   ; bh_xd++
  DBF       D7,bhlInd_lf030

  FMOVE.X   (SP)+,FP0
  MOVEM.L   (SP)+,D0-D7/A2-A6       ; Restore context
  RTS

  
; Pre-calculation of cosinus/sinus table using FPU
; void lcosin_fpu(long i, long* pcs)
;                      D0       A0
;  double angle = i*ANGLE_ADD ;
;  pcs[0] = 65536.0 * cos( angle ) ;
;  pcs[1] = 65536.0 * sin( angle ) ;
lcosin_fpu:
  FMOVEM.X   FP0-FP2,-(SP)

  FMOVE      D0,FP0
; 3.8349519697141030742952189737299e-4=M_PI/2.0/(double)QUARTER
; For some reason, I did not manage to use EQU with floating point constants
  FMUL.X     #3.8349519697141030742952189737299e-4,FP0
  FSINCOS.X  FP0,FP1:FP2
  FMUL.X     #65536.0,FP1
  FMUL.X     #65536.0,FP2
  FMOVE.L    FP1,(A0)+
  FMOVE.L    FP2,(A0)

  FMOVEM.X   (SP)+,FP0-FP2
  RTS
