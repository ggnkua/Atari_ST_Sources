rem COLORTXT.BAS; For Low res 16 colours, Med Res 4 colours, Hi Res 2 colours.
rem      also OK on VGA 256 colours (set 0 to 255 in line 5)
'                  ' apostrophy allows remarks, not used in progam.
'
for n = 0 to 15    ' 0=White, 1 Black, 2 Red, 3 Green,etc.
color n
print "Colours";   ' note semicolon causes text to continue along the line.
'    note first colour is Black, leaving a space before it. (filled later by 1,1)
next n             ' do next colour.
'
print              ' prints a blank line.
print              ' another blank line
'
 for t=1 to 3
color t
print "text"       ' no semicolon gives text lines below each other.
next t
'
print
for s=1 to 4
color 2
print "comma...",  ' comma prints in several columns.
next s
'
print
start!=timer
Locate 12,20
print "Press RETURN"
do
a$=inkey$
loop until a$=chr$(13)

'
Locate 1,1         ' top left corner
Print "1,1"
locate 9,1         ' other positions, depending on resolution.
print "9,1"
locate 17,1
print "17,1"
locate 4,20
print "4,20"
locate 5,36
print "5,36"
locate 4,70
print "4,70"
locate 17,36
print "17,36"





