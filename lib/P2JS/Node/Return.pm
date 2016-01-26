package P2JS::Node::Return;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub body {
    my ($self) = @_;
    return $self->{body} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        'return ',
        $self->body->to_javascript($depth),
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth),
    );
}

1;
