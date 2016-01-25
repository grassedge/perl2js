package P2JS::Node::Class;

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
        "class " . $self->token->data . " {\n",
        $self->body->to_javascript($depth + 1),
        "}\n"
    );
}

1;
