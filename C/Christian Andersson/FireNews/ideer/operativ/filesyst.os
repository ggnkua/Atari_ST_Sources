Filsystemet i Firestorm OS!

* St”d f”r l„ngre filnamn „n vad vanliga DOS klarar av. (64 tecken)

* St”d f”r Sm†/Stora tecken i filnamnen

* St”d f”r K”rbara "Bibliotek" DVS du kan ha ett bibliotek som n„r det 
	Exekveras s† startar huvudprogrammet i det biblioteket upp, detta 
	inneb„r att vi f†r en renare struktur eftersom vi inte beh”ver se all 
	data som finns i biblioteket, och att vi d„rf”r inte beh”ver heller bry 
	oss om vad som finns d„r!

* St”d f”r "mjuka" l„nkningar av filer och bibliotek!

* St”d f”r H†rda l„nkar av partitioner och HD:s genom detta f†r man ett fil- 
	system som ser ut som om man har bara 1 h†rddisk.

* 1 fil kan ”ppnas f”r L„sning eller skrivning. En fil som har ”ppnats f”r 
	l„sning kan ”ppnas f”r l„sning och skrivning av andra processer. En fil 
	som ”ppnats f”r skrivning kan bara ”ppnas f”r l„sning av andra program. 
	Dvs, En fil kan ”ppnas f”r l„sning av flera processer, men bara f”r 
	skrivning av 1 process. F”r att detta skall kunna till†tas (1 fil ”ppen 
	f”r b†de l„sning och skrivning) s† m†ste ett meddelande skickas till 
	processerna som har ”ppnat filen f”r l„sning, och tala om f”r dem att 
	filen har blivit „ndrad. detta meddelande skickas till processerna n„r 
	filen „ndras p† disk, dvs n„r „ndringarna sparas.

* F”r att ett k”rbart bibliotek skall kunna implementers s† m†ste vissa 
    filer i det k”rbara biblioteket se ut p† ett visst s„tt, h„r nedan 
    kommer jag att beskriva hur s†dana	h„r filer skall se ut.
	.../"K”rbart Bibliotek"/
		.Info					Information om det k”rbara biblioteket
		.Icon					Icon f”r det k”rbara Biblioteket
		.Help.XXX				Fil som anv„nds i Operativsystemet som 
								hj„lp-fil, dvs standardiserade filer 
								som ger hj„lp om vissa program osv.
								(Se HELP.OS f”r mera information)
								XX „r till f”r att ange spr†ket p† filen 
								(Se Language.OS ”fr mera information)

* Utm„rkt st”d f”r s„kerhet.
  Varje fil har 10 bitar f”r att st„lla in olika anv„ndares r„ttigheter till 
  filen. F”rst s† har vi 3 stycken f”r „garen till filen, sedan 3 till alla 
  i samma grupp som „garen, och tillslut 3 f”r alla andra. den 10:de biten 
  talar om ifal filen „r krypterad eller inte.
  De 3 bitarna f”r Žgaren, gruppen och alla andra inneh†ler samma 
  information och talar om ifall den kan k”ras, l„sas eller skrivas till. P† 
  detta s„tt kan man till†ta att gruppen kan l„sa filen, men inte skriva 
  till den. Utm„rkt f”r att dela information till andra (WWW)
  Detta system g„llert f”r alla typer av filer och „ven bibliotek. 
  Biblioteket kan „ven det vara kodat!

* kryptering av filer och bibliotek.
  F”r att man skall kunna ha st”rre skydd av sina filer/bibliotek s† finns 
  det en m”jlighet att kryptera inneh†llet. detta g”rs genam att man s„tter  
  krypterings-biten p† en fil/bibliotek. och man blir d† tillfr†gad om ett 
  "l”sen-ord", utan detta l”sen-ord s† kommer man inte att kunna l„sa 
  filen/biblioteket. F”r att OS:et skall veta att man anv„nt r„tt l”senord 
  s† ligger l”senordet med i filsystemet krypterat med sig sj„lv som nyckel
  Om det som kryptears „r en fil s† lagras l”senordet sist i filen, om det 
  „r ett bibliotek s† lagras det krypterade l”senordet som en fil i 
  biblioteket. OM inte det uppkrypterade l”senordet och det man skriver in 
  st„mmer ”verens s† kommer man inte att kunna l„sa/skriva fr†n/till denna 
  fil, det g†r dock bra att radera filen. (om man har de r„tta 
  privilegierna)

* St”d f”r Automatisk Defragmentering!
  Om systemet varit outnyttjat under en viss tid, s† kommer en automatisk 
  defragmentering att ske, eftersom denna defragmentering tar "kraft" fr†n 
  datorn s† s„tts en v„ldigt l†g ptrioritet p† denna egenskap, opcvh n„r 
  datorn b”rjar utnyttjas igen s† avslutas denna uppgift, f”r att forts„tta 
  en annan g†ng.
  filer som „r ”ppnade av program elelr p† andra s„tt anv„nds, p†verkas inte 
  av denna defragmentering.

* St”d f”r Automatisk Komprimering, fungerar som den Automatiska
  Defragmenteringen, man kan st„lla in  hur "gammal" och hur ofta en fil m†ste
  vara f”r att komprimeras, samt „ven andra data som g„ller vid komprimering,
  vissa filer/bibliotek skall tex inte omprimeras alls, medans andra skall
  komprimeras f”r fulla muggar.

* Olika typer av fil-skapar funktioner, de vanliga med att man ”ppna en fil skall
  finnas, men „ven s†dana som fungerar mera som minnen, dvs du kan allokera en fil
  p† tex 1000 Kb, d† skapas denna stora fil p† en g†ng, och alla „ndringar i filen
  sker automatikst, man beh”ver inte st„nga filen. Filer som skapats som minne, kan
  man sedan minska eller ”ka stolreken p†, och man kan f† reda p† om det fungerade
  elelr inte p† 1 g†ng. Perfekt f”r Multitasking.