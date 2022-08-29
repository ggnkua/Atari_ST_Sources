README.DOC                                               25.6.90

This is GFA Basic Compiler 3.5E

There is a new program MAKE_NDX.PRG on the compiler disk. With 
this program you can modify and create the additional .NDX  files 
(Library Index Files).

See the GFA Basic Compiler Manual 3.2.2 'Linking with the use  of 
C Libraries'.

GFA  Basic 3.5E Compiler supports the new commnds available  with 
GFA Basic 3.5E Interpreter. See the interpreter documentation for 
details of these new commands.

GFA Basic 3.5E (released 25.6.90) corrects a bug with RSRC_GADDR.
GFA Basic 3.5E (released 05.7.90) corrects a bug with OPEN.


Version 3.03 Compiler

UNPACK.GFA

This  program  will  unpack the TEST.O O-File  generated  by  the 
compiler to a standard unpacked DR-Format TESTX.O.

P_LIB.GFA

This program will pack a standard DR-Format O-File into a  packed 
format (zero bytes removed).

MENU.GFA

This is the source code to the MENU.PRG.  Ensure that you have  a 
back up of your master disk before modifying this program.


1.   Please note the additional compiler options that  were   not 
     documented  in the manual.  These options are  available  as 
     work  arounds  to  known problems.  It  is  hoped  that  the 
     problems  will  be  resolved  in a  future  release  of  the 
     Compiler.

1.1  $%6  With  this  option  the compiler  is  forced  to  round 
     integers up

     eg
          x%=RND*640 will generate numbers from 0 to 639

     with $%6 inserted in the code,  the compiler would round  up 
     x%=639.5 to 640 instead of 639.   

1.2  $N+  The FOR-NEXT loop when using a byte variable (to remain 
          compatible with C) will cause a problem when used as in  
          the following example:

          FOR i|=0 to 255
          ....
          NEXT i

     Where  i is declared as a BYTE variable then the above  loop 
     would  never terminate.  The $N+ when inserted in  the  code 
     prior  to  the loop,  would ensure that the  loop  FOR  NEXT 
     terminates correctly. 
$N-  $N- switches this facility off.

1.3       Version 3.02

     The following bugs in GFA Compiler 3.01 have now been fixed, 
     resulting in the release of 3.02:

     EXIT IF TRUE
     INPUT               May result in scroll error
     PRINT USING         was not correct when using ^^^^
     CLOSEW 0            incorrect clipping
     GB                  was incorrect
     SCRP_READ           
     CLS #               did not function
     SETMOUSE x,y,b      b variable was wrong
     OPTION BASE 1       for 1 & 2 dimension boolean arrays

1.3.1     Clarification on the use of the $ symbol

     See chapter 2.3 for the list of compiler options.

     These  options  are set (and cleared) from  within  the  GFA 
     source program.

     eg.  A  short  program which requires error messages  to  be 
     displayed as text (E$), and have interrupt routines disabled 
     (I-):

          $E$
          $I-
          PRINT "I AM ONLY A TEST PROGRAM"
          ...
          END

1.4       Version 3.03

          Version 3.03 creates smaller code than 3.02.

          The  following  commands have had  errors  within  them 
          rectified:

1.4.1     EVNT-MOOUSE was not working correctly.

1.4.2     $U function

1.4.3     BPUT/BGET

1.4.4     CLOSEW

          sometimes forgot WIND-DELETE

1.4.5     DIM 

1.4.6     FSEL-INPUT

          Sometimes added an extra null byte to the file name.

1.4.7     SHEL-WRITE

1.4.8     GRAF-HANDLE

1.4.9     GRAF-MOUSE

1.4.10    FORM-DIAL

          With a byte variable as the first parameter, produced 4 
          bombs.

1.4.11    CVF(MKF$(0))

1.4.12    FORM-KEYBD




2.   Known errors to be rectified in a future release:

2.1  The following addition of mixed variable types will cause  a 
     problem:

          x=-3.5
          x&=10

          a&=x+x&
          a&= TRUNC( -3.5 + 10 ) = TRUNC( 6.5 ) = 6

     where as
          b&=x&+x
          b&= 10 + TRUNC( -3.5 ) = 10 + -3      = 7


     The temporary solution:

     Instead of a&= x + x&
      
     Use        a&=ADD(x,x&)

     or         a&=CFLOAT(x+x&)
 
3.0  RSC2.PRG

     The   GFA   Compiler  makes  reference   to   the   Resource 
     Construction Set Program.  This program is found on the  GFA 
     Basic 3.0 Interpreter disk.

     The RSC2 was only included on versions 3.06 onwards.  If you 
     have an earlier version of GFA Basic Interpreter  3.x,  then 
     you can obtain an upgrade to the latest 3.07.

     To  claim  your 3.07 upgrade,  make a backup  copy  of  your 
     master disk and send the master disk, with œ3.00 (post   and 
     packing) to:

          GFA User
          186 Holland Street
          Crewe 
          Cheshire
          CW1 3SJ

          Tel: 0270 256429

     GFA User will update your disk and supply you with a copy of 
     the independent GFA User Magazine. The upgrade fee to 
     existing subscribers is only œ1.50. 

4.0  Note  that to invoke the RSC2.PRG or  the  Interpreter,  you 
     must  either copy them to the same disk as the  Compiler  or 
     change the path name within MENU.PRG.

5.0  If  your program will still not Compile and Link then  carry 
     out the following steps:

5.1  Check the compiler and linker by compiling the .GFA programs 
     contained on the distribution disk.

5.2  Remove  all  desk  accessories.  Some public  domain  DA  do 
     illegal things,  and may not run with the  compiler.  Please 
     let us know if you find any.

5.3  Verify  your  source program carefully.  Remember  that  the 
     compiler  is not as forgiving as the  interpreter.  Programs 
     that  run  on  the  interpreter,   can  still  be  in  error 
     logically,  and  may  not function  on  the  compiler.  Only 
     careful debugging can resolve.

5.4  If  still  in  doubt,  send your source code  that  you  are 
     attempting  to compile on disc to GFA,  so that we may  help 
     you identify the problem. Please enclose a stamped addressed 
     envelope for return.

6.0  Corrupt Disk?

     If you find this or any other GFA disk corrupted,  return to 
     to your GFA dealer, who will be to replace the disk for you.

     Alternatively   return the original master disk to GFA  Data 
     Media (UK) Ltd, with a note indicating the problem.

     Always  make a backup of your master disk and work from  the 
     backup, storing the original in a safe place.

     GFA products are not copy protected,  but beware anyone that 
     we discover making illegal copies.

7.0  Bug Reporting

     If you believe that you have discovered a bug please let  us 
     know,  so that we may correct it.  Due to the nature of  bug 
     reporting  and fixing,  please report all bugs  in  writing, 
     with example code to support if needed. 

