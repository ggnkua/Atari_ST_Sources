Last update: 13.12.89


                            GFA NOTES
                            =========

  An expanding notebook of use and interest to GFA BASIC 2 users, 
  generated and prompted largely by users' queries and comments.

                    CONTRIBUTIONS ARE WELCOME

(Naturally  GFA can not take  any responsibility whatsoever for 
any of the information contained herein.)


1)  If you are confused by the operation of  SETCOLOR  and  COLOR, 
the following table will help:

          SETCOLOR  0... affects COLOR  0
                    1                   2
                    2                   3
                    3                   6
                    4                   4
                    5                   7
                    6                   5
                    7                   8
                    8                   9
                    9                   10
                    10                  11
                    11                  14
                    12                  12
                    13                  15
                    14                  13
                    15                  1

It  will probably be best to read this table into an array at  the 
beginning of your program, like so

Data 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
Dim C(15)
For X=0 To 15
  Read C(X)
Next X

                                      saving  it  on  disc   using 
SAVE,A so that it can be MERGEd into other programs.  It will then 
be used by:
                    Setcolor N,...
                    Color C(N)



2)    The 'up-arrow' character is accessible by typing:

                          ctrl-a,1,space

However, you can only 'print' it using 'TEXT'.



3)    For SPRITEs to operate in the XOR mode,  MKI$(1) on page 219 
of the Manual should read MKI$(-1). 



4)    GFA  BASIC  will not allow you to OPEN more than  10  Random 
Access  Files  at  once.  If you attempt to open 11  or  more  the 
slightly cryptic Error message will appear: 'Too many Fields (Max. 
 19)'.  Actually it is the Error message which is in error, and it 
should read: 'Too many R files (Max.10)'.



5)  This  program  loads 'NEO-CHROME' pictures  and  colours,  but 
without the flowing effects:

Do
  Fileselect "\*.NEO",".NEO",A$
  Exit If A$=""
  Open "i",#1,A$
  Col$=Input$(128,#1)
  Scr$=Input$(32000,#1)
  Close #1
  Sput Scr$
  Void Xbios(6,L:Varptr(Col$)+4)
  Void Inp(2)
  Setcolor 0,&H777
  Setcolor 15,0
Loop



6)   For details of the various BIOS, XBIOS etc. calls (accessible 
through GFA BASIC 2), the following book should prove useful


      GFA BASIC : Advanced Programming
             by Frank Ostrowski

published by GFA Data Media (UK) Ltd at œ19.95 including disk.


The Concise Atari ST 68000 Programmer's  Reference Guide 
             by Katherine Peel
published  by  Glentop  Press at œ17.95. 



7)    To  save/load  strings of known length,  which  may  contain 
control  characters, to disc, use PRINT # and INPUT$,  not WRITE # 
and INPUT #:

For I=1 to 2000
  Print "*";
Next I
Sget Screen$
Open "O",#1,"screen"
Print #1,Screen$
Close #1
Cls
Pause 250
Open "I",#1,"screen"
Screen$=Input$(32000,#1)
Close #1
Sput Screen$



8)    To save a numeric array to disc,  we can use VARPTR to  find 
out where it is and save it in one chunk using BSAVE:

Dim P(2,2)
Dim Q(2,2)
E=Dim?(P())                        !no. of elements in array
For X=0 To 2
  For Y=0 To 2
    Input P(X,Y)
  Next Y
Next X
Bsave "Parray",Varptr(P(0,0)),E*6 !or E*4 for integer arrays
Pause 250                         ! see TYPE p.290
Bload "Parray",Varptr(Q(0,0))
For X=0 To 2
  For Y=0 To 2
    Print Q(X,Y)
  Next Y
Next x

9)    To save a string array,  each element must be PRINT #'ed to 
the file separately:

Dim A$(2,2)
Open "O",#1,"Aarray"
For X=0 To 2
  For Y=0 To 2
    Input A$(X,Y)
    Print #1,A$(X,Y)
  Next Y
Next X
Close #1
Pause 250
Open "I",#1,"Aarray"
For X=0 To 2
  For Y=0 To 2
    Input #1,A$(X,Y)
    Print A$(X,Y)
  Next Y
Next X
Close #1
 

10)   Turn on inverse video with escape-p, off with escape-q:

Print Chr$(27);"p";
Print "hello"
Print Chr$(27);"q";
Print "goodbye"


11) From Frank Ostrowski:

The fastest way to get data into the ST:

Attach some device to the cartridge port  (See the Atari  Robokit 
Interface).

Don't decode all address lines.
If your device responds to all even addresses between $FA0000 and
$FA00FF (128 addresses) you can use:

     A$=Space$(256)
     Bmove &HFA0000,Varptr(A$),256

If you have 8-bit data,  then every second byte in the string will 
contain  this  data.  If you get your data in 16-bit chunks, every 
byte in the string will contain data.

If you get only one bit of data at a time, you may use:

     Dim A!(256*8-1)
     Bmove &HFA0000,Varptr(A!(0))

Your data will be in A!(0), A!(16), A!(32), .....  and so on,
               or in A!(15), A!(31), A!(47) .....  and so on,
depending on which data line your data comes in on.

Another way is, of course, to use a little machine code routine to 
get  the  data and put it into an array,  string,  or whatever you 
want.



12)  This  makes  a  message scroll smoothly from  right  to  left 
across the bottom of the screen in Hi-Res.  Conversion for Lo- and 
Med-Res is left as an exercise for the reader....

A$="This is a message of up to 32687 characters..."+Space$(80)
For L=1 To Len(A$)
  Get 8,384,639,399,B$
  For N=1 To 8
    Rem : a VSYNC here slows it down but makes it smoother
    Put 8-N,384,B$
  Next N
  A1$=Mid$(A$,L,1)
  Print At(79,25);A1$;
Next L


13) The keyboard click can be disabled by:

                    Spoke &H484,Peek(&H484) And &HFE
and enabled by:
                    Spoke &H484,Peek(&H484) Or &H01



14)  PRINT in colour by:

                    Print Chr$(27);"b";Chr$(COLOUR);"Message etc."

     Change background colour:

                    Print Chr$(27);"c";Chr$(COLOUR);

     where COLOUR = 0 to 15 (Low res.) or 0 to 4 (Med res.)



15)  To reserve up to 32K bytes, just use a dummy string such as

               A$=Space$(n)
 
     You will then have n bytes at Varptr(A$). 


From Frank Ostrowski:

If  you want to reserve more than 32000 bytes,  do not use several 
dummy strings in an array. Instead use:

     Dim A%(no.of.bytes.to.be.reserved/4)
                                             then you get a  block 
of  memory  which will not move while the program is  running,  as 
strings very often do,  as long as you do not erase any previously 
DIMmed arrays.

For a screen, you can use:

     Dim Scr%(32255/4)     !screen must start on a page boundary
     Scradr%=Varptr(Scr%(0))+255 And &HFFFF00

Or, use the Reserve command:

     Reserve Fre(0)-64000          !Reserve 64000 bytes
     A%=Gemdos(72,L:50000)         !50000 bytes for GEM

     ......some code......

     A%=Gemdos(73,L:A%)                      !Free memory
     Reserve Xbios(3)-16384-Himem+Fre(0)     !Un-reserve

It's  very important to give this Malloced memory back at the  end 
of the program with Gemdos(73,..), or by Quit or System.



16)  It is necessary for the mouse to be removed from  the  screen 
whenever any Printing takes place,  and this is done automatically 
by  GFA BASIC 2.  Unfortunately  this results in the  mouse  pointer 
flashing and becoming semi-invisible in a loop like this:

               Do
                 Print At(1,1);Mousex,Mousey;
               Loop

This  can be overcome to a large extent by checking  first  before 
printing to see if the mouse has moved:

               Oldx=Mousex
               Oldy=Mousey
               Do
                 Mouse X,Y,K
                 If X<>Oldx Or Y<>Oldy
                   Oldx=X
                   Oldy=Y
                   Print At(1,1);X,Y;
                 Endif
               Loop



17) Here is a demo to show the use of random access files:

Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=1 To 10
  V$="Test_"+Str$(I)
  Lset A$=V$
  Put #1,I
Next I
Close #1
Cls
Print "Ten records have been sent to the file and the file closed."
Print "Press any key to read the file so far:"
Gosub Wait
Print
'
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=1 To 10
  Get #1,I
  Print A$
Next I
Close #1
'
Print "Press any key to add another ten records:"
Gosub Wait
Cls
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=11 To 20
  V$="Test_"+Str$(I)
  Lset A$=V$
  Put #1,I
Next I
Close #1
'
Cls
Print "Another ten records have been added and the file closed."
Print "Press any key to read the whole file:"
Gosub Wait
Print
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=1 To 20
  Get #1,I
  Print A$
Next I
Close #1
'
Print "Press any key to read the middle ten records:"
Gosub Wait
Cls
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=5 To 14
  Get #1,I
  Print A$
Next I
Close #1
'
Print "Press any key to change the 17th record:"
Gosub Wait
Cls
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
V$="New seventeenth"
Lset A$=V$
Put #1,17
Close #1
'
Print "Press any key to read the whole file:"
Gosub Wait
Cls
Open "r",#1,"zzz",20  !The record length must be specified if it is not 128
Field #1,20 As A$
For I=1 To 20
  Get #1,I
  Print A$
Next I
Close #1
'
Procedure Wait
  Repeat
    Z$=Inkey$
  Until Z$<>""
  Repeat
  Until Inkey$=""
Return
'

18)  GFA USER Magazine

     The  independent GFA User magazine is available to  all  GFA 
     Users.  If you would like a copy then send œ1.70, (cheque or 
     postal order) to:

          GFA User Magazine
          186 Holland St
          Crewe
          Cheshire
          CW1 3SJ

     Telephone: 0270 256429

     GFA  User also has available over 80 disks of public  domain 
     software,  most of which is written in GFA Basic with source 
     code supplied.

19)  Technical Support

     Technical  support  is available from GFA User at  the  
     following times:

               0270 256429    1800 - 2100     Tue Wed Thur

     A bulletin board is connected to this line at other times.     

     Written  communication  is preferred,  as  it  is  sometimes 
     difficult to give an instant answer on the phone.  Questions 
     or  problems should be sent to either GFA User (see  address 
     above) or GFA Data Media (UK) Ltd.

20)  Upgrading your GFA Basic 2.0 Interpreter and Compiler

     If you wish to progress onto the professional GFA Basic  3.0 
     Interpreter, please contact GFA Data Media. GFA Basic 3.0 is 
     available to REGISTERED owners of GFA BASIC 2.0 at a special 
     upgrade  price  of œ 29.95 only direct from GFA Data  Media. 

     Also now available:

          GFA Basic 3.0 Compiler                       œ 29.95
          GFA Software Development Book and Disk       œ 19.95
    
          

     Plus more books in the pipe line supporting GFA Basic.

     GFA  Basic  3.0 has all the features of GFA  Basic  2.0  and 
     more,  with over 400 Basic commands.  Additional  features 
     include:  
               Support of the Resource Construction Set. 
               INLINE assembly language command
               Bit operations               
               Folding Procedures
               


     STOP PRESS 13.12.89

     Watch out for the following product releases in 1990:

     GEM Utility Package      A set of GFA Basic library routines 
                              to  allow  new programmers  to  GEM 
                              fully utilise the features of  GEM. 
                              Full GFA Basic source code of  this 
                              product is provided.

     GFA C Converter          Convert  your  GFA Basic  3  source 
                              code to C source code.

     GFA Structure            Allows  GFA programs to be  written 
                              using structured block diagrams  to 
                              define the program flow.

     GFA Basic 3.5            An  additional  50 commands  to  be 
                              added        allowing        matrix 
                              manipulations.


     Be  sure  to complete and return your registration  form  so 
     that  we  may  keep  you informed of  these  and  other  new 
     products.


     GFA data Media (UK) Ltd
     Box 121
     Wokingham
     Berkshire
     RG11 9LP

     0734 794941
