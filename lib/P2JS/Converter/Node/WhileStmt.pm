package P2JS::Converter::Node::WhileStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use Compiler::Lexer::Token;

use P2JS::Converter::Node::Nop;
use P2JS::Converter::Node::SingleTermOperator;

use P2JS::Node::WhileStmt;

sub expr { shift->{expr} // P2JS::Converter::Node::Nop->new; }
sub true_stmt { shift->{true_stmt} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $expr;
    if ($token->name eq 'UntilStmt') {
        $expr = P2JS::Converter::Node::SingleTermOperator->new(
            token => bless({
                data => '!'
            }, 'Compiler::Lexer::Token'),
            expr => $self->expr,
        );
    } else {
        $expr = $self->expr;
    }
    return P2JS::Node::WhileStmt->new(
        token => $self->token,
        expr  => $expr->to_js_ast($context),
        true_stmt  => $self->true_stmt->to_js_ast($context),
        next => $self->next->to_js_ast($context),
    );
}

1;
