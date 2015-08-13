*********************************************************************************
* Data structure per ethernet device						*
*										*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* module netdevice.h of Linux originally due to the authors Donald Becker, ...	*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*********************************************************************************
* $Id: netdev.i 1.1 2002/03/24 13:53:06 Thomas Exp Thomas $
*
		OFFSET	0
* this is only a small subset of struct dev from linux' netdevice.h

dev_start		DS.B	1	; device is active when <>0
dev_interrupt		DS.B	1	; interrupt arrived
dev_tbusy		DS.B	1	; transmitter busy
			DS.B	1	; filler for word align
dev_trans_start		DS.L	1	; Time (in jiffies) of last Tx
dev_flags		DS.W	1	; interface flags (a la BSD)
dev_dev_addr		DS.B	6	; MAC address
dev_mc_list		DS.L	1	; pointer to Multicast MAC addresses (who fills this?)

* this is only a small subset of struct ei_device from linux' 8390.h
lcl_name		DS.L	1	; points to device name string
lcl_irqlock		DS.B	1	; lock out 8390 interrupts when <>0
			DS.B	1	; filler for word align
lcl_tx_start_page	DS.B	1	; first tx RAM page
lcl_rx_start_page	DS.B	1	; first rx RAM page = point past last rx RAM page
lcl_stop_page		DS.B	1	; point past last rx RAM page
lcl_current_page	DS.B	1	; Previous write pointer in buffer

* The new statistics table as per Linux' struct enet_statistics
lcl_stats			EQU	*
lcl_es_rx_packets		DS.W	1
lcl_es_tx_packets		DS.W	1
lcl_es_rx_errors		DS.W	1
lcl_es_tx_errors		DS.W	1
lcl_es_rx_dropped		DS.W	1
lcl_es_tx_dropped		DS.W	1
lcl_es_multicast		DS.W	1
lcl_es_collisions		DS.W	1

* detailed rx_errors
lcl_es_rx_length_errors		DS.W	1
lcl_es_rx_over_errors		DS.W	1
lcl_es_rx_crc_errors		DS.W	1
lcl_es_rx_frame_errors		DS.W	1
lcl_es_rx_fifo_errors		DS.W	1
lcl_es_rx_missed_errors		DS.W	1

* detailed tx_errors
lcl_es_tx_aborted_errors	DS.W	1
lcl_es_tx_carrier_errors	DS.W	1
lcl_es_tx_fifo_errors		DS.W	1
lcl_es_tx_hartbeat_errors	DS.W	1
lcl_es_tx_window_errors		DS.W	1

* my stuff
ticks2ms		DS.L	1		; 2ms in processor specific ticks (calibrated by Adelay)
Ndevice			EQU	*

