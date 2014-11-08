Minneshantering i FireSTorm OS

* St”d f”r Virtuellt Minne
  - Variabel Fil, om mera minne beh”vs f”r tillf„llet, och det inte finns 
    plats i den aktuella Minnes-filen s† allokeras mera plats †t 
    minnesfilen. Och om Virtuellt Minne inte anv„nts p† ett tag, s† 
    deallokeras det minnet. Hur mycket virtuellt Minne som man kan anv„nda 
    bst„mms d† av hur mycket plats man har p† H†rddisken f”r tillf„llet.
  - Fast Fil, DVS man talar om hur mycket virtuellt Minne man vill ha, sedan 
    skapar OS:et en fil med denna storlek.
  - "Partition" p† H†rddisken, dvs Man s„tter ett specifikt st„lle p† 
    h†rddisken som Virtuellt Minne, dvs man f†r d† ingen fil som m†ste 
    uppdateras, och som kan fragmenteras, utan man f†r ett enda l†ngt omr†de 
    som man har direkt†tkomst p†.
* St”d av H†rdvaru-Sidhantering av Minnet MSTE finnas (68030+ eller 
  68020+PMMU)
* "Minsta" antalet sidor en process har i Minnet samtidigt „r 5 (om inte 
  processen „r mindre), MEN en process kan l„ggas ut helt och h†llet p† det 
  virtuella Minnet, n„r minne till denna process sedan anv„ndes laddas 5 
  sidor in.
* ALLA adresser skall hanteras som 64bitars tal, dvs adressregistret „r p† 
  64bitar
* Dynamisk Minneshantering, dvs alla processer kan n„r de vill allokera och 
  deallokare minne. Taack var sidhanteringen s† kan man „ven ut”ka och 
  minska sina allokerade minnen som man vill.
* Allokeringsflaggor st”djs. dvs det allokerade omr†det kan ha olika flaggor 
  som talar om hur minnet „r och hur det beter sig.
  Dessa flaggor talar tex om hur pass Aktivt minnet kommer att vara (f”r att 
  anpassa den virtuella minneshanteringen) och hur pass bra s„kerhet det „r 
  p† minnet, dvs hur olika processer skall kunna komma †t minnet, osv.
* Man skall kunna tala om vilka processer som (f”rutom „garen) skall kunna 
  l„sa/Manipulera/Deallokera minnet.
  Det kan tex ibland vara f”rdelaktigt att dela sitt minne med sina barn.


...* MemoryAlloc(... size);
...* MemoryFree(... *adress);
...* MemorySize(... *adress, ... newsize);
... MemoryProperties(...)

... = Vet ej f”r tillf„llet.
      N„r det g„ller MemoryAlloc, MemoryFree och Memorysize s† kan det vara
      ett 32 eller 64 bitars v„rde (32/64 bitars adress) kanske rentav 128
      bitar.

