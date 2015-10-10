package MooseX::Types::Authen::Passphrase;
# ABSTRACT: L<Authen::Passphrase> type constraint and coercions

use strict;
use warnings;

our $VERSION = '0.05';

use Authen::Passphrase;
use Authen::Passphrase::RejectAll;

use MooseX::Types::Moose qw(Str Undef);

use MooseX::Types -declare => [qw(Passphrase)];

use namespace::clean 0.19;

class_type "Authen::Passphrase";
class_type Passphrase, { class => "Authen::Passphrase" };

foreach my $type ( "Authen::Passphrase", Passphrase ) {
    coerce( $type,
        from Undef, via { Authen::Passphrase::RejectAll->new },
        from Str, via {
            if ( /^\{/ ) {
                return Authen::Passphrase->from_rfc2307($_);
            } else {
                return Authen::Passphrase->from_crypt($_);
                #my ( $p, $e ) = do { local $@; my $p = eval { Authen::Passphrase->from_crypt($_) }; ( $p, $@ ) };

                #if ( ref $p and $p->isa("Authen::Passphrase::RejectAll") and length($_) ) {
                #    warn "e: $e";
                #    return Authen::Passphrase::Clear->new($_);
                #} elsif ( $e ) {
                #    die $e;
                #} else {
                #    return $p;
                #}
            }
        },
    );
}

__PACKAGE__

__END__

=pod

=head1 SYNOPSIS

    package User;
    use Moose;

    use MooseX::Types::Authen::Passphrase qw(Passphrase);

    has pass => (
        isa => Passphrase,
        coerce => 1,
        handles => { check_password => "match" },
    );

    User->new( pass => undef ); # Authen::Passphrase::RejectAll

    my $u = User->new( pass => "{SSHA}ixZcpJbwT507Ch1IRB0KjajkjGZUMzX8gA==" );

    $u->check_password("foo"); # great success

    User->new( pass => Authen::Passphrase::Clear->new("foo") ); # clear text is not coerced by default

=head1 DESCRIPTION

This L<MooseX::Types> library provides string coercions for the
L<Authen::Passphrase> family of classes.

=head1 TYPES

=head2 C<Authen::Passphrase>, C<Passphrase>

These are defined a class types.

The following coercions are defined:

=over 4

=item from C<Undef>

Returns L<Authen::Passphrase::RejectAll>

=item from C<Str>

Parses using C<from_rfc2307> if the string begins with a C<{>, or using
C<from_crypt> otherwise.

=back

=cut
