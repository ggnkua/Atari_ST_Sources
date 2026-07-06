While the TDI Modula-2/ST system is highly recommendable, I don't much
care for the editor supplied with the system.  However, the TDI editor
has one major advantage: it allows you to step through a source program,
finding compilation errors.  This article contains an interface program,
written in Modula-2, which allows you to use Micro-Emacs (v3.7i, as
posted by James Turner of Imagen Corp) in the same manner. 

Although this program can be used on any ST on which Modula-2/ST runs,
it's probably best to use a ramdisk (there is a fair amount of I/O on
startup).  I use RMD650.ACC, which provides enough room for the
compiler, linker, non-GEM library, and the compiler's intermediate
files. 

Files included
----- --------

   README.TXT    -- you are reading it.
   EDITOR.MOD    -- the interface program.
   MODEMACS.RC   -- a Micro-Emacs startup file.
   M2ERRORS.TXT  -- a prototype error message file (the full file is not
                    distributed for copyright reasons).
 
Installing the program
---------- --- -------

1) Compile and link EDITOR.MOD. If you use the OPT linker option, the program
   will take up about 8500 bytes. The default stack size of 8K is adequate.
   
2) Leaving the program name as EDITOR.PRG (so that M2DESK will know about it),
   use Show Info... to change the program type to "TOS-takes-parameters" (so
   that you can run it from the desktop). Save the desktop.
   
3) Using the supplied M2ERRORS.TXT as a format guide, type in the error
   messages from the manual. Name the resulting file M2ERRORS.TXT.
   
4) Add the contents of MODEMACS.RC to your EMACS.RC file at the end.

5) Make sure that EDITOR.PRG, EMACS.TTP, M2ERRORS.TXT, and the revised
   EMACS.RC are in the same directory, and that that directory is writable.
   
Running the program
------- --- -------

You can either open it from the desktop, or invoke it as the editor from
M2DESK.

1) If invoked with no argument, or with an argument whose name doesn't end
   in .MOD or .DEF, it pretty well does nothing except to invoke EMACS.TTP.

2) If the argument name ends in .MOD or .DEF, it searches for a file in the
   same folder named .ERM or .ERD (respectively). If no such file exists, 
   it again invokes Micro-Emacs.
   
3) If a compiler error file does exist, however, it generates a file of
   Micro-Emacs commands which annotates the source file with error numbers,
   and defines key F10 as a macro which searches for the next error. If 
   errors exist, there will be two windows in the screen: a one-line window
   containing the error message, and another window containing your source
   file.
   
Caveats
-------

1) Modula-2 code must absolutely *NEVER* contain the character sequences 
   (*% and %*) , which are used to mark error message numbers. Failure to
   abide by this restriction will cause the F10 key macro to remove a few
   characters near the offending character sequence, with little explanation.
   If this represents a problem to you, then you can change the error markers.

2) Don't do any window manipulation while using these commands. The F10 
   macro assumes there are two windows on the screen, one containing the
   source code, and one containing the error messages. Arbitrary window
   splitting or window movement will confuse it.
   
3) There have been allegations on the net that Micro-Emacs can crash because
   of the well-known problems with GEMDOS memory allocation. I don't know
   about this, as it has never happened to me. However, my programming 
   instincts suggest that if it's going to happen at all, it's most likely
   to happen with command files such as MODEMACS.RC, which contains macros
   which generate buffers of commands which are then executed. (I'm not 
   defending this style; I just couldn't think of any other way to do it.)
   Frequent saving of files might be a good idea.
   
4) As mentioned above, the directory containing the editor must be writable.
   If you aren't going to use a ramdisk, beware.
      
5) The only way I could figure out to do the error scanning was to make rather
   extensive use of the kill buffer and the mark. Sorry.
    
