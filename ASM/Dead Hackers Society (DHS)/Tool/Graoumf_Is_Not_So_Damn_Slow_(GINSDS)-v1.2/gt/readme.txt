

Hi Falconeers/trackers,

This here is a patched, raped, ripped and optimised version of the Graoumpf
tracker replay code. You can place the .PGT file in your SYS directory.
For you coders out there the modified sources are included (now including
tables).

It should now run flawlessly on a CT2 accelerated Falcon. I haven't tested
any others. Anyway, the DSP mixer has been optimised to almost the limit.
Maybe some smart coders can push it some more but I doubt it. I tested a
32chn xm on this CT2a Falcon and it never came over 85% load even with
all channels filled. On a plain Falcon 20chn is possible.

I reckon the CPU part could still be optimised, but what would this save...
1% cpu time perhaps?

> update:

Again I optimised the dsp a little. Also a dsp-interrupt is used again
instead of the weird 8192Hz(!) polling interrupt used for timers a/c/d. This
definelely saves precious cpu time! But I was afraid of this due to a
particular accelerator having no dsp interrupt (CT2!). Nevertheless, it
runs fine with the dspint-patch.

Have alot of fun.

stay cool stay atari,
                     earx/fun
