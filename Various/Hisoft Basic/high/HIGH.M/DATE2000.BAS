LIBRARY "gemdos"
DEFINT a-z
DIM SHARED stamp(1)
REM $OPTION B-,Y+,N-,E-

'	Remember to rename the programme to Date2000.PRG
'	after compliation, when used from the Auto folder.

'Date Functions using the GEMDOS Date Stamp
'==========================================

FUNCTION getdd%(BYVAL datestamp%)
STATIC v&
	v& = CLNG(datestamp%)
	IF v& < 0 THEN v& = V& + 65536
	getdd% = CINT(v& MOD 32)
END FUNCTION

FUNCTION getmm%(BYVAL datestamp%)
STATIC v&
	v& = CLNG(datestamp%)
	IF v& < 0 THEN v& = V& + 65536
	getmm% = CINT((v& \ 32) MOD 16)
END FUNCTION

FUNCTION getyyyy%(BYVAL datestamp%)
STATIC v&
	v& = CLNG(datestamp%)
	IF v& < 0 THEN v& = V& + 65536
	getyyyy% = CINT((v& \ 512) + 1980)
END FUNCTION

FUNCTION setdatestamp%(BYVAL day%, BYVAL mon%, BYVAL year%)
IF year% < 1980 OR year% > 2107 OR mon% < 1 OR mon% > 12 _
	OR day% <1 OR day% >31 _
	OR (day% > 30 AND (mon% = 9 OR mon% = 4 OR mon% = 6 OR mon% = 11)) _
	OR (day% > 29 AND mon% = 2) _
	OR (day% > 28 AND mon% = 2 AND year% MOD 4 > 0) THEN
	setdatestamp% = 0
ELSEIF year < 2044 THEN
	setdatestamp% = day%  + (mon% * 32) + ((year% - 1980)* 512)
ELSE
	setdatestamp% = CINT(day +(mon *32) + ((CLNG(year)-1980)*512) - 65536)
END IF
END FUNCTION	'Returns zero for error or date < 1/1/1980 or > 31/12/2107

FUNCTION weekday%(BYVAL day%, BYVAL mon%, BYVAL year%)
IF year% < 1980 OR year% > 2107 OR mon% < 1 OR mon% > 12 _
	OR day% <1 OR day% >31 _
	OR (day% > 30 AND (mon% = 9 OR mon% = 4 OR mon% = 6 OR mon% = 11)) _
	OR (day% > 29 AND mon% = 2) _
	OR (day% > 28 AND mon% = 2 AND year% MOD 4 > 0) THEN
	weekday% = 0
ELSE
	IF mon% < 3 THEN
		mon% = mon% + 12
		year% = year% - 1
	END IF
	weekday% = ((day% + INT(2.6 * (mon% + 1)) + INT(1.25 * year%) _
		 - INT(year%/100) + INT(year%/400) -1) MOD 7) + 1
END IF
END FUNCTION	'Returns 0 for error, 1 for Sunday, 2 for Monday etc.

FUNCTION dayofwk$(BYVAL wd%)
SELECT ON wd%
= 1
	dayofwk$ = "Sunday    "
= 2
	dayofwk$ = "Monday    "
= 3
	dayofwk$ = "Tuesday   "
= 4
	dayofwk$ = "Wednesday "
= 5
	dayofwk$ = "Thursday  "
= 6
	dayofwk$ = "Friday    "
= 7
	dayofwk$ = "Saturday  "
=ELSE
	dayofwk$ = "DateError "
END SELECT
END FUNCTION

'Time Functions using the GEMDOS Time Stamp
'==========================================

FUNCTION gethour%(BYVAL timestamp%)
STATIC v&
	v& = CLNG(timestamp%)
	IF v& < 0 THEN v& = V& + 65536
	gethour% = CINT((v& \ 2048))
END FUNCTION

FUNCTION getmins%(BYVAL timestamp%)
STATIC v&
	v& = CLNG(timestamp%)
	IF v& < 0 THEN v& = V& + 65536
	getmins% = CINT((v& )\ 32) MOD 64
END FUNCTION

FUNCTION getsecs%(BYVAL timestamp%)
STATIC v&
	v& = CLNG(timestamp%)
	IF v& < 0 THEN v& = V& + 65536
	getsecs% = CINT((v& MOD 32) * 2)
END FUNCTION

FUNCTION settimestamp%(BYVAL hour%, BYVAL mins%, BYVAL secs%)
IF hour% < 0 OR hour% > 24 OR mins% < 0 OR mins% > 60 _
	OR secs% < 0 OR secs% > 60 THEN
	settimestamp% = 0 
ELSEIF hour < 16 THEN
	settimestamp% = (secs% \ 2) + (mins% * 32) + (hour% * 2048)
ELSE
	settimestamp% = CINT((secs \2) + (mins *32) + (CLNG(hour) *2048) - 65536)
END IF
END FUNCTION	'Returns zero for error

'___________________________________________________________________

'	START OF PROGRAMME LISTING
'	==========================

SUB StampAdjust(day,mon,year,hour,mins,secs)
	IF secs < 0 THEN
		secs = 59
		mins = mins - 1
	END IF
	IF secs > 59 THEN
		secs = 0
		mins = mins + 1
	END IF
	IF mins < 0 THEN
		mins = 59
		hour = hour - 1
	END IF
	IF mins > 59 THEN
		mins = 0
		hour = hour + 1
	END IF
	IF hour < 0 THEN
		hour = 23
		day = day - 1
	END IF
	IF hour > 23 THEN
		hour = 0
		day = day + 1
	END IF
	IF day < 1 THEN
		IF mon > 1 THEN
			mon = mon - 1
		ELSE
			mon = 12
			IF year > 1980 THEN year = year - 1
		END IF
		day = 31
		DO WHILE weekday%(day,mon,year) = 0
			day = day -1
		LOOP
	END IF
	IF day > 1 AND weekday%(day,mon,year) = 0 THEN
		day = 1
		mon = mon + 1
	END IF
	IF mon < 1 THEN
		mon = 12
		IF year > 1980 THEN year = year - 1
	END IF
	IF mon > 12 THEN
		mon = 1
		IF year < 2107 THEN year = year + 1
	END IF
	IF year < 1980 THEN year = 1980
	IF year > 2107 THEN	year = 2107
END SUB


PRINT CHR$(27);"p Date2000 for Date & Time.  ½M.High ";CHR$(27);"q"
PRINT " Use Cursor &/or Number Keys to set"
PRINT "      Press Return to confirm."
CHDIR "\auto"
han = fopen%("date2000.prg", 2)
IF han < 0 THEN
	PRINT " File Date2000.PRG file not found"
	day = 1
	mon = 1
	year = 1996
	hour = 12
	mins = 1
	secs = 0
	edit = 1
	elapse! = 0
	timeout! = 0
ELSE
	day = getdd%(tgetdate%)    'Unlike the DATE$ function, tgetdate%
	mon = getmm%(tgetdate%)	   'works from year 2069 to 2107!
	year= getyyyy%(tgetdate%)
	buffer& = VARPTR(stamp(0))
	CALL fdatime(buffer&, han, 0) 	'NOTE: buffer& & han are reversed
                                	'      from the manual order.
                                	
        'It seems that different versions of TOS and the like alter the
        'way that the clock is initialised on power-up. The date always
        'seems to be in the past (I think it is the TOS issue date). For
        'the IF statement to work first time, the clock must be correctly
        'set when the programme is compiled.
                                	
	IF weekday%(day,mon,year) = 0 OR year < getyyyy%(stamp(1)) THEN
		PRINT "  Clock was last set on ..."
		day = getdd%(stamp(1))
		mon = getmm%(stamp(1))
		year = getyyyy%(stamp(1))
		secs = getsecs%(stamp(0))
		mins = getmins%(stamp(0))
		hour = gethour%(stamp(0))
		edit = 1
		elapse! = 0
		timeout! = 0
	ELSE
		PRINT "  Clock set. Please confirm time."
		day = getdd%(tgetdate%)
		mon = getmm%(tgetdate%)
		year= getyyyy%(tgetdate%)
		secs = getsecs%(tgettime%)
		mins = getmins%(tgettime%)
		hour = gethour%(tgettime%)
		edit = 4
		elapse! = TIMER
		timeout! = TIMER
	END IF
END IF

WIDTH 255

key$ = " "
num1 = -1
num2 = -1
num3 = -1
num4 = -1

PRINT " ";		'to offset time & date display from margin


'Data processing begins here
DO WHILE edit > 0

 	IF key$ >= "0" AND key$ <= "9" THEN		'processing number keys
 	
 		timeout! = 0	'stops time-out as a valid key has been pressed
 		
		IF num1 = -1 THEN
			num1 = VAL(key$)
		ELSEIF num2 = -1 THEN
			num2 = VAL(key$)
		ELSEIF num3 = -1 THEN
			num3 = VAL(key$)
		ELSE
			num4 = VAL(key$)
		END IF
		
		IF num1 > 0	OR edit > 3	'supress display change when a leading 0 
                              	'is keyed in a date field
		SELECT CASE edit
		CASE = 6
			IF num2 = -1 THEN
				secs = num1
			ELSE
				secs = (10 * num1) + num2
			END IF
			IF num1 > 5 OR num2 > -1 THEN
				num1 = -1
				num2 = -1
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		CASE = 5
			IF num2 = -1 THEN
				mins = num1
			ELSE
				mins = (10 * num1) + num2
			END IF
			IF num1 > 5 OR num2 > -1 THEN
				num1 = -1
				num2 = -1
				edit = 6
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		CASE = 4
			IF num2 = -1 THEN
				hour = num1
			ELSE
				hour = (10 * num1) + num2
			END IF
			IF num1 > 5 OR num2 > -1 THEN
				num1 = -1
				num2 = -1
				edit = 5
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		CASE = 3
			IF num2 = -1 THEN
				year = num1
			ELSEIF num3 = -1 THEN
				year = (10 * num1) + num2
			ELSEIF num4 = -1 THEN
				year = (100 * num1) + (10 * num2) + num3
			ELSE
				year = (1000 * num1) + (100 * num2) + (10 * num3) + num4
				num1 = -1
				num2 = -1
				num3 = -1
				num4 = -1
				edit = 4
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		CASE = 2
			IF num2 = -1 THEN
				mon = num1
			ELSE
				mon = (10 * num1) + num2
			END IF
			IF num1 > 1 OR num2 > -1 THEN
				num1 = -1
				num2 = -1
				edit = 3
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		CASE = 1
			IF num2 = -1 THEN
				day = num1
			ELSE
				day = (10 * num1) + num2
			END IF
			IF num1 > 3 OR num2 > -1 THEN
				num1 = -1
				num2 = -1
				edit = 2
				StampAdjust day,mon,year,hour,mins,secs
			END IF
		END SELECT
		ELSE
			num1 = -1         	'reset num1 when a leading date 0 is
		END IF                  ' keyed in

	ELSEIF LEN(key$) = 2 THEN	'processing special keys
 	
 		timeout! = 0	'stops time-out as a special key has been pressed

		num1 = -1
		num2 = -1
		num3 = -1
		num4 = -1
		
		IF RIGHT$(key$,1) = "M" THEN		'right arrow
			IF edit < 6 THEN
				edit = edit + 1
			ELSE
				edit = 1
			END IF
		ELSEIF RIGHT$(key$,1) = "K" THEN	'left arrow
			IF  edit > 1 THEN 
				edit = edit - 1
			ELSE
				edit = 6
			END IF
		ELSEIF RIGHT$(key$,1) = "H" THEN	'up arrow
			SELECT CASE edit
			CASE = 1
				day = day + 1				
			CASE = 2
				mon = mon + 1
			CASE = 3
				year = year + 1
			CASE = 4
				hour = hour + 1
			CASE = 5
				mins = mins + 1
			CASE = 6
				secs = secs + 1
			END SELECT
			StampAdjust day,mon,year,hour,mins,secs
		ELSEIF RIGHT$(key$,1) = "P" THEN	'down arrow
			SELECT CASE edit
			CASE = 1
				day = day - 1				
			CASE = 2
				mon = mon - 1
			CASE = 3
				year = year - 1
			CASE = 4
				hour = hour - 1
			CASE = 5
				mins = mins - 1
			CASE = 6
				secs = secs - 1
			END SELECT
			StampAdjust day,mon,year,hour,mins,secs
		ELSE 
			BEEP			'for non-arrow special keys
		END IF

	ELSEIF LEN(key$) = 1 AND key$ <> CHR$(13) THEN
		BEEP				'for non-numeric standard keys
				
	END IF

'Seconds display control
	
	IF edit = 6 THEN elapse! = TIMER	'stops clock to adjust seconds

	IF elapse! <> 0 AND TIMER - elapse! >= 1 THEN
		elapse! = TIMER
		secs = secs + 1
		StampAdjust day,mon,year,hour,mins,secs
		key$ = "!"                   	'update seconds display
	END IF
	
	IF timeout! <> 0 AND TIMER - timeout! > 10 THEN key$ = CHR$(13)

'Routine to clear highlighted display
	IF key$ = CHR$(13) THEN	edit = 0

' Routine for screen display
	IF LEN(key$) > 0 THEN
		PRINT dayofwk$(weekday%(day,mon,year));
		IF edit = 1 THEN
			PRINT CHR$(27);"p";
			PRINT USING "##";day;
			PRINT CHR$(27);"q";"/";
		ELSE
			PRINT USING "##";day;
			PRINT "/";	
		END IF
		IF edit = 2 THEN
			PRINT CHR$(27);"p";
			PRINT USING "##";mon;
			PRINT CHR$(27);"q";"/";
		ELSE
			PRINT USING "##";mon;
			PRINT "/";
		END IF
		IF edit = 3 THEN
			PRINT CHR$(27);"p";
			PRINT USING "####";year;
			PRINT CHR$(27);"q";" at ";
		ELSE
			PRINT USING "####";year;
			PRINT " at ";
		END IF
		IF edit = 4 THEN
			PRINT CHR$(27);"p";
			PRINT USING "##";hour;
			PRINT CHR$(27);"q";":";
		ELSE
			PRINT USING "##";hour;
			PRINT ":";
		END IF
		IF edit = 5 THEN
			PRINT CHR$(27);"p";
			PRINT USING "##";mins;
			PRINT CHR$(27);"q";":";
		ELSE
			PRINT USING "##";mins;
			PRINT ":";
		END IF
		IF edit = 6 THEN
			PRINT CHR$(27);"p";
			PRINT USING "##";secs;
			PRINT CHR$(27);"q";
		ELSE
			PRINT USING "##";secs;
		END IF
		i=0
		DO
			PRINT CHR$(8);
			i=i+1
		LOOP WHILE i < 32
	END IF

	key$ = INKEY$
	
LOOP

PRINT
PRINT

stamp(1) = setdatestamp%(day, mon, year)
stamp(0) = settimestamp%(hour, mins, secs)
tsetdate(stamp(1))
tsettime(stamp(0))

IF han >= 0 THEN
	CALL fdatime(buffer&, han, 1)
	CALL fclose%(han)
END IF

SYSTEM

