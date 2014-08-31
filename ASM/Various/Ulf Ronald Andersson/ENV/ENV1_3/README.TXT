This archive should contain the following:

ENV.PRG
ENV.INF
ENV.CPX
README.TXT     <-- this file

To use drop ENV.PRG & ENV.INF into your \AUTO folder and copy ENV.CPX into 
the folder containing your CPXs probably \CPX. Reset your machine and that 
is it.

After opening the CPX:
    Main display:
        Clicking on one of the variables takes you to the edit display with 
        that variable displayed.
        The scroll bar works as normal.
        The Load button loads in the env.inf file to reset the variables 
        back to their original values.
        The Save button save the present settings.
        The Add button takes you to a blank edit display so that you can 
        add a new variable.
    Edit display:
    	Up to 240 characters can be entered for each variable.
    	This consists of 8 lines by 30 characters, so you have to break 
    	each variable up into chunks if it is longer than 30 characters.
    	Sorry about this but it is a limitation of GEM.
    	The Delete button will delete the displayed variable, the Cancel 
    	button will cancel any edits you have done and the Exit button will 
    	add or change the displayed variable.


I hope these programs are of some use to you.

Simon        srobins@cix.compulink.co.uk


Versions:
1.0
    First attempt - Used cookie
    Strings LF/CR terminated, ENV.PRG translates to NULL terminated.
1.1
    Attempted to intercept exec_os vector and change GEM there - failed.
1.2
    Uses the the_env vector - ENV.PRG allocates memory 2 * ENV.INF
    ENV.CPX now just saves the env as is to ENV.INF - no translation 
    neccessary, ENV.PRG altered to just read in ENV.INF as is.
1.3
    ENV.PRG now allocates memory 4 times the size of ENV.INF or 1024 bytes 
    whichever is the larger.
