Ballistix - a cracking history by KrazyK

This was the first game I ever cracked and filed way back in 1990 when I was just starting to learn 68000, so the code was a bit lame. 
But i've recently re-discovered it and re-wrote most of it and now it makes more sense.

This was one of the first games I bought that had no files on the disk.  A bootsector loader that then loaded more tracks and sectors.  What the hell?
A word with some of my swapping pals at the time (Hoskas, Frosty) and I then acquired some useful tools and programs to help me on my way!
After many hours of failing miserably and the keyboard locking up (green as grass I was) I  found that it was a TRAP #14 Floprd command that did the sector loading.
What if I could find where that command was being called from then save the data out to another floppy?
More time passed. I eventually found all the calls made to Floprd and I eventually dumped the whole disk as a file by changing a few bytes in the code.  Genius I thought to myself
Also found the simple disk check that threw you to an ILLEGAL if it failed.  Simple to remove that one.
But what do I do now and how do I make it load and run or make it smaller to fit on a menu?

By now I was quite intimate with the workings of this game and it goes something like this:
Bootsector loads the first bit of code to $30000 and runs it.
The various loading screens,and font are loaded along with the roll down image.
More sprites, the pitch, and some sin/cos tables are loaded after the rolldown image.
The second main bit of code is loaded at $15800 and part of it is decrypted using a EORI.W command so that it reveals the main disk check routine at $199CA.  
That's why you can't find it with a disk editor - stoopid!
The disk protection is called by changing byte $19DBE to 1, running the disk check subroutine at $199CA and comparing it to 0 afterwards.  
If it fails you get thrown to an ILLEGAL command that was decrypted earlier. Simple to remove by BRA.S over it and bypassing it altogether.
The main screen is loaded with the 3d joysticks spinning and when you press a button the next disk check is done and more data loaded along with the sample.

The game is loaded quite high in memory compared to some other games, as I discovered later, (Stormtrooper loaded down to $8  !!!) so I could still use TRAP #1 for file saving quite easily.
Now that i've re-discovered the code again i've re-written most of it, the whole disk data is loaded to $82000 and depacked using Atomic 3.5 and the memory loading code to $80000 for the 1mb version.
Luckily the game doesn't trash the TRAP #1 calls so I could dump files out too each time the game loaded sectors, so I could then have a filed version that would work on a 520STF.
I experimented in dumping each bit of loaded data separately then writing some code to load those files, but it failed after the main loading screen for some reason.
Turns out the memory that the loader was using was being over-written by the game data so I had to relocate it elsewhere.
The game is patched and cracked on the fly so you can see what had to be done to crack it.
All the code I've used is in the zip file for anyone to mess with and also as a preservation method as I only discovered this disk when a mate sent it to me from one of many boxes in his loft.
Probably lame compared to most of you cracking/coding experts, but back in 1990 when I first loaded up that blank screen in GenST and thought "What the hell do I do now?", then this was my finest work.
I'm going to pay him a visit soon to see what other goodies he has, as he was my library back in the day when we were messing about with Stos and assmebler and most of what I did he copied and preserved.
Now to re-discover some other code, like Sabre Team and the multi-trainer I did for it.  Now where is that disk....
