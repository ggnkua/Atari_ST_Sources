Short Description of this Firenews Package.

Included are:
  - The program (with resource-file)

Setup:

Select the paths:entry in the setup menu (or press SHIFT-ALT-P) Here you should 
select the news-directory in which your activefile lies (and the newsgroups is)
ie the NEWS dir in this package. You should also set the editor of your choice 
(Everest, Qed, etc)
If you would like to reply via e-mail you should have 3 options to choose from
1: Antmail - Select the default.set that you are using.
2: Newsie - Select the outbox.mbx file that you are using.
3: infitra - Select where the QUEUE\mail.idx file that your infitra-account are 
   using for sending files in.
You can also select where babel is, and finally if you want to have an signature 
file, you should select that also. To select a File/Path you should double-click 
on the text, and select it via the fileselector that pops up.

After you have setup the files/paths, you should setup the user-settings.
Hopefully these settings ARE self-explained, but I'll do a litle explenation
anyway. (I use myself as example)
Name: your name (Christian Andersson)
E-mail: Your e-mail adress (faltrion@bigfoot.com) (Here you have 2 lines to write 
  it on)
Reply-to: This is the adress that you want all replys to be sent to, you should 
  only need to fill in this IF it is different from the e-mail adress.
  (faltrion@bigfoot.com)
Organization: this is to be filled in if you are working for someone, and you 
want your e-mails/news messages to be associated to it. Or if you are within
any other group that you want to be associated with. (FireSTorm Atari Center)

When you have done this you should save the info you have just entered with the 
menu-entry save setup (SHIFT-ALT-S)

Now you should be able to test FireNews as much as you like.

Some things regarding this version.
The font-selection  does not show what size of the font that you have chosen.

You should be able to use the sliders in ALL windows that has those, but you 
should be aware that the sliders in the list-windows works differently from the 
sliders in the text-windows. Instead of scrolling the page it just selects a new 
list-entry, and scroll only if needed. Also, The Horisontal sliders are 
non-working.

Short-cuts.
CTRL-A - Opens the Subscribed news-groups lists.
CTRL-L - Opens the Newsgroup message list.

The list-windows are used as follows.
UP         - Move the selection 1 line up.
DOWN       - Move the selection 1 line down.
SHIFT_UP   - Move the selection 1 page up.
SHIFT-DOWN - Move the selection 1 page down.
HOME       - Move the selection to the first line.
SHIFT-HOME - Move the selection to the last line.
RETURN     - Selects the current selection to be the "active one".

The message-window.
UP         - scroll the page 1 line up.
DOWN       - scroll the page 1 line down.
LEFT       - go to the next message. (DOWN+RETURN in the message-list window)
RIGHT      - go to the previous message. (UP+RETURN in the message-list window)
SHIFT-UP   - scroll 1 page up.
SHIFT-DOWN - scroll 1 page down.
HOME       - scroll to top of text.
SHIFT-HOME - scroll to bottom of text.


If you have any problems with fireNews, ie it crashes, it behaves strangely, 
etc.
PLEASE run FireNews with the command string "-log" (you can do this by changeing 
the programname to firenews.gtp and then write -log after you have double 
clicked on it)
This will produce an firenews.log file that could be helpful for me.
If you are certain that you know what part of the problem, it is possible to tell 
FireNews only to log certain parts, instead if logging everything.
this is done by writing -log ABCDE... where ABCDE... is replaced by the 
following characters.

F - File operations.
M - Memory handling.
W - Window handling.
E - Certain error-messages.
I - Initialisation procedures.
A - Aes messages.
D - Dialog handling

so "firenews.prg -log FM" will make it log only file-operations and memory 
handling.

Have fun :)

Christian Andersson
faltrion@bigfoot.com