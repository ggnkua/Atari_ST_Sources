	 Documentation Vid‚o
	
Mode true color:
RRRRRGGGGGGBBBBB

Cookie: _VDO : $00000300

******** SetScreen
~XBIOS(5,L:logique,L:physique,W:st_rez,W:falc_rez)
si ST_REZ=3 alors on utilise FALC_REZ
NB: Maintenant, le VDI est patch‚ (en th‚orie...).


******** VSetMode
old_falc_rez.w=XBIOS(88,W:falc_rez)
FALC_REZ est cod‚ comme suit:
				???????F SoPv8nnn
avec:

		1			0

F	Interlac‚/Double ligne	Mode normal
S	ST compatible		Modes Falcon
O	Overscan		Non overscan
P	PAL			NTSC
V	Mode VGA		Mode RVB
8	~640 pixels		~320 pixels
nnn	Nombre de plans vid‚os (1-2-4-8-16)
	
NB: Pas possible d'avoir 2 couleurs en 40 colonnes, ou bien 65536 couleurs
en VGA 640 pixels.

VERTICAL  = 256
MODE_ST   = 128
OVERSCAN  =  64
PAL       =  32   NTSC  = 0
VGA       =  16   RVB   = 0
L_640     =   8   L_320 = 0
C_65536  = 4
C_256    = 3
C_16     = 2
C_4      = 1
C_2      = 0

NB (2) : On est pri‚ de faire gaffe en l'utilisant...


******** MonType
type_moniteur.w=XBIOS(89)
La valeur obtenue est trŠs explicite:
0 -> Un moniteur monochrome ST (Ok)
1 -> Un moniteur couleur RVB (Re OK)
2 -> Un moniteur VGA (Ca parait Ok)
3 -> Une T‚l‚vision Couleur Pal/Secam, multistandard avec 2 prises canal
     plus... (Gasp ! En plus c'est une 16/9Šme... Waouoouuuu)
     

******** VSetSync
~XBIOS(90,W:sync_mode)
SYNC_MODE se pr‚sente ainsi: 00000hvc
				  |||
				  ||+--> Horloge externe 
				  |+---> Syncro verticale externe
				  +----> Syncro horizontale externe
NB: Ca ne fonctionne qu'en mode FALCON, et pas dans les modes 4 couleurs !
(D'ici … en conclure que le sh‚ma hardware du VIDEL a ‚t‚ tach‚ par une
tasse de caf‚ au moment de la conception...) [Quels cons]
... [Tu sais ce qu'il te disent les cons ????]


******* VGetSize
taille_de_l'‚cran.l=XBIOS(91,W:falc_rez)
Je ne pense pas qu'il faille expliquer...


******* VSetRGB (XBIOS(6)+ sur'activ‚ avec agents colorants)
~XBIOS(93,W:premiere_couleur,W:nombre_couleurs,L:adresse_couleurs%)
Ca charge une palette vers le VIDEL.
Les couleurs sont cod‚s au format 0RVB.L


******* VGetRGB
~XBIOS(94,W:premiere_couleur,W:nombre_couleurs,L:adresse_couleurs%)
Ca permet de lire une palette (Ca manquait.).


******* VSetMask
~XBIOS(150,W:mask_and,W:mask_or)
Par defaut, and=-1 et or=0
Ca ne sert … rien, hors de la vid‚o (C'est pour d‚finir la couleur
transparente...).
