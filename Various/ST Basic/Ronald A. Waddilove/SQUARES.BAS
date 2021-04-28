10    REM Recursive Squares
20    REM By R.A Waddilove
30    REM (c) Atari ST User
40    FULLW 2:CLEARW 2
50    GOTOXY 0,0
60    mode%=PEEK(SYSTAB)
70    IF mode%=4 THEN ? "Medium/High resolution only":END
80    INPUT "Level of recursion (1-8)";rec%
90    Level%=200/mode%
100   FOR i%=1 TO rec%
110   Level%=Level%/2
120   NEXT
130   DIM Lx%(50),Ly%(50),Ls%(50)
140   sp%=0
150   tx%=270:ty%=120/mode%:ts%=100/mode%:GOSUB square
160   INPUT "Press RETURN...",k$
170   END
180   REM --------------------
190   square:
200   IF ts%<Level% THEN RETURN
210   Lx%(sp%)=x%:Ly%(sp%)=y%:Ls%(sp%)=s%:sp%=sp%+1
220   x%=tx%:y%=ty%:s%=ts%
230   LINEF x%,y%,x%,y%+s%
240   LINEF x%,y%+s%,x%+s%,y%+s%
250   LINEF x%+s%,y%+s%,x%+s%,y%
260   LINEF x%+s%,y%,x%,y%
270   tx%=x%+s%/4:ty%=y%+s%:ts%=s%/2:GOSUB square
280   tx%=x%+s%:ty%=y%+s%/4:ts%=s%/2:GOSUB square
290   tx%=x%-s%/2:ty%=y%+s%/4:ts%=s%/2:GOSUB square
300   tx%=x%+s%/4:ty%=y%-s%/2:ts%=s%/2:GOSUB square
310   sp%=sp%-1:x%=Lx%(sp%):y%=Ly%(sp%):s%=Ls%(sp%)
320   RETURN
