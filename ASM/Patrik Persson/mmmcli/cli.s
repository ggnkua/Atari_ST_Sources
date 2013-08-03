                OUTPUT '\CLI.PRG'
                TEXT
                >PART 'Konstanter'

; TRAP

GEMDOS          EQU 1
XGEMDOS         EQU 2
BIOS            EQU 13
XBIOS           EQU 14

; GEMDOS

cconin          EQU 1
cconout         EQU 2
cauxout         EQU 4
crawcin         EQU 7
cconws          EQU 9
cconis          EQU 11
dsetdrv         EQU 14
cprnos          EQU 17
dgetdrv         EQU 25
fsetdta         EQU 26
super           EQU 32
sversion        EQU 48
dfree           EQU 54
dcreate         EQU 57
ddelete         EQU 58
dsetpath        EQU 59
fcreate         EQU 60
fopen           EQU 61
fclose          EQU 62
fread           EQU 63
fwrite          EQU 64
fdelete         EQU 65
fseek           EQU 66
fdup            EQU 69
fforce          EQU 70
fgetpath        EQU 71
malloc          EQU 72
mfree           EQU 73
pterm           EQU 76
fsfirst         EQU 78
fsnext          EQU 79
frename         EQU 86
fdatime         EQU 87

; XGEMDOS

AES             EQU 200

; BIOS

mediach         EQU 9

; XBIOS

getrez          EQU 4
cursconf        EQU 21
supexec         EQU 38

; AES

appl_init       EQU $0A000100
appl_exit       EQU $13000100
evnt_mesag      EQU $17000101
evnt_multi      EQU $19100701
menu_bar        EQU $1E010101
menu_tnormal    EQU $21020101
objc_draw       EQU $2A060101
form_dial       EQU $33090100
graf_mouse      EQU $4E010101
wind_get        EQU $68020500
wind_set        EQU $69060100
rsra_free       EQU $6F000100
rsrc_gaddr      EQU $70020100
rsrc_load       EQU $6E000101
rsrc_obfix      EQU $72010101
shel_read       EQU $78000102

g_text          EQU 21

; LINE-A

v_cel_mx        EQU -44

; Diverse

his_size        EQU 32

; Offsets i basepage

bp_env          EQU $2C
bp_stdin        EQU $30
bp_stdout       EQU $31
bp_stdaux       EQU $32
bp_stdprn       EQU $33

                ENDPART
                >PART 'Init'

start:          lea     mystack,SP
                lea     start(PC),A6
                pea     $0100+mystack-start
                pea     start-$0100(PC)
                pea     $4A0000
                trap    #GEMDOS
                lea     12(SP),SP

                bsr     install

                bsr     initgem

                bsr     makeenv
                bsr     setupio
                bsr     gemoff
                lea     hello(PC),A0
                bsr     sendlin2

                moveq   #0,D0
                lea     start-128(PC),A0
                move.b  (A0)+,D0
                beq.s   nocmd
                sf      0(A0,D0.w)
                lea     linebuf(PC),A1
                cmpi.b  #' ',(A0)       ; Anti-skr„pskydd
                ble.s   nocmd
argloop:        move.b  (A0)+,(A1)+
                bne.s   argloop
                bsr     tolk
                bra.s   main

nocmd:          pea     dta(PC)
                move.w  #fsetdta,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                move.w  #-1,-(SP)
                pea     autobat(PC)
                move.w  #fsfirst,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.w   D0
                bmi.s   main
                move.b  dta+21(PC),D0
                and.b   #%11000,D0
                bne.s   main
                lea     autobat(PC),A0
                lea     linebuf(PC),A1
nocmd_loop:     move.b  (A0)+,(A1)+
                bne.s   nocmd_loop
                bsr     tolk

                ENDPART
                >PART 'Main'

main:           move.w  #dgetdrv,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                add.b   #'A',D0
                move.b  D0,buffer-start(A6)
                move.b  #':',buffer+1-start(A6)
                clr.w   -(SP)
                pea     buffer+2(PC)
                move.w  #fgetpath,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                lea     buffer(PC),A0
                movea.l A0,A1
main_loop:      tst.b   (A1)+
                bne.s   main_loop
                lea     buffer+3(PC),A2
                cmpa.l  A2,A1
                bgt.s   main_noroot
                move.b  #'\',-1(A1)
                addq.l  #1,A1
main_noroot:    sf      (A1)
                move.b  #'>',-(A1)
                tst.w   bathdl-start(A6)
                bne.s   main_bat
                st      enterflg-start(A6)
                bsr.s   readln
main_doit:      tst.b   errcount-start(A6)
                beq.s   main_nodec
                subq.b  #1,errcount-start(A6)
main_nodec:     bsr     tolk
                bra.s   main
main_bat:       tst.b   watch_level-start(A6)
                beq.s   main_bat_noecho
                bsr     sendlin
main_bat_noecho:lea     cursoff(PC),A0
                bsr     sendlin
                bsr     batread
                lea     curson(PC),A0
                bsr     sendlin
                tst.b   watch_level-start(A6)
                beq.s   main_doit
                lea     linebuf(PC),A0
                bsr     sendlin2
                bra.s   main_doit

                ENDPART
                >PART 'Inmatning fr†n stdin'

readln:         movem.l D3-D7/A4-A5,-(SP)
                movea.l A0,A5
                moveq   #0,D7
                moveq   #0,D6
                moveq   #-1,D5
input_loop1:    addq.w  #1,D5
                tst.b   (A0)+
                bne.s   input_loop1
                linea   #0 [ Init ]
                move.w  -44(A0),D4
                move.w  -26(A0),D0
                add.b   #32,D0
                move.b  D0,xystr+2-start(A6)
                clr.b   linebuf-start(A6)
                clr.w   his_counter-start(A6)
input_mloop:    moveq   #27,D0
                bsr     sendchar
                moveq   #'f',D0
                bsr     sendchar
                moveq   #13,D0
                bsr     sendchar
                movea.l A5,A0
                bsr     sendlin
                move.w  D4,D2
                lea     linebuf(PC),A4
                sub.w   D5,D2
                subq.w  #3,D2
                move.w  D6,D0
                add.w   D5,D0
                cmp.w   D2,D6
                bmi.s   input_noprob
                adda.w  D6,A4
                suba.w  D2,A4
                move.w  D2,D0
                add.w   D5,D0
input_noprob:   add.b   #32,D0
                move.b  D0,xystr+3-start(A6)
                move.w  D4,D3
                subq.w  #4,D3
                sub.w   D5,D3
input_loop1b:   move.b  (A4)+,D0
                beq.s   input_loop1end
                bsr     sendchar
                dbra    D3,input_loop1b
input_loop1end: bsr     sendlin
                moveq   #27,D0
                bsr     sendchar
                moveq   #'K',D0
                bsr     sendchar
                moveq   #13,D0
                bsr     sendchar
                lea     xystr(PC),A0
                bsr     sendlin
                moveq   #27,D0
                bsr     sendchar
                moveq   #'e',D0
                bsr     sendchar
input_doit:     bsr     getchar
                cmpi.b  #8,D0
                beq     input_backspace
                cmpi.b  #13,D0
                beq     input_cr
                cmpi.b  #27,D0
                beq     input_esc
                cmpi.b  #127,D0
                beq     input_del
                tst.b   D0
                beq.s   input_scan
                cmp.b   #' ',D0
                bmi     input_mloop
                bra.s   input_noscan
input_scan:     swap    D0
                cmpi.b  #75,D0
                beq     input_left
                cmpi.b  #77,D0
                beq     input_right
                cmpi.b  #115,D0
                beq     input_left2
                cmpi.b  #116,D0
                beq     input_right2
                cmpi.b  #72,D0
                beq     input_up
                cmpi.b  #80,D0
                beq     input_down
                bra     input_mloop
input_noscan:   cmpi.w  #256,D7
                bpl     input_mloop
                lea     linebuf(PC),A0
                adda.w  D7,A0
                move.w  D7,D1
                sub.w   D6,D1
                beq.s   input_nomove
input_loop3:    move.b  (A0),1(A0)
                subq.l  #1,A0
                dbra    D1,input_loop3
                addq.l  #1,A0
input_nomove:   move.b  D0,(A0)
                addq.w  #1,D6
                addq.w  #1,D7
                lea     linebuf(PC),A0
                clr.b   0(A0,D7.w)
                bra     input_mloop

input_backspace:tst.w   D6
                beq     input_mloop
                cmp.w   D6,D7
                beq.s   input_bsp_1
                lea     linebuf-1(PC),A0
                adda.w  D6,A0
                move.w  D7,D0
                sub.w   D6,D0
                subq.w  #1,D0
input_bsp_lp:   move.b  1(A0),(A0)
                addq.w  #1,A0
                dbra    D0,input_bsp_lp
input_bsp_1:    subq.w  #1,D6
                subq.w  #1,D7
                lea     linebuf(PC),A0
                clr.b   0(A0,D7.w)
                bra     input_mloop

input_cr:       tst.w   D7
                beq.s   input_ende
                lea     his_buf+(his_size-1)*256(PC),A0
                lea     256(A0),A1
                move.w  #(his_size-1)*256-1,D0
input_cr_loop1: move.b  -(A0),-(A1)
                dbra    D0,input_cr_loop1
                lea     linebuf(PC),A0
                lea     his_buf(PC),A1
                move.w  #255,D0
input_cr_loop2: move.b  (A0)+,(A1)+
                dbra    D0,input_cr_loop2
input_ende:     movem.l (SP)+,D3-D7/A4-A5
                bra     docrlf

input_esc:      moveq   #0,D6
                moveq   #0,D7
                sf      linebuf-start(A6)
                bra     input_mloop

input_del:      cmp.w   D6,D7
                beq     input_mloop
                lea     linebuf(PC),A0
                adda.w  D6,A0
                move.w  D7,D0
                sub.w   D6,D0
                subq.w  #1,D0
input_del_lp:   move.b  1(A0),(A0)
                addq.w  #1,A0
                dbra    D0,input_del_lp
                subq.w  #1,D7
                bra     input_mloop

input_left:     tst.w   D6
                beq     input_mloop
                subq.w  #1,D6
                bra.s   ilput_testwrt

input_left2:    lea     linebuf(PC),A0
input_left2_b:  tst.w   D6
                beq     input_mloop
                subq.w  #1,D6
                beq     input_mloop
                cmpi.b  #' ',-1(A0,D6.w)
                beq     input_mloop
                bra.s   input_left2_b

input_right:    cmp.w   D6,D7
                beq     input_mloop
                addq.w  #1,D6
ilput_testwrt:  move.w  D6,D3
                add.w   D5,D3
                move.w  D4,D0
                subq.w  #3,D0
                cmp.w   D0,D3
                bpl     input_mloop
                lea     xystr(PC),A0
                add.b   #32,D3
                move.b  D3,3(A0)
                bsr     sendlin
                bra     input_doit

input_right2:   lea     linebuf(PC),A0
input_right2_b: cmp.w   D6,D7
                beq     input_mloop
                addq.w  #1,D6
                cmpi.b  #' ',-1(A0,D6.w)
                beq     input_mloop
                bra.s   input_right2_b

input_up:       cmpi.w  #his_size,his_counter-start(A6)
                bpl     input_mloop
                move.w  his_counter(PC),D0
                lsl.w   #8,D0
                lea     his_buf(PC),A0
                adda.w  D0,A0
                lea     linebuf(PC),A1
                move.w  #$FF,D0
input_up_loop1: move.b  (A0)+,(A1)+
                dbra    D0,input_up_loop1
                lea     linebuf(PC),A0
                moveq   #-1,D6
input_up_loop2: addq.w  #1,D6
                tst.b   (A0)+
                bne.s   input_up_loop2
                move.w  D6,D7
                addq.w  #1,his_counter-start(A6)
                bra     input_mloop

input_down:     tst.w   his_counter-start(A6)
                beq     input_mloop
                subq.w  #1,his_counter-start(A6)
                move.w  his_counter(PC),D0
                lsl.w   #8,D0
                lea     his_buf(PC),A0
                adda.w  D0,A0
                lea     linebuf(PC),A1
                move.w  #$FF,D0
input_down_lp1: move.b  (A0)+,(A1)+
                dbra    D0,input_down_lp1
                lea     linebuf(PC),A0
                moveq   #-1,D6
input_down_lp2: addq.w  #1,D6
                tst.b   (A0)+
                bne.s   input_down_lp2
                move.w  D6,D7
                bra     input_mloop

                ENDPART
                >PART 'Inmatning fr†n batchfil'
; L„ser en rad fr†n batchfilen. Tolkar „ven argument (%1, %2 etc).
; L„mnar raden i linebuf. Anv„nder buffer.

batread:        lea     linebuf(PC),A5
                moveq   #0,D7
                st      D6
batread_loop:   sf      (A5)
                pea     buffer(PC)
                pea     1.w
                move.w  bathdl(PC),-(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                tst.w   D0
                bmi     batread_error
                bne.s   batread_noend
                tst.b   D6
                bne     batread_close
                bra.s   batread_end
batread_noend:  sf      D6
                move.b  buffer(PC),D0
                cmp.b   #13,D0
                beq.s   batread_end
                cmp.b   #' ',D0
                bmi.s   batread_loop
                move.b  D0,(A5)+
                addq.w  #1,D7
                cmp.w   #384,D7
                ble.s   batread_loop
                sf      linebufend-1-start(A6)
batread_end:    lea     linebuf(PC),A0
                lea     buffer(PC),A1
batread_cpylp:  move.b  (A0)+,(A1)+
                bne.s   batread_cpylp
                lea     buffer(PC),A0
                lea     linebuf(PC),A1
                move.w  #383,D0
batread_loop1:  move.b  (A0)+,D1
                cmp.b   #'%',D1
                beq.s   batread_isarg
batread_cont:   move.b  D1,(A1)+
                dbeq    D0,batread_loop1
batread_argend: sf      linebufend-1-start(A6)
                rts
batread_isarg:  move.b  (A0)+,D2
                sub.b   #'0',D2
                blt.s   batread_cont
                cmp.b   #9,D2
                bgt.s   batread_cont
                ext.w   D2
                lea     argbuf(PC),A2
batread_loop2:  movea.l A2,A3
batread_loop3:  cmpi.b  #' ',(A2)+
                bgt.s   batread_loop3
                tst.b   -1(A2)
                bne.s   batread_notlast
                tst.w   D2
                bgt.s   batread_loop1
batread_notlast:dbeq    D2,batread_loop2
batread_loop4:  move.b  (A3)+,D1
                cmp.b   #' ',D1
                ble.s   batread_loop1
                move.b  D1,(A1)+
                dbra    D0,batread_loop4
                bra.s   batread_argend
batread_error:  move.w  D0,-(SP)
                bsr.s   batread_close
                move.w  (SP)+,D0
                bra     error
batread_close:  move.w  bathdl(PC),D0
                bsr     closefile
                clr.w   bathdl-start(A6)
                tst.b   enterflg
                beq     exit
                bra     batread_end

                ENDPART
                >PART 'Tolk'
; Sj„lva tolkrutinen. Rekursiv och fan vet allt.
; Tolk2 „r en variant d„r de gamla STDIN- och STDOUT-filerna skrivs till p†
; raden. B„st att anropa f”r att bevara dem vid rekursiva anrop.

tolk2:          lea     linebuf(PC),A0
tolk2_loop:     tst.b   (A0)+
                bne.s   tolk2_loop
                lea     stdoutfile(PC),A1
                tst.b   (A1)
                beq.s   tolk2_nostdout
                move.b  #'>',-1(A0)
tolk2_loop1:    cmpa.l  #linebufend,A0
                bpl.s   tolk2_cut
                move.b  (A1)+,(A0)+
                bne.s   tolk2_loop1
tolk2_nostdout: lea     stdinfile(PC),A1
                tst.b   (A1)
                beq.s   tolk2_cut
                move.b  #'<',-1(A0)
tolk2_loop2:    cmpa.l  #linebufend,A0
                bpl.s   tolk2_cut
                move.b  (A1)+,(A0)+
                bne.s   tolk2_loop2
tolk2_cut:      sf      linebufend-1-start(A6)

; And here we go

tolk:           cmpi.b  #1,watch_level-start(A6)
                ble.s   tolk_noverbose
                lea     linebuf(PC),A5
                bsr     error_sendit
                lea     crlf(PC),A5
                bsr     error_sendit
                cmpi.b  #2,watch_level-start(A6)
                ble.s   tolk_noverbose
                bsr     getchar
tolk_noverbose: pea     dta(PC)
                move.w  #fsetdta,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                moveq   #$7E,D0
                cmpa.l  #stackstart,SP
                ble     tolk_iserr
                cmpi.w  #1000,tolk_counter
                bpl     tolk_iserr
                addq.w  #1,tolk_counter
                bsr     testio
                bsr     testvar
                lea     linebuf(PC),A0
                move.b  (A0)+,D0
                beq     tolk_end
                cmp.b   #':',D0
                beq     tolk_end
                bsr     getarg
                cmpi.b  #':',linebuf+1-start(A6)
                bne.s   tolk_nodrv
                tst.b   linebuf+2-start(A6)
                bne.s   tolk_nodrv
                tst.b   s1-start(A6)
                bne     tolk_syntax
                tst.b   s2-start(A6)
                bne     tolk_syntax
                moveq   #-46,D0
                move.b  linebuf(PC),D0
                and.b   #$DF,D0
                sub.b   #'A',D0
                blt.s   tolk_error
                ext.w   D0
                move.w  D0,-(SP)
                move.w  #dsetdrv,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                bra.s   tolk_end
tolk_nodrv:     moveq   #0,D1
                tst.b   s1-start(A6)
                beq.s   tolk_find
                addq.w  #1,D1
                tst.b   s2
                beq.s   tolk_find
                addq.w  #1,D1
tolk_find:      lea     comtab(PC),A0
tolk_loop:      movem.l (A0)+,A1-A2
                move.w  (A0)+,D0
                bmi     tolk_nocmd
                lea     linebuf(PC),A3
tolk_loop3:     move.b  (A3)+,D2
                cmp.b   #' ',D2
                beq.s   tolk_mkuc
                cmp.b   #'a',D2
                blt.s   tolk_nocaps
                cmp.b   #'z',D2
                bgt.s   tolk_nocaps
tolk_mkuc:      bclr    #5,D2
tolk_nocaps:    cmp.b   (A2)+,D2
                bne.s   tolk_loop
                tst.b   D2
                bne.s   tolk_loop3
                cmp.w   #$FF,D0
                beq.s   tolk_skip
                cmp.w   D0,D1
                bne.s   tolk_syntax
tolk_skip:      jsr     (A1)
tolk_iserr:     tst.w   D0
                beq.s   tolk_end
                move.b  #2,errcount-start(A6)
tolk_error:     bsr     error
tolk_end:       move.w  tmpstdout(PC),D0
                beq.s   tolk_noout
                bsr     closefile
                clr.w   tmpstdout-start(A6)
                move.w  stdout(PC),-(SP)
                move.w  #1,-(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
tolk_noout:     move.w  tmpstdin(PC),D0
                beq.s   tolk_noin
                bsr     closefile
                clr.w   tmpstdin-start(A6)
                move.w  stdin(PC),-(SP)
                clr.w   -(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
tolk_noin:      subq.w  #1,tolk_counter
                rts
tolk_syntax:    move.w  #$80,D0
                bra.s   tolk_iserr
tolk_que:       moveq   #$7F,D0
                bra.s   tolk_iserr
tolk_nocmd:     bsr     testmac
                tst.w   D0
                bne.s   tolk_nomac
                bsr     tolk2
                bra.s   tolk_end
tolk_nomac:     lea     buffer(PC),A0
                sf      (A0)
                bsr.s   testpath
                tst.l   D0
                bpl.s   tolk_iserr
                lea     linebuf(PC),A0
tolk_myloop:    cmpi.b  #'\',(A0)
                beq.s   tolk_que
                cmpi.b  #':',(A0)
                beq.s   tolk_que
                cmpi.b  #' ',(A0)+
                bgt.s   tolk_myloop
                bsr     getpath
                tst.w   D0
                bne.s   tolk_que
tolk_cmdlp:     lea     buffer(PC),A1
tolk_cmdlp2:    move.b  (A0)+,D0
                tst.b   D0
                beq.s   tolk_strend
                cmp.b   #';',D0
                beq.s   tolk_strend
                cmp.b   #',',D0
                beq.s   tolk_strend
                move.b  D0,(A1)+
                bra.s   tolk_cmdlp2
tolk_strend:    sf      (A1)
                move.l  A0,-(SP)
                bsr.s   testpath
                movea.l (SP)+,A0
                tst.l   D0
                bpl     tolk_iserr
                tst.b   -1(A0)
                bne.s   tolk_cmdlp
                bra.s   tolk_que

                ENDPART
                >PART 'Kollar path & k”r program'
; Buffer inneh†ller programnamnet, som givits i kommandot. Missbrukas hejdl”st.
; Alla extensions unders”ks och ett GEM-, TOS-program eller en batchfil k”rs.

testpath:       lea     buffer(PC),A1
                movea.l A1,A0
testpath_loop:  tst.b   (A1)+
                bne.s   testpath_loop
                subq.l  #1,A1
                cmpa.l  A1,A0
                beq.s   testpath_good
                cmpi.b  #':',-1(A1)
                beq.s   testpath_good
                cmpi.b  #'\',-1(A1)
                beq.s   testpath_good
                move.b  #'\',(A1)+
testpath_good:  lea     linebuf(PC),A0
testpath_fnloop:move.b  (A0)+,D0
                cmp.b   #' ',D0
                bls.s   testpath_mkext
                move.b  D0,(A1)+
                bra.s   testpath_fnloop
testpath_mkext: lea     linebuf(PC),A2
testpath_dotlp: move.b  (A2)+,D0
                cmp.b   #' ',D0
                ble.s   testpath_noext
                cmp.b   #'.',D0
                beq.s   testpath_isext
                cmpa.l  A0,A2
                ble.s   testpath_dotlp
testpath_noext: lea     exts(PC),A2
                moveq   #4,D7
                move.b  #'.',(A1)+
                movea.l A1,A5
testpath_extlp: moveq   #2,D0
testpath_extlp2:move.b  (A2)+,(A1)+
                dbra    D0,testpath_extlp2
                move.l  A2,-(SP)
                bsr.s   testpath_extok
                movea.l (SP)+,A2
                movea.l A5,A1
                tst.l   D0
                bpl.s   testpath_end
                dbra    D7,testpath_extlp
testpath_end:   rts
testpath_isext: lea     exts(PC),A0
                moveq   #4,D7
testpath_isext3:movea.l A2,A3
                move.b  (A3)+,D0
                bsr     ucased0
                cmp.b   (A0),D0
                bne.s   testpath_isext2
                move.b  (A3)+,D0
                bsr     ucased0
                cmp.b   1(A0),D0
                bne.s   testpath_isext2
                move.b  (A3)+,D0
                bsr     ucased0
                cmp.b   2(A0),D0
                beq.s   testpath_extok
testpath_isext2:addq.l  #3,A0
                dbra    D7,testpath_isext3
                moveq   #-1,D0
                rts
testpath_extok: sf      (A1)
                move.w  #-1,-(SP)
                pea     buffer(PC)
                move.w  #fsfirst,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.w   D0
                beq.s   testpath_gotit
                moveq   #-1,D0
                rts
testpath_gotit: lea     linebuf(PC),A0
                lea     s1(PC),A1
                sf      (A1)
testpath_cmdlp1:tst.b   (A0)
                beq.s   testpath_nocmd
                cmpi.b  #' ',(A0)+
                bne.s   testpath_cmdlp1
                tst.b   (A0)
                beq.s   testpath_nocmd
                movea.l A0,A2
                movea.l A1,A3
                addq.l  #1,A3
testpath_cmdlp2:addq.b  #1,(A1)
                move.b  (A2)+,(A3)+
                bne.s   testpath_cmdlp2
                subq.b  #1,(A1)
testpath_nocmd: tst.w   D7
                beq     batexec
                cmp.w   #2,D7
                bgt.s   testpath_nogem1
                bsr     gemon
                lea     buffer(PC),A1
testpath_getnam:tst.b   (A1)+
                bne.s   testpath_getnam
                subq.l  #2,A1
                lea     1(A1),A2
testpath_getnm2:cmpa.l  #buffer,A2
                beq.s   testpath_isnam2
                move.b  -(A2),D0
                cmp.b   #'\',D0
                beq.s   testpath_isname
                cmp.b   #':',D0
                bne.s   testpath_getnm2
testpath_isname:addq.l  #1,A2
testpath_isnam2:moveq   #-1,D1
                lea     text_object(PC),A0
testpath_namelp:move.b  (A2)+,D0
                bsr     ucased0
                addq.w  #1,D1
                move.b  D0,(A0)+
                bne.s   testpath_namelp
                move.w  D1,text_length-start(A6)
                moveq   #4,D0
                move.l  D0,intin-start(A6)
                move.l  #wind_get,D0
                bsr     aes
                movem.w intout+2(PC),D0-D3
                move.w  D1,D3
                moveq   #0,D1
                movem.w D0-D3,text_xywh-start(A6)
                move.l  D1,intin-start(A6)
                movem.w D0-D3,intin+4-start(A6)
                lea     object_tree(PC),A0
                move.l  A0,addrin-start(A6)
                move.l  #objc_draw,D0
                bsr     aes
testpath_nogem1:bsr     deinstall
                pea     envbuf(PC)
                pea     s1(PC)
                pea     buffer(PC)
                pea     $4B0000         ; Pexec(0,buffer,s1,envbuf)
                trap    #GEMDOS
                lea     16(SP),SP
                move.w  D0,-(SP)
                cmp.w   #2,D7
                bgt.s   testpath_nogem2
                bsr     gemoff
testpath_nogem2:bsr     install
                moveq   #0,D0
                move.w  (SP)+,D0
                rts

                ENDPART
                >PART 'K”r batchfil'

batexec:        tst.w   bathdl-start(A6)
                beq.s   batexec_noold
                move.w  bathdl(PC),D0
                bsr     closefile
                clr.w   bathdl-start(A6)
batexec_noold:  clr.w   -(SP)
                pea     buffer(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.w   D0
                bmi.s   batexec_baterr
                move.w  D0,bathdl-start(A6)
                moveq   #0,D0
                lea     argbuf(PC),A0
                lea     buffer(PC),A1
batexec_loop2:  move.b  (A1)+,(A0)+
                bne.s   batexec_loop2
                lea     s1(PC),A1
                tst.b   (A1)+
                beq.s   batexec_argend
                move.b  #' ',-1(A0)
batexec_loop3:  move.b  (A1)+,(A0)+
                bne.s   batexec_loop3
batexec_argend: moveq   #0,D0
batexec_baterr: ext.l   D0
                rts

                ENDPART
                >PART 'GEM'
; GEM-rutiner

initgem:        move.l  #appl_init,D0
                bsr     aes
                move.w  #getrez,-(SP)
                trap    #XBIOS
                addq.l  #2,SP
                tst.w   D0
                bne.s   initgem_80col
                move.l  #$020011,status_pos-start(A6)
initgem_80col:  clr.w   intin-start(A6)
                lea     sysdesk(PC),A0
                move.l  A0,addrin-start(A6)
                move.l  #rsrc_obfix,D0
                bsr     aes
                lea     owndesk(PC),A0
                move.l  A0,addrin-start(A6)
                moveq   #5,D6
initgem_loop:   move.w  D6,intin-start(A6)
                move.l  #rsrc_obfix,D0
                bsr     aes
                dbra    D6,initgem_loop
                move.w  #8,image_size-start(A6)
                move.w  #10,image_size2-start(A6)
                move.w  #18,image_size3-start(A6)
                rts

gemon:          moveq   #4,D0
                move.l  D0,intin-start(A6)
                clr.w   intout-start(A6)
                move.l  #wind_get,D0
                bsr     aes
                tst.w   intout-start(A6)
                bne.s   gemon_okidok
                rts
gemon_okidok:   lea     clsstr(PC),A0
                bsr     sendlin
                clr.l   -(SP)
                move.w  #cursconf,-(SP)
                trap    #XBIOS
                addq.l  #6,SP
                move.w  #14,intin+2-start(A6)
                clr.l   intin+4-start(A6)
                clr.w   intin+8-start(A6)
                move.l  #wind_set,D0
                bsr.s   aes
                movem.l intout+2(PC),D0-D1
                move.w  #3,intin-start(A6)
                movem.l D0-D1,intin+2-start(A6)
                movem.l D0-D1,intin+10-start(A6)
                move.l  #form_dial,D0
                bsr.s   aes
                linea   #0 [ Init ]
                lea     $18(A0),A0
                move.l  #$010001,D0
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                addq.l  #4,A0
                clr.w   (A0)+
                movem.w intout+2(PC),D0-D2
                subq.w  #1,D1
                subq.w  #1,D2
                movem.w D0-D2,(A0)
                clr.l   $32(A0)
                linea   #4 [ Hline ]
                linea   #0 [ Init ]
                clr.w   intin-start(A6)
                move.l  #intin,8(A0)
                linea   #9 [ Showm ]
                move.w  #2,intin-start(A6)
                move.l  #graf_mouse,D0

aes:            moveq   #0,D1
                movep.l D1,control-start(A6)
                movep.l D0,control+1-start(A6)
                move.w  D1,control+8-start(A6)
                lea     aespb(PC),A0
                move.l  A0,D1
                move.w  #AES,D0
                trap    #XGEMDOS
                rts

gemoff:         linea   #10 [ Hidem ]
                pea     $010000
                move.w  #cursconf,-(SP)
                trap    #XBIOS
                addq.l  #6,SP
                lea     clsstr(PC),A0
                bra     sendlin

                ENDPART
                >PART 'Upper Case D0'
; G”r VERSALER av d0.b. Fixar Ž™š.

ucased0:        cmp.b   #'a',D0
                blt.s   ucased0_no1
                cmp.b   #'z',D0
                bgt.s   ucased0_no1
                sub.b   #32,D0
ucased0_no1:    cmp.b   #'†',D0
                bne.s   ucased0_no2
                move.b  #'',D0
                rts
ucased0_no2:    cmp.b   #'„',D0
                bne.s   ucased0_no3
                move.b  #'Ž',D0
                rts
ucased0_no3:    cmp.b   #'”',D0
                bne.s   ucased0_no4
                move.b  #'™',D0
                rts
ucased0_no4:    cmp.b   #'',D0
                bne.s   ucased0_no5
                move.b  #'š',D0
                rts
ucased0_no5:    cmp.b   #'‚',D0
                bne.s   ucased0_ret
                move.b  #'',D0
ucased0_ret:    rts

                ENDPART
                >PART 'Skriv ut GEMDOS-fel p† STDERR'
; IN: d0=felnummer. Se tabellen i DATA-segmentet.

error:          cmp.w   #-1,D0
                beq.s   error_okidok
                cmp.w   #$78,D0
                bge.s   error_okidok
                cmp.w   #-32,D0
                bgt.s   error_bye
error_okidok:   lea     errtab(PC),A5
error_loop:     move.b  (A5)+,D1
                beq.s   error_what
                cmp.b   D0,D1
                beq.s   error_gotit
error_loop2:    tst.b   (A5)+
                bne.s   error_loop2
                bra.s   error_loop
error_what:     lea     err1(PC),A5
                bra.s   error_sendit
error_bye:      rts
error_gotit:    move.l  A5,-(SP)
                lea     err_own(PC),A5
                cmp.w   #-1,D0
                beq.s   error_go_ahead
                cmp.w   #$78,D0
                bpl.s   error_go_ahead
                cmp.b   #$80,D0
                beq.s   error_go_ahead
                lea     err_num(PC),A0
                move.w  D0,D1
                neg.w   D1
                bsr     mk2dig
                lea     err_gemdos(PC),A5
error_go_ahead: bsr.s   error_sendit
                movea.l (SP)+,A5
                bsr.s   error_sendit
                lea     crlf(PC),A5
error_sendit:   moveq   #0,D0
                move.b  (A5)+,D0
                beq.s   error_bye
                bsr     sendcharerr
                bra.s   error_sendit

                ENDPART
                >PART 'Getarg, k”r versaler av 2 arg'
; Tar de f”rsta tv† argumenten, g”r versaler av dem och stoppar in dem i s1 & s2

getarg:         lea     linebuf(PC),A0
                sf      s1-linebuf(A0)
                sf      s2-linebuf(A0)
getarg_lp1:     cmpi.b  #' ',(A0)+
                bhi.s   getarg_lp1
                tst.b   -1(A0)
                beq.s   getarg_end
                lea     s1(PC),A1
                bsr.s   getarg_copy
                tst.b   D0
                beq.s   getarg_end
                lea     s2(PC),A1
getarg_copy:    move.b  (A0)+,D0
                cmp.b   #' ',D0
                bls.s   getarg_cpyend
                bsr     ucased0
                move.b  D0,(A1)+
                bra.s   getarg_copy
getarg_cpyend:  sf      (A1)
getarg_end:     rts

                ENDPART
                >PART 'I/O Setup'

; Rutin som dubblerar stdin & stdout och sparar dem tills vidare. Kollar „ven
; stderr enligt isatty() & skickar till CON: om stderr inte „r en fil.

setupio:        clr.w   -(SP)
                move.w  #fdup,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                tst.w   D0
                bmi     exit
                move.w  D0,stdin-start(A6)
                move.w  #1,-(SP)
                move.w  #fdup,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                tst.w   D0
                bmi     exit
                move.w  D0,stdout-start(A6)
                moveq   #2,D0
                bsr     isatty
                tst.l   D0
                bne.s   setupio_notty
                move.w  #-1,-(SP)
                move.w  #2,-(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
setupio_notty:  rts

                ENDPART
                >PART 'Tolka environment-variabler'
; Kollar om n†gra variabler (inom parenteser + %) finns i linebuf.
; Dessa tolkas om de inte befinner sig inom krullparenteser {}.
; Format: goja...goja...goja...(%VAR%)...goja...goja...goja...

testvar:        lea     linebuf(PC),A0
                lea     buffer(PC),A1
                moveq   #0,D1
testvar_loop:   move.b  (A0)+,D0
                cmp.b   #'{',D0
                bne.s   testvar_noleft
                addq.w  #1,D1
                bra.s   testvar_cont
testvar_noleft: cmp.b   #'}',D1
                bne.s   testvar_noright
                subq.w  #1,D1
                bra.s   testvar_cont
testvar_noright:tst.w   D1
                bne.s   testvar_cont
                cmp.b   #'(',D0
                bne.s   testvar_cont
                cmpi.b  #'%',(A0)
                bne.s   testvar_cont
                addq.l  #1,A0
                bra.s   testvar_isvar
testvar_cont:   move.b  D0,(A1)+
                beq.s   testvar_end1
                cmpa.l  #buffer+300,A1
                blt.s   testvar_loop
testvar_end1:   sf      buffer+299-start(A6)
                lea     buffer(PC),A0
                lea     linebuf(PC),A1
testvar_loop2:  move.b  (A0)+,(A1)+
                bne.s   testvar_loop2
testvar_end:    rts
testvar_isvar:  lea     s1(PC),A2
testvar_loop3:  move.b  (A0)+,D0
                beq.s   testvar_end
                cmp.b   #'%',D0
                bne.s   testvar_noend
                cmpi.b  #')',(A0)
                beq.s   testvar_varend
testvar_noend:  bsr     ucased0
                move.b  D0,(A2)+
                bra.s   testvar_loop3
testvar_varend: addq.l  #1,A0
                sf      (A2)
                movem.l A0-A1,-(SP)
                bsr     findenv
                movea.l A0,A2
                movem.l (SP)+,A0-A1
                tst.w   D0
                bmi.s   testvar_loop
testvar_loop4:  move.b  (A2)+,D0
                cmpa.l  #buffer+300,A1
                bge.s   testvar_end1
                move.b  D0,(A1)+
                bne.s   testvar_loop4
                subq.l  #1,A1
                bra     testvar_loop

                ENDPART
                >PART 'Tolka I/O-redirection'
; Tar hand om >fil, >>fil och <fil. Fungerar bara p† TOS 1.4 (GEMDOS 0.21) och
; senare. Om man f”rs”ker k”ra detta med tidigare TOS skrivs felmeddelande ut.
; Om n†got av tecknen <, > eller >> ing†r i krullisar {} sker ingen omstyrning.

testio:         move.w  stdout(PC),-(SP)
                move.w  #1,-(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                move.w  tmpstdout(PC),D0
                beq.s   testio_noout2
                bsr     closefile
                clr.w   tmpstdout-start(A6)
testio_noout2:  move.w  stdin(PC),-(SP)
                clr.w   -(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                move.w  tmpstdin(PC),D0
                beq.s   testio_noin2
                bsr     closefile
                clr.w   tmpstdin-start(A6)
testio_noin2:   lea     linebuf(PC),A0
                sf      stdoutfile-start(A6)
                sf      stdinfile-start(A6)
                moveq   #0,D7
testio_loop:    move.b  (A0)+,D0
                beq     testio_real_end
                cmp.b   #'{',D0
                bne.s   testio_noleft
                addq.w  #1,D7
                bra.s   testio_loop
testio_noleft:  cmp.b   #'}',D0
                bne.s   testio_noright
                subq.w  #1,D7
                bra.s   testio_loop
testio_noright: tst.w   D7
                bne.s   testio_loop
                cmp.b   #'>',D0
                bne     testio_noout
                move.l  A0,-(SP)
                bsr     testio_move
                move.w  #sversion,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                cmp.w   #$1500,D0
                bpl.s   testio_tosok1
                moveq   #$7D,D0
testio_outerr:  bsr     error
                bra.s   testio_skpout
testio_tosok1:  move.w  tmpstdout(PC),D0
                beq.s   testio_noold
                bsr     closefile
testio_noold:   movea.l (SP),A0
                cmpi.b  #'>',(A0)
                beq.s   testio_addout
                clr.w   -(SP)
                pea     buffer(PC)
                move.w  #fcreate,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.l   D0
                bmi.s   testio_outerr
                move.w  D0,tmpstdout-start(A6)
                bra.s   testio_outok
testio_addout:  move.w  #1,-(SP)
                pea     buffer(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.l   D0
                bmi.s   testio_outerr
                move.w  D0,tmpstdout-start(A6)
                move.w  #2,-(SP)
                move.w  D0,-(SP)
                clr.l   -(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                tst.l   D0
                bmi.s   testio_outerr
testio_outok:   move.w  tmpstdout(PC),-(SP)
                move.w  #1,-(SP)
                move.w  #fforce,-(SP)
                trap    #1
                addq.l  #6,SP
                tst.w   D0
                bmi.s   testio_outerr
                movea.l (SP),A0
                lea     stdoutfile(PC),A1
testio_copylp1: move.b  (A0)+,(A1)+
                bne.s   testio_copylp1
testio_skpout:  movea.l (SP)+,A0
                subq.l  #1,A0
                bra     testio_loop
testio_noout:   cmp.b   #'<',D0
                bne     testio_loop
                move.l  A0,-(SP)
                bsr.s   testio_move
                move.w  #sversion,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                cmp.w   #$1500,D0
                bpl.s   testio_tosok2
                moveq   #$7D,D0
                bsr     error
                bra.s   testio_skpout
testio_tosok2:  move.w  tmpstdin(PC),D0
                beq.s   testio_noin
                bsr     closefile
testio_noin:    clr.w   -(SP)
                pea     buffer(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.l   D0
                bmi     testio_outerr
                move.w  D0,tmpstdin-start(A6)
                move.w  D0,-(SP)
                clr.w   -(SP)
                move.w  #fforce,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                tst.w   D0
                bmi     testio_outerr
                movea.l (SP),A0
                lea     stdinfile(PC),A1
testio_copylp2: move.b  (A0)+,(A1)+
                bne.s   testio_copylp2
                bra.s   testio_skpout
testio_move:    movea.l A0,A1
                cmpi.b  #'>',(A1)
                bne.s   testio_noadd
                addq.l  #1,A1
testio_noadd:   subq.l  #1,A0
                lea     buffer(PC),A2
testio_loop2:   move.b  (A1)+,D0
                cmp.b   #' ',D0
                ble.s   testio_end
                move.b  D0,(A2)+
                bra.s   testio_loop2
testio_end:     sf      (A2)
                subq.l  #1,A1
testio_loop3:   move.b  (A1)+,(A0)+
                bne.s   testio_loop3
testio_real_end:rts

                ENDPART
                >PART 'Tolka macros'
; Tolkar och konverterar macros.

testmac:        lea     macbuf(PC),A1
testmac_loop1:  lea     linebuf(PC),A0
                movea.l A1,A2
testmac_loop2:  move.b  (A1)+,D1
                beq.s   testmac_tstend
                move.b  (A0)+,D0
                bsr     ucased0
                cmp.b   #' ',D0
                bgt.s   testmac_noend1
                cmp.b   #' ',D1
                beq.s   testmac_gotit
testmac_noend1: cmp.b   D1,D0
                beq.s   testmac_loop2
testmac_getend: tst.b   (A1)+
                bne.s   testmac_getend
                bra.s   testmac_loop1
testmac_loop3:  tst.b   (A1)+
                bne.s   testmac_loop3
testmac_tstend: tst.b   (A1)
                bne.s   testmac_loop1
                moveq   #-1,D0
                rts
testmac_gotit:  move.b  (A2)+,D0
                cmp.b   #' ',D0
                bgt.s   testmac_gotit
                lea     buffer(PC),A0
testmac_loop4:  move.b  (A2)+,D0
                cmp.b   #'&',D0
                bne.s   testmac_nometa
                move.b  (A2)+,D1
                cmp.b   #'A',D1
                beq.s   testmac_all
                cmp.b   #'a',D1
                beq.s   testmac_all
                sub.b   #'0',D1
                bls.s   testmac_nometa2
                cmp.b   #9,D1
                bhi.s   testmac_nometa2
                lea     linebuf(PC),A1
                ext.w   D1
testmac_loop6:  movea.l A1,A3
testmac_loop5:  move.b  (A1)+,D0
                bne.s   testmac_nonul
                tst.w   D1
                bne.s   testmac_loop4
testmac_nonul:  cmp.b   #' ',D0
                bhi.s   testmac_loop5
                dbra    D1,testmac_loop6
testmac_loop7:  move.b  (A3)+,D0
                cmp.b   #' ',D0
                bls.s   testmac_loop4
                cmpa.l  #bufferend,A0
                bge.s   testmac_full
                move.b  D0,(A0)+
                bra.s   testmac_loop7
testmac_nometa2:cmp.l   #bufferend,D0
                bge.s   testmac_full
                move.b  D0,(A0)+
                move.b  D1,D0
                add.b   #'0',D0
testmac_nometa: cmpa.l  #bufferend,A0
                bge.s   testmac_full
                move.b  D0,(A0)+
                bne.s   testmac_loop4
testmac_full:   sf      bufferend-1-start(A6)
                lea     buffer(PC),A0
                lea     linebuf(PC),A1
testmac_loop8:  move.b  (A0)+,(A1)+
                bne.s   testmac_loop8
                moveq   #0,D0
                rts
testmac_all:    move.l  A1,-(SP)
                lea     linebuf(PC),A1
testmac_loop9:  cmpi.b  #' ',(A1)+
                bgt.s   testmac_loop9
                tst.b   -1(A1)
                beq.s   testmac_bluff
testmac_loop10: cmpa.l  #bufferend,A0
                bge.s   testmacUfull2
                move.b  (A1)+,(A0)+
                bne.s   testmac_loop10
                subq.l  #1,A0
testmac_bluff:  movea.l (SP)+,A1
                bra     testmac_loop4
testmacUfull2:  movea.l (SP)+,A1
                bra.s   testmac_full

                ENDPART
                >PART 'I/O-rutiner'

sendlin2:       bsr.s   sendlin
docrlf:         lea     crlf(PC),A0

sendlin:        move.l  A0,-(SP)
                move.w  #cconws,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                moveq   #0,D0
                rts

sendchar:       and.w   #$FF,D0
                move.w  D0,-(SP)
                move.w  #cconout,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                rts

getchar:        move.w  #crawcin,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                rts

getchar_echo:   move.w  #cconin,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                rts

sendcharerr:    move.w  D0,-(SP)
                move.w  #cauxout,-(SP)  ; STDERR=STDAUX. Varf”r inte?
                trap    #GEMDOS
                addq.l  #4,SP
                rts

closefile:      move.w  D0,-(SP)
                move.w  #fclose,-(SP)
                trap    #GEMDOS
                addq.l  #4,SP
                rts

                ENDPART
                >PART 'Mk2Dig'

; IN: D1.W = Tal
;     A0 -> utrymme om tv† bytes att dumpa siffrorna i. Skriver allts† inte ut.

mk2dig:         and.l   #$FFFF,D1
                divu    #10,D1
                add.b   #'0',D1
                move.b  D1,(A0)+
                swap    D1
                add.b   #'0',D1
                move.b  D1,(A0)+
                rts

                ENDPART
                >PART 'Evaluate'

; Ber„knar v„rdet av ett uttryck. Skiter fullst„ndigt i operatorordning och
; s†nt tjafs och utv„rderar fr†n v„nster till h”ger. 5+4*2=18 men 5+(4*2)=13.
; IN: A0 -> str„ng
; UT: D0=tal, D1.w=typ (0=.W, 1=.L, -1=fnurr). Om D1.W=-1 inneh†ller D0 @~?*!.

; Klarar + - * / % (MOD) & (AND) | (OR) ^ (XOR)
; @(adress) motsvarar PEEK(adress). "adress" b”r vara longword.
; W(uttryck) omvandlar longword till word.

evaluate:       movem.l D3-D7/A1,-(SP)
                moveq   #0,D4           ; Resultat (0)
                moveq   #'+',D5         ; Nuvarande operation
                moveq   #0,D6           ; Resultatets storlek (.W)
                moveq   #0,D7           ; Flagga (0 = fler termer, !=0 = nix)
evaluate_loop2: tst.b   (A0)
                beq     evaluate_break
                cmpi.b  #'(',(A0)
                bne.s   evaluate_nolpar
evaluate_par:   addq.l  #1,A0
                bsr.s   evaluate
                move.b  (A0)+,D2
                cmp.b   #')',D2
                bne.s   evaluate_skip
                moveq   #-1,D7
                bra.s   evaluate_skip
evaluate_nolpar:cmpi.b  #'@',(A0)
                bne.s   evaluate_noindir
                addq.l  #1,A0
                cmpi.b  #'(',(A0)+
                bne.s   evaluate_syntax
                bsr.s   evaluate
                movem.l D1-A0,-(SP)
                move.l  D0,evaluate_temp-start(A6)
                pea     evaluate_super(PC)
                move.w  #supexec,-(SP)
                trap    #XBIOS
                addq.l  #6,SP
                movem.l (SP)+,D1-A0
                move.b  (A0)+,D2
                cmp.b   #')',D2
                bne.s   evaluate_skip
                moveq   #-1,D7
                bra.s   evaluate_skip
evaluate_noindir:cmpi.b #'W',(A0)
                beq.s   evaluate_isl2w
                cmpi.b  #'w',(A0)
                bne.s   evaluate_nol2w
evaluate_isl2w: addq.l  #1,A0
                cmpi.b  #'(',(A0)+
                bne.s   evaluate_syntax
                bsr.s   evaluate
                and.l   #$FFFF,D0
                moveq   #0,D1
                moveq   #0,D6
                move.b  (A0)+,D2
                cmp.b   #')',D2
                bne.s   evaluate_skip
                moveq   #-1,D7
                bra.s   evaluate_skip
evaluate_nol2w: bsr.s   evaluate_sub
evaluate_skip:  tst.w   D1
                bmi.s   evaluate_break
                bsr     evaluate_do
                tst.w   D7
                beq     evaluate_loop2
evaluate_break: move.w  D6,D1
                move.l  D4,D0
                movem.l (SP)+,D3-D7/A1
                rts
evaluate_break2:move.b  (A0)+,D2
                bra.s   evaluate_break
evaluate_syntax:moveq   #-1,D6
                bra.s   evaluate_break

evaluate_sub:   move.b  (A0),D0
                beq     evaluate_fnurr
                bsr     ucased0
                moveq   #0,D1
                cmp.b   #'L',D0
                bne.s   evaluate_action
                cmpi.b  #':',1(A0)
                bne     evaluate_fnurr
                addq.l  #2,A0
                moveq   #1,D1
evaluate_action:moveq   #0,D0
                moveq   #0,D2
                move.b  (A0)+,D2
                beq.s   evaluate_fnurr
                moveq   #10,D3
                cmp.b   #'$',D2
                bne.s   evaluate_loop
                moveq   #16,D3
                move.b  (A0)+,D2
evaluate_loop:  tst.b   D2
                beq.s   evaluate_ok
                cmp.b   #' ',D2
                beq.s   evaluate_ok
                cmp.b   #')',D2
                beq.s   evaluate_ok
                cmp.b   #'+',D2
                beq.s   evaluate_back
                cmp.b   #'-',D2
                beq.s   evaluate_back
                cmp.b   #'*',D2
                beq.s   evaluate_back
                cmp.b   #'%',D2
                beq.s   evaluate_back
                cmp.b   #'/',D2
                beq.s   evaluate_back
                cmp.b   #'&',D2
                beq.s   evaluate_back
                cmp.b   #'|',D2
                beq.s   evaluate_back
                cmp.b   #'^',D2
                beq.s   evaluate_back
                sub.b   #'0',D2
                bmi.s   evaluate_fnurr
                cmp.b   #9,D2
                ble.s   evaluate_dec
                sub.b   #'A'-'9'-1,D2
                cmp.b   #$0F,D2
                bgt.s   evaluate_fnurr
evaluate_dec:   cmp.b   #16,D3
                beq.s   evaluate_hex
                movea.l D0,A1
                adda.l  A1,A1
                lsl.l   #3,D0
                add.l   A1,D0
evaluate_cont:  add.l   D2,D0
                move.b  (A0)+,D2
                bra.s   evaluate_loop
evaluate_hex:   lsl.l   #4,D0
                bra.s   evaluate_cont
evaluate_ok:    moveq   #-1,D7
evaluate_back:  rts
evaluate_fnurr: moveq   #-1,D1
                rts

evaluate_do:    or.w    D1,D6
                cmp.b   #'+',D5
                beq.s   plus
                cmp.b   #'-',D5
                beq.s   minus
                cmp.b   #'*',D5
                beq.s   mult
                cmp.b   #'/',D5
                beq.s   div
                cmp.b   #'%',D5
                beq.s   mod
                cmp.b   #'&',D5
                beq.s   and
                cmp.b   #'|',D5
                beq.s   or
                cmp.b   #'^',D5
                beq.s   xor
                rts
plus:           add.l   D0,D4
                bra.s   evaluate_do_end
minus:          sub.l   D0,D4
                bra.s   evaluate_do_end
mult:           mulu    D0,D4
                bra.s   evaluate_do_end
div:            divu    D0,D4
                and.l   #$FFFF,D4
                bra.s   evaluate_do_end
mod:            divu    D0,D4
                swap    D4
                and.l   #$FFFF,D4
                bra.s   evaluate_do_end
and:            and.l   D0,D4
                bra.s   evaluate_do_end
or:             or.l    D0,D4
                bra.s   evaluate_do_end
xor:            eor.l   D0,D4
evaluate_do_end:move.b  D2,D5
                rts

evaluate_super: movea.l evaluate_temp(PC),A0
                moveq   #3,D1
evaluate_suplp: rol.l   #8,D0
                move.b  (A0)+,D0
                dbra    D1,evaluate_suplp
                rts

                ENDPART
                >PART 'Bin2HexW & Bin2HexL'

; Rutiner f”r att omvandla fr†n bin„rt till hex-text.
; IN: D0=tal, A0 -> buffert
; UT: A0 -> n„sta byte efter hextalet. NULL fylls INTE i.

bin2hexw:       moveq   #3,D1
                move.b  #'$',(A0)+
bin2hexw_loop:  rol.w   #4,D0
                move.b  D0,D2
                and.b   #$0F,D2
                cmp.b   #9,D2
                ble.s   bin2hexw_dec
                add.b   #'A'-'9'-1,D2
bin2hexw_dec:   add.b   #'0',D2
                move.b  D2,(A0)+
                dbra    D1,bin2hexw_loop
                rts

bin2hexl:       moveq   #7,D1
                move.b  #'L',(A0)+
                move.b  #':',(A0)+
                move.b  #'$',(A0)+
bin2hexl_loop:  rol.l   #4,D0
                move.b  D0,D2
                and.b   #$0F,D2
                cmp.b   #9,D2
                ble.s   bin2hexl_dec
                add.b   #'A'-'9'-1,D2
bin2hexl_dec:   add.b   #'0',D2
                move.b  D2,(A0)+
                dbra    D1,bin2hexl_loop
                rts

                ENDPART
                >PART 'etv_term & etv_critic'

install:        pea     myterm(PC)
                pea     $050102         ; setvec($102,myterm)
                trap    #BIOS
                addq.l  #8,SP
                move.l  D0,oldterm-start(A6)
                pea     mycrit(PC)
                pea     $050101         ; setvec($101,mycrit)
                trap    #BIOS
                addq.l  #8,SP
                move.l  D0,oldcrit-start(A6)
                rts

deinstall:      move.l  oldterm(PC),-(SP)
                pea     $050102         ; setvec($102,(oldterm) )
                trap    #BIOS
                addq.l  #8,SP
                move.l  oldcrit(PC),-(SP)
                pea     $050101         ; setvec($101,(oldcrit) )
                trap    #BIOS
                addq.l  #8,SP
                rts

; Tar hand om Ctrl-C. Ser till att supervisormode INTE infinner sig.
; St„nger filer och batchfiler.

myterm:         lea     start(PC),A6
                move    SR,D0
                btst    #13,D0
                beq.s   myterm_user
                andi    #$DFFF,SR
myterm_user:    bsr     close
                move.w  bathdl(PC),D0
                beq.s   myterm_nobat
                bsr     closefile
                clr.w   bathdl
myterm_nobat:   lea     mystack,SP
                bra     main

; Hanterar BIOS-fel. Upptr„der som en PC (Abort, Retry, Ignore).
; Primitivt, men det fungerar.

mycrit:         move.w  4(SP),D1
                cmp.w   #-17,D1
                beq     mycrit_media
                neg.w   D1
                lea     crit2(PC),A0
                bsr     mk2dig
                lea     crit1(PC),A0
                bsr     biosprt
                lea     errtab(PC),A0
                move.w  4(SP),D0
mycrit_loop:    move.b  (A0)+,D1
                beq.s   mycrit_undef
                cmp.b   D1,D0
                beq.s   mycrit_gotit
mycrit_loop2:   tst.b   (A0)+
                bne.s   mycrit_loop2
                bra.s   mycrit_loop
mycrit_undef:   lea     err1(PC),A0
                bsr     biosprt
                bra.s   mycrit_loop3
mycrit_gotit:   bsr     biosprt
                cmpi.w  #-17,4(SP)
                bmi.s   mycrit_nodrive

                lea     drive_message(PC),A0
                bsr     biosprt

                move.w  6(SP),D0
                add.w   #'A',D0
                move.w  D0,-(SP)
                pea     $030002
                trap    #BIOS
                addq.l  #6,SP

mycrit_nodrive: move.w  #'.',-(SP)
                pea     $030002
                trap    #BIOS
                addq.l  #6,SP
                lea     crlf(PC),A0
                bsr.s   biosprt
mycrit_loop3:   lea     crit3(PC),A0
                bsr.s   biosprt

                pea     $020002
                trap    #BIOS
                addq.l  #4,SP
                and.w   #$DF,D0
                move.w  D0,-(SP)
                move.w  D0,-(SP)
                pea     $030002
                trap    #BIOS
                addq.l  #6,SP

                lea     crlf(PC),A0
                bsr.s   biosprt
                move.w  (SP)+,D0
                cmp.b   #'I',D0
                beq.s   mycrit_ignore
                cmp.b   #'R',D0
                beq.s   mycrit_retry
                cmp.b   #'A',D0
                bne.s   mycrit_loop3
                move.w  4(SP),D0
                ext.l   D0
                rts
mycrit_ignore:  moveq   #0,D0
                rts
mycrit_retry:   moveq   #1,D0
                swap    D0
                rts
mycrit_media:   move.w  6(SP),D0
                add.w   #'A',D0
                move.b  D0,crit4a
                lea     crit4(PC),A0
                bsr.s   biosprt
                move.l  #$020002,-(SP)
                trap    #BIOS
                addq.l  #4,SP
                rts

                ENDPART
                >PART 'BIOSprint'
; IN: A0-> Str„ng. Det „r n„mligen inte s† bra att l†ta etv_critic anv„nda
; GEMDOS' standard I/O.

biosprt:        move.l  A0,-(SP)
biosprt_loop:   movea.l (SP)+,A0
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   biosprt_end
                move.l  A0,-(SP)
                move.w  D0,-(SP)
                pea     $030002         ; bconout(2, D0)
                trap    #BIOS
                addq.l  #6,SP
                bra.s   biosprt_loop
biosprt_end:    rts

                ENDPART
                >PART 'Expandera s”kv„g'

; Expanderar en s”kv„g, t ex a:pelle.prg till a:\folder\pelle.prg
; IN: a0 -> buffert med s”kv„gen. Bufferten ska ha plats till den exp. s”kv„gen
; UT: expanderad s”kv„g i samma buffert
; L†ter stacken sv„lla med 128 bytes (rensar naturligtvis efter sig).

expand:         link    A5,#-128
                move.l  A0,-(SP)
                lea     -128(A5),A1
                move.b  (A0),D0
                beq.s   expand_isnodrv
                cmpi.b  #':',1(A0)
                beq.s   expand_isdrv
expand_isnodrv: movem.l A0-A1,-(SP)
                move.w  #dgetdrv,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                movem.l (SP)+,A0-A1
                add.b   #'A',D0
                move.b  D0,(A1)+
                move.b  #':',(A1)+
                bra.s   expand_nodrv
expand_isdrv:   move.b  (A0)+,(A1)+
                move.b  (A0)+,(A1)+
expand_nodrv:   and.w   #$DF,D0
                sub.b   #'A',D0
                movem.l D0/A0-A1,-(SP)
                move.w  D0,-(SP)
                move.w  #mediach,-(SP)
                trap    #BIOS
                addq.l  #4,SP
                move.w  D0,D1
                movem.l (SP)+,D0/A0-A1
                subq.w  #1,D1
                ble.s   expand_nomch
                move.b  #'\',(A1)+
                cmpi.b  #'\',(A0)
                bne.s   expand_isroot
                addq.l  #1,A0
                bra.s   expand_isroot
expand_nomch:   addq.w  #1,D0
                cmpi.b  #'\',(A0)
                beq.s   expand_isroot
                movem.l A0-A1,-(SP)
                move.w  D0,-(SP)
                move.l  A1,-(SP)
                move.w  #fgetpath,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                movem.l (SP)+,A0-A1
expand_loop:    tst.b   (A1)+
                bne.s   expand_loop
                move.b  #'\',-1(A1)
expand_isroot:  move.b  (A0)+,(A1)+
                bne.s   expand_isroot
                lea     -128(A5),A0
                movea.l (SP)+,A1
expand_loop2:   move.b  (A0)+,D0
                bsr     ucased0
                move.b  D0,(A1)+
                bne.s   expand_loop2
                unlk    A5
                rts

                ENDPART
                >PART 'Environment-subrutiner'
; Subrutiner f”r variabelhanteringen

makeenv:        movea.l start-256+bp_env(PC),A0
                lea     envbuf(PC),A1
                move.l  A1,start-256+bp_env-start(A6)
                lea     envbufend(PC),A2
makeenv_loop:   cmpa.l  A2,A1
                bpl.s   makeenv_cont
                move.b  (A0)+,(A1)+
                bne.s   makeenv_loop
                tst.b   (A0)
                bne.s   makeenv_loop
                lea     buf_str(PC),A0
makeenv_loop2:  cmpa.l  A2,A1
                bpl.s   makeenv_cont
                move.b  (A0)+,(A1)+
                bne.s   makeenv_loop2
                lea     dta(PC),A0
                move.l  A0,D0
                movea.l A1,A0
                bsr     bin2hexl
                sf      (A0)+
                sf      (A0)
                rts
makeenv_cont:   sf      envbufend-start(A6)
                sf      envbufend+1-start(A6)
                rts

findenv:        moveq   #0,D0
                lea     envbuf(PC),A1
findenv_loop:   tst.b   (A1)
                beq.s   findenv_fail
                lea     s1(PC),A0
                movea.l A1,A2
findenv_loop1:  cmpm.b  (A0)+,(A1)+
                beq.s   findenv_loop1
                tst.b   -1(A0)
                bne.s   findenv_loop2
                cmpi.b  #'=',-1(A1)
                beq.s   findenv_end
findenv_loop2:  tst.b   (A1)+
                bne.s   findenv_loop2
                bra.s   findenv_loop
findenv_fail:   moveq   #-1,D0
findenv_end:    addq.l  #1,A1
                movea.l A1,A0
                movea.l A2,A1
                rts

askenv:         bsr.s   findenv
                tst.w   D0
                bne.s   askenv_fail
                move.l  A0,-(SP)
                movea.l A1,A0
                bsr     sendlin
                movea.l (SP)+,A0
                bsr     sendlin2
                moveq   #0,D0
askenv_fail:    rts

setenv:         lea     s1(PC),A0
setenv_loop:    cmpi.b  #'=',(A0)+
                bne.s   setenv_loop
                sf      -1(A0)
                tst.b   (A0)
                seq     D7              ; Flagga: FF=radera bara
                bsr.s   findenv
                tst.w   D0
                bne.s   setenv_nodel

setenv_dellp:   tst.b   (A0)+           ; Radera
                bne.s   setenv_dellp    ; F† a0 att peka p† str„ngens slut
setenv_dellp2:  tst.b   (A0)            ; Inga fler efter?
                beq.s   setenv_delend
setenv_dellp3:  move.b  (A0)+,(A1)+
                bne.s   setenv_dellp3
                bra.s   setenv_dellp2
setenv_delend:  sf      (A1)+
                sf      (A1)

setenv_nodel:   tst.b   D7
                bne.s   setenv_cont

                lea     s1(PC),A0
setenv_qearch:  tst.b   (A0)+
                bne.s   setenv_qearch
                movea.l A0,A5
                lea     envbuf(PC),A0
setenv_setlp:   tst.b   (A0)+
                bne.s   setenv_setlp
                tst.b   (A0)
                bne.s   setenv_setlp
                cmpa.l  #envbuf+1,A0
                bne.s   setenv_nostrt
                lea     envbuf(PC),A0
setenv_nostrt:  lea     s1(PC),A1
                lea     envbufend(PC),A2
setenv_setlp2:  cmpa.l  A2,A0
                blt.s   setenv_nofull
setenv_full:    sf      (A2)
                sf      -(A2)
                bra.s   setenv_cont
setenv_nofull:  move.b  (A1)+,(A0)+
                bne.s   setenv_setlp2
                move.b  #'=',-1(A0)
                cmpa.l  A2,A0
                bge.s   setenv_full
                sf      (A0)+
setenv_setlp3:  cmpa.l  A2,A0
                bge.s   setenv_full
                move.b  (A5)+,(A0)+
                bne.s   setenv_setlp3
                sf      (A0)
setenv_cont:    moveq   #0,D0
                rts

getpath:        lea     pathstr(PC),A0
                lea     s1(PC),A1
                moveq   #5,D0
getpath_loop:   move.b  (A0)+,(A1)+
                dbra    D0,getpath_loop
                bra     findenv

make_ans:       move.l  D0,-(SP)
                lea     out_str1(PC),A1
                lea     s1(PC),A0
make_ans_setlp1:move.b  (A1)+,(A0)+
                bne.s   make_ans_setlp1
                subq.l  #1,A0
                bsr     bin2hexw
                sf      (A0)
                bsr     setenv
                move.l  (SP)+,D0
                lea     out_str2(PC),A1
                lea     s1(PC),A0
make_ans_setlp2:move.b  (A1)+,(A0)+
                bne.s   make_ans_setlp2
                subq.l  #1,A0
                bsr     bin2hexl
                sf      (A0)
                bra     setenv

                ENDPART
                >PART 'St„ng alla (2) filer'

close:          move.w  handle1(PC),D0
                tst.w   D0
                beq.s   close_skip1
                bsr     closefile
                clr.w   handle1-start(A6)
close_skip1:    move.w  handle2(PC),D0
                tst.w   D0
                beq.s   close_skip2
                bsr     closefile
                clr.w   handle2-start(A6)
close_skip2:    rts

                ENDPART
                >PART 'IsATTY'

; Kollar om handle i D0 „r en TTY (sk„rm p† svenska).
; UT: D0.L=0 => Sk„rm
;     D0.L<>0 => Icke-sk„rm

isatty:         movem.l D5-D7,-(SP)
                move.w  D0,D5
                move.w  #1,-(SP)
                move.w  D5,-(SP)
                clr.l   -(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                move.l  D0,D7           ; Gamla pos i d7
                clr.w   -(SP)
                move.w  D5,-(SP)
                pea     1.w
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                move.l  D0,D6
                clr.w   -(SP)
                move.w  D5,-(SP)
                move.l  D7,-(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                move.l  D6,D0
                movem.l (SP)+,D5-D7
                rts

                ENDPART
                >PART 'Sortera str„ngar'

; Bubblesorterar macrosarna p† l„ttaste s„tt. Anv„nder buffer
; OCH LINEBUF (!!!!!) redl”st.
; Fungerar som f”ljer:
; Spanar igenom macrobufferten g†ng p† g†ng. Om tv† p† varandra f”ljande
; macros ligger i fel ordning, f†r de byta plats och en flagga s„tts.
; Om bufferten spanats igenom och flaggan inte „r satt ligger allts† alla
; macros som de ska. Primitivt, men det funkar.

macsort:        moveq   #0,D7           ; Flagga f”r byten skedda p† sistone
                lea     macbuf(PC),A0
macsort_loop0:  bsr.s   macsort]next
                tst.b   (A1)
                beq.s   macsort_done1
                movem.l A0-A1,-(SP)
                bsr.s   mac_strcmp
                tst.w   D0
                ble.s   macsort_noswap
                movem.l (SP),A0-A1
                moveq   #-1,D7
                lea     buffer(PC),A2
macsort_loop1:  move.b  (A0)+,(A2)+
                bne.s   macsort_loop1
                lea     linebuf(PC),A2
macsort_loop2:  move.b  (A1)+,(A2)+
                bne.s   macsort_loop2
                movem.l (SP),A0-A1
                lea     linebuf(PC),A1
macsort_loop3:  move.b  (A1)+,(A0)+
                bne.s   macsort_loop3
                lea     buffer(PC),A1
macsort_loop4:  move.b  (A1)+,(A0)+
                bne.s   macsort_loop4
macsort_noswap: movem.l (SP)+,A0-A1
                bsr.s   macsort]next
                movea.l A1,A0
                bra.s   macsort_loop0
macsort_done1:  tst.w   D7
                bne.s   macsort
                rts

; Tar fram n„sta macro
; IN: A0->macro
; UT: A1->n„sta macro ('\0' om slut)

macsort]next:   movea.l A0,A1
macsort_next_lp:tst.b   (A1)+
                bne.s   macsort_next_lp
                rts

; J„mf”r str„ngar pekade p† av A0(str1) / A1(str2).
; UT: D0=0 => str1=str2
; D0<0 => str1<str2
; D0>0 => str1>str2
; A0, A1, D0 sabbas

mac_strcmp:     move.b  (A0)+,D0
                beq.s   mac_strcmp_null
                sub.b   (A1)+,D0
                beq.s   mac_strcmp
                bra.s   mac_stramp_end
mac_strcmp_null:sub.b   (A1),D0
mac_stramp_end: ext.w   D0
                rts

                ENDPART
; Kommandon
                >PART 'ASK'

ask:            tst.w   bathdl-start(A6)
                beq.s   ask_nobat
                lea     s1(PC),A1
                sf      (A1)
                lea     linebuf(PC),A0
ask_loop:       move.b  (A0)+,D0
                beq.s   ask_noprpt
                cmp.b   #' ',D0
                bne.s   ask_loop
ask_loop2:      move.b  (A0)+,(A1)+
                bne.s   ask_loop2
ask_noprpt:     moveq   #0,D0
                bsr     isatty
                tst.l   D0
                bne.s   ask_notty
                lea     s1(PC),A0
                bsr     readln
ask_tolka:      lea     linebuf(PC),A0
                lea     argbuf(PC),A1
ask_loop5:      cmpi.b  #' ',(A1)+
                bgt.s   ask_loop5
                sf      -1(A1)
                tst.b   (A0)
                beq.s   ask_empty
                move.b  #' ',-1(A1)
ask_loop6:      move.b  (A0)+,(A1)+
                bne.s   ask_loop6
ask_empty:      moveq   #0,D0
                rts
ask_nobat:      moveq   #$7B,D0
                rts
ask_notty:      lea     linebuf(PC),A5
                lea     s1(PC),A0
                bsr     sendlin
ask_diskloop1:  move.l  A5,-(SP)
                pea     1.w
                clr.w   -(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                tst.l   D0
                ble.s   ask_diskeof
                addq.l  #1,A5
                bra.s   ask_diskloop1
ask_diskeof:    sf      (A5)
                lea     linebuf(PC),A0
                bsr     sendlin
                bra.s   ask_tolka

                ENDPART
                >PART 'BREAK'

break:          move.l  loop_flag_ptr(PC),D0
                beq.s   break_what
                movea.l D0,A0
                st      (A0)
break_what:     moveq   #0,D0
                rts

                ENDPART
                >PART 'COPY1'

cmpy1_end:      rts
copy1:          lea     s1(PC),A0
                lea     buffer(PC),A1
copy1_aha1:     movea.l A1,A5
copy1_loop1:    move.b  (A0)+,D0
                move.b  D0,(A1)+
                beq.s   copy1_end1
                cmpa.l  #s1+2,A0
                bne.s   copy1_nodrv1
                cmp.b   #':',D0
                beq.s   copy1_aha1
copy1_nodrv1:   cmp.b   #'\',D0
                beq.s   copy1_aha1
                bra.s   copy1_loop1
copy1_end1:     lea     s2(PC),A0
                movea.l A0,A1
copy1_loop2:    tst.b   (A0)+
                bne.s   copy1_loop2
                subq.l  #2,A0
                cmpi.b  #'\',(A0)
                beq.s   copy1_start
                cmpa.l  #s2+1,A0
                bne.s   copy1_nodrv3
                cmpi.b  #':',(A0)
                beq.s   copy1_start
copy1_nodrv3:   pea     (A0)
                move.w  #-1,-(SP)
                pea     s2(PC)
                move.w  #fsfirst,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                movea.l (SP)+,A0
                tst.w   D0
                bmi.s   copy1_start
                btst    #4,dta+21-start(A6)
                beq.s   copy1_start
                addq.l  #1,A0
                move.b  #'\',(A0)+
                sf      (A0)+
copy1_start:    move.w  #-1,-(SP)
                pea     s1(PC)
                move.w  #fsfirst,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.w   D0
                bmi     cmpy1_end
                lea     dta+30(PC),A0
                movea.l A5,A1
copy1_loop3:    move.b  (A0)+,(A1)+
                bne.s   copy1_loop3
                lea     s2(PC),A0
                lea     buffer+128(PC),A1
copy1_loop4:    move.b  (A0)+,(A1)+
                bne.s   copy1_loop4
                subq.l  #2,A0
                cmpi.b  #'\',(A0)
                beq.s   copy1_insert
                cmpi.b  #':',(A0)
                bne.s   copy1_noins
                cmpa.l  #s2+1,A0
                bne.s   copy1_noins
copy1_insert:   lea     dta+30(PC),A0
                subq.l  #1,A1
copy1_loop5:    move.b  (A0)+,(A1)+
                bne.s   copy1_loop5
copy1_noins:

copyfil:        lea     buffer(PC),A0
                bsr     expand
                clr.w   -(SP)
                pea     buffer(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.l   D0
                bmi     copyfil_end
                moveq   #0,D1
                bsr     copy_fixhandle
                move.w  D0,handle1-start(A6)
                move.w  #-1,-(SP)
                pea     buffer(PC)
                move.w  #fsfirst,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.w   D0
                bmi     copyfil_end2b
                move.b  dta+21(PC),D0
                ext.w   D0
                move.w  D0,-(SP)
                pea     buffer+128(PC)
                move.w  #fcreate,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                tst.l   D0
                bmi     copyfil_end2b
                moveq   #1,D1
                bsr     copy_fixhandle
                move.w  D0,handle2-start(A6)
                move.l  dta+22(PC),control-start(A6)
                move.w  #1,-(SP)
                move.w  handle2(PC),-(SP)
                pea     control(PC)
                move.w  #fdatime,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                pea     -1.w
                move.w  #malloc,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                tst.l   D0
                beq.s   copyfil_end2b
                cmpi.w  #5,handle2-start(A6)
                bgt.s   copyfil_skip
                lea     $7FFF.w,A0
                cmp.l   A0,D0
                ble.s   copyfil_skip
                move.l  A0,D0
copyfil_skip:   move.l  D0,D7
                move.l  D0,-(SP)
                move.w  #malloc,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                tst.l   D0
                beq.s   copyfil_end2
                movea.l D0,A4
                move.l  D0,buffer+256-start(A6)
                pea     copyfil_cpytrm(PC)
                pea     $050102
                trap    #BIOS
                addq.l  #8,SP
copyfil_cpylp:  pea     (A4)
                move.l  D7,-(SP)
                move.w  handle1(PC),-(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                tst.l   D0
                ble.s   copyfil_end2
                move.l  D0,D6
                pea     (A4)
                move.l  D6,-(SP)
                move.w  handle2(PC),-(SP)
                move.w  #fwrite,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                move.l  D0,D1
                moveq   #$7C,D0
                cmp.l   D1,D6
                bne.s   copyfil_end2
                moveq   #0,D0
                cmp.l   D6,D7
                beq.s   copyfil_cpylp
copyfil_end2:   move.w  D0,-(SP)
                pea     (A4)
                move.w  #mfree,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  (SP)+,D0
copyfil_end2b:  move.w  D0,-(SP)
                bsr     close
                pea     myterm(PC)
                pea     $050102         ; setvec($102,myterm)
                trap    #BIOS
                addq.l  #8,SP
                move.w  (SP)+,D0
copyfil_end:    rts

copyfil_cpytrm: move.l  buffer+256(PC),-(SP)
                move.w  #mfree,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                pea     myterm(PC)
                pea     $050102         ; setvec($102,myterm)
                trap    #BIOS
                addq.l  #8,SP
                bra     myterm

; Konverterar character-handles (-3..-1) till standard-handles (0..3).
; IN: D0=handle
;     D1=handle att ev. ers„tta CON: med (0 f”r STDIN, 1 f”r STDOUT).
; AUX: omvandlas inte till handle 2 eftersom denna pekar p† STDERR. Tyv„rr.

copy_fixhandle: cmp.w   #-1,D0
                bne.s   fixhdl_docon
                move.w  D1,D0
                bra.s   fixhdl_done
fixhdl_docon:   cmp.w   #-3,D0
                bne.s   fixhdl_done
                moveq   #3,D0
fixhdl_done:    rts

                ENDPART
                >PART 'END'

end:            moveq   #-1,D0
                move.w  bathdl(PC),D1
                beq.s   end_end
                move.w  D1,D0
                bsr     closefile
                st      enterflg-start(A6)
                clr.w   bathdl-start(A6)
end_end:        rts

                ENDPART
                >PART 'ERROR'

errorsub:       lea     s1(PC),A0
                cmpi.b  #'$',(A0)+
                bne.s   errorsub_errorsub
                moveq   #0,D0
errorsub_loop:  move.b  (A0)+,D1
                beq.s   errorsub_end
                sub.b   #'0',D1
                bmi.s   errorsub_errorsub
                cmp.b   #9,D1
                ble.s   eprorsub_nohex
                sub.b   #'A'-'9'-1,D1
eprorsub_nohex: and.b   #$0F,D1
                lsl.w   #4,D0
                or.b    D1,D0
                bra.s   errorsub_loop
errorsub_end:   rts
errorsub_errorsub:moveq #$80,D0
                rts

                ENDPART
                >PART 'EXIT'

exit:           tst.w   bathdl-start(A6)
                bne.s   exit_isbatch
                lea     exits1(PC),A0
                bsr     sendlin
                bsr     getchar_echo
                bsr     ucased0
                cmp.w   #'Y',D0
                bne.s   exit_nope
exit_isbatch:   bsr     deinstall
                bsr     gemon
                move.l  #appl_exit,D0
                bsr     aes
                move.l  #$4C0000,-(SP)
                trap    #GEMDOS         ; ™verlever den detta s† j„vlar
exit_nope:      bra     docrlf

                ENDPART
                >PART 'GOTO'

goto:           move.w  bathdl(PC),D0
                beq     goto_error
                move.w  #1,-(SP)
                move.w  D0,-(SP)
                clr.l   -(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                tst.l   D0
                bmi     goto_end
                move.l  D0,D7           ; spara position, OM...
                lea     buffer+2(PC),A3
                lea     buffer+2(PC),A4
                clr.w   -(SP)
                move.w  bathdl(PC),-(SP)
                clr.l   -(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                tst.l   D0
                bne.s   goto_error
                st      D6
goto_loop:      bsr.s   goto_getchar
                tst.l   D0
                beq.s   goto_normal
                move.b  buffer(PC),D0
                cmp.b   #':',D0
                bne.s   goto_nolbl
                tst.b   D6
                bne.s   goto_lbl
goto_nolbl:     cmp.b   #' ',D0
                slt     D6
                bra.s   goto_loop
goto_lbl:       lea     s1(PC),A5
goto_loop2:     bsr.s   goto_getchar
                tst.w   D0
                beq.s   goto_normal
                move.b  buffer(PC),D0
                cmp.b   #' ',D0
                bgt.s   goto_noend
                tst.b   (A5)+
                bne.s   goto_loop
                bra.s   goto_gotit
goto_noend:     bsr     ucased0
                cmp.b   (A5)+,D0
                bne.s   goto_loop
                bra.s   goto_loop2
goto_gotit:     move.l  A4,D0
                sub.l   A3,D0
                neg.l   D0
                move.w  #1,-(SP)
                move.w  bathdl(PC),-(SP)
                move.l  D0,-(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                moveq   #0,D0
                rts
goto_normal:    move.w  D0,-(SP)
                clr.w   -(SP)
                move.w  bathdl(PC),-(SP)
                move.l  D7,-(SP)
                move.w  #fseek,-(SP)
                trap    #GEMDOS
                lea     10(SP),SP
                move.w  (SP)+,D0
                tst.w   D0
                bne.s   goto_end
goto_error:     moveq   #-1,D0
goto_end:       rts

goto_getchar:   cmpa.l  A3,A4
                bgt.s   goto_getc_ok
                lea     buffer+2(PC),A3
                pea     (A3)
                pea     bigbufferend-buffer-3.w
                move.w  bathdl(PC),-(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                tst.l   D0
                ble.s   goto_getc_err
                lea     buffer+2(PC),A3
                lea     0(A3,D0.l),A4
goto_getc_ok:   move.b  (A3)+,buffer-start(A6)
                moveq   #1,D0
                rts
goto_getc_err:  moveq   #0,D0
                rts

                ENDPART
                >PART 'IF'

if:             lea     linebuf(PC),A0
                bsr.s   condition
                cmp.w   #-2,D0
                beq.s   if_syntax
                movea.l A0,A1
                move.w  D0,-(SP)
if_loop:        movea.l A1,A2
                move.b  (A1)+,D0
                beq.s   if_gotend
                bsr     ucased0
                cmp.b   #'E',D0
                bne.s   if_loop
                move.b  (A1)+,D0
                beq.s   if_gotend
                bsr     ucased0
                cmp.b   #'L',D0
                bne.s   if_loop
                move.b  (A1)+,D0
                beq.s   if_gotend
                bsr     ucased0
                cmp.b   #'S',D0
                bne.s   if_loop
                move.b  (A1)+,D0
                beq.s   if_gotend
                bsr     ucased0
                cmp.b   #'E',D0
                bne.s   if_loop
                move.b  (A1)+,D0
                beq.s   if_gotend
                cmp.b   #' ',D0
                bne.s   if_loop
                move.w  (SP)+,D0
                sf      (A2)
                beq.s   if_falskt
                bra.s   if_sant
if_gotend:      move.w  (SP)+,D0
                beq.s   if_end
if_sant:        lea     linebuf(PC),A1
if_sant_loop:   move.b  (A0)+,(A1)+
                bne.s   if_sant_loop
                bra     tolk2
if_falskt:      lea     linebuf(PC),A0
if_falsit_loop: move.b  (A1)+,(A0)+
                bne.s   if_falsit_loop
                bra     tolk2
if_syntax:      moveq   #$80,D0
if_end:         rts

; Returnerar 0 f”r falskt, -1 f”r sant och -2 f”r flel

condition:      bsr.s   cond_getstr
                movea.l A0,A1
                moveq   #-2,D0
                tst.b   -1(A0)
                beq.s   cond_okidok
                bsr.s   cond_getstr
                cmpi.b  #'=',(A0)+
                bne.s   cond_okidok
                cmpi.b  #' ',(A0)+
                bne.s   cond_okidok
cond_loop:      move.b  (A0)+,D0
                cmp.b   #' ',D0
                beq.s   cond_tstend
                bsr     ucased0
                move.b  D0,D1
                move.b  (A1)+,D0
                bsr     ucased0
                cmp.b   D0,D1
                beq.s   cond_loop
                moveq   #0,D0
                rts
cond_tstend:    moveq   #-1,D0
                cmpi.b  #' ',(A1)
                ble.s   cond_okidok
                moveq   #0,D0
                bsr.s   cond_getstr
cond_okidok:    rts

cond_getstr:    cmpi.b  #' ',(A0)+
                bgt.s   cond_getstr
                rts

                ENDPART
                >PART 'INFO'

info:           lea     hello(PC),A0
                bsr     sendlin2
                lea     info_div_s1(PC),A0
                bsr     sendlin2
                lea     comtab(PC),A5
info_div_loop:  movem.l (A5)+,A0-A1
                move.w  (A5)+,D0
                bmi.s   info_div_end
                cmpi.b  #'{',(A1)
                beq.s   info_div_loop
                movea.l A1,A0
                bsr     sendlin
                moveq   #9,D0
                bsr     sendchar
                bra.s   info_div_loop
info_div_end:   bra     docrlf

                ENDPART
                >PART 'LOOP'

loop_offset     EQU -514
loop_flag       EQU -514
loop_buf_offset EQU -512

loop:           link    A5,#loop_offset
                tst.b   s1-start(A6)
                beq.s   loop_syntax
                lea     linebuf(PC),A0
                lea     loop_buf_offset(A5),A1
loop_loop0:     cmpi.b  #' ',(A0)+
                bne.s   loop_loop0
loop_loop1:     move.b  (A0)+,(A1)+
                bne.s   loop_loop1
                sf      loop_flag(A5)
loop_loop:      lea     loop_buf_offset(A5),A0
                lea     linebuf(PC),A1
loop_loop2:     move.b  (A0)+,(A1)+
                bne.s   loop_loop2
                lea     loop_flag(A5),A0
                move.l  A0,loop_flag_ptr-start(A6)
                move.l  A5,-(SP)
                bsr     tolk2
                movea.l (SP)+,A5
                moveq   #0,D0
                bsr     sendchar
                tst.b   loop_flag(A5)
                beq.s   loop_loop
                moveq   #0,D0
                bra.s   loop_end
loop_syntax:    moveq   #$80,D0
loop_end:       unlk    A5
                clr.l   loop_flag_ptr-start(A6)
                rts

                ENDPART
                >PART 'MACRO'

macro:          tst.b   s1-start(A6)
                beq     macro_list
                lea     macbuf(PC),A0
macro_loop1:    movea.l A0,A2
                lea     s1(PC),A1
macro_loop2:    move.b  (A1)+,D1
                beq.s   macro_s1end
                move.b  (A0)+,D0
                beq.s   macro_next2
                bsr     ucased0
                cmp.b   D1,D0
                beq.s   macro_loop2
macro_next:     tst.b   (A0)+
                bne.s   macro_next
macro_next2:    tst.b   (A0)
                bne.s   macro_loop1
                tst.b   s2-start(A6)
                bne.s   macro_add
                moveq   #-1,D0
                rts
macro_s1end:    cmpi.b  #' ',(A0)
                bgt.s   macro_next
                movea.l A2,A0
macro_loop3:    tst.b   (A0)+
                bne.s   macro_loop3
                tst.b   (A0)
                bne.s   macro_loop4
                sf      (A2)+
                sf      (A2)
                bra.s   macro_isadd
macro_loop4:    move.b  (A0)+,(A2)+
                bne.s   macro_loop4
                tst.b   (A0)
                bne.s   macro_loop4
                sf      (A2)
macro_isadd:    tst.b   s2-start(A6)
                beq     macro_okend
macro_add:      lea     macbuf(PC),A0
                tst.b   (A0)
                beq.s   macro_empty
macro_loop5:    tst.b   (A0)+
                bne.s   macro_loop5
                tst.b   (A0)
                bne.s   macro_loop5
macro_empty:    lea     linebuf(PC),A1
macro_loop6:    cmpi.b  #' ',(A1)+
                bne.s   macro_loop6
                st      D7
macro_loop7:    cmpa.l  #macbufend,A0
                bge.s   macro_full
macro_loop7b:   move.b  (A1)+,D0
                cmp.b   #'!',D0
                bne.s   macro_noskip
                cmpi.b  #'>',(A1)
                beq.s   macro_loop7b
                cmpi.b  #'<',(A1)
                beq.s   macro_loop7b
macro_noskip:   cmp.b   #' ',D0
                bne.s   macro_nospc
                sf      D7
macro_nospc:    tst.b   D7
                beq.s   macro_noucas
                bsr     ucased0
macro_noucas:   move.b  D0,(A0)+
                bne.s   macro_loop7
                sf      (A0)
macro_full:     lea     macbufend(PC),A0
                sf      -(A0)
                sf      -(A0)
                bsr     macsort
                bra.s   macro_okend

macro_list:     lea     macbuf(PC),A5
macro_lstlp0:   movea.l A5,A4
macro_lstlp1:   tst.b   (A5)+
                bne.s   macro_lstlp1
macro_lstlp2:   move.b  (A4)+,D0
                cmp.b   #' ',D0
                bls.s   macro_noname
                bsr     sendchar
                bra.s   macro_lstlp2
macro_noname:   moveq   #9,D0
                bsr     sendchar
                moveq   #'|',D0
                bsr     sendchar
                moveq   #' ',D0
                bsr     sendchar
                moveq   #68,D7
                move.b  start-256+bp_stdout(PC),D0
                addq.b  #1,D0
                bne.s   macro_listlp3
                linea   #0 [ Init ]
                move.w  -44(A0),D7
                sub.w   #11,D7
macro_listlp3:  moveq   #0,D0
                move.b  (A4)+,D0
                beq.s   macro_nameend
                bsr     sendchar
                dbra    D7,macro_listlp3
                tst.b   (A4)
                beq.s   macro_nameend
                bsr     docrlf
                bra.s   macro_noname
macro_nameend:  bsr     docrlf
                tst.b   (A5)
                bne.s   macro_lstlp0
macro_okend:    moveq   #0,D0
                rts

                ENDPART
                >PART 'MENU'

menu:           moveq   #$78,D0
                tst.b   menu_flag-start(A6)
                bne     menu_realend
                moveq   #$80,D0
                tst.b   s2-start(A6)
                bne     menu_realend
                moveq   #1,D6           ; Finns en meny (  )
                pea     -1.w
                move.w  #malloc,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                move.l  D0,-(SP)
                move.w  #malloc,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                tst.l   D0
                bmi     menu_realend
                movea.l D0,A5
                movea.l A5,A4
                tst.b   s1-start(A6)
                beq     menu_nofile
                clr.w   -(SP)
                pea     s1(PC)
                move.w  #fopen,-(SP)
                trap    #GEMDOS
                addq.l  #8,SP
                move.l  D0,D7
                bmi     menu_realend2
                lea     s1(PC),A3
                move.w  #8,(A3)
                move.w  #20,2(A3)
menu_loop1:     bsr     menu_getchar
                cmp.b   #26,D0
                beq     menu_action
                cmp.b   #'[',D0
                beq.s   menu_title
                cmp.b   #'<',D0
                beq.s   menu_entry
                cmp.b   #'(',D0
                beq     menu_dummy
                cmp.b   #' ',D0
                ble.s   menu_loop1
menu_syntax:    move.w  D7,D0
                bsr     closefile
                move.w  #$79,D0
                bra     menu_realend2
menu_title:     addq.w  #1,D6
                addq.l  #4,A3
                clr.l   (A3)
                sf      (A4)+
menu_title_loop:bsr     menu_getchar
                cmp.b   #']',D0
                beq.s   menu_title2
                cmp.b   #26,D0
                beq.s   menu_syntax
                move.b  D0,(A4)+
                bra.s   menu_title_loop
menu_title2:    sf      (A4)+
                bra.s   menu_loop1
menu_entry:     addq.w  #1,(A3)
                moveq   #0,D5
menu_entry_b:   bsr     menu_getchar
                cmp.b   #'>',D0
                beq.s   menu_entry2
                cmp.b   #26,D0
                beq.s   menu_syntax
                addq.w  #1,D5
                move.b  D0,(A4)+
                bra.s   menu_entry_b
menu_entry2:    cmp.w   2(A3),D5
                ble.s   menu_entry2b
                move.w  D5,2(A3)
menu_entry2b:   sf      (A4)+
menu_entry_lp1: bsr     menu_getchar
                cmp.b   #',',D0
                beq.s   menu_entry3
                cmp.b   #' ',D0
                beq.s   menu_entry_lp1
                bra.s   menu_entry4
menu_entry3:    bsr     menu_getchar
                cmp.b   #' ',D0
                beq.s   menu_entry3
menu_entry_lp2: cmp.b   #26,D0
                beq.s   menu_syntax
                cmp.b   #' ',D0
                ble.s   menu_entry4
                move.b  D0,(A4)+
                bsr     menu_getchar
                bra.s   menu_entry_lp2
menu_entry4:    sf      (A4)+
menu_entry_lp3: bsr     menu_getchar
                cmp.b   #26,D0
                beq.s   menu_entry5
                cmp.b   #' ',D0
                ble.s   menu_entry_lp3
menu_entry_lp4: move.b  D0,(A4)+
                bsr     menu_getchar
                cmp.b   #' ',D0
                bpl.s   menu_entry_lp4
menu_entry5:    sf      (A4)+
                bra     menu_loop1
menu_dummy:     addq.w  #1,(A3)
menu_dummy_b:   bsr     menu_getchar
                cmp.b   #')',D0
                beq.s   menu_dummy1
                cmp.b   #26,D0
                beq     menu_syntax
                move.b  D0,(A4)+
                bra.s   menu_dummy_b
menu_dummy1:    sf      (A4)+
                sf      (A4)+
                sf      (A4)+
                bra     menu_loop1
menu_action:    sf      (A4)+
                sf      (A4)+
                sf      (A4)+
                move.w  D7,D0
                bsr     closefile
menu_nofile:    move.l  A4,D0
                and.b   #$FE,D0
                movea.l D0,A4
; Kopiera de f”rsta 3 objekten
                moveq   #17,D0
                lea     main_ibox(PC),A0
                movea.l A4,A3
menu_loop2:     move.l  (A0)+,(A4)+
                dbra    D0,menu_loop2
                add.w   D6,main_ibox+4-main_ibox(A3)
                add.w   D6,white_box-main_ibox(A3)
                add.w   D6,title_ibox+4-main_ibox(A3)
                movea.l A5,A0
                addq.l  #1,A0
; Kopiera in Desk-menyn
                move.w  #4,(A4)+
                lea     desk_title+2(PC),A1
                moveq   #8,D0
menu_loop3:     move.w  (A1)+,(A4)+
                dbra    D0,menu_loop3
                move.l  #$040301,(A4)+
                moveq   #5,D1
                cmp.w   #1,D6
                beq.s   menu_skip1
; Kopiera in resten av menyerna
                moveq   #4,D3
                move.w  D6,D0
                subq.w  #2,D0
menu_loop4:     tst.w   D0
                bne.s   menu_not0
                move.w  #2,(A4)+
                bra.s   menu_done0
menu_not0:      move.w  D1,(A4)+
menu_done0:     lea     desk_title+2(PC),A1
                moveq   #4,D2
menu_loop5b:    move.w  (A1)+,(A4)+
                dbra    D2,menu_loop5b
                move.l  A0,(A4)+
                move.l  A0,D2
                bsr     menu_getstring
                sub.l   A0,D2
                not.w   D2              ; Neg -1
                move.w  D3,(A4)+
                clr.w   (A4)+
                move.w  D2,(A4)+
                move.w  #769,(A4)+
                add.w   D2,D3
menu_strlp:     tst.b   (A0)
                beq.s   menu_gotmenu
                bsr     menu_getstring
                bsr     menu_getstring
                bsr     menu_getstring
                bra.s   menu_strlp
menu_gotmenu:   bsr     menu_getstring
                addq.w  #1,D1
                dbra    D0,menu_loop4
                move.w  D3,title_ibox+20-main_ibox(A3)
; Kopiera in IBOXen f”r menyrutorna
menu_skip1:     clr.w   (A4)+
                move.w  D6,D0
                addq.w  #4,D0
                move.w  D0,(A4)+
                lea     strings_ibox+4(PC),A0
                moveq   #4,D0
menu_loop19:    move.l  (A0)+,(A4)+
                dbra    D0,menu_loop19
                addq.w  #1,D1
; Kopiera in boxen f”r Desk-menyn
                move.w  D1,D0
                addq.w  #8,D0
                move.w  D0,(A4)+
                move.w  D1,(A4)+
                addq.w  #1,D1
                subq.w  #1,D0
                move.w  D0,(A4)+
                lea     menu_box+6(PC),A0
                moveq   #6,D0
menu_loop20:    move.w  (A0)+,(A4)+
                dbra    D0,menu_loop20
                move.l  #$140001,(A4)+
; Kopiera in inneh†llet i Desk-menyn
                move.w  D1,(A4)+
                addq.w  #1,D1
                lea     string_object+2(PC),A0
                moveq   #8,D0
menu_loop21:    move.w  (A0)+,(A4)+
                dbra    D0,menu_loop21
                move.l  #$140001,(A4)+
                move.w  D1,(A4)+
                addq.w  #1,D1
                lea     dummy_object+2(PC),A0
                moveq   #7,D0
menu_loop22:    move.w  (A0)+,(A4)+
                dbra    D0,menu_loop22
                move.w  #1,(A4)+
                move.l  #$140001,(A4)+
                moveq   #2,D3
                moveq   #5,D2
menu_loop23:    tst.w   D2
                bne.s   menu_not0e
                move.w  D6,D0
                addq.w  #4,D0
                move.w  D0,(A4)+
                bra.s   menu_skip0e
menu_not0e:     move.w  D1,(A4)+
menu_skip0e:    addq.w  #1,D1
                lea     string_object+2(PC),A0
                moveq   #7,D0
menu_loop24:    move.w  (A0)+,(A4)+
                dbra    D0,menu_loop24
                move.w  D3,(A4)+
                addq.w  #1,D3
                move.l  #$140001,(A4)+
                dbra    D2,menu_loop23
; Kopiera in de andra menyerna
                cmp.w   #1,D6
                beq     menu_skip2
                lea     s1+4(PC),A1
                movea.l A5,A0
                addq.l  #1,A0
                move.w  D6,D0
                subq.w  #2,D0
menu_loop25:    tst.w   D0
                bne.s   menu_not0f
                moveq   #3,D2
                add.w   D6,D2
                move.w  D2,(A4)+
                muls    #24,D2
                move.w  D1,D3
                subq.w  #1,D3
                move.w  D3,4(A3,D2.w)
                bra.s   menu_skip0f
menu_not0f:     move.w  (A1),D2
                add.w   D1,D2
                move.w  D2,(A4)+
menu_skip0f:    move.w  D1,-(SP)
                subq.w  #1,(SP)
                move.w  D1,(A4)+
                move.w  D1,D2
                add.w   (A1),D2
                subq.w  #1,D2
                move.w  D2,(A4)+
                addq.w  #1,D1
                moveq   #4,D2
                lea     menu_box+6(PC),A2
menu_loop26:    move.w  (A2)+,(A4)+
                dbra    D2,menu_loop26
                move.w  D6,D2
                sub.w   D0,D2
                muls    #24,D2
                move.w  2*24+16(A3,D2.w),(A4)+
                clr.w   (A4)+
                move.w  2(A1),(A4)+
                move.w  (A1),(A4)+
; Kopiera in str„ngarna
                move.w  (A1),D2
                subq.w  #1,D2
                moveq   #0,D3
                bsr     menu_getstring
menu_loop27:    tst.w   D2
                bne.s   menu_not0g
                move.w  (SP)+,(A4)+
                bra.s   menu_skip0g
menu_not0g:     move.w  D1,(A4)+
menu_skip0g:    addq.w  #1,D1
                lea     string_object+2(PC),A2
                moveq   #4,D4
menu_loop28:    move.w  (A2)+,(A4)+
                dbra    D4,menu_loop28
                move.l  A0,(A4)+
                bsr     menu_getstring
                bsr     menu_getstring
                tst.b   (A0)
                bne.s   menu_active
                bset    #3,-16+11(A4)
menu_active:    bsr     menu_getstring
                clr.w   (A4)+
                move.w  D3,(A4)+
                addq.w  #1,D3
                move.w  2(A1),(A4)+
                move.w  #1,(A4)+
                dbra    D2,menu_loop27
                bsr     menu_getstring
                addq.l  #4,A1
                dbra    D0,menu_loop25
                bra.s   menu_fixed
menu_skip2:     move.w  #5,-24(A4)
                move.w  24*4+2(A3),24*4+4(A3)
                move.w  #4,24*5(A3)
                move.w  #2,24*3(A3)
                move.w  #4,24*2+20(A3)
menu_fixed:     bset    #5,-24+9(A4)
                move.l  A4,D0
                sub.l   A5,D0
                move.l  D0,-(SP)
                move.l  A5,-(SP)
                move.l  #$4A0000,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                move.w  D1,D6
                subq.w  #1,D6
menu_loop18:    move.w  D6,intin-start(A6)
                move.l  A3,addrin-start(A6)
                move.l  #rsrc_obfix,D0
                bsr     aes
                dbra    D6,menu_loop18
menu_loop_b:    bsr     gemon
                move.l  A0,tedinfo3-start(A6)
                clr.w   intin-start(A6)
                move.l  #graf_mouse,D0
                bsr     aes
                move.w  #14,intin+2-start(A6)
                lea     owndesk(PC),A0
                move.l  A0,intin+4-start(A6)
                clr.w   intin+8-start(A6)
                move.l  #wind_set,D0
                bsr     aes
                movem.l intout+2(PC),D0-D1
                move.w  #3,intin-start(A6)
                movem.l D0-D1,intin+2-start(A6)
                movem.l D0-D1,intin+10-start(A6)
                move.l  #form_dial,D0
                bsr     aes
                move.l  A3,addrin-start(A6)
                move.w  #1,intin-start(A6)
                move.l  #menu_bar,D0
                bsr     aes
menu_loop:      move.w  #cconis,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                tst.w   D0
                beq.s   menu_empty
                move.w  #crawcin,-(SP)
                trap    #GEMDOS
                addq.l  #2,SP
                bra.s   menu_loop
menu_empty:     lea     s1(PC),A0
                move.l  A0,addrin-start(A6)
                move.w  #16+1,intin-start(A6)
                move.l  #evnt_multi,D0
                bsr     aes
                btst    #0,intout+1(PC)
                bne     menu_iskey
                cmpi.w  #10,s1-start(A6)
                bne.s   menu_loop
                move.l  A3,addrin-start(A6)
                move.w  s1+6(PC),intin-start(A6)
                move.w  #1,intin+2-start(A6)
                move.l  #menu_tnormal,D0
                bsr     aes
                move.w  s1+8(PC),D0
                muls    #24,D0
                movea.l 12(A3,D0.w),A0
                cmpa.l  #menu_back,A0
                beq.s   menu_end
                bsr     menu_getstring
                bsr     menu_getstring
menu_docmd:     lea     linebuf(PC),A1
menu_loop29:    move.b  (A0)+,(A1)+
                bne.s   menu_loop29
                movem.l D6/A3-A5,-(SP)
                move.l  A3,addrin-start(A6)
                clr.w   intin-start(A6)
                move.l  #menu_bar,D0
                bsr     aes
                bsr     gemoff
                bsr     tolk2
                movem.l (SP)+,D6/A3-A5
                bra     menu_loop_b
menu_end:       move.l  A3,addrin-start(A6)
                clr.w   intin-start(A6)
                move.l  #menu_bar,D0
                bsr     aes
                bsr     gemoff
                moveq   #0,D0
menu_realend2:  move.w  D0,-(SP)
                move.l  A5,-(SP)
                move.w  #mfree,-(SP)
                trap    #GEMDOS
                addq.l  #6,SP
                move.w  (SP)+,D0
                sf      menu_flag-start(A6)
menu_realend:   rts

menu_iskey:     move.b  intout+11(PC),D0
                beq.s   menu_scan
                cmp.b   #27,D0
                beq.s   menu_end
                bsr     ucased0
                move.b  D0,D1
                movea.l A5,A0
                addq.l  #1,A0
menukey_loop:   bsr     menu_getstring
                tst.b   (A0)
                beq     menu_loop
menukey_loop2:  bsr     menu_getstring
                move.b  (A0),D0
                bsr     ucased0
                cmp.b   D0,D1
                beq.s   menu_gotkey
                bsr     menu_getstring
                bsr     menu_getstring
                tst.b   (A0)
                bne.s   menukey_loop2
                bsr     menu_getstring
                bra.s   menukey_loop
menu_scan:      movea.l A5,A0
                move.b  intout+10(PC),D0
                sub.b   #58,D0
                ble     menu_loop
                cmp.b   #10,D0
                bgt     menu_loop
menu_scanlp2:   bsr.s   menu_getstring
                bsr.s   menu_getstring
                tst.b   (A0)
                beq     menu_loop
menu_scanlp:    tst.b   (A0)
                beq.s   menu_scanlp2
                bsr.s   menu_getstring
                cmpi.b  #'f',(A0)
                beq.s   menu_fkey
                cmpi.b  #'F',(A0)
                bne.s   menu_scan2
menu_fkey:      movea.l A0,A1
                addq.l  #1,A1
                move.b  (A1)+,D1
                sub.b   #'0',D1
                ble.s   menu_scan2
                cmp.b   #10,D1
                bpl.s   menu_scan2
                cmp.b   #1,D1
                bne.s   menu_notf10
                cmpi.b  #'0',(A1)
                bne.s   menu_notf10
                moveq   #10,D1
menu_notf10:    cmp.b   D0,D1
                beq.s   menu_gotkey
menu_scan2:     bsr.s   menu_getstring
                bsr.s   menu_getstring
                bra.s   menu_scanlp
menu_gotkey:    bsr.s   menu_getstring
                bra     menu_docmd

menu_getchar:   pea     buffer(PC)
                pea     1.w
                move.w  D7,-(SP)
                move.w  #fread,-(SP)
                trap    #GEMDOS
                lea     12(SP),SP
                move.l  D0,D1
                move.b  buffer(PC),D0
                tst.l   D1
                bgt.s   menu_gotchar
                moveq   #26,D0
menu_gotchar:   rts

menu_getstring: tst.b   (A0)+
                bne.s   menu_getstring
                rts

                ENDPART
                >PART 'MSG'

msg:            lea     text_object2(PC),A0
                bset    #7,status_hide+1-start(A6)
                movea.l A0,A1
                moveq   #35,D0
msg_loop0:      move.b  #' ',(A0)+
                dbra    D0,msg_loop0
                moveq   #0,D0
                tst.b   s1-start(A6)
                beq.s   msg_end
                bclr    #7,status_hide+1-start(A6)
                lea     linebuf(PC),A0
msg_loop1:      move.b  (A0)+,D0
                cmp.b   #' ',D0
                bgt.s   msg_loop1
                moveq   #0,D0
                moveq   #0,D1
msg_loop2:      move.b  (A0)+,D0
                beq.s   msg_end
                move.b  D0,(A1)+
                addq.w  #1,D1
                cmp.w   #36,D1
                bmi.s   msg_loop2
msg_end:        rts

                ENDPART
                >PART '{ } (MULTI)'

multioffset     EQU -512

multi:          link    A5,#multioffset
                move.b  s1(PC),D0
                beq     multi_syntax
                cmpi.b  #';',D0
                beq     multi_syntax
                lea     linebuf(PC),A0
                lea     multioffset(A5),A1
                movea.l A1,A4
multi_loop0:    cmpi.b  #' ',(A0)+
                bne.s   multi_loop0
multi_loop1:    move.b  (A0)+,(A1)+
                bne.s   multi_loop1
multi_loop2:    movea.l A4,A0
                lea     linebuf(PC),A1
                moveq   #0,D1
multi_loop3:    move.b  (A0)+,D0
                beq.s   multi_cut
                cmp.b   #'{',D0
                beq.s   multi_meck
                cmp.b   #'}',D0
                beq.s   multi_testcut
multi_insert:   move.b  D0,(A1)+
                bra.s   multi_loop3
multi_meck:     addq.w  #1,D1
                bra.s   multi_insert
multi_testcut:  subq.w  #1,D1
                bpl.s   multi_insert
                subq.l  #1,A1
multi_cut:      movea.l A0,A4
                sf      (A1)
                tst.b   D0
                sne     D0
                movem.l D0/A4-A5,-(SP)
                bsr     tolk2
                move.b  stdoutfile(PC),D0
                beq.s   multi_noio
                cmp.b   #'>',D0
                beq.s   multi_noio
                lea     stdoutfile+127(PC),A0
                lea     stdoutfile+128(PC),A1
                moveq   #$7E,D0
multi_ioloop:   move.b  -(A0),-(A1)
                dbra    D0,multi_ioloop
                move.b  #'>',stdoutfile-start(A6)
multi_noio:     movem.l (SP)+,D0/A4-A5
                tst.b   D0
                beq.s   multi_ende
                move.l  loop_flag_ptr(PC),D0
                beq.s   multi_noflag
                movea.l D0,A0
                tst.b   (A0)
                bne.s   multi_ende
multi_noflag:   cmpi.b  #'{',(A4)+
                bne.s   multi_ende
multi_loop:     tst.b   (A4)
                beq.s   multi_ende
                cmpi.b  #' ',(A4)
                bne.s   multi_loop2
                addq.l  #1,A4
                bra.s   multi_loop
multi_ende:     moveq   #0,D0
                bra.s   multi_end
multi_syntax:   moveq   #$80,D0
multi_end:      unlk    A5
                rts

                ENDPART
                >PART 'SET'

set:            tst.b   s1
                bne.s   set_nolist
                lea     envbuf(PC),A5
set_loop:       tst.b   (A5)
                beq.s   set_end
                movea.l A5,A4
set_loop1:      tst.b   (A4)+
                bne.s   set_loop1
                movea.l A5,A0
                bsr     sendlin
                tst.b   (A4)            ; Ska inte kunna h„nda
                beq.s   set_end
                movea.l A4,A5
set_loop2:      tst.b   (A5)+
                bne.s   set_loop2
                movea.l A4,A0
                bsr     sendlin2
                bra.s   set_loop
set_end:        moveq   #0,D0
                rts
set_nolist:     lea     s1(PC),A0
set_loop3:      cmpi.b  #'=',(A0)
                beq.s   set_doset
                tst.b   (A0)+
                bne.s   set_loop3
                bra     askenv

set_doset:      bsr     setenv
                lea     s1(PC),A0
                bsr     findenv
                lea     linebuf(PC),A1
set_loop4:      cmpi.b  #'=',(A1)+
                bne.s   set_loop4
set_loop5:      move.b  (A1)+,(A0)+
                bne.s   set_loop5
                moveq   #0,D0
                rts

                ENDPART
                >PART 'SHIFT'

shift:          tst.w   bathdl-start(A6)
                beq.s   shift_nobat
                lea     argbuf(PC),A0
                movea.l A0,A1
shift_loop1:    cmpi.b  #' ',(A0)+
                bgt.s   shift_loop1
                tst.b   -1(A0)
                beq.s   shift_end
shift_loop2:    move.b  (A0)+,(A1)+
                bne.s   shift_loop2
shift_end:      moveq   #0,D0
                rts
shift_nobat:    moveq   #$7B,D0
                rts

                ENDPART
                >PART 'TRAP'

trap:           movea.l SP,A5
                tst.b   s1-start(A6)
                beq     trap_error
                lea     linebuf(PC),A0
trap_loop0:     cmpi.b  #' ',(A0)+
                bne.s   trap_loop0
                moveq   #0,D7           ; R„knar argument
                lea     buffer(PC),A1
trap_loop2:     movea.l A0,A2
trap_loop:      move.b  (A0)+,D0
                cmpi.b  #' ',D0
                bmi.s   trap_doit
                beq.s   trap_gotword
                cmpi.b  #'[',D0
                bne.s   trap_loop
                moveq   #0,D0
trap_fnuttlp:   move.b  (A0)+,D1
                beq.s   trap_gotword
                cmp.b   #'[',D1
                bne.s   trap_fnutt2
                addq.w  #1,D0
trap_fnutt2:    cmp.b   #']',D1
                bne.s   trap_fnuttlp
                subq.w  #1,D0
                bmi.s   trap_gotword
                bra.s   trap_fnuttlp
trap_gotword:   move.l  A2,(A1)+
                addq.w  #1,D7
                sf      -1(A0)
                cmpi.b  #' ',(A0)
                bne.s   trap_loop2
                addq.l  #1,A0
                bra.s   trap_loop2

trap_doit:      move.l  A2,(A1)+
trap_loop3:     tst.w   D7
                bmi.s   trap_go_on
                movea.l -(A1),A0
                subq.w  #1,D7
                cmpi.b  #'[',(A0)
                beq.s   trap_string
                bsr     evaluate
                tst.w   D1
                bmi.s   trap_loop3
                beq.s   trap_word
                move.l  D0,-(SP)
                bra.s   trap_loop3
trap_word:      move.w  D0,-(SP)
                bra.s   trap_loop3
trap_string:    pea     1(A0)
                bra.s   trap_loop3
trap_go_on:     cmpi.w  #GEMDOS,(SP)
                bne.s   trap_nocensur
                cmpi.w  #super,(SP)
                beq.s   trap_censur
trap_nocensur:  move.w  (SP)+,D0
                lsl.w   #2,D0
                jmp     traptab(PC,D0.w)
traptab:
i               SET 0
                REPT 15
                trap    #i
                bra.s   trap_censur
i               SET i+1
                ENDR
                trap    #15
trap_censur:    movea.l A5,SP
                bsr     make_ans
                moveq   #0,D0
                rts

trap_error:     moveq   #$80,D0
                movea.l A5,SP
                rts

                ENDPART
                >PART 'VAL'

val:            lea     s1(PC),A0
                bsr     evaluate
                tst.w   D1
                bmi.s   val_error
                bne.s   val_longword
                and.l   #$FFFF,D0
val_longword:   bsr     make_ans
                moveq   #0,D0
                rts
val_error:      moveq   #$80,D0
                rts

                ENDPART
                >PART 'WATCH'

watch:          lea     s1(PC),A0
                lea     s2(PC),A1
                tst.b   (A1)
                bne.s   watch_error
                tst.b   (A0)
                beq.s   watch_ask
                move.b  (A0)+,D0
                tst.b   (A0)
                bne.s   watch_error
                sub.b   #'0',D0
                bmi.s   watch_error
                cmp.b   #3,D0
                bgt.s   watch_error
                move.b  D0,watch_level-start(A6)
                moveq   #0,D0
                rts
watch_error:    moveq   #$80,D0
                rts
watch_ask:      lea     _watch(PC),A0
                bsr     sendlin
                lea     level_string(PC),A0
                bsr     sendlin
                move.b  watch_level(PC),D0
                add.b   #'0',D0
                bsr     sendchar
                bra     docrlf

                ENDPART
                DATA
                >PART 'Felmeddelanden'
errtab:
; Egna felmeddelanden
                DC.B $78,"Menu already active",0
                DC.B $79,"Bad menu definition file",0
                DC.B $7A,"Execution failed",0
                DC.B $7B,"Command not possible in direct mode",0
                DC.B $7C,"Disk full",0
                DC.B $7D,"I/O redirection needs TOS 1.4 or later",0
                DC.B $7E,"Stack overflow",0
                DC.B $7F,"Command not found",0
                DC.B $80,"Bad syntax",0
; BIOS' felmeddelanden
                DC.B -1,"General error",0
                DC.B -2,"Drive not ready",0
                DC.B -3,"Unknown command",0
                DC.B -4,"CRC error",0
                DC.B -5,"Bad request",0
                DC.B -6,"Seek error",0
                DC.B -7,"Unknown media",0
                DC.B -8,"Sector not found",0
                DC.B -9,"Out of paper",0
                DC.B -10,"Write error",0
                DC.B -11,"Read error",0
                DC.B -13,"Write on write-protected media",0
                DC.B -14,"Media change detected",0
                DC.B -15,"Unknown device",0
                DC.B -16,"Bad sectors",0
; GEMDOS' felmeddelanden
                DC.B -32,"User interrupt",0
                DC.B -33,"File not found",0
                DC.B -34,"Path not found",0
                DC.B -35,"Handle pool exhausted",0
                DC.B -36,"Access denied",0
                DC.B -37,"Invalid handle",0
                DC.B -39,"Insufficient memory",0
                DC.B -40,"Invalid memory block address",0
                DC.B -46,"Invalid drive specification",0
                DC.B -47,"No more files",0
                DC.B -64,"Range error",0
                DC.B -65,"GEMDOS internal error",0
                DC.B -66,"Invalid executable file format",0
                DC.B -67,"Memory block growth failure",0
                DC.B 0

drive_message:  DC.B " on drive ",0

err_own:        DC.B "Error: ",0
err_gemdos:     DC.B "GEMDOS Error #"
err_num:        DC.B "xx: ",0

                ENDPART
                >PART 'Kommandon & villkor'

_add:           DC.B "ADD",0
_ask:           DC.B "ASK",0
_break:         DC.B "BREAK",0
_copy1:         DC.B "COPY1",0
_end:           DC.B "END",0
_error:         DC.B "ERROR",0
_exit:          DC.B "EXIT",0
_goto:          DC.B "GOTO",0
_if:            DC.B "IF",0
_info:          DC.B "INFO",0
_loop:          DC.B "LOOP",0
_macro:         DC.B "MACRO",0
_menu:          DC.B "MENU",0
_msg:           DC.B "MSG",0
_set:           DC.B "SET",0
_shift:         DC.B "SHIFT",0
_sub:           DC.B "SUB",0
_trap:          DC.B "TRAP",0
_val:           DC.B "VAL",0
_watch:         DC.B "WATCH",0
_multi:         DC.B "{",0

                ENDPART
                >PART 'Data i st”rsta allm„nhet'

exts:           DC.B "TTPTOSPRGAPPBAT"

testfile:       DC.B "\TEST.DAT",0

clsstr:         DC.B 27,'E',27,'v',0
xystr:          DC.B 27,'Y',0,0,0
level_string:   DC.B " level: ",0
out_str1:       DC.B "ANS.W=",0
out_str2:       DC.B "ANS.L=",0
buf_str:        DC.B "BUFFER=",0
pathstr:        DC.B "PATH",0
autobat:        DC.B "AUTO.BAT",0
curson:         DC.B 27,'e',0
cursoff:        DC.B 27,'f',0
err1:           DC.B "Undefined error",13,10,0

crit1:          DC.B "BIOS Error #"
crit2:          DC.B "?? : ",0
crit3:          DC.B "Abort, Retry, Ignore? ",0
crit4:          DC.B "Insert disk "
crit4a:         DC.B "# into drive A: and strike any key",13,10,0

exits1:         DC.B "Exit Micro Macro Menu CLI (Y/N)? ",0

hello:          DC.B "Micro Macro Menu CLI 1.01.",13,10
                DC.B "Patrik Persson 1992.",13,10,0

crlf:           DC.B 13,10,0

info_div_s1:    DC.B "Commands:",0

enterflg:       DC.B 0

                ENDPART
                >PART 'Kommandotabell'

comtab:         DC.L ask,_ask
                DC.W $FF
                DC.L break,_break
                DC.W 0
                DC.L copy1,_copy1
                DC.W 2
                DC.L end,_end
                DC.W 0
                DC.L errorsub,_error
                DC.W 1
                DC.L exit,_exit
                DC.W 0
                DC.L if,_if
                DC.W $FF
                DC.L info,_info
                DC.W 0
                DC.L loop,_loop
                DC.W $FF
                DC.L goto,_goto
                DC.W 1
                DC.L macro,_macro
                DC.W $FF
                DC.L menu,_menu
                DC.W $FF
                DC.L msg,_msg
                DC.W $FF
                DC.L set,_set
                DC.W $FF
                DC.L shift,_shift
                DC.W 0
                DC.L trap,_trap
                DC.W $FF
                DC.L val,_val
                DC.W 1
                DC.L watch,_watch
                DC.W $FF
                DC.L multi,_multi
                DC.W $FF
                DC.L 0,0
                DC.W -1

                ENDPART
                >PART 'AES-data'

g_box           EQU 20
g_boxtext       EQU 22
g_image         EQU 23
g_ibox          EQU 25
g_string        EQU 28

aespb:          DC.L control,global,intin,intout,addrin,addrout
object_tree:    DC.W -1,-1,-1,g_text,0,0
                DC.L tedinfo
text_xywh:      DC.W 0,0,0,0

tedinfo:        DC.L text_object,0,0,$030000,$020180,0
text_length:    DC.W 0,0

tedinfo2:       DC.L text_object2,0,0
                DC.W 3,0,0,$0180,0,0,36,0

tedinfo3:       DC.L 0,0,0
                DC.W 3,0,2,$0180,0,0,13,0

bitblk:         DC.L image_data+22*10
                DC.W 22,8,0,0,2
bitblk2:        DC.L image_data
                DC.W 22,10,0,0,1

owndesk:        DC.W -1,1,3,g_box,0,0,0,$43,0,$0301,80,$0D17
                DC.W 2,-1,-1,g_boxtext
status_hide:    DC.W 128,16
                DC.L tedinfo2
status_pos:     DC.W 41,21,36,$0401
                DC.W 3,4,5,g_box,0,48,$FE,$1000,2,20,$0814
image_size3:    DC.W 0
                DC.W 0,-1,-1,g_boxtext,0,48
                DC.L tedinfo3
                DC.W 25,21,13,$0401
                DC.W 5,-1,-1,g_image,0,0
                DC.L bitblk2
                DC.W 0,0,$0614
image_size2:    DC.W 0
                DC.W 2,-1,-1,g_image,32,0
                DC.L bitblk
                DC.W 0,$0A00,$0614
image_size:     DC.W 0

sysdesk:        DC.W -1,-1,-1,g_box,32,0,0,$73,0,$0301,80,$0D17

main_ibox:      DC.W -1,1,3,g_ibox,0,0,0,0,0,0,80,25 ; 0
white_box:      DC.W 3,2,2,g_box,0,0,0,$1181,0,0,80,513 ; 1
title_ibox:     DC.W 1,3,2,g_ibox,0,0,0,0,1,0,0,769 ; 2

strings_ibox:   DC.W 0,0,0,g_ibox,128,0,0,0,1,769,128,3351 ; n+3

desk_title:     DC.W 4,-1,-1,32,0,0
                DC.L desk_string
                DC.W 0,0,4,769
menu_box:       DC.W 15,7,14,20,0,0,$FFFF,$1181,0,0,20,8
string_object:  DC.W 8,-1,-1,28,0,0
                DC.L menu_back
                DC.W 0,0,20,1
dummy_object:   DC.W 9,-1,-1,28,0,8
                DC.L dummy_line
                DC.W 0,1,20,1

desk_string:    DC.B '  ',0
menu_back:      DC.B '  Back to CLI  [Esc]',0
dummy_line:     DC.B '--------------------',0

text_object2:   DS.B 36,' '
                DC.B 0

                EVEN
image_data:     IBYTES '\IMAGE.DAT'

                ENDPART
                >PART 'Standard-macros'

macbuf:         DC.B "CALC { VAL &1 }{ ECHO &1=(%ANS.W%) }",0
                DC.B "CD { TRAP 1 59 [&1] }{ ERROR (%ANS.W%) }",0
                DC.B "COPY WITH &1 IF ISFILE &F { ECHO &F }{ COPY1 &F &2 }",0
                DC.B "DEL WITH &1 IF ISFILE &F { TRAP 1 65 [&F] }{ ERROR (%ANS.W%) }",0
                DC.B "ECHO { TRAP 1 9 [&A] }{ TRAP 1 2 13 }{ TRAP 1 2 10 }",0
                DC.B "FINFO { VAL @((%BUFFER%)+18)&$10 }{ IF (%ANS.W%) = $0010 TRAP 1 9 [(DIR)  ] ELSE { VAL @((%BUFFER%)+26)/1024 }"
                DC.B "{ TRAP 1 9 [(%ANS.W%)K ] } }{ TRAP 1 9 (%BUFFER%)+30 }{ ECHO }",0
                DC.B "FIRST { TRAP 1 26 (%BUFFER%) }{ TRAP 1 78 [&1] $FFFF }",0
                DC.B "LS { IF &1. = . FIRST *.* ELSE FIRST &1 }{ LOOP { IF (%ANS.W%) = $FFCF BREAK }{ FINFO }{ NEXT } }",0
                DC.B "NEXT TRAP 1 79",0
                DC.B "TYPE COPY1 &1 CON:",0
                DC.B 0
macbuflen       EQU *-macbuf

                ENDPART
                BSS
                >PART 'BSS'

                DS.B 2048-macbuflen

macbufend:      DS.L 1          ; Dumt † chansa

errcount:       DS.B 1

                DS.B 15
numbuf:         DS.B 1

text_object:    DS.B 13

watch_level:    DS.B 1
menu_flag:      DS.B 1

add_sub_save:   DS.B 1

evaluate_temp:  DS.L 1

handle1:        DS.W 1
handle2:        DS.W 1
bathdl:         DS.W 1

tmpstdout:      DS.W 1
tmpstdin:       DS.W 1
stdout:         DS.W 1
stdin:          DS.W 1

tolk_counter:   DS.W 1

loop_flag_ptr:  DS.L 1

stdoutfile:     DS.L 32
stdinfile:      DS.L 32

oldterm:        DS.L 1
oldcrit:        DS.L 1

; buffer, linebuf, s1 & s2 SKA ligga i rad.
; De bildar en st”rre buffert om 1.5K

buffer:         DS.L 128
bufferend       EQU *-1
                DS.L 1          ; Dumt att chansa
linebuf:        DS.L 128
linebufend      EQU *-1
                DS.L 1          ; You never know

s1:             DS.L 64
s2:             DS.L 64

bigbufferend:

argbuf:         DS.L 128
dta:            DS.L 11
envbuf:         DS.L 512
envbufend:      DS.L 1

control:        DS.W 12
global:         DS.W 15
intin:          DS.W 30
intout:         DS.W 45
addrin:         DS.L 3
addrout:        DS.L 1

his_counter:    DS.W 1
his_buf:        DS.B 256*his_size

stackstart      EQU *+1000      ; Marginal
                DS.L 12*256     ; Giga-exa-bautastack (12K)
mystack:

                ENDPART
                END
