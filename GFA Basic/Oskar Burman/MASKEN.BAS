CLS
RANDOMIZE TIMER

main:

GOSUB menu

newgame:
REM ------ Init game variabler -------
le = 100: wormlength = 10: lev = 1
starttime = 20: slutlevendtime = 100
levendtime = 100
score = 0
DIM sx(200), sy(200), srn(80, 24), poang(10), namn$(10)

initlevel:
REM ---- init level variabler ----
time = 0: x = 31: y = 11: ix = 2: iy = 0: s = 3: r = 0

FOR cx = 0 TO 80
FOR cy = 0 TO 24
srn(cx, cy) = 0
NEXT cy
NEXT cx

FOR w = 0 TO 200
sx(w) = 2
sy(w) = 1
NEXT w

REM -------- init sk„rm ---------

SCREEN 0
CLS
COLOR 4
PRINT "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
FOR w = 0 TO 19
PRINT "*                                                                             *"
NEXT w
PRINT "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"

REM ------------ Mainloop -----------

mainloop:

FOR w = 0 TO le
i$ = INKEY$
IF (i$ = "I" OR i$ = "i") AND s <> 1 THEN ix = 0: iy = -1
IF (i$ = "K" OR i$ = "k") AND s <> 0 THEN ix = 0: iy = 1
IF (i$ = "J" OR i$ = "j") AND s <> 3 THEN ix = -2: iy = 0
IF (i$ = "L" OR i$ = "l") AND s <> 2 THEN ix = 2: iy = 0
IF i$ = CHR$(27) THEN GOTO slut
IF i$ = "P" OR i$ = "p" THEN GOSUB pause
NEXT w
x = x + ix: y = y + iy
IF x > 78 OR x < 2 OR y > 21 OR y < 2 THEN GOTO slut

IF srn(x, y) = 1 THEN GOTO slut
IF srn(x, y) = 2 THEN score = score + lev * 500
IF srn(x, y) = 3 THEN GOTO nextlevel

LOCATE y, x
COLOR 15
PRINT "*"
srn(x, y) = 1

IF ix = 0 AND iy = -1 THEN s = 0
IF ix = 0 AND iy = 1 THEN s = 1
IF ix = -2 AND iy = 0 THEN s = 2
IF ix = 2 AND iy = 0 THEN s = 3

r = r + 1: IF r = wormlength THEN r = 0
LOCATE sy(r), sx(r)
PRINT " "
srn(sx(r), sy(r)) = 0
sx(r) = x
sy(r) = y

IF INT(RND(1) * 10) = 0 AND levendtime > 0 THEN
nyttslumptal:
        bx = INT(RND(1) * 38) * 2 + 3
        by = INT(RND(1) * 18) + 2
        IF srn(bx, by) <> 0 THEN GOTO nyttslumptal
        srn(bx, by) = 2
        LOCATE by, bx
        COLOR 14
        PRINT "@"
END IF

score = score + lev

COLOR 15
LOCATE 23, 1: PRINT "SCORE"; score
LOCATE 23, 15: PRINT "LEVEL"; lev
levendtime = levendtime - 1
IF levendtime = 0 THEN
nyttslumptal2:
        bx = INT(RND(1) * 38) * 2 + 3
        by = INT(RND(1) * 18) + 2
        IF srn(bx, by) <> 0 THEN GOTO nyttslumptal2
        srn(bx, by) = 3
        LOCATE by, bx
        COLOR 9 + 16
        PRINT "#"
END IF

GOTO mainloop

REM ----------- Next Level ----------
nextlevel:

CLS

LOCATE 10, 28
COLOR 12
PRINT "Yeeaahhh!!! You made it!!!"
LOCATE 12, 33
PRINT "Level"; lev; "completed"

lev = lev + 1
      
FOR w = 0 TO 10000: NEXT w

IF le > 10 THEN le = le - 10 ELSE le = le - 2
IF le = 0 THEN GOTO slut: REM --- Game completed ---
wormlength = wormlength + 5
starttime = starttime - 1: slutlevendtime = slutlevendtime + 20
levendtime = slutlevendtime

GOTO initlevel

REM ------------ Pause ------------
pause:
LOCATE 23, 40
COLOR 14 + 16
PRINT "Game paused, press C to Continue"
waitloop:
i$ = INKEY$
IF i$ <> "c" AND i$ <> "C" THEN GOTO waitloop
LOCATE 23, 40
PRINT "                                "

RETURN

REM ---------- Game Over ----------
slut:

COLOR 2
LOCATE 12, 35: PRINT "Game Over"

FOR w = 0 TO 7000: NEXT w

COLOR 15

CLS
ON ERROR GOTO finnsej
OPEN "masken.dat" FOR INPUT AS #1
FOR a = 1 TO 10
INPUT #1, namn$(a), poang(a)
NEXT a
CLOSE #1
GOTO namnfinns

finnsej:
CLOSE #1
FOR a = 1 TO 10
namn$(a) = "Walther the Worm"
poang(a) = 11000 - 1000 * a
NEXT a
RESUME namnfinns

namnfinns:
IF score > poang(10) THEN
        poang(10) = score
        COLOR 14
        PRINT "You made it to the top!": PRINT
reenter:
        INPUT "Enter your name: ", namn$(10)
        IF LEN(namn$(10)) > 20 THEN PRINT "Name must be shorter than 20 characters!": GOTO reenter

        FOR a = 10 TO 2 STEP -1
        IF poang(a) > poang(a - 1) THEN
                SWAP poang(a), poang(a - 1)
                SWAP namn$(a), namn$(a - 1)
        END IF
        NEXT a

        ON ERROR GOTO skriverinte
        OPEN "masken.dat" FOR OUTPUT AS #1
        FOR a = 1 TO 10
        WRITE #1, namn$(a), poang(a)
        NEXT a
        CLOSE #1
        GOTO klart
skriverinte:
        CLOSE #1
        PRINT "Could not save highscore file."
        RESUME klart
klart:

END IF

CLS
COLOR 4
LOCATE 2, 30
PRINT "The Greatest Worms"
LOCATE 3, 30
PRINT "------------------"
COLOR 15
FOR a = 1 TO 10
LOCATE 6 + a, 20
PRINT a
LOCATE 6 + a, 30
PRINT poang(a)
LOCATE 6 + a, 45
PRINT namn$(a)
NEXT a

LOCATE 20, 20
PRINT "Press Space for a new game or Esc to quit"
igen:
a$ = INKEY$
IF a$ <> " " AND a$ <> CHR$(27) THEN GOTO igen
IF a$ = " " THEN GOTO main
CLS
END

menu:
CLS
LOCATE 2, 35
PRINT "MASKEN"
LOCATE 3, 35
PRINT "------"
LOCATE 5, 26
PRINT "This game is for 18+ only"
LOCATE 7, 15
PRINT "Game made during the slow parts of the MV™ -95 by"
LOCATE 8, 25
PRINT "Oskar Burman and Anders Kaplan"
LOCATE 11, 23
PRINT "Use the following keys in game"
LOCATE 12, 30
PRINT "J          left"
LOCATE 13, 30
PRINT "L          right"
LOCATE 14, 30
PRINT "I          up"
LOCATE 15, 30
PRINT "K          down"
LOCATE 16, 30
PRINT "P          pause game"
LOCATE 17, 30
PRINT "[ESC]      Quit game"
LOCATE 22, 30
PRINT "Press [SPACE] to play"
waitloop2:
i$ = INKEY$
IF i$ = " " THEN RETURN
IF i$ = CHR$(27) THEN CLS : END
GOTO waitloop2


END

