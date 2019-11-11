DEFINT a-x
LIBRARY "GEMAES"

c$=SPACE$(16) : c&=VARPTR(c$)
ad$="This is a demo of how to use BubbleGEM. As you can see it brings 
a bubble up on the screen!"
ad$=ad$+" This is useful for help functions in programs, but only if 
the dialog is non-modal. The"
ad$=ad$+" call to access it is a combination of things with a 
appl_write at the end"+CHR$(0) : ad&=VARPTR(ad$)

IF LEN(ad$)>255 THEN STOP -1

i=appl_find("BUBBLE  ")
IF i=-1 THEN BEEP : STOP-1 

POKEW c&,&HBABB
POKEW c&+2,PEEKW(PEEKL(GB+4)+4)
POKEW c&+4,0
POKEW c&+6,MOUSE(0)
POKEW c&+8,MOUSE(1)
POKEL c&+10,ad&
POKEW c&+14,0

appl_write i,16,c&