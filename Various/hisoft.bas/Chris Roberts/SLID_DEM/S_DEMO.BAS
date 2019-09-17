REM $option l64,v+,y,u+,#+
REM $INCLUDE GEMAES.BH
REM $include S_DEMO.bh 
'you must use the HGT.T pre-tokenized file
DIM SHARED junk,i,object,but,result,fpos%,fslsize

CALL startProgram("",0,-1)'init HGT no menu
CALL initresourcefile("S_DEMO.RSC")' load RSC file
LET fpos%=0'starting position
LET fslsize=0'how big is the slider
CALL main

SUB main
LOCAL my,mx,mstate,kstate,obx,oby
LET object=0 
DO
selecttree(form1)'load the form
CALL sette_ptext(fpostxt%,LTRIM$(STR$(fpos%)))  'show the position of the slider in pixels
CALL drawdialog'display dialog and get what button was pushed
LET object=0' object to be drawn/redrawn 0=form parent

IF result=slider THEN'if the slider is pressed
LET fpos%=graf_slidebox(tree&,sliderparent,slider,1)'draw the outline of the box and allow it to move
LET fpos%=fpos%\10
IF fpos%>=0 THEN CALL setob_Y(slider,fpos%)'have the slider moved if so redraw it in the new location
LET object=sparent'redraw only the parent of the sliderbox
END IF

IF result=sliderparent THEN'if the slider's parent is pressed
CALL graf_mkstate(mx,my,mstate,kstate) 'find the mouse position in pixels 
LET junk=objc_offset(tree&,slider,obx,oby)' find the slider positon in pixels 
IF my>oby THEN'if the mouse is above the slider
IF fpos%+10<=100 THEN LET fpos%=fpos%+10 ELSE LET fpos%=100 'move the slider
CALL setob_Y(slider,fpos%)'redraw the slider
END IF
IF my<oby THEN'if the mouse is below the slider
IF fpos%-10>=0 THEN LET fpos%=fpos%-10 ELSE LET fpos%=0'move the slider
CALL setob_Y(slider,fpos%)'redraw the slider
END IF
LET object=sparent'redraw only the parent of the sliderbox
END IF

IF result=up THEN'if the up arrow is pressed
IF fpos%>0 THEN LET fpos%=fpos%-1'decrement the position pointer
CALL setob_Y(slider,fpos%)'redraw the slider in new position
LET object=sparent'redraw only the parent of the sliderbox
END IF

IF result=down THEN'if down arrow is pressed
IF fpos%<100 THEN LET fpos%=fpos%+1'increment the position pointer
CALL setob_Y(slider,fpos%)'redraw the slider in new position
LET object=sparent'redraw only the parent of the sliderbox
END IF

IF result=done THEN
CALL CLOSEdialog
EXIT DO
END IF

LOOP
END SUB

SUB drawdialog
STATIC x,y,w,h,but
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
junk=objc_draw(tree&,object,10,x,y,w,h)
result=form_do(tree&,0) AND &h7fff
END SUB

SUB closedialog
STATIC x,y,w,h,but
form_center tree&,x,y,w,h
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
END SUB

CALL stopprogram
SYSTEM
END
