use common::sense;

my @lines = <>;
my (%goto,%gosub);
my ($start,$len,$start18,$len18);
for (my $n=0; $n<=$#lines; $n++) {
	# le cas gosub 4000+n*10 : va de 4000 à 4640 ! trop long pour
	# un on n gosub p1,p2... donc on va remplacer par un switch
	# case, ce qui résoud aussi le pb des pop !!!
	# on va déjà extraire le groupe des lignes 4000 à 4640 pour le coller à
	# part dans le tableau g4000...
	if ($lines[$n] == 1800) {
		$start18 = $n;
		$len18 = 1;
	} elsif ($lines[$n] > 1800 && $lines[$n] < 4000) {
		$len18++;
	} elsif ($lines[$n] == 4000) {
		$start = $n;
		$len = 1;
	} elsif ($lines[$n] > 4000 && $lines[$n] < 5000) {
		$gosub{$1} = 1 if ($lines[$n] =~ /gosub (\d+)/i);
		$len++;
	} elsif ($lines[$n] >= 5000) {
		last;
	}
}
my @g4000 = splice @lines,$start,$len;

open(F,"<oric.lst");
while (<F>) {
	s/\r//;
	print;
}
close(F);
say "debut:";
foreach (@lines) {
	chomp;
	s/\r$//;
	s/ +$//;
	while (/(goto|then) ?(\d+)/gi) {
		my $lab = $2;
		$goto{$lab} = 1;
	}
	if (/goto break/i) {
		# dans la + pure tradition de la programmation spagetti la +
		# horrible... ils ont mis un goto break, avec break=xxx quand
		# ça les arrange, heureusement y en a pas trop, on arrive à
		# faire la liste !
		$goto{100} = $goto{300} = $goto{500} = $goto{530} = 1;
		my $s = "select(break):case 100:goto 100:case 300:goto 300:case 500:goto 500:case 530:goto 530:endselect";
		$s =~ s/\n$//;
		s/goto .+/$s/i;
	}
	while (s/GOSUB[ \(]?(\d+)/gosub $1/) {
		# subs spécifiques au dr genius
		my $sub = $1;
		my $on = "";
		for (my $n=1500; $n<=1580; $n+=10) {
			$gosub{$n} = 1;
			$on .= "," if ($on);
			$on .= $n;
		}
		if ($sub == 1500) {
			s/gosub.+/on li+1 gosub $on/i;
		}
		$on = "";
		for (my $n=7000; $n<=7240; $n+=10) {
			$gosub{$n} = 1;
			$on .= "," if ($on);
			$on .= $n;
		}
		if ($sub == 7000) {
			s/gosub.+/on salle gosub $on/i;
		}
		$gosub{$sub} = 1;
	}
}
my @g1800 = splice @lines,$start18,$len18;

my $for = undef;
my $num = 0;
my $end_sub = -1;
my $sub;
my $need_endsub;
foreach (@lines) {
	s/^ ?(\d+) //;
	say "$1:" if ($goto{$1});
	say "sarabande:" if ($1 == 30040);
	say "badin:" if ($1 == 31030);
	say "vars:" if ($1 == 8060);
	say "tea:" if ($1 == 32025);
	say "chars:" if ($1 == 33040);
	if ($gosub{$1}) {
		say "sub $1";
		$sub = $1;
		my $n=$num+1;
		my $end;
		my $line;
		do {
			$lines[$n] =~ /^ ?(\d+)/;
			$line = $1;
			if (!$gosub{$line}) {
				$end = $n if ($lines[$n] =~ /return/i);
				$n++;
			}
		} while ($n <= $#lines && !$gosub{$line});
		$end_sub = $end;
	}
	if ($num != $end_sub) {
		if (s/return/goto end_$sub/i) {
			$need_endsub = 1;
		}
	}
	handle_multi($_);
	$num++;
}

sub handle_multi {
	$_ = shift;
	my $handling_4000 = shift;
	my $handling_1800 = shift;
	s/then ?(\d+)/then goto $1/i;
	if ($handling_4000 && /goto ?(\d+)/i && $1 >= 4000 && $1 <= 4640) {
		# ils ont même collé un goto vers un autre numéro dans leur machin!
		my $num = ($1-4000)/10;
		s/goto.+/n=$num:goto g4000/i;
	}
	if (/"/ && $_ !~ /".*"/) {
		# Il y a des print qui ferment pas les guillemets là-dedans !!!
		$_ .= '"';
	}
	my @l = split /\:/;
	for (my $n=0; $n<$#l; $n++) {
		last if ($n == $#l);
		if (($l[$n] =~ /"/ && $l[$n] !~ /".*"/) || ($l[$n] =~ /v$/ && $l[$n] =~ /^(bget|bput)/) || $l[$n] =~ /^(rem|\')/i) {
			my $s = splice @l,$n+1,1;
			$l[$n] .= ":".$s;
			redo;
		}
	}

	my $num2 = 0;
	foreach (@l) {
		s/^ +//;
		if (/^if/i) {
			# on a un problème entre la séparation des : et des if...
			if ($num2 < $#l) {
				$_ = join(":",@l[$num2 .. $#l]);
				splice @l,$num2+1;
				redo;
			}
		}
		$num2++;

		if (/^if(.+?)then(.+)else(.+)/i) {
			my ($cond,$true,$false) = ($1,$2,$3);
			say "if $cond then";
			$true =~ s/^ +//;
			handle_multi($true,$handling_4000,$handling_1800);
			say "else";
			$false =~ s/^ +//;
			handle_multi($false,$handling_4000,$handling_1800);
			say "endif";
			return;
		} elsif (/^if(.+?)then(.+)/i) {
			my ($cond,$true) = ($1,$2);
			say "if $cond then";
			$true =~ s/^ +//;
			handle_multi($true,$handling_4000,$handling_1800);
			say "endif";
			return;
		}
		next if ($handling_4000 && /^(return|pop)/i);
		next if ($handling_1800 && /^pop/i);
		if (/^return/i && $handling_1800 && $need_endsub) {
			say "end_case_$sub:";
			$need_endsub = 0;
		}
		if (/^return/i && $num == $end_sub && $need_endsub) {
			say "end_$sub:";
			$need_endsub = 0;
		}
		s/^return/' return/i if ($handling_1800); # tranformé en case -> plus de return !
		s/poke ?\#([\da-f]+)/poke \$$1/i;
		s/(poke.+), ?\#([\da-f]+)/$1, \$$2/i;
		s/^poke ?(.+),(.+)/mypoke\($1,$2\)/i;
		s/^input ?(.*);(.+)/myinput($1,$2)/i;
		s/^paper ?(.+)/paper\($1\)/i;
		s/^ink ?(.+)/ink\($1\)/i;
		print "' " if (/^(himem|call)/i);
		s/key\$/UPPER\$\(inkey\$\)/gi; # à priori majuscules c'est mieux
		s/^wait ?(.+)/delay $1\/80/i;
		s/^music ?(.+?),(.+?),(.+?),(.+)/sound $1,$4,$3,$2+1/i;
		s/^play ?(.+?),(.+?),(.+?),(.+)/wave $1,$1,$3,$4\*200/i;
		s/^curmov ?(.+?),(.+)/curmov($1,$2)/i;
		s/^circle ?(.+?),(.+)/mycircle($1,$2)/i;
		s/^curset ?(.+?),(.+?),(.+)/myplot($1,$2,$3)/i;
		s/^draw ?(.+?),(.+?),(.+)/mydraw($1,$2,$3)/i;
		s/^cls/mycls/i;
		if (s/^print(.+); *$/myprint\($1\)/i) {
			reproc_print()
		}
		if (s/^print(.+)$/myprintln\($1\)/i) {
			reproc_print();
		}
		$for = $1 if (s/^for ?(.+?)=(.+?)to/for $1=$2 to /i);
		$for = undef if (s/^next *$/next $for/i);
		if (/^plot ?(.+?),(.+?),(.+)/i) {
			if ($3 > 0) {
				s/^plot/' plot/i;
			} else {
				say "print at($1+1,$2+2);$3";
				next;
			}
		}
		s/^(.+) '(.+)/$1!$2/; # les commentaires de fin de ligne commencent par ! au lieu de ' en gfa !

		s/^get ?(.+\$)/$1 = upper\$(chr\$(inp(2)))/i;
		if (/^print.*?"(.+)"/i) {
			# adaptation 40 colonnes -> 80 colonnes
			my $s = $1;
			if (length($1) > 38 && substr($s,36,1) ne " ") {
				$s = substr($s,0,38)." ".substr($s,38);
			}
			$s =~ s/ +/ /g;
			s/^print(.*?)"(.+)"/print$1"$s"/i;
		}
		if (/^gosub ?4000.+/i) { # le cas très particulier du gosub 4000+n*10 !
			# on aurait adoré remplacer ça par un gosub handle_4000, sauf
			# qu'il y a 2 pop et des goto en dehors de la zone des 4000 !
			# Du coup il faut coller ça au même niveau, pas de gosub... !
			say "g4000:"; # obligé pour les goto dans la même zone, on boucle sur le select dans ce cas !
			say "select n";
			my $index = 0;
			for (my $n=0; $n<=64; $n++) {
				say "case $n";
				while ($index <= $#g4000 && $g4000[$index] < 4000+$n*10+10) {
					$_ = $g4000[$index++];
					chomp;
					s/\r$//;
					s/ +$//;
					s/^ ?(\d+) //;
					handle_multi($_,1);
				}
			}
			say "endselect";
			next;
		} elsif (/^gosub 1800/i) { # et celui du 1800 !
			say "select li";
			my $index = 0;
			for (my $n=0; $n<=15; $n++) {
				say "case $n";
				my $end = -1;
				my $old_index = $index;
				# dans le cas de 1800, y a des return prématurés, embêtant
				# vu qu'on les a transformés en case ici, donc faut faire
				# un goto end_case ce coup là, assez prise de tête, mais y
				# en a pas tant que ça, heureusement. Utilisé pour la
				# commande inventaire par exemple.
				while ($index <= $#g1800 && $g1800[$index] < 1800+$n*100+100) {
					$end = $index if ($g1800[$index++] =~ /return/i);
				}
				$index = $old_index;
				$need_endsub = 0;
				while ($index <= $#g1800 && $g1800[$index] < 1800+$n*100+100) {
					$_ = $g1800[$index++];
					chomp;
					if ($index != $end && s/return/goto end_case_$n/i) {
						$need_endsub = 1;
					}
					s/^ ?(\d+) //;
					say "$1:" if ($goto{$1});
					$sub = $n;
					handle_multi($_,0,1);
				}
			}
			say "endselect";
			next;
		}
		say $_;
	}
}

sub reproc_print {
	while (s/chr\$(\(.+?\))(chr|")/chr\$$1\+$2/gi) {}
	while (s/spc(\(.+?\))"/space\$$1\+"/gi) {}
	if (/;/) {
		my @t = split(/;/);
		for (my $n=0; $n<=$#t; $n++) {
			if ($t[$n] =~ /"/ && $t[$n] !~ /".*"/) {
				my $s = splice @t,$n+1,1;
				$t[$n] .= ";".$s;
				redo;
			}
		}
		foreach (@t) {
			s/^([a-z0-9_]+)$/str\$($1)/i; # remplacer variables numériques par str$()
		}
		$_ = join("+",@t);
	}
	if (/,/) {
		my @t = split(/,/);
		for (my $n=0; $n<=$#t; $n++) {
			if ($t[$n] =~ /"/ && $t[$n] !~ /".*"/) {
				my $s = splice @t,$n+1,1;
				$t[$n] .= ",".$s;
				redo;
			}
		}
		foreach (@t) {
			s/^([a-z0-9_]+)$/str\$($1)/i; # remplacer variables numériques par str$()
		}
		$_ = join("+\"   \"+",@t);
	}
}

