package P2JS::Node::Method;

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
        $self->indent($depth) . $self->token->data . "() {\n",
        $self->body->to_javascript($depth),
        $self->indent($depth) . "}\n",
        $self->next->to_javascript($depth),
    );
}

1;
