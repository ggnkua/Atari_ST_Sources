MagiC routines for Lattice C 5.52
---------------------------------

I have included the following assembly routines to aid programmers who 
wish to write MagiC aware software using Lattice C 5.52. Although a 
library is included with MagiC, it is for Pure/Turbo C, so I hope this 
will help. I am assuming that you have the MagiC manual, and therefore 
know what these calls are supposed to do!

As I am no expert at assembly programming, I cannot guarantee that the 
routines are correct, but merely state that I have not had a problem 
with them in my own programs. In particular, I have tried to follow 
the layout of the LC AES routines I have dissasembled, even though 
some of them appear a little illogical- I am sure that there are good 
reasons for this. 

Please especially check the form_xdo, as this uses three addrin 
values- a situation which does not occur with any of the standard 
LC routines (I think), and therefore I didn't have a model to base it 
on. Again I have had no problems but....?

How to use
----------

Once you are satisfied with the routines, the easiest way to make a 
new library is through the project menu. 'Add' all the supplied 
routines (with the exception of MAESIF.S) to the project. On the 
'output to' line enter your normal library path and the name of the 
new library e.g.: 

c:\lc\lib\magiclib.lib

Select 'Make' or 'Make All' and sit back.

You must then delete the @_AESif routine from the LCG.LIB library. To 
do this, run OML and pass the following command line: 

[Your library path]\lcg.lib d _aesif

You can now add the new routine MAESIF.S by following the above step 
again, but outputting to :

[Your library path]\lcg.lib

Select 'Make' or 'Make All' again and sit back, smoke a pipe etc.

#include the MAGX.H header file in your programs, and make sure you 
link your magic library at compilation time!

N.B. As far as I know, Pure/Turbo C takes default short integers as 
opposed to Lattice 5.52 which takes default long integers. You will 
probably have to modify the MAGX.H header to take account of this.
 
Help !
------

I have never quite got the hang of OML (tell me if I'm wrong here):

When you build or add to libraries, the librarian uses the filename as 
the basis of the module name. e.g:

Adding c:\junk1.s and c:\junk2.s to c:\junklib.lib 

Gives the module names: 

c:\junk1.o and c:\junk2.o

Now whenever I try to process a module in the library, I can't seem to 
do it if it's a filename. i.e. no matter what I do, c:\junk1.o and 
c:\junk2.o don't get processed. The only exception seems to be that I 
can still use x * to extract all the modules. Since the project 
manager always seems to pass filenames to the librarian, I end up with 
whole libraries which cannot be processed...am I doing something wrong 
here? 

O.K. I know that I can edit the module names with KnifeST, and it will 
then work, but surely there must be a better way of doing this.

If you can help me with any of the above, or provide me with any 
routines to ease the pain of writing non-modal windowed dialog boxes 
(preferably with form_button, -keybd, and objc_edit rather than custom 
routines), generally cope with multi-tasking environments, and 
protocols such as Gemini AV, and XACC, I will be delighted to hear from 
you. 

If anyone wants software testing on a 4 meg STFM running MagiC 2.01 & 
NVDI 2.51, HD, MM, get in contact with me, but please include an 
S.S.A.E. or you won't get a reply!

Hope this has been of some use.

Cheers.

Richard Evans.

3 Gervis Crescent
Parkstone
Poole
Dorset
BH14 0LR

0202 744151
  