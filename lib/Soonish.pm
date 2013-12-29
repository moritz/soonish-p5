package Soonish;
use 5.014;
use warnings;
use utf8;

use Exporter qw/import/;
use JSON qw/decode_json/;
use Carp qw/croak/;

our @EXPORT_OK = qw/config model get_dbh/;

sub config {
    state $config = do {
        my $filename = $ENV{SOONISH_CONFIG} || 'config.json';
        use autodie;
        open my $IN, '<:encoding(UTF-8)', $filename;
        local $/;
        my $config_text = <$IN>;
        close $IN;
        decode_json $config_text;
    };
    my $current = $config;
    for my $k (@_) {
        unless (exists $current->{$k}) {
            croak qq[Missing config key "$k" in chain ]. join(', ', map qq["$_"], @_);
        }
        $current = $current->{$k}
    }
    return $current;
}

sub get_dbh {
    require DBI;
    my $dbh = DBI->connect(
        sprintf('DBI:Pg:database=%s;host=%s', config(db => 'name'), config(db => 'host')),
        config(db => 'user'),
        config(db => 'password'),
        { RaiseError => 1, AutoCommit => 1},
    );
    $dbh->{'pg_enable_utf8'} = 1;
    return $dbh;
}

sub model {
    require Soonish::DB;
    Soonish::DB->connect(\&get_dbh);
}

1;
