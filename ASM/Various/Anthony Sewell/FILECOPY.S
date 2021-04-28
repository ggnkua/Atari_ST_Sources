*************************************************
*       FILECOPY ½1987 by Anthony Sewell        *
*       Assembled with GST assembler            *
*       Linked with Devpac 2 linker!            *
*       (c) Atari ST User, Dec 1989.            *
*************************************************
        section   code          *text/code

******************Give back memory to Gemdos***************
        move.l    4(sp),a5      *get basepage addr
        move.l    #400000,a6    *keep most of mem
        move.l    a6,sp         *put stack at top
        sub.l     a5,a6         *calc byte total
        move.l    a6,-(sp)      *num of bytes
        move.l    a5,-(sp)      *start of prog
        clr.w     -(sp)         *dummy word
        move.w    #$4a,-(sp)    *release mem
        trap #1
        add.l     #12,sp
**********************Hide mouse/Clear screen*************
          dc.w $a000            *init A-Line data table
          dc.w $a00a            *call Hide Mouse          
          move.l  #mess01,a6    *>N.B. This initial>
          bsr     txt_out       *>message and pause>  
          bsr     in            *>may be omitted.<<
          move.l    #cls,a6     *VT52 Clear screen
          bsr       txt_out
********************Set disc transfer buffer************
          move.l    #dta,-(sp)  *Disc transf buff
          move.w    #$1a,-(sp)  *Set dta code
          trap #1
          addq.l    #6,sp
*******************Get directory***********************
          move.w    #0,-(sp)            *is read/write file    
          move.l    #filename,-(sp) 
          move.w    #$4e,-(sp)          *Search first code
          trap #1
          addq.l    #8,sp
          move.l    #length,a3          *point file leng buff
          move.l    #dir,a5             *point dir buff
getf:     move.l    dta+26,(a3)+        *store length
          move.l    #dta+30,a4          *point name
get1:     move.b    (a4)+,(a5)+         *move to dir
          tst.b     (a4)                *end of name?
          bne       get1
          clr.b     (a5)+               *zero at end
          move.w    #$4f,-(sp)          *Search next
          trap #1                       *{ d0 returns   }
          addq.l    #2,sp               *{ zero if file }
          tst.l     d0                  *{  is found    }
          beq       getf
*******************Print directory********************
          clr.w     d4          *file count
          move.l    #31,d3      *row position-1
          move.l    #dir,a5     *directory buff
again:    addq.l    #1,d4       *inc file num.
          cmp.w     #21,d4      *end of column?
          blt       num
          move.l    #cursm,a6   *VT52 postn curs
          addq.b    #1,d3       *inc row position
          move.b    d3,colm
          bsr       txt_out
**                 Print file number        **
num:      move.l    d4,d7       *process in d7
          move.l    #nbuff,a6   *point buff end
          clr.b     (a6)        *zero at end
          move.b    #32,-(a6)   *preceded by space   
num1:     move.l    d7,d6
          divu.w    #10,d6      *{quotient is in
          move.w    d6,d7       *low word - remdr
          swap      d6          *in high word}
          addi.w    #$30,d6     *form ASCII code
          move.b    d6,-(a6)    *buff grows down
          cmp.w     #0,d7       *all done?
          bne       num1
          bsr       txt_out     *print number
**               End of number print       **  
          move.l    a5,a6       *get dir buff
          bsr       txt_out     *print name
          tst.b     (a6)        *all done?   
          beq       select
          move.l    a6,a5       *save dir buff
          move.l    #newln,a6   *cr/lf
          bsr       txt_out
          bra       again
**********************Select files**********************
select:   move.b    #53,colm    *position
          move.b    #35,colm+1
          move.l    #cursm,a6   *cursor
          bsr       txt_out
          move.l    #mess02,a6  *print select
          bsr       txt_out     *message
          move.l    #pathbf,a4  *point names
          move.l    #length,a3  *point bytes
sel2:      clr.l     d7
sel3:      bsr       in         *get digit
          cmp.b     #13,d0      *return?
          beq       sel4
          sub.b     #$30,d0     *ASCII to Bin
          mulu      #10,d7      *for place value
          add.b     d0,d7       *new units
          bra sel3              *get rest ofnum
sel4:     tst.b     d7          *just return?
          beq       selecin
          move.l    #dir,a5     *point dir
          move.w    d7,-(sp)    *save count
sel1:     subq.b    #1,d7       *count files
          beq       sel5
sel6:     tst.b     (a5)+       *find zero
          bne       sel6
          bra       sel1
sel5:     move.l    #clearln,a6 *clear line
          bsr       txt_out
          move.l    a5,a6
          bsr       txt_out
          move.l    a5,(a4)+    *name pointer
          move.w    (sp)+,d5    *get count
          mulu      #4,d5       *calc offset
          addi.l    #length-4,d5        *form addr
          move.l    d5,a6       *pointer in a6
          move.l    (a6),(a3)+  *store length
          bra       sel2
**********************Open and Read files**********
selecin:  move.l    #pathbf,a4
          move.l    #length,a3
          move.l    #databuff,d4
lec1:     move.w    #2,-(sp)    *read/write
          move.l    (a4)+,-(sp) *point name
          move.w    #$3d,-(sp)  *open
          trap      #1
          addq.l    #8,sp       *handle is in d0
          move.w    d0,-(sp)    *save it to stack
**         read           ******
          move.l    d4,-(sp)    *data buff
          add.l     (a3),d4     *inc buff by length
          move.l    (a3)+,-(sp) *bytes to read
          move.w    8(sp),-(sp) *handle
          move.w    #$3f,-(sp)  *read
          trap      #1
          add.l     #12,sp
**         close                 *****
**         (handle is on stack)  *****
          move.w    #$3e,-(sp)  *close
          trap      #1
          addq.l    #4,sp
          tst.l     (a4)
          bne       lec1
*******************Create and Write files********************
          move.l    #mess03,a6
          bsr       txt_out
          bsr       in
          move.l    #pathbf,a4
          move.l    #length,a3
          move.l    #databuff,d4
copy:     move.w    #0,-(sp)    *read/write
          move.l    (a4)+,-(sp) *point name
          move.w    #$3c,-(sp)  *create
          trap      #1
          addq.l    #8,sp       *handle is in d0
          move.w    d0,-(sp)    *save it to stack
**         write                  ******
          move.l    d4,-(sp)    *data buff
          add.l     (a3),d4     *inc buff by length
          move.l    (a3)+,-(sp) *bytes to read
          move.w    8(sp),-(sp) *handle
          move.w    #$40,-(sp)  *write
          trap      #1
          add.l     #12,sp
**         close                 *****
**         (handle is on stack)  *****
          move.w    #$3e,-(sp)  *close
          trap      #1
          addq.l    #4,sp
          tst.l     (a4)
          bne       copy 
*********************Return to desktop***********************    
          move.w    #0,-(sp)
          trap #1               *Warmstart/End
*************************************************************
**********************Subroutines****************************
txt_out:  move.b    (a6)+,d5    *Get byte from buff
          tst.b     d5          *0?
          beq       done        *Yes?Then end
          move      d5,-(sp)    *Byte onto stack
          move.w    #2,-(sp)    *Print char
          trap      #1
          addq.l    #4,sp       *tidy stack
          bra       txt_out
done:     rts
in:       move.w    #1,-(sp)    *get key-
          trap #1                 
          addq.l    #2,sp
          rts
*        data                   *initialised data
newln:    dc.b 13,10,0
cls:      dc.b 27,'E',0
clearln:  dc.b 27,'l',0
mess01: dc.b 27,69,'Insert source disk,then press any key',27,118,13,10,0
mess02:   dc.b 'In numerical sequence, type and <RETURN> the number'
          dc.b ' of each file you wish to '
          dc.b 'copy. Just type <RETURN> when finished.',13,10,0
mess03: dc.b 27,69,'Insert destination disk, then press any key',13,10,0
cursm:    dc.b 27,89 
colm:     dc.b 32,58,0
filename: dc.b '*.*',0
dir:      dcb.l 165,0
*         cnop 0,2      *even
dta:      dcb.b  45,0
pathbf:   dcb.l  10,0
*         bss           *block storage section
          ds.b 11
nbuff:    ds.b 1
length:   ds.l 50
databuff: ds.b 1
          end
