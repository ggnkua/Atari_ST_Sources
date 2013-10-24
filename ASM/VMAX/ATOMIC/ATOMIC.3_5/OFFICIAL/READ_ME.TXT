ATOMIK V3.5

This program is actually the best compression program on the st
the compression rates are better than all the other packer in 95% case.
the old version of atomik had some bug but now you can be sure that
this one is really totally free from error.

some changes in atomik v3.5:

for interupt atomik you must now use undo

you can now archive files by using the
multi pack and multi depack option

AUTO_DEC.PRG

This program is done for data file unpacking.
Exemple: you can pack all your modules with
ATOMIK v3.5 and put AUTO_DEC.PRG IN \AUTO\
or just by double clicking on it.

After you can use your soundtracker with
packed modules!

AUTO_DEC.PRG will be installed in memory
and it will change vector $84 (TRAP #1)
for uncrunch each loaded data file wich
start by "ATM5".

You can use it with your old source code too.

Caution: -cannot be used when file lenght is used like included source code
         
         -cannot be used when the file is only partialy read

         exemple: degelite start by reading the first values
         of the file for testing the picture file type...
         so you can pack your degelite pictures only
         for archive them but it cannot be
         read by degelite using AUTO_DEC.PRG
         
         so when you want to use your pictures with
         degelite you must start by unpacking them
         with the unpacking option of ATOMIK v3.5
       
RELOC_V4.PRG

This program is one of the first program i have written on st
first it was called monst relocator and now it is adebug relocator
this program can do the following things

1.) It can relocate adebug everywhere you want to

a.) In top of memory
b.) In low of memory
c.) Enter adress you want to.

2.) An antivirus system

This anti virus don't know a lot of boot sector
it will just reconize AVK 3.6,SAGROTAN,GHOST
and its own old boot

But the quality of this anti-virus is that
the TDT v4.0 boot sector you can install
with RELOC_V4.PRG in the V option
will copy itself to other disk when it
are empty or contain ghost virus!

This is the best protection against ghost virus!

The TDT V3.0 (called TDT VIRUS) had a big bug
it copy itself everywhere ecxepted when the disk
contain the ghost virus!! flag bug!.

For atomik 3.5 i have coded the algorythm 8 month before
but some familly problems appears and i couldn't finish the code.
Now it's done and i'm hardly working on atomik pro wich will
be shortly comercialised by THUNDERSOFT dvlp.

Ok that's all for today freaks! good bye.


                      ALTAIR from VMAX/MCS.