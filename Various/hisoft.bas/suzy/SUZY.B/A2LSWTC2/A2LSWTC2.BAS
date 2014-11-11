rem $option K80,Y+,Z,B+
'That's release all but 80k of memory, DONT ASK ME TO PRESS A KEY
'AFTER BEING COMPILED!, and Y+ says we're not using windows when
'the program is executed. B+ disables the CONTROL-C. I'm not using
'the V option because I'm not using sub-programs. Its all straight
'forward stuff.

library "gemdos","gemaes","xbios","gemvdi","bios"
'Yes I really use all these libraries!


defint a-z					'Not just a good idea. IT'S THE LAW!

dim dta(22)         		'DTA Array needed for file stuff
							'Dim'ed at 22. Don't know why 22
							'but since thats what the example had
							'thats what I'll use.

'What follows are some very useful variables such as our screen
'address and the address of the screen we will use for those
'TTP programs.

screenl&=FNlogbase&
screenp&=FNphysbase&
lenghth&=33&*1024&			'33k. So what if I can't multiply by myself?

'The area that I'll use for my screen will be filled with all zero's.
screen$=string$(lenghth&,chr$(0))	

screenaddr&=varptr(screen$)	'The address of my screen. Sort of.

'The screen address MUST be on a 256 byte page. I added 256 to
'my address to make sure the address falls in my screen$.
screenaddr&= int(screenaddr&/256&)*256&+256&

'Whats next is for finding our path. Lengthy but it does tell us
'where we are located on disk.

drive=FNdgetdrv
drive$=chr$(drive+asc("A"))
path$=string$(64,32)
dgetpath sadd(path$),0
where=instr(path$,chr$(0))
if left$(path$,1)=chr$(0) then
	path$=drive$+":\"
else
	path$=drive$+":"+mid$(path$,1,where-1)+"\"
end if

temppath$=path$+"OUR_WORK.GAH"		'Our temporary work folder.
									'_NOBODY_ has a folder named that!

x&=fre(-1)
if x&<(128&*1024&) then				'Check if I can run those TTP's
	x&=fre(-1)/1024&
	x$=str$(x&)
	t1$="I'm sorry but for me to|"
	t2$="execute TTP's I need at|"
	t3$="least 128k to work with.|"
	t4$="  Only"+x$+"k available.|"
	junk=FNform_alert(1,"[1]["+t1$+t2$+t3$+t4$+"][ Quit ]")
	stop -1
end if
on error goto Handler				'If the CNF file does not exist...
									'ERROR!

save$="A2LSWTCH.CNF"				'Our CNF file
open save$ for input as #1	
line input#1,arcttp$				'I guess it DOES exist.
line input#1,lharcttp$
line input#1,mode$
close #1
on error goto 0						'Okay, file was there.

Handler: 

x=(FNkbshift(-1)) and 15   		   	'Hold down alt or shift or control
									'or any combination and we'll
									'create a new CNF file.

if err=53 or x<>0 then				'If there is no error in the above
									'and you're not holding down one
									'of those keys then all this will
									'be passed over.
	Configure:
	t1$="Use the Item Selector|"
	t2$="to select the ARC.TTP|"
	t3$="  that will be used.|"
	junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+"][ Okay | Quit ]")
	if junk=2 then stop -1
	fpath$=path$+"*.TTP"
	name$=""
	fsel_input fpath$,name$,but
	if but=0 then goto Configure
	arcttp$=left$(fpath$,len(fpath$)-5)+name$
	Configure2:
	t1$=" Use the Item Selector|"
	t2$="to select the LHARC.TTP|"
	t3$="  that will be used.|"
	junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+"][ Okay | Quit ]")
	if junk=2 then stop -1
'I use the same path you chose for ARC.TTP
'since LHARC.TTP is probably in the same folder as ARC.TTP
	name$=""
	fsel_input fpath$,name$,but
	if but=0 then goto Configure2
	lharcttp$=left$(fpath$,len(fpath$)-5)+name$
	
	t1$="Should I delete the original|"
	t2$=" file AFTER switching it to|"
	t3$=" the new compression method|"
	t4$="  or just leave it alone?|"
	junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+t4$+"][ Leave it | Delete ]")
	if junk=1 then
		mode$="Leave"
	else
		mode$="Delete"
	end if
	
	save$="A2LSWTCH.CNF"			'Save our new CNF file.
	open save$ for output as #1
	print #1,arcttp$
	print #1,lharcttp$
	print #1,mode$
	close #1
	
end if

Begin:
t1$="   Welcome to ARC/LZH switcher!  |"
t2$="      v1.02 by Jan Dembowski| |"
t3$="    Please choose the action|"
t4$="            To take:|"
button$=" ARC>LZH | LZH>ARC | Quit "

junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+t4$+"]["+button$+"]")

select case junk
	case 1							'Selected ARC to LZH...
		begin$="ARC"
		result$="LZH"
		from$=arcttp$
		to$=lharcttp$
	case 2							'Selected LZH to ARC...
		begin$="LZH"
		result$="ARC"
		from$=lharcttp$
		to$=arcttp$
	case 3							'Selected QUIT!
		stop -1
end select

Folder:
t1$="      Select the folder|"
t2$="    you want the "+result$+" files  |"
t3$="       to be placed in.|"
junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+"][ Select | Create | Cancel ]")

select case junk
	case 1							'Choose the destination folder.
		fpath$=path$+"*.*"
		name$=""
		fsel_input fpath$,name$,but
		if but=0 then goto Folder
		whereto$=left$(fpath$,len(fpath$)-3)
	case 2							'Create the destination folder.
		Create:
		t1$="   Use the Item Selector to|"
		t2$=" choose the path of the folder|"
		t3$="  you want and type the name|"
		t4$="    in the Selection area.|"
		junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+t4$+"][ Okay ]")
		fpath$=path$+"*.*"
		name$=""
		fsel_input fpath$,name$,but
		whereto$=left$(fpath$,len(fpath$)-3)+name$
		if but=0 or len(whereto$)=3 then goto Folder
		if name$="" then goto Create
		t1$="You Want to Create the path:| |"
		t2$=whereto$+"|"
			junk=FNform_alert(1,"[2]["+t1$+t2$+"][ Yes | No ]")
		if junk=1 then
			x=FNdcreate(whereto$)	'You created a folder!
		else
			goto Create
		end if
		whereto$=whereto$+"\"
	case 3							'Canceled. Go back to the begining.
		goto Begin
end select

Selection:
t1$=" Select the "+begin$+" to be|"
t2$="Switched. Use Wildcards|"
t3$="      If you want.|"
junk=FNform_alert(1,"[0]["+t1$+t2$+t3$+"][ Okay | Cancel ]")

select case junk
	case 1							'Choose your file to be Switched.
		fpath$=path$+"*."+begin$
		name$="*."+begin$
		fsel_input fpath$,name$,but
		if but=0 then goto Selection
		choice$=left$(fpath$,len(fpath$)-5)+name$
		fpath$=left$(fpath$,len(fpath$)-5)
	case 2							'Canceled. Go to begining...
		goto begin
end select

olddta&=FNfgetdta&

fsetdta varptr(dta(0))

exist=FNfsfirst(choice$,0)			'Does your choice exist?
if exist<0 then
	fsetdta olddta&
	t1$=" |No files selected!| |"
	junk=FNform_alert(1,"[1]["+t1$+"][ Again | Cancel ]")
	if junk=1 then
		goto selection
	else
		goto begin
	end if
end if

Tempfolder:
x=FNdcreate(temppath$)				'Create our work folder.

'In case that folder DOES exist...
try=1
if x<>0 then 
	temppath$=path$+"OUR"+chr$(48+try)+"WORK.GAH"
	if try>9 then
		setscreen screenl&,screenp&,-1
		v_show_c 0
		t1$="I can't create a folder|"
		t2$="to work with. Check your|"
		t3$=" directory for folders|"
		t4$="  named OUR_WORK.GAH|"
		junk=FNform_alert(1,"[1]["+t1$+t2$+t3$+t4$+"][ Quit ]")
		stop -1
	end if
	try=try+1
	goto Tempfolder
end if

v_hide_c							'Hide the mouse

'Now lets go to OUR screen and leave that nice GEM screen alone.
setscreen screenaddr&,screenaddr&,-1

do
	addr&=varptr(dta(15))
	do
		hold=peekb(addr&)
		if hold=0 then exit loop
		filename$=filename$+chr$(hold)
		incr addr&
	loop  

'Lets set up our Command Lines for Pexec

	commandline1$="X "+fpath$+filename$+" "+temppath$+"\*.*"

	newfile$=left$(filename$,len(filename$)-3)+result$
	commandline2$="M "+whereto$+newfile$+" "+temppath$+"\*.*"
	
'Here's	where the actual work is done. Not alot is it?

	x=FNpexec(0,from$,commandline1$,"")
	if x<>0 then goto Perror
	v_hide_c						'LHARC likes to turn on its mouse.

	x=FNpexec(0,to$,commandline2$,"")
	if x<>0 then goto Perror
	v_hide_c						'So lets turn it off for 'em!

	if left$(mode$,1)="D" then		'Delete the _original_ ARC or LZH
		filedelete$=fpath$+filename$
		x=0
		x=FNfdelete(filedelete$)
	end if
	
	filename$=""
	newfile$=""
	
	exist=FNfsnext					'Any more files to mess with?
	if exist<0 then
		fsetdta olddta&
		exit loop
	end if
loop

x=FNddelete(temppath$)				'Remove our work folder

setscreen screenl&,screenp&,-1		'Back to GEM screen!
v_show_c 0							'show mouse

t1$="  All finished.|"				'More files to do?
t2$=" Do you want to|"
t3$="Switch some more|"
t4$="     files?|"
junk=FNform_alert(2,"[1]["+t1$+t2$+t3$+t4$+"][ Yes | No ]")

if junk=1 then goto begin			'We're not finished yet!

stop -1								'Yes we are.

Perror:								'An error happened with
									'x=FNpexec

fsetdta olddta&						'Set old dta
setscreen screenl&,screenp&,-1		'Go back to GEM screen

'Sometimes the temppath wont delete. I try three times.
for a=1 to 3
	x=FNddelete(temppath$)			'Remove our work folder
next a								'If there are files in this
									'folder then you'll have to 
									'remove the folder from the
									'desktop.
v_show_c 0							'Show That Old Mouse!
t1$="   An ERROR has occured in|"
t2$=" executing one off your TTP's|"
t3$="while working on "+filename$+"|"
t4$="check that file and your TTP's.|"
junk=FNform_alert(1,"[1]["+t1$+t2$+t3$+t4$+"][ Quit ]")

stop -1
