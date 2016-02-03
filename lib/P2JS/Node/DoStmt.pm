package P2JS::Node::DoStmt;

use strict;
use warnings;
use parent qw(P2JS::Node::BlockStmt);

use P2JS::Node::Nop;

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "(function() {\n",
        $self->sentences_to_javascript($depth + 1),
        $self->indent($depth),
        "})()",
    );
}

1;
