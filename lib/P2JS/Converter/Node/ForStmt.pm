package P2JS::Converter::Node::ForStmt;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;

use P2JS::Node::ForStmt;

sub init { shift->{init} // P2JS::Converter::Node::Nop->new; }
sub cond { shift->{cond} // P2JS::Converter::Node::Nop->new; }
sub progress { shift->{progress} // P2JS::Converter::Node::Nop->new; }
sub true_stmt { shift->{true_stmt} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    return P2JS::Node::ForStmt->new(
        token => $self->token,
        init  => $self->init->to_js_ast($context),
        cond  => $self->cond->to_js_ast($context),
        progress => $self->progress->to_js_ast($context),
        true_stmt => $self->true_stmt->to_js_ast($context),
        next => $self->next->to_js_ast($context),
    );
}

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
