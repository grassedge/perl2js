package P2JS::Node::ControlStmt;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->token->data,
    );
}

1;
