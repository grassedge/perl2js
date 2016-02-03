package P2JS::Converter::Node::HashRef;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::ObjectLiteral;

sub data_node { shift->{data} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::ObjectLiteral->new(
        token => $self->token,
        data  => $self->data_node->to_js_ast($context),
    );
}

1;
