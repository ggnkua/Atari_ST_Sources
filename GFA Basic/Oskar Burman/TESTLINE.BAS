REM Av Oskar Burman 1995

SCREEN 12
x1 = 50: y1 = 52
x2 = 480: y2 = 232

IF ABS(x2 - x1) < ABS(y2 - y1) THEN GOTO 30: REM more Y

REM ------------ More X ------------

IF x2 < x1 THEN SWAP x1, x2: SWAP y1, y2
    
k = (y2 - y1) * 16384 / (x2 - x1)
k = INT(k)
m = INT(y1 - (k * x1) / 16384)
am = am + INT(x1 / 64)
REM Pekar p† r„tt X linje!
antrad = INT(x2 / 64) - INT(x1 / 64)
xt = INT(x1 / 64) * 64 + 64
10
yt = (k * xt / 16384) + m
ya = INT(yt / 64) * 32
plotpoint = am + ya
GOSUB 20
am = am + 1
plotpoint = am + ya
GOSUB 20
xt = xt + 64
antrad = antrad - 1
IF antrad > 0 THEN GOTO 10

LINE (x1, y1)-(x2, y2)

END

REM ----------- More Y ------------
30

IF y2 < y1 THEN SWAP x1, x2: SWAP y1, y2

k = (x2 - x1) * 16384 / (y2 - y1)
k = INT(k)
m = INT(x1 - (k * y1) / 16384)
am = am + INT(y1 / 64) * 32
REM Pekar p† r„tt Y linje!
antrad = INT(y2 / 64) - INT(y1 / 64)
yt = INT(y1 / 64) * 64 + 64
40
xt = (k * yt / 16384) + m
xa = INT(xt / 64)
plotpoint = am + xa
GOSUB 20
am = am + 32
plotpoint = am + xa
GOSUB 20
yt = yt + 64
antrad = antrad - 1
IF antrad > 0 THEN GOTO 40

LINE (x1, y1)-(x2, y2)

END



REM ---- Plot ----
20

yp = INT(plotpoint / 32)
xp = plotpoint - yp * 32
yp = yp * 64
xp = xp * 64
LINE (xp, yp)-(xp + 64, yp)
LINE (xp + 64, yp)-(xp + 64, yp + 64)
LINE (xp + 64, yp + 64)-(xp, yp + 64)
LINE (xp, yp + 64)-(xp, yp)

RETURN




