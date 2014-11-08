Hi coders (and other interested guys),

The news:

This is the release of the ucm/alive shell source. Many ppl asked me (earx)
to bugfix or improve the shell. I didn't. I hope some other coders more
motivated or talented than me, are brave enough to bugfix the thing. This
is why I decided to post the source to evl/dhs to let him put the source
online. Thanx btw Anders!

The concept:

This is a binary shell that is reusable with a menutext and loaderpic plus
some st and falcon musix and possibly an intro. The idea is to never have
to code specific stuff for each new issue. Maggie for instance also used
this idea.

The usage:

shell.prg uses startpic.pi1, menu_gfx.pi1 and menutext.txt + some music
files that are in the same directory. dshell.prg uses the data file in the
same directory. data files are made with makelink.ttp. files used in the
shells can be ice 2.4 packed. there is a data-extractor which just spits
out all data-file contents into your currect directory, so beware.

The bugs:

- the music: players are inside music data. This screws up the shell
  concept. If the playercode takes essential timers and possible restores
  them the wrong way, it bugs. To prohibit this, you'd need to get the music
  makers to make compatible player code or you'd need to modify this player
  every issue anew.
  It seems ppl want 3 chn sidvoices nowadays, which would take 3 timers.
  Timer b (hbl) is also used for the rasters. This means all 4 timers are
  used up. I heard rumours about some harddiskdrivers needing timer c free?
  Anyway, changing chipmusic too fast causes a hang.

- the pictures: in theory 3 pi1 pictures could be included in an article
  and split up into smaller fragments. I know in practice this is different.
  Many times only 2 pictures are able to be included and only very few
  fragments can be shown. Fatal bugs result when viewing the umpteenth
  fragment in an article.

- and prolly some i can't recall or don't know of..

The blah:

I got fed up with this stuff long ago. So basicly I should have released the
source way earlier. Sorry about that. I don't have much more motivation to
work on it now, due to a great girlfriend and somekind of falcon demo
I gotta complete! So I now permanently rid myself of this festering bunch
of parasitic lines of 68k code.

Stay cool stay atari,

Pieter (earx)  
