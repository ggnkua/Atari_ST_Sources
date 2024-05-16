Hello members of Superior (Wanderer, Jinx, Jabba),

here is the newest version of Pack-Ice and of Fire-Pack.
Both have the new unpacking routines included.

The files in the Pack-Ice folder are:
 - ICE_2_3.PRG     Pack-Ice version 2.3
 - ICE_UNPA.S      Unpacking routine. Original Data is at address A0 and
                   the destination is A1
 - ICE_UNP2.S      Unpacking routine. Packed data is at address A0 and the
                   data is unpacked to this same address. The 120 bytes
                   buffer is no longer neeed, but instead 120 bytes are
                   temporarily reserved on the stack.

There haven't been many great changes in Pack-Ice, but Fire-Pack was enhanced
with the shell and the fast packing algorithms.
To notify changes, I changed the Ice!- and Fire-identifications for packed data
to "ICE!" and "FIRE" (before: "Ice!" and "Fire").
The highest offset for Fire-Pack is $ffff.
The default offset is $2500. If you set the offset higher, you will have the
same speed for the pure packing, but the short interuptions for setting up the
compression tables (like at the beginning of packing when 99% is shown for
about 1 second) will occur more often. To be exact, this break will appear
every ($8000-offset) bytes, but that doesn't slow down packing too much. 
But I warn you to set the offset higher, because then packing is as slow as 
the old Fire-Pack versions (yawn).


Now, as long as I haven't done Pack-Ice 3.0, these two packers are still the
best packers around. As you know, Fire-Packer is more efficient for bigger
files. If a file is bigger than 50kB, you can be almost sure that Fire-Packer
is better. When I pack a Sierra file I split the big files (in Codename Iceman
each about 1.8 Meg) into smaller files (18kB) and pack them with Pack-Ice AND 
with Fire-Pack and I always take the smaller file, so the files are half 
packed with each of the two packers. Then I put the small files together 
again and create big files again (in Codename Iceman 900 kB).

What I want to do to have beter compression is modifying the pack-informations
individually for each packed file, so that you get best compression. That 
would mean changing the tables that are in the pack and depack routines.
But every time I think of programming this, I realise that it is too difficult.
I hope I will manage to do this one day, because if I will then I promise that
no packer will be better.
I think that there still are 2 or 3 packers that are better than Fire-Pack 
(like this unpacking routine Jinx once sent me). Unfortunately I couldn't use
it very much, because I would have needed one packed file. I tried to find out
how the packer works, but it was impossible without a packed file. Anyway,
I won't need it anyway if I have done this improvement for Pack-Ice. Then you
won't need Fire-Pack anymore, just Pack-Ice. It will be the same speed at
unpacking, but it might take up to twice as long for packing, which will be
no problem, because packing is so fast now.
Ok, I hope that I can soon offer you the BEST packer. I will keep trying.

Bye for now....

Axe

