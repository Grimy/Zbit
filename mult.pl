#!perl -l

sub p { print ' ' x $-[0], @_ }

my $w = 8;
my $swap = join '|', map "([a-$_])(?!\\1)([$_-z])", 'a'..'z';
$_ = '   ' x $w;

for my $b (0..$w-1) {
	print 'i' x $w, ' ' x ($w - 1 - $b), 'i';
	print ' ' x ($w-$_), 'B', $_ > 0 ? '&' : '0' for ($b+2-$w)..($w-1);
	print '0&';
	substr($_, 0, ($w+1)) = ' ' . join('', reverse chr(97+$b)..chr(96+$w+$b));

	0 while s/(\S) / $1/ ? p '0A' :
		s/pp/ p/ ? p '0^' :
		s/(\S)\1/chr(ord($1) + 1) . $1/e ? p '&^' :
		s/(?|$swap)/$2$1/ ? p 'BA' : 0;
}

print ' ' x $w, 'O' x (2 * $w);
