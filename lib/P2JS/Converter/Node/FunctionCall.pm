package P2JS::Converter::Node::FunctionCall;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::FunctionCall;

sub args {
    my ($self) = @_;
    return $self->{args};
}

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;

    return P2JS::Node::FunctionCall->new(
        token => $token,
        args => [ map { $_->to_js_ast($context) } @{$self->args} ],
        "next" => $self->next->to_js_ast($context)
    );
}

1;
