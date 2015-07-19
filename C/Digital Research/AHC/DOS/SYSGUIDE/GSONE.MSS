@part(gsone.mss,root='sysroot.mss')
@Chapter(System Overview)
@section(File Naming Conventions)
The filename extensions used in this document identify the file type. For
instance, an extension of "C" indicates an input file to the C compiler, and
and extension of "H" is a header file to be included (#include) in a
C language source file. 
@index(File type)
@index(Filename extensions)
@index(Extension, file)
@index(Compilers)
@index(Source files)
@index(Assembly language files)
@index(C language source files)
@index(Preprocessor)
@index(Macro processing)
@index(CP68)
@index(-p switch)
@index(Header file)
@index(Object files)
@index(Source files)
@index(Alcyon compiler)
@index(Linker)

An extension of "A" indicates an assembly language file which contains 
some C preprocessor source lines to aid in documentation and macro
processing. These files pass through the C preprocessor and should invoke CP68 
with the "-p" switch.  The output from that is run through the assembler. 

Extensions of "O" indicate object files, which are output of the assembler. 
(If you use the Alcyon -- or similar -- compiler, you will note 
that the output of the second pass of the compiler is handed off to the
assembler). These files are, in turn, become input to the linker. 

Files that have "ARC" as an extension are archived libraries, which are
essentially a set of "O" files collected into a single file for processing by 
the linker. 

You may notice some files, created by the compiler, assembler, and other
tools, which have extensions of @verb[.I, .1, .2,] etc.  
These are intermediate
files created by some of these tool programs, and are usually deleted when
they are no longer needed. 
@index(Intermediate files)

@section(Building the System)

In this section we will discuss the process of compiling, linking, and
booting GEM DOS. Since the needs of the BIOS builder may be different from
those of the BDOS builder, this method may not be best for you. 
Therefore, this section is intended to be only a guide, and not a fixed set of
rules on how to build the system. 
@index(LINK)
@index(OSTOOLS)

Usually there are 4 subdirectories involved in creating the system, OSTOOLS, 
BDOS, BIOS, and LINK.

@newpage
Where these subdirectories are located (in the directory tree) is not important,
since batch files that refer to different directories do so by way of a relative
directory path, not an absolute path.  The only requirement is that they all 
reside under the same parent directory. These directories and their contents are
described below. 
@index(Batch files)
@index(Directories)
@index(Parent directory)
@index(Directory tree)
@index(Subdirectories)

@subsection[OSTOOLS Directory] 
One of the first things to do is to create the
tools archive. This is a collection of utility routines, and is
fairly stable.  It is usually not necessary to compile them more than
once.  We recommend that once the tools are compiled, they be 
collected into an archive library (with the archive utility) for linking 
to the system.  This will cut down on link time, since only one file will then 
need to be opened to access all of these routines. 
@index(Utility routines)
@index(Tools)
@index(Archive utility)

@subsection[BDOS Directory] 

This directory contains the BDOS  archive
library, the STARTUP.A file, and batch files for manipulating
them. If you decide to separate the several BDOS modules
into their respective object files, do so in this directory. 
@index(STARTUP.A)
@index(BDOS.ARC)
@index(_OSINIT)
@index(Entry point)
@index(System initialization)
@index(Link phase)

Typically, the BIOS builder need not touch the BDOS archive.  He or she 
only needs to include the BDOS.ARC file with the rest of the system during 
the link phase, making sure that the BIOS system initialization logic 
calls the _OSINIT entry point after initializing the BDOS.

BDOSMAIN is a small C language file that contains the _OSINIT entry point 
into the BDOS for initializing the BDOS, setting the supervisor stack and 
calling some banner print logic (optional).  After BDOSMAIN.C has been 
compiled, BDOSMAIN.O should be moved to the LINK directory along with the 
BDOS archive for linking in with the rest of the system.
@index(BDOSMAIN)
@index(Supervisor stack)

@newpage
@subsection[BIOS Directory] 
This is where the current BIOS source version 
should be located.  After compiling the source modules, the object files
should be copied into  the  LINK directory for linking with the BDOS
and OSTOOLS. 

@subsection[LINK Directory] 
This is where all object modules are gathered in order to be  linked
into  the system.  Currently, there are two linking methods 
depending  on  the architecture of the running system. The first
and simplest method consists of linking all  object  modules comprising the
system together into one big load module.   Care  should  be  taken with  this
method, as it is easy to have a link item name collision between the BIOS and 
the BDOS.  In fact, no label referencing should occur across the
BDOS-BIOS  boundary  at  all,  with  two exceptions. 
@index(Big load module)
@index(Link item collision)
@index(Collision, link item)

@index(Label referencing)
@index(Boundary, BIOS-BDOS)

@begin(enumerate)
The BDOS needs the label "_bufl" to be the address of the first
entry in the buffer control block (BCB) pointer array. 
See @ux(Initializing Buffer Control Blocks) later in this section.
@index[Buffer control block (BCB)]
@index(Pointer array)
@index(_buf1)

The BIOS needs to know the main entry point of the BDOS.  This can be
achieved through one of two methods, described below. 
@end(enumerate)
@index(Main entry point)
@index(ROM BIOS)
@index(BIOS in ROM)
@index(BDOS boot time)

The second method is cleaner, but  requires  more work  on  the part of the
BIOS, and is usually used in systems where the BIOS is in ROM, or already
resident  at  BDOS boot time.  This method involves: 

@begin(display)
Creating a "load file" which consists of STARTUP.O, BDOS.ARC, and 
OSTOOLS.ARC.
@index(Load file)
@index(STARTUP.O)
@index(BDOS.ARC)
@index(OSTOOLS.ARC)
@index(_OSINIT)
@index(STARTUP.O)

Instead of calling a label _OSINIT (which is in BDOS.ARC, and cannot
therefore be referenced at BIOS link time), "call" the first instruction in
STARTUP.O.
@end(display)

If the Alcyon tool set and LINK68 are being used, this can be accomplished by 
linking STARTUP.O, BDOS.ARC, and OSTOOLS.ARC. Make sure that STARTUP.O is the 
first module listed as shown below.  This will insure that _OSINIT is the first 
routine in the module.  The format of the link command should look something 
like this:
@index(LINK68)
@index(Alcyon tool set)

@verbatim(
   BDOS.LD[options]=STARTUP.O,OSTOOLS.ARC,BDOS.ARC
)

When the resulting module is loaded,  the OS initialization step 
will go to the _OSINIT entry point in the STARTUP.O
file.  Since the BIOS loaded the BDOS, it knows where that is. 

@section(Booting the System)
Getting the system to boot is, of course, dependent on the  particular 
hardware and firmware  involved.  The system must be stored in a 
special  area  of  the disk for the Boot ROM Firmware to find it.  Sometimes
the load module format is not compatible with  the  format the  booter 
expects  it  to be in.  In this case, the format of the system load module
has to be modified before writing it on the boot disk. 
@index(Firmware)
@index(Boot ROM)
@index(Load module format)
@index(Disk, special area)
@index(Booter)

Systems at Digital Research employ a two stage  load,  whereby  the firmware 
loads a secondary booter.  This booter knows how to deal with GEM DOS file
systems, and  looks  for the  file  GEMDOS.SYS  on  the  specified (or
default) drive.  This is  possible after  a  file system  has  been created  on
one  of the attached disks, but how does one create the initial file system? 
@index(Two-stage load)
@index(Secondary booter)
@index(Booter, secondary)
@index(GEMDOS.SYS)
@index(Initial file system)
@index(Hierarchical file system)
@index(IBM PC)

Since GEM DOS uses a hierarchical file system,  it  is usually  not 
inconvenient for the OEM to use a IBM PC (or similar system) to format and
create  the  initial file system on a floppy. 

To get the  module  which  is  to  be  loaded  by  the firmware  onto  the
boot disk usually requires special software which is to be provided  by  the 
OEM.   This software  places  the  module  (either the system load module or
the secondary booter) onto the disk  in  the proper  location  and format. 
This software will have to run under the initial host system  
until a stable enough GEM DOS system exists. 
@index(System load module)
@index(Secondary booter)
@index(Booter, secondary)
@index(Host system)

@section(BIOS Boot Time Initialization)
How the BIOS gains control at boot time is dependent
on the boot environment (see @ux[Booting the System] above).
@index(Boot environment)

@subsection[Entry point] 
Whether a primary or secondary  booter is used to load the system, it will
probably just transfer control to the first  code  segment  in  the first
module.  This will be the first module specified in the link statement.  Note 
that the  program header produced by the linker does not contain an entry
point address,  and  assumes that the entry point is at the front of the load
module. 
@index(Primary booter)
@index(Secondary booter)
@index(Program header)
@index(Load module)
@index(Privilege mode)
@index(Supervisor mode)
@index(BDOS initialization)
@index(Interrupts)
@index(Hardware initialization)
@index(Initialization, hardware)
@index(68010 instructions)

@subsection[Privileged mode] 
When the BIOS calls the BDOS initialization routine, it must be in supervisor 
mode. This enables us to disable interrupts and to perform hardware 
initialization  while the machine
is in a quiescent state. See the following listing for sample code. 
@verbatim<
@rule()
@comment[
*  Get into supervisor mode.  This mechanism must be
*  compatible for both booting from scratch (in which 
*  case we're already in supervisor mode) as well as 
*  entering GEMDOS from some other host system (in 
*  which case we might not be in supervisor mode)
*  and it must not violate 68010 supervisor mode-only
*  instructions.]

_main:
	movem.l d0-d7/a0-a7,regsav
        move.l  #supmode, $b4  * revector trap #13
        trap    #13

supmode:
*                             *  in supervisor mode
	move    #$2700,sr     *  disable interrupts
        movem.l regsav,d0-d7/a0-a7

        and.b   #$fc,$f19f05 * mask timer/dma ints
        move.b  #$10,$f19f09 * reset the keyboard
        clr.b   $f19f0b      * disable VME bus ints
        move.b  #$80,$f19f11 * allow SCM MPU ints

*
* catch unassigned user interrupts
*
	move.l  SAVECT,-(a7) * save abort vector

        move.l  #$100,a0     * start @1st uservec
        move.l  #BadInt,a1 * move int handler
resintr:
	move.l  a1,(a0)+     * set newvect/bump ptr
        cmp.l   #$400,a0     * check upper bounds
        blt     resintr

        move.l  (a7)+,SAVECT * restore abort vector

*
* clear  bss
*
	move.l  #bssstrt,a0
clrmor:
	clr.w   (a0)+
        cmp.l   #$14000,a0
        bne     clrmor
>
@rule()

Listing 1.  Privilege Mode, Interrupt Vector Init, and BSS Init.


@subsection(How command parameters are passed to the BIOS)
Within the BDOS (which always runs in Supervisor mode) the interface to the 
BIOS is similar to the following C function call for a 1 parameter function:
@index(BIOS interface)
@index(Interface, BIOS)

@verbatim[
  long_ret = bios(function_number, parameter_1);
]

When the location '_bios' is reached, the supervisor stack will look like 
this:

@verbatim(
	   |       ...      |
	   +----------------+
	   |  parameter_1   |+6
	   +----------------+
	   |function_number |+4
	   +----------------+
	   | return_address |+0  Top of stack
	   +----------------+
)

@newpage
The '_bios' routine, in assembly language, is typically of the form 

@verbatim[
	_bios:
		move.1  (sp)+,return_save
		trap     #13
		move.1	 return_save,-(sp)
]

which, for a single tasking system is an adequate calling interface.

Since the BDOS is executing in supervisor mode, when control reaches the BIOS 
entry point the stack frame will look like this:
@index(Stack frame)

@verbatim[
	   |        ...      |
	   +-----------------+
	   |    parameter_1  |
	   +-----------------+
	   | function_number |
	   +-----------------+  
	   | processor class |  
	   | dependent size  |  
  	   |  TRAP overhead  |  
	   +-----------------+  
]

Six or more bytes of TRAP overhead are required (at least the program counter 
and status register).  On the 68010, 68020, and 68070, it will be more.
@index(TRAP overhead)
@index(68010)
@index(68020)
@index(68070)
@index(Program counter)
@index(Status register)
@index(Front end, BIOS)

The BIOS front end should check the Status Register value in the stack to 
insure that the processor was in Supervisor mode (if it was not, the 
parameters will not be on the Supervisor stack).  It can then pass the 
parameters on the stack (or pass a pointer to the parameters) to the BIOS 
routine indicated by 'function_number'.
@index(BIOS front end)
@index(Pointer)

@subsection[Interrupt vectors] 
Make sure all interrupt vectors are assigned. 
Even those  that  the BIOS doesn't use, or that the BDOS will use should be
assigned to  a  null  ISR.   The BDOS  will  reassign  it's own vectors
during it's initialization phase. 
@index(Interrupt vectors)
@index(Null ISR)
@index[Interrupt Service Routine (ISR)]
@index(BDOS vectors)

A spurious interrupt should not halt the  system. Something like this
might not even need to be reported.  But  a  stray  interrupt that  repeats, 
however  infrequently,  needs to be reported. When a new system is being
brought up, it is not surprising to find that some of the hardware has not
been properly  initialized,  and rapidly  repeating  spurious
interrupts occur.  This by itself will halt the system.  So it might  be  a
good  idea  to include some logic to recognize this condition and halt the
system with a message  indicating what has happened.  
@index(Interrupts, spurious)
@index(Interrupts, repeating)
@index(Initialization, hardware)
@index(Error message)

@subsection[Block storage segment (BSS) area] 
The start of BSS can be
determined by referencing  the label  of the first item in the BSS area passed
to the linker.  (This area of the BDOS @u[must] be cleared.) 
The surest way of  determining  this,  is  to create  an
assembler module (typically called BIOSA.A) and label  the  first  item  in 
the  BSS as 'BSSSTART'.   If  this  assembler  module  is the first module to
be linked into  the  system,  then  BSSSTART will  be the address of the first
byte of the BSS area for the system. 
@index[Block Storage Segment (BSS)]
@index(BSSSTART)
@index[Transient Program Area (TPA)]
@index(Initializing the TPA)

@subsection[Initialize Transient Program Area (TPA)] 
The TPA can be either statically or dynamically determined at BIOS 
initialization time.  The TPA must be determined so that  the  BDOS 
knows  how  much memory  is available for programs and allocatable user 
space.  (It is a good idea to clear this  area also.)  The BDOS will make
sure that any memory allocated from the TPA is properly  initialized,  but 
it's usually  a  good  idea to make sure parity is properly set on usable
memory, and this can be done by  writing to  memory  with  a  write only 
instruction (one that doesn't read before write). 
@index(Write-only instruction)
@index(Instruction, write-only)

Some machines, however, don't have this problem,  and  on  some systems, it
is preferable to leave memory intact.  This is why this logic is left to  the
BIOS, and not in the BDOS. 

Listing 2 contains some sample code for a very  simple
method of determining TPA size and clearing it.

@verbatim<
@rule()
tpastart      = $E000
tpalength     = $30000 - tpastart
	move.l  8,a0          * save old bus errvec
        move.l  #bus_error,$8 * put in temp handler
        move.l  sp,a1         * save the current SP
	
	move.l  #TPASTART,m_start * set def values
	move.l  #TPALENGTH,m_length * for int mem

        move.w  #0,$180000    * have memory here?
        move.l  #$180000,m_start * yes, update MPB
        move.l  #$40000,m_length * and len(256K)

        move.w  #0,$1C0000 * mem at 2nd 256K bndry?
        move.l  #$80000,m_length * yes, assume 512K

        move.w  #0,$200000 * mem at 3rd 256K bndry?
        move.l  #$C0000,m_length * yes, assume 3/4M

bus_error:
	move.l  a0,$8   * restore old bus errvec
        move.l  a1,sp   * and old stack pointer

        move.l  m_start,a0  * clear TPA
        move.l  m_length,d0 * get byte count
        lsr.l   #1,d0    * make word count
        subq.l  #1,d0   * pre-decrement/DBRA use
        clr.w   d1       * handy zero
parity_loop:
	move.w  d1,(a0)+    * clear word
        dbra    d0,parity_loop
>
@rule()

@center(Listing 2. Clearing the TPA)
@index(TPA, clearing)


@subsection[Initializing Buffer Control Blocks (BCBs)] 
The BCBs and buffer areas used by the
BDOS  file  system for caching special disk data must also be initialized by
the BIOS, since it is up to the BIOS  builder  to  decide  how  many buffers
are to be dedicated to each type of cache. 
@index(Initializing BCBs)
@index(Buffer)
@index(Caching)
@index[File Allocation Table (FAT)]

There are two types of buffers  available;  the  first one  is  used for
caching file allocation table (FAT) records.  The second is used for caching
both  directory  and data  records. Sample code for initializing these
structures is given in Listing 3 and Listing 4. 

@newpage
@verbatim<
/*
**  defines index into cache buffers for different
**  types of data
*/

#define B_FAT          0  /* fat buffer list */
#define B_ROOT         1  /* rootdir bufflist */
#define B_DIR          1  /* other dir bufflist */
#define B_DAT          1  /* data buffer list */

/*
**  secbuf -  sector buffers
*/

char secbuf[4][512];

/*
**  bcbx - Buffer Control Block array
*/

BCB bcbx[4];     /* bcb for each buffer */

/*
**  bufl - buffer lists
**      two lists:  fat / dir,data
*/

BCB *bufl[2];
>
@rule()

@center(Listing 3.  Data and Constant Definitions for BIOS Init Code)

@verbatim<
@rule()

/*
**  cmain - called to initialize buffer structures,
**  init bdos, load & go cli
*/

cmain()
{
	long    l;

        /* set up sector buffers */
        bcbx[0].b_link = &bcbx[1];
        bcbx[2].b_link = &bcbx[3];

        /*
        **  invalidate BCBs
        */

        bcbx[0].b_bufdrv = -1;
        bcbx[1].b_bufdrv = -1;
        bcbx[2].b_bufdrv = -1;
        bcbx[3].b_bufdrv = -1;

        /*
        **  initialize buffer pointers in BCBs
        */

	bcbx[0].b_bufr = &secbuf[0][0];
        bcbx[1].b_bufr = &secbuf[1][0];
        bcbx[2].b_bufr = &secbuf[2][0];
        bcbx[3].b_bufr = &secbuf[3][0];

        /*
        **  initialize the buffer list pointers
        */

        bufl[B_FAT] = &bcbx[0]; /* fat buffers */
        bufl[B_DAT] = &bcbx[2]; /* dir/dat bufs */

          :
          :
}
>
@rule()

@center(Listing 4.  BIOS System Init Code)


@subsection[Initialize BDOS] 
Call  _OSINIT to  allow  the  BDOS  to 
initialize itself.   This is either done by obtaining the address of
_OSINIT at  link  time,  or  by  ensuring  that BDOSMAIN.O is the first
module in the BDOS load module and calling the first address  in  that  module
after loading the BDOS. 
@index(_OSINIT)
@index(BDOSMAIN.O)
@index(TRAP1)
@index(0x0E)

Using a TRAP1, call BDOS  function  0x0E  to  set  the default  drive  used by
the file system.   Assuming the BIOS contains a C interface to the TRAP1 call, 
the syntax would be 

@begin(verbatim)
trap1( 0x0E , drive ) ;
@end(verbatim)

An example TRAP1 routine is in Listing 6.

@b[Note:] This must be done @u(after) the  BDOS  has  been
initialized. Listing 5 contains a useful example.

@subsection[Command line interpreter] Again using a TRAP1, call BDOS
function 0x4B  to  exec the command  line interpreter (CLI). The name of the 
command interpreter is not important. COMMAND.PRG is the one supplied by  DRI. 
Whatever  CLI you use, it's name should be a parameter to the EXEC call.
@index(0x4B)
@index[Command Line Interpreter (CLI)]
@index(COMMAND.PRG)
@index(EXEC)

The  function call is:
@begin(verbatim)
trap1( 0x4B , 0 , CLIPATH , TAIL , ENV ) ;
@end(verbatim)
@index(CLIPATH)
@index(TAIL)
@index(ENV)

where 0 is the subfunction, CLIPATH is the directory path 
specification for the program file for the
CLI,  TAIL is the null terminated command tail for the CLI , 
and ENV is is a pointer to 
the  environment  strings. If there are no arguments required for the CLI,
and/or if there are no environment strings to  be  passed  to it,  these 
pointers  should point to NULL strings (as opposed to being NULL pointers). 

The standard CLI, COMMAND.PRG, needs no tail  and the
single environment string. If you experience difficulty loading COMMAND.PRG, 
display a message and halt (a PANIC routine).
@index(PANIC)

The following listing contains an example of code for loading the CLI.

@newpage
@verbatim<

/*
**  useful macros to make these calls easier
*/

#define SETDRV(a)       trap_1( 0x0e , a )
#define EXEC(a,b,c,d)   trap_1( 0x4b , a,b,c,d )

/*
**  env - string used to load in shell
*/

#ifndef DEFDRV
#define DEFDRV  0       /* 0 = A:, 2 = C: */
#endif

#if     DEFDRV == 0
char env[] = "COMSPEC=A:COMMAND.PRG ";
#endif


#if     DEFDRV == 2
char env[] = "COMSPEC=C:COMMAND.PRG ";
#endif


/*
**  defdrv - indicator for default drive number
**      0 = a:, 2 = c:
*/

int     defdrv = DEFDRV ;

	:
        :
        :

        osinit();
        SETDRV(defdrv);
        l = EXEC(0,"COMMAND.PRG","",env);
        BPrStr("*** cmain: xexec returns %lx ",l) ;

        :
        :
>
@rule()

@center(Listing 5. Set Default Drive and Exec Command Interpreter)

@verbatim<
@rule()

*
* trap_1 - trap one entry point
*

	.code
_trap_1:
	move.l  (sp)+,t1regsav  * save return addr
        trap    #1              * call bdos call
        move.l  t1regsav,-(sp)  * restore ret addr
        	rts

                .data
t1regsav:       .ds.l   1               *  M01.01.01


>
@rule()

@center(Listing 6.  Example TRAP1 routine.)


@eos()
