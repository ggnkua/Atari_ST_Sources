
' [TOOLBX_C.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' The file TOOLBX_B.BAS is required to use TOOLBX_C.BAS

DECLARE SUB Init_Menu (treeno,exititem)    ' Can be found in MENU.BAS

SUB dummy_routine

END SUB


SUB AbortProgram (dummy$)
SHARED DeskACCOpen

IF DeskACCOpen=-1 THEN
	CALL Debug (dummy$) : STOP -1
ELSE
	CALL Debug (dummy$) : CALL StopProgram
END IF
END SUB


SUB Debug (BYVAL dummy$)
SHARED DeskACCOpen
STATIC dummy

IF DeskACCOpen=-1 THEN
	FOR dummy=1 TO LEN(dummy$)
		OUT 2,ASC(MID$(dummy$,dummy,1))
	NEXT dummy
ELSE
	cconws dummy$
END IF
junk=INP(2)
END SUB


FUNCTION ConvertAlt (ScanCode)
STATIC dummy&,res
	dummy&=keytbl&(-1,-1,-1)
	res=PEEKB(PEEKL(dummy&)+CLNG(ScanCode)\256)
	IF res>="a"% AND res<="z"% THEN res=res-"a"%+"A"%
	ConvertAlt=res
END FUNCTION


FUNCTION byte_align (BYVAL x)
SHARED supress_byte_align
IF supress_byte_align=0 THEN byte_align=(x+4) AND &hFFF8
END FUNCTION


SUB LoadRSC (rscname$)
IF FEXISTS(rscname$) THEN
	IF rsrc_load(rscname$)=0 THEN
		junk=form_alert(1,"[3][  "+MyProgram$+": |  Resource file could not |  be loaded! ][  OK  ]")
		STOP -1
	ELSE
		resource_loaded=-1
	END IF
ELSE
	junk=form_alert(1,"[3][  "+MyProgram$+": |  Resource file could not |  be found! ][  OK  ]")
	STOP -1
END IF
END SUB


SUB StartProgram (BYVAL rscfile$,BYVAL treeno,BYVAL exititem,BYVAL icontreeno)
SHARED WindX,WindY,WindW,WindH,itreeno

IF PEEKW(PEEKL(GB+4))<>0 THEN
	WINDOW ON
	IF rscfile$<>"" THEN
		CALL LoadRSC (rscfile$)
		IF exititem THEN Init_Menu treeno,exititem
		junk=wind_get(0,WF_WORKXYWH,WindX,WindY,WindW,WindH)
		IF icontreeno THEN itreeno=icontreeno
	END IF
ELSE
	AbortProgram "This program does not run from the Auto folder! - Press any key..."
END IF
END SUB


SUB StopProgram
STATIC button

IF allchange THEN
	button=form_alert(1,"[1][  "+MyProgram$+": |  You have not saved all your |  data, do you wish to... ][ Continue | Cancel ]")
	SELECT CASE button
		CASE 1 : Finished_Flag=-1
		CASE 2 : GOTO RETURN_HANDLER
	END SELECT
END IF
IF menutree& THEN menu_bar menutree&,0
junk=wind_set(0,WF_NEWDESK,0,0,0,0)
IF resource_loaded THEN junk=rsrc_free
STOP -1
END SUB

'[*END OF FILE*]
