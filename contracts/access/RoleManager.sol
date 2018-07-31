pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/rbac/RBAC.sol";

contract RoleManager is Ownable, RBAC {
  function addAddressToRole(address _operator, string _roleName)
    onlyOwner
    public
  {
    addRole(_operator, _roleName);
  }

  function isAccess(address _operator, string _roleName)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, _roleName);
  }

  function addAddressesToRole(address[] _operators, string _roleName)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToRole(_operators[i], _roleName);
    }
  }

  function removeAddressFromRole(address _operator, string _roleName)
    onlyOwner
    public
  {
    removeRole(_operator, _roleName);
  }

  function removeAddressesFromRole(address[] _operators, string _roleName)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromRole(_operators[i], _roleName);
    }
  }

}
