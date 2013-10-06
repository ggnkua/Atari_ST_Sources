
;The one and only.
;Ett hypa„kta kopilerad basicblock garanterat eye-destroying.
;Inte var da' man ser en s†'n.
;™h b†de topbordern och l†gbordern „r v„ck.
;men jag hoppas att det g†r bar en d† 
; mvh marcer of tln



 pea start
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 
 clr.w -(sp)
 trap #1                           ;quit
 
start:
 clr.b $484                        ;no keyclick
 clr.b $ff8260                     ;low-rez
 
 pea mouse_off
 move.w #1,-(sp)
 move.w #25,-(sp)
 trap #14
 addq.l #8,sp


 move.l #screenarea,d0
 clr.b d0                          ;even with 256
 move.l d0,scbuf
 lsr.l #8,d0
 move.b d0,$ff8203
 lsr.w #8,d0
 move.b d0,$ff8201                 ;set screenpointer

 move.l scbuf,a0
 lea pivlink+34,a1
 move.w #7999,d0
 
first_pic:
 move.l (a1)+,(a0)+
 dbra d0,first_pic
 
 move.w #3199,d0
 lea pivlink2+34,a1
 
second_pic:
 move.l (a1)+,(a0)+
 dbra d0,second_pic
 
 lea save_pal,a0
 lea pivlink+2,a2
 lea $ffff8240,a1
 move.w #7,d1

svartnar: 
 move.l (a1),(a0)+
 move.l (a2)+,(a1)+
 dbra d1,svartnar
  
 move.l $120,save_120       ;save timer B
 move.l $70,save_70         ;save vbi
 
 move.w #$2700,sr          ;turn off interrupts(big deal they are non-maskable)

 lea $fffa00,a0                  ;get address to mfp
 move #7,d0
 lea save_mfp,a1

mfp_saver:
 move.l (a0)+,(a1)+              ;save mfp registers
 dbra d0,mfp_saver 
 
 move.l #dummy,$120

 move.b #$1,$fffa07              ;enable timer B
 clr.b $fffa09                   ;no other enabled
 move.b #$1,$fffa13              ;mask timer B
 clr.b $fffa15                   ;no other masks
 move.b #8,$fffa1b               ;event count mode
 move.b #1,$fffa21               ;every time
 bset.b #3,$fffa17               ;software-end-of-interrupt-mode
 
 move.l #vbi,$70   ;holy mackerel(ett kopilerat basicblock)
 move.w #$2000,sr

oves_h”rn:
 cmp.b #$39,$fffc02
 bne oves_h”rn
 
 move.w #$2700,sr

 lea $fffa00,a0                  ;get address to mfp
 move #7,d0
 lea save_mfp,a1

mfp_ret:
 move.l (a1)+,(a0)+              ;save mfp registers
 dbra d0,mfp_ret  

 move.l #dummy,$120
 move.l save_70,$70
 move.l save_120,$120

re_install:
 lea $ffff8240,a0   
 lea save_pal,a1
 move.w #7,d0
 
ljusnar:
 move.l (a1)+,(a0)+
 dbra d0,ljusnar
 
 pea mouse_on
 move.w #1,-(sp)
 move.w #25,-(sp)
 trap #14
 addq.l #8,sp
  
 rts
 
dummy:
 bclr.b #0,$fffa0f
 rte                 ;smartiest interrupt ever written
 
 
bau2:
 
vbi	
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE	SR,-(A7)
	MOVE.W	#$2700,SR            ;no interrupts allowed
	MOVE.W	#1416,D0
L3F11A	DBF	D0,L3F11A            ;grov synkning

	MOVE.B	#$FC,$FFFF820A       ;60 hz internal synchronization
	MOVE.W	#3,D0

L3F12A	NOP
	DBF	D0,L3F12A
	
	MOVE.B	#$FE,$FFFF820A      ;50 hz
	MOVE.W	(A7)+,SR
	MOVE.B	#0,$FFFFFA1B        ;timer B off
	MOVE.B	#1,$FFFFFA21        ;data value 1
	MOVE.L	#L3F652,$120.W      ;address to timer B
	MOVE.B	#8,$FFFFFA1B        ;event count mode
L3F59A	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTE
	
L3F652	CLR.B	$FFFFFA1B              ; first timer B
	MOVE.B	#27,$FFFFFA21          ;27 i data register
	MOVE.L	#L3F728,$120.W         ;ny interrupt
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE
	
L3F728	CLR.B	$FFFFFA1B             ;2nd timer B
	MOVE.B	#200,$FFFFFA21
	MOVE.L	#L3F7A0,$120.W        ;new interrupt
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE
	
L3F7A0	CLR.B	$FFFFFA1B             ;3rd interrupt
	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFFFA21,A0
	MOVE.B	#201,(A0)
	MOVE.B	#8,$FFFFFA1B
	MOVE.B	(A0),D0
L3F7BE	CMP.B	(A0),D0
	BEQ	L3F7BE
	MOVE.B	#$FC,$FFFF820A         ;60 hz
	MOVE.W	#2,D0
L3F7D0	NOP
	DBF	D0,L3F7D0
	MOVE.B	#$FE,$FFFF820A          ;50 hz
	MOVEM.L	(A7)+,D0/A0
	MOVE.B	#0,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE
 
cool_ste_pal:
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706 
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706
 dc.w $707,$717,$727,$737,$747,$757,$767,$766,$776,$775,$774,$773,$772
 dc.w $771,$770,$760,$750,$740,$730,$720,$710,$700,$701,$702,$703,$704
 dc.w $705,$706

mouse_on:
 dc.b $8,$16
 
mouse_off:
 dc.b $1a,$12

pivlink:
 incbin "A:\bild.PI1"
 
 even
 
pivlink2:
 incbin "A:\bild.PI1"

 even

 section bss 
 
save_120:
 ds.l 1
 
save_70:
 ds.l 1  
 
save_pal:
 ds.l 8 

save_mfp:
 ds.l 8
  
scbuf:
 ds.l 2  
  
 ds.b 256
screenarea:
 ds.b 44800                 ;med plats f”r top- och l†gborder
  