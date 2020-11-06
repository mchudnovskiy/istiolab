#!/bin/bash   

function Usage() {
    echo "Usage: $0 file.txt"
    echo ""
    echo "where:"
    echo "      file.txt: file with user names"
    echo ""
}

# Exit if no argument is passed in
if [ $# -lt 1 ] ; then
    Usage
    exit 0
fi

#cleanup
for d in "users" "tmp"
do
    rm -r $d
    mkdir $d
done


while read i; do
    echo "---Preparation for user $i---"
    cp ../templates/lab-ns.yml tmp/lab-ns-$i.yml 
    sed -i '' -e "s/{{NS_TOKEN}}/$i/" tmp/lab-ns-$i.yml 

    kubectl apply -f tmp/lab-ns-$i.yml -n lab-ns-$i

    TOKEN_NAME=$(kubectl -n lab-ns-$i get serviceaccount/lab-ns-$i-user  -o jsonpath='{.secrets[0].name}')
    TOKEN=$(kubectl -n lab-ns-$i  get secret $TOKEN_NAME -o jsonpath='{.data.token}'| base64 --decode)

    echo "User name: lab-ns-$i-user"  >> users/$i.txt   
    echo "User namespace: lab-ns-$i"  >> users/$i.txt 
    echo "User token: $TOKEN"  >> users/$i.txt 
     

    rm tmp/lab-ns-$i.yml 
    sleep 2
done <$1

rm -r tmp