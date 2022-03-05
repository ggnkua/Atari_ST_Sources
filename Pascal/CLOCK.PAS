{$A+,$S5,D-}  {compile for desk accessory}

{
  Desktop Clock
  COMPUTE!'s Atari ST Disk and Magazine
  Vol. 2. - No. 1 - Feb. 1987
  Copyright 1987 COMPUTE! Publications/ABC
}

PROGRAM Sample_Accessory;

 CONST {$I gemconst.pas}
       AC_Open = 40;  {Two new message that only accessories will get}
       AC_Close = 41;
       Height = 35;  {height and width of the clock window}
       Width = 160;

 TYPE {$I gemtype.pas}
     shortstring = String[2];

 VAR window,             { The handle of our window }
     ap_id,              { Our application identification handle. }
     curx,cury,          { current x and y coordinates of window }
     menu_id : Integer ; { Index of our menu item in "Desk" menu }
     our_name,           { The name of our accessory. }
     wind_name : Str255; { The title of our window. }
     Time : String[12];

 {$I gemsubs.pas}

 {Here's our declaration of Menu_Register}

 FUNCTION Menu_Register( id : Integer ; VAR name : Str255 ) : Integer;
  EXTERNAL;

{ Open our window, if not already open, otherwise make it the front window. }

 PROCEDURE Do_Open ;
  BEGIN
   { Does our window already exist? }
   IF window <> No_window THEN
     Bring_To_Front ( window )    { Yes, just make it front window. }
   ELSE
     BEGIN
       wind_name := ' Desktop Clock ' ;
       window := New_Window ( G_Name|G_Close|G_Move,wind_name,
                              0,0,Width,Height );
       Open_Window( window,curx,cury,Width,Height )
     END {ELSE}
  END ; {Do_Open}

 { Close our window and delete it from the system }

 PROCEDURE Do_Close ;
  BEGIN
   Close_Window( window );
   Delete_Window( window );
   window := No_Window
  END; {Do_Close}

{convert two lowest digits of integer to string characters}

PROCEDURE Convert (Number : Long_Integer; VAR Timeout : shortstring);
 VAR hidigit,lodigit : Long_Integer;  {modifying Chris Chabris' demo from}
                                      {May 86 ANTIC....Thanks Chris      }
  BEGIN
    Timeout := '  ';  {clear the string and set current length}
    hidigit := Number DIV 10;
    lodigit := Number MOD 10;
    Timeout[1] := Chr(hidigit+Ord('0'));
    Timeout[2] := Chr(lodigit+Ord('0'))
  END;    {Convert}

{get the GEM timer and convert it to minutes, hours and seconds}

PROCEDURE Get_Time;

 VAR numseconds,seconds,minutes,hours : Long_Integer;
     sec,min,hr,mm : String[2];

   BEGIN
     numseconds := Clock;
     seconds := numseconds MOD 60;
     minutes := numseconds DIV 60;
     hours := minutes DIV 60;
     minutes := minutes MOD 60;
     IF hours < 12 THEN      {morning, AM}
       mm := 'AM';
     IF hours >= 12 THEN     {afternoon, PM}
       mm := 'PM';
     IF hours = 0 THEN       {early morning}
       hours := 12;
     IF hours > 12 THEN      {convert 24 hour to 12 hour clock}
       hours := hours-12;
     Convert(seconds,sec);   {convert numbers to two digit strings}
     Convert(minutes,min);
     Convert(hours,hr);
     Time := Concat(hr,':',min,':',sec,' ',mm);   {construct the string}
     Draw_String(20,12,Time)
   END;     {Get_Time}

{ Redraw an area of our window.  The redraw area is passed in the parameters
  x0,y0,w0,and h0. }

 PROCEDURE Do_Redraw( handle,x0,y0,w0,h0 : integer; bckgrnd : Boolean );

   {These will hold the size of the current redraw rectangle in redraw list. }
   VAR x,y,w,h : Integer ;

   BEGIN
    Set_window(window);    {get the clock window!}
    Begin_Update;           {Tell GEM we are updating}
    Hide_Mouse ;        {Hide mouse so we don't mess up the screen}
    Draw_Mode(1);       {Replace mode drawing}
    Paint_Style( Solid );   {draw with no pattern}
    Paint_Color( White ) ;  {Clearing each rectangle with white}
    First_Rect( handle,x,y,w,h ) ;
    WHILE (w <> 0) AND (h <> 0) DO
     BEGIN
      IF Rect_Intersect( x0,y0,w0,h0,x,y,w,h ) THEN
        BEGIN
         Set_Clip( x,y,w,h ) ;
         IF bckgrnd = True THEN   {redraw background if window was hidden}
           Paint_Rect( 0,0,Width,Height ) ;     { First clear to white...}
         Frame_Rect( 0,0,Width,Height ) ;     { Then draw rectangle outline }
         Get_Time;                   {Find the time}
        END ; { IF }
      Next_Rect( handle,x,y,w,h ) ;
     END ; {WHILE}
    Show_Mouse ;           {OK, we can redraw the mouse,too,}
    End_Update             {tell GEM were done}
   END ;    {Do_Redraw}

{ This next routine performs all events we receive from GEM.  Since we are an
  accessory, we will never stop running, so the loop below is infinite}

 PROCEDURE Event_Loop ;

   VAR event, d : Integer ;
       msg : Message_Buffer ;

   BEGIN
     WHILE True DO
      BEGIN
       {Get event--messages or timer}
       event := Get_Event( E_Message|E_Timer,0,0,0,2000,false,0,0,0,0,
                           false,0,0,0,0,msg,d,d,d,d,d,d ) ;

       IF event & E_Message <> 0 THEN  {its a message!}
        CASE msg[0] OF
         AC_Open:
           Do_Open ;      { open the window }
         AC_Close:
           { If we haven't already closed our window, pretend it's closed
             because GEM is going to close it for us. }
           IF (msg[3]=menu_id) AND (window <> No_Window) THEN
             window := No_Window ;
         WM_Sized,      { Allow any size or position on the screen }
         WM_Moved:
          BEGIN
           Set_WSize( msg[3], msg[4], msg[5], msg[6], msg[7] );
           curx := msg[4];     {keep track of x,y coordinates of}
           cury := msg[5];     {clock window.}
           Do_Redraw(window,curx,cury,Width,Height,True);
          END;
         WM_Closed:     { User wants to close our window--close it. }
           Do_Close ;
         WM_Redraw:     { Need to redraw a portion of our window }
           Do_Redraw( msg[3], msg[4], msg[5], msg[6], msg[7],True );
         WM_Topped:     { user wants us to be front window }
           Bring_To_Front( msg[3] )
        END  {CASE--and message handling routine}
       ELSE
        IF window <> No_window THEN   {only print time if the window is open}
         Do_Redraw(window,curx,cury,Width,Height,False);  {for the timer}
     END  {WHILE}
   END ; {Event_Loop}

{ Main routine -- initialize GEM, insert our name into the "Desk" menu and
  go to Event_Loop. Because that routine will NEVER return we don't need an
  Exit_Gem call at the end of the program.}

BEGIN
  ap_id := Init_Gem ;     { We do need to save our application ID }
  IF ap_id >= 0 THEN      { thats a change from most programs }
    BEGIN
      Time := '           ';  {clear the string}
      window := No_Window ; {Starting off with no window on the screen. }
      { Always put two spaces before the name of the accessory: }
      our_name := '  Desktop Clock' ;
      {Here is where we use the application ID number: }
      menu_id := Menu_Register( ap_id, our_name ) ;
      curx := 20;
      cury := 20;
      Event_Loop ;
    END {IF}
END. {Sample Accessory}
