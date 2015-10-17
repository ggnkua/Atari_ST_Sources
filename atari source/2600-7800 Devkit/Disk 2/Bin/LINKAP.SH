#
# first link the GEM application
#
link68 [u] $1.68k=gemstart,$1,ulib,osbind,vdibind,aesbind,gemlib
#
# if that worked continue
#
if (-e $1.68k) then
	relmod $1
	if (-e $1.prg) rm $1.68K
endif
