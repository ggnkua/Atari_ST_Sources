*********************************************************************** 
*                COMPUTE!s Atari ST Disk & Magazine                   *
*                 February 1987 - Volume 2, No. 1                     *
*                                                                     *
*                        EXTENDED FORMATTER                           *
*                        By Richard Smereka                           *
*                                                                     *                                                                     *                  
*                 ½ 1987 COMPUTE! Publications/ABC                    *                                                      *
*                                                                     *
* Note that this program can be executed from ST-SHELL,               * 
* COMPUTE!'s Atari ST Disk and Magazine, DEC. 1986, Vol. 1 No. 2,     *
* or installed as a TTP application and executed from the desktop.    *                                                *
* The syntax from ST-SHELL is:                                        *
*                                                                     *                                                                 
*                          FORMAT D T [E]                             *
*                                                                     *                                                                 
* Where 'd' is the drive identifier (A or B), 't' is the disk type    *
* ('s' for single side or 'd' for double side), and the 'e' optional  *
* parameter will do an extended format (83 tracks, and 10 sectors per *
* track).                                                             *
*                                                                     *                                                                 
*                                                                     *                                                                 
* The syntax from the program as a TTP application is:                *
*                                                                     *                                                                 
*                                                                     *                                                                 
*                            d t [e]                                  *
*                                                                     *                                                                 
* Where the names are the same as described for execution under       *
* ST-SHELL.                                                           *
*                                                                     *                                                                 
***********************************************************************
*                       Program Equates                               *
***********************************************************************
 
gemdos          equ     1
xbios           equ     14
conin           equ     1
conout          equ     2
mshrink         equ     $4a
malloc          equ     $48
mfree           equ     $49
prtline         equ     9
conout          equ     2
term            equ     0
flopfmt         equ     10
protobt         equ     18
flopwr          equ     9

********************************************************************
*                              Main Body                           *
********************************************************************

*******************************
* Shrink Size of Program Area *
*******************************

start           move.l  a7,a5           save user SP
                move.l  #unstk,a7
                move.l  4(a5),a5        get base page address
                move.l  $c(a5),d0
                add.l   $14(a5),d0
                add.l   $1c(a5),d0
                add.l   #$100,d0        allocate 1K of user stack space
                move.l  d0,-(sp)
                move.l  a5,-(sp)
                move    d0,-(sp)        
                move    #mshrink,-(sp)  function MSHRINK
                trap    #gemdos
                add.l   #12,sp
                lea.l   129(a5),a0      pointer to command string

*******************************
* Check for Null Command Line *
*******************************

                cmpi.b  #31,(a0)        nothing in command line?
                bhi     okparm          no, continue
                addq.b  #1,optflag      force usage string to print
                bra     exit            exit program

**********************
* Parse Command Line *
**********************

okparm          bsr     ispace          remove leading spaces (1st para.)
                bsr     optpar          parse 1st parameter
                sub.b   #65,d2          make into drive number
                cmpi.b  #1,d2           d2 > 1?
                bgt     driverr         yes, error in drive spec.
                cmpi.b  #0,d2           d2 < 0?           
                blt     driverr         yes, error in drive spec.
                ext.w   d2              extend d2 to a word
                move.w  d2,drivespec    save drive spec.
                bra     twoparm         drive spec. ok, continue

driverr         movea.l #derr,a2        address of drive error message
                bsr     pline
                bsr     newline
                addq.b  #1,optflag      indicate error
                bra     exit            exit program

twoparm         bsr     ispace          remove leading spaces (2nd para.)
                bsr     optpar          parse 2nd parameter
                cmpi.b  #'S',d2         single side format requested?
                bne     tdouble         no, test for double
                addq.w  #1,sideno       indicate 1 side
                bra     checkex
tdouble         cmpi.b  #'D',d2         double side format requested?
                beq     okd             yes, continue
                movea.l #siderr,a2      address of side error
                bsr     pline
                bsr     newline
                addq.b  #1,optflag      indicate error
                bra     exit            exit program
okd             addq.w  #2,sideno
checkex         adda    #1,a0           point to next character
                cmpi.b  #31,(a0)        anything more in command line?
                bls     pintro          no, continue
                bsr     ispace          remove space(s)
                bsr     optpar          get character
                cmpi.b  #'E',d2         extended format requested?
                beq     exok            yes, continue
                movea.l #unopt,a2       unidentified option error
                bsr     pline
                bsr     newline
                addq.b  #1,optflag      indicate usage error
                bra     exit
exok            addq.w  #3,maxtrk       maximum track to 83
                addq.w  #1,secptrk      at 10 sectors per track
  
************************
* Print Intro. Message *
************************

pintro          movea.l #intro,a2
                bsr     pline
                bsr     newline
                bsr     newline

***************************
* Wait for Operator Ready *
***************************

                movea.l #keyw,a2        address of wait string
                bsr     pline
                move.w  #conin,-(sp)
                trap    #gemdos
                addq.l  #2,sp
                bsr     newline

**************************
* Print Standby Message *
**************************

                movea.l #standmsg,a2    address of standby message
                bsr     pline
                bsr     newline

************************************
* Allocate Memory for Track Buffer *
************************************

                move.l  #20000,-(sp)    20000 bytes to allocate
                move.w  #malloc,-(sp)   function MALLOC
                trap    #gemdos
                addq.l  #6,sp

                move.l  d0,buffer       save pointer to buffer
                cmpi.l  #0,d0           pointer=zero?
                bne     okmem
                movea.l #tmemerr,a2     address of memory error string
                bsr     pline
                addq.b  #1,endflag      indicate error
                bsr     newline
                bra     exit

*******************
* Format the Disk *
*******************

okmem             move.w  sideno,d4
                  move.w  #0,d5         disk side to format
                  bsr     dformat       do format
                  cmpi.b  #0,endflag    soft error?
                  bne     rel           yes, exit program
                  sub.w   #1,d4         decrement number of sides
                  beq     fill          if zero, continue
                  move.w  #1,d5         format side 1
                  bsr     dformat

**************************
* Fill Buffer With Zeros *
**************************

fill            move.l  #0,d2           counter
                movea.l buffer,a5       address of buffer
zloop           move.l  #0,(a5)+        zero out long word
                addq.l  #1,d2
                cmpi.l  #5000,d2        reached end?
                bne     zloop

**********************************
* Write Zero to First Two Tracks *
**********************************

                move.w  #9,d2           nine sectors
                move.w  #0,d3           on track zero
                move.w  #1,d4           start on sector one
                bsr     writes
                cmpi.b  #0,endflag      error?
                bne     rel             yes, deallocate and exit 

                move.w  #9,d2           nine tracks
                move.w  #1,d3           on track one
                move.w  #1,d4           start on sector one
                bsr     writes

*****************************
* Prototype New Boot Sector *
*****************************

okmem2          bsr     proto

*************************
* Write New Boot Sector *
*************************

                move.w  #1,d2           write one sector
                move.w  #0,d3           track zero
                move.w  #1,d4           sector one
                bsr     writes
                

******************
* Release Buffer *
******************

rel             bsr     release
         
************************************************************************
*                              Exit Program                            *
************************************************************************

*****************************************
* If Usage Error, Display Program Usage *
*****************************************

exit            cmpi.b  #0,optflag      usage error?
                beq     final           no, exit program
                movea.l #usage,a2       address of usage string
                bsr     pline
                bsr     newline
                bra     exitmsg
final           cmpi.b  #0,endflag      soft failure?
                beq     terminate       no, normal exit
exitmsg         movea.l #ttpmsg,a2      address of exit message
                bsr     pline           print it
                move.w  #conin,-(sp)    wait for a key before exit
                trap    #gemdos
                addq.l  #2,sp

terminate       move.w  #term,-(sp)     function PTERM0
                trap    #gemdos
                .page
************************************************************************
*                            Program Subroutines                       *
************************************************************************

************************************************************************
*               Subroutine to Ignore Spaces in the Command Line        *
************************************************************************

ispace          cmpi.b  #32,(a0)        current byte=space?
                bne     idone           no, exit routine
                adda    #1,a0           point to next byte
                bra     ispace          do comparison again
idone           rts

***********************************************************************
*               Subroutine to Parse Command Line for Options          *
***********************************************************************

*************************************
* Convert to Uppercase if Necessary *
*************************************

optpar          cmpi.b  #'a',(a0)       < 'a'?
                bcs     noconv          yes, bypass
                cmpi.b  #'z',(a0)       > 'z'?
                bhi     noconv          yes, bypass
                sub.b   #32,(a0)        make to upper case

noconv          move.b  (a0)+,d2        place result in d2
                rts

********************************************************************
*               Subroutine to Release Allocated Memory             *
********************************************************************

release           move.l  buffer,-(sp)  address of data buffer
                  move.w  #mfree,-(sp)  function MFREE
                  trap    #gemdos
                  addq.l  #6,sp
                  rts

********************************************************************
*               Subroutine to Format the Disk                      *
********************************************************************

dformat         move.w  #0,d6            set track counter to zero
fagain          move.w  #$e5e5,-(sp)     initial value of a sector
                move.l  #$87654321,-(sp) magic value for format
                move.w  #1,-(sp)         interleave factor
                move.w  d5,-(sp)         side of disk to format
                move.w  d6,-(sp)         track number
                move.w  secptrk,-(sp)    sectors per track
                move.w  drivespec,-(sp)  drive number
                clr.l   -(sp)            junk long word
                move.l  buffer,-(sp)     track data buffer
                move.w  #flopfmt,-(sp)   function FLOPFMT
                trap    #xbios
                add.l   #26,sp
                tst     d0              test for return code
                beq     fok             if zero, operation ok

                movea.l #fail1,a2
                bsr     pline
                add.w   #65,d5          side of disk to ASCII
                move.w  d5,-(sp)
                move.w  #conout,-(sp)   print disk side
                trap    #gemdos
                addq.l  #4,sp
                movea.l #fail2,a2
                bsr     pline
                addq.b  #1,endflag      indicate error
                bra     newline

fok             addq.w  #1,d6           increment track counter
                cmp.w   maxtrk,d6       done all tracks?
                bne     fagain          no, go again
                rts

***********************************************************************
*               Subroutine to Prototype a New Boot Sector             *
***********************************************************************

proto           move.w  #0,-(sp)        nonexecutable boot sector
                move.w  sideno,d4
                addq.w  #1,d4
                move.w  d4,-(sp)        2=SS, 3=DS
                move.l  #$01000000,-(sp) random disk serial number
                move.l  buffer,-(sp)
                move.w  #protobt,-(sp)  function PROTOBT
                trap    #xbios
                add.l   #14,sp

                cmpi.w  #83,maxtrk      extended format?
                bne     noex            no, exit routine
                movea.l buffer,a5       address of boot sector
                adda    #19,a5          offset to number of sectors
                cmpi.w  #1,sideno       SS format?
                bne     dods            no, do DS
                move.b  exssls,(a5)+    indicate 830 sectors on disk
                move.b  exssms,(a5)+
                bra     rewrite
dods            move.b  exdsls,(a5)+    indicate 1660 sectors on disk
                move.b  exdsms,(a5)+

*********************************************
* If Extended Format, Recalculate Checksum  *
*********************************************

rewrite         adda    #3,a5           point to number of sectors per track
                move.b  #10,(a5)+       indicate 10 sectors per track
                move.b  #0,(a5)
                move.w  #-1,-(sp)       executable flag stays the same
                move.w  #-1,-(sp)       disk type stays the same
                move.l  #-1,-(sp)       serial number stays the same
                move.l  buffer,-(sp)    address of buffer
                move.w  #protobt,-(sp)
                trap    #xbios
                add.l   #14,sp
noex            rts

**********************************************************************
*                  Subroutine to Write Sector(s)                     *
**********************************************************************

writes          move.w  d2,-(sp)        sector count
                move.w  #0,-(sp)        on side zero
                move.w  d3,-(sp)        track
                move.w  d4,-(sp)        first sector
                move.w  drivespec,-(sp) drive number
                clr.l   -(sp)           junk long word
                move.l  buffer,-(sp)    sector buffer address
                move.w  #flopwr,-(sp)   function FLOPWR
                trap    #xbios
                add.l   #20,sp

                tst     d0              check for success of write
                beq     okwr
                movea.l #werr,a2
                bsr     pline
                addq.l  #1,endflag
                bra     newline
okwr            rts
     
*******************************************
* Early Entrance to Pline to Print CR/LF  *
*******************************************

newline         movea.l #crlf,a2

************************************************************************
*              Subroutine to Print a String of Text on Screen          *
************************************************************************

pline           move.l  a2,-(sp)        address of string on stack
                move.w  #prtline,-(sp)  function print line
                trap    #gemdos
                addq.l  #6,sp
                rts
                .page
************************************************************************
*                               Program Data                           *
************************************************************************

drivespec       .ds.w   1               drive spec. (0 or 1)
sideno          .dc.w   0               number of sides to format
maxtrk          .dc.w   80              maximum number of tracks
secptrk         .dc.w   9               sectors per track
exssls          .dc.b   62              extended SS total sectors on disk
exssms          .dc.b   3
exdsls          .dc.b   124             extended DS total sectors on disk
exdsms          .dc.b   6
optflag         .dc.b   0               error flag
endflag         .dc.b   0               end flag
intro           .dc.b   "EXTENDED FORMATTER ",0
keyw            .dc.b   "Insert disk to be formatted",$0A,$0D
                .dc.b   "and press any key when ready.",0
derr            .dc.b   "ERROR: Invalid drive specification",0
siderr          .dc.b   "ERROR: Invalid disk type specified",0
unopt           .dc.b   "ERROR: Unidentified option used",0
werr            .dc.b   "ERROR: Occurred while writing boot sector",0
tmemerr         .dc.b   "ERROR: Not enough memory available to format",0
readerr         .dc.b   "ERROR: Can't read boot sector",0
fail1           .dc.b   "ERROR: Attempt to format on side ",0
fail2           .dc.b   " failed...format terminated",0
usage           .dc.b   "Proper usage is: FORMAT drive side(s) [e]",0
ttpmsg          .dc.b   "Press any key to exit Extended Formatter",0
standmsg        .dc.b   "Please stand by...format is in progress",0
crlf            .dc.b   13,10,0         CR/LF
buffer          .ds.l   1               pointer to track buffer
                .bss
                .even
                .ds.l   256
unstk           .ds.l   1
                .end

