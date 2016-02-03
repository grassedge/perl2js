package P2JS::Converter::Node::File;
use strict;
use warnings;
use parent 'P2JS::Converter::Node::BlockStmt';

use P2JS::Node::File;

sub to_js_ast {
    my ($self, $context) = @_;
    my $file = P2JS::Node::File->new;
    $context->root($file);
    my $statements = $self->statements;
    my $line = 0;
    while ($line < scalar(@$statements)) {
        my $statement = $statements->[$line];
        if ($statement->isa('P2JS::Converter::Node::Package')) {
            my $i = $line + 1;
            while (
                defined $statements->[$i] &&
                !$statements->[$i]->isa('P2JS::Converter::Node::Package')
            ) {
                $statement->push_statement($statements->[$i]);
                $i++;
            }
            $line = $i - 1;
        }
        $file->push_statement($statement->to_js_ast($context));
        $line++;
    }
    return $file;
}

1;
