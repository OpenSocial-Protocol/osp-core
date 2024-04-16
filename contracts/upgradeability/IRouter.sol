// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IRouter {
    /**
     *  @dev An interface to describe a plug-in.
     *
     *  @param functionSelector     4-byte function selector.
     *  @param functionSignature    Function representation as a string. E.g. "transfer(address,address,uint256)"
     *  @param routerAddress        Address of the contract containing the function.
     */
    struct Router {
        bytes4 functionSelector;
        address routerAddress;
        string functionSignature;
    }

    /// @dev Emitted when a functionality is added, or plugged-in.
    event RouterAdded(bytes4 indexed functionSelector, address indexed routerAddress);

    /// @dev Emitted when a functionality is updated or overridden.
    event RouterUpdated(
        bytes4 indexed functionSelector,
        address indexed oldRouterAddress,
        address indexed newRouterAddress
    );

    /// @dev Emitted when a function selector is mapped to a particular plug-in smart contract, during construction of Map.
    event RouterSet(
        bytes4 indexed functionSelector,
        string indexed functionSignature,
        address indexed routerAddress
    );

    /// @dev Emitted when a functionality is removed.
    event RouterRemoved(bytes4 indexed functionSelector, address indexed routerAddress);

    /// @dev Add a new router to the contract.
    function addRouter(Router memory router) external;

    /// @dev Update / override an existing router.
    function updateRouter(Router memory router) external;

    /// @dev Remove an existing router from the contract.
    function removeRouter(bytes4 selector, string calldata functionSignature) external;

    /// @dev Returns the plug-in contract for a given function.
    function getRouterForFunction(bytes4 functionSelector) external view returns (address);

    /// @dev Returns all functions that are mapped to the given plug-in contract.
    function getAllFunctionsOfRouter(address routerAddress) external view returns (bytes4[] memory);

    /// @dev Returns all plug-ins known by Map.
    function getAllRouters() external view returns (Router[] memory);
}
