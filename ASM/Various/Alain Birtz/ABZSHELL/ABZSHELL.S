
* ABZ command shell, by Alain Birtz, feb. 89 
* These program and assembler source are public domain, can be copied freely
* If your use part of this source, it will be fair to mention the author
* in your header program. You can contact me via Compuserve [72467,2770]
* or write to: 650 Grand St-Charles, St-Paul d'Abbotsford,
* P.Q., Canada J0H-1A0

* ------------------------------------------------------------------------ *

BIOS    equ     13
XBIOS   equ     14
GEMDOS  equ     1
TAB     equ     9
LF      equ     10
CR      equ     13
SPACE   equ     32

NO_MEM  equ     -39
NO_PRT  equ     -993
NO_REN  equ     -994
NO_BAT  equ     -995
UNKNOW  equ     -996
VAR     equ     -997
FULL    equ     -998
MISS    equ     -999


* ------------------------------------------------------------------------ *

* release free memory.

        move.l  a7,a5                   ; save stack pointer
        lea     ustk,a7                 ; set local stack (ext data)
        move.l  (4,a5),a5               ; basepage address
        move.l  ($C,a5),d0              ; prg length
        add.l   ($14,a5),d0             ; data area length
        add.l   ($1C,a5),d0             ; bss area length
        add.l   #$100,d0                ; reserve $100 long base page 
        move.l  d0,-(sp)                ; length of memory to free
        move.l  a5,-(sp)                ; start address of this memory
        move    d0,-(sp)                ; junk word
        move    #$4A,-(sp)              ; function number 'Mshrink'
        trap    #GEMDOS
        adda.w  #12,sp                  ; update stack

        lea     def_p,a0                ; save current directory
        bsr.w   get_path
        lea     title,a0                ; print title
        bsr.w   prt_str
        lea     boot,a0                 ; execute 'BOOT.BAT'
        bsr.w   split_arg
        bsr.w   do_file
        bra.w   shell                   ; enter in the main shell loop

* ------------------------------------------------------------------------ *

shell:

* display the prompt symbol, get some command and execute this command

        tst.w   err_no                  ; some error ?
        beq.s   shell0
        bsr.w   show_error              ; yes -> display error type

shell0: lea     wait_1,a0
        bsr.w   prt_str                 ; print default pathname
        lea     def_p,a0
        bsr.w   prt_str
        lea     wait_2,a0
        bsr.w   prt_str
        lea     cmd,a0
        moveq   #80-3,d0                ; 80-3 char max
        bsr.w   get_str                 ; get user command
        tst.w   d0
        beq.s   shell                   ; at least one char
        bsr.w   upper                   ; make command upper case only
        bsr.w   split_arg               ; split command and argument
        bsr.w   do_keyword
        tst.w   d0                      ; it a keyword ?
        bne.s   shell                   ; yes -> do it, wait next command
        bsr.w   do_drive
        tst.w   d0                      ; it a drive letter ? (type 'B:')
        bne.s   shell                   ; yes -> change, wait next command
        bsr.w   do_file                 ; it is a filename ?
        tst.w   d0                      ; it a file ?
        bne.s   shell                   ; yes -> exec. it, wait next command
        move.w  #UNKNOW,err_no          ; no -> error
        bra.s   shell                   ; wait for next command

* ------------------------------------------------------------------------ *

do_keyword:

* search command in the keyword list. if the keyword is found, execute the
* routine for the keyword and return with d0 set. else return d0 clear

        moveq   #0,d2                   ; keyword counter
        lea     key_w,a0                ; list of keyword

search: movea.l arg1,a1                 ; user command (first argument)
        bsr.w   compare                 ; same as current keyword ?
        tst.w   d0
        bne.s   doKEYw                  ; yes -> execute this command
        tst.b   (a0)                    ; no -> try next keyword
        beq.s   noKEYw                  ; until end of list
        addq.w  #1,d2
        bra.s   search

doKEYw: lea     call,a0                 ; routine address table
        lsl.w   #2,d2                   ; multiply d2 by 4 -> table offset
        movea.l 0(a0,d2.w),a0           ; our routine address
        jsr     (a0)                    ; execute this routine
        moveq   #-1,d0
noKEYw: rts

* ------------------------------------------------------------------------ *

do_drive:

* if the command is of type 'A:', 'B', ... then set the default drive
* and return with d0 set. else return d0 clear

        moveq   #0,d0
        movea.l arg1,a0                 ; user command
        tst.b   2(a0)                   ; null char ?
        bne.s   do_noD                  ; yes -> execute this command
        cmpi.b  #':',1(a0)              ; colon ?
        bne.s   do_noD                  ; yes -> execute this command

        lea     def_p,a0
        clr.b   3(a0)                   ; keep only A:\
        bsr.w   set_path                ; to reset (old) drive pathname
        movea.l arg1,a0
        bsr.w   set_path                ; do it
        lea     def_p,a0                ; get complete new pathname
        bsr.w   get_path
        moveq   #-1,d0

do_noD: rts

* ------------------------------------------------------------------------ *

do_file:

* search command on the directory. if the filename is found, execute the
* program and return with d0 set. else return d0 clear

        movea.l arg1,a0                 ; user command (first argument)
        lea     work,a1                 ; work buffer
        bsr.w   str_copy                ; copy the command

* next we must check for a valid filename extension so get a dot.
* if there is no dot in the filename, get any file in the directory
* with valid extension

        movea.l a1,a2                   ; save end of filename (the copy)

getDOT: move.b  -(a1),d0
        cmpi.b  #'\',d0                 ; folder symbol ?
        beq.s   no_dot
        cmpi.b  #':',d0                 ; disk symbol ?
        beq.s   no_dot
        cmpi.b  #'.',d0                 ; dot ?
        beq.s   is_dot
        cmpa.l  #work,a1
        bhi.s   getDOT                  ; until start of command

no_dot: move.b  #'.',(a2)+              ; put a dot at the end of filename
        movea.l a2,a4                   ; the extention start there
        move.b  #'*',(a2)+              ; and a wildcard in extention area
        clr.b   (a2)                    ; null terminated string
        bra.s   getONE

is_dot: lea     1(a1),a4                ; the extention start there

* now get one filename in the directory. first get dta buffer address

getONE: move.w  #$2F,-(sp)              ; function number: Fgetdta
        trap    #GEMDOS                 ; get disk transfert address
        addq.l  #2,sp                   ; update stack
        move.l  d0,dta                  ; save dta address

* second search for the first matching file in the directory

        move.w  #1,-(sp)                ; file affribute: normal + protect
        pea     work                    ; copy of user command
        move.w  #$4E,-(sp)              ; function number: Fsfirst
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.w   nofind                  ; no -> exit

* a matching filename exist. we must check for a valid extension.

valid0: movea.l dta,a3
        lea     30(a3),a3               ; filemame in dta

valid1: move.b  (a3)+,d0
        beq.s   next                    ; no dot -> try next file
        cmpi.b  #'.',d0
        bne.s   valid1
        lea     ext,a0                  ; valid extension list

valid2: movea.l a0,a2                   ; current extention in the list
        movea.l a3,a1                   ; extention in dta filename
        bsr.w   compare                 ; same as current extension ?
        tst.w   d0
        bne.s   repl                    ; yes -> replace extension
        tst.b   (a0)                    ; no -> try next list extention
        bne.s   valid2                  ; until end of list

* no valid extention match, then get next filename

next:   move.w  #$4F,-(sp)              ; function number: Fsnext
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        beq.s   valid0                  ; yes -> check for valid extension

nofind: moveq   #0,d0                   ; file not found
        rts

repl:   movea.l a2,a0                   ; current extention in the list
        movea.l a4,a1                   ; start of extention in filename
        bsr.w   str_copy                ; copy the valid extention
        tst.b   1(a0)                   ; point now to the next list ext.
        beq.w   batch                   ; last extention is BAT (batch file)
        bne.w   program                 ; other is program file

* ------------------------------------------------------------------------ *

program:

* execute program of filename holding in 'work' and command tail pointed
* by 'arg2'. upon return d0 is set

        lea     blank,a0
        bsr.w   prt_str                 ; some blank

        movea.l arg2,a0                 ; second argument = command tail
        movea.l a0,a1

length: tst.b   (a1)+                   ; compute argument length
        bne.s   length

        move.l  a1,d0
        sub.l   a0,d0                   ; the length (including the null)
        subq.l  #1,a0
        move.b  d0,(a0)                 ; length in the string leading byte

        clr.l   -(sp)                   ; no enviroment string
        move.l  a0,-(sp)                ; command tail
        pea     work                    ; pathname and/or filename
        clr.w   -(sp)                   ; load-and-go
        move.w  #$4B,-(sp)              ; 'Pexec' function
        trap    #GEMDOS
        adda.w  #16,sp
        lea     def_p,a0
        bsr.w   set_path                ; reset default pathname
        moveq   #-1,d0
        rts

* ------------------------------------------------------------------------ *

batch:

* load and execute batch file  of filename holding in 'work' and command
* tail pointed by 'arg2'. dta buffer is pointed by 'dta'
* upon return do is set

        tst.b   exeBAT                  ; already executing batch file now ?
        beq.s   bat_0
        move.w  #NO_BAT,err_no          ; yes -> error
        moveq   #-1,d0
        rts

bat_0:  lea     work,a0                 ; filemame in dta
        bsr.w   open                    ; open source file      
        tst.w   err_no
        bpl.s   bat_r                   ; (read)
        moveq   #-1,d0
        rts                             ; error -> exit

bat_r:  moveq   #-1,d0                  ; get free memory
        bsr.w   Malloc
        subq.l  #1,d0
        move.l  d0,d1

        move.l  dta,a0
        move.l  26(a0),d3               ; file size
        move.l  d3,d0
        addi.l  #3*80,d0                ; (for lines buffer)
        addq.l  #1,d0                   ; to null terminate the file
        cmp.l   d1,d0                   ; file to big ?
        bcc.w   bat_m                   ; (memory problem)
        bsr.w   Malloc                  ; reserve memory
        move.l  d0,batBUF               ; store start address

        movea.l d0,a0
        move.l  d3,d0
        bsr.w   read                    ; read the file
        move.l  d0,d3                   ; file size
        tst.w   err_no
        bmi.s   bat_er                  ; close the file
        bsr.w   close

        move.l  batBUF,a0               ; start of batch file buffer
        move.l  a0,batPTR               ; current line pointer
        adda.l  d3,a0
        clr.b   (a0)+                   ; null terminated file

        move.l  a0,param                ; argument parameter (%1, %2, ...)
        adda.l  #80,a0
        move.l  a0,bat_LN               ; one line batch file
        bsr.w   get_param               ; get parameter address (%1, %2 ...)
        tst.w   err_no
        bmi.s   bat_x
        st      exeBAT                  ; 'executing batch file now' flag

bat_lp: move.l  batPTR,batPRV           ; save current line pointer
        bsr.w   set_line                ; set one batch line
        tst.w   err_no
        bmi.s   bat_x   

        bsr.w   do_line                 ; execute this line of command
        tst.w   err_no
        bmi.s   bat_x   

        tst.b   exeBAT                  ; STOP command ?
        beq.s   bat_x

        movea.l batPTR,a0
        tst.b   (a0)                    ; last line ?
        bne.s   bat_lp                  ; no -> try next

        bra.s   bat_x

bat_m:  move.w  #NO_MEM,err_no          ; insuficient memory
bat_er: bsr.w   close                   ; close the file
bat_x:  movea.l batBUF,a0
        bsr.w   Mfree                   ; release used memory
        moveq   #-1,d0
        clr.b   exeBAT                  ; 'executing batch file now' flag
        rts

* ------------------------------------------------------------------------ *

get_param:

* get parameter address (of %1, %2, ...) in 'parPTR' table

        movea.l arg2,a0
        movea.l param,a1                ; copy comand line argument
        bsr.w   str_copy

        movea.l param,a0                ; parameter is there
        lea     parPTR,a1               ; pointer to parameter in 'param'
        moveq   #3,d1                   ; dbra parameter counter

g_p_lp: bsr.w   split_arg               ; split argument (pointed by a0)
        move.l  arg1,(a1)+              ; save pointer
        move.l  arg2,a0                 ; try the remaining
        dbra    d1,g_p_lp

        move.l  arg2,(a1)               ; fifth parameter
        rts

* ------------------------------------------------------------------------ *

set_line:

* replace variable by parameter in the batch line pointed by 'batPTR'

        movea.l bat_LN,a1               ; one batch file line buffer
        movea.l batPTR,a2               ; current line pointer
        clr.b   cmd_ch                  ; 'is command char' flag

sLN_lp: move.b  (a2)+,d0                ; get one char
        beq.s   sLNeof                  ; exit at end of file
        cmpi.b  #'%',d0                 ; variable ?
        beq.s   sLNvar
        cmpi.b  #CR,d0
        beq.s   sLN_lp                  ; ignore carriage return
        cmpi.b  #LF,d0
        beq.s   sLNeol                  ; exit at end of line
        cmpi.b  #$20,d0                 ; control char ?
        bls.s   sLN_20
        st      cmd_ch                  ; set 'is command char' flag
sLN_20: move.b  d0,(a1)+                ; fill the batch line
        bra.s   sLN_lp

sLNvar: moveq   #0,d0
        move.b  (a2)+,d0                ; get variable no.
        sub.w   #'1',d0
        bmi.s   sLN_er
        cmpi.w  #4,d0                   ; %1 to %5 only
        bhi.s   sLN_er
        lea     parPTR,a0               ; parameter pointer table
        lsl.w   #2,d0                   ; offset in table
        movea.l 0(a0,d0.w),a0           ; the parameter address in 'param'
        tst.b   (a0)                    ; parameter exist?
        beq.s   sLN_er                  ; no -> error
        bsr.w   str_copy                ; copy a0 to a1 (replacing %_ by
        bra.s   sLN_lp                  ; its value)

sLNeof: subq.l  #1,a2
sLNeol: clr.b   (a1)                    ; null terminated string
        move.l  a2,batPTR               ; set pointer for next batch line
        rts

sLN_er: move.w  #VAR,err_no             ; 'undefined variable'
        rts

* ------------------------------------------------------------------------ *


do_line:

* execute the batch line pointed by 'bat_LN'

        tst.b   cmd_ch                  ; reach one command char ?
        beq.s   doLN_x                  ; no -> exit
        lea     one_ln,a0
        bsr.w   prt_str                 ; one line

        movea.l bat_LN,a0               ; the batch file line buffer
        bsr.w   prt_str
        bsr.w   upper                   ; make command upper case only
        bsr.w   split_arg               ; split command and argument
        bsr.w   do_keyword
        tst.w   d0                      ; it a keyword ?
        bne.s   doLN_x                  ; yes -> do it, wait next command
        bsr.w   do_drive
        tst.w   d0                      ; it a drive letter ? (type 'B:')
        bne.s   doLN_x                  ; yes -> change, wait next command
        bsr.w   do_file                 ; it is a filename ?
        bne.s   doLN_x                  ; yes -> exec. it, wait next command
        move.w  #UNKNOW,err_no          ; no -> error

doLN_x: rts

* ------------------------------------------------------------------------ *

show_error:

* display error type to the screen

        move.w  err_no,d4               ; error no
        moveq   #0,d0
        move.w  d4,d0
        neg.w   d0                      ; make it positive
        moveq   #10,d1                  ; base 10
        moveq   #2,d2                   ; display 2 char
        lea     io_no,a0                ; there
        moveq   #SPACE,d3               ; replace leading zero by blank
        bsr.w   l_to_a
        lea     io_err,a0               ; display error no.
        bsr.w   prt_str

        lea     error,a0                ; error table
        subq.l  #6,a0
err_lp: addq.l  #6,a0                   ; room for error no + error type adr.
        move.w  (a0),d0                 ; error no. in the table
        beq.s   err_x                   ; not in table -> exit
        cmp.w   d0,d4                   ; our error ?
        bne.s   err_lp                  ; no -> try next

        movea.l 2(a0),a0                ; error type address
        bsr.w   prt_str                 ; show it

err_x:  clr.w   err_no
        rts

* ------------------------------------------------------------------------ *
* ----------------------- Keyword Command -------------------------------- *
* ------------------------------------------------------------------------ *

* ---------------------- QUIT -------------------------------------------- *

do_quit:

        clr.w   -(sp)                   ; Pterm0
        trap    #GEMDOS

* ---------------------- MFREE ------------------------------------------- *

do_mem_free:

* display number of bytes free

        moveq   #-1,d0
        bsr.w   Malloc                  ; get number of free bytes in d0

        moveq   #10,d1                  ; base 10
        moveq   #8,d2                   ; display 8 char
        lea     free_s+2,a0             ; there
        moveq   #SPACE,d3               ; replace leading zero by blank
        bsr.w   l_to_a

        lea     free_s,a0
        bra.w   prt_str                 ; show it

* ---------------------- DFREE ------------------------------------------- *

do_disk_free:

* display number of bytes free in the disk

        movea.l arg2,a0
        moveq   #0,d0
        move.b  (a0),d0                 ; drive letter
        beq.s   do_D_c                  ; no argument -> current drive
        subi.b  #'A'-1,d0               ; A -> 1, B -> 2...
do_D_c: bsr.w   disk_free               ; get free space
        tst.w   err_no                  ; error ?
        beq.s   do_D_0
        rts

do_D_0: moveq   #10,d1                  ; base 10
        moveq   #8,d2                   ; display 8 char
        lea     free_s+2,a0             ; there
        moveq   #SPACE,d3               ; replace leading zero by blank
        bsr.w   l_to_a

        lea     free_s,a0
        bra.w   prt_str                 ; show it

* ------------------------------------------------------------------------ *

disk_free:

* get disk free space for drive d0.w. upon return d0.l hold free space.

        move.w  d0,-(sp)                ; drive no.
        pea     d_free                  ; info about disk
        move.w  #$36,-(sp)              ; function number: Dfree
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.l   d0                      ; error ?
        bpl.s   d_f_0
        move.w  d0,err_no
        rts

d_f_0:  lea     d_free,a0
        move.l  8(a0),d0                ; sector size (in bytes)
        move.l  12(a0),d1               ; cluster size (in sector)
        mulu    d1,d0
        move.l  (a0),d1                 ; free cluster
        mulu    d1,d0                   ; free space in bytes
        rts

* ---------------------- DIR --------------------------------------------- *

do_dir:

* build directory and display directory to the screen

        movea.l arg2,a0
        tst.b   (a0)                    ; pathname in command string ?
        bne.s   doD_0
        lea     def_p,a0                ; no -> use default pathname

doD_0:  lea     work,a1                 ; copy pathname
        bsr.w   str_copy
        cmpi.b  #'\',-1(a1)             ; ended by backslash ?
        beq.s   doD_do
        move.b  #'\',(a1)+              ; no -> add backslash
        clr.b   (a1)

doD_do: lea     dir_of,a0               ; 'Directory of '
        bsr.w   prt_str
        lea     work,a0                 ; pathname -> default or in argument
        bsr.w   prt_str

        lea     any,a0
        bsr.w   str_copy                ; add "*.*"

        lea     two_ln,a0               ; 2 new line
        bsr.w   prt_str
        bra.w   directory               ; no -> display directory

* ------------------------------------------------------------------------ *

directory:

* display directory info to the screen. pathname hold in 'work'
* register not affected

        movem.l d0-d4/a0-a4,-(sp)

* first get dta buffer address

        move.w  #$2F,-(sp)              ; function number: Fgetdta
        trap    #GEMDOS                 ; get disk transfert address
        addq.l  #2,sp                   ; update stack
        move.l  d0,a3                   ; save dta address

* second search for the first file in the directory

        move.w  #-1,-(sp)               ; file affribute: any kind
        pea     work                    ; filemame
        move.w  #$4E,-(sp)              ; function number: Fsfirst
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.w   dir_x1                  ; no -> exit

        lea     work,a4                 ; one directory entry buffer
        bsr.w   get_dir                 ; get first name, size, date, time

dir_lp: move.b  #CR,(a4)+               ; end of line
        move.b  #LF,(a4)+
        clr.b   (a4)

        lea     work,a4                 ; reset a4
        movea.l a4,a0
        bsr.w   prt_str                 ; print this line

* now try an other entry in the directory

        lea     30(a3),a0               ; filemame in dta
        moveq   #12-1,d1                ; 12 bytes in the filename
dirERA: clr.b   (a0)+                   ; erase old filename
        dbra    d1,dirERA

        move.w  #$4F,-(sp)              ; function number: Fsnext
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.w   dir_x2                  ; no -> exit
        bsr.w   get_dir                 ; get next name, size, date, time
        bra.s   dir_lp                  ; loop while end of directory

dir_x1: cmpi.w  #-33,d0                 ; -33 mean 'file not found'
        bne.s   dirERR                  ; other value is error
        lea     nofile,a0               ; 'No file in this directory'
dir_NO: move.b  (a0)+,(a4)+             ; copy
        bne.s   dir_NO
        subq.l  #1,a4
        movem.l (sp)+,d0-d4/a0-a4
        rts

dir_x2: cmpi.w  #-49,d0                 ; -49 mean 'no more files'
        bne.s   dirERR                  ; other value is error
        movem.l (sp)+,d0-d4/a0-a4
        rts

dirERR: move.w  d0,err_no               ; display error message
        movem.l (sp)+,d0-d4/a0-a4
        rts

* ------------------------------------------------------------------------ *

get_dir:

* get filename, size, date and time, and put info into the string pointed
* by a4. upon return a4 point to the last char of info plus one.
* need 44 bytes by file. register affected d0-d4/a0/a4

* file name -------------------------------------------------------------- *

        lea     30(a3),a0               ; filemame in dta
        moveq   #12-1,d1                ; 12 bytes in the filename

g_name: move.b  (a0)+,d0                ; copy filename
        beq.s   g_null                  ; if null char -> replace by blank
        cmpi.b  #'.',d0                 ; dot ?
        beq.s   g_dot                   ; yes -> special case
        move.b  d0,(a4)+                ; else -> just copy the char
gname2: dbra    d1,g_name
        bra.s   g_dir2

g_null: move.b  #SPACE,(a4)+            ; replace by blank char
        dbra    d1,g_name
        bra.s   g_dir2

g_dot:  move.b  #SPACE,(a4)+            ; replace dot by blank char and
        cmpi.w  #3,d1                   ; fill will black up to the 3 last
        bls.s   gname2                  ; char of the filename
        dbra    d1,g_dot


g_dir2: move.b  #SPACE,(a4)+            ; two blanck space
        move.b  #SPACE,(a4)+

* file size or file type (for subdirectory or volume label) -------------- *

        btst    #3,21(a3)               ; volume label ?
        bne.s   g_vol

        btst    #4,21(a3)               ; subdirectory ?
        bne.s   g_sub

        move.l  26(a3),d0               ; file size
        moveq   #10,d1                  ; base 10
        moveq   #8,d2                   ; display 8 char
        movea.l a4,a0                   ; there
        moveq   #SPACE,d3               ; replace leading zero by blank
        bsr.w   l_to_a
        addq.l  #8,a4
        move.b  #SPACE,(a4)+            ; two more blanck space
        move.b  #SPACE,(a4)+
        bra.s   g_date

g_vol:  lea     volume,a0
g_vol1: move.b  (a0)+,(a4)+             ; copy '<<VOL>> '
        bne.s   g_vol1
        subq.l  #1,a4
        move.b  #SPACE,(a4)+            ; two more blanck space
        move.b  #SPACE,(a4)+
        bra.s   g_date

g_sub:  lea     subdir,a0
g_sub1: move.b  (a0)+,(a4)+             ; copy '<<DIR>> '
        bne.s   g_sub1
        subq.l  #1,a4
        move.b  #SPACE,(a4)+            ; two more blanck space
        move.b  #SPACE,(a4)+

* file date -------------------------------------------------------------- *

g_date: move.w  24(a3),d4               ; date stamp
        moveq   #0,d0
        move.w  d4,d0
        lsr.w   #5,d0                   ; month -> bits 5-8
        and.w   #%1111,d0               ; 4 bits only
        moveq   #10,d1                  ; base 10
        moveq   #2,d2                   ; display 2 char
        movea.l a4,a0                   ; there
        moveq   #'0',d3                 ; replace leading zero by zero!
        bsr.w   l_to_a
        addq.l  #2,a4
        move.b  #'-',(a4)+              ; one dash

        moveq   #0,d0
        move.w  d4,d0                   ; day -> bits 0-4
        and.w   #%11111,d0              ; 5 bits only
        moveq   #10,d1                  ; base 10
        moveq   #2,d2                   ; display 2 char
        movea.l a4,a0                   ; there
        moveq   #'0',d3                 ; replace leading zero by zero!
        bsr.w   l_to_a
        addq.l  #2,a4
        move.b  #'-',(a4)+              ; one dash

        moveq   #0,d0
        move.w  d4,d0
        moveq   #9,d1
        lsr.w   d1,d0                   ; year -> bits 9-15
        and.w   #%1111111,d0            ; 7 bits only
        addi.w  #1980,d0                ; plus base year
        moveq   #10,d1                  ; base 10
        moveq   #4,d2                   ; display 4 char
        movea.l a4,a0                   ; there
        moveq   #'0',d3                 ; replace leading zero by zero!
        bsr.w   l_to_a
        addq.l  #4,a4
        move.b  #SPACE,(a4)+            ; two more blanck space
        move.b  #SPACE,(a4)+

* file time -------------------------------------------------------------- *

        moveq   #0,d4
        move.w  22(a3),d4               ; time stamp

        moveq   #0,d0
        move.w  d4,d0
        moveq   #11,d1
        lsr.w   d1,d0                   ; hour -> bits 11-15
        and.w   #%11111,d0              ; 5 bits only
        cmpi.w  #12,d0                  ; AM or PM ?
        bls.s   g_hour
        subi.w  #12,d0                  ; here PM
        bset    #31,d4                  ; PM flag
g_hour: moveq   #10,d1                  ; base 10
        moveq   #2,d2                   ; display 2 char
        movea.l a4,a0                   ; there
        moveq   #'0',d3                 ; replace leading zero by zero!
        bsr.w   l_to_a
        addq.l  #2,a4
        move.b  #':',(a4)+              ; one colon

        moveq   #0,d0
        move.w  d4,d0                   ; minute -> bits 5-10
        lsr.w   #5,d0
        and.w   #%111111,d0             ; 5 bits only
        moveq   #10,d1                  ; base 10
        moveq   #2,d2                   ; display 2 char
        movea.l a4,a0                   ; there
        moveq   #'0',d3                 ; replace leading zero by zero!
        bsr.w   l_to_a
        addq.l  #2,a4
        move.b  #SPACE,(a4)+            ; one more space

        moveq   #'A',d0
        btst    #31,d4                  ; AM or PM ?
        beq.s   g_AMPM
        moveq   #'P',d0
g_AMPM: move.b  d0,(a4)+                ; fill with AM or PM
        move.b  #'M',(a4)+
        rts

*----------------------- COPY ---------------------------------------------*

do_copy:

* copy file (source pointed 'arg2' to destination pointed bu 'arg3')

        movea.l arg2,a0
        bsr.w   split_arg               ; split argument in 2 parts

        movea.l arg1,a0
        tst.b   (a0)                    ; pathname in first argument ?
        bne.s   doC_1
        move.w  #MISS,err_no
        bra.w   doC_er                  ; no -> error -> exit

doC_1:  lea     work,a1                 ; copy first argument
        bsr.w   str_copy

* next get last colon/backslack symbol to set the source pathname 

doC_p:  move.b  -(a1),d0
        cmpi.b  #'\',d0                 ; folder symbol ?
        beq.s   doC_s
        cmpi.b  #':',d0                 ; disk symbol ?
        beq.s   doC_s
        cmpa.l  #work,a1
        bhi.s   doC_p                   ; until start of first argument

        bra.s   doC_2                   ; no source pathname -> use default

doC_s:  addq.l  #1,a1
        clr.b   (a1)
        lea     work,a0                 ; pathname
        suba.l  a0,a1
        move.l  a1,d0
        add.l   d0,arg1                 ; keep only filename for future use
        bsr.w   set_path                ; set source pathname
        tst.w   err_no                  ; error ?
        bne.s   doC_er                  ; yes -> exit right now

* if second argument is empty use default pathname
* else if the drive is not specified use default drive

doC_2:  lea     work,a1                 ; destination to copy second arg.
        movea.l arg2,a0
        movea.l a0,a2
        tst.b   (a0)                    ; empty ?
        beq.s   doC_e
        cmpi.b  #':',1(a0)              ; drive specified ?
        beq.s   doC_ok
        move.b  def_p,(a1)+             ; default drive letter
        move.b  #':',(a1)+              ; plus colon
        bra.s   doC_ok

doC_e:  lea     def_p,a0                ; default pathname

doC_ok: bsr.w   str_copy

        moveq   #0,d4                   ; 'need add filename to dest.' flag
        movea.l a1,a4                   ; save end of argument
        move.b  -1(a1),d0
        cmpi.b  #'\',d0                 ; last char is folder symbol ?
        beq.s   doCadd                  ; yes -> need add filename to dest.
        cmpi.b  #':',d0                 ; last char is disk symbol ?
        bne.s   doC_3                   ; no -> no need add anything

doCadd: moveq   #-1,d4                  ; need add filename to dest.

doC_3:  lea     one_ln,a0               ; 1 new line
        bsr.w   prt_str
        bsr.w   copy                    ; copy and display copied file
        tst.w   err_no                  ; error ?
        bne.s   doC_er
        lea     one_ln,a0               ; 1 new line
        bsr.w   prt_str

doC_er: lea     def_p,a0                ; restore old current directory
        bra.w   set_path                ; set current path

*--------------------------------------------------------------------------*

copy:   bsr.w   mem_all                 ; reserve all free memory

* first get dta buffer address

        move.w  #$2F,-(sp)              ; function number: Fgetdta
        trap    #GEMDOS                 ; get disk transfert address
        addq.l  #2,sp                   ; update stack
        move.l  d0,a3                   ; save dta address

* now get a first file in the source directory

        movea.l arg1,a0                 ; if no filename i.e. type A:
        tst.b   (a0)                    ; or A:\NNN\ then get any file
        bne.s   c_1st
        move.l  #any,arg1

c_1st:  clr.w   -(sp)                   ; file affribute: normal
        move.l  arg1,-(sp)              ; source filemame
        move.w  #$4E,-(sp)              ; function number: Fsfirst
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.s   c_x1                    ; no -> error

* next search for another file in the source directory

c_next: bsr.w   copy_file               ; copy previous one
        tst.w   err_no                  ; error ?
        bne.s   c_x3                    ; yes -> release used memory, exit

        move.w  #$4F,-(sp)              ; function number: Fsnext
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.w   c_x2                    ; no -> exit
        bra.s   c_next                  ; loop while end of directory

c_x1:   move.w  d0,err_no
        movea.l m_free,a0
        bra.w   Mfree                   ; release used memory

c_x2:   cmpi.w  #-49,d0                 ; -49 mean 'no more files'
        bne.s   c_x1                    ; other value is error
c_x3:   movea.l m_free,a0
        bra.w   Mfree                   ; release used memory

*--------------------------------------------------------------------------*

copy_file:

* copy one file from source in dta (pointed by a3) to destination
* (pointed arg2).

        lea     copy_s,a0
        bsr.w   prt_str
        lea     30(a3),a0               ; filemame in dta
        bsr.w   prt_str                 ; display filename

        bsr.w   open                    ; open source file      
        tst.w   err_no
        bpl.s   c_f_r                   ; (read)
        rts                             ; error -> exit

c_f_r:  move.l  26(a3),d0               ; file size
        cmp.l   amount,d0               ; file to big ?
        bcc.w   c_f_m                   ; (memory problem)
        movea.l m_free,a0               ; buffer
        bsr.w   read                    ; read the file
        move.l  d0,d6                   ; save file size
        tst.w   err_no
        bmi.s   c_f_x

        bsr.w   close                   ; close the file
        tst.w   err_no
        bpl.s   c_f_d                   ; (destination)
        rts

c_f_d:  tst.w   d4                      ; need add filename to dest. ?
        beq.s   c_f_c                   ; no -> just create
        lea     30(a3),a0               ; filemame in dta
        movea.l a4,a1                   ; add filename there
        bsr.w   str_copy

c_f_c:  lea     work,a0
        bsr.w   create                  ; create destination file
        tst.w   err_no
        bpl.s   c_f_w                   ; (write)
        rts

c_f_w:  move.l  d6,d0                   ; file size
        movea.l m_free,a0               ; buffer
        bsr.w   write                   ; write the file
        cmp.l   d0,d6                   ; room for the file ?
        beq.w   close                   ; yes -> close the file and exit

        move.w  #FULL,err_no            ; no -> disk full
        rts
c_f_m:  move.w  #NO_MEM,err_no
c_f_x:  bra.w   close                   ; close the file and exit

* ---------------------- DEL --------------------------------------------- *

do_del:

* delete file

        movea.l arg2,a0
        tst.b   (a0)                    ; pathname in command string ?
        bne.s   do_D_1
do_D_m: move.w  #MISS,err_no            ; no -> error -> exit
        rts

do_D_1: movea.l arg2,a0
        lea     work,a1                 ; copy first argument
        bsr.w   str_copy

* get last colon/backslack symbol

do_D_p: move.b  -(a1),d0
        cmpi.b  #'\',d0                 ; folder symbol ?
        beq.s   do_D_s
        cmpi.b  #':',d0                 ; disk symbol ?
        beq.s   do_D_s
        cmpa.l  #work,a1
        bhi.s   do_D_p                  ; until start of first argument

        bra.s   do_D_2                  ; no source pathname -> use default

do_D_s: addq.l  #1,a1
        clr.b   (a1)
        lea     work,a0                 ; pathname
        suba.l  a0,a1
        move.l  a1,d0
        add.l   d0,arg2                 ; keep only filename for future use
        movea.l arg2,a1
        tst.b   (a1)                    ; nothing in filename ?
        beq.s   do_D_m

        bsr.w   set_path                ; set pathname
        tst.w   err_no                  ; error ?
        bne.s   do_Der                  ; yes -> exit right now

do_D_2: bsr.w   del_file                ; delete files

do_Der: lea     def_p,a0                ; restore old current directory
        bra.w   set_path                ; set current path

* ------------------------------------------------------------------------ *

del_file:

* delete file

        clr.b   alldel                  ; clear 'delete all flag'
        clr.b   cancel                  ; clear 'cancel delete' flag

* first get dta buffer address

        move.w  #$2F,-(sp)              ; function number: Fgetdta
        trap    #GEMDOS                 ; get disk transfert address
        addq.l  #2,sp                   ; update stack
        move.l  d0,a3                   ; save dta address

* second search for the first file in the directory

        clr.w   -(sp)                   ; file affribute: normal
        move.l  arg2,-(sp)              ; filename
        move.w  #$4E,-(sp)              ; function number: Fsfirst
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.s   delERR                  ; no -> exit
        bsr.w   one_delete              ; delete one file
        tst.w   err_no                  ; error ?
        bne.s   delERR
        tst.b   cancel                  ; cancel ?
        bne.s   del_c

* now try an other entry in the directory

del_lp: move.w  #$4F,-(sp)              ; function number: Fsnext
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.w   del_x                   ; no -> exit
        bsr.w   one_delete              ; get next name, size, date, time
        tst.w   err_no                  ; error ?
        bne.s   delERR
        tst.b   cancel                  ; cancel ?
        bne.s   del_c
        bra.s   del_lp                  ; loop while end of directory

del_x:  cmpi.w  #-49,d0                 ; -49 mean 'no more files'
        bne.s   delERR                  ; other value is error
        rts

delERR: move.w  d0,err_no               ; display error message
del_c:  rts

*--------------------------------------------------------------------------*

one_delete:

* ask to delete the file in dta (pointed by a3) and delete all file,
* the current file or exit according to the answer

        lea     del_s1,a0               ; 'Delete '
        bsr.w   prt_str
        lea     30(a3),a0               ; filemame in dta
        bsr.w   prt_str
        tst.b   alldel                  ; delete all file ?
        bne.w   delete                  ; yes -> skip question and answer
        tst.b   exeBAT                  ; executing batch file
        bne.w   delete                  ; yes -> skip too

        lea     del_s2,a0               ; ' ? (Yes, No, All, Cancel) '
        bsr.w   prt_str
        bsr.w   chr_in                  ; get answer
        cmpi.b  #'a',d0
        bcs.s   oneD_u
        sub.b   #'a'-'A',d0             ; make it upper case

oneD_u: cmpi.b  #'Y',d0
        beq.w   oneD_Y
        cmpi.b  #'N',d0
        beq.s   oneD_N
        cmpi.b  #'A',d0
        beq.s   oneD_A
        cmpi.b  #'C',d0
        beq.s   oneD_C
        bra.s   one_delete              ; get one clear answer

oneD_A: st      alldel                  ; set 'delete all flag'
oneD_Y: lea     30(a3),a0               ; filemame in dta
        bra.w   delete

oneD_C: st      cancel                  ; set 'cancel delete' flag
oneD_N: rts

* ---------------------- REN --------------------------------------------- *

do_ren:

* rename file

        movea.l arg2,a0
        bsr.w   split_arg               ; split argument in 2 parts

        movea.l arg1,a0
        tst.b   (a0)                    ; first argument must be a filename
        beq.s   doRer1
        movea.l arg2,a1
        tst.b   (a1)                    ; secong argument also
        beq.s   doRer1

        move.l  a1,-(sp)                ; new filename
        move.l  a0,-(sp)                ; filename to rename
        clr.w   -(sp)                   ; dummy
        move.w  #$56,-(sp)              ; 'Frename' function
        trap    #GEMDOS
        adda.w  #12,sp
        tst.w   d0                      ; error ?
        bne.s   doRer2
        rts

doRer1: move.w  #MISS,err_no            ; missing argument
        rts

doRer2: move.w  #NO_REN,err_no          ; cannot rename
        rts

* ---------------------- PATH -------------------------------------------- *

do_path:

* set current pathname

        movea.l arg2,a0
        tst.b   (a0)                    ; pathname in command string ?
        bne.s   do_P_1
        move.w  #MISS,err_no            ; no -> error -> exit
        rts

do_P_1: lea     def_p,a0
        clr.b   3(a0)                   ; keep only A:\
        bsr.w   set_path                ; to reset (old) drive pathname
        movea.l arg2,a0
        bsr.w   set_path                ; do it
        lea     def_p,a0                ; get complete pathname
        bra.w   get_path

* ---------------------- STOP -------------------------------------------- *

do_stop:

* stop batch file execution

        clr.b   exeBAT                  ; 'executing batch file now' flag
        rts

* ---------------------- WRITE ------------------------------------------- *

do_write:

* display message to the screen

        movea.l arg2,a0
        tst.b   (a0)                    ; pathname in command string ?
        bne.s   doW_1
        move.w  #MISS,err_no            ; no -> error -> exit
        rts

doW_1:  lea     one_ln,a0
        bsr.w   prt_str
        lea     revON,a0
        bsr.w   prt_str
        movea.l arg2,a0
        bsr.w   prt_str                 ; do it
        lea     revOFF,a0
        bra.w   prt_str

* ---------------------- SHOW/PRINT -------------------------------------- *

* output the file to the screen or printer
* key 'Q', 'q' or UNDO to stop and exit, other key to do a pause

do_print:
        move.w  #0,d4                   ; printer
        bsr.w   status                  ; printer ready ?
        tst.w   err_no
        beq.s   doSP_0
        rts                             ; no -> exit

do_show:
        move.w  #2,d4                   ; screen

doSP_0: moveq   #0,d5                   ; hold byte to show/print
        moveq   #0,d6                   ; logical column

        movea.l arg2,a0
        tst.b   (a0)                    ; pathname in command string ?
        bne.s   doSP_o
        move.w  #MISS,err_no            ; no -> error -> exit
        rts

doSP_o: bsr.w   open                    ; open source file      
        tst.w   err_no
        bpl.s   doSP_r                  ; (read)
        rts                             ; error -> exit

doSP_r: moveq   #80,d0                  ; read max. 80 bytes
        lea     work,a0                 ; in the work buffer
        bsr.w   read                    ; read the file
        tst.w   err_no                  ; error ?
        bmi.w   close                   ; yes -> close the file and exit
        tst.l   d0                      ; no byte read ?
        beq.w   close                   ; yes -> close the file and exit

        lea     work,a3                 ; hold the read file segment
        move.l  d0,d3                   ; number of bytes read
        subq.l  #1,d3

doSPlp: move.b  (a3)+,d5                ; byte read
        cmpi.b  #CR,d5                  ; carriage return ?
        beq.s   doSPcr
        cmpi.b  #LF,d5                  ; line feed ?
        beq.s   doSPlf
        cmpi.b  #TAB,d5                 ; TAB ?
        beq.s   doSPtb

doSP_n: bsr.w   output                  ; show/print
        tst.w   err_no                  ; error ?
        bne.w   close                   ; yes -> close the file and exit

doSP_u: addq.l  #1,d6                   ; update logical column
        dbra    d3,doSPlp
        bra.s   doSP_r                  ; loop while end of file

doSPtb: divu    #8,d6                   ; logical column/8
        swap    d6                      ; remaining in d6
        moveq   #8,d0
        sub.w   d6,d0                   ; number of blank to output
        subq.w  #1,d0
        move.w  d0,d6

doSPsp: moveq   #SPACE,d5
        bsr.w   output                  ; output the blank
        tst.w   err_no                  ; error ?
        bne.w   close                   ; yes -> close the file and exit
        bsr.w   pause                   ; get some input from user
        tst.w   d0                      ; exit ?
        bne.w   close                   ; yes -> close the file and exit
        dbra    d6,doSPsp
        moveq   #-1,d6                  ; reset logical column
        bra.s   doSP_u

doSPcr: moveq   #-1,d6                  ; reset logical column
        cmpi.b  #LF,(a3)                ; next is line feed ?
        beq.s   doSP_n                  ; yes -> normal show/print
        bsr.w   output                  ; else -> output the CR
        tst.w   err_no                  ; error ?
        bne.w   close                   ; yes -> close the file and exit
        moveq   #LF,d5
        bra.s   doSP_n                  ; and output LF too

doSPlf: moveq   #-1,d6                  ; reset logical column
        cmpi.b  #CR,-2(a3)              ; previous is carriage return ?
        beq.s   doSP_n                  ; yes -> normal show/print
        moveq   #CR,d5
        bsr.w   output                  ; else -> output the CR
        tst.w   err_no                  ; error ?
        bne.w   close                   ; yes -> close the file and exit
        moveq   #LF,d5
        bra.s   doSP_n                  ; and output LF too

*--------------------------------------------------------------------------*

output:

* output char in d5.w to the device no. d4.w

        move.w  d5,-(sp)                ; byte read
        move.w  d4,-(sp)                ; device
        move.w  #3,-(sp)                ; 'Bconout' functiom
        trap    #BIOS
        addq.l  #6,sp
        rts

*--------------------------------------------------------------------------*

status:

* check printer status.

        move.w  d4,-(sp)                ; device
        move.w  #8,-(sp)                ; 'Bcostat' functiom
        trap    #BIOS
        addq.l  #4,sp
        tst.w   d0                      ; printer ready ?
        bne.w   stat_x
        move.w  #NO_PRT,err_no          ; no -> error
stat_x: rts

*--------------------------------------------------------------------------*

pause:

* if a user keyboard input is available, then exit for 'Q', 'q' or Undo
* key and wait next iput for other key. In the first case exit with d0.w set
* else d0.w is clear. if no input is available then exit immediately
* with d0.w clear

        move.w  #$B,-(sp)               ; 'Cconis' function
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        tst.w   d0
        beq.s   pauseX                  ; no char available -> exit

        bsr.w   do_wait                 ; get input
        cmpi.b  #'Q',d0                 ; 'Q' ?
        beq.s   pauseQ
        cmpi.b  #'q',d0                 ; 'q' ?
        beq.s   pauseQ
        swap    d0
        cmpi.b  #$61,d0                 ; UNDO ?
        beq.s   pauseQ

        bsr.w   do_wait                 ; wait until a next input
        moveq   #0,d0
        rts

pauseQ: moveq   #-1,d0
pauseX: rts

* ---------------------- WAIT -------------------------------------------- *

do_wait:

* wait for next keyboard input in d0.l

        move.w  #7,-(sp)                ; 'Crawcin' function
        trap    #GEMDOS                 ; read the char
        addq.l  #2,sp                   ; update stack
        rts

* ---------------------- IF_EXIST and IF_NOT_EXIST ----------------------- *

* execute the next command only if file exist/not_exist and only when
* executing a batch file

do_if:  moveq   #0,d4
        bra.s   doI_0

do_if_not:

        moveq   #-1,d4

doI_0:  tst.b   exeBAT                  ; executing batch file ?
        bne.s   doI_1
        rts                             ; no -> exit

doI_1:  movea.l arg2,a0
        bsr.w   split_arg               ; split argument in 2 parts

        movea.l arg1,a0
        tst.b   (a0)                    ; first argument must be a filename
        beq.s   doI_er
        movea.l arg2,a1
        tst.b   (a1)                    ; secong argument must be command
        beq.s   doI_er

        move.w  #-1,-(sp)               ; file affribute: all kind
        move.l  a0,-(sp)                ; filemame
        move.w  #$4E,-(sp)              ; function number: Fsfirst
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack
        tst.w   d0                      ; file exist ?
        bne.s   doI_no                  ; no -> if 'do_if_not' -> ok

        tst.b   d4                      ; yes -> if 'do_if' -> ok
        beq.s   doI_x
        rts                             ; else -> do nothing

doI_no: tst.b   d4                      ; if 'do_if_not' -> ok
        bne.s   doI_x
        rts                             ; else -> do nothing

* here we must execute the command following the filename
* to do this we must reset the 'batPTR' pointer, actualy pointing to
* the next batch line. 'batPRV' is the pointer the start of the line
* holding the command to be executing

doI_x:  movea.l batPRV,a0               ; our batch line
        bsr.w   split_arg               ; split in 2 arguments
        movea.l arg2,a0                 ; skip first command
        bsr.w   split_arg               ; split again, skip filename
        move.l  arg2,batPTR             ; our command begin there
        rts

doI_er: move.w  #MISS,err_no
        rts

* ---------------------- CLS -------------------------------------------- *

do_cls:

* clear screen

        lea     cls_s,a0
        bra.w   prt_str

* ---------------------- ? (question mark -> help) ---------------------- *

do_inf:

* display the list of keyword

        lea     key_w,a1                ; the list

        moveq   #4,d2                   ; 5 keywords by line
        lea     one_ln,a0               ; one line
        bsr.w   prt_str

do_Ilp: tst.b   (a1)                    ; end of list ?
        beq.s   do_I_x                  ; yes -> exit

        movea.l a1,a0
        bsr.w   prt_str                 ; show the keyword

do_I_c: tst.b   (a1)+                   ; how many char
        bne.s   do_I_c
        move.l  a1,d0
        sub.l   a0,d0                   ; number of char including the null

        moveq   #20,d1
        sub.w   d0,d1
        moveq   #SPACE,d0               ; use room of 20 char
do_Isp: bsr.w   ch_out                  ; remainning of room with blank
        dbra    d1,do_Isp

        bra.s   do_Ilp                  ; while end of list

do_I_x: lea     one_ln,a0               ; one line
        bra.w   prt_str

*--------------------------------------------------------------------------*
*--------------------------- I/O routine ----------------------------------*
*--------------------------------------------------------------------------*

close:

* close file of handle d7.w
* register affected d0-d2/a0-a2

        move.w  d7,-(sp)        ; file handle
        move.w  #$3E,-(sp)      ; function number 'Fclose'
        trap    #GEMDOS
        addq.l  #4,sp           ; update stack
        tst.l   d0              ; error ?
        bmi.s   clo_er
        rts

clo_er: move.w  d0,err_no       ; d0 < 0 is error
        rts

*--------------------------------------------------------------------------*

read:

* read d0.l bytes into the buffer pointed by a0 from the of the file
* of handle d7.w upon return d0.l hold the number of bytes read.
* register affected d0-d2/a0-a2

        move.l  a0,-(sp)        ; buffer
        move.l  d0,-(sp)        ; length of buffer
        move.w  d7,-(sp)        ; file handle
        move.w  #$3F,-(sp)      ; function number 'Fread'
        trap    #GEMDOS
        adda.w  #12,sp          ; update stack
        tst.l   d0              ; error ?
        bmi.s   rd_er
        rts

rd_er:  move.w  d0,err_no       ; d0 < 0 is error
        rts

*--------------------------------------------------------------------------*

write:

* write on file printer. a0 is the pointer to the text buffer
* d0.l the length of the text buffer and d7.w the file handle
* upon return d0.l hold the number of bytes written.
* register affected d0-d2/a0-a2

        move.l  a0,-(sp)        ; buffer
        move.l  d0,-(sp)        ; length of buffer
        move.w  d7,-(sp)        ; file handle
        move.w  #$40,-(sp)      ; function number 'Fwrite'
        trap    #GEMDOS
        adda.w  #12,sp          ; update stack
        tst.l   d0              ; error ?
        bmi.s   wr_er
        rts

wr_er:  move.w  d0,err_no       ; d0 < 0 is error
        rts

*--------------------------------------------------------------------------*

create:

* create (and open) a file on disk, nul terminated filename is pointed by a0
* upon return file handle hold on d7.w
* register affected d0-d2/d7/a0-a2

        clr.w   -(sp)           ; R/W status
        move.l  a0,-(sp)        ; address of pathname or filename
        move.w  #$3C,-(sp)      ; function number 'Fcreate'
        trap    #GEMDOS
        addq.l  #8,sp           ; update stack
        tst.l   d0              ; error ?
        bmi.s   cr_er
        move.w  d0,d7
        rts

cr_er:  move.w  d0,err_no       ; d0 < 0 is error
        rts

*--------------------------------------------------------------------------*

open:

* open a file on disk. read or write. upon return d7.w hold the file
* handle. a0 is the pointer to the null terminated filename string
* register affected d0-d2/d7/a0-a2

        move.w  #2,-(sp)        ; can be read or write
        move.l  a0,-(sp)        ; address of pathname or filename
        move.w  #$3D,-(sp)      ; function number 'Fopen'
        trap    #GEMDOS
        addq.l  #8,sp           ; update stack
        tst.l   d0              ; error ?
        bmi.s   opn_er
        move.w  d0,d7
        rts

opn_er: move.w  d0,err_no       ; d0 < 0 is error
        rts

*--------------------------------------------------------------------------*

delete:

* delete the file of filename pointed by a0 a null terminated string
* register affected d0-d2/a0-a2

        move.l  a0,-(sp)        ; address of pathname or filename
        move.w  #$41,-(sp)      ; function number 'Fdelete'
        trap    #GEMDOS
        addq.l  #6,sp           ; update stack
        tst.l   d0              ; error ?
        bne.s   del_er
        rts

del_er: move.w  d0,err_no       ; d0 <> 0 is error
        rts

*--------------------------------------------------------------------------*

chr_in:

* read char from keyboard without echo to screen.
* upon return d0 (long) hold the value returned by the keyboard:
* scan code in high word, ascii code in low byte.
* register other than d0 not affected

        movem.l d1-d2/a0-a2,-(sp)       ; save register

        move.w  #1,-(sp)                ; 'Cconin' function
        trap    #GEMDOS                 ; read the char
        addq.l  #2,sp                   ; update stack

        movem.l (sp)+,d1-d2/a0-a2       ; restore register
        rts

*--------------------------------------------------------------------------*

ch_out:

* print char in d0.w to screen.
* register other than d0 not affected

        movem.l d0-d2/a0-a2,-(sp)       ; save register

        move.w  d0,-(sp)                ; the char
        move.w  #2,-(sp)                ; 'Cconout' function
        trap    #GEMDOS                 ; print the char
        addq.l  #4,sp                   ; update stack

        movem.l (sp)+,d0-d2/a0-a2       ; restore register
        rts

*--------------------------------------------------------------------------*

prt_str:

* print null terminated string pointed by a0
* register not affected

        movem.l d0-d2/a0-a2,-(sp)       ; save register

        move.l  a0,-(sp)                ; string address
        move.w  #9,-(sp)                ; Cconws
        trap    #GEMDOS                 ; print
        addq.l  #6,sp                   ; update stack

        movem.l (sp)+,d0-d2/a0-a2       ; restore register
        rts

* ------------------------------------------------------------------------ *

get_str:

* read a string of max length d0 (d0<256). a0 must point to the string.
* the readed string will be null terminated. a room of d0 + 3 bytes must be
* allowed for a string of length d0. upon return d0 is the number of char
* read and the cursor stay at the end of the string.
* other register not affected.

        movem.l d1-d2/a0-a3,-(sp)
        move.l  a0,a3                   ; save buffer address
        move.b  d0,(a3)                 ; put the max in the first byte

        pea     curSAV                  ; save cursor position
        move.w  #9,-(sp)                ; Cconws
        trap    #GEMDOS                 ; print
        addq.l  #6,sp                   ; update stack


        move.l  a3,-(sp)                ; get string
        move.w  #$A,-(sp)
        trap    #GEMDOS                 ; 'Cconrs' function
        addq.l  #6,sp

        pea     curRES                  ; restore cursor position
        move.w  #9,-(sp)                ; Cconws
        trap    #GEMDOS                 ; print
        addq.l  #6,sp                   ; update stack

        moveq   #0,d0
        move.b  1(a3),d0                ; number of char actually read
        beq.s   nil
        lea     2(a3),a1
        lea     rgt_s,a0                ; move one char right
        move.w  d0,d1
        subq.w  #1,d1
mov_lf: move.b  (a1)+,(a3)+             ; move read string 2 char left
        bsr.w   prt_str                 ; move cursor one char right
        dbra    d1,mov_lf
nil:    clr.b   (a3)                    ; the null
        movem.l (sp)+,d1-d2/a0-a3
        rts

*--------------------------------------------------------------------------*

Malloc:

* if d0.l = -1, return free memory in d0.l
* else reserve d0.l bytes space, upon return d0.l hold start address

        move.l  d0,-(sp)                ; reserve space
        move.w  #$48,-(sp)              ; function number 'Malloc'
        trap    #GEMDOS
        addq.l  #6,sp                   ; update stack
        tst.l   d0                      ; <= 0 is error
        bpl.s   Mal_x
        move.w  #NO_MEM,err_no
Mal_x:  rts

*--------------------------------------------------------------------------*

Mfree:

* relase memory reserved by Malloc at address a0

        move.l  a0,-(sp)                ; address of reserved memory
        move.w  #$49,-(sp)              ; function number 'Mfree'
        trap    #GEMDOS
        addq.l  #6,sp                   ; update stack
        tst.w   d0                      ; error ?
        beq.s   MfreeX
        move.w  d0,err_no
MfreeX: rts

*--------------------------------------------------------------------------*

set_drv:

* set drive d0.w to be current drive

        move.w  d0,-(sp)
        move.w  #$E,-(sp)               ; function number: Dsetdrv
        trap    #GEMDOS
        addq.l  #4,sp                   ; update stack
        rts

* ------------------------------------------------------------------------ *
* ------------------------------------------------------------------------ *

set_path:

* set current drive and subdirectory according the null terminated string
* pointed by a0. WARNING a0 string can be modified


        movea.l a0,a3                   ; save pointer
s_p_0:  tst.b   (a0)+
        bne.s   s_p_0                   ; get end of string
        cmpi.b  #'\',-2(a0)             ; string terminate by backslash
        beq.s   s_p_s
        move.b  #'\',-1(a0)             ; no -> add a backslash
        clr.b   (a0)

s_p_s:  movea.l a3,a0                   ; restore pointer
        cmpi.b  #':',1(a0)              ; drive specified ?
        bne.s   s_p_1

        moveq   #0,d0
        move.b  (a0),d0                 ; drive letter
        subi.b  #'A',d0                 ; A -> 0, B -> 1...
        move.b  d0,d3                   ; save it
        move.w  d0,-(sp)
        move.w  #$E,-(sp)               ; function number: Dsetdrv
        trap    #GEMDOS
        addq.l  #4,sp                   ; update stack
        btst    d3,d0                   ; bit set in drive map ?
        beq.s   s_pE1                   ; no -> error
        addq.l  #2,a3                   ; skip drive letter and colon

s_p_1:  pea     top                     ; reset pathname
        move.w  #$3B,-(sp)              ; function number: Dsetpath
        trap    #GEMDOS
        addq.l  #6,sp                   ; update stack
        tst.l   d0                      ; error ?
        bmi.s   s_pE2

        move.l  a3,-(sp)                ; pathname
        move.w  #$3B,-(sp)              ; function number: Dsetpath
        trap    #GEMDOS
        addq.l  #6,sp                   ; update stack
        tst.l   d0                      ; error ?
        bmi.s   s_pE2
        rts

s_pE1:  move.w  #-46,err_no             ; invalid drive specification
        rts

s_pE2:  move.w  d0,err_no               ; display error message
        rts

* ------------------------------------------------------------------------ *

get_path:

* get current drive and subdirectory in the buffer pointed by a0

        move.l  a0,-(sp)                ; save pointer

        move.w  #$19,-(sp)              ; function number: Dgetdrv
        trap    #GEMDOS
        addq.l  #2,sp                   ; update stack
        movea.l (sp),a0                 ; restore buffer pointer
        addi.b  #'A',d0                 ; A -> 0, B -> 1...
        move.b  d0,(a0)+                ; put drive letter in the buffer
        move.b  #':',(a0)+              ; add a colon

        clr.w   -(sp)                   ; current drive
        move.l  a0,-(sp)                ; buffer
        move.w  #$47,-(sp)              ; function number: Dgetpath
        trap    #GEMDOS
        addq.l  #8,sp                   ; update stack

        movea.l (sp)+,a0                ; restore buffer pointer
g_p_0:  tst.b   (a0)+
        bne.s   g_p_0                   ; get end of string
        cmpi.b  #'\',-2(a0)             ; string terminate by backslash
        beq.s   g_p_s
        move.b  #'\',-1(a0)             ; no -> add a backslash
        clr.b   (a0)
g_p_s:  rts

*--------------------------------------------------------------------------*

mem_all:

* reserve all free memory. return amount of free memory in 'amount'
* and start of free in 'm_free'  (always even address)
* or exit with error message

        moveq   #-1,d0                  ; get free memory
        bsr.w   Malloc
        subq.l  #1,d0
        move.l  d0,amount               ; amount of free memory
        bsr.w   Malloc                  ; reserve all free memory
        move.l  d0,m_free               ; store...
        rts

* ------------------------------------------------------------------------ *
* -------------------------- SOME TOOLS ---------------------------------- *
* ------------------------------------------------------------------------ *

str_copy:

* copy null terminated string pointed by a0 at the address a1.
* null is also copied. upon return both a0, a1 point to the null char.
* register affected d0/a0-a1.

str_c0: move.b  (a0)+,d0
        beq.s   str_cx
        move.b  d0,(a1)+                ; copy while not null
        bra.s   str_c0

str_cx: subq.l  #1,a0                   ; to the null
        clr.b   (a1)                    ; copy the null
        rts

* ------------------------------------------------------------------------ *

upper:

* make the null terminated string pointed by a0 upper case only
* register not affected

        movem.l d0/a0,-(sp)

up_lp:  move.b  (a0)+,d0
        beq.s   up_x                    ; exit at last char
        cmpi.b  #'a',d0
        bcs.s   up_lp                   ; forget char lower than 'a'
        cmpi.b  #'z',d0
        bhi.s   up_lp                   ; and char higher than 'z' too
        subi.b  #'a'-'A',-1(a0)         ; make char upper case
        bra.s   up_lp

up_x:   movem.l (sp)+,d0/a0
        rts

* ------------------------------------------------------------------------ *

compare:

* compare null terminated string pointed by a0 and a1.
* upon return a0 is set to the char after the null char of the string a0
* and d0 is set if the two string are same and clear otherwise.
* register affected d0/a0-a1

        move.b  (a0)+,d0
        beq.s   cmpNUL                  ; exit loop at last char of a0 str
        cmp.b   (a1)+,d0
        beq.s   compare                 ; loop while non-null char are same

cmp_0:  tst.b   (a0)+                   ; get end of a0 string
        bne.s   cmp_0

cmp_no: moveq   #0,d0                   ; string are not same
        rts

cmpNUL: tst.b   (a1)                    ; last char of a1 str is null too ?
        bne.s   cmp_no                  ; no -> not same

        moveq   #-1,d0                  ; yes -> string are same
        rts

* ------------------------------------------------------------------------ *

split_arg:

* split argument string (pointed by a0 and null terminated) up to 2 parts
* WARNING: each argument must be separate by a blank char, tab or white
* space and must be not contain null char between argument.
* upon return arg1, arg2 hold the pointer for each argument or a pointer
* to a null char if there is no argument. Each argument will be null
* terminated. register affected d0/a0

        sub.l   #1,a0

sA_1st: addq.l  #1,a0                   ; update string pointer
        move.b  (a0),d0                 ; get first char of first argument
        beq.s   sA_No1
        cmpi.b  #SPACE,d0               ; skip leading blank space
        beq.s   sA_1st
        cmpi.b  #TAB,d0
        beq.s   sA_1st
        move.l  a0,arg1                 ; fill arg1

sAlast: addq.l  #1,a0                   ; get last char of argument
        move.b  (a0),d0
        beq.s   sA_No2
        cmpi.b  #SPACE,d0
        beq.s   sAnext                  ; ready for next argument
        cmpi.b  #TAB,d0
        bne.s   sAlast

sAnext: clr.b   (a0)                    ; null terminated argument

sA_sec: addq.l  #1,a0                   ; update string pointer
        move.b  (a0),d0                 ; get first char of second argument
        beq.s   sA_No2
        cmpi.b  #SPACE,d0               ; skip leading blank space
        beq.s   sA_sec
        cmpi.b  #TAB,d0
        beq.s   sA_sec
        move.l  a0,arg2                 ; fill arg1
        rts

sA_No1: move.l  a0,arg1                 ; pointer to a null (no argument)
sA_No2: move.l  a0,arg2
        rts

*--------------------------------------------------------------------------*

l_to_a:

* long in d0 is converted to ascii in base d1.l at address a0 up to d2 char
* base in d1.l must be <= 16. leading zero are replace by char in d3
* for d3.l negative, a rotation is do such that the first char is non zero
* and leading zero (d3.b) are pushed right (to the end of the string)
* register not affected

        movem.l d0-d5/a0-a1,-(sp)
        lea     digit(pc),a1            ; digit ascii string
        adda.w  d2,a0
        subq.w  #1,d2                   ; char counter
        move.w  d2,d5
        move.l  d1,d4
        move.l  d0,d1

ltoa_l: move.l  d4,d0                   ; restore base
        bsr.w   div32                   ; division by base
        move.b  (0,a1,d0.w),-(a0)       ; digit to ascii
        tst.l   d1                      ; exit for leading zero
        beq.s   ltoa_j
        dbra    d2,ltoa_l               ; up to d2 char
        movem.l (sp)+,d0-d5/a0-a1
        rts

ltoa_j: tst.l   d3                      ; left justify ?
        bmi.s   ltoa_2
        bra.s   ltoa_0

ltoa_1: move.b  d3,-(a0)                ; replace leading 0 by char in d3
ltoa_0: dbra    d2,ltoa_1               ; up to d2 char
        movem.l (sp)+,d0-d5/a0-a1
        rts

ltoa_2: tst.w   d2
        beq.s   ltoa_x                  ; no other char to fill -> exit
        sub.w   d2,d5                   ; number of char -1 to move left
        movea.l a0,a1                   ; last digit address
        suba.w  d2,a0                   ; beginning of the string to fill
ltoa_3: move.b  (a1)+,(a0)+             ; move digit left
        dbra    d5,ltoa_3
        subq.w  #1,d2
ltoa_4: move.b  d3,(a0)+                ; fill remainning of string by d3.b
        dbra    d2,ltoa_4
ltoa_x: movem.l (sp)+,d0-d5/a0-a1
        rts

digit:  dc.b    "0123456789ABCDEF"

*--------------------------------------------------------------------------*

div32:

* (unsigned) divide long in d1 by long in d0. quotient is long in d1.
* remainder is long in d0. other register not affected.

        tst.l   d0
        beq.s   d32_er          ; division by zero

        cmp.l   d0,d1           ; d1 < d0 ?
        bcs.s   d32_NO

        cmpi.l  #$FFFF,d0       ; if d0 < $FFFF, need only word division
        bhi.s   l_div           ; otherwise long division

* here word division ------------------------------------------------------*

        movem.l d2-d3,-(sp)
        moveq   #0,d3
        divu    d0,d1           ; let d1 = $FFFF*y + x, d0 = x   here y.z/x
        bvc.s   w_d_ok          ; simple division d1 = r2.q2; q2 quotient
        move.l  d1,d2           ; d2 = y.z (if overflow d1 = y.z again)
        clr.w   d1              ; d1 = y.0
        swap    d1              ; d1 = 0.y
        divu    d0,d1           ; d1 = y/x = r1.q1; r1 remainder q1 quotient
        move.w  d1,d3           ; d3 = 0.q1
        move.w  d2,d1           ; d1 = r1.z
        divu    d0,d1           ; d1 = r1.z/x = r0.q0 ; q1 quotient
w_d_ok: move.l  d1,d0           ; d0 = r2.q2 or r0.q0
        swap    d1              ; d0 = q2.r2 or q0.r0
        move.w  d3,d1           ; d1 = q2.0 or q0.q1
        swap    d1              ; d1 = 0.q2 or q1.q0 real quotient
        clr.w   d0              ; d0 = r2.0 or 0.0
        swap    d0              ; d0 = 0.r2 or 0.r0 real remainder
        movem.l (sp)+,d2-d3
        rts

* here long division ------------------------------------------------------*

l_div:  movem.l d2-d4,-(sp)
        moveq   #0,d2           ; d2 hold quotient
        moveq   #0,d3           ; shift and bit number
        move.l  d0,d4           ; d4 is unmodified divisor
        bmi.s   l_d             ; if bit 31 is set skip next (note d1 >= d0)

l_d_1:  addq.b  #1,d3           ; else shift left d0 while bit 31 is not set
        lsl.l   #1,d0           ; (and update quotient bit no.)
        bpl.s   l_d_1
        cmp.l   d0,d1           ; if d1 >= d0 skip next
        bcc.s   l_d

l_d_2:  lsr.l   #1,d0           ; divide d0 by 2 while d0 > d1
        subq.b  #1,d3           ; update quotient bit no.
        cmp.l   d0,d1
        bcs.s   l_d_2

l_d:    bset    d3,d2           ; set bit no. in the quotient
        sub.l   d0,d1           ; new dividend
        cmp.l   d4,d1           ; loop while dividend >= divisor
        bcc.s   l_d_2

        move.l  d1,d0           ; remainder
        move.l  d2,d1           ; quotient
        movem.l (sp)+,d2-d4
        rts

d32_NO: move.l  d1,d0           ; remainder d1 when d0 > d1
        moveq   #0,d1           ; quotient = 0
d32_er: rts

* ------------------------------------------------------------------------ *
* ----------------------------- DATA and BSS ----------------------------- *
* ------------------------------------------------------------------------ *

        data

call:   dc.l    do_mem_free
        dc.l    do_disk_free
        dc.l    do_quit
        dc.l    do_dir
        dc.l    do_copy
        dc.l    do_del
        dc.l    do_ren
        dc.l    do_path
        dc.l    do_stop
        dc.l    do_write
        dc.l    do_show
        dc.l    do_print
        dc.l    do_wait
        dc.l    do_if
        dc.l    do_if_not
        dc.l    do_cls
        dc.l    do_inf

error:  dc.w    -2
        dc.l    readyN
        dc.w    -6
        dc.l    seekER
        dc.w    -8
        dc.l    sec_nf
        dc.w    -10
        dc.l    writeE
        dc.w    -11
        dc.l    readE
        dc.w    -13
        dc.l    protec
        dc.w    -16
        dc.l    secBAD
        dc.w    -17
        dc.l    insert
        dc.w    -32
        dc.l    funcNB
        dc.w    -33
        dc.l    f_n_f
        dc.w    -34
        dc.l    p_n_f
        dc.w    -35
        dc.l    access
        dc.w    -39
        dc.l    insuf
        dc.w    -46
        dc.l    driveI
        dc.w    -66
        dc.l    format
        dc.w    -993
        dc.l    prt_er
        dc.w    -994
        dc.l    ren_er
        dc.w    -995
        dc.l    noBAT
        dc.w    -996
        dc.l    unk_er
        dc.w    -997
        dc.l    var_er
        dc.w    -998
        dc.l    dkfull
        dc.w    -999
        dc.l    missng
        dc.w    0

title:  dc.b    13,10,"ABZ command shell, by Alain Birtz, feb. 89",10,0
wait_1: dc.b    27,'v',27,'e',13,10,27,'p',0
wait_2: dc.b    27,"q ",0
boot:   dc.b    "BOOT.BAT",0
free_s: dc.b    13,10,"________ bytes free",0
dir_of: dc.b    13,10,10,"Directory of ",0
nofile: dc.b    "No file in this directory",0
volume: dc.b    "<<VOL>> ",0
subdir: dc.b    "<<DIR>> ",0
any:    dc.b    "*.*",0
top:    dc.b    "\",0
two_ln: dc.b    10
one_ln: dc.b    13,10,0
revON:  dc.b    27,'p',0
revOFF: dc.b    27,'q',0
curSAV: dc.b    27,'j',0
curRES: dc.b    27,'k',0
cls_s:  dc.b    27,'E',0
rgt_s:  dc.b    27,'C',0
blank:  dc.b    9,9,9,0
copy_s: dc.b    13,10,"Copying ",0
del_s1: dc.b    13,10,"Delete ",0
del_s2: dc.b    " ? (Yes, No, All, Cancel) ",0

io_err: dc.b    13,10,10,"I/O error no "
io_no:  dc.b    "--  ",0
readyN: dc.b    "Drive not ready",0
seekER: dc.b    "Seek error, track not found",0
sec_nf: dc.b    "Sector not found",0
writeE: dc.b    "Write error",0
readE:  dc.b    "Read error",0
protec: dc.b    "Disquette write protected",0
secBAD: dc.b    "Bad sector",0
insert: dc.b    "Disquette not inserted",0
funcNB: dc.b    "Invalid function number",0
f_n_f:  dc.b    "File not found",0
p_n_f:  dc.b    "Path not found",0
access: dc.b    "Acces denied",0
insuf:  dc.b    "Insufficient memory",0
driveI: dc.b    "Invalid drive specification",0
format: dc.b    "Invalid file format",0
noBAT:  dc.b    "No embedded batch file",0
unk_er: dc.b    "Unknow command",0
var_er: dc.b    "Undefined variable (type %1, %2, ...)",0
dkfull: dc.b    "Probably disk full",0
missng: dc.b    "Missing argument",0
ren_er: dc.b    "Cannot rename file",0
prt_er: dc.b    "Printer not ready",0

key_w:  dc.b    "MFREE",0
        dc.b    "DFREE",0
        dc.b    "QUIT",0
        dc.b    "DIR",0
        dc.b    "COPY",0
        dc.b    "DEL",0
        dc.b    "REN",0
        dc.b    "PATH",0
        dc.b    "STOP",0
        dc.b    "WRITE",0
        dc.b    "SHOW",0
        dc.b    "PRINT",0
        dc.b    "WAIT",0
        dc.b    "IF_EXIST",0
        dc.b    "IF_NOT_EXIST",0
        dc.b    "CLS",0
        dc.b    "?",0
        dc.b    0

ext:    dc.b    "PRG",0
        dc.b    "TOS",0
        dc.b    "TTP",0
        dc.b    "IMG",0
        dc.b    "BAT",0
        dc.b    0

        even

        bss

bpcl:   ds.l    1                       ; base page command line pointer
        ds.l    100
ustk:   ds.l    1
amount: ds.l    1                       ; how much free memory
m_free: ds.l    1                       ; start of free memory
d_free: ds.l    4                       ; used in disk free calculation
dta:    ds.l    1                       ; disk transfert address
arg1:   ds.l    1                       ; argument pointer
arg2:   ds.l    1
parPTR: ds.l    5                       ; parameter pointer table
batBUF: ds.l    1                       ; start of batch file buffer
batPTR: ds.l    1                       ; pointer to current line in batch
batPRV: ds.l    1                       ; pointer to previous line in batch
bat_LN  ds.l    1                       ; one batch line
param:  ds.l    1                       ; parameter buffer
err_no: ds.w    1                       ; error no.
cancel: ds.b    1                       ; 'Cancel' flag
alldel: ds.b    1                       ; 'delete all file' flag
cmd_ch: ds.b    1                       ; 'is command char' flag
exeBAT: ds.b    1                       ; 'executing batch file now' flag
def_p:  ds.b    80                      ; pathname buffer
cmd:    ds.b    80                      ; user command buffer
work:   ds.b    80                      ; general purpose work buffer
