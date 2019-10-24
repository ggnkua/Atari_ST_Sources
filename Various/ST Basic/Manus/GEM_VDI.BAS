62000 SETWIND:
62002 ' -----> XPOS   ; YPOS ; WIDTHE (WIDTH gives an error)
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
62152 ' -----> WIDTHE ; HEIGHT ; XOLD ; YOLD
62154 ' -----> XNEW   ; YNEW  
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

