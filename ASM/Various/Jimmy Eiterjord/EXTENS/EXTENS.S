;    G”r en egen STOS extension i assembler 
;	          av
;           Jimmy Eiterjord

;  H„r b”rjar programmet:

	BRA       start 		; Bra till de 2 huvud adresserna
  	DC.B      $80 			; Jag vet faktiskt inte vad detta 
					; „r till f”r,men det m†ste vara d„r.

;  Kommando lista
;  I den h„r listan ska alla nya kommandon som man vill ha st†.Skriv
;  dom med sm† bokst„ver,annars kan man blanda ihop dom med variablerna!
;  (Variabler st†r alltid med STORA bokst„ver i listningen, medans alla
;  kommandon har sm† bokst„ver.
;  Efter varje kommando skriver man ett nummer som STOS sedan kommer att
;  identifiera kommandot med.Nummrena ska b”rja p† $80 och g† upp†t.
;  Om ett kommandot ska vara ett vanligt kommando s† ska det vara ett 
;  JMNT tal.Vanliga kommandon „r tex print,box,copy,home,load,locate osv.
;  De kommandon som inte „r vanliga „r s†dana som h„mtar ett v„rde eller 
;  str„ng.Man skriver tex x=peek,k$=inkey$,x=sin,x=joy,f=dfree osv
;  B†de de vanliga och de andra kan man skriva parametrar till.
;  skillnaden „r att de vanliga ska inte ha parenteser runt sina parametrar 
;  medans de andra ska det.Man skriver tex "locate 10,3" (Vanligt) och 
;  "x=peek(100)" (Det ovanliga,dvs det som inte „r vanligt)

kom:  	DC.B      'vem?',$80		; skriv "vem?" i STOS och testa
  	DC.B      'frek',$81		; UDDA nummer,skriv "a=frek" i STOS
  	DC.B      'sfrek',$82		; J„mt nummer,testa "sfrek 60" 
	DC.B      'add',$83		; UDDA nummer,skriv "a=add (11,45)"
	DC.B      'vissla',$84		; J„mt nummer
	DC.B      'bomb',$86		; OBS!!  JMT NUMMER IGEN!!
  	DC.W	  0		; Avsluta listan med 0. DC.W „r viktigt!

; OBS, Jag har hoppat ”ver nummer $85 f”r jag har inte s† m†nga rutiner som
; skall h„mta v„rden.Du kan hoppa ”ver hur m†nga du vill,men det „r viktigt
; att det „r ett tomrum d„r i kommando adress listan sen!



;  Adresser till kommando rutiner
;  N„r sedan STOS hittar ett av dina kommandon i programmet s† kommer det
;  att hoppa till den adressen du anger h„r.Kommando nr $80 „r den 
;  f”rsta adressen.Om man har hoppat ”ver n†got nummer s† „r det viktigt att
;  det finns ett tommrum d„r i adress listan,annars pajar alltihopa!
;  Nja,pajar „r v„l fel ord,men det funkar inte iallafall.
;  (Felet som uppkommer i s† fall „r Extension not present)

komaddr:DC.B      0,7		;Antal addresser,„ven DC.L 0 r„knas 
  	DC.L      vem		;adress till vem kommandot	    $80		
  	DC.L      frek		;adress till frek kommandot	    $81	
  	DC.L      sfrek		;adress till sfrek kommandot	    $82	
  	DC.L      add		;adress till add kommandot	    $83
  	DC.L      vissla	;adress till vissla kommandot	    $84	
  	DC.L      0		;0 eftersom att kommando nr $85 inte finns
  	DC.L      bomb		;adress till bomb kommandot	    $86	
  	
;  Intro text
;  Du vet,n„r man startar STOS s† kommer det upp en lista p† de 
;  extensioner som „r installerade.Din extension ska naturligtvis ox†
;  st† med d„r!
;  $0A betyder att texten centreras.Om man har st„llt in Franska s†
;  kommer den andra texten upp i st„llet.Jag kan inte franska s† jag
;  skrev p† engelska d„r med.
;  Sj„lvklart ska du hitta p† n†got eget att skriva d„r! 

intro:	DC.B      $0A,'Eniacs extension' 	; Engelska
  	DC.B      ' installed',0	
  	DC.B      $0A,'Eniacs extension' 	; Franska
  	DC.B      'installed',0	

;  N†gra variabler som jag beh”vde

staddr:	DS.W      2	; H„r ska A0 lagras vid addrl,varf”r vet jag inte 
lgaddr:	DS.W      2	; H„r lagras A0 vid varje kommando,†terhopps 
			; address. 

;  Huvud adress fix lista
;  Adress till slutet i A0 och till en Ge STOS dina adresser rutin i A1.
;  ska vara RTS avslutad!

start:	LEA       THEEND,A0	; Adrees till slutet p† din extension.
  	LEA       addrl,A1	; Adress till ge STOS dina adresser rutin
  	RTS 

;  Ge STOS dina adresser rutin.
;  Efter att STOS har varit h„r och utf”rt det som st†r h„r s† kollar det
;  i A0-A3 efter n†gra adresser.S† det kan vara r„tt k„ckt att l„gga in dom!
;  ska vara RTS avslutad!

addrl:	MOVE.L    A0,staddr

;  H„r kan du l„gga en eventuell rutin som ska k”ras n„r hela extensionen
;  har laddats in.Det kan tex vara att ladda in en hj„lp fil
;  Och att st„lla in vissa variabler som du kanske beh”ver senare.

 	LEA       intro,A0	; Intro text
  	LEA       auto,A1	; Auto rutin
  	LEA       kom,A2	; Kommandon
  	LEA       komaddr,A3	; Kommando adresser
  	RTS 

; Auto rutin som utf”rs efter varge inskriven rad
; Den rutinen som f”ljer h„r kommer att utf”ras varje g†ng du skrivit in
; en ny rad,skrivit RUN eller NEW och lite andra g†nger ox† som jag inte
; vet riktigt s„kert.
; Vill du inte att n†got s†dant ska utf”ras s† l„gger du bara in en RTS 
; ist„llet.
; Du kan anv„nda rutinen till att tex r„kna antalet g†nger rutinen 
; anropas och efter ett visst antal s† kommer den ber”mda texten 
; "Du m†ste registrera dig till...." upp!
; ska vara RTS avslutad!

auto:	lea       autot(PC),a0		; Av„nder STOS egna text rutin.
	move.w    #1,d7			; Nr 1 ,Trap #3
	trap      #3
	rts
autot:	dc.b 10,13,'AUTO rutin utf”rd!',10,13,0

;  H„mta inskrivna parametrar
;  N„r du skriver ett kommando med parametrar efter s† h„mtar denna
;  rutin den sista parametern.N„sta g†ng den anropas s† blir det den 
;  n„st sista osv.Om man skriver ett tal som en parameter s† blir
;  D3=det talet.Skrev man en text str„ng s† blir D3.L=en adress vars 
;  f”rsta ord „r antalet tecken i str„ngen.D„refter f”ljer sj„lva texten.
;  OBS!!! Texten „r inte nollavsluad !

hmtpar:	MOVEA.L   (A7)+,A0
	MOVEM.L   (A7)+,D2-D4 
	TST.B     D2
	BNE       fel 
	JMP       (A0)

;  Olika error koder
;  Det kan vara r„tt praktiskt att anv„nda STOS egna error koder
;  eftersom att dom bryter programmet och skriver vilken rad det blev
;  fel p†.Vill man det s† MOVEQ ar man bara in error nummret som st†r 
;  i stos manualen in i D0 och BRA ar till error s† blir det error och 
;  programmet som eventuellt k”rs stoppas.

;  F”r att f”renkla det hela s† har jag gjort n†gra f„rdiga rutiner.

;  Syntax error

synerr:	MOVEQ     #12,D0
     	BRA.S     error 

;  Type mismatch

tmerr:	MOVEQ     #19,D0 
      	BRA.S     error 

;  Illegal function call

ilfuerr:MOVEQ     #13,D0
	bra.s	  error

	dc.w	  0	; Beh”vs egentligen inte,men om du vill ha 
			; n†gon mer error rutin s† kan det vara praktiskt.
			; (Jag m†ste ha den d„r nu f”r man kan inte BRAa
			; ingenting)

;  H„r kommer sj„lva rutinen som g”r erroret

error:	MOVEA.L   staddr(PC),A0
      	MOVEA.L   20(A0),A0 
      	JMP       (A0)

;  Vem har gjort detta? 
;  H„r kommer det f”rst kommandot, som „r ett exempel p† en text utskrift.
;  STOS egna trap #3 anv„nds.
;  Du kan sj„lv anv„nda de stos trappar som st†r i stos manualen i din
;  extension!

vem:	MOVE.L    (A7)+,lgaddr	; Lagra †terhopps adressen.
      	lea       vemt(PC),a0	; adressen till texten som skall skrivas
	move.w    #1,d7		; STOS rutin nr 1
	trap      #3		; trap #3
      	MOVEA.L   lgaddr,A0	; h„mta tillbaka †terhopps adressen.
      	JMP       (A0) 		; Hoppa tillbaka

;  Sj„lva texten som ska skrivas:

vemt:	dc.b  10,13
	dc.b 	'Det h„r „r ett exempel p† en extension!.',10,13,10
	dc.b	'Gjord av Jimmy Eiterjord',10,13
	dc.b  	'™jersbo 6843',10,13
	dc.b	'43496   Kungsbacka',10,13
	dc.w	0

;  Kolla frekvensen p† monitorn
;  Det h„r kommandot „r ett s†dant som h„mtar ett v„rde.(det var en UDDA
;  slut byte i kommando listan.
;  Man kan tex skriva "PRINT kommando" eller "x=kommando"
;  Det v„rdet som ska skrivas med print eller l„ggas i x l„gger
;  man bara i D3 s† fixar STOS resten.
;  Om du vill ha tex ett A$=kommando s† ska du l†ta D3 vara en
;  adress till ett ord (W) som talar om hur m†nga tecken det ska 
;  vara i str„ngen.D„refter ska sj„lva texten vara som STOS
;  sedan kommer att l„gga i A$. 

frek:	MOVE.L    (A7)+,lgaddr		; Lagra †terhopps adressen.
      	btst      #1,$ff820a		; Kolla bit nr 1 (2) i $ff820a
	beq	  frek1			
	move.w    #50,d3		; l„gg 50 i D3	
	bra       frek2
frek1:	move.w    #60,d3		; l„gg 60 i D3	
frek2:	MOVEA.L   lgaddr,A0		; h„mta tillbaka †terhopps adressen.
      	JMP       (A0) 			; Hoppa tillbaka

;  „ndra frekvensen p† monitorn
;  Det h„r kommandot ska „ndra frekvensen och beh”ver d„rf”r den nya 
;  frekvensen i en parameter.
;  N„r ett av dina kommandon f†r kontrollen s† l„gger STOS det antalet
;  parametrar som anv„ndaren skrev in i D0.tex Locate beh”ver 2 parametrar
;  (x och y v„rde f”r mark”ren)
 
sfrek:	MOVE.L    (A7)+,lgaddr	; Lagra †terhopps adressen.
      	CMP.W     #1,D0		; Testa om jag fick EN parameter av 
				; anv„ndaren 
      	BNE       fel 		; om inte,g† till fel 
      	BSR       hmtpar 	; H„mta den parametern,frekvensen 
				; ligger sedan i d3
	CMP.W	  #50,d3	; Kolla om man ville ha 50 Hz
	BEQ	  f50		; Ja, g† till f50
	CMP.W	  #60,d3	; Kolla om man ville ha 60 Hz
	BEQ	  f60		; Ja, g† till f60
	BRA	  ffel		; Man ville varken ha 50 el 60,g† till ffel
f50:	bset      #1,$ff820a	; „ndra till 50 Hz
	bra	  fe
f60:	bclr      #1,$ff820a	; „ndra till 50 Hz
fe:	MOVEA.L   lgaddr,A0	; Samma avslutnings rutin som vid frek
      	JMP       (A0) 		; Ett tips „r att alltid g”ra s†!
	
; En demostartion av ett b†de in och ut kommando med 2 parametrar!
; I STOS ska man sedan skriva x=add (a,b)
; Kommandot kommer att l†ta x vara lika med a+b
; i kommando listan „r detta kommandot udda,det ska alts† h„mta ett v„rde.
; N„r man har parametrar till ett s†nt kommando s† skriver man dom inom 
; parantes i STOS.

add:	MOVE.L    (A7)+,lgaddr
      	CMP.W     #2,D0 	; Testa om jag fick TV parameter av 
				; anv„ndaren 
      	BNE       fel 		; Nej, g† till fel
      	BSR       hmtpar 	; H„mta den sista parametern och l„gg den i D3
	move.l	  d3,d5		; L„gg D3 i D5 
      	BSR       hmtpar 	; H„mta den f”rsta parametern
	add.l	  d5,d3		; Addera den f”rst parametern med den sista (D5)
				; Eftersom att svaret hamnar i D3 s† beh”ver vi 
				; inte g”ra mer.
	MOVEA.L   lgaddr,A0	
      	JMP       (A0) 

;  Vissel ljud
;  Detta kommandot hade en j„mn slut byte och „r allts† ett vanligt kommando.
;  Inga parametrar anv„nds s† jag struntar i att kolla hur m†nga anv„ndaren
;  har skrivit!

vissla:	MOVE.L    (A7)+,lgaddr	
	move.l	  #vissl,-(sp)
	move.w	  #32,-(sp)
	trap	  #14		; Spela ljud med XBIOS 32
	MOVEA.L   lgaddr,A0
      	JMP       (A0) 

vissl:	dc.b 7,62,8,15,9,11,1,0,0,0
	dc.b 128,64,129,0,-2,32,0,0,255,7
	dc.b 128,64,129,0,-1,48
	dc.b 128,48,129,0,3,105,7,63,255,0

; Bomb ljud
; Fungerar som vissla kommandot fast l†ter ungef„r som BOOM 
; kommandot i STOS

bomb:	MOVE.L    (A7)+,lgaddr
	move.l	  #bombl,-(sp)	
	move.w	  #32,-(sp)
	trap	  #14		; Spela ljud med XBIOS 32
	MOVEA.L   lgaddr,A0
      	JMP       (A0) 

bombl:	dc.b 6,31,7,7,8,16,9,16,10,16
	dc.b 11,0,12,128,13,0,255,0

; exexmpel p† hemmagjorda felmeddelanden
; F”r att f† sin egna lilla Touch p† sina kommandon s† kan man ju
; alltid ha egna error rutiner som fungerar som den vanliga STOS assembler
; print instruktionen.D„refter anropar man tex synerr som stoppar
; programmet och skriver Syntax error in line...
; Det blir roligare om man har lite humor i sina fel meddelanden ox†!

; H„r kommer n†gra error som jag hittade p† i all hast.

; Fel antal parametrar

fel:	lea       felt(PC),a0	; Anv„nd STOS text rutin 
	move.w    #1,d7
	trap      #3
	bra	  synerr

; Om”jlig frekvens

ffel:	lea       ffelt(PC),a0	; Anv„nd STOS text rutin 
	move.w    #1,d7
	trap      #3
	bra	  synerr

; Och h„r kommer sj„lva fel texten till errorrutinerna

felt:	dc.b  10,13
	dc.b 'OOOOOPPPPPSSSSSIIII!',10,13
	dc.b 'Fel antal parametrar!',10,13
	dc.b 'Detta „r en Atari och den r†kar inte',10,13 
	dc.b 'ha konstgjord intelligens f”r tillf„llet!',10,13,0,0

ffelt:	dc.b  10,13
	dc.b 'r du galen?',10,13
	dc.b 'Din monitor kan faktiskt inte k”ra',10,13 
	dc.b ' i vilken frekvens som helst!',10,13,0

; H„r „r min extension slut s† h„r kan STOS ladda in n„sta extension!
; D„rf”r beh”vs adressen hit!

THEEND:	ds.w      2


;               Lycka Till !!!!!!!!