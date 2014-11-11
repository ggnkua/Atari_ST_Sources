'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB print_registration
SHARED total_order,orderform$()
STATIC handle,myfile,i,lpp

MOUSE 2
CALL generate_summary
SelectTree FORM_MAIN
IF getobj_shortcut(PRINT_ASCII)=12 THEN
	IF FEXISTS(CURDIR$+"\ORDER_FM.TXT") THEN
		IF FEXISTS(CURDIR$+"\ORDER_FM.BAK") THEN junk=DeleteFile (CURDIR$+"\ORDER_FM.BAK")
		junk=RenameFile (CURDIR$+"\ORDER_FM.TXT",CURDIR$+"\ORDER_FM.BAK")
	END IF
	handle=fcreate(CURDIR$+"\ORDER_FM.TXT",2)
	IF handle<0 THEN
		GOTO ERROR_HANDLER
	ELSE
		junk=fclose(handle)
		myfile=FREEFILE
		OPEN CURDIR$+"\ORDER_FM.TXT" FOR OUTPUT AS #myfile
			FOR i=0 TO total_order
				PRINT #myfile,orderform$(i)
			NEXT i
		CLOSE #myfile
	END IF
ELSE
	lpp=0
	FOR i=0 TO total_order
		IF ONLINE THEN 
			LPRINT orderform$(i)
			INCR lpp
			IF lpp>=VAL(getobj_text$(PRINT_LPP)) THEN LPRINT CHR$(12)
		ELSE
			MOUSE 0 : EXIT SUB
		END IF
	NEXT i
	IF getobj_shortcut(PRINT_FF)=14 THEN LPRINT CHR$(12)
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
