Received: by maskin (mbox dlanor)
 (with Cubic Circle's cucipop (v1.31 1998/05/13) Wed May 26 10:35:45 1999)
X-From_: didier.mequignon@wanadoo.fr Mon May 17 19:38:31 1999
Received: (from uucp@localhost)
	by maskin.ettnet.se (8.9.1a/8.8.8) id TAA16222
	for <dlanor@oden.se>; Mon, 17 May 1999 19:38:30 +0200 (MET DST)
Received: from UNKNOWN(193.252.19.126), claiming to be "wanadoo.fr"
 via SMTP by maskin, id smtpdAAAa003xM; Mon May 17 19:38:23 1999
Received: from tntdun7-41.abo.wanadoo.fr [164.138.53.41] by wanadoo.fr
          for <dlanor@oden.se>
          Paris Mon, 17 May 1999 19:39:15 +0200 (MET DST)
Date: Mon, 17 May 1999 19:39:15 +0200 (MET DST)
Message-Id: <199905171739.TAA28298@wanadoo.fr>
To: dlanor@oden.se (Ronald Andersson)
From: didier.mequignon@wanadoo.fr (Didier MEQUIGNON)
Organization: /|\
Subject: Re: Pb CT2B memory $0 to $7FF in user state
X-Mailer: NEWSie Version 0.94 (Atari)

Hi Ronald,

>on Fri 14-05-1999 08:21 Didier MEQUIGNON wrote:
>>On 13 May 1999 20:49:00 , Ronald Andersson wrote:
>>
>----- snip ----- Re: CT2B allows user mode access to system vector RAM

>>I have seen...WPTOSFIX.PRG, where I can found this patch ?
>
>I intend to place my patches on my homepage soon, but I want to update them
>first, to include the IO and system vector protection that we have discussed
>in this thread. When they're available on my page i will post that fact here.

I have worked on MMU, so maybe my lines can help you :

First, I have patched FLASH.BIN for see and modify tree :
I have replaced hex codes 303C00020246FFFE by
                          303C00024E714E71
and 303C00420246FFFE22C6 by
    303C003F0246FFFE22C6 2X, because some parts in flash-eprom 
                             hide tree after creation.

With this method it's possible to run patch in FastRam.

After I have put this patch at first position in auto folder:

 MOVE.L 4(SP),A5;basepage
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #256,D0
 SETBLOCK D0,(A5)
 MOVE.L #"_CT2",D0
 BSR GET_COOKIE
 BMI.S \1;no CT2
 MOVE.L #"PMMU",D0
 BSR GET_COOKIE
 BMI.S \1;no tree MMU
 SUPEXEC CHANGE_MMU
\1:TERM
 RTS

CHANGE_MMU:

 MOVE SR,-(SP)
 OR #$700,SR
 MOVEP CRP,REG_CRP
 MOVE.L REG_CRP+4,A1
 LEA $4400+$200+3(A1),A2;adress descriptor 64 bits for momory $0 to $2000
 LEA $4400(A1),A3;adress descriptor 32 bits for memory $0 to $1000000
 SUB.L #$3000000,A1;FastRam MMU $4000000 => $1000000
 LEA $4400(A1),A0
 TST.L (A0)
 BNE.S \1;modified
 MOVE.L A2,(A0)+
 MOVEQ #1,D1
 MOVEQ #0,D2
 MOVE #$2000,D2
 MOVEQ #126,D0
\2:ADD.L D2,D1
  MOVE.L D1,(A0)+
 DBRA D0,\2 
 LEA TREE_MMU_800,A4
 MOVEQ #7,D0
\3:MOVE.L (A4)+,(A0)+
 DBRA D0,\3
 MOVE.L #$007FFC02,(A1);descriptor 32 bits
 MOVE.L A3,4(A1)
 LEA $4400(A1),A0
 BSET #2,-1(A0);Write Protect tree MMU
 BSET #2,-5(A0)
 BSET #2,-7(A0)
 PMOVE REG_TC,TC;new tree with 3 levels
 PFLUSHA
\1:MOVE (SP)+,SR
 RTS

 DATA
 
TREE_MMU_800:

 DC.L $0003FFD01,$00000000;Supervisor only
 DC.L $0003FFC01,$00000800
 DC.L $0003FFC01,$00001000
 DC.L $0003FFC01,$00001800

REG_TC:DC.L $80B1B720

 BSS

REG_CRP:DS.L 2

 END


Thanks for your infos.

Regards,

Didier.



---------------------------------------------------------------------
Didier MEQUIGNON         Aniplayer download: http://aniplay.atari.org 
E-mail: didier.mequignon@wanadoo.fr  http://perso.wanadoo.fr/didierm/ 
Address: 25,rue de l'Ascenseur 62510 Arques FRANCE                   
Dev 68K/DSP56001/C on                                                
Atari FALCON 030/CT2B 46Mb  420Mb HD ~ ZIP100 ~ CD-ROM10X ~ MODEM V90
--------------------------------------------------------------------- 

