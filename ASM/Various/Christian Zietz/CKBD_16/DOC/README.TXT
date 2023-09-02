Short notes to CKBD 1.5
-----------------------

The CKBD Deluxe software is FreeWare. The complete package or parts 
of it must not be sold or modified, the copyright is held by the 
author, Pascal Fellerich.

If you have any question, write to:

	Pascal_Fellerich@aia.com	(E-mail)
or:
	Pascal Fellerich		(Snail Mail)
	45 rue des Genàts
	L-3482 Dudelange
	Luxembourg


IMPORTANT:
* With NVDI3 installed, use the Monospace 821 (Speedo) or Courier New 
(Truetype) font to display the appended table correctly.

* If you don't have NVDI 3, you should install and enable the table
'NO_NVDI3.CKB' using the COMPOSE CPX module.

* MOUSE030.CPX is only for 68030/68882 or 68040 systems (TT). Do not 
use it on a Falcon030 without co-processor!


Purpose
=======
CKBD (Composed Characters Keyboard Driver) allows you to access 
characters which do not exist on your keyboard. There are several 
different ways to access these special characters.

CKBD also offers a flexible mouse speeder which, by default inactive, 
can be enabled and configured using the MOUSE.CPX module.

CKBD does not only extend the system keyboard driver but also fixes 
the 'jumping mouse' problem when a NVDI 3 is installed and a 
MOD-player like PAULA is active.

Most important: CKBD and the associated CPX modules are FREEWARE. It 
may be copied and distributed freely, and must not be modified or 
sold.



Quick User's Guide to CKBD 1.5
==============================

1. Installation:
+ copy CKBD.PRG into your AUTO-folder, preferrably after NVDI.
+ copy COMPOSE.CPX and MOUSE.CPX (or MOUSE030.CPX if you have a TT) 
into your CPX-Folder.
+ reboot. During the boot process, hold down either SHIFT or the 
CONTROL key to read the CKBD installation message.

2. Usage:
+ using the 'Keyboard Manager' CPX, you can enable or disable the 
different compose options.
+ using the 'Mouse Control' CPX, you can configure the mouse speeder. 
If you don't want to use the mouse speeder, deactivate the MOUSE.CPX.
+ Compose: Hit the ALT-key as if it was a normal character key. A 
keyclick sound can be heard. Now type the two characters which make 
up the composed character, e.g. " and u. An Å character appears 
instead. If you make a mistake, the bell sounds. Any non-character 
key (ESC, Backspace, F-keys...) terminates the compose mode started 
by ALT.
+ Deadkey: Type an apostrophe and nothing happens, except for the 
keyclick sound if you have it enabled. Type an o and an ¢ (o acute) 
appears. Use COMPOSE.CPX to configure what keys you want to be 'dead' 
keys. Hitting a dead key twice generates the 'dead' character. Typing 
a dead key and then SPACE or any other non-character key passes both 
keys transparently to the application, regardless of the table in use.
+ Extkey: first type the 'main' character, e.g.: y. Then hold down 
the CONTROL-key and type the diacritical mark, e.g. ". An ò (y 
umlaut) appears. Note that this (old) method does not always work 
because most programs requiring keyboard input have problems with the 
CONTROL-key which is still held down when the composed character 
arrives.
+ ALT-nnn: Hold down the ALT-key and type the ASCII code on the 
numeric keypad.

For more detailed information please read the docs...




Compose table
=============

Note:
* Order sensitive means that the characters have to be entered in 
exactly the indicated order. <COMPOSE> <E> <A> doesn't work, use 
<COMPOSE> <A> <E> instead to get <í>.

* NO_NVDI3.CKB is the same table except for the ASCII codes 192 to 
222 for which no compose sequences are defined. Load this table if 
you don't use vector fonts with NVDI3.


ASCII Code	Compose Sequence	Comment or Description
	Character		Order sensitive Y/N
--------------------------------------------------------------
35	#	++      	N	number sign
64	@	aa AA      	N	commercial at
91	[	((      	N	opening bracket
92	\	//      	N	backslash
93	]	))      	N	closing bracket
123	{	(-      	N	opening brace
124	|	/^      	N	vertical line
125	}	)-      	N	closing brace
128	Ä	C,      	N	C cedilla
129	Å	u" uπ      	N	u umlaut
130	Ç	e'      	N	e acute
131	É	a^      	N	a circumflex
132	Ñ	a" aπ      	N	a umlaut
133	Ö	a`      	N	a grave
134	Ü	a. a¯      	N	a ring
135	á	c,      	N	c cedilla
136	à	e^      	N	e circumflex
137	â	e" eπ      	N	e umlaut
138	ä	e`      	N	e grave
139	ã	i" iπ      	N	i umlaut
140	å	i^      	N	i circumflex
141	ç	i`      	N	i grave
142	é	A" Aπ      	N	A umlaut
143	è	A. A¯      	N	A ring
144	ê	E'      	N	E acute
145	ë	ae      	Y	ae diphtong
146	í	AE Ae      	Y	AE diphtong
147	ì	o^      	N	o circumflex
148	î	o" oπ      	N	o umlaut
149	ï	o`      	N	o grave
150	ñ	u^      	N	u circumflex
151	ó	u`      	N	u grave
152	ò	y" yπ      	N	y umlaut
153	ô	O" Oπ      	N	O umlaut
154	ö	U" Uπ      	N	U umlaut
155	õ	c/ C/ c| C|	N	Cent sign
156	ú	L_ L- l- l_	N	Pound sign
157	ù	Y- y- Y= y=	N	Yen sign
158	û	ss      	N	German sharp s
159	ü	f-      	N	Florin sign
160	†	a'      	N	a acute
161	°	i'      	N	i acute
162	¢	o'      	N	o acute
163	£	u'      	N	u acute
164	§	n~      	N	n tilde
165	•	N~      	N	N tilde
166	¶	a_ a-      	N	feminine ordinal character
167	ß	o_ o-      	N	masculine ordinal character
168	®	??      	N	inverted ?
171	´	12      	Y	fraction 1/2
172	¨	14      	Y	fraction 1/4
173	≠	!!      	N	inverted !
174	Æ	<<      	N	angle quotation mark left
175	Ø	>>      	N	angle quotation mark right
176	∞	a~      	N	a tilde
177	±	o~      	N	o tilde
178	≤	O/ O|      	N	O slash
179	≥	o/ o|      	N	o slash
180	¥	oe      	Y	oe ligature
181	µ	OE Oe      	Y	OE ligature
182	∂	A`      	N	A grave
183	∑	A~      	N	A tilde
184	∏	O~      	N	O tilde
185	π	[Space] "	N	diaresis mark
186	∫	[Space] '	N
187	ª	[Space] +	N
188	º	PP pp   	N	paragraph sign
188	º	P| p| p/ P/	N	paragraph sign
189	Ω	co CO      	N	copyright sign
190	æ	ro RO      	N	registered sign
191	ø	tm TM      	N	trade mark sign
192	¿	A^      	N	A circumflex  (NVDI 3 only)
192	¡	A'      	N	A acute  (NVDI 3 only)
194	¬	E^      	N	E circumflex  (NVDI 3 only)
195	√	E" Eπ      	N	E umlaut  (NVDI 3 only)
196	ƒ	E`      	N	E grave  (NVDI 3 only)
197	≈	I^      	N	I circumflex  (NVDI 3 only)
198	∆	I" Iπ      	N	I umlaut  (NVDI 3 only)
199	«	I`      	N	I grave  (NVDI 3 only)
200	»	I'      	N	I acute  (NVDI 3 only)
201	…	O^      	N	O circumflex  (NVDI 3 only)
202	 	O`      	N	O grave  (NVDI 3 only)
203	À	O'      	N	O acute  (NVDI 3 only)
204	Ã	U^      	N	U circumflex  (NVDI 3 only)
205	Õ	U`      	N	U grave  (NVDI 3 only)
206	Œ	U'      	N	U acute  (NVDI 3 only)
207	œ	,,      	N	  (NVDI 3 only)
208	–	``      	N	  (NVDI 3 only)
209	—	''      	N	  (NVDI 3 only)
210	“	, [Space]	N	  (NVDI 3 only)
211	”	' [Space]	N	  (NVDI 3 only)
212	‘	< [Space]	N	  (NVDI 3 only)
213	’	> [Space]	N	  (NVDI 3 only)
214	÷	- [Space]	N	dash medium  (NVDI 3 only)
215	◊	_ [Space] 	N	dash long  (NVDI 3 only)
216	ÿ	Pt PT pt	Y	Peseta sign  (NVDI 3 only)
217	Ÿ	up UP      	Y	up arrow  (NVDI 3 only)
218	⁄	dn DN      	Y	down arrow  (NVDI 3 only)
219	€	rt RT      	Y	right arrow  (NVDI 3 only)
220	‹	lt LT      	Y	left arrow  (NVDI 3 only)
221	›	so SO      	Y	section sign
222	ﬁ	%o %.      	N	œpromille–  (NVDI 3 only)
223	ﬂ	oo OO      	N	infinity
224	‡	al AL      	Y	alpha
225	·	be BE      	Y	beta
226	‚	ga GA      	Y	GAMMA
227	„	pi PI      	Y	pi
228	‰	SI SS      	Y	SIGMA
229	Â	si      	Y	sigma
230	Ê	u/ u|      	N	micron
230	Ê	my MY      	Y	micron
231	Á	ta TA      	Y	tau
232	Ë	ph PH      	Y	PHI
233	È	O-      	N	THETA
233	È	th TH      	Y	THETA
234	Í	om OM      	Y	OMEGA
235	Î	de DE      	Y	delta
240		=-      	N
241	Ò	+-      	N
242	Ú	>- >_ >=	N
243	Û	<- <_ <=	N
246	ˆ	:-      	N
247	˜	=~      	N
248	¯	o [Space]	N	ring sign
249	˘	* [Space]	N
250	˙	. [Space]	N
251	˚	v [Space]	N	square root
252	¸	n [Space]	N	superscript n
253	˝	2 [Space]	N	superscript 2
254	˛	3 [Space]	N	superscript 3
255	ˇ	_ [Space]	N

+-------------------------------------------------------+
|  (c) 1995/1996 by Pascal Fellerich.                   |
+-------------------------------------------------------+

