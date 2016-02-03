package P2JS::Node::Import;

use strict;
use warnings;
use parent qw(P2JS::Node);

use P2JS::Node::Nop;

sub args {
    my ($self) = @_;
    return $self->{args} // P2JS::Node::Nop->new;
}

sub to_javascript {
    my ($self, $depth) = @_;
    my $module_name = $self->token->data;
    return (
        "import ",
        $self->token->data,
    );
}

1;
