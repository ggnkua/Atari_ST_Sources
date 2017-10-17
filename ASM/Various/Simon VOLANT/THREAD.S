; MultiThreading

;	OPT	O+
	
	SECTION TEXT

	; reserve la m‚moire

	move.l	A7,A5
	move.l	4(A5),A5
	move.l	$C(A5),D0
	add.l	$14(A5),D0
	add.l	$1C(A5),D0
	add.l	#$1000,D0
	move.l	D0,-(SP)
	move.l	A5,-(SP)
	clr.w	-(SP)
	move.w	#$4A,-(SP)
	TRAP	#1
	lea	12(SP),SP
	tst.w	D0
	BNE	INIT_ERROR
	
	; Passe en superviseur
	
	clr.l	-(SP)
	move.w	#32,-(SP)
	TRAP	#1
	addq.l	#6,SP
	move.l	D0,-(SP)
	
	; Installe le Scheduler

	BSR	T_INSTALL

	; On installe un premier essais

	lea	TEST,A0
	BSR	T_ADD

	; On boucle (Space, Shift+Space : sortir)

KK1:	BSR	T_SCHEDULE
	cmpi.b	#$39,$fffffc02.w
	BNE	KK1
KK2:	cmpi.b	#$39+$80,$fffffc02.w
	BNE	KK2

	; On d‚sinstalle

	BSR	T_REMOVE

	; retour en utilisateur

	move.w	#32,-(SP)
	TRAP	#1
	addq.l	#6,SP

	; Quitter

INIT_ERROR:	clr.w	-(SP)
	TRAP	#1

	RTS

	; Additionne des threads

TEST:	move.w	#7,D0
.TEST_B:	move.w	D0,-(SP)

	move.l	#TEXT,D0
	BSR	PRINT
	
	lea	TEST1,A0
	BSR	T_ADD

	lea	TEST2,A0
	BSR	T_ADD

	lea	TEST3,A0
	BSR	T_ADD

	move.w	(SP)+,D0
	DBRA.w	D0,.TEST_B
	RTS

	; Thread 1

TEST1:	move.l	#TEXT1,D0
	BSR	PRINT
	RTS

	; Thread 2

TEST2:	move.l	#TEXT2,D0
	BSR	PRINT
	RTS

	; Thread 3

TEST3:	move.l	#TEXT3,D0
	BSR	PRINT
	RTS

*******************************************************************************
* SI VOUS UTILISER CES CODES POUR UN PROGRAMME, PRECISEZ-LE DANS LA
* DOCUMENTATION ET DANS L'EXECUTABLE.
* ET SURTOUT CONTACTER-MOI:
*   Simon  VOLANT
*  2, rue de Mƒcon
*    51100 REIMS
*******************************************************************************

*******************************************************************************
*
* MK68 (MICRO-KERNEL 68000) LE MULTITACHE SUR 68000!!!
* (C)1996 SIMON VOLANT
*
* PARTIE NOYAU:
* TOUT POUR FAIRE DU MULTITACHE SUR 68000.
* ATTENTION AVEC L'UTILISATION DES APPELS SYSTEMS (TRAP #1).
* LE TOS N'EST PAS FAIT POUR TOURNER EN MULTI-THREAD.
*
* STRUCTURE DE LA ZONE THREAD:
******************************
* NOM    * OFFSET  * TAILLE * DESCRIPTION
* STACK  *       0 *      4 * POINTEUR DE PILE SP
* KILL   *       4 *      2 * ON DETRUIT LE THREAD LORSQUE KILL EST NEGATIF.
*******************************************************************************
STACK	EQU	0
KILL	EQU	4
MAX_THREAD	EQU	64+1
LOF_THREAD	EQU	1024
KILL_IT	EQU	-1
* TO SCHEDULE:	TRAP	#8
*******************************************************************************
***** INSTALLATION DU NOYAU MULTITACHE
***** TIMER A POUR GERER LA PERMUTATION DES TACHES
***** TRAP #8 POUR PROVOQUER LE SCHEDULER

T_INSTALL:	; Petit texte pour la forme

	pea	TXT_INSTALL
	move.w	#9,-(SP)
	TRAP	#1
	addq.l	#6,SP

* ON RESERVE DE LA MEMOIRE POUR LE THREAD NUMERO 1:
* IL SE CREE LUI-MEME
	; Reserve m‚moire

	pea	LOF_THREAD.L
	move.w	#$48,-(SP)
	TRAP	#1
	addq.l	#6,SP
	
	; Pointeur
	
	lea	P_LIST,A0
	move.l	D0,(A0)
	move.l	#P_LIST,E_LIST

* ON INSTALLE LE TIMER A ET LA TRAP #8
* VOUS POUVEZ VOUS-MEME VARIER LA FREQUENCE

	; Bloque le 68000 et installe les vecteurs

	move.w	#$2700,SR
	move.l	#SCHEDULER,$0A0.w	; 
	move.l	#SCHEDULER,$134.w	; 
	bset	#5,$FFFFFA07.w	; 
	bset	#5,$FFFFFA13.w	; 
	move.b	#0,$FFFFFA1F.w	; 
	move.b	#7,$FFFFFA19.w	; 
* ON CONTINUE A CREER LE THREAD PERE

	; 

	move.l	(SP)+,A1
	move.l	SP,EX_SP
	move.l	E_LIST,A0
	move.l	(A0),A0
	lea	LOF_THREAD(A0),SP
	clr.w	KILL(A0)
	move.l	A1,-(SP)
	move.w	#-1,MUSTEK

	; Retour … la normale !

	move.w	#$2300,SR

* A PARTIR D'ICI, LE PROGRAMME PEUT-ETRE PREEMPTE!!!

	RTS

TXT_INSTALL:	dc.b	"ALIVE! MK68 IS ALIVE!",13,10,0

	EVEN
*******************************************************************************
***** DESINITIALISATION

T_REMOVE:	; On stoppe tout

	move.w	#$2700,SR

* ON STOPPE LE TIMER A	; On d‚sinstalle les vecteurs

	bclr.b	#5,$FFFFFA07.w	; 
	bclr.b	#5,$FFFFFA13.w	; 
	move.b	#0,$FFFFFA19.w	; 
	move.b	#0,$FFFFFA1F.w	; 

* ON REINSTALLE L'ANCIENNE PILE

	move.l	(SP)+,A1
	move.l	EX_SP,SP
	move.l	A1,-(SP)

	; On remet tout en route

	move.w	#$2300,SR
	
	; Petit message pour la forme
	
	pea	TXT_REMOVE
	move.w	#9,-(SP)
	TRAP	#1
	addq.l	#6,SP
	
	RTS

TXT_REMOVE:	dc.b	"DEAD! MK68 IS DEAD!",13,10,0

	EVEN

*******************************************************************************
***** INTERRUPT LE SCHEDULER EN LUI-MEME

SCHEDULER:	not.l	$FFFF9800.w	; 
	clr.b	$FFFFFA19.w	; 

* LE THREAD REFUSE DE SE FAIRE INTERROMPRE

	tst.w	MUSTEK
	BEQ	.FIN1

* ON SAUVE LE PROCESSUS

.NORMAL:	movem.l	D0-A7,-(SP)
	move.l	E_LIST,A0
	move.l	A0,A1
	move.l	(A1),A1
	move.l	SP,(A1)

* ON PREND LE SUIVANT SUR LA LISTE

.NEXT1:	addq.l	#4,A0
.RETEST:	tst.l	(A0)
	BNE	.CONT1
	lea	P_LIST,A0

* ON TESTE SI ON DOIT LE TUER:
* SUICIDE OU MEUTRE

.CONT1:	move.l	(A0),A1
	tst.w	KILL(A1)
	BPL	.CONT2

* SUICIDE OU MEUTRE

.KILL_IT:	move.l	A0,A1
.NEXT2:	addq.l	#4,A1	* ON REMPLACE LA TACHE A TUER
	tst.l	(A1)	* PAR LA DERNIERE DE LA LISTE
	BNE	.NEXT2	* OU LE NULL DE FIN DE LISTE
	subq.l	#4,A1
	clr.l	(A0)
	move.l	(A1),(A0)
	clr.l	(A1)
	BRA	.RETEST

* ICI, ON LANCE LE NOUVEAU PROCESSUS

.CONT2:	move.l	A0,E_LIST
	move.l	(A0),A0
	move.l	(A0),SP
	movem.l	(SP)+,D0-A7
.FIN1:	btst	#3,$FFFFFA17.W
	BEQ	.CT
	move.b	#%11011111,$FFFFFA0F.W
.CT:	not.l	$FFFF9800.W
	move.b	#7,$FFFFFA19.W

	RTE

*******************************************************************************
***** INSTALLER UN NOUVEAU THREAD
* ENTREE: A0 QUI CONTIENT LE POINTEUR SUR LE CODE A EXECUTER PC
* SORTIE: D0 ADRESSE DE LA ZONE DE DONNEES INTERNE
* LORS DE LA RENCONTRE DU RTS, LE PROCESSUS SE SUICIDE

T_ADD:	move.l	A0,A6

* ON ALLOUE DE LA MEMOIRE

	move.l	#LOF_THREAD,D0
	BSR	MALLOC
	move.l	D0,D6

* ON COUPE TOUTE LES ITS

	move.w	MUSTEK,-(SP)
	clr.w	MUSTEK

* ON AJOUTE LA STRUCTURE A LA LISTE

	lea	P_LIST,A0
.RETRY:	tst.l	(A0)+
	BNE	.RETRY
	subq.l	#4,A0
	move.l	D6,(A0)

* ON CREE LA PILE PAR DEFAUT

	add.l	#LOF_THREAD,D6
	move.l	D6,A5
	move.l	#T_SUICIDE,-(A5)
	move.w	#0134,-(A5)
	move.l	A6,-(A5)
	move.w	SR,-(A5)
	movem.l	D0-A7,-(A5)

* ON CREE L'ENTETE
	move.l	(A0),A0
	move.l	A5,(A0)	* STOCK STACK
	clr.w	KILL(A0)	* NO KILL

* ON REMET LE MUSTEK (JETON SYSTEM)

	move.w	(SP)+,MUSTEK

	RTS

*******************************************************************************
***** MEURTRE D'UN THREAD
* ENTREE: A0 ADRESSE DE LA ZONE DE DONNEES INTERNE

T_KILL:	move.w	#KILL_IT,KILL(A0)
	BSR	T_SCHEDULE

	RTS

*******************************************************************************
***** SUICIDE D'UN THREAD

T_SUICIDE:	move.l	E_LIST,A0
	move.l	(A0),A0
	move.w	#KILL_IT,KILL(A0)

	BSR	T_SCHEDULE

	BRA	T_SUICIDE

*******************************************************************************
***** ON PROVOQUE LA PREEMPTION (PAS BESOIN DE PRENDRE PLUS DE CPU)

T_SCHEDULE:	TRAP	#8

	RTS
*******************************************************************************


*******************************************************************************
*
* MK68 (MICRO-KERNEL 68000) LE MULTITACHE SUR 68000!!!
* (C)1996 SIMON VOLANT
*
* PARTIE INTERFACE SYSTEM:
* PERMET DE GERER LES APPELS AVEC LE TOS.
* A UTILISER LORSQUE MK68 EST ACTIF!!!!
*
*******************************************************************************
* PRISE DU JETON
* ON MONOPOLISE LE CPU  (POUR PAS QUE QUELQU'UN D'AUTRE NE LE PRENDRE
* ENTRE 2 TESTS). QUE L'ON PEUT RENDRE ENSUITE.

GET_MSYS:	clr.w	MUSTEK
	tst.w	M_SYSTEM
	BNE	.GET_IT
	move.w	#-1,MUSTEK

	BSR	T_SCHEDULE

	BRA	GET_MSYS

.GET_IT:	clr.w	M_SYSTEM
	move.w	#-1,MUSTEK

	RTS

*******************************************************************************
* RENDRE LE JETON

PUT_MSYS:	move.w	#-1,M_SYSTEM

	RTS

*******************************************************************************
* FONCTION MALLOC
* D0: NOMBRE D'OCTETS A RESERVER
* INTERFACE AVEC LE SYSTEM

MALLOC:	BSR	GET_MSYS

	move.l	D0,-(SP)
	move.w	#$48,-(SP)
	TRAP	#1
	addq.l	#6,SP

	BSR	PUT_MSYS

	*BSR	T_SCHEDULE

	RTS

*******************************************************************************
* FONCTION PRINT
* D0: TEXT A IMPRIMER
* INTERFACE AVEC LE SYSTEM

PRINT:	BSR	GET_MSYS

	move.l	D0,-(SP)
	move.w	#$9,-(SP)
	TRAP	#1
	addq.l	#6,SP

	BSR	PUT_MSYS

	BSR	T_SCHEDULE

	RTS

*******************************************************************************
* FONCTION WAIT_A_KEY
* INTERFACE AVEC LE SYSTEM

WAIT_A_KEY:	BSR	GET_MSYS

	move.w	#7,-(SP)
	TRAP	#1
	addq.l	#2,SP

	BSR	PUT_MSYS

	BSR	T_SCHEDULE

	RTS

*******************************************************************************
M_SYSTEM:	dc.w	-1
*******************************************************************************

	 SECTION DATA

TEXT1:	dc.b	"1",13,10,0
	EVEN

TEXT2:	dc.b	"2",13,10,0
	EVEN

TEXT3:	dc.b	"3",13,10,0
	EVEN

TEXT:	dc.b	" 5 THREADS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",13,10,0
	EVEN

	 SECTION BSS

EX_SP:	DS.l	1
MUSTEK:	DS.w	1
E_LIST:	DS.l	1
P_LIST:	DS.l	MAX_THREAD

	EVEN