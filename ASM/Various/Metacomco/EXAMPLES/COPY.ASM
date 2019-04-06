****************************************************************************
*                                                                          *
* COPY - system utility tool for MENU+                ½ Metacomco plc 1988 *
*                                                                          *
****************************************************************************
*
         INCLUDE  'OSBIND.I'        ; System include file
         INCLUDE  'ERROR.I'         ; System errors include file
*
         TEXT
*
* Set up the memory
*
         move.l   4(a7),a3          ; get address of base page
         move.l   p_tlen(a3),d0     ; length of code +
         add.l    p_dlen(a3),d0     ; length of data +
         add.l    p_blen(a3),d0     ; length of bbs +
         add.l    #$1200,d0         ; base page + buffer + stack
         lea      0(a3,d0.l),a7     ; set stack pointer
         move.l   d0,-(a7)          ; arguments: length
         move.l   a3,-(a7)          ;            start
         move.w   #0,-(a7)          ;
         move.w   #mshrink,-(a7)    ; shrink memory
         trap     #gemdos           ;
         lea      12(a7),a7         ;
*
* Read parameters
*
         lea      p_cmdlin(a3),a0   ; get address of command tail
         move.b   (a0)+,d0          ; get length of command tail

         bsr      FINDARG           ;
         move.l   a0,INNAME         ; get source name
         bsr      FINDEND           ;

         bsr      FINDARG           ;
         move.l   a0,OUTNAME        ; get destination name
         bsr      FINDEND           ;
COPY
         lea      -$1100(a7),a0     ;
         move.l   a0,BUFFER         ; save address of buffer

         move.l   INNAME,a0         ;
         bsr      OPEN              ; open source file
         tst.l    d0                ;
         blt      EXIT1             ; exit if failed
         move.w   d0,FILEIN         ; save file handle

         move.l   OUTNAME,a0        ;
         bsr      CREATE            ; create destination file
         tst.l    d0                ;
         blt.s    EXIT0             ; exit if failed
         move.w   d0,FILEOUT        ; save file handle

                                    ; set up stack for read trap
         move.l   BUFFER,-(a7)      ; address of buffer
         move.l   #$1000,-(a7)      ; number of bytes to read
         move.w   FILEIN,-(a7)      ; source file handle
         move.w   #fread,-(a7)      ; trap number
COPY1
         trap     #gemdos           ; leave parameters on the stack
         tst.l    d0                ; did it work ?
         ble.s    COPY2             ; branch if so

         move.l   BUFFER,-(a7)      ;
         move.l   d0,-(a7)          ; number of bytes read
         move.l   d0,d3             ; save this
         move.w   FILEOUT,-(a7)     ;
         move.w   #fwrite,-(a7)     ;
         trap     #gemdos           ; write buffer to destination file
         lea      12(a7),a7         ;
         tst.l    d0                ; did it work ?
         blt.s    COPY2             ; branch if error

         cmp.l    d0,d3             ; were all bytes copied ?
         beq.s    COPY1             ; branch if yes
         move.l   #ERROR,d0         ; used for disk full
COPY2
         lea      12(a7),a7         ; finally restore stack

         move.w   FILEOUT,a0        ;
         bsr      CLOSE             ; close destination file
EXIT0
         move.w   FILEIN,a0         ;
         bsr      CLOSE             ; close source file

         tst.l    d0                ; look at return code
         beq.s    RETURN            ; branch if not an error
EXIT1
         cmp.l    #EWRITF,d0        ;
         bne.s    EXIT2             ;
         lea.l    READERR,a1        ; Read error
         bsr      WAIT              ;
EXIT2
         cmp.l    #EREADF,d0        ;
         bne.s    EXIT3             ;
         lea.l    WRITEERR,a1       ; Write error
         bsr      WAIT              ;
EXIT3
         cmp.l    #ERROR,d0         ;
         bne.s    EXIT4             ;
         lea.l    DISKFULL,a1       ; Disk full
         bsr      WAIT              ;
EXIT4
         cmp.l    #EUNCMD,d0        ;
         bne.s    EXIT5             ;
         lea.l    BADPARAM,a1       ; Bad parameters
         bsr      WAIT              ;
EXIT5
         cmp.l    #EFILNF,d0        ;
         bne.s    EXIT6             ;
         lea.l    NOTFOUND,a1       ; File not found
         bsr      WAIT              ;
EXIT6
         lea.l    OTHERERR,a1       ; Some other error
         bsr      WAIT              ;

RETURN
         move.w   d0,-(a7)          ; return error code
         move.w   #pterm,-(a7)      ; terminate
         trap     #gemdos           ;
*
* service routines
*
OPEN
         move.w   #A_READWRITE,-(a7)
         move.l   a0,-(a7)          ; stack address of filename
         move.w   #fopen,-(a7)      ;
         trap     #gemdos           ;
         addq     #8,a7             ;
         rts                        ;
CREATE
         move.w   #A_READWRITE,-(a7)
         move.l   a0,-(a7)          ; stack address of filename
         move.w   #fcreate,-(a7)    ;
         trap     #gemdos           ; 
         addq     #8,a7             ;
         rts                        ;
CLOSE
         move.l   d0,-(a7)          ; save return code
         move.w   a0,-(a7)          ; stack file handle
         move.w   #fclose,-(a7)     ; 
         trap     #gemdos           ;
         addq     #4,a7             ;
         move.l   (a7)+,d0          ; restore return code
         rts                        ;
*
* d0 number of chars left
* a0 pointer to next char
*
FINDARG                             ; look for start of argument
         tst.b    d0                ;
         beq.s    FIND3             ;

         tst.b    (a0)              ;
         beq.s    FIND1             ;
         cmp.b    #' ',(a0)         ;
         beq.s    FIND1             ;
         cmp.b    #$9,(a0)          ; is it a tab ?
         bne.s    FIND2             ;
FIND1
         addq     #1,a0             ;
         subq     #1,d0             ;
         bra.s    FINDARG           ;
FIND2
         rts                        ;
FIND3
         move.l   #EUNCMD,d0        ; set code for bad parameters
         bra      EXIT1             ;
*
FINDEND                             ; look for end of argument
         tst.b    d0
         beq.s    FIND4             ;
 
         cmp.b    #' ',(a0)         ;
         beq.s    FIND4             ;
         cmp.b    #$9,(a0)          ; is it a tab ?
         beq.s    FIND4             ;

         addq     #1,a0             ;
         subq     #1,d0             ;
         bra.s    FINDEND           ;
FIND4
         move.b   #0,(a0)           ; set null terminator
         rts                        ;
*
* Routine to write out the string pointed to by a1
*
WRITE   
         move.l     a1,-(a7)        ;
         move.w     #cconws,-(a7)   ;
         trap       #gemdos         ;
         addq.l     #6,a7           ;
         rts                        ;
*
* Routine to wait for a character to be typed
*
WAIT
         move.l     d0,-(a7)        ; save return code
         bsr        WRITE           ; output message
         lea.l      TYPECHAR,a1     ;
         bsr        WRITE           ; output prompt
*
         move.w     #2,-(a7)        ; keyboard device
         move.w     #bconin,-(a7)   ; read character
         trap       #bios           ;
         addq.l     #4,a7           ;
         move.l     (a7)+,d0        ; restore return code
         bra        RETURN          ; exit from program
*
*******************************************************************************
*
         DATA
*
TYPECHAR DC.B     $d,$a,'Press any key to continue',0
READERR  DC.B     $d,$a,'Read error occured',0
WRITEERR DC.B     $d,$a,'Write error occured',0
DISKFULL DC.B     $d,$a,'Disk full',0
NOTFOUND DC.B     $d,$a,'File not found',0
BADPARAM DC.B     $d,$a,'Bad parameters',0
OTHERERR DC.B     $d,$a,'Error whilst copying',0
*
         BSS
*
BUFFER   DS.L     1                 ; buffer for copying file
INNAME   DS.L     1                 ; address of source file name
OUTNAME  DS.L     1                 ; address of destination file name
FILEIN   DS.W     1                 ; source file handle
FILEOUT  DS.W     1                 ; destination file handle
*
         END
