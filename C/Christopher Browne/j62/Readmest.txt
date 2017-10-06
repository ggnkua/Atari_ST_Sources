February 27, 1993
This is J Version 6.2 for the Atari ST.

It was compiled using GCC version 2.3.3, and the MiNT libraries version  
0.26, and seems to run quite happily under either TOS or MiNT.  (I       
usually run it under MiNT in its own window under TOSWIN 1.2 (or is it   
1.4?  It doesn't say...)                                                 

I've compiled in the EDITLINE package, a somewhat simplified version of  
the GNU Readline system that allows you to use the "standard" Emacs      
control keys to edit past commands and present them as new ones.  There  
is some sort of screen imperfection in this, particularly relating to    
the prompt.  However, it does work, and makes it much easier to repeat   
old commands (TOSWIN also allows cut & paste, which is nice too!)        

I've included the readme file from the Editline package, and copies of   
the files that I had to modify to get it all working.                    

There is one notable "bug/feature/hack":  The "normal" way that one      
exits J is using the "End of File" also known as "Control-D."            
Unfortunately, EDITLINE uses Control-D to delete characters.  Conflict.  
(And a conflict that required a couple of re-boots before it was fixed.) 

What I have done is to add the classical ")OFF" command of APL; I test   
for a line containing (ONLY) the string ")off" or ")OFF", and change it  
to a "\004" (or Control D).  It's not standard J, but it does work.      

Depending on a job offer that may come next week, I may be moving to     
Toronto, which will certainly change my email address.  I'll leave two   
that will likely get at me:                                              

cbbrowne@csi.uottawa.ca                                                  
aa454@freenet.carleton.ca                                                

A reasonable permanent address is:                                       
1000 Stormont St.                                                        
Ottawa, Ont.                                                             
K2C 0M9                                                                  
(613)-225-3689

Hope this port is helpful.  The next step is to figure out how to use
LINKJ, and stick in some of my numerical analysis code...

Christopher Browne

