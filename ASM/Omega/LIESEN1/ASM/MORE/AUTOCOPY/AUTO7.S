                >PART 'Reserve Memory & OC & Begin'
                movea.l A7,A5           ; reserve memory and set stack
                lea     savea7(PC),A0
                move.l  A7,(A0)
                lea     stack,A7
                movea.l 4(A5),A5
                move.l  $0C(A5),D0
                add.l   $14(A5),D0
                add.l   $1C(A5),D0
                add.l   #$0100,D0
                move.l  D0,-(A7)
                move.l  A5,-(A7)
                move.w  #0,-(A7)
                move.w  #$4A,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.l   D0
                bne.s   momory

                pea     super(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                bsr     begin
                bsr     cls
menufel:        movea.l savea7(PC),A7
back:           clr.w   -(A7)
                trap    #1

**************************************
**  NOT ENOUGH MEMORY
**************************************
momory:         pea     minne(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #1,-(A7)
                trap    #1
                addq.l  #8,A7
                bra.s   back
minne:          DC.B 27,"e","NOT ENOUGH MEMORY TO RUN AUTOCOPY.PRG",13,10,0
                EVEN

***************************************
**  TEST IF OMEGA COMMANDS I AVIABLE
***************************************
super:          movea.l $98.w,A0        ; get address to omega commands
                cmpi.l  #"ILAK",2(A0)
                bne.s   nomenu
                cmpi.w  #$0104,6(A0)
                blo.s   nomenu
                move.l  #$FFFF0000,$FFFF8240.w
                clr.l   $FFFF8244.w
                rts
nomenu:         pea     nomenutext(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                move.w  #1,-(A7)
                trap    #1
                addq.l  #2,A7
                bra.s   menufel
nomenutext:     DC.B 27,"E","AUTO COPY failur!!",13,10
                DC.B "OMEGA COMMANDS 1.04 or higher version",13,10
                DC.B "is not installed in memory!!",0
                EVEN
                ENDPART

begin:          >PART 'Init'
*******************************
** BEGIN
*******************************
                moveq   #2,D0           ; det disc accsess
                trap    #6
                lea     diskaddr(PC),A1
                move.l  A0,(A1)
                moveq   #7,D0           ; get menusystem
                trap    #6
                lea     menuaddr(PC),A1
                move.l  A0,(A1)
                move.w  #$19,-(A7)      ; get discdrive
                trap    #1
                addq.l  #2,A7
                add.b   #"A",D0
                lea     autofilename(PC),A0
                move.b  D0,(A0)
                lea     pathen(PC),A0
                move.b  D0,(A0)
                move.w  #$2F,-(A7)      ; Get DTA
                trap    #1
                move.l  D0,savedta
                addq.l  #2,A7
                ENDPART
mainmenu:       >PART 'Main Menu'
                movea.l menuaddr(PC),A1
                lea     meny(PC),A0
                move.l  A0,2(A1)
                move.w  #-1,6(A1)
                clr.w   8(A1)
                clr.w   10(A1)
                move.l  #-1,12(A1)
                move.l  #workarea,16(A1)
                move.w  #0,20(A1)
                move.l  #-1,22(A1)
                move.l  #-1,26(A1)
                jsr     (A1)
                lea     meny+1(PC),A0
                move.b  #"0",(A0)+
                move.b  #"0",(A0)+
                move.b  #"0",(A0)+
                move.b  #"0",(A0)+
                bsr.s   cls
                cmp.w   #1,D0
                beq.s   quitallofthis
                cmp.w   #2,D0
                beq.s   choose
                cmp.w   #3,D0
                beq     select
                cmp.w   #4,D0
                beq     startcopy
                bra.s   mainmenu
quitallofthis:  rts
                ENDPART

***********************************************

cls:            >PART 'Clear Screen & Text'
**************************************
**  Clear Screen
**************************************
                movem.l D0-D2/A0,-(A7)
                pea     clst(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                movem.l (A7)+,D0-D2/A0
                rts
clst:           DC.B 27,"EAUTOCOPY - A Synchron Assembly product",13,10,10,0
                EVEN
                ENDPART

choose:         >PART 'Select New Autocopy.Inf'
*************************************
** SELECT THE NEW AUTOCOPY.INF
*************************************
                pea     newt(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                bsr     initgem
                move.l  #$5A0000,contrl
                move.l  #$020002,contrl+4
                move.w  #0,contrl+8
                move.l  #pathen,addrin
                move.l  #filen,addrin+4
                bsr     aes
                tst.w   intout
                beq     oops2
                tst.w   intout+2
                beq     mainmenu
                bsr     addfiles
                lea     commandline1,A1

meethere:       movea.l diskaddr(PC),A0
                move.w  #0,2(A0)
                move.l  A1,6(A0)
                move.l  #copyarea,10(A0)
                move.l  #copyarea+100000,14(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)
                tst.w   22(A0)
                bmi     anyfileerror

                move.w  #1,2(A0)
                move.l  #autofilename,6(A0)
                move.l  #copyarea,10(A0)
                move.l  #-1,14(A0)
                move.l  44(A0),18(A0)
                move.w  #0,24(A0)
                move.w  #0,38(A0)
                jsr     (A0)
                tst.w   22(A0)
                bmi     anyfileerror

                lea     autofilename(PC),A0
                bra     laddainf
newt:           DC.B 27,"ESELECT FILE TO BECOME THE AUTOCOPY.INF",0
                EVEN
oops2:          bsr     fsel2
                tst.w   D1
                bne     noinxerror
                tst.w   D0
                beq     mainmenu
                movea.l A0,A1
                bra     meethere
                ENDPART
select:         >PART 'Select A INX File'
*************************************
** SELECT A INFO FILE
*************************************
                pea     selt(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                bsr     initgem
                move.l  #$5A0000,contrl
                move.l  #$020002,contrl+4
                move.w  #0,contrl+8
                move.l  #pathen,addrin
                move.l  #filen,addrin+4
                bsr     aes
                tst.w   intout
                beq.s   oops1
                tst.w   intout+2
                beq     mainmenu
                bsr     addfiles
                lea     commandline1,A0
                bra     laddainf
selt:           DC.B 27,"ESELECT INFO FILE TO USE THIS TIME",0
                EVEN
oops1:          bsr.s   fsel2
                tst.w   D1
                bne     noinxerror
                tst.w   D0
                beq     mainmenu
                bra     laddainf
                ENDPART
fsel2:          >PART 'Own Fileselector'
********************************************
** FILESELECTOR 2
********************************************
                pea     DTA(PC)         ; Own DTA
                move.w  #$1A,-(A7)
                trap    #1
                addq.l  #6,A7

                lea     DTA(PC),A6
                lea     FILENAMES(PC),A5
                moveq   #'A',D7
                move.w  #$01,-(A7)      ;fsfirst
                pea     pathen(PC)
                move.w  #$4E,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.w   D0
                bne.s   ALLFOUND
LOOPFSEL2:      move.b  #'>',(A5)+
                move.b  D7,(A5)+
                addq.w  #1,D7
                move.b  #'c',(A5)+
                lea     30(A6),A0
COPYFSEL2:      move.b  (A0)+,D0
                move.b  D0,(A5)+
                tst.b   D0
                bne.s   COPYFSEL2
                move.w  #$4F,-(A7)      ;fsnext
                trap    #1
                addq.l  #2,A7
                tst.w   D0
                bne.s   ALLFOUND
                cmp.b   #'U',D7
                bne.s   LOOPFSEL2
ALLFOUND:       move.b  #'e',(A5)+
                clr.b   (A5)+

                move.l  savedta(PC),-(A7) ; RESTORE VALUES FOR FILESELECTOR 2
                move.w  #$1A,-(A7)
                trap    #1
                addq.l  #6,A7

                moveq   #7,D0
                trap    #6
                lea     FSELTEXT(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                tst.w   D1
                bmi.s   SKIPFSEL2
                tst.w   D0
                beq.s   SKIPFSEL2
                lea     FILENAMES(PC),A5
                lea     pathen(PC),A6
NEXTFSEL2:      move.b  (A6),(A5)
                move.b  1(A6),1(A5)
                move.b  2(A6),2(A5)
                cmp.b   #1,D0
                beq.s   SKIPFSEL2
LETANULLF2:     tst.b   (A5)+
                bne.s   LETANULLF2
                subq.w  #1,D0
                bra.s   NEXTFSEL2
SKIPFSEL2:      movea.l A5,A0
                rts

FSELTEXT:       DC.B "d+020",0
                DC.B ";cPlease select a file or press ESC",0
                DC.B ";z",0
FILENAMES:      DS.B 362        ;20*(3+14+1)+2
                EVEN
DTA:            DS.B 44
                ENDPART
addfiles:       >PART 'Add Directory To Filename'
**************************************
**  ADD DIRECTORY ON FILENAME
**************************************
                lea     pathen(PC),A0
                movea.l A0,A1
                movea.l A0,A2
lookmore:       move.b  (A0)+,D0
                cmp.b   #"\",D0
                bne.s   not1
                movea.l A0,A1
not1:           cmp.b   #":",D0
                bne.s   not2
                movea.l A0,A1
not2:           tst.b   D0
                bne.s   lookmore
                lea     commandline1,A0
copyamorea:     move.b  (A2)+,(A0)+
                cmpa.l  A1,A2
                bne.s   copyamorea
                lea     filen(PC),A1
                moveq   #11,D0
copyamore:      move.b  (A1)+,(A0)+
                dbra    D0,copyamore
                rts
                ENDPART

startcopy:      >PART 'Start Using Default File'
**************************************
**  DO COPY, NORMAL
**************************************
                lea     autofilename(PC),A0
*                bra.s   laddainf
                ENDPART
laddainf:       >PART 'Load Info File'
**************************************
** Ladda info file a0=address to filename
**************************************
                clr.w   wildflag
                movea.l diskaddr(PC),A1
                move.w  #0,2(A1)
                move.l  A0,6(A1)
                lea     infofile,A0
                move.l  A0,10(A1)
                lea     textpek(PC),A2
                move.l  A0,(A2)
                lea     5*1024(A0),A0
                move.l  A0,14(A1)
                move.w  #0,24(A1)
                move.w  #0,42(A1)
                jsr     (A1)
                tst.w   22(A1)
                beq.s   noerror1
                cmpi.w  #-33,22(A1)
                beq     filenotfound
                bra     anyfileerror2
noerror1:
                ENDPART

getnewcom:      >PART 'Get Next Command'
***************************************
**    GET NEW COMMAND
***************************************
                tst.w   wildflag
                bne     do_wildcards
                bsr     cls
                lea     commandline1,A0
                bsr     getline
                tst.b   1(A0)
                bne.s   oops
                cmpi.b  #"W",(A0)
                beq     initwildcards
                cmpi.b  #"C",(A0)
                beq     copyfile
                cmpi.b  #"F",(A0)
                beq.s   makefolder
                cmpi.b  #"E",(A0)
                beq.s   nomore
oops:           movea.l menuaddr(PC),A0
                lea     gigafel(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
nomore:         rts

gigafel:        DC.B "q99",0
                DC.B "d+060",0
                DC.B "s02",0
                DC.B ";cERROR IN INFO FILE!!",0
                DC.B ";z",0
                DC.B ">AcMAIN MENU",0
                DC.B ">BcLEAVE AUTOCOPY",0
                DC.B "e",0
                EVEN
                ENDPART

makefolder:     >PART 'Make Folder'
***************************************
**    MAKE FOLDER
***************************************
                lea     commandline1,A0
                bsr     getline
                movea.l diskaddr(PC),A1
                move.w  #4,2(A1)
                move.l  A0,6(A1)
                jsr     (A1)
                cmpi.w  #-36,22(A1)
                beq     getnewcom
                tst.w   22(A1)
                bne     foldererror
                bra     getnewcom
                ENDPART
do_wildcards:   >PART 'Do Wildcards'
***************************************
**    DO WILD CARDS
***************************************
                lea     DTA+30(PC),A0
                lea     commandline1,A1
                lea     commandline2,A2
                lea     wildname,A3
                lea     savepath,A4
copymore1:      move.b  (A4)+,(A2)+     ; Copy SAVE path
                tst.b   (A4)
                bne.s   copymore1
                movea.l A1,A5
copymore2:      move.b  (A3)+,D0        ; Copy LOAD path
                move.b  D0,(A1)+
                cmp.b   #':',D0
                beq.s   foundmark
                cmp.b   #'\',D0
                bne.s   nomark
foundmark:      movea.l A1,A5
nomark:         tst.b   D0
                bne.s   copymore2

copymore3:      move.b  (A0)+,D0        ; Copy LOAD/SAVE name
                move.b  D0,(A2)+
                move.b  D0,(A5)+
                tst.b   D0
                bne.s   copymore3

                lea     commandline1,A0
                bsr     printline
                lea     commandline2,A0
                bsr     printline

                pea     DTA(PC)
                move.w  #$1A,-(A7)      ; Set Own DTA
                trap    #1
                addq.l  #6,A7

                move.w  #$4F,-(A7)      ; Snext
                trap    #1
                addq.l  #2,A7
                tst.w   D0
                bpl.s   stillmore
                clr.w   wildflag
stillmore:
                move.l  savedta(PC),-(A7) ; Restore Old DTA
                move.w  #$1A,-(A7)
                trap    #1
                addq.l  #6,A7

                bra     laddafil
                ENDPART
initwildcards:  >PART 'Init Wildcards'
***************************************
**    WILD CARDS INIT
***************************************
                lea     wildname,A0
                bsr     getline
                lea     commandline1,A0
                move.l  A0,loadname
                lea     savepath,A0
                bsr     getline
                lea     commandline2,A0
                move.l  A0,savename

                pea     DTA(PC)
                move.w  #$1A,-(A7)      ; Set Own DTA
                trap    #1
                addq.l  #6,A7

                move.w  #%111,-(A7)     ; SFirst
                pea     wildname
                move.w  #$4E,-(A7)
                trap    #1
                addq.l  #8,A7
                clr.w   wildflag
                tst.w   D0
                bmi.s   no_more
                move.w  #-1,wildflag
no_more:
                move.l  savedta(PC),-(A7) ; Restore Old DTA
                move.w  #$1A,-(A7)
                trap    #1
                addq.l  #6,A7

                bra     getnewcom

                ENDPART
copyfile:       >PART 'Copy Normal'

***************************************
**    COPY FILE
***************************************
                lea     commandline1,A0
                bsr     getline
                move.l  A0,loadname
                lea     commandline2,A0
                bsr     getline
                move.l  A0,savename
                ENDPART
laddafil:       >PART 'Copy Routine'

                clr.w   -(A7)           ; Open LOAD
                move.l  loadname(PC),-(A7)
                move.w  #$3D,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.w   D0
                bmi     error1
                move.w  D0,loadhandle

                move.w  #0,-(A7)        ; Create SAVE
                move.l  savename(PC),-(A7)
                move.w  #$3C,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.w   D0
                bmi.s   error2
                move.w  D0,savehandle


copyloop:       pea     copyarea        ; LOAD 8*1024 Kb
                pea     8*1024.w
                move.w  loadhandle(PC),-(A7)
                move.w  #$3F,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.l   D0
                bmi.s   error1
                move.l  D0,bytesloaded

                pea     copyarea        ; SAVE all That's Loaded
                move.l  D0,-(A7)
                move.w  savehandle(PC),-(A7)
                move.w  #$40,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.w   D0
                bmi.s   error2

                move.l  bytesloaded(PC),D0
                cmpi.l  #8*1024,D0
                beq.s   copyloop

                bsr     closedown

                bra     getnewcom

bytesloaded:    DC.L 0
loadname:       DC.L 0
loadhandle:     DC.W 0
savename:       DC.L 0
savehandle:     DC.W 0

**********************************

error1:         movea.l diskaddr(PC),A0
                move.l  loadname(PC),6(A0)
                move.w  D0,22(A0)
                bsr     closedown
                bra     anyfileerror2
error2:         movea.l diskaddr(PC),A0
                move.l  savename(PC),6(A0)
                move.w  D0,22(A0)
                bsr.s   closedown
                bra     anyfileerror3

                ENDPART

getline:        >PART 'Get A Command'
**************************************
**  GET A LINE IN TEXT
**  A0= dest
**************************************
                movem.l D0-A6,-(A7)
                movea.l A0,A3
                lea     textpek(PC),A2
                movea.l (A2),A1
                move.w  #250,D6
getloop:        move.b  (A1)+,D7
                beq.s   skipthisone
                cmp.b   #10,D7
                beq.s   skipthisone
                cmp.b   #-1,D7
                beq.s   skipthisone
                cmp.b   #13,D7
                beq.s   finished
                cmp.b   #"a",D7
                blo.s   notsmall
                cmp.b   #"z",D7
                bhi.s   notsmall
                add.b   #"A"-"a",D7
notsmall:       move.b  D7,(A0)+
skipthisone:    dbra    D6,getloop
finished:       clr.b   (A0)+
                move.l  A1,(A2)
                move.l  A3,-(A7)
                move.w  #9,-(A7)
                trap    #1
                pea     return(PC)
                move.w  #9,-(A7)
                trap    #1
                lea     12(A7),A7
                movem.l (A7)+,D0-A6
                rts
                ENDPART
printline:      >PART 'Print A0 and make CRLF'
                move.l  A0,-(A7)
                move.w  #9,-(A7)
                trap    #1
                pea     return(PC)
                move.w  #9,-(A7)
                trap    #1
                lea     12(A7),A7
                rts
return:         DC.B 13,10,0
                EVEN
                ENDPART
closedown:      >PART 'Close Load and Save File'
                move.w  loadhandle(PC),-(A7) ; close LOAD
                move.w  #$3E,-(A7)
                trap    #1
                addq.l  #4,A7

                move.w  savehandle(PC),-(A7) ; close SAVE
                move.w  #$3E,-(A7)
                trap    #1
                addq.l  #4,A7
                rts
                ENDPART
*************************************************

hex_to_dec:     >PART 'HEX -> DEC Converter'
**********************************************
**      HEX -> DEC CONVERTER
**      D0=HEXTAL IN (0-$9FFFF)
**      D0=DEC TAL OUT (0-655359) (BCD SYSTEM!!)
**********************************************
                movem.l D1/D6-D7,-(A7)
                moveq   #0,D7
                moveq   #32,D6
NEXTTAL:        divu    #10,D0
                move.l  D0,D1
                swap    D1
                or.w    D1,D7
                ror.l   #4,D7
                subq.w  #4,D6
                and.l   #$FFFF,D0
                bne.s   NEXTTAL
                ror.l   D6,D7
                move.l  D7,D0
                movem.l (A7)+,D1/D6-D7
                rts
                ENDPART
insertname:     >PART 'Copy Filen Name Into Text'
**************************************
**  COPY FILE NAME INTO TEXT
**  A0=TEXTADDR
**  A1=ENDTEXTADDR
**************************************
                movem.l D0-A6,-(A7)
                movea.l diskaddr(PC),A2
r:              movea.l 6(A2),A2
kopieranamn:    move.b  (A2)+,D0
                beq.s   slutnamncopy
                move.b  D0,(A0)+
                bra.s   kopieranamn
slutnamncopy:   move.b  #'"',(A0)+
fill:           move.b  #13,(A0)+
                cmpa.l  A0,A1
                bne.s   fill
                movem.l (A7)+,D0-A6
                rts
                ENDPART
inserterror:    >PART 'Copy Error Number Into Text'
**************************************
**  COPY ERROR NUMBER INTO TEXT
**  A0=TEXTADDR (3DIGITS)
**************************************
                movem.l D0-A6,-(A7)
                movea.l diskaddr(PC),A1
                move.w  22(A1),D0
                neg.w   D0
                bsr.s   hex_to_dec
                lea     3(A0),A0
                moveq   #2,D2
three:          move.w  D0,D1
                lsr.w   #4,D0
                and.w   #$0F,D1
                add.w   #"0",D1
                move.b  D1,-(A0)
                dbra    D2,three
                movem.l (A7)+,D0-A6
                rts
                ENDPART

noinxerror:     >PART 'No INX files error'
**************************************
**  NO .INX FILES ERROR
**************************************
                movea.l menuaddr(PC),A0
                move.l  #noinx,2(A0)
                jsr     (A0)
                bra     mainmenu
noinx:          DC.B "d+080",0
                DC.B ";cThere is no .INX files!!",0
                DC.B ";z",0
                DC.B ">AcMAIN MENU",0
                DC.B "e",0
                EVEN
                ENDPART
filenotfound:   >PART 'AutoCopy File Not Found'
**************************************
**  FILE NOT FOUND ERROR
**************************************
                movea.l menuaddr(PC),A0
                lea     notfound(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                rts

notfound:       DC.B "s02",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ";cAUTOCOPY INFO FILE NOT FOUND",0
                DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcSKIP AUTOCOPY",0
                DC.B "e"
                EVEN
                ENDPART
filenotfound2:  >PART 'File Not Found'
**************************************
**  FILE NOT FOUND ERROR 2
**************************************
                lea     fil(PC),A0
                lea     endfil(PC),A1
                bsr     insertname

                movea.l menuaddr(PC),A0
                lea     notfound2(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                cmp.w   #2,D0
                beq     laddafil
                cmp.w   #3,D0
                beq     getnewcom
                rts

notfound2:      DC.B "u00",0
                DC.B "s02",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ';c"'
fil:            DS.B 50
endfil:         DC.B ";cCAN NOT BE FOUND",0
                DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcTRY AGAIN",0
                DC.B ">CcCOPY NEXT FILE",0
                DC.B ">DcSKIP AUTOCOPY",0

                DC.B "e",0
                EVEN
                ENDPART
foldererror:    >PART 'Error Creationg Folder'
**************************************
**  ERROR WHILE CREATING FOLDER
**************************************
                lea     fold(PC),A0
                lea     endfold(PC),A1
                bsr     insertname

                lea     folde(PC),A0
                bsr     inserterror

                movea.l menuaddr(PC),A0
                lea     foldere(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                cmp.w   #2,D0
                beq     getnewcom
                rts

foldere:        DC.B "u00",0
                DC.B "s03",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ";cERROR -"
folde:          DC.B "xxx WHILE CREATING THE FOLDER:",0
                DC.B ';c"'
fold:           DS.B 50
endfold:        DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcGO ON",0
                DC.B ">CcSKIP AUTOCOPY",0
                DC.B "e",0
                EVEN
                ENDPART
anyfileerror2:  >PART 'Any File Error While Loading'
**************************************
**  ANY FILE ERROR WHILE LOADING
**************************************
                movea.l diskaddr(PC),A0
                cmpi.w  #-33,22(A0)
                beq     filenotfound2
                lea     fil2(PC),A0
                lea     endfil2(PC),A1
                bsr     insertname

                lea     errorpos1(PC),A0
                bsr     inserterror

                movea.l menuaddr(PC),A0
                lea     loaderror(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                cmp.w   #2,D0
                beq     getnewcom
                cmp.w   #3,D0
                beq     laddafil
                rts

loaderror:      DC.B "u00",0
                DC.B "s02",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ";cERROR -"
errorpos1:      DC.B "xxx WHILE LOADING",0
                DC.B ';c"'
fil2:           DS.B 50
endfil2:        DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcCOPY NEXT FILE",0
                DC.B ">CcTRY AGAIN",0
                DC.B ">DcSKIP AUTOCOPY",0
                DC.B "e"
                EVEN
                ENDPART
anyfileerror3:  >PART 'Any File Error While Saving'
**************************************
**  ANY FILE ERROR WHILE SAVING
**************************************
                movea.l diskaddr(PC),A0
                cmpi.w  #-102,22(A0)
                beq     filexisterror
                lea     fil3(PC),A0
                lea     endfil3(PC),A1
                bsr     insertname

                lea     errorpos2(PC),A0
                bsr     inserterror

                movea.l menuaddr(PC),A0
                lea     saveerror(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                cmp.w   #2,D0
                beq     getnewcom
                cmp.w   #3,D0
                beq     laddafil
                rts
saveerror:      DC.B "u00",0
                DC.B "s02",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ";cERROR -"
errorpos2:      DC.B "xxx WHILE SAVING",0
                DC.B ';c"'
fil3:           DS.B 65
endfil3:        DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcCOPY NEXT FILE",0
                DC.B ">CcTRY AGAIN",0
                DC.B ">DcSKIP AUTOCOPY",0
                DC.B "e"
                EVEN
                ENDPART
anyfileerror:   >PART 'Any File Error'
**************************************
**  ANY FILE ERROR
**************************************
                lea     errorhere(PC),A0
                bsr     inserterror

                movea.l menuaddr(PC),A0
                lea     fileerror(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                rts

fileerror:      DC.B "s02",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ";cFILE ERROR -"
errorhere:      DC.B "xxx",0
                DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcSKIP AUTOCOPY",0
                DC.B "e"
                EVEN
                ENDPART
filexisterror:  >PART 'File Already Exist'
**************************************
**  ERROR WHILE SAVING -ALREADY EXISTS
**************************************
                lea     filen1(PC),A0
                lea     endfilen1(PC),A1
                bsr     insertname

                movea.l menuaddr(PC),A0
                lea     filexist(PC),A1
                move.l  A1,2(A0)
                jsr     (A0)
                cmp.w   #1,D0
                beq     mainmenu
                cmp.w   #2,D0
                bne.s   nit1
                lea     overall(PC),A0
                move.w  #0,(A0)
                lea     overone(PC),A0
                move.w  #0,(A0)
                bra     laddafil
nit1:           cmp.w   #4,D0
                bne.s   nit2
                lea     overone(PC),A0
                move.w  #0,(A0)
                bra     laddafil
nit2:           cmp.w   #3,D0
                beq     getnewcom
                rts

filexist:       DC.B "u00",0
                DC.B "s03",0
                DC.B "q99",0
                DC.B "d+060",0
                DC.B ';c"'
filen1:         DS.B 50
endfilen1:      DC.B ";cALREADY EXISTS",0
                DC.B ";z",0
                DC.B ">AcBACK TO MAIN MENU",0
                DC.B ">BcOVERWRITE ALL FILES",0
                DC.B ">CcCOPY NEXT FILE",0
                DC.B ">DcOVERWRITE THIS FILE",0
                DC.B ">EcSKIP AUTOCOPY",0
                DC.B "e"
                EVEN
                ENDPART

*************************************************

                >PART 'DATA'
***************************************
**     DATA
***************************************
savedta:        DC.L 0
savea7:         DC.L 0
menuaddr:       DC.L 0          ; address to menusystem
diskaddr:       DC.L 0
textpek:        DC.L 0
lenght:         DC.L 0
overone:        DC.W 0
overall:        DC.W -1
wildflag:       DC.W 0          ; 0=no wildcard to execute (in own DTA)
autofilename:   DC.B "A:\AUTOCOPY.INF",0
pathen:         DC.B "A:\*.INX",0
                DS.B 50
filen:          DC.B "INFOFILE.INX",0
                EVEN
meny:           DC.B "t0075",0
                DC.B "q04",0
                DC.B "u00",0
                DC.B "s04",0
                DC.B "d+030",0
                DC.B ";cAUTO COPY V1.22 made by MARTIN LIESEN -90",0
                DC.B ";c-----------------------------------------",0
                DC.B ";ca SYNCHRON ASSEMBLY product!!!",0
                DC.B ";cDedicated To SOFIA (HASTING89)",0
                DC.B "y043",0
                DC.B ">AcQUIT AUTOCOPY.PRG",0
                DC.B ">BcSELECT A NEW AUTOCOPY.INF",0
                DC.B ">CcUSE ANOTHER INFO FILE",0
                DC.B ">DcSTART COPY",0
                DC.B "y090",0
                DC.B ";cUse the AUTOINST.PRG to make info files",0
                DC.B "y105",0
                DC.B ";cThis program is FREEWARE and might",0
                DC.B ";conly be spread without profit!!",0
                DC.B "e",0

                EVEN
                ENDPART

*************************************************

initgem:        >PART 'Init Gem Routines'
******************************************
** INIT GEM ROUTINE
******************************************
                tst.w   gemflag
                bne     readydone
                move.w  #-1,gemflag
                clr.l   ap1resv
                clr.l   ap2resv
                clr.l   ap3resv
                clr.l   ap4resv

                move.w  #10,opcode      ; APPL_INIT
                clr.w   sintin
                move.w  #1,sintout
                clr.w   saddrin
                clr.w   saddrout
                bsr.s   aes

                move.w  #77,opcode      ; GRAF_HANDLE
                clr.w   sintin
                move.w  #5,sintout
                clr.w   saddrin
                clr.w   saddrout
                bsr.s   aes

                move.w  intout,grhandle

                move.w  #100,opcode     ; OPEN_VWORK
                clr.w   contrl+2
                move.w  #11,contrl+6
                move.w  grhandle(PC),contrl+12

                moveq   #9,D0
                lea     intin,A0
gem_loop:       move.w  #1,(A0)+
                dbra    D0,gem_loop
                move.w  #2,(A0)+
                bsr.s   vdi
readydone:      rts
**********************************************
***     GEM RUTINS
**********************************************
aes:            move.l  #aespb,D1
                move.w  #$C8,D0
                trap    #2
                rts
vdi:            move.l  #vdipb,D1
                moveq   #$73,D0
                trap    #2
                rts
                ENDPART
                >PART 'Gem Data'
**********************************************
***     GEM DATA
**********************************************
grhandle:       DC.W 0
gemflag:        DS.W 1
vdipb:          DC.L contrl,intin,ptsin,intout,ptsout
aespb:          DC.L contrl,global,intin,intout,addrin,addrout
                BSS
contrl:
opcode:         DS.W 1
sintin:         DS.W 1
sintout:        DS.W 1
saddrin:        DS.W 1
saddrout:       DS.L 1
                DS.W 5
global:
apversion:      DS.W 1
apcount:        DS.W 1
apid:           DS.W 1
apprivate:      DS.L 1
ap1resv:        DS.L 1
ap2resv:        DS.L 1
ap3resv:        DS.L 1
ap4resv:        DS.L 1
intin:          DS.W 128
ptsin:          DS.W 128
intout:         DS.W 128
ptsout:         DS.W 128
addrin:         DS.W 128
addrout:        DS.W 128
                ENDPART

************************************************
**      BIG TABS
************************************************
                DS.B 600
stack:
workarea:       DS.B 2*1024
infofile:       DS.B 5*1024
commandline1:   DS.B 128
commandline2:   DS.B 128
wildname:       DS.B 128
savepath:       DS.B 128
copyarea:       DS.B 8*1024
                END
