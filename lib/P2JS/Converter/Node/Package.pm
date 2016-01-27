package P2JS::Converter::Node::Package;

use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;
use P2JS::Node::Nop;

use P2JS::Node::Class;

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $class_name = $token->data;
    $class_name =~ s/.+:://g;
    $token->{data} = $class_name;
    my $class = P2JS::Node::Class->new(
        token => $self->token,
    );
    $context->push_class($class);
    $class->{body} = $self->next->to_js_ast($context);
    return P2JS::Node::Nop->new;
}

1;

__END__

=pod

=head1 NAME

P2JS::Converter::Node::Package

=head1 INHERITANCE

    P2JS::Converter::Node::Package
    isa P2JS::Converter::Node

=head1 DESCRIPTION

    This node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     ______________        _____________
    |              | next |             |
    |   Package    |----->|             |
    |______________|      |_____________|


=head2 Example

e.g.) package Person; ...

                  |
        __________|__________        _________
       |                     | next |         |
       |    Package(Person)  |----->|  .....  |
       |_____________________|      |_________|

=head1 SEE ALSO

[P2JS::Converter::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
