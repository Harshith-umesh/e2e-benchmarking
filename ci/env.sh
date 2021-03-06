#smoke test environment specifications:
export EACH_TEST_TIMEOUT=900s

#for scale perf
export ORIGINAL_WORKER_COUNT=`oc get nodes -l node-role.kubernetes.io/worker | grep -v NAME | wc -l`
export NEW_WORKER_COUNT=$((ORIGINAL_WORKER_COUNT + 1))
export RUNS=1

#for kube burner 
export JOB_ITERATIONS=3
export CLEANUP=true
export CLEANUP_WHEN_FINISH=true
export NODE_COUNT=`oc get nodes -l node-role.kubernetes.io/worker | grep -v NAME | wc -l`
export PODS_PER_NODE=40

#for upgrade perf
export VERSION=`oc get clusterversion | grep -o [0-9.]* | head -1`

#for router perf
export PBENCH_SERVER='pbench.dev.openshift.com'
export COMPARE=false
export HTTP_TEST_SUFFIX='smoke-test'
export HTTP_TEST_SMOKE_TEST=true
export HTTP_TEST_ROUTE_TERMINATION='http' 
export HTTP_TEST_RUNTIME=10
