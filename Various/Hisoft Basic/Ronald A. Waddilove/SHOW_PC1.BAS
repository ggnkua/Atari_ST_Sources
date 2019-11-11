REM Load and display a Degas Elite compressed colour PC1 file
REM Written in HiSoft Basic by R.A.Waddilove
REM Word 0 = screen resolution ($8000=compressed colour, $0000=uncompressed)
REM Words 1-16 = palette
REM Byte 34- = picture data
REM Picture data -	byte  0... 127 = copy next n+1 bytes
REM 				byte -1...-127 = copy next byte -n+1 times
REM					byte	  -128 = ignore

LIBRARY "XBIOS","GEMAES"

file$ = FNfilename$					:' get the filename

OPEN "I",#1,file$					:' open the file for input
dummy$ = INPUT$(2,#1)
FOR i%=0 TO 15
a%=256*ASC(INPUT$(1,#1))+ASC(INPUT$(1,#1))
dummy%=FNsetcolor%(i%,a%)
NEXT
scrstart& = FNphysbase&				:' get screen start address
FOR scan%=0 TO 199
FOR plane%=0 TO 6 STEP 2
 addr&=scrstart&+160*scan%+plane%
 nextline&=addr&+160
 DO
  b% = ASC(INPUT$(1,#1))		:' read a byte from picture file
  IF b%<128 THEN
   FOR i% = 0 TO b%		:' copy next n+1 bytes literally
    POKEB addr&,ASC(INPUT$(1,#1))
    IF addr& AND 1 THEN addr&=addr&+7 ELSE INCR addr&
   NEXT
  END IF
  IF b%>128 THEN
  byte% = ASC(INPUT$(1,#1))
  FOR i% = 1 TO 256-b%+1	:' copy byte% -b% + 1 times
  POKEB addr&,byte%
  IF addr& AND 1 THEN addr&=addr&+7 ELSE INCR addr&
NEXT
END IF
LOOP UNTIL addr&>=nextline&		:' finished scan line?
NEXT
NEXT
CLOSE #1
END

DEF FNfilename$
path$ = "A:\*.PC1"
ok% = 0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$ = LEFT$(path$,LEN(path$)-1)
WEND
IF name$ = "" THEN SYSTEM
FNfilename$ = path$+name$
END DEF
