package P2JS::Node::ControlStmt;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->token->data,
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
