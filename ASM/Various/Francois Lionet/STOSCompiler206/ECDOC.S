
**************************************************************************
*
*		COMPILER EXTENSION FILE
*
*
*	Note: with a compiler, think double!
*
*	A difficulty I encountered when I was starting the compiler
*	and you might find doing the extension, is this one: when you
*	write a compiler, you do not write ONE program, you write TWO!
*	You have to write the program that CREATES another one, and
*	therefor have two levels in your compiler: the COMPILER itself,
*	and the LIBRARY, and everything must work together!
*
*	I did the main job for you. But you must remember that the extension
*	file is splitted in 2:
*			- Informations about the extension for the
*			  compilation time
*			- Library routines that will be call on RUN-time
*			  and only then.
*
*	In case of problem, call me: 44 55 35 28, or send me a FAX, at the
*	same number. If it really don't work, we'll exchange files by
*	modem. I will not hesitate to spend time to make it work!
*
*	PS: forgive my English!
*
**************************************************************************
*	
*	HOW TO MAKE AN EXTENSION FOR THE COMPILER
*
*	This program is the listing of the COMPACT compiler's extension
*	I think you already have the normal COMPACT.EXA listing. You'll
*	see the differences between them. 
*	The main point: the extension code MUST BE RELOCATABLE, all in
*	(pc) code. It is not a big deal with 68000 and files smaller 
*	than 32K.
*	Also, as all the code is relocatable, you cannot use absolute
*	address variables. You have 2 solutions:
*			- Load (pc) address in a address register
*			- Use one register as a base address for all
*		variables used by the program, it's what I do here, 
*		and I think, is the easiest to do.
*	As there is NO EDITOR when the program is running, you do not
*	have a table of addresses, as you had before, but you have much
*	better: direct access to all basic's variables, via A5. I don't
*	know what exactely you use, if you need to call RESERVE or ERASE.
*	or see if a bank is reserved: call me at nigth when its cheaper,
*	and ask me exactely what you want.
*	The compiled program also has a DIRECT ACCES to ALL library 
*	routines, via a simple JSR call. Therefor, its much easier to call
*	a routine in a compiler extension then in a interpretor extension.
*
*	I'm going to comment the program now.
*
**************************************************************************

*	Includes all the equates of all basic's table. See later.

	INCLUDE "EQUATES.S"

**************************************************************************

Debu:           dc.l Para-Debu
                dc.l Data-Debu
                dc.l Libr-Debu

*	The beginning of the program MUST BE OFFSETS to the parameter
*	definition list and librairy catalogue, then the initialization 
*	routines, then the beginning of the librairy.

*********************** CATALOGUE ****************************************
*	CATALOGUE: 2 instructions: UNPACK and PACK
*	Is stored in this table, the lenght of each routine, IN EXACT
*	ORDER. I used Lxxx where xxx id the number of librairy routine, to
*	avoid bugs!
*	The CATALOGUE MUST BE JUST AFTER the offset list!
*	Off course, the order of instruction is exactely the same than
*	the order in the .EX file. If you want to add intern routines for 
*	this program, put them after the last instruction. We'll see that
*	later. INSTRUCTION are even / FUNCTIONS are ODD, just like in the
*	.EX file.

Cata:   dc.w l2-l1,l3-l2

********************** PARAMETER LIST ************************************
*	This list tells the compiler how many new instruction the routine
*	handle, and the exact parameter list the compiler must accept. As 
*	there might be more than 1 list of params, you must states all
*	different allowed syntax.

Para:   dc.w 2,2     		
*	1st: TOTAL number of routines in the librairy
*	2nd: number of new instructions. Here, the same, because I do not
*	have intern routines, but 1st may be more than 2nd.            

        dc.w p1-Para,p2-Para
*	This is the offset to each parameter definition, for each new 
*	instructionof the extension.


*	PARAMETERS ALLOWED FOR UNPACK (INSTRUCTION)
*		- 1 end the parameter list
*		- 1 1 end the instruction param list
*		- 0 stands for an integer
*		- $40 stands for a float (you do not need it I think)
*		- $80 stands for a string
*		- "," means you want a comma between each params
*	First, comes a zero that in fact is only used by the FUNCTION
*	definition, but to preserve the format, I had to put it for 
*	instructions too.
p1:     dc.b 0 					* Not used for instructions
        dc.b 0,1				* UNPACK bank#
        dc.b 0,",",0,1				* UNPACK bank#,screen
        dc.b 0,",",0,",",0,1			* UNPACK b#, sc, flags
        dc.b 0,",",0,",",0,",",0,1		* UNPACK b#, sc, X, Y
        dc.b 0,",",0,",",0,",",0,",",0,1	* UNPACK b#, sc, fl, X, Y
        dc.b 1,0				* Ends definition

*	PARAMETERS DEFINITION FOR FUNCTIONS
*	It is the same format, except for the FIRST number, that tells
*	the compiler the type of number returned by the function
p2:     dc.b 0                                  * returns an INTEGER
        dc.b 0,",",0,1				* =PACK(logic, bank#)
        dc.b 0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,1
* 	=PACK (logic, bank#, list of params I dont remember!)
        dc.b 1,0				* End of definition

************* INITIALISATION / PARAMETERS *******************************
*	This part of the program is ALWAYS copied (if the program uses
*	extension). It performs INITIALISATION of the extension and 
*	also the END of it (if you have interruption patches).
*	As it is ALWAYS copied, you must put the variables of the program
*	in this area.

*	Skip over params
Data:           bra Init

*	Params: I took the old params list, and changed it into offsets,
*	then reserved the good amount of space.
*	Be carefull, PARAMS must be 4 not to erase the BRA instruction!
params:         equ 4                   ; blk.w 9,0

larg:           equ (9*2)+params        ; dc.w 0
haut:           equ larg+2              ; dc.w 0
unpflg:         equ haut+2              ; dc.w 0
adobjet:        equ unpflg+2            ; dc.l 0 
nbplan:         equ adobjet+4           ; dc.w 0
taillex:        equ nbplan+2            ; dc.w 0
tailley:        equ taillex+2           ; dc.w 0
adycar:         equ tailley+2           ; dc.w 0
tmode:          equ adycar+2
palnul:         equ (3*4*2)+tmode
resol:          equ $44c

*	Here, I reserve zeros for the params
                dcb.b tmode-4,0
*	List of params to adapt to resolution (pointed to by tmode)
                dc.w  160,8,4,200
                dc.w  160,4,2,200
                dc.w  80,2,1,400
                dcb.w 16,0		* security

*	Internal EQUATES for the extension
code:           equ 0           ;code de reconnaissance: $06071963
cmode:          equ 4           ;resolution
dx:             equ 6           ;debut en X (mots)
dy:             equ 8           ;debut en Y (pixels)
tx:             equ 10          ;taille en X (mots)
ty:             equ 12          ;taille en Y (carres de compactage)
tcar:           equ 16          ;taille du carre de compactage
flags:          equ 18          ;flags divers
table2:         equ 20          ;adresse de la table 2
point2:         equ 24          ;adressse des pointeurs 2
palette:        equ 38          ;palette de couleurs
dcomp:          equ 70          ;debut du compactage de l'image


*	The initialisation routine, here reduced to its very minimum!
*	A2 on return points to the END routine, called when the programs 
*	stops.
*	On entry, A0---> start of usable buffer
*		  A1---> end of usable buffer
*		  A5---> basic's variable table
*	The extension can reserve a memory area to work with, it must 
*	not go over (A1). On return, A0 must point to the end of the
*	area. If the amount of space between A0 and A1 is not enough,
*	you must return a 1 in D0 to signal OUT OF MEM error.
*	Ex: -reserve $1000 for internal use-
*		lea params(pc),a2		*address of params
*		move.l a0,Buffer(a2)		*stores address
*		lea $1000(a0),a0		*$1000 bytes
*		cmp.l a1,a0
*		bcc.s OutMem
*		clr.w d0			*No errors
*		lea End(pc),a2			*End routine
*		rts
*	OutMem:	moveq #1,d0
*		rts
*
*
*	ATTENTION! this program may RUN under 2 very different conditions:
*		- STOS RUN :  the interrupt patch is ALREADY here
*		- GEM RUN  :  the interrupt patch is NOT here.
*	That's why you can TEST FlaGem(a5): this flag tells you if the
*	program runs under the editor or not: 0---> EDITOR 1---> GEM
*	(you can also directely look to the interrupt vector if you prefer
*	to stay with YOUR program only!). NOTE: FlaGem is defined in the
*	EQUATES.S file.
*
*	Remember, always put the interrupt vector as it was with the END
*	routine!
 
Init:   lea	End(pc),a2
	rts
End:	rts




************************ LIBRARY *****************************************
Libr:

*	The librairy is a "smart library", the routine used are copied
*	and just this ones. 
*	One library routine can call another via a JSR. This one call
*	also call another and so on, everything is linked during the end
*	of pass 1.
*		JSR number ---> call the routine #number in the MAIN
*				librairy
*		JSR number+$80000000  ---> call routine #number in the
*					   extension librairy
*	You must tell the compiler where in the routine is a call to 
*	another routine. This is done by a list a offset within the routine
*	at the very beginning of it. This list is ended by a ZERO, must
*	be in PROGRESSIVE order. If no call is done, the put a zero.

*	Couple of main library routines called by the extension
*	routines
adoubank:       equ 214
adecran:        equ 234
aback1:         equ 578
aback2:         equ 579

**************************************************************************
*       UNPACK origine[ ,ecran [,flags] [,dx,dy] ]
*	Here is the list of offsets to librairy calls
l1:     dc.w l1a-l1,l1b-l1,l1c-l1,l1d-l1,0
******************************************

*	The routine must not change a4-a6!

*	First, you must get the address of your parameters, it is done
*	by reading in the compiled program data zone:
        move.l Debut(a5),a3		* defined in EQUATES.S
        move.l 0(a3,d1.w),a3            * adress INIT label (params=4!)
*	Now I will index all variable access with A3

*	Same as the .EXA routine, but with A3
        clr unpflg(a3)
        lea params(a3),a2
        move.w #-1,(a2)                 ;flags par defaut
        move.l adback(a5),2(a2)         ;decor des sprites
        move.w #-1,6(a2)                ;dx
        move.w #-1,8(a2)                ;dy

*	When the routine is called, D0 tells you what list of params
*	was chosen: 0 1 ... (carefull, it doesnot tell you the number
*	of params, but the number of the list!)
*	The params are pushed into a pile pointed to by A6. They are
*	already in the good type: integer or string. Of course, it is
*	in reverse order (pile...)
*	You must UNPILE ALL parameters before returning to the main 
*	program.

        cmp.w #1,d0			*UNPACK a 
        beq.s unp4
        cmp.w #2,d0			*UNPACK a,s
        beq.s unp3
        cmp.w #3,d0			*UNPACK a,s,fl
        beq.s unp1
        cmp.w #4,d0			*UNPACK a,s,dx,dy
        beq.s unp2
; Cinq parametres			*UNPACK a,s,fl,dx,dy
        move.l (a6)+,d3
        move.w d3,8(a2)
        move.l (a6)+,d3
        lsr.w #4,d3     ;divise par 16!
        move.w d3,6(a2)
; Trois parametres
unp1:   move.l (a6)+,d3         ;Flag
        move.w d3,(a2)
        bra.s unp3
; Quatre parametres
unp2:   move.l (a6)+,d3
        move.w d3,8(a2)
        move.l (a6)+,d3
        lsr.w #4,d3
        move.w d3,6(a2)
; Deux parametres
unp3:   move #1,unpflg(a3)      ;Image

*	Here is a call to a library routine: just JSR. Simple isn't it?
l1a:    jsr adecran
        move.l d3,2(a2)
; Un parametre         
unp4:   
*	Another one
l1b:    jsr adoubank
        move.l d3,a0            ;adresse d'origine
        move.l 2(a2),a1         ;adresse destination
        move.w 6(a2),d1         ;dx
        move.w 8(a2),d2         ;dy
        move.w (a2),d3          ;flags
;
        tst unpflg(a3)          ;si l'adresse d'ecran est precisee              
        bne.s unp5              ;aucune gestion d'autoback

*	Another one
l1c:    jsr aback1
unp5:   bsr decomp
        tst unpflg(a3)
        bne.s unp6
        move.w d0,-(sp)

*	Another one
l1d:    jsr aback2
        move.w (sp)+,d0
unp6:   tst d0
        bne.s l1fc
        rts

*	In case of error, do like this:
*		-D0= # of error (see stos manual)
*		-Load the error routine address with error(a5)
*		-jump to it
*		-no need to care about PILE (sp) (a6)
*		-the only registers that MUST be preserved are A5 and 
*		 A4 (instruction address, used by on error goto!)
l1fc:   moveq #13,d0
        move.l error(a5),a0
        jmp (a0) 

********************************************** DECOMPACTEUR
*	This routine is called by a BSR, this is relocatable.
*	Of course, you must not call this routine anywhere else than
*	between labels L1 and L2, as the distance between each library
*	routine is not fixed!
*	I was obliged to modifie a little my routines to get a new free
*	register to point to my params list, but it is mainly the
*	same.
***********************************************************************
decomp: movem.l a3-a6,-(sp)
        cmp.l #$06071963,code(a0)       ;verifie le code
        bne Derr2
 
; Prepare les parametres
        move.l a0,-(sp)         ;adresse d'origine
        move.l a1,-(sp)         ;adresse destination
;
        tst.w d3
        bpl.s dflag
        move.w flags(a0),d3
dflag:  move.w d3,-(sp)         ;pousse les flags
        btst #0,d3
        beq.s flag1
; Toutes les couleurs a zero pendant le travail! FLAG= XXXXXXX1
        movem.l a0-a1/d1-d2,-(sp)
        pea palnul(a3)
        move.w #6,-(sp)
        trap #14
        addq.l #6,sp
        movem.l (sp)+,a0-a1/d1-d2

flag1:  lea -10(sp),sp          ;place pour les parametres
        move.l a1,a4            ;a4--> adresse ecran
        lea tmode(a3),a2
        move.w cmode(a0),d0
        lsl.w #3,d0
        move.w 0(a2,d0.w),d7    ;d7--> taille ligne
        move.w 2(a2,d0.w),d6    ;d6--> taille plans
        move.w 4(a2,d0.w),d5    ;d5--> nbplans
        move.w 6(a2,d0.w),d4    ;d4--> taille en Y ecran
        move.w d5,nbplan(a3)
        tst.w d1
        bpl.s dec1
        move.w dx(a0),d1
dec1:   tst.w d2
        bpl.s dec2
        move.w dy(a0),d2
dec2:   mulu d6,d1              ;calcule et verifie en X
        add.w d1,a1
        move.w tx(a0),d0        ;taille en X en mots
        mulu d6,d0
        add d0,d1
        cmp d7,d1
        bhi Derr
        move.w ty(a0),d0        ;calcule et verifie en Y
        mulu tcar(a0),d0
        add.w d2,d0
        cmp.w d4,d0
        bhi Derr
        mulu d7,d2
        add.w d2,a1
        move.l a1,6(sp)         ;6(sp)--> adresse ecran de destination     
        move tcar(a0),d0
        mulu d7,d0
        move d0,2(sp)           ;2(sp)--> addition change de ligne de carre
        move d6,(sp)            ; (sp)--> addition change de carre
        move tcar(a0),d6        ;D6--> indice hauteur carre
        move.w tx(a0),d0
        subq #1,d0
        move d0,taillex(a3)
        move.w ty(a0),d0        
        move d0,tailley(a3)
        lea dcomp(a0),a4        ;a4--> table octets 1
        move.l a0,a5
        move.l a0,a6
        add.l table2(a0),a5     ;a5--> table octets 2
        add.l point2(a0),a6     ;a6--> table pointeurs
        moveq #7,d0             ;prepare les variables de compactage
        moveq #7,d1
        move.b (a5)+,d2
        move.b (a4)+,d3
        btst d1,(a6)
        beq.s prep
        move.b (a5)+,d2
prep:   subq #1,d1

; Decompactage proprement dit
dplan:  move.l 6(sp),a2
        move.w tailley(a3),4(sp)        ;4(sp)--> compteur tailleY
dligne: move.l a2,a1
        move.w taillex(a3),d5
dcarre: move.l a1,a0
        move.w d6,d4            ;  D4 --> compteur hauteur carre

doctet1:subq.w #1,d4
        bmi.s doct3
        btst d0,d2
        beq.s doct1
        move.b (a4)+,d3
doct1:  move.b d3,(a0)
        add.w d7,a0
        dbra d0,doctet1
        moveq #7,d0
        btst d1,(a6)
        beq.s doct2
        move.b (a5)+,d2
doct2:  dbra d1,doctet1
        moveq #7,d1
        addq.l #1,a6
        bra.s doctet1
doct3:  move.l a1,a0
        move.w d6,d4

doctet2:subq.w #1,d4
        bmi.s doct7
        btst d0,d2
        beq.s doct5
        move.b (a4)+,d3
doct5:  move.b d3,1(a0)
        add.w d7,a0
        dbra d0,doctet2
        moveq #7,d0
        btst d1,(a6)
        beq.s doct6
        move.b (a5)+,d2
doct6:  dbra d1,doctet2
        moveq #7,d1
        addq.l #1,a6
        bra.s doctet2
     
doct7:  add.w (sp),a1           ;autre carres ?
        dbra d5,dcarre
        add.w 2(sp),a2          ;autre ligne de carres?
        sub.w #1,4(sp)
        bne dligne
        addq.l #2,6(sp)         ;autre plan couleur?
        sub.w #1,nbplan(a3)
        bne dplan

        lea 10(sp),sp           ;retabli la pile

; Fin du decompactage
        move.w (sp)+,d1         ;recupere les flags
        move.l (sp)+,a1         ;adresse de destination
        move.l (sp)+,a0         ;adresse de l'image
        lea palette(a0),a0
        lea 32000(a1),a1
        move.l a1,a2
        moveq #15,d0
dpal:   move.w (a0)+,(a1)+
        dbra d0,dpal
        btst #1,d1              ;ne pas changer les couleurs de l'ecran
        beq.s findec            
        move.l a2,-(sp)         ;change les couleurs de l'ecran
        move.w #6,-(sp)
        trap #14
        addq.l #6,sp

findec: movem.l (sp)+,a3-a6
        moveq #0,d0
        rts

; Erreur!
Derr:   lea 20(sp),sp           ;restore la pile!
Derr2:  movem.l (sp)+,a3-a6
        moveq #-1,d0
        rts

**************************************************************************
*       PACK (image,destination [,mode,flags,hauteur,dx,dy,tx,ty])
*	CALL offsets inside of the PACK routine
l2:     dc.w l2a-l2,l2b-l2,0

*	PACK is a function, so you must PUSH the return value in the A6
*	pile before returning.
*	The params type must be the same type as you said in the 
*	PARAMS definition list (1st byte).
*******************************************

*	Get the address of extension variables
        move.l Debut(a5),a3
        move.l 0(a3,d1.w),a3    

        lea params(a3),a2
        moveq #0,d4
        move.b $44c,d4          ;resolution .B!
        move.w d4,d1
        lsl.w #3,d1
        lea tmode(a3),a0
        moveq #0,d2
        move.w 6(a0,d1.w),d2    ;taille ecran en Y
        moveq #5,d3
        divu d3,d2
        move.w d2,(a2)+         ;TY
        moveq #0,d2
        move.w 0(a0,d1.w),d2    ;taille ligne en octets
        divu 2(a0,d1.w),d2      ;divise par taille plan en octet
        move.w d2,(a2)+         ;TX
        clr.w (a2)+             ;dy
        clr.w (a2)+             ;dx
        move.w d3,(a2)+         ;hauteur
        move.w #%11,(a2)+       ;flags
        move.w d4,(a2)+         ;resolution

* 	Get the functions parameters
        cmp.w #1,d0
        beq.s pack3
; Neuf parametres
        lea params(a3),a2	*9 params
        moveq #6,d7
pack2:  
        move.l (a6)+,d3         ;empile les cinq params
        move.w d3,(a2)+
        dbra d7,pack2
; deux parametres		*2 params
pack3:  	
l2a:    jsr adoubank
        move.l d3,-(sp)
l2b:    jsr adecran
        move.l d3,-(sp)
; Verifie les parametres
        lea params(a3),a2   
        move.w 12(a2),d0        ;resolution image
        cmp.w #2,d0
        bhi l2fc
        lsl #3,d0
        lea tmode(a3),a0
        moveq #0,d1
        move.w 0(a0,d0.w),d1    ;verifie en X
        divu 2(a0,d0.w),d1
        move.w 6(a2),d2
        add.w 2(a2),d2
        cmp.w d1,d2
        bhi l2fc
        move.w (a2),d2          ;verifie en Y
        mulu 8(a2),d2
        add.w 4(a2),d2
        cmp.w 6(a0,d0.w),d2
        bhi l2fc
        move.w (a2)+,d5         ;ty
        beq l2fc
        move.w (a2)+,d4         ;tx
        beq l2fc
        move.w (a2)+,d3         ;dy
        move.w (a2)+,d2         ;dx
        move.w (a2)+,d1         ;hauteur
        beq l2fc
        move.w (a2)+,d6         ;flags
        move.w (a2)+,d7         ;resolution
        move.l (sp)+,a0
        move.l (sp)+,a1

********************************************** COMPACTAGE
        movem.l a4-a6,-(sp)

;-----> Preparation de l'entete de l'image compactee
        move.l a1,adobjet(a3)
        move.l #$06071963,code(a1)
        move.w d7,cmode(a1)
        move.w d2,dx(a1)
        move.w d3,dy(a1)  
        move.w d4,tx(a1)  
        move.w d5,ty(a1)   
        move.w d1,tcar(a1)  
        move.w d6,flags(a1)  

; Copie de la palette
        moveq #15,d0
        lea 32000(a0),a2        ;palette de couleurs apres l'image
        lea palette(a1),a4
copal:  move.w (a2)+,(a4)+ 
        dbra d0,copal

; Preparation des parametres
        move.l a0,a4            ;a4--> adresse image
        lea dcomp(a1),a5        ;a5--> adresse TABLE 1
        lea 32000(a5),a6        ;a6--> adresse POINTEUR 1
        move.l a6,-(sp)         ;pour plus tard!
        subq #1,d5
        move d5,tailley(a3)     ;taille en Y de l'image
        move d1,d5
        move.w cmode(a1),d0
        lsl #3,d0
        lea tmode(a3),a0
        move.w 0(a0,d0.w),d7    ;d7--> taille ligne
        move.w 2(a0,d0.w),d6    ;d6--> taille plans
        move.w 4(a0,d0.w),d0    ;d0--> nbplans
        move d0,nbplan(a3)
        move d7,d0
        mulu d5,d0
        move d0,adycar(a3)      ;passage en Y d'un carre a l'autre
        subq #1,d5              ;D5--> indice taille en Y du carre
        subq #1,d4
        move d4,a0              ;a0--> indice taille en X
        move.w dy(a1),d0
        mulu d7,d0
        add.w d0,a4
        move.w dx(a1),d0
        mulu d6,d0
        add.w d0,a4             ;a4--> adresse dans l'ecran
        move.l a4,-(sp)
        moveq #7,d1             ;indice compactage
        clr.b (a5)              ;premier octet a zero
        clr.b (a6)              

; Compactage proprement dit
plan:   move.l (sp),a4
        move.w tailley(a3),d4
ligne:  move.l a4,a2
        move.w a0,d3
carre:  move.l a2,a1
        move.w d5,d2
;
octet1: move.b (a1),d0          ;compacte le carre de gauche
        cmp.b (a5),d0
        beq.s oct1
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a6)
oct1:   dbra d1,oct2
        moveq #7,d1
        addq.l #1,a6
        clr.b (a6)
oct2:   add.w d7,a1
        dbra d2,octet1
        move.l a2,a1

        move.w d5,d2
        move.l a2,a1
octet2: move.b 1(a1),d0         ;compacte le carre de droite
        cmp.b (a5),d0
        beq.s oct3
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a6)
oct3:   dbra d1,oct4
        moveq #7,d1
        addq.l #1,a6
        clr.b (a6)
oct4:   add.w d7,a1             ;passe a la ligne d'ecran suivante
        dbra d2,octet2

        add.w d6,a2             ;passe au carre suivant
        dbra d3,carre
        add.w adycar(a3),a4     ;passe a la ligne de carre suivante
        dbra d4,ligne
        addq.l #2,(sp)          ;passe au plan couleur suivant
        sub.w #1,nbplan(a3)
        bne.s plan
        addq.l #4,sp

; Compactage de la table de pointeurs 1
        move.l adobjet(a3),a1
        addq.l #1,a5
        move.l a5,d0
        sub.l a1,d0
        move.l d0,table2(a1)    ;adresse de la table intermediaire
        move.l (sp)+,a4         ;recupere le debut des pointeurs
        lea -1(a4),a0           ;nouveaux pointeurs: juste avant!
        move.l a0,-(sp)         ;pour plus tard
        moveq #7,d1
        clr.b (a5)
        clr.b (a0)
comp2:  move.b (a4)+,d0
        cmp.b (a5),d0
        beq.s comp2a
        addq.l #1,a5
        move.b d0,(a5)
        bset d1,(a0)
comp2a: dbra d1,comp2b
        moveq #7,d1
        addq.l #1,a0
        clr.b (a0)
comp2b: cmp.l a6,a4             ;compile toute la table des pointeurs
        bls.s comp2

; Termine le compactage
        addq.l #1,a5
        move.l a5,d0
        sub.l a1,d0
        move.l d0,point2(a1)    ;distance debut-pointeurs 2
        move.l (sp)+,a4
comp2c: move.b (a4)+,(a5)+
        cmp.l a0,a4             ;recopie la table des pointeurs
        bls.s comp2c

*	PUSH THE PARAMETER AND RETURNS
        move.l a5,d0
        sub.l a1,d0
        addq.l #1,d0            ;taille de l'image compactee en D0
        movem.l (sp)+,a4-a6
        move.l d0,-(a6)         ;PUSH!
fini:   rts

l2fc:   moveq #13,d0
        move.l error(a5),a0
        jmp (a0)


***********************************************************************
*	END OF THE PACK library routine
l3:     dc.w 0
***********************************************************************



