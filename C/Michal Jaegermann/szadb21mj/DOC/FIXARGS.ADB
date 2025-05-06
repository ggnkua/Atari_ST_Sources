#
# An example of a command file which 'repairs' an interpretation
# of command line arguments for szadb on gcc-compiled program.
# A stack display 'before' and 'after' is for your amusement
# and enlightment.  Load your program with: adb -k fixargs.adb <prog> <args>
# and hit F1.  Your shell may require prepending 'gem ' to a command above.
#
F1  $k11; $k13 ; $k14; $k15; $b; :c
F11 main:b <sp,10/x; $k12
# for 32 bit compiled program
#F12 <sp/W *(<sp+4)-3; <sp+4/W *(<sp+8)+c; <sp,10/x
# for 16 bit compilation - -mshort
F12 <sp/w *(<sp+2)-3; <sp+2/W *(<sp+6)+c; <sp,10/x
#
# this is only an example - the break below may not
# fall on any executable instruction in your program
# or request may not make any sense in it; be careful
# if you are going to enable it.
#
#F13 v_fillarea+e2:b <a3,<d0+2%4/8d
#F14 
#F15 
