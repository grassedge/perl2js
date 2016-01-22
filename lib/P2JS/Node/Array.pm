package P2JS::Node::Array;
use strict;
use warnings;
use parent 'P2JS::Node';

sub idx { shift->{idx} }

1;

__END__

=pod

=head1 NAME

P2JS::Node::Array

=head1 INHERITANCE

    P2JS::Node::Array
    isa P2JS::Node

=head1 DESCRIPTION

    This node is created to represent array's get/set accessor.
    Array node has single pointer of 'idx'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     ____________        _____________
    |            | next |             |
    |   Array    |----->|             |
    |____________|      |_____________|
          |
     idx  |
          v

=head2 Example

e.g.) $array[0]; ...

               |
     __________|__________        _________
    |                     | next |         |
    |     Array($array)   |----->|  .....  |
    |_____________________|      |_________|
               |
          idx  |
        _______v_______
       |               |
       |       0       |
       |_______________|

=head1 SEE ALSO

[P2JS::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
