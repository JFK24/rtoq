#!/bin/bash
# ==============================================================================
# DOWNLOAD A SELECTED SET OF NGS EXERIMENTS FROM ARRAY EXPRESS DATABASE
# FOR EACH EXERIMENT, A LIMITED NUMBER OF RAW FILES WILL BE DOWNLOADED
# AND PROCESSED WITH QUALITY CONTROL SOFTWARE.
# MORE DETAILS ON THE ARRAY EXPRESS API: https://www.ebi.ac.uk/arrayexpress/help/programmatic_access.html
#
# INPUTS:
# _ t TYPE OF NGS (1 for "RNA-seq of coding RNA"; 2 for "RNA-seq of coding RNA"; 3 for both)
# _ s SPECIES (1 for "homo sapiens"; 2 for "mus musculus"; 3 for both)
# _ e MAX NUMBER OF EXPERIMENTS
# _ f MAX NUMBER OF RAW FILES PER EXPERIMENT
# _ p MAX NUMBER OF PARALLEL THREADS
# _ o OUTPUT DIRECTORY PATH
#
# OUTPUT:
# _ TSV FILE 
# _ ...
# CREATION DATE: 2018-05-14
#
# TO DO:
# 2018-05-14: describe output file + resume coding
#
# ==============================================================================

# ==============================================================================
# GET PARAMETERS
# ==============================================================================

#set -o errexit
set -o nounset
set -o pipefail

OPTS=`getopt -o vht::s::e::f::p::o:: --long verbose,help,experiment-type::,species::,max-experiments::,max-files-per-experiment::,parallel-threads::,output-dir:: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#echo "$OPTS"
eval set -- "$OPTS"

VERBOSE=false
HELP=false
TYPE="ChIP-seq"
SPECIES="homo sapiens"
NEXP=1
NFILES=1
THREADS=1
OUTDIR="."

while true; do
  case "$1" in
    -v | --verbose ) VERBOSE=true; shift ;;
    -h | --help )    HELP=true; shift ;;
    -t | --experiment-type )
        case "$2" in
            "") TYPE='ChIP-seq' ; shift 2 ;;
            *) TYPE=$2 ; shift 2 ;;
        esac ;;
    -s | --species )
        case "$2" in
            "") SPECIES='homo sapiens' ; shift 2 ;;
            *) SPECIES=$2 ; shift 2 ;;
        esac ;;
    -e | --max-experiments ) 
        case "$2" in
            "") NEXP="1" ; shift 2 ;;
            *) NEXP=$2 ; shift 2 ;;
        esac ;;
    -f | --max-files-per-experiment )
        case "$2" in
            "") NFILES=1 ; shift 2 ;;
            *) NFILES=$2 ; shift 2 ;;
        esac ;;
    -p | --parallel-threads )
        case "$2" in
            "") THREADS=1 ; shift 2 ;;
            *) THREADS=$2 ; shift 2 ;;
        esac ;;
    -o | --output-dir )
        case "$2" in
            "") OUTDIR='.' ; shift 2 ;;
            *) OUTDIR=$2 ; shift 2 ;;
        esac ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if [ $VERBOSE = true ]; then
    echo PARAMETERS:
    echo -e "\tVERBOSE=$VERBOSE"
    echo -e "\tHELP=$HELP"
    echo -e "\tTYPE=$TYPE"
    echo -e "\tSPECIES=$SPECIES"
    echo -e "\tNEXP=$NEXP"
    echo -e "\tNFILES=$NFILES"
    echo -e "\tTHREADS=$THREADS"
    echo -e "\tOUTDIR=$OUTDIR"
fi

exit


# ==============================================================================
# ==============================================================================
# ==============================================================================

source ~/.bashrc
source ./config.sh

echo "START" > $LOG
date > $LOG

cd $SRC
# get all experimets
wget -N -O $DATADIR/experiments https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments
# xmllint --format $DATADIR/experiments > $DATADIR/experiments.pretty
#less experiments.pretty

# Get a subset of experiments
#wget -N -O $DATADIR/experiments.subset 'https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?raw=true&species="homo sapiens"&exptype="RNA-seq of coding RNA"'
wget -N -O $DATADIR/experiments.subset 'https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?raw=true&species="homo sapiens"+OR+"mus musculus"&exptype="RNA-seq of coding RNA"+OR+"ChIP-seq"'
#xmllint --format $DATADIR/experiments.subset > $DATADIR/experiments.subset.pretty
#less experiments.subset.pretty

# parsing the experiments
xsltproc --novalid $SRC/xslt/parse_experiments.xslt $DATADIR/experiments > $PROCESSING/experiments.tsv
xsltproc --novalid $SRC/xslt/parse_experiments.xslt $DATADIR/experiments.subset > $PROCESSING/experiments.subset.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_providers.xslt $DATADIR/experiments.subset > $PROCESSING/experiments.subset.providers.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_bioassaydatagroups.xslt $DATADIR/experiments.subset > $PROCESSING/experiments.subset.bioassaydatagroups.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_bibliography.xslt $DATADIR/experiments.subset > $PROCESSING/experiments.subset.bibliography.tsv

wc -l $PROCESSING/experiments.subset.tsv >> $LOG
wc -l $PROCESSING/experiments.subset.providers.tsv >> $LOG
wc -l $PROCESSING/experiments.subset.bioassaydatagroups.tsv >> $LOG
wc -l $PROCESSING/experiments.subset.bibliography.tsv >> $LOG

#less $PROCESSING/experiments.subset.tsv
#grep "EMAIL:" $DATADIR/experiments.subset.tsv | wc -l # 1637
#grep 'rawDATADIR,' $DATADIR/experiments.subset.tsv | grep "Homo sapiens" | wc -l #101
#grep 'scan,' $DATADIR/experiments.subset.tsv | grep "Homo sapiens"  | wc -l #1538
#grep 'Homo sapiens' $DATADIR/experiments.subset.tsv | wc -l #1631
#less $DATADIR/experiments.subset.providers.tsv
#grep "Homo sapiens" $DATADIR/experiments.subset.bioassayDATADIRgroups.tsv | wc -l #2501
#less $DATADIR/experiments.subset.bioassayDATADIRgroups.tsv
#less $DATADIR/experiments.subset.bibliography.tsv


# filtering
#egrep "rawData,|scan," $PROCESSING/experiments.subset.tsv | grep "Homo sapiens" | grep "EMAIL:" | grep "RNA-seq of coding RNA" | grep "PMID:" | wc -l
#egrep "rawData,|scan," $PROCESSING/experiments.subset.tsv | grep -P "\tHomo sapiens\t|\tMus musculus\t" | grep -P "\tRNA-seq of coding RNA\t|\tChIP-seq\t" | grep "EMAIL:" | grep "PMID:" > $PROCESSING/experiments.subset.filtered.tsv
egrep "rawData,|scan," $PROCESSING/experiments.subset.tsv | grep -P "\tHomo sapiens\t|\tMus musculus\t" | grep -P "\tRNA-seq of coding RNA\t|\tChIP-seq\t" | grep "PMID:" > $PROCESSING/experiments.subset.filtered.tsv
wc -l $PROCESSING/experiments.subset.filtered.tsv >> $LOG


# ==============================================================================
# OVERLAP CITED ARTICLES AND AE_EXPERIMENTS DATA
# ==============================================================================

#cut -f 1 $PROCESSING/CITA.cites.tsv > $PROCESSING/CITA.cites.pmids
#cut -f 3 $PROCESSING/experiments.subset.bibliography.tsv > $PROCESSING/experiments.subset.bibliography.pmids
#python3 $SRC/venndata.py inter $PROCESSING/CITA.cites.pmids $PROCESSING/experiments.subset.bibliography.pmids > $PROCESSING/pmc_ae.pmids
##python3 $SRC/venndata.py set1 $PROCESSING/CITA.cites.pmids $PROCESSING/experiments.subset.bibliography.pmids > $PROCESSING/pmc_ae1.pmids
##python3 $SRC/venndata.py set2 $PROCESSING/CITA.cites.pmids $PROCESSING/experiments.subset.bibliography.pmids > $PROCESSING/pmc_ae2.pmids
#wc -l pmc_ae.pmids >> $LOG

cd $PROCESSING/
#time Rscript $SRC/pmc_ae_selection.r $CITANET $PROCESSING/experiments.subset.tsv $AEBIB $INFOS
time Rscript $SRC/pmc_ae_selection.r $CITANET $PROCESSING/experiments.subset.filtered.tsv $AEBIB $INFOS
# pmc_ae_selection.tsv - "id", "pmid", "incites", "outcites", "species", "experimenttype", "bioassaydatagroups", "journal", "year", "date", "pmcid", "doi", "authorsPMC", "authors"
# pmc_ae_selection2014.tsv
# pmc_ae_years.tsv

#wc -l pmc_ae_selection.tsv # 1240
#wc -l pmc_ae_selection2014.tsv # 301


# ==============================================================================
# DOWNLOAD AE FILES (TO DO - PERFORM IT ON THE CLUSTER!)
# ==============================================================================

# # GET AND PROCESS SAMPLES DATA
# cd $DATADIR/samples
# rm -f $DATADIR/samples/*
# time Rscript $SRC/pmc_ae_download.r 500 $PROCESSING/pmc_ae_selection2014.tsv $DATADIR/samples # DEFINE BETTER NUMBER OF LINES !!!
# # rm -f $PROCESSING/pmc_ae_samples_files.tsv
# rm -f $PROCESSING/pmc_ae_samples.tsv
# for f in $DATADIR/samples/*
# do
#   xsltproc --novalid $SRC/xslt/parse_samples.xslt $f >> $PROCESSING/pmc_ae_samples.tsv
# done
#
# # GET FASTQ FILES
# # select few (3) files per experiment and downolad
# rm -f $PROCESSING/pmc_ae_samples_todownload.tsv
# rm -f $PROCESSING/pmc_ae_samples_files.tsv
# time Rscript $SRC/pmc_ae_downloadFastQ.r $PROCESSING/pmc_ae_samples.tsv $DATADIR/samples
# mv $DATADIR/samples/pmc_ae_samples_todownload.tsv $PROCESSING/pmc_ae_samples_todownload.tsv
# mv $DATADIR/samples/pmc_ae_samples_files.tsv $PROCESSING/pmc_ae_samples_files.tsv
# # pmc_ae_samples_todownload.tsv
# # pmc_ae_samples_files.tsv
#
# #ll *.gz | wc -l
# #192

exit

# ==============================================================================
# Analyze on the cluster
# ==============================================================================
# exit
# ssh andradedb
# cd ~/projects/arrayexpress/
# ./main_fastq_proc.sh
# exit

# ==============================================================================
# Machine Learning
# ==============================================================================

# $SRC/main_learning.sh
