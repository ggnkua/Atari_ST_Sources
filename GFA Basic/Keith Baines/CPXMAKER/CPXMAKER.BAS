'
' Program to build CPX using control file
'

' 5 September 1994

DEFINT A-Z

CONST MAGIC=100

COMMON SHARED FileName$
COMMON SHARED CPXFile$,IconFile$

COMMON SHARED flags,id$,version!
COMMON SHARED itext$,icolour
COMMON SHARED title$,tcolour

DIM SHARED icon&(23)

Banner

IF COMMAND$="" THEN
	ermsg "This program needs a file name on its command line"
ELSE
	main COMMAND$
END IF
STOP


FUNCTION pad$(BYVAL S$,BYVAL L)
	pad$=LEFT$(S$+STRING$(L,0),L)
END FUNCTION

FUNCTION StripType$(BYVAL f$)
	LOCAL d,s
	d=RINSTR(f$,".")
	s=MAX(RINSTR(f$,"\"),RINSTR(f$,":"))
	IF d>s THEN
		striptype$=LEFT$(f$,d-1)
	ELSE
		striptype$=f$
	END IF
END FUNCTION

FUNCTION StripPath$(BYVAL f$)
	LOCAL s
	s=MAX(RINSTR(f$,"\"),RINSTR(f$,":"))
	IF s>0 THEN
		StripPath$=MID$(f$,s+1)
	ELSE
		StripPath$=f$
	END IF
END FUNCTION



SUB main(BYVAL F$)
	LOCAL L$,n

'
' Set up file name
'
	FileName$=StripType$(F$)

	IF NOT FEXISTS(FileName$+".MCP") THEN
		Ermsg "File "+FileName$+".MCP Not Found"
		EXIT SUB
	END IF

	initialise

	process

	IF IconFile$<>"" THEN
		GetIcon
	END IF

	makecpx
	
END SUB


SUB ermsg(BYVAL m$)
	PRINT " Error: ";m$
END SUB


'
' Set default values
'
SUB initialise
	LOCAL f$,i

	CPXFile$=FileName$
	IconFile$="CPXMAKER.RSC"
	f$=StripPath$(FileName$)

	flags=0
	id$=LEFT$(f$,4)
	version!=1.00
	itext$=LEFT$(f$,13)
	FOR i=0 TO 23 : icon&(i)=0 : NEXT i
	icolour=1
	title$=LEFT$(f$,17)
	tcolour=1
END SUB

'
' Process control file
'
SUB process

	LOCAL L$,k$,v$,n
	OPEN FileName$+".MCP" FOR INPUT AS #1

	PRINT
	PRINT " Reading CPX make file "+FileName$+".MCP"
	PRINT

	DO UNTIL EOF(1)
		LINE INPUT #1,L$
		L$=LTRIM$(L$)
		IF L$<>"" THEN
			IF LEFT$(L$,1)<>"*" THEN
				n=INSTR(L$,"=")
				IF n>0 THEN
					k$=LTRIM$(RTRIM$(UCASE$(LEFT$(L$,n-1))))
					v$=LTRIM$(MID$(L$,n+1))
					SELECT CASE k$
						CASE "CPXFILE" : CPXFile$=StripType$(RTRIM$(UCASE$(v$)))
						CASE "ID" : id$=LEFT$(v$,4)
						CASE "VERSION" : version!=VAL(v$)
						CASE "ICONNAME" : itext$=LEFT$(v$,13)
						CASE "ICONFILE" : IconFile$=RTRIM$(UCASE$(v$))
						CASE "ICONCOLOUR" : icolour=VAL(v$) AND 15
						CASE "TITLE" : title$=LEFT$(v$,17)
						CASE "TITLECOLOUR" : tcolour=VAL(v$) AND 15
						CASE ELSE : ermsg "Unknown keyword: "+k$+"="
					END SELECT
				ELSE
					k$=LTRIM$(RTRIM$(L$))
					SELECT CASE k$
						CASE "SETONLY" : flags=flags OR 1
						CASE "BOOTINIT" : flags=flags OR 2
						CASE "RESIDENT" : flags=flags OR 4
						CASE ELSE : ermsg "Unknown keyword: "+k$
					END SELECT
				END IF
			END IF
		END IF
	LOOP
	CLOSE #1
END SUB

'
' Read Icon from first free image in RSC file
'
SUB GetIcon
	LOCAL n,b$,i
	LOCAL fi,ni,bblk&,bitmap&,bw,bh

	IF NOT FEXISTS(IconFile$) THEN
		ermsg "Icon file "+IconFile$+" not found"
		EXIT SUB
	END IF
	
	OPEN IconFile$ FOR INPUT AS #1
	n=LOF(1)
	b$=INPUT$(n,#1)
	CLOSE #1

	IF n<36 THEN GOTO badfile
	
	fi=CVI(MID$(b$,17,2))
	ni=CVI(MID$(b$,33,2))

	IF ni<1 THEN
		ermsg "No image in file "+IconFile$
		EXIT SUB
	END IF
	
	IF n<fi+4 THEN GOTO badfile
	bblk&=CVL(MID$(b$,1+fi,4))

	IF n<bblk&+14 THEN GOTO badfile
	bitmap&=CVL(MID$(b$,1+bblk&,4))
	bw=CVI(MID$(b$,5+bblk&,2))
	bh=CVI(MID$(b$,7+bblk&,2))

	IF bw<>4 OR bh<>24 THEN
		ermsg "Image wrong size - must by 32 wide by 24 high"
		EXIT SUB
	END IF
	
	IF n<bitmap&+96 THEN GOTO badfile
	FOR i=0 TO 23
		icon&(i)=CVL(MID$(b$,1+bitmap&+4*i,4))
	NEXT i

	EXIT SUB

badfile:
	ermsg "Invalid file "+IconFile$
	EXIT SUB
END SUB


'
' Write the CPX
'
SUB makecpx
	LOCAL v1,v2,i,b$,f$,n

'
' Check program file exists
'
	f$=CPXFILE$+".CP"
	IF NOT FEXISTS(f$) THEN f$=CPXFILE$+".TOS"
	IF NOT FEXISTS(f$) THEN f$=CPXFILE$+".TTP"
	IF NOT FEXISTS(f$) THEN f$=CPXFILE$+".PRG"
	IF NOT FEXISTS(f$) THEN	f$=CPXFILE$+".APP"
	IF NOT FEXISTS(f$) THEN
		ermsg "File "+CPXFILE$+".CP not found"
		EXIT SUB
	END IF

'
' Report header info
'
	PRINT " Flags",": ";
	IF flags AND 4 THEN PRINT "R"; ELSE PRINT "-";
	IF flags AND 2 THEN PRINT "B"; ELSE PRINT "-";
	IF flags AND 1 THEN PRINT "S"  ELSE PRINT "-"
	PRINT " ID",": '";LEFT$(id$,4);"' = 0x";HEX$(CVL(pad$(id$,4)));
	PRINT " =";CVL(pad$(id$,4))
	PRINT " Version",": ";LTRIM$(FORMATS$(version!,"###.##"))
	PRINT " Icon Text",": ";LEFT$(itext$,13)
	PRINT " Icon Colour",":";icolour
	PRINT " Title",": ";LEFT$(title$,17)
	PRINT " Title Colour",":";tcolour
	PRINT
	PRINT " Icon from",": ";IconFile$
	PRINT " Code from",": ";f$
	PRINT
	PRINT " Making",": ";CPXFILE$+".CPX"
	PRINT
	
'
' Write CPX Header
'
	OPEN CPXFile$+".CPX" FOR OUTPUT AS #2
	PRINT #2,MKI$(MAGIC);MKI$(flags);pad$(id$,4);
	v1=CINT(INT(version!))<<8
	v2=CINT(100*(version!-INT(version!)))
	PRINT #2,MKI$(v1 OR v2);
	PRINT #2,pad$(itext$,13)+CHR$(0);
	FOR i=0 TO 23 : PRINT #2,MKL$(icon&(i)); : NEXT i
	PRINT #2,MKI$(icolour<<12);
	PRINT #2,pad$(title$,17)+CHR$(0);
	PRINT #2,MKI$((tcolour<<8) OR &H1080);
	PRINT #2,STRING$(64,0);
	PRINT #2,STRING$(306,0);

'
' Append program file
'
	OPEN f$ FOR INPUT AS #1
	n=LOF(1)
	b$=INPUT$(n,#1)
	PRINT #2,b$;
	
	PRINT
	PRINT LOF(2) "bytes written to output file."

	CLOSE #1,2

END SUB

SUB Banner
	PRINT
	PRINT " === CPX Make Utility Version 0.00 by Keith Baines, September 1994 === "
	PRINT
END SUB
