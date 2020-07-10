
import click, os
from assnake.core.result import Result

result = Result.from_location(name='humann',
                              description='Functional profiling with Humann 3.0.0 alpha',
                              result_type='functional',
                              location=os.path.dirname(os.path.abspath(__file__)),
                              input_type='illumina_sample',
                              additional_inputs=[
                                  click.option('--preset', help='Preset to use. Available presets: ', default='def'),
                              ])
