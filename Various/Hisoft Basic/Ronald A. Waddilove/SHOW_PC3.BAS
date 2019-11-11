REM Load and display a Degas Elite compressed monochrome PC3 file
REM Written in HiSoft Basic by R.A.Waddilove
REM Word 0 = screen resolution ($8002=compressed mono, $0002=uncompressed)
REM Words 1-16 = palette
REM Byte 34- = picture data
REM Picture data -	byte  0... 127 = copy next n+1 bytes
REM 				byte -1...-127 = copy next byte -n+1 times
REM					byte	  -128 = ignore

LIBRARY "XBIOS","GEMAES"

file$ = FNfilename$					:' get the filename

OPEN "I",#1,file$					:' open the file for input
colour$ = INPUT$(34,#1)				:' get colour palette
scrstart& = FNphysbase&				:' get screen start address
FOR scan% = 0 TO 399				:' 400 scan lines (rows of pixels)
	addr& = scrstart& + 80*scan%	:' get address of current scan line
	nextline& = addr& + 80			:' get address of next scan line
	DO
		b% = ASC(INPUT$(1,#1))		:' read a byte from picture file
		IF b%<128 THEN
			FOR i% = 0 TO b%		:' copy next n+1 bytes literally
				POKEB addr&,ASC(INPUT$(1,#1))
				INCR addr&
			NEXT
		END IF
		IF b%>128 THEN
			byte% = ASC(INPUT$(1,#1))
			FOR i% = 1 TO 256-b%+1	:' copy byte% -b% + 1 times
				POKEB addr&,byte%
				INCR addr&
			NEXT
		END IF
	LOOP UNTIL addr&>=nextline&	:' finished scan line?
NEXT							:' next scan line
CLOSE #1						:' close the file
END

DEF FNfilename$
path$ = "A:\*.PC3"
ok% = 0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$ = LEFT$(path$,LEN(path$)-1)
WEND
IF name$ = "" THEN SYSTEM
FNfilename$ = path$+name$
END DEF
