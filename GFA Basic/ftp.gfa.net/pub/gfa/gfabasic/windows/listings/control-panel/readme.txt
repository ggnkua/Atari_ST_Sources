--------------------------
Information about SKELETON
--------------------------

SKELETON is meant to provide you, the GFA-Basic programmer, with a 
"skeleton" Control Panel applet which you can fill in and modify to
create your own applets for the Windows Control Panel.

The primary purpose of the source code is to get you interfaced
properly with CONTROL.EXE by means of the CPlApplet() function. All 
communication between your DLL and the Control Panel takes place
via this exported function. The sample DLL also contains procedures
for dialogs which you can modify for your own purposes if you wish.
These were included for demonstration purposes only.

If you wish to include resource dialogs, string tables, icons, 
bitmaps, etc. in your applet, you will need a resource compiler tool
such as Borland's Resource Workshop or Microsoft's App Studio. I have
not tried using GFA dialogs for use in a .CPL file, so I can't say
if or how they will perform. I have found the use of resource dialogs
and callbacks much simpler and efficient. For those of you who may
not own a resource compiler, but wish to compile the source code
yourself, I have included the SKELETON.RES file which can be linked
into the DLL at build time.

For those who do not own the GFA-Basic compiler, but would like to
get an idea of what can be done with it, I have also included the
finished .CPL file which can be tested by simply copying it to the
WINDOWS\SYSTEM directory and then starting the Control Panel.

For further information on creating Control Panel applets, refer
to the Windows SDK documentation.

The compressed archive should contain the following files:

SKELETON.LST - source code file in text format
SKELETON.RES - resource file
SKELETON.CPL - the finished sample applet
README.TXT   - The file you are now reading
CPXT11.ZIP   - A special "bonus" <g>. It's an archive
               containing a Freeware Control Panel applet
               (also written in GFA) which you may find useful.
               Feel free to use it and give copies of the ZIP-file
               to your friends.

If you have any questions or comments, you can contact me by CS-Mail
or leave a message in the WINAPC forum (GFA section).

My CIS ID: 
Daniel Di Bacco, 100140,1156

Have fun!
