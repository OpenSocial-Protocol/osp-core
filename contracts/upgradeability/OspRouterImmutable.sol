// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import './IRouter.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';
import '@openzeppelin/contracts/proxy/Proxy.sol';
import '@openzeppelin/contracts/utils/Multicall.sol';

contract OspRouterImmutable is Multicall, ERC165, IRouter, Proxy {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    /*///////////////////////////////////////////////////////////////
                    struct and event definitions
    //////////////////////////////////////////////////////////////*/
    struct Data {
        address admin;
        EnumerableSet.Bytes32Set allSelectors;
        mapping(address => EnumerableSet.Bytes32Set) selectorsForRouter;
        mapping(bytes4 => Router) routerForSelector;
        address pendingAdmin;
        uint96 pendingAdminTimestamp;
    }

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    event ChangeAdminStarted(address pendingAdmin, uint256 pendingAdminTimestamp);

    event PendingAdminRevoked(address pendingAdmin);

    /*///////////////////////////////////////////////////////////////
                    Constructor + initializer logic
    //////////////////////////////////////////////////////////////*/

    constructor(address admin_) {
        _changeAdmin(admin_);
    }

    /*///////////////////////////////////////////////////////////////
                            routerStorage
    //////////////////////////////////////////////////////////////*/

    bytes32 internal constant ROUTER_STORAGE_POSITION = keccak256('osp.router.storage');

    function routerStorage() internal pure returns (Data storage routerData) {
        bytes32 position = ROUTER_STORAGE_POSITION;
        assembly {
            routerData.slot := position
        }
    }

    /*///////////////////////////////////////////////////////////////
                                ERC 165
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        if (interfaceId == type(IRouter).interfaceId || super.supportsInterface(interfaceId)) {
            return true;
        } else {
            address implementation = _implementation();
            return
                implementation == address(0)
                    ? false
                    : IERC165(implementation).supportsInterface(interfaceId);
        }
    }

    /*///////////////////////////////////////////////////////////////
                        Generic contract logic
    //////////////////////////////////////////////////////////////*/
    modifier onlyAdmin() {
        Data storage data = routerStorage();
        require(msg.sender == data.admin, 'Router: Not authorized.');
        _;
    }

    /*///////////////////////////////////////////////////////////////
                        External functions
    //////////////////////////////////////////////////////////////*/

    function changeAdmin(address _newAdmin) public onlyAdmin {
        Data storage data = routerStorage();
        data.pendingAdmin = _newAdmin;
        data.pendingAdminTimestamp = uint96(block.timestamp);
        emit ChangeAdminStarted(_newAdmin, block.timestamp);
    }

    function revokePendingAdmin() public onlyAdmin {
        Data storage data = routerStorage();
        address pendingAdmin = data.pendingAdmin;
        data.pendingAdmin = address(0);
        data.pendingAdminTimestamp = 0;
        emit PendingAdminRevoked(pendingAdmin);
    }

    function acceptAdminRole() public {
        Data storage data = routerStorage();
        require(
            msg.sender == data.pendingAdmin &&
                block.timestamp > data.pendingAdminTimestamp + 1 days,
            'Router: Admin role not available.'
        );
        _changeAdmin(data.pendingAdmin);
        data.pendingAdmin = address(0);
        data.pendingAdminTimestamp = 0;
    }

    function getAdmin() public view returns (address) {
        Data storage data = routerStorage();
        return data.admin;
    }

    function getPendingAdmin() public view returns (address) {
        Data storage data = routerStorage();
        return data.pendingAdmin;
    }

    function getPendingAdminTimestamp() public view returns (uint96) {
        Data storage data = routerStorage();
        return data.pendingAdminTimestamp;
    }

    /// @dev Add functionality to the contract.
    function addRouter(Router memory _router) public onlyAdmin {
        _addRouter(_router);
    }

    /// @dev Update or override existing functionality.
    function updateRouter(Router memory _router) public onlyAdmin {
        _updateRouter(_router);
    }

    /// @dev Remove existing functionality from the contract.
    function removeRouter(bytes4 selector, string calldata functionSignature) public onlyAdmin {
        _removeRouter(selector, functionSignature);
    }

    /*///////////////////////////////////////////////////////////////
                            View functions
    //////////////////////////////////////////////////////////////*/

    /// @dev View address of the plugged-in functionality contract for a given function signature.
    function getRouterForFunction(bytes4 _selector) public view returns (address) {
        return _getRouterForFunction(_selector);
    }

    /// @dev View all funtionality as list of function signatures.
    function getAllFunctionsOfRouter(
        address _routerAddress
    ) public view returns (bytes4[] memory registered) {
        Data storage data = routerStorage();
        uint256 count = data.selectorsForRouter[_routerAddress].length();

        registered = new bytes4[](count);
        for (uint256 i; i < count; i += 1) {
            registered[i] = bytes4(data.selectorsForRouter[_routerAddress].at(i));
        }
    }

    /// @dev View all funtionality existing on the contract.
    function getAllRouters() public view returns (Router[] memory registered) {
        Data storage data = routerStorage();
        EnumerableSet.Bytes32Set storage selectors = data.allSelectors;
        uint256 count = selectors.length();
        registered = new Router[](count);
        for (uint256 i; i < count; i += 1) {
            registered[i] = data.routerForSelector[bytes4(selectors.at(i))];
        }
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/
    function _implementation() internal view virtual override returns (address) {
        address router = _getRouterForFunction(msg.sig);
        require(router != address(0), 'Router: Not found.');
        return router;
    }

    /// @dev View address of the plugged-in functionality contract for a given function signature.
    function _getRouterForFunction(bytes4 _selector) public view returns (address) {
        Data storage data = routerStorage();
        return data.routerForSelector[_selector].routerAddress;
    }

    /// @dev Add functionality to the contract.
    function _addRouter(Router memory _router) internal {
        Data storage data = routerStorage();
        require(
            data.allSelectors.add(bytes32(_router.functionSelector)),
            'Router: router exists for function.'
        );
        require(
            _router.functionSelector ==
                bytes4(keccak256(abi.encodePacked(_router.functionSignature))),
            'Router: fn selector and signature mismatch.'
        );

        data.routerForSelector[_router.functionSelector] = _router;
        data.selectorsForRouter[_router.routerAddress].add(bytes32(_router.functionSelector));

        emit RouterAdded(_router.functionSelector, _router.routerAddress);
    }

    /// @dev Update or override existing functionality.
    function _updateRouter(Router memory _router) internal {
        address currentRouter = getRouterForFunction(_router.functionSelector);
        require(currentRouter != address(0), 'Router: No router available for selector.');
        require(
            _router.functionSelector ==
                bytes4(keccak256(abi.encodePacked(_router.functionSignature))),
            'Router: fn selector and signature mismatch.'
        );

        Data storage data = routerStorage();
        data.allSelectors.add(bytes32(_router.functionSelector));
        data.routerForSelector[_router.functionSelector] = _router;
        data.selectorsForRouter[currentRouter].remove(bytes32(_router.functionSelector));
        data.selectorsForRouter[_router.routerAddress].add(bytes32(_router.functionSelector));

        emit RouterUpdated(_router.functionSelector, currentRouter, _router.routerAddress);
    }

    /// @dev Remove existing functionality from the contract.
    function _removeRouter(bytes4 _selector, string calldata _functionSignature) internal {
        Data storage data = routerStorage();
        address currentRouter = _getRouterForFunction(_selector);
        require(currentRouter != address(0), 'Router: No router available for selector.');
        require(
            _selector == bytes4(keccak256(abi.encodePacked(_functionSignature))),
            'Router: fn selector and signature mismatch.'
        );

        delete data.routerForSelector[_selector];
        data.allSelectors.remove(_selector);
        data.selectorsForRouter[currentRouter].remove(bytes32(_selector));

        emit RouterRemoved(_selector, currentRouter);
    }

    function _changeAdmin(address admin_) internal {
        Data storage data = routerStorage();
        emit AdminChanged(data.admin, admin_);
        data.admin = admin_;
    }
}
