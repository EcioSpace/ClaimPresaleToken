const Claimtoken = artifacts.require('ClaimtokenTest');
const Presales = artifacts.require('PresaleMockup');
const ECIOToken = artifacts.require('ECIO');

contract('Claimtoken', ([owner, user, someuser]) => {
  it('Should call mapping from Presales Contract', async () => {
    // deploy Claimtoken & Presales;
    let claimtokenContract = await Claimtoken.new({ from: owner });
    let presalesContract = await Presales.new({ from: owner });









    // check mapping
    assert.equal(await marketInstance.getfeesRate(), '425');



  });
});
