package P2JS::Node::ElseStmt;
use strict;
use warnings;
use parent 'P2JS::Node';

sub stmt { shift->{stmt} }

1;

__END__

=pod

=head1 NAME

P2JS::Node::ElseStmt

=head1 INHERITANCE

    P2JS::Node::ElseStmt
    isa P2JS::Node

=head1 DESCRIPTION

    ElseStmt node has single pointer of 'stmt'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     _____________        ___________
    |             | next |           |
    |   ElseStmt  |----->|           |
    |_____________|      |___________|
           |
      stmt |
           v

=head2 Example

e.g.) else { $a++; } ...

            |
     _______|_______        _________
    |               | next |         |
    |   ElseStmt    |----->|  .....  |
    |_______________|      |_________|
            |
      stmt  |
     _______v_______
    |               |
    |     Inc(++)   |
    |_______________|
            |
      expr  |
     _______v_______
    |               |
    |      $a       |
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
