63000 MOUSE:
63002 '<----- XMOUSE ; YMOUSE ; KEY
63004 poke contrl, 124
63006 vdisys
63008 xmouse = peek(ptsout) - 1
63010 ymouse = peek(ptsout + 2) - 38
63012 key = peek(intout)
63014 return
63015 '---------------------------------------------------
63030 SHOWMOUSE:
63032 poke contrl, 122
63034 poke intin, 0
63036 vdisys
63038 return
63039 '---------------------------------------------------
63050 MOUSEEDITOR:
63052 dim a$(16),b$(16)
63054 a$( 0)="---*--*----*----":b$( 0)="--******--***---"
63056 a$( 1)="--*--*----*-----":b$( 1)="-******--****---"
63058 a$( 2)="---*--*---*-----":b$( 2)="--**********----"
63060 a$( 3)="---*--*--*------":b$( 3)="--*********-----"
63062 a$( 4)="---*---*--*-----":b$( 4)="--*********-----"
63064 a$( 5)="----*-*--*------":b$( 5)="---*******------"
63066 a$( 6)="----------------":b$( 6)="--********------"
63068 a$( 7)="--*********-----":b$( 7)="-*************--"
63070 a$( 8)="--************--":b$( 8)="-**************-"
63072 a$( 9)="--*********--**-":b$( 9)="-***************"
63074 a$(10)="--*********---*-":b$(10)="-***************"
63076 a$(11)="--*********--**-":b$(11)="-***************"
63078 a$(12)="--************--":b$(12)="-***************"
63080 a$(13)="--*********-----":b$(13)="-**************-"
63082 a$(14)="---*******------":b$(14)="--*********-----"
63084 a$(15)="----------------":b$(15)="---*******------"
63086 for a = 0 to 15
63088 gridfront = 0: gridback = 0
63090 for b = 15 to 0 step -1
63092 if mid$(a$(a),b+1,1)="*" then bit = 1 else bit = 0
63094 gridfront = gridfront + 2 ^(15 - b) * bit
63096 if mid$(b$(a),b+1,1)="*" then bit = 1 else bit = 0
63098 gridback = gridback + 2^(15 - b) * bit
63100 next
63102 poke intin + a * 2 + 42, gridfront
63104 poke intin + a * 2 + 10, gridback
63106 print gridfront, gridback
63108 next
63110 goto mousenew
63112 '---------------------------------------------------
63140 '--------------- MOUSEDATA -------------------------
63141 HAMMER:
63142 data 96,480,960,1984,3968,8064
63143 data 7936,16256,15872,32512,32512,65408
63144 data 65408,65472,63424,65504,25568,65520
63145 data 496,62456,248,508,124,254
63146 data 62,127,31,63,14,31
63147 data 4,14
63150 COFFEE:
63151 data 4624,16184,9248,32376,4640,16368
63152 data 4672,16352,4384,16352,2624,8128
63153 data 0,16320,16352,32764,16380,32766
63154 data 16358,32767,16354,32767,16358,32767
63155 data 16380,32767,16352,32766,8128,16352
63156 data 0,8128
63160 WORM:
63161 data 0,8064,8064,16320,16320,32736
63162 data 26208,65520,30560,65520,32736,65532
63163 data 29132,65534,16318,32767,8054,16383
63164 data 7782,16383,7372,16382,7384,16380
63165 data 4080,8184,2022,4095,60,2046
63166 data 24,62
63199 '-------------------------------------------------
63200 MOUSEDATA:
63202 '---> restore line
63204 for a = 0 to 15
63206 read gridfront,gridback
63208 poke intin + a * 2 + 42, gridfront
63210 poke intin + a * 2 + 10, gridback
63212 next
63214 '-------------------------------------------------
63250 MOUSENEW:
63252 poke contrl    , 111
63254 poke contrl + 6, 37
63256 poke intin    , 5
63258 poke intin + 2, 5
63260 poke intin + 4, 1
63262 poke intin + 6, 0
63264 poke intin + 8, 1
63266 vdisys
63268 out 2,7
63270 return
63272 '---------------------------------------------------
63280 MOUSESHAPE:
63282 '-----> MOUSENUMBER
63286 if mousenumber > 7 then return
63288 add# = gb
63290 gintin = peek(add# + 8)
63292 addrin = peek(add# + 16)
63294 poke gintin, mousenumber
63296 poke addrin, 0
63298 gemsys(78)
63300 return
63301 '---------------------------------------------------
63302 '
63400 POLYMARK:
63402 ' ----> XPOS ; YPOS
63404 ' ----> MARKFORM ; MARKSIZE
63406 '
63408 poke contrl    , 18
63410 poke contrl + 2, 0
63412 poke contrl + 6, 1
63414 poke intin, markform
63416 vdisys
63418 poke contrl    , 19
63420 poke contrl + 2, 1
63422 poke contrl + 6, 0
63424 poke ptsin    , 0
63426 poke ptsin + 2, marksize
63428 vdisys
63430 '
63432 MARKSETTING:
63434 ' (----> XPOS ; YPOS )
63436 poke contrl    , 7
63438 poke contrl + 2, 1 : ' or more
63440 poke ptsin    , xpos + 1
63442 poke ptsin + 2, ypos + 38
63444 vdisys
63446 return
63448 '---------------------------------------------------
64100 POLYGON2:
64102 ' -----> XPOS ; YPOS
64104 '        RADIUS ; ANGLES
64106 phi = 3.141593/angles/2
64108 STAR:
64110 ' -----> PHI
64112 poke contrl    , 9
64114 poke contrl + 6, 0
64116 poke contrl + 2, angles
64118 for angle = 0 to angles * 4 step 4
64120 poke ptsin+angle    ,  1+xpos+cos(phi*angle)*radius
64122 poke ptsin+(angle+2), 38+ypos+sin(phi*angle)*radius
64124 next
64126 vdisys
64128 return
64130 '--------------------------------------------------
64140 POLYGON:
64142 ' -----> ANGLES ; XCOORD ; YCOORD
64144 poke contrl    , 9
64146 poke contrl + 6, 0
64148 poke contrl + 2, angles
64150 for i = 1 to angles
64152 poke ptsin + (i - 1) * 4, xcoord(i) + 1
64154 poke ptsin + 2 + (i - 1) * 4, ycoord(i) + 38
64156 next
64158 vdisys
64160 return
64162 '---------------------------------------------------
64300 POLYLINE:
64301 ' -----> NUMBER ; XCOORD ; YCOORD
64302 poke contrl    , 6
64304 poke contrl + 6, 0
64306 poke contrl + 2, number
64308 for i = 0 to number
64310 poke ptsin + i * 4, xcoord(i) + 1
64312 poke ptsin + 2 + i * 4, ycoord(i) + 38
64314 next
64316 vdisys
64318 return
64320 '---------------------------------------------------
65130 TEXTFORM:
65132 ' -----> FORM (1 - 4)
65134 '
65138 poke contrl    ,32
65140 poke contrl + 2,0
65142 poke contrl + 6,1
65144 poke intin, form
65146 vdisys
65148 return
