#!/bin/perl -l

my %gates = (
	'O'  => 'k1',
	# '&A' => 'l1h3o2o1h2k0',
	'&>' => 'h3l1o2l1k2',
	'&^' => 'h3o2l1o2k2',
	'&|' => 'l1l2h2',
	'<&' => 'l1h3o2h3k2',
	'<A' => 'l1h3o2k2',
	'B>' => 'h3l1o2k2',
	'BA' => 'l1h3o2h2',
	'^&' => 'l1o2h3o2k2',
	'|&' => 'h3h2l2',
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
		my $x = $-[0] * 2 - 1;
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
