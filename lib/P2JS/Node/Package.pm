package P2JS::Node::Package;
use strict;
use warnings;
use parent 'P2JS::Node';

1;

__END__

=pod

=head1 NAME

P2JS::Node::Package

=head1 INHERITANCE

    P2JS::Node::Package
    isa P2JS::Node

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

[P2JS::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
