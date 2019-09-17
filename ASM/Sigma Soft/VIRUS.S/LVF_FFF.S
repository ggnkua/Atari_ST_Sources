*************************************************
* Link-Virus-Finder V1.5                        *
* and Fast-File-Finder V1.5                     *
* (c)1989 by Maxon Computer                     *
* by  ä-soft, Markus Fritze                     *
* developed with Turbo-Ass V1.4                 *
*************************************************
;switches:
virus           EQU 0
;0:Fast-File-Finder, <>0:Link-Virus-Finder

                IF virus
                OUTPUT 'LVF.TTP' ;Link-Virus-Finder
                ELSE
                OUTPUT 'FFF.TTP' ;Fast-File-Finder
                ENDC
                OPT F+,W+        ;Warnings on,Fast-Load on

max_prgs        EQU 1000         ;maximum of 1000 Programs in the LVF
max_sectorsize  EQU 8192         ;maximum Sectorsize

;A6-Register points to the BSS-Segment
                BASE A6,BSS

;Define Structure of the BIOS-Parameter-Block
                PART 'BPB-Structure'
                RSRESET
recsiz:         RS.W 1          ;Bytes per Sector
clsiz:          RS.W 1          ;Sectors per Cluster
clsizb:         RS.W 1          ;Bytes per Cluster
rdlen:          RS.W 1          ;Length of the Root-Directories
fsiz:           RS.W 1          ;Length of a FAT
fatrec:         RS.W 1          ;Startsector of the 2.FAT
datrec:         RS.W 1          ;Startsector of the 1.free Sectors
numcl:          RS.W 1          ;Entire number of Clusters
bflags:         RS.W 1          ;Bit0=1 with 16-bit-FAT
                ENDPART

_drvbits        EQU $04C2       ;The Bitmask of the Drive

                PART 'main'
start:
        movea.l         4(SP),A0        ;Pointer to the Basepage
        movea.l         $18(A0),A6      ;Pointer to the BSS-Area
        lea             own_stack(PC),SP

        pea             init_text(PC)
        bsr             print_line      ;Startup-Message

                IF virus
        lea             data_buff(A6),A0
        move.l          A0,data_base(A6)

        clr.w           -(SP)
        pea             fname(A6)
        move.w          #$3D,-(SP)
        trap            #1              ;Fopen()
        addq.l          #8,SP
        move.l          D0,D7
        bmi.s           start1          ;Error
        move.l          data_base(A6),-(SP)
        move.l          #max_prgs*32,-(SP)
        move.w          D7,-(SP)
        move.w          #$3F,-(SP)
        trap            #1              ;Fread() - Read Datablock 
        lea             12(SP),SP
        move.w          D7,-(SP)
        move.w          #$3E,-(SP)
        trap            #1              ;Fclose()
        addq.l          #4,SP
start1:
                ENDC

        bsr             convert         ;utilize Command line 

        clr.l           -(SP)
        move.w          #$20,-(SP)
        trap            #1              ;to supervisor mode 
        move.l          D0,2(SP)
        move.l          _drvbits.w,D7   ;read out Variable 
        trap            #1              ;to User mode again
        addq.l          #6,SP
        move.w          D7,D1           ;_drvbits to D1

                IF !virus
        lea             search_mask(A6),A1  ;Search mask
        lea             search_chars(A6),A2 ;Search data
                ENDC
        moveq           #$18,D7         ;Ignore Directory & Vol-Label
        moveq           #0,D5           ;Bytes of the files found
        moveq           #0,D4           ;Number of files found
        moveq           #0,D3           ;Number of folders

        moveq           #2,D2           ;go on with Drive C 
        tst.w           D6              ;no drive specified?
        bmi.s           loop            ;Exactly! =>
        move.w          D6,D2           ;test the special drive
loop:
        btst            D2,D1           ;Drive available?
        beq.s           loop1           ;No! =>
        movea.l         #stack,A0
        adda.l          A6,A0
        move.l          A0,stack_pnt(A6) ;put stack back
        move.w          D2,D0
        bsr             set_drive       ;Set Drive,read FAT 
        movem.l         D1-D3,-(SP)
        move.l          D0,D1
        pea             drive_text(PC)
        bsr             print_line
        moveq           #'A',D0
        add.b           D2,D0
        bsr             chrout          ; output actual Drive 
        pea             drive_text2(PC)
        bsr             print_line
        moveq           #7,D2           ;maximum of 8 places output
        bsr             dec_out         ;release memory
        pea             drive_text3(PC)
        bsr             print_line      ;"Bytes free"
        movem.l         (SP)+,D1-D3

        bsr             read_dir        ;read in complete Tree

        lea             path(A6),A3
        move.b          #'A',(A3)
        add.b           D2,(A3)+        ;find out drive
        move.b          #':',(A3)+
        move.b          #'\',(A3)+      ;Set Root-Path 

        move.w          D1,-(SP)
        bsr             hunt_dir        ;search through Tree
        move.w          (SP)+,D1
loop1:
        tst.w           D6              ;Drive info?
        bpl.s           loop2           ;Yes! => Ready
        addq.w          #1,D2
        cmp.w           #32,D2          ;up to Bit 32 will not be all
        bne.s           loop            ;exponents yet? Correct! =>
loop2:
                IF virus
        moveq           #0,D1
        move.w          virus_count(A6),D1 ;Virus found?
        beq.s           loop3              ;No! =>
        moveq           #4,D2              ;maximum of 5 places output
        bsr             dec_out
        pea             virus_text(A6)
        bsr             print_line         ;attempted files found
loop3:
                ENDC
        moveq           #0,D1
        move.w          D4,D1           ;Number of 'Hits'
        moveq           #5,D2           ;maximum of 6 places output
        bsr             dec_out
        pea             files_text(A6)
        bsr             print_line
        move.l          D5,D1           ;Length of all the files together
        moveq           #7,D2           ;maximum of 8 places output
        bsr             dec_out
        pea             files_text2(A6)
        bsr             print_line

        moveq           #0,D1
        move.w          D3,D1           ;Number of folders
        moveq           #4,D2           ;maximum of 5 places output
        bsr             dec_out
        pea             folders_text(A6)
        bsr.s           print_line

        move.w          #7,-(SP)
        trap            #1              ;Wait on a key
        addq.l          #2,SP
                IF virus
        bclr            #5,D0
        cmp.b           #'J',D0         ;Write?
        bne.s           _exit           ;No! =>

        movea.l         data_base(A6),A4
        movea.l         A4,A3           ;Mark Data base 
code:
        tst.l           (A4)            ;End of the List?
        beq.s           code2           ;Yes! =>
        lea             24(A4),A4
        bra.s           code
code2:
        suba.l          A3,A4           ;Length of all Data

        clr.w           -(SP)
        pea             fname(A6)
        move.w          #$3C,-(SP)
        trap            #1              ;Fcreate()
        addq.l          #8,SP
        move.l          D0,D7
        bmi.s           _exit           ;Error
        move.l          A3,-(SP)        ;Base address of the Data
        move.l          A4,-(SP)        ;Length
        move.w          D7,-(SP)
        move.w          #$40,-(SP)
        trap            #1              ;Fwrite()
        lea             12(SP),SP
        move.w          D7,-(SP)
        move.w          #$3E,-(SP)
        trap            #1              ;Fclose()
        addq.l          #4,SP
                ENDC

_exit:
        pea             exit_text(A6)
        bsr.s           print_line      ;Cursor out again, etc.

        clr.w           -(SP)
        trap            #1              ;Program end
                ENDPART

*************************************************
* String sent to the Stack                      *
*************************************************
                PART 'print_line'
print_line:
        movem.l         D0-D2/A0-A2,-(SP)
        move.l          4+6*4(SP),-(SP)
        move.w          #$09,-(SP)
        trap            #1              ;Cconws()
        addq.l          #6,SP
        movem.l         (SP)+,D0-D2/A0-A2
        move.l          (SP)+,(SP)      ;Stack correction
        rts
                ENDPART
*************************************************
* Characters given in D0                        *
*************************************************
                PART 'chrout'
chrout:
        movem.l         D0-D2/A0-A2,-(SP)
        move.w          D0,-(SP)
        move.w          #$02,-(SP)
        trap            #1              ;Cconout()
        addq.l          #4,SP
        movem.l         (SP)+,D0-D2/A0-A2
        rts
                ENDPART
**********************************************
* positive Decimal-Number in D1              *
* without leading zeros given                *
* maximum number of places minus 1 in D2     *
**********************************************
                PART 'dec_out'
dec_out:
        movem.l         D0-D4/A1,-(SP)
        lea             dec_tab(PC),A1  ;Pointer to the Table
        move.w          D2,D0           ;Number of places-1
        add.w           D0,D0           ;times 4
        add.w           D0,D0           ;(faster than LSL.W #2,D0!)
        lea             4(A1,D0.w),A1   ;Pointer to the place number
        moveq           #0,D4           ;ignore leading zeros
dec_out1:
        move.l          -(A1),D3        ;Tables value
        moveq           #-'0',D0        ;will be -'1',-'2',-'3',...
dec_out2:
        sub.l           D3,D1           ;SUB until an occurence
        dbcs            D0,dec_out2     ;Occurrence? No! =>
        neg.w           D0              ;e.g. -'1' => '1'
        cmp.b           #'0',D0         ;a zero?
        beq.s           dec_out4        ;Yes! =>
        moveq           #-1,D4          ;from here will also be zeros
dec_out3:
        bsr.s           chrout          ;Character given in D0 
dec_out5:
        add.l           D3,D1           ;the occurrence returns
        dbra            D2,dec_out1     ;all places already?
        movem.l         (SP)+,D0-D4/A1
        rts
dec_out4:
        tst.b           D4              ;Zeros given?
        bne.s           dec_out3        ;Yes! =>
        tst.w           D2              ;last digit?
        bne.s           dec_out5        ;No! => then ignore
        moveq           #'0',D0         ;when the entire value is 0 ,
        bra.s           dec_out3        ;at least a 0 is given!
dec_tab:
                DC.L 1,10,100,1000,10000,100000
                DC.L 1000000,10000000,100000000,1000000000
                ENDPART
*************************************************
* convert() - Utilize the Commandline           *
*                                               *
* With it the variable "flag" will be set,      *
* the D6-Register (Drive) defined and the       *
* Search mask and the Search string from the    *
* File names put together.                      *
*************************************************
                PART 'convert'
convert:
        lea             start-128+1(A6),A0 ;Commandline
        clr.b           flag(A6)           ;remove all Flags
        moveq           #-1,D6             ;no drive given
convert1:
        cmpi.b          #' ',(A0)+         ;Miss spaces
        beq.s           convert1
        subq.l          #1,A0
        cmpi.b          #'-',(A0)          ;anything following?
        bne.s           convert2           ;No! =>
        addq.l          #1,A0
        bset            #0,flag(A6)        ;Count files only
convert2:
        cmpi.b          #' ',(A0)+         ;Miss spaces
        beq.s           convert2
        subq.l          #1,A0
                IF virus
        cmpi.b          #'+',(A0)          ;anything following?
        bne.s           convert3           ;No! =>
        addq.l          #1,A0
        bset            #1,flag(A6)        ;take on all files
convert3:
        cmpi.b          #' ',(A0)+         ;Miss spaces
        beq.s           convert3
        subq.l          #1,A0
        cmpi.b          #':',(A0)
        bne.s           convert8
        addq.l          #1,A0              ;Ignore colon
convert8:
        moveq           #0,D0
        move.b          (A0),D0
        bmi.s           convert14          ;Code>127 => no Drive
        bclr            #5,D0
        subi.b          #'A',D0
        bmi.s           convert14          ;<'A' => no Drive
        cmp.b           #32,D0
        bhs.s           convert14          ;>maxdrive => no Drive
        move.w          D0,D6              ;mark Drive given
convert14:
        rts
                ELSE
        cmpi.b          #':',(A0)
        bne.s           convert6
        moveq           #0,D0
        move.b          1(A0),D0
        addq.l          #2,A0
        bclr            #5,D0
        cmp.b           #32,D0
        bhs.s           convert6            ;>maxdrive => no Drive
        move.w          D0,D6               ;Mark Drive given
convert6:
        cmpi.b          #' ',(A0)+          ;Miss spaces
        beq.s           convert6
        subq.l          #1,A0
        lea             search_mask(A6),A1  ;Search mask
        lea             search_chars(A6),A2 ;Search data
        clr.l           (A1)+
        clr.l           (A1)+               ;remove all Search masks
        clr.l           (A1)
        subq.l          #8,A1
        moveq           #0,D2               ;no Allquantor
        moveq           #7,D1               ;maximum of 8 character Filename
convert7:
        move.b          (A0)+,D0
        beq             convert19           ;End of the Filenames
        cmp.b           #' ',D0             ;Space as End?
        beq             convert19           ;Yes! =>
        cmp.b           #13,D0              ;CR as End?
        beq             convert19           ;Yes! =>
        cmp.b           #'.',D0             ;Start of the Extension?
        beq.s           convert12           ;Yes! =>
        cmp.b           #'?',D0             ;Existence quantor?
        bne.s           convert8            ;No! =>
        tst.w           D2                  ;Allquantor already given?
        bne.s           convert11           ;Yes! =>
        sf              (A1)+
        sf              (A2)+               ;Ignore character
        bra.s           convert11           ;continue =>
convert8:
        cmp.b           #'*',D0             ;Allquantor?
        bne.s           convert9            ;No! =>
        moveq           #-1,D2              ;Allquantor
        bra             convert7
convert9:
        tst.w           D2                  ;Allquantor already given?
        bne.s           convert11           ;Yes! =>
        cmp.b           #'a',D0
        blo.s           convert10
        cmp.b           #'z',D0
        bhi.s           convert10
        bclr            #5,D0               ;Change to capital letters
convert10:
        move.b          D0,(A2)+            ;take on characters
        st              (A1)+               ;Set Mask with it
convert11:
        dbra            D1,convert7         ;maximum of 8 characters
        bra             convert13
convert12:
        tst.w           D2                  ;Allquantor given?
        bne             convert13           ;Yes! =>
        move.b          #' ',(A2)+          ;Filenames with ' '
        st              (A1)+               ;fill up
        dbra            D1,convert12
convert13:
        lea             search_mask+8(A6),A1  ;Search mask
        lea             search_chars+8(A6),A2 ;Search data
        moveq           #2,D1                 ;maximum 3 character extension
convert14:
        move.b          (A0)+,D0
        beq.s           convert17             ;End of the Filenames
        cmp.b           #' ',D0               ;Space as End?
        beq.s           convert17             ;Yes! =>
        cmp.b           #13,D0                ;CR as End?
        beq.s           convert17
        cmp.b           #'?',D0               ;Existence quantor?
        bne.s           convert15             ;No! =>
        sf              (A1)+
        sf              (A2)+                 ;Ignore characters
        bra.s           convert18             ;continue =>
convert15:
        cmp.b           #'*',D0               ;Allquantor?
        beq             convert19             ;No! =>
        cmp.b           #'a',D0
        blo.s           convert16
        cmp.b           #'z',D0
        bhi.s           convert16
        bclr            #5,D0                 ;change to capital letters
convert16:
        move.b          D0,(A2)+              ;take on characters
        st              (A1)+                 ;Set Mask with it
        dbra            D1,convert14          ;already all maximum 8 characters
        bra             convert19
convert17:
        move.b          #' ',(A2)+            ;Fill in Extension
        st              (A1)+                 ;with spaces
convert18:
        dbra            D1,convert17
convert19:
        rts
                ENDC
                ENDPART
*************************************************
* hunt_dir() - Complete Directory-Tree in A0    *
* searched through, the number of entries in    *
* the Directory are placed in D0 with it.       *
*                                               *
* this Routine calls on itself recursively,     *
* to also search through any low level folders  *
* as well.                                      *
*                                               *
* The Tree must through read_dir() lie in       *
* memory, i.e. ready with Pointers chained      *
* to it.                                        *
*************************************************
                PART 'hunt_dir'
hunt_dir:
        subq.w          #1,D0           ;for DBRA
hunt_dir1:
        move.w          D7,D1           ;Illegal File attribute-Bits
        and.b           11(A0),D1       ;Flags for it
        bne             hunt_dir3       ;File not found! =>
        cmpi.b          #$E5,(A0)       ;Deleted file?
        beq             hunt_dir2       ;Yes! =>
                IF !virus
        move.l          (A0),D1
        beq             hunt_dir4       ;End of the Directories =>
        and.l           (A1),D1
        cmp.l           (A2),D1         ;Characters 1-4 of the File names
        bne             hunt_dir3
        move.l          4(A0),D1
        and.l           4(A1),D1
        cmp.l           4(A2),D1        ;Characters 5-8 of the File names
        bne             hunt_dir3
        move.l          8(A0),D1
        and.l           8(A1),D1
        cmp.l           8(A2),D1        ;Compare the Extension
        bne             hunt_dir3
        btst            #0,flag(A6)     ;Count only files?
        bne.s           print_fname4    ;Yes! =>
        bsr             print_fname     ;Filenames given
print_fname4:
        addq.w          #1,D4           ;Count files
        movep.w         31(A0),D1
        move.b          30(A0),D1
        swap            D1              ;File length
        movep.w         29(A0),D1       ;from Intel
        move.b          28(A0),D1       ;to 68000
        add.l           D1,D5           ;for the entire length
                ELSE
        tst.b           (A0)
        beq             hunt_dir4       ;End of the Directories =>
        addq.w          #1,D4           ;one more file found
        move.w          8(A0),D1        ;keep characters 1+2 of the Extension
        cmp.w           #'PR',D1        ;PRG, PRX, etc.
        beq.s           found_file
        cmp.w           #'TO',D1        ;TOS
        beq.s           found_file
        cmp.w           #'TT',D1        ;TTP
        beq.s           found_file
        cmp.w           #'AC',D1        ;ACC, ACX, etc.
        beq.s           found_file
        cmp.w           #'AP',D1        ;APP
        beq.s           found_file
        cmp.w           #'DR',D1        ;DRV (Driver)
        beq.s           found_file
        cmp.w           #'SY',D1        ;SYS (Disk driver!)
        bne             hunt_dir3
found_file:
        move.l          D0,-(SP)
regs            REG D1-D4/D6-A2/A4-A6
        movem.l         regs,-(SP)
        movep.w         27(A0),D0
        move.b          26(A0),D0         ;Cluster in Intel-Format
        move.w          drive(A6),-(SP)   ;actual Drive
        subq.w          #2,D0
        mulu            clsiz(A5),D0      ;times Sectors per Cluster
        add.w           datrec(A5),D0     ;+ first free Sector
        move.w          D0,-(SP)          ;= absolute Sector
        move.w          #1,-(SP)          ;read in a Sector
        pea             sector_buffer(A6) ;to the Buffer
        move.l          #$040000,-(SP)
        trap            #13               ;Rwabs() - Read in a Sector
        lea             14(SP),SP
        tst.l           D0
        bmi             _exit
        lea             sector_buffer(A6),A2
        moveq           #0,D0
        cmpi.w          #$601A,(A2)       ;Program known?
        bne.s           count_loop1       ;No! =>
        lea             28(A2),A0         ;Pointer to the Program start
        cmpi.w          #$487A,(A0)+      ;PEA
        bne.s           no_virus          ;No! =>
        cmpi.w          #$FFFE,(A0)+      ;*-2(PC)
        bne.s           no_virus          ;No! =>
        cmpi.w          #$4EF9,(A0)       ;c't-Virus?
        beq             virus2            ;YES! =>>
        cmpi.l          #$207A0006,(A0)+  ;VCS-Virus?
        bne.s           no_virus          ;No! =>
        cmpi.l          #$4EFB8800,(A0)
        beq             virus1            ;YES! =>>
no_virus:
        moveq           #127,D2
count_loop:
        eor.w           D2,D0             ;Calculate checksum
        sub.w           (A2)+,D0
        addq.w          #1,D0
        dbra            D2,count_loop
        tst.w           D0
        bne.s           count_loop1
        moveq           #213,D0           ;The checksum is NEVER 0!
count_loop1:
        movem.l         (SP),regs         ;Checksum in D0
        tst.l           D0                ;Checksum=0?
        beq             check_it6         ;then no Program! =>

        movea.l         data_base(A6),A1
        bra.s           check_it0
check_it2:
        lea             24(A4),A1         ;the next entry
        movea.l         A2,A0             ;return to the Filenames
check_it0:
        movea.l         A0,A2             ;A0 save
        movea.l         A1,A4             ;A1 save
        tst.l           (A1)              ;Table is empty, i.e. End
        beq.s           check_it3         ;New Entry necessary! =>
        moveq           #4,D1             ;only 10(!) Letters
check_it1:
        cmpm.w          (A1)+,(A0)+       ;compare
        dbne            D1,check_it1
        bne.s           check_it2         ;unequal =>

        lea             10(A4),A1         ;Pointer to the checksum
        moveq           #6,D1             ;maximum of 7 Checksums
check_it5:
        tst.w           (A1)
        beq.s           check_it4         ;Checksum not found
        cmp.w           (A1)+,D0
        dbeq            D1,check_it5      ;continue with compare =>
        lea             -12(A1),A1
        beq.s           check_it8         ;Checksum is ok! =>
check_it4:
        movea.l         A2,A0
        bsr             print_fname       ;Filenames given
        pea             fehler_text(A6)
        bsr             print_line        ;Make report!
        btst            #1,flag(A6)       ;always take it on?
        bne.s           check_it7         ;Yes! =>
        movem.l         D0/D2/A0-A2,-(SP)
        move.w          #7,-(SP)
        trap            #1                ;Wait on a Keypress
        addq.l          #2,SP
        bclr            #5,D0
        move.w          D0,D1
        movem.l         (SP)+,D0/D2/A0-A2
        cmp.b           #'J',D1           ;take it on?
        bne.s           check_it6         ;No! =>
check_it7:
        move.w          D0,(A1)           ;Copy checksum
        addq.w          #1,D5
        bra.s           check_it6

check_it3:
        move.l          (A2)+,(A4)+       ;new entry
        move.l          (A2)+,(A4)+       ;Copy filenames
        move.w          (A2)+,(A4)+       ;(only 10 Letters!)
        move.w          D0,(A4)           ;1st Checksum
        addq.w          #1,D5
        movem.l         (SP),regs
        bsr             print_fname       ;Filenames given
        pea             new_text(A6)
        bsr             print_line
        bra.s           check_it6
check_it8:
        btst            #0,flag(A6)       ;Output?
        bne.s           check_it6         ;No! =>
        movem.l         (SP),regs
        bsr             print_fname       ;Filenames given
        bra.s           check_it6

virus1:
        movem.l         (SP),regs          ;Filenames to A0
        lea             virus1_text(A6),A4 ;VCS-Linkvirus
        bra.s           check_it9
virus2:
        movem.l         (SP),regs          ;Filenames to A0
        lea             virus2_text(A6),A4 ;Milzbrand-Virus
check_it9:
        bsr.s           print_fname        ;Fname given
        pea             virus_text(A6)
        bsr             print_line         ;Make report!
        move.l          A4,-(SP)
        bsr             print_line
        addq.w          #1,virus_count(A6) ;Virus numbers
check_it6:
        movem.l         (SP)+,regs
        move.l          (SP)+,D0
                ENDC
hunt_dir3:
        btst            #4,11(A0)       ;A directory?
        beq.s           hunt_dir2       ;No! =>
        cmpi.b          #$E5,(A0)       ;Deleted?
        beq.s           hunt_dir2       ;Yes! =>
        cmpi.w          #'. ',(A0)
        beq.s           hunt_dir2       ;Ignore Dummy-Entries
        cmpi.w          #'..',(A0)
        beq.s           hunt_dir2
        movem.l         D0/A0/A3,-(SP)
                REPT 8
        move.b          (A0)+,(A3)+
                ENDR
        move.b          #'.',(A3)+
                REPT 3
        move.b          (A0)+,(A3)+     ;Copy to the Path
                ENDR
        addq.l          #1,A0
        move.b          #'\',(A3)+
        move.l          (A0)+,D0        ;Tree length in entries
        movea.l         (A0),A0
        bsr             hunt_dir
        addq.w          #1,D3           ;INC Number of directories
        movem.l         (SP)+,D0/A0/A3
hunt_dir2:
        lea             32(A0),A0       ;=> next entry
        dbra            D0,hunt_dir1    ;through all entries?
hunt_dir4:
        rts
                ENDPART
*************************************************
* Filenames given from A0                       *
*************************************************
                PART 'print_fname'
print_fname:
        movem.l         D0-D2/A0-A3,-(SP)
                REPT 8
        move.b          (A0)+,(A3)+     ;Filenames
                ENDR
        move.b          #'.',(A3)+
                REPT 3
        move.b          (A0)+,(A3)+     ;append to the Path
                ENDR
        btst            #4,(A0)         ;A folder?
        beq.s           print_fname0
        move.b          #'\',(A3)+      ;then also to conclude
print_fname0:
        move.b          #13,(A3)+       ;CR
        move.b          #10,(A3)+       ;LF
        clr.b           (A3)
        lea             path(A6),A3
print_fname1:
        moveq           #0,D0
        move.b          (A3)+,D0        ;fetch character
        beq.s           print_fname2    ;End of the Paths =>
        cmp.b           #' ',D0         ;Ignore spaces
        beq.s           print_fname1    ;next character =>
        cmp.b           #'.',D0         ;Extension reached?
        bne.s           print_fname3    ;No! =>
        cmpi.b          #' ',(A3)       ;it follows a " "?
        beq.s           print_fname1    ;then ignore "." it
print_fname3:
        bsr             chrout          ;the character given
        bra.s           print_fname1
print_fname2:
        movem.l         (SP)+,D0-D2/A0-A3
        rts
                ENDPART
*************************************************
* read_dir() - Read in complete Directory-Tree  *
*             (in A0 it sits, Length in D0)     *
* This routine reads the Root-Directory in      *
* and then calls with each Directory,on the     *
* routine "read_sub_dir", which it itself can   *
* recursively call upon again.                  *
*************************************************
                PART 'read_dir'
read_dir:
        movem.l         D1-D7/A1-A6,-(SP)
        move.w          rdlen(A5),D0    ;Length of the Root-Directory
        mulu            recsiz(A5),D0   ;times Sector size
        bsr             get_mem         ;memory requisition
        movea.l         D0,A4           ;Pointer to the ROOT-Directory
        movea.l         D0,A3           ;Start of the Root-Directory
        move.w          drive(A6),-(SP) ;actual Drive
        move.w          fatrec(A5),D1
        add.w           fsiz(A5),D1
        move.w          D1,-(SP)        ;Start sector of the Root-Directory
        move.w          rdlen(A5),-(SP) ;Length of the FAT
        move.l          A4,-(SP)        ;in the Buffer
        move.l          #$040000,-(SP)
        trap            #13             ;Rwabs() - Read in DIR 
        lea             14(SP),SP
        tst.l           D0
        bmi             _exit
        move.w          rdlen(A5),D7    ;Length of the Root-Directory
        mulu            recsiz(A5),D7   ;times Sector size
        lsr.l           #5,D7           ;\32 Bytes (Entry sizee)
        subq.w          #1,D7           ;Entire number of entries-1
hunt_dir_loop:
        btst            #4,11(A4)       ;A directory?
        beq.s           hunt_dir_loop1  ;No! =>
        cmpi.b          #$E5,(A4)       ;deleted directory?
        beq.s           hunt_dir_loop1  ;Yes! =>
        bsr.s           read_sub_dir
hunt_dir_loop1:
        lea             32(A4),A4       ;next entry
        dbra            D7,hunt_dir_loop ;all Entries
        movea.l         A3,A0           ;Start address of the Directories
        move.w          rdlen(A5),D0    ;Length of the Directories in Bytes
        mulu            recsiz(A5),D0   ;calculate
        lsr.l           #5,D0           ;\32 Bytes (Entry size)
        movem.l         (SP)+,D1-D7/A1-A6
        rts
                ENDPART
*************************************************
* read_sub_dir() - Sub-directories from A4      *
*                  recursively read in,         *
* A4 points to the directory, that it should    *
* be read from. It determines the Cluster       *
* number, then goes on.  With "hunt_dir" ,      *
* "hunt_dir" all the correct entries are there, *
* all of the entries will be chained through    *
* (Pointers) Long words. Placed with it in the  *
* directory entries(32 Bytes long) at Offset    *
* 16 is a Longword, which points to the         *
* directory. At Offset 20 is the maximum number *
* of entries that the directory can possibly    *
* have. This will be given from "hunt_dir"      *
* as likewise required.                         *
*************************************************
                PART 'read_sub_dir'
read_sub_dir:
        movem.l         D0-A6,-(SP)
        movep.w         27(A4),D3
        move.b          26(A4),D3       ;Cluster number in Intel-Format
        movea.l         A4,A3           ;Mark Pointer to the Main directory
        moveq           #0,D5           ;Cluster number of the Sub-Directories
read_sub_dir1:
        moveq           #0,D0
        move.w          clsizb(A5),D0   ;Bytes per Cluster
        bsr             get_mem         ;Requisition memory
        movea.l         D0,A4           ;Pointer to the Cluster
        tst.w           D5
        bne.s           read_sub_dir5
        move.l          A4,16(A3)       ;Pointer to the Sub-Directory
read_sub_dir5:
        move.w          drive(A6),-(SP) ;actual Drive
        move.w          D3,D0           ;actual Cluster number
        subq.w          #2,D0
        mulu            clsiz(A5),D0    ;times Sectors per Cluster
        add.w           datrec(A5),D0   ;+ first free Sector
        move.w          D0,-(SP)        ;= absolute Sector
        move.w          clsiz(A5),-(SP) ;Read in cluster
        move.l          A4,-(SP)        ;to the Buffer
        move.l          #$040000,-(SP)
        trap            #13             ;Rwabs() - Read in cluster 
        lea             14(SP),SP
        tst.l           D0
        bmi             _exit

        move.w          clsizb(A5),D7   ;Bytes per Cluster
        lsr.w           #5,D7           ;\32 Bytes (Entry size)
        subq.w          #1,D7           ;for DBRA
read_sub_dir2:
        btst            #4,11(A4)       ;a directory?
        beq.s           read_sub_dir3   ;No! =>
        cmpi.b          #$E5,(A4)       ;deleted?
        beq.s           read_sub_dir3   ;Yes! =>
        cmpi.w          #'. ',(A4)
        beq.s           read_sub_dir3   ;ignore Dummy-Entries
        cmpi.w          #'..',(A4)
        beq.s           read_sub_dir3
        bsr.s           read_sub_dir
read_sub_dir3:
        lea             32(A4),A4        ;next entry
        dbra            D7,read_sub_dir2 ;all Entries
        addq.w          #1,D5            ;Cluster number of the Sub-Directory
        move.w          D3,D0
        add.w           D0,D0           ;times 2, as pointer to the FAT
        movea.l         fat_adr(A6),A0  ;Pointer: decoded FAT
        move.w          0(A0,D0.w),D3   ;Number of the following clusters
        bpl.s           read_sub_dir1   ;End? No! =>

        mulu            clsizb(A5),D5   ;Bytes per Cluster
        lsr.l           #5,D5           ;Size of the Sub-Directory in Bytes
        move.l          D5,12(A3)       ;Number of possible entries
        movem.l         (SP)+,D0-A6
        rts
                ENDPART
*************************************************
* Report Drive in D0 as actual Drive, read in   *
* FAT. The memory space free will be returned   *
* in  D0.                                       *
* IMPORTANT: A5 points with "set_drive" ALWAYS  *
*      to the BPB of the actual Drives.         *
*      The outcome of it will be in "read_dir". *
*************************************************
                PART 'set_drive'
set_drive:
        movem.l         D1-A4,-(SP)
        move.w          D0,drive(A6)    ;set actual Drive
        bsr.s           get_bpb         ;fetch Bios Parameter Block-Address

        moveq           #0,D0
        move.w          numcl(A5),D0
        add.l           D0,D0           ;Entire number of the Clusters*2
        bsr             get_mem         ;Requisition memory
        move.l          D0,fat_adr(A6)

        move.w          fsiz(A5),D0     ;Length of the FAT
        mulu            recsiz(A5),D0   ;times Bytes per Sector
        bsr             get_mem         ;Requisition memory
        move.l          D0,fat_buffer(A6)

        move.w          drive(A6),-(SP)  ;actual Drive
        move.w          fatrec(A5),-(SP) ;Start of the 2nd FAT
        move.w          fsiz(A5),-(SP)   ;Length of the FAT
        move.l          fat_buffer(A6),-(SP)
        move.l          #$040000,-(SP)
        trap            #13              ;2nd FAT completely read in.
        lea             14(SP),SP
        tst.l           D0
        bmi             _exit

        bsr.s           change_fat      ;FAT in 68000-Format

        movea.l         fat_adr(A6),A0  ;Pointer: decoded FAT
        addq.l          #4,A0           ;ignore first 2 Clusters
        move.w          numcl(A5),D1
        subq.w          #3,D1           ;subtract 2 Clusters (DBRA!)
        moveq           #0,D0           ;Number of free Clusters
set_drive1:
        tst.w           (A0)+           ;a free Cluster?
        bne.s           set_drive2      ;No! =>
        addq.w          #1,D0           ;INC free Cluster
set_drive2:
        dbra            D1,set_drive1   ;all counted?
        mulu            clsizb(A5),D0   ;times Bytes per Cluster
        movem.l         (SP)+,D1-A4
        rts
                ENDPART
*************************************************
* BPB of the actual Drives to A5                *
*************************************************
                PART 'get_bpb'
get_bpb:
        move.w          drive(A6),-(SP)
        move.w          #7,-(SP)
        trap            #13             ;Getbpb(drive)
        addq.l          #4,SP
        move.l          D0,act_bpb(A6)
        beq             _exit
        movea.l         D0,A5           ;Pointer to the BPB
        rts
                ENDPART
*************************************************
* FAT of the 12-bit- i.e. 16-bit-Intel-Format   *
* in 16-bit-68000-Format                        *
*************************************************
                PART 'change_fat'
change_fat:
        movea.l         fat_buffer(A6),A0 ;Pointer: FAT
        movea.l         fat_adr(A6),A1    ;Pointer: decoded FAT
        move.w          fsiz(A5),D0       ;Length of the FAT
        mulu            recsiz(A5),D0     ;times Bytes per Sector
        move.w          bflags(A5),D1     ;Fetch Flags
        btst            #0,D1             ;12-bit-FAT?
        beq.s           change_fat2       ;Yes! =>
        lsr.w           #1,D0             ;Number of Words
        subq.w          #1,D0             ;for DBRA
change_fat1:
        movep.w         1(A0),D1
        move.b          (A0),D1         ;Intel-transformation to 16-bit-FAT
        addq.l          #2,A0
        move.w          D1,(A1)+
        dbra            D0,change_fat1
        rts
change_fat2:
        divu            #3,D0           ;Change 12-bit-FAT
change_fat3:
        movep.w         1(A0),D1
        move.b          (A0),D1         ;Fetch Intel-Word 
        and.w           #$0FFF,D1       ;Bit 12-15 are unimportant
        cmp.w           #$0FF0,D1       ;Number $FF0-$FFF?
        blo.s           change_fat4     ;No! =>
        or.w            #$F000,D1       ;extend sign
change_fat4:
        move.w          D1,(A1)+        ;Mark cluster
        movep.w         2(A0),D1
        move.b          1(A0),D1        ;Fetch Intel-Word 
        lsr.w           #4,D1           ;Bit 0-3 are unimportant
        cmp.w           #$0FF0,D1       ;Number $FF0-$FFF?
        blo.s           change_fat5     ;No! =>
        or.w            #$F000,D1       ;Extend sign
change_fat5:
        move.w          D1,(A1)+        ;Mark cluster 
        addq.l          #3,A0           ;3 Bytes are ready
        dbra            D0,change_fat3  ;already all Triple?
        rts
                ENDPART
*************************************************
* D0=get_mem(Byte number in D0)                 *
*    requisition memory from the stack.         *
*************************************************
                PART 'get_mem'
get_mem:
        move.l          A0,-(SP)
        addq.l          #1,D0               ;EVEN
        and.b           #-2,D0
        move.l          stack_pnt(A6),D1    ;old Stack-Pointer
        exg             D0,D1
        add.l           D1,stack_pnt(A6)    ;Place on the stack
        movea.l         start-256+4(PC),A0  ;End of memory
        cmpa.l          stack_pnt(A6),A0    ;Upper limit of memory?
        blo             _exit               ;Yes! => exit =>
        movea.l         (SP)+,A0
        rts
                ENDPART
*************************************************
* From here: the DATA-Segment                   *
*************************************************
                DATA
                IF virus
files_text:
                DC.B ' Files, ',0
files_text2:
                DC.B ' altered e.g. new Files.',13,10,0
folders_text:
                DC.B ' Folder available.'
                DC.B ' Write to it?',13,10,0
init_text:
                DC.B 27,'E',27,'e'
                DC.B 'LVF V1.5 (Link-Virus-Finder)',13,10
                DC.B '½1989 by ä-soft,'
                DC.B ' Markus Fritze',13,10,10,0
error_text:
                DC.B 'Checksum is incorrect'
                DC.B ' (accept?)',13,10,0
virus_text:
                DC.B 7,'File contains '
                DC.B ' probably ',0
virus1_text:
                DC.B 'a VCS-Linkvirus!',13,10,7,0
virus2_text:
                DC.B 'the Milzbrand-Linkvirus!',13,10,7,0
virus_text:
                DC.B ' possibly contaminated'
                DC.B ' Files found!',7,13,10,0
new_text:
                DC.B 'File has been added.',13,10,0
fname:
                DC.B 'LVF.DAT',0
                ELSE
files_text:
                DC.B ' Files with altogether ',0
files_text2:
                DC.B ' Bytes found.',13,10,0
folders_text:
                DC.B ' Folders available.'
                DC.B ' Press a Key.',13,10,0
init_text:
                DC.B 27,'E',27,'e'
                DC.B 'FFF V1.5 (Fast-File-Finder)',13,10
                DC.B '½1989 by ä-soft, Markus Fritze'
                DC.B 13,10,10,0
                ENDC
exit_text:      DC.B 27,'E',27,'f',0
drive_text:     DC.B 'Drive ',0
drive_text2:    DC.B ': (',0
drive_text3:    DC.B ' Bytes free.)',13,10,0

**********************************************
* From here: the BSS-Segment                 *
**********************************************
                BSS
                DS.L 1024           ;4k Stack for recursive search
own_stack:      DS.L 0
drive:          DS.W 1              ;actual Drive
act_bpb:        DS.L 1              ;Pointer: BPB of the actual Drives
fat_buffer:     DS.L 1              ;Address of the FAT read in
fat_adr:        DS.L 1              ;Address of the decoded FAT
virus_count:    DS.W 1              ;Number of Viruses found
flag:           DS.B 1              ;Bit 0=1: no File output
;Bit 1=1: new Program undertaken
                EVEN
path:           DS.B 256            ;Space for the search path
stack_pnt:       DS.L 1
                IF virus
data_base:      DS.L 1              ;Pointer: File-Data in RAM
data_buff:      DS.B 24*max_prgs    ;Program-Buffer
sector_buffer:  DS.B max_sectorsize ;Sector buffer.
                ELSE
search_mask:    DS.B 12             ;Search mask (Joker)
search_chars:   DS.B 12             ;Search characters
                ENDC
stack:          DS.L 0              ;free memory to here
                END
