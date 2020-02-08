
' [NVDI.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DIM SHARED NVDIInstalled=-1

FUNCTION cookie_NVDI
STATIC dummy,NVDI&

dummy=GETCOOKIE ("NVDI",NVDI&)
IF dummy<>0 THEN
	cookie_NVDI=-1
ELSE
	cookie_NVDI=0
END IF
END FUNCTION


' Drivers & Management

SUB v_opnwk (work_in(),handle,work_out())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,1
	POKEW CONTRL+2,0
	POKEW CONTRL+6,11
	POKEW CONTRL+12,0

	FOR dummy=0 TO 10
		POKEW INTIN+(dummy*2),work_in(dummy)
	NEXT dummy
	VDISYS(0)

	handle=PEEKW(CONTRL+12)

	FOR dummy=0 TO 56
		work_out(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
	FOR dummy=0 TO 11
		work_out(dummy+45)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB v_clswk (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,2
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_opnvwk (work_in(),handle,work_out())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,100
	POKEW CONTRL+2,0
	POKEW CONTRL+6,11
	POKEW CONTRL+12,handle

	FOR dummy=0 TO 10
		POKEW INTIN+(dummy*2),work_in(dummy)
	NEXT dummy
	VDISYS(0)

	handle=PEEKW(CONTRL+12)
	FOR dummy=0 TO 56
		work_out(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
	FOR dummy=0 TO 11
		work_out(dummy+45)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB v_clsvwk (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,101
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_clrwk (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,3
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_clear_disp_list (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,22
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_updwk (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,4
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_opnbm (work_in(),bitmap&(),handle,work_out())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,100
	POKEW CONTRL+2,0
	POKEW CONTRL+6,20
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,VARPTR(bitmap&(0))

	FOR dummy=0 TO 19
		POKEW INTIN+(dummy*2),work_in(dummy)
	NEXT dummy
	VDISYS(0)

	handle=PEEKW(CONTRL+12)

	FOR dummy=0 TO 56
		work_out(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
	FOR dummy=0 TO 11
		work_out(dummy+45)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB v_clsbm (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,101
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB vq_extnd (BYVAL handle,BYVAL flag,work_out())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,102
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,flag
	VDISYS(0)

	FOR dummy=0 TO 48
		work_out(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
	FOR dummy=0 TO 11
		work_out(dummy+45)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB vq_scrninfo (BYVAL handle,work_out())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,102
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	POKEW INTIN,2
	VDISYS(0)

	FOR dummy=0 TO 271
		work_out(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB vq_devinfo (BYVAL handle,BYVAL device,dev_open,file_name$,device_name$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,248
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,device
	VDISYS(0)

	dev_open=PEEKW(PTSOUT)
	device_name$=""
	FOR dummy=1 TO (PEEKW(CONTRL+4)*2)-2
		device_name$=device_name$+MKI$(PEEKW(PTSOUT+dummy))
		INCR dummy
	NEXT dummy

	file_name$=""
	FOR dummy=0 TO ((PEEKW(CONTRL+8))*2)-1
		file_name$=file_name$+CHR$(PEEKW(INTOUT+dummy))
		INCR dummy
	NEXT dummy
END IF
END SUB


FUNCTION vq_ext_devinfo (BYVAL handle,BYVAL device,dev_exists,file_path$,file_name$,device_name$)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vq_ext_devinfo=-1 : EXIT FUNCTION
ELSE
	file_path$=SPACE$(100)
	file_name$=SPACE$(100)
	device_name$=SPACE$(100)

	POKEW CONTRL,248
	POKEW CONTRL+2,0
	POKEW CONTRL+6,7
	POKEW CONTRL+10,4242
	POKEW CONTRL+12,handle
	POKEW INTIN,device
	POKEL INTIN+2,SADD(file_path$)
	POKEL INTIN+6,SADD(file_name$)
	POKEL INTIN+10,SADD(device_name$)
	VDISYS(0)

	dev_exists=PEEKW(INTOUT)
	vq_ext_devinfo=PEEKW(INTOUT+2)
	file_path$=RTRIM$(file_path$)
	file_name$=RTRIM$(file_name$)
	device_name$=RTRIM$(device_name$)
END IF
END FUNCTION


' Colour Settings

SUB vs_color (BYVAL handle,BYVAL index,rgb())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,14
	POKEW CONTRL+2,0
	POKEW CONTRL+6,4
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	POKEW INTIN+2,rgb(0)
	POKEW INTIN+4,rgb(1)
	POKEW INTIN+6,rgb(2)
	VDISYS(0)
END IF
END SUB


FUNCTION vq_color (BYVAL handle,BYVAL color_index,BYVAL set_flag,rgb())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vq_color=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,26
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	POKEW INTIN+2,set_flag
	VDISYS(0)

	vq_color=PEEKW(INTOUT)
	rgb(0)=PEEKW(INTOUT+2)
	rgb(1)=PEEKW(INTOUT+4)
	rgb(2)=PEEKW(INTOUT+6)
END IF
END FUNCTION


FUNCTION vs_calibrate (BYVAL handle,BYVAL flag,table())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vs_calibrate=-1 : EXIT FUNCTION
ELSE
	REDIM PRESERVE table(1001)
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,76
	POKEW CONTRL+12,handle
	POKEW INTIN,VARPTR(table(0))
	POKEW INTIN+4,flag
	VDISYS(0)

	vs_calibrate=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vq_calibrate (BYVAL handle,flag)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vq_calibrate=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,77
	POKEW CONTRL+12,handle
	VDISYS(0)

	vq_calibrate=PEEKW(CONTRL+8)
	flag=PEEKW(INTOUT)
END IF
END FUNCTION


' Writing Modes & Clipping

FUNCTION vswr_mode (BYVAL handle,BYVAL mode)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vswr_mode=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,32
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,mode
	VDISYS(0)

	vswr_mode=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vs_clip (BYVAL handle,BYVAL clip_flag,xyarr())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,129
	POKEW CONTRL+2,2
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,clip_flag
	POKEW PTSIN,xyarr(0)
	POKEW PTSIN+2,xyarr(1)
	POKEW PTSIN+4,xyarr(2)
	POKEW PTSIN+6,xyarr(3)
	VDISYS(0)
END IF
END SUB


' Lines & unfilled Graphic Primitives

SUB v_pline (BYVAL handle,BYVAL count,xyarr())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,6
	POKEW CONTRL+2,count
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (count-1)
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB v_bez (BYVAL handle,BYVAL count,xyarr(),bezarr(),extent(),totpts,totmoves)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,6
	POKEW CONTRL+2,count
	POKEW CONTRL+6,(count+1)/2
	POKEW CONTRL+10,13
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (count-1)
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	FOR dummy=0 TO ((count+1)/2)-1
		POKEW INTIN+(dummy*2),bezarr(dummy)
	NEXT dummy
	VDISYS(0)

	totpts=PEEKW(INTOUT)
	totmoves=PEEKW(INTOUT+2)

	extent(0)=PEEKW(PTSOUT)
	extent(1)=PEEKW(PTSOUT+2)
	extent(2)=PEEKW(PTSOUT+4)
	extent(3)=PEEKW(PTSOUT+6)
END IF
END SUB


SUB v_arc (BYVAL handle,BYVAL x,BYVAL y,BYVAL radius,BYVAL begang,BYVAL endang)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,4
	POKEW CONTRL+6,2
	POKEW CONTRL+10,2
	POKEW CONTRL+12,handle
	POKEW INTIN,begang
	POKEW INTIN+2,endang
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+12,radius
	VDISYS(0)
END IF
END SUB


SUB v_ellarc (BYVAL handle,BYVAL x,BYVAL y,BYVAL x_radius,BYVAL y_radius,BYVAL begang,BYVAL endang)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,2
	POKEW CONTRL+10,6
	POKEW CONTRL+12,handle
	POKEW INTIN,begang
	POKEW INTIN+2,endang
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+4,x_radius
	POKEW PTSIN+6,y_radius
	VDISYS(0)
END IF
END SUB


SUB v_rbox (BYVAL handle,rect())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,8
	POKEW CONTRL+12,handle
	POKEW PTSIN,rect(0)
	POKEW PTSIN+2,rect(1)
	POKEW PTSIN+4,rect(2)
	POKEW PTSIN+6,rect(3)
	VDISYS(0)
END IF
END SUB


FUNCTION v_bez_on (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	v_bez_on=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+10,13
	POKEW CONTRL+12,handle
	VDISYS(0)

	v_bez_on=PEEKW(INTOUT)
END IF
END FUNCTION


SUB v_bez_off (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,13
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_bez_qual (BYVAL handle,BYVAL qual,set_qual)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,99
	POKEW CONTRL+12,handle
	POKEW INTIN,32
	POKEW INTIN+2,1
	POKEW INTIN+4,qual
	VDISYS(0)

	set_qual=PEEKW(INTOUT)
END IF
END SUB


FUNCTION vsl_type (BYVAL handle,BYVAL type)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsl_type=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,99
	POKEW CONTRL+12,handle
	POKEW INTIN,32
	POKEW INTIN+2,1
	POKEW INTIN+4,type
	VDISYS(0)

	vsl_type=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vsl_width (BYVAL handle,BYVAL l_width)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsl_width=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,16
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,l_width
	VDISYS(0)

	vsl_width=PEEKW(PTSOUT)
END IF
END FUNCTION


FUNCTION vsl_color (BYVAL handle,BYVAL color_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsl_color=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,17
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	VDISYS(0)

	vsl_color=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vql_attributes (BYVAL handle,attrib())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,35
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	attrib(0)=PEEKW(INTOUT)    ' Line type
	attrib(1)=PEEKW(INTOUT+2)  ' Line colour
	attrib(2)=PEEKW(INTOUT+4)  ' Writing mode
	attrib(3)=PEEKW(PTSOUT)    ' Line width
	attrib(4)=PEEKW(INTOUT+6)  ' End style of first point
	attrib(5)=PEEKW(INTOUT+8)  ' End style of last point
END IF
END SUB


SUB vsl_ends (BYVAL handle,BYVAL beg_style,BYVAL end_style)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,108
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,beg_style
	POKEW INTIN+2,end_style
	VDISYS(0)
END IF
END SUB


SUB vsl_udsty (BYVAL handle,BYVAL pattern)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,113
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,pattern
	VDISYS(0)
END IF
END SUB


SUB v_fillarea (BYVAL handle,BYVAL count,xyarr())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,9
	POKEW CONTRL+2,count
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (2*count)-1
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB v_bez_fill (BYVAL handle,BYVAL count,xyarr(),bezarr(),extent(),totpts,totmoves)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,9
	POKEW CONTRL+2,count
	POKEW CONTRL+6,(count+1)/2
	POKEW CONTRL+10,13
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (2*count)-1
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	FOR dummy=0 TO (count+1/2)-1
		POKEW INTIN+(dummy*2),bezarr(dummy)
	NEXT dummy
	VDISYS(0)

	totpts=PEEKW(INTOUT)
	totmoves=PEEKW(INTOUT+2)

	extent(0)=PEEKW(PTSOUT)
	extent(1)=PEEKW(PTSOUT+2)
	extent(2)=PEEKW(PTSOUT+4)
	extent(3)=PEEKW(PTSOUT+6)
END IF
END SUB


SUB v_bar (BYVAL handle,rect())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	POKEW PTSIN,rect(0)
	POKEW PTSIN+2,rect(1)
	POKEW PTSIN+4,rect(2)
	POKEW PTSIN+6,rect(3)
	VDISYS(0)
END IF
END SUB


SUB v_pieslice (BYVAL handle,BYVAL x,BYVAL y,BYVAL radius,BYVAL begang,BYVAL endang)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,4
	POKEW CONTRL+6,2
	POKEW CONTRL+10,3
	POKEW CONTRL+12,handle
	POKEW INTIN,begang
	POKEW INTIN+2,endang
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+12,radius
	VDISYS(0)
END IF
END SUB


SUB v_circle (BYVAL handle,BYVAL x,BYVAL y,BYVAL radius)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,3
	POKEW CONTRL+6,0
	POKEW CONTRL+10,4
	POKEW CONTRL+12,handle
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+8,radius
	VDISYS(0)
END IF
END SUB


SUB v_ellipse (BYVAL handle,BYVAL x,BYVAL y,BYVAL x_radius,BYVAL y_radius)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,5
	POKEW CONTRL+12,handle
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+4,x_radius
	POKEW PTSIN+6,y_radius
	VDISYS(0)
END IF
END SUB


SUB v_ellpie (BYVAL handle,BYVAL x,BYVAL y,BYVAL x_radius,BYVAL y_radius,BYVAL begang,BYVAL endang)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,5
	POKEW CONTRL+12,handle
	POKEW INTIN,begang
	POKEW INTIN+2,endang
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+4,x_radius
	POKEW PTSIN+6,y_radius
	VDISYS(0)
END IF
END SUB


SUB v_rfbox (BYVAL handle,rect())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,9
	POKEW CONTRL+12,handle
	POKEW PTSIN,rect(0)
	POKEW PTSIN+2,rect(1)
	POKEW PTSIN+4,rect(2)
	POKEW PTSIN+6,rect(3)
	VDISYS(0)
END IF
END SUB


FUNCTION vsf_interior (BYVAL handle,BYVAL interior)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsf_interior=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,23
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,interior
	VDISYS(0)

	vsf_interior=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vsf_style (BYVAL handle,BYVAL style_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsf_style=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,24
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,style_index
	VDISYS(0)

	vsf_style=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vsf_color (BYVAL handle,BYVAL color_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsf_color=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,25
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	VDISYS(0)

	vsf_color=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vqf_attributes (BYVAL handle,attrib())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,37
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	attrib(0)=PEEKW(INTOUT)    ' Fill type
	attrib(1)=PEEKW(INTOUT+2)  ' Fill colour
	attrib(2)=PEEKW(INTOUT+4)  ' Fill style index
	attrib(3)=PEEKW(INTOUT+6)  ' Writing mode
	attrib(4)=PEEKW(INTOUT+8)  ' Perimeter flag
END IF
END SUB


SUB v_contourfill (BYVAL handle,BYVAL x,BYVAL y,BYVAL color_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,103
	POKEW CONTRL+2,1
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)
END IF
END SUB


FUNCTION vsf_perimeter (BYVAL handle,BYVAL flag)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsf_perimeter=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,104
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,flag
	VDISYS(0)

	vsf_perimeter=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vsf_udpat (BYVAL handle,pattern(),BYVAL planes)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,112
	POKEW CONTRL+2,0
	POKEW CONTRL+6,(planes*16)
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (planes*16)-1
		POKEW INTIN+(dummy*2),pattern(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB vr_recfl (BYVAL handle,rect())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,114
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,rect(0)
	POKEW PTSIN+2,rect(1)
	POKEW PTSIN+4,rect(2)
	POKEW PTSIN+6,rect(3)
	VDISYS(0)
END IF
END SUB


' Marker

SUB v_pmarker (BYVAL handle,BYVAL count,xyarr())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,7
	POKEW CONTRL+2,count
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	FOR dummy=0 TO (count-1)
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


FUNCTION vsm_type (BYVAL handle,BYVAL type)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsm_type=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,18
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,type
	VDISYS(0)

	vsm_type=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vsm_height (BYVAL handle,BYVAL height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsm_height=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,19
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,height
	VDISYS(0)

	vsm_height=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vsm_color (BYVAL handle,BYVAL color_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsm_color=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,20
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	VDISYS(0)

	vsm_color=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vqm_attributes (BYVAL handle,attrib())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,36
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	attrib(0)=PEEKW(INTOUT)    ' Marker type
	attrib(1)=PEEKW(INTOUT+2)  ' Marker colour
	attrib(2)=PEEKW(INTOUT+4)  ' Writing mode
	attrib(3)=PEEKW(PTSOUT+2)  ' Marker height
	attrib(4)=PEEKW(PTSOUT)    ' Marker width
END IF
END SUB


' Text Output with Bitmap Vectors

SUB v_gtext (BYVAL handle,BYVAL x,BYVAL y,BYVAL text$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,8
	POKEW CONTRL+2,1
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(text$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy+1,1))
	NEXT dummy
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)
END IF
END SUB


SUB v_justified (BYVAL handle,BYVAL x,BYVAL y,BYVAL text$,BYVAL length,BYVAL word_space,BYVAL char_space)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	IF word_space=0 THEN word_space=1
	IF char_space=0 THEN char_space=1
	POKEW CONTRL,11
	POKEW CONTRL+2,2
	POKEW CONTRL+6,LEN(text$)+2
	POKEW CONTRL+10,10
	POKEW CONTRL+12,handle
	POKEW INTIN,word_space
	POKEW INTIN+2,char_space
	FOR dummy=2 TO LEN(text$)
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy-1,1))
	NEXT dummy
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	POKEW PTSIN+4,length
	VDISYS(0)
END IF
END SUB


SUB vst_height (BYVAL handle,BYVAL height,char_width,char_height,cell_width,cell_height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,12
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,height
	VDISYS(0)

	char_width=PEEKW(PTSOUT)
	char_height=PEEKW(PTSOUT+2)
	cell_width=PEEKW(PTSOUT+4)
	cell_height=PEEKW(PTSOUT+6)
END IF
END SUB


FUNCTION vst_rotation (BYVAL handle,BYVAL angle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_rotation=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,13
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,angle
	VDISYS(0)

	vst_rotation=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vst_font (BYVAL handle,BYVAL font)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_font=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,21
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,font
	VDISYS(0)

	vst_font=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vst_color (BYVAL handle,BYVAL color_index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_color=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,22
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,color_index
	VDISYS(0)

	vst_color=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vqt_attributes (BYVAL handle,attrib())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,38
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	attrib(0)=PEEKW(INTOUT)    ' Font id
	attrib(1)=PEEKW(INTOUT+2)  ' Text colour index
	attrib(2)=PEEKW(INTOUT+4)  ' Text rotation in 1/10 degrees
	attrib(3)=PEEKW(INTOUT+6)  ' Horizontal alignment
	attrib(4)=PEEKW(INTOUT+8)  ' Vertical alignment
	attrib(5)=PEEKW(INTOUT+10) ' Writing mode
	attrib(6)=PEEKW(PTSOUT)    ' Character width
	attrib(7)=PEEKW(PTSOUT+2)  ' Character height
	attrib(8)=PEEKW(PTSOUT+4)  ' Character cell width
	attrib(9)=PEEKW(PTSOUT+6)  ' Character cell height
END IF
END SUB


SUB vst_alignment (BYVAL handle,BYVAL hor_in,BYVAL vert_in,hor_out,vert_out)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,39
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,hor_in
	POKEW INTIN+2,vert_in
	VDISYS(0)

	hor_out=PEEKW(INTOUT)
	vert_out=PEEKW(INTOUT+2)
END IF
END SUB


FUNCTION vst_effects (BYVAL handle,BYVAL effect)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_effects=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,106
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,effect
	VDISYS(0)

	vst_effects=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vst_point (BYVAL handle,BYVAL point_size,char_width,char_height,cell_width,cell_height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_point=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,107
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,point_size
	VDISYS(0)

	vst_point=PEEKW(INTOUT)
	char_width=PEEKW(PTSOUT)
	char_height=PEEKW(PTSOUT+2)
	cell_width=PEEKW(PTSOUT+4)
	cell_height=PEEKW(PTSOUT+6)
END IF
END FUNCTION


SUB vqt_extent (BYVAL handle,BYVAL text$,extent())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,116
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(text$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy+1,1))
	NEXT dummy
	VDISYS(0)

	FOR dummy=0 TO 7
		extent(dummy)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


FUNCTION vqt_width (BYVAL handle,BYVAL index,cell_width,left_delta,right_delta)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_width=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,117
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	VDISYS(0)

	vqt_width=PEEKW(INTOUT)
	cell_width=PEEKW(PTSOUT)
	left_delta=PEEKW(PTSOUT+2)
	right_delta=PEEKW(PTSOUT+4)
END IF
END FUNCTION


FUNCTION vst_load_fonts (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_load_fonts=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,119
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,0
	VDISYS(0)

	vst_load_fonts=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vst_unload_fonts (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,120
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,0
	VDISYS(0)
END IF
END SUB


FUNCTION vqt_name (BYVAL handle,BYVAL index,name$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_name=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,130
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	POKEW INTIN+2,0
	VDISYS(0)

	vqt_name=PEEKW(INTOUT)

	name$=""
	FOR dummy=1 TO 32
		name$=name$+RIGHT$(MKI$(PEEKW(INTOUT+(dummy*2))),1)
	NEXT dummy
	name$=RTRIM$(name$)
END IF
END FUNCTION


FUNCTION vqt_ext_name (BYVAL handle,BYVAL index,name$,font_format,flags)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_ext_name=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,130
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	POKEW INTIN+2,0
	VDISYS(0)

	vqt_ext_name=PEEKW(INTOUT)

	name$=""
	FOR dummy=1 TO 32
		name$=name$+RIGHT$(MKI$(PEEKW(INTOUT+(dummy*2))),1)
	NEXT dummy
	name$=RTRIM$(name$)

	font_format=PEEKW(INTOUT+68)
	flags=PEEKB(INTOUT+68)
END IF
END FUNCTION


SUB vqt_fontinfo (BYVAL handle,minADE,maxADE,distances(),max_width,effects())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,131
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	minADE=PEEKW(INTOUT)
	maxADE=PEEKW(INTOUT+2)
	max_width=PEEKW(PTSOUT)
	distances(0)=PEEKW(PTSOUT+2)
	effects(0)=PEEKW(PTSOUT+4)
	distances(1)=PEEKW(PTSOUT+6)
	effects(1)=PEEKW(PTSOUT+8)
	distances(2)=PEEKW(PTSOUT+10)
	effects(2)=PEEKW(PTSOUT+12)
	distances(3)=PEEKW(PTSOUT+14)
	distances(4)=PEEKW(PTSOUT+18)
END IF
END SUB


FUNCTION vqt_xfntinfo (BYVAL handle,BYVAL flags,BYVAL id,index,info&)
STATIC font_format

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_xfntinfo=-1 : EXIT FUNCTION
ELSE
	IF flags>32 THEN flags=32
	POKEW CONTRL,229
	POKEW CONTRL+2,0
	POKEW CONTRL+6,5
	POKEW CONTRL+10,0
	POKEW CONTRL+12,handle
	POKEW INTIN,flags
	POKEW INTIN+2,id
	POKEW INTIN+4,index
	POKEL INTIN+6,info&
	VDISYS(0)

	font_format=PEEKW(INTOUT)
	vqt_xfntinfo=PEEKW(INTOUT+2)
	index=PEEKW(INTOUT+4)
END IF
END FUNCTION


FUNCTION vst_name (BYVAL handle,BYVAL font_format,BYVAL font_name$,ret_name$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_name=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,230
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(font_name$)+1
	POKEW CONTRL+10,0
	POKEW CONTRL+12,handle
	POKEW INTIN,font_format
	FOR dummy=1 TO LEN(font_name$)
		POKEW INTIN+(dummy*2),ASC(MID$(font_name$,dummy,1))
	NEXT dummy
	VDISYS(0)

	vst_name=PEEKW(INTOUT)
	ret_name$=""
	FOR dummy=1 TO PEEKW(CONTRL+8)
		ret_name$=ret_name$+RIGHT$(MKI$(PEEKW(INTOUT+(dummy*2))),1)
	NEXT dummy
	ret_name$=RTRIM$(ret_name$)
END IF
END FUNCTION


FUNCTION vqt_char_index (BYVAL handle,BYVAL src_index,BYVAL src_mode,BYVAL dst_mode)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_char_index=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,190
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,0
	POKEW CONTRL+12,handle
	POKEW INTIN,src_index
	POKEW INTIN+2,src_mode
	POKEW INTIN+4,dst_mode
	VDISYS(0)

	vqt_char_index=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION vqt_name_and_id (BYVAL handle,BYVAL font_format,BYVAL font_name$,ret_name$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vqt_name_and_id=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,230
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(font_name$)
	POKEW CONTRL+10,100
	POKEW CONTRL+12,handle
	POKEW INTIN,font_format
	FOR dummy=1 TO LEN(font_name$)
		POKEW INTIN+(dummy*2),ASC(MID$(font_name$,dummy,1))
	NEXT dummy
	VDISYS(0)

	vqt_name_and_id=PEEKW(INTOUT)
	IF PEEKW(INTOUT)<>0 THEN
		ret_name$=""
		FOR dummy=1 TO PEEKW(CONTRL+8)
			ret_name$=ret_name$+RIGHT$(MKI$(PEEKW(INTOUT+(dummy*2))),1)
		NEXT dummy
		ret_name$=RTRIM$(ret_name$)
	ELSE
		ret_name$=""
	END IF
END IF
END FUNCTION


SUB vst_width (BYVAL handle,BYVAL total_width,char_width,char_height,cell_width,cell_height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,231
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,total_width
	VDISYS(0)

	char_width=PEEKW(PTSOUT)
	char_height=PEEKW(PTSOUT+2)
	cell_width=PEEKW(PTSOUT+4)
	cell_height=PEEKW(PTSOUT+6)
END IF
END SUB


SUB vqt_fontheader (BYVAL handle,buffer&,tdf_name$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,232
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEL PTSIN,buffer&
	VDISYS(0)

	tdf_name$=""
	FOR dummy=1 TO PEEKW(CONTRL+8)
		tdf_name$=tdf_name$+MKI$(PEEKW(INTOUT+(dummy*2)))
	NEXT dummy
	tdf_name$=RTRIM$(tdf_name$)
END IF
END SUB


SUB vqt_trackkern (BYVAL handle,x_offset&,y_offset&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,234
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	x_offset&=PEEKL(INTOUT)
	y_offset&=PEEKL(INTOUT+4)
END IF
END SUB


SUB vqt_pairkern (BYVAL handle,BYVAL index1,BYVAL index2,x_offset&,y_offset&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,235
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,index1
	POKEW INTIN+2,index2
	VDISYS(0)

	x_offset&=PEEKL(INTOUT)
	y_offset&=PEEKL(INTOUT+4)
END IF
END SUB


SUB vst_charmap (BYVAL handle,BYVAL mode)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,236
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,mode
	VDISYS(0)
END IF
END SUB


FUNCTION vst_map_mode (BYVAL handle,BYVAL mode)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_map_mode=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,236
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,mode
	POKEW INTIN+2,1
	VDISYS(0)

	vst_map_mode=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vst_kern (BYVAL handle,BYVAL track_mode,BYVAL pair_mode,track,pairs)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,237
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,track_mode
	POKEW INTIN+2,pair_mode
	VDISYS(0)

	track=PEEKW(INTOUT)
	pairs=PEEKW(INTOUT+2)
END IF
END SUB


SUB vst_track_offset (BYVAL handle,BYVAL offset&,BYVAL pair_mode,track,pairs)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,237
	POKEW CONTRL+2,0
	POKEW CONTRL+6,4
	POKEW CONTRL+12,handle
	POKEW INTIN,255
	POKEW INTIN+2,pair_mode
	POKEL INTIN+4,offset&
	VDISYS(0)

	track=PEEKW(INTOUT)
	pairs=PEEKW(INTOUT+2)
END IF
END SUB


SUB v_getbitmap_info (BYVAL handle,BYVAL index,x_advance&,y_advance&,x_offset&,y_offset&,bit_width,bit_height,bitmap&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,239
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	VDISYS(0)

	bit_width=PEEKW(INTOUT)
	bit_height=PEEKW(INTOUT+2)
	x_advance&=PEEKL(INTOUT+4)
	y_advance&=PEEKL(INTOUT+8)
	x_offset&=PEEKL(INTOUT+12)
	y_offset&=PEEKL(INTOUT+16)
	bitmap&=PEEKL(INTOUT+20)
END IF
END SUB


SUB vqt_f_extent (BYVAL handle,BYVAL text$,extent())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,240
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(text$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy+1,1))
	NEXT dummy
	VDISYS(0)

	FOR dummy=0 TO 7
		extent(dummy)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB vqt_real_extent (BYVAL handle,BYVAL x,BYVAL y,BYVAL text$,extent())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,240
	POKEW CONTRL+2,1
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+10,4200
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(text$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy+1,1))
	NEXT dummy
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)

	FOR dummy=0 TO 7
		extent(dummy)=PEEKW(PTSOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB v_ftext (BYVAL handle,BYVAL x,BYVAL y,BYVAL text$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,241
	POKEW CONTRL+2,1
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(text$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(text$,dummy+1,1))
	NEXT dummy
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)
END IF
END SUB


SUB v_getoutline (BYVAL handle,BYVAL index,xyarr(),bezarr(),BYVAL max_pts,count)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,243
	POKEW CONTRL+2,0
	POKEW CONTRL+6,6
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	POKEW INTIN+2,max_pts
	POKEL INTIN+4,VARPTR(xyarr(0))
	POKEL INTIN+8,VARPTR(bezarr(0))
	VDISYS(0)

	count=PEEKW(INTOUT)
END IF
END SUB


FUNCTION vst_arbpt32 (BYVAL handle,BYVAL height&,char_width,char_height,cell_width,cell_height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_arbpt32=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,246
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEL INTIN,height&
	VDISYS(0)

	vst_arbpt32=PEEKW(INTOUT)
	char_width=PEEKW(PTSOUT)
	char_height=PEEKW(PTSOUT+2)
	cell_width=PEEKW(PTSOUT+4)
	cell_height=PEEKW(PTSOUT+6)
END IF
END FUNCTION


SUB vqt_advance32 (BYVAL handle,BYVAL index,x_advance&,y_advance&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,247
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,index
	VDISYS(0)

	x_advance&=PEEKL(PTSOUT+8)
	y_advance&=PEEKL(PTSOUT+12)
END IF
END SUB


FUNCTION vst_setsize32 (BYVAL handle,BYVAL total_width&,char_width,char_height,cell_width,cell_height)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_setsize32=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,252
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEL INTIN,total_width&
	VDISYS(0)

	vst_setsize32=PEEKW(INTOUT)
	char_width=PEEKW(PTSOUT)
	char_height=PEEKW(PTSOUT+2)
	cell_width=PEEKW(PTSOUT+4)
	cell_height=PEEKW(PTSOUT+6)
END IF
END FUNCTION


FUNCTION vst_skew (BYVAL handle,BYVAL skew)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vst_skew=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,253
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,skew
	VDISYS(0)

	vst_skew=PEEKW(INTOUT)
END IF
END FUNCTION


' Raster Operations

SUB vro_cpyfm (BYVAL handle,BYVAL wr_mode,xyarr(),src_MFDB&(),des_MFDB&())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,109
	POKEW CONTRL+2,4
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,VARPTR(src_MFDB&(0))
	POKEL CONTRL+18,VARPTR(des_MFDB&(0))
	POKEW INTIN,wr_mode
	FOR dummy=0 TO 7
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB vrt_cpyfm (BYVAL handle,BYVAL wr_mode,xyarr(),src_MFDB&(),des_MFDB&(),color_index())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,109
	POKEW CONTRL+2,4
	POKEW CONTRL+6,3
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,VARPTR(src_MFDB&(0))
	POKEL CONTRL+18,VARPTR(des_MFDB&(0))
	POKEW INTIN,wr_mode
	POKEW INTIN+2,color_index(0)
	POKEW INTIN+4,color_index(1)
	FOR dummy=0 TO 7
		POKEW PTSIN+(dummy*2),xyarr(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB vr_trnfm (BYVAL handle,src_MFDB&(),des_MFDB&())
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,110
	POKEW CONTRL+2,0
	POKEW CONTRL+4,0
	POKEW CONTRL+6,0
	POKEW CONTRL+8,0
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,VARPTR(src_MFDB&(0))
	POKEL CONTRL+18,VARPTR(des_MFDB&(0))
	VDISYS(0)
END IF
END SUB


SUB v_get_pixel (BYVAL handle,BYVAL x,BYVAL y,pel,index)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,105
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)

	pel=PEEKW(INTOUT)
	index=PEEKW(INTOUT+2)
END IF
END SUB


' Input Functions

SUB vsin_mode (BYVAL handle,BYVAL dev_type,mode)
SHARED set_mode

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,33
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,dev_type
	POKEW INTIN+2,mode
	VDISYS(0)

	set_mode=PEEKW(INTOUT)
END IF
END SUB


SUB vrq_locator (BYVAL handle,BYVAL x,BYVAL y,xout,yout,term)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,28
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)

	term=PEEKW(INTOUT)
	xout=PEEKW(PTSOUT)
	yout=PEEKW(PTSOUT+2)
END IF
END SUB


SUB vsm_locator (BYVAL handle,BYVAL x,BYVAL y,xout,yout,term)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,28
	POKEW CONTRL+2,1
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEW PTSIN,x
	POKEW PTSIN+2,y
	VDISYS(0)

	term=PEEKW(INTOUT)
	xout=PEEKW(PTSOUT)
	yout=PEEKW(PTSOUT+2)
END IF
END SUB


SUB vrq_choice (BYVAL handle,BYVAL ch_in,ch_out)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,30
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,ch_in
	VDISYS(0)

	ch_out=PEEKW(INTOUT)
END IF
END SUB


FUNCTION vsm_choice (BYVAL handle,choice)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsm_choice=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,30
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	choice=PEEKW(INTOUT)
END IF
END FUNCTION


SUB vrq_string (BYVAL handle,BYVAL max_length,BYVAL echo_mode,echo_xy(),text$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,31
	POKEW CONTRL+2,1
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,max_length
	POKEW INTIN+2,echo_mode
	POKEW PTSIN,echo_xy(0)
	POKEW PTSIN+2,echo_xy(1)
	VDISYS(0)

	text$=""
	FOR dummy=0 TO PEEKW(CONTRL+8)
		text$=text$+CHR$(PEEKW(INTOUT+dummy))
		INCR dummy
	NEXT dummy
	text$=RTRIM$(text$)
END IF
END SUB


FUNCTION vsm_string (BYVAL handle,BYVAL max_length,BYVAL echo_mode,echo_xy(),text$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	vsm_string=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,31
	POKEW CONTRL+2,1
	POKEW CONTRL+6,2
	POKEW CONTRL+12,handle
	POKEW INTIN,max_length
	POKEW INTIN+2,echo_mode
	POKEW PTSIN,echo_xy(0)
	POKEW PTSIN+2,echo_xy(1)
	VDISYS(0)

	IF PEEKW(CONTRL+8)>0 THEN
		text$=""
		FOR dummy=0 TO PEEKW(CONTRL+8)
			text$=text$+MKI$(PEEKW(INTOUT+dummy))
			INCR dummy
		NEXT dummy
		text$=RTRIM$(text$) : vsm_string=LEN(text$)
	ELSE
		text$="" : vsm_string=0
	END IF
END IF
END FUNCTION


SUB vsc_form (BYVAL handle,cursor())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,111
	POKEW CONTRL+2,0
	POKEW CONTRL+6,37
	POKEW CONTRL+12,handle
	FOR dummy=0 TO 36
		POKEW INTIN+(dummy*2),cursor(dummy)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB vsc_getform (BYVAL handle,cursor())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,111
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	FOR dummy=0 TO 36
		cursor(dummy)=PEEKW(INTOUT+(dummy*2))
	NEXT dummy
END IF
END SUB


SUB vqin_mode (BYVAL handle,BYVAL dev_type,input_mode)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,115
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,dev_type
	VDISYS(0)

	input_mode=PEEKW(INTOUT+2)
END IF
END SUB


SUB vex_timv (BYVAL handle,BYVAL tim_addr&,otim_addr&,tim_conv)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,118
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,tim_addr&
	VDISYS(0)

	otim_addr&=PEEKL(CONTRL+18)
	tim_conv=PEEKW(INTOUT)
END IF
END SUB


SUB v_show_c (BYVAL handle,BYVAL reset_cursor)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,122
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+12,handle
	POKEW INTIN,reset_cursor
	VDISYS(0)
END IF
END SUB


SUB v_hide_c (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,123
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB vq_mouse (BYVAL handle,status,x,y)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,124
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	status=PEEKW(INTOUT)
	x=PEEKW(PTSOUT)
	y=PEEKW(PTSOUT+2)
END IF
END SUB


SUB vex_butv (BYVAL handle,BYVAL pusrcode&,psavcode&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,125
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,pusrcode&
	VDISYS(0)

	psavcode&=PEEKL(CONTRL+18)
END IF
END SUB


SUB vex_motv (BYVAL handle,BYVAL pusrcode&,psavcode&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,126
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,pusrcode&
	VDISYS(0)

	psavcode&=PEEKL(CONTRL+18)
END IF
END SUB


SUB vex_curv (BYVAL handle,BYVAL pusrcode&,psavcode&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,127
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	POKEL CONTRL+14,pusrcode&
	VDISYS(0)

	psavcode&=PEEKL(CONTRL+18)
END IF
END SUB


SUB vq_key_s (BYVAL handle,status)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,128
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+12,handle
	VDISYS(0)

	status=PEEKW(INTOUT)
END IF
END SUB


' Text Mode and VT52

SUB vq_chcells (BYVAL handle,rows,columns)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,1
	POKEW CONTRL+12,handle
	VDISYS(0)

	rows=PEEKW(INTOUT)
	columns=PEEKW(INTOUT+2)
END IF
END SUB


SUB v_exit_cur (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,2
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_enter_cur (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,3
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curup (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,4
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curdown (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,5
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curright (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,6
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curleft (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,7
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curhome (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,8
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_eeos (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,9
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_eeol (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,10
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_curaddress (BYVAL handle,BYVAL row,BYVAL column)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,11
	POKEW CONTRL+12,handle
	POKEW INTIN,row
	POKEW INTIN+2,column
	VDISYS(0)
END IF
END SUB


SUB v_curtext (BYVAL handle,BYVAL text$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(text$)
	POKEW CONTRL+10,12
	POKEW CONTRL+12,handle
	FOR dummy=1 TO LEN(text$)
		POKEW INTIN+((dummy-1)*2),ASC(MID$(text$,dummy,1))
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB v_rvon (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,13
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB v_rvoff (BYVAL handle)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,14
	POKEW CONTRL+12,handle
	VDISYS(0)
END IF
END SUB


SUB vq_curaddress (BYVAL handle,row,column)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,0
	POKEW CONTRL+10,15
	POKEW CONTRL+12,handle
	VDISYS(0)

	row=PEEKW(INTOUT)
	column=PEEKW(INTOUT+2)
END IF
END SUB


' Printer specific functions

SUB v_bit_image (BYVAL handle,BYVAL file_name$,BYVAL aspect,BYVAL x_scale,BYVAL y_scale,BYVAL h_align,BYVAL v_align,xyarray())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,5+LEN(file_name$)
	POKEW CONTRL+10,23
	POKEW CONTRL+12,handle
	POKEW INTIN,aspect
	POKEW INTIN+2,x_scale
	POKEW INTIN+4,y_scale
	POKEW INTIN+6,h_align
	POKEW INTIN+8,v_align
	FOR dummy=5 TO 5+LEN(file_name$)
		POKEW INTIN+(dummy*2),ASC(MID$(file_name$,dummy-4,1))
	NEXT dummy
	POKEW PTSIN,xyarray(0)
	POKEW PTSIN+2,xyarray(1)
	POKEW PTSIN+4,xyarray(2)
	POKEW PTSIN+6,xyarray(3)
	VDISYS(0)
END IF
END SUB


FUNCTION v_orient (BYVAL handle,BYVAL orient)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	v_orient=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+10,27
	POKEW CONTRL+12,handle
	POKEW INTIN,orient
	VDISYS(0)

	v_orient=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION v_copies (BYVAL handle,BYVAL copies)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	v_copies=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+10,28
	POKEW CONTRL+12,handle
	POKEW INTIN,copies
	VDISYS(0)

	v_copies=PEEKW(INTOUT)
END IF
END FUNCTION


SUB v_trays (BYVAL handle,BYVAL p_intput,BYVAL p_output,set_input,set_output)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,2
	POKEW CONTRL+10,29
	POKEW CONTRL+12,handle
	POKEW INTIN,p_intput
	POKEW INTIN+2,p_output
	VDISYS(0)

	set_input=PEEKW(INTOUT)
	set_output=PEEKW(INTOUT+2)
END IF
END SUB


SUB vq_tray_names (BYVAL handle,input_name$,output_name$,no_input,no_output)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,4
	POKEW CONTRL+10,36
	POKEW CONTRL+12,handle
	POKEL INTIN,SADD(input_name$)
	POKEL INTIN+4,SADD(output_name$)
	VDISYS(0)

	no_input=PEEKW(INTOUT)
	no_output=PEEKW(INTOUT+2)
END IF
END SUB


FUNCTION v_page_size (BYVAL handle,BYVAL page_id)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	v_page_size=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+10,37
	POKEW CONTRL+12,handle
	POKEW INTIN,page_id
	VDISYS(0)

	v_page_size=PEEKW(INTOUT)
END IF
END FUNCTION


FUNCTION v_page_name (BYVAL handle,BYVAL page_id,BYVAL page_name$,page_width&,page_height&)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	v_page_name=-1 : EXIT FUNCTION
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,38
	POKEW CONTRL+12,handle
	POKEW INTIN,page_id
	POKEL INTIN+2,SADD(page_name$)
	VDISYS(0)

	v_page_name=PEEKW(INTOUT)
	page_width&=PEEKL(INTOUT+2)
	page_height&=PEEKL(INTOUT+6)
END IF
END FUNCTION


SUB v_escape2000 (BYVAL handle,BYVAL times)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,1
	POKEW CONTRL+10,2000
	POKEW CONTRL+12,handle
	POKEW INTIN,times
	VDISYS(0)
END IF
END SUB


' Metafile specific functions

SUB v_meta_extents (BYVAL handle,BYVAL x_min,BYVAL y_min,BYVAL x_max,BYVAL y_max)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,2
	POKEW CONTRL+6,0
	POKEW CONTRL+10,98
	POKEW CONTRL+10,4200
	POKEW PTSIN,x_min
	POKEW PTSIN+2,y_min
	POKEW PTSIN+4,x_max
	POKEW PTSIN+6,y_max
	VDISYS(0)
END IF
END SUB


SUB v_write_meta (BYVAL handle,BYVAL num_intin,a_intin(),BYVAL num_ptsin,a_ptsin())
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,num_ptsin
	POKEW CONTRL+6,num_intin
	POKEW CONTRL+10,99
	POKEW CONTRL+10,4200
	POKEW INTIN,a_intin(0)
	FOR dummy=1 TO num_intin-1
		POKEW INTIN+(dummy*2),a_intin(dummy-1)
	NEXT dummy
	FOR dummy=1 TO num_ptsin-1
		POKEW PTSIN+(dummy*2),a_ptsin(dummy-1)
	NEXT dummy
	VDISYS(0)
END IF
END SUB


SUB vm_pagesize (BYVAL handle,BYVAL pgwidth,BYVAL pgheight)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,3
	POKEW CONTRL+10,99
	POKEW CONTRL+12,handle
	POKEW INTIN,0
	POKEW INTIN+2,pgwidth
	POKEW INTIN+4,pgheight
	VDISYS(0)
END IF
END SUB


SUB vm_coords (BYVAL handle,BYVAL llx,BYVAL lly,BYVAL urx,BYVAL ury)
IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,5
	POKEW CONTRL+10,99
	POKEW CONTRL+12,handle
	POKEW INTIN,1
	POKEW INTIN+2,llx
	POKEW INTIN+4,lly
	POKEW INTIN+6,urx
	POKEW INTIN+8,ury
	VDISYS(0)
END IF
END SUB


SUB vm_filename (BYVAL handle,BYVAL filename$)
STATIC dummy

IF handle=0 THEN handle=1
IF cookie_NVDI=0 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  NVDI is not present! ][ OK ]")
	EXIT SUB
ELSE
	POKEW CONTRL,5
	POKEW CONTRL+2,0
	POKEW CONTRL+6,LEN(filename$)
	POKEW CONTRL+10,100
	POKEW CONTRL+12,handle
	FOR dummy=0 TO LEN(filename$)-1
		POKEW INTIN+(dummy*2),ASC(MID$(filename$,dummy+1,1))
	NEXT dummy
	VDISYS(0)
END IF
END SUB

'[*END OF FILE*]
