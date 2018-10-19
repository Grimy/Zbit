#!perl -l
# gate.pl: find how to implement logical gates with as few traps as possible

use strict;
use warnings;
no warnings qw(misc);

# Transition table. Rows are traps, columns are states.
# State 0: both dead
# State 1: left
# State 2: right
# State 3: both alive
# State 4: middle, facing right
# State 5: middle, facing left
# State 6: left+4
# State 7: right+5
my %traps = (
	U => sub { y/1-7/1232167/ },  # middle omnibounce
	T => sub { y/1-7/0224557/ },  # kill left
	E => sub { y/1-7/1230012/ },  # kill middle
	2 => sub { y/1-7/1014564/ },  # kill right
	X => sub { y/1-7/4274567/ },  # bounce left to middle
	M => sub { y/1-7/1232237/ },  # bounce middle to right
	Y => sub { y/1-7/1231163/ },  # bounce middle to left
	N => sub { y/1-7/1564567/ },  # bounce right to middle
);

# Maps logical gates to the shortest sequence of traps implementing them.
my %gates = ("123" => "");
my @q = ("123");

while (my $gate = shift @q) {
	for my $trap (keys %traps) {
		$_ = $gate;
		$traps{$trap}->();
		next if defined $gates{$_};
		push @q, $_;
		$gates{$_} = $gates{$gate} . $trap;
		my $name = pack('b*b*', $_, y/12/21/r) =~ y//0><^&AB/cr;
		print "$name $gates{$_}" if !/[4-7]/;
	}
}
