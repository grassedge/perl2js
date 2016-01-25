package P2JS::Node::ArrowFunction;

use strict;
use warnings;
use parent qw(P2JS::Node);

sub body { shift->{body} }
sub prototype { shift->{prototype} }

1;
