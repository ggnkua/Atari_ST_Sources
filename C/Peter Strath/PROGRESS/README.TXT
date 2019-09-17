
PROGRESS is an example of a progress report showing what is happening in
a particular function. It carries out functions 'in the background' so
not locking you totally out of the system, using a simple form of
task-switching.

The example creates a specified number of folders into the current path
using a template and adding an increasing number to the end. eg AFOLDER.1,
AFOLDER.2, AFOLDER.3 and so on. You specify the number of folders to create
by just clicking on the arrows, the number wraps around when it reaches
999 or 000.

File list;
MAIN.C       - The main section of code. Handles initialisation and most of
               the control.
FUNCTION.C   - Creates a new folder and handles arrow control.
PROGRESS.PRJ - Project file. Load in Lattice C to compile program.
PROGRESS.PRG - The runnable program.
PROGRESS.RSC - Resource file. Contains dialog box information.
PROGRESS.H   - Header file for resource information.
PROGRESS.HRD - Wercs information.
README.TXT   - This file.

The program was written with Lattice C 5.52 with windowed dialog boxes
from FLDLIB.

Tested on: 520STFM, 2.5Mb RAM, TOS 1.4(with WinX), MagiC 2.01, NVDI 2.5,
           in ST low, medium and high(emulator) resolutions.

Any comments and/or improved versions are welcome.

Address: Peter Strath
         75 Cavendish Road
         Highams Park
         London
         E4 9NQ