
Edit the IND.INF so that it contains the path to your ISM directory.

Note that any action that is connected to the slots in the main form comes 
from a module loaded from ISM\*.ISM. Four demo modules show the functions, 
only one of them (Sample Server, SAMPLE.ISM) shows a little more like the 
final modules will be, on user activation. None of the modules is resident,
they are all loaded on request, and unloaded after work is done !

Try also what happens if you have more than four modules in ISM, or less 
(just delete some, or edit the extension).

The INetD is a program that normally stays resident. Therefore is is 
protected against unintentional termination. Terminate it by holding CTRL 
while clicking the window closer button. If you closed the window without 
CTRL the INetD stays resident and can be invoked again by sending it an 
AC_OPEN or VA_START message.

The SAMPLE directory contains the full set of source files for the Sample 
Server, commented to give you an idea how things work. There are not enough 
comments yet to enable you to make your own fancy module, this will change 
soon with a real documentation of the programming interface.

Do you like it ?

Cheers  Peter
