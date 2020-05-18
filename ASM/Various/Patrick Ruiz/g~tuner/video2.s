*****************
* Kernel for 2D *
*****************
	OUTPUT	VIDEO2.PPP

; Relative PC routine
; Supervisor mode
; Parameters on the stack
; D0-D2/A0-A2 used

*ENTER/EXIT			0
;		  MemoryAddress.L	8 KB
;	   VideoFrameWidthinPixel
;	  VideoFrameHeightinPixel
;		 VideoPlaneNumber	1/2/4/8/16
;	      VideoFrameAddress.L
;			 ClipFlag	0 or <>0
;		ClipAreaXPosition
;		ClipAreaYPosition
;		    ClipAreaWidth
;		   ClipAreaHeight
;			DrawColor

*SET VIDEO FRAME ADDRESS	1
;	      VideoFrameAddress.L

*GET VIDEO FRAME ADDRESS	-1

*SET CLIP			2
;			 ClipFlag
;		ClipAreaXPosition
;		ClipAreaYPosition
;		    ClipAreaWidth
;		   ClipAreaHeight

*GET CLIP			-2

*SET DRAW COLOR 		3
;			DrawColor

*GET DRAW COLOR 		-3

*SET POINT			4
;		   PointXPosition
;		   PointYPosition

*SET POINTS			5
;   PointXYPositionArrayPointer.L	(--> X0/Y0/X1/Y1 ...)
;		      PointNumber

*SET COLORED POINTS		6
;  PointXYCPositionArrayPointer.L	(--> X0/Y0/C0/X1/Y1/C1 ...)
;		      PointNumber

; Memory						(8 KB)
VideoFrameWidthinPixel=0				;DS.W 1
VideoFrameHeightinPixel=VideoFrameWidthinPixel+2	;DS.W 1
VideoPlaneNumber=VideoFrameHeightinPixel+2		;DS.W 1
VideoFrameAddress=VideoPlaneNumber+2			;DS.L 1
ClipFlag=VideoFrameAddress+4				;DS.W 1
ClipAreaXPosition=ClipFlag+2				;DS.W 1
ClipAreaYPosition=ClipAreaXPosition+2			;DS.W 1
ClipAreaWidth=ClipAreaYPosition+2			;DS.W 1
ClipAreaHeight=ClipAreaWidth+2				;DS.W 1
DrawColor=ClipAreaHeight+2				;DS.W 1
 ;Initialized by ENTER
SetPointVector=DrawColor+2				;DS.L 1
  ;points on the point drawing routine
YWeightTable=SetPointVector+4				;DS.L 1248
  ;1664x1248 maxi !!!


VIDEO_2D:
	LEA	(SP,4),A0 ;A0 points parameters
	MOVE	(A0)+,D0
	LEA	FunctionOffsetTable(PC),A1
	MOVE	(A1,D0*2),D0
	LEA	ENTER_EXIT(PC),A1
	MOVEA.L M_Address(PC),A2 ;Don't use it !!!
	JMP	(A1,D0)
.x	RTS

SetVideoFrameAddress:
;A0 -> Parameters
;A1 -> VideoFrameAddress
	MOVE.L	(A0)+,(A1)+
	RTS

SetClip:
;A0 -> Parameters
;A1 -> ClipFlag
	MOVE	(A0)+,(A1)+
	BNE.S	.clip
.noclip CLR.L	(A1)+
	MOVE.L	VideoFrameWidthinPixel(A2),(A1)+
	ADDQ	#8,A0
	RTS
.clip	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
;Verify
	MOVE	VideoFrameWidthinPixel(A2),D1
	MOVE	VideoFrameHeightinPixel(A2),D2
.vxu	MOVE	(A1,-8),D0
	BGE.S	.vxo
	CLR	(A1,-8)
	ADD	D0,(A1,-4)
	BRA.S	.vwu
.vxo	CMP	D1,D0
	BLT.S	.vwu
	MOVE	D1,(A1,-8)
	CLR	(A1,-4)
	BRA.S	.vyu
.vwu	MOVE	(A1,-4),D0
	BGE.S	.vwo
	CLR	(A1,-4)
	BRA.S	.vyu
.vwo	ADD	(A1,-8),D0
	SUB	D1,D0
	BLE.S	.vyu
	SUB	D0,(A1,-4)
.vyu	MOVE	(A1,-6),D0
	BGE.S	.vyo
	CLR	(A1,-6)
	ADD	D0,(A1,-2)
	BRA.S	.vhu
.vyo	CMP	D2,D0
	BLT.S	.vhu
	MOVE	D2,(A1,-6)
	CLR	(A1,-2)
	BRA.S	.x
.vhu	MOVE	(A1,-2),D0
	BGE.S	.vho
	CLR	(A1,-2)
	BRA.S	.x
.vho	ADD	(A1,-6),D0
	SUB	D2,D0
	BLE.S	.x
	SUB	D0,(A1,-2)
.x	RTS

SetDrawColor:
;A0 -> Parameters
;A1 -> DrawColor
	MOVE	(A0)+,(A1)+
	RTS

ENTER:	LEA	M_Address(PC),A1
	MOVEA.L (A0)+,A2
	MOVE.L	A2,(A1)
	LEA	SetNothing(PC),A1
	MOVE.L	A1,SetPointVector(A2)
	LEA	VideoFrameWidthinPixel(A2),A1 ;and the rest ...
.width	MOVE	(A0)+,(A1)+
	BLE	.x
.height MOVE	(A0)+,(A1)+
	BLE	.x
	MOVE	(A0)+,D0
	MOVEQ	#5-1,D1 ;Test number
.pt	BTST	D1,D0
	BNE.S	.pn
	DBRA	D1,.pt
	BRA	.x
.pn	MOVEQ	#1,D0
	LSL	D1,D0
 ;If True Color 16 -> -16
	CMPI	#16,D0
	BNE.S	.vpn
	NEG	D0
.vpn	MOVE	D0,(A1)+
	BSR	SetVideoFrameAddress
	BSR	SetClip
	BSR	SetDrawColor
 ;DrawPointVector
	LEA	SetPointVector(A2),A0
	MOVE	VideoPlaneNumber(A2),D0
	LEA	SetPoint1Plane(PC),A1
	CMPI	#1,D0
	BEQ.S	.dpv
	LEA	SetPoint2Planes(PC),A1
	CMPI	#2,D0
	BEQ.S	.dpv
	LEA	SetPoint4Planes(PC),A1
	CMPI	#4,D0
	BEQ.S	.dpv
	LEA	SetPoint8Planes(PC),A1
	CMPI	#8,D0
	BEQ.S	.dpv
	LEA	SetPoint16Planes(PC),A1
.dpv	MOVE.L	A1,(A0)
 ;YWeightTable
	LEA	YWeightTable(A2),A0
	MOVE	VideoFrameHeightinPixel(A2),D0
	SUBQ	#1,D0
	MOVEQ	#0,D1
	MOVE	VideoFrameWidthinPixel(A2),D1
	MOVE	VideoPlaneNumber(A2),D2
	BPL.S	.16
	NEG	D2
	BRA.S	.wib
.16	ADDI	#16-1,D1
	ANDI	#-16,D1
.wib	MULU	D2,D1
	LSR.L	#3,D1
	MOVEQ	#0,D2
.wpl	MOVE.L	D2,(A0)+
	ADD.L	D1,D2
	DBRA	D0,.wpl
.ok	LEA	INITInd(PC),A0
	ST	(A0)
.x	RTS

EXIT:	LEA	INITInd(PC),A0
	SF	(A0)
	RTS

ENTER_EXIT:
	MOVE.B	INITInd(PC),D0
	BEQ	ENTER
	BRA	EXIT

SET_VIDEO_FRAME_ADDRESS:
	LEA	VideoFrameAddress(A2),A1
	BSR	SetVideoFrameAddress
	RTS

GET_VIDEO_FRAME_ADDRESS:
	MOVE.L	VideoFrameAddress(A2),D0
	RTS

SET_CLIP:
	LEA	ClipFlag(A2),A1
	BSR	SetClip
	RTS

GET_CLIP:
	LEA	ClipFlag(A2),A0
	MOVE.L	A0,D0
	RTS

SET_DRAW_COLOR:
	LEA	DrawColor(A2),A1
	BSR	SetDrawColor
	RTS

GET_DRAW_COLOR:
	MOVEQ	#0,D0
	MOVE	DrawColor(A2),D0
	RTS

;Basic routines
;D0 -> Color
;D1 -> Set X Mask (Plane mode)
;D2 -> Clear X Mask (Plane mode)
;A0 -> Address for drawing

SetNothing:
	RTS

SetPoint1Plane:
.b0	LSR	#1,D0
	BCS.S	.1
	AND	D2,(A0)
	RTS
.1	OR	D1,(A0)
	RTS

SetPoint2Planes:
.b0	LSR	#1,D0
	BCS.S	.1
	AND	D2,(A0)+
	BRA.S	.b1
.1	OR	D1,(A0)+
.b1	LSR	#1,D0
	BCS.S	.2
	AND	D2,(A0)+
	RTS
.2	OR	D1,(A0)+
	RTS

SetPoint4Planes:
.b0	LSR	#1,D0
	BCS.S	.1
	AND	D2,(A0)+
	BRA.S	.b1
.1	OR	D1,(A0)+
.b1	LSR	#1,D0
	BCS.S	.2
	AND	D2,(A0)+
	BRA.S	.b2
.2	OR	D1,(A0)+
.b2	LSR	#1,D0
	BCS.S	.3
	AND	D2,(A0)+
	BRA.S	.b3
.3	OR	D1,(A0)+
.b3	LSR	#1,D0
	BCS.S	.4
	AND	D2,(A0)+
	RTS
.4	OR	D1,(A0)+
	RTS

SetPoint8Planes:
.b0	LSR	#1,D0
	BCS.S	.1
	AND	D2,(A0)+
	BRA.S	.b1
.1	OR	D1,(A0)+
.b1	LSR	#1,D0
	BCS.S	.2
	AND	D2,(A0)+
	BRA.S	.b2
.2	OR	D1,(A0)+
.b2	LSR	#1,D0
	BCS.S	.3
	AND	D2,(A0)+
	BRA.S	.b3
.3	OR	D1,(A0)+
.b3	LSR	#1,D0
	BCS.S	.4
	AND	D2,(A0)+
	BRA.S	.b4
.4	OR	D1,(A0)+
.b4	LSR	#1,D0
	BCS.S	.5
	AND	D2,(A0)+
	BRA.S	.b5
.5	OR	D1,(A0)+
.b5	LSR	#1,D0
	BCS.S	.6
	AND	D2,(A0)+
	BRA.S	.b6
.6	OR	D1,(A0)+
.b6	LSR	#1,D0
	BCS.S	.7
	AND	D2,(A0)+
	BRA.S	.b7
.7	OR	D1,(A0)+
.b7	LSR	#1,D0
	BCS.S	.8
	AND	D2,(A0)+
	RTS
.8	OR	D1,(A0)+
	RTS

SetPoint16Planes:
	MOVE	D0,(A0)
	RTS

SET_POINT:
	MOVE	(A0)+,D0 ;X
	MOVE	(A0)+,D1 ;Y
.clip	MOVE	ClipAreaXPosition(A2),D2
	CMP	D2,D0
	BLT.S	.x
	ADD	ClipAreaWidth(A2),D2
	CMP	D2,D0
	BGE.S	.x
	MOVE	ClipAreaYPosition(A2),D2
	CMP	D2,D1
	BLT.S	.x
	ADD	ClipAreaHeight(A2),D2
	CMP	D2,D1
	BGE.S	.x
.A0 ;Address for drawing
	MOVEA.L VideoFrameAddress(A2),A0
	ADDA.L	YWeightTable(A2,D1*4),A0
	MOVE	VideoPlaneNumber(A2),D1
	BPL.S	.pal
.tc	LSL	#1,D0
	ADDA	D0,A0
	BRA.S	.D0
.pal	MOVEQ	#16-1,D2
	SUB	D0,D2
	ANDI	#16-1,D2
	LSR	#4,D0
.2x	LSL	#1,D0
	LSR	#1,D1
	BNE	.2x
	ADDA	D0,A0
.D1 ;X Masks
	MOVEQ	#0,D1
	BSET	D2,D1
	MOVE	D1,D2
.D2	NOT	D2
.D0 ;Color
	MOVE	DrawColor(A2),D0
	JMP	([SetPointVector,A2])
.x	RTS

SET_POINTS:
	MOVEM.L D7/A6,-(SP)
	MOVEA.L (A0)+,A6
	MOVE	(A0)+,D7
	SUBQ	#1,D7
.point	MOVEA.L A6,A0
	ADDQ	#4,A6
	BSR	SET_POINT
	DBRA	D7,.point
	MOVEM.L (SP)+,D7/A6
	RTS

SET_COLORED_POINTS:
	MOVEM.L D7/A6,-(SP)
	MOVEA.L (A0)+,A6
	MOVE	(A0)+,D7
	SUBQ	#1,D7
.point	MOVEA.L A6,A0
	ADDQ	#4,A6
	MOVE	(A6)+,DrawColor(A2)
	BSR	SET_POINT
	DBRA	D7,.point
	MOVEM.L (SP)+,D7/A6
	RTS

	D_
	DC.W	GET_DRAW_COLOR-ENTER_EXIT		-3
	DC.W	GET_CLIP-ENTER_EXIT			-2
	DC.W	GET_VIDEO_FRAME_ADDRESS-EXIT		-1
FunctionOffsetTable:
	DC.W	ENTER_EXIT-ENTER_EXIT			0
	DC.W	SET_VIDEO_FRAME_ADDRESS-ENTER_EXIT	1
	DC.W	SET_CLIP-ENTER_EXIT			2
	DC.W	SET_DRAW_COLOR-ENTER_EXIT		3
	DC.W	SET_POINT-ENTER_EXIT			4
	DC.W	SET_POINTS-ENTER_EXIT			5
	DC.W	SET_COLORED_POINTS-ENTER_EXIT		6

INITInd DC.B 0
	EVEN
M_Address	DS.L	1
