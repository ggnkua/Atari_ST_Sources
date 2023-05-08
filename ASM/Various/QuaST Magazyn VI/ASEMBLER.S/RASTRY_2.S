***************************************************************************
* Q u a s t  V I - programowanie w assemblerze							  *
***************************************************************************
* program  		 - rastry II - przesuwany raster						  *
* autor    		 - Costek  											      *
* typ Atari		 - ST/E												      *
***************************************************************************

START:
	clr.l -(sp)				* supervisor
	move.w #$20,-(sp)
	trap #1
	addq.l #6,-(sp)
	move.w #0,-(sp)

	move.l #$78000,-(sp)	* nowy adres ekranu i niska rozdzielczosc
	move.l #$78000,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

	move.w #0,$ff8240		* tlo na kolor czarny
	move.l #KOLORY,KOL		
	lea $78000,a0
	addq.l #2,a0
	move.w #200,d0

MALUJ:						* malowania kawalka ekranu po ktorym bedzie
	move.w #$ffff,48(a0)	*  przewijany kolorowy raster
	move.w #$ffff,56(a0)
	move.w #$ffff,64(a0)
	move.w #$ffff,72(a0)
	move.w #$ffff,80(a0)
	move.w #$ffff,88(a0)
	move.w #$ffff,96(a0)
	move.w #$ffff,104(a0)
	add.l #160,a0
	dbf d0,MALUJ

	move.l #SAFEREG,a0		* zapamietanie wartsci ukladu Mpf
	move.b $fffa07,(a0)+
	move.b $fffa09,(a0)+
	move.b $fffa0b,(a0)+
	move.b $fffa0f,(a0)+
	move.b $fffa13,(a0)+
	move.b $fffa17,(a0)+
	move.b $fffa1b,(a0)+
	move.b $fffa1d,(a0)+
	move.b $fffa21,(a0)+
	move.l $70,OLDVBL		* zapamietanie wektorow starych przerwan
	move.l $120,OLDTIMB	

	move.b #8,$fffa1b		* nowe waertosci do ukladu Mfp
	move.b #1,$fffa21
	ori.b #%00000001,$fffa07
	andi.b #%11011111,$fffa09
	ori.b #%00000001,$fffa13
	move.l #VBL,$70			* nowe procedury pod przerwania
	move.l #TIMER_B,$120

LOOP:						* oczekiwanie na klawisz
	cmp.b #185,$fffc02
	bne.s LOOP

	move.l #SAFEREG,a0		* zwrocenie wartosci ukladu Mfp
	move.b (a0)+,$fffa07
	move.b (a0)+,$fffa09
	move.b (a0)+,$fffa0b
	move.b (a0)+,$fffa0f
	move.b (a0)+,$fffa13
	move.b (a0)+,$fffa17
	move.b (a0)+,$fffa1b
	move.b (a0)+,$fffa1d
	move.b (a0)+,$fffa21
	move.b #$f7,$fffa23

	move.l OLDVBL,$70		* zwrocenie starych wartosci przerwan
	move.l OLDTIMB,$120
	move.w #$777,$ff8240                

	clr.l -(sp)
	trap #1					* wyjscie z programu

VBL:						* procedura przerwania VBLa
	cmp.w #400,POINT		* odliczanie kolorow ktore sa przewijanie
	bne DALEJ
	move.l #KOLORY,KOL
	clr.w POINT

DALEJ
	move.l #KOLORY,a0
	move.w POINT,d0
	addq.w #2,d0
	move.w d0,POINT
	add.l d0,a0
	move.l a0,KOL
    RTE

TIMER_B						* procedura przerwania Timera B
	move.b #1,$fffa21
	movem.l d0-d3/a0-a3,-(sp)
	move.l KOL,a0
	move.w (a0)+,$ff8244	* raster na kolor nr.2
	move.l a0,KOL
	movem.l (sp)+,d0-d3/a0-a3
	bclr.b #0,$fffa0f
	rte

WYLACZ:		dc.b $12
WLACZ:		dc.b $08,1,1
OLD:		ds.l 1
POINT: 		dc.w 0
KOL:		ds.l 1
OLDVBL:		ds.l 1
OLDTIMB: 	ds.l 1
SAFEREG: 	ds.b 10
	even
KOLORY:						* dane do przewijanych kolorow

  	dc.w $017,$027,$037,$047,$057,$067,$077,$176,$275,$374,$473,$572,$671,$770
	dc.w $771,$772,$773,$774,$775,$776,$777,$767,$757,$747,$737,$727,$717,$707                           
  	dc.w $607,$507,$407,$307,$207,$107,$007,$106,$205,$304,$403,$502,$601,$700
	dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370,$270,$170,$070
  	dc.w $071,$072,$073,$074,$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
	dc.w $016,$025,$034,$043,$052,$061,$070,$170,$270,$370,$470,$570,$670,$770
  	dc.w $771,$772,$773,$774,$775,$776,$777,$677,$577,$477,$377,$277,$177,$077
	dc.w $166,$255,$344,$433,$522,$611,$700,$710,$720,$730,$740,$750,$760,$770
  	dc.w $671,$572,$473,$374,$275,$176,$077,$076,$075,$074,$073,$072,$071,$070
   	dc.w $161,$252,$343,$434,$525,$616,$707,$717,$727,$737,$747,$757,$767,$777
  	dc.w $766,$755,$744,$733,$722,$711,$700,$610,$520,$430,$340,$250,$160,$070
	dc.w $071,$072,$073,$074,$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
  	dc.w $107,$207,$307,$407,$507,$607,$707,$716,$725,$734,$743,$752,$761,$770
	dc.w $670,$570,$470,$570,$670,$770,$770,$760,$750,$740,$730,$720,$710,$700
	dc.w $601,$403,$205,$106
   	dc.w $017,$027,$037,$047,$057,$067,$077,$176,$275,$374,$473,$572,$671,$770
	dc.w $771,$772,$773,$774,$775,$776,$777,$767,$757,$747,$737,$727,$717,$707                           
  	dc.w $607,$507,$407,$307,$207,$107,$007,$106,$205,$304,$403,$502,$601,$700
	dc.w $710,$720,$730,$740,$750,$760,$770,$670,$570,$470,$370,$270,$170,$070
  	dc.w $071,$072,$073,$074,$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
	dc.w $016,$025,$034,$043,$052,$061,$070,$170,$270,$370,$470,$570,$670,$770
  	dc.w $771,$772,$773,$774,$775,$776,$777,$677,$577,$477,$377,$277,$177,$077
	dc.w $166,$255,$344,$433,$522,$611,$700,$710,$720,$730,$740,$750,$760,$770
  	dc.w $671,$572,$473,$374,$275,$176,$077,$076,$075,$074,$073,$072,$071,$070
   	dc.w $161,$252,$343,$434,$525,$616,$707,$717,$727,$737,$747,$757,$767,$777
  	dc.w $766,$755,$744,$733,$722,$711,$700,$610,$520,$430,$340,$250,$160,$070
	dc.w $071,$072,$073,$074,$075,$076,$077,$067,$057,$047,$037,$027,$017,$007
  	dc.w $107,$207,$307,$407,$507,$607,$707,$716,$725,$734,$743,$752,$761,$770
	dc.w $670,$570,$470,$570,$670,$770,$770,$760,$750,$740,$730,$720,$710,$700
	dc.w $601,$403,$205,$106
	even
