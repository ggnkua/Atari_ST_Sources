
For Turbo C developers.

Because of the trap handling, the Atari developers can't start their programs 
from Turbo C. When resident in memory, a trap call allows to access all entry 
points of MidiShare, which is trap #5 or trap #6, depending of the compiler 
and of the interface file. Launching a MidiShare application from Turbo C will 
generate an error because it replaces these vectors with her own.


You can correct this problem by this way:
- Install the MidiSave.prg application in the AUTO folder or launch it from 
  the desktop. Just take care of that MidiShare is already resident. It will 
  save the entry points of MidiShare.
- As long as you need to test your MidiShare application and to launch it 
  from Turbo C, insert the following function at the beginning of your main 
  (before any MidiShare call):        
                               TCMidiRestore();
which try to restore the entry points of MidiShare and return true if succeed,
false if failed.
