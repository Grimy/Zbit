my %gates = qw(
	O P 0B T A0 2 00 T3 B0 TNY &0 NXE &B NXM B0 NYE B& NYM 0& XNE 0A X2M 0B XME
	B> NXTU BA NXUM <A XN2U 0> NXTUT &> NXUTY B& NXU2M &^ NYXTU <0 XN2U2 &A XNUTY
	<& XNUNE ^& XMN2U &B NXUX2M 0^ NYXTUT && NYXU2M A& XNUTNY ^0 XMN2U2
	>0 NXTUTNY >B NXTUNXU A< NXUNXTU &< NXUXT2U 0< XN2UX2M >& XNUTN2U
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
