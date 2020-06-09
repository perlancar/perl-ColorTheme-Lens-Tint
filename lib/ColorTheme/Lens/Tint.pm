package ColorTheme::Lens::Tint;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;
use parent 'ColorThemeBase::Base';

our %THEME = (
    v => 2,
    summary => 'Tint other theme',
    dynamic => 1,
    description => <<'_',

This color theme tints RGB colors from other color scheme with another color.

_
    dynamic => 1,
    args => {
        theme => {
            schema => 'perl::modname_with_args',
            req => 1,
            pos => 0,
        },
        color => {
            summary => 'Tint color',
            schema => 'color::rgb24*',
            req => 1,
            pos => 1,
        },
        percent => {
            schema => ['num*', between=>[0, 100]],
            default => 50,
        },
    },
);

sub new {
    my $class = shift;
    my %args = @_;

    my $self = $class->SUPER::new(%args);

    require Module::Load::Util;
    $self->{orig_theme_class} = Module::Load::Util::instantiate_class_with_optional_args(
        $self->{args}{theme});

    $self;
}

sub list_items {
    my $self = shift;

    # return the same list of items as the original theme
    $self->{orig_theme_class}->list_items;
}

sub get_item_color {
    require Color::RGB::Util;

    my $self = shift;

    my $color = $self->{orig_theme_class}->get_item_color(@_);
    $color = {%{$color}} if ref $color eq 'HASH'; # shallow copy

    if (!ref $color) {
        $color = Color::RGB::Util::tint_rgb_color($color, $self->{args}{color}, $self->{args}{percent}/100);
    } else { # assume hash
        $color->{fg} = Color::RGB::Util::tint_rgb_color($color->{fg}, $self->{args}{color}, $self->{args}{percent}/100) if defined $color->{fg} && length $color->{fg};
        $color->{bg} = Color::RGB::Util::tint_rgb_color($color->{bg}, $self->{args}{color}, $self->{args}{percent}/100) if defined $color->{bg} && length $color->{bg};
        # can't tint ansi_fg, ansi_bg
    }
    $color;
}

1;
# ABSTRACT:

=head1 SEE ALSO

Other C<ColorTheme::Lens::*> modules.
