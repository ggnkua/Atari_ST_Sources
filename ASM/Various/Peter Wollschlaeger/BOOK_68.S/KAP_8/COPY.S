* Kopierprogramm zu Auto-RAM-Disk
* ===============================
* (c) 1986 Markt & Technik
* by Peter Wollschlaeger
;---------------------------------------------------
;macros for GEMDOS-functions:

create  macro                   ;create new file
        move    #0,-(sp)        ;rw status
        pea     \1              ;Filename
        move    #$3C,-(sp)
        trap    #1
        addq.l  #8,sp
        move    d0,\2           ;save handle
        endm

open    macro                   ;open existing file
        move    #0,-(sp)        ;r status
        pea     \1              ;Filename
        move    #$3D,-(sp)
        trap    #1
        addq.l  #8,sp
        move    d0,\2           ;save handle
        endm

close   macro                   ;close file
        move    \1,-(sp)        ;push handle   
        move    #$3E,-(sp) 
        trap    #1
        addq.l  #4,sp
        endm

read    macro                   :read file
        pea     \1              ;adress buffer
        move.l  \2,-(sp)        ;file size to read
        move    \3,-(sp)        ;handle 
        move    #$3F,-(sp)      
        trap    #1
        add.l   #12,sp
        move.l  d0,\4           ;return size read
        endm

write   macro                   ;write file 
        pea     \1              ;adress buffer
        move.l  \2,-(sp)        ;file size
        move    \3,-(sp)        ;handle 
        move    #$40,-(sp)      
        trap    #1
        add.l   #12,sp
        endm

setdta  macro                   ;set disk transf adr
        pea    \1               ;adress dta buffer
        move    #$1A,-(sp)
        trap    #1
        addq.l  #6,sp
        endm

sfirst  macro                   ;search first file
        move    #0,-(sp)        ;atrib = normal
        pea     \1              ;file name
        move    #$4E,-(sp)
        trap    #1
        addq.l  #8,sp
        tst     d0
        endm

snext   macro                   ;search next file
        move   #$4F,-(sp);
        trap   #1
        addq.l #2,sp
        tst    d0
        endm

writes  macro                   ;print line
        pea     \1
        move.w  #9,-(sp) 
        trap    #1
        addq.l  #6,sp
        endm

ertest  macro                   ;error test
        tst     d0
        bmi     error
        endm
*------------------------------------------------
start   writes  msg           ;main loop
        setdta  dta
        sfirst  source        ;search 1th file
        bne     done          ;if none
        bsr     copy          ;else copy
loop    snext                 ;search next
        bne     done          ;if last
        bsr     copy
        bra     loop          ;else loop

done    clr     -(sp)         ;terminate
        trap    #1
*------------------------------------------------
copy    writes  name
        writes  crlf    
        move.l  #name,a1      ;put name in dta
        move.l  #sfile,a2     ;after pathname
        move    #13,d1
lp1     move.b  (a1)+,(a2)+
        dbra    d1,lp1

        open    source,d7     ;read source
        ertest
        read    buffer,size,d7,d1
        ertest
        close   d7
        ertest
        move.b  #'C',c        ;put 'C:\'
                              ;Hier aendern, wenn andern
                              ;Ziel-Drive **************
        move.b  #':',colon    ;before name
        move.b  #'\',slash

        create  c,d7          ;create new file
        ertest
        write   buffer,d1,d7  ;and write it
        ertest
        close   d7
        ertest
        rts                   ;that's all folks            
*------------------------------------------------
error   writes  ermsg
        move    #1,-(sp)
        trap    #1
        addq.l  #2,sp
        bra     done
        data
source  dc.b    'a:\rdfile\'
sfile   dc.b    '*.*',0
        dc.b    '          '   ;10 Blanks
msg     dc.b    27,'E Copying',13,10,0
        ds.w    0
crlf    dc.b    13,10,0
        ds.w    0
ermsg   dc.b    13,10,'Abbruch wegen Disk-I/O-Fehler'
        dc.b    13,10,'Druecke eine Taste ... ',0
        bss
dta     ds.b    26
size    ds.b    1
c       ds.b    1
colon   ds.b    1
slash   ds.b    1
name    ds.b    14

buffer  equ     *
        end        

        
