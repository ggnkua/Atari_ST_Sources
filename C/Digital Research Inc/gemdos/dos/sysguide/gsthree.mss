@part(gsthree.mss,root='sysroot.mss')
@chapter<Stack Format for Invocation of Character Vector Handler>

@pageheading(Left="GEM DOS System Guide",
            Right="Stack Format",odd,line "@fix[@bar<>]")
@pageheading(Left="Stack Format",
            Right="GEM DOS System Guide",even,line "@fix[@bar<>]")
The character vector handler is a routine of the form:

@display<
VOID handler(flags,info);
LONG flags, info;
{
}>

where flags have the following meanings:
@index(Character vector handler)
@index(CON:)
@index(AUX:)
@index(PRN:)
@index(CLOCK:)
@index(MOUSE:)
@index(Error bit)
@index(State changes)

@begin<format,spread 10pts>
@tabclear()
@Tabset(3picas,7picas,9picas,13picas)

@\BIT
@\ 0@\Packet received.  If this is 1, then the LONG at sp+8 is 
@\@\defined as:

@\@\For CON:, AUX:, or PRN:

@\@\@\The LONG character info that BIOS
@\@\@\function 0x02 would have returned.

@\@\For CLOCK:

@\@\@\The number of milliseconds since the
@\@\@\last tick.

@\@\For MOUSE:

@\@\@\A pointer to a parameter block that contains

@\@\@\A BYTE of button status
@\@\@\A BYTE of delta-X
@\@\@\A BYTE of delta-Y

@\ 1@\Error

@\@\If no other error status bit is on, this is just 
@\@\an error that couldn't be described any better 
@\@\with the available defined status bits.

@\ 2@\Out of paper

@\ 3@\Off line
   
@\ 4@\Timeout
    
@\ 5@\Framing Error     

@\ 6@\Parity error

@\ 7-15@\RESERVED


If no packet was received and no error was indicated, then one of the 
following had a state change:


@\ 16@\Carrier detect
      
@\ 17@\Clear to send
     
@\ 18-31@\RESERVED


and the information received is:


@\CLOCK:@\number of milliseconds since last tick

@\MOUSE:@\pointer to a mouse packet of 3 BYTEs containing

@\@\button state
@\@\delta x
@\@\delta y

@\AUX:@\character received@end<format>
@newpage

Only register A7 must be preserved by a vector handler.

The handler must jump to the next handler in the chain (at 
the address returned by the 10H character vector exchange 
function).
@eos()
