#!/usr/local/bin/perl
# HYP.PL --- Perl-Programm zum Sortieren von HyperTeX-Link-Dateien
# 12. Januar 1992 Anselm Lingnau
#
# Syntax:	perl hyp.pl foo.hyp >foo.hl
#
while (<>) {
	($page, $kind, $name) = split(/([>!])/, $_, 3);
	$def{$name} = "$page" if $kind eq '!';
	$ref{$name} .= "$page#";
}
@refs = sort keys %ref;
print scalar(@refs), "\n";
foreach (@refs) {
	$ref{$_} = join(':', &nodoubles($ref{$_}));
	$def{$_} = '0' if !defined $def{$_};
	print "$ref{$_}:$def{$_}:$_";
}

sub nodoubles {
	local(%seen);
	local(@ret) = grep(!$seen{$_}++, split(/#/, $_[0]));
	(scalar(@ret), @ret);
}

