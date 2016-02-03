package P2JS::Converter::Node::Hash;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use Compiler::Lexer::Token;
use P2JS::Converter::Node::Nop;
use P2JS::Converter::Node::Leaf;

use P2JS::Node::PropertyAccessor;

sub key { shift->{key} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $key;
    if (ref($self->key) eq 'P2JS::Converter::Node::HashRef') {
        $key = $self->key->data_node;
    } else {
        $key = $self->key;
    }
    return P2JS::Node::PropertyAccessor->new(
        token => $self->token,
        data  => P2JS::Converter::Node::Leaf->new(
            token => bless({
                data => $self->data,
                name => 'Var',
            }, 'Compiler::Lexer::Token')
        )->to_js_ast($context),
        key   => $key->to_js_ast($context),
    );
}

1;
