LIBRARY "gemaes","gemdos","mint"
DEFINT a-z
REM $option y

DECLARE FUNCTION alert(BYVAL b%,BYVAL s&)

ch=rsrc_load("LAUNCHQU.RSC")

remove%=0
IF ch=1 THEN
	j=rsrc_gaddr(0,0,addr&)
	IF j=1 THEN
		form_center addr&,x,y,w,h
		form_dial 0,0,0,0,0,x,y,w,h
		form_dial 1,0,0,0,0,x,y,w,h
		j=objc_draw(addr&,0,&H7FFF,x,y,w,h)
		remove%=1
	END IF
END IF

	REM Find needed files
	abort%=0
	tail$="BANNERS.BNR"
	j=shel_find(tail$)
	IF j=0 THEN j=form_alert(1,"[3][BANNERS.BNR][Cancel]") : abort%=1
	path$="QUOTEOTD.TTP"
	j=shel_find(path$)
	IF j=0 THEN j=form_alert(1,"[3][QUOTEOTD.TTP][Cancel]") : abort%=1

IF remove%=1 THEN
	form_dial 2,0,0,0,0,x,y,w,h
	form_dial 3,0,0,0,0,x,y,w,h
END IF

IF abort%=1 THEN
	IF ch>0 THEN j=rsrc_free
	SYSTEM
END IF

handle=fopen("U:\PIPE\FORTUNE",2)
IF handle<0 THEN
	remove%=0
	IF ch=1 THEN
		j=rsrc_gaddr(0,1,addr&)
		IF j=1 THEN
			form_center addr&,x,y,w,h
			form_dial 0,0,0,0,0,x,y,w,h
			form_dial 1,0,0,0,0,x,y,w,h
			j=objc_draw(addr&,0,&H7FFF,x,y,w,h)
			remove%=1
		END IF
	END IF
	r&=Pexec&(100,path$,tail$,"")
	REM using pexec so that GEMAES does not know directly that a program has been run.
	REM so that, gemaes does not register the presence of the program that is intended as a background task.
	IF r&<0 THEN j=form_error((0-r&)-31) : REM display error if program is not run.
	IF remove%=1 THEN
		form_dial 2,0,0,0,0,x,y,w,h
		form_dial 3,0,0,0,0,x,y,w,h
	END IF
ELSE
	j=rsrc_gaddr(5,0,addr&)
	IF j=1 THEN
		choice=alert(1,addr&)
		SELECT CASE choice
		CASE 2
			a$="?"
			j&=fwrite&(handle,LEN(a$),VARPTR(a$))
			j&=fread&(handle,LEN(a$),VARPTR(a$))
			p$=SPACE$(ASC(a$))
			j&=fread&(handle,LEN(p$),VARPTR(p$))
			IF GETCOOKIE("MiNT",j&) THEN
				salert SADD(p$+CHR$(0))
			ELSE
				j=form_alert(1,"[1][A quote for you:|"+p$+"][ok]")
			END IF
		CASE 3
			a$=CHR$(3)
			REM send it a [control]C, causes quoteserver to quit
			j&=fwrite&(handle,LEN(a$),VARPTR(a$))
		END SELECT
	END IF
	j=fclose(handle)
END IF


REM If loaded a resource then free it.

IF ch>0 THEN j=rsrc_free

SYSTEM

FUNCTION alert(BYVAL b%,BYVAL s&)
POKEW	PEEKL(GB+8),b%
POKEL PEEKL(GB+16),s&
GEMSYS(52)
alert=PEEKW(PEEKL(GB+12))
END FUNCTION

