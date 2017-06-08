#!/bin/perl -l
use utf8;

my $y;
my %parsers = (
	'^' => sub {{ tag=>'trap', x=>shift, y=>shift, type=>shift, subtype=>shift }},
	'@' => sub {{ tag=>'enemy', x=>shift, y=>shift, type=>shift, beatDelay=>0, lord=>0 }},
	'|' => sub { map { tag=>'tile', x=>$_, y=>$y, type=>$_[$_], zone=>6, torch=>0, cracked=>0 }, 0..$#_ },
);

sub parse {
	$y = -1;
	map {
		s/.//;
		$y += $& eq '|';
		$parsers{$&}->(unpack "w*", $_ ^ y// /cr);
	} $_[0] =~ /[|@^][^|@^]+/g;
}

  # 0 A B | & ^ < >
# 0 1              
# A 2 0            
# B 2 4 0          
# | 2 0 0 0        
# & 2 3 3 3 2      
# ^ 2 0 0 0 3 0    
# < 2 3 0 0 3 0 0  
# > 2 0 3 0 3 0 0 0

# BA &A &B &| &^ &< &> <A >B

my %modules = (
	'I'  => '|   | 4V|GVV^"!!%@!!¥g',
	' '  => '| 4 | 4 | 4 ',
	'O'  => '| 4 | 4 |   ^! !"',
	'A<' => '| 44 44| 44   | 4    ^$ !!^# !%^"!!&^" !$^#!!$^%"" ',
	'&|' => '| 4  4 | 4 44 | 4  4 ^!!! ^"!! ^#!! ^#"!!^""!!',
	'|&' => '| 4  4 | 44 4 | 4  4 ^$!!!^#!!!^"!!!^""! ^#"! ',
	'BA' => '| 4  4 | 4  4 | 4  4 ^! ! ^" !$^$ !!^# !%^""!!^#"! ',
);

my $regex = join '|', map quotemeta, keys %modules;

my @nodes = map {
	{ tag=>'item', x=>0, y=>0, type=>$_, bloodCost=>0, saleCost=>0, singleChoice=>0 }
} qw(misc_map head_circlet_telepathy torch_foresight weapon_dagger_electric);

while (<>) {
	chomp;
	$_ .= ' ' while y///c < 17;
	while (/$regex/g) {
		local $\ = "";
		print STDERR "($&)";
		my @module = parse($modules{$&});
		$_->{x} += $-[0] * 3 for @module;
		$_->{y} += ($. - 1) * 3 for @module;
		push @nodes, @module;
	}
	print STDERR "";
}

print "<?xml version='1.0'?>\n<dungeon character='1009' name='CIRCUIT' numLevels='1'>";
print "\t<level bossNum='-1' music='0' num='1'>";

for (qw(tiles traps enemies items)) {
	my $tag = s/(ie)?s$/$1 ? 'y' : ''/re;
	print "\t\t<$_>";
	for my $attr (grep $_->{tag} eq $tag, @nodes) {
		my @attrs = map("$_='$$attr{$_}'", grep $_ ne 'tag', sort keys %$attr);
		print "\t\t\t<$tag @attrs />";
	}
	print "\t\t</$_>";
}

printf "\t\t<chests />\n\t\t<crates />\n\t\t<shrines />\n\t</level>\n</dungeon>";
