L”senordsystemet.

 * Ist„llet f”r att de lika programmen skall beh”va spara undan l”senord, 
  osv s† skall systemet st† f”r det. dvs vill man spara undan ett l”senord 
  s† anv„nder man ett speciellt system-anrop som sparar undan l”senordet 
  kodat. Man kan sedan testa ett l”senord mot ett tidigare sparat l”senord.
  En nyckel returneras vid sparandet utav l”senordet, och det „r denna 
  nyckel som anv„nds vid ALLA l”senords-rutiner (check, change, delete, etc)
  Eftersom inte vilka som helst skall kunna radera ett l”senord, s† m†ste 
  man ange den returnerade nyckeln (den man fick vid skapandet), samt det 
  korrekta l”senordet (Om man „r Root s† finns det undantag)

S† h„r fungerar det.

word64 Save_Password(const char *password, const char *name, const int times)
word32 Check_Password(const char *password, const char *name, const word64 pass_id)
word32 Change_Password(const char *password, const char *name, const word64 pass_id, const char *new_password, const int new_times)


Save_Password(...)
In-Data: password     Det l”senord som man vill spara undan. l”senordet 
                      skickas in som en pekare till en NULL terminerad 
                      "str„ng". f”r att allt skall fungera s† m†ste 
                      l”senordet inneh†lla misnt 5 tecken.
         name         En ID-handling som man kan anv„nda f”r att beskriva 
                      l”senordet, tex anv„ndarnamet p† den som l”senordet 
                      tillh”r, eller tex namnet p† applikationen.
         times        antalet g†nger som man skall kunna kontrollerar 
                      l”senordet och f† fel, innan systemet s„tter p† lite 
                      sp„rrar.

Retur:   pass_id      Ett 64 bitars l†ngt ord som inneh†ller en 
                      identifikation av l”senordet, dvs vart ligger 
                      l”senordet,m.m.
                      OM pass_id=0 s† inneb„r det att n†got fel har h„nt, 
                      och programmet som ville skapa l”senordet f†r ta hand 
                      om det.

Beskrivning:          F”r att spara ett l”senord s† skickar man in 3 v„rden, 
                      l”senordet, namn, och times, och tillbaka f†r man ett 
                      l”senords-id som man sedan anv„nder n„r man skall 
                      kontrollera/byta eller ta bort ett l”senord.
                      
Check_Password(...)
In-Data: password     Det "inskrivna" l”senordet som man vill kontrollera 
                      mot det riktiga.
         name         Det "inskrivna" namnet som man vill kontrollera mot 
                      det riktiga.
         Pass_id      det l”senoprds-id som programmet fick vid skapandet av 
                      l”senordet.

Retur:   ok           om returnv„rdet „r 0 s† st„mde inte kontrollen, det 
                      kan vara flera orsaker till detta, tex l”senordet kan 
                      vara fel, namnet kan vara fel eller id:t kan vara fel, 
                      vad som „r fel f†r man inte reda p† (f”r att man inte 
                      skall kunna k”ra en utslutningsmetod f”r att kn„cka 
                      systemet)
                      om returv„rdet „r 1 s† st„mde kontrollen och 
                      programmet b”r d† ge access.
                      OBS skulle man anv„nda check_password(...) och man 
                      anger fel v„rden fler „n vad times (i save_password 
                      rutinen) angets s† sker vissa saker, f”rst och fr„mst 
                      s† informeras Root om detta, sedan s† sker en 
                      check-stopp p† detta id, f”r en viss tid. dvs man kan 
                      fortfarande kontrollera l”senordet, men man fp†r 
                      alltid fel som resultat. efter en viss tid (satt by 
                      Root) s† kommer l”senordskontrollen att fungerar igen 
                      f”r detta l”senord. OBS Om man skulle f”rs”ka sig p† 
                      att kontrollera l”senordet innan denna tid g†tt ut, s† 
                      kommer tid-r„kningen att b”rja om fr†n b”rjan, dvs har 
                      man ett program som konternuerligt ligger och f”rs”ker 
                      hitta l”senord s† kommer den med mycket h”g 
                      sannolikhet ALDRIG att hitta ett l”senord.
                      (denna s„kerhets-funktion „r till f”r att hindra 
                      program som f”rs”ker kncka systemet)

Beskrivning:          Denna rutin anv„nder man f”r att kontrollera ett 
                      l”senord, och den har samtidigt inbyggd kontroll och 
                      s„kerhet f”r att skydda anv„ndaren mot kn„ckning.

Change_Password(...)
In-Data: password     se check_password(...)
         name         se check_password(...)
         pass_id      se check_password(...)
         new_pasword  se Save_Password(...) In-data: password
         new_name     se Save_Password(...) In-data: name
         times        se Save_Password(...)

Retur:   ok           0 fungerade inte „ndringen och ingen annan 
                      fel-indikation anges.
                      1 Žndringen fungerade.
                      OBS samma kontroll som sker vid Check_Password sker, 
                      och d„rf”r f†r „ven Change_Password samma h”ga 
                      s„kerhet som check_password f†r.
Beskrivning:          Denna rutin anv„nds om anv„ndaren will „ndra sitt 
                      l”senord av n†gon anledning, tex han kanske r†kat 
                      n„mna den f”r n†gon.

Delete_Password(...)