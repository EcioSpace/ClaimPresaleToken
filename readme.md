
Migrate Contract to testnet
```
truffle migrate -f 2 --to 2 --network testnet
truffle migrate -f 3 --to 3 --network testnet
```

Verify Contract
```
truffle run verify PresaleMockup --network testnet
truffle run verify ClaimtokenV2 --network testnet
```