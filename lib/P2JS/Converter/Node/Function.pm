package P2JS::Converter::Node::Function;
use strict;
use warnings;
use parent 'P2JS::Converter::Node';

sub body { shift->{body} }
sub prototype { shift->{prototype} }

sub to_js_ast {
    my ($self, $context) = @_;
    
    return undef;
}

1;
