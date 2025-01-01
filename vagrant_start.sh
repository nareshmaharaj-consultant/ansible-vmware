start=`date +%s`
vagrant up | tee log.txt
end=`date +%s`

runtime=$((end-start))
echo Time taken to complete: $runtime in seconds
