package WWW::GudangAPI;

use 5.010;
use strict;
use warnings;
use Exporter::Lite;
use Log::Any '$log';
use Sub::Spec::URI;

our @EXPORT_OK = qw(get_ga_ssuri);
our %SPEC;

$SPEC{get_ga_ssuri} = {
    summary =>
        'Create Sub::Spec::URI object to access GudangAPI.com API functions',
    description => <<'_',

Once a Sub::Spec::URI object is created, you can call function, get function
spec, etc. See Sub::Spec::URI documentation for more details.

_
    args => {
        module => ['str*' => {
            summary => 'Name of module to call',
            match   => qr!^\w+(?:::\w+)*$!,
            arg_pos => 0,
        }],
        sub => ['str' => {
            summary => 'Name of function to call',
            match   => qr/^\w+$/,
            arg_pos => 1,
        }],
        user => ['str' => {
            summary => 'GudangAPI username',
            default => 'ga',
        }],
        https => ['bool' => {
            summary => 'Whether to use HTTPS instead of HTTP',
            description => <<'_',

You might want to use HTTPS if you send sensitive data such as password or
financial data. Note that HTTPS access has higher latency.

_
            default => 0,
        }],
    },
};
sub get_ga_ssuri {
    my %args = @_;

    # XXX schema

    my $user = $args{user};
    if (defined $user) {
        $user =~ /\A\w+\z/
            or return [400, "Invalid user `$user`: use alphanums only"];
    }
    $user //= "ga";

    my $module = $args{module}
        or return [400, "Please specify module"];
    $module =~ m!\A\w+(?:::\w+)*\z!
        or return [400, "Invalid module `$module`: use 'foo::bar' syntax"];

    my $sub = $args{sub};
    if (defined $sub) {
        $sub =~ /\A\w+\z/
            or return [400, "Invalid sub: use alphanums only"];
    }
    my $https = $args{https};

    my $url = join("",
                   ($https ? "https" : "http"), "://",
                   "gudangapi.com/",
                   $user,
                   "/$module",
                   (defined($sub) ? "::$sub" : "")
               );
    $log->tracef("url=%s", $url);
    Sub::Spec::URI->new($url);
}

1;


=pod

=head1 NAME

WWW::GudangAPI - Client library for GudangAPI.com

=head1 VERSION

version 0.02

=head1 SYNOPSIS

 use WWW::GudangAPI qw(get_ga_ssuri);
 my $uri = get_ga_ssuri(
     module => 'tax/id/npwp',
     sub    => 'parse_npwp',
     #https => 1, # use https, default is 0
 );
 my $res = $uri->call(npwp=>'00.000.001.8-000');
 say "valid!" if $res->[0] == 200; # prints 'valid!'

=head1 DESCRIPTION

This module is the Perl client library for GudangAPI,
L<http://www.gudangapi.com/>. It is currently a very thin wrapper for
L<Sub::Spec::URI>, since GudangAPI is L<Sub::Spec::HTTP>-compliant. As a matter
of fact, you can just do:

 my $uri = Sub::Spec::URI->new("http://gudangapi.com/ga/MODULE::FUNC");
 my $res = $uri->call(ARG=>..., ...);

and skip this module altogether. But in the future some convenience features
will be added to this module.

This module uses L<Log::Any>.

This module's functions has L<Sub::Spec> specs.

=head1 FUNCTIONS

None are exported, but they are exportable.

=head2 get_ga_ssuri(%args) -> [STATUS_CODE, ERR_MSG, RESULT]


Create Sub::Spec::URI object to access GudangAPI.com API functions.

Once a Sub::Spec::URI object is created, you can call function, get function
spec, etc. See Sub::Spec::URI documentation for more details.

Returns a 3-element arrayref. STATUS_CODE is 200 on success, or an error code
between 3xx-5xx (just like in HTTP). ERR_MSG is a string containing error
message, RESULT is the actual result.

Arguments (C<*> denotes required arguments):

=over 4

=item * B<module>* => I<str>

Name of module to call.

=item * B<sub> => I<str>

Name of function to call.

=item * B<https> => I<bool> (default C<0>)

Whether to use HTTPS instead of HTTP.

You might want to use HTTPS if you send sensitive data such as password or
financial data. Note that HTTPS access has higher latency.

=item * B<user> => I<str> (default C<"ga">)

GudangAPI username.

=back

=head1 SEE ALSO

L<Sub::Spec::HTTP>

L<Sub::Spec::URI>

http://www.gudangapi.com/

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
# ABSTRACT: Client library for GudangAPI.com

