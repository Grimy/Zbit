#!perl -l

sub p { $p = 1; print ' ' x $-[0], @_ }

my $w = 8;
my $b = 0;
$_ = '   ' x $w;

for (;;) {
	$p = 0;
	p '0^' if s/pp/ p/;
	p '&^' if s/(\S)\1/chr(ord($1) + 1) . $1/e;
	p 'BA' if s/(\S) / $1/;
	p 'BA' if s/([a-a])([b-p])/$2$1/;
	p 'BA' if s/([a-b])([c-p])/$2$1/;
	p 'BA' if s/([a-c])([d-p])/$2$1/;
	p 'BA' if s/([a-d])([e-p])/$2$1/;
	p 'BA' if s/([a-e])([f-p])/$2$1/;
	p 'BA' if s/([a-f])([g-p])/$2$1/;
	p 'BA' if s/([a-g])([h-p])/$2$1/;
	p 'BA' if s/([a-h])([i-p])/$2$1/;
	p 'BA' if s/([a-i])([j-p])/$2$1/;
	p 'BA' if s/([a-j])([k-p])/$2$1/;
	p 'BA' if s/([a-k])([l-p])/$2$1/;
	p 'BA' if s/([a-l])([m-p])/$2$1/;
	p 'BA' if s/([a-m])([n-p])/$2$1/;
	p 'BA' if s/([a-n])([o-p])/$2$1/;
	p 'BA' if s/([a-o])([p-p])/$2$1/;
	if (!$p) {
		last if $b == $w;
		print 'i' x $w, ' ' x ($w - 1 - $b), 'i';
		print ' ' x ($w+$_), 'BA' for reverse 0..($w-2-$b);
		print ' ' x ($w-$_), 'B&' for 1..($w-1);
		print '0&';
		substr($_, 0, ($w+1)) = ' ' . join('', reverse chr(97+$b)..chr(96+$w+$b));
		++$b;
	}
}

print ' ' x $w, 'O' x (2 * $w);
