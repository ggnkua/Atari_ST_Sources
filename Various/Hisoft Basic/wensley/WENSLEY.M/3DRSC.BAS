
REM $option y
LIBRARY "gemaes","gemdos","mint"
DEFINT a-z
REM $include gemaes.bh
REM $include rs_const.bh

DIM SHARED debug
DIM SHARED force
DIM SHARED nobar3d
force=0
debug=0
nobar3d=0

p$=COMMAND$
IF p$<>"" THEN
	DO
	e=INSTR(p$," ")
	IF e>0 THEN name$=LEFT$(p$,e-1) : p$=RIGHT$(p$,LEN(p$)-e) ELSE name$=p$
		SELECT CASE name$
		CASE "-?"
			IF GETCOOKIE("MiNT",j&) THEN
				a$="3DRSC is for setting the 3D object controls in the .RSC files of older GEM programs so that they use the newer AES 3D objects (The operating system did not do this by default!)"+CHR$(0)
				salert SADD(a$)
				ELSE
				j=form_alert(1,"[4][3DRSC:|For setting the|object 3D controls in the .RSC|files of old GEM programs for|the newer AES 3D appearance!][OK]")
			END IF
		CASE "-F"
			force=1
		CASE "-D"
			debug=1
			WINDOW OPEN 2,"3D Resource",PEEKW(SYSTAB+58),PEEKW(SYSTAB+60),PEEKW(SYSTAB+62),PEEKW(SYSTAB=+64),1
		CASE "-O"
			nobar3d=1
		CASE ELSE
			IF RIGHT$(name$,4)=".RSC" THEN rsc3d name$
		END SELECT
	LOOP UNTIL e=0
	SYSTEM
END IF


fspath$=CURDIR$+"\*.RSC"
fsname$=""

DO
IF PEEKW(PEEKL(GB+4))<&H130 THEN
	fsel_input fspath$,fsname$,ok
ELSE
	fsel_exinput fspath$,fsname$,ok,"Choose a resource file..."
END IF
IF ok THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	rsc3d LEFT$(fspath$,i)+fsname$
END IF
LOOP UNTIL ok=0
SYSTEM

SUB rsc3d(BYVAL name$)
LOCAL handle,j,size&,j&,addr&,rsc&,trees&,ntree&,ctree&,pointer&,cobject&,type
LOCAL spec&,col%,already3d,remaintree&,lookob&,treepointer&,pmenu,temp

handle=fopen(name$,2)
IF handle<0 THEN j=form_error((0-handle)-31) : EXIT SUB

size&=fseek&(0,handle,2)
j&=fseek&(0,handle,0)

addr&=malloc&(size&)
IF addr&=0 THEN j=form_error(8) : j=fclose(handle) : EXIT SUB

j&=fread&(handle,size&,addr&)
IF j&<0 THEN j=form_error((0-j&)-31) : j=mfree(addr&) : j=fclose(handle) : EXIT SUB

rsc&=addr& ' future expansion?

trees&=PEEKW(rsc&+rsh_object)+rsc&
ntree&=PEEKW(rsc&+rsh_numbertrees)

REM scan rsc to ensure that it's not already 3D?

already3d=0
remaintree&=ntree&
pointer&=trees&
DO UNTIL remaintree&=0
	REM is this object 3d?
	IF (PEEKW(pointer&+ob_flags) AND mask_3d)>0 THEN already3d=1
	REM is this the last object in the current tree?
	IF PEEKW(pointer&+ob_flags) AND mask_lastob THEN DECR remaintree&
	pointer&=pointer&+ob_sizeof
LOOP

REM we deliberately do not convert resource files that are?
REM already 3d because the selction process used to choose 3D?
REM object flags was general-purpose i.e program guidelines?
REM and may not match those of a specialised program that needs?
REM to have it's .RSC 3d flags set to something other than?
REM the recommendations of the specification?

REM unless, the force option is used?

IF force=1 THEN already3d=0 : j=form_alert(1,"[4][Forced][ok]")

REM IF already3d=1 THEN j=form_alert(1,"[4][Already 3d!][ok]")

IF already3d=0 THEN

IF debug THEN PRINT ntree&,"trees in rsc"
ctree&=0
pointer&=trees&
DO
	IF debug THEN PRINT "---> Begin tree"+STR$(ctree&)
	cobject&=0
	REM Check to see if the current tree is a menu:?
	REM menus contained G_TITLE objects?
	REM ---------> Check?
		lookob&=0 : treepointer&=pointer& : pmenu=0
		DO UNTIL PEEKW(treepointer&+ob_sizeof*lookob&+ob_flags) AND mask_lastob
		IF (PEEKW(treepointer&+ob_sizeof*lookob&+ob_type) AND &HFF)=G_TITLE THEN pmenu=1 : EXIT LOOP : REM need not check further?
		INCR lookob&
		LOOP
	REM <--------- End check?
	' j=form_alert(1,"[4][3DRSC:|Tree"+STR$(ctree&)+"contains if"+STR$(pmenu)+"G_TITLE][OK]")
	REM pmenu=1 activate special conversions for menus?
	REM Some other forms may also contain G_TITLEs but the conversions?
	REM would hopefully be harmless to them!?

	DO
	IF debug THEN PRINT "Object",cobject&,"is a ";
	type=PEEKW(pointer&+ob_type) AND &HFF
	spec&=pointer&+ob_spec :	IF PEEKW(pointer&+ob_flags) AND mask_indirect THEN spec&=rsc&+PEEKL(spec&) : 'PRINT "**" j=form_alert(1,"[4][Indirect][ok]")

		REM Object colour corrections for 3D?
	SELECT CASE type
	CASE G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT
		IF (PEEKL(spec&)+te_color)<size& THEN
			col%=PEEKB(rsc&+PEEKL(spec&)+te_color+1)
			REM 11111111?
			REM	||||----- fill colour?
			REM |-------- fill pattern?
			REM --------- 1- opaque 0 transparent?
			REM for 3D, if fill=0 then colour=0?
			IF (col% AND &B1110000)=0 THEN col%=(col% AND &B10000000)
			IF cobject&=0 THEN col%=(col% AND &B10000000)
			POKEB rsc&+PEEKL(spec&)+te_color+1,col%
		ELSE
			IF debug THEN PRINT "Pointer outside resource!!"
		END IF
		REM these control what type of 3d object is set? ascending priority?
		IF (PEEKW(pointer&+ob_flags) AND (mask_selectable+mask_default+mask_exit+mask_touchexit+mask_rbutton))=mask_none THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dback
		IF PEEKW(pointer&+ob_flags) AND mask_selectable THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind
		IF PEEKW(pointer&+ob_flags) AND mask_exit THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dact
		IF PEEKW(pointer&+ob_flags) AND mask_rbutton THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind
	CASE G_STRING,G_BUTTON,G_TITLE
		REM these control what type of 3d object is set? ascending priority?
		IF (PEEKW(pointer&+ob_flags) AND (mask_selectable+mask_default+mask_exit+mask_touchexit+mask_rbutton))=mask_none THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dback
		IF PEEKW(pointer&+ob_flags) AND mask_selectable THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind
		IF PEEKW(pointer&+ob_flags) AND mask_touchexit THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dact
		IF PEEKW(pointer&+ob_flags) AND mask_exit THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dact
		IF PEEKW(pointer&+ob_flags) AND mask_rbutton THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind
		REM adjustment for strings in menus to prevent possible visual object overlap?
		IF pmenu=1 AND (type=G_STRING) THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dback
		IF pmenu AND nobar3d AND (type=G_TITLE) THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))
	CASE G_BOX,G_IBOX,G_BOXCHAR
		col%=PEEKB(spec&+3)
		REM bbbbtttt11111111?
		REM	bor tex ||||----- fill colour?
		REM der tco |-------- fill pattern?
		REM col lour--------- 1- opaque 0 transparent?
		REM for 3D, if fill=0 then colour=0?

		IF (col% AND &B1110000)=0 THEN col%=(col% AND &B10000000)
		IF cobject&=0 THEN col%=(col% AND &B10000000)
		POKEB spec&+3,col%
		REM these control what type of 3d object is set? ascending priority?
		IF (PEEKW(pointer&+ob_flags) AND (mask_selectable+mask_default+mask_exit+mask_touchexit+mask_rbutton))=mask_none THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dback
		IF (PEEKW(pointer&+ob_flags) AND mask_3d)=fl3dback THEN
			REM A fun change for menus? - make border dark grey when no outline or shadow?
			IF (pmenu=1) AND ((PEEKW(pointer&+ob_state) AND (mask_outlined+mask_shadowed))=0) AND ((PEEKB(spec&+2) AND &HF0)=16) THEN POKEB spec&+2,&B10010000+(PEEKB(spec&+2) AND &B1111)
			'PRINT NOT(PEEKW(pointer&+ob_state) AND (mask_outlined+mask_shadowed)),(PEEKB(spec&+2) AND &HF0)
		END IF
		IF PEEKW(pointer&+ob_flags) AND mask_selectable THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind
		IF (PEEKW(pointer&+ob_flags) AND mask_touchexit) AND (cobject&<>0) THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dact
		IF PEEKW(pointer&+ob_flags) AND mask_exit THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dact
		IF PEEKW(pointer&+ob_flags) AND mask_rbutton THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))+fl3dind

		IF pmenu AND nobar3d THEN
			temp=PEEKW(treepointer&+ob_head)
		IF temp=cobject& THEN POKEW pointer&+ob_flags,(PEEKW(pointer&+ob_flags) AND NOT(mask_3d))
		END IF
	CASE G_IMAGE
	CASE G_ICON
	CASE G_PROGDEF
	CASE ELSE
	END SELECT

	IF debug THEN PRINT "type="+STR$(type);
	IF debug THEN
		IF PEEKW(pointer&+ob_flags) AND mask_3d THEN PRINT " the object=3d"
	END IF

	pointer&=pointer&+ob_sizeof
	INCR cobject&
	LOOP UNTIL PEEKW((pointer&+ob_flags)-ob_sizeof) AND mask_lastob
	INCR ctree&
LOOP UNTIL ctree&=ntree&
code fseek&(0,handle,0)
code fwrite&(handle,size&,addr&)
END IF

j=fclose(handle)
j=mfree(addr&)
END SUB

SUB code(BYVAL j&)
LOCAL j
IF j&<0 THEN j=form_error((0-j&)-31)
END SUB
