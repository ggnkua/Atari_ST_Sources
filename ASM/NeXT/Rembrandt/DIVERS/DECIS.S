var set 0
 rept 32
var1 set var+(32-var)*50/100
var2 set var+(32-var)*25/100
 dc.w var1,var2
 dc.w var
var1 set var*75/100
var2 set var*50/100
 dc.w var1,var2
var set var+1 
 endr
 