#APP
|
| scsicmd.s - Copyright Steve Woodford, August 1993.
| SCSI Device Access functions. 32/16 bit ints.
|
| This code supports only the ST(E)s ACSI port. Support for Falcon and
| TT would be nice, but as I dont have one of those....
|
|
| Declare entry points and exported variables...
|
            .globl  __Scsi_Timeout
            .globl  __Scsi_Command
            .globl  __Scsi_Read_Bytes
            .globl  __Scsi_Dma_Len
|
            .text
            .even
|
|
|*****************************************************************************
|
|   short   _Scsi_Timeout(secs)
|           short   secs;
|
| Modify the timeout value to use for the next SCSI command.
|
__Scsi_Timeout:
            movew   Lscsi_timeout,d0
            extl    d0
#ifdef	__MSHORT__
            movew   sp@(4),Lscsi_timeout
#else
            movew   sp@(6),Lscsi_timeout
#endif
            rts
|
|
|*****************************************************************************
|
|   short   _Scsi_Command(rw, cmd_buf, transfer_addr, length)
|           int          rw;
|           Scsi_Cmd    *cmd_buf;
|           void        *transfer_addr;
|           int          sectors;
|
| This function is used when to issue a SCSI command to a target.
| The function returns the SCSI targets completion code, or -1 if timeout.
| Note that "transfer_addr" must be on a word boundary.
|
__Scsi_Command:
#ifdef	__MSHORT__
            movew   sp@(4),rw_flag      | Save read/write flag
            movel   sp@(6),cmd_buff     | Save command buffer pointer
            movel   sp@(10),d1          | Get transfer address
#else
            movew   sp@(6),rw_flag      | Save read/write flag
            movel   sp@(8),cmd_buff     | Save command buffer pointer
            movel   sp@(12),d1          | Get transfer address
#endif
            bne     Lgood_addr          | Jump if Ok
            movel   #sec_buff,d1
Lgood_addr:
            movel   d1,tr_addr          | Save transfer address
#ifdef	__MSHORT__
            movew   sp@(14),d0          | Get transfer length
#else
            movew   sp@(18),d0          | Get transfer length
#endif
            bgt     Ldma_sect           | Jump if transferring sectors
            moveql  #1,d0               | Transfer only 1 
Ldma_sect:
            movew   d0,tr_length        | Save sector count
            movew   #0xffff,comp_code   | Assume error!
            clrw    keep_flock          | Ensure "flock" cleared on exit
            st      reset_dma           | Ensure DMA reset
            moveml  d1-d2/a2,sp@-       | Save bdos trashed registers
|
| Following code added to be compatible with Mint. Previously, xbios SUPERX
| was used, which doesnt work under Mint <sigh>.
|
            link    a6,#0
            clrl    sp@-
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            movel   d0,sp@-
            jbsr    Lscsi_command
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            unlk    a6
|
|
            moveml  sp@+,d1-d2/a2       | Restore regs
            movel   tr_addr,d0          | Get final DMA address
            subl    d1,d0               | Compute length of transfer
            moveql  #9,d1
            lsrl    d1,d0               | Compute in dma sectors
            movew   d0,__Scsi_Dma_Len   | Save it
            movew   comp_code,d0        | Fetch completion code
            extl    d0
            rts
|
Lscsi_command:
            st      0x43e:w             | Set "flock"
            lea     0x8604:w,a0         | DMA Controller Data Register
            lea     0x8606:w,a1         | DMA Status/Control Register
            movel   cmd_buff,a2         | Get pointer to command buffer
            moveql  #0,d2               | d2 == 0 for read, else 0x0100
            moveql  #1,d1
            cmpw    rw_flag,d1
            bne     Lrc_nowr
            movew   #0x0100,d2          | Flag "write"
Lrc_nowr:
            movel   0x4ba:w,d0          | 200Hz counter
            addql   #4,d0               | Got to wait about 1/50th second
Lrc_delay:
            cmpl    0x4ba:w,d0          | Delay over?
            bcc     Lrc_delay           | Back if not
            tstw    reset_dma           | Reset DMA stuff?
            beq     Lrc_no_reset        | Jump if not
            movel   tr_addr,sp@-        | Stack transfer address
            moveb   sp@(3),a1@(7)
            moveb   sp@(2),a1@(5)
            moveb   sp@(1),a1@(3)
            addqw   #4,sp
            movew   #0x0098,d0
            movew   d0,a1@              | Toggle Read/Write
            movew   #0x0198,a1@
            movew   d0,a1@
            orw     d2,d0               | Include "write" bit in DMA code
            movew   d0,a1@              | Store it
            movew   tr_length,a0@       | Store sector count
Lrc_no_reset:
            movew   #0x0088,d0          | Prime for Acsi command code
            orw     d2,d0               | Include write bit
            movew   d0,a1@
            clrw    d0
            moveb   a2@+,d0             | Fetch SCSI command code
            swap    d0
            movew   #0x008a,d0          | Prepare to send command code
            orw     d2,d0               | Include write bit
            movel   d0,a0@              | Send it
            bsr     Lreq_wait1          | Wait for interrupt
            bmi     Lrc_end             | Abort if timeout
            swap    d0
            moveb   a2@+,d0             | Command byte 1
            swap    d0
            movel   d0,a0@              | Store it
            bsr     Lreq_wait1          | Wait for interrupt
            bmi     Lrc_end             | Abort if timeout
            swap    d0
            moveb   a2@+,d0             | Command byte 2
            swap    d0
            movel   d0,a0@              | Store it
            bsr     Lreq_wait1          | Wait for interrupt
            bmi     Lrc_end             | Abort if timeout
            swap    d0
            moveb   a2@+,d0             | Command byte 3
            swap    d0
            movel   d0,a0@              | Store it
            bsr     Lreq_wait1          | Wait for interrupt
            bmi     Lrc_end             | Abort if timeout
            swap    d0
            moveb   a2@+,d0             | Command byte 4
            swap    d0
            movel   d0,a0@              | Store it
            bsr     Lreq_wait1          | Wait for interrupt
            bmi     Lrc_end             | Abort if timeout
            moveb   a2@+,d0             | Command byte 5
            swap    d0
            movew   d2,d0               | Initiate command
            movel   d0,a0@              | Store it
|
| Target should now be transferring over DMA bus
|
            movew   Lscsi_timeout,d2    | Max # of seconds to wait
Lrc_wait:
            movel   #200,d1             | 1 second delay
            bsr     Lreq_wait2          | Wait for command complete
            bpl     Lrc_ok              | Jump if Ok
            dbra    d2,Lrc_wait         | Back if not
|
| Lets do all we can to reset Scsi bus...
|
            movew   #0x008a,a1@
            nop
            tstw    a0@
            nop
            movew   #0x0098,a1@
            movew   #0x0198,a1@
            movew   #0x0098,a1@
            nop
            movew   #0x008a,a1@
            bra     Lrc_end
Lrc_ok:
            clrl    sp@-                | Make a slot on the stack
            moveb   a1@(7),sp@(3)       | Fetch final DMA address
            moveb   a1@(5),sp@(2)
            moveb   a1@(3),sp@(1)
            movel   sp@+,tr_addr        | Store it
            movew   #0x008a,a1@         | Prepare to fetch completion code
            nop
            movew   a0@,d0              | Get it
            andw    #0x00ff,d0          | Only want low 8 bits
            movew   d0,comp_code        | Store it
Lrc_end:
            movew   #0x0080,a1@         | Reset DMA
            nop
            tstw    a0@                 | Clear DMA completion code
            tstw    keep_flock          | Should we clear "flock"?
            bne     Lrc_exit            | Jump if not
Lclr_flock:
            clrw    0x43e:w             | Clear "flock"
Lrc_exit:
            rts
|
|
Lreq_wait1:
            moveql  #10,d1              | 50mS timeout
Lreq_wait2:
            addl    0x4ba:w,d1          | Used to compute timeout
Lreq_wait3:
            btst    #5,0xfa01:w
            beq     Lreq_done
            cmpl    0x4ba:w,d1          | Timed out?
            bcc     Lreq_wait3          | Jump if not
Lreq_done:
            rts
|
|
|*****************************************************************************
|
|   short   _Scsi_Read_Bytes( cmd_buf, transfer_addr, length )
|           Scsi_Cmd    *cmd_buf;
|           void        *transfer_addr;
|           short        bytes;
|
| This function is used to issue a SCSI command which transfers less
| than 512 bytes of data. This is a pain in the ST as the DMA chip buffers
| 8 bytes internally, so we may have to issue the command several times
| to get the full response we require. Either way, we use a temporary
| buffer so as not to overrun the users buffer.
|
__Scsi_Read_Bytes:
            movel   sp@(4),cmd_buff     | Save command buffer pointer
            movel   #sec_buff,tr_addr   | Use sector buffer for transfer
            movew   #1,tr_length        | 1 sector, max, to transfer
            st      reset_dma           | Signal "reset DMA"
            st      keep_flock          | Keep hold of "flock"
            clrw    rw_flag             | Read only
            movew   #16,ss_retry        | # of retries
Lss_get:
            movew   #0xffff,comp_code   | Assume error!
            subqw   #1,ss_retry
            bmi     Lss_done
            moveml  d2/a2,sp@-          | Save bdos trashed registers
|
| Following code added to be compatible with Mint. Previously, xbios SUPERX
| was used, which doesnt work under Mint <sigh>.
|
            link    a6,#0
            clrl    sp@-
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            movel   d0,sp@-
            jbsr    Lscsi_command
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            unlk    a6
|
|
            moveml  sp@+,d2/a2          | Restore regs
            clrw    reset_dma           | No more DMA resets, for now
            tstw    comp_code           | Timeout?
            bmi     Lss_done            | Yes!
            movel   tr_addr,d0          | Get current DMA address
            subl    #sec_buff,d0        | d0 == # of bytes transferred
#ifdef	__MSHORT__
            cmpw    sp@(12),d0          | Got all we want?
#else
            cmpw    sp@(14),d0          | Got all we want?
#endif
            blt     Lss_get             | Nope. Try again!
Lss_done:
            movel   sp@(8),a1           | Get dest. buffer address
#ifdef	__MSHORT__
            movew   sp@(12),d1          | Get # of bytes required
#else
            movew   sp@(14),d1          | Get # of bytes required
#endif
            cmpw    d0,d1               | Get minimum
            bge     Lss_gt
            movew   d1,d0
Lss_gt:
            lea     sec_buff,a0
            bra     Lss_enter
Lss_cloop:
            moveb   a0@+,a1@+           | Copy accross
Lss_enter:
            dbra    d0,Lss_cloop
            moveml  d2/a2,sp@-
|
| Following code added to be compatible with Mint. Previously, xbios SUPERX
| was used, which doesnt work under Mint <sigh>.
|
            link    a6,#0
            clrl    sp@-
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            movel   d0,sp@-
            jbsr    Lclr_flock
            movew   #0x20,sp@-
            trap    #1
            addqw   #6,sp
            unlk    a6
|
|
            moveml  sp@+,d2/a2
            movew   comp_code,d0        | Fetch completion code
            extl    d0
            rts
|
|*****************************************************************************
|
            .data
            .even
Lscsi_timeout:
            .word   10                  | Default to 10 second timeout
|
.comm       __Scsi_Dma_Len,2            | DMA blocks transferred goes here
|
.lcomm      cmd_buff,4
.lcomm      tr_addr,4
.lcomm      tr_length,2
.lcomm      rw_flag,2
.lcomm      comp_code,2
.lcomm      reset_dma,2
.lcomm      ss_retry,2
.lcomm      keep_flock,2
.lcomm      sec_buff,512
