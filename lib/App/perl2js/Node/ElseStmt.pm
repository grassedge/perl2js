package P2JS::Node::ElseStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "{\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "}"
    );
}

1;
