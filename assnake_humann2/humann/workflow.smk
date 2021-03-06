import os

rule merge_files:
    input:
        r1 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R1.fastq.gz',
        r2 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R2.fastq.gz',
        s = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_S.fastq.gz',
    output:
        merged = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}.fastq.gz',
    threads: 12
    shell: "cat {input.r1} {input.r2} {input.s} > {output.merged}"


rule humann2:
    input:
        merged = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}.fastq.gz',
        mp2 = '{fs_prefix}/{df}/taxa/mp3__def__v3.0.0/v30_CHOCOPhlAn_201901/{df_sample}/{preproc}/{df_sample}.rel_ab.tsv'
    output:
        gf = '{fs_prefix}/{df}/humann2__{preset}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
        pc = '{fs_prefix}/{df}/humann2__{preset}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathcoverage.tsv',
        pa = '{fs_prefix}/{df}/humann2__{preset}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathabundance.tsv'
    params:
        wd =     '{fs_prefix}/{df}/humann2__{preset}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/',
    benchmark:      '{fs_prefix}/{df}/humann2__{preset}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/benchmark.txt'
    threads: 12
    shell: ('''humann3 --taxonomic-profile {input.mp2} \
               --protein-database /ssd/DATABASES/HUMANN2/uniref \
               --nucleotide-database /ssd/DATABASES/HUMANN2/chocophlan \
               --input {input.merged} --output {params.wd} --threads {threads}''') 

# rule humann2_regroup:
#     input:
#         gf = '{fs_prefix}/{df}/humann2/{protein_db}__{nucl_db}/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
#     output:
#         gf = '{fs_prefix}/{df}/humann2/{protein_db}__{nucl_db}/{df_sample}/{preproc}/{df_sample}__{groups}.tsv',
#     conda: "../../envs/humann2.yml"
#     shell: ('''humann2_regroup_table -i {input.gf} -o {output} --custom /data11/bio/databases/HUMANN2/utility_mapping/{wildcards.groups}.txt.gz''') 
        
rule humann2_norm:
    input:
        pa      = '{fs_prefix}/{df}/humann2__{params}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathabundance.tsv',
    output:
        pa_norm_cpm = '{fs_prefix}/{df}/humann2__{params}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathabundance.cpm.tsv',
        pa_norm_relab = '{fs_prefix}/{df}/humann2__{params}__v3.0.0a/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathabundance.relab.tsv',
    # conda: "../../envs/humann2.yml" 
    shell: ('''humann_renorm_table --input {input.pa} --units cpm --output {output.pa_norm_cpm};\n
               humann_renorm_table --input {input.pa} --units relab --output {output.pa_norm_relab};''') 

# mapping = '/data11/bio/databases/KEGG_HUMANN2_BREWED/legacy_kegg_idmapping.tsv'
# pathway = '/data11/bio/databases/KEGG_HUMANN2_BREWED/keggc'
# custom_db = '/data11/bio/databases/KEGG_HUMANN2_BREWED/'

# rule humann2_custom_kegg:
#     input:
#         r1 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R1.fastq.gz',
#         r2 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R2.fastq.gz',
#         mp2 = '{fs_prefix}/{df}/taxa/mp2__def__v2.96.1/v296_CHOCOPhlAn_201901/{df_sample}/{preproc}/{df_sample}.mp2',
#         protein_db_dir = os.path.join(custom_db, '{protein_db}')
#     output:
#         gf = '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
#         pc = '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/{df_sample}_pathcoverage.tsv',
#         pa = '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/{df_sample}_pathabundance.tsv'
#     params:
#         wd =     '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/',
#         merged = '{fs_prefix}/{df}/humann2__v2.9__test1/{protein_db}__bypass/{df_sample}/{preproc}/{df_sample}.fastq.gz'
#     threads: 8
#     # conda: "../../envs/humann2.yml"
#     shell: ('''cat {input.r1} {input.r2} > {params.merged};\n
#                 set +eu;source activate humann2;\n
#                humann2\
#                --id-mapping {mapping} --pathways-database {pathway} \
#                --protein-database {input.protein_db_dir} --bypass-nucleotide-search \
#                --input {params.merged} --output {params.wd} --threads {threads} \n
#                rm {params.merged};\n
#                set -eu;''') 
        


        
# /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg
# /data5/bio/runs-jeniaole/tools/kegg/ftp.bioinformatics.jp/kegg
# 1 - Join all of the taxonomic profiles
# humann2_join_tables -i ./ --file_name .mp2 -s -o joined
# 2 - Reduce this file into a taxonomic profile that represents the maximum abundances from all of the samples in your set
# humann2_reduce_table --input joined_taxonomic_profile.tsv --output max_taxonomic_profile.tsv --function max --sort-by level
# 3 - Create a custom Kegg database for your data set, with genus-specific taxonomic limitation, using your joint taxonomic profile
# humann2_build_custom_database --input /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg/genes.pep --output kegg_fhm_db --id-mapping /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg/kegg_idmapping.tsv --format diamond --taxonomic-profile max_taxonomic_profile.tsv
# humann2 --input $SAMPLE.fastq --output $OUTPUT_DIR --id-mapping legacy_kegg_idmapping.tsv --pathways-database humann1/data/keggc --protein-database custom_database --bypass-nucleotide-search
