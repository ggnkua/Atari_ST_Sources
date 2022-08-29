About JXEDITOR version 0.7b (January 2003)

Note: I really ought to write a proper manual soon, but until 
then you'll have to do it whit this one. Sorry.
Also read HISTORY.TXT.

JXEDITOR is a TONE editor and library manager for the Roland 
JX8P, the MKS-70 Super JX module, and the JX-10 Super JX.


Things you have to know:
The program has two main screens: A TONE-EDIT screen, obviously 
inspired by Rolands PG-800 programmer, and a LIBRARY MANAGER 
screen.

Requirements:
I hope it will run on any Atari TOS or compatible computer, with a minimum
screen resolution of 640x400 pixels. In 640x400 B/W, JXEDITOR will have the
fastest screen redraws, in colour resolutions it's got the best looks, with
bigger screens it can handle larger libraries.

And, off coarse, you'll need a Roland JX8P or MKS-70. The JX-10 
sucks. From a SysEx point of view that is. Better find a real 
PG-800 and a M-64C cartridge for that synth. You'll need it.

Start
=====
Start the program by double-clicking on JXEDITOR.PRG or:
Drag a soundbank, tonefile, library file from the desktop to JXEDITOR.PRG or:
Install JXEDITOR.PRG as an apllication for *.JX files. Save your desktop.
After that you can start JXEDITOR.PRG by clicking on a .JX library file,
which will be loaded into JXEDITOR. This method is also possible with other
types of files that JXEDITOR can import.

The TONE-EDIT screen: (with many, many thanks to an unknown GFA basic programmer)
=====================
- Click on "PG-800" to choose JX8P or MKS-70.
- Use the mouse to change the Midi-Channel that you see right below
  "PG-800".
- After clicking on "Get Tone" you have to select a (new) "tone" on
  your JX8P/MKS-70 to force the instrument to send it's SysEx data to
  the Atari. MKS-70 mode: Left-click on "Get Tone" to get tone 
  A, right-click to get tone B.
- Use the knobs and sliders to create your own sounds. MKS-70: 
  the edits will go to the tone (A or B) that was selected with 
  "Get Tone".
- Click on tone-name to edit. Use <Esc> to clear the edit field.
- To store changed tones in your instrument permanently, hit some
  buttons on your JX/MKS. Don't ask me which, read your manual ;-)
- Left-clicking in the lowest part of the screen gives you a possibility 
  to test-play sounds without needing a keyboard (MKS-70!). A fixed value is
  used for velocity (v=70), pitch is determined by the horizontal position
  of the mouse cursor. If you use 640x480 resolution, you will see a nice
  keyboard on screen. It's not accurate enough to give concerts on though ;-)
- Edit the file "jxeditor.inf" with a text editor to customize 
  the looks of the TONE EDIT screen and some other default 
  settings to your own taste and needs.

The LIBRARY MANAGER
===================
JXEDITOR has an internal library that can hold a great number of tones.
The maximum number of tones depends on the size of the screen. For example
on a 640*400 ST screen, the maximum size of the library is 100. 
On a 640*480 VGA screen 120 tones fit in one library. If you 
want the files to be useable on a ST with 640*400 screen, limit 
your libraries to a maximum of 100 tones.

Click on the TO LIBRARY button to go to the LIBRARY MANAGER. If you haven't
stored 1+ tones in the editor yet, the HELP screen will automatically appear.
If you have you will see the stored tone(s) displayed on screen. 

Clicking on a tone will send the tone to your synth. MKS-70: 
Left-click to send to tone A, right-click to send to tone-B. 
Also the selection is important for manager functions like 
delete, save, and export tone.

Clicking on the MKS70/JX10 patchlist (if there is any) switches 
to patch managing mode. With a similar action you return to the 
tonemanager mode.

Drag and drop tones or patches to copy or swap using the mouse.

The HELP key is your friend: it will introduce you to JXEDITORS powerful
library functions that can be selected with a mouseclick. Use it a lot.

Some things you can do:
- Import several JX-10P, MKS-70, or JX-8P tones or tonebanks, in several different 
  formats into the Library. No need to specify the format first. Just 
  try to load the file and you will see if JXEDITOR can handle it.
- Try all these sounds on your JX-8P or MKS-70. It doesn't matter if the original
  bank came from a JX-8P and you want to try it on your MKS-70 or vice versa.
- Save the complete Library or a single tone as one file
- Export the library to a JX-8P, MKS-70, JX10 compatible SysEx 
  file that can be handled by most SysEx dump utilities, also on 
  other platforms (Mac, PC etc.)
- If 64 patches are shown on screen, it means that the most 
  recently loaded file contained MKS70/JX10 patchdata. It also 
  means that the library can be exported as a JX10/MKS70 
  bulkdump with tones AND patches.
- Click anywhere on the list with patchnames (small font) to view
  the list in full size. The tones are then displayed with a small
  font. Click on the small tonelist brings you back to the original
  displaymode.
- You can sort the tone library in alphabetical order. Warning: 
  the corresponding parameters in the patchdata (MKS-70/JX-10) 
  will not change.   This may create interesting new patches ... 
  if that's what you really want ;)
- There is also a Universal SysEx dump function to get and save
  any SysEx data, with the option to import these data into the 
  library. JXEDITOR's dump-receive routine doesn't exit or time-out
  automatically. This gives you plenty of time to find the right
  buttons on your synth. I recommend however to prepare your synth
  to make a dump before selecting this function. Many buttons on 
  your synth may cause SysEx messages to be sent. All these
  messages will be fetched, even if you don't want them. 
- JX8P: Select all 32 tone buttons on the JX8P in a row to make 
  a dump of the complete bank. Select another tone than tone number
  #1 before activating the dump utility. It's also possible to make
  a partial dump with only a few tones in it. You can decide for
  yourself if and when the dump is complete.
- MKS-70: To send a dump from the MKS-70 follow these steps:
  a) Press the "WRITE" and "MIDI" buttons simultaneously
  b) Rotate the alpha dial until the display says "MIDI BULK DUMP"
  c) Press the "ENTER" button to send the dump.
- JX-10: You can only get the memory from a M-64C cartridge.
  Select the special JX-10 mode in JXEDITOR's dump utility.
  Follow the same steps as described for the MKS-70 (a, b, c)
  If the dump is received but not complete, or corrupted:
  Try again, JXEDITOR does not check the incoming data and only
  sends "Acknowledge (ACK)" messages ;-)
- When using option F10 to transmit the library via MIDI, a time 
  interval can be set to let the program wait between every 
  SysEx packet in the dump. Experiment to find the smallest 
  value that that your synth can handle without errors. For the 
  JX-8P I have heard people mention values between 400 and 600 
  ms, for the MKS-70 something like 300 ms. The JX-10 uses a
  handshake communication protocol (it talks back between the
  packets of the dump). A simple bulkdumper, like in JXEDITOR,
  doesn't really support this protocol. But by setting an 
  appropiate time interval you can at least give the JX10 time
  to respond with an "Acknowledge" message between the packets.
  What if it responds with "Error" or "Rejection" ? JXEDITOR 
  will not know, and will simply finish the complete dump.
- Data can be saved in JXEDITOR's own library format, as pure
  System Exclusive data, or as Standard Midi File. The SMF format
  will automatically be used if you enter a filename with the
  extension ".MID" in your fileselector when saving as SysEx.
- hitting <p> will print out a list of the patches and tones 
  to paper.
- Print out a list of the tones and patches in the library by 
  hitting <p>.

To return to the TONE EDIT screen hit <Esc> or <q>


Download the latest version of JXEDITOR from:
http://www.home.zonnet.nl/m.tarenskeen/jxeditor.htm

Martin Tarenskeen
m.tarenskeen@zonnet.nl

