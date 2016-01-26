package P2JS::Converter::Node::IfStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::IfStmt;

sub expr { shift->{expr} // P2JS::Converter::Node::Nop->new; }
sub true_stmt { shift->{true_stmt} // P2JS::Converter::Node::Nop->new; }
sub false_stmt { shift->{false_stmt} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::IfStmt->new(
        token => $self->token,
        expr  => $self->expr->to_js_ast($context),
        true_stmt  => $self->true_stmt->to_js_ast($context),
        false_stmt => $self->false_stmt->to_js_ast($context),
        next => $self->next->to_js_ast($context),
    );
}

1;
