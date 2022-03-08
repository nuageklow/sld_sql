!/bin/bash



# username="kareni"
# db="sld_testing"

username="karen"
db="karen_testtest"

cd $PWD
echo "${PWD}"

mv ~/Downloads/*_cleaned.csv ../data/

# create tables + generate a sql file
python zoom_.py 

# run sql
psql -h localhost -U $username -d $db -f "zoom_raw.sql"
psql -h localhost -U $username -d $db -f "zoom_fromweb.sql"