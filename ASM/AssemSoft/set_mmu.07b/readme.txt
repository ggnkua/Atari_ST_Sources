
                            Hades PMMU tools.

                              SET_MMU v0.7b
                              MMUDUMP v0.6b

                           AssemSoft (c) 1999

                  Written (in 100% ASM) by Odd Skancke.

                         Released Nov 25 - 1999

                                FreeWare


-------------------------------------------------------------------------
----------------------------   Disclaimer   -----------------------------

 The author, me, takes no responsibility whatsoever for any effects using 
this software might have on your Hardware, unless it makes it fly. Only 
if it makes your machine fly, I'm willing to take responsibility, as that 
would be a breaktrough in programming the TOS platform. If you don't like 
these terms, DO NOT USE THIS SOFTWARE!!

-------------------------------------------------------------------------
--------------------------  What is SET_MMU? ----------------------------

 This is a small package of tools for the Hades040/060 computers. Altho 
it was written for/on the Hades, I think it can be used with any machine 
containing a 040/060 CPU, and doesn't have good PMMU (Paged Memory 
Management Unit) support in the OS.

 Keep in mind that the 040 versions have not been tested! I have only 
tested the 060 versions, then made the changes for the 040, so I hope it 
will work ;-)

 The program SET_MMU.PRG is the "main" tool in this package -- it runs at 
bootup, from the AUTO folder, and builds a Translation Tree according to 
a configuration file. After it has built the Translation Tree, it will 
enable the PMMU, and set other CPU registers according to the 
configuration file.

 If you want to understand more about the PMMU, translation trees and 
other topics talked about here, I strongly suggest obtaining and reading 
the M68040 or M68060 Users Manual, which can be obtained for free from 
Motorola.

-------------------------------------------------------------------------
----------------- The configuration file - mmusetup.cnf -----------------

 As mentioned above, SET_MMU reads a configuration file called 
MMUSETUP.CNF, which contains the info it needs to build a translation 
tree. SET_MMU first looks for this file on the root of your boot 
partition. If it is not found there, it will look in your AUTO folder. If 
not found on either of these places, SET_MMU will print an error to the 
screen and wait for a keypress. When pressing a key, it exits without 
doing anything, and the boot procedure continues.

 Now, lets look at the configuration file, and the syntax it uses. Also, 
for additional explanations/documentation, look at the supplied 
configuration files, called NOSPLIT.CNF and SPLITRAM.CNF. Read more about 
these files below...
.........................................................................
 *- Comments -* 

 In the configuration file, comments are allowed by preceeding anything 
with a '#' character. When a comment character is found, the rest of that 
line is ignored.
.........................................................................
 *- Keywords -* 

split_ram      Takes either "yes" or "no" as parameter. If split_ram=yes, 
               then set_mmu will split the available RAM into 14Mb ST 
               RAM, and the rest (everything above 16Mb, as 2Mb are 
               lost, see below for more info on this, and why splitting 
               the RAM is recommended) becomes TT RAM. When split_ram is 
               activated, set_mmu will fiddle with the phystop, ramtop 
               and _memtop system variables and jump trough the reset 
               vector on cold boots. If not present, the default is "no".
example:
split_ram=yes
.........................................................................
pagesize       This variable selects either "4k" pages or "8k" pages. 
               This variable is demanded. As I write this documentation, 
               I remembered that I forgot to make this default to 
               something, so if omitted, you'll get 0k page sizes, which 
               is not exactly what we want.

example:
pagesize=8k
.........................................................................
cacr           With this variable, you set the cache control register in 
               the CPU. This variable can take either a hexadecimal 
               numerical value (I.e., a value preceded with $), or a list 
               of comma separated "flags". This is a list of the flags 
               you can use;

               edc  - Enable Data Cache
               nad  - No Allocate Mode (data cache)
               esb  - Enable Store Buffer
               dpi  - Disable CPUSH Invalidation
               foc  - 1/2 cache operation mode enable (data cache)
               ebc  - Enable Branch Cache
               cabc - Clear all entries in the branch cache
               cubc - Clear all user entries in the branch cache
               eic  - Enable Instruction cache
               nai  - No Allocation Mode (instruction cache)
               fic  - 1/2 cache operation mode enable (instruction cache)

               If this variable is omitted, all bits in the cacr will be 
               cleared.

               The following two examples have different syntax 
               but exactly the same effect.
example:
cacr=edc,esb,edc,cabc,eic
cacr=$a0c080000
.........................................................................
itt0, itt1     These variables have the  same name as the CPU registers, 
dtt0, dtt1     wich are the "Instruction Transparent Translation" and 
               "Data Transparent Translation" registers 0 and 1. These 
               registers are used to define two blocks of Transparent 
               Translation address spaces for Instruction and Data 
               accesses respectively. These variables take a numerical 
               expression. I don't want to explain the values here, but 
               this example will be good on the Hades. 

example:
itt0=$0
dtt0=$0
itt1=$0
dtt1=$0
.........................................................................
 The next part describes the variables used to define "blocks" of logical 
address spaces that set_mmu use to build the translation tree. These 
variables *must* come in "blocks", and each block *must* be separated by 
an empty line. The variables that make up each block are as follows;

logical        This variable gives the logical starting address of the 
               block. This variable takes a numerical value.

physical       This variable gives the physical starting address of the 
               block. I.e., the logical address space is mapped to the 
               physical address space. This variable takes a numberical 
               value.

size           This gives the size of the block in bytes. This variable 
               takes a numerical value.

pd_flags       This variable is used to set initial bits in the Page 
               Descriptors of the block. This is used to set the 
               initial caching mode of the block. This variable takes a 
               comma separated list of "flags", which have the following 
               meaning;

      - The following flags are understood, but not used! pdt_r1 is always
      - forced into the pdt field of page descriptors. Also, SET_MMU can
      - not create indirect page descriptors at this time!

     pdt_iv    - Page Descriptor Type = invalid  ( %00 )
     pdt_r1    - ------- "" --------  = Resident ( %01 ) This is the pdt
                                                         value set by SET_MMU.
     pdt_r2    - ------- "" --------  = Resident ( %11 )
     pdt_id    - ------- "" --------  = Indirect ( %10 ) 

     - The following flags can all be set at will, but dont do that unless you know
     - why you do it ;-)

     wp            - Write Protect, the Page is write protected
     used          - Used.
     modified      - Modified.
     super         - Page is supervisor accessible only.
     upa_0 - upa_3 - Sets the user page attribute field to 0,1,2 or 3
     global        - Global.
     ur1/ur2       - Sets the User reserved bit 11 (ur1) and 12 (ur2).

     - Then we have the caching modes..

     c_wt   - Cachable, Writetrough. Sets Writetrough caching.
     c_cb   - Cachable, CopyBack. Sets Copyback caching.
     c_p    - Cache inhibit, Precise exception model.
     c_ip   - Cache inhibit, ImPrecise exception model.


 Here is a snip from the SPLITRAM.CNF file to illustrate the use of these 
"block" variables...

------------------------------- << SNIP >> ------------------------------
# Since we split the available RAM into ST/TT RAM, we need to first set up the
# block defining the ST RAM.
logical=$0
physical=$0
size=14*1024*1024
pd_flags=c_wt

# Then we set up the block that define the TT RAM. I have got a total of 40Mb in
# my Hades, and when 16Mb are gone ( 14Mb = ST ram, 2Mb lost ) we subtract that
# from the total amout of RAM available. I use 40-16=24Mb ( I WANT MORE RAM!! )
# This is the only thing you need to change in this file.
logical=$01000000
physical=$01000000
size=24*1024*1024
pd_flags=c_wt

# Then we remap the cartridge area up into ISA memory area, where it is actually
# found when you have a ROM card. TOS crash without this (access errors)
logical=$00fa0000
physical=$ff7a0000
size=128*1024
pd_flags=c_p

# Then we map the standard Atari I/O area up to where the Hades have it mapped.
logical=$00ff8700
physical=$ffff8700
size=$00ffffff-$00ff8700+1
pd_flags=c_p
------------------------------- << SNAP >> ------------------------------

 The above block definitions will build four logical address areas into 
the translation tree.


-------------------------------------------------------------------------
----------- Spliting the RAM into ST and TT-RAM on the Hades ------------

 As all Hades owners know, the Hades sees all its RAM as ST-RAM. This is 
a source of incompatibilities and problems with certain software. For 
example, the Atari hardware I/O addresses are located at addresses 
between 0x00F00000 and 0x00FFFFFF. In the Hades, this area is just 
plain RAM when all memory is seen as ST-RAM. Then it becomes evident that 
applications that thinks it is accessing hardware, infact is accessing 
plain memory. And if this memory is used by (or resided by) other 
applications, one might experience crashes due to corrupted memory. The 
Hades have it's corresponding Atari hardware compatible I/O located at 
0xFFF00000 and up. The TT also "shadows" the hardware I/O from 0x00Fxxxxx 
to 0xFFFxxxxx, so in this respect the Hades and the TT have hardware I/O 
located at the same address space.

 Now, to make the Hades as compatible with the TT as possible, we split 
the Hades RAM into ST and TT-RAM. Since the Hades use a modified version 
of the "TT-TOS" - TOS 3.06, it already supports this. SET_MMU can do this 
for you, and this is what the "split_ram" option is for. When you do 
this, SET_MMU will divide your available RAM. This is what happends;

1. First 14Mb's of RAM (0x00000000 to 0x00E00000) is set to be ST-RAM.
2. All remaining memory above 0x01000000 is set to be TT-RAM.
3. The physical RAM located at the "gap" between 0x00E00000 and 
   0x01000000 is made unavailable. This RAM "overlaps" the hardware 
   I/O area, and is 2Mb in size. This is also the exact reason why the 
   Falcon030 can only use 14Mb's of 16Mb's actually installed.

 This is accomplished by changing some system variables, and then jumping 
through the reset vector, so the changes take effect. You will notice 
this on cold-boots (when you turn on your machine, or 
ctrl+alt+shft+del) as another reset (a warm reset) as soon as set_mmu 
runs. Now, the memory between 0x00E00000 and 0x01000000 is lost, as 
described in point 3 above. In this area the Atari's original hardware 
I/O and cartridge address area resides in original Atari machines. If you 
look at the SPLITRAM.CNF file, you will see that all the Atari hardware 
I/O is remapped to where the Hades have the corresponding I/O. This means 
that if an application addresses the the soundchip, for example, at 
0x00FF8800, this access is remapped (Translated) by the PMMU so the 
access actually happens at 0xFFFF8800. This remapping is totally 
transparent to the application. You can then see that this remapped area 
"overlap" the physical RAM at this address space (0x00E00000 - 
0x01000000), so if we were to be able to use this RAM, we would have to 
remap it to a different logical address space. This is what the Milan 
does, you don't loose memory in the Milan because of this. I have tried 
remapping the physical RAM at this area to different logical areas in TT-
RAM, but I haven't succeeded. The TOS in the Hades always crash when 
attempting this. However, if you want to experiment with this, go ahead, 
and let me konw if you are in anyway successful :-)

--------------------------------------------------------------------------
-----------------------  Managing the cache..  -------------------------

 Included are several small tools to change/set caching mode.

 IMPORTANT: If using memory-protection under MiNT, NON OF THESE TOOLS CAN 
            BE USED!! This is because MiNT builds a separate translation 
            tree for each process it starts.

 The following is a description on the available tools.

 In the .\BIN\ folder you will find these folders and files;

040\
060\
RAM_CB.PRG
RAM_WT.PRG
STRAM_CB.PRG
STRAM_WT.PRG
TTRAM_CB.PRG
TTRAM_WT.PRG

 In the 040 and 060 directory you will find the programs needed for the 
relevant CPU. We'll discuss those below.

 The program-files in this directory (.\BIN\) are common to both the 040 
and 060. All these tools depend on the PMMU to be enabled. If the PMMU is 
not enabled, these tools just terminate without doing anything. What 
they do is this - They traverse the installed translation tree, address 
of which is obtained from the CPU register User Root Pointer (URP). 
When doing so, they set the caching mode corresponding to the tools 
name, i.e, CB = CopyBack and WT = WriteTrough caching. Note, however,  
that this has no effect if the caches are not turned on. This is just 
setting the cache mode, not enabling/disabling caching. There is no 
output generated by any of the tools. From this, you see that 
caching mode for each "page" of memory is set in the Translation 
Tree, and not in a specific CPU register, like on the 030. Let's look at 
each individual tool;

RAM_CB.PRG     This one walks an existing translation tree, and sets 
               Copyback caching in all page descriptors from logical 
               address 0x00000000 up to 0x40000000. It exits when it 
               reach the upper address or at the first INVALID page 
               descriptor.

RAM_WT.PRG     Same as RAM_CB.PRG, but sets Writetrough caching.

 RAM_CB.PRG and RAM_WT.PRG are the ones to use when running the Hades 
without splitting its RAM into ST/TT-RAM. These two tools cover the whole 
translation  tree (or logical address space) from address 0x00000000 to 
the 1st invalid page-descripor, or when reaching the 1GB RAM limit.

 The following are for use when splitting the Hades's RAM into ST and TT-
RAM...

STRAM_CB.PRG   This one walks the logical address space from address 
               0x00000000 to 0x00E00000 in the translation tree and sets 
               Copyback caching in the page descriptors there. This 
               means, it sets the caching mode of the ST RAM to Copyback. 
               Indended to be used when RAM is split into ST/TT RAM.

STRAM_WT.PRG   Same as STRAM_CB.PRG, but sets Writetrough caching.

TTRAM_CB.PRG   This one walks the logical address space from address 
               0x01000000 to the first invalid descriptor in the 
               translation tree, and sets Copyback caching. This means 
               that it sets Copyback caching on the TT RAM. Indended to 
               be used when RAM is split into ST/TT RAM.

TTRAM_WT.PRG   Same as TTRAM_CB.PRG, but sets Writetrough caching.
.........................................................................
 Now for the programs and tools in the 040 and 060 directories. 
Both directory has the following;

.\BIN\040\ or 060\

CACHE\
MMUDUMP\
SET_MMU\
TTR\

*** In CACHE\,
 you will find two tools, called CACHE_ON.PRG and CACHE_OF.PRG. These are 
the tools that actually turn on/off the cache. As mentioned above, 
changing caching mode have no effect until you run CACHE_ON.PRG to turn 
caching on if caches are off.

*** In MMUDUMP\,
 you find a program, MMUDUMP.TOS that dumps the current CPU status to the 
screen. If the PMMU is enabled, it will ask if you want to dumpt the 
translation tree. NOTE: Dumping the translation tree generates a LOT of 
data! If you redirect its output to disk, the dump might take some time, 
and it generates a huge file. A dump on my 40Mb Hades generates a 
whooping 5-6Mb textfile!. The more RAM you have, the larger the dump!

*** In SET_MMU\,
 you will find the main tool. This is the program you run at bootup in 
the AUTO folder to setup the translation tree. See below on how to 
install it.

NOSPLIT.CNF    Configuration file to use when not splitting RAM 

SPLITRAM.CNF   Configuration file to use when splitting RAM

SET_MMU.PRG    The main setup tool, see below for installation notes.

*** In the TTR\
 directory you will find two tools, CACHE_CB.PRG and CACHE_WT.PRG. These 
two tools can absolutely NOT be used with when the PMMU is enabled! These 
are meant to me used in the autofolder, but are now more or less useless, 
since set_mmu.prg now is supposed to run as the 1st program in the 
autofolder. If you prefer to run without the PMMU, you can use these 
tools...

CACHE_CB.PRG   This one turns off the PMMU, (and therefore can not be 
               used after set_mmu.prg has run) and sets up the TTR's 
               (Instruction/Data Transparent Translation registers) so 
               that the logical address area between 0x00000000 and 
               0x80000000 are Copyback cachable, and the area above that 
               is cache-inhibited. Intended for use when not using the 
               PMMU.

CACHE_WT.PRG   Same as cache_cb.prg, but sets Writetrough caching.


=========================================================================
===========================                  ============================
=========================     INSTALLATION     ==========================
===========================                  ============================
=========================================================================

 To install and use SET_MMU on your Hades, you do the following easy 
 steps;

 1. Copy one of the configuration files from .\BIN\0x0\SET_MMU\ to the 
    root directory of your boot partition, 'x' being either 4 or 6 
    depening on what CPU you have. If you want to use your Hades with a 
    split RAM model, you select SPLITRAM.CNF, otherwise you select 
    NOSPLIT.CNF. Then rename the copy of your chosen file to MMUSETUP.CNF.

 2. Edit MMUSETUP.CNF to suit you. To start using, or to just test it, 
    the only thing you need to edit is the size of your RAM. It is noted 
    in the file where you should make the change.

 3. Copy SET_MMU.PRG into your AUTO folder. Resort your AUTO folder so 
    that SET_MMU.PRG runs as early as possible. I myself have it running 
    right after the boot manager.

 4. You can now reboot. 


  Now you can run MMUDUMP to make sure SET_MMU has done its job. If 
everything seems fine, you can now run CACHE_ON.PRG (in .\BIN\0x0\CACHE\) 
to turn the caches on. (TOS seems to be messing with the cache settings 
while booting when the PMMU is on) Also, try running the different cach-
mode tools to get optimal speed. It should be noted that, at least on my 
Hades, plain TOS is VERY unstable when running with copy-back caching 
enabled. MiNT, on the other hand, is perfectly stable when using split 
RAM, and any caching mode works just flawlessly.

 Ofcourse, some applications do not like Copyback caching, and will 
crash. So, if you experience that a program that used to work now 
crashes, try changing cache mode to writethrough. I myself have found out 
that XCONTROL will crash everytime if I invoke it with Copyback enabled. 
I get around these "problem-apps" by using split RAM, then have my ST-RAM 
set to Writethrough, TT-RAM set to Copyback. Then I make the problem-apps 
run in ST-RAM. Quite nice :)

 If you try these tools on machines other than the Hades, you need to 
know your machine well regarding the memory mapping, what can be cached 
and what can't be cached, and so on.

-------------------------------------------------------------------------
----------------------   Hints and Tips for MiNT   ----------------------

 First of all, I would really, really recommend to use the split RAM 
 model with MiNT. At least on my Hades, splitting the RAM into ST/TT RAM 
 makes it as stable as on my TT, while I have had some strange problems 
 with all RAM being ST RAM. So, for this reason, I'll assume that split 
 RAM is being used from now on.

 If you use MiNT with MP enabled, only the CACHE_ON/OF.PRG makes any 
 sense. You can not use RAM_CB/WT.PRG, STRAM_CB/WT.PRG or TTRAM_CB/WT.PRG 
 with MP enabled, as these programs take the address out of the URP CPU 
 register. MiNT creates a new translation tree for each process, so you 
 will only end up changing the caching mode on the small tree setup by 
 MiNT for this process, which will be the tool itself. Running 
 STRAM_xx.PRG/TTRAM_xx.PRG or RAM_xx.PRG doesn't have any effect, and is 
 not dangerous, BUT DO NOT USE CACHE_WT/CB.PRG WITH MEMORY PROTECTION AS 
 THESE TURN OFF THE PMMU!! That will probably cause havoc, but I have not 
 tried it myself :)

 Now, given the fact that you can't change caching mode once MiNT starts 
 with MP enabled, and you know you have some applications that don't like 
 Copy Back, what can you do? I solve it like this;

 1. Make sure "problem apps" that don't like Copy Back caching run in ST 
    RAM.
 2. Configure the ST RAM to have Write Through caching, and TT RAM to 
    have Copy Back caching in MMUSETUP.CNF.
 3. Switching off the caches by setting cacr=$0 in MMUSETUP.CNF
 4. When booting is done, enable the caches by running CACHE_ON.PRG. You 
    can also run CACHE_ON.PRG from mint.cnf, or the AES's config file.

 Since caches are off during bootup, this will be slow until CACHE_ON is 
 run. The earliest place CACHE_ON.PRG can be run from is mint.cnf, so it 
 is a good idea to try that. If an application crash, or behaves strange, 
 try to run in in ST RAM. I know that XCONTROL v1.0 crash if run with 
 Copy Back, so this one has to be run in ST RAM. Some modules (can't 
 remember exactly which) for GemView have problems with Copy Back too. 
 These are the only two apps that I have found to be problematic with 
 Copy Back caching.



 That's all, folks. I would like to get some feedback on how this package 
 works for you. Both good and bad feedback is most welcome, and can be 
 sent to the mail address below ;-)

 Have fun.

 AssemSoft Productions

 Odd Skancke - ozk@atari.org
