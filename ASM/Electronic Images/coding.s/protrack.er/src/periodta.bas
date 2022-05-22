'PeriodTable:
' dc.w 856,808,762,720,678,640,604,570,538,508,480,453
' dc.w 428,404,381,360,339,320,302,285,269,254,240,226
' dc.w 214,202,190,180,170,160,151,143,135,127,120,113
' dc.w 0

DEFDBL a-s

INPUT "tuning";n
a = 2^(1/12)
b = a^(n/8)

PRINT a,b
PRINT


fclk = 4433618.75#*1.6
pclk = (1/fclk)*2

GOTO loop
fr=258.9731 * b
FOR g=0 TO 36
   per = 1/fr/pclk
   PRINT g;fr,per/16
   fr = fr * a
   IF INKEY$<>"" THEN
abc:
     IF INKEY$="" THEN abc
   END IF
NEXT

loop:
INPUT "period";t
xx=1/(t*pclk)
yy=1/(xx*b)/pclk
zz=1/(yy*pclk)

PRINT xx, xx/16, yy, zz/16

GOTO loop

