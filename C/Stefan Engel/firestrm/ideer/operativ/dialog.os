Dialog hantering i FireSTorm OS

Editerbara f„lt:
  * Editerbara f„lt skall vara markerbara.
  * Man skall kunna dra det markerade ifr†n ett editerbart f„lt till n†gon 
    annan applikation, Eller ett annat editerbart f„lt.
  * Man skall kunna l„gga en "textstr„ng" p† ett editerbart f„lt och den 
    skall d† fylla i f„ltet med det man drog. (fungerar som CTRL-V)
  * CTRL-C skall Kopiera ifr†n det editerbara f„ltet. Endera det markerade, 
    ELLER hela f„ltet (om inget „r markerat).
  * ESC t”mmer f„ltet.
  * CLR t”mmer „ven det f„ltet.
  * UNDO †ngrar en „ndring i det editerbara f„ltet (upp till 10 „ndringar 
    skall kommas ih†g)
  * CTRL-UNDO Fyller i det ursprungliga v„rdet, dvs det v„rdet som stod
    i f„ltet n„r dialogen ”ppnades.
  * CTRL-X Klipper det markerade ifr†n det editerbara f„ltet. Eller hela 
    f„ltet om Inget markerats.
  * CTRL-V skall Klistra in i det editerbara f„ltet. Inklistringen skall ske 
    ifr†n mark”ren, och skall beakta INSERT/OVERWRITE.
    Inklistringen skall „ven betrakta vad som FR klistras in.
  * SHIFT-CTRL-V ers„tter ALLT i det editerbara f„ltet med det som skall 
    klistras in.
  * VNSTER/H™GER/UPP/NED flyttar mark”ren i ett editerbart f„lt.
  * SHIFT-UPP/NED flyttar till f”reg†ende/N„sta editerbara f„lt, men enbart om 
    de har Samma f”r„lder.
  * H”ger musknapp skall bringa upp en meny, d„r man kan v„lja kopiera, 
    klipp ut, Klistra, t”m, etc.
  * Om ett editerbart f„lt har flera rader s† skall RETURN g† till n„sta rad,
    ocxh CTRL-RETURN flytta till n„sta f„lt.

Popup: Tangentbord.
  * RETURN aktiverar en popup (dvs ”ppnar den)
  * UPP/NED flyttar den markerade raden 1 steg upp, eller 1 steg ned.
  * RETURN i en aktiverad popup v„ljer ett av alternativen och returnerar 
    det till Programmet/dialogen.
  * ESC avbryter den aktiva popupen, och inga „ndringar sker.

Popup: Mus (Icke nedh†llen knapp)
  * V„nster musknapp ”ppnar popupen.
  * Scrollar upp/ned g”r man med de up/ned-pilen som befinner sig v„nster om 
    popupen. Eller med hj„lp av den slidebar som finns.
  * V„nster mustryck vid ”ppen popup och p† n†got av popup alternativen, 
    returnerardet alternativet till dialogen/programmet.
  * v„nster musknapp utanf”r popup avbryter popupen,. och ingen „ndring 
    sker.
  * h”ger musknapp avbryter popupen och inga „ndringar sker.

Popup: Mus (Nedh†llen knapp)
  * V„nster musknapp aktiverar popupen, men ist„llet f”r att g”ra ett klick 
    s† h†ller man fortfarande musknappen nedtryckt.
  * Sl„pper man musknappen och n†got av alternativen „r aktiverade s† v„ljs 
    det alternativet och skickas tillbaka till dialog/program
  * sl„pps musknappen utanf”r popup s† abryts det hela och inga „ndringar 
    sker.
  * flyttas mus nedanf”r/ovanf”r popup s† scrollas popup:en ned†t/upp†t. 
    Hastigheten p† scrollningen beror p† hur LNGT ovanf”r/nedanf”r musen 
    befinner sig.

F”rflyttning mellan objekt:
  * TAB flyttar till n„sta objekt som kan „ndras, tex knappar, flaggor, 
    Popups, editerbara f„lt, etc.
  * SHIFT TAB flyttar till f”reg†ende objekt (annars som TAB)
  * RETURN Trycker in knappar/G†r till n„sta rad i ett editerbart f„lt.
  * CTRL-RETURN - G†r till n„sta objekt som kan „ndras (som TAB) om det
    aktiva objektet „r ett etxt-f„lt..

F”r att ALLA tangentbords kombinationer, funktioner ovan skall g„lla s† 
kr„vs det att objektet det skall p†verka „r aktivt. Byte av aktivt objekt 
kan g”ras med musen, eller via tangentbordet (angivet ovan)

F”r att man skall kunna „ndra i en Resurs under k”rning s† finns det ett 
antal funktioner som man kan anv„nda sig utav.

* ResourceAddObject(...)
* ResourceDeleteObject(...)
* ResourceReorderObject(...)

Dialog-systemet „r uppbyggt kring "Relativ sortering" dvs det finns inga
x,y,w eller h Koordinater sparade (inte ens relativa s†dana) utan hela
dialogen „r uppbygd kring den verkliga storleken p† objektet och den
verkliga storleke beror p† inneh†llet. dvs st†r det "hejsan" i en knapp s†
„r den knappen mindre „n en som det st†r "Tjofadderittan" i. Detta f”rfarande
kan dock unds„ttas genom att man best„mmer att alla objekt skall ha samma
storlek. Dvs knappen f”r "Hejsan" blir lika stor som knappen f”r
"Tjofaderittan".