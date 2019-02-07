1000  'Dragon Maze:  Copyright 1986 Antic Publishing (START Winter '87)
1005  'Start the Program
1010  Mx=13:My=11:Scx=22:Scy=14:DDir=0  'initialize variables
1015  HighScore=0:Score=0:OldScore=0:NumMove=0
1020  Dim Maze(Mx,My),Title$(15):Door=0:Title$="Dragon Maze"+Chr$(0)
1030  Fullw 2:Clearw 2:Gosub NewTitle 'open/clear the output window
1032  Gosub TitleScreen  'display the title screen
1035  Gosub SetUpJoystick 'fill w/white and get choice of keys or joystick
1037  Gosub HiddenMaze 'see if maze should be hidden or visible
1040  Clearw 2:  Color 1,1,1:Fill 1,1 'clear screen to black
1050  For Xx=0 To Mx:For Yy=0 To My
1060  Maze(Xx,Yy)=15:Next Yy:Next Xx
1070  Gosub DrawMaze
1080  X=0:Y=Int(Rnd(1)*My):If H=0 Then Clearw 2:Color 1,1,1:Fill 1,1 'hide maze
1090  Color 1,1,0:Linef 0,0,(Mx+1)*Scx-1,0
1100  Linef (Mx+1)*Scx-5,0,(Mx+1)*Scx-5,(My+1)*Scy
1110  Linef (Mx+1)*Scx-5,(My+1)*Scy,0,(My+1)*Scy
1120  Linef 0,(My+1)*Scy,0,0  'draw the borders
1130  DrX=Mx:DrY=Int(Rnd(1)*My)
1140  Maze(DrX,DrY)=Maze(DrX,DrY) OR 32  'put in exit
1150  Color 1,1,1:Linef Scx*(Drx+1)-5,Scy*Dry,Scx*(Drx+1)-5,Scy*(Dry+1) 'punch a hole for the exit
1160  Poke Contrl,14:Poke Contrl+2,0:Poke Contrl+6,4:Poke Intin,2
1170  Poke Intin+2,0:Poke Intin+4,800:Poke Intin+6,0
1180  VdiSys(1)  'set color 2 (the dragon) to green
1190  Poke Contrl,14:Poke Contrl+2,0:Poke Contrl+6,4:Poke Intin,3
1200  Poke Intin+2,800:Poke Intin+4,0:Poke Intin+6,0
1210  VdiSys(1)  'set color 3 (the player) to red
1220  Color 1,2,2  'choose green
1230  PCircle DrX*Scx+10,DrY*Scy+8,6  'Draw the Dragon
1240  Color 1,3,3  'choose red
1250  PCircle X*Scx+10,Y*Scy+8,6     'Draw the Player
1270  While Door=0 'test for exit found (1) or eaten by dragon (2)
1280  If A=74 Or A=106 Then Goto RdStick 'use the read joystick routine
1290  Ans=Inp(2):If Ans=0 Then Goto 1290  'because Inkey$ doesn't work
1295  NumMove=NumMove+1
1300  If Ans=203 Then Gosub Left  'the left arrow
1310  If Ans=205 Then Gosub Right 'the right arrow
1320  If Ans=200 Then Gosub Up  'the up arrow
1330  If Ans=208 Then Gosub Down  'the down arrow
1340  Goto 1410  'read the keys again
1350  RdStick:  'read the joystick
1360  Joystick= Peek(&hfffc02):If Joystick<0 Or Joystick=255 Then Goto 1360
1370  If Joystick=1279 Then Gosub Left  'left push on stick
1380  If Joystick=2303 Then Gosub Right  'right push on stick
1390  If Joystick=511 Then Gosub Up  'up push on stick
1400  If Joystick=767 Then Gosub Down  'down push on stick
1410  Gosub MoveDragon 'go move the dragon
1415  Wend  'end of the While Door=0 loop
1420  Poke &hfffc02,&h0008  'turn on mouse
1430  If Door=2 Then Goto Eaten  'the dragon ate you
1435  Score=500-2*NumMove
1440  Color 2,0,0 'white sign
1450  For lp=50 to 100
1460  Linef 30,lp,250,lp
1470  Next lp:Color 2,0,3
1475  Linef 30,50,250,50:Linef 250,50,250,100
1476  Linef 250,100,30,100:Linef 30,100,30,50  'borders
1480  GotoXY 4,6:Print "Score: ";Score
1490  If Score>HighScore Then HighScore=Score
1500  GotoXY 4,7:Print "High Score: ";HighScore
1510  GotoXY 4,8:Print "Press P to Play, Q to Quit"
1520  Aq=Inp(2):If Aq=0 Then Goto 1520
1530  If Aq=80 or Aq=112 Then Door=0:NumMove=0:ClearW 2:Goto 1035
1540  If Aq=81 or Aq=113 Then Color 1,1,1:Title$="OUTPUT"+Chr$(0):Gosub NewTitle:End
1550  Aq=0:Goto 1520
1560  Eaten:  'the dragon ate you
1570  Color 2,0,0
1580  For lp=50 to 100
1590  Linef 30,lp,250,lp
1600  Next lp:Color 2,0,3
1610  Linef 30,50,250,50:Linef 250,50,250,100
1620  Linef 250,100,30,100:Linef 30,100,30,50  'borders
1630  GotoXY 4,6:Print "The Dragon Ate You!"
1640  Goto 1510
2000  DrawBlock:  'Draws each block of the maze
2010  If (Maze(Dx,Dy) AND 1)<>0 THEN Color 1,1,0  Else Color 1,1,1
2020  Linef Scx*(Dx+1),Scy*Dy,Scx*(Dx+1),Scy*(Dy+1)
2030  If (Maze(Dx,Dy) AND 2)<>0 THEN Color 1,1,0 Else Color 1,1,1
2040  Linef Scx*Dx,Scy*(Dy+1),Scx*(Dx+1),Scy*(Dy+1)
2050  If (Maze(Dx,Dy) AND 4)<>0 THEN Color 1,1,0 Else Color 1,1,1
2060  Linef Scx*Dx,Scy*Dy,Scx*Dx,Scy*(Dy+1)
2070  If (Maze(Dx,Dy) AND 8)<>0 THEN Color 1,1,0 Else Color 1,1,1
2080  Linef Scx*Dx,Scy*Dy,Scx*(Dx+1),Scy*Dy
2090  Return
2100  NewX: 'Uses loop variable D to calculate a new value of X
2110  If D=1 Then Nx=X+1:Return
2120  If D=3 Then Nx=X-1:Return
2130  Nx=X:Return
2150  NewY: 'Uses loop variable D to calculate a new value of Y
2160  If D=0 Then Ny=Y-1:Return
2170  If D=2 Then Ny=Y+1:Return
2180  Ny=Y:Return
2200  FindNewBlock: 'Determine whether a block is next to an unused one
2210  NewBlock=0  'assume it is not
2220  For D=0 To 3
2230  Gosub NewX:Gosub NewY
2240  If (Nx>=0) AND (Ny>=0) AND (Nx<=Mx) AND (Ny<=My) THEN If Maze(Nx,Ny)=15 THEN NewBlock=1
2250  Next D
2260  Return
2300  FindAllUsed:   'See if all blocks are used
2310  AllUsed=1  'assume they are
2320  For Lx=0 To Mx
2330  For Ly=0 To My
2340  If Maze(Lx,Ly)=15 Then AllUsed=0  'they're not!
2350  Next Ly:Next Lx
2360  Return
2400  AddBlock:  'Put a block in the Maze
2410  If D<>0 Then Goto 2450
2420  Maze(X,Y)=Maze(X,Y) AND 7:Maze(Nx,Ny)=Maze(Nx,Ny) AND 13
2430  Dx=X:Dy=Y:Gosub DrawBlock:Dx=Nx:Dy=Ny:Gosub DrawBlock
2440  X=Nx:Y=Ny:Return
2450  If D<>1 Then Goto 2490
2460  Maze(X,Y)=Maze(X,Y) AND 14:Maze(Nx,Ny)=Maze(Nx,Ny) AND 11
2470  Dx=X:Dy=Y:Gosub DrawBlock:Dx=Nx:Dy=Ny:Gosub DrawBlock
2480  X=Nx:Y=Ny:Return
2490  If D<>2 Then Goto 2530
2500  Maze(X,Y)=Maze(X,Y) AND 13:Maze(Nx,Ny)=Maze(Nx,Ny) AND 7
2510  Dx=X:Dy=Y:Gosub DrawBlock:Dx=Nx:Dy=Ny:Gosub DrawBlock
2520  X=Nx:Y=Ny:Return
2530  If D<>3 Then Goto 2560
2540  Maze(X,Y)=Maze(X,Y) AND 11:Maze(Nx,Ny)=Maze(Nx,Ny) AND 14
2550  Dx=X:Dy=Y:Gosub DrawBlock:Dx=Nx:Dy=Ny:Gosub DrawBlock
2560  X=Nx:Y=Ny:Return
3000  DrawMaze:  'Draw the maze
3005  Maze(0,0)=31  'put in th entrance
3010  For X1=0 To Mx: For Y1=0 To My
3030  If Maze(X1,Y1)=15 Then Goto 3125
3040  X=X1:Y=Y1
3050  BeginLoop:   'the beginning of the loop
3060  D=Int(Rnd(1)*4):Gosub NewX:Gosub NewY
3070  If (Nx<0) OR (Ny<0) OR (Nx>Mx) OR (Ny>My) Then Goto BeginLoop
3080  Holdx=Nx:Holdy=Ny:HoldD=D:Gosub FindNewBlock:Nx=Holdx:Ny=Holdy:D=HoldD
3090  If (Maze(Nx,Ny)<>15) AND (NewBlock=1) Then Goto BeginLoop
3100  If Maze(Nx,Ny)=15 Then Gosub AddBlock
3110  Holdx=Nx:Holdy=Ny:HoldD=D:Gosub FindNewBlock:Nx=Holdx:Ny=Holdy:D=HoldD
3120  If NewBlock=1 Then Goto BeginLoop
3125  Next Y1:Next X1
3130  Gosub FindAllUsed:If AllUsed=0 Then Goto 3010
3140  Return
3150  Left:  'respond to the left direction
3160  Color 1,1,0:PCircle X*Scx+10,Y*Scy+8,6  'erase current position
3170  If (Maze(X,Y) AND 4)=0 Then X=X-1 Else If H=0 Then Linef Scx*X,Scy*Y,Scx*X,Scy*(Y+1)
3180  Color 1,3,3:PCircle X*Scx+10,Y*Scy+8,6  'redraw the player
3190  Return
3200  Right:   'respond to the right direction
3210  Color 1,1,0:PCircle X*Scx+10,Y*Scy+8,6
3220  If (Maze(X,Y) AND 1)=0 Then X=X+1 Else If H=0 Then Linef Scx*(X+1),Scy*Y,Scx*(X+1),Scy*(Y+1)
3230  Color 1,3,3:PCircle X*Scx+10,Y*Scy+8,6
3240  If (Maze(X,Y) AND 32)<>0 Then Door=1  'found the exit
3250  Return
3300  Up:  'respond to the up direction
3310  Color 1,1,0: PCircle X*Scx+10,Y*Scy+8,6
3320  If (Maze(X,Y) AND 8)=0 Then Y=Y-1 Else If H=0 Then Linef Scx*X,Scy*Y,Scx*(X+1),Scy*Y
3330  Color 1,3,3:PCircle X*Scx+10,Y*Scy+8,6
3340  Return
3350  Down:  'respond to the down direction
3360  Color 1,1,0:PCircle X*Scx+10,Y*Scy+8,6
3370  If (Maze(X,Y) AND 2)=0 Then Y=Y+1 Else If H=0 Then Linef Scx*x,Scy*(Y+1),Scx*(X+1),Scy*(Y+1)
3380  Color 1,3,3:PCircle X*Scx+10,Y*Scy+8,6
3390  Return
3400  SetUpJoystick:  'get ready to read the joystick
3410  Color 1,0,1:GotoXY 2,5:Print "Use Joystick or Keyboard Arrows?"
3420  GotoXY 8,6:Print "Press J or K"
3430  A=Inp(2):If A=0 Then Goto 3430
3440  If A=74 or A=106 Then GotoXY 8,7:Print "Joystick":Goto 3470
3450  If A=75 or A=107 Then GotoXY 8,7:Print "Keyboard":Goto 3490
3460  A=0:Goto 3430
3470  Poke &hfffc02,&h0012  'turn off mouse
3480  Poke &hfffc02,&h0014  'turn on joystick
3490  Return
3500  NewTitle: 'change the window title
3510  Poke Systab+24,1
3520  a#=gb  'get globals address
3530  gintin=Peek(a#+8)  'AES Int_in array
3540  Poke gintin,Peek(Systab+8) 'OUTPUT window handle
3550  Poke gintin+2,2  'changing the window name
3560  s#=gintin+4  'double address for long poke
3570  Poke s#,varptr(title$)  ' title of window
3580  GemSys(105)  'wind_set AES call
3590  Poke systab+24,0
3600  Return
3610  HiddenMaze:  'maze hidden or visible?
3620  GotoXY 2,9:Print "Should Maze be Hidden or Visible?"
3630  GotoXY 8,10:Print "Press H or V"
3640  Hv=Inp(2):If Hv=0 Then Goto 3640
3650  If Hv=72 or Hv=104 Then GotoXY 8,11:Print "Hidden":H=0:Goto 3680
3660  If Hv=86 Or Hv=118 Then GotoXY 8,11:Print "Visible":H=1:Goto 3680
3670  Hv=0:Goto 3640
3680  Return
3700  MoveDragon:  'move the dragon
3710  Color 1,1,0:PCircle Drx*Scx+10,Dry*Scy+8,6 'erase the dragon
3720  DDir=(DDir+2) Mod 4  'start with Dragon backing up
3730  If (DDir=0) AND ((Maze(DrX,DrY) AND 8)<>0) Then DDir=(DDir+1) Mod 4
3740  If (DDir=1) AND ((Maze(DrX,DrY) AND 1)<>0) Then DDir=(DDir+1) Mod 4
3750  If (DDir=2) AND ((Maze(DrX,DrY) AND 2)<>0) Then DDir=(DDir+1) Mod 4
3760  If (DDir=3) AND ((Maze(DrX,DrY) AND 4)<>0) Then DDir=(DDir+1) Mod 4
3770  Jump=Int(Rnd(1)*20) 'sometimes, the dragon will jump a wall!
3780  If (Y<DrY) AND (((Maze(DrX,DrY) AND 8)=0) Or (Jump=0)) Then DDir=0
3790  If (X>DrX) AND (((Maze(DrX,DrY) AND 1)=0) Or (Jump=0)) Then DDir=1
3800  If (Y>DrY) AND (((Maze(DrX,DrY) AND 2)=0) Or (Jump=0)) Then DDir=2
3810  If (X<DrX) AND (((Maze(DrX,DrY) AND 4)=0) Or (Jump=0)) Then DDir=3
3820  If DDir=0 Then DrY=DrY-1
3830  If DDir=1 Then DrX=DrX+1
3840  If DDir=2 Then DrY=DrY+1
3850  If DDir=3 Then DrX=DrX-1
3860  Color 1,2,2:PCircle Drx*Scx+10,DrY*ScY+8,6 'enter the dragon
3870  If (DrX=X) And (DrY=Y) Then Door=2 'eaten by the dragon!
3880  Color 1,3,3:PCircle X*Scx+10,Y*Scy+8,6  'redraw the player
3890  Return
3900  TitleScreen:  'display the title screen
3910  Color 1,2,3,9,3
3920  Linef 0,0,303,0:Linef 0,1,303,1
3930  Linef 303,0,303,166:Linef 302,0,302,166
3940  Linef 303,166,0,166:Linef 303,165,0,165
3950  Linef 0,166,0,0:Linef 1,166,1,0
3960  Fill 10,10:Special=4:Gosub TextEffects
3970  GotoXY 6,3:Print "START and David Plotkin"
3975  Special=0:Gosub TextEffects
3980  GotoXY 13,5:Print "Present"
3990  Aa=10:Title$="D R A G O N  M A Z E":Gosub TextHeight
4000  GotoXY 7,10:Print "Use Joystick in Port 1"
4010  GotoXY 7,11:Print "or Keyboard Arrows to"
4020  GotoXY 7,12:Print "to find your way out of"
4030  GotoXY 7,13:Print "the Dragon's Maze":Gosub Playtune
4040  GotoXY 5,15:Print "Press any key to continue"
4050  Kk=Inp(2):If Kk=0 Then Goto 4050
4060  ClearW 2:Color 1,2,3,1,1:Return
4100  TextEffects:  'set special effects for text
4110  Poke Contrl,106:Poke contrl+2,0:Poke Contrl+6,1
4120  Poke Intin,Special
4130  VdiSys(1)
4140  Return
4150  TextHeight:  'set character height, absolute mode
4160  Gosub SetHeight
4170  For I=1 To Len(Title$)
4180  Poke Intin+(I-1)*2,Asc(Mid$(Title$,I,1))
4190  Next I
4200  Poke Intin+(I-1)*2,0
4210  Poke Contrl,8
4220  Poke Contrl+2,1
4230  Poke Contrl+6,Len(Title$)+1
4240  Poke Ptsin,70  'x coordinate
4250  Poke Ptsin+2,100 'y coordinate
4260  VdiSys(1)
4270  Aa=9:Gosub SetHeight  'back to normal
4280  Return
4290  SetHeight:
4300  Poke Contrl,107
4310  Poke Contrl+2,0
4320  Poke Contrl+6,1
4330  Poke Intin,Aa
4340  VdiSys(1)
4350  Return
4400  Playtune:  'play the opening title tune
4410  Wave 7:For numnotes=1 to 28:Read Note
4420  Sound 1,10,Note,4,6:Sound 2,10,Note,3,6
4430  Next numnotes:Sound 1,0,0,0,0:Sound 2,0,0,0,0
4440  Data 1,1,3,3,5,6,8,1,1,3,3,5,6,8,8,10,11,11,8,10,11,1,3,5,5,1,3,5
4450  Return
