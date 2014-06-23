#!/usr/bin/perl -T

my %p;
%p = @ARGV; s/,\z// foreach values %p; # DEPLOYMENT SCRIPT EDITS THIS LINE

use strict;

use Tversky 'cat';

# ------------------------------------------------
# Parameters
# ------------------------------------------------

my @ssrs = 1 .. 95;

my $matching_trials = 10;

# ------------------------------------------------
# Declarations
# ------------------------------------------------

my $o; # Will be our Tversky object.

sub p ($)
   {"<p>$_[0]</p>"}

sub matching_trial
   {my ($key, $ss_reward, $ss_condition, $ll_condition) = @_;
    if (defined $key)
       {$o->okay_page('matching_instructions', cat
            '<p class="long">In this task, you will answer a series of questions.',
            '<p class="long">Each trial will present you with a hypothetical choice between two amounts of money. However, one of the amounts will be left blank. For example, a trial might be:',
                '<ul class="matching">',
                '<li>$20 today',
                '<li>$__ in 1 month',
                '</ul>',
            '<p class="long">Or a trial might involve uncertainty instead of delay:</p>',
                '<ul class="matching">',
                '<li>$20 for sure',
                '<li>$__ with 10% probability',
                '</ul>',
            '<p class="long">In each trial, your task is fill in the blank with an amount that makes the two options equally appealing to you; that is, an amount that makes you indifferent between the two options. It would make sense to fill in the blank with an amount larger than the fixed amount so that you would be compensated for the risk or delay.',
            '<p class="long">Even though these are completely hypothetical decisions, please think carefully and imagine what you would do if you were really offered these choices.');}
    $o->dollars_entry_page($key,
        q(<p>Fill in the blank so you're indifferent between:</p>) .
        '<ul class="matching">' .
        sprintf('<li>$%02d %s', $ss_reward, $ss_condition) .
        "<li>\$__ $ll_condition" .
        '</ul>');}

sub round
   {my $x = shift;
    int($x + ($x < 0 ? -0.5 : 0.5));}

# ------------------------------------------------
# Tasks
# ------------------------------------------------

sub matching_task
   {my ($k, $ss_condition, $ll_condition) = @_;

    $o->loop("m_${k}_iter", sub
       {my $trial = $_ + 1;

        my $ssr = $o->randomly_assign("m_${k}_ssr.$trial", @ssrs);
        matching_trial "m_${k}_response.$trial",
            $ssr, $ss_condition, $ll_condition;

        $trial == $matching_trials and $o->done;});}

my %matching_tasks =
   (delay => sub {matching_task 'delay', 'today', 'in 1 month'},
    risk => sub {matching_task 'risk', 'for sure', 'with 10% probability'});

# ------------------------------------------------
# Mainline code
# ------------------------------------------------

my $see_experimenter_msg = 'The task is complete. Please see the experimenter.';

$o = new Tversky
   (cookie_name_suffix => 'String',
    here_url => $p{here_url},
    database_path => $p{database_path},
    task => $p{task},

    after_consent_prep => sub
       {my $o = shift;
        $o->randomly_assign('first_task', 'risk', 'delay');},

    head => do {local $/; <DATA>},
    footer => "\n\n\n</body></html>\n",

    assume_consent => 1,
    password_hash => $p{password_hash},
    password_salt => $p{password_salt},

    experiment_complete => "<p>$see_experimenter_msg</p>");

$o->run(sub

   {$matching_tasks{$o->getu('first_task')}->();
    $o->okay_page('between_tasks', "<p style='margin-bottom: 20in'>$see_experimenter_msg</p>");
    $matching_tasks{$o->getu('first_task') eq 'risk' ? 'delay' : 'risk'}->();});

__DATA__

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Decision-Making</title>

<style type="text/css">

    h1, form, div.expbody p
       {text-align: center;}

    div.expbody p.long, div.debriefing p
       {text-align: left;}

    input.consent_statement
       {border: thin solid black;
        background-color: white;
        color: black;
        margin-bottom: .5em;}

    div.multiple_choice_box
       {display: table;
        margin-left: auto; margin-right: auto;}
    div.multiple_choice_box > div.row
       {display: table-row;}
    div.multiple_choice_box > div.row > div
       {display: table-cell;}
    div.multiple_choice_box > div.row > div.button
       {padding-right: 1em;
        vertical-align: middle;}
    div.multiple_choice_box > div.row > .body
       {text-align: left;
        vertical-align: middle;}

    input.text_entry, textarea.text_entry
       {border: thin solid black;
        background-color: white;
        color: black;}

    textarea.text_entry
       {width: 90%;}

    ul.matching
       {width: 15em;
        margin-left: auto;
        margin-right: auto;}

</style>
