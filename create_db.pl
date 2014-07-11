#!/usr/bin/perl

# Quick demo of using sqlite_db_handle(), commit_handle() and sql subroutines. Normally you would run a query
# rather than creating a table, but a query is a query.

# update_first_word.pl has a more complex sql subroutine that uses two queries.
# schema.sql is the database schema for the db used by update_first_word.pl

# ./create_db.pl

# > sqlite3 test.db 
# SQLite version 3.6.20
# Enter ".help" for instructions
# Enter SQL statements terminated with a ";"
# sqlite> .sch
# CREATE TABLE person (
#        person_id integer primary key autoincrement,
#        first_name text,
#        last_name text
# );
# sqlite> .q


use strict;
use session_lib qw(:all);

my $db_name = "test.db";

main();
exit();

sub main
{
    my $dbh = sqlite_db_handle($db_name);
    sql_create(dbh => $dbh);
    commit_handle($db_name);
}

sub sql_prototype
{ 
    my %arg = @_;
    my $dbh = $arg{dbh};

    my $sql = "";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "prep", $db_name, (caller(0))[3]);
    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

}

sub sql_create
{ 
    my %arg = @_;
    my $dbh = $arg{dbh};

    my $sql = "create table person (
       person_id integer primary key autoincrement,
       first_name text,
       last_name text
);";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "prep", $db_name, (caller(0))[3]);
    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

}
