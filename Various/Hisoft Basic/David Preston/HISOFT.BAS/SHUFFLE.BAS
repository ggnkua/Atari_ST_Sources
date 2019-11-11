defint a-z

dim shared deck(51)

randomize timer

restart:
cls

? "Shuffling demonstration - Hisoft/Power Basic"
? "By David Preston for ICTARI"
? : ?

reset_deck

t!=timer
deal_1
? "Loop...until method took";timer-t!;"seconds"
? : ?

reset_deck

t!=timer
deal_2
? "Swapping method took";timer-t!;"seconds"

? : ? : ?
? "Press <Esc> to quit or any other key to repeat"

do
	k$=inkey$
loop until k$<>""
if asc(k$)<>27 then restart

stop -1


sub reset_deck
static card
for card=0 to 51
	deck(card)=card
next card
end sub

sub deal_1
static card,this_card
for card=0 to 51
	do
		this_card=int(rnd*52)
	loop until deck(this_card)<>-1
	deck(this_card)=-1
	? this_card;
next card
? : ?
end sub


sub deal_2
static card,other_card
for card=0 to 51
	other_card=int(rnd*52)
	swap deck(card),deck(other_card)
next card
for card=0 to 51
	? deck(card);
next card
? : ?
end sub