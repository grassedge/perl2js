package P2JS::Node::FunctionCall;

use strict;
use warnings;
use parent qw(P2JS::Node);

sub args {
    my ($self) = @_;
    return $self->{args};
}

sub to_javascript {
    my ($self, $depth) = @_;
    my $token = $self->token;
    return (
        $self->token->data,
        "(",
        (map { $_->to_javascript($depth) } grep { $_ } @{$self->args}),
        ")",
        ($self->next->is_nop ? () : (";\n" . $self->indent($depth))),
        $self->next->to_javascript($depth)
    );
}

1;
