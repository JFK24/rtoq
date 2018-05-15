#!/bin/bash
# ==============================================================================
# DOWNLOAD A SELECTED SET OF NGS EXERIMENTS FROM ARRAY EXPRESS DATABASE
# FOR EACH EXERIMENT, A LIMITED NUMBER OF RAW FILES WILL BE DOWNLOADED
# AND PROCESSED WITH QUALITY CONTROL SOFTWARE.
# MORE DETAILS ON THE ARRAY EXPRESS API: https://www.ebi.ac.uk/arrayexpress/help/programmatic_access.html
#
# INPUTS:
# _ t TYPE OF NGS ('"RNA-seq of coding RNA"'; '"ChIP-seq"')
# _ s SPECIES ('"homo sapiens"'; '"mus musculus"')
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
#TYPE="ChIP-seq"
#TYPE="RNA-seq of coding RNA"
TYPE='"RNA-seq of coding RNA"+OR+"ChIP-seq"'
#SPECIES="homo sapiens"
#SPECIES="mus musculus"
SPECIES='"homo sapiens"+OR+"mus musculus"'
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


SPECIES="'homo sapiens' 'mus musculus'"


echo ${SPECIES[@]}
arr=$SPECIES

#AE_EXP_BASEURL="https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?"
#AE_EXP_QUERY="raw=true&species=\"homo sapiens\"+OR+\"mus musculus\"&exptype=\"RNA-seq of coding RNA\"+OR+\"ChIP-seq\""
AE_EXP_QUERY="https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?raw=true&species=$SPECIES&exptype=$TYPE"
#echo $AE_EXP_BASEURL$AE_EXP_QUERY
#echo $AE_EXP_QUERY > $LOG



exit

# ==============================================================================
# ==============================================================================
# ==============================================================================

source ~/.bashrc
source ./config.sh

echo "START pmc_ae_download" > $LOG
date >> $LOG

# Get a subset of experiments
#wget -N -O $tOUTDIR/experiments.subset 'https://www.ebi.ac.uk/arrayexpress/xml/v3/experiments?raw=true&species="homo sapiens"+OR+"mus musculus"&exptype="RNA-seq of coding RNA"+OR+"ChIP-seq"'
wget -N -O $OUTDIR/experiments.subset "'$AE_EXP_QUERY'"

#xmllint --format $DATADIR/experiments.subset > $DATADIR/experiments.subset.pretty
#less experiments.subset.pretty

# parsing the experiments
#xsltproc --novalid $SRC/xslt/parse_experiments.xslt $DATADIR/experiments > $PROCESSING/experiments.tsv
xsltproc --novalid $SRC/xslt/parse_experiments.xslt $OUTDIR/experiments.subset > $OUTDIR/experiments.subset.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_providers.xslt $OUTDIR/experiments.subset > $OUTDIR/experiments.subset.providers.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_bioassaydatagroups.xslt $OUTDIR/experiments.subset > $OUTDIR/experiments.subset.bioassaydatagroups.tsv
xsltproc --novalid $SRC/xslt/parse_experiments_bibliography.xslt $OUTDIR/experiments.subset > $OUTDIR/experiments.subset.bibliography.tsv

wc -l $OUTDIR/experiments.subset.tsv >> $LOG
wc -l $OUTDIR/experiments.subset.providers.tsv >> $LOG
wc -l $OUTDIR/experiments.subset.bioassaydatagroups.tsv >> $LOG
wc -l $OUTDIR/experiments.subset.bibliography.tsv >> $LOG

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
egrep "rawData,|scan," $OUTDIR/experiments.subset.tsv | grep -P "\tHomo sapiens\t|\tMus musculus\t" | grep -P "\tRNA-seq of coding RNA\t|\tChIP-seq\t" | grep "PMID:" > $OUTDIR/experiments.subset.filtered.tsv
wc -l $OUTDIR/experiments.subset.filtered.tsv >> $LOG


echo "END pmc_ae_download" > $LOG
date >> $LOG

exit

