;
;                  Atari Command Line Interface
;             by Jeffrey R. Wilson for STart Magazine
;                  (c) 1987, All rights reserved
;
; A multi-function desk accessory for Atari ST computers
;
; Assemble using the MetaComCO Macro Assembler
;

          TTL       'CLI.ASM'

          INCLUDE   'MACROS.CLI'        ;include CLI macros


START     LEA       stack,SP            ;switch to our local stack
          appl_init                     ;initialize the program for GEM
          MOVE.W    intout,apid         ;record our identification #
          menu_register apid,#ACC_NAME  ;install our name in the list

DA_LOOP   evnt_mesag #MSGBUF            ;wait for a message to come to us
          CMPI.W    #40,MSGBUF          ;is it an 'open desk accessory' message?
          BNE.S     DA_LOOP             ; -no, keep waiting

          malloc    #33000              ; -yes, allocate a screen buffer
          TST.L     D0                  ;was memory allocated?
          BEQ.S     1$                  ; -no, report the lack for memory
          BPL.S     2$                  ; -yes, continue with the open

     1$:  form_alert #1,#MEM_ERROR      ;no memory for a screen
          BRA       DA_LOOP             ;display error and loop

     2$:  hide_mouse                    ;hide the mouse cursor
          MOVE.L    D0,MEM_ADDR         ;save the address of our block
          MOVE.L    D0,A0
          MOVE.W    #8250,D1            ;prepare to clear the CLI screen

     3$:  CLR.L     (A0)+               ;clear the CLI screen
          DBRA      D1,3$

          ADDI.L    #512,D0             ;make sure the base address we use
          ANDI.L    #$FFFFFF00,D0       ; is a multiple of 256
          MOVE.L    D0,CLI_SCREEN       ;record the CLI screen base address

          physbase                      ;get the actual screen physical base
          MOVE.L    D0,PHYSBASE
          logbase                       ;get the actual screen logical base
          MOVE.L    D0,LOGBASE
          setscreen CLI_SCREEN,CLI_SCREEN,#-1     ;change to the CLI screen

          open      #prompt_path,#0     ;read in default prompt
          TST       D0
          BMI.S     4$                  ; if one exists...
          MOVE.W    D0,-(SP)
          read      D0,#80,#prompt
          MOVE.W    #$3E,-(SP)          ;(close)
          TRAP      #1
          ADDQ.L    #4,SP

     4$:  BSR       cli_version    ;show startup information

          sfirst    #autorun,#$07  ;is there an autorun batch file?
          TST.L     D0
          BNE.S     top            ; no, continue normally

          LEA       autobat,A0     ; yes, execute the batch file
          MOVE.W    autocount,D1
          BSR       batch

top       BSR       show_prompt    ;output prompt
          LEA       cmdline,A0     ;get input
          BSR       instr

          TST       D0             ;do nothing on no input
          BEQ.S     top
          BSR       LOOKUP
          BRA.S     top            ;otherwise, execute the command

;
; Utility Routines
;

;
; Look for the command word in the command table, and execute the command
;

LOOKUP    MOVE.W    D0,-(SP)       ;save string length

          LEA       command,A0     ;prepare for case convert, lookup
          LEA       table,A1
          MOVE.B    #' ',0(A0,D0.W)
          MOVEQ     #0,D0

convert   MOVE.B    0(A0,D0.W),D1  ;convert case, if necessary
          CMP.B     #' ',D1
          BEQ.S     2$
          CMP.B     #$61,D1
          BLT.S     1$
          SUB.B     #$20,D1
          MOVE.B    D1,0(A0,D0.W)

     1$:  ADDQ.W    #1,D0
          BRA.S     convert
     2$:  MOVEQ     #0,D0

lookup    MOVE.B    0(A0,D0.W),D1  ;lookup command
          CMP.B     0(A1),D1
          BEQ.S     2$             ;character match!!
          TST.B     0(A1)
          BEQ.S     external       ;no command matches found
     1$:  ADDQ.L    #8,A1
          BRA.S     lookup
     2$:  ADDQ.L    #1,D0          ;scan for command match
          MOVE.B    0(A0,D0.W),D1
          CMP.B     #' ',D1
          BEQ.S     match
          TST.B     0(A1,D0.W)
          BEQ.S     3$
          CMP.B     0(A1,D0.W),D1
          BNE       3$
          CMP.B     #3,D0
          BEQ.S     match
          BRA.S     2$
     3$:  MOVEQ     #0,D0          ;match not found - continue search
          BRA.S     1$

;
; Internal command match found -- execute routine
;

match     ADDQ.L    #4,A1          ;match found
          MOVE.L    (A1),A1
          MOVEQ     #0,D0

     1$:  MOVE.B    0(A0,D0.W),D1  ;set up command line pointer
          CMP.B     #' ',D1
          BEQ.S     2$
          ADDQ.W    #1,D0
          BRA.S     1$

     2$:  ADDQ.W    #1,D0
          MOVE.W    (SP)+,D1       ;execute routine
          SUB.W     D0,D1
          BPL.S     3$             ;when execution begins, parameters
          MOVEQ     #0,D1          ;are passed in the following registers:
     3$:  ADD.L     D0,A0          ;  D1 = number of bytes in command tail
          MOVE.B    #0,0(A0,D1.W)  ;  A0 = command tail pointer
          JMP       (A1)           ;  A1 = routine address

;
; Execute an external command
;

external  MOVE.W    (SP)+,D0       ;pull length off stack
          LEA       cmd_buffer,A1  ;prepare for exec process

     1$:  MOVE.B    (A0)+,D0       ;construct the command
          CMP.B     #' ',D0
          BEQ.S     2$
          MOVE.B    D0,(A1)+
          BRA.S     1$

     2$:  LEA       cmd_ext,A2     ;append .PRG extension

     3$:  MOVE.B    (A2)+,(A1)+
          BNE.S     3$

          exec      #0,#cmd_buffer,A0,#0        ;execute the external command

          TST       D0             ;command found, executed
          BNE.S     4$             ;an error of some type was encountered
          RTS

     4$:  LEA       unknown,A0     ;command not found, show error
          BRA.S     lineout

error_out conout    #7             ;output a bell to signify an error
          RTS

;
; Read a string in from the current input device
;

instr     CLR.L     -(SP)               ;save a long space on the stack
          MOVE.L    (A0)+,-(SP)         ;move length of input buffer on the stack
          MOVE.L    A0,4(SP)            ;put address of buffer in long space
          MOVE.W    device_in,-(SP)     ;read from the current device
          MOVE.W    #$3F,-(SP)          ;(read)
          TRAP      #1                  ;GEMDOS
          ADD.L     #12,SP
          TST       D0                  ;was an error encountered?
          BMI.S     error_out           ; -yes, ring the bell
          RTS                           ; -no, return

;
; Output a single character to the current output device
;

otchar    MOVE.B    D0,buffer           ;move the character to the output buffer
otchar1   MOVE.L    #buffer,-(SP)       ;character address
          MOVE.L    #1,-(SP)            ;only 1 character
          MOVE.W    device_out,-(SP)    ;write to current output device
          MOVE.W    #$40,-(SP)          ;(write)
          TRAP      #1                  ;GEMDOS
          LEA       12(SP),SP
          TST       D0                  ;was an error encountered?
          BMI.S     error_out           ; -yes, ring the bell
          RTS                           ; -no, return

;
; Output a null-terminated line to the current output device
;

lineout   MOVEQ     #0,D0               ;maintain a character output count in D0
     1$:  MOVE.B    (A0)+,buffer        ;move the first character to the buffer
          BEQ.S     2$                  ; done, exit
          MOVEM.L   D0/A0,-(SP)
          BSR.S     otchar1             ;output the character
          MOVEM.L   (SP)+,D0/A0
          ADDQ.L    #1,D0               ;increment the counter
          BRA.S     1$                  ;loop until done
     2$:  RTS

;
; Get a single character from the current input device
;

inchar    MOVE.L    #buffer,-(SP)       ;read into I/O buffer
          MOVE.L    #1,-(SP)            ;only read one character
          MOVE.W    device_in,-(SP)     ;from the current input device
          MOVE.W    #$3F,-(SP)          ;(read)
          TRAP      #1                  ;GEMDOS
          ADD.L     #12,SP
          TST       D0                  ;was an error encountered?
          BEQ.S     1$                  ; -no, return
          BMI       error_out           ; -yes, display an error messaage
          MOVE.B    buffer,D0
     1$:  RTS

;
; Show the prompt on the screen
;

show_prompt   
          MOVEM.L   D1-D2/A1-A2,-(SP)
          MOVE.W    device_out,-(SP)    ;redirect output to screen
          MOVE.W    #1,device_out

          LEA       prompt_set,A0       ;output prompt set string
          BSR       lineout
          LEA       prompt,A1           ;scan through prompt string

     1$:  MOVE.B    (A1)+,buffer        ;output normal characters
          BEQ       11$                 ; and scan for functions
          CMP.B     #'#',buffer         ;command of some type?
          BEQ.S     2$                  ; -yes, do function display
          BSR       otchar1             ;output the character
          BRA.S     1$

     2$:  MOVE.B    (A1)+,D0       ;find function
          CMP.B     #'P',D0        ;show prefix
          BEQ.S     4$
          CMP.B     #'F',D0        ;line feed
          BEQ.S     6$
          CMP.B     #'T',D0        ;show time
          BEQ.S     7$
          CMP.B     #'S',D0        ;show date
          BEQ       9$
          CMP.B     #'#',D0        ;show hash-mark
          BEQ       10$

          MOVE.B    D0,-(SP)       ;VT52 command of some sort
          MOVE.B    #$1B,buffer    ;output the escape
          BSR       otchar1
          MOVE.B    (SP)+,buffer   ;output the character
          BSR       otchar1
          BRA.S     1$             ;loop for the next character

     4$:  getdrv                   ;show prefix
          MOVE.W    D0,-(SP)
          ADD.W     #'A',D0        ;show the currently active drive
          BSR       otchar

          MOVE.B    #':',buffer    ;show the colon
          BSR       otchar1

          ADDQ.W    #1,(SP)
          MOVE.L    #work_buf,-(SP)
          MOVE.W    #$47,-(SP)
          TRAP      #1             ;get the directory for this drive
          ADDQ.L    #8,SP
          LEA       work_buf,A2

     5$:  MOVE.B    (A2)+,buffer   ;show it on the screen
          BEQ       1$
          BSR       otchar1
          BRA.S     5$

     6$:  MOVE.B    #10,buffer     ;line feed
          BSR       otchar1
          BRA       1$

     7$:  gettime                  ;show time
          MOVE.W    D0,D1
          BSR       showtime
          BRA       1$

     9$:  getdate                  ;show date
          MOVE.W    D0,D1
          BSR       showdate
          BRA       1$

    10$:  BSR       otchar         ;show hash-mark
          BRA       1$

    11$:  MOVE.W    (SP)+,device_out    ;restore redirection
          MOVEM.L   (SP)+,D1-D2/A1-A2
          RTS

showtime
    15$:  MOVE.W    D1,-(SP)       ;display hour
          LSR.W     #8,D1
          LSR.W     #3,D1
          BSR       WTDEC2D
          MOVE.B    #':',buffer
          BSR       otchar1

          MOVE.W    (SP)+,D1       ;display minute
          LSR.W     #5,D1
          AND.W     #$3F,D1
          BRA       WTDEC2D

showdate  MOVE.W    D1,-(SP)       ;display month
          LSR.W     #5,D1
          AND.W     #$0F,D1
          BSR       WTDEC2D
          MOVE.B    #'/',buffer
          BSR       otchar1

          MOVE.W    (SP),D1        ;display day
          AND.W     #$1F,D1
          BSR       WTDEC2D
          MOVE.B    #'/',buffer
          BSR       otchar1

          MOVE.W    (SP)+,D1       ;display year
          LSR.W     #8,D1
          LSR.W     #1,D1
          AND.W     #$7F,D1
          ADD.W     #80,D1
          BRA       WTDEC2D

gen_error LEA       generic,A0     ;generic error message
          BRA       lineout

;
; Construct a complete path to the file(s) specified on the command line
;

getpath   MOVE.L    A0,A1               ;get the paths from a wildcard
          LEA       work_buf,A2         ; or regular path template
          MOVE.L    A2,A3
     1$:  MOVE.B    (A1)+,D0            ;parse out the portion of the name not
          BEQ.S     3$                  ; containing any wildcard parameters
          CMP.B     #' ',D0
          BEQ.S     3$
          MOVE.B    D0,(A2)+
          CMP.B     #':',D0
          BEQ.S     2$
          CMP.B     #'\',D0
          BEQ.S     2$
          BRA.S     1$

     2$:  MOVE.L    A2,A3               ;save a pointer to the end of the parsed line
          BRA.S     1$

     3$:  sfirst    A0,#7               ;get the first match
          TST.L     D0
          BEQ.S     makefn
          LEA       nofiles,A0          ;output an error message if nothing
          BSR       lineout             ; matches the template on the command line
          MOVE.W    #1,CCR              ;set the carry for a no more files return
          RTS

makefn    getdta                        ;construct the complete path
          MOVE.L    D0,A0
          LEA       name(A0),A0
          MOVE.L    A3,A1               ;copy the sfirst match to the end of
     5$:  MOVE.B    (A0)+,(A1)+         ; the pathname as previously entered
          BNE.S     5$
          LEA       work_buf,A0
          TST       D0                  ;clear the carry for a valid return
          RTS

;
; Find the next pathname that matches the specifications
;

nextpath  snext                         ;get the next matching pathname
          TST.L     D0
          BEQ.S     makefn              ;construct the name if one exists
          MOVE.W    #1,CCR              ;else return a carry set
          RTS

;
;  segment name : WTDECL - write a long decimal # to the screen
;    IN:  D1.L = number to convert and display
;    OUT: D1.W = number of characters sent to the screen
;
WTDECL    MOVEM.L   D2-D3/A2,-(SP) ;save the registers
          MOVEQ     #0,D2          ;clear the offset
          CLR.L     -(SP)          ;clear the count & flag -- (SP)
          LEA       BIGNUMTBL(PC),A2    ;get the big number table

WTDECL1   MOVE.L    0(A2,D2.W),D3  ;are we at the end of the table?
          BEQ.S     WTDECL5        ; yes, go to WTDEC
          MOVEQ     #'0',D0        ; no, set the number to ASCII zero

WTDECL2   CMP.L     D3,D1          ;is the # bigger than the next big #?
          BCS.S     WTDECL3        ; yes (BLO)
          SUB.L     D3,D1          ; no, subtract off this number
          ADDQ.W    #1,D0          ;increment the number
          SNE.B     3(SP)          ;set the flag (always done)
          BRA.S     WTDECL2        ; loop for more

WTDECL3   TST.B     3(SP)          ;is the flag set?
          BEQ.S     WTDECL4        ; no, don't put the digit
          BSR       otchar         ; yes, put the digit
          ADDQ.W    #1,(SP)        ;increment the count

WTDECL4   ADDQ.W    #4,D2          ;increment the pointer
          BRA.S     WTDECL1        ;loop for more

WTDECL5   MOVEQ     #2,D2          ;skip the 10,000s
          BRA.S     WTDEC0

BIGNUMTBL DC.L      1000000000
          DC.L      100000000
          DC.L      10000000
          DC.L      1000000
          DC.L      100000
          DC.L      10000
          DC.L      0

;
; segment name: WTDEC2D
;   output 2 decimal digits with no zero suppression
;
WTDEC2D   MOVEM.L   D2-D3/A2,-(SP)
          MOVE.L    #$000000FF,-(SP)
          MOVEQ     #6,D2
          BRA       WTDEC0

;
; segment name: WTDEC
;  display a word value as a decimal number, up to 650,000
;
;  same conventions as in WTDECL, above
;
WTDEC     MOVEM.L   D2-D3/A2,-(SP) ;save registers
          CLR.L     -(SP)          ;clear the flag/count on the stack
          MOVEQ     #0,D2          ;clear the offset

WTDEC0    LEA       LITNUMTBL(PC),A2    ;get the little number table

WTDEC1    MOVEQ     #'0',D0        ;set the number to ASCII zero
          MOVE.W    0(A2,D2.W),D3  ;are we at the end of the table?
          BEQ.S     WTDEC5         ; yes, end

WTDEC2    CMP.W     D3,D1          ;is the # bigger than the next big #?
          BCS.S     WTDEC3         ; yes (BLO)
          SUB.W     D3,D1          ; no, subtract off this number
          ADDQ.W    #1,D0          ;increment the count
          SNE.B     3(SP)          ;set the flag (always done)
          BRA.S     WTDEC2         ;loop for more

WTDEC3    TST.B     3(SP)          ;is the flag set?
          BEQ.S     WTDEC4         ; no, don't put the digit
          BSR       otchar         ; yes, put the digit
          ADDQ.W    #1,(SP)        ;increment the count

WTDEC4    ADDQ.W    #2,D2          ;increment the pointer
          BRA.S     WTDEC1         ;loop for more

WTDEC5    TST.B     3(SP)          ;did we put anything out?
          BNE.S     WTDEC6         ; yes
          JSR       otchar         ; no, output a single '0'
          ADDQ.W    #1,(SP)        ;count the character

WTDEC6    MOVE.W    (SP)+,D1       ;get the count
          ADDQ.L    #2,SP          ;clear the flag
          MOVEM.L   (SP)+,D2-D3/A2 ;restore the registers
          RTS
          
LITNUMTBL DC.W      10000
          DC.W      1000
          DC.W      100
          DC.W      10
          DC.W      1
          DC.W      0

;
; Check for a keypress or cancel
;

stopchk   constat                  ;check keyboard status
          TST       D0
          BNE.S     1$             ;no keys are waiting, return
          RTS                      ;       with 0 in D0

     1$:  coninwoe                 ;get the waiting character
          SWAP      D0
          CMP.W     #$61,D0        ;UNDO - return with 61 in D0
          BNE.S     2$
          RTS

     2$:  constat                  ;pause until a key is pressed
          TST       D0
          BEQ.S     2$
          coninwoe
          SWAP      D0
          CMP.W     #$61,D0        ;UNDO - return with 61 in D0
          BEQ.S     3$
          MOVEQ     #0,D0          ;CONTINUE - return with a 0 in D0
     3$:  RTS

;
; CLI command line routines
;

;
; Exit the CLI -- recycle the Desk Accessory for next time
;

exit      MOVE.L    (SP)+,D0                 ;pull the return address
          setscreen LOGBASE,PHYSBASE,#-1     ;restore the screen
          mfree     MEM_ADDR                 ;free the CLI screen memory

          aline_init               ;show the mouse pointer
          MOVE.W    #1,INTIN(A0)   ;(if at the appropriate level)
          MOVE.L    CONTRL(A0),A0
          CLR.W     2(A0)
          MOVE.W    #1,6(A0)
          show_mouse
          cursconf  #0,#0          ;disable the normal cursor
          BRA       DA_LOOP        ;and loop back to the top

;
; Disk catalog
;

cat_short MOVE.L    A0,-(SP)       ;save the command tail location
          MOVE.W    #$11,-(SP)     ;short catalog
          BRA.S     cat_common

cat_long  MOVE.L    A0,-(SP)       ;save the command tail location
          MOVE.W    #$17,-(SP)     ;long catalog

cat_common
          MOVEQ     #3,D0          ;append *.* to input, and use it
          LEA       catpath,A1

     0$:  MOVE.B    (A1)+,0(A0,D1.W)
          ADDQ.W    #1,D1
          DBRA      D0,0$

          MOVE.L    A0,-(SP)
          MOVE.W    #$4E,-(SP)
          TRAP      #1             ;sfirst
          ADDQ.L    #6,SP

          MOVE.L    D0,-(SP)       ;do initializations
          LEA       cathead,A0
          BSR       lineout
          getdta
          MOVE.L    D0,A3
          MOVE.L    (SP)+,D0

     1$:  TST       D0             ;done with the catalog?
          BNE       catdone        ; yes, return

          LEA       catset,A0      ; no, position cursor for output
          BSR       lineout
          BSR.S     catshow        ;display the current info
          BSR       stopchk        ;pause or abort?
          TST       D0
          BNE       catdone
          snext
          BRA.S     1$

catshow   MOVE.L    A3,A4          ;output the DTA file info
          LEA       name(A4),A4
          CLR.W     -(SP)

     1$:  MOVE.B    (A4)+,D0       ;output the first part of the name
          BEQ.S     4$
          CMP.B     #'.',D0
          BEQ.S     2$
          ADDQ.W    #1,(SP)
          BSR       otchar
          BRA.S     1$

     2$:  ADDQ.W    #1,(SP)        ;output period
          BSR       otchar

     3$:  MOVE.B    (A4)+,D0       ;output the extension
          BEQ.S     4$
          ADDQ.W    #1,(SP)
          BSR       otchar
          BRA.S     3$

     4$:  CMP.W     #14,(SP)       ;fill with spaces to proper length
          BEQ.S     5$
          MOVE.B    #' ',buffer
          BSR       otchar1
          ADDQ.W    #1,(SP)
          BRA.S     4$

     5$:  ADDQ.L    #2,SP          ;remove the count from the stack
          MOVE.L    size(A3),D1    ;show the file size
          BEQ.S     6$             ; unless it is 0 (directory)
          BSR       WTDECL

     6$:  CMP.W     #9,D1          ;pad with spaces
          BEQ.S     7$
          MOVE.B    #' ',buffer
          BSR       otchar1
          ADDQ.W    #1,D1
          BRA.S     6$

     7$:  CLR.W     -(SP)
          MOVE.B    attribute(A3),D1    ;check attributes
          BTST      #4,D1
          BEQ.S     8$
          LEA       cat_dir,A0     ;directory
          BSR       lineout
          ADD.W     D0,(SP)
          BRA.S     12$

     8$:  BTST      #0,D1
          BNE.S     9$
          LEA       cat_norm,A0    ;r/w (normal) attribute
          BSR       lineout
          ADD.W     D0,(SP)
          BRA.S     10$

     9$:  LEA       cat_pro,A0     ;r/  (protected) attribute
          BSR       lineout
          ADD.W     D0,(SP)

    10$:  BTST      #2,D1
          BEQ.S     11$
          LEA       cat_sys,A0     ;,system attribute
          BSR       lineout
          ADD.W     D0,(SP)

    11$:  BTST      #1,D1
          BEQ.S     12$
          LEA       cat_hid,A0     ;,hidden attribute
          BSR       lineout
          ADD.W     D0,(SP)

    12$:  CMP.W     #13,(SP)       ;pad with spaces
          BCC.S     13$
          MOVE.B    #' ',buffer
          BSR       otchar1
          ADDQ.W    #1,(SP)
          BRA       12$

    13$:  ADDQ.L    #2,SP          ;remove counter from stack
          MOVE.W    date(A3),D1
          BSR       showdate       ;display the date

    14$:  MOVE.B    #' ',buffer    ;output 2 spaces
          BSR       otchar1
          BSR       otchar1

    15$:  MOVE.W    time(A3),D1    ;display the time
          BRA       showtime

catdone   MOVE.W    (SP)+,D0       ;are we doing a short or long?
          MOVE.L    (SP)+,A0       ;restore the command tail location
          CMP.W     #$17,D0
          BEQ.S     1$             ;long, show volume info
          RTS                      ;short, return now

     1$:  MOVEQ     #0,D0          ;prepare to show for current drive
          LEA       gdfs_buff,A3   ;prepare to show volume info

          MOVE.B    (A0),D1        ;get the first byte
          CMPI.B    #'A',D1        ;less than 'A'?
          BMI.S     3$             ; -yes, get space from the current disk

          CMPI.B    #'q',D1        ;greater than 'q'?
          BPL.S     3$             ; -yes, get space from the current disk

          CMP.B     #'P',D1        ;show this disk's free space (upper case)
          BMI.S     2$

          CMP.B     #'`',D1        ;get space from the current disk
          BMI.S     3$

          SUBI.B    #' ',D1        ;convert from lower case to upper case
     2$:  SUBI.B    #'@',D1        ;calculate disk number for upper case
          MOVE.B    D1,D0          ;show space on the specified volume

     3$:  freespace A3,D0          ;get the disk free space

          LEA       catend1,A0     ;show free bytes
          BSR       lineout

          MOVE.L    free_all(A3),D1
          MULU      sec_per_all(A3),D1
          MULU      sector_size(A3),D1
          MOVE.L    D1,-(SP)
          BSR       WTDECL

          LEA       catend2,A0     ;show used bytes
          BSR       lineout

          MOVE.L    total_all(A3),D4
          MULU      sec_per_all(A3),D4
          MULU      sector_size(A3),D4
          MOVE.L    D4,D1
          SUB.L     (SP)+,D1
          BSR       WTDECL

          LEA       catend3,A0     ;show total bytes
          BSR       lineout

          MOVE.L    D4,D1
          BRA       WTDECL

;
; Set Default Drive
;

a_drive   MOVE.W    #0,D0
          BRA.S     ok_drive
b_drive   MOVE.W    #1,D0
          BRA.S     ok_drive
c_drive   MOVE.W    #2,D1
          BRA.S     drive_common
d_drive   MOVE.W    #3,D1
          BRA.S     drive_common
e_drive   MOVE.W    #4,D1
          BRA.S     drive_common
f_drive   MOVE.W    #5,D1
          BRA.S     drive_common
g_drive   MOVE.W    #6,D1
          BRA.S     drive_common
h_drive   MOVE.W    #7,D1
          BRA.S     drive_common
i_drive   MOVE.W    #8,D1
          BRA.S     drive_common
j_drive   MOVE.W    #9,D1
          BRA.S     drive_common
k_drive   MOVE.W    #10,D1
          BRA.S     drive_common
l_drive   MOVE.W    #11,D1
          BRA.S     drive_common
m_drive   MOVE.W    #12,D1
          BRA.S     drive_common
n_drive   MOVE.W    #13,D1
          BRA.S     drive_common
o_drive   MOVE.W    #14,D1
          BRA.S     drive_common
p_drive   MOVE.W    #15,D1

drive_common
          MOVE.W    D1,-(SP)
          drvmap                        ;get drive map

     1$:  LSR.W     #1,D0               ;determine if this drive is active
          DBRA      D1,1$

          BCC.S     no_ok_drive         ;not active, don't set drive
          MOVE.W    (SP)+,D0

ok_drive  setdrv    D0                  ;active, set drive to here
          RTS

no_ok_drive
          ADDQ.L    #2,SP               ;output an error message if not active
          LEA       no_drive,A0
          BSR       lineout
          RTS

;
; Output Redirection
;

screen    MOVEM.L   A0/D1,-(SP)         ;show screen redirection message
          LEA       screen_out,A0
          BSR       lineout

          MOVEQ     #1,D0
          BRA.S     out_common

modem     MOVEM.L   A0/D1,-(SP)         ;show modem redirection message
          LEA       modem_out,A0
          BSR       lineout

          MOVEQ     #2,D0
          BRA.S     out_common

print     MOVEM.L   A0/D1,-(SP)         ;show printer redirection message
          LEA       print_out,A0
          BSR       lineout

          MOVEQ     #3,D0

out_common
          MOVEM.L   (SP)+,A0/D1         ;common redirection handler
          TST       D1                  ;parameter(s) passed?
          BEQ.S     3$                  ; -no, redirect output from now on

          MOVE.W    device_out,-(SP)    ; -yes, save old output state
          MOVE.W    D0,device_out       ;set output direction

          LEA       command,A1          ;prepare to lookup and execute the command
          MOVEQ     #0,D0
     1$:  MOVE.B    (A0)+,(A1)+
          BEQ.S     2$
          ADDQ.L    #1,D0
          BRA.S     1$

     2$:  BSR       LOOKUP              ;execute the redirected command
          MOVE.W    (SP)+,device_out    ;restore output direction
          RTS

     3$:  MOVE.W    D0,device_out
          RTS

;
; Set Disk Path
;

path      TST       D1                  ;any paramters?
          BEQ.S     1$                  ; -no, move to the root directory
          chdir     A0                  ; -yes, change to specified path
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error message
          RTS                           ; -no, return

     1$:  chdir     #root_path          ;set to root path
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error message
          RTS                           ; -no, return

;
; Set Prompt
;

set_prompt
          LEA       prompt,A1           ;set input string to prompt

     1$:  MOVE.B    0(A0,D1.W),D0       ;copy input to prompt string
          MOVE.B    D0,0(A1,D1.W)
          DBRA      D1,1$

          create    #prompt_path,#2     ;create a hidden file
          MOVE.W    D0,-(SP)
          write     D0,#80,#prompt      ;write out the prompt buffer
          MOVE.W    #$3E,-(SP)          ;(close)
          TRAP      #1
          ADDQ.L    #4,SP               ;on error, prompt will not configure
          RTS                           ; on startup

;
; Clear Screen
;

clear_scr LEA       clear,A0            ;use VT52 screen clear / home cursor string
          BRA       lineout

;
; Version Number
;

cli_version
          LEA       startup,A0          ;show startup screen
          BRA       lineout

;
; Delete the specified file(s)
;

cli_delete
          BSR       getpath             ;get a path to delete
          BCS.S     2$                  ; -no matches, exit
          MOVE.L    A0,-(SP)
          LEA       deleting,A0         ;output 'deleting:' prompt
          BSR       lineout
          MOVE.L    (SP)+,A0
     1$:  MOVE.L    A0,A1               ;show file that will be deleted
          BSR       lineout
          LEA       resetpos,A0         ;reset position for future output
          BSR       lineout
          unlink    A1                  ;delete the file
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error, abort delete
          BSR       nextpath            ; -no, get next path
          BCC.S     1$                  ;loop if there are more files to delete
     2$:  RTS

;
; Create the specified directory
;

cli_mkdir mkdir     A0                  ;create the specified directory
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error
          RTS                           ; -no, exit

;
; Delete the specified directory
;
cli_rmdir rmdir     A0                  ;delete the specified directory
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error
          RTS                           ; -no, exit

;
; Rename the specified file to the new specified file name
;

cli_rename
          CLR.L     -(SP)               ;save a long word on the stack
          MOVE.L    A0,-(SP)            ;save the old name pointer

     1$:  MOVE.B    (A0)+,D0            ;scan to the new name
          CMP.B     #' ',D0
          BNE.S     1$

          MOVE.L    A0,4(SP)            ;move the address of the new name to the saved long word
          CLR.W     -(SP)
          MOVE.W    #$56,-(SP)          ;(rename)
          TRAP      #1
          ADD.L     #12,SP
          TST       D0                  ;was an error encountered?
          BNE       gen_error           ; -yes, show error
          RTS                           ; -no, return

;
; Change File Attributes
;

lock      MOVEQ     #$01,D2             ;set attribute bit #1
          BRA.S     set_attribute

hide      MOVEQ     #$02,D2             ;set attribute bit #2
          BRA.S     set_attribute

system    MOVEQ     #$04,D2             ;set attribute bit #3

set_attribute
          BSR       getpath             ;get a path to change attributes
          BCS.S     2$                  ;no matches found, exit
          BSR       showmod             ;show 'modifying:' message
     1$:  MOVE.L    A0,-(SP)
          BSR       lineout             ;show file that is under modification
          LEA       resetpos,A0
          BSR       lineout             ;reset position for future output
          MOVE.L    (SP),A0
          chmod     A0,#0,#0            ;get the current status word
          TST.L     D0                  ;was an error encountered?
          BMI       gen_error           ; -yes, show error, abort modification
          OR.B      D2,D0               ; -no, set the specified bit 
          MOVE.L    (SP)+,A0
          chmod     A0,#1,D0            ;use the new status word to reset the file
          TST.L     D0                  ;was an error encountered?
          BMI       gen_error           ; -yes, show error, abort modification
          BSR       nextpath            ;get next path to change
          BCC.S     1$                  ;no more, exit
     2$:  RTS

unlock    MOVE.W    #$FE,D2             ;clear attribute bit #1
          BRA.S     clear_attribute

unhide    MOVE.W    #$FD,D2             ;clear attribute bit #2
          BRA.S     clear_attribute

unsys     MOVE.W    #$FB,D2             ;clear attribute bit #3

clear_attribute
          BSR       getpath             ;get a pathname for the file to change
          BCS.S     2$                  ;no matches found, done
          BSR       showmod             ;show 'modifying:' prompt
     1$:  MOVE.L    A0,-(SP)
          BSR       lineout             ;show path for modification
          LEA       resetpos,A0
          BSR       lineout             ;reset position for future output
          MOVE.L    (SP),A0
          chmod     A0,#0,#0            ;get current status word
          TST.L     D0                  ;was an error encountered?
          BMI       gen_error           ; -yes, show error, abort modify
          AND.B     D2,D0               ; -no, clear the bit in the status word
          MOVE.L    (SP)+,A0
          chmod     A0,#1,D0            ;set the status word as modified
          TST.L     D0                  ;was an error encountered?
          BMI       gen_error           ; -yes, show error, abort modify
          BSR       nextpath            ; -no, get next path to modify
          BCC.S     1$                  ;change next path
     2$:  RTS                           ;no more paths, return

showmod   MOVE.L    A0,-(SP)            ;display 'modifying:' message
          LEA       modifying,A0
          BSR       lineout
          MOVE.L    (SP)+,A0
          RTS

;
; Type File Command
;

type      open      A0,#0               ;open the requested file
          TST       D0                  ;was an error encountered?
          BMI       gen_error           ; -yes, stop

          MOVE.W    device_in,-(SP)     ; -no, redirect input to be
          MOVE.W    D0,-(SP)            ;   file handle of file being typed
          MOVE.W    D0,device_in

          LEA       typeset,A0          ;prepare for the output
          BSR       lineout

     1$:  BSR       inchar              ;show all ASCII characters
          TST       D0                  ;are we done?
          BEQ.S     2$                  ; -yes, stop
          CMP.B     #127,D0             ;in range?
          BCC.S     1$                  ; -no, don't display
          BSR       otchar              ;display character

          BSR       stopchk             ;pause or abort?
          TST       D0
          BEQ.S     1$                  ;not aborted, continue

     2$:  MOVE.W    #$3E,-(SP)          ;close the file
          TRAP      #1
          ADDQ.L    #4,SP
          MOVE.W    (SP)+,device_in     ;restore input direction
          RTS

;
; Batch File Processor
;

batch     TST       D1                  ;return on no input
          BNE.S     1$
          RTS

     1$:  MOVEQ     #45,D0              ;prepare to save batch area
          LEA       bfp_save,A1         ;  for batch file nesting

    18$:  MOVE.L    (A1)+,-(SP)         ;save batch area
          DBRA      D0,18$
          MOVE.L    A1,-(SP)            ;save batch area save address

          LEA       batch_name,A1

     2$:  MOVE.B    (A0)+,D0            ;terminate the batch file name
          MOVE.B    D0,(A1)+            ;          with .BAT
          BEQ.S     3$
          SUBQ      #1,D1
          CMP.B     #' ',D0
          BNE.S     2$

     3$:  SUBQ      #1,A1
          MOVE.L    A0,A2
          LEA       batch_ext,A0

     4$:  MOVE.B    (A0)+,(A1)+         ;append extension
          BNE.S     4$

          open      #batch_name,#0      ;open the specified batch file
          TST       D0
          BPL.S     6$

     5$:  LEA       batch_error,A0      ;batch error message out
          BSR       lineout
          BRA       19$                 ;exit batch processor

     6$:  MOVE.W    device_in,-(SP)     ;save input device
          MOVE.W    D0,-(SP)            ;save handle
          MOVE.W    D0,device_in        ;use handle for input
          MOVEQ     #0,D3               ;clear count
          TST       D1                  ;check for additional parameters
          BEQ.S     10$                 ;no parameters, continue

          LEA       bfp_save,A0
     7$:  MOVE.L    A0,A1
          ADDQ.W    #1,D3

     8$:  MOVE.B    (A2)+,D0            ;copy strings to parameter save area
          SUBQ.W    #1,D1
          CMP.B     #' ',D0
          BEQ.S     9$
          MOVE.B    D0,(A1)+
          TST       D1
          BEQ.S     10$
          BRA.S     8$

     9$:  CLR.B     (A1)                ;move to next parameter if not done
          ADD.L     #19,A0
          CLR.B     (A0)+               ;insure null-termination
          CMP.B     #9,D3
          BCC.S     10$                 ;stop the copy if we have 9 strings
          TST       D1
          BPL.S     7$
          
    10$:  LEA       command,A2          ;command line pointer
          MOVEQ     #0,D2               ;character counter
          TST       echo_flag           ;echo command in effect?
          BEQ.S     11$
          BSR       show_prompt         ; -yes, output the prompt

    11$:  BSR       inchar              ; -no, just get the input
          TST       D0
          BEQ       16$                 ;stop on no input
          CMP.B     #10,D0
          BEQ.S     11$                 ;ignore all line feeds
          CMP.B     #13,D0
          BEQ.S     13$                 ;execute command on cr
          CMP.B     #'%',D0
          BEQ.S     14$                 ;insert parameters
          ADDQ.W    #1,D2
          MOVE.B    D0,(A2)+            ;none of the above, save char
          TST       echo_flag
          BEQ.S     11$                 ;show char on echo flag set
          BSR       otchar1
          BRA.S     11$

    13$:  MOVE.W    D2,D0               ;set the count
          BEQ.S     11$                 ;don't do anything if the line is blank
          MOVE.W    D3,-(SP)            ;save count
          BSR       LOOKUP              ;execute the command
          MOVE.W    (SP)+,D3            ;restore count

          BSR       stopchk             ;pause or abort?
          TST       D0
          BEQ.S     10$                 ;loop back to the top

          LEA       batch_abort,A0      ;confirm batch abort
          BSR       lineout
    17$:  conin
          CMP.B     #'N',D0
          BEQ.S     10$
          CMP.B     #'n',D0
          BEQ.S     10$
          CMP.B     #'Y',D0
          BEQ.S     16$
          CMP.B     #'y',D0
          BEQ.S     16$
          BRA.S     17$

    14$:  BSR       inchar              ;get the parameter number
          AND.B     #$0F,D0
          BEQ.S     11$                 ;zero is not valid
          CMP.B     D3,D0
          BGT.S     11$                 ;this parameter has not been defined
          SUBQ.W    #1,D0
          MULU      #32,D0
          LEA       bfp_save,A1
          ADD.W     D0,A1

    15$:  MOVE.B    (A1)+,D0            ;set the parameter
          BEQ       11$
          MOVE.B    D0,(A2)+
          ADDQ.W    #1,D2
          TST       echo_flag
          BEQ.S     15$
          BSR       otchar
          BRA.S     15$

    16$:  MOVE.W    #$3E,-(SP)          ;close the file
          TRAP      #1
          ADDQ.L    #4,SP
          MOVE.W    (SP)+,device_in     ;restore input direction

    19$:  MOVEQ     #45,D0              ;prepare to restore batch area
          MOVE.L    (SP)+,A1            ;  for batch file nesting

    20$:  MOVE.L    (SP)+,-(A1)         ;restore batch area
          DBRA      D0,20$
          RTS

;
; Echo Toggle
;

echo      TST       D1                  ;is the echo state specified?
          BEQ.S     2$                  ; -no, toggle

          MOVE.B    1(A0),D0            ; -yes, set it to off or on?
          CMP.B     #'F',D0
          BEQ.S     1$                  ;off
          CMP.B     #'f',D0
          BEQ.S     1$                  ;off
          MOVE.W    #$FFFF,echo_flag    ;on
          BRA.S     3$

     1$:  MOVE.W    #$FFFF,echo_flag    ;off
     2$:  EOR.W     #$FFFF,echo_flag    ;exclusive or to toggle echo state
     3$:  TST       echo_flag           ;is echo on or off?
          BEQ.S     4$                  ; off, display state

          LEA       echo_on_str,A0      ; on, display state
          BRA       lineout

     4$:  LEA       echo_off_str,A0
          BRA       lineout

;
; Pause for a keypress
;

pause     MOVE.W    device_out,-(SP)    ;change output to screen
          MOVE.W    #1,device_out
          LEA       pause_mess,A0       ;display pause message
          BSR       lineout
          coninwoe                      ;wait for a keypress
          MOVE.W    (SP)+,device_out    ;restore output direction
          RTS

;
; Memory Size
;

memory    LEA       show_mem,A0         ;show start of prompt
          BSR       lineout
          malloc    #-1                 ;find size of memory
          MOVE.L    D0,-(SP)
          MOVE.L    D0,D1
          BSR       WTDECL              ;show size of memory
          LEA       show_mem1,A0        ;show middle of prompt
          BSR       lineout
          MOVE.L    (SP)+,D1            ;show size of memory + 33,000 bytes
          ADD.L     #33000,D1
          BSR       WTDECL
          LEA       show_mem2,A0        ;show end of prompt
          BRA       lineout

;
; Cursor Flash Control
;

flash     TST.W     D1                  ;any parameters specified?
          BNE.S     1$                  ; -yes, configure as requested
          cursconf  #3,#0               ; -no, configure non-flashing cursor
          RTS

     1$:  MOVEQ     #0,D0               ;initialize counter
     2$:  SUBQ.W    #1,D1               ;convert digits to actual value
          BMI.S     3$
          MULU.W    #10,D0
          MOVE.B    (A0)+,D2
          SUB.B     #'0',D2
          AND.W     #$0F,D2
          ADD.W     D2,D0
          BRA.S     2$

     3$:  cursconf  #4,D0               ;set the cursor to the new rate
          cursconf  #2,#0               ;and display it as a flashing cursor
          RTS

;
; Help Command
;

help      LEA       help_str,A0         ;display help screen
          BRA       lineout

;
; Copy Command
;

copy      MOVE.L    A0,A1               ;make a working copy of A0 (command tail)
          LEA       work_buf2,A2        ;point A2 at the destination pathname buffer

     1$:  MOVE.B    (A1)+,D0            ;scan to the beginning of the destination path
          BEQ.S     4$                  ; -no destination path
          CMP.B     #' ',D0
          BNE.S     1$

     2$:  MOVE.B    (A1)+,D0            ;parse the destination path
          BEQ.S     4$                  ; -end reached
          CMP.B     #' ',D0             ; -skip multiple spaces
          BEQ.S     2$
          MOVE.B    D0,(A2)+            ; -save first character of destination

     3$:  MOVE.B    (A1)+,(A2)+         ;copy to destination until end reached
          BNE.S     3$
          SUBQ.L    #1,A2               ;don't leave the null in the destination!

     4$:  MOVE.B    #'\',(A2)+          ;add a '\' for the complete path
          MOVE.L    A2,A5               ;save the current location in A5
          BSR       getpath             ;get the path to the first file
          BCS       9$                  ;nothing to copy -- stop now

          MOVE.L    A0,-(SP)            ;display message -- copying file(s)
          LEA       copying,A0
          BSR       lineout
          MOVE.L    (SP),A0             ;reset A0 to the source path
          BRA.S     6$

     5$:  MOVE.L    A0,-(SP)

     6$:  BSR       lineout             ;show source filename
          LEA       nextpos,A0
          BSR       lineout             ;show pointer to destination

          MOVE.L    A5,A2               ;copy the filename onto the destination path
          MOVE.L    A3,A1
     7$:  MOVE.B    (A1)+,(A2)+
          BNE.S     7$

          LEA       work_buf2,A0
          BSR       lineout             ;show destination filename 
          LEA       resetpos,A0
          BSR       lineout             ;reset for next file

          getdta                        ;get the size of the file that was found with getpath
          MOVE.L    D0,A0
          MOVE.L    size(A0),fsize

          malloc    size(A0)            ;allocate a copy buffer the size of the file
          TST.L     D0
          BEQ       13$                 ;insufficient memory -- multi-pass copy required
          BMI       13$

          MOVE.L    D0,D3               ;save the copy buffer address
          MOVE.L    (SP)+,A0            ;restore the source file name pointer

          open      A0,#0               ;open the source file
          MOVE.W    D0,-(SP)
          TST.L     D0
          BMI.S     10$

          read      D0,fsize,D3         ;read the source file into the copy buffer
          TST.L     D0
          BMI.S     10$

          MOVE.W    #$3E,-(SP)          ;close the source file
          TRAP      #1
          ADDQ.L    #4,SP

          create    #work_buf2,#0       ;create a destination file for this copy
          MOVE.W    D0,-(SP)
          TST.L     D0
          BMI.S     11$

          write     D0,fsize,D3         ;write the copy buffer to the destination file
          TST.L     D0
          BMI.S     11$

          MOVE.W    #$3E,-(SP)          ;close the destination file
          TRAP      #1
          ADDQ.L    #4,SP

     8$:  mfree     D3                  ;free the copy buffer
          BSR       nextpath            ;check for another file to copy
          BCC       5$                  ;loop to copy the next file

     9$:  RTS

    10$:  LEA       noread,A0           ;error message -- unable to read source
          BRA.S     12$

    11$:  LEA       nowrite,A0          ;error message -- unable to write destination
    12$:  BSR       lineout
          MOVE.W    #$3E,-(SP)          ;close the file in question
          TRAP      #1
          ADDQ.L    #4,SP
          BRA.S     8$                  ;try to copy any additional files

    13$:  MOVE.L    fsize,D5            ;multi-pass copy routine -- put file size in D5

          malloc    #-1                 ;see how much free memory there is
          TST.L     D0
          BEQ       17$                 ;-none, abort the copy process
          BMI       17$
          MOVE.L    D0,D4               ;save the memory buffer size in D4
          malloc    D0                  ;allocate all free memory
          MOVE.L    D0,D3               ;save address of memory buffer in D3

          MOVE.L    (SP)+,A0            ;restore the pointer to the source pathname
          open      A0,#0               ;open the source file
          MOVE.W    D0,-(SP)            ;save the handle
          TST.L     D0
          BMI.S     10$                 ;report an error if one occured

          create    #work_buf2,#0       ;create the destination file
          MOVE.W    D0,-(SP)            ;save the destination handle
          TST.L     D0
          BPL.S     15$                 ;continue on no error

    14$:  MOVE.W    #$3E,-(SP)          ;error handling routine from here on out
          TRAP      #1                  ;close destination file
          ADDQ.L    #4,SP
          BRA.S     11$                 ;report error message and close source file

    15$:  MOVE.W    2(SP),D0            ;restore the source handle
          read      D0,D4,D3            ;read a buffer full of data
          TST.L     D0
          BMI.S     14$                 ;report an error if one occured

          MOVE.W    (SP),D0             ;restore the destination handle
          write     D0,D4,D3            ;write a buffer full of data
          TST.L     D0
          BMI.S     14$                 ;report an error if one occured

          SUB.L     D4,D5               ;subtract the size of the buffer from the file size
          BEQ.S     16$                 ;stop if the size went to zero or negative
          BMI.S     16$
          CMP.L     D4,D5               ;otherwise, see which of the two numbers is larger
          BPL.S     15$                 ;copy another full buffer (file size is larger)
          MOVE.L    D5,D4               ;copy the remainder of the file
          BRA.S     15$

    16$:  MOVE.W    #$3E,-(SP)          ;done with multi-pass copy
          TRAP      #1                  ;close the destination file
          ADDQ.L    #4,SP

          MOVE.W    #$3E,-(SP)          ;close the source file
          TRAP      #1
          ADDQ.L    #4,SP
          BRA       8$                  ;loop for additional files

    17$:  MOVE.L    (SP)+,A0            ;no memory for copy -- fix stack pointer,
          LEA       nomem,A0            ; display error message,
          BRA       lineout             ; and abort the copy process

;
; Format disk
;

init_disk
        MOVEM.L A0/D1,-(SP)             ;save command tail information
        malloc  #5200                   ;allocate a buffer
        MOVEM.L (SP)+,A0/D1             ;restore command tail information
        TST.L   D0                      ;buffer sucessfully allocated?
        BMI.S   1$                      ; -no, display error
        BNE.S   2$                      ; -yes, continue format

   1$:  LEA     no_memory,A0            ;display no memory prompt and return
        BRA     lineout

   2$:  MOVE.L  D0,A3                   ;record buffer location
        MOVE.L  #$2D0,-(SP)             ;default sides = 1, sectors = $2D0
        MOVEQ   #9,D6                   ;default to 9 sectors/track
        MOVEQ   #0,D7                   ;default to drive A:
        MOVE.B  #'A',drive

parse_loop                              ;parse options from command tail
        MOVE.B  (A0)+,D0
        CMP.B   #'B',D0
        BNE.S   2$
   1$:  MOVEQ   #1,D7                   ;set to drive B:
        MOVE.B  #'B',drive
        BRA.S   7$

   2$:  CMP.B   #'D',D0
        BNE.S   4$
   3$:  MOVE.W  #1,(SP)                 ;set to double-sided format
        BRA.S   7$

   4$:  CMP.B   #'T',D0
        BNE.S   6$
   5$:  MOVEQ   #10,D6                  ;set to ten sector format
        MOVE.W  #$320,2(SP)
        BRA.S   7$

   6$:  CMP.B   #'b',D0                 ;also check for lower case entry
        BEQ.S   1$
        CMP.B   #'d',D0
        BEQ.S   3$
        CMP.B   #'t',D0
        BEQ.S   5$

   7$:  DBRA    D1,parse_loop           ;loop until all characters are parsed

        LEA     format_prompt,A0        ;display drive format prompt
        BSR     lineout

        TST.W   (SP)
        BEQ.S   8$
        LEA     double,A0               ;display double-sided format message
        BSR     lineout

   8$:  CMPI.W  #10,D6
        BNE.S   9$
        LEA     ten,A0                  ;display 10 sector format message
        BSR     lineout

   9$:  LEA     ready,A0                ;display ready prompt, wait for keypress
        BSR     lineout
        coninwoe                        ;get input

        CMPI.B  #'F',D0                 ;make certain user wants to format the disk
        BEQ.S   do_format
        CMPI.B  #'f',D0
        BEQ.S   do_format

        MOVE.L  (SP)+,D0                ;abort format!! return to caller
        RTS

do_format                               ;not aborted, proceede with format
        LEA     show_format,A0          ;reposition for graphic display of format
        BSR     lineout

        MOVEQ   #0,D5                   ;initialize track pointer
   1$:  MOVE.W  (SP),D4                 ;set/reset the count for number of sides
   2$:  MOVE.W  #8,D3                   ;retry 8 times on each sector

   3$:  flopfmt A3,D7,D6,D5,D4,#1       ;format track!
        TST.L   D0                      ;error?
        BEQ.S   4$                      ; -no, continue
        SUBQ.W  #1,D3                   ; -yes, retry format?
        BPL.S   3$                      ; -yes, loop
        BRA     7$                      ; -no, report error

   4$:  SUBQ.W  #1,D4                   ;done with both sides?
        BPL.S   2$                      ; -no, do the other side (if needed)

        MOVE.B  #'_',buffer             ;graphically display progress
        BSR     otchar1

        ADDQ.W  #1,D5                   ;increment the track number
        CMPI.W  #$50,D5                 ;have we done all the tracks?
        BNE.S   1$                      ; -no, loop until finished

        mediach D7                      ;check for a media change (just to be safe?)
        MOVE.W  (SP),D0                 ;calculate disk type ( #sides +2 )
        ADD.W   #2,D0
        protobt A3,#$11111111,D0,#0     ;prototype a boot sector

        TST.W   (SP)                    ;correct sector number by disk side(s)
        BEQ.S   5$
        LSL.W   2(SP)                   ;(multiply by two if double-sided)

   5$:  MOVE.B  2(SP),$14(A3)           ;set actual number of total sectors
        MOVE.B  3(SP),$13(A3)
        CLR.B   $19(A3)                 ;set actual number of sectors/track
        MOVE.B  D6,$18(A3)

        flopwr  A3,D7,#1,#0,#0,#4       ;write boot sector to disk

        MOVE.L  #$4FF,D0                ;set to clear the buffer
        MOVE.L  A3,A2
        MOVEQ   #0,D1

   6$:  MOVE.L  D1,(A2)+                ;clear $1400 bytes of buffer
        DBRA    D0,6$

        flopwr  A3,D7,#2,#0,#0,#8       ;clear sector 2 for FAT use

        mfree   A3                      ;release buffer memory
        MOVE.L  (SP)+,D0                ;remove variables from stack
        RTS                             ;return to calling program

   7$:  MOVE.L  (SP)+,D0                ;remove variables from stack
        LEA     format_err,A0           ;display error message and exit
        BRA     lineout

;
; Remark command
;

remark  RTS                             ;don't do anything with a remark

;
; Program Data Area
;

          DATA

;
; Startup / version message
;

startup   dc.b      27,69,'Atari ST Command Line Interpreter'
          dc.b      13,10,' Version 1.0 - Jeffrey R. Wilson'
          dc.b      13,10,'   ',189,'1987,  All rights reserved',10,0

;
; Prompt messages and data
;

prompt_set dc.b     13,10,10,27,101,0   ;prompt set string

prompt    dc.b      '#P >',0,0          ;default prompt string
          dcb.b     74,0
          dc.w      0

prompt_path
          dc.b      'C:\PROMPT.CNF',0   ;location of new prompt

;
; Pathname for the root directory
;

root_path dc.b      '\',0

;
; Command buffers and data
;

          cnop      0,2
cmdline   dc.l      cmd_buffer-command
command   dcb.b     120,0          ;command buffer

cmd_buffer dcb.b    32,0           ;external command workspace
cmd_ext    dc.b     '.PRG',0,0

;
; Calculation and work buffers and data
;

          cnop      0,2
work_buf  dcb.b     64,0           ;prompt output buffer
work_buf2 dcb.b     64,0           ;extra work buffer
buffer    dcb.w     1,0            ;otchar output buffer
fsize     dcb.l     1,0            ;file size indicator for copy

device_in  dc.w     0              ;input device handle
device_out dc.w     1              ;output device handle

;
; Error Messages
;

unknown   dc.b      13,10,10,7,'Unknown Command',0

no_drive  dc.b      13,10,10,7,'No such drive connected',0

generic   dc.b      13,10,10,7,'Unable to perform command as entered',0

;
; Format messages
;

format_prompt
        DC.B    27,102,13,10,10,'Ready to format drive '
drive   DC.B    'A:, ',0

double  DC.B    'Double sided, ',0

ten     DC.B    'Ten sector,',0

ready   DC.B    13,10,'Press F to format, any other key to abort',0

show_format
        DC.B    13,10,0

format_err
        DC.B    7,13,10,10,'An error ocurred during the disk formatting',0

no_memory
        DC.B    7,13,10,10,'There is insufficient memory to format a disk',0

;
; Pause message
;

pause_mess
          dc.b      13,10,10,7,27,102,'Press any key to continue...',0

;
; Generic "no files" message
;

nofiles
          dc.b      13,10,10,7,'No file(s) located',0

;
; Clear screen message
;

clear     dc.b      27,'E',0

;
; Attribute modification message
;

modifying dc.b      13,10,10,'Modifying attribute of:',13,10,10,0

;
; Delete message
;

deleting  dc.b      13,10,10,'Deleting:',13,10,10,0

;
; Copy messages
;

copying   dc.b      13,10,10,'Copying:',13,10,10,0

noread    dc.b      13,10,7,'  Unable to read source file!',13,10,10,0

nowrite   dc.b      13,10,7,'  Unable to write destination file!',13,10,10,0

nomem     dc.b      13,10,7,'  Insufficient memory to copy files!',13,10
          dc.b      '    Copy process aborted!',13,10,10,0

resetpos  dc.b      13,10,0,0
nextpos   dc.b      ' --> ',0

;
; Catalog messages
;

cathead   dc.b      13,10,10,27,102,'        Filename    Size'
          dc.b      '    Attributes      Date    Time',10,0

catend1   dc.b      13,10,10,'    Bytes Free: ',0

catend2   dc.b      '   Bytes Used: ',0

catend3   dc.b      '   Total: ',0

catpath   dc.b      '*.*',0

catset    dc.b      13,10,'      ',0

cat_norm  dc.b      'r/w',0

cat_pro   dc.b      'r/ ',0

cat_dir   dc.b      'directory  ',0

cat_hid   dc.b      ',hidden ',0

cat_sys   dc.b      ',system ',0

;
; Catalog Equates
;

attribute equ       21             ;DTA equates
time      equ       22
date      equ       24
size      equ       26
name      equ       30

free_all    equ     0              ;disk free space equates
total_all   equ     4
sector_size equ     10
sec_per_all equ     14

          cnop      0,2
gdfs_buff dcb.l     4,0            ;disk free space buffer

;
; Memory Size Messages
;

show_mem  dc.b      13,10,10,'Current usable memory size is: ',0

show_mem1 dc.b      ' bytes',13,10,'   Outside CLI memory size is: ',0

show_mem2 dc.b      ' bytes',0

;
; Echo status messages
;

echo_on_str dc.b    13,10,10,'Echo is on',0

echo_off_str dc.b   13,10,10,'Echo is off',0

;
; Output redirection messages
;

screen_out dc.b     13,10,10,'Output is directed to screen',0

modem_out dc.b      13,10,10,'Output is directed to modem',0

print_out dc.b      13,10,10,'Output is directed to printer',0

;
; Help message
;

help_str  dc.b      13,10,10,'Internal commands are:',13,10,10
          dc.b      '-         BATCH     BYE       CAT       '
          dc.b      'CATALOG   CDIR      CLS       COPY      ',13,10
          dc.b      'DELETE    DIR       DIRECTORY ECHO      '
          dc.b      'ERASE     FLASH     FORMAT    FREE      ',13,10
          dc.b      'HIDE      INIT      LOCK      MEM       '
          dc.b      'MKDIR     MODEM     PATH      PAUSE     ',13,10
          dc.b      'PRINT     PROMPT    PROTECT   QUIT      '
          dc.b      'REM       REMOVE    RENAME    RMDIR     ',13,10
          dc.b      'SCREEN    SYSTEM    TYPE      UNHIDE    '
          dc.b      'UNLOCK    UNPROTECT UNSYSTEM  VERSION   ',13,10,10
          dc.b      'A:   B:   C:   D:   E:   F:   G:   H:   '
          dc.b      'I:   J:   K:   L:   M:   N:   O:   P:   ',0

;
; Batch file messages
;

batch_error
          dc.b      13,10,10,7,'Unable to execute requested batch file',0

batch_abort
          dc.b      13,10,10,'Abort Batch File? (y/n) ',0

typeset   dc.b      27,102,13,10,10,0

;
; Batch file variables and parameter block
;

          cnop      0,2
autorun   dc.b      'C:\CLI.BAT',0,0
autobat   dc.b      'C:\CLI',0
autocount dc.w      6

batch_name dcb.b    50,0           ;batch file path name
batch_ext  dc.b     '.BAT',0       ;batch file extension
echo_flag  dc.w     $FFFF          ;echo default is on

          cnop      0,2
bfp_save  dcb.b     20,0           ;parameter 1 (big enough for 19 bytes of
          dcb.b     20,0           ;parameter 2  data and 1 null-termination)
          dcb.b     20,0           ;parameter 3
          dcb.b     20,0           ;parameter 4
          dcb.b     20,0           ;parameter 5
          dcb.b     20,0           ;parameter 6
          dcb.b     20,0           ;parameter 7
          dcb.b     20,0           ;parameter 8
          dcb.b     20,0           ;parameter 9

;
; Command Table
;
; entry format:
;
;         dc.b      'COMM'    ;exactly 4 bytes of the command in upper case
;         dc.l      command_handler_address
;

          cnop      0,2
table     dc.b      '-',0,0,0
          dc.l      batch

          dc.b      'A:',0,0
          dc.l      a_drive

          dc.b      'BATC'
          dc.l      batch

          dc.b      'BYE',0
          dc.l      exit

          dc.b      'B:',0,0
          dc.l      b_drive

          dc.b      'CAT',0
          dc.l      cat_short

          dc.b      'CATA'
          dc.l      cat_long

          dc.b      'CDIR'
          dc.l      path

          dc.b      'CLS',0
          dc.l      clear_scr

          dc.b      'COPY'
          dc.l      copy

          dc.b      'C:',0,0
          dc.l      c_drive

          dc.b      'DELE'
          dc.l      cli_delete

          dc.b      'DIR',0
          dc.l      cat_short

          dc.b      'DIRE'
          dc.l      cat_long

          dc.b      'D:',0,0
          dc.l      d_drive

          dc.b      'ECHO'
          dc.l      echo

          dc.b      'ERAS'
          dc.l      cli_delete

          dc.b      'E:',0,0
          dc.l      e_drive

          dc.b      'FLAS'
          dc.l      flash

          dc.b      'FORM'
          dc.l      init_disk

          dc.b      'FREE'
          dc.l      memory

          dc.b      'F:',0,0
          dc.l      f_drive

          dc.b      'G:',0,0
          dc.l      g_drive

          dc.b      'HELP'
          dc.l      help

          dc.b      'HIDE'
          dc.l      hide

          dc.b      'H:',0,0
          dc.l      h_drive

          dc.b      'INIT'
          dc.l      init_disk

          dc.b      'I:',0,0
          dc.l      i_drive

          dc.b      'J:',0,0
          dc.l      j_drive

          dc.b      'K:',0,0
          dc.l      k_drive

          dc.b      'LOCK'
          dc.l      lock

          dc.b      'L:',0,0
          dc.l      l_drive

          dc.b      'MEM',0
          dc.l      memory

          dc.b      'MKDI'
          dc.l      cli_mkdir

          dc.b      'MODE'
          dc.l      modem

          dc.b      'M:',0,0
          dc.l      m_drive

          dc.b      'N:',0,0
          dc.l      n_drive

          dc.b      'O:',0,0
          dc.l      o_drive

          dc.b      'PATH'
          dc.l      path

          dc.b      'PAUS'
          dc.l      pause

          dc.b      'PRIN'
          dc.l      print

          dc.b      'PROM'
          dc.l      set_prompt

          dc.b      'PROT'
          dc.l      lock

          dc.b      'P:',0,0
          dc.l      p_drive

          dc.b      'QUIT'
          dc.l      exit

          dc.b      'REM',0
          dc.l      remark

          dc.b      'REMO'
          dc.l      cli_delete

          dc.b      'RENA'
          dc.l      cli_rename

          dc.b      'RMDI'
          dc.l      cli_rmdir

          dc.b      'SCRE'
          dc.l      screen

          dc.b      'SYST'
          dc.l      system

          dc.b      'TYPE'
          dc.l      type

          dc.b      'UNHI'
          dc.l      unhide

          dc.b      'UNLO'
          dc.l      unlock

          dc.b      'UNPR'
          dc.l      unlock

          dc.b      'UNSY'
          dc.l      unsys

          dc.b      'VERS'
          dc.l      cli_version

          dc.b      0,0

;
; GEM / Desk Accessory variables and stack
;

           CNOP     0,2
CLI_SCREEN DCB.L    1,0       ;pointer to the screen when in the CLI
PHYSBASE   DCB.L    1,0       ;pointer to the actual screen physical base
LOGBASE    DCB.L    1,0       ;pointer to the actual screen logical base
MEM_ADDR   DCB.L    1,0       ;address of the memory allocated for screen
MSGBUF     DCB.B    16,0      ;message buffer for message events

aespb      DC.L     contrl,global,intin,intout,addrin,addrout

contrl
opcode     DCB.W    1,0
sintin     DCB.W    1,0
sintout    DCB.W    1,0
saddrin    DCB.L    1,0
saddrout   DCB.L    1,0
           DCB.W    5,0

global
apversion  DCB.W    1,0
apcount    DCB.W    1,0
apid       DCB.W    1,0
apprivate  DCB.L    1,0
apptree    DCB.L    1,0
ap1resv    DCB.L    1,0
ap2resv    DCB.L    1,0
ap3resv    DCB.L    1,0
ap4resv    DCB.L    1,0

intin                         ;GEM input/output array
intout     DCB.W    20,0

addrin                        ;GEM address in/out array
addrout    DCB.W    20,0

ACC_NAME   DC.B     '  ',14,15,' Command Line',0
MEM_ERROR  DC.B     '[1][ |Insufficient memory to run CLI|'
           DC.B     'Make more space and try again!| ][Sorry]',0

           CNOP     0,2
           DCB.B    1982,0    ;insure the stack is large enough for
stack      DCB.W    1,0       ; batch file recursion (round to 10000 bytes)

           END
