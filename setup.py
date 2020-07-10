from typing import Union

from setuptools import setup, find_packages
from setuptools.command.develop import develop
from setuptools.command.install import install
import os, shutil
import click


setup(
    name='assnake-humann2',
    version='0.0.1',
    include_package_data=True,
    license='MIT',         
    description = 'Humann2 module for assnake',   
    author = 'Dmitry Fedorov',                  
    author_email = 'fedorov.de@gmail.com',      
    url = 'https://github.com/ASSNAKE/assnake-humann2',   
    keywords = ['ILLUMINA', 'NGS', 'METAGENOMIC', 'DATA'], 
    packages=find_packages(),
    entry_points = {
        'assnake.plugins': ['assnake-humann2 = assnake_humann2.snake_module_setup:snake_module']
    },
    install_requires=[
        'assnake'
    ]
)