package P2JS::Node::Function;

use strict;
use warnings;
use parent qw(P2JS::Node);

sub body {
    my ($self) = @_;
    return $self->{body};
}

sub to_javascript {
    my ($self, $depth) = @_;
    return (
        $self->indent($depth) . "function " . $self->token->data . "() {\n",
        $self->indent($depth) . "}\n",
        $self->next->to_javascript($depth)
    );
}

1;
