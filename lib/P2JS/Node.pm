package P2JS::Node;

use strict;
use warnings;

use P2JS::Node::Nop;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub token {
    my ($self) = @_;
    return $self->{token};
}

sub next {
    my ($self) = @_;
    return $self->{next} // P2JS::Node::Nop->new;
}

sub is_nop {
    my ($self) = @_;
    return $self->isa("P2JS::Node::Nop");
}

sub indent {
    my ($self, $depth) = @_;
    return "    " x $depth;
}

sub to_javascript {
    my ($self) = @_;
    return ("to_javascript not implemented: " . ref($self));
}

1;
