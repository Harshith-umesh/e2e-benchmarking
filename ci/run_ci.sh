
#!/bin/bash

source ci/env.sh

test_choice=$@                                  #to accept inputs from command line

if [[ ${test_choice} != '' ]]; then
  echo -e "Running chosen tests: "
  for i in ${test_choice};do
    echo -e "${i}"
  done
  test_list=${test_choice}
else
  echo "Running full test"
  test_list=`cat ci/CI_test_list.yml`           #yml file contains the list of test scripts to run from different workloads
  echo -e  "$test_list\n\n"                         
fi

diff_list=`git diff --name-only origin/master`
echo -e "List of files changed : ${diff_list} \n"

cat > results.markdown << EOF
Results for e2e-benchmarking CI Tests
Workload                | Test                           | Result | Runtime  |
------------------------|--------------------------------|--------|----------|
EOF


test_rc=0
bit=0

for test in ${test_list}; do            

  start_time=`date`

  command=${test##*:}                                     #to extract the shell script name to run
  directory=${test%:*}                                    #to extract the workload directory name 
  
  echo -e "\n======================================================================"
  echo -e "     CI test for ${test}                    "
  echo -e "======================================================================\n"

  if [[ ( $directory == scale-perf ) && ( $bit == 0 ) ]]; #check to increment number of worker nodes by 1 and to bring it 
  then                                                    #back to the original count after running all other tests 
    export SCALE=$NEW_WORKER_COUNT
    bit=1
  else
    export SCALE=$ORIGINAL_WORKER_COUNT
  fi

  
  cd workloads/
  cd $directory
  echo $PWD

  (sleep $EACH_TEST_TIMEOUT; sudo pkill -f $command) &  #to kill a workload script if it doesn't execute within default test timeout ; runs in the background
  bash $command                                         #to execute each shell script

  EXIT_STATUS=$?
  if [ "$EXIT_STATUS" -eq "0" ]                         #to check if the workloads exit successfully or not
  then
      result="PASS"
  else
      result="FAIL"
      test_rc=1
  fi

  end_time=`date`
  duration=`date -ud@$(($(date -ud"$end_time" +%s)-$(date -ud"$start_time" +%s))) +%T`
  cd ../..
  
  echo "${directory} | ${command} | ${result} | ${duration}" >> results.markdown

done  

cat results.markdown

exit $test_rc

