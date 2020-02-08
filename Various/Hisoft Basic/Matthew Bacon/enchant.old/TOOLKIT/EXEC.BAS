
' [EXEC.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION Environment$
STATIC dummy,dummy$,temp$

dummy$="" : dummy=1
DO
	temp$=ENVIRON$(dummy)
	IF temp$="" THEN EXIT LOOP
	dummy$=dummy$+temp$+CHR$(0)
	INCR dummy
LOOP
Environment$=dummy$
END FUNCTION


SUB Execute(file$,commandline$)
SHARED fspath$
SHARED menutree&,desktree&,Windx,Windy,Windw,Windh,HowManyWindows,woHandle(1)
STATIC windtemp(2),cur_handle,dummy,cur_top,temp$,temp&,dummy&,dummy$,oldtree&

IF PEEKW(PEEKL(GB+4)+2)>1 THEN
	temp$=SPACE$(16) : temp&=VARPTR(temp$)
	dummy$=file$+CHR$(0) : dummy&=VARPTR(dummy$)
	POKEW temp&,av_startprog
	POKEW temp&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW temp&+4,0
	POKEL temp&+6,dummy&
	dummy$=commandline$+CHR$(0) : dummy&=VARPTR(dummy$)
	POKEL temp&+10,dummy&
	POKEW temp&+14,0
	appl_write 0,16,temp&
ELSE
	oldtree&=tree&
	junk=wind_get(0,WF_WORKXYWH,Windx,Windy,Windw,Windh)
	junk=wind_get(0,WF_TOP,cur_top,0,0,0)
	DIM windtemp(HowmanyWindows,4)
	FOR dummy=1 TO HowManyWindows
		cur_handle=woHandle(dummy)
		junk=wind_get(cur_handle,WF_CURRXYWH,windtemp(dummy,1),windtemp(dummy,2),_
			windtemp(dummy,3),windtemp(dummy,4))
		junk=wind_close(woHandle(dummy))
	NEXT dummy
	IF menutree& THEN menu_bar menutree&,0
	MOUSE 2
	junk=dsetdrv(ASC(LEFT$(fspath$,1))-65)
	junk=dsetpath(fspath$)
	dummy$=Environment$
	dummy&=pexec&(0,file$,commandline$,dummy$)
	IF desktree& THEN junk=wind_set(0,WF_NEWDESK,PEEKW(VARPTR(desktree&)),PEEKW(VARPTR(desktree&)+2),0,0)
	MOUSE 0
	IF menutree& THEN menu_bar menutree&,1
	FOR dummy=1 TO HowManyWindows
		junk=wind_open(woHandle(dummy),windtemp(dummy,1),windtemp(dummy,2),_
			windtemp(dummy,3),windtemp(dummy,4))
	NEXT dummy
	ERASE windtemp : junk=wind_set(0,WF_TOP,cur_top,0,0,0)
	form_dial FMD_FINISH,0,0,0,0,Windx,Windy,Windw,Windh
	tree&=oldtree&
END IF
END SUB

'[*END OF FILE*]