cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement

inputs:

  fastq_input_file_upstream:
    type: File
    label: "FASTQ input file, upstream"
    format: "http://edamontology.org/format_1930"
    doc: "Reads data in a FASTQ format, upstream strand"

  fastq_input_file_downstream:
    type: File
    label: "FASTQ input file, downstream"
    format: "http://edamontology.org/format_1930"
    doc: "Reads data in a FASTQ format, downstream strand"

  star_indices:
    type: Directory
    label: "STAR indices folder"
    s:isPartOf: "genome/organism"
    s:isBasedOn:
    - class: s:SoftwareApplication
      s:url: "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/star-index.cwl"
      s:locationCreated: "outputs/indices_folder"
    doc: "STAR generated indices"

  clip_3p_end:
    type: int?
    label: "Clip from 3p end"
    doc: "Number of bases to clip from the 3p end"

  clip_5p_end:
    type: int?
    label: "Clip from 5p end"
    doc: "Number of bases to clip from the 5p end"

  chrom_length:
    type: File
    label: "Chromosome length file"
    format: "http://edamontology.org/format_2330"
    s:isPartOf: "genome/organism"
    s:isBasedOn:
    - class: s:SoftwareApplication
      s:url: "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/star-index.cwl"
      s:locationCreated: "outputs/chr_length"
    doc: "Chromosome length file"

  bowtie_indices:
    type: Directory
    label: "BOWTIE indices folder"
    format:
      - http://edamontology.org/format_3484 # ebwt
      - http://edamontology.org/format_3491 # ebwtl
    s:isPartOf: "genome/organism"
    s:isBasedOn:
    - class: s:SoftwareApplication
      s:url: "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/bowtie-index.cwl"
      s:locationCreated: "outputs/indices_folder"
    doc: "Bowtie generated indices"

  annotation:
    type: File
    label: "GTF annotation file"
    format: "http://edamontology.org/format_2306"
    s:isPartOf: "genome/organism"
    s:isBasedOn:
    - class: s:SoftwareApplication
      s:url: "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/star-index.cwl"
      s:locationCreated: "inputs/annotation_input_file"
    doc: "GTF annotation file"

  dutp:
    type: boolean
    label: "dUTP"
    doc: "Enable strand specific dUTP calculation"

  threads:
    type: int?
    label: "Number of threads to run tools"
    doc: "Number of threads for those steps that support multithreading"


outputs:
  bigwig:
    type: File
    format: "http://edamontology.org/format_3006"
    label: "BigWig file"
    doc: "Generated BigWig file"

  star_reads_alignment_log:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "STAR alignment log"
    doc: "STAR alignment log file"

  fastx_quality_stats_upstream_statistics:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "fastx_quality_stats upstream FASTQ file statistics"
    doc: "Fastx statistics file for upstream FASTQ file"

  fastx_quality_stats_downstream_statistics:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "fastx_quality_stats downstream FASTQ file statistics"
    doc: "Fastx statistics file for downstream FASTQ file"

  bambai_pair:
    type: File
    format: "http://edamontology.org/format_2572"
    label: "Coordinate sorted BAM alignment file (+index BAI)"
    doc: "Coordinate sorted BAM file and BAI index file"

  bowtie_reads_alignment_log:
    type: File
    format: "http://edamontology.org/format_2330"
    label: "Bowtie alignment log"
    doc: "Bowtie alignment log file"  # To display plain text

  rpkm_calculation_table:
    type: File
    format:
    - "http://edamontology.org/format_3752" # csv
    - "http://edamontology.org/format_3475" # tsv
    label: "RPKM table file"
    doc: "Calculated rpkm values"  # To display csv/tsv file as a table

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "run-rna-PE"
s:downloadUrl: https://raw.githubusercontent.com/SciDAP/workflows/v0.0.1b/workflows/scidap/run-rna-PE.cwl
s:codeRepository: https://github.com/SciDAP/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:michael.kotliar@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898
      - class: s:Person
        s:name: Andrey Kartashov
        s:email: mailto:Andrey.Kartashov@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0001-9102-5681

s:about: >
  Current workflow should be used only with the paired-end RNA-Seq data. It performs the following steps:
  1. Use STAR to align reads from upstream and downstream FASTQ files according to the predefined reference indices; generates unsorted BAM file and alignment statistics file
  2. Use fastx_quality_stats to analyze upstream and downstream input FASTQ files; generate quality statistics files
  3. Use samtools sort to generate coordinate sorted BAM(+BAI) file pair from the unsorted BAM file obtained on the step 1 (after running STAR)
  4. Calculate basic statistics for sorted BAM file using bamtools stats. Return mapped reads number.
  5. Generate BigWig file on the base of sorted BAM file
  6. Map input upstream and downstream FASTQ files to predefined rRNA reference indices using Bowtie to define the level of rRNA contamination; export resulted statistics
  7. Calculate isoform and gene expression levels for the sorted BAM file and GTF annotation file using SciDAP reads-counting utility; export results to file
  Tasks #2 and #6 are started independently on other workflow steps.
  Workflow doesn't depend on the type of the organism
