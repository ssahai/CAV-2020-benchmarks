#!/bin/bash

NUM_EXP=10

rm -r temp
mkdir temp
cd temp

mod="/model.ucl"
model="_model.ucl"
enu="/enumeration.ucl"
enumeration="_enumeration.ucl"

for dir in ../Models/*/
do
    dir=${dir%*/}           
    cp ${dir}$mod ${dir##*/}$model
    cp ${dir}$enu ${dir##*/}$enumeration
done

printf "\n"
printf "\t\t\t\t\t\tStatistics with separate modules\n"
printf "\t\t\t\t\t\t--------------------------------\n\n"
printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+\n"
printf "|  \t   Filename \t \t | \t LOC \t | \t invariants \t | \t procedures \t | \t pre/post conditions    |\n"
printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+\n"
i=0
for filename in ./*.ucl; do
    loc=$(wc -l $filename | awk '{print $1}')
    inv=$(grep "invariant" $filename | wc -l)
    proc=$(grep "procedure" $filename | wc -l)
    pre=$(grep "requires" $filename | wc -l)
    post=$(grep "ensures" $filename | wc -l)
    printf "| %-30s | \t %-4s\t | \t\t%-4s\t |\t\t%-6s\t | \t\t%-4s \t\t|\n" $(basename ${filename%%.ucl}) $loc $inv $proc $(($pre+$post))
    i=$(($i+1))
    if (($i%2 == 0))
    then
        printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+\n"
    fi
done

printf "\n\n"
printf "\t\t\t\t\t\tStatistics with combined modules\n"
printf "\t\t\t\t\t\t--------------------------------\n\n"
printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+---------------+-------------+\n"
printf "|  \t   Filename \t \t | \t LOC \t | \t invariants \t | \t procedures \t | \t pre/post conditions    |   Wall Time   |   CPU Time  |\n"
printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+---------------+-------------+\n"
for dir in ../Models/*/
do
    dir=${dir%*/}           
    cp ${dir}$mod ${dir##*/}$model
    sys_module_file=${dir##*/}$model
    enum_module_file=${dir##*/}$enumeration
    time_file=${dir##*/}.time
    j=1
    while [[ $j -le $NUM_EXP ]]
    do
        `/usr/bin/time -f "%e,%S,%U" -a -o $time_file uclid -m enumeration $sys_module_file $enum_module_file | tail -n 0`
        j=$(( $j+1 ))
    done
    
    wall_time=0
    cpu_time=0
    while IFS=, read -r col1 col2 col3
    do
        wall_time=$(echo "$wall_time+$col1" | bc) 
        cpu_time=$(echo "$cpu_time+$col2+$col3" | bc)
    done < $time_file

    loc=$(wc -l $sys_module_file | awk '{print $1}')
    inv=$(grep "invariant" $sys_module_file | wc -l)
    proc=$(grep "procedure" $sys_module_file | wc -l)
    pre=$(grep "requires" $sys_module_file | wc -l)
    post=$(grep "ensures" $sys_module_file | wc -l)

    loc_e=$(wc -l $enum_module_file | awk '{print $1}')
    inv_e=$(grep "invariant" $enum_module_file | wc -l)
    proc_e=$(grep "procedure" $enum_module_file | wc -l)
    pre_e=$(grep "requires" $enum_module_file | wc -l)
    post_e=$(grep "ensures" $enum_module_file | wc -l)
    printf "| %-30s | \t %-4s\t | \t\t%-4s\t |\t\t%-6s\t | \t\t%-4s \t\t|\t%-6.2f  |   %6.2f    |\n" ${dir##*/} $(($loc+$loc_e)) $(($inv+$inv_e)) $(($proc+$proc_e)) $(($pre+$post+$pre_e+$post_e)) $(echo "$wall_time/$NUM_EXP" | bc -l) $(echo "$cpu_time/$NUM_EXP" | bc -l)
done
printf "+--------------------------------+---------------+-----------------------+-----------------------+------------------------------+---------------+-------------+\n"
cd ..
rm -r temp
