import click, glob, os
from assnake.core.sample_set import generic_command_individual_samples, generate_result_list
from assnake.cli.cli_utils import sample_set_construction_options, add_options
from assnake.core.result import Result

parameters = [p.split('/')[-1].replace('.json', '') for p in glob.glob('/data11/bio/databases/ASSNAKE/params/tmtic/*.json')]
additional_options = [
    click.option(
        '--params', 
        help='Parameters id to use. Available parameter sets: ' + str(parameters), 
        required=False, 
        default = 'def'
        )
]



@click.command('trimmomatic', short_help='Quality based trimming')

@add_options(sample_set_construction_options)
@add_options(additional_options)
@click.pass_obj
def trimmomatic_invocation(config, **kwargs):
    print(config['requested_results'])

    wc_str = '{fs_prefix}/{df}/reads/{preproc}__tmtic_{params}/{df_sample}_R1.fastq.gz'
    sample_set, sample_set_name = generic_command_individual_samples(config,  **kwargs)
    config['requests'] += generate_result_list(sample_set, wc_str, **kwargs)
    config['requested_results'] += [{'result': 'trimmomatic', 'sample_set': sample_set, 'preprocessing': True, 'preprocessing_addition': 'tmtic_'+kwargs['params']}]

this_dir = os.path.dirname(os.path.abspath(__file__))
result = Result.from_location(name = 'trimmomatic', location = this_dir, input_type = 'illumina_sample', additional_inputs = None, invocation_command = trimmomatic_invocation)
