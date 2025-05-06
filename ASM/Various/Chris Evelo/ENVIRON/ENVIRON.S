        .text
*housekeeping
        move.l  a7,a5
        move.l  4(a5),a5        ;compute size for TSR call
        move.l  $c(a5),d6       ;text
        add.l   $14(a5),d6      ;data
*       add.l   $1c(a5),d6      ;bss
        add.l   #$100,d6        ;basepage
        add.l   #$40,d6         ;saftey
*open
        move.w  #0,-(sp)
        pea     envfstr
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,handl
        blt     bexit
*read
        pea     workar
        move.l  #8192,-(sp)
        move.w  handl,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.l   #12,sp
        add.w   d0,d6           ;length of used BSS = length of file
        move.l  #workar,a0
        add.w   d0,a0           ;point to end of environment
        move.b  #0,(a0)         ;put nulls afterword
        move.b  #0,1(a0)        ;put nulls afterword
 
;change linefeeds to nulls
        move.l  #workar,a0
        move.w  d0,d1
zaplflp:
        cmp.b   #10,(a0)
        bne.b   notlf            ;was: bne.s          
        move.b  #0,(a0)
notlf:
        addq.l  #1,a0
        dbf     d0,zaplflp
;remove returns
        move.l  #workar,a0
        move.l  a0,a1
zapcrs:
        cmp.b   #13,(a0)
        bne.b   notcr            ;was: .s
        addq.l  #1,a0
        bra.b   zapcrs           ;was: .s
notcr:
        move.b  (a0)+,(a1)+
        cmp.b   #0,(a0)
        dbeq    d1,zapcrs         
        move.b  #0,(a1)
 
        add.w   #$40,d6         ;safety
*close
        move.w  handl,-(sp)
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #4,sp
 
* alter vector
        move.l  #doit,-(sp)     ;point to the vector changer code
        move.w  #38,-(sp)       ;we want to do it in supervisor mode!
        trap    #14             ;execute it!
        addq.l  #6,sp
* tell everyone we are here
        pea     msg1
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
* TSR
        clr     -(sp)           ;exit but stay
        move.l  d6,-(sp)
        move    #$31,-(sp)
        trap    #1
 
bexit:  move    #0,-(sp)
        trap    #1
* set env upon startup
movenv:
        move.l  a7,a5
        move.l  4(a5),a5
        move.l  a5,a4
linkup:
        move.l  $24(a4),a4
        movea.l $2c(a4),a3
        cmp.w   #0,(a3)
        beq.b   setwork ;was: .s
        move.l  a4,a5
        bra.b   linkup  ;was: .s
setwork:
 
        move.l  #workar,$2c(a5)
        move.l  shlsav,a5
        jmp     (a5)
***
* install (in super) vector
doit:   move.l  $4fe,shlsav     ;move
        move.l  #movenv,$4fe    ;move
        rts                     ;and return
***
*************************
        .data
msg1:           dc.b    $0d,$0a,' Environment Set V2',$0d,$0a,0
envfstr:        dc.b    'ENVIRON.DAT',0
handl:          dc.w    0
shlsav:         dc.l    0
        .bss
workar:         ds.b    8192
        .end
