;************************************************************
;*                      RSC_TO_S                            *
;*                 May '90  Roy Glover                      *
;*                                                          *
;*    convert GEM resource file to assembler source text    *
;* 		Modified Oct '19 '1991 Gary burke	    *
;* will now compile with devpac 2 or higher		    *
;* output source file devpac compatible 		    *
;************************************************************
	opt	c+

 move.l a7,a5
 move.l #nstack,a7
 move.l 4(a5),a5
 move.l $c(a5),d0
 add.l $14(a5),d0
 add.l $1c(a5),d0
 add.l #$100,d0
 move.l d0,-(sp)
 move.l a5,-(sp)
 move d0,-(sp)
 move #$4a,-(sp)
 trap #1
 add.l #12,sp

;********
 bsr main                   ;go to main program
;********

exit:
 lea clos_vwork,a1       ;close work
 bsr vdi

 lea appl_exit,a1         ;appl exit
 bsr aes

 clr -(sp)                  ;back to desktop
 trap #1

;*******************
main:
 move.l #0,ap1resv
 move.l #0,ap2resv
 move.l #0,ap3resv
 move.l #0,ap4resv
 lea appl_init,a1
 bsr aes

 lea graf_handle,a1
 bsr aes
 move intout,grhandle

 move.l #$10001,d0
 lea intin,a0
 move.l d0,(a0)+
 move.l d0,(a0)+
 move.l d0,(a0)+
 move.l d0,(a0)+
 move.l d0,(a0)+
 move #2,(a0)
 lea open_vwork,a1
 bsr vdi

 bsr getmemsiz              ;get free mem
 bsr setbuf                 ;set buffer size & addr

;********prog loop here*******

mloop:
 bsr hide
 move.l #clrscrn,a1
 bsr prnt
; move.l bufsiz,d7          ;use these lines to
; move.l #bsiz,a6           ; display available
; bsr hexl                  ;  memory size
; move.b #0,(a6)+
; move.l #siztxt,a1
; bsr prnt
 bsr show
 move.l #menu1,a1
 bsr alert
 cmp #1,intout               ;file?
 beq file
 cmp #2,intout               ;print?
 beq print
 move.l #confirm,a1         ;quit?
 bsr alert
 cmp #1,intout              ;no
 beq mloop
 bra exit                   ;yes

file:
 move.l #menu2,a1
 bsr alert
 cmp #1,intout               ;load?
 beq load
 cmp #2,intout               ;save?
 beq save
 bra mloop                  ;to top

load:
 move.l #menu3,a1
 bsr alert
 cmp #1,intout               ;load rsc?
 beq rscload
 cmp #2,intout               ;load src?
 beq srcload
 bra mloop

rscload:
 move.l #rscbuf,bufaddr
 move.l #defnam1,defnam
 move.l #srchspec1,srchspec
 move.l #$ffff,filsiz
 bsr loadfile
 tst oops                   ;error?
 bne mloop
 tst select                 ;cancel?
 beq mloop
 tst.l filsiz
 beq mloop
convert:
 move.l filsiz,d0
 mulu #5,d0                 ;source file may be 5x rsc file
 cmp.l bufsiz,d0            ;buf large enough?
 bls .1                     ;yes
 move.l #menu7,a1
 bsr alert
 cmp #2,intout              ;cancel?
 beq mloop
.1:
 move.l #menu4,a1
 bsr alert
 cmp #2,intout              ;cancel?
 beq mloop
 bsr rsctosrc
 bra mloop

srcload:
 move.l bufstrt,bufaddr
 move.l #defnam2,defnam
 move.l #srchspec2,srchspec
 move.l bufsiz,filsiz
 bsr loadfile
 move.l filsiz,txtsiz
 bra mloop

save:
 move.l #menu6,a1
 bsr alert
 cmp #1,intout               ;save src file?
 bne mloop
 tst.l txtsiz
 bne .1
 bsr empbuf
 bra mloop
.1:
 move.l bufstrt,bufaddr
 move.l #defnam2,defnam
 move.l #srchspec2,srchspec
 move.l txtsiz,filsiz
 bsr savefile
 bra mloop

print:
 move.l #menu5,a1
 bsr alert
 cmp #1,intout               ;screen?
 beq toscreen
 cmp #2,intout               ;printer?
 beq toprntr
 bra mloop

toscreen:
 tst.l txtsiz
 bne .1
 bsr empbuf
 bra mloop
.1:
 move.l #menu9,a1
 bsr alert
 bsr hide
 move.l #clrscrn,a1
 bsr prnt
 move.l bufstrt,a5
 moveq #25,d7               ;for 25 lines to start
.15:
 tst.b (a5)
 beq .6
 cmp.b #$d,(a5)             ;CR?
 bne .16
 subq.b #1,d7
 beq .5
.16:
 move.b (a5)+,d1
 bsr scrnout
 bra .15
.2:
 tst.b (a5)
 beq .6
 bsr testkey
 cmp.b #27,d0               ;esc?
 beq mloop
 cmp.b #32,d0               ;space?
 beq .4
 move.b (a5)+,d1
 bsr scrnout
 bra .2
.4:
 tst.b (a5)
 beq .6
 cmp.b #$d,(a5)             ;CR?
 beq .5
.45:
 move.b (a5)+,d1
 bsr scrnout
 bra .4
.5:
 bsr testkey
 cmp.b #27,d0               ;esc?
 beq mloop
 cmp.b #32,d0               ;space?
 beq .45
 cmp.b #13,d0               ;return?
 bne .5
 bra .2
.6:
 move.l #eoftxt,a1
 bsr prnt
.7:
 bsr testkey
 tst d0
 beq .7
 bra mloop

testkey:
 move.w #2,-(sp)            ;key pressed?
 move.w #1,-(sp)
 trap #13
 addq.l #4,sp
 tst d0
 bne rtnkey                 ;yes
 rts
rtnkey:
 move.w #2,-(sp)            ;get key
 move.w #2,-(sp)
 trap #13
 addq.l #4,sp
 rts

scrnout:
 move d1,-(sp)              ;write char in d1 to screen
 move #2,-(sp)
 move #3,-(sp)
 trap #13
 addq.l #6,sp
 rts

toprntr:
 tst.l txtsiz
 bne .1
 bsr empbuf
 bra mloop
.1:
 move.l #menu10,a1
 bsr alert
 move.l bufstrt,a5
.2:
 tst.b (a5)
 beq mloop
 move.l #$ffff,d7
.4:
 bsr testkey
 cmp.b #27,d0               ;esc?
 beq mloop
 bsr testprt
 tst d0
 bne .5
 subq.l #1,d7
 bne .4
 move.l #menu8,a1
 bsr alert
 cmp #1,intout              ;retry?
 beq .2
 bra mloop
.5:
 move.b (a5)+,d1
 bsr prtout
 bra .2

testprt:
 move #0,-(sp)              ;printer ready?
 move #8,-(sp)
 trap #13
 addq.l #4,sp
 rts

prtout:
 move d1,-(sp)              ;write char in d1 to printer
 move #0,-(sp)
 move #3,-(sp)
 trap #13
 addq.l #6,sp
 rts

rsctosrc:
 clr.l txtsiz
 bsr getptrs
 bsr doheader
 bsr dostrings
 bsr doicndata
 bsr dobitdata
 bsr dostrtbl
 bsr dobitblks
 bsr doimgtbl
 bsr doicnblks
 bsr doteds
 bsr doobjs
 bsr dotretbl
 bsr dorscend
 move.l txtptr,d0           ;end of text
 sub.l bufstrt,d0           ; minus start of text
 move.l d0,txtsiz           ;  equals size of text
 rts

getmemsiz:
 move.l #-1,-(sp)
 move #$48,-(sp)
 trap #1
 addq.l #6,sp               ;num of free bytes in d0
 sub.l #$1000,d0            ;minus 4k for system?
 and.l #$fffffffe,d0        ;make sure it's even
 move.l d0,bufsiz           ; and save it
 rts

setbuf:
 move.l bufsiz,-(sp)        ;num of bytes to allocate
 move #$48,-(sp)
 trap #1
 addq.l #6,sp
 tst.l d0
 bmi exit                   ;error - terminate
 move.l d0,bufstrt          ;save start addr of buf
 move.l d0,txtptr           ; start txt at same addr
 add.l bufsiz,d0
 subq.l #2,d0
 move.l d0,bufend           ;save end addr of buf
 rts

relbuf:
 move.l bufstrt,-(sp)       ;start addr of mem to release
 move #$49,-(sp)
 trap #1
 addq.l #6,sp
 rts

getptrs:
 lea rscbuf,a4
 lea rscbuf+2,a5
 lea objstrt,a6
 moveq #8,d0
.1:
 clr.l d7
 move (a5)+,d7
 beq .2
 add.l a4,d7
.2:
 move.l d7,(a6)+
 dbra d0,.1
 moveq #3,d0
.3:
 move.l (a5)+,(a6)+
 dbra d0,.3
 move.l bufend,savtblptr    ;start offset pointer table at bufend
 rts

doheader:
 move.l bufstrt,a6          ;start of text buffer
 move.l #s5,a4              ;'rsc' & 'header'
 bsr storstr
 lea rscbuf,a5
 move.b #'0',(a6)+
 move.b #',',(a6)+
 tst objcnt
 bne .1
 move.b #'0',(a6)+
 bra .2
.1:
 move.l #s85,a4             ;'objects'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.2:
 move.b #',',(a6)+
 tst tedcnt
 bne .3
 move.b #'0',(a6)+
 bra .4
.3:
 move.l #s75,a4             ;'teds'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.4:
 move.b #',',(a6)+
 tst icncnt
 bne .5
 move.b #'0',(a6)+
 bra .6
.5:
 move.l #s255,a4            ;'iconblks'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.6:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 tst bitcnt
 bne .7
 move.b #'0',(a6)+
 bra .8
.7:
 move.l #s235,a4            ;'bitblks'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.8:
 move.b #',',(a6)+
 tst fstrcnt
 bne .9
 move.b #'0',(a6)+
 bra .10
.9:
 move.l #s225,a4            ;'strptrtbl'
 bsr storstr
 move.l #s1,a4
 bsr storstr
.10:
 move.b #',',(a6)+
 tst 12(a5)                 ;string start
 bne .11
 move.b #'0',(a6)+
 bra .12
.11:
 move.b #'$',(a6)+
 move 12(a5),d7
 bsr hexw
.12:
 move.b #',',(a6)+
 tst icncnt
 bne .13
 move.b #'0',(a6)+
 bra .14
.13:
 move.l #s175,a4            ;'icondata'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.14:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 move bitcnt,d0
 bne .16
.15:
 move.b #'0',(a6)+
 bra .19
.16:
 clr.l d2
 subq #1,d0
 move 8(a5),d1              ;first bitblk offset
 move 16(a5),d2             ;cursor img data ptr tbl offset
 move.l 0(a5,d2.l),d2       ;pointer to data
.17:
 cmp d1,d2
 beq .18
 add #14,d1
 dbra d0,.17
 bra .15                    ;not found
.18:
 move.l #s305,a4            ;'imgptrtbl'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.19:
 move.b #',',(a6)+
 tst objcnt
 bne .20
 move.b #'0',(a6)+
 bra .21
.20:
 move.l #s275,a4            ;'treptrtbl'
 bsr storstr
 move.l #s1,a4              ;'-rsc'
 bsr storstr
.21:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 lea 20(a5),a5              ;11th word
 moveq #6,d0
.22:
 move (a5)+,d7
 bsr decw
 move.b #',',(a6)+
 dbra d0,.22
 move.l #s32,a4             ;'rscend-rsc'
 bsr storstr
 move.l a6,txtptr           ;save position in text buffer
 rts

dostrings:
 tst icncnt
 beq .01                    ;no icon blks
 move.l imgstrt,d5          ;addr of icon data
 bra .08
.01:
 tst bitcnt
 beq .02                    ;no bit blks
 move.l bitstrt,a0          ;first bitblk
 move.l (a0),d5             ;bit data offset
 add.l #rscbuf,d5           ; addr of data
 bra .08
.02:
 tst fstrcnt
 beq .03                    ;no free strings
 move.l fstrptr,d5          ;free string pointer table addr
 bne .08
.03:
 tst tedcnt
 beq .04                    ;no teds
 move.l tedstrt,d5
 bra .08
.04:
 tst objcnt                 ;objs?
 bne .05                    ;yes
 clr.l d5
 move rscsiz,d5             ;rsc size
 add.l #rscbuf,d5           ;end of rsc addr
 bra .08
.05:
 move.l objstrt,d5
.08:
 clr strcnt
 move.l strstrt,a5
 cmp.l d5,a5
 bge .10                    ;no strings
 move.l savtblptr,a3
 move.l a3,strtbl           ;set addr of string ptr tbl
 move.l txtptr,a6
 move.l #s6,a4              ;strings
 bsr storstr
 move.b #':',(a6)+
 clr strnum
 tst.b (a5)                 ;first byte zero?
 beq .8                     ;yes
.1:
 addq #1,strcnt             ;count num of strings
 move.l a6,savptr           ;save start of line
 bsr getoff                 ;return with offset in d7 & 'offset'
 move d7,-(a3)              ;store offset in table
 clr.l d7
 move.l #s9,a4              ;'str'
 bsr storstr
 move strnum,d7             ;put string num after 'str'
 bsr decw
 addq #1,strnum
 move.l #s10,a4             ;'dc.b'
 bsr storstr
.11:
 tst.b (a5)
 beq .65
 cmp.b #$22,(a5)            ;quote?
 beq .15
 cmp.b #$1b,(a5)            ;esc?
 beq .15
 cmp.b #7,(a5)
 blt .2                     ;< bell
 cmp.b #13,(a5)
 bgt .2                     ;> cr
.15:
 move.b #'$',(a6)+
 move.b (a5)+,d7
 bsr hexb
 cmp.l d5,a5
 blt .16
 bra .66                    ;offset & end
.16:
 bsr chklngth               ;check string length
 tst d4
 bne .11
 move.b #',',(a6)+
 bra .11
.2:
 move.b #$22,(a6)+          ;start quote
.3:
 move.b (a5)+,d7
 beq .5
 cmp.b #$22,d7            ;quote?
 beq .41
 cmp.b #$1b,d7            ;esc?
 beq .41
 cmp.b #7,d7
 blt .45                     ;< bell
 cmp.b #13,d7
 bgt .45                     ;> cr
.41:
 move.b #$22,(a6)+          ;end prev quote
 move.b #',',(a6)+
 move.b #'$',(a6)+
 bsr hexb
 cmp.l d5,a5
 blt .42
 bra .66                    ;offset & end
.42:
 bsr chklngth
 tst d4
 bne .11
 move.b #',',(a6)+
 bra .11
.45:
 move.b d7,(a6)+
 cmp.l d5,a5
 bge .5
 move.l a6,d4
 sub.l savptr,d4
 cmp #70,d4                 ;longer than 70 char?
 blt .3                     ;no
 move.b #$22,(a6)+          ;yes- end quote
 bsr newlin                 ;start next line
 bra .11
.5:
 move.b #$22,(a6)+          ;end quote
.6:
 move.b #',',(a6)+
.65:
 move.b #'0',(a6)+
 cmp.l d5,a5                ;end?
 blt .7                     ;no
.66:
 bsr storoff               ;yes-comment with offset value
 bra .8                     ; and end
.7:
 tst.b (a5)                 ;next byte zero?
 bne .73                    ;no
 tst.b (a5)+                ;yes-don't store extra zeros
 cmp.l d5,a5                ;end?
 blt .7                     ;no-loop
 bra .66                    ;yes-end
; tst.b (a5)                 ;next byte zero?           | use this to
; bne .73                    ;no                        | store all
; tst.b (a5)+                ;yes- point to next byte   | zeros
; bsr chklngth               ;                          |
; tst.b d4                   ;start new line?           |
; bne .65                    ;yes                       |
; bra .6                     ;no- store ',0'            |
.73:
 bsr storoff               ;prnt offset
 bra .1                     ; and start next string
.8:
 move.l #s165,a4            ;'align'
 bsr storstr
 move.l #s4,a4              ;'null'
 bsr storstr
.9:
 subq.l #2,a3               ;next word in offset table
 move.l a3,savtblptr        ; and save it
 move.l a6,txtptr
.10:
 rts

chklngth:
 move.l a6,d4
 sub.l savptr,d4
 cmp #70,d4                 ;longer than 70 char?
 bgt newlin                 ;yes
 clr d4
 rts
newlin:
 move.l a6,savptr
 move.l #s31,a4             ;'dc.b'
 bsr storstr
 moveq #1,d4
 rts

doicndata:
 tst icncnt
 beq .20                    ;no icon blks
 move.l savtblptr,a3
 move.l a3,imgtbl           ;set icon image data table addr
 move.l txtptr,a6
 move.l #s17,a4             ;'icondata'
 bsr storstr
 move.b #':',(a6)+
 clr.l d0
 move icncnt,d0
 subq.l #1,d0
 move.l icnstrt,a0
 clr msknum
 clr imgnum
.1:
 clr.l d1
 move 22(a0),d1             ;icon width in pixels
 divu #16,d1                ; div by 16 equals width in words
 mulu 24(a0),d1             ;  times ht equals total num of words
 move d1,-(sp)              ;save
 move.l #s18,a4             ;'msk'
 bsr storstr
 move msknum,d7
 bsr decw
.2:
 move.l #s15,a4             ;'dc.w'
 bsr storstr
 move.l (a0),a5             ;mask offset
 add.l #rscbuf,a5           ; plus rsc start equals addr
 bsr getoff                 ;offset in d7
 move d7,-(a3)              ;save mask offset to table
 moveq #7,d2                ;8 words per line
.3:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .5
 tst d2
 beq .4
 move.b #',',(a6)+
.4:
 dbra d2,.3
.5:
 bsr storoff
 tst d1
 beq .11
.6:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #7,d2
.7:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .11
 tst d2
 beq .8
 move.b #',',(a6)+
.8:
 dbra d2,.7
 bra .6
.11:
 clr.l d1                   ;now do image data
 move (sp)+,d1              ;restore num of words
 move.l #s19,a4             ;'img'
 bsr storstr
 move imgnum,d7
 bsr decw
.12:
 move.l #s15,a4             ;'dc.w'
 bsr storstr
 move.l 4(a0),a5             ;img offset
 add.l #rscbuf,a5           ; plus rsc start equals addr
 bsr getoff
 move d7,-(a3)              ;save image data offset to table
 moveq #7,d2                ;8 words per line
.13:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .15
 tst d2
 beq .14
 move.b #',',(a6)+
.14:
 dbra d2,.13
.15:
 bsr storoff
 tst d1
 beq .19
.16:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #7,d2
.17:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .19
 tst d2
 beq .18
 move.b #',',(a6)+
.18:
 dbra d2,.17
 bra .16
.19:
 add.l #34,a0               ;next iconblk
 addq #1,msknum
 addq #1,imgnum
 dbra d0,.1
 move.l a6,txtptr
 subq.l #2,a3               ;addr of next word in table
 move.l a3,savtblptr        ; and save it
.20:
 rts

dobitdata:
 tst bitcnt
 beq .20                    ;no bit blks
 move.l savtblptr,a3
 move.l a3,bittbl           ;set bit image table addr
 move.l txtptr,a6
 move.l #s20,a4             ;'bitdata'
 bsr storstr
 move.b #':',(a6)+
 clr.l d0
 move bitcnt,d0
 subq.l #1,d0
 clr bitnum
 move.l bitstrt,a0          ;first bitblk
.1:
 clr.l d1
 move 4(a0),d1              ;bit image width in bytes
 divu #2,d1                 ; div by 2 equals width in words
 mulu 6(a0),d1             ;  times ht equals total num of words
 move.l #s21,a4             ;'bimg'
 bsr storstr
 move bitnum,d7
 bsr decw
.2:
 move.l #s15,a4             ;'dc.w'
 bsr storstr
 move.l (a0),a5             ;bit image offset
 add.l #rscbuf,a5           ; plus rsc start equals addr
 bsr getoff
 move d7,-(a3)              ;save offset to table
 moveq #7,d2                ;8 words per line
.3:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .5
 tst d2
 beq .4
 move.b #',',(a6)+
.4:
 dbra d2,.3
.5:
 bsr storoff
 tst d1
 beq .10
.6:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #7,d2
.7:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 subq #1,d1
 beq .10
 tst d2
 beq .8
 move.b #',',(a6)+
.8:
 dbra d2,.7
 bra .6
.10:
 add.l #14,a0
 addq #1,bitnum
 dbra d0,.1
 move.l a6,txtptr
 subq.l #2,a3
 move.l a3,savtblptr        ;save next addr in table
.20:
 rts

dostrtbl:
 clr.l d0
 move fstrcnt,d0
 beq .4
 move.l txtptr,a6
 move.l fstrptr,a5          ;string pointer table addr
 move.l #s22,a4             ;'strptrtbl'
 bsr storstr
 move.b #':',(a6)+
.1:
 move.l #s3,a4              ;'dc.l'
 bsr storstr
 moveq #3,d1                ;4 long words per line
.2:
 move.l (a5)+,d7
 move.l d7,a4
 add.l #rscbuf,a4           ;addr of str
 tst.b (a4)                 ;first byte null?
 bne .24                    ;no
 move.l #s0,a4              ;'null-rsc'
 bsr storstr
 bra .26
.24:
 bsr strsrch                ;calc str num from offset in d7
 cmp #-1,d6                 ; & return with str num or -1 in d6
 beq .25                    ;num not found-just store offset
 move.l #s95,a4             ;'str'
 bsr storstr
 move d6,d7                 ;str num
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .26
.25:
 move.b #'$',(a6)+
 bsr hexl
.26:
 subq #1,d0
 beq .4
 tst d1
 beq .3
 move.b #',',(a6)+
.3:
 dbra d1,.2
 bra .1
.4:
 move.l a6,txtptr
 rts

dobitblks:
 move bitcnt,d0
 beq .7
 subq #1,d0
 clr bblknum
 move.l bitstrt,a5
 move.l #s23,a4             ;'bitblks'
 bsr storstr
 move.b #':',(a6)+
.1:
 bsr getoff                ;get offset to first bitblk
 move.l #s24,a4             ;'bblk'
 bsr storstr
 move bblknum,d7
 bsr decw
 addq #1,bblknum
 move.l #s12,a4             ;'dc.l'
 bsr storstr
.2:
 move.l (a5)+,d7
 bsr bitsrch
 cmp #-1,d6
 beq .25                    ;not found
 move.l #s215,a4            ;'bimg'
 bsr storstr
 move d6,d7                 ;bit image num
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .3
.25:
 move.b #'$',(a6)+
 bsr hexl
.3:
 bsr storoff               ;bblk offset value string
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #4,d1                ;5 words
.4:
 move.b #'$',(a6)+
 move (a5)+,d7              ;w-h-x-y & color
 bsr hexw
 tst d1
 beq .5
 move.b #',',(a6)+
.5:
 dbra d1,.4
 dbra d0,.1
 move.l a6,txtptr
.7:
 rts

doimgtbl:
 tst imgcnt
 beq .5
 move.l imgptr,d5           ;cursor img data ptr tbl addr
 beq .5
 move.l d5,a5
 tst icncnt
 beq .01
 move.l icnstrt,d5
 bra .09
.01:
 tst tedcnt
 beq .02
 move.l tedstrt,d5
 bra .09
.02:
 tst objcnt
 beq .03
 move.l objstrt,d5
 bra .09
.03:
 clr.l d5
 move rscsiz,d5             ;size
 add.l #rscbuf,d5           ; plus strt addr equals end addr
.09:
 move.l txtptr,a6
 move.l #s30,a4             ;'imgptrtbl'
 bsr storstr
 move.b #':',(a6)+
.1:
 move.l #s3,a4              ;'dc.l'
 bsr storstr
 moveq #3,d1                ;4 long words per line
.2:
 move.l (a5)+,d7
 bsr bblksrch
 cmp #-1,d6
 beq .25
 move.l #s245,a4            ;'bblk'
 bsr storstr
 move d6,d7                 ;bblknum
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .26
.25:
 move.b #'$',(a6)+
 bsr hexl
.26:
 cmp.l d5,a5
 bge .4
 tst d1
 beq .3
 move.b #',',(a6)+
.3:
 dbra d1,.2
 bra .1
.4:
 move.l a6,txtptr
.5:
 rts

doicnblks:
 move icncnt,d0
 beq .10
 move.l txtptr,a6
 subq #1,d0
 clr iblknum
 move.l icnstrt,a5
 move.l #s25,a4             ;'iconblks'
 bsr storstr
 move.b #':',(a6)+
.1:
 bsr getoff                ;get offset
 move.l #s26,a4             ;'iblk'
 bsr storstr
 move iblknum,d7
 bsr decw
 addq #1,iblknum
 move.l #s12,a4             ;'dc.l'
 bsr storstr
 moveq #1,d1                ;2 longs - msk & img
.2:
 move.l (a5)+,d7
 bsr msksrch
 cmp #-1,d6
 beq .22
 move.l #s185,a4            ;'msk'
 bra .23
.22:
 bsr imgsrch
 cmp #-1,d6
 beq .24
 move.l #s195,a4            ;'img'
.23:
 bsr storstr
 move d6,d7                 ;msk or img num
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .25
.24:
 move.b #'$',(a6)+
 bsr hexl
.25:
 move.b #',',(a6)+
.3:
 dbra d1,.2
 clr.l d7
 move.l (a5)+,d7
 move.l d7,a4
 add.l #rscbuf,a4
 tst.b (a4)                 ;point to null?
 bne .32                    ;no
 move.l #s0,a4              ;'null-rsc'
 bsr storstr
 bra .36
.32:
 bsr strsrch
 cmp #-1,d6
 beq .34
 move.l #s95,a4             ;'str'
 bsr storstr
 move d6,d7                 ;strnum
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .36
.34:
 move.b #'$',(a6)+
 bsr hexl
.36:
 bsr storoff               ;icnblk offset value string
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #2,d1                ;3 words
.4:
 move.b #'$',(a6)+
 move (a5)+,d7              ;char,x-y char
 bsr hexw
 tst d1
 beq .5
 move.b #',',(a6)+
.5:
 dbra d1,.4
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #3,d1                ;4 words
.6:
 move.b #'$',(a6)+
 move (a5)+,d7              ;x-y-w-h icon
 bsr hexw
 tst d1
 beq .7
 move.b #',',(a6)+
.7:
 dbra d1,.6
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #3,d1                ;4 words
.8:
 move.b #'$',(a6)+
 move (a5)+,d7              ;x-y-w-h text
 bsr hexw
 tst d1
 beq .9
 move.b #',',(a6)+
.9:
 dbra d1,.8
 dbra d0,.1
 move.l a6,txtptr
.10:
 rts

doteds:
 move tedcnt,d0
 beq .7
 move.l txtptr,a6
 subq #1,d0
 clr tednum
 move.l tedstrt,a5
 move.l #s7,a4              ;'teds'
 bsr storstr
 move.b #':',(a6)+
.1:
 bsr getoff                ;get offset to ted
 move.l #s11,a4              ;'ted'
 bsr storstr
 move tednum,d7
 bsr decw
 addq #1,tednum
 move.l #s12,a4             ;'dc.l'
 bsr storstr
 moveq #2,d1                ;3 longs
.2:
 move.l (a5)+,d7
 move.l d7,a4
 add.l #rscbuf,a4
 tst.b (a4)                 ;first char 0?
 bne .21
 move.l #s0,a4              ;'null-rsc'
 bsr storstr
 bra .23
.21:
 bsr strsrch
 cmp #-1,d6
 beq .22
 move.l #s95,a4             ;'str'
 bsr storstr
 move d6,d7                 ;strnum
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .23
.22:
 move.b #'$',(a6)+
 bsr hexl
.23:
 tst d1
 beq .3
 move.b #',',(a6)+
.3:
 dbra d1,.2
 bsr storoff               ;ted offset value string
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #2,d1                ;3 words
.4:
 move (a5)+,d7              ;font,resrvd,just
 bsr decw
 move.b #',',(a6)+
 dbra d1,.4
 move.b #'$',(a6)+
 move (a5)+,d7              ;color
 bsr hexw
 move.b #',',(a6)+
 moveq #3,d1                ;4 words
.5:
 move (a5)+,d7              ;resrvd,border,txtlgth,tmplgth
 bsr decw
 tst d1
 beq .6
 move.b #',',(a6)+
.6:
 dbra d1,.5
 dbra d0,.1
 move.l a6,txtptr
.7:
 rts

doobjs:
 move objcnt,d0
 beq .9
 move.l txtptr,a6
 subq #1,d0
 clr trenum
 move.l objstrt,a5
 move.l #s8,a4              ;'objs'
 bsr storstr
 move.b #':',(a6)+
.1:
 cmp #-1,(a5)               ;tree start?
 bne .11
 move.l #s13,a4             ;'tree'
 bsr storstr
 move trenum,d7
 bsr decw
 move.b #':',(a6)+
 clr objnum
.11:
 move.l #s14,a4             ;'obj'
 bsr storstr
 clr.l d7
 move trenum,d7             ;tree number
 bsr decw                   ; followed by
 move.b #'_',(a6)+
 move objnum,d7             ;  obj number
 bsr decw                   ;   gives obj label number
 addq #1,objnum
 move.l #s15,a4             ;'dc.w'
 bsr storstr
 moveq #5,d1                ;6 words
.2:
 move (a5)+,d7
 bsr decw
 tst d1
 beq .3
 move.b #',',(a6)+
.3:
 dbra d1,.2
 move -6(a5),d7             ;obj type
 cmp #20,d7                 ;box?
 beq .4
 cmp #25,d7                 ;ibox?
 beq .4
 cmp #27,d7                 ;boxchar?
 beq .4
 move.l #s3,a4              ;'dc.l'
 bsr storstr
 cmp #24,d7                 ;progdef?
 beq .38
 cmp #23,d7                 ;bitblk?
 bne .31
 move.l (a5)+,d7            ;pointer
 bsr bblksrch
 cmp #-1,d6
 beq .39
 move.l #s245,a4            ;'bblk'
 bsr storstr
 move d6,d7
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .5
.31:
 cmp #31,d7                 ;icnblk?
 bne .32
 move.l (a5)+,d7            ;pointer
 bsr iblksrch
 cmp #-1,d6
 beq .39
 move.l #s265,a4            ;'iblk'
 bsr storstr
 move d6,d7
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .5
.32:
 cmp #26,d7                 ;button?
 beq .33
 cmp #28,d7                 ;string?
 beq .33
 cmp #32,d7                 ;title?
 bne .34
.33:
 move.l (a5)+,d7            ;pointer
 move.l d7,a0
 add.l #rscbuf,a0
 tst.b (a0)                 ;first byte zero?
 bne .331
 move.l #s0,a4              ;'null-rsc'
 bsr storstr
 bra .5
.331:
 bsr strsrch
 cmp #-1,d6
 beq .39
 move.l #s95,a4             ;'str'
 bsr storstr
 move d6,d7
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .5
.34:
 cmp #21,d7                 ;text?
 beq .35
 cmp #22,d7                 ;boxtext?
 beq .35
 cmp #29,d7                 ;ftext?
 beq .35
 cmp #30,d7                 ;fboxtext?
 bne .38
.35:
 move.l (a5)+,d7            ;pointer
 bsr tedsrch
 cmp #-1,d6
 beq .39
 move.l #s115,a4             ;'ted'
 bsr storstr
 move d6,d7
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 bra .5
.38:
 move.l (a5)+,d7            ;obj spec - txt,ted,icon, or bit img pntr
.39:
 move.b #'$',(a6)+
 bsr hexl
 bra .5
.4:
 move.b #',',(a6)+
 moveq #5,d1                ;6 words - obj spec & x-y-w-h
 bra .6
.5:
 move.l #s2,a4              ;'dc.w'
 bsr storstr
 moveq #3,d1                ;4 words - x-y-w-h
.6:
 move.b #'$',(a6)+
 move (a5)+,d7
 bsr hexw
 tst d1
 beq .7
 move.b #',',(a6)+
.7:
 dbra d1,.6
 cmp #-1,(a5)               ;tree start?
 bne .8
 addq #1,trenum
.8:
 dbra d0,.1
 move.b #$d,(a6)+
 move.b #$a,(a6)+
 move.l a6,txtptr
.9:
 rts

dotretbl:
 clr.l d0
 move trecnt,d0
 beq .5
 clr trenum
 move.l txtptr,a6
 move.l treeptr,a5          ;tree pointer table addr
 move.l #s27,a4             ;'treetbl'
 bsr storstr
 move.l #s12,a4             ;'dc.l'
 bsr storstr
 moveq #3,d1
 bra .2
.1:
 move.l #s3,a4              ;'dc.l'
 bsr storstr
 moveq #3,d1                ;4 long words per line
.2:
 move.l #s135,a4            ;'tree'
 bsr storstr
 move trenum,d7
 bsr decw
 move.l #s1,a4              ;'-rsc'
 bsr storstr
 addq #1,trenum
 subq #1,d0
 beq .4
 tst d1
 beq .3
 move.b #',',(a6)+
.3:
 dbra d1,.2
 bra .1
.4:
 move.l a6,txtptr
.5:
 rts

dorscend:
 move.l txtptr,a6
 move.l #s29,a4             ;'rscend:' & 'end'
 bsr storstr
 move.b #0,(a6)+
 move.l a6,txtptr
 rts

decb:
 and.l #$ff,d7              ;byte in d7
decw:
 and.l #$ffff,d7              ;word in d7
 tst d7
 bne .1
 move.b #'0',(a6)+
 rts
.1:
 bpl .2
 neg d7
 move.b #'-',(a6)+
.2:
 move.l d6,-(sp)
 move.l d7,d6
 cmp #10000,d6
 blt .3
 divu #10000,d7
 add.b #'0',d7
 move.b d7,(a6)+
 swap d7
 ext.l d7
.3:
 cmp #1000,d6
 blt .4
 divu #1000,d7
 add.b #'0',d7
 move.b d7,(a6)+
 swap d7
 ext.l d7
.4:
 cmp #100,d6
 blt .5
 divu #100,d7
 add.b #'0',d7
 move.b d7,(a6)+
 swap d7
 ext.l d7
.5:
 cmp #10,d6
 blt .6
 divu #10,d7
 add.b #'0',d7
 move.b d7,(a6)+
 swap d7
 ext.l d7
.6:
 add.b #'0',d7
 move.b d7,(a6)+
 move.l (sp)+,d6
 rts

hexb:
 movem.l d6/a3,-(sp)
 move.l #hextbl,a3      ;enter with byte in d7
 move.b d7,d6
 lsr #4,d6
 and.l #$f,d6
 move.b 0(a3,d6.l),(a6)+
 move.b d7,d6
 and.l #$f,d6
 move.b 0(a3,d6.l),(a6)+
 movem.l (sp)+,d6/a3
 rts

hexw:
 tst d7
 bne .1
 move.b #'0',(a6)+
 rts
.1:
 movem.l d2/d6/a3,-(sp)
 move.l #hextbl,a3      ;enter with word in d7
 moveq #3,d2
.2:
 lsl.l #4,d7
 move.l d7,d6
 swap d6
 and.l #$f,d6
 move.b 0(a3,d6.l),(a6)+
 dbra d2,.2
 movem.l (sp)+,d2/d6/a3
 rts

hexl:
 tst.l d7                   ;long word in d7
 bne .1
 move.b #'0',(a6)+
 rts
.1:
 move.l d7,-(sp)            ;save it
 swap d7                    ;do hi word
 tst d7
 beq .2
 bsr .3
.2:
 move.l (sp)+,d7            ;do lo word
.3:
 and.l #$ffff,d7
 bsr hexw
 rts

strsrch:
 movem.l d0/a3,-(sp)
 clr.l d6
 clr.l d0                   ;enter with string offset in d7
 move strcnt,d0             ;num of strings
 beq .2
 subq #1,d0                 ; minus 1 for counter
 move.l strtbl,a3           ;addr of string offset table
.1:
 cmp -(a3),d7               ;does table entry match offset?
 beq .3                     ;yes-strnum in d6
 addq #1,d6
 dbra d0,.1
.2:
 move #-1,d6                ;not found
.3:
 movem.l (sp)+,d0/a3
 rts

bitsrch:
 movem.l d0/a3,-(sp)
 clr.l d6
 clr.l d0                   ;enter with bit image offset in d7
 move bitcnt,d0             ;num of bitblks
 beq .2
 subq #1,d0                 ; minus 1 for counter
 move.l bittbl,a3           ;addr of bit img offset table
.1:
 cmp -(a3),d7               ;does table entry match offset?
 beq .3                     ;yes-bitnum in d6
 addq #1,d6
 dbra d0,.1
.2:
 move #-1,d6                ;not found
.3:
 movem.l (sp)+,d0/a3
 rts

msksrch:
 movem.l d0/a3,-(sp)
 clr.l d6
 clr.l d0                   ;enter with mask offset in d7
 move icncnt,d0             ;num of iconblks
 beq .2
 subq #1,d0                 ; minus 1 for counter
 move.l imgtbl,a3           ;addr of icon img offset table
.1:
 cmp -(a3),d7               ;does table entry match offset?
 beq .3                     ;yes-mask num in d6
 tst -(a3)                  ;skip every other entry
 addq #1,d6
 dbra d0,.1
.2:
 move #-1,d6                ;not found
.3:
 movem.l (sp)+,d0/a3
 rts

imgsrch:
 movem.l d0/a3,-(sp)
 clr.l d6
 clr.l d0                   ;enter with mask offset in d7
 move icncnt,d0             ;num of iconblks
 beq .2
 subq #1,d0                 ; minus 1 for counter
 move.l imgtbl,a3           ;addr of icon img offset table
 tst -(a3)                  ;skip first entry
.1:
 cmp -(a3),d7               ;does table entry match offset?
 beq .3                     ;yes-img num in d6
 tst -(a3)                  ;skip every other entry
 addq #1,d6
 dbra d0,.1
.2:
 move #-1,d6                ;not found
.3:
 movem.l (sp)+,d0/a3
 rts

bblksrch:
 movem.l d0/d3,-(sp)
 clr.l d0
 clr.l d6
 move bitcnt,d0
 subq #1,d0
 lea rscbuf,a4
 move 8(a4),d3              ;1st bblk offset
.1:
 cmp d3,d7
 beq .2
 addq #1,d6
 add #14,d3                 ;next bblk offset
 dbra d0,.1
 move #-1,d6
.2:
 movem.l (sp)+,d0/d3
 rts

iblksrch:
 movem.l d0/d3,-(sp)
 clr.l d0
 clr.l d6
 move icncnt,d0
 subq #1,d0
 lea rscbuf,a4
 move 6(a4),d3              ;1st iblk offset
.1:
 cmp d3,d7                  ;offset match?
 beq .2
 addq #1,d6
 add #34,d3                 ;next iblk offset
 dbra d0,.1
 move #-1,d6
.2:
 movem.l (sp)+,d0/d3
 rts

tedsrch:
 movem.l d0/d3,-(sp)
 clr.l d0
 clr.l d6
 move tedcnt,d0
 subq #1,d0
 lea rscbuf,a4
 move 4(a4),d3              ;1st ted offset
.1:
 cmp d3,d7
 beq .2
 addq #1,d6
 add #28,d3                 ;next ted offset
 dbra d0,.1
 move #-1,d6
.2:
 movem.l (sp)+,d0/d3
 rts

getoff:
 move.l a5,d7               ;addr of position in rsc
 sub.l #rscbuf,d7           ; minus start of rsc
 move d7,offset            ;  equals offset- save it
 rts

storoff:
 rts                        ;remove this line for offset listings
 move.l #s28,a4             ;',$'
 bsr storstr
 move offset,d7
 bsr hexw
 rts

storstr:
 move.l d7,-(sp)
.1:
 move.b (a4)+,d7            ;addr of string in a4
 beq .2
 move.b d7,(a6)+            ;txt buf pntr in a6
 bra .1
.2:
 move.l (sp)+,d7
 rts

loadfile:
 bsr show
 bsr selfil
 bsr hide
 move.l #clrscrn,a1
 bsr prnt
 bsr show
 tst oops
 beq .1
 tst select
 beq .1
 bsr getsiz
 tst oops
 bmi .1
 cmp.l filsiz,d7        ;test file size limit
 bhi toobig
 move.l d7,filsiz
 bsr open
 tst oops
 bmi .1
 move.l bufaddr,a1         ;addr of file buffer
 bsr read
 tst oops
 bmi .1
 bsr close
 tst oops
 bmi .1
 clr oops
.1:
 rts

savefile:
 bsr show
 bsr selfil
 bsr hide
 move.l #clrscrn,a1
 bsr prnt
 bsr show
 tst oops
 beq .1
 tst select
 beq .1
 bsr create
 tst oops
 bmi .1
 move.l bufaddr,a1         ;addr of file buffer
 bsr write
 tst oops
 bmi .1
 bsr close
.1:
 rts

create:
 move #0,-(sp)            ;create file r/w
 pea filnam
 move #$3c,-(sp)
 trap #1
 addq.l #8,sp
 tst d0
 bmi error
 move d0,fhandle
 rts

open:
 move #2,-(sp)            ;open file r/w
 pea filnam
 move #$3d,-(sp)
 trap #1
 addq.l #8,sp
 tst.l d0
 bmi error
 move d0,fhandle
 rts

close:
 move fhandle,-(sp)
 move #$3e,-(sp)
 trap #1
 addq.l #4,sp
 bmi error
 rts

read:
 move.l a1,-(sp)             ;data buffer addr
 move.l filsiz,-(sp)         ;buffer length
 move fhandle,-(sp)
 move #$3f,-(sp)
 trap #1
 add.l #12,sp
 tst.l d0
 bpl .1
 swap d0
 bra error
.1:
 rts

write:
 move.l a1,-(sp)
 move.l filsiz,d0
 subq.l	#1,d0
 move.l d0,-(sp)
 move fhandle,-(sp)
 move #$40,-(sp)
 trap #1
 add.l #12,sp
 tst.l d0
 bpl .1
 swap d0
 bra error
.1:
 rts

getsiz:
 move #$2f,-(sp)            ;get dta
 trap #1
 addq.l #2,sp
 move.l d0,dtaptr
 move #$00,-(sp)          ;sfirst
 move.l #filnam,-(sp)
 move #$4e,-(sp)
 trap #1
 addq.l #8,sp
 tst d0
 bne error
 move.l dtaptr,a2
 move.l 26(a2),d7         ;file size
 rts

selfil:
 move #$19,-(sp)          ;get active drive
 trap #1
 addq.l #2,sp
 add #'A',d0
 lsl #8,d0
 add.b #':',d0
 move d0,drvnam
getpath:
 move #0,-(sp)            ;get path for active drive
 move.l #path,-(sp)
 move #$47,-(sp)
 trap #1
 addq.l #8,sp
setdir:
 move.l #dirnam,a1          ;move drive,path,& search spec
 move.l #drvnam,a0          ;       to fil sel directory
.1:
 tst.b (a0)
 beq .2
 move.b (a0)+,(a1)+
 bra .1
.2:
 move.l srchspec,a0
.3:
 move.b (a0)+,(a1)+
 bne .3
setfil:
 move.l defnam,a0          ;set up default filname
 move.l #filnam,a1
.1:
 move.b (a0)+,(a1)+
 bne .1
filsel:
 lea fsel_input,a1          ;gem file selector
 move.l #dirnam,addrin
 move.l #filnam,addrin+4
 bsr aes
 move intout,oops           ;if oops=0 then error
 move intout+2,select       ;0='Cancel'  1='OK'
 tst oops
 bne .1
 move #-1,d0
 bra error
.1:
 tst select
 bne .2
 rts
.2:
 cmp.b #':',dirnam+1        ;set drive
 bne .3
 move.b dirnam,d0
 cmp.b #'A',d0
 blt .3
 cmp.b #'P',d0
 bgt .3
 sub #'A',d0
 move d0,-(sp)
 move #$0e,-(sp)
 trap #1
 addq.l #4,sp
.3:
 move.l #dirnam,a0          ;find path
.4:
 tst.b (a0)+                ;find end of dir string
 bne .4
.5:
 cmp.b #'\',-(a0)           ;back up to last backslash
 bne .5
 move.b #0,1(a0)            ;end string
 move.l #dirnam,-(sp)
 move #$3b,-(sp)          ;set path
 trap #1
 addq.l #6,sp
 tst d0
 bmi error
 rts

error:
 move d0,oops
error2:
 bsr show
 move oops,d0
 neg d0
 move d0,intin
 lea form_error,a1
 bsr aes
 rts

hide:
 lea v_hide_c,a1
 bsr vdi
 rts

show:
 move #0,intin
 lea v_show_c,a1
 bsr vdi
 rts

alert:
 move.l a1,addrin
 move #0,intin
 lea form_alert,a1
 bsr aes
 rts

toobig:
 bsr show
 move #1,intin
 move.l #bigmenu,a1
 bsr alert
 clr.l txtsiz               ;zero text size
 clr rscsiz                 ;zero rsc size
 rts

empbuf:
 bsr show
 move #1,intin
 move.l #empmenu,a1
 bsr alert
 rts

prnt:
 move.l a1,-(sp)
 move #9,-(sp)
 trap #1
 addq.l #6,sp
 rts

getkey:
 move #7,-(sp)
 trap #1
 addq.l #2,sp
 rts

aes:
 move.l a1,aespb
 move.l #aespb,d1
 move #$c8,d0
 trap #2
 rts

vdi:
 move grhandle,12(a1)
 move.l a1,vdipb
 move.l #vdipb,d1
 moveq.l #$73,d0
 trap #2
 rts
;
 data

clrscrn: dc.b 27,'E',0,0
eoftxt: dc.b $d,$a,$d,$a,'   - End of File - ',0
siztxt: dc.b 27,'Y',56,60,'buffer size $'
bsiz:   ds.b 12

 even

menu1:
 dc.b '[0]'
 dc.b '[ File - load and save |'
 dc.b '         .RSC & .S files|'
 dc.b ' Print - print text files|'
 dc.b '         to screen or printer | ]'
 dc.b '[ File | Print | Quit ]',0,0

menu2:
 dc.b '[0]'
 dc.b '[        File | ]'
 dc.b '[ Load | Save | Cancel ]',0,0

menu3:
 dc.b '[0]'
 dc.b '[           Load File | ]'
 dc.b '[ Resource | Source | Cancel ]',0,0

menu4:
 dc.b '[0]'
 dc.b '[ Convert Resource to Source? | ]'
 dc.b '[ Convert | Cancel ]',0,0

menu5:
 dc.b '[0]'
 dc.b '[           Print | ]'
 dc.b '[ Screen | Printer | Cancel ]',0,0

menu6:
 dc.b '[0]'
 dc.b '[ Save source file? | ]'
 dc.b '[ Save | Cancel ]',0,0

menu7:
 dc.b '[2]'
 dc.b '[ There might not be enough |'
 dc.b ' memory to convert this file. |'
 dc.b ' Continue at your own risk! | ]'
 dc.b '[ Continue | Cancel ]',0,0

menu8:
 dc.b '[2]'
 dc.b '[ Printer is not responding | ]'
 dc.b '[ Retry | Cancel ]',0,0

menu9:
 dc.b '[0]'
 dc.b '[ Space - print single line |'
 dc.b ' Return - continuous printing |'
 dc.b ' Esc - abort printing | ]'
 dc.b '[ OK ]',0,0

menu10:
 dc.b '[0]'
 dc.b '[ Esc - abort printing | ]'
 dc.b '[ OK ]',0,0

confirm:
 dc.b '[0]'
 dc.b '[                         |'
 dc.b  'Sure you want to quit ? |'
 dc.b '                         ]'
 dc.b '[ No | Yes ]',0,0

bigmenu:
 dc.b '[0]'
 dc.b '[                         |'
 dc.b  'File is too large for buffer|'
 dc.b '                         ]'
 dc.b '[ return ]',0,0

empmenu:
 dc.b '[0]'
 dc.b '[                         |'
 dc.b  '  * Buffer Is Empty *   |'
 dc.b '                         ]'
 dc.b '[ return ]',0,0

 even

appl_init: dc.w 10,0,1,0,0
graf_handle: dc.w 77,0,5,0,0
form_alert: dc.w 52,1,1,1,0
form_error: dc.w 53,1,1,0,0
open_vwork: dc.w 100,0,0,11,0,0,0
clos_vwork: dc.w 101,0,0,0,0,0,0
appl_exit: dc.w 19,0,1,0,0
fsel_input: dc.w 90,0,2,2,0
v_hide_c: dc.w 123,0,0,0,0,0,0
v_show_c: dc.w 122,0,0,1,0,0,0

;
aespb: dc.l contrl,global,intin,intout,addrin,addrout
vdipb: dc.l contrl,intin,ptsin,intout,ptsout
;

treeaddr: dc.l 0
bufaddr: dc.l 0             ;R/W buffer address
defnam: dc.l defnam1
defnam1: dc.b '        .RSC',0,0   ;default filename
defnam2: dc.b '        .S',0,0
srchspec: dc.l srchspec1
srchspec1: dc.b '\*.RSC',0,0   ;default search specification
srchspec2: dc.b '\*.S',0,0
filsiz:  dc.l 0
dtaptr:  ds.l 1
oops:    ds.w 1
select:  ds.w 1
fhandle:  ds.w 1
filnam: ds.b 16
dirnam: ds.b 64
drvnam: ds.b 2              ;drive letter & colon
path:   ds.b 64             ;** keep path after drvnam **
hextbl: dc.b '0123456789ABCDEF'

s0: dc.b 'null'
s1: dc.b '-rsc',0
s2: dc.b $d,$a,'        dc.w ',0
s3: dc.b $d,$a,'        dc.l ',0
s4: dc.b $d,$a,'null dc.w 0',0
s5: dc.b $d,$a,'rsc:',$d,$a,'header  dc.w ',0
s6: dc.b $d,$a,$d,$a
s65: dc.b 'strings',0
s7: dc.b $d,$a,$d,$a
s75: dc.b 'teds',0
s8: dc.b $d,$a,$d,$a
s85: dc.b 'objects',0
s9: dc.b $d,$a
s95: dc.b 'str',0
s10: dc.b '  dc.b ',0
s11: dc.b $d,$a
s115: dc.b 'ted',0
s12: dc.b '  dc.l ',0
s13: dc.b $d,$a
s135: dc.b 'tree',0
s14: dc.b $d,$a
s145: dc.b 'obj',0
s15: dc.b '  dc.w ',0
s16: dc.b $d,$a
s165: dc.b $d,$a,' even',0
s17: dc.b $d,$a,$d,$a
s175: dc.b 'icondata',0
s18: dc.b $d,$a
s185: dc.b 'msk',0
s19: dc.b $d,$a
s195: dc.b 'img',0
s20: dc.b $d,$a,$d,$a,'bitdata',0
s21: dc.b $d,$a
s215: dc.b 'bimg',0
s22: dc.b $d,$a,$d,$a
s225: dc.b 'freestrings',0
s23: dc.b $d,$a,$d,$a
s235: dc.b 'bitblks',0
s24: dc.b $d,$a
s245: dc.b 'bblk',0
s25: dc.b $d,$a,$d,$a
s255: dc.b 'iconblks',0
s26: dc.b $d,$a
s265: dc.b 'iblk',0
s27: dc.b $d,$a,$d,$a
s275: dc.b 'trees',0
s28: dc.b '    ;$',0
s29: dc.b $d,$a,$d,$a,'rscend:',$d,$a,' even',$d,$a,' text',$d,$a,0,0
s30: dc.b $d,$a,$d,$a
s305: dc.b 'imgptrtbl',0
s31: dc.b $d,$a,'      dc.b ',0
s32: dc.b 'rscend-rsc',0

 even
 bss

grhandle: ds.w 1

offset: ds.w 1             ;tmp offset value
txtptr:  ds.l 1             ;location in text buffer
txtsiz: ds.l 1
savptr:  ds.l 1
savtblptr: ds.l 1
bufstrt: ds.l 1             ;start addr of txt buf
bufend: ds.l 1              ;end addr of txt buf
bufsiz: ds.l 1              ;size of buffer

strtbl: ds.l 1              ;addr of string offset table
imgtbl: ds.l 1              ;addr of icon mask & image table
bittbl: ds.l 1              ;bit img table

objstrt: ds.l 1             ;1st obj
tedstrt: ds.l 1             ;1st ted
icnstrt: ds.l 1             ;1st iconblk
bitstrt: ds.l 1             ;1st bitblk
fstrptr: ds.l 1             ;free string pointer table
strstrt: ds.l 1             ;1st string
imgstrt: ds.l 1             ;icon image data
imgptr:  ds.l 1             ;cursor image data pointer table
treeptr: ds.l 1             ;tree pointer table
objcnt:  ds.w 1             ;num of objects
trecnt:  ds.w 1             ;num of trees
tedcnt:  ds.w 1             ;num of teds
icncnt:  ds.w 1             ;num of iconblks
bitcnt:  ds.w 1             ;num of bitblks
fstrcnt: ds.w 1             ;num of free strings
imgcnt:  ds.w 1             ;num of free images
rscsiz:  ds.w 1             ;num of bytes in rsc
strcnt:  ds.w 1             ;num of strings

strnum: ds.w 1
msknum: ds.w 1
imgnum: ds.w 1
bitnum: ds.w 1
bblknum: ds.w 1
iblknum: ds.w 1
tednum: ds.w 1
trenum: ds.w 1
objnum: ds.w 1

 even

contrl:
opcode:   ds.w 1
sintin:   ds.w 1
sintout:  ds.w 1
saddrin:  ds.w 1
saddrout: ds.w 1
          ds.w 5
global:
apversion: ds.w 1
apcount:   ds.w 1
apid:      ds.w 1
apprivate: ds.l 1
apptree:   ds.l 1
ap1resv:   ds.l 1
ap2resv:   ds.l 1
ap3resv:   ds.l 1
ap4resv:   ds.l 1
intin: ds.w 128
ptsin: ds.w 128
intout: ds.w 128
ptsout: ds.w 128
addrin: ds.w 128
addrout: ds.w 128
        ds.l 300
nstack: ds.l 6

rscbuf:  ds.b $10000        ;64k for rsc file
rbufend: ds.l 1

 end
