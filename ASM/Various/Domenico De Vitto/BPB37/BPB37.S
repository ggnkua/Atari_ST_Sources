program
 bsr setscreen
 bsr getdrive
 bsr readboot
 bsr interpret
 bsr extrainfo
 bsr pressanykeytoexit
 bsr resetscreen
 clr.w -(sp)
 trap #1


setscreen
 move.w #4,-(sp)
 trap #14		* get screen mode in d0
 addq.l #2,sp
 cmp.w #1,d0
 bne dontchgmode
 move.w d0,screenmode	* if med-res save 1 in screenmode
 move.w #0,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move.w #5,-(sp)
 trap #14		* change to mode 0
 add.l #12,sp
 move.l #colregs,-(sp)
 move.w #6,-(sp)
 trap #14
 addq.l #6,sp
dontchgmode
 bsr print
 dc.b 27,"E","BPB-37 by Domenico De Vitto",0
 rts

getdrive 
 move.w #10,-(sp)
 trap #13
 addq.l #2,sp
 move.l d0,drivemap
 bsr showdrives
 bsr getdrv
 rts
showdrives
 bsr print
 dc.b 10,13,"Drives Available :",0
 even
 moveq #0,d7
drvloop
 bsr checkdrive
 tst d0
 bne nextdrv
 moveq #65,d0
 add.b d7,d0
 bsr printchr
nextdrv
 addq #1,d7
 btst #5,d7
 beq drvloop
 rts

getdrv
 bsr print
 dc.b 10,13,"Enter Drive Letter :",0
 even
gdrvloop
 bsr getkey
 bsr convertlu
 sub.b #65,d0
 bmi gdrvloop
 cmp #31,d0
 bpl gdrvloop
 exg d0,d7
 bsr checkdrive
 bne gdrvloop
 move.w d7,driveselect
 exg d0,d7
 add.b #65,d0
 bsr printchr
 rts

readboot
 move.w driveselect,-(sp)
 move.w #0,-(sp)
 move.w #1,-(sp)
 move.l #buffer,-(sp)
 move.w #2,-(sp) * must be read 2 in order to catch disk changes.
 move.w #4,-(sp)
 trap #13
 add.l #14,sp
 rts

interpret
 tst d0
 beq okdrive
 bsr print
 dc.b 10,13,"Error Reading Drive",0
 even
 rts
okdrive
 bsr print
 dc.b 10,13,27,"p","         From the Boot sector :         ",27,"q"
 dc.b 10,13,"Branch to boot code :$",0
 even
 move.w buffer(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Volume Serial # :$",0
 even
 move.w buffer+8(pc),d0
 bsr hexword86
 move.b buffer+10(pc),d0
 bsr hexprint
 bsr print
 dc.b 10,13,"Bytes per sector :$",0
 even
 move.l buffer+10(pc),d0
 ror.l #8,d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Sectors per Cluster :$",0
 even
 move.w buffer+12(pc),d0
 ror.w #8,d0
 bsr hexprint
 bsr print
 dc.b 10,13,"Reserved Sectors (inc. boot) :$",0
 even
 move.w buffer+14(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"File Allocation Tables (FATs):$",0
 even
 move.b buffer+16(pc),d0
 bsr hexprint
 bsr print
 dc.b 10,13,"Max Root Directory entries :$",0
 even
 move.l buffer+16(pc),d0
 ror.l #8,d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Sectors (inc reserved) :$",0
 even
 move.l buffer+18(pc),d0
 ror.l #8,d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Media Descripter (not used by TOS) :$",0
 even
 move.b buffer+21(pc),d0
 bsr hexprint
 bsr print
 dc.b 10,13,"Sectors per FAT :$",0
 even
 move.w buffer+22(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Sectors per Track :$",0
 even
 move.w buffer+24(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Sides on media :$",0
 even
 move.w buffer+26(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Hidden Sectors :$",0
 even
 move.w buffer+28(pc),d0
 bsr hexword86
 bsr print
 dc.b 10,13,"Calculated dir sector :$",0
 even


 moveq #0,d0
 move.b buffer+16(pc),d0
 move.w buffer+22(pc),d1
 ror.w #8,d1
 mulu d1,d0 
 move.w buffer+14(pc),d1
 ror.w #8,d1
 add.l d1,d0
 rol.l #8,d0
 bsr hexprint
 rol.l #8,d0
 bsr hexprint		* print longword of start sect of dir
 rol.l #8,d0
 bsr hexprint
 rol.l #8,d0
 bsr hexprint
 rts

extrainfo
 move.w driveselect(pc),d0
 addq.w #1,d0
 move.w d0,-(sp)
 pea driveextra(pc)
 move.w #54,-(sp)
 trap #1
 addq.l #8,sp
 bsr print
 dc.b 10,13,27,"p","   From the Operating System (TOS) :    ",27,"q"
 dc.b 10,13,"Total Clusters :$",0
 move.l driveextra+4(pc),d0
 bsr hexlongst
 bsr print
 dc.b 10,13,"Free Clusters :$",0
 move.l driveextra(pc),d0
 bsr hexlongst
 bsr print
 dc.b 10,13,"Sectors per Cluster :$",0
 move.l driveextra+12(pc),d0
 bsr hexlongst
 bsr print
 dc.b 10,13,"Bytes per Sector :$",0
 move.l driveextra+8(pc),d0
 bsr hexlongst
 bsr freespace
 rts

freespace
 jsr print
 dc.b 10,13,"Therefore Free space = ",0
 even

 move.l driveextra(pc),d0 	* no free clusters
 move.l driveextra+12(pc),d6	* sects per cluster
 mulu driveextra+10(pc),d6
 mulu d6,d0
 divu #$400,d0		* mulu and print free space
 move.w d0,digibyte
 jsr digits
 jsr print
 dc.b "K of ",0

 move.l driveextra+4(pc),d0 	* total no of clusters
 move.l driveextra+12(pc),d6	* sects per cluster
 mulu driveextra+10(pc),d6
 mulu d6,d0
 divu #$400,d0
 move.w d0,digibyte
 jsr digits
 jsr print
 dc.b " total",0
 rts

pressanykeytoexit
 bsr print
 dc.b 10,13,27,"p","         Press any key to exit          ",27,"q",0
 even
 bsr getkey
 rts

resetscreen
 tst screenmode
 beq resetscreenexit
 move.w #1,-(sp)
 move.l #-1,-(sp)
 move.l #-1,-(sp)
 move.w #5,-(sp)
 trap #14
 add.l #12,sp
 move.l #colregs,-(sp)
 move.w #6,-(sp)
 trap #14
 addq.l #6,sp
resetscreenexit
 rts


***************************************

*** digital word print ,word in digibyte bsr digits
digits
 moveq.l #0,d7
 move.w digibyte,d7
 divu #10000,d7
 bsr digiprint 
 moveq.l #0,d7
 move.w digibyte,d7
 divu #1000,d7
 bsr digiprint 
 moveq.l #0,d7
 move.w digibyte,d7
 divu #100,d7
 bsr digiprint 
 moveq.l #0,d7
 move.w digibyte,d7
 divu #10,d7
 bsr digiprint 
 move.w #$ffff,digiflag
 move.w digibyte,d7
 swap d7
 bsr digiprint
 clr.w digiflag
 rts
digiprint
 swap d7
 move.w d7,digibyte
 swap d7
 tst.b d7
 beq digizero
 move.w #$ffff,digiflag
digiret1
 add.w #"0",d7
digiret2
 move.w d7,-(sp)
 move.w #2,-(sp)
 trap #1
 addq.l #4,sp
 rts
digizero
 tst digiflag
 bne digiret1
 rts	 		* The end of VERY long digital print routine !
digiflag
 dc.w 0 
digibyte
 dc.w 0
getkey
 move.l #$20002,-(SP)
 trap   #13
 add.l #4,SP
 rts

hexlongst
 move.l d0,-(sp)
 rol.l #8,d0
 bsr hexprint
 rol.l #8,d0
 bsr hexprint
 rol.l #8,d0
 bsr hexprint
 rol.l #8,d0
 bsr hexprint
 move.l (sp)+,d0
 rts
 

hexprint
 move.l d0,-(sp)
 asr.l #4,d0
 bsr hpnext
 move.l (sp),d0
 bsr hpnext
 move.l (sp)+,d0
 rts
hpnext
 andi.l #$f,d0
 cmpi.b #10,d0
 bmi hpnext2
 addq.b #7,d0
hpnext2
 addi.b #48,d0
 move.w d0,-(sp)
 move.w #2,-(sp)
 trap #1
 addq.l #4,sp
 rts

hexword86
 move.l d0,-(sp)
 bsr hexprint
 ror.l #8,d0
 bsr hexprint
 move.l (sp)+,d0
 rts


print
 move.l (sp),-(sp)
 move.w #9,-(sp)
 trap #1
 addq.l #6,sp
 move.l (sp)+,a0
ploop
 move.w (a0),d0
 tst.b d0
 beq pend
 asr.w #8,d0
 tst.b d0
 beq pend
  adda #2,a0
 bra ploop
pend
 adda #2,a0
 move.l a0,-(sp)
 rts

printchr
 move.l d0,-(sp)
 and.l #$ff,d0
 move.w d0,-(sp)
 move.w #2,-(sp)
 move.w #3,-(sp)
 trap #13
 add.l #6,sp
 move.l (sp)+,d0
 rts

checkdrive
 move.l drivemap,d6
 btst d7,d6		* drv to check = d7
 beq checkdrivexit
 moveq #0,d0		* ret code in d0
 rts			* -1 = not there, 0=ok
checkdrivexit
 moveq #-1,d0
 rts

convertlu
 cmp.b #"a",d0		* if d0>=asc "a" subtract 32 from it
 bmi convertexit	* eg a => A , z => Z 
 sub.b #32,d0
convertexit
 rts

driveextra
 ds.l 4

drivemap
 dc.l 0
driveselect
 dc.w 0
colour0
 dc.w 16
screenmode
 dc.w 0
colregs
 dc.l $ffff3f00
 dc.l $f8f80000
 ds.l 6

buffer