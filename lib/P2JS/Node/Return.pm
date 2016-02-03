# TODO: this package is not BlockStmt.
# field 'body' is used as statements in C::P::Node::Function.

package P2JS::Node::Return;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub body {
    my ($self) = @_;
    return $self->{body} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        'return ',
        ($self->statements->[0] || P2JS::Node::Nop->new)->to_javascript($depth + 1)
    );
}

1;
