'********************************************
'**  This SUB-Program is used to de-pack
'**  files that have been included into
'**  the program with DATACON3.TOS.
'**  It will not work with earlier vesions.
'**
'**  It is called automatically by another
'**  sub program.
'********************************************

sub decrunch(addr&,nummain&,numbytes&,crunchflag&)
local item&,trans&,howmany&,depack&
for trans&=1 to nummain&
	read item&
	if item&=crunchflag& then
		read howmany&,item&
		for depack&=addr& to addr&+(4*howmany&) step 4
			pokel depack&,item&
		next
		addr&=addr&+(4*howmany&)
	else
		pokel addr&,item& : addr&=addr&+4
	end if
next
for trans&=1 to numbytes&
	read item&
	pokeb addr&,item&
	incr addr&
next
end sub
