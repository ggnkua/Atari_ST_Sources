set prompt='! $cwd> '
set path=m:\ c:\bin c:
set temp=m:\
set symb=m:\
set include=m:\include\

alias cdb cd c:\bin
alias cdu cd c:\utils
alias cdc cd c:\cross
echo set date and time
if( -e m:\ ) then
	echo ramdisk already installed
else
	ramdisk
endif
if( -e m:\include ) then
else
	mkdir m:\include
endif
cp \include\*.h m:\include
cp \bin\as68symb.dat m:\
cp \bin\cp*.prg \bin\link68.prg \bin\relmod.prg \bin\cc.prg m:\
cp \bin\as68.prg m:\
cd \skel
cp *.o gemlib libf m:\
cd \cross
