' All main variables are global.
'
Creell=0.745428
Cimag=0.113009
'
Mmandelbrot=42                 !These are the menu entry constants
Mjuliaset=43
Mkoor=11
Mstepxy=12
Mmax=13
Mgrenz=14
Mcree=16
Mcim=17
Mstandpar=19
Mjuliakonst=30
Mzeich=27
Mgross=28
Mgrau=45
'
Lim=50                ! Limit of pictures internally stored
'
Dim Val(Lim,11)       ! Array to store the data from which each picture
'                       is calculated
Dim Val$(Lim)         ! Array to store the actual pictures in
'
Dat=1                 ! Index to the current array position
'                     ! for both Val,Val$
Maxdat=1              ! Index to the last picture currently stored, so that
'                     ! nothing is lost when one goes to previous pictures
'
Dim A$(49)                  ! Menu installation
A$(0)="Desk "
A$(1)=" Info            "
A$(2)="-----------------"
A$(3)="1"
A$(4)="2"
A$(5)="3"
A$(6)="4"
A$(7)="5"
A$(8)="6"
A$(9)=""
A$(10)="Param"
A$(11)="  Coordinates"
A$(12)="  Step X, Step y     "
A$(13)="  Maxiterat          "
A$(14)="  Limit              "
A$(15)="---------------------"
A$(16)="  CReal              "
A$(17)="  CImaginary         "
A$(18)="---------------------"
A$(19)="  Standard Parameter "
A$(20)="---------------------"
A$(21)="  Show Parameters    "
A$(22)="  Print Parameters   "
A$(23)=""
A$(24)="Go"
A$(25)=" Start                 "
A$(26)="-----------------------"
A$(27)=" Redraw Area           "
A$(28)=" Enlarge Area          "
A$(29)="-----------------------"
A$(30)=" Choose Julia-Constant "
A$(31)=""
A$(32)="Files"
A$(33)="  Save Picture    "
A$(34)="  Load Picture    "
A$(35)="------------------"
A$(36)="  Save Data       "
A$(37)="  Load Data       "
A$(38)="------------------"
A$(39)="  Next Picture    "
A$(40)="  Last Picture    "
A$(41)="------------------"
A$(42)="  Draw Mandel     "
A$(43)="  Draw Julia      "
A$(44)="------------------"
A$(45)="  Show Grayshades "
A$(46)="------------------"
A$(47)=" Quit "
A$(48)=""
A$(49)=""
'
' This is the main program
Start=False       ! Tells if the picture is to be drawn using the GO command
'                 ! (TRUE) or the REDRAW,ENLARGE commands (false)
'
@Initvalues
@Setxandy
'
Hidem
Cls
Sget Val$(1)           !Save initial screen
Showm
'
Menu A$()
Menu Off
On Menu  Gosub Menustuff
@Menudefaults
Do
  On Menu
Loop
' End of Main Program
'
Procedure Initvalues
  Xstart%=0
  Ystart%=0
  X0max%=320       !Resolution values
  X2max%=640
  Y0max%=200
  Y2max%=400
Return
'
Procedure Setxandy  ! Sets Xmax and Ymax according to resolution
  Rez%=Xbios(4)
  If Rez%=0 Then
    Xvalue%=X0max%
    Yvalue%=Y0max%
  Else
    If Rez%=1 Then
      Alert 1,"Program runs only in Low |or Highres.|",1," Oh ",Bt%
      End
    Else
      Xvalue%=X2max%
      Yvalue%=Y2max%
    Endif
  Endif
Return
'
Procedure Calcvars   ! Converts the screen coordinates to coords in the
  Rminl=(Rechts-Links)*(1/Xvalue%)    ! complex plane
  Ominu=(Oben-Unten)*(1/Yvalue%)
Return
'
Procedure Disablemanual ! Disables manual parameter entry options in the
  Menu Mkoor,2          ! menu
  Menu Mstepxy,2
  Menu Mmax,2
  Menu Mgrenz,2
  Menu Mcree,2
  Menu Mcim,2
Return
'
Procedure Enablemanual
  Menu Mkoor,3
  Menu Mstepxy,3
  Menu Mmax,3
  Menu Mgrenz,3
  Menu Mcree,3
  Menu Mcim,3
Return
'
Procedure Showmenu   ! Shows menu with the current settings
  Menu A$()
  If Rez%=2 Then
    If Grau Then    !Grau = gray
      Menu Mgrau,1
    Else
      Menu Mgrau,0
    Endif
  Else
    Menu Mgrau,2
  Endif
  If Not Start Then
    Menu Mzeich,2
    Menu Mgross,2
  Else
    Menu Mzeich,3
    Menu Mgross,3
  Endif
  If Not Julia Then
    Menu Mmandelbrot,1
    Menu Mjuliaset,0
    Menu Mjuliakonst,3
  Else
    Menu Mmandelbrot,0
    Menu Mjuliaset,1
    Menu Mjuliakonst,2
  Endif
  If Inpar Then        ! Inpar=True => standart parameters
    Menu Mstandpar,1
    @Disablemanual
  Else
    Menu Mstandpar,0
    @Enablemanual
  Endif
Return
'
Procedure Introduction
  Print At(1,3);
  Print "     THE  CHAOSGENERATOR V25.00"
  Print
  Print "This   program  calculates  and  draws "
  Print "pictures of the socalled    Mandelbrot "
  Print "and Julia Sets.                        "
  Print
  Print "The   program   scans   and   draws  a "
  Print "selectable  area   of the   imaginary  "
  Print "coordinate  plane."
  Print "Black    points  lie     whithin   the "
  Print "sets, coloured points at the borders or"
  Print "outside.  "
  Print "                                       "
  Print "The  program works in low res colour or"
  Print "monochrome.    For   more  interesting "
  Print "results   one  should  choose   colour "
  Print "since the gray shades  in   monochrome "
  Print "do not look pretty good.               "
  Print "                                       "
  Print "                                       "
  Print "Press a key, please                    "
  L=Gemdos(7)
  Print At(1,3);
  Print "A   picture calculation can be stopped "
  Print "at any time by pressing a mousebutton. "
  Print "                                       "
  Print "                                       "
  Print "The  program    is    completely menu  "
  Print "controlled.                            "
  Print "                                       "
  Print "============= M E N U ================="
  Print "                                       "
  Print " Param :                               "
  Print "                                       "
  Print "Under Param one can enter the parameter"
  Print "necessary for the  calculations  of  a "
  Print "picture, either by hand or by standard "
  Print "default. Standard parameters  are  set "
  Print "automatically  at  the  start  of  the "
  Print "program.To manually enter  the  values "
  Print "one   has  to  deselect  the  Standard "
  Print "Parameter entry.                       "
  Print "                                       "
  Print "Press a key please.                    "
  L=Gemdos(7)
  Print At(1,3);
  Print " Go:                                   "
  Print "                                       "
  Print "Under Go  are  the  commands  to  work "
  Print "the picture.                           "
  Print "START begins  a  new picture according "
  Print "to the selected parameters.            "
  Print "                                       "
  Print "REDRAW AREA  allows the  selection  of "
  Print "a picture area, which is then  redrawn "
  Print "according to  Step,Limit  and Maxiterat"
  Print "values.                                "
  Print "                                       "
  Print "ENLARGE AREA allows the  selection  of "
  Print "a picture area, which is then drawn in "
  Print "full screen size.                      "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "Press a key please.                    "
  L=Gemdos(7)
  Print At(1,3);
  Print "Watch out that  you  set  the  correct "
  Print "parameters, especially the STEP X  and "
  Print "STEP Y values, BEFOR you redraw or en- "
  Print "large an area, as the program directly "
  Print "starts with the drawing  without  any  "
  Print "request for parameter changes.         "
  Print "                                       "
  Print "CHOOSE JULIA CONSTANT   allows     the "
  Print "selection of a point of a Madelbrot Set"
  Print "This   point  is  then  taken  as  the "
  Print "complex   constant  for  a  Julia  Set "
  Print "                                       "
  Print "For every point  of a  Mandelbrot  Set "
  Print "there  is  a  Julia  Set.  Interesting "
  Print "Julia Sets are  produced  with  points "
  Print "at the borders of a Madelbrot Set.     "
  Print "                                       "
  Print "Remember  here  as  well  to  set  the "
  Print "correct  parameter.  A hint:  set  the "
  Print "program to  Standard Parameter.        "
  Print "                                       "
  Print "Press a key please.                    "
  L=Gemdos(7)
  Print At(1,3);
  Print "FILES:                                 "
  Print "                                       "
  Print "LOAD / SAVE PICTURE     loads / saves  "
  Print "a  low  res  picture  in  uncompressed "
  Print "Degas-Format, a  monochrome picture in "
  Print "screenformat. Screenformat can be read "
  Print "with STAD.                             "
  Print "                                       "
  Print "During loading the current picture  in "
  Print "memory will be overwritten.            "
  Print "                                       "
  Print "It is to note, that ONLY  the  picture "
  Print "will be loaded or saved, and  NOT  the "
  Print "corresponding parameters !             "
  Print "                                       "
  Print "The parameters have to be saved/loaded "
  Print "using the SAVE / LOAD DATA commands.   "
  Print "The current data in memory  is  over - "
  Print "written during loading !               "
  Print "                                       "
  Print "                                       "
  Print "Press a key please.                    "
  L=Gemdos(7)
  Print At(1,3);
  Print "NEXT / LAST PICTURE                    "
  Print "                                       "
  Print "Every picture and its data is  intern- "
  Print "ally saved after  every  operation  or "
  Print "a mouse break.                         "
  Print "                                       "
  Print "Using  'Next / last picture'  one  can "
  Print "get those saved pictures back onto the "
  Print "screen.                                "
  Print "                                       "
  Print "This is especially  intended  for  the "
  Print "event that one wants to get back to the"
  Print "original picture after an enlargement  "
  Print "or  julia  constant  choice  does  not "
  Print "please.                                "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "Press a key please.                    "
  Print "                                       "
  L=Gemdos(7)
  Print At(1,3);
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "        !!!! WARNING !!!!              "
  Print "                                       "
  Print "If a new enlargement  or  julia  point "
  Print "selection is made after  returning  to "
  Print "the  original  picture,  the  previous "
  Print "enlargement or julia selection is over-"
  Print "written !!!!!                          "
  Print "                                       "
  Print "The program can only store 50 pictutes."
  Print "When the last picture is reached, any  "
  Print "new picture will overwrite the old one."
  Print "When the 2nd last picture is reached,a "
  Print "warning will be given.                 "
  Print "                                       "
  Print "Press a key please.                    "
  Print "                                       "
  L=Gemdos(7)
  Print At(1,3);
  Print "This program is Public Domain.         "
  Print "It may be freely copied but  NOT  sold "
  Print "provided this text remains unchanged,  "
  Print "except for additions about improvements"
  Print "                                       "
  Print "                                       "
  Print " (C) 27.01.1992 Michael Jueschke       "
  Print "                Perth                  "
  Print "                West Australien        "
  Print "                                       "
  Print "Thanks to  Maik Zielinsky              "
  Print "           Wipperfuerth-Kreuzberg      "
  Print "                                       "
  Print "      and  Andreas Ernst               "
  Print "           Perth                       "
  Print "                                       "
  Print "                                       "
  Print "                                       "
  Print "Press a key please.                    "
  L=Gemdos(7)
  Sput Val$(Dat)     ! Write picture in the array at position dat to screen
  @Showmenu
Return
'
Procedure Initparameters
  If Julia Then
    Oben=1           !These four mean Top,Bottom,Left,Right
    Unten=-1
    Links=-1.5
    Rechts=1.5
  Else
    Oben=1.2
    Unten=-1.2
    Links=-0.5
    Rechts=2.1
  Endif
  Grenze%=4        ! limit
  Maxiterat%=100
  If Rez%=2 Then
    Stepx%=5
    Stepy%=5
  Else
    Stepx%=3
    Stepy%=3
  Endif
Return
'
Procedure Emptymouse  ! get rid off previous mousebutton presses.
  While C%<>0
    Mouse Xm%,Ym%,C%
  Wend
Return
'
Procedure Calculatejulia
  X=Xwert%*Rminl+Links      !Xwert , Ywert are the running screen coords
  Y=Oben-Ywert%*Ominu       ! X,Y are the complex coords
  Repeat
    Inc Iterat%
    Xhoch2=X*X
    Yhoch2=Y*Y
    Wegho2=Xhoch2+Yhoch2
    Y=2*X*Y-Cimag
    X=Xhoch2-Yhoch2-Creell
    Mouse Xm%,Ym%,C%
  Until (Iterat%=Maxiterat%) Or (Wegho2>Grenze%) Or C%=1
Return
'
Procedure Calculatemandel
  X=0
  Y=0
  Cre=Xwert%*Rminl+Links
  Cim=Oben-Ywert%*Ominu
  Repeat
    Inc Iterat%
    Xhoch2=X*X
    Yhoch2=Y*Y
    Wegho2=Xhoch2+Yhoch2
    Y=2*X*Y-Cim
    X=Xhoch2-Yhoch2-Cre
    Mouse Xm%,Ym%,C%
  Until (Iterat%=Maxiterat%) Or (Wegho2>Grenze%) Or C%=1
Return
'
Procedure Steprate      ! Used to create pixel gray shades
  Dl%=(Iterat% Mod 15)  ! It sets a value and only plots a point when
  Dl%=Abs(Dl%)          ! the value has reached 0 and the then current
  If Dl%>=0 And Dl%<3 Then  ! point is black.
    Ste%=3                  ! ( the looping and plotting is actually done
  Else                      !   in a different procedure, here the ste%
    If Dl%>=3 And Dl%<4 Then !  is only set to a value )
      Ste%=4
    Else
      If Dl%>=4 And Dl%<5 Then
        Ste%=2
      Else
        If Dl%>=5 And Dl%<6 Then
          Ste%=4
        Else
          If Dl%>=6 And Dl%<8 Then
            Ste%=2
          Else
            If Dl%>=8 And Dl%<9 Then
              Ste%=4
            Else
              If Dl%>=9 And Dl%<11 Then
                Ste%=3
              Endif
            Endif
          Endif
        Endif
      Endif
    Endif
  Endif
Return
'
Procedure Stepstepon20  ! Calculates and plots a highres block picture
  Repeat                ! without symetry (either Mandel or Julia)
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2%=0
      If Julia Then
        @Calculatejulia
      Else
        @Calculatemandel
      Endif
      If Iterat%=Maxiterat% Then
        Deffill 1,1
      Else
        If Grau Then
          Deffill 1,2,(Iterat% Mod 15)+8
        Else
          Deffill 0,1
        Endif
      Endif
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1  ! Xvalue, Yvalue are the right,bottom
    Add Ywert%,Stepy%              ! limits of the drawing area.
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Stepstepon21  ! Highres block picture for Julia set with
  Repeat                ! point symetry about the origin
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2%=0
      @Calculatejulia
      Xx%=Xvalue%-Xwert%
      Yy%=2*Yvalue%-Ywert%
      If Iterat%=Maxiterat% Then
        Deffill 1,1
      Else
        If Grau Then
          Deffill 1,2,(Iterat% Mod 15)+8
        Else
          Deffill 0,1
        Endif
      Endif
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Pbox Xx%,Yy%,Xx%-Stepx%,Yy%-Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Stepstepon22  ! Mandel highres block picture with line symetry
  Repeat                ! about the real ( x ) axis.
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2%=0
      @Calculatemandel
      Yy%=2*Yvalue%-Ywert%
      If Iterat%=Maxiterat% Then
        Deffill 1,1
      Else
        If Grau Then
          Deffill 1,2,(Iterat% Mod 15)+8
        Else
          Deffill 0,1
        Endif
      Endif
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Pbox Xwert%,Yy%,Xwert%+Stepx%,Yy%-Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Nostep20     ! Nosteps are the same as StepSteps exept that they
  Repeat               ! draw in single pixelel.
    Xwert%=Xstart%     ! The numbers indicate the resolution and the type
    Repeat             ! of symetry, eg 20 -- highres, no sym
      Iterat%=0        !                02 -- lowres , line sym
      Wegho2%=0
      If Julia Then
        @Calculatejulia
      Else
        @Calculatemandel
      Endif
      If Iterat%=Maxiterat% Then
        Color 1
        Plot Xwert%,Ywert%
        Color 0
      Else
        If Grau Then
          If Ste%=0 Then
            @Steprate
            Color 1
          Else
            Color 0
            Sub Ste%,1
          Endif
          Plot Xwert%,Ywert%
        Endif
      Endif
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Nostep21
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2%=0
      @Calculatejulia
      Xx%=Xvalue%-Xwert%
      Yy%=2*Yvalue%-Ywert%
      If Iterat%=Maxiterat% Then
        Color 1
        Plot Xwert%,Ywert%
        Plot Xx%-Xwert%,Yy%
        Color 0
      Else
        If Grau Then
          If Ste%=0 Then
            @Steprate
            Color 1
          Else
            Color 0
            Sub Ste%,1
          Endif
          Plot Xwert%,Ywert%
          Plot Xx%-Xwert%,Yy%
        Endif
      Endif
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Nostep22
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2%=0
      @Calculatemandel
      Yy%=2*Yvalue%-Ywert%
      If Iterat%=Maxiterat% Then
        Color 1
        Plot Xwert%,Ywert%
        Plot Xwert%,Yy%
        Color 0
      Else
        If Grau Then
          If Ste%=0 Then
            @Steprate
            Color 1
          Else
            Color 0
            Sub Ste%,1
          Endif
          Plot Xwert%,Ywert%
          Plot Xwert%,Yy%
        Endif
      Endif
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Stepstepon00  ! low res, no sym, blocks
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      If Julia Then
        @Calculatejulia
      Else
        @Calculatemandel
      Endif
      If Iterat%=Maxiterat% Then
        Deffill 1
      Else
        Deffill (Iterat% Mod 15)+2
      Endif
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Stepstepon01
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      @Calculatejulia
      If Iterat%=Maxiterat% Then
        Deffill 1
      Else
        Deffill (Iterat% Mod 15)+2
      Endif
      Yy%=2*Yvalue%-Ywert%
      Xx%=Xvalue%-Xwert%
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Pbox Xx%,Yy%,Xx%-Stepx%,Yy%-Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Stepstepon02
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      @Calculatemandel
      If Iterat%=Maxiterat% Then
        Deffill 1
      Else
        Deffill (Iterat% Mod 15)+2
      Endif
      Yy%=2*Yvalue%-Ywert%
      Pbox Xwert%,Ywert%,Xwert%+Stepx%,Ywert%+Stepy%
      Pbox Xwert%,Yy%,Xwert%+Stepx%,Yy%-Stepy%
      Add Xwert%,Stepx%
    Until Xwert%>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%>=Yvalue% Or C%=1
Return
'
Procedure Nostep00  ! low res, no sym, pixels
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      If Julia Then
        @Calculatejulia
      Else
        @Calculatemandel
      Endif
      If Iterat%=Maxiterat% Then
        Color 1
      Else
        Color (Iterat% Mod 15)+2
      Endif
      Plot Xwert%,Ywert%
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Nostep01
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      @Calculatejulia
      If Iterat%=Maxiterat% Then
        Color 1
      Else
        Color (Iterat% Mod 15)+2
      Endif
      Yy%=2*Yvalue%-Ywert%
      Xx%=Xvalue%
      Plot Xwert%,Ywert%
      Plot Xx%-Xwert%,Yy%
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Nostep02
  Repeat
    Xwert%=Xstart%
    Repeat
      Iterat%=0
      Wegho2=0
      @Calculatemandel
      If Iterat%=Maxiterat% Then
        Color 1
      Else
        Color (Iterat% Mod 15)+2
      Endif
      Yy%=2*Yvalue%-Ywert%
      Plot Xwert%,Ywert%
      Plot Xwert%,Yy%
      Add Xwert%,Stepx%
    Until Xwert%-1>=Xvalue% Or C%=1
    Add Ywert%,Stepy%
  Until Ywert%-1>=Yvalue% Or C%=1
Return
'
Procedure Highres     ! Called when in highres. Selects drawing proc
  If Stepstep% Then   ! according to symetry and step size.
    If Isym%=0 Then   ! StepStep   -- means steps > 1 = blocks
      @Stepstepon20   ! Isym -- type of symetry.
    Else
      If Isym%=1 Then
        @Stepstepon21
      Else
        @Stepstepon22
      Endif
    Endif
  Else
    If Isym%=0 Then
      @Nostep20
    Else
      If Isym%=1 Then
        @Nostep21
      Else
        @Nostep22
      Endif
    Endif
  Endif
Return
'
Procedure Nothighres   ! NotHighRes ---- as Highres but for low res
  If Stepstep% Then
    If Isym%=0 Then
      @Stepstepon00
    Else
      If Isym%=1 Then
        @Stepstepon01
      Else
        @Stepstepon02
      Endif
    Endif
  Else
    If Isym%=0 Then
      @Nostep00
    Else
      If Isym%=1 Then
        @Nostep01
      Else
        @Nostep02
      Endif
    Endif
  Endif
Return
'
Procedure Running   ! Main procedure. Determines symetry and resolution
  Hidem             ! Calls Highres or Nothighres
  @Emptymouse
  If Julia Then
    If Links+Rechts=0 And Oben+Unten=0 And Nosymetry=0 Then
      Isym%=1
      Div Yvalue%,2
    Else
      Isym%=0
    Endif
  Else
    If Oben+Unten=0 And Nosymetry=0 Then
      Isym%=2
      Div Yvalue%,2
    Else
      Isym%=0
    Endif
  Endif
  Ywert%=Ystart%
  Stepstep%=((Stepx%<>1) And (Stepy%<>1))
  If Rez%=2 Then
    Color 1
    @Highres
  Else
    @Nothighres
  Endif
  Showm
Return
'
Procedure Takedata  ! Saves data of current picture into array Val
  If Dat>=Lim Then  ! at position Dat
    Alert 1,"Memory limit reached.|Next picture overwrites old one!|",1," Sorry ",Btn%
  Endif
  If Dat<=Lim Then
    If Dat=Maxdat Then  ! Maxdat <> lim . Maxdat is last entry in array
      Add Maxdat,1      ! Lim is the limit size of the array
    Endif
  Endif
  Add Dat,1
  Sget Val$(Dat)
  Val(Dat,1)=Julia
  Val(Dat,2)=Oben
  Val(Dat,3)=Unten
  Val(Dat,4)=Links
  Val(Dat,5)=Rechts
  Val(Dat,6)=Maxiterat%
  Val(Dat,7)=Grenze%
  Val(Dat,8)=Creell
  Val(Dat,9)=Cimag
  Val(Dat,10)=Stepx%
  Val(Dat,11)=Stepy%
Return
'
Procedure Dragbox(Xs%,Ys%,X%,Y%)
  Color 1
  Graphmode 3
  Box Xs%,Ys%,X%,Y%
  Box Xs%,Ys%,X%,Y%
  Graphmode 0
Return
'
Procedure Getclicks   ! Waits for mouse click to mark top left dragbox
  @Emptymouse         ! corner. Then adjusts size of the box and waits
  Showm               ! for the click to mark the bottom right corner
  Repeat
    Mouse Xm%,Ym%,C%
  Until C%<>0
  Mx%=Xm%
  My%=Ym%
  @Emptymouse
  Repeat
    Mouse Xm%,Ym%,C%
    @Dragbox(Mx%,My%,Xm%,Ym%)
  Until C%<>0
  Hidem
  Sput Val$(Dat)
  Nosymetry=1     ! when a box is chosen, any symetry in the original data
Return            ! is overridden by this, as the box is unlikely to be
'                 ! symetric.
Procedure Redraw
  Menu Off        ! redraw section with new values for steps and/or
  Sput Val$(Dat)  ! maxiterat.
  Inpar=False
  @Enablemanual
  @Getclicks
  Xvalue%=Xm%   ! set corners to mousepositions from Getclicks
  Yvalue%=Ym%
  Xstart%=Mx%
  Ystart%=My%
  Deffill 1,1
  Pbox Mx%,My%,Xm%-1,Ym%-1  ! Clear section (only necessary for highres
  Graphmode 3               ! but used in low anyway)
  Pbox Mx%-1,My%-1,Xm%,Ym%
  Graphmode 0
  Sub Dat,1        ! reduce index to update existing picture in memory
  @Running         ! and not to create a new picture. Also updates the
  @Takedata        ! data set.
  @Showmenu
Return
'
Procedure Fulldraw ! Redraws a section in full screen size (enlarge)
  Menu Off
  Sput Val$(Dat)
  Inpar=False
  @Enablemanual
  @Getclicks
  Xstart%=0
  Ystart%=0
  @Setxandy
  O=Oben
  L=Links
  Oben=O-My%*(O-Unten)*(1/Yvalue%)
  Unten=O-Ym%*(O-Unten)*(1/Yvalue%)
  Links=L+Mx%*(Rechts-L)*(1/Xvalue%)
  Rechts=L+Xm%*(Rechts-L)*(1/Xvalue%)
  @Calcvars
  @Emptymouse
  Cls
  @Running
  @Takedata    ! Does not update existing picture, but creates new entries
  @Showmenu
Return
'
Procedure Drawjulia  ! Sets program values to julia set, changes menu
  Menu Off           ! settings
  Sput Val$(Dat)
  @Emptymouse
  Menu Mmandelbrot,0
  Menu Mjuliaset,1
  Menu Mjuliakonst,2
  Menu Mstandpar,1
  Inpar=True
  Julia=True
  Showm
  Repeat               ! I just noticed that this loop is an 'Emptymouse'
    Mouse Xm%,Ym%,C%
  Until C%<>0
  Creell=Xm%*Rminl+Links
  Cimag=Oben-Ym%*Ominu
  @Initparameters
  @Initvalues
  @Setxandy
  @Calcvars
  @Emptymouse
  Nosymetry=0
  Hidem
  Cls
  @Running
  @Takedata
  @Showmenu
Return
'
Procedure Readdata   ! Read current array entries in as current variables
  Julia=Val(Dat,1)
  Oben=Val(Dat,2)
  Unten=Val(Dat,3)
  Links=Val(Dat,4)
  Rechts=Val(Dat,5)
  Maxiterat%=Val(Dat,6)
  Grenze%=Val(Dat,7)
  Creell=Val(Dat,8)
  Cimag=Val(Dat,9)
  Stepx%=Val(Dat,10)
  Stepy%=Val(Dat,11)
  @Initvalues
  @Setxandy
  @Calcvars
Return
'
Procedure Loaddata
  Menu Off
  Fileselect Chr$(Gemdos(25)+65)+":\*.cao","",File$
  If File$<>"" Then
    Open "I",#1,File$
    For A=1 To 11
      Input #1,Val(Dat,A)
    Next A
    Close #1
  Endif
  Inpar=False
  @Readdata
  Start=True
  @Showmenu
Return
'
Procedure Savedata
  Menu Off
  Fileselect Chr$(Gemdos(25)+65)+":\*.cao","",File$
  If File$<>"" Then
    Open "O",#1,File$
    For A=1 To 11
      Print #1,Val(Dat,A)
    Next A
    Close #1
  Endif
Return
'
Procedure Lastpicture  ! Go back a picture (and hence go back a data set)
  Menu Off
  If Dat>1 Then
    Sub Dat,1
    @Readdata
    Sput Val$(Dat)
    @Showmenu
  Else
    Alert 1,"This is the first picture.|",1," Aha ",Bt%
  Endif
Return
'
Procedure Nextpicture ! go forward
  Menu Off
  If Dat<Maxdat Then
    Add Dat,1
    @Readdata
    Sput Val$(Dat)
    @Showmenu
  Else
    Alert 1,"This is the last picture.|",1," Aha ",Bt%
  Endif
Return
'
Procedure Loadpicture
  Menu Off
  If Rez%=0 Then
    Fileselect Chr$(Gemdos(25)+65)+":\*.PI1","",File$
    If File$<>"" Then
      Bload File$,Xbios(3)-34
    Endif
  Else
    Fileselect Chr$(Gemdos(25)+65)+":\*.PIC","",File$
    If File$<>"" Then
      Bload File$,Xbios(2)
    Endif
  Endif
  Sget Val$(Dat)
  @Showmenu
Return
'
Procedure Savepicture
  Menu Off
  If Rez%=0 Then
    Fileselect Chr$(Gemdos(25)+65)+":\*.PI1","",File$
    If File$<>"" Then
      Sput Val$(Dat)
      Bsave File$,Xbios(3)-34,32066
    Endif
  Else
    Fileselect Chr$(Gemdos(25)+65)+":\*.PIC","",File$
    If File$<>"" Then
      Sput Val$(Dat)
      Bsave File$,Xbios(2),32000
    Endif
  Endif
  @Showmenu
Return
'
Procedure Finish
  Menu Off
  Alert 1," Abbort program ? | Has the picture been saved ?|",2," Exit | Back | Save ",Btn%
  If Btn%=1 Then
    Menu Kill
    End
  Else
    If Btn%=3 Then
      @Savepicture
    Endif
  Endif
Return
'
Procedure Inputcoords
  Menu Off
  Print At(1,3);"Top  ";Oben;" : ";
  Input Oben
  Print "Bottom ";Unten;" : ";
  Input Unten
  Print "Left  ";Links;" : ";
  Input Links
  Print "Right  ";Rechts;" : ";
  Input Rechts
  Sput Val$(Dat)  ! Restore picture as it was before writing all over it
Return
'
Procedure Inputgrenze
  Menu Off
  Print At(1,3);"Limit  ";Grenze%;" : ";
  Input Grenze%
  Sput Val$(Dat)
Return
'
Procedure Inputmaxiterat
  Menu Off
  Print At(1,3);"Maxiterat ";Maxiterat%;" : ";
  Input Maxiterat%
  Sput Val$(Dat)
Return
'
Procedure Inputcreell
  Menu Off
  Print At(1,3);"CReal  ";Creell;" : ";
  Input Creel
  Sput Val$(Dat)
Return
'
Procedure Inputcimg
  Menu Off
  Print At(1,3);"CImag ";Cimag;" : ";
  Input Cimag
  Sput Val$(Dat)
Return
'
Procedure Inputstep
  Menu Off
  Print At(1,3);"Step X ";Stepx%;" : ";
  Input Stepx%
  Print "Step Y ";Stepy%;" : ";
  Input Stepy%
  Sput Val$(Dat)
Return
'
Procedure Printvalues
  Menu Off
  If Bios(8,0)=-1 Then
    If Julia Then
      Lprint "Julia Set"
      Lprint
      @Printconstants
    Else
      Lprint "Mandelbrot Set"
      Lprint
    Endif
    Lprint "TOP       ";Oben
    Lprint "BOTTOM    ";Unten
    Lprint "LEFT      ";Links
    Lprint "RIGHT     ";Rechts
    Lprint "LIMIT     ";Grenze%
    Lprint "MAXITERAT ";Maxiterat%
    Lprint "STEP X    ";Stepx%
    Lprint "STEP Y    ";Stepy%
  Else
    Alert 1,"Printer is not ready !|",1," Ups ",Bt%
  Endif
Return
'
Procedure Printconstants
  Lprint "CImg      ";Cimag
  Lprint "CReal     ";Creell
  Lprint
Return
'
Procedure Listvalues
  Menu Off
  If Julia Then
    Print At(1,4);"Julia Set"
    Print
    @Listconstants
  Else
    Print At(1,4);"Mandelbrot Set"
    Print
  Endif
  Print "TOP       ";Oben
  Print "BOTTOM    ";Unten
  Print "LEFT      ";Links
  Print "RIGHT     ";Rechts
  Print "LIMIT     ";Grenze%
  Print "MAXITERAT ";Maxiterat%
  Print "STEP X    ";Stepx%
  Print "STEP Y    ";Stepy%
  Print
  Print "Press a key please."
  L=Gemdos(7)
  Sput Val$(Dat)
  @Showmenu
Return
'
Procedure Listconstants
  Print "CImg      ";Cimag
  Print "CReal     ";Creell
  Print
Return
'
Procedure Startup   ! Called when 'GO' is chosen in the menu.
  Menu Off          ! It initiallises all relevant data for a full
  Start=True        ! screen draw (mainly xstart,ystart,xvalue,yvalue)
  Index=1
  Cls
  '
  Nosymetry=0
  '
  @Initvalues
  @Setxandy
  @Calcvars
  @Running
  @Takedata
  Hidem
  @Showmenu
  Showm
Return
'
Procedure Menustuff   ! Select action
  If A$(Menu(0))=" Info            " Then
    @Introduction
  Endif
  If A$(Menu(0))="  Save Picture    " Then
    @Savepicture
  Endif
  If A$(Menu(0))="  Load Picture    " Then
    @Loadpicture
  Endif
  If A$(Menu(0))="  Save Data       " Then
    @Savedata
  Endif
  If A$(Menu(0))="  Load Data       " Then
    @Loaddata
  Endif
  If A$(Menu(0))="  Next Picture    " Then
    @Nextpicture
  Endif
  If A$(Menu(0))="  Last Picture    " Then
    @Lastpicture
  Endif
  If A$(Menu(0))="  Draw Mandel     " Then
    Julia=False
    If Inpar Then      ! if standard parameters are selected, initialise
      @Initparameters
    Endif
    Menu Off
    Menu Mmandelbrot,1
    Menu Mjuliaset,0
    Menu Mjuliakonst,3
  Endif
  If A$(Menu(0))="  Draw Julia      " Then
    Julia=True
    If Inpar Then
      @Initparameters
    Endif
    Menu Off
    Menu Mmandelbrot,0
    Menu Mjuliaset,1
    Menu Mjuliakonst,2
  Endif
  If A$(Menu(0))="  Coordinates"
    @Inputcoords
    Sub Dat,1      ! reduce index to update current values as
    @Takedata      ! Takedata does increase Dat by one before writing
    @Showmenu      ! values into the array
  Endif
  If A$(Menu(0))="  Step X, Step y     "
    @Inputstep
    Sub Dat,1
    @Takedata
    @Showmenu
  Endif
  If A$(Menu(0))="  Maxiterat          "
    @Inputmaxiterat
    Sub Dat,1
    @Takedata
    @Showmenu
  Endif
  If A$(Menu(0))="  Limit              "
    @Inputgrenze
    Sub Dat,1
    @Takedata
    @Showmenu
  Endif
  If A$(Menu(0))="  CReal              "
    @Inputcreell
    Sub Dat,1
    @Takedata
    @Showmenu
  Endif
  If A$(Menu(0))="  CImaginary         "
    @Inputcimg
    Sub Dat,1
    @Takedata
    @Showmenu
  Endif
  If A$(Menu(0))="  Standard Parameter "
    Menu Off
    If Inpar Then
      Inpar=False
      Menu Mstandpar,0
      @Enablemanual
    Else
      Inpar=True
      Menu Mstandpar,1
      @Disablemanual
      @Initparameters
    Endif
  Endif
  If A$(Menu(0))="  Show Parameters    " Then
    @Listvalues
  Endif
  If A$(Menu(0))="  Print Parameters   " Then
    @Printvalues
  Endif
  If A$(Menu(0))=" Start                 " Then
    @Startup
  Endif
  If A$(Menu(0))=" Redraw Area           " Then
    @Redraw
  Endif
  If A$(Menu(0))=" Enlarge Area          " Then
    @Fulldraw
  Endif
  If A$(Menu(0))=" Choose Julia-Constant " Then
    @Drawjulia
  Endif
  If A$(Menu(0))="  Show Grayshades " Then
    Menu Off
    If Grau Then
      Grau=False
      Menu Mgrau,0
    Else
      Grau=True
      Menu Mgrau,1
    Endif
  Endif
  If A$(Menu(0))=" Quit " Then
    @Finish
  Endif
Return
'
Procedure Menudefaults
  If Rez%<>2 Then
    Menu Mgrau,2    ! if not hi