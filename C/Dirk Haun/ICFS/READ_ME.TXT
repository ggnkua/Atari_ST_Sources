ICFS - What's that?                                      June 13, 1994

Since  version  1.07,  Atari's  MultiTOS  has  a  new feature,  called
"iconify".  It  means that you can shrink a window down to the size of
an icon  (hence the name).  A very useful feature since it enables you
to  get  windows  out of the way if you don't need the program  (which
they belong to) at the moment.  With a click on such a shrunk window
it regains it's original size and place.

Unfortunately,  all  MultiTOS  versions  having  this feature are not
available  for  the general public at this moment in time.  Apart from
that,  it would be nice to have this feature with SingleTOS and Mag!X,
too.  It  would  be no problem,  implementing a similar solution in an
application. But if more than one program does this, the placing of the
shrunken windows must be coordinated between them - and that's exactly
what ICFS does (ICFS stands for "IConiFy Server").

MultiTOS  places the shrunken windows on the lower edge of the screen,
starting in the lower left corner, going left to right and up. This is
therefore the default method used by ICFS. Use ICFS.CPX to change this
behaviour.


Installation

Copy ICFS.PRG into your AUTO folder and reboot. That's all.

ICFS  installs  a cookie,  with which programs can get a position for
their  shrunken  windows.  ICFS  does not allocate any processor time
since  it  is not installed in any traps or vectors.  The use of ICFS
should  not  cause  any problems since it is only called by programs
which are aware of it.


How do I use this?

To iconify a window, click on the window's closer and hold down one of
the following keys:

  [Alternate] - shrink a single window
  [Control]   - shrink all windows to one
  [Shift]     - shrink all windows, one by one

This must be supported by the program, otherwise it won't work!


Which programs support ICFS?

At  this  moment  in  time the following programs support ICFS  (as of
June 13, 1994; please connect me if you have any corrections).

  program      version    type           author
 ---------------------------------------------------------------
  Chatwin      3.01       shell          Dirk Haun @ WI2
  IconMan      0.63       icon utility   Dirk Haun @ WI2
  Kandinsky    1.69       drawing prg.   Ulrich Rossgoderer @ M
  ObjectGEM    1.11       PP lib         Thomas Much @ KA2
  SysGEM       1.10       PC/PP lib      Andreas Pietsch @ WI2
  SysInfo      2.10       system info    Thorsten Bergner @ B
  Windoze      PL 0       PC lib         Dirk Haun @ WI2
  XAcc-Spy     25.03.94   XACC utility   Thomas Much @ KA2
  Yukon        Rel. D     cards game     Dirk Haun @ WI2
  Zeig's mir   0.22       file viewer    Reiner Rosin @ WI2
 ---------------------------------------------------------------
  (PC: Pure C, PP: Pure Pascal; e-mail adresses: MausNet)


Who's responsible for all this?

Nobody, since you use this software  (as any other)  at your own risk.
The original idea however is by

     Rosin Datentechnik
     Reiner Rosin
     Peter-Spahn-Str. 4
     D-65375 Oestrich-Winkel
     Germany
     Telefon 06723 4978  Fax 7190

     email Reiner Rosin @ WI2 (MausNet) / Reiner_Rosin@wi2.maus.de

whereas the program ICFS and this text were written by

     Dirk Haun
     Europastr. 8
     D-64569 Nauheim
     Germany

     e-mail: Dirk Haun @ WI2 (MausNet)


ICFS  is  freeware.  You  are  allowed  to  include ICFS into your own
software.  If  you  only  include part of the package please make sure
that this includes at least ICFS.PRG and ICFS.TXT.
