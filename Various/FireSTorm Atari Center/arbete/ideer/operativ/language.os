Beskrivning av spr†k-filerna.

Struktur p† spr†kfilen ser ut som nedanst†ende

[Dialog-namn/Menunamn]
{
   
   'objektnamn','[Text som visas i Objektet]','[Shortkey]'
   'objektnamn','[Text som visas i Objektet]'
   'objektnamn','[Shortkey]'
   ...
}
[Dialognamn/Menunamn]
{
   ...
}
...
GSK
{
  'objektnamn','[Shortkey]'
  ...
}

Observera att ordningen p† datan i objekten f†r „ndras. anledningen till detta
„r att spr†k-laddaren anv„nder sig utav objekt-namnen f”r att hitta r„tt objekt.
F”rekommer ett '_' s† kommer efterf”ljande tecken att bli understruket. Allt f”r
att man skall kunna se vilken tangent som „r short-key (man beh”ver ej specifiera
en 'short-key' f”r detta object, f”r ALT-'tecken' blir default d†)

NamnBeskrivning av Short-key knappar som inte „r skrivbara

Knapp           - shortkeynamn
Escape          - <Esc>
Tab             - <Tab>
Return          - <Return>
Help            - <Help>
Undo            - <Undo>
Backspace       - <Back>
Delete          - <Del>
Insert          - <Ins>
Clr/Home        - <Clr>
F-tangenterna   - <F1,...,F10>
Num-tangentbord - <Num0,...,Num9,Num(,...>
Control         - <Ctrl>
V„nstershift    - <Lsh>
H”gershift      - <Rsh>
Shift (N†gon)   - <Shift>
Alternate       - <Alt>
Space           - <Space>
Pil up          - <Up>
Pil v„nster     - <Left>
Pil h”ger       - <Right>
Pil ned         - <Down>
<               - <"<">
>               - <">">
'               - <'>

Short-key hanteraren ser ingen skillnad p† stora och sm† bokst„ver, dvs
<Space>,<SPACE>,<SpaCE> tolkas likadant. detsamma g„ller de vanliga tecknen
a,A,b,B, osv. vill man ha en skillnad p† dem i programmet s† f†r man
utnyttja <shift>,<Rsh> och <Lsh> men observera att d† tas det ingen h„nsyn
till Capslock-tangenten.

F”rkortningar f”r Olika spr†k - se landskod.txt

vid fel i n†gon Spr†k-fil s† talar OS:et om f”r anv„ndaren vad som „r fel, och man f†r
alternativet att editera spr†kfilen, eller f”rs”ka med n†gon ny spr†k-fil.

Ex p† hur en spr†k-fil kan se ut.

Everest.eng

Mainmenu
{
  'EVEREST'
  'About Everest...'
  'file'
  'New','<Ctrl>N'
  'Open...','<Ctrl>O'
  'Merge...','<Ctrl>H'
  'Save','<Ctrl>S'
  'Save as...','<Ctrl>M'
  'Close','<Ctrl>U'
  'Cycle Windows','<Ctrl>W'
  'Save changes','<Shift><Ctrl>S'
  'Close all','<Shift><Ctrl>U'
  'Print...','<Ctrl>P'
  'Quit','<Ctrl>Q'
  ...
}
...
GSK
{
  Undo,'<UNDO>'
  Delete_line,'<CTRL>Y'
  ...
}
