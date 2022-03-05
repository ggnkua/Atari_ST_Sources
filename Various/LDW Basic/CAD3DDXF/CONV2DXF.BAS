REM
REM         CAD-3D to DXF Converter
REM             by Dave Edwards
REM     Copyright 1990 Antic Publishing
REM
DIM T(5000, 2), COLORS(15)
PRINT "CAD-3D to DXF Converter"
PRINT "by Dave Edwards"
PRINT "Copyright 1990 Antic Publishing Inc."
VERNUM: INPUT "Input AutoCAD version number (9 or 10)"; VNUM
IF VNUM < 9 THEN GOTO VERNUM:
IF VNUM > 10 THEN GOTO VERNUM:
INPUT "Input name of CAD-3D file ( .3D2 extension required) - "; NAME3D$
INPUT "Input name of output DXF file ( .DXF extension required) - "; NAMEDXF$
PRINT "AutoCAD Colors - other color numbers are permissible..."
PRINT "1 - RED               4 - CYAN"
PRINT "2 - YELLOW            5 - BLUE"
PRINT "3 - GREEN             6 - MAGENTA"
PRINT "           7 - WHITE"
OPEN "R", #1, NAME3D$, 1
FIELD 1, 1 AS VALUE$
OPEN "O", #2, NAMEDXF$
PRINT #2, "0": PRINT #2, "SECTION"
PRINT #2, "2": PRINT #2, "ENTITIES"
GET #1: GET #1
GOSUB TYPE1: NO = NI
PRINT "Number of Objects - "; NO
FOR X = 1 TO 32
   GET #1: GET #1
NEXT X
FOR X = 0 TO 15
   GET #1: GET #1
NEXT X
GET #1: GET #1: PALTYPE = VAL("&H" + HEX$(ASC(VALUE$)))
IF PALTYPE = 1 THEN GOTO SHADE14:
IF PALTYPE = 2 THEN GOTO CUSTOM:
PRINT "CAD-3D Color Palette Type is Seven-Shade"
INPUT "Input Color number for First Primary color - "; FIRSTCOLOR
FOR X = 0 TO 7: COLORS(X) = FIRSTCOLOR: NEXT X
INPUT "Input Color number for Second Primary color - "; SECONDCOLOR
FOR X = 8 TO 15: COLORS(X) = SECONDCOLOR: NEXT X
GOTO START:
SHADE14: 
PRINT "CAD-3D Color Palette Type is Fourteen-Shade"
INPUT "Input Color number for Primary color - "; PRIMCOLOR
FOR X = 0 TO 15: COLORS(X) = PRIMCOLOR: NEXT X
GOTO START:
CUSTOM:
PRINT "CAD-3D Color Palette Type is Custom"
FOR X = 0 TO 15
   PRINT "Input Color Number for Custom Color #"; X; : INPUT COLORNUM
   COLORS(X) = COLORNUM
NEXT X
START:
GET #1: GET #1: GET #1: GET #1
FOR X = 1 TO 150
   GET #1
NEXT X
FOR I = 1 TO NO
   OBJNAME$ = ""
   FOR J = 1 TO 9
      GET #1
      IF ASC(VALUE$) = 0 THEN SW1 = 1
      IF SW1 <> 1 THEN OBJNAME$ = OBJNAME$ + VALUE$
   NEXT J
   SW1 = 0
   PRINT "Processing Object - "; OBJNAME$
   GOSUB TYPE1: NV = NI
   FOR K = 0 TO NV - 1
      GOSUB TYPE2:
      T(K, 0) = NR
      GOSUB TYPE2:
      T(K, 1) = NR
      GOSUB TYPE2:
      T(K, 2) = NR
   NEXT K
   GOSUB TYPE1: NF = NI
   FOR L = 0 TO NF - 1
      PRINT #2, "0": PRINT #2, "3DFACE": PRINT #2, "8": PRINT #2, OBJNAME$
      GOSUB TYPE1: PRINT #2, "10": PRINT #2, T(NI, 0)
      PRINT #2, "20": PRINT #2, T(NI, 1)
      PRINT #2, "30": PRINT #2, T(NI, 2): N4 = NI
      GOSUB TYPE1: PRINT #2, "11": PRINT #2, T(NI, 0)
      PRINT #2, "21": PRINT #2, T(NI, 1)
      PRINT #2, "31": PRINT #2, T(NI, 2)
      GOSUB TYPE1: PRINT #2, "12": PRINT #2, T(NI, 0)
      PRINT #2, "22": PRINT #2, T(NI, 1)
      PRINT #2, "32": PRINT #2, T(NI, 2)
      PRINT #2, "13": PRINT #2, T(N4, 0)
      PRINT #2, "23": PRINT #2, T(N4, 1)
      PRINT #2, "33": PRINT #2, T(N4, 2)
      IF VNUM = 9 THEN GET #1: GOTO VER9:
      PRINT #2, "70"
      GET #1: N5 = VAL("&H" + HEX$(ASC(VALUE$)))
      IF N5 = 7 THEN N6 = 0
      IF N5 = 3 THEN N6 = 1
      IF N5 = 5 THEN N6 = 2
      IF N5 = 1 THEN N6 = 3
      IF N5 = 6 THEN N6 = 4
      IF N5 = 2 THEN N6 = 5
      IF N5 = 4 THEN N6 = 6
      IF N5 = 0 THEN N6 = 7
      PRINT #2, N6
VER9: PRINT #2, "62"
      GET #1: N7 = VAL("&H" + HEX$(ASC(VALUE$)))
      PRINT #2, COLORS(N7)
   NEXT L
NEXT I
PRINT #2, "0": PRINT #2, "ENDSEC": PRINT #2, "0": PRINT #2, "EOF"
CLOSE : END
TYPE1: GET #1: N1 = VAL("&H" + HEX$(ASC(VALUE$))) * 256
       GET #1: N2 = VAL("&H" + HEX$(ASC(VALUE$)))
       NI = N1 + N2
       RETURN
TYPE2: GET #1: N1 = VAL("&H" + HEX$(ASC(VALUE$))) * 256
       GET #1: N2 = VAL("&H" + HEX$(ASC(VALUE$)))
       N = N1 + N2
       IF N > 4500 THEN N = N - 65536
       NR = N / 100
       RETURN
