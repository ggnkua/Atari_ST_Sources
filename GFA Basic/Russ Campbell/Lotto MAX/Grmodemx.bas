OPEN "grmodemax.dat" FOR OUTPUT AS #1
_FULLSCREEN
start:
CLS
PRINT
PRINT "Graphics Mode Setup for Lotto Max Package Version 2019 "
PRINT "-------------------------------------------------------"
PRINT
INPUT "Do want colour screens [default Yes]       : ", cs$
IF cs$ = "y" THEN
    cs$ = "Y"
ELSEIF cs$ = "n" THEN
    cs$ = "N"
END IF
IF cs$ = "" THEN
    cs$ = "Y"
END IF
INPUT "Do you have a printer online [default Yes] : ", printer$
IF printer$ = "y" THEN
    printer$ = "Y"
ELSEIF printer$ = "n" THEN
    printer$ = "N"
END IF
IF printer$ = "" THEN
    printer$ = "Y"
END IF
PRINT
PRINT "[A]  -  No Graphics Card"
PRINT "[B]  -  VGA Mode"
PRINT "[C]  -  HDMI Mode"
PRINT
PRINT "[Return] defaults to HDMI Mode ..."
PRINT
INPUT "Enter [A B C] : ", answer$
IF answer$ = "a" OR answer$ = "A" THEN
    stype = 0
    stype$ = "None"
ELSEIF answer$ = "b" OR answer$ = "B" THEN
    stype = 1
    stype$ = "VGA"
ELSEIF answer$ = "c" OR answer$ = "C" THEN
    stype = 2
    stype$ = "HDMI"
ELSEIF answer$ = "" THEN
    stype = 2
    stype$ = "HDMI"
END IF
qqqq:
CLS
PRINT
PRINT "This program will allow you to set up a permanent amount of tickets"
PRINT "To buy every time you run it, however it is limited to 25 tickets"
PRINT "Note that this section defaults to 1 ticket if you press enter "
PRINT "The program will allow you to override this however if you wish"
INPUT "How many sets of tickets do you want to permanently set up ?? : ", qqq
IF qqq = 0 THEN qqq = 1
IF qqq > 25 THEN
    PRINT "Keep it under 26 sets of tickets OK?"
    GOTO qqqq
END IF
CLS
PRINT
PRINT "Printer       : "; printer$
PRINT "Color         : "; cs$
PRINT "Graphics Mode : "; stype$
PRINT "Permanent amounts of tickets  : "; qqq; " sets"
PRINT
INPUT "Is the above correct [Y]es or [N]o : ", answer$
IF answer$ = "n" OR answer$ = "N" OR answer$ = "no" OR answer$ = "NO" THEN
    GOTO start
END IF
PRINT #1, printer$
PRINT #1, cs$
PRINT #1, stype
PRINT #1, qqq
CLOSE #1
CHAIN "lottomax2019"
END
