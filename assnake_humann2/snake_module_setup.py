import os, assnake

import assnake_humann2.humann2.result
from assnake.utils import read_yaml


this_dir = os.path.dirname(os.path.abspath(__file__))

snake_module = assnake.SnakeModule(
    name = 'assnake-humann2', 
    install_dir = this_dir,
    results = [
        assnake_humann2.humann2.result
    ],

    snakefiles = [],
    invocation_commands = []
)
