aVNCServ - Atari VNC Server
===========================

Features:

Uses LibVNCServer 0.9.9, with changes inside main.c for create rbf.log in the same directory than aVNCServ instead stderr.
Need MiNT 1.16 (see below), MagiC and TOS can't work because LibVNCServer need socket interface.
For args use -help (for example for set password).
Atari release infos frombthe file fbvncserver.c :
- Mouse events injected to XBIOS with MOUSEVEC.
- Undocumented KBDVEC used for send keyboard scancodes to XBIOS, inside MiNT and acia.c, OZK created a regression since 2007 with this vector removed (now not compatible with TOS 4.04), this is the workaround :
  * Use MiNT 1.16.
  * Use a CT60/CTPCI (drivers >= 1.02) or a Firebee, the XBIOS try to patch MiNT using XBRA for install MiNT ikbd_scan routine as KBDVEC handler. You must plug an USB keyboard and press a key before start the VNC for install the patch.
  * Rebuild MiNT with NO_AKP_KEYBOARD.
  * Wait a fix inside MiNT, for more info :
  http://sparemint.atariforge.net/cgi-bin/cvsweb/freemint/sys/arch/acia.S.diff?r1=1.4&r2=1.5
- English / French / German keyboard tables VNC to Atari scancodes translation.
- Extended Vsetscreen (CTPCI / Milan / Supervidel) used for get screen infos, VDI and AES not used.
- Basic test for try to install a VNC cursor for graphic cards (because cursor displayed on screen by hardware).
- Works in 65K or 16M colors (32 bits) big endian.
- Screen comparison test with a pixel on two for fastest answer inside blocks 32x32.
- Coldfire v4e version not linked with native libs (jpeg, png, z, pthread, and socket).

Note: If your AES change the screen, you must start aVNCServer with the AES.

 