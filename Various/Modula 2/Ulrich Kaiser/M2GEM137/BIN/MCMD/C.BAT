:rem KAOS/Mag!X-CMD script to call the c preprocessor cpp.ttp
:rem %1 is the actual source
:rem %2 is the destination system
:rem sample call: c aes.mod HM2
:rem make the -imacros path suitable to your own file system
:rem
echo cpp %1 fr %2...
cpp %1 -D%2 -P -imacros D:\USR\INCLUDE\CRYSTAL.M2H |x2d1 >temp
ECHO OFF
del %1
ren temp %1