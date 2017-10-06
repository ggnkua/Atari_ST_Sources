100 rem RANDOM.BAS -- Test RANDOMIZE and RND
110 print "This is a first sequence of three RND numbers:"
120 randomize timer
130 print rnd
140 print rnd
150 print rnd
160 print "This is a second sequence of three RND numbers:"
170 randomize timer + 18
180 print rnd
190 print rnd
200 print rnd
210 print "The second sequence should have been differrent"
220 print "from the first."
