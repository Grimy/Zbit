#!/usr/bin/perl -ln

(@_[$-[0]..$+[0]-1]) = split(//, sprintf "%0*b", length $&, shift) while /Ii*/g;
@_ = map int, @_;
print(oct 'b' . join '', @_[$-[0]..$+[0]-1]), last if /O+/g;
print STDERR s/.\K/ /gr;
y/0AB/%#;/;
@_[@-] = map { eval join chr ord, @_[@-] } $&, $1 while /[&|^<>#;](.)/gi;
print STDERR "@_";
