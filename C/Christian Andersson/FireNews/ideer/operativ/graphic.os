Beskrivning av Graphic.Device

* Denna fil, „r den som tar hand om Kommunikationen till/fr†n Grafik-kortet
  Vid installation av systemet s† skall man tala om vilket grafik-kort man 
  har, resten sk”ter installations-programmet av.

* I denna Graphic.device s† finns ALLA rutiner som man beh”ver anv„nda f”r att 
  rita p† sk„rmen. och den startas upp i b”rjan av systemet f”r att kolla om 
  det „r R„tt grafik-kort och s† vidare.

* De olika ritinerna i graphic.device „r "f”nster" baserade, dvs de m†ste 
  ha ett f”nster att rita i f”r att fungera.
* Funktioner inom samma grupp b”rjar med liknande begynelse, tex 
  funktionerna f”r att h„mta v„rden b”rjar alltid med GGet*

* funktioner f”r att rita

GDraw_Line(...)
GDraw_PolyLine(...)
GDraw_Box(...)
GDraw_FilledBox(...)
GDraw_Circle(...)
GDraw_Fill(...)
...

GSet_DrawMode(...)
GSet_FillColor(...)
GSet_FillStyle(...)