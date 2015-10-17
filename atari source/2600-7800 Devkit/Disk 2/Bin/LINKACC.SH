#
# link the desk accessory
#
link68 $1.68k=accstart,$1,osbind,vdibind,aesbind
#
# if that worked (the *.68k file exists) then relmod
if (-e $1.68k) then
	relmod $1.acc
	if (-e $1.acc) rm $1.68K
endif

