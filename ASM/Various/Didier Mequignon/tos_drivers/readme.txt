This is the second release of TOS drivers (V1.01).

A great HYP documentation in english is inside doc\CTPCI.HYP, thanks 
to Sascha Uhlig.

Radeon driver works on all tested targets (CTPCI/M5484LITE/M5485EVB/FIREBEE).
Clocks over 135 MHz have heat isues with DVI on RV100 (Radeon 7000 
boards), high modes are rejected.

Coldfire drivers now are compiled with GCC 4 for the v4e.
Coldfire targets are always in progress, for more information see 
doc\coldfire.readme.


CT60/CTPCI:
===========
For update drivers load drivers\drivers.hex with FLASH060 from the 
TOS060 archive at http://ct60conf.atari.org
If you reload ct60tos.bin, you must reload drivers.hex, else you can 
use only boot.hex and drivers.hex for update each part.
There are a driver for fVDI: drivers\radeon.sys

Hardware CTPCI bugs list:
-------------------------
- PCI 33MHz boards not works, for example USB generic NEC board
  go to "unrecoverable PCI error" and set "Parity error".
  => use only graphics boards who are 33/66 MHz compatible (more 
  signal tolerance).
- Interrupts not works, to confirm (maybe the real cause is the first 
  problem). Local interrupts can't work.
- DMA writing sometimes freeze the system (easy to create with 
  MagiC/NVDI real time moving window.
  => disable DMA with CT650CONF.CPX.
- DMA reading crashes the system (not used actually).
- Bus mastering for works for same reason.
- PCI arbitration not works, for example if you want use Video RAM 
  with USB board (maybe the real cause is the first problem).

So actually the best is to install ONLY the Radeon board.


M5484LITE:
==========
Ethernet works (need dBUG settings).
USB NEC OHCI/EHCI boards drivers:
- Mouse and keyboard works fine.
- Mass Storage return timeout, sometimes works a little bit (worse 
with EHCI), the cause sems the PCI BUS at 50 MHz, the NEC chip is 
for PCI at 33 MHz.


M5485EVB:
=========
Lynx and RTC drivers not works.


FIREBEE:
========
For update drivers load drivers\drivers_firebee.hex with FLASH060 
from the TOS060 at http://ct60conf.atari.org
There are a native Coldfire driver for fVDI (untested with the 
CF68KLIB): drivers\radeon_f.sys
Ethernet works (need dBUG or CPX settings).
USB mouse and keyboard works (OHCI & EHCI NEC drivers).
Videl ACP extended modes with EDID detection works else if a Radeon 
board is found on the PCI the Radeon driver replace the Videl (who 
has no hardware acceleration).
AC97 works (GSXB XBIOS compatible) and has STE DMA emulation.

Hardware FIREBEE bugs list:
---------------------------
- Floppy writing not works with the default TOS404 routines (AJAX 
controller), mabe a driver for try to fix the problem in the future, 
the FPGA emulation in theory is ST compatible => use SD-Card.
- DVI-I HSYNC problem => try with another monitor.
- Power supply / voltage on-board problems (3V3 bad value and not 
enough power on 5V) => try with another adapter.
- PCI voltage jumpers (5V), you can't move it to 5V PCI.
- Sound input noise (5V).
- Atari Serial characters lost => use Highspeed Serial (SERIAL 2).
- Audio codec reset (impossible use the codec a 2nd time without reset 
all the board) => replace BAS by dBUG.
- IDE read ramdom first data read lost (normally fixed by software 
with comparison and retry loop).
- USB troubles with PCI when there are lot of transfers (high speed 
devices) => plug a Radeon board on the PCI bus. 
Some bugs like Floppy can be fixed by an FPGA update.
Maybe some bugs has software issues.


Didier MEQUIGNON

aniplay@wanadoo.fr
