H„r kommer en liten miniskola f”r assembler-programmering.
Den b”r hj„lpa dig litegrann! Jag l„r dig mer vid senare tillf„lle!

F”rst t„nkte jag g† igenom Processorn och dess register.

1/ Processorn!

Processorn „r en Motorola 68000. Den har 8 dataregister (d0-d7)
och 7 adressregister (a0-a6). Den har dessutom en programr„knare
(pc), en stackpelare (sp el. a7) och ett statusregister (SR)

1.1 Dataregistrena anv„nds av datorn f”r att r„kna i. (Alla instruktioner
kr„ver inte att dataregistrena anv„nds!). De anv„nds ocks† som r„knare
i loop-instruktioner.

1.2 Adressregistrena inneh†ller adresser i minnet och anv„nds f”r att
g”ra snabbare typer av intruktionsupps„ttningar.

1.3 Stackpelaren „r ocks† ett adressregister men f†r inte anv„ndas
hur som helst utav dig. Stacken fungerar som en sorts h”g med papper.
Det papper du l„gger l„ngst upp p† h”gen „r ocks† det papper som du
i f”rsta hand kommer att ta bort. Papprena kan j„mf”ras med data du l„gger
p† h”gen. Stacken anv„nds t. ex. vid Subrutinsanrop.

1.4 Programr„knaren (pc) inneh†ller adressen till den instruktion
som ska utf”ras. N„r instruktionen utf”rts, hoppar programr„knaren
fram till adressen till n„sta instruktion.
Vid ett subrutinsanrop (JSR) sparas PC:s inneh†ll p† stacken. Adressen
till den nya rutinen l„ggs i PC. N„r subrutinen kommit till sitt slut
(RTS), l„ggs det v„rde som „r sparat p† stacken i PC och processorn
forts„tter att exkverera instruktioner p† sin ursprungliga adress.

1.5 Statusregistret (SR) t„nker jag inte ber„tta s† mycket om h„r.
I SR anv„nds de fem f”rsta bitarna som flaggor.

Flaggorna „r:

(C)arry    (flaggan inneh†ller den bit som kom utanf”r vid en SHIFT-instr.)
o(V)erflow (biten s„tts om overflow intr„ffar vid en ber„kning.
(Z)ero     (Biten s„tts om resultaten av en ber„kning blev 0.)
(N)egative (flaggan s„tts om resultatet blev negativt (-). )
e(X)tend   (vet jag inte vad den anv„nds till)

Dessa flaggor anv„nds vid IF-konstruktioner. (†terkommer till det)

I SR finns ocks† ”vervakarbiten.
Om den „r 1 s† „r processorn i ”vervakarl„ge. (supervisor-mode)
Žr den 0 s† „r pr. i anv„ndarl„ge (User-mode)

I Usermode kan man inte komma †t de delar av minnet som h†rdvaran
anv„nder som H†rdvaruregister. (ex $ff8240 = grafikkortets register
f”r f„rg nr 0)

Man kan heller inte s„tta ”vervakarbiten till 1 fr†n Usermode.
F”r detta m†ste man anv„nda en s„rskild TRAP-rutin.
(STOS k”rs t.ex i Supervisor-mode. Alltid!)

Mer om SR kan du l„sa dig till!

   
2/ Adresserings-s„tt (12 st. Jag kan inte alla)

Alla instuktioner klarar inte alla s„tt. (det „r delvis det som g”r
att vissa instruktioner blir snabbare.) MOVE klarar alla!

(Dn = dataregister och An = adressregister)

Dn	till/fr†n dataregister
An	till/fr†n adressregister
(An)	till/fr†n den adress som An pekar p†!
(An)+	till/fr†n den adress som An pekar p† och ”ka p† An med B,W el L.
-(An)	till/fr†n den adress som An pekar p† och minska med B,W el L.
X(An)	till/fr†n den adress som An+X pekar p†. (Ex move.w 4(a0),6(a1) )
#data	ett tal! (Ex add.l #5,d0
Adress	till/fr†n det v„rde som ligger i adressen (ex move.w $ff8240,$100 )
 
Resten kan jag inte!

Alla dessa utom #data brukar kunna st† som K„lla eller Destination.
#data kan bara st† som K„lla i en instruktionen.

3/ Olika typer av instruktioner!

Instruktion: move.b	K„lla,Destination
	     add.l	K„lla,Destination
	     divu	K,D

**

move.b.w.l
add.b.w.l
sub.b.w.l
mulu.b.w	Dataregister m†ste st† som Destination
divu.b.w	Dataregister m†ste st† som Destination

or.b.w.l	instruktionen kolla bitarna s† h„r:

	K„lla (K)	%10010101101100110
	Dest  (D)	%10101110101001101
	 		 |||||||||||||||||
		=	%10111111101101111
 
	Žr bit nr 0 i K„llan 1 ELLER(or) bit 0 i Dest 1 s† blir 
	svaret 1 i bit 0. Sedan g†r den igenom alla bitarna i talet
	likadant

and.b.w.l	Žr bit nr 0 i K„llan 1 OCH(and) bit 0 i Dest 1 s† blir
	svaret 1 i bit 0.

xor.b.w.l	Žr en av bitarna 1 s† blir svaret 1. Žr b†da 1 s† 
		blir svaret 0.

** Instruktioner med endast Destination

not.b.w.l	Alla bitar som „r 0 blir 1, alla bitar som „r 1 blir 0
		(ex. 	not.l	(a0)+ )
tst.b.w.l	Testar om ett tal „r Negativt, Positivt eller Noll.
		Svaret hamnar i SR:s flaggor.
clr.b.w.l	S„tter alla bitar i ett tal till noll.

** Instruktioner med delvis k„lla.

(Jag vet inte b.w.l p† f”ljande instr.)

bset	s„tt bit som k„llan anger till ett i destinationen. K„llan kan
	antingen vara Dn eller #data
	Ex	bset d0,(a0)	el.	bset #3,d2
bclr	nolla bit
bchg	„ndra bit (den kan ju bara vara 1 eller 0)

** Dessa „r sv†rare att f”rklara (f”rklarar n†n annan g†ng)

ROL
ROR
LSL
LSR
ASL
ASR

** ™vriga

jsr	Jump to SubRoutine
rts	ReTurn from Subroutine
jmp	Hoppa till rutin (ej subrutinshopp)
bsr	Branch to SubRoutine (n„stan likadan som JSR)

I JSR-instr. kan man skriva s† h„r JSR (An) = hoppa till adress
som An pekar p†.
Det kan man inte med BSR.

** IF-konstruktioner. **

IF-rader g”rs genom att processorn k„nner av flaggorna i SR och g”r ett 
hopp till en rutin (ej subrutinshopp) om flaggorna st„mde ”verens med
vad man ville.

De olika hoppen:

bcc	Branch if Carry is Clear.
bcs	Branch if Carry is Set.

bvc	Branch if oVerflow is Clear.
bvs	Branch if oVerflow is Set.

bne	Branch if Not Equal (om Zero-flaggan inte „r satt)
beq	Branch if Equal.

bmi	Branch if MInus
bpl	Branch if PLus

bge	Branch if Greater or Equal
ble	Branch if Lower or Equal

Det finns tv† eller tre till som jag inte kommer ih†g!

Instruktionen ser ut s† h„r:

	bne	SYMBOL


F”r att kolla tv† tal g”r man s† h„r:

	cmp.l	d0,d1	j„mf”r d0 med d1 (flaggorna kommer s„ttas) 
	beq	LIKA	om d0 „r lika stort som d1, s† hoppa!
 
Kommandot CMP „r samma sak som SUB, f”rutom att den bara
l†tsas Subtrahera. Subtraktionen sker aldrig p† riktigt.

F”r att kolla ett tal g”r man s† h„r:

	tst.w	(a0)
	beq	NOLL	om (a0) „r noll s† hoppa.
	bmi	MINUS	om (a0) „r negativt s† hoppa.
	bpl	PLUS	om (a0) „r positivt s† hoppa.
 	

4/ Traps!

Traps „r egentligen bara f„rdigskrivna Assembler-rutiner som finns
i datorn.
Dessa Rutiner finns fr†n b”rjan: BIOS, XBIOS, GEMDOS, XGEMDOS
BIOS    = trap	#13
XBIOS   = trap	#14
GEMDOS  = trap	#1
XGEMDOS = trap	#2

Parametrarna till Rutinerna l„ggs p† stacken.
Sist l„gger man rutin nummer p† stacken och anropar med TRAP.
Efter rutinens slut ska man l„gga p† stacken, det antal Bytes man tog
bort. (Stacken v„xer n„mligen ner†t i minnet.)

ex

XBIOS 37 VSYNC (samma som Wait Vbl)

	move.w	#37,-(a7)	l„gg rutinnummer p† stacken
	trap	#14		anropa XBIOS
	addq.l	#2,a7		l„gg p† ett Word (lika mycket som vi
				flyttade till stacken.)

GEMDOS 9 CCONWS (skriv str„ng p† sk„rmen)

	move.l	#text,-(a7)	l„gg adressen till str„ngen p† SP
	move.w	#9,-(a7)	l„gg in rutin-numret
	trap	#1		anropa GEMDOS
	addq.l	#6,a7		l„gg p† ett Lword + word p† stacken.

text	dc.b	'Detta „r Jonas Assemblerskola.',0

	Str„ngen m†ste vara 0-avslutad!

GEMDOS 32 SUPER (byt mellan Supervisor- och Usermode)

	move.l	#0,-(a7)	Adressen till ny SP. Ska vara 0 om
				man ska byta till SUPER.
	move.w	#32,-(a7)	L„gg rutinnumret p† SP
	trap	#1		Anropa Gemdos!
	addq.l	#6,a7		R„tta till stacken
				D0 kommer inneh†lla adressen p†
				gamla stackpelaren.


Nu befinner sig datorn i ™vervakarl„ge.

GEMDOS 0 PTERMO (avsluta program)

	move.w	#0,-(a7)	l„gg rutinnummer p† SP
	trap	#1		anropa GEMDOS
				i denna rutin beh”ver man inte r„tta
				till stacken.

Maskinkodsprogram till STOS ska avslutas med RTS ist„llet.
Kommandot CALL start(15) „r n„mligen samma sak som JSR!.

XBIOS 2 _PHYSBASE (h„mta den fysiska bildminnesadressen)

	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
			Adressen till PHYSIC finns nu i D0.l

*** Fullst„ndig f”rteckning ”ver alla TRAPS finns i 
Atari ST/STE H†rdfakta!. (kostar 150 :- p† Stor och Liten.)****


5/ GenST Editor och Assembler!


Koden best†r av Symboler,Instruktioner och Data.

Symbolerna skrivs alltid i h”gra kanten. N„r programmet
assembleras kommer symbolerna att st† f”r Minnesadresser i
offset fr†n programmets start. Symbolerna kan vara namn
p† t.ex en subrutin eller en variabel.

ex.
	jsr	FLYTTA	


FLYTTA	move.w	$ff8240,$ff8242	(FLYTTA „r allts† en symbol)
	rts


Instruktionerna skrivs vanligen en <TAB> fr†n h”gra sidans kan.
Efter instruktionsnamnet trycker man <TAB> en g†ng till f”r att
komma till instruktionens parametrar.

ex.

<TAB>	add.l	#2,d0
	    <TAB>

Variblar och data definieras s† h„r:

<TAB>	dc.b	10
	dc.l	12312
	dc.w	110

dc st†r f”r Define Constant. N„r programmet assembleras 
kommer en b.w el. l att reserveras och talet kommer att l„ggas
in det reserverade utrymmet.
Man kan ocks† l„gga in flera tal p† samma rad.

ex.

	dc.w	123,$123,%10011,2,34,7
 
Naturligtvis kan du s„tt Symboler framf”r variablarna.
All data ska st† sist i koden!!!


Rem-rader g”rs med en stj„rna (*)

ex.

* Denna rad g”r ingenting.


1.2 Assemblatorn.

Innan ett program kan k”ras, ska det assembleras.
G† upp i PROGRAM-menyn och v„lj ASSEMBLE.
Man kan v„lja om man vill Assemblera till DISK el. MEMORY.
N„r man assemblerat klart och inga fel har uppst†tt, kan man
k”ra programmet genom att trycka p† RUN el. <ALT> + X.

Har du avslutat programmet med GEMDOS 0 s† kommer programmet
att †terv„nda till Editorn om inga krascher har uppst†tt.
Men f”r s„kerhets skull...... SPARA!!!!!

1.3 Debugger

N„r du assemblerat ett program och det blir fel n„r du k”r, kan
du g† in i Debuggern = Avlusaren (ALT + D).
Din kod kommer att komma upp i Disassembly (PC)-f”nstret.
Nu kan du trycka fram instruktion f”r instruktion med CTRL-A.
Vill du hoppa ”ver en instruktion trycker du CTRL-S.
CTRL-C kommer att avsluta och †terg† till Editorn.

Debuggern inneh†ller en m„ngd olika funktioner.
Du f†r testa dig fram till dem med hj„lp av tangent-bordet.
(T„nk p† att anv„nda CTRL och ALT ocks†!)


\

Hoppas du f†r ut n†got av det h„r s† l„nge!

Detta „r J.MOZART vid tangentbordet. TSM (C) 1993.

Lycka till!\

