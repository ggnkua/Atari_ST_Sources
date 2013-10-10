struct
{
  union
  {
    long ltype;
    char stype[4];
  }
  long ap_id;
  union
  {
    byte bdata[8];
    word wdata[4];
    long ldata[2];
  }  
}MESSAGE;
/*
 Beskrivning av MESSAGE structen
 * ltype/stype - Vilken TYP meddelandet har
 * ap_id Applikationens ID-Nummer
 * size Storlek p† den Data som befinner sig utanf”r sj„lva structen
 * bdata/wdata/ldata Data som skickas med applikationen, denna data „r 8 byters stort
   och oftast tillr„ckligt f”r att man skall kunna skicka de flesta meddelanden.
   Vill man d„remot skicka meddelanden som „r st”rre „n 8 bytes s† kan man g† tillv„ga
   p† f”ljande s„tt. (dessa meddelanden kalar ju h„danefter l†nga)
     * Allokera minne (SHARED) s† att det r„cker till †t sitt meddelande.
     * s„tt det allokerade minnet s† att mottagaren kan l„sa det.
     * S„tt ldata[0] till storleken p† det allokerade minnet. (S† att mottagaren vet
         hur mycket som skall l„sas.
     * s„tt ldata[1] till att peka p† det minnet som inneh†ller meddelandet.
     * Fyll i Minnet med meddelandet.
     * Skicka Meddelandet.
     * Minnet som man allokerade skall man sedan "gl”mma bort"
   P† Mottagar-sidan b”r f”ljande utf”ras.
     * L„s in meddelandet.
     * kopiera det som finns i minnesomr†det d„r ldata[1] pekar.
       antalet bytes att kopiera „r ldata[0]
     * deallokera det gemensamma minnet.
     * Behandla meddelandet.
   Detta f”rfarande „r inte att rekommendera om man skickar ett l†ngt medeelande till
     flera processer (tex en grupp, eller ALLA processer) eftersom man f†r problem med n„r
     skall man deallokera minnet som man allokerat f”r meddelandet. skall s„ndaren
     deallokera, eller skall mottagaren g”ra det (is†fall vilken mottagare)?
*/     