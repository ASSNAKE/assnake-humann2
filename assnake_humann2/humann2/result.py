import click, glob, os
from assnake.core.sample_set import generic_command_individual_samples, generate_result_list
from assnake.cli.cli_utils import sample_set_construction_options, add_options
from assnake.core.result import Result

parameters = [p.split('/')[-1].replace('.json', '') for p in glob.glob('/data11/bio/databases/ASSNAKE/params/tmtic/*.json')]
additional_options = [
    # click.option(
    #     '--params', 
    #     help='Parameters id to use. Available parameter sets: ' + str(parameters), 
    #     required=False, 
    #     default = 'def'
    #     )
    click.option(
        '--protein_db', 
        help='Name of protein database', 
        required=True, 
        default = None
        )
]

@click.command('humann2', short_help='Functional profiling')
    
@add_options(sample_set_construction_options)

@click.option(
        '--protein-db', 
        help='Name of protein database', 
        required=True, 
        default = None
        )
# @add_options(additional_options)
@click.pass_obj
def humann2_invocation(config, protein_db, **kwargs):
    print(config['requested_results'])

    wc_str = '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/{df_sample}_pathabundance__cpm.tsv'
    sample_set, sample_set_name = generic_command_individual_samples(config,  **kwargs)
    kwargs.update({'protein_db': protein_db})
    config['requests'] += generate_result_list(sample_set, wc_str, **kwargs)
    config['requested_results'] += [{'result': 'humann2', 'sample_set': sample_set}]

this_dir = os.path.dirname(os.path.abspath(__file__))
result = Result.from_location(name = 'humann2', location = this_dir, input_type = 'illumina_sample', additional_inputs = None, invocation_command = humann2_invocation)
