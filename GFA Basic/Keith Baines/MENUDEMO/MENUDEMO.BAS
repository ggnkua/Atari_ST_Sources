'
' Demo of disabling menu items when top window does not belong to program
' for Ictari, by Keith Baines, January 1995
'
' Compile with HiSoft Basic 2.10 or after
'

REM $OPTION Y+,K20
DEFINT A-Z
LIBRARY "GEMVDI","GEMAES"

REM $INCLUDE MENUDEMO.BH

COMMON SHARED dummy
CONST TRUE=-1
CONST FALSE=0

CALL Main
STOP -1

SUB main
	SHARED OurWindow,TheMenu&
	LOCAL e,m,s,msgbuf(7)

	IF rsrc_load("MENUDEMO.RSC")=0 THEN
		dummy=form_alert(1,"[2][ Can't load resource file ][OK]")
		EXIT SUB
	END IF

	initialise

	DO
		e=evnt_multi(16+32,0,0,0, 0,0,0,0,0, 0,0,0,0,0, VARPTR(msgbuf(0)), _
										20, 0,0,0,0,0,0)
		IF e=32 THEN
			check_top_window
		ELSEIF (e AND 16) THEN
			m=msgbuf(0)
			SELECT CASE m
				CASE 10	' menu selected
					s=msgbuf(4)
					SELECT CASE s
						CASE MenuAbout
							dummy=form_alert(1,"[0][ Demo for Ictari  | by Keith Baines  | January 1995  ][OK]")
						CASE MenuQuit
							EXIT LOOP
						CASE MenuTest
							dummy=form_alert(1,"[0][ This menu item is only| available when the window  | is on top.][OK]")
					END SELECT
					menu_tnormal TheMenu&,msgbuf(3),1

				CASE 20	' redraw window
					redraw msgbuf(3),msgbuf(4),msgbuf(5),msgbuf(6),msgbuf(7)
				
				CASE 21	' window topped
					dummy=wind_set(msgbuf(3),10,0,0,0,0)
				
				CASE 30	' window untopped (AES 4)
					check_top_window

				CASE 31 ' window on top (AES 4)
					check_top_window

			END SELECT

		END IF

	LOOP	' Stay in loop until Quit menu item is selected.
	
	dummy=wind_close(OurWindow)
	dummy=wind_delete(OurWindow)

	menu_bar TheMenu&,0
	
END SUB


SUB initialise
	SHARED OurWindow,TheMenu&,OnTop
	LOCAL x,y,w,h,WinName&

	dummy=rsrc_gaddr(0,TheMenu,TheMenu&)
	menu_bar TheMenu&,1

	dummy=wind_get(0,4,x,y,w,h)
	OurWindow=wind_create(1,x,y,w,h)
	IF OurWindow<0 THEN
		dummy=form_alert(1,"[2][ Can't create window ][OK]")
		EXIT SUB
	END IF
	
	dummy=rsrc_gaddr(5,WindowName,WinName&)
	dummy=wind_set(OurWindow,2,PEEKW(VARPTR(WinName&)),PEEKW(VARPTR(WinName&)+2),0,0)

	dummy=wind_open(OurWindow,x+w\4,y+h\4,w\2,h\2)
	
	OnTop=TRUE
END SUB


SUB redraw(hand,rx,ry,rw,rh)
	SHARED OurWindow
	LOCAL wx,wy,ww,wh,x,y,w,h

	IF hand<>OurWindow THEN EXIT SUB

	dummy=wind_update(1)
	graf_mouse 256,0
	dummy=wind_get(OurWindow,11,wx,wy,ww,wh)
	DO WHILE ww>0 OR wh>0
		intersection rx,ry,rw,rh,wx,wy,ww,wh,x,y,w,h
		IF w>0 AND h>0 THEN
			vr_recfl x,y,x+w-1,y+h-1
		END IF
		dummy=wind_get(OurWindow,12,wx,wy,ww,wh)
	LOOP
	graf_mouse 257,0
	dummy=wind_update(0)
END SUB


SUB check_top_window
	SHARED OurWindow,TheMenu&,OnTop
	LOCAL top_win

	dummy=wind_get(OurWindow,10,top_win,0,0,0)

	IF top_win=OurWindow THEN
		IF NOT OnTop THEN
			enable TheMenu&,MenuTest
			OnTop=TRUE
		END IF
	ELSE
		IF OnTop THEN
			disable TheMenu&,MenuTest
			OnTop=FALSE
		END IF
	END IF
END SUB

SUB enable(BYVAL M&,BYVAL S)
	LOCAL A&

	A&=M&+24*S+10
	dummy=wind_update(1)	' make sure menu is NOT displayed when we change it
	POKEW A&,PEEKW(A&) AND (NOT 8)
	dummy=wind_update(0)
END SUB

SUB disable(BYVAL M&,BYVAL S)
	LOCAL A&

	A&=M&+24*S+10
	dummy=wind_update(1)	' make sure menu is NOT displayed when we change it
	POKEW A&,PEEKW(A&) OR 8
	dummy=wind_update(0)
END SUB

