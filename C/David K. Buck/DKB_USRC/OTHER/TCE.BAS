'*****************
' Filename: TCE.BAS (The Color Editor)
' Function: Edit/Create DKB Color declarations.
' Written by: Dan Farmer
' Date: 03/26/91
' Version 1.0
' NOTES:
' Color 0 (background color) is set to mid-gray for use by gui-panels.
' Color displayed in sample window is palette index #1.
' Colors 17 - 255 used for the preview sphere gradient and are re-set when
'        previewing.
'--------------------------------------------
' Revision History: (Who, when, what)
' 03/26/91 DFM  Original release.
'---------------------------------
' 04/03/91 DMF  Make.Gradient.Palette(): Better palette scaling.
'               Sphere() : Use PSET instead of LINE for background of view.
'                          "Seamless paper" backdrop for view.
'
' 04/04/91 DMF  Draw the preview sphere only once and keep it on the scren,
'               "P"review now only updates the palette.  Faster, plus you
'               can compare two colors on screen at once.  Wish I could
'               page-flip in mode 13 and draw it "in the dark".
'
' 04/10/91 DMF -Load full filename from commandline instead of just path
'               to it.  DKB2.10 calls the color file COLORS.DAT rather
'               than COLOR.DAT.  User may have other color files, too!
'              -Ability to specify input and output filenames.  Also
'               now prompts for input filename if none given at loadtime.
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  Conversion notes:                                          ''
''     DEFINT means any untyped variable defaults to INT       ''
''     GET #1,,IN$ means get from file #1 into IN$ for a length''
''        of however big IN$ already is.                       ''
''     COMMAND$ is the command line less the program name. Just''
''        rewrite the lousy BASIC interpretation of parameters.''
''     Type ! is a float, & is a long int, # is an 8-byte float''
''     STRING$(n,c) function returns a string containing 'n'   ''
''        occurances of the character 'c'.                     ''
''     FUNCTION returns a value.  SUB doesn't (void)           ''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
OPTION BASE 1       ' Set default lowest bound for arrays to 1

DECLARE FUNCTION Color.Set.Shade& (red!, green!, blue!)

DECLARE SUB Color.Set.And.Show.Current (red!, green!, blue!)
DECLARE SUB Color.Set.Values (Amount!, hue!)
DECLARE SUB Color.Clear.Values (value!, red!, green!, blue!)
DECLARE SUB Color.Write.Data (ColorName$, red!, green!, blue!, recno, Reccount, ColorBuffer$())
DECLARE SUB Color.Load.Color.File (Reccount!, recno!)
DECLARE SUB Color.Parse.Color.File (a$, Buffer$(), recno!)
DECLARE SUB Color.Convert.Color.Data (recno!, Buffer$(), red!, green!, blue!)
DECLARE SUB Color.Make.Gradient.Palette (red!, green!, blue!)
DECLARE SUB Color.Preview.Sphere (Xc%, Yc%, Radius!, red!, green!, blue!)
DECLARE SUB Gui.Clear.Msg (AtRow!)
DECLARE SUB Gui.KbGet (a$)
DECLARE SUB Gui.Center.Msg (AtRow, a$)
DECLARE SUB Gui.CapsState ()
DECLARE SUB Gui.Panel (WinLeft%, WinTop%, WinRight%, WinBottom%, Depth%)
DECLARE SUB Gui.Screen.Init ()
DECLARE SUB Gui.Waitkey ()
DECLARE SUB Chime.Friendly ()
DECLARE SUB Chime.Warning ()


COMMON SHARED FileName$
COMMON SHARED Input.File$, Output.File$, Input.File.Handle, Output.File.Handle
COMMON SHARED ESC$, CursorUp$, CursorDown$
COMMON SHARED Reccount, recno
COMMON SHARED MoreRedButton%, MoreGreenButton%, MoreBlueButton%
COMMON SHARED LessRedButton%, LessGreenButton%, LessBlueButton%
COMMON SHARED BrightenButton%, DarkenButton%, PreviewButton%, SaveButton%
COMMON SHARED ClearButton%, InOutButton%
COMMON SHARED Good.Input.File$

CONST FALSE = 0, TRUE = NOT FALSE
CONST MAXRECS = 512                            ' Way more than enough
ESC$ = CHR$(27)
F1$ = CHR$(0) + CHR$(59)
CursorUp$ = CHR$(0) + CHR$(72)
CursorDown$ = CHR$(0) + CHR$(80)

' ColorBuffer$: Element #1:= Color Name$   #2:= red$   #3:= green$   #4:=blue$
DIM SHARED ColorBuffer$(MAXRECS, 4)

CONST Color.Values.Row = 2
CONST Color.Name.Row = 12

' Flags for gui-button status
MoreRedButton% = 1: MoreGreenButton% = 1: MoreBlueButton% = 1
LessRedButton% = 1: LessGreenButton% = 1: LessBlueButton% = 1
BrightenButton% = 1: DarkenButton% = 1: PreviewButton% = 1: SaveButton% = 1
ClearButton% = 1: InOutButton% = 1

' Find override color file dir/name
FileName$ = COMMAND$                               ' Check argv first
IF FileName$ = "" THEN FileName$ = ENVIRON$("DKB") ' Check environ variable
IF FileName$ = "" THEN FileName$ = "COLORS.DAT"    ' Use default

Input.File$ = FileName$
Output.File$ = FileName$                           ' May be changed by user

Input.File.Handle = 1
Output.File.Handle = 2


Reccount = 0                        ' Number of "records" in color buffer
recno = 0                           ' Index pointer to current color in buffer
incr = .01                          ' Color increment rate.  Toggles to 0.10
MAIN:
	CALL Gui.Screen.Init

	'   --- Load COLOR.DAT file into memory (ColorBuffer$)
	CALL Color.Load.Color.File(Reccount, recno)            '

	'   --- Convert rgb into long int
	CALL Color.Convert.Color.Data(recno, ColorBuffer$(), red!, green!, blue!)

	Msg$ = ColorBuffer$(recno, 1)
	DO                                                    ' Loop unit ESC$
		GOSUB Screen.Freshen
		CALL Gui.KbGet(a$)
		CALL Gui.Clear.Msg(12)


		SELECT CASE a$

			'   --- Cursor Up/Down picks next/prev COLORS.DAT color.
			'       Other keys affect the color displayed currently.
			CASE CursorDown$
				recno = recno + 1: IF recno > Reccount THEN recno = 1
				CALL Color.Convert.Color.Data(recno, ColorBuffer$(), red!, green!, blue!)
				Msg$ = ColorBuffer$(recno, 1)

			CASE CursorUp$
				recno = recno - 1: IF recno < 1 THEN recno = Reccount
				CALL Color.Convert.Color.Data(recno, ColorBuffer$(), red!, green!, blue!)
				Msg$ = ColorBuffer$(recno, 1)

			CASE "+", "="
				IF incr = .01 THEN incr = .1 ELSE incr = .01   'Toggle increment

			CASE "R"
				IF red! < 1 THEN
					Msg$ = "Increasing Red"
					CALL Color.Set.Values(incr, red!)
					MoreRedButton% = -1: LessRedButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Max Red!"
				END IF

			CASE "r"
				IF red! > 0 THEN
					Msg$ = "Decreasing Red"
					CALL Color.Set.Values(-incr, red!)
					LessRedButton% = -1: MoreRedButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Red is zero!"
				END IF

			CASE "G"
				IF green! < 1 THEN
					Msg$ = "Increasing Green"
					CALL Color.Set.Values(incr, green!)
					MoreGreenButton% = -1: LessGreenButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Max Green!"
				END IF


			CASE "g"
				IF green! > 0 THEN
					Msg$ = "Decreasing Green"
					CALL Color.Set.Values(-incr, green!)
					LessGreenButton% = -1: MoreGreenButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Green is zero!"
				END IF


			CASE "B"
				IF blue! < 1 THEN
					Msg$ = "Increasing Blue"
					CALL Color.Set.Values(incr, blue!)
					MoreBlueButton% = -1: LessBlueButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Max Blue!"
				END IF

			CASE "b"
				IF blue! > 0 THEN
					Msg$ = "Decreasing Blue"
					CALL Color.Set.Values(-incr, blue!)
					LessBlueButton% = -1: MoreBlueButton% = 1
				ELSE
					CALL Chime.Friendly
					Msg$ = "Blue is zero!"
				END IF

			CASE "L", "l"
					IF red! = 1 AND green! = 1 AND blue! = 1 THEN
						Msg$ = "Can't brighten WHITE!"
						CALL Chime.Warning
					ELSE
						BrightenButton% = -1
						Msg$ = "Lightening Hue"
						IF red! < 1 THEN CALL Color.Set.Values(incr, red!)
						IF green! < 1 THEN CALL Color.Set.Values(incr, green!)
						IF blue! < 1 THEN CALL Color.Set.Values(incr, blue!)
					END IF

			CASE "D", "d"
					IF red! = 0 AND green! = 0 AND blue = 0 THEN
						Msg$ = "Can't darken BLACK!"
						CALL Chime.Warning
					ELSE
						DarkenButton% = -1
						Msg$ = "Darkening Hue"
						IF red! > 0 THEN CALL Color.Set.Values(-incr, red!)
						IF green! > 0 THEN CALL Color.Set.Values(-incr, green!)
						IF blue! > 0 THEN CALL Color.Set.Values(-incr, blue!)
					END IF

			CASE "C", "c"
				Saved.Msg$ = Msg$
				ClearButton% = -1
				Msg$ = "[W]hite, [G]ray, or [B]lack?"
				GOSUB Screen.Freshen
				a$ = ""
				WHILE a$ = "": a$ = INKEY$: WEND
				IF INSTR("Ww", a$) THEN
					CALL Color.Clear.Values(1!, red!, green!, blue!)
					Msg2$ = "White"
				ELSEIF INSTR("Gg", a$) THEN
					CALL Color.Clear.Values(.5, red!, green!, blue!)
					Msg2$ = "Middle Gray"
				ELSEIF INSTR("Bb", a$) THEN
					CALL Color.Clear.Values(0!, red!, green!, blue!)
					Msg2$ = "Black"
				ELSE
					Msg2$ = Saved.Msg$
				END IF
				Msg$ = "": GOSUB Screen.Freshen
				Msg$ = Msg2$: GOSUB Screen.Freshen: Msg2$ = ""

			CASE "S", "s", "W", "w"
				Old.Color.Name$ = Msg$
				SaveButton% = -1: Msg$ = "": GOSUB Screen.Freshen
				CALL Gui.Center.Msg(12, "Color name:" + SPACE$(20))
				LOCATE 12, POS(0) - 20
				LINE INPUT Color.Name$
				CALL Color.Write.Data(Color.Name$, red!, green!, blue!, recno, Reccount, ColorBuffer$())
				CALL Gui.Clear.Msg(12)
				IF LTRIM$(Color.Name$) = "" THEN Color.Name$ = Old.Color.Name$
				Msg$ = Color.Name$

			CASE "V", "v", "P", "p"
				PreviewButton% = -1
				CALL Color.Make.Gradient.Palette(red!, green!, blue!)

			CASE "F", "f", "I", "i"
				InOutButton% = -1
				Saved.Msg$ = Msg$
				Msg$ = "[I]nput or [O]utput file?"
				GOSUB Screen.Freshen
				a$ = ""
				WHILE a$ = "": a$ = INKEY$: WEND
				CALL Gui.Clear.Msg(12)
				IF INSTR("Ii", a$) THEN          ' Input file
					' The ON ERROR handler in Color.Load.Color.File will ask for
					' a new filename if passed a bad one.
					Input.File$ = "  "
					Reccount = 0
					recno = 0
					CALL Color.Load.Color.File(Reccount, recno)
					CALL Gui.Clear.Msg(12)

				ELSEIF INSTR("Oo", a$) THEN      ' Output file
					InOutButton% = -1
					CALL Gui.Center.Msg(12, "Output file:" + SPACE$(20))
					LOCATE 12, POS(0) - 20
					' Output file is always closed except when writing to it
					' so there's no need to open it now.  Just get the name.
					LINE INPUT Output.File$
					CALL Gui.Clear.Msg(12)

				ELSE
					Msg2$ = Saved.Msg$
				END IF
				Msg$ = "": GOSUB Screen.Freshen
				Msg$ = Msg2$: GOSUB Screen.Freshen: Msg2$ = ""

			CASE ESC$
				' DON'T BEEP
			CASE ELSE
				Msg$ = "Invalid keypress"
				CALL Chime.Warning
		END SELECT
	LOOP WHILE a$ <> ESC$

END.PROGRAM:
	SCREEN 0: WIDTH 80: CLS
	LOCATE 10, 1
	PRINT "                      ÚÄThank you for usingÄÄÄÄÄÄÄÄÄÄÄ¿"
	PRINT "                      ³ TCE: The Color Editor         ³"
	PRINT "                      ³ Copyright By Dan Farmer, 1991 ³"
	PRINT "                      ³ All rights reserved.          ³"
	PRINT "                      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
END
'--------------------------- end of main ------------------------------------

' --- Repaint the screen, update button status, show current color in window.
Screen.Freshen:
	COLOR 8
	LOCATE 22, 11: PRINT "TCE:The Color Editor"

	'   --- Little "wings" logo (BirdWARE logo?)
LogoColors:  DATA 4,2,3
	RESTORE LogoColors
	FOR i% = 2 TO 6 STEP 2
		READ a
		LINE (46 + i% * 2, 168 + i%)-(73, 168 + i%), a
		LINE (246, 168 + i%)-(273 - i% * 2, 168 + i%), a
	NEXT i%
	CALL Gui.Panel(148, 182, 234, 192, 1)  ' ESC to quit message panel


	COLOR 8
	LOCATE 24, 20: PRINT "[ESC] Quit";
	LOCATE 24, 36: IF incr = .1 THEN PRINT "Fast";  ELSE PRINT "Slow";

	'   --- Display Message in color name window
	CALL Gui.Center.Msg(12, Msg$)


   '--- "Radio Buttons"
   '    --- Left side, Left column
   CALL Gui.Panel(13, 101, 40, 113, MoreRedButton%)
   COLOR 4
   LOCATE 14, 3: PRINT "R";                 ' chr(24)
   CALL Gui.Panel(13, 117, 40, 129, MoreGreenButton%)
   COLOR 2
   LOCATE 16, 3: PRINT "G";
   CALL Gui.Panel(13, 133, 40, 145, MoreBlueButton%)
   COLOR 3
   LOCATE 18, 3: PRINT "B";
   CALL Gui.Panel(13, 149, 40, 161, BrightenButton%)
   COLOR 8
   LOCATE 20, 3: PRINT "Ltn";                 ' chr(18)
  
   '    --- Left side, Right column
   CALL Gui.Panel(46, 101, 73, 113, LessRedButton%)
   COLOR 4
   LOCATE 14, 7: PRINT "r";                  ' chr(25)
   CALL Gui.Panel(46, 117, 73, 129, LessGreenButton%)
   COLOR 2
   LOCATE 16, 7: PRINT "g";
   CALL Gui.Panel(46, 133, 73, 145, LessBlueButton%)
   COLOR 3
   LOCATE 18, 7: PRINT "b";
   CALL Gui.Panel(46, 149, 73, 161, DarkenButton%)
   COLOR 8
   LOCATE 20, 7: PRINT "Dkn";
   COLOR 8

   '    --- Right side
   CALL Gui.Panel(246, 101, 306, 113, PreviewButton%)
   LOCATE 14, 32: PRINT "Preview"
   CALL Gui.Panel(246, 117, 306, 129, SaveButton%)
   LOCATE 16, 32: PRINT "Save"
   CALL Gui.Panel(246, 133, 306, 145, ClearButton%)
   LOCATE 18, 32: PRINT "Clear";
   COLOR 7

	CALL Color.Set.And.Show.Current(red!, green!, blue!)      ' Show the color

RETURN

' ---- Called if color file not found or user pressed "F"ile / "I"nput file.
GetInputFile:

	COLOR 8

	CLOSE #Input.File.Handle                       ' Avoid "file already open"
	CALL Gui.Center.Msg(12, "Input file:" + SPACE$(20))
	LOCATE 12, POS(0) - 20                         ' Backspace for input
	LINE INPUT Input.File$                         ' Get filename from user

	Reccount = 0                                   ' Reset counters
	recno = 0

	CALL Gui.Clear.Msg(12)

	IF Input.File$ = "" THEN
		IF Good.Input.File$ = "" THEN
			CLS : WIDTH 80: PRINT : PRINT
			PRINT "TCE Error: Input filename not specified."
			PRINT "           Useage : TCE d:\path\filename.ext"
			PRINT "                or: SET DKB=d:\path\filename.ext"
			PRINT "           where filename is your DKB color file."
			PRINT
			SYSTEM
		ELSE
			Input.File$ = Good.Input.File$  'resort to last good filename
			RESUME
		END IF
	ELSE
		RESUME
	END IF

RETURN

SUB Chime.Friendly
	SOUND 1500, .1
	SOUND 3000, .1
END SUB

SUB Chime.Warning
'    SOUND 40, 3
END SUB

' --- Reset all RGB values to zero
SUB Color.Clear.Values (value!, red!, green!, blue!) STATIC
	red! = value!: green! = value!: blue! = value!
END SUB

'   --- Convert values in color buffer to rgb floats
SUB Color.Convert.Color.Data (recno, Buffer$(), red!, green!, blue!) STATIC
	red! = VAL(Buffer$(recno, 2))
	green! = VAL(Buffer$(recno, 3))
	blue! = VAL(Buffer$(recno, 4))
END SUB

'   --- Load COLORS.DAT into a buffer.
'       Requires COMMON input.file.handle,input.file$
'       and CONST MAXRECS
SUB Color.Load.Color.File (Reccount, recno) STATIC
STATIC Work$

	CLOSE #Input.File.Handle
	ON ERROR GOTO GetInputFile
	OPEN Input.File$ FOR INPUT AS #Input.File.Handle
	ON ERROR GOTO 0     ' This clears the ON ERROR event driver
	Good.Input.File$ = Input.File$

	' Since COLOR.DAT is composed of variable-length records, RANDOM file access
	' is not workable, so let's fake it with an array.
	recno = 1

	' Sample Line = "DECLARE White = COLOUR RED 1.0 GREEN 1.0 BLUE 1.0"
	DO WHILE NOT EOF(Input.File.Handle)
		INPUT #Input.File.Handle, Work$      ' read in one line as a string
		CALL Color.Parse.Color.File(LTRIM$(Work$), ColorBuffer$(), recno)
	LOOP

	CLOSE #Input.File.Handle
	Reccount = recno - 1
	recno = 1
END SUB

'   --- This routine probably needs some work.  Aaron says to look at his
'       hsv_to_rgb routine in the DKB imb.c code.
'       What I am *trying* to do is make a dark-to-light gradient for the
'       current color.  This is then used to paint the preview image.
SUB Color.Make.Gradient.Palette (red!, green!, blue!) STATIC
STATIC red2!, green2!, blue2!

	ambient = .25
	diffuse = 1 - ambient

	MAXCOLORS = 255
	COLOROFFSET = 17
	numcolors = MAXCOLORS - COLOROFFSET
	red.scale = red! + diffuse
	green.scale = green! + diffuse
	blue.scale = blue! + diffuse

	redincr! = red! / numcolors * red.scale
	greenincr! = green! / numcolors * green.scale
	blueincr! = blue! / numcolors * blue.scale

	red2! = ambient + redincr!: green2! = ambient + greenincr!: blue2! = ambient + blueincr!


	' Set pallette indices 17 - 255 from dark hue to bright hue
	FOR i% = 1 TO numcolors
		PALETTE COLOROFFSET + i%, Color.Set.Shade&(red2!, green2!, blue2!)
		  CALL Color.Set.Values(redincr!, red2!)
		  CALL Color.Set.Values(greenincr!, green2!)
		  CALL Color.Set.Values(blueincr!, blue2)
	NEXT i%
END SUB

SUB Color.Parse.Color.File (a$, Buffer$(), recno) STATIC
STATIC red$, green$, blue$, IsRed, IsGreen, IsBlue, ColorName$, EqualSign

		IF INSTR(a$, "DECLARE") THEN
			a$ = LTRIM$(RTRIM$(MID$(a$, 8)))            ' strip the DECLARE
			ColorName$ = LTRIM$(RTRIM$(MID$(a$, 8)))    ' parse the name
			EqualSign = INSTR(a$, "=")
			ColorName$ = LTRIM$(RTRIM$(LEFT$(a$, EqualSign - 1)))
			Buffer$(recno, 1) = ColorName$              ' put name in buffer

			IsRed = INSTR(a$, "RED")                    ' parse RED value
			IF IsRed THEN
				red$ = MID$(a$, IsRed + 4)
			ELSE
				red$ = "0.0"
			END IF
			Buffer$(recno, 2) = red$

			IsGreen = INSTR(a$, "GREEN")                ' parse GREEN value
			IF IsGreen THEN
				green$ = MID$(a$, IsGreen + 6)
			ELSE
				green$ = "0.0"
			END IF
			Buffer$(recno, 3) = green$

			IsBlue = INSTR(a$, "BLUE")                  ' parse BLUE value
			IF IsBlue THEN
				blue$ = MID$(a$, IsBlue + 5)
			ELSE
				blue$ = "0.0"
			END IF
			Buffer$(recno, 4) = blue$

			recno = recno + 1                           ' increment record#

		END IF
END SUB

SUB Color.Preview.Sphere (Xc%, Yc%, Radius!, red!, green!, blue!) STATIC

	' Gui Panel parms := " Left, Top, Right, Bottom, +/-Depth
	CALL Gui.Panel(80, 101, 240, 161, -2)    ' Make a viewing window

	CALL Color.Make.Gradient.Palette(red!, green!, blue!)

	'   --- Draw sky and a shaded floor
	horizon% = 120
	FOR y% = 103 TO 159
		FOR x% = 82 TO 238
			IF y% < horizon% THEN
				PSET (x%, y%), 119    ' mid-range "sky" (our actual color)
			ELSE
				PSET (x%, y%), 16 + (y% - horizon%) * 3
			END IF
		NEXT x%
	NEXT y%


	'   --- Note: The following two lines are NOT generic.  They are
	'       hard-coded by trial and error for correct placement.  My
	'       Momma taught me better- she really did!

	'   --- Draw a projected shadow
	ambient = 40
	CIRCLE (Xc% + 10, Yc% + Radius! * .52), Radius!, ambient, , , .3
	PAINT (Xc% + 10, Yc% + Radius! * .52), ambient

	' --- Draw a shaded Color.Preview.Sphere by reducing the radius of and
	' moving the center of a filled circle while cycling the palette
	' from dark to light.
   
	BStep! = 0
	FOR i% = 1 TO 238
		kolor% = i% + 20                     ' Skip reserved colors & darkest 4
		IF kolor% > 255 THEN kolor% = 255     'cause I screw up!
		Radius! = Radius! - .12: IF Radius! < 1 THEN Radius! = 1
		BStep! = BStep! + .06                 ' offsets the next circle x & y
		x% = Xc% - BStep! / 1.75               ' shift the hilight left
		y% = Yc% - BStep!                     ' shift the hilight upwards
		CIRCLE (x%, y%), Radius!, kolor%
		PAINT (x%, y%), kolor%
	NEXT i%
END SUB

'   --- Display a box filled with the current hue
'       Requires PUBLIC CONSTANT named Color.Values.Row (could be hard-coded)
'       Sets Pallette index 1
SUB Color.Set.And.Show.Current (red!, green!, blue!) STATIC

	PALETTE 1, Color.Set.Shade&(red!, green!, blue!)

	LINE (7, 26)-(313, 70), 1, BF                   ' Filled box

	'   --- Display current RGB values
	COLOR 4
	LOCATE Color.Values.Row, 3: PRINT USING "Red: #.##"; red!
	COLOR 2
	LOCATE Color.Values.Row, 15: PRINT USING "Green: #.##"; green!
	COLOR 3
	LOCATE Color.Values.Row, 29: PRINT USING "Blue: #.##"; blue!
	COLOR 8
END SUB

'   --- Create a LONG INT color value for pallette set from rgb components
FUNCTION Color.Set.Shade& (red!, green!, blue!) STATIC
	r& = red! * 63!
	g& = green! * 63!
	B& = blue! * 63!
	Color.Set.Shade& = r& + g& * 256& + B& * 65536
END FUNCTION

' Increase or decrease hue value by specified amount.
SUB Color.Set.Values (Amount!, hue!) STATIC

	Direction% = SGN(Amount!)
	Amount! = ABS(Amount!)

	IF Direction% = 1 THEN
		hue! = hue! + Amount: IF hue! > 1! THEN hue! = 1!
	ELSEIF Direction% = -1 THEN
		hue! = hue! - Amount: IF hue! < 0! THEN hue! = 0!
	END IF
	hue$ = LTRIM$(STR$(hue!))

END SUB

'   --- Prompt user for a descriptive color name and
'       write out the color data, DKB style, to a filename, outfile$
'       Requires CONSTANT named Filename.Row
'       Requires COMMON SHARED named output.file.handle AND output.file$
'
SUB Color.Write.Data (ColorName$, red!, green!, blue!, recno, Reccount, Buffer$()) STATIC

	IF ColorName$ <> "" THEN
		OPEN Output.File$ FOR APPEND AS #Output.File.Handle
			PRINT #Output.File.Handle, "DECLARE "; ColorName$; " = COLOUR";
			PRINT #Output.File.Handle, USING " RED #.##"; red!;
			PRINT #Output.File.Handle, USING " GREEN #.##"; green!;
			PRINT #Output.File.Handle, USING " BLUE #.##"; blue!
		CLOSE #Output.File.Handle
		Reccount = Reccount + 1
		recno = Reccount
		Buffer$(Reccount, 1) = ColorName$
		Buffer$(Reccount, 2) = LTRIM$(STR$(red!))
		Buffer$(Reccount, 3) = LTRIM$(STR$(green!))
		Buffer$(Reccount, 4) = LTRIM$(STR$(blue!))
		CALL Chime.Friendly
	END IF

END SUB

'   --- Check status of caps-lock
'       Requires PUBLIC CONSTANT named Prompt.Row (generally 24)
SUB Gui.CapsState STATIC
STATIC OldState, NewState, CapsOn

	DEF SEG = 0                                 'Set data segment to low memory
	OldState = CapsOn
	CapsOn = (PEEK(&H417) AND 64)
	NewState = CapsOn
	IF OldState <> NewState OR NOT Called.Before THEN
		IF CapsOn THEN
			CALL Gui.Panel(6, 182, 40, 192, 1)
		  LOCATE 24, 2: PRINT "CAPS";
		ELSE
			CALL Gui.Panel(6, 182, 40, 192, -1)
			LOCATE 24, 2: PRINT "caps";
		END IF
	END IF
	DEF SEG                                      'Restore default data segment

	' The following is, I believe, a BASIC only trick, since BASIC does not
	' REQUIRE variable initializing. Of course, Called.Before *could* be
	' defined as a COMMON SHARED variable and initialized to FALSE
	' outside of this function, but why bother?

	Called.Before = TRUE

END SUB

'   --- Center a string on the current line
SUB Gui.Center.Msg (AtRow, a$) STATIC
	IF a$ = "" THEN CALL Gui.Clear.Msg(AtRow): EXIT SUB
	LeftTab% = 21 - LEN(a$) / 2
	WLeft% = (LeftTab% * 8) - 12
	WRight% = WLeft% + (LEN(a$) * 8) + 10
	WTop% = AtRow * 8 - 12
	WBottom% = WTop% + 14
	CALL Gui.Panel(WLeft%, WTop%, WRight%, WBottom%, -1)
	LOCATE AtRow, LeftTab%: PRINT a$;
END SUB

'   --- Clear a line
SUB Gui.Clear.Msg (AtRow) STATIC
	a$ = SPACE$(34)
	LeftTab% = 21 - (LEN(a$) / 2)
	WLeft% = LeftTab% * 8 - 12
	WRight% = LEN(a$) * 8 + WLeft% + 4
	WTop% = AtRow * 8 - 12
	WBottom% = WTop% + 14
	CALL Gui.Panel(WLeft%, WTop%, WRight%, WBottom%, 0)
	LOCATE AtRow, LeftTab%: PRINT a$;
END SUB

'--- Read keybuffer and check caps lock state while waiting.  Requires
'--- the subprogram Gui.CapsState().
SUB Gui.KbGet (a$) STATIC
	a$ = ""
	WHILE a$ = ""
		a$ = INKEY$
		CALL Gui.CapsState
	WEND
END SUB

SUB Gui.Panel (WinLeft%, WinTop%, WinRight%, WinBottom%, Depth%) STATIC
STATIC i%

' Parameter Depth := -1 FOR INSET, 1 FOR OUTSET
'                     -2 FOR INSET 2 DEEP, 3 TO OUTSET 3 DEEP, ETC.
INSET% = (Depth% < 0)
Depth% = ABS(Depth%)

IF Depth% = 0 THEN
	LINE (WinLeft% + 1, WinTop% - 1)-(WinRight% - 1, WinBottom% + 1), 7, BF
ELSE
	FOR i% = 0 TO Depth% - 1
		IF INSET% THEN                                 ' INSET PANEL
			LINE (WinLeft% + i%, WinTop% + i%)-(WinLeft% + i%, WinBottom% - i%), 8' LEFT SIDE
			LINE (WinLeft% + i%, WinTop% + i%)-(WinRight% - i%, WinTop% + i%), 8  ' TOP LINE
			LINE (WinLeft% + i%, WinBottom% - i%)-(WinRight% - i%, WinBottom% - i%), 15' BOTTOM LINE
			LINE (WinRight% - i%, WinTop% + i%)-(WinRight% - i%, WinBottom% - i%), 15' RIGHT SIDE
		ELSE                                             ' OUTSET PANEL
			LINE (WinLeft% + i%, WinTop% + i%)-(WinLeft% + i%, WinBottom% - i%), 15' LEFT SIDE
			LINE (WinLeft% + i%, WinTop% + i%)-(WinRight% - i%, WinTop% + i%), 15 ' TOP LINE
			LINE (WinLeft% + i%, WinBottom% - i%)-(WinRight% - i%, WinBottom% - i%), 8' BOTTOM LINE
			LINE (WinRight% - i%, WinTop% + i%)-(WinRight% - i%, WinBottom% - i%), 8' RIGHT SIDE
		END IF
	NEXT i%
END IF
END SUB

SUB Gui.Screen.Init
	CLS

	' --- Init screen to graphics mode 13 (MCGA 320x200x256)
	'        Colorswitch on, Active Page 0, Visual Page 0
	SCREEN 13, 1, 0, 0

	PALETTE 0, Color.Set.Shade&(.66, .66, .66) ' Set background to color 7

	' Gui.Panel Parameters: Left top right bottom Depth
	CALL Gui.Panel(1, 1, 319, 198, 1)     ' Border panel
	CALL Gui.Panel(6, 5, 314, 18, -2)     ' Color values window (Top line)
	CALL Gui.Panel(6, 25, 314, 71, -1)    ' Color display window
	CALL Gui.Panel(6, 78, 314, 176, 1)    ' Main panel (Help screen,view,etc)
	' Useable text area inside lower panel : rows 14-22, cols 2-38

	CALL Gui.Panel(60, 182, 138, 192, 1)     ' File button
	COLOR 8
	LOCATE 24, 9: PRINT "[F]=Files";
	COLOR 7
	CALL Gui.Panel(278, 182, 314, 192, -1)   ' Increment window, line 24

	CALL Color.Preview.Sphere(160, 128, 25, .5, .5, .5)

END SUB

'   --- Wait forever for a keypress
SUB Gui.Waitkey STATIC
	 CALL Gui.Panel(148, 182, 256, 192, 1)    ' Press any key panel
	 COLOR 15
	 LOCATE 24, 20: PRINT "Press any key";
	 COLOR 8
	 a$ = ""
	 WHILE a$ = ""
		 CALL Gui.KbGet(a$)                        ' Check for keypress
	 WEND
	 CALL Gui.Panel(147, 182, 261, 192, 0)     ' Erase panel
END SUB
