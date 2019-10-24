62000 SETWIND:
62002 ' -----> XPOS   ; YPOS ; WIDTH
62004 ' -----> HEIGHT ; WINDOWNUMBER
62006 poke gintin    , windownumber
62008 poke gintin + 2, 5
62010 poke gintin + 4, xpos
62012 poke gintin + 6, ypos
62014 poke gintin + 8, widthe
62016 poke gintin + 10, height
62018 gemsys 105
62020 return
62022 ' --------------------------------------------------
62050 FULLWIND:
62052 '
62054 poke gintin    , 3        :' OUTPUT-window
62056 poke gintin + 2, 5        :' with/ without edge
62058 poke gintin + 4, 0        :'  0  : (  -1) ; x1
62060 poke gintin + 6, 1        :'  1  : (   0) ; y1
62062 poke gintin + 8, 658      :' 658 : ( 660) ; x2
62064 poke gintin + 10,417      :' 417 : ( 419) ; y2
62066 gemsys 105
62068 return
62070 ' --------------------------------------------------
62080 CLEARDESK:
62082 ' merge "RECTANGLE.bas"
62084 color 1,0,1 :
62086 xpos1 = -1 : xpos2 = 638 : ypos1 = -40 : ypos2 = -20
62088 gosub rectangle: color 1,1,1
62090 return
62092 ' --------------------------------------------------
62100 SHRINXBOX:  
62102 ' ----->  XOLD ; YOLD ; WIDTH1 ; HEIGHT1
62104 ' ----->  XNEW ; YNEW ; WIDTH2 ; HEIGHT2
62106 shrinx% = 1
62108 '
62110 GROWBOX:
62112 ' ----->  SEE SHRINXBOX  
62114 '
62116 poke contrl + 2, 8
62118 poke contrl + 4, 1
62120 poke gintin     , xold
62122 poke gintin + 2 , yold
62124 poke gintin + 4 , width1
62126 poke gintin + 6 , height1
62128 poke gintin + 8 , xnew  + 1
62130 poke gintin + 10, ynew  + 38
62132 poke gintin + 12, width2
62134 poke gintin + 14, height2
62136 gemsys 73 + shrinx%
62138 shrinx% = 0
62140 return
62142 ' --------------------------------------------------
62150 MOVEBOX:
62152 ' -----> WIDTHE; HEIGHT ; XOLD ; YOLD
62154 ' -----> XNEW  ; YNEW  
62156 poke contrl + 2, 6
62158 poke contrl + 4, 1
62160 poke gintin    , widthe
62162 poke gintin + 2, height
62164 poke gintin + 4, xold + 1
62166 poke gintin + 6, yold + 38
62168 poke gintin + 8, xnew + 1
62170 poke gintin + 10,ynew + 38
62172 gemsys 72
62174 return
62176 ' --------------------------------------------------
62200 RUBBERBOX:
62202 ' -----> MUISX ; MUISY
62204 ' <----- WIDTHE ; HEIGHT
62206 poke gintin    , mousex + 1
62208 poke gintin + 2, mousey + 38
62210 poke gintin + 4, 1
62212 poke gintin + 6, 1
62214 AES.3: gemsys 70
62216 widthe = peek(gintout + 2)
62218 height = peek(gintout + 4)
62220 if height<3 or widthe<3 then goto AES.3
62222 return
62224 ' -------------------------------------------------
62250 DRAGBOX:
62252 ' -----> WIDTHE ; HEIGHT
62254 '        X.MIN   ; Y.MIN
62256 '        X.MAX   ; Y.MAX
62258 ' <----- XPOS1   ; YPOS1
62260 poke contrl + 2, 8
62262 poke contrl + 4, 3
62264 poke gintin    , widthe
62266 poke gintin + 2, height
62268 poke gintin + 4, mousex + 1
62270 poke gintin + 6, mousey + 38
62272 poke gintin + 8, x.min + 1
62274 poke gintin +10, y.min + 38
62276 poke gintin +12, x.max + 1
62278 poke gintin +14, y.max + 38
62280 gemsys 71
62282 xpos1 = peek(gintout + 2)-1
62284 ypos1 = peek(gintout + 4)-38
62286 return
62288 '-------------------------------------------------
62500 EVENTMOUSE:
62502 ' -----> XPOS1 ; YPOS1
62504 ' -----> WIDTHE ; HEIGHT
62506 poke gintin    , 0
62508 poke gintin + 2, xpos1 + 1
62510 poke gintin + 4, ypos1 + 38
62512 poke gintin + 6, widthe
62514 poke gintin + 8, height
62516 gemsys 22
62518 return
62520 ' ------------------------------------------------
62550 MOUSE2:
62552 ' <----- MOUSEX ; MOUSEY
62554 ' <----- KEYA  ; KEYB
62556 mousex = peek(gintout + 2)-1
62558 mousey = peek(gintout + 4)-38
62560 keya  = peek(gintout + 6)
62562 keyb  = peek(gintout + 8)
62564 gemsys 79
62566 return
62568 ' ------------------------------------------------
62700 COLORSET:
62702 ' -----> RED ; GREEN ; BLUE 
62704 '        COLORNUMBER
62706 poke contrl, 14
62708 poke intin, colornumber
62710 poke intin + 2, red  * 140
62712 poke intin + 4, green * 140
62714 poke intin + 6, blue * 140
62716 vdisys
62718 return
62720 ' --------------------------------------------------
62750 POLYMARKCOLOR:
62752 ' -----> MARKCOLOR
62754 poke contrl, 20
62756 poke intin, markcolor
62758 vdisys
62760 return
62762 ' --------------------------------------------------
62900 INIT:
62902 aes# = gb
62904 control = peek(aes#)
62906 global  = peek(aes# + 4)
62908 gintin  = peek(aes# + 8)
62910 gintout = peek(aes# + 12)
62912 addrin  = peek(aes# + 16)
62914 addrout = peek(aes# + 20)
62916 return
62918 ' --------------------------------------------------
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
63042 HIDEMOUSE:
63044 poke contrl    , 123
63046 vdisys
63048 return
63049 ' ------------------------------------------------
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
63500 FILLPATTERN:
63502 ' -----> restore MONSTER
63504 poke contrl    , 112
63506 poke contrl + 6, 16
63508 for st = 0 to 30 step 2
63510 read MONSTER
63512 poke intin + st, monster
63514 next: vdisys
63516 return
63518 ' -----------------------------------------------
64000 RECTANGLE:
64002 ' -----> XPOS1 : YPOS1 : XPOS2 : YPOS2
64004 poke contrl    , 11
64006 poke contrl + 2, 2
64008 poke contrl + 6, 0
64010 poke contrl + 10, 1
64012 poke ptsin    , XPOS1 + 1
64014 poke ptsin + 2, YPOS1 + 38
64016 poke ptsin + 4, XPOS2 + 1
64018 poke ptsin + 6, YPOS2 + 38
64020 vdisys
64022 return
64024 ' --------------------------------------------------
64026 '
64030 RECTANGLEROUND:
64032 ' -----> XPOS1 ; YPOS1 ; XPOS2 ; YPOS2
64034 ' -----> FILLING  0  or <> 0
64035 '
64036 poke contrl    , 11
64038 poke contrl + 2, 2
64040 poke contrl + 6, 0
64042 if FILLING = 0 then poke contrl + 10,8 else poke contrl + 10,9
64044 poke ptsin    , XPOS1 + 1
64046 poke ptsin + 2, YPOS1 + 38
64048 poke ptsin + 4, XPOS2 + 1
64050 poke ptsin + 6, YPOS2 + 38
64052 vdisys
64054 return
64056 '--------------------------------------------------
64057 '
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
64200 LINESEND:
64201 ' -----> BEGINFORM ; ENDFORM
64202 poke contrl    , 108
64204 poke contrl + 2, 1
64206 poke contrl + 6, 0
64208 poke intin    , BEGINFORM
64210 poke intin + 2, ENDFORM
64212 vdisys
64214 return
64216 '--------------------------------------------------
64217 '
64220 LINETHICKNESS:
64222 ' -----> THICK
64224 poke contrl    , 16
64226 poke contrl + 2, 1
64228 poke contrl + 6, 0
64230 poke ptsin, THICK
64232 poke ptsin + 2, 0
64234 vdisys
64236 return
64238 '-------------------------------------------------
64239 '
64240 LINEPATTERN:
64242 ' -----> PATTERN
64244 '        1 - 7
64246 poke contrl    , 15
64248 poke contrl + 2, 0
64250 poke contrl + 6, 1
64252 poke intin, PATTERN
64254 vdisys
64256 return
64258 '------------------------------------------------
64259 '
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
65000 TEXTMODE:
65002 ' -----> TEXTKIND:
65004 '        0 = normal     1 = double strike   2 = light
65006 '        4 = italics    8 = underlined     16 = hollow
65008 '             or combinations
65010 '
65012 poke contrl    , 106
65014 poke contrl + 2, 0
65016 poke contrl + 6, 1
65018 poke intin, TEXTKIND
65020 vdisys
65022 return
65024 '------------------------------------------------
65025 '
65030 TEXTSIZE:
65032 ' -----> SIZE:
65034 '           < 9 = very small          9 = small
65036 '       10 - 15 = normal        16 - 17 = big
65038 '       18 - 19 = very big
65040 '
65042 poke contrl    , 107
65044 poke contrl + 2, 0
65046 poke contrl + 6, 1
65048 poke intin, SIZE
65050 vdisys
65052 return
65054 '-------------------------------------------------
65055 '
65060 TEXTOUTPUT:
65062 ' -----> TEXT$  ; XPOS ; YPOS
65064 '   text on scale
65066 for i = 0 to len(TEXT$ ) - 1
65068 poke intin + i * 2, asc(mid$(TEXT$ , i + 1, 1))
65070 next i
65072 poke intin + i * 2, 0
65074 poke contrl    , 8
65076 poke contrl + 2, 1
65078 poke contrl + 6, len(TEXT$ ) + 1
65080 poke ptsin    , XPOS + 1
65082 poke ptsin + 2, YPOS + 38
65084 vdisys
65086 return
65088 '------------------------------------------------
65089 '
65100 TEXTANGLE:
65102 ' -----> ANGLE:
65104 '      angle = 0 ; 900 ; 1800 ; 2700 degrees
65106 poke contrl    , 13
65108 poke contrl + 2, 0
65110 poke contrl + 6, 1
65112 poke intin, ANGLE
65114 vdisys
65116 return
65118 '-----------------------------------------------
65119 '
65130 TEXTFORM:
65132 ' -----> FORM (1 - 4)
65134 '
65136 '        3 = XOR               4 = revers, mix
65138 poke contrl    ,32
65140 poke contrl + 2,0
65142 poke contrl + 6,1
65144 poke intin, form
65146 vdisys
65148 return
65150 '-----------------------------------------------
65151 '
65200 CLIPPING:
65202 ' -----> XPOS1, YPOS1, XPOS2, YPOS2
65204 poke contrl   , 129
65210 poke intin    , 1       : 'Clipping on (0 = uit)
65212 poke ptsin    , xpos1   : '0
65214 poke ptsin + 2, ypos1   : '0
65216 poke ptsin + 4, xpos2   : '600
65218 poke ptsin + 6, ypos2   : '400
65220 vdisys
65222 return
65224 ' -----------------------------------------------
65250 FRAMING:
65252 ' -----> FRAME (0,1)
65254 poke contrl    , 104
65256 poke intin     , frame
65258 vdisys
65260 return
65262 ' -----------------------------------------------
65300 LETTERSIZING:
65302 ' -----> LETTERSIZE
65304 poke contrl    , 12
65306 poke ptsin + 2 , lettersize
65308 vdisys
65310 return
65312 ' -----------------------------------------------
