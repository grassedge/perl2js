package P2JS::Converter::Node::CodeDereference;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub name { shift->{name} }
sub args { shift->{args} }

1;

__END__
