# an example of a function keys definition file used
# to correct an argument interpretation for gcc
# compiled program
F1  $k11; $k13 ; $k14; $k15; $b; :c
F11 main:b <sp,10/x; $k12
F12 <sp/W *(<sp+4)-3; <sp+4/W *(<sp+8)+c; <sp,10/x
# for 16 bit
#F12 <sp/w *(<sp+2)-3; <sp+2/W *(<sp+6)+c; <sp,10/x
F13 getitime:b
