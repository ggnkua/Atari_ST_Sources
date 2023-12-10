Eiffel 1.0.8 User Scancodes Tables feature
------------------------------------------
You can use or edit/build this tables stored in .inf only if you want  
different scancodes for each key. For example, on a French PC keyboard 
you need on the '8' key: 
 Unshift: _
 Shift: 8
 AltGr: \
On A French Atari keyboard you need:
 0D scancode and Shift for _
 09 scancode and Shift for 8
 28 scancode and Alt for \
This feature works totaly with the PS/2 set 3 but only for 50 keys 
with the AT set 2 selected, with the table index of the set 3 (.inf):
 07 (F1), 0E, 0F (F2), 11, 12, 13 (><), 15 (AQ), 16 (1), 17 (F3),
 1E (2), 1F (F4), 24 (E), 25 (4), 26 (3), 27 (F5), 2E (5), 2F (F6),
 36 (6), 37 (F7), 39 (ALTGR), 3A (,M), 3D (7), 3E (8), 3F (F8),
 41 (;,), 45 (0), 46 (9), 47 (F9), 49 (:.), 4A (!/), 4C (M;), 4E ()-),
 4F (F10), 52 (—'), 53 (*\), 54 (^[), 55 (=), 56 (F11), 57 (PRTSCR),
 59, 5B ($]), 5E (F12), 5F (SCROLL), 62 (PAUSE), 65 (END), 6D (PAGEDN),
 6F (PAGEUP), 76 (VERRN), 7F (SLEEP), 80 (POWER), 81 (WAKE), 8B (WLEFT),
 8C (WRIGHT), 8E (WAPP).

Each file is a PS/2 set 3 to Atari scancode translation, excepted for 
the file 'modifier.txt' where there are just PS/2 offsets.
Offset values can be found inside \doc\ATscancodes3.txt.
Atari scancodes values can be found inside \doc\AtariKeyboard.txt.

The Unshift table is the main Eiffel table stored inside the data 
EEPROM memory. The table is also used by the AT set 2, and the 
eiffelcf keyboard page.

The Shift, AltGr, and Modifier tables are stored in the Flash program 
memory, so you must load the firmware (eiffel.hex) for change this 
tables (null bytes by default => Eiffel 1.0.6 compatibility).
Inside the Shift and ALtGr tables, a 00 entry is unused (Eiffel use 
the Unsift table), a FF entry is invalid (Eiffel not send scancode).
A special feature can send status frames for exemple if you want 
different scancodes for SHIFT F1/10 like the original atari keyboard
use scancode + 80: 
       send F6 05 00 00 00 00 00 scancode.
    or send F6 05 00 00 00 00 00 scancode+80 for break code.

The Modifier table is a bit special, because there are no scancodes but 
bits in the hexa values are used for force host SHIFT and ALT states:
 bit 7: 1 for a valid entry.
 bit 6: 1 for force CTRL.
 bit 5: ALT, bit 4: SHIFT states for the AltGR table.
 bit 3: ALT, bit 2: SHIFT states for the Shift table.
 bit 1: ALT, bit 0: SHIFT states for the Unshift table.
 
The French/German examples use different way than Default for the PAGE 
UP/DOWN  keys, the Default files send new scancodes (you need driver), 
and the French/German files force to SHIFT UP/DOWN ARROW.
German example, changed keys :
 49 PRINT SCREEN removed, used as 62 HELP.
 4C SCROLL LOCK  removed, used as 50 DOWN ARROW.
 4F PAUSE        removed, used as 61 UNDO.
 62 F11 (HELP)   removed, used as 63 (.
 61 F12 (UNDO)   removed, used as 64 ).
French example: PRINT SCREEN force to ALT HELP.
The French/German examples has also:
 END who force SHIFT HOME.
 LEFT/RIGHT WIN who force CTRL ALT TAB (MagiC).
 WIN APP who force SHIFT ALT < (Start Me Up).

If you want just use Eiffel like before, use the Init Keyboard Table 
for the data EEPROM, load eiffelcf.hex and program the flash memory.

Didier M‚quignon 
aniplay@atari.org

Thanks to Ekkehard Flessa for the German example.
