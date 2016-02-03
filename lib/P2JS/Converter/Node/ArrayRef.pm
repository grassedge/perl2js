package P2JS::Converter::Node::ArrayRef;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::ArrayLiteral;

sub data_node { shift->{data} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::ArrayLiteral->new(
        token => $self->token,
        data  => $self->data_node->to_js_ast($context),
    );
}

1;

__END__

=pod

=head1 NAME

P2JS::Converter::Node::ArrayRef

=head1 INHERITANCE

    P2JS::Converter::Node::ArrayRef
    isa P2JS::Converter::Node

=head1 DESCRIPTION

    This node is created to represent array reference's get/set accessor.
    ArrayRef node has single pointer of 'data'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     _____________        _____________
    |             | next |             |
    |   ArrayRef  |----->|             |
    |_____________|      |_____________|
           |
     data  |
           v

=head2 Example

e.g.) $array_ref->[0]; ...

               |
     __________|______________        _________
    |                         | next |         |
    |   ArrayRef($array_ref)  |----->|  .....  |
    |_________________________|      |_________|
               |
         data  |
        _______v_______
       |               |
       |       0       |
       |_______________|

=head1 SEE ALSO

[P2JS::Converter::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
