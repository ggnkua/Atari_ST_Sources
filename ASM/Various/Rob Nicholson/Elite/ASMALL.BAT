echo off
tm start/n
delete errors
echo Assembling elite    (1 of 39)
echo **** ELITE **** >> errors
m68k temp=f:elite >> errors
a68k e:elite=header.m68 >> errors
echo Assembling debug    (2 of 39)
echo **** DEBUG **** >> errors
m68k temp=f:debug >> errors
a68k e:debug=header.m68 >> errors
echo Assembling chkstart (3 of 39)
echo **** CHKSTART **** >> errors
m68k temp=f:chkstart >> errors
a68k e:chkstart=header.m68 >> errors
echo Assembling bios     (4 of 39)
echo **** BIOS **** >> errors
m68k temp=f:bios >> errors
a68k e:bios=header.m68 >> errors
echo Assembling data     (5 of 39)
echo **** DATA **** >> errors
m68k temp=f:data >> errors
a68k e:data=header.m68 >> errors
echo Assembling init     (6 of 39)
echo **** INIT **** >> errors
m68k temp=f:init >> errors
a68k e:init=header.m68 >> errors
echo Assembling maths    (7 of 39)
echo **** MATHS **** >> errors
m68k temp=f:maths >> errors
a68k e:maths=header.m68 >> errors
echo Assembling vector   (8 of 39)
echo **** VECTOR **** >> errors
m68k temp=f:vector >> errors
a68k e:vector=header.m68 >> errors
echo Assembling special  (9 of 39)
echo **** SPECIAL **** >> errors
m68k temp=f:special >> errors
a68k e:special=header.m68 >> errors
echo Assembling main     (10 of 39)
echo **** MAIN **** >> errors
m68k temp=f:main >> errors
a68k e:main=header.m68 >> errors
echo Assembling rotate   (11 of 39)
echo **** ROTATE **** >> errors
m68k temp=f:rotate >> errors
a68k e:rotate=header.m68 >> errors
echo Assembling attract  (12 of 39)
echo **** ATTRACT **** >> errors
m68k temp=f:attract >> errors
a68k e:attract=header.m68 >> errors
echo Assembling cockpit  (13 of 39)
echo **** COCKPIT **** >> errors
m68k temp=f:cockpit >> errors
a68k e:cockpit=header.m68 >> errors
echo Assembling sounds   (14 of 39)
echo **** SOUNDS **** >> errors
m68k temp=f:sounds >> errors
a68k e:sounds=header.m68 >> errors
echo Assembling music    (15 of 39)
echo **** MUSIC **** >> errors
m68k temp=f:music >> errors
a68k e:music=header.m68 >> errors
echo Assembling except   (16 of 39)
echo **** EXCEPT **** >> errors
m68k temp=f:except >> errors
a68k e:except=header.m68 >> errors
echo Assembling graphics (17 of 39)
echo **** GRAPHICS **** >> errors
m68k temp=f:graphics >> errors
a68k e:graphics=header.m68 >> errors
echo Assembling flight   (18 of 39)
echo **** FLIGHT **** >> errors
m68k temp=f:flight >> errors
a68k e:flight=header.m68 >> errors
echo Assembling galaxy   (19 of 39)
echo **** GALAXY **** >> errors
m68k temp=f:galaxy >> errors
a68k e:galaxy=header.m68 >> errors
echo Assembling disk     (20 of 39)
echo **** DISK **** >> errors
m68k temp=f:disk >> errors
a68k e:disk=header.m68 >> errors
echo Assembling action   (21 of 39)
echo **** ACTION **** >> errors
m68k temp=f:action >> errors
a68k e:action=header.m68 >> errors
echo Assembling novella  (22 of 39)
echo **** NOVELLA **** >> errors
m68k temp=f:novella >> errors
a68k e:novella=header.m68 >> errors
echo Assembling sprites  (23 of 39)
echo **** SPRITES **** >> errors
m68k temp=f:sprites >> errors
a68k e:sprites=header.m68 >> errors
echo Assembling pdata    (24 of 39)
echo **** PDATA **** >> errors
m68k temp=f:pdata >> errors
a68k e:pdata=header.m68 >> errors
echo Assembling funny    (25 of 39)
echo **** FUNNY **** >> errors
m68k temp=f:funny >> errors
a68k e:funny=header.m68 >> errors
echo Assembling dust     (26 of 39)
echo **** DUST **** >> errors
m68k temp=f:dust >> errors
a68k e:dust=header.m68 >> errors
echo Assembling logic    (27 of 39)
echo **** LOGIC **** >> errors
m68k temp=f:logic >> errors
a68k e:logic=header.m68 >> errors
echo Assembling missions (28 of 39)
echo **** MISSIONS **** >> errors
m68k temp=f:missions >> errors
a68k e:missions=header.m68 >> errors
echo Assembling auto     (29 of 39)
echo **** AUTO **** >> errors
m68k temp=f:auto >> errors
a68k e:auto=header.m68 >> errors
echo Assembling radar    (30 of 39)
echo **** RADAR **** >> errors
m68k temp=f:radar >> errors
a68k e:radar=header.m68 >> errors
echo Assembling orbit    (31 of 39)
echo **** ORBIT **** >> errors
m68k temp=f:orbit >> errors
a68k e:orbit=header.m68 >> errors
echo Assembling combat   (32 of 39)
echo **** COMBAT **** >> errors
m68k temp=f:combat >> errors
a68k e:combat=header.m68 >> errors
echo Assembling tweak    (33 of 39)
echo **** TWEAK **** >> errors
m68k temp=f:tweak >> errors
a68k e:tweak=header.m68 >> errors
echo Assembling cargo    (34 of 39)
echo **** CARGO **** >> errors
m68k temp=f:cargo >> errors
a68k e:cargo=header.m68 >> errors
echo Assembling equip    (35 of 39)
echo **** EQUIP **** >> errors
m68k temp=f:equip >> errors
a68k e:equip=header.m68 >> errors
echo Assembling options  (36 of 39)
echo **** OPTIONS **** >> errors
m68k temp=f:options >> errors
a68k e:options=header.m68 >> errors
echo Assembling effects  (37 of 39)
echo **** EFFECTS **** >> errors
m68k temp=f:effects >> errors
a68k e:effects=header.m68 >> errors
echo Assembling chkend   (38 of 39)
echo **** CHKEND **** >> errors
m68k temp=f:chkend >> errors
a68k e:chkend=header.m68 >> errors
echo Assembling checksum (39 of 39)
echo **** CHECKSUM **** >> errors
m68k temp=f:checksum >> errors
a68k e:checksum=header.m68 >> errors
tm stop/n
