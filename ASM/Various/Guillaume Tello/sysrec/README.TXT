******* SYSREC documentation *******
      guillaume.tello@orange.fr
*******                      *******

(english below)

SYSREC est un petit logiciel qui enregistre les appels systŠme d'un
programme sp‚cifi‚.

Mat‚riel:
---------
	Un Atari sous TOS

Qu'enregistre t-il?
-------------------
	Les appels GEMDOS, BIOS, XBIOS, AES, VDI et LineA, les adresses
	d'appel.

Comment fonctionne t-il?
------------------------
	On lance SYSREC.PRG, de pr‚f‚rence depuis le dossier du programme
… surveiller.
	R‚pondre … toutes les questions:
	Program name
	Command line
	Buffer size (*)
	What to record
	When to start recording (#)
	Save LOG File (*)
	Save TEXT File

	Ensuite, le programme est charg‚, ex‚cut‚ et, en retour, vous
obtenez deux fichiers (ou seulement ceux s‚lectionn‚s):

(*) SYSREC.LOG une copie m‚moire des codes enregistr‚s. Sa taille vous
donne exactement la RAM qui a ‚t‚ utilis‚e pourl'enregistrement. Cette
information peut vous aider … bien calibrer le paramŠtre Buffer Size.
	En fixant le flag TTRam Mem le buffer est allou‚ en TT Ram, sinon
il est en ST Ram.

SYSREC.TXT un fichier texte avec les appels de chaque fonction avec num‚ro
et nom, chaque ligne est de cette forme:

GEMDOS(074/$04A) :  Mshrink
	Il y a eu une appel … la fonction Mshrink du Gemdos et c'est la
	fonction 74 ou $4A en hexad‚cimal.

GEMDOS(074/$04A) :  $00000022  Mshrink
	Idem, mais vous avez sp‚cifi‚ l'option "O" qui enregistre les
	adresses. Cet appel a ‚t‚ r‚alis‚ … l'offset $22 depuis la zone
	text.
	Donc … l'offset $22 + $100 = $122 depuis la basepage
	Ou finalement … l'offset $22 + $1C = $3E dans le fichier PRG

XBIOS (004/$004)*:  $00000048  Getrez
	Une ‚toile avant les deux points signale que l'appel a ‚t‚ fait en
	mode superviseur.

(#) Quand commencer … enregistrer?
----------------------------------
	Deux options sont offertes:
	- soit imm‚diatement etparla suite Alt+Help est une bascule qui
	permet de mettre l'enregistrement en pause ou de le red‚marrer.
	- soit l'enregistrement commence au premier Alt+Help.

Utilisation d'un fichier SYSREC.INF
-----------------------------------
	Si des utilisations r‚p‚t‚es sont n‚cessaires pour un mˆme
programme, on peut ‚crire une bonne fois pour toutes les options fixes
dans un fichier texte SYSREC.INF. Les options absentes de ce fichier
seront demand‚es au clavier lors de l'ex‚cution. Le fichier a ce format:

; commentaire		chaque ligne commen‡ant par ";" est un commentaire
p="nom du programme"	sp‚cifie le nom du programme entre guillements
c="ligne de commande"	idem pour la ligne de commande
b=nnnnn			taille du buffer en Kilo Octets (d‚cimal)
s=I ou s=A		d‚marrer (start) imm‚diatement ou avec Alt+Help
l=Y ou l=N		enregistrer ou non le fichier LOG
t=Y ou t=N		enregistrer ou non le fichier texte.
r=GBXAVLO		sp‚cifierles initiales de ce qu'il faut
			enregistrer (Gemdos, etc...). Ligne vide pour
			tout.
	L'option "r=" peut etre cibl‚e sur certains fonctions:
r=G+60+61AV+120
	Enregistrera uniquement les appels GEMDOS 60 et 61
	Tous les appels AES
	Et uniquement l'appel VDI 120
	
	Si au lieu d'un "+", le num‚ro de fonction est pr‚c‚d‚ d'un "-",
le progamme d‚clanche une instruction "illegal". Ce qui peut permettre
un arret dans un Debugger. Dans ce cas:
	Pour GEMDOS/BIOS/XBIOS:
	A2 = adresse dans le programme appelant
	Pour AES/VDI:
	A1 = pointeur sur le tableau CONTROL
	A2 = adresse dans le programme appelant
	Pour le LineA:
	A2 = adresse dans le programme appelant
	D0 = num‚ro de fonction
	
	Les espaces ne sont pas accept‚s!
	S = Y sera ignor‚.
	Majuscules ou minuscules , peu importe:
	T=y ou t=Y ou T=Y sont ‚quivalents.

Utilisation de plusieurs fichiers INF
-------------------------------------
	Par d‚faut, le fichier d'information est SYSREC.INF. Mais si vous
d‚posez un autre fichier INF sur le programme, il se lance en ouvrant ce
dernier.
	Ceci vous permet plusieurs configurations!

Format du fichier SYSREC.LOG
----------------------------
	Il est orient‚ MOT 16 bits:

15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
 S  t  t  t  n  n  n  n  n  n  n  n  n  n  n  n

S = Bit superviseur
	si S=1, appel en superviseur, Si S=0, appel en User

ttt = code du TRAP
	0 VDI avec sous fonction, le mot suivant est le num‚ro de
	sous-fonction
	1 GEMDOS
	2 AES
	3 BIOS
	4 XBIOS
	5 VDI
	6 LINEA

nnnnnnnnnnnn = num‚ro de la fonction

Cas particulier: Si le mot est $0000 : Alt+Help record OFF
		 Si le mot est $FFFF : Alt+Help record ON

Avec l'option "O", chaque code est suivi d'un mot long de 4 octets
repr‚sentant l'adresse d'appel.

************************ Fin du fran‡ais*****************************

SYSREC is a little system monitor that records the system calls performed
by a specified application.

Requierements:
--------------
	Atari with TOS

What can it record?
-------------------
	GEMDOS, BIOS, XBIOS, AES, VDI and LineA calls, and offsets of
	calling addresses.

How does it work?
-----------------
	Run SYSREC preferabily from the folder of the application to
monitor.
	Answer every question:
	Program name
	Command line
	Buffer size (*)
	What to record
	When to start recording (#)
	Save LOG File (*)
	Save TEXT File

Then the program is loaded, executed and, upon exit, you get two files (or
only selected ones):

(*) SYSREC.LOG is a memory copy of the recorded codes, its size will tell
you how many RAM was actually used. This can help you tune the buffer size
correctly.
	If you set the flag TTRam mem then the buffer is allocated in TT
Ram, else in ST Ram.

SYSREC.TXT is a text file with the system calls with number and names,
each line has this format:

GEMDOS(074/$04A) :  Mshrink
	A call to GEMDOS Mshrink has been recorded. It is function 74 or
	$4A in hexadecimal.

GEMDOS(074/$04A) :  $00000022  Mshrink
	The same, but you asked for offset recording (oprion "O), so this
	call has been made from offset $22 from TEXT zone.
	Then it is offset $22 + $100 = $122 from basepage
	Or finally offset $22 + $1C = $3E in the PRG file

XBIOS (004/$004)*:  $00000048  Getrez
	A star (*) before semi-column indicates that the call was made in
	supervisor mode.

(#) When to start recording?
----------------------------
	Two options: either immediately and then every Alt+Help toggles
	between recording or pause.

	Or wait for the first Alt+Help to start recording.

The use of SYSREC.INF
---------------------
	If your program is to be monitored more than once, you can create
a INF text file containing every option or only the fixed ones. Then only
missing options will be prompted from the keyboard.
	The format of this file is:
; comment		every line with ";" is a comment
p="program name"        specifies the program to monitor between " and "
c="command line"	idem for the command line
b=nnnn			buffer size in kiloBytes (decimal)
s=I or s=A		start mode (immediately or Alt+Help)

l=Y or l=N		save (Y) or not (N) LOG file
t=Y or t=N		save (Y) or not (N) text file

r=GBXVALO		any subset of GBXAVLO to specify what to record
			empty line to record all
	The option "r=" can target specific functions:
r=G+60+61AV+120
	Will record only GEMDOS 60 and 61
	All AES calls
	And only VDI 120
	
	If, instead of a "+", the function number starts with a "-",
the program jumps to an ILLEGAL instruction. This is a wayt to stop
the execution under a Debugger.
	In this case:
	Pour GEMDOS/BIOS/XBIOS:
	A2 = address in the calling program
	Pour AES/VDI:
	A1 = pointer to CONTROL array
	A2 = address in the calling program
	Pour le LineA:
	A2 = address in the calling program
	D0 = function number


	No space is accepted in syntax, for example:
	s = I 		will be ignored

	The case is ignored, thus
	S=i or S=I or s=I are the same.

Multiple INF files usage
------------------------
	The default INF file is SYSREC.INF. But you can drag and drop
another INF file onto the program. Then, this last will be used!
	You can have several sets ofconfigurations.

SYSREC.LOG internal format
--------------------------
	The file is 16 bits WORD oriented:

15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
 S  t  t  t  n  n  n  n  n  n  n  n  n  n  n  n

S = supervisor bit
	if S=1, call in supervisor, if S=0, call in User

ttt = TRAP code
	0 VDI with subfunction, next word is the subfunction number.
	1 GEMDOS
	2 AES
	3 BIOS
	4 XBIOS
	5 VDI
	6 LINEA

nnnnnnnnnnnn = function number

Reserved values: if word is $0000 : Alt+Help record OFF
		 if word is $FFFF : Alt+Help record ON

With the "O" option, every code is followed by a 4-bytes value
representing the calling address.