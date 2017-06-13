my %gates = qw(
	O P 0B T A0 2 00 T2 B0 TNU 0A 2XU 0| XUE &| XUY 0& XNE |& XNY |0 NUE &0 NXE
	<A XNUE BA XNUY B> NXUE ^& XUNUE &A XNUTY <0 XNUE2 <& XNU2U &^ NUXUE &> NXUTU
	0> NXUTE B& NXU2M && XUNUTY ^0 XUNUE2 A& XNUTNY 0^ NUXUTE &B NXU2XM
	>& XNUTNUE 0< XNUE2XU A< XNUEXNU >B XNUXNUE >0 NXUTENU &< NXU2XUE
);
my @input;
my $w = 47;

sub node { my $tag = shift; push @$tag, { type=>shift, x=>shift, y=>shift, @_ } }

node('item', $_, 0, 0) for qw(misc_map head_circlet_telepathy weapon_dagger_electric);
node('tile', 20, $_, 0, zone => 6) for 0..$w;
node('tile', 18 * ($_&1), $_, 1, zone => 6) for 0..$w;
node('tile', 103, $_, 2, zone => 6) for 0..$w;
node('trap', 1, 2*$_, 2, subtype => 7) for 0..$w/2;

while (<>) {
	while (/[0&>A<B^|]{2}|[OIi]|(\S\S?)(?{die "Unknown gate: $1"})/g) {
		my $x = $-[0] * 2;
		if (lc($&) eq 'i') {
			node('enemy', 1, $x, 1) for 1..($input[$x]++ ? 1 : 2);
			node('trap', 1, $x, 1, subtype => 2);
		}
		for (unpack "c*", $gates{$&}) {
			node('trap', 1, $x + $_%4, 2, subtype => $_%11);
		}
	}
}

print "<dungeon character='1009' numLevels='1'><level num='1'>\n";

for my $tag (qw(tile trap enemy item)) {
	printf "\t<%ss>\n", $tag =~ s/y$/ie/r;
	for my $node (@$tag) {
		my @attrs = map("$_='$$node{$_}'", grep $_ ne 'tag', sort keys %$node);
		print "\t\t<$tag @attrs />\n";
	}
	printf "\t</%ss>\n", $tag =~ s/y$/ie/r;
}

print "</level></dungeon>\n";
