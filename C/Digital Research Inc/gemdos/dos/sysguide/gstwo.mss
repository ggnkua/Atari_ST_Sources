@part(gstwo.mss,root='sysroot.mss')
@pagefooting(immediate,Left="",Right="@value[page]",odd)
@pagefooting(immediate,Left="@value[page]",Right="",even)

@chapter(Summary of BIOS Functions)

This section describes each of the GEM DOS BIOS functions.  These functions 
are described in C nomenclature.  Parameters to functions are on the stack 
following the return address, starting with the leftmost parameter.
@index(BIOS functions)
@index(Function parameters)

Function values should be returned in register D0.  The unused portion of 
register D0 should be cleared.  For example, if a function returns a word 
value, the high order 16 bits of D0 should be 0.

The following terms are used in this guide:

@begin(display)
@tabclear
@tabset(1pica,5pica)
@\BYTE@\8 bit value

@\WORD@\16 bit value

@\LONG@\32 bit value
@end(display)
@index(BYTE)
@index(WORD)
@index(LONG)

The following table summarizes the BIOS functions.

@begin(table)
@caption(BIOS function list)
@tag(biosfuncs)
@rule()
@begin(format)
@tabclear
@tabset(3pica,10pica)
@\Function@\Description
@rule()
@tabclear
@tabset(4pica,7pica)

@\00H@\Get Memory Parameter Block
@\01H@\Character Input Status
@\02H@\Character Input
@\03H@\Character Output
@\04H@\Read/Write Disk Sectors
@\05H@\Get/Set Exception Vector
@\06H@\Get Tick Information
@\07H@\Get BIOS Parameter Block
@\08H@\Character Output Status
@\09H@\Media Change
@\0AH@\Get Drive Map
@\0BH@\Get/Set Shift Keys (Console)
@\0CH@\Character Control Input
@\0DH@\Character Control Output
@\0EH@\Disk Control Input
@\0FH@\Disk Control Output
@\10H@\Character Vector Exchange
@rule()
@end(format)
@end(table)

@newpage
@string(funcname="BIOS Function 00")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 00  Get Memory Parameter Block}]
@rule()
@indexsecondary[primary='BIOS function',secondary='00  Get Memory Parameter 
Block']
@tabset(4pica,8pica)
@begin(format)

@b[C Interface:]

@\VOID@\Get_MPB(p_MPB)
@\MPB@\*p_MPB;
@\{
@\}
@end(format)
@index(Get_MPB)

@begin(description)
@b[Parameters:]@\p_MPB is a pointer to an empty memory parameter block, 
which is a data structure consisting of three LONG pointers that must be
filled in as follows:
@begin(format)
@tabset(3pica)
+$0@\Address of Memory Descriptor (or MD chain)
+$4@\0 (Reserved for GEM DOS)
+$8@\Same address as in +$0
@end(format)
@index(Memory descriptor)
@index(Memory parameter block)
@index(Memory chain)

@b[Return Values:]@\Void

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\Initializes the memory parameter block (p_MPB).
An MPB looks like this:

@begin(format)
@tabset(5 picas,10picas)
MPB
{
struct MD@\*mp_mfl;@\/* link */
struct MD@\*mp_mal;@\/*alloc'd list*/
struct MD@\*mp_rover;@\/* roving ptr*/
} ;
@end(format)
@\and a memory descriptor (MD) looks like this:

@begin(format)
@tabset(5 picas,10picas)
MD
{
struct MD@\*m_link;@\/* link */
long@\m_start;@\/* start add */
long@\m_length@\/* length */
struct PD@\*m_own;@\/*ptr to owner's 
@\@\process descr */
} ;
@end(format)

@newpage

@\This function initializes the MPB as follows:

@verbatim[
p_MPB->mp_mfl = 
             p_MPB->mp_rover = &b_mdx;
p_MPB->mp_mal = ( MD * ) 0 ;
]

@\where b_mdx is the MD which describes the original TPA.  If the original TPA 
is fragmented, b_mdx would be the root of the list of memory descriptors 
describing it.
@index(Fragmented TPA)
@index(TPA, fragmented)

@\There should be one Memory Descriptor for each contiguous block of 
available memory.  GEM DOS best utilizes one block or a few large blocks, but
little use can be made of blocks smaller than a typical program.
@end(description)

@comment(--------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 01H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 01  Character input status}]
@rule()
@indexsecondary[primary='BIOS function',secondary='01  Character input status']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_In_Stat(handle)
@\WORD@\handle;
@\{
@\}
@end(format)
@index(Char_In_Stat)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to check
@index(Device handles)
@index(Character input status)
@index(handle)

Valid device handles for this function are:
@begin(display)
PRN:  0

AUX:  1

CON:  2 
@end(display)
@end(format)

@b[Return Values:]
@\Register D0.L contains (-1) if device is ready, 
(0) otherwise.

@b[Critical Error Handling:]@\The critical error handler is not invoked.
@index(Device status)

@b[Description:]
@\Reports input device status.
@end(description)
@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 02H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 02  Character input}]
@rule()
@indexsecondary[primary='BIOS function',secondary='02  Character input']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Input(handle)
@\WORD@\handle;
@\{
@\}
@end(format)
@index(Char_Input)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to read character from

Valid device handles for this function are 0, 1, and 
2 (see Function 01).
@end(format)

@b[Return Values:]@\Register D0.L contains a character for the device 
indicated. A LONG negative return value indicates an error.
@index(Character input)

@b[Critical Error Handling:]@\The critical error handler is not invoked.
 
@b[Description:]@\Returns an indication of whether a character is ready 
to be read from the device indicated. 

@\This function returns information concerning an input character from the 
device indicated by its handle.  What is returned is a longword value 
initialized as follows:  If the handle indicates CON:, the GSX 2.0 compatible 
scan code is in the low byte of the high word.  The low byte of the low word 
contains the ASCII code for the character, or 0 if it is not an ASCII 
character.  For AUX: the low order byte of the longword contains the ASCII 
code for the character.  All other bytes of the longword not mentioned are set 
to 0.
@index(CON:)
@index(GSX 2.0)
@index(Scan code)
@index(ASCII code)
@index(AUX:)

@\@b(Note:) This function does not return until a character is available.
@end(description)
@comment(-----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 03H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 03  Character output}]
@rule()
@indexsecondary[primary='BIOS function',secondary='03  Character output']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Output(handle,char)
@\WORD@\handle,char;
@\{
@\}
@end(format)
@index(Char_Output)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to write character to

@b<char>@\character to write

Valid device handles for this function are 0, 1, and 2
(see Function 01).
@end(format)

@b[Return Values:]@\Register D0.L contains 0 if OK.
A LONG negative return value indicates an error.
@index(Character output)
@index(char)
@index(handle)

@b[Critical Error Handling:]@\The critical error handler is not invoked.
@end(description)

@begin(description)
@b[Description:]@\This function outputs the lower 8 bits of the 
character "char" to the device 
"handle".  The character may be output directly for polled output, or put in a 
queue for interrupt driven output.
@index(Polled output)
@index(Queue)
@index(Interrupt driven output)

@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 04H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 04  Read/Write disk sectors}]
@rule()
@indexsecondary[primary='BIOS function',secondary='04  Read/Write disk sectors']
@tabset(4pica,7pica,10pica)
@begin(format)

@b[C Interface:]
@index(wrtflg)
@index(buffer)
@index(count)
@index(begin)
@index(drive)

@\LONG@\Read_Write_Sectors(wrtflg,buffer,count,begin,drive)
@\WORD@\wrtflg
@\BYTE@\*buffer
@\WORD@\count
@\WORD@\begin
@\WORD@\drive
@\{
@\}
@end(format)
@index(Read_Write_Sectors)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<wrtflag>@\0:  read 
@\1:  write

@b<buffer>@\address of transfer buffer 

@b<count>@\number of sectors to transfer

@b<begin>@\sector number of first sector to transfer

@b<drive>@\drive number to access (0=A:, 1=B:, etc.)
@end(format)

@b[Return Values:]@\This function returns 0 or an error indication.
@index(Transfer buffer)
@index(Error condition)

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function performs a read or write, depending on the 
"wrtflg" parameter, to the device indicated by the drive parameter.
@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 05H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 05  Get/Set exception vector}]
@rule()
@indexsecondary[primary='BIOS function',secondary='05  Get/Set exception 
vector']
@tabset(4pica,7pica,8pica)
@begin(format)

@b[C Interface:]

@\LONG@\Get_Set_Vector(n, addr)
@\WORD@\n; 
@\LONG@\addr;
@\{
@\}
@end(format)
@index(Get_Set_Vector)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<n>@\vector number to be replaced

@b<addr>@\address of the new interrupt service routine 
@\(ISR), or -1
@end(format)

@b[Return Values:]@\Register D0.L:@\
@index(Exception vector)
@index(Interrupt service routine)
@index(addr)
@index(Get/Set vector)

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function will initialize the indicated 
interrupt vector with the address 
indicated by "addr" and return the original of the vector.  If the "addr" 
parameter is -1, no initialization is performed; only the current value of the 
vector is returned.
@index(Interrupt vectors)
@index(Extended vectors $101, $102)
@index(Vectors $00 - $FF)
@index(Critical error handler)
@index(Process termination handler)
@index(Termination)
@index(Error handler)

@\Vectors $00 - $FF are defined by the CPU and associated 
hardware.  GEM DOS defines two extended vectors:
@begin(format)
@tabclear
@tabset(3pica)
$101@\Critical Error Handler
$102@\Process Termination Handler
@end(format)
@\See Section Four for more information.
@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 06H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 06  Get tick info}]
@rule()
@indexsecondary[primary='BIOS function',secondary='06  Get tick info']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Get_Ticks()
@\{
@\}
@end(format)
@index(Timer ticks)
@index(Timer interrupt)
@index(tick)
@index(Get_Ticks)

@begin(description)
@b[Parameters:]@\None

@b[Return Values:]@\Number of milliseconds per tick.

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function returns the number of miliseconds per timer 
interrupt ("tick") to the nearest millisecond.
@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 07H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 07  Get BIOS Parameter Block}]
@rule()
@indexsecondary[primary='BIOS function',secondary='07  Get BIOS Parameter 
Block']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\BPB@\*Get_BPB(drive)
@\WORD@\drive;
@\{
@\}
@end(format)
@index[BIOS Parameter Block (BPB)]
@index(drive)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<drive>@\ 0=A:, 1=B:, etc.  
@end(format)

@b[Return Values:]@\A pointer to the BIOS Parameter 
Block (BPB) for this disk.

@b[Critical Error Handling:]@\If a physical error is encountered by the 
BIOS while attempting to determine 
the media type, use the corresponding error code from GEMERROR.H and invoke the 
critical error handler.  A minimal BIOS may simply return 0 to indicate 
failure. 
@index(Media type, determining)
@index(Minimal BIOS)
@index(GEMERROR.H)
@index(Physical error)

@b[Description:]@\If multiple media types are supported on 'drive', 
determine type of media.

@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 08H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 08  Character output status}]
@rule()
@indexsecondary[primary='BIOS function',secondary='08  Character output status']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Out_Stat(handle)
@\WORD@\handle;
@\{
@\}
@end(format)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to check 

Valid devices handles for this function are 0, 1, and 2
(see Function 01).
@end(format)
@index(Char_Out_Stat)

@b[Return Values:]@\-1 if device is ready 
@\ 0 if device is not ready

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function returns the status of the device "handle" as 
to whether it is ready for output.  It returns -1 if it is ready, otherwise it 
returns 0.
@end(description)
@index(handle)
@index(Device status)


@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 09H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 09  Media change}]
@rule()
@indexsecondary[primary='BIOS function',secondary='09  Media change']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Media_Change(drive)
@\WORD@\drive;
@\{
@\}
@end(format)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<drive>@\0=A:, 1=B:, etc.
@end(format)
@index(Media_Change)

@b[Return Values:]@\
@format<0  the media has not changed
1  the media may have changed 
2  the media has definitely changed>

@b[Critical Error Handling:]@\If a physical error is encountered by the BIOS 
while attempting to determine media change status, use the corresponding error 
code from GEMERROR.H and invoke the critical error handler. A minimal BIOS 
need not invoke the critical error handler and will possibly never return a 2.

@b[Description:]@\This function checks to see if the media has changed since 
the last access and returns the appropriate value.  The "maybe" value (1) is 
for hardware without a "drive door open" determination.
@end(description)
@index(Media change)
@index(drive)
@index(GEMERROR.H)
@index(Minimal BIOS)
@index(Physical error)
@index(Drive door open)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0AH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0A  Get drive map}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0A  Get drive map']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Get_Drive_Map()
@\{
@\}
@end(format)
@index(Get_Drive_Map)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<drive>@\0=A:, 1=B:, etc.
@end(format)

@b[Return Values:]@\a bit map of the accessible drives on 
the system  

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function returns a bit map of the accessible disk drives 
on the system.  

@\@b<Note:>  If the BIOS supports logical drives A and B on a single physical 
drive, it should return both bits set if a floppy disk is present.
    
@end(description)
@index(Drive map)
@index(Get drive map)
@index(Logical drives)
@index(Physical drives)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0BH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0B  Get/Set shift keys (console)}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0B  Get/Set shift keys 
(console)']
@tabset(4pica,7pica,8pica)
@begin(format)

@b[C Interface:]

@\LONG@\Get_Set_Shift(flag)
@\WORD@\flag;
@\{
@\}
@end(format)
@index(Get_Set_Shift)

@begin(description)
@b[Parameters:]@\The bits in 'flag' are assigned to be:
@begin(format)
@tabset(2pica,4pica)
@\0@\Right shift key
@\1@\Left shift key
@\2@\Control key
@\3@\Alt key
@\4@\Caps lock key
@end(format)

@b[Return Values:]@\The previous key states

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\The flag parameter is used to control the operation of this 
function.  If flag is not -1, it is copied into the state variable(s) for the 
Shift, Ctrl, and Alt keys and the previous key states are returned.  If flag 
is -1, then only the inquiry is done.

@end(description)
@index(Get set shift)
@index(flag)
@index(Shift key)
@index(State variables)
@index(Ctrl key)
@index(Alt key)
@index(Caps lock key)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0CH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0C  Character control input}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0C  Character control input']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Ctl_In(handle, length, buffer)
@\WORD@\handle, length;
@\BYTE@\*buffer;
@\{
@\}
@end(format)
@index(Char_Ctl_In)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to access

@b<length>@\size of input buffer

@b<buffer>@\address of buffer in which to place control 
@\string
@end(format)

@b[Return Values:]@\If less than 0, whatever error has occurred

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function reads up to the number of bytes specified by 
"length" from "handle's" control channel into "buffer". It can also be 
called with "length"= 0 to determine if the device accepts control strings.
The BIOS should return ERROR if it does not.

@\Specific control string functions are not defined.
@end(description)
@index(handle)
@index(length)
@index(buffer)
@index(Character control Input)
@index(Control string)
@index(Control channel)
@index(ERROR)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0DH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0D  Character control output}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0D  Character control 
output']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Ctl_Out(handle, length, buffer)
@\WORD@\handle, length;
@\BYTE@\*buffer;
@\{
@\}
@end(format)
@index(Char_Ctl_Out)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to access

@b<length>@\length of control string to output

@b<buffer>@\address of control string to output
@end(format)

@b[Return Values:]@\If less than 0, whatever error has occurred

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function writes the number of bytes specified by 
"length" to "handle's" control channel from "buffer".

@\Specific control string functions are not defined.

@end(description)
@index(handle)
@index(length)
@index(buffer)
@index(Character control output)
@index(Control string)
@index(Control channel)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0EH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0E  Disk control input}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0E  Disk control input']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Disk_Ctl_In(drive, length, buffer)
@\WORD@\drive, length;
@\BYTE@\*buffer;
@\{
@\}
@end(format)
@index(Disk_Ctl_In)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<drive>@\0=A:, 1=B:, etc.

@b<length>@\length of control string to output

@b<buffer>@\address of control string to buffer
@end(format)

@b[Return Values:]@\Register D0.L:@\

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function reads up to the number of bytes specified by 
"length" from "handle's" control channel into "buffer".  It can also be 
called with "length" = 0 to determine if "handle" accepts control strings.

@\Specific control string functions are not defined.

@end(description)
@index(drive)
@index(length)
@index(buffer)
@index(Control channel)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 0FH")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 0F  Disk control output}]
@rule()
@indexsecondary[primary='BIOS function',secondary='0F  Disk control output']
@tabset(4pica,7pica)
@begin(format)

@b[C Interface:]

@\LONG@\Disk_Ctl_Out(drive, length, buffer)
@\WORD@\drive, length;
@\BYTE@\*buffer;
@\{
@\}
@end(format)
@index(Disk_Ctl_Out)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<drive>@\0=A:, 1=B:, etc.

@b<length>@\length of control string

@b<buffer>@\pointer to control string
@end(format)

@b[Return Values:]@\Error code or E_OK

@b[Critical Error Handling:]@\The critical error handler must be invoked 
on error conditions.

@b[Description:]@\This function writes the number of bytes specified by 
"length" to "handle's" control channel from "buffer".  It can also be 
called with "length" = 0 to determine if the device accepts control strings.
The BIOS should return ERROR if it does not.
@index(Control string)
@index(Control channel)
@index(ERROR)
@index(handle)
@index(buffer)
@index(length)

@\The only control strings presently defined are:
@begin(format)
@tabclear()
@tabset<2 picas>
0@\No more control string information
1@\Format the drive
@end(format)
@end(description)

@comment(----------------------------------------------------------)
@newpage
@string(funcname="BIOS Function 10H")
@pageheading(Left="GEM DOS System Guide",
            Right="@value[funcname]",odd,line "@fix[@bar<>]")
@pageheading(Left="@value[funcname]",
            Right="GEM DOS System Guide",even,
            line "@fix[@bar<>]")
@process(pageheadings)
@center[@b{Function 10  Character vector exchange}]
@rule()
@indexsecondary[primary='BIOS function',secondary='10  Character vector 
exchange']
@tabset(4pica,7pica,8pica)
@begin(format)

@b[C Interface:]

@\LONG@\Char_Vec_Exchange(handle, addr)
@\WORD@\handle;
@\LONG@\addr;
@\{
@\}
@end(format)
@index(Vector exchange)
@index(Char_Vec_Exchange)

@begin(description)
@b[Parameters:]@\
@begin(format)
@tabclear()
@tabset<+.6in>
@b<handle>@\identifies device to exchange vector for 

@b<addr>@\address of vector, or -1
@end(format)

@b[Return Values:]@\New interrupt handler routines

@\Former interrupt vector

@\ERR if an error occurred (bad "handle")
@index(ERR)

@b[Critical Error Handling:]@\The critical error handler is not invoked.

@b[Description:]@\This function performs an exchange of 
the current logical interrupt vector 
for the new one indicated by "addr" for the device indicated by "handle".  If 
"addr" is -1, then only the current vector is returned (no exchange is made). 
@index(Logical interrupt vector)
@index(addr)
@index(handle)

@\Valid handle values are 0=A:, 1=B:, etc.

@\It is not strictly necessary to implement this function for 
CON: in the current release of GEM DOS.

@\Presently, this only needs to be implemented for CLOCK: and MOUSE:, although
implementing it for AUX: as well is extremely useful for communication programs.
Presently, no system component uses this for CON: or PRN:.  Handle values for 
MOUSE: and CLOCK: are now "-1" and "-2" respectively.

@\This mechanism provides a level of isolation from the physical hardware, and
allows the implementation of a logical interrupt handler for a device.
@end(description)
@index(Logical interrupt handler)
@index(CLOCK:)
@index(MOUSE:)
@index(AUX:)
@index(CON:)
@index(PRN:)
@index(Handle values)


@eos()
