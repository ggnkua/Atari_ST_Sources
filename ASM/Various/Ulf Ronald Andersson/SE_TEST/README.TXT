  In the folder SE_TEST there are the following files:
  
  ERROR.TXT    Sample Error messages that are given to Everest by 
               SE_TEST.
  
  SEPROTO.H    Definitions for the SE-protocol.
  
  SE_TEST.C    Simple demo program to demonstrate the communication
  SE_TEST.H    with Everest using the SE-protocol.
  SE_TEST.PRG
  SE_TEST.PRJ
  SE_TEST.RSC

  VAPROTO.H    Definitions for the VA-protocol
  

The SE (Shell-Editor) protocol was invented for communication between 
an editor and a shell under a multitasking operating system like 
MagiC!. CHATWIN is a highly recommended programmable shell, that 
supports the SE-protocol.

The shell has to announce to Everest via the SE_INIT message. Everest 
asks via AV_PROTOKOLL if the shell understands AV_SENDKEY. If the 
shell understands AV_SENDKEY, it's possible with the EXTRAS/ SHELL 
option to strike a key that will be sent to the shell.

The options EXTRAS/ MAKE and EXTRAS/ COMPILE cause Everest to send 
ES_MAKE and ES_COMPILE:

  -MAKE: All changed texts are saved. If the option 'Close all texts 
   after make' in the PARAMETERS/ PROGRAM_EXIT menu is checked, all 
   texts are closed. Then Everest sends ES_MAKE with a NULL-parameter 
   for the makefile.
  
  -COMPILE: the actual text is saved and its filename is given to the 
   shell via the ES_COMPILE message.
   
Everest understands the following messages:

SE_OPEN    Everest loads the given file.

SE_ERROR   The given file is topped. If it's not loaded it will be 
           loaded. The cursor is moved to the desired position and the 
           given text will be shown in an alertbox.

SE_ERRFILE With this message it's possible to hand over two filenames. 
           One file can be regarded as the compiled file. This file 
           will be topped, if it's loaded, if not, it will be loaded. 
           The other file may be regarded as the errorlist. If this 
           file is already loaded, it will be closed and then 
           reloaded.

SE_QUIT    The shell is terminated and gives Everest notice about 
           this.

SE_TERMINATE The shell wants Everest to quit.

SE_CLOSE    Everest closes all open windows.

More detailed information about the SE-Protocol can be found in the 
file SEPROTO.H.

The SE-Protocol was developed by Dirk_Steins@k2.maus.de and 
Frank_Storm@ac2.maus.de.

EOF