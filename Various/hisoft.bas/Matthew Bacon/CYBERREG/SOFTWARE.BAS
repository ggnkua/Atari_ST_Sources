'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB software
SHARED HowManyTextWindows,woTLines(),software_handle,woHandle(),selected_items
STATIC file$

IF software_handle<>0 THEN
	TopAWindow software_handle
	CALL FullRedraw (software_handle)
ELSE
	file$=CURDIR$+"\SOFTWARE.DAT"
	IF FEXISTS(file$) THEN
		IF TextWindowSystem=0 THEN InitTextSystem 2,200
		LoadSoftware file$,HowManyTextWindows,woTLines(HowManyTextWindows)
		software_handle=OpenTextWindow(MyProgram$+" : Software - 0 items selected",win_all-win_close-win_info)
		IF selected_items=1 THEN
			RenameWindow software_handle,MyProgram$+": Software -"+STR$(selected_items)+" item selected"
		ELSE
			RenameWindow software_handle,MyProgram$+": Software -"+STR$(selected_items)+" items selected"
		END IF
	ELSE
		junk=form_alert(1,"[1][  "+MyProgram$+": |  The file SOFTWARE.DAT could |  not be found - sorry! ][ Abort ]")
	END IF
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LoadSoftware(BYVAL file$,BYVAL index,TotalLines)
SHARED WindTLines$(2),MaxTextLines,expandtabsflag,software$()
STATIC dummy,myfile,dummy$,begin_software

IF TextWindowSystem=0 THEN EXIT SUB
CALL update_mouse
begin_software=0 : dummy=0 : myfile=FREEFILE
DIM software$(11,100)
OPEN file$ FOR INPUT AS #myfile
DO
	IF begin_software=0 THEN
		LINE INPUT #myfile,dummy$
	ELSE
		INPUT #myfile,software$(0,dummy)
		IF software$(0,dummy)="<end>" THEN
			EXIT LOOP
		ELSE
			INPUT #myfile,software$(1,dummy),software$(2,dummy),software$(3,dummy)
			INPUT #myfile,software$(4,dummy),software$(5,dummy),software$(6,dummy),software$(7,dummy)
			INPUT #myfile,software$(8,dummy),software$(9,dummy),software$(10,dummy)

			CALL padoutstring (software$(0,dummy),9)
			CALL padoutstring (software$(1,dummy),20)
			CALL padoutstring (software$(2,dummy),7)
			CALL padoutstring (software$(3,dummy),6)
			CALL padoutstring (software$(4,dummy),39)
			CALL padoutstring (software$(5,dummy),6)
			CALL padoutstring (software$(6,dummy),9)
			CALL padoutstring (software$(7,dummy),9)
			CALL padoutstring (software$(8,dummy),6)
			CALL padoutstring (software$(9,dummy),9)
			CALL padoutstring (software$(10,dummy),9)
			dummy$=software$(0,dummy)
		END IF
	END IF
	SELECT CASE dummy
	CASE 0
		IF dummy$<>"<CyberReg>" THEN
			junk=form_alert(1,"[1][  "+MyProgram$+": |  A valid SOFTWARE.DAT file |  could not be found - sorry! ][ Abort ]")
			EXIT LOOP
		END IF
	CASE 1
		IF dummy$<>"<begin>" THEN
			junk=form_alert(1,"[1][  "+MyProgram$+": |  A valid SOFTWARE.DAT file |  could not be found - sorry! ][ Abort ]")
			EXIT LOOP
		ELSE
			begin_software=-1
			dummy=3
		END IF
	CASE ELSE
		WindTLines$(index,dummy)=software$(0,dummy)+software$(1,dummy)+software$(2,dummy)+software$(3,dummy)+software$(4,dummy)+software$(5,dummy)+software$(6,dummy)+software$(7,dummy)+software$(8,dummy)+software$(9,dummy)+software$(10,dummy)
		IF dummy>=MaxTextLines THEN EXIT LOOP
	END SELECT
	INCR dummy
	CALL update_mouse
LOOP UNTIL EOF(myfile)
	WindTLines$(index,0)="-------------------------------------------------------------------------------------------------------------------------------"
	WindTLines$(index,1)="Version  Software/Author      Fee  Status Brief description                      P&P UK: (UKP)           P&P ROW: (UKP)"
	WindTLines$(index,2)="                             (UKP)                                               1 prg 2-4 prgs 5+ prgs  1 prg 2-4 prgs 5+ prgs"
	WindTLines$(index,3)="-------------------------------------------------------------------------------------------------------------------------------"
	WindTLines$(index,dummy)="-------------------------------------------------------------------------------------------------------------------------------"
	IF dummy<>MaxTextLines THEN
		INCR dummy
		WindTLines$(index,dummy)="Key : -S- Shareware ; -F- Freeware ; -B- Feedbackware ; -C- Commercial"
		INCR dummy
		WindTLines$(index,dummy)="Note: You must pay the shareware fee if you use the program. Freeware programs"
		INCR dummy
		WindTLines$(index,dummy)="      programs carry a suggested minimum contribution."
		INCR dummy
		WindTLines$(index,dummy)="-------------------------------------------------------------------------------------------------------------------------------"
		INCR dummy
	END IF
CLOSE myfile : TotalLines=dummy
ERASE software$ : MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB padoutstring (dummy$,BYVAL length)
STATIC dummy

dummy=LEN(dummy$)
SELECT CASE dummy
CASE 0 : dummy$=SPACE$(length)
CASE >length
	dummy$=LEFT$(dummy$,length)
CASE <length
	dummy$=dummy$+SPACE$(length-dummy)
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SelectSoftware (BYVAL mx,BYVAL my)
SHARED CommonHandle,software_handle,woTindex(1),WindTlines$(2),woTLines(1),woVSWR(2)
SHARED woOffx(1),woOffy(1),CommonIndex,cellx,celly,selected_items,summary_handle
SHARED total_order,itemfee$(),orderform$()
STATIC file,item,x,y,w,h,dummy$,dummy

CommonIndex=WhichWindow(software_handle)
junk=wind_get(software_handle,WF_WORKXYWH,x,y,w,h) : file=woTindex(CommonIndex)

item=(woOffy(CommonIndex)\celly)+((my-y)\celly)
SELECT CASE item
CASE =<woTLines(file)
SELECT CASE item
CASE 4 TO (woTLines(file)-4)
	MOUSE -1
	vswr_mode 3
	vs_clip 1,x,y+(((my-y)\celly)*celly)+1,w,y+((((my-y)\celly)+1)*celly)
	vr_recfl x,y+(((my-y)\celly)*celly)+1,w,y+((((my-y)\celly)+1)*celly)
	MOUSE 0
	IF woVSWR(file,item)<>1 THEN
		woVSWR(file,item)=1
		DECR selected_items
		itemfee$(item)=""
	ELSE
		woVSWR(file,item)=4
		INCR selected_items
		IF MID$(WindTLines$(file,item),35,1)="+" THEN
			SelectTree FORM_FEE : setobj_text FEE_FEE,MID$(WindTLines$(file,item),30,2)+MID$(WindTLines$(file,item),33,2)
			setobj_text FEE_MINIMUM,""+MID$(WindTLines$(file,item),30,5)+")"
			junk=xdialog (FORM_FEE,FEE_FEE,0,1,0)
			IF VAL(getobj_text$(FEE_FEE))<VAL(MID$(WindTLines$(file,item),30,2)+MID$(WindTLines$(file,item),33,2))
				itemfee$(item)=MID$(WindTLines$(file,item),30,5)
			ELSE
				itemfee$(item)=LEFT$(getobj_text$(FEE_FEE),2)+"."+RIGHT$(getobj_text$(FEE_FEE),2)
			END IF
			SelectTree FORM_MAIN
		ELSE
			itemfee$(item)=MID$(WindTLines$(file,item),30,5)
		END IF
	END IF
	IF selected_items=1 THEN
		RenameWindow software_handle,MyProgram$+": Software -"+STR$(selected_items)+" item selected"
	ELSE
		RenameWindow software_handle,MyProgram$+": Software -"+STR$(selected_items)+" items selected"
	END IF
	vswr_mode 1
	IF summary_handle<>0 THEN
		CALL generate_summary
		CommonIndex=WhichWindow(summary_handle) : file=woTindex(CommonIndex)
		FOR dummy=0 TO total_order
			WindTLines$(file,dummy)=orderform$(dummy)
		NEXT
		woTLines(file)=total_order+1
		CALL FullRedraw (summary_handle)
	END IF
END SELECT
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
