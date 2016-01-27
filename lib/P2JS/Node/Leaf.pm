package P2JS::Node::Leaf;

use strict;
use warnings;
use parent qw(P2JS::Node);

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->token->data,
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
