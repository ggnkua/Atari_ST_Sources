REM *** Daily Keno Package Version 2019
REM *** Written by: Russ Campbell
REM
REM *** Last Update : November 25 2018 - 8:13 PM
REM
_FULLSCREEN _STRETCH
CLEAR , , 750000
DIM temp(20): TIMER ON
DIM temp2(20)
DIM temp3(70)
DIM temp4(70)
DIM entry(70)
DIM month$(12)
DIM numb(300000)
DIM chart(300000, 23)
DIM outpt(300000)
REM $STATIC

RANDOMIZE TIMER
REM ON ERROR GOTO errorhandle
GOSUB grcheck
GOSUB grinit
GOSUB buildchart
GOSUB convert
IF crs$ = "Y" THEN COLOR 1, 7
CLS
IF crs$ = "Y" THEN COLOR 11, 1
REM build top corner at pos 3,6
LOCATE 3, 6
PRINT CHR$(201)
REM build top line at line 3
FOR i = 2 TO 67
    LOCATE 3, 5 + i
    PRINT CHR$(205)
NEXT i
REM build end corner at pos 3,73
LOCATE 3, 73
PRINT CHR$(187)
FOR i = 4 TO 17
    LOCATE i, 6
    PRINT CHR$(186)
    LOCATE i, 73
    PRINT CHR$(186)
NEXT i
LOCATE 18, 6
PRINT CHR$(200)
FOR i = 2 TO 67
    LOCATE 18, 5 + i
    PRINT CHR$(205)
NEXT i
LOCATE 18, 73
PRINT CHR$(188)
IF crs$ = "Y" THEN COLOR 7, 1
FOR i = 8 TO 72
    LOCATE 4, i
    PRINT CHR$(178)
NEXT i
FOR i = 8 TO 72
    LOCATE 17, i
    PRINT CHR$(178)
NEXT i
FOR i = 4 TO 17
    LOCATE i, 7
    PRINT CHR$(178)
    LOCATE i, 72
    PRINT CHR$(178)
NEXT i
IF crs$ = "Y" THEN COLOR 3, 1
LOCATE 5, 8
PRINT CHR$(201)
FOR i = 9 TO 70
    LOCATE 5, i
    PRINT CHR$(205)
NEXT i
LOCATE 5, 71
PRINT CHR$(187)
FOR i = 9 TO 70
    LOCATE 16, 8
    PRINT CHR$(205)
NEXT i
FOR i = 5 TO 16
    LOCATE i, 8
    IF i = 5 THEN
        PRINT CHR$(201)
    ELSEIF i = 16 THEN
        PRINT CHR$(200)
    ELSEIF i = 6 OR i = 7 OR i = 14 THEN
        PRINT CHR$(204)
    ELSE
        PRINT CHR$(186)
    END IF
    LOCATE i, 71
    IF i = 5 THEN
        PRINT CHR$(187)
    ELSEIF i = 16 THEN
        PRINT CHR$(188)
    ELSEIF i = 6 OR i = 7 OR i = 14 THEN
        PRINT CHR$(185)
    ELSE
        PRINT CHR$(186)
    END IF
NEXT i
FOR i = 9 TO 70
    LOCATE 6, i
    PRINT CHR$(205)
NEXT i
FOR i = 9 TO 70
    LOCATE 7, i
    PRINT CHR$(205)
NEXT i
FOR i = 9 TO 70
    LOCATE 16, i
    PRINT CHR$(205)
NEXT i
IF crs$ = "Y" THEN COLOR 10, 5
LOCATE 6, 11
PRINT "     Daily Keno Midday Package Version 2019 Copyright 2018    "
IF crs$ = "Y" THEN COLOR 2, 12
LOCATE 8, 9
PRINT "                                                              "
LOCATE 9, 9
PRINT "                                                              "
IF crs$ = "Y" THEN COLOR 2, 12
LOCATE 10, 9
PRINT "                                                              "
LOCATE 11, 9
PRINT "                                                              "
LOCATE 12, 9
PRINT "                                                              "
LOCATE 13, 9
PRINT "                                                              "
IF crs$ = "Y" THEN COLOR 10, 5
LOCATE 9, 14
PRINT "Written By    : Russ Campbell                      "
LOCATE 10, 14
PRINT "Release Date  : Nov 24 2018 - 4:00 PM              "
LOCATE 11, 14
PRINT "Registered To :                                    "
LOCATE 11, 30
PRINT reg$
LOCATE 12, 14
PRINT "Serial Number : "; reg2$; "      "
IF crs$ = "Y" THEN COLOR 3, 1
FOR i = 9 TO 70
    LOCATE 14, i
    PRINT CHR$(205)
NEXT i
IF crs$ = "Y" THEN COLOR 2, 12
LOCATE 15, 9
PRINT " Graphics Mode : "
LOCATE 15, 25
PRINT "["
LOCATE 15, 30
PRINT "]"
IF crs$ = "Y" THEN COLOR 4, 2
LOCATE 15, 26
PRINT "    "
LOCATE 15, 26
PRINT grmode$
LOCATE 15, 45
IF crs$ = "Y" THEN COLOR 15, 3
LOCATE 15, 31
PRINT
IF crs$ = "Y" THEN COLOR 15, 3
LOCATE 15, 63
PRINT "       "
IF crs$ = "Y" THEN COLOR 11, 6
LOCATE 15, 31
PRINT "       Press any key to continue...     "
IF crs$ = "Y" THEN COLOR 10, 2
DO WHILE INKEY$ = ""
LOOP
GOTO main
picker:
CLS
IF randome$ = "no" THEN
    PRINT ""
    PRINT "This section will prompt you for up to"; qqq;
    PRINT "sets of numbers of your choosing"
    PRINT "then create a number of sets of numbers randomly"
    PRINT "using only your chosen numbers."


    PRINT ""
ELSEIF randome$ = "yes" THEN
    PRINT ""
    PRINT "This section will pick random numbers for you"
    PRINT "then create as many sets of numbers as you desire."
    PRINT
END IF
PRINT
money:
INPUT "How many sets of numbers do you wish "; sets

IF sets > 10 THEN PRINT "This can get expensive !!!!!!"
PRINT "Are You sure [Y]es or [N]o : "; answer$

INPUT "How many numbers do you wish to buy  [At $1.00 per number : ]  $", numbers
IF numbers < 10 THEN
    PRINT "You need to spend at least $10.00 Please try again!"
    GOTO money
END IF
cost = sets * numbers * 1
PRINT USING "This will cost you a grand total of $###### "; cost
PRINT " Can you afford this much money? :"
INPUT " Answer [Y]es or [N]o to continue : "; answer$
PRINT
diskcop:
INPUT "Output to disk file [Y]es or [N]o : ", diskcopy$
IF diskcopy$ = "Y" OR diskcopy$ = "y" OR diskcopy$ = "yes" OR diskcopy$ = "YES" OR diskcopy$ = "Yes" OR diskcopy$ = "yES" THEN
    diskcopy$ = "Y"
    INPUT "Filename [without extension] : ", file$
    IF file$ = "" OR file$ = "numbers2" OR file$ = "reg" OR file$ = "grmode" THEN
        PRINT "Invalid filename ... please try again !!!"
        GOTO diskcop
    END IF
    file$ = file$ + ".dat"
    OPEN file$ FOR OUTPUT AS #2
END IF

PRINT
IF randome$ = "yes" THEN
    GOTO start
ELSEIF randome$ = "no" THEN
    GOTO previously
END IF
previously:
INPUT "Do you wish to use a previously saved set of numbers  [Y] or [N] : ", answer$
IF answer$ = "y" OR answer$ = "Y" THEN
    OPEN "numbers.dat" FOR INPUT AS #1
    DO UNTIL EOF(1)
        counter = counter + 1
        INPUT #1, number
        entry(counter) = number
    LOOP
ELSE
    GOTO entry
END IF
CLOSE #1
IF counter < qqq THEN
    qqq = counter
ELSEIF counter > qqq THEN
    qqq = counter
END IF
GOTO start
entry:
IF randome$ = "yes" THEN GOTO start
CLS
FOR zq = 1 TO qqq
    1 PRINT "Entry #"; zq; " ";: INPUT ":", entry(zq)
    IF entry(zq) = 0 THEN
        IF diskcopy$ = "Y" THEN
            CLOSE #2
        END IF
        GOTO main
    END IF
    IF entry(zq) < 1 OR entry(zq) > 70 THEN
        PRINT "Number Out of Range ! , Try Again !!"
        GOTO 1
    END IF
    IF zq > 1 THEN
        FOR i = 1 TO (zq - 1)
            IF entry(zq) = entry(i) THEN
                PRINT "Number already entered, pick another!"
                GOTO 1
            END IF
        NEXT i
    END IF
NEXT zq

PRINT
CLS
PRINT
PRINT "You have picked the following numbers: "
PRINT
FOR i = 1 TO qqq
    PRINT "Entry # "; i; " "; entry(i)
NEXT i
PRINT
INPUT "Is this all correct [Y]es or [N]o  : ", answer$
IF answer$ = "n" OR answer$ = "N" THEN GOTO entry
PRINT
INPUT "Save Numbers to disk [Y] or [N] : ", answer$
IF answer$ = "Y" OR answer$ = "y" THEN
    OPEN "numbers.dat" FOR OUTPUT AS #1
    FOR i = 1 TO qqq
        PRINT #1, entry(i)
    NEXT i
    CLOSE #1
END IF
start:
CLS
PRINT
PRINT "Daily Keno Winning Number List"
PRINT "------------------------------"
PRINT
IF hardcopy$ = "Y" OR hardcopy$ = "y" THEN
    LPRINT
    LPRINT "Daily Keno Winning Number List"
    LPRINT "------------------------------"
    LPRINT
END IF

FOR y = 1 TO 70
    GOSUB pick
NEXT y
IF randome$ = "no" THEN
    FOR i = 1 TO sets
        temp(i) = entry(temp(i))
    NEXT i
END IF
FOR i = 1 TO setnumbers
    temp2(i) = temp(i)
NEXT i
FOR j = 1 TO 50
    marker = 99
    FOR i = 1 TO 50
        IF temp2(iii) < marker THEN
            marker = temp2(iii)
            marker2 = iii
        END IF
    NEXT i
    temp2(marker2) = 99
    temp(j) = marker
NEXT
IF diskcopy$ = "Y" THEN
    PRINT #2, USING "On ## ## ####  The  winning numbers in the Midday   were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c; d; e; f; g; h; i1; j1; k1; l1; n1; o1; p1; q1; r1; s1; t1
    PRINT #2, USING "On ## ## ####  The  winning numbers in the Evening  were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c1; d1; e1; f1; g1; h1; i1; j1; k1; l1; n1; o1; p1; q1; r1; s1; t1


END IF
IF hardcopy$ = "Y" OR hardcopy$ = "y" THEN
    LPRINT USING "On ## ## ####  The winning numbers in the Midday   were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c1; d1; e1; f1; g1; h1; i1; j1; k1; l1; m1; n1; o1; p1; q1; r1; s1; t1;
    LPRINT USING "On ## ## ####  The winning numbers in the Evening  were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c1; d1; e1; f1; g1; h1; i1; j1; k1; l1; m1; n1; o1; p1; q1; r1; s1; t1;


END IF
PRINT USING "On ## ## #### The winning numbers in the Midday   were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c1; d1; e1; f1; g1, h1, i1, j1, k1, l1, m1, n1, o1, p1, q1, r1, s1, t1
PRINT USING "On ## ## #### The winning numbers in the Evening  were :  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a1; b1; c1; d1; e1; f1; g1, h1, i1, j1, k1, l1, m1, n1, o1, p1, q1, r1, s1, t1


GOSUB cleararrays
PRINT
PRINT "Program Written by : Russ Campbell"
IF hardcopy$ = "Y" AND randome$ = "no" THEN
    LPRINT
    LPRINT "The numbers that you have chosen are as follows: "
    LPRINT
    FOR i = 1 TO qqq
        LPRINT entry(i); " ";
    NEXT i
    PRINT
END IF
IF hardcopy$ = "Y" THEN
    LPRINT
    LPRINT "Program written by : Russ Campbell"
    LPRINT
    LPRINT CHR$(12)
END IF
IF diskcopy$ = "Y" THEN
    CLOSE #2
END IF
PRINT
PRINT "Press any key to continue"
DO WHILE INKEY$ = ""
LOOP
GOTO main
pick:
IF randome$ = "yes" THEN
    raaa = 35
END IF
IF randome$ = "no" THEN
    raaa = 0
END IF
rzzz = INT((qqq + raaa) * RND(1) + 1)
temp(y) = rzzz
temp3(rzzz) = temp3(rzzz) + 1
GOSUB checkforduplicates
RETURN
cleararrays:
ERASE temp3
RETURN
checkforduplicates:
IF y > 1 THEN
    IF temp3(rzzz) > 1 THEN
        GOSUB pick
    END IF
END IF
RETURN
main:
IF crs$ = "Y" THEN COLOR 1, 7
CLS
IF crs$ = "Y" THEN COLOR 3, 8
LOCATE 4, 7
PRINT CHR$(201)
FOR i = 8 TO 73
    LOCATE 4, i
    PRINT CHR$(205)
NEXT i
LOCATE 4, 74
PRINT CHR$(187)
FOR i = 5 TO 13
    LOCATE i, 7
    IF i = 6 OR i = 11 OR i = 13 THEN
        PRINT CHR$(204)
    ELSE
        PRINT CHR$(186)
    END IF
    LOCATE i, 74
    IF i = 6 OR i = 11 OR i = 13 THEN
        PRINT CHR$(185)
    ELSE
        PRINT CHR$(186)
    END IF
NEXT i
FOR i = 8 TO 73
    LOCATE 6, i
    PRINT CHR$(205)
NEXT i
FOR i = 8 TO 73
    LOCATE 11, i
    PRINT CHR$(205)
NEXT i
FOR i = 8 TO 73
    LOCATE 13, i
    PRINT CHR$(205)
NEXT i
LOCATE 14, 7
PRINT CHR$(186)
LOCATE 14, 74
PRINT CHR$(186)
LOCATE 15, 7
PRINT CHR$(200)
FOR i = 8 TO 73
    LOCATE 15, i
    PRINT CHR$(205)
NEXT i
LOCATE 15, 74
PRINT CHR$(188)
IF crs$ = "Y" THEN COLOR 15, 3
LOCATE 14, 8
PRINT "                                                                  "
LOCATE 14, 8
PRINT USING "     Winning Numbers Database Updated On : ##-##-#### "; month; day; year
IF crs$ = "Y" THEN COLOR 10, 5
LOCATE 5, 8
PRINT "             Daily Keno Package Version 2019  Main Menu            "
IF crs$ = "Y" THEN COLOR 4, 7
FOR i = 7 TO 10
    LOCATE i, 13
    PRINT "["
    LOCATE i, 15
    PRINT "]"
    LOCATE i, 42
    PRINT "["
    LOCATE i, 44
    PRINT "]"
NEXT i
IF crs$ = "Y" THEN COLOR 0, 7
LOCATE 7, 14
PRINT "A"
LOCATE 7, 43
PRINT "B"
LOCATE 8, 14
PRINT "C"
LOCATE 8, 43
PRINT "D"
LOCATE 9, 14
PRINT "E"
LOCATE 9, 43
PRINT "F"
LOCATE 10, 14
PRINT "G"
LOCATE 10, 43
PRINT "H"
IF crs$ = "Y" THEN COLOR 1, 7
LOCATE 7, 18
PRINT "Enter Winning Numbers."
LOCATE 8, 18
PRINT "Use"; qqq; "Number System."
LOCATE 9, 18
PRINT "Initialize Data Files."
LOCATE 10, 18
PRINT "Special Bargraph Menu."
LOCATE 7, 47
PRINT "Search and Print Menus."
LOCATE 8, 47
PRINT "Pick random Numbers."
LOCATE 9, 47
PRINT "Bargraph Menu."
LOCATE 10, 47
PRINT "Frequency Calculator."
IF crs$ = "Y" THEN COLOR 4, 7
LOCATE 12, 31
PRINT "["
LOCATE 12, 33
PRINT "]"
LOCATE 12, 42
PRINT "Escape Key Exits Program."
IF crs$ = "Y" THEN COLOR 1, 7
LOCATE 12, 13
PRINT "Your choice is : "
main2:
LOCATE 12, 32
answer$ = ""
answer$ = INPUT$(1)
PRINT answer$
IF answer$ = CHR$(27) THEN
    GOTO finish
ELSEIF answer$ = "A" OR answer$ = "a" THEN
    GOTO enter
ELSEIF answer$ = "B" OR answer$ = "b" THEN
    GOTO searchmenu
ELSEIF answer$ = "C" OR answer$ = "c" THEN
    randome$ = "no"
    GOTO picker
ELSEIF answer$ = "D" OR answer$ = "d" THEN
    randome$ = "yes"
    GOTO picker
ELSEIF answer$ = "E" OR answer$ = "e" THEN
    GOTO cleardata
ELSEIF answer$ = "F" OR answer$ = "f" THEN
    spec$ = "N"
    GOTO bargraph
ELSEIF answer$ = "G" OR answer$ = "g" THEN
    spec$ = "Y"
    GOTO enquiremonth
ELSEIF answer$ = "H" OR answer$ = "h" THEN
    GOTO chart2
ELSEIF answer$ = "%" THEN
    CLS
    INPUT "Enter Password: ", pass2$
    owner$ = "Russ Campbell"
    registered$ = reg$
    distribute$ = "Public Domain"
    serial$ = reg2$
    version$ = "Daily Keno Midday Version"
    release$ = "November 25 2018 - 8:13 PM"
    pass$ = "Omnimon43"
    IF pass2$ = pass$ THEN
        CLS
        PRINT
        PRINT "Program Written by : "; owner$
        PRINT "Registered to      : "; registered$
        PRINT "Distributed by     : "; distribute$
        PRINT "Serial #           : "; serial$
        PRINT "Version #          : "; version$
        PRINT "Release date       : "; release$
        PRINT
        PRINT "Press any key to continue ... "
        DO WHILE INKEY$ = ""
        LOOP
    END IF
    GOTO main
ELSE
    GOTO main2
END IF
chart:
CLS
PRINT "Number Pattern"
PRINT "--------------"
PRINT
PRINT "This sections displays the number pattern for winning #s that have"
PRINT "been entered. The amount of times each number has been picked is "
PRINT "displayed as in the chart below."
PRINT
IF bonus$ = "Y" THEN
    title2$ = "With Bonus Numbers"
ELSEIF bonus$ = "N" THEN
    title2$ = "Without Bonus Numbers"
END IF
FOR i = 1 TO 75
    outpt(i) = 0
NEXT i
FOR i = 1 TO 70
    IF bonus$ = "Y" THEN
        outpt(i) = numb(i) + bonus(i)
    ELSEIF bonus$ = "N" THEN
        outpt(i) = numb(i)
    END IF
NEXT i
PRINT
PRINT "Number Chart "; title2$
PRINT
FOR i = 1 TO 10
    PRINT USING "Num ## : ####"; i; outpt(i);
    PRINT USING "  Num ## : ####"; i + 10; outpt(i + 10);
    PRINT USING "  Num ## : ####"; i + 20; outpt(i + 20);
    PRINT USING "  Num ## : ####"; i + 30; outpt(i + 30);
    PRINT USING "  Num ## : ####"; i + 40; outpt(i + 40);
    PRINT USING "  Num ## : ####"; i + 50; outpt(i + 50);
    PRINT USING "  Num ## : ####"; i + 60; outpt(i + 60)
NEXT i
IF hardcopy$ = "Y" THEN
    LPRINT
    LPRINT "Number Chart "; title2$
    LPRINT
    LPRINT
    FOR i = 1 TO 10
        LPRINT USING "Num ## : ####"; i; outpt(i);
        LPRINT USING "  Num ## : ####"; i + 10; outpt(i + 10);
        LPRINT USING "  Num ## : ####"; i + 20; outpt(i + 20);
        LPRINT USING "  Num ## : ####"; i + 30; outpt(i + 30);
        LPRINT USING "  Num ## : ####"; i + 40; outpt(i + 40);
        LPRINT USING "  Num ## : ####"; i + 50; outpt(i + 50);
        LPRINT USING "  Num ## : ####"; i + 60; outpt(i + 60)
    NEXT i
    LPRINT
    LPRINT "Program Written by Russ Campbell"
    LPRINT
    LPRINT CHR$(12)
END IF
PRINT: PRINT "Press any key to continue"
DO WHILE INKEY$ = ""
LOOP
GOTO graphmenu
enquiremonth:
CLS
PRINT
PRINT "View Graphs from specified date"
PRINT
INPUT "Enter Year to start from  : ", yearin
IF yearin < 2000 THEN
    yearin = 2000
END IF
INPUT "Enter Month to start from : ", monthin
INPUT "Enter Year to finish at   : ", yearend
IF yearend < 2000 THEN
    yearend = 2000
END IF
INPUT "Enter Month to finish at  : ", monthend
bargraph:
FOR i = 1 TO 70
    numb(i) = 0
    outpt(i) = 0
NEXT i
GOSUB convert
viewpoint$ = ""
graphmenu:
IF crs$ = "Y" THEN COLOR 1, 7
CLS
IF crs$ = "Y" THEN COLOR 3, 8
LOCATE 2, 6
PRINT CHR$(201)
FOR i = 7 TO 73
    LOCATE 2, i
    PRINT CHR$(205)
NEXT i
LOCATE 2, 74
PRINT CHR$(187)
FOR i = 3 TO 21
    LOCATE i, 6
    IF i = 4 OR i = 7 OR i = 12 OR i = 14 OR i = 20 THEN
        PRINT CHR$(204)
    ELSE
        PRINT CHR$(186)
    END IF
    LOCATE i, 74
    IF i = 4 OR i = 7 OR i = 12 OR i = 14 OR i = 20 THEN
        PRINT CHR$(185)
    ELSE
        PRINT CHR$(186)
    END IF
NEXT i
LOCATE 22, 6
PRINT CHR$(200)
LOCATE 22, 74
PRINT CHR$(188)
FOR i = 7 TO 73
    LOCATE 22, i
    PRINT CHR$(205)
NEXT i
FOR i = 7 TO 73
    LOCATE 7, i
    PRINT CHR$(205)
NEXT i
FOR i = 7 TO 73
    LOCATE 12, i
    PRINT CHR$(205)
NEXT i
FOR i = 7 TO 73
    LOCATE 20, i
    PRINT CHR$(205)
NEXT i
FOR i = 7 TO 73
    LOCATE 14, i
    PRINT CHR$(205)
NEXT i
FOR i = 7 TO 73
    LOCATE 4, i
    PRINT CHR$(205)
NEXT i
LOCATE 4, 37
PRINT CHR$(203)
LOCATE 5, 37
PRINT CHR$(186)
LOCATE 6, 37
PRINT CHR$(186)
LOCATE 7, 37
PRINT CHR$(206)
LOCATE 8, 37
PRINT CHR$(186)
LOCATE 9, 37
PRINT CHR$(186)
LOCATE 10, 37
PRINT CHR$(186)
LOCATE 11, 37
PRINT CHR$(186)
LOCATE 12, 37
PRINT CHR$(202)
IF crs$ = "Y" THEN COLOR 4, 7
FOR i = 8 TO 11
    LOCATE i, 12
    PRINT "["
    IF crs$ = "Y" THEN COLOR 0, 7
    LOCATE i, 13
    PRINT CHR$(57 + i)
    IF crs$ = "Y" THEN COLOR 4, 7
    LOCATE i, 14
    PRINT "]"
NEXT i
FOR i = 8 TO 11
    LOCATE i, 42
    PRINT "["
    IF crs$ = "Y" THEN COLOR 0, 7
    LOCATE i, 43
    PRINT CHR$(61 + i)
    IF crs$ = "Y" THEN COLOR 4, 7
    LOCATE i, 44
    PRINT "]"
NEXT i
FOR i = 15 TO 19
    LOCATE i, 20
    PRINT "["
    IF crs$ = "Y" THEN COLOR 0, 7
    LOCATE i, 21
    PRINT CHR$(58 + i)
    IF crs$ = "Y" THEN COLOR 4, 7
    LOCATE i, 22
    PRINT "]"
NEXT i
IF crs$ = "Y" THEN COLOR 10, 5
LOCATE 3, 7
PRINT "          Barchart Menu            "
LOCATE 13, 7
PRINT "     Other Options Available       "
LOCATE 5, 7
IF crs$ = "Y" THEN COLOR 15, 3
PRINT "         Barcharts                  "
LOCATE 6, 7
IF crs$ = "Y" THEN COLOR 4, 7
LOCATE 21, 38
PRINT "["
LOCATE 21, 40
PRINT "]"
IF crs$ = "Y" THEN COLOR 1, 7
LOCATE 8, 17
PRINT "Low Numbers"
LOCATE 8, 47
PRINT "Low Numbers"
LOCATE 9, 17
PRINT "Average Numbers"
LOCATE 9, 47
PRINT "Average Numbers"
LOCATE 10, 17
PRINT "High Numbers"
LOCATE 10, 47
PRINT "High Numbers"
LOCATE 11, 17
PRINT "All Numbers"
LOCATE 11, 47
PRINT "All Numbers"
LOCATE 15, 25
PRINT "Change Graphics Mode"
LOCATE 19, 25
PRINT "Return To Main Menu"
LOCATE 21, 20
PRINT "Your Choice Is : "
LOCATE 21, 39
answer$ = ""
answer$ = INPUT$(1)
PRINT answer$
IF answer$ = "" OR answer$ = CHR$(27) THEN
    spec$ = "N"
    GOTO main
ELSEIF answer$ = "a" OR answer$ = "A" THEN
    viewpoint$ = "low"
    bonus$ = "Y"
    GOTO start3
ELSEIF answer$ = "b" OR answer$ = "B" THEN
    viewpoint$ = "average"
    GOTO start3
ELSEIF answer$ = "c" OR answer$ = "C" THEN
    viewpoint$ = "high"
    bonus$ = "Y"
    GOTO start3
ELSEIF answer$ = "d" OR answer$ = "D" THEN
    viewpoint$ = "all"
    GOTO start3
ELSEIF answer$ = "e" OR answer$ = "E" THEN
    viewpoint$ = "low"
    bonus$ = "N"
    GOTO start3
ELSEIF answer$ = "f" OR answer$ = "F" THEN
    viewpoint$ = "average"
    bonus$ = "N"
    GOTO start3
ELSEIF answer$ = "g" OR answer$ = "G" THEN
    viewpoint$ = "high"
    bonus$ = "N"
    GOTO start3
ELSEIF answer$ = "h" OR answer$ = "H" THEN
    viewpoint$ = "all"
    bonus$ = "N"
    GOTO start
ELSEIF answer$ = "k" OR answer$ = "K" THEN
    GOTO start3
ELSEIF answer$ = "l" OR answer$ = "L" THEN
    CHAIN "grmode"
ELSEIF answer$ = "m" OR answer$ = "M" OR answer$ = "" THEN
    spec$ = "no"
    GOTO main
END IF
start3:

FOR i = 1 TO 70
    outpt(i) = 0
NEXT i
FOR i = 1 TO 70
    outpt(i) = numb(i)
NEXT i
low = 200: high = 0
FOR i = 1 TO 70
    IF numb(i) < low THEN
        low = numb(i)
    END IF
    IF numb(i) > high THEN
        high = numb(i)
    END IF
NEXT i
spread = INT(high * .02)

IF grtype = 0 THEN
    CLS
    GOSUB asciidisplay
    GOTO graphmenu
END IF
_FULLSCREEN _STRETCH
FOR i = 1 TO 70
    cl = cl + 1: IF cl > 12 THEN cl = 1
    IF cl = 2 THEN cl = 8
    length = outpt(i) / barl
    IF viewpoint$ = "low" THEN
        title$ = " Numbers Least Drawn"
        IF outpt(i) > low + spread THEN
            length = 4
        END IF
    ELSEIF viewpoint$ = "average" THEN
        title$ = " Numbers Average Drawn"
        IF outpt(i) < low + spread OR outpt(i) > high - spread THEN
            length = 4
        END IF
    ELSEIF viewpoint$ = "high" THEN
        title$ = " Numbers Most Drawn"
        IF outpt(i) < high - spread THEN
            length = 4
        END IF
    ELSEIF viewpoint$ = "all" THEN
        title$ = " All Numbers Drawn"
        length = outpt(i) * barl
    END IF
    searchmenu:
    CLS
    IF crs$ = "Y" THEN COLOR 3, 8
    LOCATE 3, 10
    PRINT CHR$(201)
    FOR i = 11 TO 68
        LOCATE 3, i
        PRINT CHR$(205)
    NEXT i
    LOCATE 3, 69
    PRINT CHR$(187)
    FOR i = 4 TO 12
        LOCATE i, 10
        IF i = 5 OR i = 11 THEN
            PRINT CHR$(204)
        ELSE
            PRINT CHR$(186)
        END IF
        LOCATE i, 69
        IF i = 5 OR i = 11 THEN
            PRINT CHR$(185)
        ELSE
            PRINT CHR$(186)
        END IF
    NEXT i
    FOR i = 11 TO 68
        LOCATE 5, i
        PRINT CHR$(205)
    NEXT i
    FOR i = 11 TO 68
        LOCATE 11, i
        PRINT CHR$(205)
    NEXT i
    FOR i = 11 TO 68
        LOCATE 13, i
        PRINT CHR$(205)
    NEXT i
    LOCATE 13, 10
    PRINT CHR$(200)
    LOCATE 13, 69
    PRINT CHR$(188)
    IF crs$ = "Y" THEN COLOR 10, 5
    LOCATE 4, 11
    PRINT "      Search and Print Menu           "
    PRINT

    IF crs$ = "Y" THEN COLOR 4, 7
    FOR i = 6 TO 10
        LOCATE i, 17
        PRINT "["
        LOCATE i, 19
        PRINT "]"
    NEXT i
    IF crs$ = "Y" THEN COLOR 0, 7
    FOR i = 6 TO 10
        LOCATE i, 18
        PRINT CHR$(59 + i)
    NEXT i
    IF crs$ = "Y" THEN COLOR 1, 7
    LOCATE 6, 22
    PRINT "Search For Winning Numbers By Date"
    LOCATE 7, 22
    PRINT "Print Out List of Winning Numbers"
    LOCATE 8, 22
    PRINT "Check List of Numbers for Winners"
    LOCATE 9, 22
    PRINT "Scan Database for a series of Numbers"
    LOCATE 10, 22
    PRINT "Print lists from Frequency Calculator"
    LOCATE 12, 17
    PRINT "Your Choice Is: "
    LOCATE 12, 33
    answer$ = INPUT$(1)
    PRINT answer$
    IF answer$ = "a" OR answer$ = "A" THEN
        GOTO search
    ELSEIF answer$ = "b" OR answer$ = "B" THEN
        GOTO printmenu
    ELSEIF answer$ = "c" OR answer$ = "C" THEN
        GOTO checknumbers
    ELSEIF answer$ = "d" OR answer$ = "D" THEN
        GOTO specialcheck
    ELSEIF answer$ = "e" OR answer$ = "E" THEN
        GOTO freqprint
    ELSE
        GOTO main
    END IF
    GOTO main
    freqprint:
    OPEN "next.txt" FOR INPUT AS #1
    DO UNTIL EOF(1)
        INPUT #1, a$
        LPRINT a$
    LOOP
    CLOSE #1
    LPRINT CHR$(12)
    OPEN "freq.txt" FOR INPUT AS #1
    DO UNTIL EOF(1)
        INPUT #1, a$
        LPRINT a$
    LOOP
    CLOSE #1
    LINE (counter, wl)-(counter, wl - length), cl
    LINE (counter + 1, wl)-(counter + 1, wl - length), cl
    LINE (counter + 2, wl)-(counter + 2, wl - length), cl
    LINE (counter + 3, wl)-(counter + 3, wl - length), cl
    LINE (counter + 4, wl)-(counter + 4, wl - length), cl
    LINE (counter + 5, wl)-(counter + 5, wl - length), cl
    LINE (counter + 6, wl)-(counter + 6, wl - length), cl
    counter = counter + 8
NEXT i
PRINT
LOCATE 3, 4
PRINT "Frequency Distribution Chart  " + title$ + title2$
LOCATE 4, 4
PRINT "Covering the period from  "; month$(monthin); yearin; " to  "; month$(monthend); yearend
IF grmode$ = "HDMI" THEN
    LOCATE 21, 13
    PRINT "0000000001111111111222222222233333333334444444444555555555566666666667"
    LOCATE 22, 13
    PRINT "1234567890123456789012345678901234567890123456789012345678901234567890"
ELSEIF grmode$ = "vga" THEN
    LOCATE 21, 13
    PRINT "0000000001111111111222222222233333333334444444444555555555566666666667"
    LOCATE 22, 13
    PRINT "1234567890123456789012345678901234567890123456789012345678901234567890"

END IF
LOCATE 7 - offset - 1, 10
PRINT "1000"
LOCATE 7 - offset - 1, 63
PRINT "1000"
LOCATE 10 - offset, 10
PRINT "800"
LOCATE 10 - offset, 63
PRINT "800"
LOCATE 13 - offset, 10
PRINT "600"
LOCATE 13 - offset, 63
PRINT "600"
LOCATE 16 - offset, 10
PRINT "400"
LOCATE 16 - offset, 63
PRINT "400"
LOCATE 19 - offset, 10
PRINT "200"
LOCATE 19 - offset, 63
PRINT "200"
IF grmode$ = "HDMI" THEN
    LOCATE 23, 22
ELSEIF grmode$ = "vga" THEN
    LOCATE 23, 22
END IF
PRINT "Press any key to continue ...."
DO WHILE INKEY$ = ""
LOOP
viewpoint$ = "": normal$ = "": bonus$ = ""
SCREEN 0
GOTO graphmenu
GOTO main
specialcheck:
bypass$ = ""
CLS
PRINT "This section checks for patterns in winning numbers. You can choose"
PRINT "to search either the last 3 months of the database, or the whole "
PRINT "database for any sets of numbers that you input."
PRINT
PRINT "Any matches will be printed out as the program runs ...."
PRINT
INPUT "Do you wish to load numbers from a saved file [ Enter defaults to Yes ]: ", saved$
IF saved$ = "" THEN
    saved$ = "Y"
END IF
IF saved$ = "n" OR saved$ = "N" THEN
    saved$ = "N"
    GOTO search2
END IF
filename:
INPUT "Enter filename [without extension] [Enter Defaults to Demo File] : ", file$
IF file$ = "numbers2" THEN
    PRINT
    PRINT "Incorrect filename !"
    PRINT
    PRINT "Press any key to continue ...."
    DO WHILE INKEY$ = ""
    LOOP
    GOTO filename
ELSEIF file$ = "grmode" THEN
    PRINT
    PRINT "Incorrect filename !"
    PRINT
    PRINT "Press any key to continue ...."
    DO WHILE INKEY$ = ""
    LOOP
    GOTO filename
ELSEIF file$ = "" THEN
    file$ = "demo"
    PRINT "Loading Demo File"
END IF
PRINT
file$ = file$ + ".cnf"
IF saved$ = "N" THEN GOTO savednumbers
IF saved$ = "Y" OR saved$ = "y" THEN
    saved$ = "Y"
    OPEN file$ FOR INPUT AS #1
    DO UNTIL EOF(1)
        INPUT #1, entry(zqa)
        zqa = zqa + 1
    LOOP
END IF
CLOSE #1
search2:
PRINT "Search [L]ast 3 months data or [E]ntire list of data "
PRINT
INPUT "[L] or [E] <return defaults to [L] > : ", answer$
IF answer$ = "e" OR answer$ = "E" THEN
    bypass$ = "Y"
    GOTO bypass
END IF
IF month > 3 THEN
    firstmonth = month - 3
    lastmonth = month
    firstyear = year
    lastyear = year
ELSEIF month < 4 THEN
    firstyear = year - 1
    lastyear = year
    monthadj = monthadj + 12
    firstmonth = monthadj - 3
    lastmonth = month
END IF
bypass:
IF saved$ = "Y" THEN GOTO savednumbers
savednumbers:
IF saved$ = "Y" OR saved$ = "y" THEN GOTO sc
INPUT "Do you wish to save the following numbers to disk : ", numsave$
IF numsave$ = "Y" OR numsave$ = "y" THEN
    numsave$ = "Y"
    filename2:
    INPUT "Enter filename [without extension] [Enter Defaults to Demo File]: ", file$
    IF file$ = "numbers2" THEN
        PRINT "Incorrect filename !"
        PRINT

        PRINT "Press any key to continue ...."
        DO WHILE INKEY$ = ""
        LOOP
        GOTO filename2
    ELSEIF file$ = "grmode" THEN
        PRINT
        PRINT "Incorrect filename !"
        PRINT
        PRINT "Press any key to continue ...."
        DO WHILE INKEY$ = ""
        LOOP
        GOTO filename2
    END IF
    file$ = file$ + ".cnf"
    PRINT
    OPEN file$ FOR OUTPUT AS #1
END IF
IF numsave$ = "N" THEN GOTO sc
za = 0: zb = 0: zc = 0: zd = 0: ze = 0: zf = 0: zg = 0: zh = 0: zi = 0: zj = 0: zk = 0: zl = 0: zm = 0: zn = 0: zo = 0: z0 = 0: zq = 0: zq = 0: zr = 0: zs = 0: zt = 0
INPUT "How many Numbers : ", numbrs
IF numbrs > 50 THEN
    PRINT "50 Is The Limit of numbers that you can buy."
END IF
FOR zqa = 1 TO numbrs
    rd2:
    IF saved$ = "Y" THEN
        GOTO szc
    END IF
    PRINT "Entry #"; zqa; " ";: INPUT ":", entry(zqa)
    IF entry(zqa) < 1 OR entry(zqa) > 70 THEN PRINT "Number Out of Range ! , Try Again !!": GOTO rd2
    IF zqa > 1 THEN
        FOR i = 1 TO (zqa - 1)
            IF entry(zqa) = entry(i) THEN PRINT "Number already entered, pick another": GOTO rd2
        NEXT i
    END IF
    IF numsave$ = "Y" THEN
        PRINT #1, entry(zqa)
    END IF
NEXT zqa
CLOSE #1

sc:
szc:
za = entry(1): zb = entry(2): zc = entry(3): zd = entry(4): ze = entry(5): zf = entry(6): zg = entry(7): zh = entry(8): zi = entry(9): zj = entry(10): zk = entry(11): zl = entry(12): zm = entry(13): zn = entry(14): zo = entry(15): zp = entry(16): zq = entry(17): zr = entry(18): zs = entry(19): zt = entry(20)
PRINT "Press any key to start search ...."
DO WHILE INKEY$ = ""
LOOP
CLS
PRINT
PRINT "Searching , please stand bye ............."
PRINT
FOR i = 1 TO linecounter
    IF bypass$ = "Y" THEN
        GOTO bypass2
    END IF
    IF chart(i, 3) < firstyear THEN GOTO sczzz
    IF chart(i, 1) < firstmonth AND chart(i, 3) = firstyear THEN GOTO sczzz
    bypass2:
    FOR j = 4 TO 20
        IF chart(i, j) = za OR chart(i, j) = zb OR chart(i, j) = zc OR chart(i, j) = zd OR chart(i, j) = ze OR chart(i, j) = zf OR zg = chart(i, j) OR zh = chart(i, j) OR zi = chart(i, j) OR zj = chart(i, j) OR zk = chart(i, j) OR zk = chart(i, j) OR zl = chart(i, j) OR zm = chart(i, j) OR zn = chart(i, j) OR zo = chart(i, j) OR zp = chart(i, j) OR zq = chart(i, j) OR zr = chart(i, j) OR zs = chart(i, j) OR zt = chart(i, j) THEN
            match = match + 1
        END IF
    NEXT j
    IF match > 2 THEN
        PRINT "Match for : ";
        PRINT USING ""; month$(chart(i, 1));
        PRINT USING "## #### ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; chart(i, 2); chart(i, 3); chart(i, 4); chart(i, 5); chart(i, 6); chart(i, 7); chart(i, 8); chart(i, 9); chart(i, 10); chart(i, 11); chart(i, 12); chart(i, 13); chart(i, 14); chart(i, 15); chart(i, 16); chart(i, 17); chart(i, 18); chart(i, 19); chart(i, 20);
        PRINT "  > "; match; " Correct."
        IF hardcopy$ = "Y" THEN LPRINT "Match for : ";
        LPRINT USING "\    \"; month$(chart(i, 1));
        LPRINT USING "## #### ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; chart(i, 2); chart(i, 3); chart(i, 4); chart(i, 5); chart(i, 6); chart(i, 7); chart(i, 8); chart(i, 9); chart(i, 10); chart(i, 11); chart(i, 12); chart(i, 13); chart(i, 14); chart(i, 15); chart(i, 16); chart(i, 17); chart(i, 18); chart(i, 19); chart(i, 20);
        LPRINT "  > "; match; " Correct."
    END IF
    match = 0
    found = found + 1
    match = 0
    sczzz:
NEXT i
IF found = 0 THEN
    PRINT
    PRINT "No Match found for your numbers"
    PRINT
    PRINT "Your numbers were : ";
    LPRINT "Your numbers were : ";
    FOR i = 1 TO 20
        IF entry(i) = 0 THEN GOTO nopr1
        PRINT entry(i);
        LPRINT entry(i);
    NEXT i
    nopr1:
    PRINT
    LPRINT

ELSE
    PRINT
    PRINT found; " Matches found for your numbers"
    PRINT
    PRINT "Your numbers were : ";
    FOR i = 1 TO 14
        IF entry(i) = 0 THEN
            GOTO nopr2
        END IF
        PRINT entry(i);
    NEXT i
    nopr2:
    PRINT
END IF
IF hardcopy$ = "Y" AND found > 0 THEN
    LPRINT
    LPRINT "Program written by : Russ Campbell"
    LPRINT
    LPRINT CHR$(12)
END IF
     
found = 0
PRINT
PRINT "Press any key to continue ..."
DO WHILE INKEY$ = ""
LOOP
GOTO main
checknumbers:
CLS
PRINT
PRINT "Winning Number Check"
PRINT
PRINT "This section of the program will take a file that you have written"
PRINT "out from option C or D and check to see if you have any winning "
PRINT "numbers in the file."
PRINT
PRINT "You can either enter the numbers manually or read them in from"
PRINT "the winning numbers database."
PRINT
INPUT "Enter filename [without extension] : "; file$
IF file$ = "numbers2" THEN
    PRINT
    PRINT "Incorrect filename !"
    PRINT
    PRINT "Press any key to continue ...."
    DO WHILE INKEY$ = ""
    LOOP
    GOTO checknumbers
ELSEIF file$ = "" THEN
    GOTO searchmenu
END IF

PRINT
PRINT
INPUT "Get numbers Manually or Read from database [M] or [R] : "; answer$
IF answer$ = "r" OR answer$ = "R" THEN
    GOTO inq
ELSEIF answer$ = "M" OR answer$ = "m" THEN
    GOTO manent
ELSE
    GOTO checknumbers
END IF
inq:
INPUT "Enter year of draw  : "; yearinp
IF yearinp < 2000 THEN
    GOTO main
END IF
INPUT "Enter month of draw : "; monthinp
INPUT "Enter day of draw   : "; dayinp
PRINT
PRINT "Date of Draw        : "; month$(monthinp); dayinp; yearinp
PRINT
INPUT "Is this correct ??? "; answer$
PRINT
IF answer$ = "N" OR answer$ = "n" OR answer$ = "no" OR answer$ = "NO" OR answer$ = "nO" OR answer$ = "No" THEN
    GOTO inq
END IF
IF answer$ = "" THEN
    GOTO searchmenu
END IF
FOR i = 1 TO linecounter
    IF chart(i, 3) <> yearinp THEN
        GOTO nextitem2
    ELSEIF chart(i, 1) <> monthinp THEN
        GOTO nextitem2
    ELSEIF chart(i, 2) <> dayinp THEN
        GOTO nextitem2
    ELSEIF chart(i, 3) = yearinp AND chart(i, 1) = monthinp AND chart(i, 2) = dayinp THEN
        search = 1
        PRINT
        PRINT USING "Winning Numbers  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; chart(i, 4); chart(i, 5); chart(i, 6); chart(i, 7); chart(i, 8); chart(i, 9); char(i, 10); chart(i, 11); chart(i, 12); chart(i, 13); chart(i, 14); chart(i, 15); chart(i, 16); chart(i, 17); chart(i, 18); chart(i, 19); chart(i, 20); chart(i, 21); chart(i, 22); chart(i, 23)
        PRINT
        INPUT "Is this Correct <return defaults yes> [Y]es or [N]o : "; answer$
        IF answer$ = "N" OR answer$ = "n" OR answer$ = "NO" OR answer$ = "no" OR answer$ = "No" OR answer$ = "nO" THEN
            GOTO inq
        END IF
        ac = chart(i, 4)
        bc = chart(i, 5)
        cc = chart(i, 6)
        dc = chart(i, 7)
        ec = chart(i, 8)
        fc = chart(i, 9)
        gc = chart(i, 10)
        hc = chart(i, 11)
        ic = chart(i, 12)
        jc = chart(i, 13)
        kc = chart(i, 14)
        lc = chart(i, 15)
        mc = chart(i, 16)
        nc = chart(i, 17)
        oc = chart(i, 18)
        pc = chart(i, 19)
        qc = chart(i, 20)
        rc = chart(i, 21)
        sc = chart(i, 22)
        tc = chart(i, 23)

    END IF
    nextitem2:
NEXT i
IF search = 0 THEN
    PRINT
    PRINT "Draw not found"
    PRINT
    PRINT "Either use manual entry or ensure that correct data"
    PRINT "has been entered with main menu option A"
    PRINT
    PRINT "Press any key to Continue ...."
    DO WHILE INKEY$ = ""
    LOOP
    CLOSE #2
    GOTO searchmenu
END IF
search = 0
GOTO reedfiles
manent:
CLS
PRINT
PRINT "Winning Numbers Entry"
PRINT
PRINT "This option is only for checking winning numbers, it does NOT"
PRINT "update the numbers database. Use option A from the main menu"
PRINT "if you want to update the database."
PRINT
FOR zqa = 1 TO 20
    rd1:
    PRINT "Entry #"; zqa; " ";: INPUT entry(zqa)
    IF entry(zqa) = 0 THEN GOTO searchmenu
    IF entry(zqa) < 1 OR entry(zqa) > 70 THEN PRINT "Number Out of Range ! , Try Again !!": GOTO rd1
    IF zqa > 1 THEN
        FOR i = 1 TO (zqa - 1)
            IF entry(zqa) = entry(i) THEN PRINT "Number already entered, pick another": GOTO rd1
        NEXT i
    END IF
NEXT zqa

ac = entry(1): bc = entry(2): cc = entry(3): dc = entry(4): ec = entry(5): fc = entry(6): gc = entry(7): hc = entry(8): ic = entry(9): jc = entry(10)
kc = entry(11): lc = entry(12): mc = entry(13): nc = entry(14): oc = entry(15): pc = entry(16): qc = entry(17): rc = entry(18): sc = entry(19): tc = entry(20)
reedfiles:
file$ = file$ + ".dat"
OPEN file$ FOR INPUT AS #2
CLS
linecount = 0
DO UNTIL EOF(2)
    INPUT #2, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    IF a = ac OR a = bc OR a = cc OR a = dc OR a = ec OR a = fc OR a = gc OR a = hc OR a = hc OR a = ic OR a = jc OR a = kc OR a = lc OR a = mc OR a = nc OR a = oc OR a = pc OR a = qc OR a = rc OR a = sc OR a = tc THEN
        winnings = winnings + 1
    END IF
    IF b = ac OR b = bc OR b = cc OR b = dc OR b = ec OR b = fc OR b = gc OR b = hc OR b = hc OR b = ic OR b = jc OR b = kc OR b = lc OR b = mc OR b = nc OR b = oc OR b = pc OR b = qc OR b = rc OR b = sc OR b = tc THEN
        winnings = winnings + 1
    END IF
    IF c = ac OR c = bc OR c = cc OR c = dc OR c = ec OR c = fc OR c = gc OR c = hc OR c = ic OR c = jc OR c = kc OR c = lc OR c = mc OR c = nc OR c = oc OR c = pc OR c = qc OR c = rc OR c = sc OR c = tc THEN
        winnings = winnings + 1
    END IF
    IF d = ac OR d = bc OR d = cc OR d = dc OR d = ec OR d = fc OR d = gc OR d = hc OR d = ic OR d = jc OR d = kc OR d = lc OR d = mc OR d = nc OR d = oc OR d = pc OR d = qc OR d = rc OR d = sc OR d = tc THEN
        winnings = winnings + 1
    END IF
    IF e = ac OR e = bc OR e = cc OR e = dc OR e = ec OR e = fc OR e = gc OR e = hc OR e = ic OR e = jc OR e = kc OR e = lc OR e = mc OR e = nc OR e = oc OR e = pc OR e = qc OR e = rc OR e = sc OR e = tc THEN
        winnings = winnings + 1
    END IF
    IF f = ac OR f = bc OR f = cc OR f = dc OR f = ec OR f = fc OR f = gc OR f = hc OR f = ic OR f = jc OR f = kc OR f = lc OR f = mc OR f = nc OR f = oc OR f = pc OR f = qc OR f = rc OR f = sc OR f = tc THEN
        winnings = winnings + 1
    END IF
    IF g = ac OR g = bc OR g = cc OR g = dc OR g = ec OR g = fc OR g = gc OR g = hc OR g = ic OR g = jc OR g = kc OR g = lc OR g = mc OR g = nc OR g = oc OR g = pc OR g = qc OR g = rc OR g = sc OR g = tc THEN
        winnings = winnings + 1
    END IF
    IF h = ac OR h = bc OR h = cc OR h = dc OR h = ec OR h = fc OR h = gc OR h = hc OR h = ic OR h = jc OR h = kc OR h = lc OR h = mc OR h = nc OR h = oc OR h = pc OR h = qc OR h = rc OR b = sc OR h = tc THEN
        winnings = winnings + 1
    END IF
    IF i = ac OR i = bc OR i = cc OR i = dc OR i = ec OR i = fc OR i = gc OR i = hc OR i = ic OR i = jc OR i = kc OR i = lc OR i = mc OR i = nc OR i = oc OR i = pc OR i = qc OR i = rc OR i = sc OR i = tc THEN
        winnings = winnings + 1
    END IF
    IF j = ac OR j = bc OR j = cc OR i = dc OR i = ec OR i = fc OR j = gc OR j = hc OR j = ic OR j = jc OR j = kc OR j = lc OR j = mc OR j = nc OR j = oc OR j = pc OR j = qc OR j = rc OR j = sc OR j = tc THEN
        winnings = winnings + 1
    END IF
    IF k = ac OR k = bc OR k = cc OR k = dc OR k = ec OR k = fc OR k = gc OR k = hc OR k = ic OR k = jc OR k = kc OR k = lc OR k = mc OR k = nc OR k = oc OR k = pc OR k = qc OR k = rc OR k = sc OR k = tc THEN
        winnings = winnings + 1
    END IF
    IF l = ac OR l = bc OR l = cc OR l = dc OR l = ec OR l = fc OR l = gc OR l = hc OR l = ic OR l = jc OR l = kc OR l = lc OR l = mc OR l = nc OR l = oc OR l = pc OR l = qc OR l = rc OR l = sc OR l = tc THEN
        winnings = winnings + 1
    END IF
    IF m = ac OR m = bc OR m = cc OR m = dc OR m = ec OR m = fc OR m = gc OR m = hc OR m = ic OR m = jc OR m = kc OR m = lc OR m = mc OR m = nc OR m = oc OR m = pc OR m = qc OR m = rc OR m = sc OR m = tc THEN
        winnings = winnings + 1
    END IF
    IF n = ac OR n = bc OR n = cc OR n = dc OR n = ec OR n = fc OR n = gc OR n = hc OR n = ic OR n = jc OR n = kc OR n = lc OR n = mc OR n = nc OR n = oc OR n = pc OR n = qc OR n = rc OR n = sc OR n = tc THEN
        winnings = winnings + 1
    END IF
    IF o = ac OR o = bc OR o = cc OR o = dc OR o = ec OR o = fc OR o = gc OR o = hc OR o = ic OR o = jc OR o = kc OR o = lc OR o = mc OR o = nc OR o = oc OR o = pc OR o = qc OR o = rc OR o = sc OR o = tc THEN
        winnings = winnings + 1
    END IF
    IF p = ac OR p = bc OR p = cc OR p = dc OR p = ec OR p = fc OR p = gc OR p = hc OR p = ic OR p = jc OR p = kc OR p = lc OR p = mc OR p = nc OR p = oc OR p = pc OR p = qc OR p = rc OR p = sc OR p = tc THEN
        winnings = winnings + 1
    END IF
    IF q = ac OR q = bc OR q = cc OR q = dc OR q = ec OR q = fc OR q = gc OR q = hc OR q = ic OR q = jc OR q = kc OR q = lc OR q = mc OR q = nc OR q = oc OR q = pc OR q = qc OR q = rc OR q = sc OR q = tc THEN
        winnings = winnings + 1
    END IF
    IF r = ac OR r = bc OR r = cc OR r = dc OR r = ec OR r = fc OR r = gc OR r = hc OR r = ic OR r = jc OR r = kc OR r = lc OR r = mc OR r = nc OR r = oc OR r = pc OR r = qc OR r = rc OR r = sc OR r = tc THEN
        winnings = winnings + 1
    END IF
    IF s = ac OR s = bc OR s = cc OR s = dc OR s = ec OR s = fc OR s = gc OR s = hc OR s = ic OR s = jc OR s = kc OR s = lc OR s = mc OR s = nc OR s = oc OR s = pc OR s = qc OR s = rc OR s = sc OR s = tc THEN
        winnings = winnings + 1
    END IF
    IF t = ac OR t = bc OR t = cc OR t = dc OR t = ec OR t = fc OR t = gc OR t = hc OR t = ic OR t = jc OR t = kc OR t = lc OR t = mc OR t = nc OR t = oc OR t = pc OR t = qc OR t = rc OR t = sc OR t = tc THEN
        winnings = winnings + 1
    END IF



    linecount = linecount + 1
    IF winnings = 3 THEN
        PRINT USING "You have 3 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 4 THEN
        PRINT USING "You have 4 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 5 THEN
        PRINT USING "You have 5 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 6 THEN
        PRINT USING "You have 6 numbers correct in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    linecount = linecount + 1
    IF winnings = 7 THEN
        PRINT USING "You have 7 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 8 THEN
        PRINT USING "You have 8 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 9 THEN
        PRINT USING "You have 9 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 10 THEN
        PRINT USING "You have 10 numbers correct in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    linecount = linecount + 1
    IF winnings = 11 THEN
        PRINT USING "You have 11 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 12 THEN
        PRINT USING "You have 12 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 13 THEN
        PRINT usung; "You have 13 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 14 THEN
        PRINT USING "You have 14 numbers correct in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    linecount = linecount + 1
    IF winnings = 15 THEN
        PRINT USING "You have 15 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 16 THEN
        PRINT USING "You have 16 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 17 THEN
        PRINT USING "You have 17 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 18 THEN
        PRINT USING "You have 18 numbers correct in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    linecount = linecount + 1
    IF winnings = 19 THEN
        PRINT USING "You have 19 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF
    IF winnings = 20 THEN
        PRINT USING "You have ALL 20 correct numbers in line #####"; linecount
        correctnum = correctnum + 1
    END IF


    IF hardcopy$ = "Y" AND winnings > 3 THEN
        LPRINT "Line # "; linecount; ">= ";
        LPRINT USING "## ## ## ## ## ## ##"; a; b; c; d; e; f; g; h; i; j; k; l; m; n; o; p; q; r; s; t
        LPRINT "    > "; winnings; "  Correct."
    END IF
    winnings = 0
LOOP
PRINT "You had a total of "; correctnum; " possible winners in that file."
PRINT "Check your printout, diskfile or tickets for more info."
IF hardcopy$ = "Y" AND correctnum > 0 THEN
    LPRINT
    LPRINT "Program Written by : Russ Campbell"
    LPRINT
    LPRINT CHR$(12)
END IF
correctnum = 0
PRINT
PRINT USING "The winning numbers were : ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; ac; bc; cc; dc; ec; fc; gc; hc; ic; jc; lc; mc; nc; oc; pc; qc; rc; sc; tc
PRINT
PRINT "Press any key to continue ....."
PRINT
DO WHILE INKEY$ = ""
LOOP
CLOSE #2
GOTO searchmenu
enter:
OPEN "keno midday.dat" FOR APPEND AS #1
beginning:
CLS
PRINT
PRINT "Daily Keno Package Version 2019 Winning Numbers Entry"
PRINT "----------------------------------------------------"
PRINT
PRINT "This section allows you to enter winning numbers from each draw."
PRINT "It then stores the numbers in a database for use with the chart"
PRINT "used in section B."
PRINT
PRINT "Date last updated    : "; month$; day; year
PRINT "Last numbers entered : "; a; b; c; d; e; f; g; h; i; j; k; l; m; n; o; p; q; r; s; t
PRINT
year:
INPUT "Enter Year  : ", year
IF year < 2018 THEN
    CLOSE #1: GOTO main
END IF
IF year = 0 THEN CLOSE #1: GOTO main
month:
INPUT "Enter Month : ", month
IF month = 0 THEN CLOSE #1: GOTO main
IF month < 1 OR month > 12 THEN
    PRINT "Month out of range !": GOTO month
END IF
month$ = month$(month)
day:
INPUT "Enter Day   : ", day
IF day < 1 OR day > 31 THEN
    PRINT "Day out of range!": GOTO day
END IF


PRINT
first:
INPUT "Enter 1st number   : ", a
IF a = 0 THEN CLOSE #1: GOTO main
IF a < 1 OR a > 70 THEN PRINT "Number Out of range !": GOTO first

second:
INPUT "Enter 2nd number   : ", b
IF b < 1 OR b > 70 THEN PRINT "Number Out of Range !": GOTO second
IF b = a THEN PRINT "Number already picked!": GOTO second

third:
INPUT "Enter 3rd number   : ", c
IF c < 1 OR c > 70 THEN PRINT "Number Out of Range !": GOTO third
IF c = b OR c = a THEN PRINT "Number already picked!": GOTO third

fourth:
INPUT "Enter 4th number   : ", d
IF d < 1 OR d > 70 THEN PRINT "Number Out of Range !": GOTO fourth
IF d = c OR d = b OR d = a THEN PRINT "Number already picked!": GOTO fourth

fifth:
INPUT "Enter 5th number   : ", e
IF e < 1 OR e > 70 THEN PRINT "Number Out of Range !": GOTO fifth
IF e = d OR e = c OR e = b OR e = a THEN PRINT "Number already picked!": GOTO fifth

sixth:
INPUT "Enter 6th number   : ", f
IF f < 1 OR f > 70 THEN PRINT "Number Out of Range !": GOTO sixth
IF f = e OR f = d OR f = c OR f = b OR f = a THEN PRINT "Number already picked!": GOTO sixth

seventh:
INPUT "Enter 7th number : ", g
IF g < 1 OR g > 70 THEN PRINT "Number Out of Range !": GOTO seventh
IF g = f OR g = e OR g = d OR g = c OR g = b OR g = a THEN PRINT "Number already picked !": GOTO seventh

eighth:
INPUT "Enter 8th number   : ", h
IF h < 1 OR h > 70 THEN PRINT "Number Out of range !": GOTO eighth
IF h = g OR h = f OR h = e OR h = d OR h = c OR h = b OR h = a THEN PRINT "Number already picked !": GOTO eighth

nineth:
INPUT "Enter 9th number   : ", i
IF i < 1 OR i > 70 THEN PRINT "Number Out of Range !": GOTO nineth
IF i = h OR i = g OR i = f OR i = e OR i = d OR i = c OR i = b OR i = a THEN PRINT "Number already picked !": GOTO nineth

tenth:
INPUT "Enter 10th number   : ", j
IF j < 1 OR j > 70 THEN PRINT "Number Out of Range !": GOTO tenth
IF j = i OR j = h OR j = g OR j = f OR j = e OR j = d OR j = c OR j = b OR j = a THEN PRINT "Number already picked !": GOTO tenth

eleventh:
INPUT "Enter 11th number   : ", k
IF k < 1 OR k > 70 THEN PRINT "Number Out of Range !": GOTO eleventh
IF k = j OR k = i OR k = h OR k = g OR k = f OR k = e OR k = d OR k = c OR k = b OR k = a THEN PRINT "Number already picked !": GOTO eleventh

twelfth:
INPUT "Enter 12th number   : ", l
IF l < 1 OR l > 70 THEN PRINT "Number Out of Range !": GOTO twelfth
IF l = k OR l = j OR l = i OR l = h OR l = g OR l = f OR l = e OR l = d OR l = c OR l = b OR l = a THEN PRINT "Number already picked!": GOTO twelfth

thirteenth:
INPUT "Enter 13th number   : ", m
IF m < 1 OR m > 70 THEN PRINT "Number Out of Range !": GOTO thirteenth
IF m = l OR m = k OR m = j OR m = i OR m = h OR m = g OR m = f OR m = e OR m = d OR m = c OR m = b OR m = a THEN PRINT "Number already picked!": GOTO thirteenth

fourteenth:
INPUT "Enter 14th number   : ", n
IF n < 1 OR n > 70 THEN PRINT "Number Out of Range !": GOTO fourteenth
IF n = m OR n = l OR n = k OR n = j OR n = i OR n = h OR n = g OR n = f OR n = e OR n = d OR n = c OR n = b OR n = a THEN PRINT "Number already picked !": GOTO fourteenth

fifteenth:
INPUT "Enter 15th number   : ", o
IF o < 1 OR o > 70 THEN PRINT "Number Out of range !": GOTO fifteenth
IF o = n OR o = m OR o = l OR o = k OR o = j OR o = i OR o = h OR o = g OR o = f OR o = e OR o = d OR o = c OR o = b OR o = a THEN PRINT "Number Already picked!"

sixteenth:
INPUT "Enter 16th number   : ", p
IF p < 1 OR p > 70 THEN PRINT "Number Out of Range !": GOTO sixteenth
IF p = o OR p = n OR p = m OR p = l OR p = k OR p = j OR p = i OR p = h OR p = g OR p = f OR p = e OR p = d OR p = c OR p = b OR p = a THEN PRINT "Number already picked !": GOTO sixteenth

seventeenth:
INPUT "Enter 17th number   : ", q
IF q < 1 OR q > 70 THEN PRINT "Number Out of Range !": GOTO seventeenth
IF q = p OR q = o OR q = n OR q = m OR q = l OR q = k OR q = j OR q = i OR q = h OR q = g OR q = f OR q = e OR q = d OR q = c OR q = b OR q = a THEN PRINT "Number already picked !": GOTO seventeenth

eighteenth:
INPUT "Enter 18th number   : ", r
IF r < 1 OR r > 70 THEN PRINT "Number Out of Range !": GOTO eighteenth
IF r = q OR r = p OR r = o OR r = n OR r = m OR r = l OR r = k OR r = j OR r = i OR r = h OR r = g OR r = f OR r = e OR r = d OR r = c OR r = b OR r = a THEN PRINT "Number already picked !": GOTO eighteenth

nineteenth:
INPUT "Enter 19th number   : ", s
IF s < 1 OR s > 70 THEN PRINT "Number Out of Range !": GOTO nineteenth
IF s = i OR s = h OR s = g OR s = f OR s = e OR s = d OR s = c OR s = b OR s = a THEN PRINT "Number already picked !": GOTO nineteenth
IF s = r OR s = q OR s = p OR s = o OR s = n OR s = m OR s = l OR s = k OR s = j OR s = i OR s = h OR s = g OR s = f OR s = e OR s = d OR s = c OR s = b OR s = a THEN PRINT "Number already picked !": GOTO nineteenth
twentyeth:
INPUT "Enter 20th number   : ", t
IF t < 1 OR t > 70 THEN PRINT "Number Out of Range !": GOTO twentyeth
IF t = s OR t = r OR t = q OR t = p OR t = o OR t = n OR t = m OR t = l OR t = k OR t = j OR t = i OR t = h OR t = g OR t = f OR t = e OR t = d OR t = c OR t = b OR t = a THEN PRINT "Number already picked !": GOTO twentyeth

PRINT
INPUT "Is the above correct [Y]es  No  Quit [Y default] : "; answer$
IF answer$ = "" THEN answer$ = "Y"
IF answer$ = "n" OR answer$ = "N" OR answer$ = "no" OR answer$ = "NO" THEN GOTO beginning
IF answer$ = "Q" OR answer$ = "q" THEN CLOSE #1: GOTO main

PRINT #1, USING " ## ## #### ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##"; month; day; year; a; b; c; d; e; f; g; h; i; j; k; l; m; n; o; p; q; r; s; t
PRINT
INPUT "Any more winning numbers ??? [Y] or No [Y default] "; answer$
IF answer$ = "" THEN answer$ = "Y"
IF answer$ = "Y" OR answer$ = "y" THEN GOTO beginning

CLOSE #1
GOSUB buildchart
GOSUB convert
GOTO main
cleardata:
CLS
PRINT
PRINT "Initialize data files"
PRINT
PRINT "This option clears all of the data files for the winning Daily Keno"
PRINT "numbers. Are you sure you want to do this ??? "
PRINT
INPUT "Are you sure you want to do this [Y]es or [N]o : ", answer$
IF answer$ = "YES" OR answer$ = "Yes" OR answer$ = "yES" OR answer$ = "Y" OR answer$ = "y" THEN
    answer$ = "YES"
END IF
IF answer$ <> "YES" THEN
    GOTO main
ELSEIF answer$ = "YES" THEN
    OPEN "kenonumbers2.dat" FOR OUTPUT AS #1
    CLOSE #1
END IF
GOTO main
buildchart:
chartbuild = chartbuild + 1
chartcount = 62
linecounter = 0
ERASE chart
OPEN "keno midday.dat" FOR INPUT AS #1
DO UNTIL EOF(1)
    INPUT #1, month, day, year, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    chart(linecounter, 1) = month
    chart(linecounter, 2) = day
    chart(linecounter, 3) = year
    chart(linecounter, 4) = a
    chart(linecounter, 5) = b
    chart(linecounter, 6) = c
    chart(linecounter, 7) = d
    chart(linecounter, 8) = e
    chart(linecounter, 9) = f
    chart(linecounter, 10) = g
    chart(linecounter, 11) = h
    chart(linecounter, 12) = i
    chart(linecounter, 13) = j
    chart(linecounter, 14) = k
    chart(linecounter, 15) = l
    chart(linecounter, 16) = m
    chart(linecounter, 17) = n
    chart(linecounter, 18) = o
    chart(linecounter, 19) = p
    chart(linecounter, 20) = q
    chart(linecounter, 21) = r
    chart(linecounter, 22) = s
    chart(linecounter, 23) = t
    linecounter = linecounter + 1
LOOP
CLOSE #1
RESTORE monthread
FOR i = 1 TO 12
    READ month$(i)
NEXT i
monthread:
DATA "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
month$ = month$(month)
RETURN
convert:
FOR i = 1 TO linecounter
    IF spec$ = "Y" THEN
        IF chart(i, 3) < yearin THEN GOTO zqzq
        IF chart(i, 1) < monthin AND chart(i, 3) = yearin THEN GOTO zqzq
        IF chart(i, 3) > yearend THEN GOTO zqzq
        IF chart(i, 1) > monthend AND chart(i, 3) = yearend THEN GOTO zqzq
    END IF
    numb(chart(i, 4)) = numb(chart(i, 4)) + 1
    numb(chart(i, 5)) = numb(chart(i, 5)) + 1
    numb(chart(i, 6)) = numb(chart(i, 6)) + 1
    numb(chart(i, 7)) = numb(chart(i, 7)) + 1
    numb(chart(i, 8)) = numb(chart(i, 8)) + 1
    numb(chart(i, 9)) = numb(chart(i, 9)) + 1
    numb(chart(i, 10)) = numb(chart(i, 10)) + 1
    numb(chart(i, 11)) = numb(chart(i, 11)) + 1
    numb(chart(i, 12)) = numb(chart(i, 12)) + 1
    numb(chart(i, 13)) = numb(chart(i, 13)) + 1
    numb(chart(i, 14)) = numb(chart(i, 14)) + 1
    numb(chart(i, 15)) = numb(chart(i, 15)) + 1
    numb(chart(i, 16)) = numb(chart(i, 16)) + 1
    numb(chart(i, 17)) = numb(chart(i, 17)) + 1
    numb(chart(i, 18)) = numb(chart(i, 18)) + 1
    numb(chart(i, 19)) = numb(chart(i, 19)) + 1
    numb(chart(i, 20)) = numb(chart(i, 20)) + 1
    numb(chart(i, 21)) = numb(chart(i, 21)) + 1
    numb(chart(i, 22)) = numb(chart(i, 22)) + 1
    numb(chart(i, 23)) = numb(chart(i, 23)) + 1
    zqzq:
NEXT i
IF spec$ = "N" THEN
    yearin = chart(i, 3)
    yearend = chart(linecounter, 3)
    monthin = chart(i, 1)
    monthend = chart(linecounter, 1)
END IF
RETURN
printmenu:
CLS
IF crs$ = "Y" THEN COLOR 10, 5

LOCATE 4, 18
PRINT "          Daily Keno Version 2019 Print Menu          "
PRINT
IF crs$ = "Y" THEN COLOR 3, 8
LOCATE 3, 17
PRINT CHR$(201)
FOR i = 18 TO 57
    LOCATE 3, i
    PRINT CHR$(205)
NEXT i
LOCATE 3, 58
PRINT CHR$(187)
FOR i = 18 TO 57
    LOCATE 5, i
    PRINT CHR$(205)
NEXT i
FOR i = 18 TO 57
    LOCATE 9, i
    PRINT CHR$(205)
NEXT i
FOR i = 18 TO 57
    LOCATE 11, i
    PRINT CHR$(205)
NEXT i
LOCATE 11, 17
PRINT CHR$(200)
LOCATE 11, 58
PRINT CHR$(188)
FOR i = 4 TO 10
    LOCATE i, 17
    IF i = 5 OR i = 9 THEN
        PRINT CHR$(204)
    ELSE
        PRINT CHR$(186)
    END IF
    LOCATE i, 58
    IF i = 5 OR i = 9 THEN
        PRINT CHR$(185)
    ELSE
        PRINT CHR$(186)
    END IF
NEXT i
IF crs$ = "Y" THEN COLOR 4, 7
FOR i = 6 TO 8
    LOCATE i, 27
    PRINT "["
    LOCATE i, 28
    IF crs$ = "Y" THEN COLOR 0, 7
    PRINT CHR$(59 + i)
    IF crs$ = "Y" THEN COLOR 4, 7
    LOCATE i, 29
    PRINT "]"
NEXT i
LOCATE 10, 45
PRINT "["
LOCATE 10, 47
PRINT "]"
IF crs$ = "Y" THEN COLOR 1, 7
LOCATE 6, 31
PRINT "Print Entire List"
LOCATE 7, 31
PRINT "Print Partial List"
LOCATE 8, 31
PRINT "Goto Search Menu"
LOCATE 10, 27
PRINT "Your Choice is:"
LOCATE 10, 46
answer$ = INPUT$(1)
PRINT answer$
IF answer$ = "a" OR answer$ = "A" THEN
    monthin = 1
    monthend = 12
    yearin = 2000
    yearend = 3000
    GOTO printentirelist
ELSEIF answer$ = "b" OR answer$ = "B" THEN
    monthin = 1
    monthend = 12
    yearin = 2000
    yearend = 3000
    GOTO printpartial
ELSEIF answer$ = "c" OR answer$ = "C" OR answer$ = "" THEN
    GOTO searchmenu
ELSE
    GOTO searchmenu
END IF
printpartial:
CLS
PRINT
PRINT "Printing Partial List of winning numbers."
partial = 1
PRINT
INPUT "Start  Month: ", monthin
IF monthin = 0 THEN GOTO main
IF monthin < 1 OR monthin > 12 THEN
    GOTO printpartial
END IF
INPUT "Start  Year [All 4 digits] : ", yearin
IF yearin = 0 THEN
    GOTO main
END IF
INPUT "Finish Month: ", monthend
IF monthend = 0 THEN
    GOTO main
END IF
IF monthend < 1 OR monthend > 12 THEN
    GOTO printpartial
END IF
INPUT "Ending Year [All 4 digits] : ", yearend
IF yearend = 0 THEN
    GOTO main
END IF
printentirelist:
IF partial <> 0 THEN GOTO lister
PRINT
PRINT "Printing Entire List of winning numbers."
PRINT
lister:
IF hardcopy$ = "Y" THEN
    LPRINT
    LPRINT "List of Daily Keno Winning Numbers"
    LPRINT "---------------------------------"
    LPRINT
    LPRINT "|Month|Date|Year|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|"
    LPRINT "|-----|----|----|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|"
    LPRINT
    pat$ = "|   ##|  ##|####|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|"
    FOR i = 1 TO linecounter
        IF chart(i, 3) < yearin THEN GOTO qzqz
        IF chart(i, 1) < monthin AND chart(i, 3) = yearin THEN GOTO qzqz
        IF chart(i, 3) > yearend THEN GOTO qzqz
        IF chart(i, 1) > monthend AND chart(i, 3) = yearend THEN GOTO qzqz
        LPRINT USING pat$; chart(i, 1); chart(i, 2); chart(i, 3); chart(i, 4); chart(i, 5); chart(i, 6); chart(i, 7); chart(i, 8); chart(i, 9); chart(i, 10); chart(i, 11); chart(i, 12); chart(i, 13); chart(i, 14); chart(i, 14); chart(i, 15); chart(i, 16); chart(i, 17); chart(i, 18); chart(i, 19); chart(i, 20); chart(i, 21); chart(i, 22); chart(i, 23)
        qzqz:
    NEXT i
END IF
CLS
PRINT
PRINT "List of Daily Keno Winning Numbers"
PRINT "---------------------------------"
PRINT
PRINT "Month|Day|Year|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|"
PRINT "-----|---|----|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|"
PRINT
pat$ = "   ##| ##|####|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|##|"
FOR i = 1 TO linecounter
    linecounter = linecounter + 1
    IF chart(i, 4) < yearin THEN GOTO qzqzqz
    IF chart(i, 2) < monthin AND chart(i, 4) = yearin THEN GOTO qzqzqz
    IF chart(i, 4) > yearend THEN GOTO qzqzqz
    IF chart(i, 2) > monthend AND chart(i, 4) = yearend THEN GOTO qzqzqz
    PRINT USING pat$; chart(i, 1); chart(i, 2); chart(i, 3); chart(i, 4); chart(i, 5); chart(i, 6); chart(i, 7); chart(i, 8); chart(i, 9); chart(i, 10); chart(i, 11); chart(i, 12); chart(i, 13); chart(i, 14); chart(i, 14); chart(i, 15); chart(i, 16); chart(i, 17); chart(i, 18); chart(i, 19); chart(i, 20); chart(i, 21); chart(i, 22); chart(i, 23); chart(i, 24); chart(i, 25)
    qzqzqz:
NEXT i
DO WHILE INKEY$ = ""
LOOP
GOTO printmenu
errorhandle:
CLS
PRINT
PRINT "There is something wrong with what you have input. Either you said"
PRINT "that you have a printer online, when in fact you don't or you have"
PRINT "tried to read a non-existant file."
PRINT
PRINT "In the above case if you do have a printer online, make sure that"
PRINT "it is turned on, is online and has paper in it."
PRINT
PRINT "If you are trying to read the chart, and get this error, then make "
PRINT "sure that the 'numbers2.dat' file exists. It can be created with "
PRINT "the [I]nitialize program option."
PRINT
PRINT "If you are using the barchart menu, and are trying to display a chart"
PRINT "when this error occurrs, then it is most likely that you have the "
PRINT "wrong graphics mode set. Try reseting your graphics mode."
PRINT
PRINT "If all else fails, and the error keeps coming up, then it is obviously"
PRINT "a program error. Please let me know about it and I will try to fix it."
PRINT
PRINT
PRINT "Press any key to continue ..."
DO WHILE INKEY$ = ""
LOOP
GOTO finish:
asciidisplay:
FOR j = 1 TO 70
    IF viewpoint$ = "low" THEN
        title$ = "Numbers Least Drawn"
        IF outpt(j) > low + spread THEN
            markz = 1
        END IF
    ELSEIF viewpoint$ = "average" THEN
        title$ = " Numbers Average Drawn"
        IF outpt(j) < low + spread OR outpt(i) > high - spread THEN
            markz = 1
        END IF
    ELSEIF viewpoint$ = "high" THEN
        title$ = " Numbers Most Drawn"
        IF outpt(j) < high - spread THEN
            markz = 1
        END IF
    ELSEIF viewpoint$ = "all" THEN
        title$ = "All Numbers Drawn"
    END IF
    IF markz > 0 THEN
        GOTO disp
    END IF
    countz = (outpt(j) / 16.247255256274392)
    countz = 30 - countz
    IF ca > 2 THEN
        ca = 0
    END IF
    FOR i = 20 TO countz STEP -1
        LOCATE i, j + 11
        PRINT CHR$(176 + ca)
    NEXT i
    disp:
    markz = 0
    ca = ca + 1
NEXT j
LOCATE 3, 4
PRINT "Frequency Distribution Chart  " + title$ + title2$
LOCATE 4, 4
PRINT "Covering the period from "; month$(monthin); yearin; " to "; month$(monthend); yearend
LOCATE 21, 12
PRINT "0000000001111111111222222222233333333334444444444555555555556666666667"
LOCATE 22, 12
PRINT "1234567890123456789012345678901234567890123456789012345678901234567890"
xyxty = 4 * 2
FOR i = 20 TO 6 STEP -1
    LOCATE i, 6
    PRINT xyxty
    LOCATE i, 63
    PRINT xyxty
    xyxty = xyxty + 48
NEXT i
LOCATE 24, 20
PRINT "Press any key to continue ..."
DO WHILE INKEY$ = ""
LOOP
viewpoint$ = "": normal$ = "": bonus$ = ""
RETURN
GOTO main
chart2:
CLS
PRINT
PRINT "This section will check each number from 1 to 70 and see how often"
PRINT "it occurs. It takes a few seconds to run however."
PRINT
PRINT "It will then give you a saved report that tells when the numbers came"
PRINT "up last, when they may come up again by, and the average days between"
PRINT "occurances."
PRINT
PRINT "Press any key to continue ....."
DO WHILE INKEY$ = ""
LOOP
CLS
x1 = VAL(MID$(DATE$, 1, 2))
x2 = VAL(MID$(DATE$, 4, 5))
x3 = VAL(MID$(DATE$, 7, 10))
x1 = x1 * 30
x3 = x3 * 365
now2 = x1 + x2 + x3
OPEN "freq.txt" FOR OUTPUT AS #1 LEN = 80
OPEN "next.txt" FOR OUTPUT AS #2 LEN = 80

FOR jjj = 1 TO 70
    FOR iii = 1 TO linecounter
        IF chart(iii, 5) = jjj OR chart(iii, 6) = jjj OR chart(iii, 7) = jjj OR chart(iii, 8) = jjj OR chart(iii, 9) = jjj OR chart(iii, 9) = jjj OR chart(iii, 10) = jjj OR chart(iii, 11) = jjj OR chart(iii, 12) = jjj OR chart(iii, 13) = jjj OR chart(iii, 14) = jjj OR chart(iii, 15) = jjj OR chart(iii, 16) = jjj OR chart(iii, 17) = jjj OR chart(iii, 18) = jjj OR chart(iii, 19) = jjj OR chart(iii, 20) = jjj OR chart(iii, 21) = jjj OR chart(iii, 22) = jjj OR chart(iii, 23) = jjj OR chart(iii, 24) = jjj THEN
            count = count + 1
            kkk = iii
            IF count = 1 THEN
                day1 = chart(iii, 3)
                month1 = chart(iii, 2)
                year1 = chart(iii, 4)
            END IF
            IF count > 1 THEN
                day2 = chart(iii, 3)
                month2 = chart(iii, 2)
                year2 = chart(iii, 4)
                now = (year2 * 365) + (month2 * 30) + day2
                thn = (year1 * 365) + (month1 * 30) + day1
                balance = now - thn
                temp4(jjj) = temp4(jjj) + balance
                year1 = year2
                month1 = month2
                day1 = day2
            END IF
        END IF
    NEXT iii
    temp4(jjj) = INT(temp4(jjj) / count)
    count = 0
    PRINT #1, USING "Number ## comes up  every ## days."; jjj; temp4(jjj)
    PRINT #1, USING "Number ## last came up ## ## ####."; jjj; chart(kkk, 1); chart(kkk, 2); chart(kkk, 3)
    day3 = chart(kkk, 2) + temp4(jjj)
    IF day3 > 30 THEN
        day3 = day3 - 30
        month3 = chart(kkk, 1) + 1
    ELSE
        month3 = chart(kkk, 1)
    END IF
    IF month3 > 12 THEN
        month3 = month3 - 12
        year3 = chart(kkk, 4) + 1
    ELSE
        year3 = chart(kkk, 3)
    END IF
    PRINT #1, USING "Number ##   due by:    ## ## ####."; jjj; month3; day3; year3
    z1 = month3 * 30
    z2 = day3
    z3 = year3 * 365
    thn2 = z1 + z2 + z3
    IF thn2 < (now2 - 20) THEN
        PRINT #2, USING "Number  ##  is a good bet as it was due by : ## ## ####"; j; month3; day3; year3
        PRINT USING "Number ## is a good bet, it was due by : ## ## ####"; j; month3; day3; year3
    END IF
    k = 0
    PRINT #1, ""
NEXT jjj
PRINT
PRINT "Press any key to continue ..."
DO WHILE INKEY$ = ""
LOOP
CLOSE #1
CLOSE #2
GOTO main
search:
CLS
PRINT
PRINT "Search for Winning Numbers by Date"
PRINT "----------------------------------"
PRINT
month2:
INPUT "Enter Month: ", month2
IF month2 = 0 THEN
    GOTO searchmenu
END IF
IF month2 < 1 OR month2 > 12 THEN
    PRINT "Invalid Month !": GOTO month2
END IF
day2:
INPUT "Enter Day: ", day2
IF day2 < 1 OR day2 > 31 THEN
    PRINT "Invalid Month !": GOTO day2
END IF
INPUT "Enter Year [All 4 digits ] "; year2
FOR i = 1 TO linecounter
    IF chart(i, 3) <> year2 THEN
        GOTO nextitem
    ELSEIF chart(i, 1) <> month2 THEN
        GOTO nextitem
    ELSEIF chart(i, 2) <> day2 THEN
        GOTO nextitem
    ELSEIF chart(i, 3) = year2 AND chart(i, 1) = month2 AND chart(i, 2) = day2 THEN
        search = 1
        CLS
        PRINT
        PRINT "Winning Numbers List"
        PRINT "--------------------"
        PRINT
        PRINT "Day   : ", chart(i, 1)
        PRINT "Month : ", chart(i, 2)
        PRINT "Date  : ", chart(i, 3)
        PRINT "Year  : ", chart(i, 4)
        PRINT
        PRINT "1st   : ", chart(i, 5)
        PRINT "2nd   : ", chart(i, 6)
        PRINT "3rd   : ", chart(i, 7)
        PRINT "4th   : ", chart(i, 8)
        PRINT "5th   : ", chart(i, 9)
        PRINT "6th   : ", chart(i, 10)
        PRINT "7th   : ", chart(i, 11)
        PRINT "8th   : ", chart(i, 12)
        PRINT "9th   : ", chart(i, 13)
        PRINT "10th  : ", chart(i, 14)
        PRINT "11th  : ", chart(i, 15)
        PRINT "12th  : ", chart(i, 16)
        PRINT "13th  : ", chart(i, 17)
        PRINT "14th  : ", chart(i, 18)
        PRINT "15th  : ", chart(i, 19)
        PRINT "16th  : ", chart(i, 20)
        PRINT "17th  : ", chart(i, 21)
        PRINT "18th  : ", chart(i, 22)
        PRINT "19th  : ", chart(i, 24)
        PRINT "20th  : ", chart(i, 25)
        PRINT
        PRINT "Press any key to continue ... "
        PRINT
        DO WHILE INKEY$ = ""
        LOOP
    END IF
    nextitem:
NEXT i
IF search = 0 THEN
    PRINT
    PRINT "There was no draw on : "; month2; day2; year2
    PRINT
    PRINT "Press any key to continue ...."
    DO WHILE INKEY$ = ""
    LOOP
END IF
search = 0
GOTO searchmenu
grcheck:
OPEN "grmode.dat" FOR INPUT AS #1
INPUT #1, hardcopy$
INPUT #1, crs$
INPUT #1, grtype
INPUT #1, qqq
CLOSE #1
OPEN "dname.dat" FOR INPUT AS #1
INPUT #1, reg$
FOR i = 1 TO LEN(reg$)
    counter4 = counter4 - 5.1384276
    z2 = ASC(MID$(reg$, i, i))
    MID$(reg$, i, i) = CHR$(z2 + counter4)
NEXT i
CLOSE #1
counter4 = 0
OPEN "reg.dat" FOR INPUT AS #1
INPUT #1, reg2$
FOR i = 1 TO LEN(reg2$)
    counter4 = counter4 - 5.214253
    z2 = ASC(MID$(reg2$, i, i))
    MID$(reg2$, i, i) = CHR$(z2 + counter4)
NEXT i
CLOSE #1

RETURN
grinit:
IF hardcopy$ = "y" THEN
    hardcopy$ = "Y"
END IF
IF grtype = 0 THEN
    grmode$ = "none"
ELSEIF grtype = 1 THEN
    grmode$ = "vga"
    wl = 3
    smode = 12
    barl = 5 / 4.8
    offset = 0
ELSEIF grtype = 2 THEN
    grmode$ = "HDMI"
    wl = 3
    smode = 12
    barl = 5 / 4.125
    offset = 0
END IF
RETURN
finish:
IF crs$ = "Y" THEN COLOR 7, 0
CLS
PRINT "Program Guarantee"
PRINT "-----------------"
PRINT
PRINT "The only guarantee that this program has is that if you use it, you will"
PRINT "probably spend more money on lotteries. I do not guarantee winning of "
PRINT "the lotteries with the use of this program, nor do I take any responsibility"
PRINT "for losses incurred by the use of this program."
PRINT
PRINT "Registration of Daily Keno Package"
PRINT "---------------------------------"
PRINT
PRINT "This program has been released into the public domain"
PRINT "and recompiled with QB64 , source code for everything"
PRINT "has been included. I however will continue to support"
PRINT "the program as I wrote it. My address, telephone #"
PRINT "is listed below: NO SPAM PLEASE!"
PRINT ""
PRINT "Russ Campbell"
PRINT "409 Mill Street, Unit 202B"
PRINT "Kitchener, Ontario, Canada"
PRINT "N2G 3M4, Phone # (226) 798-5888 Voice or Text"
PRINT "Internet : rcamp48@rogers.com"
PRINT
PRINT "Thanks for using Daily Keno Package Version 2019"
PRINT
PRINT "Press any key to continue ...."
DO WHILE INKEY$ = ""
LOOP
END

