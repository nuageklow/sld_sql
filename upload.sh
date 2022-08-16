rm create.sql
cp template_create.sql create.sql

fileName="event_label_mapping"
# $filename=$1
csvPath="${PWD}/data/${fileName}.csv"
# csvPath="./data/${fileName}.csv"
sed -i 's@csvPath@'"$csvPath"'@' create.sql

# tbl
# tblName=$(basename -- "$csvPath")
tblName=$fileName
sed -i "s/tblName/${tblName}/g" create.sql

tblHeader=$(head -n 1 $csvPath)
sed -i "s/tblHeader/${tblHeader}/g" create.sql


IFS=',' read -a arr <<< "$tblHeader"  # delimit commas
for i in "${arr[@]}"; do
  if [ $i = ${arr[@]: -1} ]; then
      ind_col="${i} VARCHAR(200)";
  else
      ind_col="${i} VARCHAR(200),";
  fi
  newtblHeader+="$ind_col";
done
sed -i "s/fieldNames/${newtblHeader}/g" create.sql


psql -h localhost -U karenion -d postgres -p 5432 -a -q -f ./create.sql