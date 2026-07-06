link68 [s,u] $1.68k=apstart,$2,aesbind,vdibind,osbind,gemlib
if (-e $1.68k) then 
	relmod $1
	if (-e $1.prg) rm $1.68K
endif
