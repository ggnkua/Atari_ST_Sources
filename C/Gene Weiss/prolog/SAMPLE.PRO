VARIABLES(x,dummy)

goal() :- write_intro(),
	pause(),
	happy(Betty).

happy(x) :- message_1(),
		pause(),
		healthy(x),
		message_2(),
		pause(),
		wealthy(x),
		message_3(),
		pause(),
		wise(x),
		message_4().

healthy(x) :- message_5(),
		pause(),
		jogs(x),
		message_6(),
		pause(),
		diets(x).
wealthy(x) :- message_7(),
		pause(),
		has_a_rich_uncle(x).
wealthy(x) :- message_8(),
		pause(),
		investment_banker(x).
wise(x) :- message_9(),
		pause(),
		reads_philosophy(x).
jogs(Betty) :- message_10(),
		pause().
diets(Betty) :- message_11(),
		pause().
investment_banker(Betty) :- message_12(),
				pause().
reads_philosophy(Betty) :- message_13(),
				pause().

pause() :- write("Hit <CR> to continue\n"),
	read(dummy).
write_intro() :- write("this program looks like this:\n"),
		write("goal :- happy(Betty),\n"),
		write("happy(x) :- healthy(x),\n"),
		write("\t wealthy(x),\n"),
		write("\t wise(x),\n"),
		write("healthy(x) :- jogs(x),\n"),
		write("\t diets(x).\n"),
		write("wealthy(x) :- has_a_rich_uncle(x).\n"),
		write("wealthy(x) :- investment_banker(x).\n"),
		write("wise(x) :- reads_philosophy(x).\n"),
		write("jogs(Betty).\n"),
		write("diets(Betty).\n"),
		write("investment_banker(Betty).\n"),
		write("reads_philosophy(Betty).\n"),
		write("\nThe body of the first clause is 'happy(Betty)',\n"),
		write("so that's our goal\n").

message_1() :- write("\nWe've unified with clause 2, which tells us that\n"),
		write("in order to prove that Betty is happy, we need first to\n"),
		write("prove that she is healthy, wealthy, and wise\n").
message_2() :- write("\n'healthy(Betty)' has now been proven, so we go on to prove\n"),
		write("'wealthy(Betty)\n").
message_3() :- write("\nWe've now proven both 'healthy(Betty)' and 'wealthy(Betty)'\n"),
		write("so it only remains to prove 'wise(Betty)'\n").
message_4() :- write("\nAll of the goals have been proven, so the proof succeeded,\n"),
		write("and the interpreter gives us this message:\n").
message_5() :- write("\nWe'll now try clause three, which we can use to prove\n"),
		write("'healthy(Betty)'\n").
message_6() :- write(\n'jogs(Betty) has been proven, so we now have to prove\n"),
		write("diets(Betty)'\n").
message_7() :- write("\nWe're now trying to prove that Betty is wealthy by \n"),
		write("trying to prove that she has a rich uncle.  Unfortunately,\n"),
		write("she's not so lucky, so we'll backtrack and try another tack.\n").
message_8() :- write("\nThis time, we'll try to demonstrate Betty's wealth by showing\n"),
		write("that she's an investment banker.\n").
message_9() :- write("\nAt this point, we're trying to prove 'wise(Betty)' by\n"),
		write("proving 'reads-philosophy(Betty)'.\n").
message_10() :- write("\nWe now know that Betty jogs.\n").
message_11() :- write("\nWe now know that Betty diets.\n").
message_12() :- write("\nWe now know that Betty is an investment banker.\n").
message_13() :- write("\nWe now know that Betty reads philosophy.\n").
