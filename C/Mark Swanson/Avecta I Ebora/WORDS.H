/***************************************************************************/
/* The rules for entering the text lines is as follows:  Each dungeon is   */
/* given eighty rummsg entries and 80 msg entries.  Recall that the first  */
/* 80 msg entries are open, to be used for examining the portable objects. */
/* The first 40 msg slots are called in the program when outside and,      */
/* except by trapres!  The next 40 are reserved for the objects between    */
/* 41 and 80.  The next 80 msg slots belong to dungeon #1, etc.            */
/***************************************************************************/

char *rummsg[] = {"",
                   /* #1 */
"-> This is a dimly lit hallway.  The floor is rotting and swarming with \
insects.  A sense of unease permeates the air.",
                   /* #2 */
"-> This room is strangely lit, and piles of trash can be seen.",
                   /* #3 */
"-> This is a narrow dark corridor.",
                   /* #4 */
"-> There is a charnel house stench in this room.  Remains of ghastly meals \
litter the floor.",   
                   /* #5 */
"-> An acrid smell permeates the air, and numerous bits of clothing and \
shoes lie about on the floor, half dissolved.",
                   /* #6 */
"-> This room looks like a kitchen for preparing some unspeakable meals.",
                   /* #7 */
"-> This room is dominated by a huge statue of a repulsive character.",
                   /* #8 */
"-> This room is hideously hot. Intense pain from the heat begins immediately. \
Various ironworking forges can be seen.",
                   /* #9 */
"-> This room is dark but reeks of animal droppings.",
                   /* #10 */
"-> It is quickly evident that this is the bedroom for \
the goblins who work at the forges.  It exhibits the usual level of goblin \
untidiness.",
                   /* #11 */
"-> This is a small closet, the floor littered with trash and odd, useless \
objects stacked precariously against the walls.",
                   /* #12 */
"-> This room holds a number of tables and fireplaces with the greasy food of \
which goblins are so fond stewing in pots.  No quiche eaters these fellows.",
                   /* #13 */
"-> This room is intensely dark.  The darkness has a malevolent presence to it,\
 as if it was alive and angry.",
                   /* 14 */
"-> This room is dark.",
                   /* 15 */
"-> This room is musty-smelling, but with a hint of some exotic perfume.  It \
has the feeling of something old and antique, yet evil.",
                   /* 16 */
"-> There is the smell of strange chemicals in the air, as well as benches with\
 arcane equipment.",
                   /* 17 */
"-> This is a long, winding tunnel whose stone walls and floor are cold to the \
touch.", 
                   /* 18 */
"-> This room is dark, with nothing visible.",
                   /* 19 */
"-> There is a feeling of intense evil having been \
committed here. The accoutrements of evil abound: pentagrams, arcane runes, \
and a hideous coldness to everything.",
                   /* 20 */
"-> This room smells horrible, as if some huge, unwashed creature \
had inhabited it for long time.",
                   /* 21 */
"-> A sign on the door of this room states `Duplicator Room.  Unau\
thorized Use Will Lead to Immediate Torture and Death. This Means YOU! - \
MELKTHROP'",
                   /* 22 */
"-> This room is very cold and dark.",
                   /* 23 */
"-> This tunnel appears to be an emergency escape from the building.  From its\
 appearance it has never been used before.",
                   /* 24 */
"",
                   /* 25 */
"","","","","","",
/* 31 */
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
/* 81  Dungeon #2 = Kilkaney */
"-> The room is the entrance or exit archway to the walled city of Kilkaney.",
"-> The courtyard of the city is dominated by a large fountain.",
"-> This is a stone walkway connecting the courtyard to the market square.",
"-> This shop specializes in torches of all variety. Various tables hold \
torches being cut and bound.",
"-> This is the shop of a fletcher. Handsome bows line the wall, as well \
quarrels of arrows.",
"-> The market square features many tables of wares. A prominent sign warns \
of the consequences of using magic or attempting theft.",
"-> This is a walkway through the more rundown section of town. A sign at the \
west end of the street proclaims the entrance to the town dump.",
"-> The bar room of the Red Lion smells of spilled ale and hearty stew. Tables \
and chairs are spread about, as well as a sign prohibiting magic use on the \
premises.",
"-> This is a narrow hallway leading to the Red Lion's rented rooms.",
"-> The small room possesses a reasonably comfortable looking bed and a trunk.",
/* 11 */
"-> The small room possesses a reasonably comfortable looking bed and a trunk.",
"-> The small room possesses a reasonably comfortable looking bed and a trunk.",
"-> The Kilkaney dump is a horrid place, filled with garbage heaps of all \
sorts. A terrible stench fills the air.",
"-> This is a walkway through the somewhat seedier section of town.",
"-> This is the apartment of a pair of rogues who specialize in smuggling.",
"-> This deserted apartment feels cold and threatening.",
"-> This is a small walkway connecting the market square to the park.",
"-> This is a small park which lies at the entrance to the Duke of Kilkaney's\
 living quarters.",
"-> This is the sumptuous quarters of the Duke of Kilkaney. Lavish tapestries, \
comfortable chairs, and expensive rugs fill the room.",
"-> This is a swordmaker's shop. Scimitars of all variety line the walls. A \
sign proclaims `Better steel and no magic.'",
/* 21 */
"-> This shop specializes in magic power potions. Posters on the wall depict \
powerful men drinking potions.",
"-> This is a walkway on the more expensive side of town.",
"-> This is the apartment of a well-heeled older rogue, a fellow who was \
quite an adventurer in his day.",
"-> This is a walkway of no particular note.",
"-> This is a long, dark corridor.",
"",
"",
"",
"-> Is this a dream? The room is strangely empty, full of dust, with no \
trace of Leveth, the memory of whose words seems to ring as if they were \
just spoken.",
"-> This is the room of a powerful mage. Various retorts and bookshelves can \
be seen lining the walls.",
"-> This subterranean room is cold and damp. It is difficult to imagine \
anything human living under these circumstances.",
"",
"-> This is a cold, dark room. A sense of supernatural terror seems to emanate \
from the very stones.",
"","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
/* 161 Dungeon #3 = Cave */
/* 1 */
"-> This is a typical dingy cavern entrance. Several fires are burning to\
 provide illumination. Discarded and well-chewed bones litter the floor.",
/* 2 */
"-> This room is dark with the smell of undisposed garbage permeating the \
air.",
/* 3 */
"-> This room is dark.",
/* 4 */
"-> Several fires are burning here, and several garbage heaps lie along \
the floor.",
/* 5 */
"",

"",

"",

"",

"-> This appears to be an orc dining hall.",

"-> This is a sleeping quarter for the orc soldiers.",
/* 11 */
"-> This is a bedroom of somewhat better furnishings than usual for orcs.",
"-> This is the kitchen of the orcs. Various greasy concoctions are cooking in \
the stoves, and the nauseating smell of burnt flesh hangs in the air.",
"-> This is a dining hall and meeting hall for the orcs.",
"-> This appears to be a very nice room for an orc. The furniture and finishing\
s are unusually expensive.",
"-> This is a long dark corridor.",
"-> This strangely lit room contains a powerful looking machine in its center.",
"-> This room is ankle deep in revoltingly filthy water.",
"-> There is an eerie quality to this room, as if something terrible had \
happened here long ago.",
"-> This room is ankle deep in slimy foul-smelling water.",
"",
/* 21 */
"",
"-> This room smells of animal droppings.",
"","","",
"-> This room smells of decay and evil. There are the signs of intelligence, \
bookshelves and desk, but an air of evil pervades the room.",
"","","",
/* 30 */
"-> This room is extremely hot. Several fires are dancing in the corners, \
almost as if they were alive.",
"-> This room is the home of flamers and is therefore intolerably hot.",
"-> This room is evidently a store room for the flamers, whose material needs \
are few.",
"-> There is a strange quality to the darkness of this room, as if it is \
cloaking something.","","","","","","","",""};

char *msg[] = 
{"the ",
                    /* #1 */
"-> This strange clearing holds a hole.",
                    /* #2 */
"-> A group of wrecked wagons litter this clearing. Some are burned, others \
ransacked.",
                    /* #3 */
"",
                    /* #4 */
"",
                    /* #5 */
"",
                    /* #6 */
"",
                    /* #7 */
"",
                    /* #8 */
"",
                    /* #9 */
"",
                    /* #10 */
"",
                    /* #11 */
"",
                    /* #12 */
"",
                    /* #13 */ 
"",
                    /* #14 */
"",
                    /* #15 */
"",
                    /* #16 */
"",
                    /* #17 */
"",
                    /* #18 */
"",
                    /* 19 */
"",
                     /* 20 */ 
"",
                     /* 21 */
"",
                     /* 22 */
"",
                     /* 23 */
"",
                     /* 24 - the potion */
"",
                     /* #25 - the diary, room 8 */
"",
                    /* #26 - the orb, room 10 */
"",
                     /* #27  -  the book */
"",
                     /* #28 */
"",
                     /* #29 - the key to the thrang's lair */
"",
                     /* #30 - the pentalex */
"",
                     /* #31 - ring of protection   */
"",
                     /* #32 - the X-shaped mesmerune */
"",
                     /* 33 - the talking head */
"",
                    /* 34 - trunk scroll */
"",
                    /* 35 - thrang scroll */
"",
                    /* 36 */
"",
                    /* 37 */
"",
                    /* 38 */
"",
                    /* 39 */
"",
                    /* 40 */
"",
                    /* 41 */
"-> The mighty broadsword is incredibly heavy.  Its pommel is inscribed with \
arcane runes, hinting at the possibility it was forged by magicians or \
worse. Its heaviness appears to be magical, as if strength is not the only \
factor in lifting it.",
                    /* 42 */
"-> The scimitar is like all its brethren, a worthy instrument of combat, \
razor sharp and ready.",
                    /* 43 */
"",
                   /* 44 */
"-> The dagger, while not terribly effective, can still be lethal in close \
combat.",
                   /* 45 */
"-> The bow, of indeterminate origin, is difficult to use without practice, \
nevertheless, terribly effective at long distance.",
                   /* 46 */
"-> The key is fashioned from bone, a true skeleton key.",
                   /* 47 */
"-> Careful inspection reveals the tarnished button was once on the boot of \
Avag Daargath, head trainer at the school for unruly gorks.  As such it has \
sent many a gork reeling in terror as the button was applied to its backside.",
                   /* 48 */
"-> The rusty key reads `Room 3 - Bates Motel - Return to Norman Bates and \
receive a free night at the Bates Motel.'",
                   /* 49 */
"-> The rune is surrounded by an electrical aura that causes the skin to \
prickle and the hair to stand on end.",
                   /* 50 */
"-> The black key is made from obsidian and has the inscription 'Unlawful \
possession punishable by Melkthrop himself.'",
                   /* 51 */
"-> The glowing tongs put off a hideous heat.  Written on the side in glowing \
letters is 'Another Fine Torture Instrument, Copyright Melkthrop Forges, Inc.'",
                   /* 52 */
"-> The rod has a set of pulsating colors on its surface.  Written on the side \
is `Guaranteed Rod of Abeyance.  Warranteed against Spirits of Darkness and \
Nocturnal Forms.  Leveth Magic Works, Inc.'",
                   /* 53 */
"-> The bottle of bourbon carries the label 'Old Scratch Bourbon - Best \
Damned Bourbon You Can Buy!'",
                   /* 54 */
"-> The poster shows a hideous demon pointing a scaly finger toward the viewer \
with the caption 'MELKTHROP WANTS YOU TO SEE HIS ECTOPLASMIC CONVERTER!'",
                   /* 55 */
"-> The potion bottle reads 'Temporary Mana Abnegator - Use only as Directed by\
 Your Local Magician - another fine product from Lord Vindroble.'",
/* 56 */
"-> The garlic clove, having just been freshly cut, reeks so profoundly it \
would terrify even the most ravenous vampire.",
/* 57 */
"-> This weird device gives absolutely not one hint of its use.  It possesses \
fins which jut out from each side, while along the side is written 'Insert \
along the stasis line and turn to the right. Stand clear on the dorsal side.'",
/* 58 */
"-> The bag of rocks probably serves as ballast for some of the more \
light-headed residents of Avecta, of which there are an inordinate number.",
/* 59 */
"-> The note, abandoned by a previous visitor to the monastery, reads `There is\
 a bone key in the garbage for you. Your wife and children \
are safe in my keeping. I am sure they miss you. Please visit them. \
Melkthrop the Merciful.'",

" -> The note written in angry scrawl reads `Any goblin found guilty of not \
covering the hidden stairwell with the middle forge will be used at the weekly \
sacrifice! - signed Melkthrop the Merciless'.",

"-> This is an old bone of indeterminate origin. It serves as a ritual bone \
 for the goblins, reminding them of all their victory meals in the past as \
they beat the victory drum with it.",

"-> The mighty tome entitled 'Melkthrop's Memoirs' pompously details the career of\
 the demon Melkthrop, his 'fall' from grace in Hell, and his plans to use the \
ectoplasmic converter to return. It mentions a secret door in the machine \
room.",

"-> Looking at this key induces a sense of nausea and dread. Strange and \
disorienting patterns are cut in the metal which convey a sense of vileness.",

"-> The thick book is labelled Wethwicker's All the World's Spells. It is full \
of strange symbols and tables, inexplicable diagrams, odd lists, and unpronoun\
ceable incantations. At the end it contains a 224 page theory of magic due to \
Wethwicker and others.",

"-> This mask seems to be cut in the form of an orc's face. Along one side is \
written `Property of Guldor Ragoth. Return to Capetown Immediately.'",

"-> The black ball has written on its surface `Store only in a dark place. \
When firing keep eyes safely covered. Good for one use only. Manufactured by \
the King's Torpedo Works, Bromley, Chale.'",

"-> The note written in claw marks and blood reads `I, Gondrath, in service of \
Hissar Zul, do proclaim Melkthrop to be recipient of the benefits and entitle\
ments due him upon the arrival of the Dark One, the New God, the Avatar of \
Despair'.",

"-> Well, congratulations, you made it all the way through! But don't get a \
swelled head over it! New trouble is brewing and I'm sure it will probably \
involve you. After all, the forces of darkness have a long memory. Until then\
, happy adventuring!",

"-> The potion has a label depicting an extremely muscular man being admired \
by a bevy of scantily clad beauties. Written underneath is `Laglolly's Elixir\
 of Power'",
"-> The heavy bag bulges as if it were full of small hard disks.",
"","","","","","","","","",
"-> The seekshard is an infallible mechanism for imprinting the structure of \
the local spacetime for later use in a teleport spell. Instructions on the \
side read 'Simply place the seekshard on the floor of the room. Report any \
malfunctions to Leveth Magic Works, Inc.'",
      /* first dungeon messages */
            /* 81 */
"-> The trash is full of discarded human clothing, belts, shoes, and \
personal effects. It is not clear if they were dropped on the way into or \
out of the monastery.  However, nothing is the right size, so don't get \
excited.",
            /* 82 - Dungeon 1, msg 2 */
"-> The garbage ominously consists of bones of all sizes. They appear to be\
 well-chewed, and not by dogs, judging from the shape of the teeth marks.",

"-> This table is definitely on its last legs. Bad puns abound in Avecta.",

"-> A pack of hideous ghouls, busy comparing the size of their bellies, turn \
toward the door, slavering at the thought of an \
in-between-meal snack.",

"-> The skeleton is a cherished reminder of the ghouls' favorite meal, an ogre\
 named Bumblesnitch, who blundered into the room near dinnertime looking for a \
good time, and, needless to say, didn't find one.",

"-> A group of hairy spiders descend from the ceiling. Spiders are always \
unpleasant when they're hungry, and this group is just about starved.",

"-> The statue of an impossibly vain-looking demon stares out above a plaque \
warning `MELKTHROP SEES ALL!' It's probably true that he takes notes on it \
too.",
/* 88 */
"-> The door possesses an obvious keyhole.  Eirik's familiar voice comes from \
the other side, `Crom!  My luck still holds!  Melkthrop will not drink my \
soul, but my blade shall have his!'",

"-> A group of goblins clad in asbestos suits spin from their work at the \
forges and prepare for battle against the intruder. One of them curses and \
says `Melkthrop better give us combat pay for this.'",

"-> A pack of screeching bats descends on the intruder!",

"-> The goblin beds are ghastly in their filth, but then goblins don't spend \
much time on personal hygiene.  In fact, goblins spend most of their time \
arguing, drinking, and playing cards, which they cheat at relentlessly.",

"-> This is a pile of abandoned goblin garbage, including chewed bones and \
asundry unidentifiable pieces of offal. Or is it `awful'? I warned you about\
 the puns.",

"-> Several goblins, busy gobblin' some slumgullion, turn toward the \
intruder. One wipes his face on his sleeve, grabs his mace, and shouts \
`Assault and battery is my middle name!' Of course, that's three middle \
names, but goblins never could count.",

"-> The desk contains reams of bad doggerel, evidently the product of a \
lovesick vampire.  One memorable line sticks out `Violets are blue, \
blood is red, O come to me, come to me, my darling undead.'",

"-> The statue of the demon is recognizable as the same one as in the room \
with the `death' riddle, but here it seems to be guarding against something.",

/* 16 */
"-> An aged but powerful vampire shrieks `How dare you interfere with my grand\
 literary endeavours!  I was just finishing an ode of tribute to Melkthrop!  \
You shall pay for this, or at least show some collateral!'",
/* 17 */
"-> The garbage holds reams of discarded foolscap, failed attempts at both \
poetry and Melkthrop's memoirs.  Some of the discarded papers detail how \
Melkthrop has finally obtained the Onesword, the only material weapon which \
can harm him, and now feels immune to human meddling.",
/* 18 */
"-> Somewhere in school you learned that an ectoplasmic converter is used to \
extract the spiritual essence of the\
 victim, storing it in an iesis chamber.  An open slot on the side reads \
`INSERT THE NEUTRALIZER DEVICE ONLY TO PURGE THE IESIS CHAMBER'",
/* 19 */
"-> Hanging from the door is the note `Any goblin stupid enough to enter this \
room will be promptly killed by a gork trained by Avag Daargath himself! \
This gork guards the Onesword, so watch it! - signed Melkthrop the \
 Mean'",
/* 20 */
"-> A sign above this ruin reads `Receiver Rune.  Unlawful duplication is \
punishable by law.  See the copyright laws before using this \
rune for duplication.'",
/* 21 */
"-> A sign above this rune reads `Donation Rune.  The sandestin \
trapped in the donation rune is very capricious and hard to please.'",
/* 22 */
"-> The altar is covered with demonic symbols.  Chiseled in the side \
`I am invincible. Melkthrop will rule in Hell in his own time!'",
/* 23 */
"-> The barrel holds the favorite objects of goblins, pretty rocks.",
/* 24 */
"-> The laboratory table is covered with strange equipment upon strange \
runes.  There is some indication that it is used to prepare the victims of \
the ectoplasmic converter.",
/* 25 */
"-> A horrid voice is heard to rasp `Who invades Melkthrop's domain?'",
/* 26 */
"-> The gork appears, huffing and drooling, ready to defend its turf.",
/* 27 */
"-> The skeleton has strangely fibered bones, twists of colored material \
running through them.  It is possible that this skeleton is that of a plane \
stalker.",
"-> The door contains a keyhole. In small letters above the keyhole is a \
message saying `Do not enter!' The door is hot to the touch.","","",
"-> The door possesses an obvious keyhole. A sign above the door reads \
`Deliver captives only on Thursday'.",
"","","","","","","","","",
/* 41 */
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
/* 81  begin kilkaney */ 
"-> The door is locked. It obviously leads to a private residence.",
"-> The door is sealed with a padlock from the Kilkaney Guards.",
"","","","","","","","",
/* 11 */
"","",
"-> A pack of giant rats bursts from the garbage heaps of the dump! Hissing \
and spitting they attack!",
"-> The sign reads `This building is condemned. Supernatural events have \
been reported. Trespassing is perilous and hereby forbidden. The Kilkaney \
Guards.'",
"-> The sign reads `Magic is prohibited on these premises. Use thereof will \
be detected and arrest will follow immediately. The Kilkaney Guards.'",
"-> The sign advertises `Fletchery - Fine Bows and Arrows - Reasonable Prices\
 - Brian McArtle, Proprietor.'",
"-> The sign advertises `Torches - Long Burning and Smokeless- Michael O'Vend, \
Proprietor'.",
"-> The sign reads `Blademaster - Finest Steel - Shamus McGee, Steelmaster.'",
"-> The sign reads `Magic Potions - Elixirs of Strength - Axel Laglolly, \
Proprietor'.",
"-> The sign outside the tavern depicts a red lion roaring. Legend has it that\
 the original owner named the tavern after one of the creatures who perpetual\
ly inhabited his attacks of delirium tremens following lost weekends.",
/* 21 */
"-> The sign reads `Town Dump - Do not enter alone as there is considerable \
danger from rats. Collection times are Tuesdays and Thursdays, from 1 to 4. \
The Kilkaney Guards.'",
"-> The garbage contains the usual refuse of a city, items ranging from \
old clothes to broken pots.",
"-> The aging rogue looks up in surprise, `Well, well!' he says.",
"-> The two rogues look quite shocked.",
"-> The case holds a large selection of exotic liquors.",
"-> The case holds a large selection of scimitars.",
"-> The case holds a vast selection of potions.",
"-> The case holds a fine collection of bows and arrows.",
"-> Numerous bunches of torches can be seen.","",
/* 31 */
"","",
"-> With a terrible wail the spirits attack! `Get out! Get out!' one of \
them moans.","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
/* 161 begin the cave */
/* 1 */
"-> A group of hefty orcs grab their blades! One snarls `Dis one's no \
member of da Orcs of da Bloody Blade! Leave us show who runs dis toif!'",
"-> Orcs appear! One slaps the other on the arm and growls `Dere's a hoomin! I\
 toldja I hoid a fight! But ya never lissen!'",
"",
"-> A group of orcs busy arguing about who has kitchen duty turn on the \
intruder! \
One groans `Kripes! Lefty and his boys musta gone ta sleep at the door again!\
 Now us hasta clean up da mess!'",
"-> A skull and cross-bones covers the lid of the trunk, and for the occasion\
al literate orc is written `Youse guys stay out!'",
"",
"",
"",
/* 9 */
"-> A pack of the orcs' favorite pets, firewolves, is enraged by the presence \
of the unfamiliar intruder! Snarling, the pack attacks!",
"-> A group of orcs roll out of their beds rubbing their eyes! One grabs his \
tulwar and growls `Dis is da last straw! I can't even cop some Z's but whud \
some hoomin comes bustin' in!'",
/* 11 */
"-> A pair of orcs are discussing in low voices. `So, da way I sees \
it, da old boy ain't got much longer. Now, it's gonna be between you and me, \
and I can't see no reason why we can't work sumpin' out ... But whud! Who's \
dat! A stinkin' hoomin!'","","",
/* 14 */
"-> An elderly orc stands up and mutters `Dis is it! Da head of heads, and I \
gotta fight my own fights! Dis is a lack of respeck, and I'm not gonna take \
dis lyin' down.'",
"","","",
"-> A group of specters appears! One of them moans `The warmth of life ... \
the warmth ... surrender it to us.'",
"-> A frightening, slithering, repellent, hissing, revolting, coiling mass of\
 reptilian terror appears!",
"",
/*21*/
"",
/* 22 */
"-> A group of snarling bats descends on the fresh meat!",
"","","",
/* 26 */
"-> A hideous thrang appears! It slowly cackles `I am the eternal thrang. \
Slay me and I shall return again. In the end I shall feed upon your flesh!'",

"-> The crusher appears! In all of Avecta this creature is only a legend! \
The crusher smiles idiotically and splutters `Oh boy! Oh boy! A cute little \
human! I want to hug it and squeeze it and pet it and mash it!'",
"","",
/* 30 */
"-> The flamers appear, crackling and hissing. One of their fiery numbers \
snarls `It is not incandescent. It seeks to usurp our last sacred home\
 ground. Let it die by pieces of our living flame.'",
"","",
"-> Ghosts appear wailing `Our gold! Our gold! You will not have it!'",
"-> The gigantic machine relentlessly swivels its metallic detector, sweeping\
 the room for evidence of any unorcish activity.",
"-> The stove contains a boiling pot of the orcs' favorite repast, lizard. \
This isn't exactly haute cuisine, but then orcs aren't exactly connoisseurs \
of much but mayhem and cheap thrills.",
"-> The desk contains an extensive record of crimes committed, dates, and \
payments. The last entry reads `Ambushed human caravan - found magic book - \
1000 GP - boys paid in full'",
"-> The trunk, evidently belonging to the crusher, has pictures of teddy \
bears and ducks drawn on its surface.",
"-> The bed is dishevelled, but the covers have a drawing of a powerfully built\
 orc waving a bloody blade over his head.",
"-> The trunk is standard issue orc, sturdy, but chipped and dented from \
years of constant abuse and whittling with knives.",
/* 40 */
"-> The garbage heap bears mute evidence of the squalor of an orc's life. Dis\
carded bones, bloody bandages, torn clothing, whiskey bottles, broken blades, \
and worthless knickknacks testify to the low-rent nature of these fellows.",
"-> The crusher's bed has broken springs from years of supporting such a mass.",
"-> Close examination of the fire reveals `baby' flamers scurrying about in \
the flames. Obviously the fire serves as an incubator for them.",
"","","","","","","",
"","","","","","","","","","",
"","","","","","","","","","",
"","","","","","","","","",""
};
