package P2JS::Node::ObjectLiteral;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub data_node {
    my ($self) = @_;
    return $self->{data} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        "{",
        $self->data_node->to_javascript($depth),
        "}",
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
