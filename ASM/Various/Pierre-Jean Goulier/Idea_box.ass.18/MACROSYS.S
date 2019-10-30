;
; BibliothŠque de macros GEMDOS, BIOS, XBIOS et LINE A.
; Auteur : P-Jean Goulier.
;
; Pour chaque macro : 1 - Descriptif succinct.
;		      2 - Syntaxe.
;		      3 - Retour ‚ventuel.

;
; Macros GEMDOS.
;


pterm0	macro			; Fin de programme.
				; pterm0
	clr	-(sp)
	trap	#1
	endm

cconin	macro			; Attente d'un caractŠre + sortie vid‚o.
				; cconin
				; D0 = caractŠre.
				
	move	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

cconout	macro			; Edition d'un caractŠre.
				; cconout char
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	endm

cauxin	macro			; R‚ception d'un caractŠre sur RS232.
				; cauxin
				; D0 = caractŠre.
	move	#3,-(sp)	
	trap	#1
	addq.l	#2,sp
	endm
	
cauxout	macro			; Emission d'un caractŠre sur RS232.
				; cauxout char
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
cprnout	macro			; Emission d'un caractŠre sur la Centronics
				; cprnout char
				; D0 = -1 si caractŠre imprim‚.
				; D0 = 0  si problŠme (30s).

	move	\1,-(sp)
	move	#5,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
crawio	macro			; Print / Inkey.
				; crawio #$FF => Inkey
				; crawio  'X' => Print
	move	\1,-(sp)
	move	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
crawcin	macro			; Attente d'un caractŠre sans sortie vid‚o.
				; crawcin
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

cconws	macro			; Affichage d'un texte (fin=0).
				; cconws texte
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
cconrs	macro			; R‚ception d'une ligne de saisie.
				; cconrs buffer
				; Avant saisie : 1er oct Buffer = Nb car. maxi.
				; AprŠs saisie : 2me oct Buffer = Nb car. re‡us.
				; ChaŒne saisie … partir du 3me octet.
	move.l	\1,-(sp)
	move	#$A,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
cconis	macro			; Teste du buffer clavier.
				; cconis
				; D0 = -1 => caractŠre disponible.
				; D0 = 0  => aucun caractŠre.

	move	#$B,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
dsetdrv	macro			; Fixation du lecteur courant.
				; dsetdrv dev
				; A = 0, B = 1, etc.

	move	\1,-(sp)
	move	#$E,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
cprnos	macro			; Test de la Centronics.
				; cprnos
				; D0 = -1 si disponible.

	move	#$11,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
cauxis	macro			; Test de disponibilit‚ de la RS232 en r‚ception.
				; cauxis
				; D0 = 0 si disponible.
	move	#$12,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
cauxos	macro			; Test de disponibilit‚ de la RS232 en ‚mission.
				; cauxos : retour si disponible.
				D0 = 0 si disponible.
	move	#$13,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

dgetdrv	macro			; Obtention du lecteur actif.
				; dgetdrv
				; => D0 : code lecteur (0=A, B=1, etc).
	move	#$19,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
fsetdta	macro			; Fixation du tampon DTA.
				; fsetdta dta
				; Le tampon DTA doit se constituer ainsi :
				; dta:   ds.b	21	(R‚serv‚)
				; attr:  ds.b	1
				;        even
				; heure: ds.w	1
				; date:  ds.w	1
				; long:  ds.l	1
				; nom:   ds.b   14	
	move.l	\1,-(sp)
	move	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
super	macro			; Passage en superviseur.
				; super
				; D0 = USP
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
user	macro			; Passage en utilisateur.
				; user usp
	move.l	\1,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
tgetdate	macro		; Obtention de la date systeme.
				; tgetdate
				; D0 = date au format :
				;      bits 0 … 4  => jour.
				;      bits 5 … 8  => mois.
				;      bits 9 … 15 => ann‚e (0=1980).

	move	#$2A,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
tsetdate	macro		; Fixation de la date systŠme.
				; tsetdate date
				; D0 = -1 si date invalide.
				; Cf tgetdate pour le format.

	move	\1,-(sp)
	move	#$2B
	trap	#1
	addq.l	#4,sp
	endm
	
tgettime	macro		; Obtention de l'heure systŠme.
				; tgettime
				; D0 = heure au format :
				;      bits 0 … 4   => secondes.
				;      bits 5 … 10  => minutes.
				;      bits 11 … 15 => heures.

	move	#$2C,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
tsettime	macro		; Fixation de l'heure systŠme.
				; tsettime date
				; D0 = -1 si heure invalide.
				; Cf tgettime pour le format.

	move	#$2D,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

fgetdta	macro			; Obtention du pointeur DTA.
				; fgetdta
				; D0 = ptr DTA.

	move	#$2F,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
sversion	macro		; Obtention de la version du GEMDOS.
				; sversion
				; D0 = version.

	move	#$30,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
ptermres macro			; Fin de programme r‚sident.
				; ptermres taille
	clr	-(sp)
	move.l	\1,-(sp)
	move	#$31,-(sp)
	trap	#1
	endm
	
dfree	macro			; Obtention de la place disque.
				; dfree buffer,dev
				; 0 = disque actif, 1 = A, 2 = B, etc.
				; R‚sultat dans un buffer 4 LW :
				;	0 => nb de clusters libres.
				;	1 => nb de clusters (total).
				;	2 => Taille d'un cluster.
				;	3 => nb de sect/cluster.

	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$36,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

dcreate	macro			; Cr‚ation d'un dossier.
				; dcreate pathname.
				; D0 = -1 => Erreur.

	move.l	\1,-(sp)
	move	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
ddelete	macro			; Effacement d'un dossier.
				; ddelete pathname
				; D0 = -1 => Erreur.
				; D0 = $FFFFFFCA => Le dossier contient
				;		    encore des fichiers.

	move.l	\1,-(sp)
	move	#$3A,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
dsetpath	macro		; Fixation d'un chemin.
				; dsetpath path
				; D0 = -1 => Erreur.

	move.l	\1,-(sp)
	move	#$3B,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
fcreate	macro			; Cr‚ation d'un fichier
				; fcreate nom,type
				; Type : Bit 0 => libre(0)/prot(1)
				;	     1 => cach‚.
				;            2 => systŠme.
				;            3 => disk name.
				;            4 => dossier.
				;            5 => archive.
				; => D0 : erreur si < 0 ou Handle.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$3C,-(sp)
	trap	#1
	lea	8(sp),sp
	endm
			
fopen	macro			; Ouverture d'un fichier.
				; fopen nom,type
				; Type : 0 => Lecture.
				;        1 => Ecriture.
				;        2 => Les deux.
				; => D0 : erreur si < 0 ou Handle.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$3D,-(sp)
	trap	#1
	lea	8(sp),sp
	endm
	
fclose	macro			; Fermeture d'un fichier.
				; fclose hdle
				; => D0 : erreur si < 0.
	move	\1,-(sp)
	move	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
	
fread	macro			; Lecture d'un fichier.
				; fread hdle,count,buffer
				; => D0 : erreur si < 0.
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
fwrite	macro			; Ecriture sur un fichier.
				; fwrite hdle,count,buffer
				; => D0 : erreur si < 0.
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
fdelete	macro			; Effacement d'un fichier.
				; fdelete name
				; => D0 : erreur si < 0.
	move.l	\1,-(sp)
	move	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
fseek	macro			; Saut dans un fichier.
				; fseek offset,hdle,mode
				; Mode : 0 = D‚but
				;	 1 = Position actuelle.
				;	 2 = Fin.
				; => D0 : erreur si < 0.
				; 	  Pointeur si > 0.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	
fattrib	macro			; Fixation d'attributs d'un fichier.
				; fattrib name,flag,attrib
				; flag : 0 = lecture.
				;        1 = ‚criture.
				; attrib : cf fcreate.
				; D0 : erreur si < 0.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$43,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	
dgetpath	macro		; Obtention du chemin actif.
				; dgetpath device,path
				; => D0 : erreur si < 0.
	move	\1,-(sp)
	move.l	\2,-(sp)
	move	#$47,-(sp)
	trap	#1
	lea	8(sp),sp
	endm
	
malloc	macro			; R‚servation de m‚moire GEMDOS.
				; ou demande de la place disponible (-1).
				; malloc size
				; => D0 : Taille disponible (-1).
				;	  Adresse du buffer.
				;	  Erreur si < 0.
	move.l	\1,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
mfree	macro			; Lib‚ration de la m‚moire.
				; mfree adr
				; => D0 : erreur si < 0.
	move.l	\1,-(sp)
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	endm
	
mshrink	macro			; Lib‚ration de la m‚moire.
				; mshrink addr,size
				; => D0 : Erreur si <> 0.
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#$4A,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
pexec	macro			; Charger et/ou ex‚cuter un programme.
				; Mode 0 : Load & Go => pexec mode,nom,cmd,env
				; Mode 3 : Load => pexec mode,nom,cmd,env
				;          D0 = Adr du prg en RAM.
				; Mode 4 : Go => pexec mode,cmd,adr,env
	move.l	\4,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#$4B,-(sp)
	trap	#1
	lea	16(sp),sp
	endm
	
pterm	macro			; Fin de programme.
				; pterm code.
	move	\1,-(sp)
	move	#$4C,-(sp)
	trap	#1
	endm
	
fsfirst	macro			; Recherche d'un fichier (1er).
				; fsfirst filename,attrib
				; => D0 : <> 0 si fichier non trouv‚.
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$4E,-(sp)
	trap	#1
	lea	8(sp),sp
	endm
	
fsnext	macro			; Recherche des fichiers suivants.
				; correspondant au masque de Fsfirst.
				; => D0 : <> 0 si fichier non trouv‚.
	move	#$4F,-(sp)
	trap	#1
	addq.l	#2,sp
	endm
	
frename	macro			; Renommer un fichier.
				; frename old,new
				; D0 => erreur si < 0.
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	clr	-(sp)
	move	#$56,-(sp)
	trap	#1
	lea	12(sp),sp
	endm
	
fdatime	macro			; Lecture / Ecriture de la date et heure d'un fichier.
				; fdatime buffer,hdle,flag
				; Le fichier doit ˆtre ouvert.
				; flag : 0 = lire.
				;        1 = ‚crire.
				; buffer : 1 LW contenant 1W = heure.
				;			  1W = date.
				; cf tgetdate et tgettime pour format.
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$57,-(sp)
	trap	#1
	lea	10(sp),sp
	endm
	
	
;
; Macros BIOS.
;

getmpb	macro			; Obtention du Memory Parameter Block.
				; getmpb ptr
				; ptr : buffer de 3 LW qui pointent sur
				;	la structure m‚moire.
	move.l	\1,-(sp)
	clr	-(sp)
	trap	#13
	addq.l	#6,sp
	endm
	
bconstat	macro		; Test d'un p‚riph‚rique d'entr‚e.
				; bconstat dev
				; D0 = 0 si caractŠre disponible.
				; dev : 0 = Centronics (PRT).
				;	1 = RS232 (AUX).
				;	2 = Clavier & ‚cran (CON).
				;	3 = MIDI (MID).
				;	4 = Clavier (IKBD).
				;	5 = Ecran.
	move	\1,-(sp)
	move	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
bconin	macro			; Attente d'un caractŠre sur
				; un p‚riph‚rique d'entr‚e.
				; bconin dev
				; => D0
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
bconout	macro			; Emission d'un caractŠre sur
				; un p‚riph‚rique de sortie.
				; bconout dev,car
	move	\2,-(sp)
	move	\1,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	endm
	
rwabs	macro			; Lecture / Ecriture de secteurs sur disque.
				; rwabs flag,buffer,count,sect,dev
				; D0 => erreur si < 0.
				; flag : 0 = lecture.
				;	 1 = ‚criture.
				; buffer : tampon de donn‚es.
				; count : nombre de secteurs.
				; sect : no du 1er secteur logique.
				; dev : lecteur.
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#4,-(sp)
	trap	#13
	lea	14(sp),sp
	endm
	
setexec	macro			; D‚tournement d'un vecteur d'exception.
				; setexec num,vec
				; D0 => adresse ancien vecteur.
	move.l	\2,-(sp)
	move	\1,-(sp)
	move	#5,-(sp)
	trap	#13
	lea	8(sp),sp
	endm
	
tickcal	macro			; Obtention du nb de ms entre 2 appels
				; de l'horloge systŠme.
				; tickcal
				; D0 = nb de ms (50 Hz = 20 ms).
	move	#6,-(sp)
	trap	#13
	addq.l	#2,sp
	endm

getbpb	macro			; Obtention du Bios Parameter Block.
				; getbpb dev
				; D0 = ptr BPB.
				; Constitution du BPB :
				;	1W : nb oct/sect.
				;	1W : nb sect/clust.
				;	1W : nb oct/clust.
				;	1W : nb sect/dir.
				;	1W : nb sect/FAT.
				;	1W : no sect 2me FAT.
				;	1W : no sect 1er data clust.
				;	1W : nb data clust/disk.
				;	1W : 0
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
bcostat	macro			; Test d'un p‚riph‚rique de sortie.
				; bcostat dev
				; Utilisation identique … bconstat.
	move	\1,-(sp)
	move	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
mediach	macro			; Test si une disquette a ‚t‚ chang‚e.
				; mediach dev
				; D0 = 0 => disquette maintenue.
				;      1 => peut-ˆtre chang‚e.
				;      2 => chang‚e.
	move	\1,-(sp)
	move	#9,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
	
drvmap	macro			; Test des disques pr‚sents.
				; drvmap
				; D0 = vecteur de bits repr‚sentant
				;      les unit‚s disponibles.
	move	#$A,-(sp)
	trap	#13
	addq.l	#2,sp
	endm
	
getshift	macro		; Test ou modification des touches
				; mortes du clavier.
				; getshift mode
				; Mode = -1 => Lecture.
				;	  0 => Modification.
				; D0 = vecteur de bits.
				;	bit 0 : Shift droit.
				;	bit 1 : Shift gauche.
				;	bit 2 : CTRL.
				;	bit 3 : ALT.
				;	bit 4 :	CAPS LOCK.
				;	bit 5 : CLR/HOME.
				;	bit 6 : INSERT.
				;	bit 7 : Inutilis‚.
	move	\1,-(sp)
	move	#$B,-(sp)
	trap	#13
	addq.l	#4,sp
	endm
				
	

;
; Macros XBIOS.
;

initmous	macro		; Modification du vecteur de la souris.
				; initmous type,par,vec
				; typ = 0 : d‚connecte la souris.
				;	1 : connecte la souris (relatif).
				;	2 : connecte la souris (absolu).
				;	3 : inutilis‚.
				;	4 : connecte la souris (clavier).
				; par = ptr d'un bloc de paramŠtres.
				;	1B : topmode => 0 : Y=0 en bas.
				;			1 : Y=0 en haut.
				;	1B : buttons => par. pour le "set
				;			mouse buttons" de l'IKBD.
				;	1B : xparam  => facteurs scalaires pour le
				;	1B : yparam	d‚placement de la souris.
				;
				;	Si typ = 2,
				;	1W : xmax    => coordonn‚es maximales.
				;	1W : ymax
				;	1W : wstart  => origine de la souris.
				;	1W : ystart
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move	\1,-(sp)
	clr	-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
physbase macro			; Adresse physique de l'‚cran.
				; => D0.
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
logbase	macro			; Adresse logique de l'‚cran.
				; => D0.
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
getrez	macro			; Obtention de la r‚solution.
				; => D0.
	move	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
setscreen macro			; Fixe les adresses de l'‚cran.
				; setscreen log,phys,resol.
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	endm
	
setpalette macro		; Fixe la palette.
				; setpalette palette.
	move.l	\1,-(sp)
	move	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
setcolor macro			; Fixe une couleur.
				; setcolor coul,RVB.
	move	\2,-(sp)
	move	\1,-(sp)
	move	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

floprd	macro			; Lecture de secteurs.
				; Floprd buffer,dev,sect,trk,face,count
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	endm
	
flopwr	macro			; Ecriture de secteurs.
				; Flopwr buffer,dev,sect,trk,face,count
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	endm
	
flopfmt	macro			; Formatage d'une piste de disquette.
				; flopfmt buffer,dev,spt,track,face,inter,virgin
				; D0 : erreur si < 0.
				; Buffer au mini 8Ko pour 9 sect/trk.
				; Si D0 = -16 => mauvais secteur.
				;		 Le buffer contient une liste des
				;		 secteurs erron‚s.
	move	\7,-(sp)
	move.l	#$87654321,-(sp)
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#$A,-(sp)
	trap	#14
	lea	26(sp),sp
	endm
	
iorec	macro			; Obtention d'un pointeur sur un enregistrement
				; de donn‚es du tampn pour un p‚rih‚rique d'entr‚e.
				; iorec dev
				; => D0 = ptr.
	move	\1,-(sp)
	move	#14,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
rsconf	macro			; Configuration de la RS232.
				; rsconf baud,ctrl,ucr,rsr,tsr,scr
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$F,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
keytbl	macro			; Configuration d'un nouveau clavier.
				; keytbl unshift,shift,caps
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	#$10,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
random	macro			; Tirage d'un nombre al‚atoire.
				; D0 = nb al‚atoire sur 24 bits.
	move	#$17,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
protobt	macro			; G‚n‚ration d'un boot secteur
				; protobt buffer,serial,type,flag
	move	\4,-(sp)
	move	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move	#18,-(sp)
	trap	#14
	lea	14(sp),sp
	endm
	
flopver	macro			; V‚rification d'un secteur de disquette.
				; flopver buffer,dev,sect,track,face,count
				; Buffer doit ˆtre align‚ sur un nb entier de Ko.
				; D0 : erreur si < 0.
	move	\6,-(sp)
	move	\5,-(sp)
	move	\4,-(sp)
	move	\3,-(sp)
	move	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move	#$13,-(sp)
	trap	#14
	lea	20(sp),sp
	endm
	
scrdmp	macro			; Hardcopy d'‚cran.
				; scrdmp
	move	#$14,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
cursconf	macro		; Configuration du curseur.
				; cursconf fct,taux
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$15,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
bioskeys	macro		; Replace le clavier dans sa configuration initiale.
				; bioskeys
	move	#$18,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
ikbdws	macro			; Transmission de commandes au processeur clavier.
				; ikbdws nb,ptr
	move.l	\1,-(sp)
	move	\2,-(sp)
	move	#$16,-(sp)
	trap	#14
	lea	8(sp),sp
	endm
	
dosound	macro			; G‚n‚ration de sons sous interruption.
				; dosound ptr
	move.l	\1,-(sp)
	move	#$20,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
kbrate	macro			; Fixe la r‚p‚tition des touches du clavier.
				; kbrate delay,repeat
	move	\2,-(sp)
	move	\1,-(sp)
	move	#$23,-(sp)
	trap	#14
	addq.l	#6,sp
	endm
	
vsync	macro			; Attente d'une VBL.
				; vsync
	move	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	endm
	
supexec	macro			; Ex‚cution d'une routine en superviseur.
				; supexec adr
	move.l	\1,-(sp)
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

	
;
; Macros LINE A.
;

init_linea	macro		; Initialisation de la Line A.
				; => D0 : Adresse des paramŠtres.
	dc.w	$a000
	endm
	
mouseoff	macro		; Extinction de la souris.
	dc.w	$a00a
	endm
	
mouseon	macro			; Activation de la souris.
	dc.w	$a009
	endm
	
