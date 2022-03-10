
rsc:
header  dc.w 0,objects-rsc,teds-rsc,iconblks-rsc
        dc.w 0,freestrings-rsc,$0024,icondata-rsc
        dc.w 0,trees-rsc
        dc.w 35,3,2,1,0,1,0,rscend-rsc

strings:
str0  dc.b " Desk ",0
str1  dc.b " File ",0
str2  dc.b " Other ",0
str3  dc.b "  About WERCTEST...",0
str4  dc.b "----------------------",0
str5  dc.b "  Desk Accessory 1  ",0
str6  dc.b "  Desk Accessory 2  ",0
str7  dc.b "  Desk Accessory 3  ",0
str8  dc.b "  Desk Accessory 4  ",0
str9  dc.b "  Desk Accessory 5  ",0
str10  dc.b "  Desk Accessory 6  ",0
str11  dc.b "  Quit",0
str12  dc.b "  Check me",0
str13  dc.b "-------------------",0
str14  dc.b "  Dialog box...",0
str15  dc.b "  Install desktop",0
str16  dc.b " A Test Dialog Box ",0
str17  dc.b "OK",0
str18  dc.b "Cancel",0
str19  dc.b "JUNKJUNK",0
str20  dc.b "Editable text: ________",0
str21  dc.b "X",0
str22  dc.b "Radio #1",0
str23  dc.b "Radio #2",0
str24  dc.b "Radio #3",0
str25  dc.b "Tiny text...",0
str26  dc.b "Floppy Disk",0
str27  dc.b "[2][Simple Test Program][ OK ]",0
 even
null dc.w 0

icondata:
msk0  dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
        dc.w $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
img0  dc.w $0,$0,$7FFF,$FFFE,$4400,$0042,$4400,$0F42
        dc.w $4400,$0942,$4400,$0942,$4400,$0942,$4400,$0942
        dc.w $4400,$0942,$4400,$0F42,$4400,$0042,$47FF,$FFC2
        dc.w $4000,$0002,$4000,$0002,$47FF,$FFF2,$4400,$0012
        dc.w $4400,$0012,$4400,$0012,$4400,$0012,$4400,$0012
        dc.w $4400,$0012,$4400,$0012,$4400,$0012,$4400,$0012
        dc.w $5400,$0012,$4400,$0012,$7FFF,$FFFE,$0,$0

freestrings:
        dc.l str27-rsc

iconblks:
iblk0  dc.l msk0-rsc,img0-rsc,str26-rsc
        dc.w $1051,$000D,$0012
        dc.w $001C,$0006,$0020,$001C
        dc.w $000D,$0026,$0042,$0006

teds:
ted0  dc.l str19-rsc,str20-rsc,str21-rsc
        dc.w 3,6,0,$1180,0,-1,9,24
ted1  dc.l str25-rsc,null-rsc,null-rsc
        dc.w 5,6,0,$1180,0,-1,13,1

objects:
tree0:
obj0_0  dc.w -1,1,6,25,0,0,$0,$0,$0,$0,$00A0,$0019
obj0_1  dc.w 6,2,2,20,0,0,$0,$1100,$0,$0,$00A0,$0201
obj0_2  dc.w 1,3,5,25,0,0,$0,$0,$0002,$0,$0013,$0301
obj0_3  dc.w 4,-1,-1,32,0,0
        dc.l str0-rsc
        dc.w $0,$0,$0006,$0301
obj0_4  dc.w 5,-1,-1,32,0,0
        dc.l str1-rsc
        dc.w $0006,$0,$0006,$0301
obj0_5  dc.w 2,-1,-1,32,0,0
        dc.l str2-rsc
        dc.w $000C,$0,$0007,$0301
obj0_6  dc.w 0,7,18,25,0,0,$0,$0,$0,$0301,$00A0,$0013
obj0_7  dc.w 16,8,15,20,0,0,$00FF,$1100,$0002,$0,$0016,$0008
obj0_8  dc.w 9,-1,-1,28,0,0
        dc.l str3-rsc
        dc.w $0,$0,$0016,$0001
obj0_9  dc.w 10,-1,-1,28,0,8
        dc.l str4-rsc
        dc.w $0,$0001,$0016,$0001
obj0_10  dc.w 11,-1,-1,28,0,0
        dc.l str5-rsc
        dc.w $0,$0002,$0016,$0001
obj0_11  dc.w 12,-1,-1,28,0,0
        dc.l str6-rsc
        dc.w $0,$0003,$0016,$0001
obj0_12  dc.w 13,-1,-1,28,0,0
        dc.l str7-rsc
        dc.w $0,$0004,$0016,$0001
obj0_13  dc.w 14,-1,-1,28,0,0
        dc.l str8-rsc
        dc.w $0,$0005,$0016,$0001
obj0_14  dc.w 15,-1,-1,28,0,0
        dc.l str9-rsc
        dc.w $0,$0006,$0016,$0001
obj0_15  dc.w 7,-1,-1,28,0,0
        dc.l str10-rsc
        dc.w $0,$0007,$0016,$0001
obj0_16  dc.w 18,17,17,20,0,0,$00FF,$1100,$0008,$0,$0007,$0001
obj0_17  dc.w 16,-1,-1,28,0,0
        dc.l str11-rsc
        dc.w $0,$0,$0007,$0001
obj0_18  dc.w 6,19,22,20,0,0,$00FF,$1000,$000E,$0,$0013,$0004
obj0_19  dc.w 20,-1,-1,28,0,0
        dc.l str12-rsc
        dc.w $0,$0,$0013,$0001
obj0_20  dc.w 21,-1,-1,28,0,8
        dc.l str13-rsc
        dc.w $0,$0001,$0013,$0001
obj0_21  dc.w 22,-1,-1,28,0,0
        dc.l str14-rsc
        dc.w $0,$0002,$0013,$0001
obj0_22  dc.w 18,-1,-1,28,32,0
        dc.l str15-rsc
        dc.w $0,$0003,$0013,$0001
tree1:
obj1_0  dc.w -1,1,9,20,0,16,$0002,$1100,$0701,$0201,$002D,$0011
obj1_1  dc.w 2,-1,-1,28,0,16
        dc.l str16-rsc
        dc.w $000D,$0001,$0013,$0001
obj1_2  dc.w 3,-1,-1,26,7,0
        dc.l str17-rsc
        dc.w $0020,$000E,$0007,$0001
obj1_3  dc.w 4,-1,-1,26,5,0
        dc.l str18-rsc
        dc.w $0004,$000E,$0007,$0001
obj1_4  dc.w 5,-1,-1,29,8,0
        dc.l ted0-rsc
        dc.w $0004,$0005,$0018,$0001
obj1_5  dc.w 9,6,8,25,0,0,$0001,$1100,$0004,$0008,$0025,$0003
obj1_6  dc.w 7,-1,-1,26,17,1
        dc.l str22-rsc
        dc.w $0002,$0001,$0009,$0001
obj1_7  dc.w 8,-1,-1,26,17,0
        dc.l str23-rsc
        dc.w $000E,$0001,$0009,$0001
obj1_8  dc.w 5,-1,-1,26,17,0
        dc.l str24-rsc
        dc.w $001A,$0001,$0009,$0001
obj1_9  dc.w 0,-1,-1,21,32,0
        dc.l ted1-rsc
        dc.w $0012,$000E,$000D,$0001
tree2:
obj2_0  dc.w -1,1,1,20,0,0,$0,$1151,$0001,$0001,$0034,$0009
obj2_1  dc.w 0,-1,-1,31,32,0
        dc.l iblk0-rsc
        dc.w $0003,$0003,$2007,$2001


trees  dc.l tree0-rsc,tree1-rsc,tree2-rsc

rscend:
 even
 text
