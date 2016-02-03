package P2JS::Converter::Node::WhileStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use Compiler::Lexer::Token;

use P2JS::Converter::Node::Nop;
use P2JS::Converter::Node::SingleTermOperator;

use P2JS::Node::WhileStmt;

sub expr { shift->{expr} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $expr;
    if ($token->name eq 'UntilStmt') {
        $expr = P2JS::Converter::Node::SingleTermOperator->new(
            token => bless({
                data => '!',
                name => '', # TODO
            }, 'Compiler::Lexer::Token'),
            expr => $self->expr,
        );
    } else {
        $expr = $self->expr;
    }
    return P2JS::Node::WhileStmt->new(
        token => $self->token,
        expr  => $expr->to_js_ast($context),
        statements => [ map { $_->to_js_ast($context) } @{$self->statements} ],
    );
}

1;
