;
; Un programme qui communique avec Rembrandt !!!
;


 opt o+,w-

	include	gemmacro.i

start	move.l	#mystack,a7		must have a stack!

	appl_init
	move.w	d0,ap_id		store the application id

	menu_register ap_id,#nom_menu	start by installing me in the Desk menu

* the main loop of the application
* the only interesting events are messages
waitforevent
	evnt_mesag #messagebuf
	move.l	#messagebuf,a0
	move.w	(a0),d0			message type
	cmp.w	#40,d0
	beq	open_acc
	cmp.w	#$1234,d0
	beq	pipe_message_recu
* check others here
	bra.s	waitforevent


* here when I have to Open
open_acc
	appl_find #nom_rembrandt
	cmp #-1,d0
	beq affiche_inactif
	move d0,id_rembrandt
	
affiche_actif
	*
	* Invoque le fileselect
	*
	; blalalalalalalbalal
	*
	* Pr‚pare la ligne de message
	*
	lea buffer,a0

	move #$1234,(a0)+	$1234 -> Demande d'informations
	move ap_id,(a0)+	Identificateur de l'accessoire
	clr (a0)+		Longueur du message
	move.l #'NeXT',(a0)+	Message d'identification
	move.l #'Pipe',(a0)+
	appl_write id_rembrandt,#16,#buffer
	bra waitforevent

affiche_inactif
	form_alert #1,#alerte_rembrandt_inactif
	bra waitforevent




***[PIPE]***
*
* a0->Pointe sur le message buffer.
*
* Si l'on re‡oit un message diff‚rent de celui-la, on signale une erreur.
*
* 1	+0	$1234	-> Demande d'infos
* 2	+2		-> Ap Id
* 3	+4	0	-> 16 octets
* 4/5	+6	'NeXT'
* 6/7	+10	'Pipe'
*
pipe_message_recu
 lea buffer_message,a0
 move 2(a0),id_acc		M‚morise l'APP_ID de l'accessoire
 addq #6,a0			Longueur du message (on s'en tape !)

 cmp.l #'NeXT',(a0)+
 bne .message_foireux
 cmp.l #'Pipe',(a0)+
 bne .message_foireux
 move.l (a0)+,liste_routines

 move #640,largeur_image	On attribue par d‚faut une image 320x200
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 
 rts

.message_foireux
 form_alert #1,#alert_message_foireux
 rts

liste_routines	ds.l 1		Pointe sur les routines de Rembrandt 
message_pipe	ds.b 16
id_acc		ds.w 1

 rsreset
combien_m‚moire		rs.l 1
r‚serve_bloc		rs.l 1
libŠre_bloc		rs.l 1
pr‚pare_buffer_image	rs.l 1

 
alert_message_foireux
 dc.b "[1][R‚ception d'un message|de type inconnu.][ECHEC]",0

alert_message_ok
 dc.b "[1][R‚ception d'un message|compris.][Yeah !!!]",0
 
 even




	SECTION	DATA

* all C strings must end in a null
nom_menu	dc.b	'  Rembrandt-pipe !!!',0

nom_rembrandt	dc.b "REMBRAND",0
	
alerte_envoie			dc.b "[1][J'envoie la sauce !!!][ OK ]",0
alerte_termine			dc.b "[1][C'est fait...][ OK ]",0

alerte_recoie			dc.b "[1][J'ai la r‚ponse ???][ OK ]",0

alerte_rembrandt_inactif	dc.b '[1][Rembrandt est inactif][ OK ]',0

 even
image		incbin 'test.tg1'

* global constants
	SECTION	BSS

ap_id		ds.w 1
id_rembrandt	ds.w 1
messagebuf	ds.b 16
buffer		ds.b 16

	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)


* if not linking then include the run-times

	IFEQ	__LK
	include	aeslib.s
	ENDC

 END
 
Structure d'un message:

1)	+0	Type de message
2)	+2	APP_ID de l'application qui envoie le message	(Si '1', c'est le Screen Manager)
3)	+4	Taille du message en octets -16. (Si '0', c'est que le message fait 16 octets au maximum)
~~~
4)	+6	Selon l'application
 5)	+8
6)	+10
7)	+12
8)	+14
