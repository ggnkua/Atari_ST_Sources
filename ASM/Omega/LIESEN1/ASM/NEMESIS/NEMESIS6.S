home            EQU 0
Nr_Of_Posters   EQU 256
                PATH 'D:\LIESEN\DATA'


* Execute Fast
* Execute Normal
* Execute Slow   ,man skall kunna stoppa in en ny disk oxo..

* Special stuff...
*    Select Boot Block, Select Loader prog
*      Create a directory...... and that's it man!

* Ett system med RELOAD, ej at den ÜterstÑlls varje gÜng man kîr file operands.
* Sorterings metoder (Name, Extension)
* Ett prog som gîr en discus double sided till tvÜ singel sided.


* Filer fÜr inte ligga pÜ TVè disk sidor.
* TvÜ directories skall kunna linkas ihop nÑr allt Ñr klart.
* Directory pÜ track 79 sector 0-9
* Directory pÜ BèDA sidor och alla diskar.
*

                >PART 'Reduce Memory'
                movea.l a7,a5                     ; reserve memory and set stack
                movea.l 4(a5),a5
                move.l  $0C(a5),d0
                add.l   $14(a5),d0
                add.l   $1C(a5),d0
                add.l   #$0100,d0
                move.l  d0,-(a7)
                move.l  a5,-(a7)
                move.w  #0,-(a7)
                move.w  #$4A,-(a7)
                trap    #1
                lea     12(a7),a7
                ENDPART
                >PART 'StartSuper & Terminate'
                pea     super(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                clr.w   -(a7)
                trap    #1
                ENDPART
super:          >PART 'Init & Quit'
                lea     s(pc),a5
                bsr.s   BugFix
                move.w  #$20,-(a7)
                bsr     Nemesis
                bmi.s   usch

                move.w  #$14,-(a7)
                bsr     Nemesis
                movea.l d0,a1
                lea     Fonten(pc),a0
                move.l  a0,(a1)

                pea     Start_Text(pc)
                move.w  #0,-(a7)
                bsr     Nemesis

                bsr.s   MainMenu

                move.w  #$21,-(a7)
                bsr     Nemesis

                bsr.s   BugFix
                rts
usch:           illegal
                ENDPART
BugFix:         >PART 'Fix Bitplane Bug'
                move.b  #0,$FFFF8260.w            ; BitPlane Bug Remover HI
                move.w  #37,-(a7)
                trap    #14
                addq.l  #2,a7
                bclr    #1,$FFFF820A.w
                move.w  #37,-(a7)
                trap    #14
                addq.l  #2,a7
                bset    #1,$FFFF820A.w
                move.b  #2,$FFFF8260.w
                rts
                ENDPART

MainMenu:       >PART 'Main Menu'
*******************************************************
                pea     bar_string(pc)
                move.w  #10,-(a7)
                move.w  #2,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

mainloop:       clr.w   -(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                cmp.w   #0,d0
                beq.s   quiting
                cmp.w   #1,d0
                bne.s   NotSelectD
                bsr.s   SelectDrives
                bra.s   mainloop
NotSelectD:     cmp.w   #2,d0
                bne.s   Not_FileOpt
                bsr     FileOptMenu
                bra.s   mainloop
Not_FileOpt:    cmp.w   #3,d0
                bne.s   Not_Special
                bsr     Special_Menu
                bra.s   mainloop
Not_Special:    bra.s   mainloop
quiting:        move.w  #$81,-(a7)
                bsr     Nemesis
                bmi.s   usch
                rts
                ENDPART
SelectDrives:   >PART 'Select Drives Menu'
*******************************************************
                pea     bar_sd(pc)
                move.w  #13,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

SDloop:         clr.w   -(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                cmp.w   #0,d0
                bne.s   notDiscusSi
                bsr.s   DiscusSide
                bra.s   SDloop
notDiscusSi:    cmp.w   #1,d0
                bne.s   notTosP
                bsr.s   NewTosPath
                bra.s   SDloop
notTosP:        cmp.w   #2,d0
                bne.s   notTrashP
                bsr     NewTrashPath
                bra.s   SDloop
notTrashP:      cmp.w   #3,d0
                bne.s   notTempP
                bsr     NewTempPath
                bra.s   SDloop
notTempP:       cmp.w   #4,d0
                beq.s   quitingSD

                bra.s   SDloop

quitingSD:      move.w  #$81,-(a7)
                bsr     Nemesis
                rts
                ENDPART
DiscusSide:     >PART 'Select Discus Drive menu'
*******************************************************
                pea     bar_discus_ab(pc)
                move.w  #16,-(a7)
                move.w  #6,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis
                move.w  DiscusDrive(pc),-(a7)
                move.w  #$82,-(a7)
                bsr     Nemesis

                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                cmp.w   #0,d0
                bne.s   notA
                move.w  #0,DiscusDrive-s(a5)
                bra.s   quitingDS
notA:           move.w  #1,DiscusDrive-s(a5)
quitingDS:      rts
                ENDPART
NewTosPath:     >PART 'Enter new tos Path'
                move.w  #1,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                move.w  #4,-(a7)
                move.w  #8,-(a7)
                move.w  #75,-(a7)
                move.w  #10,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     Input70_text1(pc)
                clr.w   -(a7)
                bsr     Nemesis
                moveq   #70,d7
                lea     TosPath(pc),a6
                bsr     Input
                movea.l a6,a0
                bsr     MakeLarge

                move.w  #$33,-(a7)
                bsr     Nemesis

                pea     Input70_text2(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #0,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                rts
                ENDPART
NewTrashPath:   >PART 'Enter new trash Path'
                move.w  #1,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                move.w  #4,-(a7)
                move.w  #8,-(a7)
                move.w  #75,-(a7)
                move.w  #10,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     Input70_text1(pc)
                clr.w   -(a7)
                bsr     Nemesis
                moveq   #70,d7
                lea     TrashPath(pc),a6
                bsr     Input
                movea.l a6,a0
                bsr     MakeLarge

                move.w  #$33,-(a7)
                bsr     Nemesis

                pea     Input70_text2(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #0,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                rts
                ENDPART
NewTempPath:    >PART 'Enter new trash Path'
                move.w  #1,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                move.w  #4,-(a7)
                move.w  #8,-(a7)
                move.w  #75,-(a7)
                move.w  #10,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     Input70_text1(pc)
                clr.w   -(a7)
                bsr     Nemesis
                moveq   #70,d7
                lea     TempPath(pc),a6
                bsr     Input
                movea.l a6,a0
                bsr     MakeLarge

                move.w  #$33,-(a7)
                bsr     Nemesis

                pea     Input70_text2(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #0,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                rts
                ENDPART

Special_Menu:   >PART 'Special Menu'
                movem.l d0-a6,-(a7)
                pea     bar_spec(pc)
                move.w  #3,-(a7)
                move.w  #3,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

sl1:            clr.w   -(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                cmp.w   #0,d0
                bne.s   po1
                bsr.s   Spe_Set_Menu

po1:            cmp.w   #1,d0
                bne.s   po2
                bsr     Create_Discus


po2:            cmp.w   #2,d0
                bne.s   sl1


                move.w  #$81,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts
                ENDPART
Spe_Set_Menu:   >PART 'Special Settings'
                movem.l d0-a6,-(a7)
                pea     bar_spec_set(pc)
                move.w  #5,-(a7)
                move.w  #5,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

sl1s:           clr.w   -(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis

                cmp.w   #0,d0
                bne.s   pol1
                move.w  #10,d0
                moveq   #8,d1
                moveq   #12,d3
                lea     BootName(pc),a0
                bsr     InputString
                bsr     MakeLarge
                bra.s   sl1s

pol1:           cmp.w   #1,d0
                bne.s   pol2
                move.w  #23,d0
                moveq   #8,d1
                moveq   #12,d3
                lea     DirName(pc),a0
                bsr     InputString
                bsr     MakeLarge
                bra.s   sl1s




pol2:           cmp.w   #2,d0
                bne.s   pol3
                move.w  #35,d0
                moveq   #8,d1
                moveq   #4,d3
                lea     Magic(pc),a0
                bsr     InputString
                bsr     MakeLarge
                bra.s   sl1s


pol3:           cmp.w   #3,d0
                bne.s   pol4
                bsr.s   Spe_SetC_Menu

pol4:           cmp.w   #4,d0
                beq.s   qsls
                bra.s   sl1s

qsls:           move.w  #$81,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts
                ENDPART
Spe_SetC_Menu:  >PART 'Special Crypto Settings'
                movem.l d0-a6,-(a7)
                pea     bar_spec_cryp(pc)
                move.w  #7,-(a7)
                move.w  #7,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

sl1sc:          clr.w   -(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis

                cmp.w   #0,d0
                bne.s   Sofia1
                moveq   #10,d0
                moveq   #10,d1
                move.w  Crypt_Add(pc),d2
                moveq   #4,d3
                bsr     InputHex
                move.w  d2,Crypt_Add-s(a5)
Sofia1:
                cmp.w   #1,d0
                bne.s   Sofia2
                moveq   #25,d0
                moveq   #10,d1
                move.w  Crypt_Eor(pc),d2
                moveq   #4,d3
                bsr     InputHex
                move.w  d2,Crypt_Eor-s(a5)
Sofia2:
                cmp.w   #2,d0
                bne.s   Sofia3
                moveq   #37,d0
                moveq   #10,d1
                move.w  Crypt_Rol(pc),d2
                moveq   #4,d3
                bsr     InputHex
                move.w  d2,Crypt_Rol-s(a5)
Sofia3:

                cmp.w   #3,d0
                beq.s   qslsc
                bra.s   sl1sc


qslsc:          move.w  #$81,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts
                ENDPART

Create_Discus:  PART 'Create Discus'
                movem.l d0-a6,-(a7)
                move.w  #1,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                move.w  #1,-(a7)
                move.w  #8,-(a7)
                move.w  #77,-(a7)
                move.w  #24,-(a7)
                move.w  #$0F,-(a7)
                move.w  #0,-(a7)
                move.w  #$90,-(a7)
                bsr     Nemesis
                movea.l d0,a4

                move.l  a4,-(a7)
                pea     CreateText1(pc)
                move.w  #$93,-(a7)
                bsr     Nemesis


Repeating:      moveq   #4,d0
                moveq   #18,d1
                moveq   #70,d3
                lea     LoaderFile(pc),a0
*                bsr     InputString
*                bsr     MakeLarge
*                bsr     Exist
*                bne.s   Repeating

                move.l  a4,-(a7)
                pea     LoaderFile(pc)
                move.w  #$93,-(a7)
                bsr     Nemesis

                move.l  a4,-(a7)
                pea     CreateText2(pc)
                move.w  #$93,-(a7)
                bsr     Nemesis

                moveq   #38,d0
                moveq   #10,d1
                move.w  DiscNr(pc),d2
                moveq   #2,d3
                bsr     InputHex
                move.w  d2,DiscNr-s(a5)
                bsr     PrintHex

                move.l  a4,-(a7)
                pea     CreateText3(pc)
                move.w  #$93,-(a7)
                bsr     Nemesis

                moveq   #37,d0
                moveq   #12,d1
                move.w  BootDisc(pc),d2
                moveq   #2,d3
                bsr     InputHex
                move.w  d2,BootDisc-s(a5)
                bsr     PrintHex


                pea     bar_sure(pc)
                move.w  #10,-(a7)
                move.w  #10,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                bne.s   StoppaNu


                bsr     Do_Create


StoppaNu:       move.l  a4,-(a7)
                move.w  #$91,-(a7)
                bsr     Nemesis

                move.w  #0,-(a7)
                move.w  #$84,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts


DiscNr:         DC.W 0
BootDisc:       DC.W 0
LoaderFile:     DC.B "LOADER.B"
                DS.B 63
CreateText1:    DC.B 27,"q"
                DC.B 27,"E"
                DC.B 27,"a",2,9,77,16
                DC.B 27,"#",0
                DC.B 27,"a",3,10,76,15
                DC.B "Loader File:  512 bytes bootblock.",13,10
                DC.B "              Loader, any size at all.",13,10
                DC.B "The loader part must be loaded from the bootblock, it's located",13,10
                DC.B "from sector 2 and forward (=Sector after bootblock)",13,10
                DC.B "You can skip the header data on the bootblock!",13,10
                DC.B 10
                DC.B 0

CreateText2:    DC.B 27,"a",2,8,77,16
                DC.B 27,"#",1

                DC.B 27,"a",2,17,77,24
                DC.B 27,"#",0
                DC.B 27,"a",3,18,76,23
                DC.B 27,"E"
                DC.B "Discus Disc nr should always be even (as odd means side b).",13,10
                DC.B "Should be keep zero until more than one disc is requierd.",13,10
                DC.B 0
CreateText3:    DC.B 13,10,10,"Disc to boot from (Normally same as Disc nr).",13,10
                DC.B 0


                EVEN
                ENDPART
Do_Create:      >PART 'Do Create Discus'
                movem.l d0-a6,-(a7)
                movem.l (a7)+,d0-a6
                rts
                ENDPART


bar_spec:       DC.B "[{ Settings }:{ Create Discus }:{ Back }]"
                DC.B 0
bar_spec_set:   DC.B "[{ Boot Name }:{ Dir Name }:{ Magic String }:{ Crypto Values }:{ Back }]"
                DC.B 0
bar_spec_cryp:  DC.B "[{ Add Value }:{ Eor Value }:{ Rol Value }:{ Back }]"
                DC.B 0
bar_creat:      DC.B "[{ Boot Sector File }:{ Loader File }:{ Loader Address }:{ Back }]"
                DC.B 0
                EVEN

Magic:          DC.L "ANNA"
                DC.W 0
Crypt_Add:      DC.W 0
Crypt_Eor:      DC.W 0
Crypt_Rol:      DC.W 0
DirName:        DC.B "DIRECTOR.DIR"
                DC.W 0
BootName:       DC.B "BOOTAREA.RSV"
                DC.W 0


                EVEN

*************************************************

FileOptMenu:    >PART 'File Operand Menu'
                move.w  #5,-(a7)
                move.w  #9,-(a7)
                move.w  #74,-(a7)
                move.w  #23,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                move.b  #'A',z1-s(a5)
                move.w  DiscusDrive(pc),d0
                add.b   d0,z1-s(a5)

                pea     ShowPathsText1(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     TosPath(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     ShowPathsText2(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     TrashPath(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     ShowPathsText3(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     TempPath(pc)
                clr.w   -(a7)
                bsr     Nemesis
                pea     ShowPathsText4(pc)
                clr.w   -(a7)
                bsr     Nemesis

                pea     bar_ok_cancel(pc)
                move.w  #13,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis
                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                move.w  d0,d7

                cmp.w   #1,d7
                beq.s   Haha_Cancel

                moveq   #0,d7
                lea     TosPath(pc),a0
                bsr     ChDir
                tst.l   d0
                bpl.s   we1
                bset    #0,d7
we1:            lea     TrashPath(pc),a0
                bsr     ChDir
                tst.l   d0
                bpl.s   we2
                bset    #1,d7
we2:            lea     TempPath(pc),a0
                bsr     ChDir
                tst.l   d0
                bpl.s   we3
                bset    #2,d7
we3:            tst.w   d7
                bne.s   No_Way

                move.w  #$33,-(a7)
                bsr     Nemesis

                bsr     FillBufferts
                bsr     fileutil
                bsr     RemoveBufferts
                rts

******************************* Error Handler

Haha_Cancel:    move.w  #$33,-(a7)
                bsr     Nemesis
                rts

No_Way:         btst    #0,d7
                beq.s   No_Way2

                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                pea     bar_no_tospath(pc)
                move.w  #13,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis
                bsr     Nemesis

No_Way2:        btst    #1,d7
                beq.s   No_Way3

                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                pea     bar_no_trashp(pc)
                move.w  #13,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis
                bsr     Nemesis

No_Way3:        btst    #2,d7
                beq.s   No_Way4

                move.w  #1,-(a7)
                move.w  #$85,-(a7)
                pea     bar_no_tempp(pc)
                move.w  #13,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis
                bsr     Nemesis

No_Way4:        bra.s   Haha_Cancel

                ENDPART

FillBufferts:   >PART 'Load dirrs and creat bufferts'
                movem.l d0-a6,-(a7)
                pea     Nr_Of_Posters*16.w
                move.w  #$30,-(a7)
                bsr     Nemesis
                move.l  d0,Del_B-s(a5)
                movea.l d0,a0
                move.w  #Nr_Of_Posters*4-1,d0
HyperSpace1:    clr.l   (a0)+
                dbra    d0,HyperSpace1

                pea     Nr_Of_Posters*16.w
                move.w  #$30,-(a7)
                bsr     Nemesis
                move.l  d0,Trash_B-s(a5)
                movea.l d0,a0
                move.w  #Nr_Of_Posters*4-1,d0
HyperSpace2:    clr.l   (a0)+
                dbra    d0,HyperSpace2

                pea     Nr_Of_Posters*16.w
                move.w  #$30,-(a7)
                bsr     Nemesis
                move.l  d0,Work_B-s(a5)
                movea.l d0,a0
                move.w  #Nr_Of_Posters*4-1,d0
HyperSpace3:    clr.l   (a0)+
                dbra    d0,HyperSpace3

                pea     Nr_Of_Posters*16.w
                move.w  #$30,-(a7)
                bsr     Nemesis
                move.l  d0,Discus_B-s(a5)
                movea.l d0,a0
                move.w  #Nr_Of_Posters*4-1,d0
HyperSpace4:    clr.l   (a0)+
                dbra    d0,HyperSpace4

                lea     TosPath(pc),a0
                bsr     ChDir
                movea.l Work_B(pc),a3
                moveq   #'W',d7
                bsr     CopyDir
                lea     TrashPath(pc),a0
                bsr     ChDir
                movea.l Trash_B(pc),a3
                moveq   #'T',d7
                bsr     CopyDir

                movem.l (a7)+,d0-a6
                rts
                ENDPART
RemoveBufferts: >PART 'Free Buffert Memory'
                movem.l d0-a6,-(a7)
                move.l  Del_B(pc),-(a7)
                move.w  #$31,-(a7)
                bsr     Nemesis
                move.l  Trash_B(pc),-(a7)
                move.w  #$31,-(a7)
                bsr     Nemesis
                move.l  Work_B(pc),-(a7)
                move.w  #$31,-(a7)
                bsr     Nemesis
                move.l  Discus_B(pc),-(a7)
                move.w  #$31,-(a7)
                bsr     Nemesis
                movem.l (a7)+,d0-a6
                rts
                ENDPART

Copy_Buffs:     >PART 'Copy Bufferts to Windows'
                movem.l d0-a6,-(a7)
                movea.l w_trash+4(pc),a0
                movea.l Trash_B(pc),a1
                move.w  #Nr_Of_Posters-1,d0
Only_For1:      move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                dbra    d0,Only_For1
                movea.l w_work+4(pc),a0
                movea.l Work_B(pc),a1
                move.w  #Nr_Of_Posters-1,d0
Only_For2:      move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                move.l  (a1)+,(a0)+
                dbra    d0,Only_For2

                movem.l (a7)+,d0-a6
                rts
                ENDPART

Del_B:          DS.L 1
Trash_B:        DS.L 1
Work_B:         DS.L 1
Discus_B:       DS.L 1

fileutil:       >PART 'File Swapper'
                movem.l d0-a6,-(a7)

                move.w  #$03,-(a7)
                bsr     Nemesis
                movea.l d0,a4

                pea     bar_fs(pc)
                move.w  #1,-(a7)
                move.w  #3,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

                move.w  #43,-(a7)
                move.w  #2,-(a7)
                move.w  #79,-(a7)
                move.w  #7,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)
                move.w  #0,-(a7)
                move.w  #8,-(a7)
                move.w  #79,-(a7)
                move.w  #8,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     swap_text(pc)
                clr.w   -(a7)
                bsr     Nemesis

                lea     w_del(pc),a0
                bsr     Init_Window
                lea     w_trash(pc),a0
                bsr     Init_Window
                lea     w_work(pc),a0
                bsr     Init_Window
                lea     w_discus(pc),a0
                bsr     Init_Window


                bsr     Copy_Buffs


                moveq   #3,d0
oopd:           bsr     Draw_Content
                dbra    d0,oopd

                bsr     Draw_Help_Line
                moveq   #2,d0
                bsr     Mark_Window

fu_loop:        bsr     Update_Window
                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                move.l  d0,d7
                move.l  d7,d6
                swap    d6
                move.l  d0,-(a7)
                move.w  #$83,-(a7)
                bsr     Nemesis
                move.w  d0,d5

                bsr     Up_Down


                cmp.b   #$47,d6                   ; 'ClrHome'
                beq.s   change
                cmp.b   #$0F,d6                   ; 'Tab'
                beq.s   change
                cmp.b   #$11,d6                   ; 'W'
                bne.s   not_w
change:         move.w  U_w(pc),d0
                move.w  M_w(pc),U_w-s(a5)
                move.w  d0,M_w-s(a5)
                bsr     Mark_Window
not_w:          cmp.b   #$2B,d6
                beq.s   do_met
                cmp.b   #$10,d6                   ; 'Q'
                bne.s   not_q
do_met:         move.w  M_w(pc),d0
                addq.w  #1,d0
                andi.w  #3,d0
                cmp.w   U_w(pc),d0
                bne.s   NiceMan
                addq.w  #1,d0
                andi.w  #3,d0
NiceMan:        move.w  d0,M_w-s(a5)
                bsr     Mark_Window
                bsr     Draw_Help_Line
not_q:          cmp.b   #$20,d6                   ; 'D'
                beq.s   do_del
                cmp.b   #$53,d6                   ; 'Del'
                bne.s   not_d
do_del:         bsr     Delete
not_d:          cmp.b   #$52,d6                   ; 'M'
                bne.s   not_m
                clr.w   d6
                cmpi.w  #0,U_w-s(a5)
                beq.s   do_del
                bsr     Move
not_m:          cmp.b   #$2E,d6                   ; 'C'
                bne.s   not_c
                bsr     Copy
not_c:
                cmp.b   #'-',d7
                bne.s   not_minus
                move.w  M_w(pc),d0
                bsr     Swap_Up
not_minus:      cmp.b   #'+',d7
                bne.s   not_plus
                move.w  M_w(pc),d0
                bsr     Swap_Down
not_plus:       cmp.b   #$62,d6
                bne.s   not_help
                moveq   #0,d5
                bra.s   Jesus
not_help:

                cmp.b   #13,d7
                beq.s   Jesus
                bra     fu_loop

Jesus:          cmp.w   #0,d5
                bne.s   uy1
                move.w  #5,-(a7)
                move.w  #3,-(a7)
                move.w  #75,-(a7)
                move.w  #23,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     help_text(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                move.w  #$33,-(a7)
                bsr     Nemesis

uy1:            cmp.w   #1,d5
                bne.s   uy2
                bsr.s   ExecuteMenu
                tst.w   d0
                bne.s   uy2
                moveq   #2,d5

uy2:            cmp.w   #2,d5
                beq.s   jaaaAA
                bra     fu_loop

jaaaAA:
                lea     w_del(pc),a0
                bsr     Restore_Window
                lea     w_trash(pc),a0
                bsr     Restore_Window
                lea     w_work(pc),a0
                bsr     Restore_Window
                lea     w_discus(pc),a0
                bsr     Restore_Window

                pea     swap_text2(pc)
                clr.w   -(a7)
                bsr     Nemesis


                move.w  #$33,-(a7)
                bsr     Nemesis
                move.w  #$33,-(a7)
                bsr     Nemesis

                move.w  #$81,-(a7)
                bsr     Nemesis


                movem.l (a7)+,d0-a6
                rts
                ENDPART

ExecuteMenu:    >PART 'Execute'
                movem.l d1-a6,-(a7)
                pea     bar_exe(pc)
                move.w  #4,-(a7)
                move.w  #4,-(a7)
                move.w  #$80,-(a7)
                bsr     Nemesis

Exe_loop:       move.w  #0,-(a7)
                move.w  #$85,-(a7)
                bsr     Nemesis
                cmp.w   #0,d0
                bne.s   hj1
                bsr.s   Exe_Fast
hj1:            cmp.w   #1,d0
                bne.s   hj2
                bsr.s   Exe_Normal
hj2:            cmp.w   #2,d0
                bne.s   hj3
                bsr.s   Exe_Slow
hj3:            cmp.w   #3,d0
                bne.s   not_helpa

                move.w  #0,-(a7)
                move.w  #0,-(a7)
                move.w  #79,-(a7)
                move.w  #24,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                pea     exe_help_text(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                move.w  #$33,-(a7)
                bsr     Nemesis
                bra.s   Exe_loop

not_helpa:      cmp.w   #4,d0
                bne.s   not_back
                moveq   #-1,d0
                bra.s   HejHej

not_back:
                moveq   #0,d0

HejHej:         move.w  d0,-(a7)
                move.w  #$81,-(a7)
                bsr     Nemesis
                move.w  (a7)+,d0
                movem.l (a7)+,d1-a6
                tst.w   d0
                rts
                ENDPART
Exe_Fast:       >PART 'Fast Method'
                movem.l d0-a6,-(a7)

                movem.l (a7)+,d0-a6
                rts
                ENDPART
Exe_Normal:     >PART 'Normal Method'
                movem.l d0-a6,-(a7)
                movem.l (a7)+,d0-a6
                rts
                ENDPART
Exe_Slow:       >PART 'Slow Method'
                movem.l d0-a6,-(a7)
                movem.l (a7)+,d0-a6
                rts
                ENDPART


*********************************************
Delete:         >PART 'Delete Button'
                movem.l d0-a6,-(a7)
                cmpi.w  #0,M_w-s(a5)
                beq.s   polisbil

                move.w  M_w(pc),d0
                add.w   d0,d0
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                movea.l 4(a3),a0
                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                adda.w  d0,a0

                moveq   #0,d0

                movem.l d0/a0,-(a7)
                bsr     FindString2
                move.w  d0,d1
                movem.l (a7)+,d0/a0
                tst.w   d1
                bmi.s   Relif


                movem.l d0/a0,-(a7)               ; Delete Old if Already Exist
                move.w  w_del+$0C(pc),-(a7)
                move.w  w_del+$0E(pc),-(a7)
                clr.w   w_del+$0C-s(a5)
                move.w  d1,w_del+$0E-s(a5)
                bsr     DelPos
                move.w  (a7)+,w_del+$0E-s(a5)
                move.w  (a7)+,w_del+$0C-s(a5)
                movem.l (a7)+,d0/a0


Relif:          bsr     InsPos
                move.w  M_w(pc),d0
                bsr     DelPos

polisbil:       movem.l (a7)+,d0-a6
                rts
                ENDPART
Move:           >PART 'Move Button'
                movem.l d0-a6,-(a7)

                move.w  M_w(pc),d0
                add.w   d0,d0
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                movea.l 4(a3),a0
                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                adda.w  d0,a0
                move.w  U_w(pc),d0

                movem.l d0/a0,-(a7)
                bsr     FindString
                move.w  d0,d1
                movem.l (a7)+,d0/a0
                tst.w   d1
                bpl.s   brandbil

                bsr     InsPos
                move.w  M_w(pc),d0
                bsr     DelPos

brandbil:       movem.l (a7)+,d0-a6
                rts
                ENDPART
Copy:           >PART 'Copy Button'
                movem.l d0-a6,-(a7)

                move.w  M_w(pc),d0
                add.w   d0,d0
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                movea.l 4(a3),a0
                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                adda.w  d0,a0
                move.w  U_w(pc),d0

                movem.l d0/a0,-(a7)
                bsr     FindString
                move.w  d0,d1
                movem.l (a7)+,d0/a0
                tst.w   d1
                bpl.s   Plogbil
                bsr     InsPos

                move.l  #$500000,d7
                bsr     Up_Down

Plogbil:        movem.l (a7)+,d0-a6
                rts
                ENDPART
Swap_Up:        >PART 'Swap up'
                movem.l d0-a6,-(a7)

                move.w  M_w(pc),d0
                add.w   d0,d0                     ; Get Address
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                move.w  $0C(a3),d7                ; Top ?
                add.w   $0E(a3),d7
                tst.w   d7
                beq.s   Ambulans
                movea.l 4(a3),a2
                lsl.w   #4,d7
                tst.b   0(a2,d7.w)
                beq.s   Ambulans

                move.l  #$480000,d7               ; Go Up
                bsr     Up_Down

                move.w  $0C(a3),d7
                add.w   $0E(a3),d7
                movea.l 4(a3),a2                  ; Swap
                lsl.w   #4,d7
                adda.w  d7,a2
                move.l  16(a2),d0
                move.l  (a2),16(a2)
                move.l  d0,(a2)+
                move.l  16(a2),d0
                move.l  (a2),16(a2)
                move.l  d0,(a2)+
                move.l  16(a2),d0
                move.l  (a2),16(a2)
                move.l  d0,(a2)+
                move.l  16(a2),d0
                move.l  (a2),16(a2)
                move.l  d0,(a2)+

                move.w  $1E(a3),d1
                move.w  M_w(pc),d0
                bsr     Draw_Selectorn

                addq.w  #1,$0C(a3)
                bsr     Draw_On_Pos
                subq.w  #1,$0C(a3)
                bsr     Draw_On_Pos
                move.w  $1E(a3),d1
                move.w  M_w(pc),d0
                bsr     Draw_Selectorn


Ambulans:       movem.l (a7)+,d0-a6
                rts
                ENDPART
Swap_Down:      >PART 'Swap Down'
                movem.l d0-a6,-(a7)

                move.w  M_w(pc),d0
                add.w   d0,d0                     ; Get Address
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                move.w  $0C(a3),d7                ; Top ?
                add.w   $0E(a3),d7
                movea.l 4(a3),a2
                lsl.w   #4,d7
                tst.b   16(a2,d7.w)
                beq.s   BÑrningsbil

                move.l  #$500000,d7               ; Go Down
                bsr.s   Up_Down

                move.w  $0C(a3),d7
                add.w   $0E(a3),d7
                movea.l 4(a3),a2                  ; Swap
                lsl.w   #4,d7
                adda.w  d7,a2
                move.l  -16(a2),d0
                move.l  (a2),-16(a2)
                move.l  d0,(a2)+
                move.l  -16(a2),d0
                move.l  (a2),-16(a2)
                move.l  d0,(a2)+
                move.l  -16(a2),d0
                move.l  (a2),-16(a2)
                move.l  d0,(a2)+
                move.l  -16(a2),d0
                move.l  (a2),-16(a2)
                move.l  d0,(a2)+

                move.w  $1E(a3),d1
                move.w  M_w(pc),d0
                bsr     Draw_Selectorn

                subq.w  #1,$0C(a3)
                bsr     Draw_On_Pos
                addq.w  #1,$0C(a3)
                bsr     Draw_On_Pos
                move.w  $1E(a3),d1
                move.w  M_w(pc),d0
                bsr     Draw_Selectorn


BÑrningsbil:    movem.l (a7)+,d0-a6
                rts
                ENDPART

Up_Down:        >PART 'Check for Up/Down'
* d7=key, tos
                movem.l d0-a6,-(a7)
                swap    d7

                lea     Win_Tab(pc),a0
                move.w  M_w(pc),d0
                add.w   d0,d0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3


                cmp.b   #$48,d7
                bne.s   not_ups

                subq.w  #1,$0C(a3)
                bpl.s   not_ups
                clr.w   $0C(a3)
                tst.w   $0E(a3)
                beq.s   not_ups
                subq.w  #1,$0E(a3)

                move.w  M_w(pc),d0
                move.w  $1E(a3),d1
                bsr     Draw_Selectorn
                move.w  #27,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #'S',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #1,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis

                bsr     Draw_On_Pos

                move.w  M_w(pc),d0
                move.w  $0C(a3),d1
                move.w  d1,$1E(a3)
                bsr     Draw_Selectorn
                move.w  $0E(a3),$20(a3)

*******
not_ups:        cmp.b   #$50,d7
                bne.s   not_downs

                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                movea.l 4(a3),a0
                tst.b   0(a0,d0.w)
                beq.s   not_downs

                addq.w  #1,$0C(a3)
                cmpi.w  #14,$0C(a3)
                blo.s   not_downs
                subq.w  #1,$0C(a3)
                addq.w  #1,$0E(a3)

                move.w  M_w(pc),d0
                move.w  $1E(a3),d1
                bsr     Draw_Selectorn
                move.w  #27,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #'S',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #0,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis

                bsr.s   Draw_On_Pos

                move.w  M_w(pc),d0
                move.w  $0C(a3),d1
                move.w  d1,$1E(a3)
                bsr     Draw_Selectorn
                move.w  $0E(a3),$20(a3)

***********
not_downs:      movem.l (a7)+,d0-a6
                rts

                ENDPART
Draw_On_Pos:    >PART 'Update Text on selector'
* a3=address to window
                movem.l d0-a6,-(a7)

                move.w  #27,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #'z',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  #0,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                move.w  $0C(a3),-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis

                move.w  $0C(a3),d1
                add.w   $0E(a3),d1
                lsl.w   #4,d1
                movea.l 4(a3),a0
                adda.w  d1,a0

                pea     clear_Text(pc)
                clr.w   -(a7)
                bsr     Nemesis
                move.l  a0,-(a7)
                clr.w   -(a7)
                bsr     Nemesis
                movem.l (a7)+,d0-a6
                rts

clear_Text:     DC.B 27,")","               ",27,"(",0
                EVEN
                ENDPART

Draw_Content:   >PART 'Update Content of a window'
* d0=Window
                movem.l d0-a6,-(a7)
                move.w  d0,d7
                add.w   d0,d0
                lea     Win_Tab(pc),a0
                move.w  0(a0,d0.w),d0
                lea     0(a5,d0.w),a3

                move.w  $1C(a3),d0                ; Get area
                lea     0(a5,d0.w),a0
                move.l  a0,-(a7)
                clr.w   -(a7)
                bsr     Nemesis
                pea     Cls(pc)
                clr.w   -(a7)
                bsr     Nemesis

                movea.l 4(a3),a1
                move.w  $0E(a3),d0
                move.w  d0,$20(a3)
                lsl.w   #4,d0
                adda.w  d0,a1

                moveq   #13,d1
                bra.s   zp2
zp1:            pea     Cr(pc)
                clr.w   -(a7)
                bsr     Nemesis
zp2:            move.l  a1,-(a7)
                clr.w   -(a7)
                bsr     Nemesis
                lea     16(a1),a1
                dbra    d1,zp1

                move.w  d7,d0
                move.w  $0C(a3),d1
                move.w  d1,$1E(a3)                ; Bloody Hell!
                bsr.s   Draw_Selectorn

                movem.l (a7)+,d0-a6
                ENDPART
Draw_Selectorn: >PART 'Draw Selector(n)'
* d0=Window
* d1=Pos
                movem.l d0-a6,-(a7)
                lea     Win_Tab(pc),a0
                adda.w  d0,a0
                adda.w  d0,a0
                move.w  (a0),d0
                lea     0(a5,d0.w),a3

                move.w  $1C(a3),d0                ; Get area
                lea     0(a5,d0.w),a0
                move.l  a0,-(a7)
                clr.w   -(a7)
                bsr     Nemesis

                add.w   d1,2(a4)
                moveq   #16,d1

InVErSe:        move.w  #$04,-(a7)
                bsr     Nemesis
                bchg    #4,d0
                move.w  d0,-(a7)
                move.w  #$05,-(a7)
                bsr     Nemesis
                addq.w  #1,(a4)
                dbra    d1,InVErSe

                movem.l (a7)+,d0-a6
                rts
                ENDPART

Mark_Window:    >PART 'Mark Window'
* D0=window to mark
                movem.l d0-a6,-(a7)
                move.w  d0,M_w-s(a5)
                move.w  d0,d7
                moveq   #3,d6
                lea     Win_Tab(pc),a0
unmarkall:      move.w  (a0)+,d0
                lea     0(a5,d0.w),a1
                bclr    #1,$19(a1)
                dbra    d6,unmarkall
                lea     Win_Tab(pc),a0
                add.w   d7,d7
                move.w  0(a0,d7.w),d0
                lea     0(a5,d0.w),a1
                bset    #1,$19(a1)

                movem.l (a7)+,d0-a6
                rts
                ENDPART
Update_Window:  >PART 'Update Window'
                movem.l d0-a6,-(a7)

                lea     Win_Tab+8(pc),a3
                moveq   #3,d7

upd:            move.w  -(a3),d0
                lea     0(a5,d0.w),a0
                move.w  $18(a0),d6
                cmp.w   $1A(a0),d6
                beq.s   Skipp

                move.w  d6,$1A(a0)
                btst    #0,d6                     ; Shadow/Normal
                beq.s   Shod
                pea     Marked(pc)
                bra.s   Kom_Hit
Shod:           pea     Shadow(pc)
Kom_Hit:        clr.w   -(a7)
                bsr     Nemesis
                btst    #1,d6                     ; Marked/UnMarked
                beq.s   UnM
                move.w  2(a0),d0
                bra.s   Kom_Hit2
UnM:            move.w  (a0),d0
Kom_Hit2:       lea     0(a5,d0.w),a1
                move.l  a1,-(a7)
                clr.w   -(a7)
                bsr     Nemesis

Skipp:          move.w  $0C(a0),d0                ; Selector and UpperLine
                cmp.w   $1E(a0),d0
                bne.s   Shame
                move.w  $0E(a0),d0
                cmp.w   $20(a0),d0
                beq.s   Skippp

Shame:          bsr.s   Update_Select

Skippp:         dbra    d7,upd

                movem.l (a7)+,d0-a6
                rts

*********************************************
                ENDPART
Update_Select:  >PART 'handled by Update Window'
* d7 = Window
                movem.l d0-a6,-(a7)
                lea     Win_Tab(pc),a0
                adda.w  d7,a0
                adda.w  d7,a0
                move.w  (a0),d0
                lea     0(a5,d0.w),a3

                move.w  $0E(a3),d0
                cmp.w   $20(a3),d0
                beq.s   No_Harm1

                move.w  d7,d0
                bsr     Draw_Content
                bra.s   No_Harm2
No_Harm1:

                move.w  d7,d0
                move.w  $1E(a3),d1
                bsr     Draw_Selectorn
                move.w  $0C(a3),d1
                move.w  d1,$1E(a3)
                bsr     Draw_Selectorn

No_Harm2:       movem.l (a7)+,d0-a6
                rts
                ENDPART

Init_Window:    >PART 'Init Window'
* a0=Address to window
                clr.w   $18(a0)
                clr.w   $1A(a0)

                clr.w   $0C(a0)
                clr.w   $0E(a0)
                clr.w   $1E(a0)
                clr.w   $20(a0)

                move.w  $10(a0),-(a7)
                move.w  $12(a0),-(a7)
                move.w  $14(a0),-(a7)
                move.w  $16(a0),-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,$08(a0)
                move.w  (a0),d0
                lea     0(a5,d0.w),a1
                pea     Shadow(pc)
                clr.w   -(a7)
                bsr     Nemesis
                move.l  a1,-(a7)
                clr.w   -(a7)
                bsr     Nemesis
                pea     Cls(pc)
                clr.w   -(a7)
                bsr     Nemesis

                pea     16*Nr_Of_Posters.w
                move.w  #$30,-(a7)
                bsr     Nemesis
                move.l  d0,$04(a0)
                movea.l d0,a1
                move.w  #Nr_Of_Posters-1,d0
rensaren3:      clr.l   (a1)+
                clr.l   (a1)+
                clr.l   (a1)+
                clr.l   (a1)+
                dbra    d0,rensaren3

                rts
*********************************************
                ENDPART
Restore_Window: >PART 'Restore window'
* a0=address to window
                move.l  8(a0),-(a7)
                move.w  #$33,-(a7)
                bsr     Nemesis
                move.l  4(a0),-(a7)
                move.w  #$31,-(a7)
                bsr     Nemesis
                rts
*********************************************
                ENDPART
Draw_Help_Line: >PART 'Draw Help Line'
                movem.l d0-a6,-(a7)
                move.w  M_w(pc),d1
                move.w  U_w(pc),d2

                cmp.w   d1,d2
                bhi.s   noworry
                exg     d1,d2
noworry:
                add.w   d1,d1
                add.w   d2,d2
                lea     Win_Tab(pc),a0
                movea.l a0,a1
                moveq   #3,d3
shadda:         move.w  (a1)+,d0
                lea     0(a5,d0.w),a2
                bclr    #0,$19(a2)
                dbra    d3,shadda

                move.w  0(a0,d1.w),d1
                move.w  0(a0,d2.w),d2
                lea     0(a5,d1.w),a2
                lea     0(a5,d2.w),a3

                move.w  $10(a2),d1
                move.w  $10(a3),d2

                add.w   #10,d1
                add.w   #10,d2

                pea     qw1(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  d1,(a4)
                move.w  #'…',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis

                move.w  d2,d3
                sub.w   d1,d3
                subq.w  #2,d3
drawlinen:      move.w  #'Õ',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                dbra    d3,drawlinen
                move.w  #'ª',-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis

                bset    #0,$19(a2)
                bset    #0,$19(a3)

                pea     qw2(pc)
                clr.w   -(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts

qw1:            DC.B 27,")",27,"a",0,8,79,8,27,"q"
                DC.B 27,"E",0
qw2:            DC.B 27,"(",0
                EVEN

                ENDPART

DelPos:         >PART 'Delete Selector Pos'
* d0=window
                movem.l d0-a6,-(a7)
                move.w  d0,d7
                add.w   d7,d7
                lea     Win_Tab(pc),a0
                move.w  0(a0,d7.w),d7
                lea     0(a5,d7.w),a3

                movea.l 4(a3),a2
                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                adda.w  d0,a2
                tst.b   (a2)
                beq.s   Kidding

                move.w  #-1,$20(a3)               ; Force Update

HeheHaha:       move.l  16(a2),(a2)+
                move.l  16(a2),(a2)+
                move.l  16(a2),(a2)+
                move.l  16(a2),(a2)+

                tst.b   (a2)
                bne.s   HeheHaha


Kidding:        movem.l (a7)+,d0-a6
                rts
                ENDPART
InsPos:         >PART 'Insert String on Pos'
* d0=window
* a0=Address to string to insert

                movem.l d0-a6,-(a7)
                tst.b   (a0)
                beq.s   Skojigt

                movea.l a0,a6

                move.w  d0,d7
                add.w   d7,d7
                lea     Win_Tab(pc),a0
                move.w  0(a0,d7.w),d7
                lea     0(a5,d7.w),a3

                movea.l 4(a3),a2
                move.w  $0C(a3),d0
                add.w   $0E(a3),d0
                lsl.w   #4,d0
                adda.w  d0,a2
                movea.l a2,a1


                move.w  #-1,$20(a3)               ; Force Update

FindLastFucker: lea     16(a1),a1
                tst.b   (a1)
                bne.s   FindLastFucker
                lea     16(a1),a1
                lea     -16(a1),a0

HîHî:           move.l  -(a0),-(a1)
                move.l  -(a0),-(a1)
                move.l  -(a0),-(a1)
                move.l  -(a0),-(a1)

                cmpa.l  a0,a2
                bne.s   HîHî

                move.l  (a6)+,(a2)+
                move.l  (a6)+,(a2)+
                move.l  (a6)+,(a2)+
                move.l  (a6)+,(a2)+


Skojigt:        movem.l (a7)+,d0-a6
                rts
                ENDPART
FindString:     >PART 'Check if name exist in buf'
* d0=window
* a0=address to string
* out: d0=pos
*      a0=address to pos
                movem.l d1-d7/a1-a6,-(a7)

                add.w   d0,d0
                lea     Win_Tab(pc),a1
                move.w  0(a1,d0.w),d0
                lea     0(a5,d0.w),a3

                movea.l 4(a3),a6

                moveq   #0,d6
                addq.l  #3,a0
Is_It:          movea.l a0,a1
                lea     3(a6),a2

                moveq   #11,d7
Always:         move.b  (a1)+,d0
                cmp.b   (a2)+,d0
                bne.s   Like
                tst.b   d0
                beq.s   This
                dbra    d7,Always
                bra.s   This

Like:           addq.l  #1,d6
                lea     16(a6),a6
                tst.b   (a6)
                bne.s   Is_It
                moveq   #-1,d6

This:           movea.l a6,a0
                move.l  d6,d0

                movem.l (a7)+,d1-d7/a1-a6
                rts
                ENDPART
FindString2:    >PART 'Check if string exist in buf'
* d0=window
* a0=address to string
* out: d0=pos
*      a0=address to pos
                movem.l d1-d7/a1-a6,-(a7)
                add.w   d0,d0
                lea     Win_Tab(pc),a1
                move.w  0(a1,d0.w),d0
                lea     0(a5,d0.w),a3
                movea.l 4(a3),a6
                moveq   #0,d6
With:           movea.l a0,a1
                movea.l a6,a2

                moveq   #15,d7
Out:            move.b  (a1)+,d0
                cmp.b   (a2)+,d0
                bne.s   You
                tst.b   d0
                beq.s   Weee
                dbra    d7,Out
                bra.s   Weee

You:            addq.l  #1,d6
                lea     16(a6),a6
                tst.b   (a6)
                bne.s   With
                moveq   #-1,d6

Weee:           movea.l a6,a0
                move.l  d6,d0

                movem.l (a7)+,d1-d7/a1-a6
                rts
                ENDPART

CopyDir:        >PART 'Copy all in dir'
* a3=Dest tab
* d7=Char to include in name ('W','T','D'...)
                movem.l d0-a6,-(a7)
                move.w  #$2F,-(a7)
                trap    #1
                addq.l  #2,a7
                movea.l d0,a2

                move.w  #0,-(a7)
                pea     search(pc)
                move.w  #$4E,-(a7)
                trap    #1
                addq.l  #8,a7

Flensa:         tst.w   d0
                bne.s   NoMoreDir

                lea     30(a2),a1
                movea.l a3,a0

                move.b  #' ',(a0)+
                move.b  d7,(a0)+
                move.b  #' ',(a0)+

Utsikt:         move.b  (a1)+,d0
                beq.s   Rumpa
                move.b  d0,(a0)+
                bra.s   Utsikt
Rumpa:          lea     16(a3),a3

                move.w  #$4F,-(a7)
                trap    #1
                addq.l  #2,a7
                bra.s   Flensa

NoMoreDir:
                movem.l (a7)+,d0-a6
                rts

search:         DC.B "*.*",0
                EVEN
                ENDPART
ChDir:          >PART 'Change Dir, and Drive'
* a0=Address to new dir
* out; d0 as tos;
                movem.l d1-a6,-(a7)
                cmpi.b  #':',1(a0)
                bne.s   noDrive
                moveq   #0,d0
                move.b  (a0),d0
                sub.b   #'A',d0
                move.l  a0,-(a7)
                move.w  d0,-(a7)
                move.w  #$0E,-(a7)
                trap    #1
                addq.l  #4,a7
                tst.w   d0
                bmi.s   FeLFEl
                movea.l (a7)+,a0
                addq.l  #2,a0                     ; Skip Drive
noDrive:
                move.l  a0,-(a7)
                move.w  #$3B,-(a7)
                trap    #1
                addq.l  #6,a7

FeLFEl:         movem.l (a7)+,d1-a6
                rts
                ENDPART
Exist:          >PART 'Test if a file exist'
* a0=Address to string
                movem.l d1-a6,-(a7)
                movea.l a0,a1
                movea.l a1,a2
Sara:           move.b  (a1)+,d0
                beq.s   MariA
                cmp.b   #":",d0
                beq.s   YeS
                cmp.b   #"\",d0
                bne.s   Sara
YeS:            movea.l a1,a2
                bra.s   Sara
MariA:
                move.b  (a2),d1
                clr.b   (a2)
                bsr.s   ChDir
                move.b  d1,(a2)

                move.b  #0,-(a7)
                move.l  a2,-(a7)
                move.w  #$4E,-(a7)
                trap    #1
                addq.l  #8,a7


                movem.l (a7)+,d1-a6
                tst.w   d0
                rts
                ENDPART
                >PART 'Window Data'
M_w:            DC.W 2
U_w:            DC.W 3

Win_Tab:        DC.W w_del-s,w_trash-s,w_work-s,w_discus-s


w_del:          DC.W uw_del-s                     ; $00  Unmark text
                DC.W mw_del-s                     ; $02  Mark Text
                DC.L 0                            ; $04  Address to tab
                DC.L 0                            ; $08  Address to saved block
                DC.W 0                            ; $0c  Selector pos in window
                DC.W 0                            ; $0e  Upper line pos in tab
                DC.W 0                            ; $10  X1
                DC.W 9                            ; $12  Y1
                DC.W 18                           ; $14  X2
                DC.W 24                           ; $16  Y2
                DC.W 0                            ; $18  Status
                DC.W $20                          ; $1a  Old Status
                DC.W sw_del-s                     ; $1c  Select area text
                DC.W 0                            ; $1e  old Selector pos
                DC.W 0                            ; $20  old Upper line pos

* bit 0    1=Active (not shadow)
* bit 1    1=Marked

w_trash:        DC.W uw_trash-s                   ; Unmark text
                DC.W mw_trash-s                   ; Mark Text
                DC.L 0                            ; Address to tab
                DC.L 0                            ; Address to saved block
                DC.W 0                            ; Selector pos in window
                DC.W 0                            ; Upper line pos in tab
                DC.W 20                           ; X1
                DC.W 9                            ; Y1
                DC.W 38                           ; X2
                DC.W 24                           ; Y2
                DC.W 0                            ; $18  Status
                DC.W 0                            ; $1a  Old Status
                DC.W sw_trash-s                   ; $1c  Select area text
                DC.W 0                            ; $1e  old Selector pos
                DC.W 0                            ; $20  old Upper line pos

w_work:         DC.W uw_work-s                    ; Unmark text
                DC.W mw_work-s                    ; Mark Text
                DC.L 0                            ; Address to tab
                DC.L 0                            ; Address to saved block
                DC.W 0                            ; Selector pos in window
                DC.W 0                            ; Upper line pos in tab
                DC.W 41                           ; X1
                DC.W 9                            ; Y1
                DC.W 59                           ; X2
                DC.W 24                           ; Y2
                DC.W 0                            ; $18  Status
                DC.W 0                            ; $1a  Old Status
                DC.W sw_work-s                    ; $1c  Select area text
                DC.W 0                            ; $1e  old Selector pos
                DC.W 0                            ; $20  old Upper line pos

w_discus:       DC.W uw_discus-s                  ; Unmark text
                DC.W mw_discus-s                  ; Mark Text
                DC.L 0                            ; Address to tab
                DC.L 0                            ; Address to saved block
                DC.W 0                            ; Selector pos in window
                DC.W 0                            ; Upper line pos in tab
                DC.W 61                           ; X1
                DC.W 9                            ; Y1
                DC.W 79                           ; X2
                DC.W 24                           ; Y2
                DC.W 0                            ; $18  Status
                DC.W 0                            ; $1a  Old Status
                DC.W sw_discus-s                  ; $1c  Select area text
                DC.W 0                            ; $1e  old Selector pos
                DC.W 0                            ; $20  old Upper line pos


uw_del:         DC.B 27,"a",0,9,18,24,27,"#",1
                DC.B 27,"z",2,0," Delete "
                DC.B 27,"<",1
                DC.B 27,"a",1,10,17,23
                DC.B 0
mw_del:         DC.B 27,"a",0,9,18,24,27,"#",0
                DC.B 27,"z",2,0," Delete "
                DC.B 27,"<",1
sw_del:         DC.B 27,"a",1,10,17,23
                DC.B 0
uw_trash:       DC.B 27,"a",20,9,38,24,27,"#",1
                DC.B 27,"z",2,0," Trash "
                DC.B 27,"<",1
                DC.B 27,"a",21,10,37,23
                DC.B 0
mw_trash:       DC.B 27,"a",20,9,38,24,27,"#",0
                DC.B 27,"z",2,0," Trash "
                DC.B 27,"<",1
sw_trash:       DC.B 27,"a",21,10,37,23
                DC.B 0
uw_work:        DC.B 27,"a",41,9,59,24,27,"#",1
                DC.B 27,"z",2,0," Work "
                DC.B 27,"<",1
                DC.B 27,"a",42,10,58,23
                DC.B 0
mw_work:        DC.B 27,"a",41,9,59,24,27,"#",0
                DC.B 27,"z",2,0," Work "
                DC.B 27,"<",1
sw_work:        DC.B 27,"a",42,10,58,23
                DC.B 0
uw_discus:      DC.B 27,"a",61,9,79,24,27,"#",1
                DC.B 27,"z",2,0," Discus "
                DC.B 27,"<",1
                DC.B 27,"a",62,10,78,23
                DC.B 0
mw_discus:      DC.B 27,"a",61,9,79,24,27,"#",0
                DC.B 27,"z",2,0," Discus "
                DC.B 27,"<",1
sw_discus:      DC.B 27,"a",62,10,78,23
                DC.B 0
                EVEN
                ENDPART

Input:          >PART 'Input Routine'
* D7=Max lenght, excluding the ending null
* A6=Where to put it (and preset data)  NO ESC COMMANDS!
                movem.l d0-a6,-(a7)
                subq.w  #1,d7
                move.w  d7,MaxInpX-s(a5)
                lea     EditBuf(pc),a0
                movea.l a0,a1
                moveq   #40,d0
rensaren:       clr.w   (a0)+
                dbra    d0,rensaren
                movea.l a6,a0
f1:             move.b  (a0)+,d0
                beq.s   f2
                move.b  d0,(a1)+
                bra.s   f1
f2:             move.w  #$03,-(a7)
                bsr     Nemesis
                movea.l d0,a4
                move.w  (a4),Xet-s(a5)

                pea     EditBuf(pc)
                clr.w   -(a7)
                bsr     Nemesis


InputLoop:      move.w  (a4),d0
                sub.w   Xet(pc),d0

                cmp.w   MaxInpX(pc),d0
                blo.s   okithen
                move.w  MaxInpX(pc),d0
                move.w  d0,(a4)
                move.w  Xet(pc),d1
                add.w   d1,(a4)
okithen:        move.w  d0,TrueX-s(a5)

                bsr     DrawCursor
                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                bsr     DrawCursor
                move.l  d0,d1
                swap    d1

                cmp.b   #$4B,d1
                bne.s   notlefta
                tst.w   TrueX-s(a5)               ; Left
                beq.s   InputLoop
                subq.w  #1,(a4)
                bra.s   InputLoop
notlefta:       cmp.b   #$4D,d1
                bne.s   notrighta
                lea     EditBuf(pc),a0
                adda.w  TrueX(pc),a0
                tst.b   (a0)
                beq.s   InputLoop
                addq.w  #1,(a4)
                bra.s   InputLoop
notrighta:      cmp.b   #$48,d1
                bne.s   notdowna
                move.w  Xet(pc),(a4)
                bra.s   InputLoop
notdowna:       cmp.b   #$50,d1
                bne.s   notupa
                lea     EditBuf(pc),a0
                move.w  Xet(pc),(a4)
look_vidare:    tst.b   (a0)+
                beq.s   InputLoop
                addq.w  #1,(a4)
                bra.s   look_vidare
notupa:
                cmp.b   #32,d0
                blo.s   notascII
                cmp.b   #127,d0
                beq.s   notascII
                bsr     InsertPos
                move.w  TrueX(pc),d1
                lea     EditBuf(pc),a0
                move.b  d0,0(a0,d1.w)

                move.w  d0,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
                bra     InputLoop
notascII:       cmp.b   #127,d0
                bne.s   notdeleta
                bsr     DeletePos
                bra     InputLoop

notdeleta:      cmp.b   #27,d0
                bne.s   notesca
                bsr.s   ClearEdit
                bra     InputLoop
notesca:        cmp.b   #$61,d1
                bne.s   notundo
                bsr.s   ClearEdit
                lea     EditBuf(pc),a1
                movea.l a6,a0
f3:             move.b  (a0)+,d0
                beq.s   f4
                move.b  d0,(a1)+
                bra.s   f3
f4:             move.w  #$03,-(a7)
                bsr     Nemesis
                movea.l d0,a4
                move.w  (a4),Xet-s(a5)
                pea     EditBuf(pc)
                clr.w   -(a7)
                bsr     Nemesis
                bra     InputLoop
notundo:        cmp.b   #$08,d0
                bne.s   notbackspace
                subq.w  #1,TrueX-s(a5)
                bmi     InputLoop
                subq.w  #1,(a4)
                bsr.s   DeletePos
                bra     InputLoop

notbackspace:
                cmp.b   #13,d0
                bne     InputLoop
                lea     EditBuf(pc),a0
                movea.l a6,a1
                move.w  MaxInpX(pc),d0
copyback:       move.b  (a0)+,(a1)+
                dbra    d0,copyback

                movem.l (a7)+,d0-a6
                rts
*************************************
ClearEdit:      lea     EditBuf(pc),a0
                move.w  Xet(pc),(a4)
                move.w  MaxInpX(pc),d7
rensaren2:      clr.b   (a0)+
                move.w  #4,-(a7)
                bsr     Nemesis
                and.w   #$FF,d0
                or.w    #$2000,d0
                move.w  d0,-(a7)
                move.w  #$05,-(a7)
                bsr     Nemesis
                addq.w  #1,(a4)
                dbra    d7,rensaren2
                move.w  Xet(pc),(a4)
                rts
*************************************
DeletePos:      movem.l d0-a6,-(a7)
                lea     EditBuf(pc),a0
                move.w  TrueX(pc),d5
                adda.w  d5,a0
                add.w   Xet(pc),d5
                move.w  2(a4),d6
                mulu    $12(a4),d6
                add.w   d5,d6
                add.w   d6,d6
                movea.l $16(a4),a1
                adda.w  d6,a1

                move.w  MaxInpX(pc),d6
                sub.w   TrueX(pc),d6
                subq.w  #1,d6
                bmi.s   oooppss
deleteloop:     move.w  2(a1),(a1)+
                move.b  1(a0),(a0)+
                dbra    d6,deleteloop
                move.b  #32,(a1)
                move.b  #0,(a0)

oooppss:        move.w  (a4),-(a7)
                move.w  2(a4),-(a7)
                move.w  MaxInpX(pc),d0
                add.w   Xet(pc),d0
                move.w  d0,-(a7)
                move.w  2(a4),-(a7)
                move.w  #2,-(a7)
                bsr     Nemesis
                movem.l (a7)+,d0-a6
                rts
*************************************
InsertPos:      movem.l d0-a6,-(a7)
                lea     EditBuf(pc),a0
                move.w  MaxInpX(pc),d5
                adda.w  d5,a0
                add.w   Xet(pc),d5
                move.w  2(a4),d6
                mulu    $12(a4),d6
                add.w   d5,d6
                add.w   d6,d6
                movea.l $16(a4),a1
                adda.w  d6,a1

                move.w  MaxInpX(pc),d6
                sub.w   TrueX(pc),d6
                bmi.s   ooopps
insertlloop:    move.w  -2(a1),(a1)
                subq.w  #2,a1
                move.b  -1(a0),(a0)
                subq.w  #1,a0
                dbra    d6,insertlloop

ooopps:         move.w  (a4),-(a7)
                move.w  2(a4),-(a7)
                move.w  MaxInpX(pc),d0
                add.w   Xet(pc),d0
                move.w  d0,-(a7)
                move.w  2(a4),-(a7)
                move.w  #2,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts
*************************************
DrawCursor:     movem.l d0-a6,-(a7)
                move.w  #$04,-(a7)
                bsr     Nemesis

                bchg    #4,d0
                move.w  d0,-(a7)
                move.w  #$05,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-a6
                rts

Xet:            DC.W 0
TrueX:          DC.W 0
MaxInpX:        DC.W 0
EditBuf:        DS.B 82
                ENDPART
InputHex:       >PART 'LongWord Input as hex'
* d0=x
* d1=y
* d2=value
* d3=nr of values (2=Byte 4=Word 8=Longword)
* out d3=New value
                movem.l d0-d1/d3-a6,-(a7)

                lea     gnu1(pc),a0
                lea     gnu2(pc),a1
                move.w  d0,d7
                move.b  d7,2(a1)
                move.w  d7,d6
                subq.w  #1,d6
                move.b  d6,2(a0)
                add.w   d3,d7
                subq.w  #1,d7
                move.b  d7,4(a1)
                addq.w  #1,d7
                move.b  d7,4(a0)

                move.w  d1,d7
                move.b  d7,3(a1)
                move.b  d7,5(a1)
                subq.w  #1,d7
                move.b  d7,3(a0)
                addq.w  #2,d7
                move.b  d7,5(a0)

                moveq   #0,d0
                move.b  2(a0),d0
                move.w  d0,-(a7)
                move.b  3(a0),d0
                move.w  d0,-(a7)
                move.b  4(a0),d0
                move.w  d0,-(a7)
                move.b  5(a0),d0
                move.w  d0,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)

                lea     stupidbuf(pc),a0
                moveq   #4,d0
tyu:            clr.w   (a0)+
                dbra    d0,tyu

                lea     convert(pc),a4

                lea     stupidbuf(pc),a0
                moveq   #7,d1
conv1:          rol.l   #4,d2
                cmp.w   d3,d1
                bhs.s   Pernilla
                move.w  d2,d0
                and.w   #$0F,d0
                move.b  0(a4,d0.w),(a0)+
Pernilla:       dbra    d1,conv1

Noughty:        pea     InputHex_text(pc)
                clr.w   -(a7)
                bsr     Nemesis
                lea     stupidbuf(pc),a6
                move.w  d3,d7
                bsr     Input
                lea     stupidbuf(pc),a0
                bsr     MakeLarge

                lea     stupidbuf(pc),a0
Anna:           move.b  (a0)+,d0
                beq.s   felfri
                moveq   #15,d1
Malin:          cmp.b   0(a4,d1.w),d0
                beq.s   Anna
                dbra    d1,Malin
                bra.s   Noughty

felfri:         pea     RestorePosen(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #$33,-(a7)
                bsr     Nemesis

                lea     stupidbuf(pc),a0
                lea     convert(pc),a4
                moveq   #7,d3
                moveq   #0,d2

Lisa:           moveq   #0,d1
                move.b  (a0)+,d0
                beq.s   Susan
                moveq   #15,d1
Linda:          cmp.b   0(a4,d1.w),d0
                beq.s   Tina
                dbra    d1,Linda
Tina:
                rol.l   #4,d2
                or.b    d1,d2
Susan:          dbra    d3,Lisa
                movem.l (a7)+,d0-d1/d3-a6
                rts

stupidbuf:      DS.B 10
convert:        DC.B "0123456789ABCDEF"

InputHex_text:  DC.B 27,")"
                DC.B 27,"p",27,"w"
gnu1:           DC.B 27,"a",30,7,35,9
                DC.B 27,"#",0
gnu2:           DC.B 27,"a",31,8,34,8
                DC.B 27,"E",0

                ENDPART
InputString:    >PART 'String Input'
* d0=x
* d1=y
* d3=nr chars
* a0=String
* out d3=New value
                movem.l d0-d1/d3-a6,-(a7)
                movea.l a0,a6

                lea     gnu1(pc),a0
                lea     gnu2(pc),a1
                move.w  d0,d7
                move.b  d7,2(a1)
                move.w  d7,d6
                subq.w  #1,d6
                move.b  d6,2(a0)
                add.w   d3,d7
                subq.w  #1,d7
                move.b  d7,4(a1)
                addq.w  #1,d7
                move.b  d7,4(a0)

                move.w  d1,d7
                move.b  d7,3(a1)
                move.b  d7,5(a1)
                subq.w  #1,d7
                move.b  d7,3(a0)
                addq.w  #2,d7
                move.b  d7,5(a0)

                moveq   #0,d0
                move.b  2(a0),d0
                move.w  d0,-(a7)
                move.b  3(a0),d0
                move.w  d0,-(a7)
                move.b  4(a0),d0
                move.w  d0,-(a7)
                move.b  5(a0),d0
                move.w  d0,-(a7)
                move.w  #$32,-(a7)
                bsr     Nemesis
                move.l  d0,-(a7)


                pea     InputHex_text(pc)
                clr.w   -(a7)
                bsr     Nemesis
                move.w  d3,d7
                bsr     Input


                pea     RestorePosen(pc)
                clr.w   -(a7)
                bsr     Nemesis

                move.w  #$33,-(a7)
                bsr     Nemesis

                movem.l (a7)+,d0-d1/d3-a6
                rts


                ENDPART
MakeLarge:      >PART 'Make All Chars Large'
* a0=address to string
                movem.l d0-a6,-(a7)
                movea.l a0,a1
StorlOOp:       move.b  (a0)+,d0
                beq.s   slUT

                cmp.b   #'a',d0
                blo.s   hurmph
                cmp.b   #'z',d0
                bhi.s   hurmph

                sub.b   #'a'-'A',d0

hurmph:         move.b  d0,(a1)+
                bra.s   StorlOOp
slUT:           movem.l (a7)+,d0-a6
                rts
                ENDPART
PrintHex:       >PART 'Print hex'
* d2=value
* d3=nr of values (2=Byte 4=Word 8=Longword)
                movem.l d0-a6,-(a7)

                lea     convert(pc),a4

                moveq   #7,d1
conv3:          rol.l   #4,d2
                cmp.w   d3,d1
                bhs.s   Pernilla3
                move.w  d2,d0
                and.w   #$0F,d0
                move.b  0(a4,d0.w),d0
                and.w   #$FF,d0
                move.w  d0,-(a7)
                move.w  #1,-(a7)
                bsr     Nemesis
Pernilla3:      dbra    d1,conv3

                movem.l (a7)+,d0-a6
                rts
                ENDPART

Fonten:
                IBYTES 'IBMFNT16.FNT'
*                IBYTES 'IBMFNT8.FNT'

DiscusDrive:    DC.W 0                            ; 0=a 1=b
TosPath:        DC.B "D:\TEMP\",0
                DS.B 61
                DC.B 0
TrashPath:      DC.B "D:\TEMP\TRASH\",0
                DS.B 55
                DC.B 0
TempPath:       DC.B "D:\TEMP\TEMP\",0
                DS.B 56
                DC.B 0
bar_string:
                DC.B "[{ Quit }:{ Select Drives }:{ File Operands }:{ Special }]"
                DC.B 0
bar_sd:         DC.B "[{ Discus Disk }:{ Tos Path }:{ Trash Path }:{ Temporary Path }:{ Back }]",0
bar_discus_ab:  DC.B "[{ A }:{ B }]",0
bar_ok_cancel:  DC.B "[{ Ok }:{ Cancel }]",0
bar_no_tospath: DC.B "[{ Tos Path not valid }]",0
bar_no_trashp:  DC.B "[{ Trash Path not valid }]",0
bar_no_tempp:   DC.B "[{ Temporary Path not valid }]",0
bar_fs:         DC.B "[{ Help }:{ Execute }:{ Cancel }]",0
bar_exe:        DC.B "[{ Fast }:{ Normal }:{ Slow }:{ Help }:{ Back }]",0
bar_sure:       DC.B "[{ Do This }:{ Skip This }]",0

                >PART 'Text'
help_text:      DC.B 27,")"
                DC.B 27,"p",27,"a",5,3,74,23
                DC.B 27,"#",0
                DC.B 27,"a",6,4,73,22
                DC.B 27,"E"
                DC.B "Del Window   -  Files that will be deleted when Execute.",13,10
                DC.B "Trash Window -  Quite meaningsless, but may help sometimes.",13,10
                DC.B "Work Window  -  Like Trash, but a litle bit more serious..",13,10
                DC.B "Discus Window-  Files that will be placed on the discus disc.",13,10
                DC.B 10
                DC.B "When Execute, the files files will be handled in the sorted order,",13,10
                DC.B "but files on the TOS paths will NOT be sorted (!!) in their",13,10
                DC.B "directory (but the Discus files will be sorted..).",13,10
                DC.B 10
                DC.B "Tab,W,ClrHome     Change active window",13,10
                DC.B "Q,\               Select new active window (hard to describe..)",13,10
                DC.B "Insert,M          Move a file from Selected to othe window.",13,10
                DC.B "Delete,D          Delete a file (=Move to Trash)",13,10
                DC.B "C                 Copy a file (dangerous in this version!) ",13,10
                DC.B "-                 Swap a file in the window upwards",13,10
                DC.B "+                 Swap a file in the window downwards",13,10
                DC.B "Help              Guess..",13,10
                DC.B "Cursor keys       Guess..",13,10
                DC.B "Return            This is getting silly..",13
                DC.B 27,"("
                DC.B 0

swap_text:      DC.B 27,")",27,"p",27,"w",27,"r"
                DC.B 27,">",0
                DC.B 27,"s"
                DC.B 27,">",1
                DC.B 27,"a",43,2,79,7
                DC.B 27,"E"
                DC.B 27,"#",1
                DC.B 27,"z",2,0
                DC.B " QuickHelp "
                DC.B 27,"a",44,3,78,6
                DC.B "'-' Swap up    'M' Move    D=Discus",13,10
                DC.B "'+' Swap down  'D' Delete  W=Work",13,10
                DC.B "'W' Window     'C' Copy    T=Trash",13,10
                DC.B "'Q' Conection  'Help' for more info"
                DC.B 0

Cr:             DC.B 13,10,0
Cls:            DC.B 27,"E",0
SavePosen:      DC.B 27,")",0
RestorePosen:   DC.B 27,"(",0
Shadow:         DC.B 27,"<",0,0
Marked:         DC.B 27,"<",1,0
swap_text2:     DC.B 27,"(",0

*****************************************************

ShowPathsText1: DC.B 27,")"
                DC.B 27,"p"
                DC.B 27,"a",5,9,74,23
                DC.B 27,"E"
                DC.B 27,"#",1
                DC.B 27,"a",6,10,73,22
                DC.B "Please verify the following data and select OK if",13,10
                DC.B "it look un-dangerous to you.",13,10,10
                DC.B "In drive "
z1:             DC.B "A: is the Discus Disc to work on.",13,10,10
                DC.B "Tos Path to work in:",13,10,0
ShowPathsText2: DC.B 13,10,10
                DC.B "Path to put 'trashed' files:",13,10,0
ShowPathsText3: DC.B 13,10,10
                DC.B "Path for temporary storage:",13,10,0
ShowPathsText4: DC.B 27,"(",0

*****************************************************

Input70_text1:  DC.B 27,"("
                DC.B 27,"p",27,"w"
                DC.B 27,"a",4,8,75,10
                DC.B 27,"#",0
                DC.B 27,"a",5,9,74,9
                DC.B 27,"E",0
Input70_text2:  DC.B 27,")",0

*****************************************************

exe_help_text:  DC.B 27,")"
                DC.B 27,"p",27,"a",2,3,77,23,27,"E",27,"#",0
                DC.B 27,"a",4,4,75,22
                DC.B "When Saving/Deleting/Moving files you have thoose Options:",13,10
                DC.B 10
                DC.B "Fast   - Delete, causing gaps, Insert at best suitable gap.",13,10
                DC.B "         Sort the directory, not the files position on the disc.",13,10
                DC.B "         This method is recomended while working on your",13,10
                DC.B "         project, then use slow when finished.",13,10
                DC.B 10
                DC.B "Normal - Delete, remove gaps, Insert at end.",13,10
                DC.B "         Sort the directory, not the files, but new files",13,10
                DC.B "         will be placed sorted at the end.",13,10
                DC.B 10
                DC.B "Slow   - All files to temporary path, then the whole disc is",13,10
                DC.B "         deleted and the files is inserted again, in sorted",13,10
                DC.B "         order. This action is quite slow!",13
                DC.B 27,"("
                DC.B 0

*****************************************************

Start_Text:     DC.B 27,"E"
                DC.B 27,")",27,"a",0,0,79,1,27,"w"
                DC.B 27,"p",27,"E","Discus0.1  (C) Synchron Assembly 1991     Made By Martin Liesen",13,10
                DC.B "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ",0
                DC.B 27,"("
                DC.B 0
                ENDPART
                EVEN


*****************************************************
**** Nemesis User Interface *************************
**** (C) Martin Liesen 1991   Synchron Assemby
*****************************************************
**** Later Versions of NEMESIS will probably not
**** be totaly compatible with older versions..
*****************************************************
rem             EQU 0
SizeOfSavePos   EQU 8                             ; Limit 32!
StackSavePos    EQU 31                            ; Memory Spent = (17+StackSavePos)*SizeOfPos
Xsize           EQU 80                            ; In Highest Resolution
Ysize           EQU 25                            ; In Highest Resolution

                OPT P+
s:
******************************************************
Nemesis:        >PART 'Nemesis, JSR handler'
                movem.l d1-a6,-(a7)               ; Denna rutin ser skum ut,
                move.l  _RegAddr(pc),-(a7)        ; beror pÜ rekrusivitet

                lea     s(pc),a5

                move.l  a7,_RegAddr-s(a5)

                lea     (15*4)+4(a7),a6
                clr.l   Return-s(a5)
                move.w  (a6)+,d0
                lea     Function_Tab(pc),a0
.FindFunc:      move.w  (a0)+,d1
                bmi.s   not_found
                move.w  (a0)+,d3
                move.w  (a0)+,d2
                cmp.b   d0,d1
                bne.s   .FindFunc
                lea     0(a5,d2.w),a0
                move.w  d3,-(a7)
                jsr     (a0)
                move.w  (a7)+,d3

QuitNemesis:    move.l  Return(pc),d0
                lea     (15*4)(a7),a7
                move.l  (a7)+,d1
                lea     0(a7,d3.w),a7
                move.l  d1,-(a7)

                movea.l _RegAddr(pc),a6
                move.l  (a6)+,_RegAddr-s(a5)
                movem.l (a6)+,d1-a6

                tst.l   d0
                rts

not_found:      move.l  #-2,Return-s(a5)          ; Tough Luck!!
                moveq   #0,d3
                bra.s   QuitNemesis


Return:         DS.L 1
_RegAddr:       DS.L 1                            ; Address to saved regs tab

* $0000-$000F   Screen output routs
* $0010-$002F   General nemesis data rutines
* $0030-$00     Any thing, memory ect
* $0070-$007F   Keybord rutines
* $0080-$008F   Bar rutines
* $0090-$009F   Window rutines

Function_Tab:   DC.W $00,$06,Con_Print_Line-s
                DC.W $01,$04,Con_Print_Char-s
                DC.W $02,$0A,Con_Update-s
                DC.W $03,$02,Con_GetDataTab-s
                DC.W $04,$02,Con_GetValue-s
                DC.W $05,$04,Con_SetValue-s


                DC.W $10,$04,Gen_Set_Sel-s
                DC.W $11,$02,Gen_Get_Sel-s
                DC.W $12,$04,Gen_Set_UnSel-s
                DC.W $13,$02,Gen_Get_UnSel-s
                DC.W $14,$02,Gen_Get_FontP-s
                DC.W $15,$06,Gen_Set_Mask-s
                DC.W $16,$02,Gen_Get_Mask-s
                DC.W $17,$02,Gen_Get_Screen-s
                DC.W $18,$06,Gen_Set_Screen-s

                DC.W $20,$02,Gen_Open_Work-s
                DC.W $21,$02,Gen_Close_Work-s

                DC.W $30,$06,Any_Rese_Mem-s
                DC.W $31,$06,Any_Free_Mem-s
                DC.W $32,$0A,Any_Save_Blk-s
                DC.W $33,$06,Any_Rest_Blk-s

                DC.W $70,$02,Key_Conin-s

                DC.W $80,$0A,Bar_Open-s
                DC.W $81,$02,Bar_Close-s
                DC.W $82,$04,Bar_SetPos-s
                DC.W $83,$06,Bar_Update-s
                DC.W $84,$04,Bar_Redraw-s
                DC.W $85,$04,Bar_Take_Con-s

                DC.W $90,$0E,Win_Open-s
                DC.W $91,$06,Win_Close-s
                DC.W $92,0,Win_ChgBorder-s
                DC.W $93,$0A,Win_Print-s
                DC.W $94,$08,Win_PrintChar-s
                DC.W -1,-1,-1
                ENDPART
******************************************************
String_Print:   >PART 'Print Line'
* A0=Address to string
* out; d0=Number of chars written
                movem.l d1,-(a7)
                moveq   #0,d1
Printing:       move.b  (a0)+,d0
                beq.s   LastOne
Not_Last_One:   addq.w  #1,d1
                bsr.s   Do_Char
                bra.s   Printing
LastOne:        tst.w   EscDoing-s(a5)
                bne.s   Not_Last_One
                move.l  d1,d0
                movem.l (a7)+,d1
                rts
                ENDPART
Do_Char:        >PART 'Print Character'
**********************************************************

                movem.l d0-a6,-(a7)
                and.w   #$FF,d0
                tst.w   EscDoing-s(a5)
                bne     Execute_Com
                cmp.b   #27,d0
                beq     Got_Esc

                cmp.b   #10,d0
                beq     LF
                cmp.b   #13,d0
                beq     CR

                move.w  X(pc),d1
                move.w  Y(pc),d2
                cmp.w   Xmax(pc),d1               ; Cliping
                bls.s   m1
                move.w  Xmax(pc),d1
m1:             cmp.w   Xmin(pc),d1
                bhs.s   m2
                move.w  Xmin(pc),d1
m2:             cmp.w   Ymax(pc),d2
                bls.s   m3
                move.w  Ymax(pc),d2
m3:             cmp.w   Ymin(pc),d2
                bhs.s   m4
                move.w  Ymin(pc),d2
m4:

                movea.l a5,a0
                adda.w  A_Print_Rout(pc),a0
                move.b  Look_Byte(pc),d3
                jsr     0(a0)

                move.w  X(pc),d1
                move.w  Y(pc),d2
                tst.w   OverFlow-s(a5)
                bne.s   No_Ow
                cmp.w   Xmax-s(a5),d1
                blo.s   No_Ow
                move.w  Xmin(pc),d1
                addq.w  #1,d2
                move.w  d1,X-s(a5)
                move.w  d2,Y-s(a5)
                bsr.s   Test_Scroll
                bra.s   Enough

No_Ow:          addq.w  #1,d1
                move.w  d1,X-s(a5)
                move.w  d2,Y-s(a5)
                bra.s   Enough


**********************************************************

Test_Scroll:    movem.l d0-d3,-(a7)
                move.w  Ymax-s(a5),d0
                addq.w  #1,d0
                cmp.w   Y(pc),d0
                bne.s   No_Hurry
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                bsr     ScrollUp
                subq.w  #1,Y-s(a5)
No_Hurry:       movem.l (a7)+,d0-d3
                rts



**********************************************************

CR:             move.w  Xmin(pc),X-s(a5)
                bra.s   Enough
LF:             addq.w  #1,Y-s(a5)
                bsr.s   Test_Scroll
*                bra.s   Enough

**********************************************************


Enough:         movem.l (a7)+,d0-a6
                rts

**********************************************************
                ENDPART

Mono8x8:        >PART 'Print Mono 8*8'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #Xsize,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #3,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #3,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1)+,(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1)+,2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1)+,4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1)+,6*80(a0)
                move.b  (a1)+,7*80(a0)

                btst    #4,d3
                beq.s   thanks1
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
thanks1:        btst    #5,d3
                beq.s   thanks2
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
thanks2:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART
Mono8x16_II:    >PART 'Print Mono 8*16 using 8*8 font'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #80,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #4,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #3,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1),(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1),2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1),4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1),6*80(a0)
                move.b  (a1)+,7*80(a0)
                move.b  (a1),8*80(a0)
                move.b  (a1)+,9*80(a0)
                move.b  (a1),10*80(a0)
                move.b  (a1)+,11*80(a0)
                move.b  (a1),12*80(a0)
                move.b  (a1)+,13*80(a0)
                move.b  (a1),14*80(a0)
                move.b  (a1)+,15*80(a0)

                btst    #4,d3
                beq.s   thanks1b
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
                not.b   8*80(a0)
                not.b   9*80(a0)
                not.b   10*80(a0)
                not.b   11*80(a0)
                not.b   12*80(a0)
                not.b   13*80(a0)
                not.b   14*80(a0)
                not.b   15*80(a0)
thanks1b:       btst    #5,d3
                beq.s   thanks2b
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
                move.b  (a1)+,d0
                and.b   d0,8*80(a0)
                move.b  (a1)+,d0
                and.b   d0,9*80(a0)
                move.b  (a1)+,d0
                and.b   d0,10*80(a0)
                move.b  (a1)+,d0
                and.b   d0,11*80(a0)
                move.b  (a1)+,d0
                and.b   d0,12*80(a0)
                move.b  (a1)+,d0
                and.b   d0,13*80(a0)
                move.b  (a1)+,d0
                and.b   d0,14*80(a0)
                move.b  (a1)+,d0
                and.b   d0,15*80(a0)
thanks2b:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART
Mono8x16:       >PART 'Print Mono 8*16'
*          Mono don't give a shit about the colors!
* D0=Char
* D1=X
* D2=Y
* D3=LookByte
                movem.l d0-d2/d4/a0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                mulu    #80,d2
                move.w  d1,d4

                add.w   d2,d4
                add.w   d4,d4
                move.b  d0,0(a0,d4.w)
                move.b  d3,1(a0,d4.w)

                lsl.w   #4,d2
                add.w   d1,d2
                movea.l $044E.w,a0
                adda.w  d2,a0
                lsl.w   #4,d0
                movea.l Font_Point(pc),a1
                adda.w  d0,a1

                move.b  (a1)+,(a0)
                move.b  (a1)+,1*80(a0)
                move.b  (a1)+,2*80(a0)
                move.b  (a1)+,3*80(a0)
                move.b  (a1)+,4*80(a0)
                move.b  (a1)+,5*80(a0)
                move.b  (a1)+,6*80(a0)
                move.b  (a1)+,7*80(a0)
                move.b  (a1)+,8*80(a0)
                move.b  (a1)+,9*80(a0)
                move.b  (a1)+,10*80(a0)
                move.b  (a1)+,11*80(a0)
                move.b  (a1)+,12*80(a0)
                move.b  (a1)+,13*80(a0)
                move.b  (a1)+,14*80(a0)
                move.b  (a1)+,15*80(a0)

                btst    #4,d3
                beq.s   thanks1c
                not.b   (a0)
                not.b   1*80(a0)
                not.b   2*80(a0)
                not.b   3*80(a0)
                not.b   4*80(a0)
                not.b   5*80(a0)
                not.b   6*80(a0)
                not.b   7*80(a0)
                not.b   8*80(a0)
                not.b   9*80(a0)
                not.b   10*80(a0)
                not.b   11*80(a0)
                not.b   12*80(a0)
                not.b   13*80(a0)
                not.b   14*80(a0)
                not.b   15*80(a0)
thanks1c:       btst    #5,d3
                beq.s   thanks2c
                lea     Mask(pc),a1
                move.b  (a1)+,d0
                and.b   d0,0*80(a0)
                move.b  (a1)+,d0
                and.b   d0,1*80(a0)
                move.b  (a1)+,d0
                and.b   d0,2*80(a0)
                move.b  (a1)+,d0
                and.b   d0,3*80(a0)
                move.b  (a1)+,d0
                and.b   d0,4*80(a0)
                move.b  (a1)+,d0
                and.b   d0,5*80(a0)
                move.b  (a1)+,d0
                and.b   d0,6*80(a0)
                move.b  (a1)+,d0
                and.b   d0,7*80(a0)
                move.b  (a1)+,d0
                and.b   d0,8*80(a0)
                move.b  (a1)+,d0
                and.b   d0,9*80(a0)
                move.b  (a1)+,d0
                and.b   d0,10*80(a0)
                move.b  (a1)+,d0
                and.b   d0,11*80(a0)
                move.b  (a1)+,d0
                and.b   d0,12*80(a0)
                move.b  (a1)+,d0
                and.b   d0,13*80(a0)
                move.b  (a1)+,d0
                and.b   d0,14*80(a0)
                move.b  (a1)+,d0
                and.b   d0,15*80(a0)
thanks2c:
                movem.l (a7)+,d0-d2/d4/a0-a1
                rts
                ENDPART

Amount_Tab:     >PART 'Data for ESC commands'
                DC.B "A",0
                DC.W P_CursUp-s
                DC.B "B",0
                DC.W P_CursDown-s
                DC.B "C",0
                DC.W P_CursRight-s
                DC.B "D",0
                DC.W P_CursLeft-s
                DC.B "E",0
                DC.W P_ClrHome-s
                DC.B "H",0
                DC.W P_Home-s
                DC.B "I",0
                DC.W P_CursUpScroll-s
                DC.B "S",1
                DC.W P_Scroll-s
                DC.B "Y",2
                DC.W P_Place_Curs_O-s
                DC.B "Z",2
                DC.W P_Place_Curs_F-s
                DC.B "a",4
                DC.W P_SetArea-s
                DC.B "b",1
                DC.W P_Color-s
                DC.B "j",0
                DC.W P_VTSave-s
                DC.B "k",0
                DC.W P_VTRestore-s
                DC.B "p",0
                DC.W P_Reverse_On-s
                DC.B "q",0
                DC.W P_Reverse_Off-s
                DC.B "r",0
                DC.W P_Mask_On-s
                DC.B "s",0
                DC.W P_Mask_Off-s
                DC.B "v",0
                DC.W P_OverFlow_On-s
                DC.B "w",0
                DC.W P_OverFlow_Off-s
                DC.B "x",1
                DC.W P_Place_Curs_X-s
                DC.B "y",1
                DC.W P_Place_Curs_Y-s
                DC.B "z",2
                DC.W P_Place_Curs_W-s
                DC.B ">",1
                DC.W P_SaveData-s
                DC.B "<",1
                DC.W P_RestoreData-s
                DC.B ")",0
                DC.W P_SP_Save-s
                DC.B "(",0
                DC.W P_SP_Restore-s
                DC.B "#",1
                DC.W P_DrawBox-s
                DC.B "+",0
                DC.W P_OPTon-s
                DC.B "-",0
                DC.W P_OPToff-s

                DC.B -1,-1
                DC.W 0
                ENDPART
PrintDataTab:   >PART 'Print Data'
**********************************************************
X:              DC.W 0                            ; $0
Y:              DC.W 0                            ; $2
Xmin:           DC.W 0                            ; $4
Ymin:           DC.W 0                            ; $6
Xmax:           DC.W Xsize-1                      ; $8
Ymax:           DC.W Ysize-1                      ; $a
OPT_Flag:       DC.W 0                            ; $c  0=On
OverFlow:       DC.W 0                            ; $e  0=0n
Look_Byte:      DC.B 1                            ; $10
                DC.B 0                            ; $11
                DC.W Xsize                        ; $12  Read Only
                DC.W Ysize                        ; $14  Read Only
Char_Screen:    DS.L 1                            ; $16  1b Char 1b data

                DS.B $40-$1A
                EVEN
**********************************************************
A_Print_Rout:   DC.W Mono8x16-s                   ; $40
A_Scroll_U_Rout:DC.W ScrU_all-s                   ; $42
A_Scroll_D_Rout:DC.W ScrD_all-s                   ; $44
A_Scroll_L_Rout:DC.W ScrL_all-s                   ; $46
A_Scroll_R_Rout:DC.W ScrR_all-s                   ; $48
A_Fill_Area:    DC.W FillA_all-s                  ; $4a
A_Update_Area:  DC.W UpdateA_all-s                ; $4c
**********************************************************
Char_Buffert:   DS.B 10
Char_Pek:       DS.L 1
EscDoing:       DS.W 1
Recived:        DS.W 1
**********************************************************
                ENDPART
                >PART 'DOC'

* A                  Y  Cursor Up
* B                  Y  Cursor Down
* C                  Y  Cursor Right
* D                  Y  Cursor Left
* E                  Y  Clear Window And Place Cursor at Home
* H                  Y  Place Cursor at home
* I                  Y  Cursor Up, Scroll Down if at top, and keep Y
* S(0-3)             Y  Scroll 0=Up, 1=Down, 2=Left 3=Right
* Y(x+32,y+32)       N  Place Cursor (VT52, x+32, y+32  full screen)
* Z(x,y)             N  Place Cursor (fullscreen coordinates)
* a(x1,y1,x2,y2)     Y  Set textarea, and Home cursor
* b(0-F)            -  Set color on character
* c(0-3)             -  Set forground color
* j                  Y  Save Position
* k                  Y  Restore Position
* p                  -  Reverse On
* q                  -  Reverse Off
* r                  -  Mask On
* s                  -  Mask Off
* v                  Y  Overflow On
* w                  Y  Overflow Off
* z(x,y)             Y  Place Cursor (window coordinates)
* >(0-F)             Y  Save all values concerning text
* <(0-F)             Y  Restore saved values
* )                  Y  Put values on a 'stack'
* (                  Y  Get values from the 'stack'
* #(0-F)             Y  Draw a box, at the Window coorninates
                ENDPART
                >PART 'Handel ESC stuff'

**********************************************************

Got_Esc:        move.w  #-1,EscDoing-s(a5)        ; Escape is just recived
                clr.w   Recived-s(a5)
                lea     Char_Buffert(pc),a0       ; Prevent error
                move.l  a0,Char_Pek-s(a5)
                bra     Enough

**********************************************************

Execute_Com:    movea.l Char_Pek(pc),a0           ; Escape recived before
                move.b  d0,(a0)+
                move.l  a0,Char_Pek-s(a5)
                subi.w  #1,Recived-s(a5)
                bmi.s   First_Command
                bne     Enough

Do_Command:     lea     Char_Buffert(pc),a0
                lea     s(pc),a1
                adda.w  (a0)+,a1
                jsr     (a1)
                clr.w   EscDoing-s(a5)
                bra     Enough

**********************************************************

First_Command:  lea     Amount_Tab(pc),a0         ; Got Escape and ONE character
tn1:            move.b  (a0)+,d1
                bmi.s   None_At_All
                move.b  (a0)+,d2
                move.w  (a0)+,d3
                cmp.b   d0,d1
                bne.s   tn1

                lea     Char_Buffert(pc),a0
                move.w  d3,(a0)+
                move.l  a0,Char_Pek-s(a5)
                ext.w   d2
                beq.s   Do_Command
                move.w  d2,Recived-s(a5)

                bra     Enough

None_At_All:    clr.w   EscDoing-s(a5)            ; Not valid command
                bra     Enough

**********************************************************
                ENDPART

Update_Area:    >PART 'Update A Specific Area'
                move.w  d4,-(a7)
                move.w  A_Update_Area(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

* D0=X1   D1=Y1   D2=X2   d3=Y2
*
UpdateA_all:
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

loopy4a:        move.w  d1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx4a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx4a
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy4a
                movem.l (a7)+,d0-a2
                rts

                ENDPART
Fill_Area:      >PART 'Fill A Specific Area'
                move.w  d4,-(a7)
                move.w  A_Fill_Area(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

* D0=X1   D1=Y1   D2=X2   d3=Y2
* D6=Char D7=LookByte
FillA_all:      movem.l d0-a1,-(a7)

                movea.l Char_Screen(pc),a0
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a1
                move.w  d3,d4
                move.w  d2,d3
                move.w  d1,d2
                move.w  d0,d1

copyloop10:     movem.w d0/d3,-(a7)
                move.w  d6,d0
                move.w  d7,d3
                jsr     (a1)
                movem.w (a7)+,d0/d3

                addq.w  #1,d1
                cmp.w   d3,d1
                ble.s   copyloop10
                move.w  d0,d1
                addq.w  #1,d2
                cmp.w   d4,d2
                ble.s   copyloop10

                movem.l (a7)+,d0-a1
                rts

                ENDPART


ScrollUp:       >PART 'Scroll Area Upwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_U_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrU_all:                                         ; General Scroll Up
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                cmp.w   d1,d3                     ; = Only Emptiness
                beq.s   Start_Clear0

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                subq.w  #1,d6                     ; Skip Emptiness Area

                move.w  d2,d3
                add.w   #1,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT0

loopy0a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx0a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx0a
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy0a
                bra.s   Start_Clear0


DoOPT0:
loopy0b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx0b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   -162(a2),d0
                bne.s   dohim0
                cmp.b   -161(a2),d3
                beq.s   skiphim0
dohim0:         jsr     (a0)
skiphim0:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx0b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy0b



Start_Clear0:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d3,d1
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollDown:     >PART 'Scroll Area Downwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_D_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrD_all:                                         ; General Scroll Down
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0
                exg     d1,d3

                cmp.w   d1,d3                     ; = Only Emptiness
                beq.s   Start_Clear1

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                addq.w  #1,d6                     ; Skip Emptiness Area

                move.w  d2,d3
                add.w   #-1,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT1

loopy1a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx1a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx1a
                move.w  d7,d1
                subq.w  #1,d2
                lea     -80*2(a1),a1
                cmp.w   d6,d2
                bge.s   loopy1a
                bra.s   Start_Clear1


DoOPT1:
loopy1b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx1b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   158(a2),d0
                bne.s   dohim1
                cmp.b   159(a2),d3
                beq.s   skiphim1
dohim1:         jsr     (a0)
skiphim1:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx1b
                move.w  d7,d1
                subq.w  #1,d2
                lea     -80*2(a1),a1
                cmp.w   d6,d2
                bge.s   loopy1b



Start_Clear1:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d1,d3
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollLeft:     >PART 'Scroll Area Leftwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_L_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrL_all:                                         ; General Scroll Left
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0

                cmp.w   d0,d2                     ; = Only Emptiness
                beq.s   Start_Clear2

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                subq.w  #1,d5                     ; Skip Emptiness Area

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT2

loopy2a:        move.w  d1,d3                     ; UnOptimized Version
                addq.w  #1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx2a:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                jsr     (a0)
                addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx2a
                move.w  d7,d1
                lea     80*2(a1),a1
                addq.w  #1,d2
                cmp.w   d6,d2
                ble.s   loopy2a
                bra.s   Start_Clear2


DoOPT2:
loopy2b:        move.w  d1,d3                     ; Optimized Version
                addq.w  #1,d3
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx2b:        move.b  (a2)+,d0
                move.b  (a2)+,d3
                cmp.b   -4(a2),d0
                bne.s   dohim2
                cmp.b   -3(a2),d3
                beq.s   skiphim2
dohim2:         jsr     (a0)
skiphim2:       addq.w  #1,d1
                cmp.w   d5,d1
                ble.s   loopx2b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy2b



Start_Clear2:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d2,d0
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts

                ENDPART
ScrollRight:    >PART 'Scroll Area Rightwards'
                move.w  d4,-(a7)
                move.w  A_Scroll_R_Rout(pc),d4
                jsr     0(a5,d4.w)
                move.w  (a7)+,d4
                rts

ScrR_all:                                         ; General Scroll Right
* D0=X1   D1=Y1   D2=X2   d3=Y2
                movem.l d0-a2,-(a7)
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a0
                exg     d0,d2

                cmp.w   d0,d2                     ; = Only Emptiness
                beq.s   Start_Clear3

                move.w  d3,d6
                move.w  d2,d5
                move.w  d1,d2
                move.w  d0,d1
                move.w  d0,d7

                addq.w  #1,d5                     ; Skip Emptiness Area

                move.w  d2,d3
                mulu    #80*2,d3
                movea.l Char_Screen(pc),a1
                adda.w  d3,a1

                tst.w   OPT_Flag-s(a5)
                beq.s   DoOPT3

loopy3a:        move.w  d1,d3                     ; UnOptimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx3a:        move.b  -(a2),d3
                move.b  -(a2),d0
                jsr     (a0)
                subq.w  #1,d1
                cmp.w   d5,d1
                bge.s   loopx3a
                move.w  d7,d1
                lea     80*2(a1),a1
                addq.w  #1,d2
                cmp.w   d6,d2
                ble.s   loopy3a
                bra.s   Start_Clear3


DoOPT3:
loopy3b:        move.w  d1,d3                     ; Optimized Version
                add.w   d3,d3
                lea     0(a1,d3.w),a2
loopx3b:        move.b  -(a2),d3
                move.b  -(a2),d0
                cmp.b   2(a2),d0
                bne.s   dohim3
                cmp.b   3(a2),d3
                beq.s   skiphim3
dohim3:         jsr     (a0)
skiphim3:       subq.w  #1,d1
                cmp.w   d5,d1
                bge.s   loopx3b
                move.w  d7,d1
                addq.w  #1,d2
                lea     80*2(a1),a1
                cmp.w   d6,d2
                ble.s   loopy3b



Start_Clear3:   movem.l (a7),d0-a2                ; Clear Emptiness
                moveq   #32,d6
                move.w  d0,d2
                move.b  Look_Byte(pc),d7
                bsr     Fill_Area
                movem.l (a7)+,d0-a2
                rts


* D0=X1   D1=Y1   D2=X2   d3=Y2

                movem.l d0-d5/a0-a1,-(a7)
                movea.l Char_Screen(pc),a0
                move.w  A_Print_Rout(pc),d4
                lea     0(a5,d4.w),a1
                exg     d0,d2
                move.w  d3,d4
                move.w  d2,d3
                move.w  d1,d2
                move.w  d0,d1


copyloop8:      moveq   #0,d5
                cmp.w   d1,d3
                bne.s   copyloop9
                moveq   #-1,d5

copyloop9:      movem.l d0/d3-d4,-(a7)

                move.w  d1,d3
                move.w  d2,d4
                subq.w  #1,d3
                add.w   d3,d3
                mulu    #80*2,d4
                add.w   d3,d4
                move.b  0(a0,d4.w),d0
                move.b  1(a0,d4.w),d3
                ext.w   d0
                ext.w   d3
                tst.w   d5
                beq.s   goahead4
                moveq   #32,d0
                move.b  Look_Byte(pc),d3
goahead4:       jsr     (a1)
                movem.l (a7)+,d0/d3-d4

                subq.w  #1,d1
                cmp.w   d3,d1
                bge.s   copyloop8
                move.w  d0,d1
                addq.w  #1,d2
                cmp.w   d4,d2
                ble.s   copyloop8

                movem.l (a7)+,d0-d5/a0-a1
                rts

                ENDPART

P_CursUp:       >PART 'Move Cursor Up'
                move.w  Y(pc),d0
                cmp.w   Ymin(pc),d0
                ble.s   go1
                subq.w  #1,Y-s(a5)
go1:            rts
                ENDPART
P_CursDown:     >PART 'Move Cursor Down'
                move.w  Y(pc),d0
                cmp.w   Ymax(pc),d0
                bge.s   go2
                addq.w  #1,Y-s(a5)
go2:            rts
                ENDPART
P_CursLeft:     >PART 'Move Cursor Left'
                move.w  X(pc),d0
                cmp.w   Xmin(pc),d0
                ble.s   go3
                subq.w  #1,X-s(a5)
go3:            rts
                ENDPART
P_CursRight:    >PART 'Move Cursor Right'
                move.w  X(pc),d0
                cmp.w   Xmax(pc),d0
                bge.s   go4
                addq.w  #1,X-s(a5)
go4:            rts
                ENDPART
P_CursUpScroll: >PART 'Move Cursor Up,Scroll if top'
                move.w  Y(pc),d0
                cmp.w   Ymin(pc),d0
                ble.s   go5
                subq.w  #1,Y-s(a5)
                rts
go5:
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                bsr     ScrollDown
                rts
                ENDPART
P_ClrHome:      >PART 'Clear Home'
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                moveq   #32,d6
                move.b  Look_Byte(pc),d7
                move.w  OPT_Flag(pc),-(a7)
                move.w  #-1,OPT_Flag-s(a5)
                bsr     Fill_Area
                move.w  (a7)+,OPT_Flag-s(a5)
                move.w  Xmin(pc),X-s(a5)
                move.w  Ymin(pc),Y-s(a5)
                rts
                ENDPART
P_Home:         >PART 'Cursor Home'
                move.w  Xmin(pc),X-s(a5)
                move.w  Ymin(pc),Y-s(a5)
                rts
                ENDPART
P_SetArea:      >PART 'Set Text Area and Home Cursor'
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                move.b  (a0)+,d2
                move.b  (a0)+,d3
                cmp.b   d0,d2
                blo.s   Forget_It
                cmp.b   d1,d3
                blo.s   Forget_It
                ext.w   d0
                bmi.s   Forget_It
                ext.w   d1
                bmi.s   Forget_It
                ext.w   d2
                ext.w   d3
                cmp.w   #Xsize-1,d2
                bhi.s   Forget_It
                cmp.w   #Ysize-1,d3
                bhi.s   Forget_It

                move.w  d0,X-s(a5)
                move.w  d1,Y-s(a5)
                move.w  d0,Xmin-s(a5)
                move.w  d1,Ymin-s(a5)
                move.w  d2,Xmax-s(a5)
                move.w  d3,Ymax-s(a5)
Forget_It:      rts
                ENDPART
P_OverFlow_On:  >PART 'Turn OverFlow detection on'
                clr.w   OverFlow-s(a5)
                rts
                ENDPART
P_OverFlow_Off: >PART 'Turn OverFlow detection off'
                move.w  #-1,OverFlow-s(a5)
                rts
                ENDPART
P_Reverse_On:   >PART 'Turn Reverse On'
                bset    #4,Look_Byte-s(a5)
                rts
                ENDPART
P_Reverse_Off:  >PART 'Turn Reverse Off'
                bclr    #4,Look_Byte-s(a5)
                rts
                ENDPART
P_Mask_On:      >PART 'Turn Mask On'
                bset    #5,Look_Byte-s(a5)
                rts
                ENDPART
P_Mask_Off:     >PART 'Turn Mask Off'
                bclr    #5,Look_Byte-s(a5)
                rts
                ENDPART
P_Color:        >PART 'Set Normal Color'
                move.b  (a0)+,d0
                and.b   #$0F,d0
                andi.b  #$F0,Look_Byte-s(a5)
                or.b    d0,Look_Byte-s(a5)
                rts
                ENDPART
P_Place_Curs_O: >PART 'Place Cursor, Old method.'
                move.b  (a0)+,d0
                ext.w   d0
                sub.w   #32,d0
                move.w  d0,Y-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                sub.w   #32,d0
                move.w  d0,X-s(a5)
                rts
                ENDPART
P_Place_Curs_F: >PART 'Place Cursor, Full Cordinates.'
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,X-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Place_Curs_W: >PART 'Place Cursor, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Xmin(pc),d0
                move.w  d0,X-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Ymin(pc),d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Place_Curs_X: >PART 'Place Cursor X, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Xmin(pc),d0
                move.w  d0,X-s(a5)
                rts
                ENDPART
P_Place_Curs_Y: >PART 'Place Cursor Y, Window Cord.'
                move.b  (a0)+,d0
                ext.w   d0
                add.w   Ymin(pc),d0
                move.w  d0,Y-s(a5)
                rts
                ENDPART
P_Scroll:       >PART 'Scroll Screen'
                move.b  (a0)+,d4
                move.w  Xmin(pc),d0
                move.w  Ymin(pc),d1
                move.w  Xmax(pc),d2
                move.w  Ymax(pc),d3
                cmp.b   #0,d4
                bne.s   nou
                bsr     ScrollUp
                bra.s   nor
nou:            cmp.b   #1,d4
                bne.s   nod
                bsr     ScrollDown
                bra.s   nor
nod:            cmp.b   #2,d4
                bne.s   nol
                bsr     ScrollLeft
                bra.s   nor
nol:            cmp.b   #3,d4
                bne.s   nor
                bsr     ScrollRight
nor:            rts
                ENDPART
P_SaveData:     >PART 'Save Position and so on..'
                move.b  (a0)+,d0
                cmp.b   #15,d0
                bhi.s   now1
                ext.w   d0
                mulu    #SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     SavePos
now1:           rts
                ENDPART
P_RestoreData:  >PART 'Restore Position and so on..'
                move.b  (a0)+,d0
                cmp.b   #15,d0
                bhi.s   now2
                ext.w   d0
                mulu    #SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     RestorePos
now2:           rts
                ENDPART
P_VTSave:       >PART 'Save as old VT52 pos'
                move.w  #16*SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     SavePos
                rts
                ENDPART
P_VTRestore:    >PART 'Restore as old VT52 pos'
                move.w  #16*SizeOfSavePos,d0
                movea.l Save_Pos_Mem(pc),a0
                adda.w  d0,a0
                bsr     RestorePos
                rts
                ENDPART
P_DrawBox:      >PART 'Draw a box at window'

                move.b  (a0)+,d0
                ext.w   d0
                lea     CharTab(pc),a1
                mulu    #12,d0
                adda.w  d0,a1
                move.w  A_Print_Rout(pc),d1
                lea     0(a5,d1.w),a0
                move.b  Look_Byte(pc),d3

                move.b  3(a1),d0
                move.w  Xmin(pc),d1
                move.w  Ymin(pc),d2
                jsr     (a0)
                move.b  5(a1),d0
                move.w  Xmax(pc),d1
                move.w  Ymin(pc),d2
                jsr     (a0)
                move.b  9(a1),d0
                move.w  Xmin(pc),d1
                move.w  Ymax(pc),d2
                jsr     (a0)
                move.b  11(a1),d0
                move.w  Xmax(pc),d1
                move.w  Ymax(pc),d2
                jsr     (a0)

                move.b  2(a1),d0
                move.w  Xmin(pc),d4
                addq.w  #1,d4
                move.w  Xmax(pc),d5
drawline1:      cmp.w   d4,d5                     ; Draw Top/Bottom
                beq.s   linedrawn1
                move.w  d4,d1
                move.w  Ymax(pc),d2
                jsr     (a0)
                move.w  Ymin(pc),d2
                jsr     (a0)
                addq.w  #1,d4
                bra.s   drawline1
linedrawn1:     move.b  1(a1),d0                  ; Draw Left/right
                move.w  Ymin(pc),d4
                addq.w  #1,d4
                move.w  Ymax(pc),d5
drawline2:      cmp.w   d4,d5
                beq.s   linedrawn2
                move.w  d4,d2
                move.w  Xmax(pc),d1
                jsr     (a0)
                move.w  Xmin(pc),d1
                jsr     (a0)
                addq.w  #1,d4
                bra.s   drawline2
linedrawn2:
                rts

                ENDPART
P_OPTon:        >PART 'Turn OPT flag on'
                clr.w   OPT_Flag-s(a5)
                rts
                ENDPART
P_OPToff:       >PART 'Turn OPT flag off'
                move.w  #-1,OPT_Flag-s(a5)
                rts
                ENDPART
P_SP_Save:      >PART 'Save as pos on "stack"'
                movea.l Save_Pos_Pek(pc),a0
                cmpa.l  Save_Pos_Hi(pc),a0
                beq.s   nostackleft
                addq.l  #SizeOfSavePos,Save_Pos_Pek-s(a5)
                bsr.s   SavePos
nostackleft:    rts
                ENDPART
P_SP_Restore:   >PART 'Restore pos from "stack"'
                movea.l Save_Pos_Pek(pc),a0
                cmpa.l  Save_Pos_Low(pc),a0
                beq.s   noneonstack
                subq.l  #SizeOfSavePos,Save_Pos_Pek-s(a5)
                movea.l Save_Pos_Pek(pc),a0
                bsr.s   RestorePos
noneonstack:    rts
                ENDPART

                >PART 'sub Rutines for pos saving'
* a0=address to buf
SavePos:        move.b  X+1(pc),(a0)+
                move.b  Y+1(pc),(a0)+
                move.b  Xmin+1(pc),(a0)+
                move.b  Ymin+1(pc),(a0)+
                move.b  Xmax+1(pc),(a0)+
                move.b  Ymax+1(pc),(a0)+
                move.b  OverFlow+1(pc),(a0)+
                move.b  Look_Byte(pc),(a0)+
                rts
RestorePos:     move.b  (a0)+,X+1-s(a5)
                move.b  (a0)+,Y+1-s(a5)
                move.b  (a0)+,Xmin+1-s(a5)
                move.b  (a0)+,Ymin+1-s(a5)
                move.b  (a0)+,Xmax+1-s(a5)
                move.b  (a0)+,Ymax+1-s(a5)
                move.b  (a0)+,d0
                ext.w   d0
                move.w  d0,OverFlow-s(a5)
                move.b  (a0)+,Look_Byte-s(a5)
                rts
                ENDPART


**********************************************************
Con_Print_Line: >PART 'Print a string'
                movea.l (a6)+,a0
                bsr     String_Print
                move.l  d0,Return-s(a5)
                rts
                ENDPART
Con_Print_Char: >PART 'Print One Byte'
                move.w  (a6)+,d0
                bsr     Do_Char
                rts
                ENDPART
Con_Update:     >PART 'Update a part of the screen'
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                bsr     Update_Area
                rts
                ENDPART
Con_GetDataTab: >PART 'Get address to Print data tab'
                lea     PrintDataTab(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Con_GetValue:   >PART 'Get ASCII and Attrib'
* out 8-15 ASCII 0-7 Attrib
                move.w  Y(pc),d0
                mulu    #Xsize,d0
                add.w   X(pc),d0
                add.w   d0,d0
                movea.l Char_Screen(pc),a0
                moveq   #0,d1
                move.w  0(a0,d0.w),d1
                move.l  d1,Return-s(a5)
                rts
                ENDPART
Con_SetValue:   >PART 'Set ACII and Attrib'
* 1.w AscII & Attrib
                move.b  (a6)+,d0
                move.b  (a6)+,d3
                move.w  X(pc),d1
                move.w  Y(pc),d2
                move.w  A_Print_Rout(pc),d4
                jsr     0(a5,d4.w)
                rts
                ENDPART

**********************************************************
Bar_SetPos:     >PART 'Set Bar Selector pos'
* 1.w NewPos

                move.w  (a6)+,d7
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                bsr.s   Draw_Selector
                move.w  d7,12(a6)
                bsr.s   Draw_Selector

                clr.l   Return-s(a5)

                rts

Draw_Selector:  movem.l d0-a6,-(a7)
                tst.w   12(a6)
                bmi     not_draw
                movea.l 4(a6),a0
                moveq   #0,d6
                moveq   #0,d7

s1:             bsr     Skip_Esc
                beq.s   s1
                cmpi.b  #'{',(a0)
                beq.s   s2
                bsr     Skip_Control
                beq.s   s1
                addq.w  #1,d7
                addq.w  #1,a0
                bra.s   s1
s2:             addq.w  #1,a0
                cmp.w   12(a6),d6
                beq.s   s3
                addq.w  #1,d6
                bra.s   s1

s3:             add.w   (a6),d7
                move.w  2(a6),d6
                move.w  18(a6),d0
                and.w   #$0F,d0
                cmp.w   #$0F,d0
                beq.s   skippp
                addq.w  #1,d6
skippp:         movea.l Char_Screen(pc),a1
                movea.l a5,a2
                adda.w  A_Print_Rout(pc),a2
                move.w  d6,d0
                mulu    #Xsize*2,d0
                add.w   d7,d0
                add.w   d7,d0
                adda.w  d0,a1
                moveq   #0,d0

s4:             bsr     Skip_Esc
                beq.s   s4
                cmpi.b  #'}',(a0)
                beq.s   s5
                bsr     Skip_Control
                beq.s   s4

                addq.w  #1,a0
                move.b  (a1)+,d0
                move.w  d7,d1
                move.w  d6,d2

                move.b  (a1)+,d3
                bchg    #4,d3
                addq.w  #1,d7
                jsr     (a2)
                bra.s   s4
s5:


not_draw:       movem.l (a7)+,d0-a6
                rts

                ENDPART
Bar_Update:     >PART 'Update Bar, and send key'
* 1.L  Tos Key

                move.w  (a6)+,d0
                move.b  d0,d5
                swap    d0
                move.b  d0,d6

                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                move.w  12(a6),d7
                bsr     Scan_String

                tst.b   14(a6)                    ; left
                bne.s   scan1
                cmp.b   15(a6),d5
                bne.s   notleft
                bra.s   doleft
scan1:          cmp.b   15(a6),d6
                bne.s   notleft
doleft:         move.w  d2,d7
                bra.s   leftdone

notleft:        tst.b   16(a6)                    ; Right
                bne.s   scan2
                cmp.b   17(a6),d5
                bne.s   leftdone
                bra.s   doright
scan2:          cmp.b   17(a6),d6
                bne.s   leftdone
doright:        move.w  d3,d7
leftdone:
                cmp.w   12(a6),d7
                beq.s   nochg

                move.w  d7,-(a7)
                movea.l a7,a6
                bsr     Bar_SetPos
                addq.l  #2,a7

nochg:
                move.w  12(a6),d0                 ; Return POS
                ext.l   d0
                move.l  d0,Return-s(a5)



                rts

                ENDPART
Bar_Redraw:     >PART 'Draw Bar on Screen'
* 1.w Mode
                move.w  (a6)+,d7
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6

                tst.w   d7
                bne.s   w1
                move.w  18(a6),d2
w1:             cmp.w   #1,d7
                bne.s   w2
                move.w  20(a6),d2
w2:             cmp.w   #2,d7
                bne.s   w3
                move.w  F_Sel_Mode(pc),d2
w3:             cmp.w   #3,d7
                bne.s   w4
                move.w  F_UnSel_Mode(pc),d2
w4:
                bsr.s   Bar_Draw

                move.w  12(a6),-(a7)
                move.w  #-1,12(a6)
                movea.l a7,a6
                bsr     Bar_SetPos
                addq.l  #2,a7

                move.w  12(a6),d0                 ; Return POS
                ext.l   d0
                move.l  d0,Return-s(a5)

                rts


Bar_Draw:
* d2=F_Sel/UnSel
* a6=address to bar tab
                movem.l d0-a6,-(a7)

                lea     FullScreen(pc),a0         ; Save settings and 80x50
                bsr     String_Print
                moveq   #27,d0                    ; Place Cursor
                bsr     Do_Char
                moveq   #'Z',d0                   ; Place Cursor
                bsr     Do_Char
                move.w  (a6),d0
                bsr     Do_Char
                move.w  2(a6),d0
                bsr     Do_Char

                lea     CharTab(pc),a4
                move.w  d2,d7
                and.w   #$0F,d7
                move.w  d7,d6
                mulu    #12,d6
                adda.w  d6,a4
                and.w   #$FF00,d2
                lsr.w   #8,d2
                move.b  d2,Look_Byte-s(a5)

                cmp.b   #$0F,d7
                beq     draw_bartext

                moveq   #10,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #")",d0
                bsr     Do_Char

                movea.l 4(a6),a0                  ; Get String
wd5:            bsr     Do_Esc
                beq.s   wd5
                bsr     Skip_Control
                beq.s   wd5
                move.b  (a0)+,d0
                beq.s   wd1
                move.b  2(a4),d2
                move.b  2(a4),d1
                cmp.b   #'[',d0
                bne.s   wd2
                move.b  3(a4),d2
                move.b  9(a4),d1
wd2:            cmp.b   #']',d0
                bne.s   wd3
                move.b  5(a4),d2
                move.b  11(a4),d1
wd3:            cmp.b   #':',d0
                bne.s   wd4
                move.b  4(a4),d2
                move.b  10(a4),d1
wd4:
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"A",d0
                bsr     Do_Char
                move.w  d2,d0
                bsr     Do_Char
                moveq   #10,d0
                bsr     Do_Char
                moveq   #10,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"D",d0
                bsr     Do_Char
                move.w  d1,d0
                bsr     Do_Char
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"A",d0
                bsr     Do_Char

                bra.s   wd5
wd1:
                moveq   #27,d0
                bsr     Do_Char
                moveq   #"(",d0
                bsr     Do_Char


draw_bartext:   movea.l 4(a6),a0                  ; Get String
drawnext:       bsr     Do_Esc
                beq.s   drawnext
                bsr     Skip_Control
                beq.s   drawnext
                bsr     Skip_Linefix
                beq.s   specchar

                move.b  (a0)+,d0
                tst.b   d0
                beq.s   alldrawn
                bsr     Do_Char
                bra.s   drawnext
specchar:       move.b  1(a4),d0
                bsr     Do_Char
                bra.s   drawnext
alldrawn:

                lea     NormalScreen(pc),a0       ; Restore settings
                bsr     String_Print

                movem.l (a7)+,d0-a6
                rts



                ENDPART
Bar_Open:       >PART 'Open a bar'
* 1.L Adddress
* 1.W X
* 1.W Y
                move.l  a6,-(a7)                  ; Unmark last bar
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq.s   FirstOne
                move.w  #1,-(a7)
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
FirstOne:       movea.l (a7)+,a6

                move.w  (a6)+,d1
                move.w  (a6)+,d0
                movea.l (a6)+,a0
                movem.l d0/a0,-(a7)
                move.l  #22,d0
                bsr     Reserve_Mem
                movea.l a0,a6
                movem.l (a7)+,d0/a0
                cmpa.l  #0,a6
                beq     Error

                move.w  d0,(a6)
                move.w  d1,2(a6)
                move.l  a0,4(a6)

                movem.l d2-d4,-(a7)
                move.l  d0,-(a7)
                bsr     GetLenght
                add.w   (a6),d0
                subq.w  #1,d0
                move.w  d0,d2
                move.l  (a7)+,d0
                move.w  d1,d3
                move.w  F_Sel_Mode(pc),d4
                and.w   #$0F,d4
                cmp.w   #$0F,d4
                beq.s   No_Box_Man
                addq.w  #2,d3
No_Box_Man:
                bsr     Save_Area
                movem.l (a7)+,d2-d4

                move.l  a0,8(a6)
                move.w  #0,12(a6)
                move.w  #$FF4B,14(a6)
                move.w  #$FF4D,16(a6)
                move.w  F_Sel_Mode(pc),18(a6)
                move.w  F_UnSel_Mode(pc),20(a6)

                movea.l Bar_Pointer(pc),a1
                move.l  a6,(a1)+
                move.l  a1,Bar_Pointer-s(a5)

                move.w  #0,-(a7)                  ; ReDraw, Selected
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
                rts


                ENDPART
Bar_Close:      >PART 'Close Bar'
                movea.l Bar_Pointer(pc),a6
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq     Error
                movea.l -4(a6),a6
                subq.l  #4,Bar_Pointer-s(a5)
                movea.l 8(a6),a0
                cmpa.l  #-1,a0
                beq.s   No_Area
                bsr     Rest_Area
No_Area:
                movea.l a6,a0
                bsr     Free_Mem

                movea.l Bar_Pointer(pc),a6        ; Mark
                cmpa.l  Bar_Tab_Addr(pc),a6
                beq.s   FirstOne2
                move.w  #0,-(a7)
                movea.l a7,a6
                bsr     Bar_Redraw
                addq.l  #2,a7
FirstOne2:
                rts
                ENDPART
Bar_Take_Con:   >PART 'Take Control of bar'
* 1.w Mode  0= Take the active bar
*           1= Take the active bar, close when finished
*        bit 0  1=Close
* out: Resulting Pos or -1 if error
                move.w  (a6)+,d7
keyloop:        move.w  #$70,-(a7)
                jsr     (a5)
                cmp.b   #13,d0
                beq.s   Pressed_CCR
                move.l  d0,-(a7)
                move.w  #$83,-(a7)
                bsr     Nemesis
                bra.s   keyloop
Pressed_CCR:    clr.l   -(a7)
                move.w  #$83,-(a7)
                bsr     Nemesis
                move.l  d0,d6
                btst    #0,d7
                beq.s   not_close
                move.w  #$81,-(a7)
                bsr     Nemesis
                bmi.s   felfel
not_close:      move.l  d6,Return-s(a5)
felfel:         rts
                ENDPART
                >PART 'Bar special inside routines'

******************************************************

Scan_String:
* a6=bar data
* out d0=Lowest pos
*     d1=Highest pos
*     d2=Pos to the left (warp included)
*     d3=Pos to the right (warp included)
* If no position was avaiable, the -1 on all!

                movem.l d4-a0,-(a7)
                movea.l 4(a6),a0
                moveq   #-1,d0                    ; Lowest Found
                moveq   #-1,d1                    ; Highest Found
                moveq   #-1,d2                    ; To the Left
                moveq   #-1,d3                    ; To The Right
                moveq   #0,d4                     ; 0=no ~ found,  -1 got one
                moveq   #0,d5                     ; internal counter

r1:             bsr.s   Skip_Esc
                beq.s   r1
                bsr     Skip_Linefix
                beq.s   r1
                move.b  (a0)+,d7
                beq.s   all_clear
                cmp.b   #'~',d7
                bne.s   r2
                moveq   #-1,d4
                bra.s   r1
r2:             cmp.b   #'{',d7
                bne.s   r1

                tst.w   d4
                bne.s   klammerdone
                move.w  d5,d1                     ;(Highest)
                tst.w   d0
                bpl.s   r3
                move.w  d5,d0                     ;(lowest)
r3:             cmp.w   12(a6),d5
                bhs.s   r4
                move.w  d5,d2                     ;(left)
r4:             tst.w   d3
                bpl.s   r7
                cmp.w   12(a6),d5
                bls.s   r7
                move.w  d5,d3                     ;(right)
r7:

klammerdone:    moveq   #0,d4
                addq.w  #1,d5
                bra.s   r1

all_clear:
                tst.w   d2                        ; Warp
                bpl.s   r5
                move.w  d1,d2
r5:             tst.w   d3
                bpl.s   r6
                move.w  d0,d3
r6:
                movem.l (a7)+,d4-a0
                rts


**********************************************

Skip_Esc:       cmpi.b  #27,(a0)                  ; Skips ESC comand and makes
                bne.s   noesc                     ; beq true if esc was found
                addq.l  #1,a0                     ; and bne if not found
                movem.l d0/a1,-(a7)
                move.b  (a0)+,d0
                lea     Amount_Tab(pc),a1
lookmore:       cmp.b   (a1)+,d0
                bmi.s   existnot
                beq.s   found
                addq.w  #3,d0
                bra.s   lookmore
found:          move.b  (a1)+,d0
                ext.w   d0
                adda.w  d0,a0
existnot:       movem.l (a7)+,d0/a1
                move    #4,ccr
                rts
noesc:          move    #0,ccr
                rts

**********************************************

Do_Esc:         cmpi.b  #27,(a0)                  ; Executes ESC command if any.
                bne.s   noesc2                    ; also makes BEQ true if
                move.w  d0,-(a7)                  ; ESC command was found
moreesc:        move.b  (a0)+,d0
                bsr     Do_Char
                tst.w   EscDoing-s(a5)
                bne.s   moreesc
                move.w  (a7)+,d0
                move    #4,ccr
                rts
noesc2:         move    #0,ccr
                rts

**********************************************

Skip_Linefix:   cmpi.b  #'[',(a0)                 ; If line command if found
                beq.s   LineCh                    ; it is skipped and BEQ is
                cmpi.b  #']',(a0)                 ; true
                beq.s   LineCh
                cmpi.b  #':',(a0)
                beq.s   LineCh
                move    #0,ccr
                rts
LineCh:         addq.w  #1,a0
                move    #4,ccr
                rts

**********************************************

Skip_Control:   cmpi.b  #'~',(a0)                 ; Skip Control, beq true if
                beq.s   ControlCh                 ; control found
                cmpi.b  #'@',(a0)
                beq.s   ControlCh
                cmpi.b  #'{',(a0)
                beq.s   ControlCh
                cmpi.b  #'}',(a0)
                beq.s   ControlCh
                move    #0,ccr
                rts
ControlCh:      addq.w  #1,a0
                move    #4,ccr
                rts

**********************************************

SkipConLin:     bsr.s   Skip_Control              ; Skip's both command
                beq.s   SkipConLin                ; types. Z is NOT set as
                bsr.s   Skip_Linefix              ; a result (hehe)
                beq.s   SkipConLin
                rts

GetLenght:      movem.l d1-a6,-(a7)
                movea.l 4(a6),a0
                moveq   #0,d0
Strunta:        bsr.s   Skip_Control
                beq.s   Strunta
                bsr     Skip_Esc
                beq.s   Strunta
                tst.b   (a0)+
                beq.s   EnoughStrunt
                addq.w  #1,d0
                bra.s   Strunta
EnoughStrunt:   movem.l (a7)+,d1-a6
                rts

**********************************************
                ENDPART
**********************************************************
Win_Open:       >PART 'Open a window area'
* 1.w   x1   (of work area)
* 1.w   y1
* 1.w   x2
* 1.w   y2
* 1.w   Border Attribute
* 1.w   Special flags
*       bit 0    1=Don't Clear window
*       bit 1    1=Don't Save area
                move.w  (a6)+,d5
                move.w  (a6)+,d4
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                move.l  d0,-(a7)
                move.l  #48,d0
                bsr     Reserve_Mem
                move.l  (a7)+,d0
                move.l  a0,Return-s(a5)
                movea.l a0,a4
                move.w  d0,(a4)
                move.w  d1,2(a4)
                move.w  d2,4(a4)
                move.w  d3,6(a4)
                move.l  #-1,8(a4)
                btst    #1,d5
                bne.s   .NoScrSave
                move.w  d4,d7
                and.w   #$0F,d7
                cmp.b   #$0F,d7
                beq.s   .Phuu
                subq.w  #1,d0
                subq.w  #1,d1
                addq.w  #1,d2
                addq.w  #1,d3
.Phuu:          bsr     Save_Area
                move.l  a0,8(a4)
.NoScrSave:     move.w  d4,12(a4)
                move.w  d4,14(a4)

                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     _OpenWinT(pc),a0          ; Draw lines, open window
                move.b  1(a4),2(a0)
                move.b  3(a4),3(a0)
                move.b  5(a4),4(a0)
                move.b  7(a4),5(a0)
                subq.b  #1,2(a0)
                subq.b  #1,3(a0)
                addq.b  #1,4(a0)
                addq.b  #1,5(a0)
                move.b  1(a4),11(a0)
                move.b  3(a4),12(a0)
                move.b  5(a4),13(a0)
                move.b  7(a4),14(a0)
                move.w  14(a4),d0
                and.w   #$0F,d0
                cmp.w   #$0F,d0
                bne.s   .BorderYes
                lea     9(a0),a0                  ; Skip Border text
.BorderYes:     move.b  d0,8(a0)
                bsr     String_Print

                btst    #0,d5                     ; Clear window?
                beq.s   .NotClear
                moveq   #27,d0
                bsr     Do_Char
                moveq   #'E',d0
                bsr     Do_Char
.NotClear:
                lea     16(a4),a0                 ; Save con data (win)
                bsr     SavePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char

                rts
                ENDPART
Win_Close:      >PART 'Close a opened window'
* 1.l Address to window tab
                movea.l (a6)+,a4
                movea.l 8(a4),a0
                bsr     Rest_Area
                movea.l a4,a0
                bsr     Free_Mem
                rts

                ENDPART
Win_ChgBorder:  >PART 'Change border of window'
                ENDPART
Win_Print:      >PART 'Print String in window'
* 1.l Address to window tab
* 1.l Address to string to print
                movea.l (a6)+,a3
                movea.l (a6)+,a4
                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     RestorePos

                movea.l a3,a0
                bsr     String_Print


                lea     16(a4),a0
                bsr     RestorePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char
                rts

                ENDPART
Win_PrintChar:  >PART 'Print String in window'
* 1.l Address to window tab
* 1.w Char to print
                move.w  (a6)+,d7
                movea.l (a6)+,a4
                moveq   #27,d0
                bsr     Do_Char
                moveq   #')',d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     RestorePos

                move.w  d7,d0
                bsr     Do_Char

                lea     16(a4),a0
                bsr     RestorePos

                moveq   #27,d0
                bsr     Do_Char
                moveq   #'(',d0
                bsr     Do_Char
                rts

                ENDPART
                >PART 'Window Routs'
_OpenWinT:      DC.B 27,"a",0,0,0,0               ; 2,3,4,5
                DC.B 27,"#",0                     ; 8
                DC.B 27,"a",0,0,0,0               ; 11,12,13,14
                DC.B 0
                EVEN
                ENDPART
                >PART 'Tab doc'
*                DS.W 1                            ; 0  X1 Pos (of work area)
*                DS.W 1                            ; 2  Y1 Pos (of work area)
*                DS.W 1                            ; 4  X2 Pos (of work area)
*                DS.W 1                            ; 6  X3 Pos (of work area)
*                DS.L 1                            ; 8  address to save area buf
*                DS.W 1                            ; 12  Open Attribute (only on border)
*                DS.W 1                            ; 14  Current Attribute (only on border)
*                DS.B 32                           ; 16  Windows work term data
* 48
*
                ENDPART
**********************************************************
Gen_Set_Sel:    >PART 'Set Select Flags'
* 1.W new select mode
* ret:
                move.w  (a6)+,F_Sel_Mode-s(a5)
                rts
                ENDPART
Gen_Get_Sel:    >PART 'Get Select Flags'
* ret: select mode
                move.w  F_Sel_Mode(pc),Return-s+2(a5)
                rts
                ENDPART
Gen_Set_UnSel:  >PART 'Set UnSelect Flags'
* 1.W new select mode
* ret:
                move.w  (a6)+,F_UnSel_Mode-s(a5)
                rts
                ENDPART
Gen_Get_UnSel:  >PART 'Get UnSelect Flags'
* ret: select mode
                move.w  F_UnSel_Mode(pc),Return-s+2(a5)
                rts
                ENDPART
Gen_Get_FontP:  >PART 'Get Address To Font Pointer'
* ret: Address to font
                lea     Font_Point(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Gen_Set_Mask:   >PART 'Set Mask Data'
* 1.L address to new mask (16 words)
* ret:
                movea.l (a6)+,a0
                lea     Mask(pc),a1
                move.w  #15,d0
copy_mask:      move.w  (a0)+,(a1)+
                dbra    d0,copy_mask
                rts
                ENDPART
Gen_Get_Mask:   >PART 'Get Address To Mask'
* ret:  Address to Mask
                lea     Mask(pc),a0
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Gen_Get_Screen: >PART 'Get Address to Char Screen'
* out   Address to Character Screen
                move.l  Char_Screen(pc),Return-s(a5)
                rts
                ENDPART
Gen_Set_Screen: >PART 'Set Char Screen Address'
* 1.l  Char Screen Address to use
                move.l  (a6)+,Char_Screen-s(a5)
                rts
                ENDPART
Gen_Open_Work:  >PART 'Open WorkStation'
* out:  -1=Not enough memory
                move.l  #Xsize*Ysize*2,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Char_Screen-s(a5)
                move.l  #64*4,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Bar_Tab_Addr-s(a5)
                move.l  a0,Bar_Pointer-s(a5)

                move.l  #(17+StackSavePos)*SizeOfSavePos,d0
                bsr     Reserve_Mem
                ble     Error
                move.l  a0,Save_Pos_Mem-s(a5)
                lea     17*SizeOfSavePos(a0),a0
                move.l  a0,Save_Pos_Pek-s(a5)
                move.l  a0,Save_Pos_Low-s(a5)
                lea     StackSavePos*SizeOfSavePos(a0),a0
                move.l  a0,Save_Pos_Hi-s(a5)
                rts
                ENDPART
Gen_Close_Work: >PART 'Close WorkStation'
* out:  -1=Error
                movea.l Char_Screen(pc),a0
                bsr     Free_Mem
                bmi     Error

                movea.l Bar_Tab_Addr(pc),a0
                bsr.s   Free_Mem
                bmi     Error

                movea.l Save_Pos_Mem(pc),a0
                bsr.s   Free_Mem
                bmi     Error

                rts
                ENDPART

Gen_Set_Graph:  >PART 'Set Graphics Resolution'
* 1.W New graphmode
* ret: old mode
                move.w  F_Graph_Mode(pc),Return-s+2(a5)
                move.w  (a6)+,F_Graph_Mode-s(a5)
                rts
                ENDPART
Gen_Set_Memory: >PART 'Set Free Memory Address'
* 1.L  End Of memory if not using Malloc
* 1.L  Memory address, -1 for Malloc
* ret: old memory address
                move.l  Memory_Base(pc),Return-s(a5)
                move.l  (a7)+,Memory_End-s(a5)
                move.l  (a7)+,Memory_Base-s(a5)
                rts
                ENDPART
**********************************************************
Any_Rese_Mem:   >PART 'Reserve Memory'
* 1.l Amount
* out: Address to saved area, or null if error
                move.l  (a6)+,d0
                bsr.s   Reserve_Mem
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Free_Mem:   >PART 'Release Memory'
* 1.l Address to Saved area to be released
* out: Null if OK, negative if error
                movea.l (a6)+,a0
                bsr.s   Free_Mem
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Save_Blk:   >PART 'Save a part of the screen'
* 1.w x1
* 1.w y1
* 1.w x2
* 1.w y2
* out: Address to Block
                move.w  (a6)+,d3
                move.w  (a6)+,d2
                move.w  (a6)+,d1
                move.w  (a6)+,d0
                bsr.s   Save_Area
                move.l  a0,Return-s(a5)
                rts
                ENDPART
Any_Rest_Blk:   >PART 'Restore a saved block'
* 1.l address to saved block
* out : negative if error
                movea.l (a6)+,a0
                bsr.s   Rest_Area
                rts
                ENDPART
**********************************************************
Key_Conin:      >PART 'Wait for key'
* no input
* out:  key as Gemdos
                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7
                move.l  d0,Return-s(a5)
                rts
                ENDPART
**********************************************************
Reserve_Mem:    >PART 'Reserve Memory'
* d0=amout to be reserved
* out: A0=address
* SR   BLE will be true if there was no memory..
                movem.l d1-d7/a1-a6,-(a7)
                move.l  d0,-(a7)
                move.w  #$48,-(a7)
                trap    #1
                addq.l  #6,a7
                movea.l d0,a0
                movem.l (a7)+,d1-d7/a1-a6
                tst.l   d0
                rts
                ENDPART
Free_Mem:       >PART 'Free Memory'
* A0= address to free
* out: D0=0 if ok, otherwise -1
*      beq will be true if no error.
*      bne will be true if error.
                movem.l d1-a6,-(a7)
                move.l  a0,-(a7)
                move.w  #$49,-(a7)
                trap    #1
                addq.l  #6,a7
                movem.l (a7)+,d1-a6
                tst.w   d0
                rts
                ENDPART
Save_Area:      >PART 'Save a part of the screen'
* d0=x1
* d1=y1
* d2=x2
* d3=y2
* out a0=address, -1 if error
                movem.w d4,-(a7)
                move.w  Save_Area_Char(pc),d4
                lea     0(a5,d4.w),a0
                jsr     (a0)
                movem.w (a7)+,d4
                rts
                ENDPART
Rest_Area:      >PART 'Restore a saved area'
* a0=address to block
                cmpa.l  #-1,a0
                beq.s   .Fools
                movem.l d0/a0-a1,-(a7)
                move.w  10(a0),d0
                lea     0(a5,d0.w),a1
                jsr     (a1)
                movem.l (a7)+,d0/a0-a1
.Fools:         rts
                ENDPART
Save_Area_C1:   >PART 'Save Char, Standard'
* d0=x1
* d1=y1
* d2=x2
* d3=y2
* out:  a0=address, -1 if there wasn't enough memory
                movem.l d0-d7/a1-a6,-(a7)
                movem.w d0-d3,-(a7)
                movem.w (a7)+,d4-d7

                move.w  d6,d0
                sub.w   d4,d0
                addq.w  #1,d0
                move.w  d7,d1
                sub.w   d5,d1
                addq.w  #1,d1
                mulu    d1,d0
                add.l   d0,d0
                add.l   #16,d0
                bsr     Reserve_Mem
                movea.l a0,a6
                ble.s   couldnt1
                move.w  d4,(a0)+
                move.w  d5,(a0)+
                move.w  d6,(a0)+
                move.w  d7,(a0)+
                move.w  F_Graph_Mode(pc),(a0)+
                move.w  Rest_Area_Char(pc),(a0)+
                clr.l   (a0)+

                movea.l Char_Screen(pc),a1
                move.w  d4,d0
                add.w   d0,d0
                adda.w  d0,a1
                move.w  d5,d0
                mulu    #Xsize*2,d0
                adda.w  d0,a1

                sub.w   d5,d7
                sub.w   d4,d6
loopy:          movea.l a1,a2
                lea     80*2(a1),a1
                move.w  d6,d4
loopx:          move.w  (a2)+,(a0)+
                dbra    d4,loopx
                dbra    d7,loopy
                movea.l a6,a0
sluta_nu:       movem.l (a7)+,d0-d7/a1-a6
                rts
couldnt1:       lea     -1.w,a0
                bra.s   sluta_nu
                ENDPART
Rest_Area_C1:   >PART 'Restore Chars, Standard'
* A0=address to saved block
                movem.l d0-a6,-(a7)
                movea.l a0,a4
                move.w  (a0)+,d4
                move.w  (a0)+,d5
                move.w  (a0)+,d6
                move.w  (a0)+,d7
                addq.l  #8,a0

                movea.l Char_Screen(pc),a1
                move.w  d4,d0
                add.w   d0,d0
                adda.w  d0,a1
                move.w  d5,d0
                mulu    #Xsize*2,d0
                adda.w  d0,a1

                sub.w   d5,d7
                sub.w   d4,d6
loopy2:         movea.l a1,a2
                lea     80*2(a1),a1
                move.w  d6,d4
loopx2:
                move.w  (a0)+,(a2)+
                dbra    d4,loopx2
                dbra    d7,loopy2

                movea.l a4,a0
                move.w  (a4)+,d0
                move.w  (a4)+,d1
                move.w  (a4)+,d2
                move.w  (a4)+,d3
                bsr     Update_Area

                bsr     Free_Mem

                movem.l (a7)+,d0-a6
                rts

                ENDPART

Error:          move.l  #-1,Return-s(a5)
                rts

FullScreen:     DC.B 27,")",27,"a",0,0,Xsize-1,Ysize-1,0
NormalScreen:   DC.B 27,"(",0
                EVEN

* data:    0-3  Color
*          4    On=Inverse Off=Not Inverse
*          5    On=Masked  Off=Not Masked
*          6-7  Background color
Save_Pos_Mem:   DS.L 1
Save_Pos_Pek:   DS.L 1
Save_Pos_Hi:    DS.L 1
Save_Pos_Low:   DS.L 1

Bar_Tab_Addr:   DS.L 1
Bar_Pointer:    DS.L 1                            ; Bar's works like a stack, here's the pointer

F_Save_Scr:     DC.W 0


F_Sel_Mode:     DC.W $1000
* 0-4    Line type to use on box
* 8-15   Look Byte
F_UnSel_Mode:   DC.W $3001
* 0-4    Line type to use on box
* 8-15   Look Byte

F_Graph_Mode:   DC.W -1
* -1 = Take Xbios(4)
* 0  = Force Low Resolution
* 2  = Force Medium Resolution
* 3  = Force High Resolution

Memory_End:     DC.L -1                           ; If not using Malloc
Memory_Base:    DC.L -1
Font_Point:     DS.L 1
* -1 = Use Malloc
* n  = Address to start of free memory base

*************
**** Pointers
*************
Save_Area_Char: DC.W Save_Area_C1-s
Save_Area_Img:  DC.W Save_Area_C1-s
Rest_Area_Char: DC.W Rest_Area_C1-s
Rest_Area_Img:  DC.W Rest_Area_C1-s


                >PART 'Mask and CharTabel'
CharTab:
                DC.B " ∫Õ"                        ; 0
                DC.B "…Àª"
                DC.B "ÃŒπ"
                DC.B "» º"
                DC.B " ≥ƒ"                        ; 1
                DC.B "⁄¬ø"
                DC.B "√≈¥"
                DC.B "¿¡Ÿ"
                DC.B " ∫ƒ"                        ; 2
                DC.B "÷“∑"
                DC.B "«◊∂"
                DC.B "”–Ω"
                DC.B " ≥Õ"                        ; 3
                DC.B "’—∏"
                DC.B "∆ÿµ"
                DC.B "‘œæ"
                DC.B " €€"                        ; 4
                DC.B "€€€"
                DC.B "€€€"
                DC.B "€€€"
                DC.B " ≤≤"                        ; 5
                DC.B "≤≤≤"
                DC.B "≤≤≤"
                DC.B "≤≤≤"
                DC.B " ±±"                        ; 6
                DC.B "±±±"
                DC.B "±±±"
                DC.B "±±±"
                DC.B " ∞∞"                        ; 7
                DC.B "∞∞∞"
                DC.B "∞∞∞"
                DC.B "∞∞∞"
                DC.B " ≥ƒ"                        ; 8
                DC.B "ÙÙÙ"
                DC.B "≥≈≥"
                DC.B "ııı"
                DS.B 7*12,32




Mask:           DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                DC.W %1010101010101010
                DC.W %101010101010101
                ENDPART

***********************************************************
******* END OF NEMESIS
***********************************************************
                END
