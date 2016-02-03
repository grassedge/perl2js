package P2JS::Converter::Node::Block;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use P2JS::Node::Block;

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::Block->new(
        token => $self->token,
        statements => [ map { $_->to_js_ast($context) } @{$self->statements} ],
    );
}

1;
