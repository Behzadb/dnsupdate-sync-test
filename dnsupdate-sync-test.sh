# Test dns update on dns servers

#!/bin/bash

authorative='192.168.X.X'
recnode1='192.168.X.X'   #directly connected to authorative
recnode2remote='192.168.X.X'
recnode3forwarder='192.168.1.58'

arecordname='record1.speed.test'  ## create speed.test zone in authoraive before running script
arecordip='192.168.25.25'
arecordipupdate='192.168.125.125'



## create nsupdate files
  
    ## Pay attention to TTL(higher values cause remote recursors update slowly)
  echo "server $authorative 53" > ./nsupdateCreate.txt
  echo "zone speed.test" >> ./nsupdateCreate.txt
  echo "update add $arecordname 1 A $arecordip" >> ./nsupdateCreate.txt
  echo "send" >> ./nsupdateCreate.txt  


  echo "server $authorative 53" > ./nsupdateUpdate.txt
  echo "zone speed.test" >> ./nsupdateUpdate.txt
  echo "update delete $arecordname A" >> ./nsupdateUpdate.txt
  echo "update add $arecordname 1 A $arecordipupdate" >> ./nsupdateUpdate.txt
  echo "send" >> ./nsupdateUpdate.txt 

  echo "server $authorative 53" > ./nsupdateDelete.txt
  echo "zone speed.test" >> ./nsupdateDelete.txt
  echo "update delete $arecordname A" >> ./nsupdateDelete.txt
  echo "send" >> ./nsupdateDelete.txt 

## remove previous executions
nsupdate -k key.conf nsupdateDelete.txt
echo ''> resultQueryForwarderCreate.txt
echo ''> resultQueryForwarderUpdate.txt
echo ''> resultQueryCreate.txt
echo ''> resultQueryUpdate.txt
echo ''> resultQueryRemoteUpdate.txt
echo ''> resultQueryRemoteCreate.txt


for i in {1..1}
do 

## nsupdate create record

   nsupdate -k key.conf nsupdateCreate.txt


    ## query record
      result=$(dig @"$recnode1" "$arecordname"  +short A)
        ## save result
          if [ "$arecordip" == "$result" ]; then
            echo '1'>> resultQueryCreate.txt
          else 
            echo '0'>> resultQueryCreate.txt
            echo  "$result"           
          fi
    ## query remote
      sleep 2
      result=$(dig @"$recnode2remote" "$arecordname"  +short A)
        ## save result
          if [ "$arecordip" == "$result" ]; then
            echo '1'>> resultQueryRemoteCreate.txt
          else 
            echo '0'>> resultQueryRemoteCreate.txt 
            echo  "$result"            
          fi

    ## query forwarder
      result=$(dig @"$recnode3forwarder" "$arecordname"  +short A)
        ## save result
          if [ "$arecordip" == "$result" ]; then
            echo '1'>> resultQueryForwarderCreate.txt
          else 
            echo '0'>> resultQueryForwarderCreate.txt
            echo  "$result"             
          fi

## nsupdate update record

   nsupdate -k key.conf nsupdateUpdate.txt


    ## query record
          result=$(dig @"$recnode1" "$arecordname"  +short A)

          if [ "$arecordipupdate" == "$result" ]; then
            echo '1'>> resultQueryUpdate.txt
          else 
            echo '0'>> resultQueryUpdate.txt
          fi

    sleep 2

    ## query remote
      result=$(dig @"$recnode2remote" "$arecordname"  +short A)
        ## save result
          if [ "$arecordipupdate" == "$result" ]; then
            echo '1'>> resultQueryRemoteUpdate.txt
          else 
            echo '0'>> resultQueryRemoteUpdate.txt
          #  echo  "$result"  # Uncomment to print query result if not matched
          fi

      result=$(dig @"$recnode3forwarder" "$arecordname"  +short A)
        ## save result
          if [ "$arecordipupdate" == "$result" ]; then
            echo '1'>> resultQueryForwarderUpdate.txt
          else 
            echo '0'>> resultQueryForwarderUpdate.txt
          fi

## delete record
     nsupdate -k key.conf nsupdateDelete.txt
done


