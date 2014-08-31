10   REM Eine Uhr
20   CLS:DEGREE:USING$:esc$=CHR$(27)
30   r1=66:r2=r1+8:mx=128:my=92:st=360/12:schritt=4:win=5:win1=10
40   omin=-100:osec=-100:DIM x1(11),y1(11),x2(11),y2(11)
50   FOR i=0 TO 11
60     t=i*st
70     x=SIN(t):y=COS(t)
80     x1(i)=r1*x+mx
90     x2(i)=r2*x+mx
100    y1(i)=r1*y+my
110    y2(i)=r2*y+my
120  NEXT
130  INPUT 'Uhrzeit: ',TIMEV$:IF TIMEV$<>'' THEN TIMEV=DEG(TIMEV$):start=TIMEV*720000-PEEKL $4BA
140  PRINT esc$+'f'
150  WHILE INKEY$<>esc$
160    TIMEV=PEEKL $4BA+start
170    sec=TIMEV/200
180    IF sec<osec+1 THEN 630
190    osec=sec
200    min=sec/60
210    hour=min/60
220    WHILE hour>=24:hour=hour-24:WEND
230    IF min<omin+RCP(schritt)THEN 580
240    omin=INT(min*schritt)/schritt:CLS
250    CIRCLE mx,my,r2+1
260    GOTOXY 15,3:PRINT '12'
270    LINE x1(0),y1(0),x2(0),y2(0)
280    LINE x1(11),y1(11),x2(11),y2(11)
290    LINE x1(1),y1(1),x2(1),y2(1)
300    LINE x1(10),y1(10),x2(10),y2(10)
310    GOTOXY 8,10:PRINT '9'
320    GOTOXY 23,10:PRINT '3'
330    LINE x1(2),y1(2),x2(2),y2(2)
340    LINE x1(9),y1(9),x2(9),y2(9)
350    LINE x1(3),y1(3),x2(3),y2(3)
360    LINE x1(8),y1(8),x2(8),y2(8)
370    LINE x1(4),y1(4),x2(4),y2(4)
380    LINE x1(7),y1(7),x2(7),y2(7)
390    LINE x1(5),y1(5),x2(5),y2(5)
400    LINE x1(6),y1(6),x2(6),y2(6)
410    GOTOXY 16,18:PRINT '6'
420    t=min*6
430    x=SIN(t+win)*40+mx:y=COS(t+win)*40+my
440    xa=SIN(t-win)*40+mx:ya=COS(t-win)*40+my
450    xe=60*SIN(t)+mx:ye=60*COS(t)+my
460    LINE mx,my,x,y
470    LINE mx,my,xa,ya
480    LINE x,y,xe,ye
490    LINE xa,ya,xe,ye
500    t=hour*30
510    x=SIN(t+win1)*20+mx:y=COS(t+win1)*20+my
520    xa=SIN(t-win1)*20+mx:ya=COS(t-win1)*20+my
530    xe=40*SIN(t)+mx:ye=40*COS(t)+my
540    LINE mx,my,x,y
550    LINE mx,my,xa,ya
560    LINE x,y,xe,ye
570    LINE xa,ya,xe,ye
580    TIMEV$=DMS$(hour)
590    FOR i=1 TO 255
600      IF MID$(TIMEV$,i,1)=',' THEN TIMEV$=MID$(TIMEV$,1,i-1):i=256
610    NEXT
620    USING$,8:GOTOXY 12,21:PRINT TIMEV$;:USING$
630  WEND
640  PRINT esc$+'e':END
