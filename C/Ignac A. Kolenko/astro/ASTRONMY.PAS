

                  {     A S T R O N M Y . P A S     }


{This is the main program for the aSTronomer. It contains the program shell,
 and all the support subroutines for the main menu. As it compiles, it calls
 6 include files, three of which are for GEM, 2 for the main menu choice, ie.
 ALMANAC.PAS, SKY_PLOT.PAS, and 1 resource include file, ASTRONMY.I.}

                { Last Modifications: February 20, 1987 }

{Thanks go to Darek Mihocka, (even though he tried to make me 'C' the light),
 and Carmine Caccioppoli for the ideas they gave throughout the programming of
 this piece of software.}



Program Astronomy (input, output, infile, outfile, i2, i3, i4) ;


const

   {$I GEMCONST.PAS}
   {$I ASTRONMY.I}
   pi    = 3.14159265359 ;                {standard constants for calculations}
   twopi = 6.283185307 ;
   rad   = 57.29577951 ;
   stars = 1573 ;                           {number of stars in large database}
   n_star = 166 ;                      {number of stars in small star database}
   n_objects   = 9 ;      {number of objects in planet and comet database file}


type
   {$I GEMTYPE.PAS}
   fullstr  = string[255] ;                            {full sized string type}
   s_system = array [1..n_objects] of real ;                {solar system data}


var

   outfile             : text ;    {screen/printer/nul IO redirection variable}

   Astronomy_Menu        : Menu_Ptr ;                     {main menu variables}
   astron_dial,dial_init : Dialog_Ptr ;        {initial and desk info variable}

   c, p                : integer ;                   {planet and comet numbers}

   prompt,editfld      : fullstr ;                         {dialog strings and}
   w_name,d_str,values : fullstr ;                                {window name}

   what_event          : integer;                       {event returned by gem}
   resolution          : integer  ;
   a                   : integer ;                    {for single letter input}

   fullwindow          : integer ;                {window management variables}
   fw_x,fw_y,fw_w,fw_h : integer ;
   unletter            : integer ;
   dummy               : integer ;           {dummy variable for event handler}
   msg                 : Message_Buffer ;             {buffer for gem messages}

   scrnwhite, did_current : boolean ;   {flags for scrn color (white or black)}
   scrncol, txtcol : integer ;                         {colors for screen, txt}
                                                              {default strings}
   tempstr, latitude_str, longitude_str, date_str, time_str, device : fullstr ;
   printouts           : boolean ;

   tp,ep,om,ee,ax      : s_system ;                               {planet data}
   ii,no,th,bb         : s_system ;

   c_pe,c_pl,c_no,c_tp : s_system ;                                {comet data}
   c_ee,c_ii,c_aa      : s_system ;

   planet              : array [1..n_objects] of fullstr ; {planet/comet names}
   comet               : array [1..n_objects] of fullstr ;

   sright              : array [1..n_star] of real ;          {star RA and Dec}
   sdecl               : array [1..n_star] of real ;

   right, decl    : array [1..19]  of real ;   {data arrays for plotting needs}
   alts, azim     : array [1..19]  of integer ;
   salts, sazim   : array [1..166] of integer ;
   obname         : array [1..19]  of fullstr ;

   s_ra,s_de,s_mag     : array [1..stars] of real ;  {large database of stars,}
            {includes RA, Dec and magnitudes for the detailed Star Atlas plot.}

   h, m, s, rh, rm, rs, dh, dm, ds        : integer ; {HMS variables for time,}
                                                           {RA and declination}
   day, month, year                       : integer ;      {variables for date}

   dday, dd, la, be, RA_0, Dec_0, t_univ : real ;    {variables for days since}
   RA, Dec, epsilon, latitude, longitude : real ; {1980, RA, dec, latitude,etc}


{$I GEMSUBS.PAS}


function Val (Snumber : string) : real ;   {turn a string into a real number!!}
                                           {Personal Pascal should have this!!}
var
   number  : real ;                      {number that is converted from string}
   x,z,y   : integer ;                  {variables for positions inside string}
   neg     : integer ;                                   {negative number flag}
   ten     : real ;            {factor to multiply each component of string by}
   c,d     : fullstr ;                                      {temporary strings}

begin
   number := 0 ;                                {original value of string is 0}
   ten    := 1.0 ;                                      {multiplication factor}
   c      := Copy (Snumber,1,1) ;             {check to see if number negative}
   if c = '-' then begin
      neg := -1 ;                                             {negative factor}
      Delete (Snumber,1,1) ;
   end
   else neg := 1 ;                                            {positive factor}
   y      := Pos ('.',Snumber) ;               {find location of decimal point}
   if y = 0 then y := length (Snumber) + 1 ;           {calculate integer part}
   for x := (y-1) downto 1 do begin
      number := number + (ord (Snumber [x])-48) * ten ;
      ten := ten * 10 ;                 {increment multiplication factor by 10}
   end;
   ten := 0.1;                                      {calculate fractional part}
   z   := Pos ('E',Snumber) ;       {find location of exponent if there at all}
   if z = 0 then z := length (Snumber) + 1 ;
   if y < (length(Snumber)) then  begin                    {do fractional part}
      for x := (y+1) to (z-1) do begin
         number := number + (ord (Snumber [x])-48) * ten ;
         ten := ten / 10 ;              {decrease mulitiplication factor by 10}
      end ;
      if z < length(Snumber) then begin                    {calculate exponent}
         c := Copy (Snumber,z+1,1) ;                 {get +/- sign of exponent}
         d := Copy (Snumber,z+2,2) ;                             {get exponent}
         y := round (Val(d)) ;
         if c = '-' then for x:= 1 to y do number := number / 10.0
         else for x:= 1 to y do number := number * 10.0 ;     {calculate value}
     end ;                                                          {of string}
   end ;
   number := number * neg ;       {make number negative if string was negative}
   Val := number;               {return the value of the string back to Pascal}
end ;  {Val}


procedure itoa (x : integer; var s : string) ;      {convert integer to string}
              {pass to it an integer, and the string for it to be converted to}

var
   c        : integer ;                                               {counter}
   ten      : integer ;                                      {division counter}
   negative : boolean ;                                         {negative flag}

begin
   if x = 0 then s := '0' else begin                               {check if 0}
      if x < 0 then negative := TRUE else negative := FALSE ;    {check if neg}
      x := abs (x) ;                                   {make sure its positive}
      s := '     ' ;                         {initialize string,factor,counter}
      ten := 10000 ;
      c := 1 ;
      while (ten <> 0) do begin                                 {do conversion}
         s[c] := chr ( (x div ten) + 48) ;
         c := c + 1 ;
         x := x mod ten ;
         ten := ten div 10 ;
      end ;
      while s[1] = '0' do Delete (s,1,1) ;               {remove leading zeros}
      while s[1] = ' ' do Delete (s,1,1) ;              {remove leading spaces}
      if negative then s := Concat ('-',s) ;           {add neg sign if needed}
   end ;
end ;  {itoa}


procedure read_stars ;           {read in star data and convert to real values}

var
   infile            : text ;                                   {file variable}
   x                 : integer ;                      {counter for data arrays}
   s                 : fullstr ;       {input string to be converted into real}

begin
   x:= 1 ;
   reset (infile,'ASTRONOM.Y\CONST.DAT') ;
   while not eof (infile) do begin
      readln (infile,s) ; sright[x] := Val (s) ;
      readln (infile,s) ; sdecl [x] := Val (s) ;
      x := x + 1 ;
   end ;
   close (infile) ;
end ;  {read_stars}


procedure read_com ;            {read in comet data and convert to real values}

var
   infile            : text ;                                   {file variable}
   x                 : integer ;                      {counter for data arrays}
   s                 : fullstr ;       {input string to be converted into real}

begin
   x:= 1 ;
   reset (infile,'ASTRONOM.Y\COMETS.DAT') ;
   while not eof (infile) do begin
      readln (infile, comet[x]) ;
      readln (infile,s) ; c_pe[x] := Val (s) ;
      readln (infile,s) ; c_pl[x] := Val (s) ;
      readln (infile,s) ; c_no[x] := Val (s) ;
      readln (infile,s) ; c_tp[x] := Val (s) ;
      readln (infile,s) ; c_aa[x] := Val (s) ;
      readln (infile,s) ; c_ee[x] := Val (s) ;
      readln (infile,s) ; c_ii[x] := Val (s) ;
      x := x + 1 ;
   end ;
   close (infile) ;
end ;  {read_com}


procedure read_pln ;           {read in planet data and convert to read values}

var
   infile            : text ;                                   {file variable}
   x                 : integer ;                      {counter for data arrays}
   s                 : fullstr ;       {input string to be converted into real}

begin
   x:= 1 ;
   reset (infile,'ASTRONOM.Y\PLANETS.DAT') ;
   while not eof (infile) do begin
      readln (infile, planet[x]) ;
      readln (infile,s) ; tp[x] := Val (s) ;
      readln (infile,s) ; ep[x] := pi / 180.0 * Val (s) ;        {do degree to}
      readln (infile,s) ; om[x] := pi / 180.0 * Val (s) ;  {radian conversions}
      readln (infile,s) ; ee[x] := Val (s) ;
      readln (infile,s) ; ax[x] := Val (s) ;
      readln (infile,s) ; ii[x] := pi / 180.0 * Val (s) ;
      readln (infile,s) ; no[x] := pi / 180.0 * Val (s) ;
      readln (infile,s) ; th[x] := pi / 180.0 * Val (s) ;
      readln (infile,s) ; bb[x] := Val (s) ;
      x := x + 1 ;
   end ;
   close (infile) ;
end ;  {read_pln}


procedure r_star_data ;        {read in large star database (over 1500 stars!)}
                               {and convert strings to read numbers as read in}

var
   infile       : text ;                                        {file variable}
   a            : string ;             {input strings to be converted to reals}
   x            : integer ;                            {counter for data array}

   function conra (s:string) : real ;      {convert RA string to a real number}
                                                         {string in form HHMMD}
   var
      a,b,c : string ;
      d,e,f : real ;

   begin
      a := Copy (s,1,2) ;                 {parse string to get required values}
      b := Copy (s,3,2) ;
      c := Copy (s,5,1) ;
      d := Val (a) ;
      e := Val (b) ;
      f := Val (c) ;
      conra := d + (e + f/10) / 60 ;                   {convert to real number}
   end ;  {conra}


   function conde (s:string) : real ;     {convert Dec string to a real number}
                                                         {string in form -DDMM}
   var
      a,b,c : string ;
      d,e,f : real ;

   begin
      c := Copy (s,1,1) ;                 {parse string to get required values}
      a := Copy (s,2,2) ;
      b := Copy (s,4,2) ;
      d := Val (a) ;
      e := Val (b) ;
      f := d + e / 60 ;
      if c = '-' then conde := -f else conde := f ;    {convert to real number}
   end ;  {conde}


begin
   reset (infile,'ASTRONOM.Y\S_RA.DAT') ;                            {RA file}
   for x := 1 to stars do begin
      readln (infile,a) ;
      s_ra [x]   := conra (a) ;                          {convert string to RA}
   end ;
   close (infile) ;
   reset (infile,'ASTRONOM.Y\S_DE.DAT') ;                   {Declination file}
   for x := 1 to stars do begin
      readln (infile,a) ;
      s_de [x]   := conde (a) ;                         {convert string to Dec}
   end ;
   close (infile) ;
   reset (infile,'ASTRONOM.Y\S_MAG.DAT') ;                    {Magnitude file}
   for x := 1 to stars do begin
      readln (infile,a) ;
      s_mag [x]  := Val (a) ;
   end ;
   close (infile) ;
end ;  {r_star_data}


function Get_Rez : integer ;                            {get screen resolution}
   XBIOS (4) ;


function gettime : integer ;                              {get the system time}
   GEMDOS ($2C) ;


function getdate : integer ;                              {get the system date}
   GEMDOS ($2A) ;


procedure system_time (var s : string) ;          {get system time into string}

var
   h,m,a        : integer ;              {temporary variables for hour, minute}
   s_h,s_m      : string ;                       {temporary string equivalents}


begin
   a  := gettime ;                                            {get system time}
   h  := ShR ( (a & $F800),11) ;                           {get hr bit pattern}
   m  := ShR ( (a & $07E0), 5) ;                          {get min bit pattern}
   itoa (h,s_h) ;    if h < 10 then s_h := Concat ('0',s_h) ;  {convert to str}
   itoa (m,s_m) ;    if m < 10 then s_m := Concat ('0',s_m) ;
   s  := Concat (s_h,s_m) ;
end ;  {system_date}


procedure system_date (var s : string) ;          {get system date into string}

var
   y,m,d,a      : integer ;          {temporary variables for year, month, day}
   s_y,s_m,s_d  : string ;                       {temporary string equivalents}


begin
   a  := getdate ;                                            {get system date}
   y  := ShR ( (a & $FE00),9) + 1980 ;                   {get date bit pattern}
   m  := ShR ( (a & $01E0),5) ;                         {get month bit pattern}
   d  := a & $001F ;                                      {get day bit pattern}
   itoa (y,s_y) ;                 {convert to a string for default date string}
   itoa (m,s_m) ;    if m < 10 then s_m := Concat ('0',s_m) ;
   itoa (d,s_d) ;    if d < 10 then s_d := Concat ('0',s_d) ;
   s  := Concat (s_y,s_m,s_d) ;
end ;  {system_date}


function setprt (x : integer) : integer ;   {set/get the printer configuration}
   XBIOS (33) ;


function bconin (dev : integer) : integer ;            {single character input}
   BIOS (2) ;


procedure Curs_Off ;                                          {turn off cursor}

begin
   write (output, chr(27), 'f') ;                               {VT-52 command}
end ;  {Curs_Off}


procedure PrintAt (x : integer; y : integer);          {position cursor at x,y}

var
   esc : char;                                    {ASCII esc character code 27}

begin
   esc := chr (27);                                      {the escape character}
   write (output, esc, 'Y', chr(x+32), chr(y+32));         {use VT-52 emulator}
end;     {PrintAt}


procedure Button_Key ;        {Gem function to check keyboard and mouse button}

begin
   what_event := Get_Event (E_Button | E_Message | E_Keyboard,
                            1,0,1,0,False,0,0,0,0,
                            False,0,0,0,0,msg,unletter,dummy,
                            dummy,dummy,dummy,dummy);
end;  {Button_Key}


procedure Event (what_kind : integer);                  {general event manager}

begin
   what_event := Get_Event (what_kind,0,0,0,0,False,0,0,0,0,
                            False,0,0,0,0,msg,dummy,dummy,
                            dummy,dummy,dummy,dummy);
end;  {Event}


function Multi_Dial (pr,ed,va : string ; var d_str : string) : boolean ;

{sets up a standard dialog box with one prompt and edit field; returns true if
OK is selected, false if Cancel is selected; d_str is modified by this routine}

var
   d_dialog : Dialog_Ptr ;
   d_title, d_item, d_ok, d_cancel, button : integer ;
   s_str    : fullstr ;

begin
   d_dialog  := New_Dialog (4,0,0,30,8);
   d_title   := Add_DItem (d_dialog, G_String, None, 2,1,0,0,0,0);
   Set_DText (d_dialog, d_title, pr, System_Font, TE_Left);
   d_item    := Add_DItem (d_dialog, G_FText, None, 2,3,26,1,0,$1180);
   Set_DEdit (d_dialog, d_item, ed, va, d_str, System_Font,TE_Center);
                                    {set up the edit portion of the dialog box}
   d_ok      := Add_DItem (d_dialog,G_Button,Selectable|Default|Exit_Btn,
             3,5,8,2,2,$1180);                  {make OK the default choice!!!}
   Set_DText (d_dialog,d_ok,'OK',System_Font,TE_Center);
   d_cancel  := Add_DItem (d_dialog,G_Button,Selectable|Exit_Btn,
             19,5,8,2,2,$1180);                       {standard dialog button!}
   Set_DText (d_dialog,d_cancel,'Cancel',System_Font,TE_Center);
   Center_Dialog (d_dialog);
   Show_Mouse;
   button    := Do_Dialog (d_dialog,d_item);
   if button <>d_cancel then begin
      Get_DEdit(d_dialog,d_item,s_str) ;                       {get new string}
      if length (s_str) = length (d_str) then d_str := s_str ;   {check if new}
   end ;                                  {string is same length as old string}
   Hide_Mouse ;                               {if yes, replace old with new!!!}
   End_Dialog    (d_dialog) ;
   Delete_Dialog (d_dialog) ;
   if button = d_ok then Multi_Dial := True else Multi_Dial := False ;
end ;  {Multi_Dial}


procedure wind_open (windtitle: Window_Title) ;     {do necessary procedures to
                                            open a full screen graphics window}

begin
   fullwindow := New_Window (g_Name | G_Close,windtitle,0,0,0,0) ;
   Open_Window (fullwindow,0,0,0,0) ;               {open full graphics window}
   Set_Window  (fullwindow) ;                       {make it window for output}
   Work_Rect (fullwindow,fw_x,fw_y,fw_w,fw_h) ;    {find limits of work screen}
   Set_Clip (fw_x,fw_y,fw_w,fw_h) ;                       {set clipping values}
   Paint_Style (1) ;  Paint_Color (white) ;
   Paint_Rect (0,0,fw_w,fw_h) ;                {paint interior of window white}
end ;  {wind_open}                               {in other words, clear screen}


procedure wind_close ;        {procedure to close the previously opened window}

begin
   Text_Style (Thickened) ;        {choose bold face for close window message!}
   if resolution = 2 then Text_Color (txtcol) else Text_Color (Red) ;
   Draw_String (158, (fw_h - 4),            {red in med res, black in high res}
       ' Click Window Closed to Return to Menu ...  ') ;
   Show_Mouse ;                            {allow mouse to click window closed}
   while (msg[0]<>WM_Closed) do Button_Key ; {wait until window closed message}
   Hide_Mouse ;
   Close_Window (fullwindow) ;            {close and remove window from screen}
   Delete_Window (fullwindow) ;
   if not scrnwhite then write (chr(27),'q') ;        {reset text screen color}
end ;  {wind_close}


procedure Clearxy  ;                               {clear main window to color}

begin
   Paint_Style (1) ; Draw_Mode (2) ; Line_Style (1) ;  {set up graphics attrib}
   Line_Color (txtcol) ; Text_Color (txtcol) ;          {set up txt/line color}
   Paint_Color (scrncol) ;   {choose color interior and paint the window color}
   Paint_Rect (0,0,fw_w,fw_h) ;
   if not scrnwhite then write (chr(27),'p') ;       {set up text screen color}
end ;  {Clearxy}


procedure Init_Astronomy_Menu ;                          {initialize main menu}

var ok : boolean ;

begin
   ok := Load_Resource ('ASTRONMY.RSC') ;                 {set up object trees}
   Find_Menu   (MAINMENU,Astronomy_Menu) ;
   Find_Dialog (ASTROINF,astron_dial) ;
   Set_Mouse (M_Arrow) ;
   Menu_Check (Astronomy_Menu,WHITSCRN,TRUE) ;                  {set checkmark}
   Hide_Mouse ;                                       {hide mouse until needed}
end;     {Init_Astronomy_Menu}


procedure About_The_Desktop_Astronomer;                   {desktop information}

var
   ok   : integer ;                    {dummy variable for dialog box function}

begin
   Show_Mouse ;
   Obj_SetState (astron_dial, INF_BUTN, Normal, False) ;
   Center_Dialog (astron_dial) ;
   ok := Do_Dialog (astron_dial,0) ;
   End_Dialog (astron_dial) ;
   Hide_Mouse ;
end ;  {About_The_Desktop_Astronomer}



function OK_to_Quit (choice : integer) : integer ;       {verify if OK to quit}
          {Aye means yes, Nay means no (close to what Sulu would say to Kirk!!}
var
   ok : integer ; {variable for alert box function, corresponding to yes or no}

begin
   ok := Do_Alert
('[3][ Get us out of orbit  | Mr. Sulu. Ahead warp | factor 1.][ Aye | Nay ]'
                 ,2);
   if ok = 2 then OK_to_Quit := 0 else Ok_to_Quit := choice; {set up quit flag}
end ;  {OK_to_Quit}


{$I ALMANAC.PAS}                       {sky plot support, and its menu choices}
{$I SKY_PLOT.PAS}


procedure Do_Print ;                      {do the printout options menu choice}

begin
   if printouts = TRUE then begin                        {check printouts flag}
      Menu_Check (Astronomy_Menu,PRNT_OUT,FALSE) ;        {remove checkmark on}
      printouts := FALSE ;                                   {menu, reset flag}
      device := 'CON:' ;                               {reset device to screen}
   end
   else begin
      Menu_Check (Astronomy_Menu,PRNT_OUT,TRUE) ;       {set checkmark on menu}
      printouts := TRUE ;                                         {set flag on}
      device := 'PRN:' ;                                {set device to printer}
   end ;
end ;  {Do_Print}


procedure Do_White ;                      {do the printout options menu choice}

var txt : string[255] ;

begin
   if scrnwhite = TRUE then begin                            {check color flag}
      Menu_Check (Astronomy_Menu,WHITSCRN,FALSE) ;           {remove checkmark}
      scrnwhite := FALSE ;                                         {reset flag}
      scrncol := black ; txtcol := white ;                       {reset colors}
   end
   else begin
      Menu_Check (Astronomy_Menu,WHITSCRN,TRUE) ;               {set checkmark}
      scrnwhite := TRUE ;                                          {reset flag}
      scrncol := white ; txtcol := black ;                       {reset colors}
   end ;
end ;  {Do_White}


procedure Do_Setup ;                         {set up the printer configuration}

var
   x,a,b,c,d,e,f : integer ;     {variables for bits in the printer config var}
   w             : Window_Title ;                      {name of window to open}

begin
   x := setprt (-1) ;                              {get current printer config}
   a := (x & 1) ;                                   {dot matrix or daisy wheel}
   b := (x & 4) div 4 ;                                {Atari or Epson printer}
   c := (x & 8) div 8 ;                                   {draft or final mode}
   d := (x & 16) div 16 ;                             {Parallel or Serial Port}
   e := (x & 32) div 32 ;                           {form or single sheet feed}
   f := (x & 2) div 2 ;                               {monochrome device/color}
   a := Do_Alert (                 {get new information or default to original}
'[0][       Type of printer?       ][  Dot  | Daisy ]',(a+1)) - 1 ;
   if a = 0 then b := Do_Alert (
'[0][    Which make of printer?    ][ Atari | Epson ]',(b+1)) - 1 ;
   c := Do_Alert (
'[0][     Which printing mode?     ][ Draft | Final ]',(c+1)) - 1 ;
   d := Do_Alert (
'[0][         Which  Port?         ][ Parallel | Serial ]',(d+1)) - 1 ;
   e := Do_Alert (
'[0][    Type of paper feeding?    ][  Form  | Single ]',(e+1)) - 1 ;

   x := a + (f*2) + (b*4)+ (c*8)+ (d*16)+ (e*32) ;    {calculate new parameter}

   x := setprt (x) ;                               {set the port with new data}
   w := ' Current Printer Status ' ;                       {open output window}
   wind_open (w) ;
   PrintAt (6,20) ;
   writeln (output,'Printer Status is:') ;   {output the new status of printer}
   PrintAt (10,20) ;
   if a = 0 then writeln (output,'Dot Matrix Printer')
   else writeln (output,'Daisy Wheel Printer') ;
   PrintAt (12,20) ;
   if b = 0 then writeln (output,'Atari Printer')
   else writeln (output,'Epson Printer') ;
   PrintAt (14,20) ;
   if c = 0 then writeln (output,'Draft Mode Printing')
   else writeln (output,'Final Mode Printing') ;
   PrintAt (16,20) ;
   if d = 0 then writeln (output,'Parallel Printer Port')
   else writeln (output,'Serial (RS 232) Port') ;
   PrintAt (18,20) ;
   if e = 0 then writeln (output,'Form Feeding')
   else writeln (output,'Single Sheet Feeding') ;
   wind_close ;
end ;  {Do_Setup}


procedure Do_Help ;                                         {display help file}

var
   infile : text ;                                              {file variable}
   x      : integer ;                                {current line to print on}
   s      : fullstr ;                                            {input string}
   w_name : Window_Title ;                              {name of output window}

begin
   w_name := '  Help Window  ' ;                     {open a new output window}
   wind_open (w_name) ;
   reset (infile,'ASTRONOM.Y\HELP.DOC') ;          {open file and read from it}
   x := 3 ;                                         {start at line 3 on screen}
   while not eof (infile) do begin
      readln (infile,s) ;                              {read line of help text}
      PrintAt (x,5) ;
      write  (output,s) ;                           {print help text on screen}
      x := x + 1 ;
   end ;
   wind_close ;
end ;  {Do_Help}


procedure Do_Location (menu : integer) ;     {change the latitude or longitude}

var
   ok   : boolean ;       {determines if latitude/longitude chosen or canceled}

begin
   did_current := FALSE ;
   if menu = LATITUD then begin
      prompt := 'Please enter the latitude:' ;
      editfld := '__ d __ '' __ " _ ' ;
      values := '999999A' ;
      ok := Multi_Dial (prompt,editfld,values,latitude_str); {get new latitude}
   end
   else begin
      prompt := 'Please enter the longitude:' ;
      editfld := '___ d __ '' __ " _ ' ;
      values := '9999999A' ;
      ok := Multi_Dial(prompt,editfld,values,longitude_str);{get new longitude}
   end ;
end ;  {Do_Location}


procedure Do_Clock (menu : integer) ;             {change the date or the time}

var
   ok   : boolean ;              {determines if date/time is changed or cancel}

begin
   did_current := FALSE ;
   if menu = DATE then begin
      prompt := 'Please enter the date:' ;
      editfld := 'Y: ____  M: __  D: __ ' ;
      values := '99999999' ;
      ok := Multi_Dial (prompt,editfld,values,date_str) ;        {get new date}
   end
   else begin
      prompt := 'Please enter time (U.T.):' ;
      editfld := '__ h  __ m' ;
      values := '9999' ;
      ok := Multi_Dial (prompt,editfld,values,time_str) ;        {get new time}
   end ;
end ;  {Do_Clock}


procedure Do_The_Menu ;                                      {do the main menu}

var
   choice1 : integer ;                                       {main menu choice}
   choice2 : integer ;                                  {pull down menu choice}

begin
   Draw_Menu (Astronomy_Menu) ;                  {Display and freeze main menu}
   Erase_Menu (Astronomy_Menu) ;
   About_The_Desktop_Astronomer ;                  {display info on program!!!}
   repeat
      Draw_Menu (Astronomy_Menu) ;
      Show_Mouse ;
      Event (E_Message) ;                   {wait for a menu item to be chosen}
      Hide_Mouse ;
      Erase_Menu (Astronomy_Menu) ;

      choice1 := msg[3] ;                         {which menu choice is chosen}
      choice2 := msg[4] ;                         {which pull down menu chosen}

      case choice1 of                                               {do choice}
         DESK_INF : About_The_Desktop_Astronomer ;
         ALMANAC  : Do_Sky_Plot (choice2) ;
         OPTIONS  : case choice2 of
                       PRNT_OUT : Do_Print ;
                       SET_PRNT : Do_Setup ;
                       WHITSCRN : Do_White ;
                       HELP     : Do_Help ;
                       QUIT     : choice2 := OK_to_Quit (choice2) ;
                    end ;                                        {case choice2}
         LOCATION : Do_Location (choice2) ;
         CLOCK    : Do_Clock    (choice2) ;
      end ;

      Menu_Normal (Astronomy_Menu,DESK_INF) ;            {return the main menu}
      Menu_Normal (Astronomy_Menu,ALMANAC) ;                        {to normal}
      Menu_Normal (Astronomy_Menu,OPTIONS) ;
      Menu_Normal (Astronomy_Menu,LOCATION) ;
      Menu_Normal (Astronomy_Menu,CLOCK) ;

   until choice2 = QUIT ;
   Delete_Menu (Astronomy_Menu) ;                    {allow restoration of Gem}
   Show_Mouse ;                                  {make sure mouse is on at end}
end ;  {Do_The_Menu}


begin                                                                {mainline}

   resolution := Get_Rez ;             {find out what resolution program is in}
   if resolution = 0 then begin
      Clear_Screen ;                     {don't allow use of low resolution!!!}
      Curs_Off ;                                          {turn off any cursor}
      PrintAt (10,0) ;                               {output error message!!!!}
      writeln (output,'Use medium or high resolution PLEASE!') ;
      write   (output,'Please press any key ... ') ;
      a := bconin (2) ;                                       {get a character}
   end
   else begin
      Init_Astronomy_Menu ;                          {Set up the main menu bar}
      latitude_str  := '432950N' ;                     {set up default strings}
      longitude_str := '0802230W' ;
      system_time (time_str) ;                                    {system time}
      system_date (date_str) ;                                    {system date}
      printouts     := FALSE ;                          {set printout flag off}
      device        := 'CON:' ;                          {set device to screen}
      did_current   := FALSE ;                     {no data has been calc yet!}
      scrnwhite := TRUE ; scrncol:= white ; txtcol:= black ; {set up flag, col}

      if Init_Gem <> -1 then              {initialize GEM for graphics, etc!!!}
      begin
         PrintAt (0,0) ;                 {tell user that files are being read!}
         write (output,
         '                 Please Wait ... Initializing Data Files!!!       ');
         read_pln ;                                     {read in data files!!!}
         read_stars ;
         read_com ;
         r_star_data ;

         Do_The_Menu ;
         Exit_Gem ;                           {leave GEM and return to desktop}
      end ;
   end ;
end.                                                                 {mainline}


