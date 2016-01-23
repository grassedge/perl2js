package P2JS::Converter::Node::ForStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub init { shift->{init} }
sub cond { shift->{cond} }
sub progress { shift->{progress} }
sub true_stmt { shift->{true_stmt} }

1;

__END__

=pod

=head1 NAME

P2JS::Converter::Node::ForStmt

=head1 INHERITANCE

    P2JS::Converter::Node::ForStmt
    isa P2JS::Converter::Node

=head1 DESCRIPTION

    This node is created to represent for statement.
    ForStmt node has four pointers of 'init', 'cond', 'progress' and 'true_stmt'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     __________________________________________        _____________
    |                                          | next |             |
    |                 ForStmt                  |----->|             |
    |__________________________________________|      |_____________|
        |         |            |             |
   init |   cond  |   progress |   true_stmt |
        v         v            v             |
                                             v

=head2 Example

e.g.) for (my $i = 0; $i < 10; $i++) { $a++ }

                                          |
        __________________________________|_____________________________________        _____________
       |                                                                        | next |             |
       |                               ForStmt(for)                             |----->|             |
       |________________________________________________________________________|      |_____________|
               |                          |                  |            |
          init |                    cond  |         progress |  true_stmt |
       ________v_________         ________v________      ____v____    ____v____
      |                  |       |                 |    |         |  |         |
      |        =         |       |        <        |    |   ++    |  |   ++    |
      |__________________|       |_________________|    |_________|  |_________|
         |            |            |             |           |            |
    left |      right |       left |       right |      expr |       expr |
     ____v____    ____v____    ____v____     ____v___    ____v____    ____v____
    |         |  |         |  |         |   |        |  |         |  |         |
    |   $i    |  |    0    |  |   $i    |   |   10   |  |   $i    |  |   $a    |
    |_________|  |_________|  |_________|   |________|  |_________|  |_________|



=head1 SEE ALSO

[P2JS::Converter::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
