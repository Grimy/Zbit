#!/bin/perl -l

use strict;
use warnings;

my @mem = map { 0 } 1..256;
my @r = (0, 0, 0, 0);

my @mnemonics = qw(
	copy swap zjmp njmp
	add sub mul div
	inc dec swiz resa
	load save recv send
);

# 4 I/O channels, 0 is used for inter-node communication, the rest is puzzle I/O
# 4 registers, r3 is IP

my @ops = (
	sub { $r[$a] = $r[$b] },
	sub { @r[$a, $b] = @r[$b, $a] },
	sub { $r[3] = $r[$b] if $r[$a] == 0 },
	sub { $r[3] = $r[$b] if $r[$a] != 0 },

	sub { $r[$a] += $r[$b] },
	sub { $r[$a] -= $r[$b] },
	sub { $r[$a] *= $r[$b] },
	sub { $r[$a] = $r[$b] ? $r[$a] / $r[$b] : 0 },

	sub { $r[$a] += 4 ** $b },
	sub { $r[$a] -= 4 ** $b },
	sub { "swiz" },
	sub { "resa" },

	sub { $r[$a] = $mem[$r[$b]] },
	sub { $mem[$r[$b]] = $r[$a] },
	sub { $r[$a] = <> },
	sub { print $r[$a] },
);

my $dp = 0;

while (<DATA>) {
	/([a-z]+) ([0-3]) ([0-3])/;
	my ($opcode) = grep { $mnemonics[$_] eq $1 } 0..15;
	$mem[$dp++] = ($opcode << 4) | ($2 << 2) | $3;
}

for (;;) {
	my $instr = $mem[$r[3]++];
	$r[3] %= 256;

	my $opcode = $instr >> 4;
	$a = ($instr >> 2) & 3;
	$b = $instr & 3;
	last unless defined $ops[$opcode]->();

	$r[$a] = int($r[$a]) % 256;
	$r[$b] = int($r[$b]) % 256;
}

=pod tuto

This is your QPU. A QPU has 4 registers and 256 memory cells, each of which can
hold a number between 0 and 255. Both code and data are stored in memory, with
each number corresponding to an instruction.


Register 3 is the instruction pointer.
=cut

=pod fibo
inc 1 0
out 0 0
add 0 1
swp 0 1
div 3 3
=cut

__DATA__
copy 0 1
copy 0 0
recv 0 0
copy 1 0
dec 1 0
copy 2 1
dec 2 0
div 2 2
mul 3 2
copy 2 0
div 2 1
mul 2 1
sub 2 0
div 2 2
load 2 2
mul 2 3
inc 2 1
copy 3 2
copy 0 0
copy 0 0
send 0 0
sub 3 3
