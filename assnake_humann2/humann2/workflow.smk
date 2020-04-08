rule humann2:
    input:
        r1 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R1.fastq.gz',
        r2 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R2.fastq.gz',
        mp2 = '{fs_prefix}/{df}/taxa/{preproc}/mp2__def/{df_sample}/{df_sample}.mp2'
    output:
        gf = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
        pc = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathcoverage.tsv',
        pa = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_pathabundance.tsv'
    params:
        wd =     '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/',
        merged = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}.fastq.gz'
    threads: 48
    conda: "../../envs/humann2.yml"
    shell: ('''cat {input.r1} {input.r2} > {params.merged} \n 
               humann2 --taxonomic-profile {input.mp2} \
               --protein-database /data5/bio/databases/humann2/uniref90/uniref \
               --nucleotide-database /data5/bio/databases/humann2/chocophlan/chocophlan \
               --input {params.merged} --output {params.wd} --threads {threads} \n
               rm {params.merged}''') 

mapping = '/data11/bio/databases/KEGG_HUMANN2_BREWED/legacy_kegg_idmapping.tsv'
pathway = '/data11/bio/databases/KEGG_HUMANN2_BREWED/keggc'
custom_db = '/data11/bio/databases/KEGG_HUMANN2_BREWED/BIOCAD_custom_db'

rule humann2_custom_kegg:
    input:
        r1 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R1.fastq.gz',
        r2 = '{fs_prefix}/{df}/reads/{preproc}/{df_sample}_R2.fastq.gz',
        mp2 = '{fs_prefix}/{df}/taxa/mp2__def__v2.96.1/{database}/{df_sample}/{preproc}/{df_sample}.mp2'
    output:
        gf = '{fs_prefix}/{df}/humann2__v2.9__test1/KEGG_BIOCAD__bypass/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
        pc = '{fs_prefix}/{df}/humann2__v2.9__test1/KEGG_BIOCAD__bypass/{df_sample}/{preproc}/{df_sample}_pathcoverage.tsv',
        pa = '{fs_prefix}/{df}/humann2__v2.9__test1/KEGG_BIOCAD__bypass/{df_sample}/{preproc}/{df_sample}_pathabundance.tsv'
    params:
        wd =     '{fs_prefix}/{df}/humann2__v2.9__test1/KEGG_BIOCAD__bypass/{df_sample}/{preproc}/',
        merged = '{fs_prefix}/{df}/humann2__v2.9__test1/KEGG_BIOCAD__bypass/{df_sample}/{preproc}/{df_sample}.fastq.gz'
    threads: 12
    # conda: "../../envs/humann2.yml"
    shell: ('''cat {input.r1} {input.r2} > {params.merged};\n
                source activate humann2;\n
               humann2\
               --id-mapping {mapping} --pathways-database {pathway} \
               --protein-database {custom_db} --bypass-nucleotide-search \
               --input {params.merged} --output {params.wd} --threads {threads} \n
               rm {params.merged}''') 
        
rule humann2_regroup:
    input:
        gf = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_genefamilies.tsv',
    output:
        gf = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}__{groups}.tsv',
    conda: "../../envs/humann2.yml"
    shell: ('''humann2_regroup_table -i {input.gf} -o {output} --custom /data5/bio/databases/humann2/ut_mapping/utility_mapping/{wildcards.groups}.txt.gz''') 
        
rule humann2_norm:
    input:
        gf = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_{groups}.tsv',
    output:
        norm = '{fs_prefix}/{df}/humann2/{db_nucl}__{db_protein}/{df_sample}/{preproc}/{df_sample}_{groups}__norm.tsv'
    conda: "../../envs/humann2.yml"
    shell: ('''humann2_renorm_table --input {input.gf} --units relab --output {output.norm}''') 

        
# /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg
# /data5/bio/runs-jeniaole/tools/kegg/ftp.bioinformatics.jp/kegg
# 1 - Join all of the taxonomic profiles
# humann2_join_tables -i ./ --file_name .mp2 -s -o joined
# 2 - Reduce this file into a taxonomic profile that represents the maximum abundances from all of the samples in your set
# humann2_reduce_table --input joined_taxonomic_profile.tsv --output max_taxonomic_profile.tsv --function max --sort-by level
# 3 - Create a custom Kegg database for your data set, with genus-specific taxonomic limitation, using your joint taxonomic profile
# humann2_build_custom_database --input /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg/genes.pep --output kegg_fhm_db --id-mapping /data5/bio/runs-jeniaole/tools/humann/data/humann2/kegg/kegg_idmapping.tsv --format diamond --taxonomic-profile max_taxonomic_profile.tsv
# humann2 --input $SAMPLE.fastq --output $OUTPUT_DIR --id-mapping legacy_kegg_idmapping.tsv --pathways-database humann1/data/keggc --protein-database custom_database --bypass-nucleotide-search
