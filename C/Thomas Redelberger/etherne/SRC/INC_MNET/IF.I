*********************************************************************************
* Data structure per ethernet device MagicNet/MintNet				*
*										*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* module if.h of MintNet originally due to Kay Roemer				*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*********************************************************************************
* $Id: if.i 1.1 2002/03/24 14:06:12 Thomas Exp Thomas $
*

IF_NAMSIZ		EQU	16			; maximum if name len
IF_MAXQ			EQU	60			; maximum if queue len
IF_SLOWTIMEOUT		EQU	1000			; one second
IF_PRIORITY_BITS	EQU	1
IF_PRIORITIES		EQU	(1<<IF_PRIORITY_BITS)

HWTYPE_ETH		EQU	1			; ethernet

ETH_ALEN		EQU	6			; HW addr length
ETH_HLEN		EQU	14			; Eth frame header length
ETH_MIN_DLEN		EQU	46			; minimum data length
ETH_MAX_DLEN		EQU	1500			; maximum data length


* struct ifq
		OFFSET	0

q_maxqlen	DS.W	1				; short	maxqlen;
q_qlen		DS.W	1				; short	qlen;
q_curr		DS.W	1				; short	curr;
q_qfirst	DS.L	IF_PRIORITIES			; BUF	*qfirst[IF_PRIORITIES];
q_qlast		DS.L	IF_PRIORITIES			; BUF	*qlast[IF_PRIORITIES];
Nqueue		EQU	*


* struct netif
		OFFSET	0

if_name		DS.B	IF_NAMSIZ			; char name[IF_NAMSIZ]
if_unit		DS.W	1				; short unit
if_flags	DS.W	1				; ushort flags
if_metric	DS.L	1				; ulong metric
if_mtu		DS.L	1				; ulong mtu
if_timer	DS.L	1				; ulong timer
if_hwtype	DS.W	1				; short hwtype
if_hwlocalLen	DS.W	1				; hwlocal.len
if_hwlocalAddr	DS.B	10				; hwlocal.addr
if_hwbrctsLen	DS.W	1				; hwbrcst.len
if_hwbrctsAddr	DS.B	10				; hwbrcst.addr
if_addrlist	DS.L	1				; struct ifaddr* addrlist
if_snd		DS.B	Nqueue				; struct ifq snd
if_rcv		DS.B	Nqueue				; struct ifq rcv
if_open		DS.L	1				; *open
if_close	DS.L	1				; *close
if_output	DS.L	1				; *output
if_ioctl	DS.L	1				; *ioctl
if_timeout	DS.L	1				; *timeout
if_data		DS.L	1				; void* data
if_in_packets	DS.L	1				; ulong in_packets
if_in_errors	DS.L	1				; ulong in_errors
if_out_packets	DS.L	1				; ulong out_packets
if_out_errors	DS.L	1				; ulong out_errors
if_collisions	DS.L	1				; ulong collisions
if_next		DS.L	1				; struct netif* next
if_maxpackets	DS.W	1				; short maxpackets
if_bpf		DS.L	1				; struct bpf *bpf
		DS.L	4				; long reserved[4]
Nif		EQU	*

