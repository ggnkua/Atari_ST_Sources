 ; Program Name: PRG_2DP.S
 ; Version 1.004

 ; Assembly Instructions:

 ;    Assemble in PC-relative mode and save with a TOS extension.

 ; Execution Note:

 ;    This program invokes custom traps which must be installed by
 ; TRAPS.PRG and TRAP_10.PRG prior to its execution.  Execute this program
 ; by typing its name on SPEEDTST.TTP's command line.

 ;    But before executing this program, prepare three floppy disks.  The
 ; first should be formatted from the desktop, using the ST formatting
 ; algorithm.  The second should be formatted with a version of DCFORMAT,
 ; available from ST Informer, 909 NW Starlite Place, Grants Pass, OR 97526,
 ; (503)476-0071 on disk PDM 188 or PDM 1288.  The price of each disk from
 ; ST Informer is $6.00 for non-subscribers.  You can subscribe for $18.00
 ; per year and get a free disk coupon.  I highly recommend a subscription.

 ;    The third disk should be formatted with Dave Small and Dan Moore's
 ; Twister program available on START magazine's Summer, 1988 issue.  You
 ; can find an order form in any issue of START or phone (800)234-7001.

 ;    Copy PRG_2DP.TOS to each blank disk.  Copy SPEEDTST.TTP to each disk.
 ; Execute SPEEDTST.TTP on each disk in turn, typing PRG_2DP.TOS on its
 ; command line.  Compare the contents of the WRITE_1 and WRITE_2 files of
 ; each disk to verify that they are identical.  Compare the PRG_2DP.DAT file
 ; on each disk to the others. 

 ; Program Function:

 ;    This program writes data to WRITE_1.DAT, reads WRITE_1.DAT, then
 ; writes what it has read to WRITE_2.DAT to confirm that it has correctly
 ; written and read the data declared within the data section of the program.

 ;    SPEEDTST.TTP will report the load and total execution time for this
 ; program.

 ;    Within the program, the time to write the data to WRITE_1.DAT will be
 ; calculated and reported; and the time to read the data from WRITE_1.DAT
 ; will also be calculated and reported; finally, the time to write the data
 ; to WRITE_2.DAT will be calculated and reported.

 ;    This program is to be used to compare the write to and read from times
 ; involving three floppy disks, each of which has been formatted with a
 ; different formatting algorithm.

fetch_load_time:              
 trap       #3                  ; Returns value of system clock in D0.
release_excess_memory:          ; Also stores after-load time in TRAPS bss.
 lea        program_end, a0     ; Put "end of program" address in A0.
 movea.l    4(a7), a1           ; Put "basepage" address in A1.
 trap       #6                  ; Calculate program size and release memory.
 lea        stack, a7

print_heading:
 lea        heading, a0
 bsr        print_string

fetch_write_start_time:
 trap       #3
 lea        write_start_time, a0
 move.w     d0, (a0)
create_file_1:
 move.w     #0, -(sp)           ; File attribute = read/write.
 pea        file_1_name         ; For WRITE_1.DAT.
 move.w     #$3C, -(sp)         ; Function = f_create = GEMDOS $3C.
 trap       #1                  ; File handle is returned in D0.
 addq.l     #8, sp
 lea        file_1_handle, a0   ; Store returned file handle.
 move.w     d0, (a0)

write_to_file_1:
 pea        string               ; Push address of buffer.
 move.l     #451, -(sp)          ; Number of bytes to write.
 move.w     d0, -(sp)            ; File handle to be written to.
 move.w     #$40, -(sp)          ; GEMDOS function =  write.
 trap       #1
 lea        $C(sp), sp           ; Reposition stack pointer to top of stack.
close_file_1:                    
 move.w     file_1_handle, -(sp) 
 move.w     #$3E, -(sp)          ; Function = GEMDOS $3E = f_close.
 trap       #1
 addq.l     #4, sp
get_end_time:
 trap       #3
 sub.w      write_start_time, d0 ; Subtract start time from end time.
 ext.l      d0                   ; Extend to 32 bits
 trap       #10                  ; Convert to milliseconds and print.

set_dta:
 pea        dta                  ; dta = address of 44 byte buffer.
 move.w     #$1A, -(sp)          ; GEMDOS function = set dta.
 trap       #1
 addq.l     #6, sp
print_read_time_label:
 lea        read_msg, a0
 bsr        print_string
fetch_read_start_time:
 trap       #3
 lea        read_start_time, a0
 move.w     d0, (a0)

 ; NOTE: Reading is so fast, must loop to accumulate enough time to measure.

 move.w     #99, d3              ; Set up counter for 100 loops.
search_for_file: 
 move.w     #0, -(sp)            ; Attribute = normal access.
 pea        file_1_name          ; Name of file to search for.
 move.w     #$4E, -(sp)          ; GEMDOS function = search first.
 trap       #1
 addq.l     #8, sp
 tst        d0
 bne.s      not_found

read_WRITE_1_DAT:
 lea        dta, a0
 pea        buffer
 move.l     $1A(a0), -(sp)       ; Number of bytes to read.
 move.w     file_1_handle, -(sp) ; File to read.
 move.w     #$3F, -(sp)          ; GEMDOS function = read.
 trap       #1
 lea        $C(sp), sp           ; Reposition stack pointer.
 dbra       d3, search_for_file
_get_end_time:
 trap       #3
 sub.w      read_start_time, d0  ; Subtract start time from end time.
 ext.l      d0                   ; Extend to 32 bits
 trap       #10                  ; Convert to milliseconds and print.

print_write_time_label:
 lea        write_msg, a0
 bsr        print_string
_fetch_write_start_time:
 trap       #3
 lea        write_start_time, a0
 move.w     d0, (a0)
create_file_2:
 move.w     #0, -(sp)            ; File attribute = read/write.
 pea        file_2_name          ; For WRITE_2.DAT.
 move.w     #$3C, -(sp)          ; Function = f_create = GEMDOS $3C.
 trap       #1                   ; File handle is returned in D0.
 addq.l     #8, sp
 lea        file_2_handle, a0    ; Store returned file handle.
 move.w     d0, (a0)
write_to_file_2:
 lea        dta, a0
 pea        string               ; Push address of buffer.
 move.l     $1A(a0), -(sp)       ; Number of bytes to write.
 move.w     d0, -(sp)            ; File handle to be written to.
 move.w     #$40, -(sp)          ; GEMDOS function =  write.
 trap       #1
 lea        $C(sp), sp           ; Reposition stack pointer to top of stack.
close_file_2:        
 move.w     file_2_handle, -(sp) 
 move.w     #$3E, -(sp)          ; Function = GEMDOS $3E = f_close.
 trap       #1
 addq.l     #4, sp
_get__end_time:
 trap       #3
 sub.w      write_start_time, d0 ; Subtract start time from end time.
 ext.l      d0                   ; Extend to 32 bits
 trap       #10                  ; Convert to milliseconds and print.

not_found:
 trap       #8                   ; Terminate.

print_string:
 pea        (a0)
 move.w     #9, -(sp)
 trap       #1
 addq.l     #6, sp
 rts

 data
file_1_name: dc.b 'WRITE_1.DAT',0     
file_2_name: dc.b 'WRITE_2.DAT',0
heading:     dc.b 'PRG_2DP.TOS Execution Results',$D,$A,$D,$A
             dc.b '  Time to create, write and close WRITE_1.DAT:   ',0
read_msg     dc.b '  Time to read WRITE_1.DAT into buffer 10 times: ',0 
write_msg:   dc.b '  Time to create, write and close WRITE_2.DAT:   ',0 
string:      dc.b '  This paragraph will be written to a disk file named '
             dc.b 'WRITE_1.DAT.  The time ',$D,$A
             dc.b '  required to write the paragraph will be reported in '
             dc.b 'file PRG_2DP.DAT.',$D,$A
             dc.b '  Then the contents of WRITE_1.DAT will be read into a '
             dc.b 'buffer.  The time ',$D,$A
             dc.b '  required to read the contents of the file will be '
             dc.b 'reported in file ',$D,$A
             dc.b '  PRG_2DP.DAT.  Finally, the contents of the buffer '
             dc.b 'will be written to ',$D,$A
             dc.b '  WRITE_2.DAT so that what has been read can be compared '
             dc.b 'to what was written.',$D,$A,$1A

 ; NOTE: The ASCII code for ^Z (control Z) is normally used to mark the end
 ;       of a file so that a program reading the file may look for that mark.

 bss
 align
file_1_handle:    ds.w   1
file_2_handle:    ds.w   1
write_start_time: ds.w   1
read_start_time:  ds.w   1
dta:              ds.b  44
buffer:           ds.b 452
                  ds.l  96
stack:            ds.l   0
program_end:      ds.l   0
 end
