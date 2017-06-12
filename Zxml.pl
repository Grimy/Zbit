#!/bin/perl -l

my %gates = qw(
	O  k1
	&| l0l1h1
	|& h2h1l1
	<A l0h2o1k1
	BA l0h2o1h1
	B> h2l0o1k1
	^& l0o1h2o1k1
	<& l0h2o1h2k1
	&> h2l0o1l0k1
	&^ h2o1l0o1k1
	B& h2l0o1o2k3l1
	A< l0h2o1k1l0h2o1
	>B h2l0o1k1l0h2o1
	&B h2l0o1l0l2k3l1
	&& h2h1l0o1l2k3l1
	&A l0l2l1h3o2k1h2h1h3
	A& l0h2l2o1l0k1h2h1h3
);

my $regex = join '|', map quotemeta, keys %gates;

my $w = 31;

my @nodes = (
	map({ tag=>'item', type=>$_ }, qw(misc_map head_circlet_telepathy weapon_dagger_electric)),
	map({ tag=>'tile', zone=>'6', x=>$_ }, 0..$w),
	map({ tag=>'tile', zone=>'6', x=>$_, y=>1, type=>(0, 18)[$_<$w && ($_&1)] }, 0..$w),
	map({ tag=>'tile', zone=>'6', x=>$_, y=>2, type=>103 }, 0..$w),
	map({ tag=>'enemy', type=>'1', y=>1, x=>2*$_ }, 0..$w/2),
);

while (<>) {
	while (/$regex|[\sIi]|(..?)(?{die "Unknown gate: $1"})/g) {
		my $x = $-[0] * 2;
		push @nodes, map { /(.)(.)/; {
			tag => 'trap',
			x => $x + int($2),
			y => 2,
			type => 1,
			subtype => index('lhjknbyuo', $1),
		}} $gates{$&} =~ /../g;
	}
}

print "<dungeon character='1009' numLevels='1'><level num='1'>";

for (qw(tiles traps enemies items)) {
	my $tag = s/(ie)?s$/$1 ? 'y' : ''/re;
	print "\t<$_>";
	for my $attr (grep $_->{tag} eq $tag, @nodes) {
		my @attrs = map("$_='$$attr{$_}'", grep $_ ne 'tag', sort keys %$attr);
		print "\t\t<$tag @attrs />";
	}
	print "\t</$_>";
}

printf "</level></dungeon>";
