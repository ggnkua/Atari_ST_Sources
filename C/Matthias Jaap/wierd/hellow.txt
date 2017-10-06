Just to illustrate exactly how sick I am, this took about three hours,
most of which was fidgeting with the editor to make the geometry work.

OK, I cheated a bit by:
	-- putting the text in the program
	-- using the fact that functions with an empty stack are
		essentially nops
And I didn't use anything nifty--no multithreading, genuine conditionals,
or anything of the like.  Just brute force.  I did, however, when I was
running out of space, "put" the coordinates in memory so I could just
"get" them later.

Anyway, I found at least one not-quite-as-advertised "feature" in the
interpreter.  The main one is that a zero on top of the stack does a put
of put and get, instead of the expected get, and a non-zero does get
instead of put.  Since I was doing more getting than putting in the
program, I was actually kind of happy, but that means the spec and my
comments are wrong (unless you *really* want to declare the least-trivial
piece of Wierd code written to date *and* the only currently implemented
interpreter non-standard...).  The others are really obscure things that I
can't figure out how to fix (the gap-jumping doesn't seem to quite work as
I understand it).

Well, I could probably strip out another couple of bytes here and there,
but I just don't have the stomach for it today...

Oh, Ben:  If you're going to try a 99-Bottles program, I'd suggest
expanding the playing field, since this program clocked in at just under
128x128...

Now I'm going to bang my head against a softer object for a while so I
don't notice the pain...

					--John

P.S.  Anybody besides me see the portrait of George Washington in the
program?  No?  I must be hallucinating, then...Oh, well...
