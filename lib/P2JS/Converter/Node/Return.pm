package P2JS::Converter::Node::Return;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::Return;

sub body { shift->{body} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::Return->new(
        token => $self->token,
        body  => $self->body->to_js_ast($context),
        next  => $self->next->to_js_ast($context),
    );
}

1;
