#!/bin/perl -l
use utf8;

my ($w, $y);
my %parsers = (
	'^' => sub {{ tag=>'trap', x=>shift, y=>shift, type=>shift, subtype=>shift }},
	'@' => sub {{ tag=>'enemy', x=>shift, y=>shift, type=>shift }},
	'|' => sub { map { tag=>'tile', x=>$_, y=>$y, type=>$_[$_], zone=>6 }, 0..$#_ },
);

sub parse {
	$y = -1;
	map {
		s/.//;
		$y += $& eq '|';
		$parsers{$&}->(unpack "w*", $_ ^ y// /cr);
	} $_[0] =~ /[|@^][^|@^]+/g;
}

my %modules = (
	"\n" => '|   |   |   ',
	'I'  => '|   | 4V|GVV^"!!%@!!¥g',
	'i'  => '|   | 4V|GVV^"!!%@!!¥g',
	' '  => '| 4 | 4 | 4 ',
	'O'  => '| 4 | 4 |   ^! !"',
	'A<' => '| 44 44| 44   | 4    ^$ !!^# !%^"!!&^" !$^#!!$^%"" ',
	'&|' => '| 4  4 | 4 44 | 4  4 ^!!! ^"!! ^#!! ^#"!!^""!!',
	'|&' => '| 4  4 | 44 4 | 4  4 ^$!!!^#!!!^"!!!^""! ^#"! ',
	'BA' => '| 4  4 | 4  4 | 4  4 ^! ! ^" !$^$ !!^# !%^""!!^#"! ',
);

my $regex = join '|', map quotemeta, keys %modules;

my @nodes = map { { tag=>'item', type=>$_ } } qw(
	misc_map head_circlet_telepathy torch_foresight weapon_dagger_electric
);

while (<>) {
	++$w   while y///c > $w;
	s/$/ / while y///c < $w;
	while (/$regex|(..?)(?{die "Unknown gate: $1"})/g) {
		my @module = parse($modules{$&});
		$_->{x} += $-[0] * 3 for @module;
		$_->{y} += ($. - 1) * 3 for @module;
		push @nodes, @module;
	}
}

print "<dungeon character='1009'><level>";

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
