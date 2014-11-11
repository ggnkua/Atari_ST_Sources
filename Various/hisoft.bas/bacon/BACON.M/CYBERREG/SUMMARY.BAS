'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB generate_summary
SHARED CommonIndex,summary_handle,woTIndex(),WindTLines$(),software_handle,woTLines()
SHARED total_order,total_cost,OS_OTHER$,EMULATION_OTHER$,itemfee$(),orderform$()
SHARED whichcountry$,selected_items
STATIC i,dummy,dummy_computer,dummy_os,file,dummy$,temp$,total_fee,total_pp
STATIC total_shareware

SelectTree FORM_MAIN
i=0 : dummy_computer=0 : dummy_os=0
orderform$(i)="                CyberSTrider Atari Products Order Form"
INCR i : orderform$(i)="======================================================================"
INCR i : orderform$(i)="Address  : CyberSTrider: PO Box 2023, Wickford SS12 9RX, UK"
INCR i : orderform$(i)="Email    : dbhabuta@cix.compulink.co.uk ; denesh@cyberstrider.org"
INCR i : orderform$(i)="WWW      : http://www.cyberstrider.org/"
INCR i : orderform$(i)="FAX      : +44 (0)171-681-1307"
INCR i : orderform$(i)="======================================================================"
INCR i : orderform$(i)="Your personal details"
INCR i : orderform$(i)="----------------------------------------------------------------------"
INCR i : orderform$(i)="Name     : "+getobj_text$(DET_NAME)
INCR i : orderform$(i)="Street   : "+getobj_text$(DET_STREET)
INCR i : orderform$(i)="Town     : "+getobj_text$(DET_TOWN)
INCR i : orderform$(i)="Postcode : "+getobj_text$(DET_POSTCODE)
INCR i : orderform$(i)="Country  : "++LTRIM$(getobj_text$(DET_COUNTRY))
INCR i : orderform$(i)="Phone    : "+getobj_text$(DET_PHONE)
INCR i : orderform$(i)="Email    : "+getobj_text$(DET_EMAIL)
INCR i : orderform$(i)=""
INCR i : orderform$(i)="System"
INCR i : orderform$(i)="----------------------------------------------------------------------"

SelectTree FORM_POPUPS
dummy=pop_computer
DO
	IF enquire_state(dummy,mask_checked) THEN
		INCR dummy_computer
		IF dummy_computer=1 THEN
			INCR i : orderform$(i)="Computer : "+LTRIM$(getobj_text$(dummy))
		ELSE
			INCR i : orderform$(i)="           "+LTRIM$(getobj_text$(dummy))
		END IF
	END IF
	IF NOT getobj_child(pop_computer,dummy) THEN EXIT LOOP
	IF enquire_flags(dummy,mask_lastob) THEN EXIT LOOP
	INCR dummy
LOOP

dummy=pop_os
DO
	IF enquire_state(dummy,mask_checked) THEN
		INCR dummy_os
		IF LTRIM$(getobj_text$(dummy))="Other" THEN
			IF dummy_os=1 THEN
				INCR i : orderform$(i)="OS       : "+OS_OTHER$
			ELSE
				INCR i : orderform$(i)="           "+OS_OTHER$
			END IF
		ELSE
			IF dummy_os=1 THEN
				INCR i : orderform$(i)="OS       : "+LTRIM$(getobj_text$(dummy))
			ELSE
				INCR i : orderform$(i)="           "+LTRIM$(getobj_text$(dummy))
			END IF
		END IF
	END IF
	IF NOT getobj_child(pop_os,dummy) THEN EXIT LOOP
	IF enquire_flags(dummy,mask_lastob) THEN EXIT LOOP
	INCR dummy
LOOP
SelectTree FORM_MAIN
IF NOT enquire_state(DET_EMULATION,mask_disabled) THEN
	IF LTRIM$(getobj_text$(DET_EMULATION))="Other" THEN
		INCR i : orderform$(i)="Emulation: "+EMULATION_OTHER$
	ELSE
		INCR i : orderform$(i)="Emulation: "+LTRIM$(getobj_text$(DET_EMULATION))
	END IF
END IF
INCR i : orderform$(i)="Drive    : "+LTRIM$(getobj_text$(DET_DRIVE))
INCR i : orderform$(i)=""
INCR i : orderform$(i)="Other...."
INCR i : orderform$(i)="----------------------------------------------------------------------"
IF getobj_shortcut(OTHER_REQUIRED)=12 THEN
 	INCR i : orderform$(i)="[*] Masterdisk(s) NOT required"
	IF getobj_shortcut(OTHER_FVERSION)=14 THEN INCR i : orderform$(i)="[*] Email full version (UUE/MIME)"
	IF getobj_shortcut(OTHER_MAIL)=14 THEN INCR i : orderform$(i)="[*] Email/snail mail registration"
ELSE
	INCR i : orderform$(i)="[*] Masterdisk(s) required"
END IF
INCR i : orderform$(i)=""
INCR i : orderform$(i)="Products required"
INCR i : orderform$(i)="----------------------------------------------------------------------"
INCR i : orderform$(i)="Software                                  Reg. Fee (Sterling) |  P&P"
INCR i : orderform$(i)="----------------------------------------------------------------------"

total_fee=0 : total_pp=0 : total_shareware=0
IF selected_items>0 THEN
CommonIndex=WhichWindow(software_handle) : file=woTindex(CommonIndex)
FOR dummy=0 TO woTLines(file)
	IF itemfee$(dummy)<>"" THEN
		dummy$=MID$(WindTLines$(file,dummy),37,3)
		IF dummy$<>"-C-" THEN INCR total_shareware
	END IF
NEXT

FOR dummy=0 TO woTLines(file)
	IF itemfee$(dummy)<>"" THEN
		dummy$=MID$(WindTLines$(file,dummy),10,20)
		CALL padoutstring (dummy$,42)
		temp$=itemfee$(dummy)
		CALL padoutstring (temp$,19)
		total_fee=total_fee+VAL(itemfee$(dummy))

	IF getobj_shortcut(OTHER_REQUIRED)=12 THEN
		INCR i : orderform$(i)=dummy$+""+temp$+"| 0.00"
	ELSE
		SELECT CASE whichcountry$
		CASE "Europe","ROW"
			SELECT CASE total_shareware
			CASE 1
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),106,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),106,6))
			CASE 2 TO 4
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),112,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),112,6))
			CASE >=5
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),121,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),121,6))
			END SELECT
		CASE ELSE
			SELECT CASE total_shareware
			CASE 1
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),82,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),82,6))
			CASE 2 TO 4
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),88,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),88,6))
			CASE >=5
				INCR i : orderform$(i)=dummy$+""+temp$+"| "+MID$(WindTLines$(file,dummy),97,6)
				total_pp=total_pp+VAL(MID$(WindTLines$(file,dummy),97,6))
			END SELECT
		END SELECT		
	END IF
	END IF
NEXT
END IF
INCR i : orderform$(i)="----------------------------------------------------------------------"
IF getobj_shortcut(OTHER_REQUIRED)<>12 THEN
	INCR i : orderform$(i)="NB: P&P is only applicable if 'Masterdisk(s) required'"
END IF
INCR i : orderform$(i)=""
total_cost=total_fee+total_pp
INCR i : orderform$(i)="                                              Total (inc. P&P):"+STR$(total_cost)+".00"
INCR i : orderform$(i)=""
INCR i : orderform$(i)="======================================================================"
INCR i : orderform$(i)="These details will be kept electronically. Your entry is available for"
INCR i : orderform$(i)="inspection on request under provisions of the UK Data Protection Act."
INCR i : orderform$(i)="======================================================================"
INCR i : orderform$(i)="Produced using CyberReg, Copyright 1998-9 Matthew Bacon & CyberSTrider"
INCR i : orderform$(i)=""
total_order=i
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB summary
SHARED HowManyTextWindows,WindTLines$(),woTLines(),woHandle(),woTindex()
SHARED CommonIndex,total_order,summary_handle,orderform$()
STATIC dummy,file

CALL generate_summary
IF summary_handle<>0 THEN
	CommonIndex=WhichWindow(summary_handle) : file=woTindex(CommonIndex)
	FOR dummy=0 TO total_order
		WindTLines$(file,dummy)=orderform$(dummy)
	NEXT
	woTLines(file)=total_order+1
	TopAWindow summary_handle
	CALL FullRedraw (summary_handle)
ELSE
	IF TextWindowSystem=0 THEN InitTextSystem 2,200
	FOR dummy=0 TO total_order
		WindTLines$(HowManyTextWindows,dummy)=orderform$(dummy)
	NEXT
	woTLines(HowManyTextWindows)=total_order+1
	summary_handle=OpenTextWindow(MyProgram$+" : Summary",win_all-win_info)
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
