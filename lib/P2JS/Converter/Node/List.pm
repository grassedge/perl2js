package P2JS::Converter::Node::List;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;
use P2JS::Node::List;

sub data_node {
    my ($self) = @_;
    return $self->{data} // P2JS::Converter::Node::Nop->new;
}

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::List->new(
        token => $self->token,
        data  => $self->data_node->to_js_ast($context),
        next  => $self->next->to_js_ast($context),
    );
}

1;
