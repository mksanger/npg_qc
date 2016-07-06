use strict;
use warnings;
use Test::More tests => 42;
use Test::Exception;

use_ok ('npg_qc::autoqc::results::result');

{
    my $r = npg_qc::autoqc::results::result->new(id_run => 2, path => q[mypath], position => 1);
    isa_ok ($r, 'npg_qc::autoqc::results::result');
}


{
    my $r = npg_qc::autoqc::results::result->new(id_run => 2, path => q[mypath], position => 1);
    is($r->check_name(), q[result], 'check name');
    is($r->class_name(), q[result], 'class name');
    is($r->package_name(), q[npg_qc::autoqc::results::result], 'class name');
    is($r->tag_index, undef, 'tag index undefined');
    ok($r->has_composition, 'composition is built');
    my $c = $r->composition->components->[0];
    is($c->id_run, 2, 'component run id');
    is($c->position, 1, 'component position');
    is($c->tag_index, undef, 'component tag index undefined');
    is($c->subset, undef, 'component subset is undefined');

    throws_ok {npg_qc::autoqc::results::result->new(path => q[mypath])}
      qr/Empty composition is not allowed/,
      'object with an empty composition is not built';
    throws_ok {npg_qc::autoqc::results::result->new(position => 1, path => q[mypath])}
      qr/Empty composition is not allowed/,
      'object with an empty composition is not built';
    throws_ok {npg_qc::autoqc::results::result->new(id_run => 3, path => q[mypath])}
      qr/Attribute \(position\) does not pass the type constraint/,
      'position is needed';
}


{
    my $r = npg_qc::autoqc::results::result->new(id_run => 2, path => q[mypath], position => 1, tag_index => 4,);
    is($r->tag_index, 4, 'tag index set');
    lives_ok {npg_qc::autoqc::results::result->new(id_run => 2, path => q[mypath], position => 1, tag_index => 4,)}
       'can pass undef for tag_index in the constructor';
}


{
    my $r = npg_qc::autoqc::results::result->new(
                                        position  => 3,
                                        path      => 't/data/autoqc/090721_IL29_2549/data',
                                        id_run    => 2549,
                                                 );
    my $saved_path = q[/tmp/autoqc_check.json];
    $r->store($saved_path);
    my $saved_r = npg_qc::autoqc::results::result->load($saved_path);
    sleep 1;
    unlink $saved_path;
    is_deeply($r, $saved_r, 'serialization to JSON file');
}

{
    my $r = npg_qc::autoqc::results::result->new(
                                        position  => 3,
                                        path      => 't/data/autoqc/090721_IL29_2549/data',
                                        id_run    => 2549,
                                                 );
    throws_ok {$r->equals_byvalue({})} qr/No parameters for comparison/, 'error when an empty hash is given in equals_byvalue';
    throws_ok {$r->equals_byvalue({position => 3, unknown => 5,})} qr/cannot be compared/, 'error when a hash with an unknown key is used in equals_byvalue';
    ok($r->equals_byvalue({position => 3, id_run => 2549,}), 'equals_byvalue returns true');
    ok($r->equals_byvalue({position => 3, class_name => q[result],}), 'equals_byvalue returns true');
    ok($r->equals_byvalue({position => 3, check_name => q[result], tag_index => undef,}), 'equals_byvalue returns true');
    ok(!$r->equals_byvalue({position => 3, check_name => q[result], tag_index => 0,}), 'equals_byvalue returns false');
    ok(!$r->equals_byvalue({position => 3, check_name => q[result], tag_index => 1,}), 'equals_byvalue returns false');
    ok(!$r->equals_byvalue({position => 3, class_name => q[insert_size],}), 'equals_byvalue returns false');    
}

{
    my $r = npg_qc::autoqc::results::result->new(
                                        position  => 3,
                                        path      => 't/data/autoqc/090721_IL29_2549/data',
                                        id_run    => 2549,
                                        tag_index => 5,
                                                 );
    ok($r->equals_byvalue({position => 3, id_run => 2549, tag_index => 5, }), 'equals_byvalue returns true');
    ok($r->equals_byvalue({position => 3, class_name => q[result],}), 'equals_byvalue returns true');
    ok(!$r->equals_byvalue({position => 3, check_name => q[result], tag_index => undef,}), 'equals_byvalue returns false');
    ok(!$r->equals_byvalue({position => 3, check_name => q[result], tag_index => 0,}), 'equals_byvalue returns false');
    ok(!$r->equals_byvalue({position => 3, check_name => q[result], tag_index => 1,}), 'equals_byvalue returns false'); 
}

{
    my $r = npg_qc::autoqc::results::result->new(
                                        position  => 3,
                                        path      => 't/data/autoqc/090721_IL29_2549/data',
                                        id_run    => 2549,
                                                );
    $r->set_info('Aligner', 'bwa-0.55');
    $r->set_info('Check', 'npg_qc::autoqc::check::sequence_error-7766');
    is($r->get_info('Aligner'), 'bwa-0.55', 'aligner version number stored');
    is($r->get_info('Check'), 'npg_qc::autoqc::check::sequence_error-7766', 'check version number stored')
}

{
    my $r = npg_qc::autoqc::results::result->new(
                                        position  => 3,
                                        path      => 't/data/autoqc/090721_IL29_2549/data',
                                        id_run    => 2549,
                                                );
    is (npg_qc::autoqc::results::result->rpt_key_delim, q[:], 'rpt key delim');
    is (npg_qc::autoqc::role::result->rpt_key_delim, q[:], 'rpt key delim');
    is ($r->rpt_key_delim, q[:], 'rpt key delim');
    is ($r->rpt_key, q[2549:3], 'rpt key');
    
    $r->tag_index(0);
    is ($r->rpt_key, q[2549:3:0], 'rpt key');

    $r->tag_index(3);
    is ($r->rpt_key, q[2549:3:3], 'rpt key');      
}


{
    throws_ok {npg_qc::autoqc::results::result->inflate_rpt_key(q[5;6])} qr/Invalid rpt key/, 'error when inflating rpt key';
    is_deeply(npg_qc::autoqc::results::result->inflate_rpt_key(q[5:6]), {id_run=>5,position=>6,}, 'rpt key inflated');
    is_deeply(npg_qc::autoqc::results::result->inflate_rpt_key(q[5:6:1]), {id_run=>5,position=>6,tag_index=>1}, 'rpt key inflated');
    is_deeply(npg_qc::autoqc::results::result->inflate_rpt_key(q[5:6:0]), {id_run=>5,position=>6,tag_index=>0}, 'rpt key inflated');
}
