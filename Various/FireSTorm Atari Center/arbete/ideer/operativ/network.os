N„tverk „r n†gonting som man borde bygga in i Operativsystemet fr†n b”rjan.

sj„lvklart „r denna del en Modul till sj„lva k„rnan, MEN den „r en del i 
K„rnan likas†.

N„tverket som levereras med FireStorm OS „r ett TCP/IP baserat n„tverk.

Funktioner som kan beh”vas. Alla funktioner kan anv„ndas p† 2 s„tt, endera 
s† l†ses funktionen tills den har utf”rt det den skall, ELLER s† returnerar 
den direkt och man blir tvunen att Polla funktionen f”r att se n„r den „r 
f„rdig.
* connect(...) Skapar en f”rbindelse med en mottagare.
* accept(...)  ™ppnar en f”rbindelse med en s„ndare (s„ndare av connect).
* read(...)    L„ser data fr†n en f”rbindelse.
* readpkt(...) L„ser ett paket fr†n en f”rbindelse.
* write(...)   skriver data till en f”rbindelse.
* cgets(...)   L„ser en rad fr†n en f”rbindelse (NOLL,\n,\r avslutar).
* cputs(...)   skriver en rad till en f”rbindelse.
* cgetc(...)   L„ser ett tecken fr†n en f”rbindelse.
* cputc(...)   skriver ett tecken till en f”rbindelse.
* send(...)    Skickar data till en mottagera (f”rbindelse l”st)
* recv(...)    Tar emot data fr†n en s„ndare (f”rbindelsel”st)
* getconn(...) L„ser av uppkopplings informationen, tex VEM „r jag upkopplad 
               emot, etc
* putconn(...) Skriver data till Uppkopplings informationen.
