package P2JS::Converter::Node::Module;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

use P2JS::Converter::Node::Nop;
use P2JS::Node::Import;

sub args { shift->{args} // P2JS::Converter::Node::Nop->new; }

sub to_js_ast {
    my ($self, $context) = @_;
    my $token = $self->token;
    my $module_name = $token->data;

    # translate various modules to JavaScript
    if (
        $module_name eq 'strict' ||
        $module_name eq 'utf8' ||
        $module_name eq 'warnings'
    ) {
        return $self->next->to_js_ast($context);
    } elsif (
        $module_name eq 'base' ||
        $module_name eq 'parent'
    ) {
        my $base_name = $self->args->expr->token->data;
        $self->token->{data} = $base_name;
        my $import = P2JS::Node::Import->new(
            token => $self->token,
        );
        $context->push_import($import);
        $context->current_class->{super_class} = $base_name;
    } else {
        my $import = P2JS::Node::Import->new(
            token => $self->token,
        );
        $context->push_import($import);
    }
    return $self->next->to_js_ast($context);
}

1;
