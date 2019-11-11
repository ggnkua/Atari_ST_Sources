REM        COLRDISP.BAS    colour display, p75 1st Basic Manual.   Med Res.
'
defint a-z
Library "xbios"           ' uses XBIOS library
'                           draw 3 boxes in triangular formation
for i=1 to 3
x=120
y=25
if i=2 then x=x-75:y=y+75
if i=3 then x=x+75:y=y+65
color ,i                  ' fill colour only
bar x,y,100,50            ' draw box
next i
'
rem                         cycle through colours
for red=0 to 7
for green=0 to 7
for blue= 0 to 7
'                           initialise colours
palette 1,red*&h100+green*h*10+blue
palette 2,red*h10+green+blue*&h100
palette 3,red+green*&h100+blue*&h10
vsync                      ' pause 1/50 second
vsync
next blue
next green
next red
'
rem                          reset to standard palette.
palette 0,&h777
palette 1,&h000
palette 2,&h700
palette 3,&h070
beep
end