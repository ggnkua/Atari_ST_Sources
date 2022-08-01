
Hi there, this little hack is an extremely quick port of the Amiga
file packer "File Imploder".

Background:
I was talking to Claude about packing on Jaguar cartridges when he
mentioned that he used an Amiga packer called "File Imploder". I told
him to send it to me for closer inspection. He did, I disassembled it
to pieces, rewrote the malloc/memfree code and added the worst user
interface so far in Atari history. Some quick testing showed that it
is in fact not any better than Ice or Atomik (best) though, so I'm not
going to put much time into this. It might be useful for someone out
there though, so I'm releasing it as it is with source (if you find a 
bug, fix it yourself :) The source is a mess though, but what do you
expect from someone with 'hack' as part of his nickname :)


Usage:
Very simple. Install it as a .ttp taking full-pathname. Then simply 
drag any file onto the imploder.ttp icon. Various things will happen 
depending on the type of file:

1) Unknown filetype -> Is simply packed and saved using original name.
2) Executable file  -> The file is packed and you can select to save it
                       as a data or exectuable file.
3) Packed file/prg  -> Depacked and saved using original name.


Smartasses with amigas might know that you can select pack-methods 
from 0-11 on the amiga version. I've locked my version in mode 11 which
packs best.

Compatibility:
Only tested on my Falcon, but it assembles in 68k without warnings so 
it should run on ST. A fair bit of memory is probably needed. There
is hardly any error checking so if it crashes it's probably caused by 
lack of memory or write protected files. I don't use Mint.

Legal stuff:
Do whatever you want with this as long as you keep the files together
and remember that I am in no way responsible for any trouble you might
get into using this program.

Enjoy,

Torbjorn 'Hackbear/Digital Chaos' Ose - to@hihm.no - Hackbear/#Atari

Thanks to Claude/ Visual Impact BVBA for the Amiga binary + depack 
source.
