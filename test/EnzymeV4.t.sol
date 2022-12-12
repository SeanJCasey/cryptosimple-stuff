// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IEnzymeFundValueCalculatorRouter {
    function calcNetShareValueInAsset(address _vaultProxy, address _quoteAsset)
        external
        returns (uint256 netShareValue_);
}

interface IEnzymeV4Comptroller {
    function calcGav() external returns (uint256 gav_);

    function callOnExtension(
        address _extension,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external;
}

interface IEnzymeV4Vault {
    function getAccessor() view external returns (address comptrollerProxy_);

    function getOwner() view external returns (address owner_);
}

contract EnzymeV4Test is Test {
    function test_logFundCalcsWithoutMaplePosition() public {
        // Enzyme vars - value calcs
        IEnzymeFundValueCalculatorRouter fundValueCalculatorRouterContract = IEnzymeFundValueCalculatorRouter(0x7c728cd0CfA92401E01A4849a01b57EE53F5b2b9);
        address quoteAsset = 0x9579f735d0C93B5eef064Fe312CA3509BD695206; // USD

        // Enzyme vars - ExternalPositionManager
        address externalPositionManager = 0x1e3dA40f999Cf47091F869EbAc477d84b0827Cf4;
        uint256 removeExternalPositionActionId = 2;

        // CryptoSimple vars
        address aggressiveVault = 0x871812670a3d67067dCE4a4ba036F55cF33a0dec;
        address maplePosition = 0xACf14710b3A8E5F47369eAb81E728e0052811DbF;

        // Derive rest of needed fund vars
        IEnzymeV4Vault vaultContract = IEnzymeV4Vault(aggressiveVault);
        IEnzymeV4Comptroller comptrollerContract = IEnzymeV4Comptroller(vaultContract.getAccessor());

        // Make all further calls as vault owner
        vm.startPrank(vaultContract.getOwner());

        // Untrack Maple position
        comptrollerContract.callOnExtension(externalPositionManager, removeExternalPositionActionId, abi.encode(maplePosition));

        // Log the desired fund calcs
        console.log(fundValueCalculatorRouterContract.calcNetShareValueInAsset(address(vaultContract), quoteAsset));
    }
}
