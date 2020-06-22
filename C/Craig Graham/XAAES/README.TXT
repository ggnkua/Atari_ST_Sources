XaAES - XaAES ain't AES
½1995, Data Uncertain Software
Written By Craig Graham
--

After using MultiTOS, then AES4.1, I became frustrated at the lack of a decent
GUI to use the real power of the MiNT kernal - X-Windows is all very
well, but I cann't run GEM programs on it. MultiTOS (even AES4.1) is to slow.
Geneva didn't run with MiNT (and, having tried the new MiNT compatible version,
I can say it wasn't very compatible - at least AES4.1 is quite stable, if a 
little slow). MagiC lives in a very fast, very small world all it's own (no
networking support, few programs written to exploit it).

So I decided to write my own AES, with XaAES being the result.

The major points about XaAES are (or will be):

o It works only with MiNT - the architecture was designed to use MiNT,
  and so you must have it.
o Being written especially for MiNT, it is a real MultiTasking GUI
  that can run GEM programs, not a slow & unwieldy kludge like MultiTOS.
o The full distribution will install all the things you need - network
  drivers, MiNT kernal, MinixFS. What you get is a full all singing, all
  dancing OS replacement that can compete with the likes of Windows95 and
  OS/2. As far as possible I've made this an install & go system - the Thing
  desktop is included ready installed with programs to go, and Myriad is
  being expanded to fully support XaAES in the next release.
o Groovy sculpted 3D interface.
o Colour icon support for all machines.
o Client-Server architecture.
o No busy waiting in the AES - the GUI server blocks itself if it has nothing
  to do.
o The source is freely available. Anyone can change the code, if they send
  patches to me with descriptions I'll included them into the next version.
o Built with a 'real' C compiler (Lattice) not GNU.
o Extended fast interface for use by XaAES aware programs.
  Extended call interface allows XaAES aware applications to make AES calls
  without blocking to wait for replies they don't want, and to make multiple
  AES calls (calls to the AES server are queued).
o As it runs under MiNT, you get a fully pre-emptive system.
o Window widgets are coloured and animated, not just dull characters.
o It's free.
o More stable than Geneva (try Geneva with MiNT and you'll see).

Acknowledgments
---------------
- Steve Sowerby for the resource loader & colour icon handling code
 	(taken from the AGiLE library used in Myriad), and also for supporting
 	XaAES in the Myriad desktop.

- Chris Ridd for the Lattice C port of MiNTlibs pl46.

- Simes Harrison for invaluable advice on the low-level trap handling
	routines.

- Eric Smith for MiNT.

- Atari World magazine for the auto folder detect routine and guidelines on
	calling the VDI without the GEM AES present.

- Phil Lishman for his thoughts on how to approach various problems in the
	 window handling.

XaAES was built with Lattice C 5.52, using the MiNTlib library pl46, on
a Falcon030 4/32Mhz running MiNT 1.12h2 and AES4.1. Mouse shapes designed
using Mouse-Ka-Mania2.
