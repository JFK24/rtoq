#!/bin/bash

# ==============================================================================
# LOAD ENV VARIABLES FROM CONFIG FILE
# ==============================================================================
source ~/.bashrc
source ./config.sh

echo "START" > $LOG
date > $LOG

cd $SRC

ARCHIVES_PMC=(articles.A-B.xml.tar.gz,articles.C-H.xml.tar.gz,articles.I-N.xml.tar.gz,articles.O-Z.xml.tar.gz)
ARCHIVES_MAN=(PMC002XXXXXX.xml.tar.gz,PMC003XXXXXX.xml.tar.gz,PMC004XXXXXX.xml.tar.gz,PMC005XXXXXX.xml.tar.gz)
ARCHIVES=($ARCHIVES_PMC,$ARCHIVES_MAN)
ARCHIVES_PMC_URLS=(ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.A-B.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.C-H.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.I-N.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.O-Z.xml.tar.gz)
ARCHIVES_MAN_URLS=(ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC002XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC003XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC004XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC005XXXXXX.xml.tar.gz)
ARCHIVES_URLS=(ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.A-B.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.C-H.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.I-N.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.O-Z.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC002XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC003XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC004XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC005XXXXXX.xml.tar.gz)


ARCHIVES_URLS_TEST=(ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC002XXXXXX.xml.tar.gz,ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/manuscript/PMC005XXXXXX.xml.tar.gz)

# echo ${ARCHIVES_PMC[*]}
# echo ${ARCHIVES_MAN[*]}
# echo ${ARCHIVES[*]}
# echo ${ARCHIVES_URLS[*]}


# ==============================================================================
# PROCESSING PUBMED
# ==============================================================================

# # create table of information about articles and MeSH2PubMed
# #ssh web mysql -e "SELECT pmid, journal, year, date, pmcid, doi FROM infos;" jfontain_Medline > $DATADIR/infos.tsv
# #ssh web mysql -e "SELECT pmid, major, name FROM $M2PTABLE;" jfontain_Medline > $DATADIR/$M2PTABLE.tsv
# mysql -e "SELECT pmid, journal, year, date, pmcid, doi, authors FROM infos;" jfontain_Medline > $DATADIR/infos.tsv
# #mysql -e "SELECT pmid, journal, year, date, pmcid, doi, authors FROM infos WHERE year>=2008;" jfontain_Medline > $DATADIR/infos.tsv
# mysql -e "SELECT pmid, major, name FROM $M2PTABLE;" jfontain_Medline > $DATADIR/$M2PTABLE.tsv

ll $DATADIR/infos.tsv >> $LOG
ll $DATADIR/$M2PTABLE.tsv >> $LOG


# ==============================================================================
# DOWNLOAD AND EXTRACT PMC XML FILES

cd $PMCDIR

CPUS=8
nice -n 19 time R --no-save -q "$ARCHIVES_URLS" << EOF
  setwd("$PMCDIR");
  library(parallel);
  clus <- makeCluster($CPUS);
  args <- commandArgs();
  data <- unlist(strsplit(args[4],","));
  val <- parSapply(
      clus,
      data,
      function(row){
        # system(paste("/bin/echo /usr/bin/wget -N ", row, sep=""));
        # system(paste("/bin/echo tar xzf ", basename(row), sep=""));
        # system(paste("/bin/echo 'tar ztf $PMCDIR/", basename(row), " | egrep \"xml$\" > ", basename(row), ".files'", sep=""));
        # wget -N ftp://ftp.ncbi.nlm.nih.gov/pub/pmc/articles.A-B.xml.tar.gz
        # tar xzf $PMCDIR/articles.A-B.xml.tar.gz
        # tar ztf $PMCDIR/articles.A-B.xml.tar.gz | egrep "xml$" >  $PMCFILES && \
        # system(paste("/usr/bin/wget -N ", row, sep=""));
        download.file(row, basename(row), "wget", quiet = TRUE, extra = "-N");
        system(paste("tar xzf ", basename(row), sep=""));
        system(paste("tar ztf $PMCDIR/", basename(row), " | egrep \"xml$\" > ", basename(row), ".files", sep=""));
        return(row);
      }
  );
  stopCluster(clus);
EOF

# COLLECT INDIVIDUAL XML FILE NAMES
find $PMCDIR -name "*.files" -print0 | xargs -0 -I file cat file > $PMCFILES
sed -e "s,^,$PMCDIR/," -i $PMCFILES
find $PMCDIR -name "*.files" -delete
wc -l $PMCFILES >> $LOG # 2021764


# ==============================================================================
# PROCESS PMC XML FILES INTO Author and Citations DATA

cd $SRC
# CLEAN
rm -f $OUTPUT_AUTH $OUTPUT_AUTH.gz $OUTPUT_CITA $OUTPUT_CITA.gz
find $PMCDIR -type f -name "*tsv" -delete

# PROCESS IN PARALLEL
CPUS=20
nice -n 19 time R --no-save << EOF
    library(parallel);
    clus <- makeCluster($CPUS);
    data <- read.delim("$PMCFILES", stringsAsFactors=F, header = FALSE);
    data <- cbind(data[,1], as.numeric(c(1:length(data))));
#    data <- cbind(data[1:2000,1], c(1:2000));
    val <- parRapply(
        clus,
        data,
        function(row){
            system(paste("/home/jfontain/opt/bin/xsltproc --novalid $SRC/xslt/parse_authors.xslt '", row[1], "' > '", paste(row[1], ".auth.tsv", sep=""), "'", sep=""));
            system(paste("/home/jfontain/opt/bin/xsltproc --novalid $SRC/xslt/parse_citations.xslt '", row[1], "' > '", paste(row[1], ".cita.tsv", sep=""), "'", sep=""));
            return(row[1]);
        }
    );
    stopCluster(clus);
EOF
# 1h28 (CPUS=40)
# kill -9 `ps -ef | grep "/usr/lib/R/bin/exec/R" | grep -v grep | awk '{print $2}'`
# find $PMCDIR -type f -name "*tsv" -delete

# CONCATENATE RESULTING FILES
time find $PMCDIR -name "*auth.tsv" -print0 | xargs -0 -I file cat file > $OUTPUT_AUTH #
time find $PMCDIR -name "*cita.tsv" -print0 | xargs -0 -I file cat file > $OUTPUT_CITA #

echo "AUTH.TSV" >> $LOG
wc -l $OUTPUT_AUTH >> $LOG # 12 226 253
echo "CITA.TSV" >> $LOG
wc -l $OUTPUT_CITA >> $LOG # 78 671 795

# CLEAN
echo "AUTH FILES - TOTAL" >> $LOG
find $PMCDIR -type f -name "*auth.tsv" | wc -l >> $LOG        # 2021764
echo "AUTH FILES - EMPTY" >> $LOG
find $PMCDIR -type f -name "*auth.tsv" -empty | wc -l >> $LOG #   39583
echo "CITA FILES - TOTAL" >> $LOG
find $PMCDIR -type f -name "*cita.tsv" | wc -l >> $LOG        # 2021764
echo "CITA FILES - EMPTY" >> $LOG
find $PMCDIR -type f -name "*cita.tsv" -empty | wc -l >> $LOG #  177976

find $PMCDIR -type f -name "*tsv" -delete

# REPLACE EMPTY FIELDS BY \N FOR MYSQL
time awk -F"\t" -v OFS="\t" '{
        for (i=1;i<=NF;i++) {
          if ($i == "") $i="\N"
        }
        print $0;
  }' $OUTPUT_CITA > $OUTPUT_CITA.processed

# N_LINES=1000000
# time zcat $OUTPUT_CITA.zip |
# #head -n $N_LINES |
# awk -F"\t" -v OFS="\t" '{
#        for (i=1;i<=NF;i++) {
#          if ($i == "") $i="\N"
#        }
#        print $0;
#  }' > $OUTPUT_CITA.processed

# COMPRESS
pigz -f $OUTPUT_AUTH
pigz -f $OUTPUT_CITA
pigz -f $OUTPUT_CITA.processed

# ==============================================================================
# CREATE NETWORK OF CITATIONS FOR OA ARTICLES (PMID-incites-outcites-journal)

#zcat ../CITA.tsv.gz | head -n 500000 > ../CITA.small.tsv
#gzip -f ../CITA.small.tsv
#time ./cita2network.py ../CITA.small.tsv.gz > CITA.small.cites.tsv
#sort -rt $'\t' -k 2,2 -V CITA.small.cites.tsv | head
#sort -rt $'\t' -k 2,2 -V CITA.small.cites.tsv | head -n 219 | sort -rt $'\t' -k 4,4 -V
#bsub -J "cita2net" -q andradeinf -app Reserve10G -u fontaine@uni-mainz.de -e $LOG -o $PROCESSING/CITA.cites.tsv python3 $SRC/cita2network.py $PROCESSING/CITA.tsv.gz
time python3 $SRC/cita2network.py $PROCESSING/CITA.tsv.gz > $PROCESSING/CITA.cites.tsv # 13 min
#head $PROCESSING/CITA.cites.tsv
#sort -rt $'\t' -k 2,2 -V $DATADIR/CITA.cites.tsv | head -n 50
#sort -rt $'\t' -k 2,2 -V $DATADIR/CITA.cites.tsv | head -n 671128 | sort -rt $'\t' -k 4,4 -V | head -n 50
#tail -n +76 $PROCESSING/CITA.network.tsv | head -n -6 > $PROCESSING/CITA.network.tsv.clean
#mv $PROCESSING/CITA.network.tsv.clean $PROCESSING/CITA.cites.tsv


