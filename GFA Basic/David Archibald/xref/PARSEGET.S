******************************************************************************
*          main loop for parse_line & get_whatever in gfa_xref.bas.
*                            Copyright (c) 1987
*                            by David Archibald
******************************************************************************
*
* calling syntax:  call addr%(starting_pos%,len(string$)+1,string$,addr%)
*
******************************************************************************
*
*
             .text

             move.l     6(sp),a1               *ptr to parameters.
             move.l     (a1)+,d0               *position in the string.
             move.l     (a1)+,d3               *the string's length.
             move.l     (a1)+,a0               *and the addr of the string.
             move.l     (a1),a1                *this program's address.
             clr.b      start(a1)              *init the data area.
             clr.b      end(a1)
             clr.b      char(a1)

get_start:
             cmp.w      d0,d3
             bls        EOL_exit               *end of string yet?
             move.b     -1(a0,d0.w),d1
             cmp.b      #$22,d1                *check for an opening quote.
             beq        quote
             cmp.b      #'!',d1                *rest of line is a remark-exit.
             beq        EOL_exit
             cmp.b      #'a',d1                *if it's not lower case, then
             blt        cont                    it's not a var/proc/label.
             cmp.b      #'z',d1                *it's between a-z, so it's the
             ble        find_end                beginning of a var/proc/label.

cont:
             addq.w     #1,d0
             bra        get_start

EOL_exit:
             move.b     #-1,start(a1)          *flag: end of the line reached.
             rts

find_end:
             move.b     d0,start(a1)           *save where the var/proc/label
*                                               starts.
get_end:
             addq.w     #1,d0
             move.b     -1(a0,d0.w),d1
             cmp.b      #'!',d1                *part of the var--keep looking.
             beq        get_end
             cmp.b      #'$',d1                *part of the var--keep looking.
             beq        get_end
             cmp.b      #'%',d1                *part of the var--keep looking.
             beq        get_end
             cmp.b      #'_',d1                *part of the var--keep looking.
             beq        get_end
             cmp.b      #'0',d1                *not part of the var/proc/label
             blt        exit                    so git!
             cmp.b      #'9',d1                *between 0 and 9, that's ok.
             ble        get_end
             cmp.b      #'a',d1                *if it's not between a-z, exit.
             blt        exit
             cmp.b      #'z',d1
             bgt        exit
             cmp.w      d0,d3
             bhi        get_end                *loop until the end of the str.

exit:
             move.b     d0,end(a1)             *where the var/proc/label ends.
             move.b     d1,char(a1)            *save the last char checked.
             rts

quote:
             addq.w     #1,d0                  *loop until the closing quote
             move.b     -1(a0,d0.w),d1          is found.
             cmp.b      #$22,d1
             bne        quote
             bra        cont

start:
             dc.b       0
end:
             dc.b       0
char:
             dc.b       0
             .end
