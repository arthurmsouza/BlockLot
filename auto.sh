# TOKEN에 최신 토큰 받아와서 아래에 넣어주기.
# TOKEN="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NjQ3NjkzNTgsInVzZXJuYW1lIjoiTG90dGVyeVNlcnZlciIsIm9yZ05hbWUiOiJPcmcxIiwiaWF0IjoxNTI4NzY5MzU4fQ.uPYpLGQaIWvqJ-SIRm4M38Enn5m4iWhn-WK2p0t_WGA"
TOKEN=$(head TOKEN)
chaincodeName="lottery"
chaincodeVersion="v0"
chaincodeType="golang"
chaincodePath="github.com/lottery_cc"
channelName="mychannel"

peers="[\"peer0.org1.example.com\",
        \"peer1.org1.example.com\",
        \"peer2.org1.example.com\",
        \"peer3.org1.example.com\",
        \"peer4.org1.example.com\",
        \"peer5.org1.example.com\",
        \"peer6.org1.example.com\"
        ]"

# Fake names for sample lottery
fakeNames="`pwd`/data/fake-names"

oneh="$fakeNames/100-americans.txt"
twoh="$fakeNames/200-koreans.txt"
fourh="$fakeNames/400-russians.txt"
eighth="$fakeNames/800-chineses.txt"

function echoToken() {
    echo $TOKEN
}

function echoFakeNames() {
    echo $oneh
    echo $twoh
    echo $fourh
    echo $eighth
}

function createChannels() {
    curl -s -X POST \
        http://localhost:4000/channels \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json" \
        -d '{
            "channelName":"mychannel",
            "channelConfigPath":"../artifacts/channel/mychannel.tx"
        }'  
}

function joinChannel() {
    reqBody="{
        \"peers\": $peers
    }"
    curl -s -X POST \
        http://localhost:4000/channels/mychannel/peers \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json" \
        -d "$reqBody"
}

function chaincodesInstall() {
    reqBody="{
        \"chaincodeName\":\"$chaincodeName\",
        \"chaincodePath\":\"$chaincodePath\",
        \"chaincodeType\": \"$chaincodeType\",
        \"chaincodeVersion\":\"$chaincodeVersion\",
        \"peers\": $peers
    }"
    curl -s -X POST \
        http://localhost:4000/chaincodes \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json" \
        -d "$reqBody"
}

function chaincodesInstantiate() {
    fakeNames100=$(cat $oneh | paste -s -d ',')
    fakeNames200=$(cat $twoh | paste -s -d ',')
    fakeNames400=$(cat $fourh | paste -s -d ',')
    fakeNames800=$(cat $eighth | paste -s -d ',')

    reqBody="{
        \"chaincodeName\":\"$chaincodeName\",
        \"chaincodeType\": \"$chaincodeType\",
        \"chaincodeVersion\":\"$chaincodeVersion\",
        \"peers\": $peers,
        \"args\":[\"$fakeNames100\", \"$fakeNames200\", \"$fakeNames400\", \"$fakeNames800\"]
    }"
    curl -s -X POST \
        http://localhost:4000/channels/mychannel/chaincodes \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json" \
        -d "$reqBody"
}

function chaincodesUpgrade() {
    reqBody="{
        \"chaincodeName\":\"$chaincodeName\",
        \"chaincodeType\": \"$chaincodeType\",
        \"chaincodeVersion\":\"$chaincodeVersion\",
        \"peers\": $peers,
        \"args\":[\"\"]
    }"
    curl -s -X POST \
        http://localhost:4000/channels/mychannel/chaincodes/upgrade \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json" \
        -d "$reqBody"
}

# Query pre-registered lottery
function chaincodeQuery() {
    # fcn="query_lottery_event_hash"
    fcn="invoke"
    # args="[\"query_lottery_event_hash\"]"
    args="query_lottery_event_hash\",\"6b60d2b794832322312lf44d479fd7c634eaf8e3r96e723d5d2224c9222222d1"
    # args="[\"query_lottery_event_hash\",\"6b60d2b794832322312lf44d479fd7c634eaf8e3r96e723d5d2224c9222222d1\"]"
    curl -s -X GET \
        "http://localhost:4000/channels/$channelName/chaincodes/$chaincodeName?peer=peer3.org1.example.com&fcn=$fcn&args=%5B%22"$args"%22%5D" \
        -H "authorization: $TOKEN" \
        -H "content-type: application/json"

}

function networkInitialize() {
    echo "create channels..."
    createChannels
    echo "join channels..."
    joinChannel
    echo "chaincodes Install..."
    chaincodesInstall
    echo "chaincodes Instantiate..."
    chaincodesInstantiate
}

echoToken

networkInitialize

# chaincodesUpgrade
# chaincodeQuery
echoFakeNames

