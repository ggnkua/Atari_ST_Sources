******************************************************************
***********									***********
*********** Routine de ligne pour Falcon en True Color	***********
***********									***********
***********  Par Simplet (Simply Strange) of ABSTRACT	***********
***********		  pour How To Code II			***********
***********									***********
***********	Les mini-Inits utilisent le XBios pour	***********
***********	le changement de r‚solution et donc	***********
***********	ne marchent pas si NVDI est install‚	***********
***********									***********
***********		Tabulation sous DevPac : 5		***********
***********									***********
******************************************************************

		Section	TEXT

		clr.l	-(sp)
		move.w	#32,-(sp)
		trap		#1
		addq.l	#6,sp

		bsr		Save
		bsr		Init


		movea.l	Adr_Screen(pc),a0
		moveq.l	#0,d0
		move.w	#(320*200*2)/4-1,d7
Clear_Screen
		move.l	d0,(a0)+
		dbra		d7,Clear_Screen



Main_Loop	clr.w	VBL_Cmpt

VBL_Wait	tst.w	VBL_Cmpt(pc)			
		beq.s	VBL_Wait				
		
		bsr.s	VBL_Rout				

		cmp.b	#$39,$fffffc02.w		
		bne.s	Main_Loop				

* Restorations
		bsr		Restore

* Fin du Programme
		clr.w	-(sp)				
		trap		#1					


******************************************************************
***********		Routine tournant … chaque VBL		***********
******************************************************************

VBL_Rout	move.l	#$5f6f00ff,$ffff9800.w

		move.w	#54,-(sp)

VBL_Loop	move.w	#0,d0				
		move.w	#0,d1				
		move.w	#319,d2				
		move.w	#199,d3				
		move.w	#$5678,d4				
		movea.l	Adr_Screen(pc),a0		
		bsr.s	Line

		subq.w	#1,(sp)
		bne.s	VBL_Loop

		addq.l	#2,sp

VBL_Ret	clr.l	$ffff9800.w
		rts

******************************************************************
***********		Interruption VBL : Compteur		***********
******************************************************************

New_VBL	addq.w	#1,VBL_Cmpt
		rte

******************************************************************
***********									***********
***********	   Routines de ligne en True Color		***********
***********									***********
***********	   Coordon‚es de D‚part en d0/d1.w		***********
***********	   Coordon‚es d'Arriv‚e en d2/d3.w		***********
***********  Couleur dans mots fort et faible de d4.l	***********
***********		Adresse de l'‚cran en a0.l		***********
***********									***********
******************************************************************

Line		cmp.w	d0,d2				
		beq		V_Line				
		cmp.w	d1,d3				
		beq		H_Line				

		move.w	d2,d5				
		sub.w	d0,d5				
		bpl.s	dX_Ok				
		neg.w	d5					
dX_Ok		move.w	d3,d6				
		sub.w	d1,d6				
		bpl.s	dY_Ok				
		neg.w	d6					
dY_Ok
		cmp.w	d5,d6
		blt.s	X_Line				
		bgt.s	Y_Line				

***********
* dX = dY *
***********


O_Line	move.w	#640,d7				
		moveq.l	#2,d6				

		cmp.w	d0,d2				
		bgt.s	O_Ok1				
		neg.w	d6					

O_Ok1	cmp.w	d1,d3				
		bgt.s	O_Ok2				
		neg.w	d7					

O_Ok2	add.w	d6,d7				

		add.w	d0,d0
		adda.w	d0,a0				
		mulu.w	#640,d1
		adda.l	d1,a0				

O_Line_Loop	
		move.w	d4,(a0)				
		adda.w	d7,a0				
		dbra		d5,O_Line_Loop	
		rts

***********
* dX > dY *
***********

X_Line
		move.w	#640,d7				
		cmp.w	d0,d2				
		bgt.s	X_Ok1				
		exg.l	d1,d3				
		exg.l	d0,d2				
X_Ok1		cmp.w	d1,d3				
		bgt.s	X_Ok2				
		neg.w	d7					

X_Ok2	add.w	d0,d0
		adda.w	d0,a0				
		mulu.w	#640,d1
		adda.l	d1,a0				

		addq.l	#1,d5				
		addq.l	#1,d6				
		swap.w	d6					
		clr.w	d6					
		divu.w	d5,d6				
		ext.l	d6					
		moveq.l	#0,d3				

		subq.w	#1,d5
X_Line_Loop
		move.w	d4,(a0)+				
		add.w	d6,d3				
		bcc.s	No_Y					
		adda.w	d7,a0				

No_Y		dbra		d5,X_Line_Loop	
		rts

***********
* dY > dX *
***********

Y_Line	move.w	#640,d7				

		cmp.w	d0,d2				
		bgt.s	Y_Ok1				
		exg.l	d1,d3				
		exg.l	d0,d2				
Y_Ok1	cmp.w	d1,d3				
		bgt.s	Y_Ok2				
		neg.w	d7					

Y_Ok2	add.w	d0,d0
		adda.w	d0,a0				
		mulu.w	#640,d1
		adda.l	d1,a0				

		addq.l	#1,d5				
		addq.l	#1,d6				
		swap.w	d5					
		clr.w	d5					
		divu.w	d6,d5				
		ext.l	d5					
		moveq.l	#0,d3				

		subq.w	#1,d6
Y_Line_Loop
		add.w	d5,d3				
		bcs.s	Go_X					
		move.w	d4,(a0)				
		adda.w	d7,a0				

		dbra		d6,Y_Line_Loop	
		rts

Go_X		move.w	d4,(a0)+				
		adda.w	d7,a0				

		dbra		d6,Y_Line_Loop	
		rts


***********
* X1 = X2 *
***********

V_Line	move.w	#640,d7				

		cmp.w	d1,d3				
		bgt.s	Ok_V					
 		exg.l	d1,d3				

Ok_V		sub.w	d1,d3				

		add.w	d0,d0
		adda.w	d0,a0				
		mulu.w	#640,d1
		adda.l	d1,a0				

V_Line_Loop
		move.w	d4,(a0)				
		adda.w	d7,a0				
		dbra		d3,V_Line_Loop
		rts

***********
* Y1 = Y2 *
***********
		
H_Line	cmp.w	d0,d2				
		bgt.s	Ok_H					
		exg.l	d0,d2				

Ok_H		sub.w	d0,d2				
 
		add.w	d0,d0
		adda.w	d0,a0				
		mulu.w	#640,d1
		adda.l	d1,a0				

H_Line_Loop
		move.w	d4,(a0)+				
		dbra		d2,H_Line_Loop
		rts

******************************************************************
***********		    Inits et compagnie			***********
******************************************************************

Save

* Sauvegarde anciennes adresses ‚cran
		move.w	#2,-(sp)				
		trap		#14					
		move.l	d0,Old_Log_Adr
		move.w	#3,-(sp)				
		trap		#14					
		move.l	d0,Old_Phys_Adr
		addq.l	#4,sp				

* Sauvegarde ancienne r‚solution
		move.w	#-1,-(sp)
		move.w	#88,-(sp)				
		trap		#14					
		addq.l	#4,sp				
		move.w	d0,Old_Rez			

* Sauvegarde couleur de fond
		move.l	$ffff9800.w,Old_BackGroundColor

* Sauvegarde interruptions
		move.b	$fffffa07.w,Old_IERA
		move.b	$fffffa09.w,Old_IERB
		move.l	$70.w,Old_VBL
		rts


Init
* Calcul adresse ‚cran
		move.l	#Screen+4,d0			
		and.b	#$fc,d0				
		move.l	d0,Adr_Screen			

* Passage en mode 320*200 True Color
		move.w	#$24,-(sp)			
		move.w	#3,-(sp)				
		move.l	Adr_Screen(pc),-(sp)	
		move.l	Adr_Screen(pc),-(sp)	
		move.w	#5,-(sp)				
		trap		#14					
		lea.l	14(sp),sp				

* Interruptions
		move.w	#$2700,sr				
		clr.b	$fffffa07.w			
		clr.b	$fffffa09.w			
		move.l	#New_VBL,$70.w			
		move.w	#$2300,sr				

		rts


Restore

* Restore interruptions
		move.w	#$2700,sr
		move.l	Old_VBL,$70.w
		move.b	Old_IERA,$fffffa07.w
		move.b	Old_IERB,$fffffa09.w
		move.w	#65535,d0
		dbra		d0,*
		move.w	#$2300,sr

* Restore l'ancienne couleur de fond
		move.l	Old_BackGroundColor(pc),$ffff9800.w

* Restore l'ancienne r‚solution et ancienne adresse ‚cran
		move.w	Old_Rez(pc),-(sp)
		move.w	#3,-(sp)
		move.l	Old_Phys_Adr(pc),-(sp)
		move.l	Old_Log_Adr(pc),-(sp)
		move.w	#5,-(sp)				
		trap		#14					
		lea.l	14(sp),sp				
		rts

			Section	BSS

VBL_Cmpt		Ds.w		1
Adr_Screen	Ds.l		1
Old_IERA		Ds.b		1
Old_IERB		Ds.b		1
Old_VBL		Ds.l		1
Old_BackGroundColor
		Ds.l		1
Old_Log_Adr	Ds.l		1
Old_Phys_Adr	Ds.l		1
Old_Rez		Ds.w		1
Screen		Ds.b		(320*200*2)+4			
