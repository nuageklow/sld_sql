# !/bin/bash


# grep -Po '(?<=\[).+?(?=\])' ../data/tables/age_insights.manifest | head -1 >> ../data/out_tables/ig.csv

rm ../data/out_tables/*

for f in ../data/tables/*; do

    if test -d $f; then 
        fileName="$(basename $f)"
        # cat $f/* >> .../data/out_tables/ig.csv
        grep -Po '(?<=\[).+?(?=\])' ../data/tables/$fileName.manifest | head -1 >> ../data/out_tables/ig_$fileName.csv
        cat $f/* >> ../data/out_tables/ig_$fileName.csv
    fi
done

# cat ../data/out_tables/ig.csv

# grep -Po '(?<=\[).+?(?=\])' in/tables/age_insights.manifest | head -1 >> out/tables/insight.csv

for f in in/tables/*; do 
    if test -d $f; then 
        fileName="$(basename $f)"
        grep -Po '(?<=\[).+?(?=\])' ../data/tables/$fileName.manifest | head -1 >> ../data/out_tables/ig_$fileName.csv
        cat $f/* >> ../data/out_tables/ig_$fileName.csv
    fi
done