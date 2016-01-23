package P2JS::Converter::Node::DoStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub stmt { shift->{stmt} }

1;

__END__

=pod

=head1 NAME

P2JS::Converter::Node::DoStmt

=head1 INHERITANCE

    P2JS::Converter::Node::DoStmt
    isa P2JS::Converter::Node

=head1 DESCRIPTION

    DoStmt node has single pointer of 'stmt'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     ___________        ___________
    |           | next |           |
    |   DoStmt  |----->|           |
    |___________|      |___________|
          |
     stmt |
          v


=head2 Example

e.g.) do { $a++; } ...

            |
     _______|_______        _________
    |               | next |         |
    |   DoStmt(do)  |----->|  .....  |
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

[P2JS::Converter::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
