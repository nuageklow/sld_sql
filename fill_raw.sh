!/bin/bash



username="karenion"
db="sld_testing"

cd $PWD
echo "${PWD}"

mv ~/Downloads/*_cleaned.csv ../data/

# create tables + generate a sql file
python zoom_.py 

# run sql
psql -h localhost -U $username -d $db -f "zoom_raw.sql"