package P2JS::Converter::Node::ControlStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Node::ControlStmt;

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    if ($token->name eq 'Next') {
        $token->{name} = 'Continue';
        $token->{data} = 'continue';
    } elsif ($token->name eq 'Last') {
        $token->{name} = 'Break';
        $token->{data} = 'break';
    }
    return P2JS::Node::ControlStmt->new(
        token => $self->token,
    );
}


1;
