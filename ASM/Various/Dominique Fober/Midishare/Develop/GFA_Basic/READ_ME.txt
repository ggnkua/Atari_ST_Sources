***************************************************************************
*              MidiShare development kit for GFA Basic                    *
***************************************************************************


The GFA folder contains all the files you need to build MidiShare 
applications with GFA Basic.

MidiShare must be resident in memory before launching any MidiShare 
application or desk accessory.

You will find there an application skeleton (SKELETON.LST) and examples 
of applications using this skeleton : MICROSEQ.LST and MSECHO.LST.

The MIDSHARE.LST file contains the description of all the entry points of 
MidiShare, merge it with any program that call any MidiShare function.

Because of the impossibility of getting a function address, the MidiShare 
GFA Basic interface does not implement all the functions that allow the 
task management.

WARNING : GFA Basic causes a minor display bug when you use timer events. 
We hope to see it corrected with the future version of GFA Basic. 
See also the procedure @lisez_moi at the beginning of SKELETON.LST.
