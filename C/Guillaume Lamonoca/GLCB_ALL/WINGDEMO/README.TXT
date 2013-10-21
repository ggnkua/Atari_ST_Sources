                             WinGDemo
                                By
                        Guillaume LAMONOCA

WinGDemo is a demo that shows you how to create a 3D maze and move
yourself into it... When modules are fast enough, 3D bitmap
projections is allowed... (it is called WinGDemo, because it will
be very interesting for WinG users or powerful computer users).
WinG is a free extension of Windows 3.1, and a full part of
Windows 95, and other 32 bits version of Windows.
If you don't find it, send E-mail to mmdinfo@microsoft.com.

Compatible PC (MSDOS,Windows, and Win32s) executables, as well
as Atari GEM executables can be found in the WINGDEMO.ZIP archive.

To avoid pixelisation effect (pixels become big when you are
near a wall), launch the programs with IMAGE.MUR as parameter
(drag and drop IMAGE.MUR above any executable version of the demo)
IMAGE.MUR has a better resolution than IMAGE2.MUR, but will
result in a loss of speed on 16 bits Windows because it won't
fit in a segment (64K). 

In WING.C, assume this:
USER_FREE_FUNCTION is defined
NOSYSCURSOR is defined
SYSTEM_CURSOR_COLOR is defined, and its value is 200 (for example)

You can compile a SVGA version with the following changes :
In WING.C, WIDTH=640 & HEIGHT=400
In WINGDEMO.C, WIDTH=640, HEIGHT=400 & FACT=256L

Left mouse button shows you the map
Right mouse button stops the demo
Moves are defined by relative mouse position from screen center

Enjoy GLCB!
