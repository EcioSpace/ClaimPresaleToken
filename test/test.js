const Claimtoken = artifacts.require('Claimtoken');
const Presales = artifacts.require('Presales');

contract('Claimtoken', ([owner, user, someuser]) => {
  it('Should call mapping from Presales Contract', async () => {
    // deploy Claimtoken & Presales;
    let marketPlace = await Claimtoken.new({ from: owner });
    let proxyContract = await Presales.new({ from: owner });




    // check mapping
    assert.equal(await marketInstance.getfeesRate(), '425');



  });
});
