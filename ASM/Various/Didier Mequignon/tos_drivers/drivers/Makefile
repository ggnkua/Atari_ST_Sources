### 68060 - GCC 3.3 ###
CC = gcc
### Coldfire - GCC 4.4 ###
CCF = /home/usr/local/bin/m68k-atari-mint-gcc
LD = ld
STRIP = strip
STACK =	stack
rm = rm

VERSION = 0x0101

ATICOD = ../nonfree/ativcm20.cod

SRCDIR = ./
INCDIR = ./include
INCDIRFVDI = ./fvdi/include
OBJDIR = ./obj
OBJDIRCF = ./obj_cf
OBJDIRCF2 = ./obj_cf2
OBJDIRCF3 = ./obj_cf3

SUBOBJDIRS=	\
		$(OBJDIR)/tools \
		$(OBJDIR)/radeon \
		$(OBJDIR)/video \
		$(OBJDIR)/emulator \
		$(OBJDIR)/emulator/pcbios \
		$(OBJDIR)/emulator/x86emu \
		$(OBJDIR)/fvdi \
		$(OBJDIR)/fvdi/common \
		$(OBJDIR)/fvdi/1_plane \
		$(OBJDIR)/dma_utils \
		$(OBJDIR)/usb

SUBOBJDIRSCF=	\
		$(OBJDIR)/tools \
		$(OBJDIRCF)/radeon \
		$(OBJDIRCF)/lynx \
		$(OBJDIRCF)/video \
		$(OBJDIRCF)/emulator \
		$(OBJDIRCF)/emulator/pcbios \
		$(OBJDIRCF)/emulator/x86emu \
		$(OBJDIRCF)/fvdi \
		$(OBJDIRCF)/fvdi/common \
		$(OBJDIRCF)/mcdapi \
		$(OBJDIRCF)/dma_utils \
		$(OBJDIRCF)/net \
		$(OBJDIRCF)/lwip \
		$(OBJDIRCF)/usb_dev \
		$(OBJDIRCF)/usb \
		$(OBJDIRCF)/ac97 \
		$(OBJDIRCF)/rtc \
		$(OBJDIRCF)/bdos \
		$(OBJDIRCF)/freertos

SUBOBJDIRSCF2=	\
		$(OBJDIR)/tools \
		$(OBJDIRCF2)/radeon \
		$(OBJDIRCF2)/video \
		$(OBJDIRCF2)/emulator \
		$(OBJDIRCF2)/emulator/pcbios \
		$(OBJDIRCF2)/emulator/x86emu \
		$(OBJDIRCF2)/fvdi \
		$(OBJDIRCF2)/fvdi/common \
		$(OBJDIRCF2)/dma_utils \
		$(OBJDIRCF2)/net \
		$(OBJDIRCF2)/lwip \
		$(OBJDIRCF2)/usb \
		$(OBJDIRCF2)/bdos \
		$(OBJDIRCF2)/freertos
		
SUBOBJDIRSCF3=	\
		$(OBJDIR)/tools \
		$(OBJDIRCF3)/radeon \
		$(OBJDIRCF3)/video \
		$(OBJDIRCF3)/emulator \
		$(OBJDIRCF3)/emulator/pcbios \
		$(OBJDIRCF3)/emulator/x86emu \
		$(OBJDIRCF3)/fvdi \
		$(OBJDIRCF3)/fvdi/common \
		$(OBJDIRCF3)/mcdapi \
		$(OBJDIRCF3)/dma_utils \
		$(OBJDIRCF3)/net \
		$(OBJDIRCF3)/lwip \
		$(OBJDIRCF3)/usb \
		$(OBJDIRCF3)/ac97 \
		$(OBJDIRCF3)/bdos \
		$(OBJDIRCF3)/freertos

INCLUDE = -I$(INCDIR)
INCLUDEFVDI = -I$(INCDIRFVDI)
INCLUDEUSB = -I$(INCDIRUSB)
CFLAGS = -m68060 -Os -fno-builtin -fomit-frame-pointer -Wall -Wno-multichar -g
### Coldfire - GCC 3.3 ###
#CFLAGSCF = -m5200 -Os -fno-builtin -fomit-frame-pointer -Wall -Wno-multichar -g -Wa,-m5200 -DCOLDFIRE
### Coldfire - GCC 4.4 ###
CFLAGSCF = -mcfv4e -Os -fno-builtin -fomit-frame-pointer -fno-strict-aliasing -fno-inline-small-functions -Wall -Wno-multichar -g -DCOLDFIRE
CFLAGSCF2 = $(CFLAGSCF) -DMCF5445X
CFLAGSCF3 = $(CFLAGSCF) -DMCF547X
LDFLAGS = -nostdlib -s

OBJSDRIVERFVDI=	\
		$(OBJDIR)/radeon/radeon_accel.o \
		$(OBJDIR)/radeon/radeon_render.o \
		$(OBJDIR)/radeon/radeon_pm.o \
		$(OBJDIR)/radeon/radeon_monitor.o \
		$(OBJDIR)/radeon/radeon_i2c.o \
		$(OBJDIR)/radeon/radeon_cursor.o \
		$(OBJDIR)/video/i2c-algo-bit.o \
		$(OBJDIR)/video/modedb.o \
		$(OBJDIR)/video/fbmem.o \
		$(OBJDIR)/video/fbmon.o \
		$(OBJDIR)/video/offscreen.o \
		$(OBJDIR)/video/1b_pal.o \
		$(OBJDIR)/video/8b_pal.o \
		$(OBJDIR)/video/16b_pal.o \
		$(OBJDIR)/video/32b_pal.o \
		$(OBJDIR)/video/access.o \
		$(OBJDIR)/video/debug.o \
		$(OBJDIR)/video/mouse.o \
		$(OBJDIR)/fvdi/common/init.o \
		$(OBJDIR)/fvdi/common/common.o \
		$(OBJDIR)/fvdi/common/c_common.o \
		$(OBJDIR)/fvdi/common/clip.o \
		$(OBJDIR)/fvdi/common/lineachk.o \
		$(OBJDIR)/fvdi/common/colours.o \
		$(OBJDIR)/fvdi/common/falc_pal.o \
		$(OBJDIR)/fvdi/1_plane/1_line.o \
		$(OBJDIR)/fvdi/1_plane/1_fill.o \
		$(OBJDIR)/timer.o \
		$(OBJDIR)/gcc.o

OBJSDRIVERFVDICF=	\
		$(OBJDIRCF)/radeon/radeon_accel.o \
		$(OBJDIRCF)/radeon/radeon_render.o \
		$(OBJDIRCF)/radeon/radeon_pm.o \
		$(OBJDIRCF)/radeon/radeon_monitor.o \
		$(OBJDIRCF)/radeon/radeon_i2c.o \
		$(OBJDIRCF)/radeon/radeon_cursor.o \
		$(OBJDIRCF)/video/i2c-algo-bit.o \
		$(OBJDIRCF)/video/modedb.o \
		$(OBJDIRCF)/video/fbmem.o \
		$(OBJDIRCF)/video/fbmon.o \
		$(OBJDIRCF)/video/offscreen.o \
		$(OBJDIRCF)/video/8b_pal.o \
		$(OBJDIRCF)/video/16b_pal.o \
		$(OBJDIRCF)/video/32b_pal.o \
		$(OBJDIRCF)/video/access.o \
		$(OBJDIRCF)/video/debug.o \
		$(OBJDIRCF)/video/mouse.o \
		$(OBJDIRCF)/fvdi/common/init.o \
		$(OBJDIRCF)/fvdi/common/common.o \
		$(OBJDIRCF)/fvdi/common/clip.o \
		$(OBJDIRCF)/fvdi/common/lineachk.o \
		$(OBJDIRCF)/fvdi/common/colours.o \
		$(OBJDIRCF)/fvdi/common/falc_pal.o \
		$(OBJDIRCF)/gcc.o
		
OBJSDRIVERFVDICF2=	\
		$(OBJDIRCF2)/radeon/radeon_accel.o \
		$(OBJDIRCF)/radeon/radeon_pm.o \
		$(OBJDIRCF)/radeon/radeon_monitor.o \
		$(OBJDIRCF)/radeon/radeon_i2c.o \
		$(OBJDIRCF)/radeon/radeon_cursor.o \
		$(OBJDIRCF)/video/i2c-algo-bit.o \
		$(OBJDIRCF)/video/modedb.o \
		$(OBJDIRCF)/video/fbmem.o \
		$(OBJDIRCF)/video/fbmon.o \
		$(OBJDIRCF)/video/offscreen.o \
		$(OBJDIRCF)/video/8b_pal.o \
		$(OBJDIRCF)/video/16b_pal.o \
		$(OBJDIRCF)/video/32b_pal.o \
		$(OBJDIRCF)/video/access.o \
		$(OBJDIRCF2)/video/debug.o \
		$(OBJDIRCF)/video/mouse.o \
		$(OBJDIRCF)/fvdi/common/init.o \
		$(OBJDIRCF)/fvdi/common/common.o \
		$(OBJDIRCF)/fvdi/common/clip.o \
		$(OBJDIRCF)/fvdi/common/lineachk.o \
		$(OBJDIRCF)/fvdi/common/colours.o \
		$(OBJDIRCF)/fvdi/common/falc_pal.o \
		$(OBJDIRCF2)/gcc.o

OBJSDRIVERFVDICF3=	\
		$(OBJDIRCF)/radeon/radeon_accel.o \
		$(OBJDIRCF)/radeon/radeon_render.o \
		$(OBJDIRCF)/radeon/radeon_pm.o \
		$(OBJDIRCF)/radeon/radeon_monitor.o \
		$(OBJDIRCF)/radeon/radeon_i2c.o \
		$(OBJDIRCF)/radeon/radeon_cursor.o \
		$(OBJDIRCF)/video/i2c-algo-bit.o \
		$(OBJDIRCF)/video/modedb.o \
		$(OBJDIRCF)/video/fbmem.o \
		$(OBJDIRCF)/video/fbmon.o \
		$(OBJDIRCF)/video/offscreen.o \
		$(OBJDIRCF)/video/8b_pal.o \
		$(OBJDIRCF)/video/16b_pal.o \
		$(OBJDIRCF)/video/32b_pal.o \
		$(OBJDIRCF)/video/access.o \
		$(OBJDIRCF)/video/debug.o \
		$(OBJDIRCF)/video/mouse.o \
		$(OBJDIRCF)/fvdi/common/init.o \
		$(OBJDIRCF)/fvdi/common/common.o \
		$(OBJDIRCF)/fvdi/common/clip.o \
		$(OBJDIRCF)/fvdi/common/lineachk.o \
		$(OBJDIRCF)/fvdi/common/colours.o \
		$(OBJDIRCF)/fvdi/common/falc_pal.o \
		$(OBJDIRCF)/gcc.o

OBJSNETCF=	\
		$(OBJDIRCF)/net/tftp.o \
		$(OBJDIRCF)/net/ip.o \
		$(OBJDIRCF)/net/arp.o \
		$(OBJDIRCF)/net/icmp.o \
		$(OBJDIRCF)/net/udp.o \
		$(OBJDIRCF)/net/net_timer.o \
		$(OBJDIRCF)/net/queue.o \
		$(OBJDIRCF)/net/nbuf.o \
		$(OBJDIRCF)/net/nif.o \
		$(OBJDIRCF)/net/fec.o \
		$(OBJDIRCF)/net/fecbd.o \
		$(OBJDIRCF)/net/bcm5222.o \
		$(OBJDIRCF)/net/init.o

OBJSNETCF2=	\
		$(OBJDIRCF2)/net/tftp.o \
		$(OBJDIRCF2)/net/ip.o \
		$(OBJDIRCF2)/net/arp.o \
		$(OBJDIRCF2)/net/icmp.o \
		$(OBJDIRCF2)/net/udp.o \
		$(OBJDIRCF2)/net/net_timer.o \
		$(OBJDIRCF2)/net/queue.o \
		$(OBJDIRCF2)/net/nbuf.o \
		$(OBJDIRCF2)/net/nif.o \
		$(OBJDIRCF2)/net/fec.o \
		$(OBJDIRCF2)/net/fecbd.o \
		$(OBJDIRCF2)/net/init.o

OBJSNETCF3=	\
		$(OBJDIRCF)/net/tftp.o \
		$(OBJDIRCF)/net/ip.o \
		$(OBJDIRCF)/net/arp.o \
		$(OBJDIRCF)/net/icmp.o \
		$(OBJDIRCF)/net/udp.o \
		$(OBJDIRCF)/net/net_timer.o \
		$(OBJDIRCF)/net/queue.o \
		$(OBJDIRCF)/net/nbuf.o \
		$(OBJDIRCF)/net/nif.o \
		$(OBJDIRCF3)/net/fec.o \
		$(OBJDIRCF3)/net/fecbd.o \
		$(OBJDIRCF3)/net/am79c874.o \
		$(OBJDIRCF3)/net/init.o
		
		
OBJSLWIPCF=	\
		$(OBJDIRCF)/lwip/tcp_out.o \
		$(OBJDIRCF)/lwip/inet.o \
		$(OBJDIRCF)/lwip/chksum.o \
		$(OBJDIRCF)/lwip/mem.o \
		$(OBJDIRCF)/lwip/memp.o \
		$(OBJDIRCF)/lwip/netif.o \
		$(OBJDIRCF)/lwip/pbuf.o \
		$(OBJDIRCF)/lwip/raw.o \
		$(OBJDIRCF)/lwip/stats.o \
		$(OBJDIRCF)/lwip/sys.o \
		$(OBJDIRCF)/lwip/tcp.o \
		$(OBJDIRCF)/lwip/tcp_in.o \
		$(OBJDIRCF)/lwip/udp.o \
		$(OBJDIRCF)/lwip/ip.o \
		$(OBJDIRCF)/lwip/ip_addr.o \
		$(OBJDIRCF)/lwip/icmp.o \
		$(OBJDIRCF)/lwip/ip_frag.o \
		$(OBJDIRCF)/lwip/tcpip.o \
		$(OBJDIRCF)/lwip/api_msg.o \
		$(OBJDIRCF)/lwip/err.o \
		$(OBJDIRCF)/lwip/api_lib.o \
		$(OBJDIRCF)/lwip/loopif.o \
		$(OBJDIRCF)/lwip/sockets.o \
		$(OBJDIRCF)/lwip/etharp.o \
		$(OBJDIRCF)/lwip/resolv.o \
		$(OBJDIRCF)/lwip/sys_arch.o \
		$(OBJDIRCF)/lwip/nbuf.o \
		$(OBJDIRCF)/lwip/fec.o \
		$(OBJDIRCF)/lwip/bcm5222.o \
		$(OBJDIRCF)/lwip/gs_func.o \
		$(OBJDIRCF)/lwip/gs_mem.o \
		$(OBJDIRCF)/lwip/gs_stik.o \
		$(OBJDIRCF)/lwip/intel_c3_flash.o \
		$(OBJDIRCF)/lwip/tftp.o \
		$(OBJDIRCF)/lwip/ftpd.o \
		$(OBJDIRCF)/lwip/web.o \
		$(OBJDIRCF)/lwip/gif.o \
		$(OBJDIRCF)/lwip/init.o \
		$(OBJDIRCF)/dma_utils/dma_utils.o \
		$(OBJDIRCF)/mcdapi/MCD_dmaApi.o \
		$(OBJDIRCF)/mcdapi/MCD_tasksInit.o \
		$(OBJDIRCF)/mcdapi/MCD_tasks.o \
		$(OBJDIRCF)/bdos/bdos.o \
		$(OBJDIRCF)/usb_dev/msc.o \
		$(OBJDIRCF)/usb_dev/msc_desc.o \
		$(OBJDIRCF)/usb_dev/usb.o \
		$(OBJDIRCF)/stdlib.o \
		$(OBJDIRCF)/printk.o

OBJSLWIPCF2=	\
		$(OBJDIRCF)/lwip/tcp_out.o \
		$(OBJDIRCF)/lwip/inet.o \
		$(OBJDIRCF)/lwip/chksum.o \
		$(OBJDIRCF)/lwip/mem.o \
		$(OBJDIRCF)/lwip/memp.o \
		$(OBJDIRCF)/lwip/netif.o \
		$(OBJDIRCF2)/lwip/pbuf.o \
		$(OBJDIRCF)/lwip/raw.o \
		$(OBJDIRCF)/lwip/stats.o \
		$(OBJDIRCF)/lwip/sys.o \
		$(OBJDIRCF)/lwip/tcp.o \
		$(OBJDIRCF2)/lwip/tcp_in.o \
		$(OBJDIRCF2)/lwip/udp.o \
		$(OBJDIRCF2)/lwip/ip.o \
		$(OBJDIRCF)/lwip/ip_addr.o \
		$(OBJDIRCF)/lwip/icmp.o \
		$(OBJDIRCF)/lwip/ip_frag.o \
		$(OBJDIRCF)/lwip/tcpip.o \
		$(OBJDIRCF)/lwip/api_msg.o \
		$(OBJDIRCF)/lwip/err.o \
		$(OBJDIRCF)/lwip/api_lib.o \
		$(OBJDIRCF)/lwip/loopif.o \
		$(OBJDIRCF)/lwip/sockets.o \
		$(OBJDIRCF)/lwip/etharp.o \
		$(OBJDIRCF)/lwip/resolv.o \
		$(OBJDIRCF2)/lwip/sys_arch.o \
		$(OBJDIRCF2)/lwip/nbuf.o \
		$(OBJDIRCF2)/lwip/fec.o \
		$(OBJDIRCF2)/lwip/dp83849.o \
		$(OBJDIRCF)/lwip/gs_func.o \
		$(OBJDIRCF)/lwip/gs_mem.o \
		$(OBJDIRCF)/lwip/gs_stik.o \
		$(OBJDIRCF2)/lwip/flash.o \
		$(OBJDIRCF)/lwip/tftp.o \
		$(OBJDIRCF)/lwip/ftpd.o \
		$(OBJDIRCF2)/lwip/web.o \
		$(OBJDIRCF)/lwip/gif.o \
		$(OBJDIRCF2)/lwip/init.o \
		$(OBJDIRCF2)/dma_utils/dma_utils.o \
		$(OBJDIRCF)/bdos/bdos.o \
		$(OBJDIRCF2)/stdlib.o \
		$(OBJDIRCF)/printk.o

OBJSLWIPCF3=	\
		$(OBJDIRCF)/lwip/tcp_out.o \
		$(OBJDIRCF)/lwip/inet.o \
		$(OBJDIRCF)/lwip/chksum.o \
		$(OBJDIRCF)/lwip/mem.o \
		$(OBJDIRCF)/lwip/memp.o \
		$(OBJDIRCF)/lwip/netif.o \
		$(OBJDIRCF3)/lwip/pbuf.o \
		$(OBJDIRCF)/lwip/raw.o \
		$(OBJDIRCF)/lwip/stats.o \
		$(OBJDIRCF)/lwip/sys.o \
		$(OBJDIRCF)/lwip/tcp.o \
		$(OBJDIRCF3)/lwip/tcp_in.o \
		$(OBJDIRCF3)/lwip/udp.o \
		$(OBJDIRCF3)/lwip/ip.o \
		$(OBJDIRCF)/lwip/ip_addr.o \
		$(OBJDIRCF)/lwip/icmp.o \
		$(OBJDIRCF)/lwip/ip_frag.o \
		$(OBJDIRCF)/lwip/tcpip.o \
		$(OBJDIRCF)/lwip/api_msg.o \
		$(OBJDIRCF)/lwip/err.o \
		$(OBJDIRCF)/lwip/api_lib.o \
		$(OBJDIRCF)/lwip/loopif.o \
		$(OBJDIRCF)/lwip/sockets.o \
		$(OBJDIRCF)/lwip/etharp.o \
		$(OBJDIRCF)/lwip/resolv.o \
		$(OBJDIRCF3)/lwip/sys_arch.o \
		$(OBJDIRCF3)/lwip/nbuf.o \
		$(OBJDIRCF3)/lwip/fec.o \
		$(OBJDIRCF3)/lwip/am79c874.o \
		$(OBJDIRCF)/lwip/gs_func.o \
		$(OBJDIRCF)/lwip/gs_mem.o \
		$(OBJDIRCF)/lwip/gs_stik.o \
		$(OBJDIRCF3)/lwip/amd_flash.o \
		$(OBJDIRCF)/lwip/tftp.o \
		$(OBJDIRCF)/lwip/ftpd.o \
		$(OBJDIRCF3)/lwip/web.o \
		$(OBJDIRCF)/lwip/gif.o \
		$(OBJDIRCF3)/lwip/init.o \
		$(OBJDIRCF3)/dma_utils/dma_utils.o \
		$(OBJDIRCF)/mcdapi/MCD_dmaApi.o \
		$(OBJDIRCF)/mcdapi/MCD_tasksInit.o \
		$(OBJDIRCF)/mcdapi/MCD_tasks.o \
		$(OBJDIRCF)/bdos/bdos.o \
		$(OBJDIRCF)/stdlib.o \
		$(OBJDIRCF)/printk.o

OBJSUSB=	\
		$(OBJDIR)/usb/usb.o \
		$(OBJDIR)/usb/ohci-hcd.o \
		$(OBJDIR)/usb/ehci-hcd.o \
		$(OBJDIR)/usb/usb_kbd.o \
		$(OBJDIR)/usb/usb_mouse.o \
		$(OBJDIR)/usb/usb_storage.o \
		$(OBJDIR)/usb/usb_mem.o \
		$(OBJDIR)/usb/cmd_usb.o
    
OBJSUSBCF=	\
		$(OBJDIRCF)/usb/usb.o \
		$(OBJDIRCF)/usb/ohci-hcd.o \
		$(OBJDIRCF)/usb/ehci-hcd.o \
		$(OBJDIRCF)/usb/usb_kbd.o \
		$(OBJDIRCF)/usb/usb_mouse.o \
		$(OBJDIRCF)/usb/usb_storage.o \
		$(OBJDIRCF)/usb/usb_mem.o \
		$(OBJDIRCF)/usb/cmd_usb.o

OBJSUSBCF2=	\
		$(OBJDIRCF2)/usb/usb.o \
		$(OBJDIRCF2)/usb/ohci-hcd.o \
		$(OBJDIRCF2)/usb/ehci-hcd.o \
		$(OBJDIRCF2)/usb/usb_kbd.o \
		$(OBJDIRCF2)/usb/usb_mouse.o \
		$(OBJDIRCF)/usb/usb_storage.o \
		$(OBJDIRCF2)/usb/usb_mem.o \
		$(OBJDIRCF)/usb/cmd_usb.o

OBJSUSBCF3=	\
		$(OBJDIRCF3)/usb/usb.o \
		$(OBJDIRCF3)/usb/ohci-hcd.o \
		$(OBJDIRCF3)/usb/ehci-hcd.o \
		$(OBJDIRCF3)/usb/usb_kbd.o \
		$(OBJDIRCF3)/usb/usb_mouse.o \
		$(OBJDIRCF)/usb/usb_storage.o \
		$(OBJDIRCF3)/usb/usb_mem.o \
		$(OBJDIRCF)/usb/cmd_usb.o

OBJSAC97CF=	\
		$(OBJDIRCF)/ac97/mcf548x_ac97.o 

OBJSAC97CF3=	\
		$(OBJDIRCF3)/ac97/mcf548x_ac97.o

OBJSBDOSCF=	\
		$(OBJDIRCF)/bdos/fsbuf.o \
		$(OBJDIRCF)/bdos/fsfat.o \
		$(OBJDIRCF)/bdos/fsio.o \
		$(OBJDIRCF)/bdos/fsdir.o \
		$(OBJDIRCF)/bdos/fsglob.o \
		$(OBJDIRCF)/bdos/fsmain.o \
		$(OBJDIRCF)/bdos/fsdrive.o \
		$(OBJDIRCF)/bdos/fshand.o \
		$(OBJDIRCF)/bdos/fsopnclo.o \
		$(OBJDIRCF)/bdos/osmem.o \
		$(OBJDIRCF)/bdos/umem.o \
		$(OBJDIRCF)/bdos/iumem.o \
		$(OBJDIRCF)/bdos/console.o \
		$(OBJDIRCF)/bdos/bdosmain.o \
		$(OBJDIRCF)/bdos/proc.o \
		$(OBJDIRCF)/bdos/kpgmld.o \
		$(OBJDIRCF)/bdos/time.o \
		$(OBJDIRCF)/bdos/rwa.o \
		$(OBJDIRCF)/bdos/setjmp.o
		
OBJSBDOSCF2=	\
		$(OBJDIRCF)/bdos/fsbuf.o \
		$(OBJDIRCF)/bdos/fsfat.o \
		$(OBJDIRCF)/bdos/fsio.o \
		$(OBJDIRCF)/bdos/fsdir.o \
		$(OBJDIRCF)/bdos/fsglob.o \
		$(OBJDIRCF)/bdos/fsmain.o \
		$(OBJDIRCF)/bdos/fsdrive.o \
		$(OBJDIRCF)/bdos/fshand.o \
		$(OBJDIRCF)/bdos/fsopnclo.o \
		$(OBJDIRCF)/bdos/osmem.o \
		$(OBJDIRCF)/bdos/umem.o \
		$(OBJDIRCF)/bdos/iumem.o \
		$(OBJDIRCF)/bdos/console.o \
		$(OBJDIRCF)/bdos/bdosmain.o \
		$(OBJDIRCF)/bdos/proc.o \
		$(OBJDIRCF)/bdos/kpgmld.o \
		$(OBJDIRCF)/bdos/time.o \
		$(OBJDIRCF)/bdos/rwa.o \
		$(OBJDIRCF)/bdos/setjmp.o

OBJSBDOSCF3=	\
		$(OBJDIRCF)/bdos/fsbuf.o \
		$(OBJDIRCF)/bdos/fsfat.o \
		$(OBJDIRCF)/bdos/fsio.o \
		$(OBJDIRCF)/bdos/fsdir.o \
		$(OBJDIRCF)/bdos/fsglob.o \
		$(OBJDIRCF)/bdos/fsmain.o \
		$(OBJDIRCF)/bdos/fsdrive.o \
		$(OBJDIRCF)/bdos/fshand.o \
		$(OBJDIRCF)/bdos/fsopnclo.o \
		$(OBJDIRCF)/bdos/osmem.o \
		$(OBJDIRCF)/bdos/umem.o \
		$(OBJDIRCF)/bdos/iumem.o \
		$(OBJDIRCF)/bdos/console.o \
		$(OBJDIRCF)/bdos/bdosmain.o \
		$(OBJDIRCF)/bdos/proc.o \
		$(OBJDIRCF)/bdos/kpgmld.o \
		$(OBJDIRCF)/bdos/time.o \
		$(OBJDIRCF)/bdos/rwa.o \
		$(OBJDIRCF)/bdos/setjmp.o

OBJSRTOSCF=	\
		$(OBJDIRCF)/freertos/tasks.o \
		$(OBJDIRCF)/freertos/queue.o \
		$(OBJDIRCF)/freertos/list.o \
		$(OBJDIRCF)/freertos/heap_2.o \
		$(OBJDIRCF)/freertos/heap_2b.o \
		$(OBJDIRCF)/freertos/port.o

OBJSRTOSCF2=	\
		$(OBJDIRCF)/freertos/tasks.o \
		$(OBJDIRCF)/freertos/queue.o \
		$(OBJDIRCF)/freertos/list.o \
		$(OBJDIRCF)/freertos/heap_2.o \
		$(OBJDIRCF)/freertos/heap_2b.o \
		$(OBJDIRCF2)/freertos/port.o

OBJSRTOSCF3=	\
		$(OBJDIRCF)/freertos/tasks.o \
		$(OBJDIRCF)/freertos/queue.o \
		$(OBJDIRCF)/freertos/list.o \
		$(OBJDIRCF)/freertos/heap_2.o \
		$(OBJDIRCF)/freertos/heap_2b.o \
		$(OBJDIRCF3)/freertos/port.o

OBJS=	\
		$(OBJDIR)/header.o \
		$(OBJDIR)/init.o \
		$(OBJDIR)/videocnf.o \
		$(OBJDIR)/gemform.o \
		$(OBJDIR)/xbios.o \
		$(OBJDIR)/detxbios.o \
		$(OBJDIR)/detlinea.o \
		$(OBJDIR)/detvdi.o \
		$(OBJDIR)/work.o \
		$(OBJDIR)/debug.o \
		$(OBJDIR)/m68k_disasm.o \
		$(OBJDIR)/emulator/biosemu.o \
		$(OBJDIR)/emulator/pcbios/pcibios.o \
		$(OBJDIR)/emulator/x86emu/debug.o \
		$(OBJDIR)/emulator/x86emu/decode.o \
		$(OBJDIR)/emulator/x86emu/fpu.o \
		$(OBJDIR)/emulator/x86emu/ops.o \
		$(OBJDIR)/emulator/x86emu/ops2.o \
		$(OBJDIR)/emulator/x86emu/prim_ops.o \
		$(OBJDIR)/emulator/x86emu/sys.o \
		$(OBJDIR)/fvdi/utility.o \
		$(OBJDIR)/fvdi/fonts.o \
		$(OBJDIR)/fvdi/text.o \
		$(OBJDIR)/fvdi/textrndr.o \
		$(OBJDIR)/fvdi/blit.o \
		$(OBJDIR)/fvdi/line.o \
		$(OBJDIR)/fvdi/draw.o \
		$(OBJDIR)/fvdi/polygon.o \
		$(OBJDIR)/fvdi/conic.o \
		$(OBJDIR)/fvdi/contourfill.o \
		$(OBJDIR)/fvdi/vdi_misc.o \
		$(OBJDIR)/video/accel_rom.o \
		$(OBJDIR)/video/spec_rom.o \
		$(OBJDIR)/radeon/radeon_base_rom.o \
		$(OBJDIR)/radeon/radeon_video.o \
		$(OBJDIR)/radeon/radeon_theatre_dsp.o \
		$(OBJDIR)/radeon/radeon_theatre.o \
		$(OBJDIR)/radeon/radeon_vid.o \
		$(OBJDIR)/dma_utils/dma_utils.o \
		$(OBJDIR)/stdlib.o \
		$(OBJDIR)/printk.o \
		$(OBJSUSB) \
		$(OBJSDRIVERFVDI)

OBJSCF=	\
		$(OBJDIRCF)/init.o \
		$(OBJDIRCF)/videocnf.o \
		$(OBJDIRCF)/gemform.o \
		$(OBJDIRCF)/xbios.o \
		$(OBJDIRCF)/detxbios.o \
		$(OBJDIRCF)/detlinea.o \
		$(OBJDIRCF)/detvdi.o \
		$(OBJDIRCF)/work.o \
		$(OBJDIRCF)/timer_rom.o \
		$(OBJDIRCF)/m68k_disasm.o \
		$(OBJDIRCF)/emulator/biosemu.o \
		$(OBJDIRCF)/emulator/pcbios/pcibios.o \
		$(OBJDIRCF)/emulator/x86emu/debug.o \
		$(OBJDIRCF)/emulator/x86emu/decode.o \
		$(OBJDIRCF)/emulator/x86emu/fpu.o \
		$(OBJDIRCF)/emulator/x86emu/ops.o \
		$(OBJDIRCF)/emulator/x86emu/ops2.o \
		$(OBJDIRCF)/emulator/x86emu/prim_ops.o \
		$(OBJDIRCF)/emulator/x86emu/sys.o \
		$(OBJDIRCF)/fvdi/utility.o \
		$(OBJDIRCF)/fvdi/fonts.o \
		$(OBJDIRCF)/fvdi/text.o \
		$(OBJDIRCF)/fvdi/textrndr.o \
		$(OBJDIRCF)/fvdi/blit.o \
		$(OBJDIRCF)/fvdi/line.o \
		$(OBJDIRCF)/fvdi/draw.o \
		$(OBJDIRCF)/fvdi/polygon.o \
		$(OBJDIRCF)/fvdi/conic.o \
		$(OBJDIRCF)/fvdi/contourfill.o \
		$(OBJDIRCF)/fvdi/vdi_misc.o \
		$(OBJDIRCF)/fvdi/common/c_common_rom.o \
		$(OBJDIRCF)/video/spec_rom.o \
		$(OBJDIRCF)/video/accel_rom.o \
		$(OBJDIRCF)/video/videl.o \
		$(OBJDIRCF)/radeon/radeon_base_rom.o \
		$(OBJDIRCF)/radeon/radeon_video.o \
		$(OBJDIR)/radeon/radeon_theatre_dsp.o \
		$(OBJDIRCF)/radeon/radeon_theatre.o \
		$(OBJDIRCF)/radeon/radeon_vid.o \
		$(OBJDIRCF)/lynx/smi_base.o \
		$(OBJDIRCF)/lynx/smi_accel.o \
		$(OBJDIRCF)/lynx/smi_cursor.o \
		$(OBJDIRCF)/lynx/smi_i2c.o \
		$(OBJDIRCF)/get.o \
		$(OBJDIRCF)/rtc/rtc5c387.o \
		$(OBJSUSBCF) \
		$(OBJSDRIVERFVDICF) \
		$(OBJSNETCF)

OBJSCF2=	\
		$(OBJDIRCF2)/init.o \
		$(OBJDIRCF)/videocnf.o \
		$(OBJDIRCF)/gemform.o \
		$(OBJDIRCF2)/xbios.o \
		$(OBJDIRCF2)/detxbios.o \
		$(OBJDIRCF)/detlinea.o \
		$(OBJDIRCF)/detvdi.o \
		$(OBJDIRCF)/work.o \
		$(OBJDIRCF2)/timer_rom.o \
		$(OBJDIRCF)/m68k_disasm.o \
		$(OBJDIRCF)/emulator/biosemu.o \
		$(OBJDIRCF)/emulator/pcbios/pcibios.o \
		$(OBJDIRCF)/emulator/x86emu/debug.o \
		$(OBJDIRCF)/emulator/x86emu/decode.o \
		$(OBJDIRCF)/emulator/x86emu/fpu.o \
		$(OBJDIRCF)/emulator/x86emu/ops.o \
		$(OBJDIRCF)/emulator/x86emu/ops2.o \
		$(OBJDIRCF)/emulator/x86emu/prim_ops.o \
		$(OBJDIRCF)/emulator/x86emu/sys.o \
		$(OBJDIRCF)/fvdi/utility.o \
		$(OBJDIRCF)/fvdi/fonts.o \
		$(OBJDIRCF)/fvdi/text.o \
		$(OBJDIRCF)/fvdi/textrndr.o \
		$(OBJDIRCF)/fvdi/blit.o \
		$(OBJDIRCF)/fvdi/line.o \
		$(OBJDIRCF)/fvdi/draw.o \
		$(OBJDIRCF)/fvdi/polygon.o \
		$(OBJDIRCF)/fvdi/conic.o \
		$(OBJDIRCF)/fvdi/contourfill.o \
		$(OBJDIRCF)/fvdi/vdi_misc.o \
		$(OBJDIRCF)/fvdi/common/c_common_rom.o \
		$(OBJDIRCF)/video/spec_rom.o \
		$(OBJDIRCF2)/video/accel_rom.o \
		$(OBJDIRCF2)/video/videl.o \
		$(OBJDIRCF2)/radeon/radeon_base_rom.o \
		$(OBJDIRCF)/get.o \
		$(OBJSUSBCF2) \
		$(OBJSDRIVERFVDICF2) \
		$(OBJSNETCF2)

OBJSCF3=	\
		$(OBJDIRCF3)/init.o \
		$(OBJDIRCF3)/videocnf.o \
		$(OBJDIRCF)/gemform.o \
		$(OBJDIRCF3)/xbios.o \
		$(OBJDIRCF3)/detxbios.o \
		$(OBJDIRCF)/detlinea.o \
		$(OBJDIRCF)/detvdi.o \
		$(OBJDIRCF)/work.o \
		$(OBJDIRCF)/timer_rom.o \
		$(OBJDIRCF)/m68k_disasm.o \
		$(OBJDIRCF)/emulator/biosemu.o \
		$(OBJDIRCF)/emulator/pcbios/pcibios.o \
		$(OBJDIRCF)/emulator/x86emu/debug.o \
		$(OBJDIRCF)/emulator/x86emu/decode.o \
		$(OBJDIRCF)/emulator/x86emu/fpu.o \
		$(OBJDIRCF)/emulator/x86emu/ops.o \
		$(OBJDIRCF)/emulator/x86emu/ops2.o \
		$(OBJDIRCF)/emulator/x86emu/prim_ops.o \
		$(OBJDIRCF)/emulator/x86emu/sys.o \
		$(OBJDIRCF)/fvdi/utility.o \
		$(OBJDIRCF)/fvdi/fonts.o \
		$(OBJDIRCF)/fvdi/text.o \
		$(OBJDIRCF)/fvdi/textrndr.o \
		$(OBJDIRCF)/fvdi/blit.o \
		$(OBJDIRCF)/fvdi/line.o \
		$(OBJDIRCF)/fvdi/draw.o \
		$(OBJDIRCF)/fvdi/polygon.o \
		$(OBJDIRCF)/fvdi/conic.o \
		$(OBJDIRCF)/fvdi/contourfill.o \
		$(OBJDIRCF)/fvdi/vdi_misc.o \
		$(OBJDIRCF)/fvdi/common/c_common_rom.o \
		$(OBJDIRCF)/video/spec_rom.o \
		$(OBJDIRCF3)/video/accel_rom.o \
		$(OBJDIRCF3)/video/videl.o \
		$(OBJDIRCF3)/video/blitter.o \
		$(OBJDIRCF)/radeon/radeon_base_rom.o \
		$(OBJDIRCF)/radeon/radeon_video.o \
		$(OBJDIR)/radeon/radeon_theatre_dsp.o \
		$(OBJDIRCF)/radeon/radeon_theatre.o \
		$(OBJDIRCF)/radeon/radeon_vid.o \
		$(OBJDIRCF3)/get.o \
		$(OBJSUSBCF3) \
		$(OBJSDRIVERFVDICF3) \
		$(OBJSNETCF3)

HEX = drivers.hex
HEXCF = drivers_cf.hex
HEXCF2 = drivers_cf2.hex
HEXCF3 = drivers_cf3.hex
HEXFIREBEE = drivers_firebee.hex
DRIVERFVDI = radeon.sys
DRIVERFVDICF = radeon_cf.sys
DRIVERFVDICF2 = radeon_cf2.sys
DRIVERFVDICF3 = radeon_f.sys
FLASH_DRIVERS = 0xEC0000
FLASH_DRIVERS_CF = 0xEA0000
FLASH_DRIVERS_FIREBEE = 0xE04A0000

BINHEX_BINARY= binhex.ttp
COMPRESS_BINARY= compress.ttp
STACKSIZE= 64k

all: $(BINHEX_BINARY) $(COMPRESS_BINARY) version.h $(HEX) $(HEXCF) $(HEXCF2) $(HEXCF3) $(DRIVERFVDI) $(DRIVERFVDICF) $(DRIVERFVDICF2) $(DRIVERFVDICF3)

ctpci: $(BINHEX_BINARY) $(COMPRESS_BINARY) version.h $(HEX) $(DRIVERFVDI)

m5484lite: $(BINHEX_BINARY) $(COMPRESS_BINARY) version.h $(HEXCF) $(DRIVERFVDICF)

m54455evb: $(BINHEX_BINARY) $(COMPRESS_BINARY) version.h $(HEXCF2) $(DRIVERFVDICF2)

firebee: $(BINHEX_BINARY) $(COMPRESS_BINARY) version.h $(HEXCF3) $(DRIVERFVDICF3)

clean:
	rm -rf $(OBJDIR) $(OBJDIRCF) $(OBJDIRCF2) $(OBJDIRCF3)
	rm -f $(BINHEX_BINARY) $(COMPRESS_BINARY) $(HEX) $(HEXCF) $(HEXCF2) $(HEXCF3) $(HEXFIREBEE) drivers.map drivers_cf.map drivers_cf2.map drivers_cf3.map $(DRIVERFVDI) $(DRIVERFVDICF) $(DRIVERFVDICF2) $(DRIVERFVDICF3) 

$(HEX):	$(OBJS)
	$(LD) --oformat srec -Map drivers.map --cref -T drivers.lk \
	--entry Start -o $(HEX) $(OBJS)
	$(COMPRESS_BINARY) $(HEX) temp.bin
	objcopy --verbose -I binary -O srec --adjust-vma=$(FLASH_DRIVERS) temp.bin $(HEX)
	rm temp.bin 

$(HEXCF):	$(OBJDIRCF)/header.o $(OBJSCF) $(OBJSBDOSCF) $(OBJSRTOSCF) $(OBJSLWIPCF) $(OBJSAC97CF)
	$(LD) --oformat srec -Map drivers_cf.map --cref -T drivers_cf.lk \
	--entry Start -o $(HEXCF) $(OBJSCF)
	$(COMPRESS_BINARY) $(HEXCF) temp.bin
	objcopy --verbose -I binary -O srec --adjust-vma=$(FLASH_DRIVERS_CF) temp.bin $(HEXCF)
	rm temp.bin 

$(HEXCF2):	$(OBJDIRCF)/header.o $(OBJSCF2) $(OBJSBDOSCF2) $(OBJSRTOSCF2) $(OBJSLWIPCF2)
	$(LD) --oformat srec -Map drivers_cf2.map --cref -T drivers_cf2.lk \
	--entry Start -o $(HEXCF2) $(OBJSCF2)
	$(COMPRESS_BINARY) $(HEXCF2) temp.bin
	objcopy --verbose -I binary -O srec --adjust-vma=$(FLASH_DRIVERS_CF) temp.bin $(HEXCF2)
	rm temp.bin 

$(HEXCF3):	$(OBJDIRCF)/header.o $(OBJSCF3) $(OBJSBDOSCF3) $(OBJSRTOSCF3) $(OBJSLWIPCF3) $(OBJSAC97CF3)
	$(LD) --oformat srec -Map drivers_cf3.map --cref -T drivers_cf3.lk \
	--entry Start -o $(HEXCF3) $(OBJSCF3)
	$(COMPRESS_BINARY) $(HEXCF3) temp.bin
	objcopy --verbose -I binary -O srec --adjust-vma=$(FLASH_DRIVERS_FIREBEE) temp.bin $(HEXFIREBEE)
	objcopy --verbose -I binary -O srec --adjust-vma=$(FLASH_DRIVERS_CF) temp.bin $(HEXCF3)
	rm temp.bin 

$(DRIVERFVDI):	$(OBJDIR)/video/spec.o $(OBJDIR)/video/accel.o $(OBJDIR)/radeon/radeon_base.o $(OBJSDRIVERFVDI)
	$(LD) $(LDFLAGS) -o $(DRIVERFVDI) $(OBJDIR)/video/spec.o $(OBJDIR)/video/accel.o $(OBJDIR)/radeon/radeon_base.o $(OBJSDRIVERFVDI)
	$(STRIP) $(DRIVERFVDI)

$(DRIVERFVDICF):	$(OBJDIRCF)/video/spec.o $(OBJDIRCF)/video/accel.o $(OBJDIRCF)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF)/timer.o $(OBJSDRIVERFVDICF)
	$(LD) $(LDFLAGS) -o $(DRIVERFVDICF) $(OBJDIRCF)/video/spec.o $(OBJDIRCF)/video/accel.o $(OBJDIRCF)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF)/timer.o $(OBJSDRIVERFVDICF)
	$(STRIP) $(DRIVERFVDICF)

$(DRIVERFVDICF2):	$(OBJDIRCF)/video/spec.o $(OBJDIRCF2)/video/accel.o $(OBJDIRCF2)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF2)/timer.o $(OBJSDRIVERFVDICF2)
	$(LD) $(LDFLAGS) -o $(DRIVERFVDICF2) $(OBJDIRCF)/video/spec.o $(OBJDIRCF2)/video/accel.o $(OBJDIRCF2)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF2)/timer.o  $(OBJSDRIVERFVDICF2)
	$(STRIP) $(DRIVERFVDICF2)

$(DRIVERFVDICF3):	$(OBJDIRCF)/video/spec.o $(OBJDIRCF3)/video/accel.o $(OBJDIRCF3)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF)/timer.o $(OBJSDRIVERFVDICF3)
	$(LD) $(LDFLAGS) -o $(DRIVERFVDICF3) $(OBJDIRCF)/video/spec.o $(OBJDIRCF3)/video/accel.o $(OBJDIRCF3)/radeon/radeon_base.o $(OBJDIRCF)/fvdi/common/c_common.o $(OBJDIRCF)/timer.o  $(OBJSDRIVERFVDICF3)
	$(STRIP) $(DRIVERFVDICF3)

version.h:
	@date -u +%e,%_m,%Y,%k,%_M > date.tmp
	@echo "#define VERSION" $(VERSION) > $(INCDIR)/version.h
	@echo "#define DATE \\" > version.tmp
	@cat version.tmp >> $(INCDIR)/version.h
	@cat date.tmp >> $(INCDIR)/version.h
	@rm version.tmp
	@rm date.tmp
	@touch -m $(SRCDIR)/header.S

$(BINHEX_BINARY):	$(OBJDIR)/tools/binhex.o
	$(CC) $(OBJDIR)/tools/binhex.o -o $(BINHEX_BINARY)
	$(STRIP) $(BINHEX_BINARY)
	$(STACK) -S $(STACKSIZE) $(BINHEX_BINARY)

$(COMPRESS_BINARY):	$(OBJDIR)/tools/compress.o $(OBJDIR)/tools/lz.o $(OBJDIR)/tools/srec.o
	$(CC) $(OBJDIR)/tools//compress.o $(OBJDIR)/tools/lz.o $(OBJDIR)/tools/srec.o -o $(COMPRESS_BINARY)
	$(STRIP) $(COMPRESS_BINARY)
	$(STACK) -S $(STACKSIZE) $(COMPRESS_BINARY)

define CREATEOBJDIRS
	@for d in $(OBJDIR) $(SUBOBJDIRS); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

define CREATEOBJDIRSCF
	@for d in $(OBJDIRCF) $(SUBOBJDIRSCF); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

define CREATEOBJDIRSCF2
	@for d in $(OBJDIRCF2) $(SUBOBJDIRSCF2); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

define CREATEOBJDIRSCF3
	@for d in $(OBJDIRCF3) $(SUBOBJDIRSCF3); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

$(OBJDIR)/radeon/%.o:	$(SRCDIR)/radeon/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/radeon/%.o:	$(SRCDIR)/radeon/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/radeon/%.o:	$(SRCDIR)/radeon/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/radeon/%.o:	$(SRCDIR)/radeon/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/radeon/%.o:	$(SRCDIR)/radeon/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/radeon/%.o:	$(SRCDIR)/radeon/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/radeon/%.o:	$(SRCDIR)/radeon/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/radeon/%.o:	$(SRCDIR)/radeon/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/radeon/%.o:	$(SRCDIR)/radeon/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/video/%.o:	$(SRCDIR)/video/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/video/%.o:	$(SRCDIR)/video/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/video/%.o:	$(SRCDIR)/video/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/video/%.o:	$(SRCDIR)/video/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/video/%.o:	$(SRCDIR)/video/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/video/%.o:	$(SRCDIR)/video/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/video/%.o:	$(SRCDIR)/video/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/common/%.o:	$(SRCDIR)/fvdi/common/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/1_plane/%.o:	$(SRCDIR)/fvdi/1_plane/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/%.o:	$(SRCDIR)/fvdi/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/%.o:	$(SRCDIR)/fvdi/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/%.o:	$(SRCDIR)/fvdi/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/%.o:	$(SRCDIR)/fvdi/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/fvdi/%.o:	$(SRCDIR)/fvdi/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/fvdi/%.o:	$(SRCDIR)/fvdi/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/fvdi/%.o:	$(SRCDIR)/fvdi/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/fvdi/%.o:	$(SRCDIR)/fvdi/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIRCF)/net/%.o:	$(SRCDIR)/net/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/net/%.o:	$(SRCDIR)/net/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/net/%.o:	$(SRCDIR)/net/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -c $< -o $@

$(OBJDIRCF)/net//%.o:	$(SRCDIR)/net//%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/net//%.o:	$(SRCDIR)/net//%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/net//%.o:	$(SRCDIR)/net//%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -c $< -o $@
	
$(OBJDIRCF)/usb_dev/%.o:	$(SRCDIR)/usb_dev/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -c $< -o $@

$(OBJDIR)/usb/%.o:	$(SRCDIR)/usb/%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/usb/%.o:	$(SRCDIR)/usb/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/usb/%.o:	$(SRCDIR)/usb/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/usb/%.o:	$(SRCDIR)/usb/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -c $< -o $@

$(OBJDIRCF)/ac97/%.o:	$(SRCDIR)/ac97/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/ac97/%.o:	$(SRCDIR)/ac97/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/ac97/%.o:	$(SRCDIR)/ac97/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -c $< -o $@

$(OBJDIRCF)/bdos/%.o:	$(SRCDIR)/bdos/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -mshort -c $< -o $@

$(OBJDIRCF2)/bdos/%.o:	$(SRCDIR)/bdos/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -mshort -c $< -o $@

$(OBJDIRCF3)/bdos/%.o:	$(SRCDIR)/bdos/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -mshort -c $< -o $@

$(OBJDIRCF)/bdos//%.o:	$(SRCDIR)/bdos//%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(CFLAGSCF) -mshort -c $< -o $@

$(OBJDIRCF2)/bdos//%.o:	$(SRCDIR)/bdos//%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(CFLAGSCF2) -mshort -c $< -o $@

$(OBJDIRCF3)/bdos//%.o:	$(SRCDIR)/bdos//%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(CFLAGSCF3) -mshort -c $< -o $@

$(OBJDIR)/%.o:	$(SRCDIR)%.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/%.o:	$(SRCDIR)/%.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/%.o:	$(SRCDIR)/%.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/%.o:	$(SRCDIR)/%.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

$(OBJDIR)/%.o:	$(SRCDIR)/%.S
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/%.o:	$(SRCDIR)/%.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -c $< -o $@

$(OBJDIRCF2)/%.o:	$(SRCDIR)/%.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -c $< -o $@

$(OBJDIRCF3)/%.o:	$(SRCDIR)/%.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -c $< -o $@

#$(OBJDIR)/radeon/%.o:	$(SRCDIR)/radeon/%.c
#	$(CREATEOBJDIRS)
#	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -Wa,-alhsd=x.ls -c $< -o $@

#$(OBJDIRCF)/emulator/biosemu.o:	$(SRCDIR)/emulator/biosemu.c
#	$(CREATEOBJDIRSCF)
#	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -Wa,-alhsd=biosemu.ls -c $< -o $@

$(OBJDIR)/radeon/radeon_base_rom.o:	$(SRCDIR)/radeon/radeon_base.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/radeon/radeon_base_rom.o:	$(SRCDIR)/radeon/radeon_base.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/radeon/radeon_base_rom.o:	$(SRCDIR)/radeon/radeon_base.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/radeon/radeon_base_rom.o:	$(SRCDIR)/radeon/radeon_base.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIR)/radeon/radeon_accel_rom.o:	$(SRCDIR)/radeon/radeon_accel.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/radeon/radeon_accel_rom.o:	$(SRCDIR)/radeon/radeon_accel.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/radeon/radeon_accel_rom.o:	$(SRCDIR)/radeon/radeon_accel.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/radeon/radeon_accel_rom.o:	$(SRCDIR)/radeon/radeon_accel.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIR)/radeon/radeon_theatre_dsp.o: $(ATICOD)
	$(COMPRESS_BINARY) $(ATICOD) ./ati.bin
	$(BINHEX_BINARY) ./ati.bin $(SRCDIR)/radeon/radeon_theatre_dsp.txt theatre_dsp
	@rm ati.bin
	@echo "#include \"config.h\"" > $(SRCDIR)/radeon/radeon_theatre_dsp.c
	@echo "#ifdef RADEON_THEATRE" >> $(SRCDIR)/radeon/radeon_theatre_dsp.c
	@cat $(SRCDIR)/radeon/radeon_theatre_dsp.txt >> $(SRCDIR)/radeon/radeon_theatre_dsp.c
	@echo "#endif" >> $(SRCDIR)/radeon/radeon_theatre_dsp.c
	@rm $(SRCDIR)/radeon/radeon_theatre_dsp.txt
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(CFLAGS) -c $(SRCDIR)/radeon/radeon_theatre_dsp.c -o $@

$(OBJDIR)/video/spec_rom.o:	$(SRCDIR)/video/spec.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/video/spec_rom.o:	$(SRCDIR)/video/spec.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/video/spec_rom.o:	$(SRCDIR)/video/spec.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/video/spec_rom.o:	$(SRCDIR)/video/spec.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIR)/video/accel_rom.o:	$(SRCDIR)/video/accel.c
	$(CREATEOBJDIRS)
	$(CC) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGS) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/video/accel_rom.o:	$(SRCDIR)/video/accel.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/video/accel_rom.o:	$(SRCDIR)/video/accel.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/video/accel_rom.o:	$(SRCDIR)/video/accel.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/fvdi/common/c_common_rom.o:	$(SRCDIR)/fvdi/common/c_common.S
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/fvdi/common/c_common_rom.o:	$(SRCDIR)/fvdi/common/c_common.S
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/fvdi/common/c_common_rom.o:	$(SRCDIR)/fvdi/common/c_common.S
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF)/timer_rom.o:	$(SRCDIR)/timer.c
	$(CREATEOBJDIRSCF)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF2)/timer_rom.o:	$(SRCDIR)timer.c
	$(CREATEOBJDIRSCF2)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF2) -DDRIVER_IN_ROM -c $< -o $@

$(OBJDIRCF3)/timer_rom.o:	$(SRCDIR)/timer.c
	$(CREATEOBJDIRSCF3)
	$(CCF) $(INCLUDE) $(INCLUDEFVDI) $(CFLAGSCF3) -DDRIVER_IN_ROM -c $< -o $@

