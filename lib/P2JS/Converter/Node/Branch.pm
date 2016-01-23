package P2JS::Converter::Node::Branch;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub left  { shift->{left}  }
sub right { shift->{right} }

1;

__END__

=pod

=head1 NAME

P2JS::Converter::Node::Branch

=head1 INHERITANCE

    P2JS::Converter::Node::Branch
    isa P2JS::Converter::Node

=head1 DESCRIPTION

    Branch node has two pointers of 'left' and 'right'.
    Also, this node has 'next' pointer to access next statement's node.
    This node includes token kind of 'Operator', 'Assign' and 'Comma'.

=head1 LAYOUT

     ____________________________________        _____________
    |                                    | next |             |
    |   Branch(Operator,Assign,Comma)    |----->|             |
    |____________________________________|      |_____________|
             |                   |
       left  |                   | right
             v                   v

=head2 Example

e.g.) 1 + 2 + 3; ...

                  |
        __________|__________        _________
       |                     | next |         |
       |        Add(+)       |----->|  .....  |
       |_____________________|      |_________|
           |             |
      left |             | right
    _______v_______    __v__
   |               |  |     |
   |     Add(+)    |  |  3  |
   |_______________|  |_____|
      |         |
 left |         | right
    __v__     __v__
   |     |   |     |
   |  1  |   |  2  |
   |_____|   |_____|

=head1 SEE ALSO

[P2JS::Converter::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
