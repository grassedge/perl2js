package P2JS::Converter::Node::ThreeTermOperator;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::ThreeTermOperator;

sub cond { shift->{cond} // P2JS::Converter::Node::Nop->new; }
sub true_expr { shift->{true_expr} // P2JS::Converter::Node::Nop->new; }
sub false_expr { shift->{false_expr} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::ThreeTermOperator->new(
        token => $self->token,
        cond  => $self->cond->to_js_ast($context),
        true_expr  => $self->true_expr->to_js_ast($context),
        false_expr => $self->false_expr->to_js_ast($context),
    );
}

1;
