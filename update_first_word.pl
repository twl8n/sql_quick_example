#!/usr/bin/perl

# This was run after id2db.pl, and after the db was altered to have columns first_word, and first_word_norm.

use strict;
use session_lib qw(:all);

my $db_name = "all_ids_names.db";
main();
exit();

sub main
{
    my $dbh = sqlite_db_handle($db_name);
    
    sql_update_first(dbh=>$dbh);
    
    # No harm in commiting one last time, I guess.
    commit_handle($db_name);
    exit();
}

sub sql_update_first
{
    my %arg = @_;
    my $dbh = $arg{dbh};

    # Use anonymous local blocks so we can use $sql for each query without interference. Otherwise we'd have
    # to edit each of the err_stuff() calls. We have syntactic scoping, so we might as well use it for what is
    # was intended for.

    # We need the sth to be non-local to the block, so no "my" on $sth_select inside the block.

    my $sth_select;
    {
        # Select all the names we want, in this case all names. The data goes into a SQL cursor, so Perl DBI is
        # able to pull one record at a time from the cursor.
        my $sql = "select name, nid from name_info";
        $sth_select = $dbh->prepare($sql);
        err_stuff($dbh, $sql, "prep", $db_name, (caller(0))[3]);
        $sth_select->execute();
        err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    }

    # Don't need to put the update query into a local block. 

    # Update the db. Prepare here, and execute in the while loop below.

    my $sql = "update name_info set first_word=?, first_word_norm=? where nid=?";
    my $sth_update = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "prep", $db_name, (caller(0))[3]);


    my $xx = 0;
    while(my $hr = $sth_select->fetchrow_hashref())
    {
        # Match leading word, capture.
        $hr->{name} =~ m/^(\w+)/;
        my $first_word = $1;
        my $first_word_norm = normalize($first_word);
        # print "Name: $hr->{name} fw: $first_word nid: $hr->{nid}\n";

        $sth_update->execute($first_word, $first_word_norm, $hr->{nid});
        err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
        if (($xx % 100000) == 0)
        {
            print "Commmit $xx\n";
            commit_handle($db_name);
        }
        $xx++;
    }
    commit_handle($db_name);
}

sub sql_save_name
{ 
    my %arg = @_;
    my $dbh = $arg{dbh};
    my $name = $arg{name};
    my $file = $arg{file};
    my $norm = $arg{norm};

    my $db_name = "";

    my $sql = "insert into name_info (name, file, norm) values (?,?,?)";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "prep", $db_name, (caller(0))[3]);
    $sth->execute($name, $file, $norm);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
}


sub trim
{
    my $fixme = $_[0];
    $fixme =~ s/^\s+//;
    $fixme =~ s/\s+$//;
    return $fixme;
}

sub normalize
{
    my $fixme = $_[0];
    $fixme =~ s/^\s+//;
    $fixme =~ s/\s+$//;
    $fixme =~ s/,|\.//g;
    $fixme = lc($fixme);
    return $fixme;
}

sub found
{
    my $look = $_[0];
    my $list_ref = $_[1];
    foreach my $val (@{$list_ref})
    {
        # print "testing: $val " . length($val). " : $look " . length($look) . "\n";
        
        # It is vital that you use quoting in if $look ever has regex special characters like ( or ) or [.

        if ($val =~ m/^\Q$look\E$/) # or $val eq $look)
        {
            # print "matches: $val : $look\n";
            return 1;
        }
    }
    # print "no $look in " . Dumper($list_ref);
    return 0;
}
