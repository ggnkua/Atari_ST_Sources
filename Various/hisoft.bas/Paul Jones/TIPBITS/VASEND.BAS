REM $option y-,v+,u+,#,[

LIBRARY "GEMAES"
DEFINT a-z

a$=SPACE$(16) : a&=VARPTR(a$)
c$=COMMAND$+CHR$(0) : c&=VARPTR(c$)

i=appl_find("VAACC")

IF i=-1 THEN PRINT "Not here!"

IF i-1 THEN

POKEW a&,&H4711
POKEW a&+2,PEEKW(PEEKL(GB+4)+4)
POKEW a&+4,0
POKEL a&+6,c&
POKEW a&+10,0

appl_write i,16,a&
END IF
