rem Quellaufwerk
%1
cd \tc\swap
rem Ziellaufwerk
%2
cd \
if not exist tc md tc
cd tc
if not exist swap md swap
cd swap
copy %1*.c %2
copy %1*.h %2
copy %1tcpick.tcp %2
copy %1swapdemo.rsc %2
copy %1swapdemo.prj %2
copy %1swapdemo.app %2
copy %1swapcopy.bat %2
copy %1sdrename.bat %2

%1
cd ..\include
%2
cd ..
if not exist include md include
cd include
copy %1*.h %2

%1
cd ..\gembind
%2
cd ..
if not exist gembind md gembind
cd gembind
copy %1*.c %2
copy %1*.h %2



