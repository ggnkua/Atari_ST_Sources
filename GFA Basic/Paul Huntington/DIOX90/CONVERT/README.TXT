*********************************
IMPORTANT FOR GFA BASIC v3 OWNERS
*********************************

     Diox v0.95 was written to produce dialogue boxes for GFA 
Basic v2. However, with v3 of GFA Basic there are some important 
differences in the way that variables are passed to procedures 
(use VAR instead of *). This makes DIOX v0.95 (as far as I know, 
the latest version available in England) boxes incompatible with 
GFA Basic v3.      
     The program CONVERT.GFA converts boxes into a form suitable 
for use with v3. Load it into GFA Basic, run it and select the 
*.LST file that you wish to convert. The rest is done by the 
program.
     The program TESTIT.GFA is a version of BOXTEST.BAS for v3. 
Change the procedure name "testbox" to the name of your box, and 
merge the (converted) *.LST file at the point indicated.
     There is one small change needed in the method to call the 
box from your program. Contrary to what is said in the manual, 
the form below should be used.

     box_name(default$,selection$)

     Where box_name is the procedure name of your box,
           default$ are the preset states of radio/toggle buttons
     and   selection$ contains the status of buttons after the 
           box has been used.

Adam Millard-Ball
7/7/92

     

