* REGISTRE DU MFP 68901
IEA	EQU	$FFFA07	registre d'interup. A, hors service
IEB	EQU	$FFFA09	registre d'interup. B, hors service
ISRA	EQU	$FFFA0F	interup. en service (registre A)
IMA	EQU	$FFFA13	masque d'interup. A
TBCR	EQU	$FFFA1B	registre de controle du Timer B
TBDR	EQU	$FFFA21	registre Data du timer B

* REGISTRE DE L'ECRAN
ECR_RAM	EQU	$FF8201	registre de la ram ‚cran
MODE	EQU	$FF8260	contient la r‚solution

* REGISTRE D'EXECPTIONS
VBL_VEC	EQU	$70	vecteur d'interup. verticale
HBL_VEC	EQU	$120	vecteur d'inter. horiz. (Timer B)
KEY_VEC	EQU	$118	vecteur d'interup. clavier/MIDI

	MOVE.L	#MOUSE_OFF,-(SP)
	MOVE.W	#0,-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
* passage en mode superviseur et sauvegarde de l'ancienne pile
	CLR.W	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	LEA	ANC_PILE(PC),A0
	MOVE.L	D0,(A0)
	
	BSR	DESSIN_ECRAN	pour afficher les carr‚s
	
	MOVE.W	#15,D0	petit compteur
	LEA	$FF8240,A1	adresse de la palette du ST		
	LEA	ANC_PAL(PC),A0	buffer de rangement
SAUVE_PAL	
	MOVE.W	(A1)+,(A0)+	sauvegarde palette
	DBF	D0,SAUVE_PAL
	
	
* sauvegarde des valeurs des registres du syst‚me
	LEA	ANC_IEA(PC),A1
	MOVE.B	IEA,(A1)
	LEA	ANC_IEB(PC),A1
	MOVE.B	IEB,(A1)
	LEA	ANC_IMA(PC),A1
	MOVE.B	IMA,(A1)
	
	LEA	ANC_MODE(PC),A1
	MOVE.B	MODE,(A1)
	
	AND.B	#$DF,IEB	arrete timer C 
	AND.B	#$FE,IEA	arrete timer B (H. interup.)
	
	LEA	ANC_HBL(PC),A1	sauve valeur anc HBL
	MOVE.L	HBL_VEC,(A1)
	
	LEA	HBL_INTER(PC),A0	en route pour HBL_INTER
	MOVE.L	A0,HBL_VEC
	
	OR.B	#1,IEA	rend impossible HBL interup.
	OR.B	#1,IMA
	
	MOVE.B	#0,MODE	basse r‚s. si en moyenne
	
	LEA	ANC_VBL+2(PC),A1
	MOVE.L	VBL_VEC,(A1)
	LEA	VBL_INTER(PC),A0	en route pour VBL_INTER
	MOVE.L	A0,VBL_VEC	

ATTENTE	MOVE.W	#7,-(SP)	attend un appui sur la barre
	TRAP	#1	d'espace pour finir le programme
	ADDQ.L	#2,SP
	CMP.B	#$20,D0
	BNE.S	ATTENTE
	
* puisque c'est fini, on remet en place tout les paramŠtres
* qu'on a sauv‚s au d‚but, on remet la palette d'origine,
* on quitte le mode superviseur et on termine le programme.
	
	MOVE.B	ANC_IEB(PC),IEB
	MOVE.B	ANC_IEA(PC),IEA
	MOVE.B	ANC_IMA(PC),IMA
	MOVE.B	ANC_MODE(PC),MODE
	
	MOVE.L	ANC_VBL+2(PC),VBL_VEC
	MOVE.L	ANC_HBL(PC),HBL_VEC
	
	MOVE.W	#15,D0	petit compteur
	LEA	$FF8240,A1
	LEA	ANC_PAL(PC),A0
REND_PAL	MOVE.W	(A0)+,(A1)+
	DBF	D0,REND_PAL
	
	MOVE.L	ANC_PILE(PC),-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	MOVE.L	#MOUSE_ON,-(SP)	met 8 avec Xbios(25)
	MOVE.W	#0,-(SP)		cela r‚active la souris
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
	MOVE.W	#0,-(SP)	bye bye...
	TRAP	#1
	
****************************************************************		
* dessin de l'‚cran (16 colonnes, 1 de chaque couleur)
* au lieu de ssiner des colonnes, on peut afficher
* une image, c'est comme ti veux!
DESSIN_ECRAN
	LEA	BITBLT(PC),A6	paramŠtres pour $A007
	
	CLR.L	D0	prend l'adresse de la ram ‚cran
	MOVE.B	ECR_RAM,D0
	LSL.L	#8,D0
	MOVE.B	ECR_RAM+2,D0
	LSL.L	#8,D0
	MOVE.L	D0,32(A6)	et la sauve dans les paramŠtres
	
	DC.W	$A000	initialisation ligne A
	
	CLR.W	D2	coordonn‚es Y
	MOVE.W	#19,D4	pour faire la boucle1 20 fois
	
BOUCLE1	CLR.W	D1	coordonn‚es X
	MOVE.W	#15,D3	pour faire la boucle2 16 fois
	
BOUCLE2	LEA	BOX(PC),A0
	MOVE.L	A0,$12(A6)
	MOVE.W	#4,4(A6)
	MOVE.W	D3,D0
	EOR.W	#$F,D0
	MOVE.W	D0,6(A6)	couleur du bloc
	
	CLR.W	8(A6)
	MOVE.W	D1,$1C(A6)	coordonn‚e X
	MOVE.W	D2,$1E(A6)	coordonn‚e Y
	
	MOVEM.L	D0-D4/A6,-(SP)
	DC.W	$A007	fonction de transfert de bit (ligne A)
	MOVEM.L	(SP)+,D0-D4/A6
	
	ADD.W	#20,D1	20 de plus pour les X
	DBRA	D3,BOUCLE2
	
	ADD.W	#10,D2	10 de plus pour les Y
	DBRA	D4,BOUCLE1
	
	RTS
	
* on vient ici … chaque fin d'affichage de ligne	
HBL_INTER	
	MOVEM.L	A0/A1,-(SP)
	LEA	$FF8240,A0	adresse de la palette du ST dans A0
	MOVE.L	POINT_PAL(PC),A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+	on transfŠre la	
	MOVE.L	(A1)+,(A0)+	nouvelle pallette
	MOVE.L	(A1)+,(A0)+	le plus vite
	MOVE.L	(A1)+,(A0)+	possible.
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	LEA	POINT_PAL(PC),A0	restaure pointeur
	MOVE.L	A1,(A0)
	MOVEM.L	(SP)+,A0/A1
	BCLR	#0,ISRA
	RTE
	
VBL_INTER	
	MOVEM.L	A0/A1,-(SP)
	LEA	PALETTE(PC),A0	charge adresse palette
	LEA	POINT_PAL(PC),A1
	MOVE.L	A0,(A1)
	
	MOVE.B	#0,TBCR	arr‚te le timer
	MOVE.B	#6,TBDR	compte 6 ‚vŠnements (6 lignes)
	MOVE.B	#8,TBCR	d‚marre le timer .Ainsi la premiŠre
* interup. H_Blank arrivera … la 6 Šme ligne.

	MOVEM.L	(SP)+,A0/A1
	
ANC_VBL	
	JMP	$0

	SECTION DATA
ANC_HBL	DC.L	0
POINT_PAL	DC.L	0
ANC_PILE	DC.L	0
ANC_PAL	DC.W	16,0
ANC_IEA	DC.B	0
ANC_IEB	DC.B	0
ANC_IMA	DC.B	0
ANC_MODE	DC.B	0


* bloc de paramŠtres pour la ligne A ($A007)
BITBLT	DC.W	20,10
	DC.W	4
	DC.W	0,0
	DC.B	4,4,7,7
	DC.W	0,0
	DC.L	BOX
	DC.W	2,4,0
	DC.W	0,0
	DC.L	$78000
	DC.W	8,160,2
	DC.L	0,0,0,0,0,0,0,0,0
	
*donn‚es pour l'image qui sera affich‚ par BITBLT
BOX	DC.L	$FFFFF000,$FFFFF000
	DC.L	$FFFFF000,$FFFFF000
	DC.L	$FFFFF000,$FFFFF000
	DC.L	$FFFFF000,$FFFFF000
	DC.L	$FFFFF000,$FFFFF000

MOUSE_OFF	DC.B	18,0
MOUSE_ON	DC.B	8,0


PALETTE
    DC.W   
$070,$170,$270,$370,$470,$570,$670,$770,$760,$750,$740,$730,$720,$710,$700,$702 
    DC.W   
$070,$170,$270,$370,$470,$570,$670,$770,$760,$750,$740,$730,$720,$710,$700,$702 
    DC.W   
$071,$060,$160,$260,$360,$460,$560,$660,$650,$640,$630,$620,$610,$600,$602,$712 
    DC.W   
$171,$061,$050,$150,$250,$350,$450,$550,$540,$530,$520,$510,$500,$502,$612,$722 
    DC.W   
$271,$161,$051,$040,$140,$240,$340,$440,$430,$420,$410,$400,$402,$512,$622,$732 
    DC.W   
$371,$261,$151,$041,$030,$130,$230,$330,$320,$310,$300,$302,$412,$522,$632,$742 
    DC.W   
$471,$361,$251,$141,$031,$020,$120,$220,$210,$200,$202,$312,$422,$532,$642,$752 
    DC.W   
$571,$461,$351,$241,$131,$021,$010,$110,$100,$102,$212,$322,$432,$542,$652,$762 
    DC.W   
$671,$561,$451,$341,$231,$121,$011,$000,$002,$112,$222,$332,$442,$552,$662,$772 
    DC.W   
$771,$661,$551,$441,$331,$221,$111,$001,$003,$012,$122,$232,$342,$452,$562,$672 
    DC.W   
$761,$651,$541,$431,$321,$211,$101,$103,$113,$013,$022,$132,$242,$352,$462,$572 
    DC.W   
$751,$641,$531,$421,$311,$201,$203,$213,$223,$123,$023,$032,$142,$252,$362,$472 
    DC.W   
$741,$631,$521,$411,$301,$303,$313,$323,$333,$233,$133,$033,$042,$152,$262,$372 
    DC.W   
$731,$621,$511,$401,$403,$413,$423,$433,$443,$343,$243,$143,$043,$052,$162,$272 
    DC.W   
$721,$611,$501,$503,$513,$523,$533,$543,$553,$453,$353,$253,$153,$053,$062,$172 
    DC.W   
$711,$601,$603,$613,$623,$633,$643,$653,$663,$563,$463,$363,$263,$163,$063,$072 
    DC.W   
$701,$703,$713,$723,$733,$743,$753,$763,$773,$673,$573,$473,$373,$273,$173,$073 
    DC.W   
$704,$714,$724,$734,$744,$754,$764,$774,$674,$574,$474,$374,$274,$174,$074,$076 
    DC.W   
$705,$604,$614,$624,$634,$644,$654,$664,$564,$464,$364,$264,$164,$064,$066,$176 
    DC.W   
$715,$605,$504,$514,$524,$534,$544,$554,$454,$354,$254,$154,$054,$056,$166,$276 
    DC.W   
$725,$615,$505,$404,$414,$424,$434,$444,$344,$244,$144,$044,$046,$156,$266,$376 
    DC.W   
$735,$625,$515,$405,$304,$314,$324,$334,$234,$134,$034,$036,$146,$256,$366,$476 
    DC.W   
$745,$635,$525,$415,$305,$204,$214,$224,$124,$024,$026,$136,$246,$356,$466,$576 
    DC.W   
$755,$645,$535,$425,$315,$205,$104,$114,$014,$016,$126,$236,$346,$456,$566,$676 
    DC.W   
$765,$655,$545,$435,$325,$215,$105,$004,$006,$116,$226,$336,$446,$556,$666,$776 
    DC.W   
$775,$665,$555,$445,$335,$225,$115,$005,$007,$106,$216,$326,$436,$546,$656,$766 
    DC.W   
$675,$565,$455,$345,$235,$125,$015,$017,$117,$107,$206,$316,$426,$536,$646,$756 
    DC.W   
$575,$465,$355,$245,$135,$025,$027,$127,$227,$217,$207,$306,$416,$526,$636,$746 
    DC.W   
$475,$365,$255,$145,$035,$037,$137,$237,$337,$327,$317,$307,$406,$516,$626,$736 
    DC.W   
$375,$265,$155,$045,$047,$147,$247,$347,$447,$437,$427,$417,$407,$506,$616,$726 
    DC.W   
$275,$165,$055,$057,$157,$257,$357,$457,$557,$547,$537,$527,$517,$507,$606,$716 
    DC.W   
$175,$065,$067,$167,$267,$367,$467,$567,$667,$657,$647,$637,$627,$617,$607,$706 
    DC.W   
$075,$077,$177,$277,$377,$477,$577,$677,$777,$767,$757,$747,$737,$727,$717,$707
    DC.W   
$075,$077,$177,$277,$377,$477,$577,$677,$777,$767,$757,$747,$737,$727,$717,$707

