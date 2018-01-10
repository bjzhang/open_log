192.168.100.236 ct07
192.168.100.231 ct08
192.168.100.190 ct09

#export machine01=ct07
#export machine02=ct08
#export machine03=ct09
export machine01=192.168.100.236
export machine02=192.168.100.231
export machine03=192.168.100.190
export DEPLOY=/home/tidb/deploy

./bin/pd-server --name=pd1 \
                --data-dir=$DEPLOY \
                --client-urls="http://$machine01:2379" \
                --peer-urls="http://$machine01:2380" \
                --initial-cluster="pd1=http://$machine01:2380,pd2=http://$machine02:2380,pd3=http://$machine03:2380" \
                -L "info" \
                --log-file=pd.log

./bin/pd-server --name=pd2 \
                --data-dir=$DEPLOY \
                --client-urls="http://$machine02:2379" \
                --peer-urls="http://$machine02:2380" \
                --initial-cluster="pd1=http://$machine01:2380,pd2=http://$machine02:2380,pd3=http://$machine03:2380" \
                -L "info" \
                --log-file=pd.log

./bin/pd-server --name=pd3 \
                --data-dir=$DEPLOY \
                --client-urls="http://$machine03:2379" \
                --peer-urls="http://$machine03:2380" \
                --initial-cluster="pd1=http://$machine01:2380,pd2=http://$machine02:2380,pd3=http://$machine03:2380" \
                -L "info" \
                --log-file=pd.log

./bin/tikv-server --pd="$machine01:2379,$machine02:2379,$machine03:2379" \
                  --addr="$machine01:20160" \
                  --data-dir=tikv \
                  --log-file=tikv.log

./bin/tikv-server --pd="$machine01:2379,$machine02:2379,$machine03:2379" \
                  --addr="$machine02:20160" \
                  --data-dir=tikv \
                  --log-file=tikv.log

./bin/tikv-server --pd="$machine01:2379,$machine02:2379,$machine03:2379" \
                  --addr="$machine03:20160" \
                  --data-dir=tikv \
                  --log-file=tikv.log

./bin/tidb-server --store=tikv \
                  --path="$machine01:2379,$machine02:2379,$machine03:2379" \
                  --log-file=tidb.log

mysql -h $machine01 -P 4000 -u root -D test
