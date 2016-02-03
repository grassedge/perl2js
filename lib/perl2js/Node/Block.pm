package P2JS::Node::Block;

use strict;
use warnings;

use parent qw(P2JS::Node::BlockStmt);

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "{\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth), "}",
    );
}

1;
