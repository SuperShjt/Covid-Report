LINUX_OUT_AREA=/home/cloudera/covid_project/landing_zone/out

hive -e 'set hive.cli.print.header=true; select * from covid_db.covid_final_output;' | sed 's/[\t]/,/g' | head -n -2  > $LINUX_OUT_AREA/out.csv
echo "fetched results to out.csv sucessfully"

