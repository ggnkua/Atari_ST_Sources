Sid Sound Designer replaycode v1.02


History:
--------
1.00 reassembled,fixed and new stuff added by .defjam./.checkpoint.
1.01 Falcon-IDE-fix by FroST
1.02 Pattern Fix, Optimisation, Commented by Ben / OVR


The SSD replay is available in two versions:

1. ACD: A version that uses Timer A, C and D for creating
   SIDvoice effects on all three channels.
   As Timer-C is Trashed, you can not use this version
   while the OS is in use. Howevr Timer-B is free for
   raster effects, border-killing or something else.

2. ABD: Another version which uses Timer A, B and D for
   the same SIDvoice effects.
   As Timer-C is free, this routine works nicely
   together with the OS, for example used in
   SNDH-files.



Files:
------
readme.txt       Me!
timbral.tri      Example tune note datas (by Timbral/DHS).
timbral.tvs      Example tune instrument datas.

abd/ssd_abd.s    Actual replay source code, not needed for replay.
abd/ssd_abd.drv  Binary version of the above source, used for replay.
abd/exmp-vbl.s   Example how to replay from VBL.
abd/exmp-tc.s    OS-friendly and frequency adaptive example Timer-C Replay.

acd/ssd_acd.s    Actual replay source code, not needed for replay.
acd/ssd_acd.drv  Binary version of the above source, used for replay.
acd/exmp-vbl.s   Example how to replay from VBL.
acd/exmp-tc.s    Example Timer-B replay (adaptive freq. possible).
