Information om Meddelande-systemet i FireSTorm OS

Ett meddelande best†r utav Typ, vem som skickade meddelandet, och sedan 
sj„lva meddelandet
Man kan skicka meddelanden endera till 
 - Ett specifikt program (app-ID)
 - Till en grupp av program (grp-ID)
 - Till Alla

Meddelande grupper:
	f”r att man enklare skall kunna best„mma vad programmet skall klara av 
	s† delas alla meddelanden in i olika grupper. d„r varje grupp best†r 
	utav 1 meddelande som talar om att denna grupp inte st”djs, och sedan 
	upp till 255 meddelanden i gruppen.
	dvs det finns ett maximalt antal av 256 meddelanden i varje grupp. 
	Detta inneb„r att det finns ca 16Milj antal olika typer av grupper, s† 
	varje program borde klara sig „nd†.
	F”r att ytterligare f”renkla f”r programmerarna s† „r det best„mmt att 
	de f”rst 16 bitarna i meddelande typen talar om ifall det „r ett 
	program-specifikt meddelande eller, ocm det „r ett "generellt" 
	meddelande. Vid generella meddelanden s† „r de f”rsta 16 bitarna satta 
	till 0.
	Man kan d„rf”r dela upp meddelande typen som f”ljande skiss n„r det 
	g„ller generella meddelanden.
    |0000000000000000|XXXXXXXX|YYYYYYYY|
    X - Meddelande grupp
    Y - Meddelande i denna grupp.
    Och n„r det g„ller program-specifika meddelanden
    |XXXXXXXXXXXXXXXXXXXXXXXX|YYYYYYYY|
    X - Grupp-ID
    Y - Meddelande i Gruppen.
    Et r†d „r att meddelanden inom samma program, b”r h†lla sig inom samma 
    grupp.

Funktioner som „r anv„ndbara tillsammans med meddelanden.
mesg_send(...)
 - Skickar ett meddelande till en Applikation/grupp av applikationer,
   till alla eller till s„ndarens barn.
mesg_get(...)
 - V„ntar p† ett meddelande, ELLER kollar om det finns ett meddelande som 
   skall h„mtas (Funktionen kan allts† avslutas utan att ett meddelande 
   kommer in, perfekt f”r tex Raytracers, eller andra program som arbetar i 
   bakgrunden)
get_group(...)
 - H„mtar information om en Applikations-grupp
get_appl(...)
 - H„mtar information om en Application. 
get_wind(...)
 - H„mtar information om de olika f”nstren som en applikation anv„nder sig 
   utav.
reg_group(...)
 - Anv„nds f”r att registrera en applikations-grupp som inte redan finns.
reg_appl(...)
 - anv„nds f”r att registrera sin applikation.
 
* Varf”r skall man anv„nda sig av grupper f”r?
  Det „r ett enkelt s„tt att tala om f”r andra applikationer vilket typ av 
  applikation man sj„lv „r. DVS min applikation kan tala om att jag „r ett 
  Grafik-program, och andra applikationer VET d† om detta, och kan skicka 
  meddelanden som ber”r grafik till mitt program (Tex editera denna bild, 
  etc)
  Varje Applikationstyp beskrivs med hj„lp av en text-str„ng p† 16 tecken 
  Om inte ALLA tecken i Str„ngen anv„nds SKALL de ICKE anv„nda vara 
  Nollade, detta f”r att j„mf”relsen skall fungera snabbast m”jligt.

  Exempel p† Olika typer av applikationer:
    "Text-Editor", "Text-viewer", "Sound-Editor", "Sound-Player", 
    "Music-Editor", "Music-Player", "Graphic-Editor", "Graphic-Viewer", 
    "GIF-Viewer", "Jpeg-Viewer", "Targa-Viewer",

  Om nan har 2 GIF-Visare ig†ng och man vill visa en GIF-bild s† kan man nu 
  f† ett meddelande om att det finns 2 visare, och man kan nu f† v„lja 
  visare. Dessutom s† kan ALLA Program Visa en GIF-bild om GIF-viewer finns 
  med som grupp-typ, utan att applikationen alls k„nner till vilken 
  gif-visare man anv„nder sig utav.

*Meddelande strukturen.
struct
{
  union
  {
    long ltype;
    char stype[4];
  }
  long ap_id;
  long size;
  void *data;
  union
  {
    byte bdata[8];
    word wdata[4];
    long ldata[2];
  }  
}MESSAGE;

* Meddelande typer och kort beskrivning
-----------------
Win*			- Meddelanden som g„ller f”nster. dessa meddelanden skickas 
					oftast fr†n OS:et n„r en anv„ndare utf”rt n†got med f”nstrena.
WinMoved		- F”nstret vill bli flyttat
WinSized		- F”nstret vill „ndra storleken
WinTopped		- F”nstret vill aktiveras.
WinBottomed		- F”nstret vill l„ggas i botten.
WinOnTop		- F”nstret har blivit aktivt
WinUnTop		- F”nstret har deaktiverats.
WinIconify		- F”nstret vill Ikoniseras.
WinUnIconify	- F”nstret vill inte vara ikoniserat l„ngre
WinAllIconify	- Alla f”nster skall iconizeras (1 icon?)
WinAllUniconify	- Alla f”nster tillbaka till icke ikoniserat l„ge.
WinUpdate		- F”nstret beh”ver uppdateras
WinFulled		- F”nstret vill bli bli stort(Full-Size)
Winclosed		- F”nstret vill st„ngas.
WinDragOn		- N†gonting har blivit sl„ppt p† ett f”nster.
WinDragOff		- N†gonting har blivit dragit fr†n f”nstret och sl„ppts 
					n†gonstans.
WinHidden		- F”nstret har G”mts. (och beh”ver d„rf”r inte uppdateras)
WinUnHidden		- Ett g”mt F”nster har plockats fram. (Och skall b”rja 
					updateras igen)
WinUpLine		- Upp-pilen har tryckts, dvs man vill "scrolla" 1 rad upp†t, 
					eller liknande (kan ocks† genereras via pil upp p† 
					tangentbordet)
WinDownLine		- Ned-Pilen har tryckts. (Via Mus, eller tangentbord)
WinUpPage		- Man har tryckt Ovanf”r Slide-Boxen, Eller, anv„nt SHIFT 
					tillsamans med ett tryck p† Up-Pilen.
					(Kan „ven genereras fr†n Tangentbord, med Page-up)
WinDownPage		- Som f”r UpPage. men d† Ned 1 sida.
WinVSlide		- Man har flyttat den vertikala Sliden.
WinHslide		- Man har flyttat den horisontella Sliden.
WinClicked		- N†gon har tryckt inom f”nstret.
WinMouseEnter	- N†gon har flyttat musen in i f”nstret.
WinMouseLeave	- N†gon har flyttat musen ut ur f”nstret.

-----------------
Appl*			- Meddelande till/Fr†n Applikationer fr†n/till andra 
					applikationer.
ApplActive		- Applicationen L„ggs i F”rgrunden
ApplDeactive	- Applicationen l„ggs i Bakgrunden
ApplIdent		- En Applikation vill identifiera sig med denna.
ApplOpenFile	- En Applikation vill att denna applikation skall ”ppna en fil.
ApplFileOpened	- Applikationen har ”ppnat filen (svar till ApplOpenFile)
ApplFileChanged - If an appliction opens a file via the ApplOpenfile Message it should
					tell the Program that sent the message if it has changed, this message
					does just that.
ApplFileClosed  - If an Application opens a file via the ApplOpenFile Message it should
					tell the program that sent the message that the file has been closed,
					ie the application has finnished with this file. This message is for
					this purpose.
ApplGetStatus	- N†gon vill ha reda p† Applikationens status
applStatus		- Status som en applikation har skickat, Utseendet/Inneh†llet 
					f”r denna status „r Applikations-beroende, f”rutom vissa 
					specifika saker i b”rjan av meddelandet.
ApplStartProg	- Applikationen b”r starta denna applikation, detta 
					meddelande skickas oftast till Program-Hanteraren.
					Man kan „ven skicka default-Namn som „r specifierade, tex 
					EDITOR vilket d† „r den specifierade editorn (kan vara 
					olika beroende p† anv„ndaren, och beroende p† vilken 
					typ av fil somskall editeras)
ApplProgStart	- Svaret p† ett ApplStartProg meddelande, h„r finns 
					information om det gick att starta den ”nskade 
					applikationen,eller inte.
ApplPath		- N†got i denna s”kv„g har „ndrats, applikationer som 
					anv„nder sig utav denna s”kv„g b”r uppdatera den.
					Žven aplikationer som anv„nder sig utav underbibliotek 
					b”r uppdatera sina bibliotek.
ApplExit		- En Applikationen b”r avsluta.
ApplExiting		- The answer to the ApplExit Request, it tells the sender of the
					application can exit direclty, in while, it cannot exit, or if it
					requires some user-responce to be able to exit.
ApplHalt        - The Applications should stop all it's activities, and wait for an ApplStart
					Message (this one is used to get more processortime for a specific program)
ApplHalting     - The responce to an ApplHalt message, this one tells teh ApplHalt sender if the
					application will comply to the ApplHalt Message.
-----------------                 
Clip*           - Messages concerning the ClipBoard
ClipNew         - A New clipboard entity (that was not in here before) has been created.
ClipChanged     - An Clipboard entity has been changed.
ClipAsk         - A Program asks the clipboard manager if a certain entity exist.
ClipReply       - The clipboard tells the Program if a Certain Type exist or not. It can
                  also tell the Program if there exist other entitys that can be converted
                  to the requsted type.
ClipConvert     - Converts a Clipboard entity from one kind of Entity to another
                  (Ex: Windows Bitmap to Atari Image)

-----------------                 
Menu*			- Meddelanden som ber”r Menyer (endera i f”nster eller i 
					Desktopen)
MenuSelected	- Ett meny-val har blivit valt.

Timer*			- Meddelande som ber”r Timers
TimerExited		- En timer avslutades.

-----------------
Mouse*			- Meddelande som r”r Mus-Hanteringen
MouseEnter		- Musen Gick in i ett specifierat omr†de
MouseLeave		- Musen gick utanf”r ett specifierat omr†de
MousePressed	- En/Flera Musknapper trycktes ned.
MouseRelease	- En/Flera musknapper sl„pptes upp.
MouseClicked	- en musknapp har tryckts ned och sl„ppts upp (snabb f”ljd)
					Eller dubbel-klick har genomf”rts.
					(detta meddelande skickas ist„llet f”r MousePressed och 
					MouseReleased, om dessa h„ndelser sker inom en viss tid.
					Tiden f”r detta „r Naturligtvis inst„llbart. Sker 
					ytterligare MouseJKlick-Events s† kan det bli ett 
					dubbeltryck/Trippeltryck utav det, men aldrig mera)
MouseMoved		- Musen har Flyttat p† sig.
					Detta meddelande „r Ackumulativt, dvs om INTE 
					meddelandet l„ses av, utan ligger i meddelande 
					bufferten, s† kommer inte nya meddelanden av denna typ 
					att genereras, utan det tiddigare meddelandet kommer att 
					ut”kas. Detta g„ller dock endast om detta meddelande 
					ligger SIST i k”n.

-----------------                 
Keyb*			- Meddelanden som r”r tangentbordet
KeybPressed		- en tangent har tryckts ned och h†lls ned.
KeybReleased	- en knapp har sl„ppts upp.
KeybHit			- en tangent trycktes ned och sl„ppts upp (relativt snabbt).
					(Om nedtryckningen och uppsl„ppningen sker inom en viss 
					tid s† kommer OS:et att ist„llet f”r att skicka ett 
					KeybPressed och sedan ett Keybrelease, s† kommer ett 
					KeybHit Att skickas. tiden f”r detta „r naturligtvis 
					inst„llbart.)
-----------------                 
Objc*			- Meddelande som r”r Objekt i F”nster.
ObjcLClicked	- V„nster nusknapp trycktes ned p† ett objekt
ObjcRClicked	- H”ger ...
ObjcLDClicked	- Dubbel click med V„nster
ObjcRDClicked	- Dubbel med H”ger
ObjcUpLine		- En Up-pil har tryckts
ObjcDownLine	- En Nedpil har tryckts
ObjcUpPage		- Man har tryckt ovanf”r en slider (och vill d† g† en sida 
                    upp.
ObjcDownPage	- ...
ObjcVSlide		- ...
ObjcLeftLine	- ...
ObjcRightLine	- ...
ObjcLeftPage	- ...
ObjcRightPage	- ...
ObjHSlid		- ...
ObjcDragged     - 
ObjcDraggedOff	-
ObjcDropped		-
ObjcMouseEnter	-
ObjcMouseLeave	-
ObjcEnter       -
ObjcLeave       -
-----------------                 
Log*            - External Logging of Internal functions in Programs, this 
                  is a safer way to ensure that the log-file will NOT be 
                  corrupted by the application that logs. AND it will also 
                  provide the ability to read and sort the log with the 
                  special log-tool :)
LogRegister     - Register The application so that the Logger will recognise 
                  it when the log-messages are used.
LogRegistered   - Tells the application that it can now use the logger.
LogWhat         - Sends a text-string of what is to be logged, this 
                  text-string is then used to See if the current log-message 
                  is to be loged or not
LogString       - Tells the logger to log this message, but ONLY if the type 
                  is correct. The type is checked against the text-string 
                  that was sent with the LogWhat message.
LogExit         - Tells the Logger that No logging is now necessery, so that 
                  can forget the data that belongs to this application.