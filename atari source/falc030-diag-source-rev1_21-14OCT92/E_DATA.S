.if !TOS
	.globl Bltmsg,Blt,debug,loopt,loopt1,flag,msgsave,intword,intword6
	.globl blkstart,blkend,savekey,spurisave,msgsave1,longsave,wordsave
	.globl int6save,inttmrsave,intsave0,besave0,stacksave0,spsave0
	.globl pcsave0,srsave0,intsave,besave,spsave,pcsave,srsave
	.globl loopsave,accaddr,passw,addrw,passl,faill,failw,bytecnt,mapdt
	.globl intlev,spc_sav,erflge,imra_sv,iera_sv,ipra_sv,isra_sv,imra_save
	.globl imrb_save,iera_save,isra_save,ipra_save,tadr_save,tacr_save
	.globl expand_sv,excepsave,vectsave,handle,dta,ram4k,buf_dma,under_sp
	.globl buf_1dma,over_sp,buf_dma,under_sp,buf_1dma,over_sp,savectl
.endif
.even
Bltmsg: ds.l 1
Blt:    ds.l 1
debug:  ds.w 1		; TLE 7/23/92
loopt:  ds.w 1
loopt1:  ds.w 1
loopt2:  ds.w 1
loopt3:  ds.w 1
loopt4:  ds.w 1
loopt5:  ds.w 1
flag:   ds.w  1
intword:   ds.w  1
intword6:   ds.w  1
cur_x:    ds.w  1
cur_y:    ds.w  1

blkstart: ds.l 1
blkend: ds.l 1
savekey:  ds.l  1
spurisave:  ds.l  1
msgsave1:  ds.l  1
msgsave:  ds.l  1
longsave: ds.l  1
wordsave: ds.w  1
int6save: ds.l  1
inttmrsave: ds.l 1
intsave0:  ds.l  1
besave0:   ds.l  1
stacksave0: ds.l 1
spsave0:    ds.l 1
pcsave0:    ds.l 1
srsave0:    ds.w 1
intsave:   ds.l  1
besave:   ds.l  1

.if TOS=1
stacksave: ds.l 1
.endif

spsave:    ds.l 1
pcsave:    ds.l 1
srsave:    ds.w 1
loopsave:  ds.l 1
accaddr:  ds.l  1
passw: ds.w     1
addrw: ds.w     1
passl: ds.l     1
faill: ds.l     1
failw: ds.w     1
bytecnt: ds.l   1
mapdt:   ds.l   1
mapbase:  ds.l  1
maplo:  ds.l  1
maphi:  ds.b  1
intlev:  ds.b   1	; save interrupt test level
spc_sav: ds.b   1 	; save SPControl byte before testing expansion port 
savectl: ds.b   1
erflge:  ds.b   1
imra_sv:  ds.b   1
iera_sv:  ds.b   1
ipra_sv:  ds.b   1
isra_sv:  ds.b   1
imra_save: ds.b 1
imrb_save: ds.b 1
iera_save: ds.b 1
isra_save: ds.b 1
ipra_save: ds.b 1
tadr_save: ds.b 1
tacr_save: ds.b 1
expand_sv: ds.b 1
.even
excepsave: ds.l 7
vectsave: ds.l  256    
handle: ds.w    1
dta:    ds.b    44
	ds.l	1
ram4k:
.if HOST=0
buf_dma:   ds.b  1024*32
under_sp:   ds.b  4
buf_1dma:   ds.b  1024*32
over_sp:    ds.b  4
.else
.abs   $50000
buf_dma:   ds.b  1024*32
.abs   $60000
under_sp:   ds.b  4
buf_1dma:   ds.b  1024*32
over_sp:    ds.b  4

.endif
