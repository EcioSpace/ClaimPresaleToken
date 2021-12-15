const Claimtoken = artifacts.require('Claimtoken');
const Presales = artifacts.require('Presales');

contract('Claimtoken', ([owner, user, someuser]) => {
  it('Should call mapping from Presales Contract', async () => {
    // deploy Claimtoken
    let marketPlace = await Claimtoken.new({ from: someuser });

    // deploy Presales
    let proxyContract = await Presales.new(marketPlace.address, data, { from: owner });

    // check mapping

    assert.equal(await marketInstance.getfeesRate(), '425');


    
  });
});
