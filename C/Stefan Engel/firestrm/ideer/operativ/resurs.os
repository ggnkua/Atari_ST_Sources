Beskrivning av Resurs-filerna (de bildar tillsamans med spr†k-filerna det
kompletta grafiska gr„nsnittet (n†ja n„stan komplett) (OBS utan spr†kfilen
s† jkan inte resurs-filen anv„ndas)

Resurs-systemet „r uppbyggt via en form av tr„d-struktur. ™verst ligger
sj„lva huvudinformationen och under denna ligger resterande dialoger,
menyer, mm. Alla tr„d f”rutom det ”verst „r objekt. men alla Objekt kan inte
anv„ndas ”verallt. De Objekt som ligger direkt under huvudinformationen „r
sk huvud-objekt.

                          Resurs-information
              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍúúú
         Huvud-Objekt           Huvud-Objekt           úúú
   ÉÍÍÍÍÍÍÍËÍÍÊÍÍÍÍËÍÍúúú        ÉÍÍÍÊÍÍúúú
Objekt   Objekt   úúú           úúú
 ÉÍÊÍÍúúú
úúú

De olika huvud-objekten man kan anv„nda sig utav „r f”ljande.
dialog, Meny, Popup, fri str„ng, fri bild, fri icon.

OBS!!!!!
F”ljande information om resurser beskriver hur de ligger i MINNET!!!!
dvs EJ hur det ligger lagrat som filer.
OBS!!!!!

Resurs-informationen inneh†ller f”ljande information:
struct RO_object *list[];      pekare till en lista av objekt. i denna lista
       ligger ALLA object, och deligger i ordning, dvs barnen ligger direkt
       efter f”r„ldern.

F”r att g”ra det enkelt s† kan man inte (OM man inte anv„nder sig utav egna 
objekt) anv„nda mer „n 255 f„rger i en dialog. dvs alla objekt som 
anv„nder sig utav f„rg-register har endast 1 byte att lagra f„rg-nummret i.
Ett undantag „r naturligtvis det anv„ndar-definierade objektet, d„r man kan 
anv„nda hela f„rg-spektrumet.

Ett objekt har f”ljande struktur:
struct OBJECT
{
  char          name[16];
  long          next,
                prev,
                parent,
                child;
  short         type,
				grouping      : 1,  // Skall "barn" objekt grupperas upp/ned eller v„nster/h”ger
                change_width  : 1,  // Skall bredden „ndras n„r f”r„lderns bredd „ndras
                change_height : 1,  // Skall h”jden „ndras n„r f”r„lderns h”jd „ndras?
;
  union /* Data */
  {
    RO_UserDefined  *UserDefined;
    RO_Button       *Button;
    RO_ButtonHelp   *ButtonHelp;
    RO_BottunScroll *ButtonScroll;
    ...
    void            *data;
  };
}

name:  namnet p† objektet, detta namn anv„nds f”r att man skall kunna ha en 
       mycket fri spr†k fil, dessa namn kan „ven anv„ndas f”r att leta reda 
       p† objekt (och p† det s„ttet f† en resurs som „r n„stan helt och 
       h†llet fri fr†n ordningsberoende (dvs man kan byta objektordning, och 
       „nd† finna objektet). Dessa namn „r „ven ett m†ste om man vill 
       anv„nda sig utav grafika gr„nssnitt i FireSTorm Scripts.
       Denna del „r INTE Noll-terminerad, dvs man kan anv„nda ALLA 16 tecknen
       till namnet, DOCK s† skall alla icke anv„nda tecken vara t”mda/Nollade.
next:  Index nummer till n„sta objekt, „r detta "objekt" -1 s† finns inga mera 
       objekt.
prev:  Som next men f”reg†ende objekt.
parent: F”r„lder till objektet, finns det ingen f”r„lder s† „r detta 
        "objekt" -1
child: f”rsta barn objektet, -1 inget barn finns.
type:  Talar om vilken typ objektet „r utav. dvs str„ng, box, knapp, mm.
switches: Dessa talar om lite om hur objektet skall hanteras, tex „r det 
          g”mt? Aktivt?, etc.
data:  Pekare till ytterligare Objekt-data, eller data i sig sj„lv.denna
       data ser olika ut beroende p† vilken typ av objekt man har.
Helptext: Pekare till en liten text-str„ng som skall visas i en sk 
          pratbubbla om musmark”ren st†r stilla ”ver objektet under en viss 
          tid.
x:     Placering av objektet i X-led. („r det ett barn s† „r det relativt
       f”r„ldern.
y:     Placering av objektet i Y-led. („r det ett barn s† „r det relativt
       f”r„ldern.
w:     Bredd p† objektet.
h:     H”jd p† objektet.

Observera att x,y,w,h utseendem„ssigt kanske inte st„mmer ”verens med de
v„rden som st†r i Objekt-infot, detta beror p† vilka l„gen de st†r i, samt
vilka effekter man har utf”rt p† dem. Man kan dock alltid f† fram det 
"riktiga" v„rdet (i f”rh†llande till f”nstrets koordinater) med hj„lp av en 
extra funktion.

De olika typer som finns „r f”ljande.

*  Tree
     Denna inneh†ller information om det f”rsta tr„det, eller det andra tr„det,
     dessa object har INGA parents, bara 1 child, och next/prev "pekar" till
     n„sta/f”reg†ende tr„d. N„sta tr„d m†ste ligga senare i listan, och f”reg†ende
     is†fall f”e i listan. I detta object s† Detta objekt ser dock inte ut som andra
     objekt utan f”ljande „ndringar har gjorts.
     x,y - f”rh†llandet mellan x och y n„r detta tr„d skapades (f”r att FireSTorm
       l„t skall kunna omorganisera resursen i andra upl”sningar, „ven med andra 
       f”rh†llanden, normat sett s† anger man det l„gsta f”rh†llandet, tex 640*400
       ger x=8,y=5, 640*480 ger x=4, y=3
     w - anger antalet objekt som detta tr„d ha under sig, dvas alla barn, barnbar, etc.
     h - Anger antalet niv†er med barn,barnbarn, osv (dvs djupet)
     data - inneh†ller h„r 2 tecken som definierar det spr†k som resursen „r gjord f”r,
       dvs default spr†ket. DOCK s† kan det finnas flera spr†k, men denna skall ALLTID
       finnas med, utan denna spr†kfil s† fungerar inte resursen.
*  UserDefined
     Allt som sker detta objekt sk”ts via definierade gr„nssnitt i 
     anv„ndar-programmet. dvs uppdatering, etc. Man kan tala om vilka 
     "meddelanden" som skall skicka till dessa objekt.
*  Button
     En vanlig knapp, som man kan anv„nda f”r att g”ra olika val.
     Denna knapp fins i olika utseenden och funktioner.
*  ButtonHelp  (Vet ej om denna skall vara med, den skulle kunna finnas med i den vanliga Button)
     Denna "knapp" fungerar lite annorlunda „n vanliga knappar, eftersom
     det f”rst och fr„mst bara kan finnas 1 s†dan h„r per dialog, och att
     den automatiskt leder till att en hj„lp-fil kommer att visas. Den „r
     ocks† annorlunda genom det att den alltid har <HELP> knappen som
     short-key.
     Denna skall d† anv„ndas som hj„lp f”r "hela" f”nstret. 
*  ButtonScroll (Up/Down/Left/Right)
     Fungerar som vanlig knapp, men den anv„nds f”r att scrolla en Text-Area 
     Denna knapp associeras till en Slide-box och till den Text-Area som 
     skall scrollas.
*  SlideBox (Vertikal/Horisontal)
     Anv„ndes f”r att kunna scrolla i TextArea objekt. Detta objekt l„nkas 
     till en text-Area och 2 ButtonScrolls (Up/Down, eller Left/Right)
*  String
     En helt vanlig 1 radig str„ng,utan effekter eller n†got annorlunda.
*  Text
     en vanlig text-str„ng, men med den skillnaden (j„mf”rt med String) att 
     man kan definiera flera egenskaper, tex F„rger, Storlek, font, etc.
     Detta objekt kan „ven vara p† flera rader, vilket inte String klarade 
     av.
*  TextInput
     Som en Text, MEN den anv„ndes f”r att ta emot indata fr†n anv„ndaren.
     En "validation" str„ng anv„ndes d„rf”r f”r att anv„naren inte skall 
     kunna mata in fel sorts tecken. Vid anv„ndandet av h”ger knappen p† ett 
     s†dant h„r objekt s† dyker en liten popup up d„r man kan v„lja att 
     klistra/klippa/kopiera/rensa inmatningsf„ltet. Dessa saker fungerar 
     „ven med CTRL-C (Cut) CTRL-X (Copy) CTRL-V (Paste) och Esc (Clear)
     Del raderar ett tecken efter mark”ren, BACKSPACE raderar ett tecken f”re 
     mark”ren. SHIFT-DEL ett ord (och mellanslag efter/f”re ordet) 
     SHIFT-BACKSPACE som SHIFT-DEL men f”re, CTRL-DEL raderar ALLT efter 
     mark”ren, CTRL-BACKSPACE som CTRL-DEL men f”re mark”ren.
     Markerar i Texten kan man g”ra med SHIFT-H™GER/VNSTER eller med 
     v„nster musknapp.
     Om flera raders inmatning kan ske s† raderar CTRL-Y 1 rad i taget.
*  TextInputMenu
     Fungerar i princip som en Text-Input, MEN med den skillnaden att l„ngst 
     ut till h”ger finns det en knapp som ”ppnar en "menu" som man „ven kan 
     v„lje emellan. F”rslag om att UPP/NED skall automatiskt v„lja ett av 
     alternativen finns.
*  TextInputSecret
     Se textInput, men med den skillnaden att allt som skrives 
     representeras med enbart 1 tecken som representerar det man skriver, 
     tex '*' eller '#' eller inget tecken alls.
     Cut/Copy fungerar inte, utan det „r d† enbart Paste som fungerar.
     OBS alla program som anv„nder sig utav TextInputSecret R skyldiga att 
     kolla att detta objekt fortfarande „r ett TextInputSecret f”re 
     anv„ndandet utav den (tex om n†gon „ndrat i resursen)
*  TextArea
     Fungerar som text men med den skillnaden att den „r scrollbar, och den 
     associeras d„rf”r med Button-Up/down/Left/Right och med 
     SlideBox-Vertical/Horisontal f”r att kunna man”vereras ifr†n s†dana.
     Observera, detta objekt inneh†ller en text-str„ng d„r CR/LF (eller om 
     det „r LF/CR) som anv„ndes f”r att indikera de olika raderna.
* TextInputArea
     detta objekt fungerar i princip som en enkel text-editor. 
     Klippa/klistra finns naturligtvis med. TextInputArea „r dock sv†rare 
     att fixa f”r den som programmerar dialog-hanteraren :)
     Man skall kunna tala om maximalt antalet Rader/Kolumner (eller 
     o„ndligt)
*  TextListArea
     fungerar n„stan som en Text-area, men ist„llet f”r att ha en pekare 
     till en text som skall visas s† anv„nder man sig utav 
     callback-funktioner f”r att hitta inneh†llet i raderna. Detta f”r att 
     resurs-hanteraren inte har n†gon som helst aaning om hur structer och 
     s† vidare ligger lagrat.
     Det „r allts† upp till programmet att skapa och formatera listan p† 
*  PictureListArea
     fungerar n„stan som TextLisdtArea, men ist„llet f”r att callback-rutinerna
     returnerar en pekare till en etxt-str„ng (char *) s† returneras en pekare
     till ett object, av typen RO_Icon, eller RO_Image, Om objectet „r en
     RO_Icon s† fungerar denna icon som den borde g”ra om den anv„ndes direkt
     i dialogen.
*  Icon
     En "icon" „r egentligen en Image, men med den skillnaden att varje bild 
     kan best† utav flera bilder som ser olika ut, beroende p† om bilden „r 
     vald, deaktiverad, etc. Den reagerar „ven p† mustryckningar p† s† s„tt 
     att bilden kan „ndras n„r den blir aktiverad. En icon kan „ven ritas 
     upp med storleks-f”r„ndringar (det kan inte en Image) s† att den b„ttre 
     passar in i f”nstret. Till en bild kan man „ven ha en liten text-remsa, 
     och en hj„lp-text.
*  Image
     en bild, i endera 1,16 eller 256 f„rger. Alla dessa alternativ kan 
     ligga lagrat i detta objekt, Och den som ligger n„rmast till sanningen 
     anv„ndes.
*  PageRegister
     Sv†rt att f”rklara utan en bild :) Men varje del-register i en 
     Pageregister associeras till en egen page, och n„r ett delregister i en 
     Page-Register v„ljs, s† g”ms de pages som „r associerade till de ”vriga 
     delregistren, och den Page som „r associerad till det aktiva 
     delregistret visas. Man kan tala om hur m†nga "rader" man vill anv„nda 
     sig utav, Och „ven hur den skall se ut (orienteringen, v„nster, h”ger, 
     upp,ned) Om fler „n 1 rad anv„ndes s† kommer den rad d„r den aktuella 
     Page:n finns att hamna n„rmast Page:n.
*  Page
     Varje page som skall h”ra till Samma page-register MSTE ha samma 
     storlek (dvs Page:s som finns under samma f”r„lder) annars s† kan man 
     inte n† de "felaktiga" sidorna. Observera att den korrekta sidan „r den 
     som associerats fr†n det f”rsta delregistret :) OCH bred eller h”jd
     MSTE st„mma ”verens med den bred eller h”jd som page-registret 
     anv„nder sig utav.
*  Panel
     En Panel „r enkelt utryck en box man anvnder f”r att grupera ihop olika 
     kontroller, tex Radio-buttons fungerar endast inom samma panel. dvs om 
     man markerar 1 radio-button s† avmarkeras alla med samma f”r„lder, 
     Panels anv„nder man f”r att f† samma f”r„lder.
*  ToolPanel
     r i princip en Panel, men med den skillnaden att man kan minimera den 
     s† att endast en etremt liten del synes.
*  ToolPanelGroup
     r ett s„tt att gruppera ihop flera Panels, Om man anv„nder sig utav 
     ToolPanelGroup f”r att grupera ihop panelerna, s† kommer man vid 
     minimerandet av flera ToolPanels att f† en mycket mindre minimering 
     j„mf”rt med de separata minimeringarna. Man skall ocks† kunne flytta om 
     bland de olika Toolpanels, dvs om Toolpanel 1 ligger ”verst s† skall 
     man kunna lga toolpanel 2 ”verst...
*  Menu
     Vet ej hur jag skall f† Menu-strukturen at fungera, det borde finnas 3 
     olika typer av objekt. 
     Menu - Som talar om att detta „r ett menu-objekt, Barnet till detta 
         object „r den f”rsta menu-titel-entryt (typ Arkiv)
     MenuItem - Det „r dessa objekt som Menu-titlarna och Menu Raderna 
         best†r utav.
*  DrawObject
     Ritar en "figur" av n†got slag, Figuren kan vara tex en Box, En Linje, 
     en Cirkel, En Box med Runda h”rn, etc.
     P† dessa Objekt kan man sedan l„gga p† Effekter, som tex Skugga, 
     Intryckt, Uppsl„ppt, 3D-Ram, etc.
