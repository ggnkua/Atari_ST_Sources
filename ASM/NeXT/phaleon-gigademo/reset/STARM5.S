tempo = 1

* pour les etoiles
nb_star =70 *300
precision = 20
max_speed = 10
nb_vbl_pre = 1
xmin = 16
xmax = xmin+288
ymin = 0
ymax = ymin+200

 pea debut
 move #$26,-(sp)
 trap #14
 addq #6,sp
 clr -(sp)
 trap #1

 include starrese.s

debut
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,s_colors
 move #0,-(sp)
 pea -1 
 pea -1
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,s_ecr
 move.l #ecran+256,d0
 sf d0
 move.l d0,a6
 move.l d0,ecr
 add.l #32000,d0
 move.l d0,ecrb
 move #(64000/4)-1,d7
.cleen
 clr.l (a6)+
 dbra d7,.cleen

 bsr init_all

.loop_vbl
 vsync
 ifne tempo
 move #$4,$ffff8240.w
 endc
 bsr star
 change_ecr
 ifne tempo
 move #$0,$ffff8240.w
 endc
 cmp.b #$39,$fffffc02.w
 bne .loop_vbl

 move #1,-(sp)
 move.l s_ecr,-(sp)
 move.l s_ecr,-(sp)
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 movem.l s_colors,d0-d7
 movem.l d0-d7,$ffff8240.w
 rts


 section bss
s_colors ds.l 8
s_ecr ds.l 1
ecr ds.l 1
ecrb ds.l 1
var_random ds.l 1

eras_buf1 ds.l 1
eras_buf2 ds.l 1
eras ds.l nb_star*2
buffer_star ds.l 6*nb_star
merde ds.l 2
tablex ds.w precision*(320+2*max_speed)
tabley ds.w precision*(200+2*max_speed)
ecran ds.l (32000*2)+256